## This module contains the Browser type and related procedures.
## The Browser type is used to interact with a Chrome browser instance,
## create new tabs, close tabs, register and listen for CDP events, etc.

import std/[json, asyncdispatch, tables]
import pkg/ws
import base, chrome, ../domains/target

{.experimental: "codeReordering".} # remove need for fwd declarations

proc launchBrowser*(userDataDir: string; portNo = 0; headless = HeadlessMode.True): Future[Browser] {.async} =
    new result
    result.ws = await newWebSocket(startChrome(portNo, userDataDir, headless))
    asyncCheck result.launchCDPListener()

proc close*(browser: Browser) {.async.} =
    let targets = (await browser.getTargets())["result"]["targetInfos"].to(seq[JsonNode])
    for target in targets:
        await browser.closeTarget(target["targetId"].to(string))
    browser.ws.close()

proc newTab*(browser: Browser): Future[Tab] {.async.} =
    let
        targetId = (await browser.createTarget())["result"]["targetId"].to(string)
        sessionId = (await browser.attachToTarget(targetId))["result"]["sessionId"].to(string)
    result = Tab(browser: browser, sessionId: sessionId)

proc launchCDPListener(browser: Browser) {.async.} =
    while browser.ws.readyState == Open:
        let
            packet = await browser.ws.receiveStrPacket()
            jsn = parseJson(packet)
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

echo "\nTODO: Implement removeSessionEvent, addGlobalEvent, removeGlobalEvent procedures."