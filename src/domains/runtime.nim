## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Runtime Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/>`_.
##
## Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror objects. Evaluation results are
## returned as mirror object that expose object type, string representation and unique identifier that can be used for
## further object reference. Original objects are maintained in memory unless they are either explicitly released or
## are released along with the other objects in their object group.

import std/[json, asyncdispatch]
import ../core/base

type
    Runtime* {.pure} = enum ## **Runtime Domain** events
        consoleAPICalled = "Runtime.consoleAPICalled"
        executionContextCreated = "Runtime.executionContextCreated"
        executionContextDestroyed = "Runtime.executionContextDestroyed"
        executionContextCleared = "Runtime.executionContextCleared"
        exceptionThrown = "Runtime.exceptionThrown"
        exceptionRevoked = "Runtime.exceptionRevoked"
        inspectRequested = "Runtime.inspectRequested"

proc addBinding*(tab: Tab; name: string; params: JsonNode) {.async.} =
    ## `Runtime.addBinding <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-addBinding>`_
    ##
    ## This method is interesting and has nuances regarding parameters. Visit the link above for more information.
    params["name"] = newJString(name)
    discard await tab.sendCommand("Runtime.addBinding", params)
proc addBinding*(tab: Tab; name: string) {.async} =
    discard await tab.sendCommand("Runtime.addBinding", %*{"name": name})

proc awaitPromise*(tab: Tab; promiseObjectId: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Runtime.awaitPromise <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-awaitPromise>`_
    ##
    ## Add handler to promise with given promise object id.
    params["promiseObjectId"] = newJString(promiseObjectId)
    result = await tab.sendCommand("Runtime.awaitPromise", params)
proc awaitPromist*(tab: Tab; promiseObjectId: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Runtime.awaitPromise", %*{"promiseObjectId": promiseObjectId})

proc callFunctionOn*(tab: Tab; functionDeclaration: string;
                     params: JsonNode): Future[JsonNode] {.async.} =
    ## `Runtime.callFunctionOn 
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-callFunctionOn>`_
    ##
    ## Calls function with given declaration on the given object. Object group of the result is inherited from the target object.
    params["functionDeclaration"] = newJString(functionDeclaration)
    result = await tab.sendCommand("Runtime.callFunctionOn", params)
proc callFunctionOn*(tab: Tab; functionDeclaration: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Runtime.callFunctionOn", %*{"functionDeclaration": functionDeclaration})

proc compileScript*(tab: Tab; expression, sourceURL: string; persistScript: bool;
                    params: JsonNode): Future[JsonNode] {.async.} =
    ## `Runtime.compileScript <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-compileScript>`_
    ##
    ## Compiles expression.
    params["expression"] = newJString(expression)
    params["sourceURL"] = newJString(sourceURL)
    params["persistScript"] = newJBool(persistScript)
    result = await tab.sendCommand("Runtime.compileScript", params)
proc compileScript*(tab: Tab; expression, sourceURL, persistScript: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Runtime.compileScript", %*{"expression": expression,
                                            "sourceURL": sourceURL, "persistScript": persistScript})

proc disableRuntimeDomain*(tab: Tab) {.async.} =
    ## `Runtime.disable <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-disable>`_
    ##
    ## Disables reporting of execution contexts creation.
    discard await tab.sendCommand("Runtime.disable")

proc discardConsoleEntries*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Runtime.discardConsoleEntries <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-discardConsoleEntries>`_
    ##
    ## Discards collected exceptions and console API calls.
    discard await tab.sendCommand("Runtime.discardConsoleEntries")

proc enableRuntimeDomain*(tab: Tab) {.async.} =
    ## `Runtime.enable <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-enable>`_
    ##
    ## Enables reporting of execution contexts creation by means of `executionContextCreated` event. When the
    ## reporting gets enabled the event will be sent immediately for each existing execution context.
    discard await tab.sendCommand("Runtime.enable")

proc evaluate*(tab: Tab; expression: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Runtime.evaluate <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-evaluate>`_
    ##
    ## Evaluates expression on global object.
    params["expression"] = newJString(expression)
    result = await tab.sendCommand("Runtime.evaluate", params)
proc evaluate*(tab: Tab; expression: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Runtime.evaluate", %*{"expression": expression})

proc getProperties*(tab: Tab; objectId: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Runtime.getProperties <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-getProperties>`_
    ##
    ## Returns properties of a given object. Object group of the result is inherited from the target object.
    params["objectId"] = newJString(objectId)
    result = await tab.sendCommand("Runtime.getProperties", params)
proc getProperties*(tab: Tab; objectId: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Runtime.getProperties", %*{"objectId": objectId})

proc globalLexicalScopeNames*(tab: Tab; executionContextId: string): Future[JsonNode] {.async.} =
    ## `Runtime.globalLexicalScopeNames <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-globalLexicalScopeNames>`_
    ##
    ## Returns all let, const and class variables from global scope.
    result = await tab.sendCommand("Runtime.globalLexicalScopeNames",
                                        %*{"executionContextId": executionContextId})
proc globalLexicalScopeNames*(tab: Tab): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Runtime.globalLexicalScopeNames")

proc queryObjects*(tab: Tab; prototypeObjectId: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Runtime.queryObjects <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-queryObjects>`_
    params["prototypeObjectId"] = newJString(prototypeObjectId)
    result = await tab.sendCommand("Runtime.queryObjects", params)
proc queryObjects*(tab: Tab; prototypeObjectId: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Runtime.queryObjects", %*{"prototypeObjectId": prototypeObjectId})

proc releaseObject*(tab: Tab; objectId: string) {.async.} =
    ## `Runtime.releaseObject <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-releaseObject>`_
    ##
    ## Releases remote object with given id.
    discard await tab.sendCommand("Runtime.releaseObject", %*{"objectId": objectId})

proc releaseObjectGroup*(tab: Tab; objectGroup: string) {.async.} =
    ## `Runtime.releaseObjectGroup
    ##  <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-releaseObjectGroup>`_
    ##
    ## Releases all remote objects that belong to a given group.
    discard await tab.sendCommand("Runtime.releaseObjectGroup", %*{"objectGroup": objectGroup})

proc removeBinding*(tab: Tab; name: string) {.async.} =
    ## `Runtime.removeBinding <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-removeBinding>`_
    ##
    ## This method does not remove binding function from global object but unsubscribes current runtime agent
    ## from Runtime.bindingCalled notifications.
    discard await tab.sendCommand("Runtime.removeBinding", %*{"name": name})

proc runIfWaitingForDebugger*(tab: Tab) {.async.} =
    ## `Runtime.runIfWaitingForDebugger
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-runIfWaitingForDebugger>`_
    ##
    ## Tells inspected instance to run if it was waiting for debugger to attach.
    discard await tab.sendCommand("Runtime.runIfWaitingForDebugger")

proc runScript*(tab: Tab; scriptId: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Runtime.runScript <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-runScript>`_
    ##
    ## Runs script with given id in a given context.
    params["scriptId"] = newJString(scriptId)
    result = await tab.sendCommand("Runtime.runScript", params)
proc runScript*(tab: Tab; scriptId: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Runtime.runScript", %*{"scriptId": scriptId})

proc setAsyncCallStackDepthRuntimeDomain*(tab: Tab; maxDepth: int) {.async.} =
    ## `Runtime.setAsyncCallStackDepth
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#method-setAsyncCallStackDepth>`_
    ##
    ## Enables or disables async call stacks tracking.
    discard await tab.sendCommand("Runtime.setAsyncCallStackDepth", %*{"maxDepth": maxDepth})