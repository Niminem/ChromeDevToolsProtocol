## This module contains the Browser type and related procedures.
## The Browser type is used to interact with a Chrome browser instance,
## create new tabs, close tabs, register and listen for CDP events, etc.

import std/[json, asyncdispatch, tables, os, tempfiles]
import pkg/ws
import base, chrome, ../domains/[target, browser_domain]

{.experimental: "codeReordering".} # remove need for fwd declarations

proc launchBrowser*(userDataDir = "";
                    portNo = 0; headlessMode = HeadlessMode.On;
                    chromeArguments: seq[string] = @[]): Future[Browser] {.async} =
    new result
    if userDataDir == "": result.userDataDir = newTmpUserDataDir()
    else: result.userDataDir = userDataDir
    result.ws = await newWebSocket(startChrome(portNo, result.userDataDir,
                                               headlessMode, chromeArguments))
    asyncCheck result.launchCDPListener()

proc close*(browser: Browser) {.async.} =
    await browser.closeBrowserDomain()
    browser.ws.close()
    for attempt in 1 .. 3:
        await sleepAsync 1000 # wait for browser to close
        try:
            browser.userDataDir.removeDir()
            break
        except OSError as e:
            if attempt == 3: raise e

proc newTab*(browser: Browser): Future[Tab] {.async.} =
    let
        targetId = (await browser.createTarget())["result"]["targetId"].to(string)
        sessionId = (await browser.attachToTarget(targetId))["result"]["sessionId"].to(string)
    result = Tab(browser: browser, sessionId: sessionId)

proc newTmpUserDataDir(): string =
    result = createTempDir("cdp_","_tmpdir")

proc launchCDPListener(browser: Browser) {.async.} =
    while browser.ws.readyState == Open:
        var packet = ""
        try: packet = await browser.ws.receiveStrPacket()
        except WebSocketError: break
        let jsn = parseJson(packet)
        if jsn.hasKey("id"): # CDP response
            let id = jsn["id"].getInt()
            if browser.responseTable.hasKey(id):
                browser.responseTable[id].complete(jsn)
                browser.responseTable.del(id)
        else: # CDP event
            let mthd = jsn["method"].getStr()
            if jsn.hasKey("sessionId"): # CDP Session event
                let sessionId = jsn["sessionId"].getStr()
                if browser.sessionEventTable.hasKey(sessionId):
                    if browser.sessionEventTable[sessionId].hasKey(mthd):
                        # for handler in browser.sessionEventTable[sessionId][mthd]:
                        asyncCheck browser.sessionEventTable[sessionId][mthd](jsn)
            else:
                if browser.globalEventTable.hasKey(mthd): # CDP Global event
                    # for handler in browser.globalEventTable[mthd]:
                    asyncCheck browser.globalEventTable[mthd](jsn)

proc addSessionEventCallback*(browser: Browser; sessionId: SessionId; event: ProtocolEvent; handler: EventHandler) =
    if not browser.sessionEventTable.hasKey(sessionId):
        browser.sessionEventTable[sessionId] = initTable[ProtocolEvent, EventHandler]()
    browser.sessionEventTable[sessionId][event] = handler

proc waitForSessionEvent*(browser: Browser; sessionId: string;
                          event: ProtocolEvent): Future[JsonNode] {.async.} =
    let future = newFuture[JsonNode]()
    browser.addSessionEventCallback(sessionId, event, proc(jsn: JsonNode) {.async.} =
        future.complete(jsn))
    result = await future
    browser.sessionEventTable[sessionId].del(event)

proc addGlobalEventCallback*(browser: Browser; event: ProtocolEvent; handler: EventHandler) =
    browser.globalEventTable[event] = handler

proc waitForGlobalEvent*(browser: Browser; event: ProtocolEvent): Future[JsonNode] {.async.} =
    let future = newFuture[JsonNode]()
    browser.addGlobalEventCallback(event, proc(jsn: JsonNode) {.async.} =
        future.complete(jsn))
    result = await future
    browser.globalEventTable.del(event)

proc deleteSessionEventCallback*(browser: Browser; sessionId: SessionId; event: ProtocolEvent) =
    if browser.sessionEventTable.hasKey(sessionId):
        if browser.sessionEventTable[sessionId].hasKey(event):
            browser.sessionEventTable[sessionId].del(event)
            log "Deleted session event callback for event: " & event

proc deleteGlobalEventCallback*(browser: Browser; event: ProtocolEvent) =
    if browser.globalEventTable.hasKey(event):
        browser.globalEventTable.del(event)
        log "Deleted global event callback for event: " & event