## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `DOMDebugger Domain <https://chromedevtools.github.io/devtools-protocol/1-3/DOMDebugger/>`_.
## 
## DOM debugging allows setting breakpoints on particular DOM operations and events.
## JavaScript execution will stop on these operations as if there was a regular breakpoint set.

import std/[json, asyncdispatch]
import ../core/base

proc getEventListeners*(tab: Tab; objectId: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `DOMDebugger.getEventListeners
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOMDebugger/#method-getEventListeners>`_
    ##
    ## Returns event listeners of the given object.
    params["objectId"] = newJString(objectId)
    result = await tab.sendCommand("DOMDebugger.getEventListeners", params)
proc getEventListeners*(tab: Tab; objectId: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("DOMDebugger.getEventListeners", %*{"objectId": objectId})

proc removeDOMBreakpoint*(tab: Tab; nodeId: int; `type`: string): Future[JsonNode] {.async.} =
    ## `DOMDebugger.removeDOMBreakpoint
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOMDebugger/#method-removeDOMBreakpoint>`_
    ##
    ## Removes DOM breakpoint that was set using `setDOMBreakpoint`.
    result = await tab.sendCommand("DOMDebugger.removeDOMBreakpoint", %*{"nodeId": nodeId, "type": `type`})

proc removeEventListenerBreakpoint*(tab: Tab; eventName: string; params: JsonNode) {.async.} =
    ## `DOMDebugger.removeEventListenerBreakpoint
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOMDebugger/#method-removeEventListenerBreakpoint>`_
    ##
    ## Removes breakpoint on particular DOM event.
    params["eventName"] = newJString(eventName)
    discard await tab.sendCommand("DOMDebugger.removeEventListenerBreakpoint", params)
proc removeEventListenerBreakpoint*(tab: Tab; eventName: string) {.async.} =
    discard await tab.sendCommand("DOMDebugger.removeEventListenerBreakpoint", %*{"eventName": eventName})

proc removeXHRBreakpoint*(tab: Tab; url: string) {.async.} =
    ## `DOMDebugger.removeXHRBreakpoint
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOMDebugger/#method-removeXHRBreakpoint>`_
    ##
    ## Removes breakpoint from XMLHttpRequest.
    discard await tab.sendCommand("DOMDebugger.removeXHRBreakpoint", %*{"url": url})

proc setDOMBreakpoint*(tab: Tab; nodeId: int; `type`: string) {.async.} =
    ## `DOMDebugger.setDOMBreakpoint
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOMDebugger/#method-setDOMBreakpoint>`_
    ##
    ## Sets breakpoint on particular operation with DOM.
    discard await tab.sendCommand("DOMDebugger.setDOMBreakpoint", %*{"nodeId": nodeId, "type": `type`})

proc setEventListenerBreakpoint*(tab: Tab; eventName: string; params: JsonNode) {.async.} =
    ## `DOMDebugger.setEventListenerBreakpoint
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOMDebugger/#method-setEventListenerBreakpoint>`_
    ##
    ## Sets breakpoint on particular DOM event.
    params["eventName"] = newJString(eventName)
    discard await tab.sendCommand("DOMDebugger.setEventListenerBreakpoint", params)
proc setEventListenerBreakpoint*(tab: Tab; eventName: string) {.async.} =
    discard await tab.sendCommand("DOMDebugger.setEventListenerBreakpoint", %*{"eventName": eventName})

proc setXHRBreakpoint*(tab: Tab; url: string) {.async.} =
    ## `DOMDebugger.setXHRBreakpoint
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOMDebugger/#method-setXHRBreakpoint>`_
    ##
    ## Sets breakpoint on XMLHttpRequest.
    discard await tab.sendCommand("DOMDebugger.setXHRBreakpoint", %*{"url": url})