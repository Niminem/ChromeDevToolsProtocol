## This module provides the basic types and procedures for interacting with
## the Chrome DevTools Protocol (CDP).

import std/[json, asyncdispatch, tables]
import pkg/ws

type
    CDPError* = object of CatchableError
    SessionId* = string
    ProtocolEvent* = string
    EventCallback* = proc(data: JsonNode) {.async.}
    ResponseTable* = Table[int, Future[JsonNode]]
    SessionEventTable* = Table[SessionId, Table[ProtocolEvent, EventCallback]]
    GlobalEventTable* = Table[ProtocolEvent, EventCallback]
    Browser* = ref object
        userDataDir*: tuple[dir: string, isTempDir: bool]
        ws*: WebSocket
        requestId*: int
        responseTable*: ResponseTable
        globalEventTable*: GlobalEventTable
        sessionEventTable*: SessionEventTable
    Tab* = ref object
        browser*: Browser
        sessionId*: SessionId


proc sendCommand*(browser: Browser; mthd: string; params: JsonNode): Future[JsonNode] {.async.} =
    browser.requestId += 1
    if browser.requestId > 9999: browser.requestId = 1
    let future = newFuture[JsonNode]()
    browser.responseTable[browser.requestId] = future
    await browser.ws.send($(%*{"id": browser.requestId, "method": mthd, "params": params}))
    result = await future

proc sendCommand*(browser: Browser; mthd: string): Future[JsonNode] {.async.} =
    browser.requestId += 1
    if browser.requestId > 9999: browser.requestId = 1
    let future = newFuture[JsonNode]()
    browser.responseTable[browser.requestId] = future
    await browser.ws.send($(%*{"id": browser.requestId, "method": mthd}))
    result = await future

proc sendCommand*(tab: Tab; mthd: string; params: JsonNode): Future[JsonNode] {.async.} =
    tab.browser.requestId += 1
    if tab.browser.requestId > 9999: tab.browser.requestId = 1
    let msg = %*{"id": tab.browser.requestId, "method": mthd,
                 "sessionId": tab.sessionId, "params": params}
    let future = newFuture[JsonNode]()
    tab.browser.responseTable[tab.browser.requestId] = future
    await tab.browser.ws.send($msg)
    result = await future

proc sendCommand*(tab: Tab; mthd: string): Future[JsonNode] {.async.} =
    tab.browser.requestId += 1
    if tab.browser.requestId > 9999: tab.browser.requestId = 1
    let future = newFuture[JsonNode]()
    tab.browser.responseTable[tab.browser.requestId] = future
    await tab.browser.ws.send($(%*{"id": tab.browser.requestId, "method": mthd,
                                   "sessionId": tab.sessionId}))
    result = await future