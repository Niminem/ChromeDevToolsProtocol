## This module provides the basic types and procedures for interacting with
## the Chrome DevTools Protocol (CDP).

import std/[json, asyncdispatch, tables, osproc]
import pkg/ws

type
    CDPError* = object of CatchableError
    RequestId* = int
    SessionId* = string
    ProtocolEvent* = string
    EventCallback* = proc(data: JsonNode) {.async.}
    ResponseTable* = Table[RequestId, Future[JsonNode]]
    SessionEventTable* = Table[SessionId, Table[ProtocolEvent, EventCallback]]
    GlobalEventTable* = Table[ProtocolEvent, EventCallback]
    Browser* = ref object ## Represents a `Browser` instance. Fields are read-only and should not be
                          ## used directly.
        chrome*: Process
        userDataDir*: tuple[dir: string, isTempDir: bool]
        ws*: WebSocket
        requestId*: RequestId
        responseTable*: ResponseTable
        globalEventTable*: GlobalEventTable
        sessionEventTable*: SessionEventTable
    Tab* = ref object ## Represents a `Tab` (Page). Fields are read-only, do not modify.
        browser*: Browser
        sessionId*: SessionId


proc sendCommand*(browser: Browser; mthd: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## Version of `sendCommand` that sends a command with parameters (for the Browser object).
    browser.requestId += 1
    if browser.requestId > 9999: browser.requestId = 1
    let future = newFuture[JsonNode]()
    browser.responseTable[browser.requestId] = future
    await browser.ws.send($(%*{"id": browser.requestId, "method": mthd, "params": params}))
    result = await future

proc sendCommand*(browser: Browser; mthd: string): Future[JsonNode] {.async.} =
    ## **This is a generic procedure for sending a command to the CDP endpoint.
    ## All wrapped CDP v1.3 methods/commands use a version of this procedure.**
    ##
    ## *If you need to send a command that is not covered by the v1.3 of CDP, like those
    ## from experimental Domains, you can use this procedure to create a new wrapper or
    ## send the command directly.*
    browser.requestId += 1
    if browser.requestId > 9999: browser.requestId = 1
    let future = newFuture[JsonNode]()
    browser.responseTable[browser.requestId] = future
    await browser.ws.send($(%*{"id": browser.requestId, "method": mthd}))
    result = await future

proc sendCommand*(tab: Tab; mthd: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## Version of `sendCommand` that sends a command with parameters (for the Tab object).
    tab.browser.requestId += 1
    if tab.browser.requestId > 9999: tab.browser.requestId = 1
    let msg = %*{"id": tab.browser.requestId, "method": mthd,
                 "sessionId": tab.sessionId, "params": params}
    let future = newFuture[JsonNode]()
    tab.browser.responseTable[tab.browser.requestId] = future
    await tab.browser.ws.send($msg)
    result = await future

proc sendCommand*(tab: Tab; mthd: string): Future[JsonNode] {.async.} =
    ## Version of `sendCommand` that sends a command without parameters (for the Tab object).
    tab.browser.requestId += 1
    if tab.browser.requestId > 9999: tab.browser.requestId = 1
    let future = newFuture[JsonNode]()
    tab.browser.responseTable[tab.browser.requestId] = future
    await tab.browser.ws.send($(%*{"id": tab.browser.requestId, "method": mthd,
                                   "sessionId": tab.sessionId}))
    result = await future