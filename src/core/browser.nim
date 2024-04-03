## This module contains the `Browser` procedures.
## The `Browser` type is used to interact with a Chrome browser instance,
## create new tabs, close tabs, register and listen for CDP events, etc.

import std/[json, asyncdispatch, tables, os, tempfiles, osproc]
import pkg/ws
import base, chrome, ../domains/[target, browser_domain]

{.experimental: "codeReordering".}

proc launchBrowser*(userDataDir = "";
                    portNo = 0; headlessMode = HeadlessMode.On;
                    chromeArguments: seq[string] = @[]): Future[Browser] {.async} =
    new result
    if userDataDir == "":
        var tmpDir: string
        try:
            tmpDir = createTempDir("cdp_","_tmpdir")
        except OSError as e:
            echo "Error creating temp dir: " & e.msg
            raise e
        result.userDataDir = (dir: tmpDir, isTempDir: true)
    else: result.userDataDir = (dir: userDataDir, isTempDir: false)

    let (chrome, endpoint) = startChrome(portNo, result.userDataDir.dir,
                                         headlessMode, chromeArguments)
    result.chrome = chrome
    result.ws = await newWebSocket(endpoint)
    asyncCheck result.launchCDPListener()

proc close*(browser: Browser) {.async.} =
    await browser.closeBrowserDomain()
    browser.ws.close()
    var errorLog: string
    if browser.userDataDir.isTempDir:
        for attempt in 1 .. 3:
            await sleepAsync 1000 # wait for browser to close (3 secs max)
            try:
                browser.userDataDir.dir.removeDir()
                break
            except OSError as e:
                if attempt == 3:
                    errorLog.add("[OsError] error deleting user data dir: " & browser.userDataDir.dir &
                        "message: " & e.msg
                    )
    browser.chrome.terminate()
    browser.chrome.close()
    if errorLog.len > 0:
        raise newException(OSError, errorLog)


proc newTab*(browser: Browser): Future[Tab] {.async.} =
    let
        targetId = (await browser.createTarget())["result"]["targetId"].to(string)
        sessionId = (await browser.attachToTarget(targetId))["result"]["sessionId"].to(string)
    result = Tab(browser: browser, sessionId: sessionId)

proc launchCDPListener(browser: Browser) {.async.} =
    while browser.ws.readyState == Open:
        var packet: string
        try: packet = await browser.ws.receiveStrPacket()
        except WebSocketError: break
        var jsn: JsonNode
        try: jsn = parseJson(packet)
        except JsonParsingError as e:
            echo "error parsing JSON from packet. message: " & e.msg &
                "\npacket received: " & packet
            raise e

        if jsn.hasKey("id"): # CDP response
            let id = jsn["id"].getInt()
            if browser.responseTable.hasKey(id):
                browser.responseTable[id].complete(jsn)
                browser.responseTable.del(id)
        elif jsn.hasKey("method"): # CDP event
            let mthd = jsn["method"].to(string)
            if jsn.hasKey("sessionId"): # CDP Session event
                let sessionId = jsn["sessionId"].to(string)
                if browser.sessionEventTable.hasKey(sessionId):
                    if browser.sessionEventTable[sessionId].hasKey(mthd):
                        asyncCheck browser.sessionEventTable[sessionId][mthd](jsn)
            else:  # CDP Global event
                if browser.globalEventTable.hasKey(mthd):
                    asyncCheck browser.globalEventTable[mthd](jsn)
        else: # CDP error of some kind
            raise newException(CDPError, "JSON from CDP packet does not contain 'id' or 'method':\n" & packet)

proc addGlobalEventCallback*(browser: Browser; event: ProtocolEvent; cb: EventCallback) =
    browser.globalEventTable[event] = cb

proc addSessionEventCallback*(browser: Browser; sessionId: SessionId; event: ProtocolEvent; cb: EventCallback) =
    if not browser.sessionEventTable.hasKey(sessionId):
        browser.sessionEventTable[sessionId] = initTable[ProtocolEvent, EventCallback]()
    browser.sessionEventTable[sessionId][event] = cb

proc waitForGlobalEvent*(browser: Browser; event: ProtocolEvent): Future[JsonNode] {.async.} =
    let future = newFuture[JsonNode]()
    browser.addGlobalEventCallback(event, proc(jsn: JsonNode) {.async.} =
        future.complete(jsn))
    result = await future
    browser.globalEventTable.del(event)

proc waitForSessionEvent*(browser: Browser; sessionId: string; event: ProtocolEvent): Future[JsonNode] {.async.} =
    let future = newFuture[JsonNode]()
    browser.addSessionEventCallback(sessionId, event, proc(jsn: JsonNode) {.async.} =
        future.complete(jsn))
    result = await future
    browser.sessionEventTable[sessionId].del(event)

proc deleteGlobalEventCallback*(browser: Browser; event: ProtocolEvent) =
    if browser.globalEventTable.hasKey(event):
        browser.globalEventTable.del(event)

proc deleteSessionEventCallback*(browser: Browser; sessionId: SessionId; event: ProtocolEvent) =
    if browser.sessionEventTable.hasKey(sessionId):
        if browser.sessionEventTable[sessionId].hasKey(event):
            browser.sessionEventTable[sessionId].del(event)