
## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Debugger Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/>`_.
##
## **Debugger Domain** exposes JavaScript debugging capabilities. It allows setting and
## removing breakpoints, stepping through execution, exploring stack traces, etc.

import std/[json, asyncdispatch]
import ../core/base

type
    Debugger* {.pure.} = enum  ## **Debugger Domain** events
        breakpointResolved = "Debugger.breakpointResolved"
        paused = "Debugger.paused"
        resumed = "Debugger.resumed"
        scriptFailedToParse = "Debugger.scriptFailedToParse"
        scriptParsed = "Debugger.scriptParsed"

proc continueToLocation*(tab: Tab; location: JsonNode; params: JsonNode) {.async.} =
    ## `Debugger.continueToLocation
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-continueToLocation>`_
    ##
    ## Continues execution until specific location is reached.
    params["location"] = location
    discard await tab.sendCommand("Debugger.continueToLocation", params)
proc continueToLocation*(tab: Tab; location: JsonNode) {.async.} =
    discard await tab.sendCommand("Debugger.continueToLocation", %*{"location": location})

proc disableDebuggerDomain*(tab: Tab) {.async.} =
    ## `Debugger.disable
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-disable>`_
    ##
    ## Disables debugger for given page.
    discard await tab.sendCommand("Debugger.disable")

proc enableDebuggerDomain*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Debugger.enable
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-enable>`_
    ##
    ## Enables debugger for the given page. Clients should not assume that the debugging has been
    ## enabled until the result for this command is received.
    result = await tab.sendCommand("Debugger.enable")

proc evaluateOnCallFrame*(tab: Tab; callFrameId: string; expression: string;
                          params: JsonNode): Future[JsonNode] {.async.} =
    ## `Debugger.evaluateOnCallFrame
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-evaluateOnCallFrame>`_
    ##
    ## Evaluates expression on a given call frame.
    params["callFrameId"] = newJString(callFrameId)
    params["expression"] = newJString(expression)
    result = await tab.sendCommand("Debugger.evaluateOnCallFrame", params)
proc evaluateOnCallFrame*(tab: Tab; callFrameId: string; expression: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Debugger.evaluateOnCallFrame",
                                %*{"callFrameId": callFrameId, "expression": expression})

proc getPossibleBreakpoints*(tab: Tab; start, params: JsonNode): Future[JsonNode] {.async.} =
    ## `Debugger.getPossibleBreakpoints
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-getPossibleBreakpoints>`_
    ##
    ## Returns possible locations for breakpoint. scriptId in start and end range locations should
    ## be the same.
    params["start"] = start
    result = await tab.sendCommand("Debugger.getPossibleBreakpoints", params)
proc getPossibleBreakpoints*(tab: Tab; start: JsonNode): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Debugger.getPossibleBreakpoints", %*{"start": start})

proc getScriptSource*(tab: Tab; scriptId: string): Future[JsonNode] {.async.} =
    ## `Debugger.getScriptSource
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-getScriptSource>`_
    ##
    ## Returns source for the script with given id.
    result = await tab.sendCommand("Debugger.getScriptSource", %*{"scriptId": scriptId})

proc pause*(tab: Tab) {.async.} =
    ## `Debugger.pause
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-pause>`_
    ##
    ## Stops on the next JavaScript statement.
    discard await tab.sendCommand("Debugger.pause")

proc removeBreakpoint*(tab: Tab; breakpointId: string) {.async.} =
    ## `Debugger.removeBreakpoint
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-removeBreakpoint>`_
    ##
    ## Removes JavaScript breakpoint.
    discard await tab.sendCommand("Debugger.removeBreakpoint", %*{"breakpointId": breakpointId})

proc restartFrame*(tab: Tab; callFrameId: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Debugger.restartFrame
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-restartFrame>`_
    ##
    ## Restarts particular call frame from the beginning.
    ##
    ## The old, deprecated behavior of `restartFrame` is to stay paused and allow further CDP
    ## commands after a restart was scheduled. This can cause problems with restarting, so we now
    ## continue execution immediatly after it has been scheduled until we reach the beginning of
    ## the restarted frame. To stay back-wards compatible, `restartFrame` now expects a `mode`
    ## parameter to be present. If the `mode` parameter is missing, `restartFrame` errors out.
    ## The various return values are deprecated and `callFrames` is always empty. Use the call
    ## frames from the `Debugger#paused` events instead, that fires once V8 pauses at the beginning
    ## of the restarted function.
    params["callFrameId"] = newJString(callFrameId)
    result = await tab.sendCommand("Debugger.restartFrame", params)
proc restartFrame*(tab: Tab; callFrameId: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Debugger.restartFrame", %*{"callFrameId": callFrameId})

proc resume*(tab: Tab; params: JsonNode) {.async.} =
    ## `Debugger.resume
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-resume>`_
    ##
    ## Resumes JavaScript execution.
    discard await tab.sendCommand("Debugger.resume", params)
proc resume*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Debugger.resume")

proc searchInContent*(tab: Tab; scriptId, query: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Debugger.searchInContent
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-searchInContent>`_
    ##
    ## Searches for given string in script content.
    params["scriptId"] = newJString(scriptId)
    params["query"] = newJString(query)
    result = await tab.sendCommand("Debugger.searchInContent", params)
proc searchInContent*(tab: Tab; scriptId, query: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Debugger.searchInContent",
                                %*{"scriptId": scriptId, "query": query})

proc setAsyncCallStackDepthDebuggerDomain*(tab: Tab; maxDepth: int) {.async.} =
    ## `Debugger.setAsyncCallStackDepth
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setAsyncCallStackDepth>`_
    ##
    ## Enables or disables async call stacks tracking.
    discard await tab.sendCommand("Debugger.setAsyncCallStackDepth", %*{"maxDepth": maxDepth})

proc setBreakpoint*(tab: Tab; location: JsonNode; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Debugger.setBreakpoint 
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setBreakpoint>`_
    ##
    ## Sets JavaScript breakpoint at a given location.
    params["location"] = location
    result = await tab.sendCommand("Debugger.setBreakpoint", params)
proc setBreakpoint*(tab: Tab; location: JsonNode): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Debugger.setBreakpoint", %*{"location": location})

proc setBreakpointByUrl*(tab: Tab; lineNumber: int; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Debugger.setBreakpointByUrl
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setBreakpointByUrl>`_
    ##
    ## Sets JavaScript breakpoint at given location specified either by URL or URL regex. Once
    ## this command is issued, all existing parsed scripts will have breakpoints resolved and
    ## returned in `locations` property. Further matching script parsing will result in subsequent
    ## `breakpointResolved` events issued. This logical breakpoint will survive page reloads.
    params["lineNumber"] = newJInt(lineNumber)
    result = await tab.sendCommand("Debugger.setBreakpointByUrl", params)
proc setBreakpointByUrl*(tab: Tab; lineNumber: int): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Debugger.setBreakpointByUrl", %*{"lineNumber": lineNumber})

proc setBreakpointsActive*(tab: Tab; active: bool) {.async.} =
    ## `Debugger.setBreakpointsActive
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setBreakpointsActive>`_
    ##
    ## Activates / deactivates all breakpoints on the page.
    discard await tab.sendCommand("Debugger.setBreakpointsActive", %*{"active": active})

proc setInstrumentationBreakpoint*(tab: Tab; instrumentation: string): Future[JsonNode] {.async.} =
    ## `Debugger.setInstrumentationBreakpoint
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setInstrumentationBreakpoint>`_
    ##
    ## Sets instrumentation breakpoint.
    result = await tab.sendCommand("Debugger.setInstrumentationBreakpoint",
                                %*{"instrumentation": instrumentation})

proc setPauseOnExceptions*(tab: Tab; state: string) {.async.} =
    ## `Debugger.setPauseOnExceptions
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setPauseOnExceptions>`_
    ##
    ## Defines pause on exceptions state. Can be set to stop on all exceptions, uncaught exceptions, or
    ## caught exceptions, no exceptions. Initial pause on exceptions state is `none`.
    discard await tab.sendCommand("Debugger.setPauseOnExceptions", %*{"state": state})

proc setScriptSource*(tab: Tab; scriptId, scriptSource: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Debugger.setScriptSource
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setScriptSource>`_
    ##
    ## Edits JavaScript source live. In general, functions that are currently on the stack can not be
    ## edited with a single exception: If the edited function is the top-most stack frame and that is
    ## the only activation of that function on the stack. In this case the live edit will be successful
    ## and a `Debugger.restartFrame` for the top-most function is automatically triggered.
    params["scriptId"] = newJString(scriptId)
    params["scriptSource"] = newJString(scriptSource)
    result = await tab.sendCommand("Debugger.setScriptSource", params)
proc setScriptSource*(tab: Tab; scriptId, scriptSource: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Debugger.setScriptSource",
                                %*{"scriptId": scriptId, "scriptSource": scriptSource})

proc setSkipAllPauses*(tab: Tab; skip: bool) {.async.} =
    ## `Debugger.setSkipAllPauses
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setSkipAllPauses>`_
    ##
    ## Makes page not interrupt on any pauses (breakpoint, exception, dom exception etc).
    discard await tab.sendCommand("Debugger.setSkipAllPauses", %*{"skip": skip})

proc setVariableValue*(tab: Tab; scopeNumber: int; variableName: string;
                       params: JsonNode) {.async.} =
    ## `Debugger.setVariableValue
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-setVariableValue>`_
    ##
    ## Changes value of variable in a callframe. Object-based scopes are not supported and must be
    ## mutated manually.
    params["scopeNumber"] = newJInt(scopeNumber)
    params["variableName"] = newJString(variableName)
    discard await tab.sendCommand("Debugger.setVariableValue", params)
proc setVariableValue*(tab: Tab; scopeNumber: int; variableName: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Debugger.setVariableValue",
                                %*{"scopeNumber": scopeNumber, "variableName": variableName})

proc stepInto*(tab: Tab; params: JsonNode) {.async.} =
    ## `Debugger.stepInto
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-stepInto>`_
    ##
    ## Steps into the function call.
    discard await tab.sendCommand("Debugger.stepInto", params)
proc stepInto*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Debugger.stepInto")

proc stepOut*(tab: Tab) {.async.} =
    ## `Debugger.stepOut
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-stepOut>`_
    ##
    ## Steps out of the function call.
    discard await tab.sendCommand("Debugger.stepOut")

proc stepOver*(tab: Tab; params: JsonNode) {.async.} =
    ## `Debugger.stepOver
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Debugger/#method-stepOver>`_
    ##
    ## Steps over the statement.
    discard await tab.sendCommand("Debugger.stepOver", params)
proc stepOver*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Debugger.stepOver")