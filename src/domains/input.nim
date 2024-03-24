## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Input Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Input/>`_.

import std/[json, asyncdispatch]
import ../core/base

proc cancelDragging*(tab: Tab) {.async.} =
    ## `Input.cancelDragging
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Input/#method-cancelDragging>`_
    ##
    ## Cancels any active dragging in the page.
    discard await tab.sendCommand("Input.cancelDragging")

proc dispatchKeyEvent*(tab: Tab; `type`: string; params: JsonNode) {.async.} =
    ## `Input.dispatchKeyEvent
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Input/#method-dispatchKeyEvent>`_
    ##
    ## Dispatches a key event to the page.
    params["type"] = newJString(`type`)
    discard await tab.sendCommand("Input.dispatchKeyEvent", params)
proc dispatchKeyEvent*(tab: Tab; `type`: string) {.async.} =
    discard await tab.sendCommand("Input.dispatchKeyEvent", %*{"type": `type`})

proc dispatchMouseEvent*(tab: Tab; `type`: string;
                         x: float | int; y: float | int; params: JsonNode) {.async.} =
    ## `Input.dispatchMouseEvent
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Input/#method-dispatchMouseEvent>`_
    ##
    ## Dispatches a mouse event to the page.
    params["type"] = newJString(`type`)
    params["x"] = %x
    params["y"] = %y
    discard await tab.sendCommand("Input.dispatchMouseEvent", params)
proc dispatchMouseEvent*(tab: Tab; `type`: string; x: float | int; y: float | int) {.async.} =
    discard await tab.sendCommand("Input.dispatchMouseEvent", %*{"type": `type`, "x": x, "y": y})

proc dispatchTouchEvent*(tab: Tab; `type`: string; touchPoints: seq[JsonNode]; params: JsonNode) {.async.} =
    ## `Input.dispatchTouchEvent
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Input/#method-dispatchTouchEvent>`_
    ##
    ## Dispatches a touch event to the page.
    params["type"] = newJString(`type`)
    params["touchPoints"] = %touchPoints
    discard await tab.sendCommand("Input.dispatchTouchEvent", params)
proc dispatchTouchEvent*(tab: Tab; `type`: string; touchPoints: seq[JsonNode]) {.async.} =
    discard await tab.sendCommand("Input.dispatchTouchEvent", %*{"type": `type`, "touchPoints": touchPoints})

proc setIgnoreInputEvents*(tab: Tab; ignore: bool) {.async.} =
    ## `Input.setIgnoreInputEvents
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Input/#method-setIgnoreInputEvents>`_
    ##
    ## Ignores input events (useful while debugging).
    discard await tab.sendCommand("Input.setIgnoreInputEvents", %*{"ignore": ignore})