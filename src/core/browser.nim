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
                        for handler in browser.sessionEventTable[sessionId][mthd]:
                            asyncCheck handler(jsn)
            else:
                if browser.globalEventTable.hasKey(mthd): # CDP Global event
                    for handler in browser.globalEventTable[mthd]:
                        asyncCheck handler(jsn)

proc addSessionEvent*(browser: Browser; sessionId: SessionId; event: ProtocolEvent; handler: EventHandler) {.async.} =
    if not browser.sessionEventTable.hasKey(sessionId):
        browser.sessionEventTable[sessionId] = initTable[ProtocolEvent, seq[EventHandler]]()
    if browser.sessionEventTable[sessionId].hasKeyOrPut(event, @[handler]):
        browser.sessionEventTable[sessionId][event].add(handler)