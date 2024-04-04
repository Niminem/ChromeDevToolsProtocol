## This module contains procedures for the `Browser` object type.
## The `Browser` object is used to interact with a Chrome browser instance,
## create new tabs, register and listen for CDP events, etc.

import std/[json, asyncdispatch, tables, os, tempfiles, osproc]
import pkg/ws
import base, chrome, ../domains/[target, browser_domain]

{.experimental: "codeReordering".}

proc launchBrowser*(userDataDir = "";
                    portNo = 0; headlessMode = HeadlessMode.On;
                    chromeArguments: seq[string] = @[]): Future[Browser] {.async} =
    ## Launches a new Chrome browser instance and returns a `Browser` object.
    ## 
    ## `userDataDir` parameter can be used to specify a directory where the
    ## browser's user data will be stored. If an empty string is passed, a temporary
    ## directory will be created and used.
    ## 
    ## `portNo` parameter can be used to specify a port number for the browser to
    ## listen on. If `portNo` is 0, chrome will choose a random port.
    ## 
    ## `headlessMode` parameter can be used to specify whether the browser should be
    ## launched in headless mode or not. `HeadlessMode.On` (the default) will launch
    ## the new version of Chrome headless mode (for Chrome >= v112). **Use `HeadlessMode.Legacy`
    ## to launch the browser in headless mode for Chrome < v112.** The new headless mode is
    ## recommended as the old version of headless mode will be deprecated, and the new version
    ## is the actual browser rather than a separate browser implementation.
    ## 
    ## `chromeArguments` parameter can be used to pass additional arguments to the
    ## Chrome browser instance. For a list of all available arguments, see:
    ## https://peter.sh/experiments/chromium-command-line-switches/ or
    ## https://github.com/puppeteer/puppeteer/blob/main/packages/puppeteer-core/src/node/ChromeLauncher.ts
    ## for a list of arguments used by Puppeteer.
    ## 
    ## The following command-line arguments are *always* passed to Chrome:
    ## - `--remote-debugging-port=<portNo>`
    ## - `--user-data-dir=<userDataDir>`
    ## - `--no-first-run`
    ## - `--headless=new` or `--headless` (if `headlessMode` is `HeadlessMode.On` (default) or `HeadlessMode.Legacy`)
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
    ## Closes the browser instance, closes the websocket connection,
    ## deletes the user data directory, and terminates
    ## the Chrome process (if it is still running).
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
    ## Creates a new tab (Page) in the browser instance and returns a `Tab` object.
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
    ## Adds a callback function to the global event table for the specified event.
    ## The callback function will be called when the specified event is received.
    ## 
    ## Remove the callback via `deleteGlobalEventCallback` when it is no longer needed.
    ##
    ## **Note:** Currently, there can only be one callback function per event in the global event table.
    browser.globalEventTable[event] = cb

proc addSessionEventCallback*(browser: Browser; sessionId: SessionId;
                              event: ProtocolEvent; cb: EventCallback) =
    ## Adds a callback function to the session event table for the specified event.
    ## The callback function will be called when the specified event is received.
    ## 
    ## Remove the callback via `deleteSessionEventCallback` when it is no longer needed.
    ## 
    ## **Note:** Currently, there can only be one callback function per event, *per session* in the
    ## session event table. Meaning, for example, if you have two tabs open and you want to listen
    ## for the `Page.loadEventFired` event on both tabs, you can have two separate callback functions,
    ## on the same event, one for each tab (using the tab's `sessionId`).
    if not browser.sessionEventTable.hasKey(sessionId):
        browser.sessionEventTable[sessionId] = initTable[ProtocolEvent, EventCallback]()
    browser.sessionEventTable[sessionId][event] = cb

proc waitForGlobalEvent*(browser: Browser; event: ProtocolEvent): Future[JsonNode] {.async.} =
    ## Returns a `Future` that completes when the specified global event is received.
    ## 
    ## **Note:** This procedure will override the callback function in the global event table
    ## if one already exists for the specified event..
    let future = newFuture[JsonNode]()
    browser.addGlobalEventCallback(event, proc(jsn: JsonNode) {.async.} =
        future.complete(jsn))
    result = await future
    browser.globalEventTable.del(event)

proc waitForSessionEvent*(browser: Browser; sessionId: string;
                          event: ProtocolEvent): Future[JsonNode] {.async.} =
    ## Returns a `Future` that completes when the specified session event is received.
    ## 
    ## **Note:** This procedure will override the callback function in the session event table
    ## if one already exists for the specified event.
    let future = newFuture[JsonNode]()
    browser.addSessionEventCallback(sessionId, event, proc(jsn: JsonNode) {.async.} =
        future.complete(jsn))
    result = await future
    browser.sessionEventTable[sessionId].del(event)

proc deleteGlobalEventCallback*(browser: Browser; event: ProtocolEvent) =
    ## Removes the callback function from the global event table for the specified event.
    if browser.globalEventTable.hasKey(event):
        browser.globalEventTable.del(event)

proc deleteSessionEventCallback*(browser: Browser; sessionId: SessionId; event: ProtocolEvent) =
    ## Removes the callback function from the session event table for the specified event.
    if browser.sessionEventTable.hasKey(sessionId):
        if browser.sessionEventTable[sessionId].hasKey(event):
            browser.sessionEventTable[sessionId].del(event)