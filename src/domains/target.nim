## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Target Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Target/>`_.
##
## The **Target Domain** supports additional targets discovery and allows to attach to them.

import std/[json, asyncdispatch]
import ../core/base

type
    Target* {.pure.} = enum ## **Target Domain** events
        receivedMessageFromTarget = "Target.receivedMessageFromTarget"
        targetCreated = "Target.targetCreated"
        targetDestroyed = "Target.targetDestroyed"
        targetCrashed = "Target.targetCrashed"
        targetInfoChanged = "Target.targetInfoChanged"

proc activateTarget*(browser: Browser; targetId: string) {.async.} =
    ## `Target.activateTarget <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-activateTarget>`_
    ##
    ## activates (focuses) the *target*.
    discard await browser.sendCommand("Target.activateTarget", %*{"targetId": targetId})

proc attachToTarget*(browser: Browser; targetId: string): Future[JsonNode] {.async.} =
    ## `Target.attachToTarget <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-attachToTarget>`_
    ##
    ## attaches to the *target* with the given `targetId`.
    ##
    ## `flatten` parameter is forced `true` to simplify the API (and will be default in future versions of CDP).
    result = await browser.sendCommand("Target.attachToTarget", %*{"targetId": targetId,"flatten": true})

proc closeTarget*(browser: Browser; targetId: string) {.async.} =
    ## `Target.closeTarget <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-closeTarget>`_
    ##
    ## Closes the *target*. If the *target* is a **page** that gets closed too.
    ##
    ## Note: the return object is deprecated, so we return a `Future[void]` instead.
    discard await browser.sendCommand("Target.closeTarget", %*{"targetId": targetId})

proc createBrowserContext*(browser: Browser; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Target.createBrowserContext <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-createBrowserContext>`_
    ##
    ## Creates a new *browser context*. Similar to an incognito profile but you can have more than one.
    result = await browser.sendCommand("Target.createBrowserContext", params)
proc createBrowserContext*(browser: Browser): Future[JsonNode] {.async.} =
    result = await browser.sendCommand("Target.createBrowserContext")

proc createTarget*(browser: Browser; url: string = ""; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Target.createTarget <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-createTarget>`_
    ##
    ## creates a new *page*. Passing "" to `url` parameter will create a blank page (about:blank).
    params["url"] = newJString(url)
    result = await browser.sendCommand("Target.createTarget", params)
proc createTarget*(browser: Browser; url: string = ""): Future[JsonNode] {.async.} =
    result = await browser.sendCommand("Target.createTarget", %*{"url": url})

proc detachFromTarget*(browser: Browser; sessionId: string) {.async.} =
    ## `Target.detachFromTarget <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-detachFromTarget>`_
    ##
    ## detaches session with given id.
    discard await browser.sendCommand("Target.detachFromTarget", %*{"sessionId": sessionId})

proc disposeBrowserContext*(browser: Browser; browserContextId: string) {.async.} =
    ## `Target.disposeBrowserContext <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-disposeBrowserContext>`_
    ##
    ## Deletes a *browser context*. All the belonging pages will be closed without calling their beforeunload hooks.
    discard await browser.sendCommand("Target.disposeBrowserContext", %*{"browserContextId": browserContextId})

proc getBrowserContexts*(browser: Browser): Future[JsonNode] {.async.} =
    ## `Target.getBrowserContexts <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-getBrowserContexts>`_
    ##
    ## returns all browser contexts created with `Target.createBrowserContext`.
    result = await browser.sendCommand("Target.getBrowserContexts")

proc getTargets*(browser: Browser; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Target.getTargets <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-getTargets>`_
    ##
    ## retrieves a list of available targets.
    result = await browser.sendCommand("Target.getTargets", params)
proc getTargets*(browser: Browser): Future[JsonNode] {.async.} =
    result = await browser.sendCommand("Target.getTargets")

proc setAutoAttach*(browser: Browser; autoAttach, waitForDebuggerOnStart: bool; params: JsonNode) {.async.} =
    ## `Target.setAutoAttach <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-setAutoAttach>`_
    ##
    ## Controls whether to automatically attach to new targets which are considered to be related to this one.
    ## When turned on, attaches to all existing related targets as well. When turned off, automatically detaches
    ## from all currently attached targets. This also clears all targets added by `autoAttachRelated` from the
    ## list of targets to watch for creation of related targets.
    ## `flatten` parameter is forced `true` to simplify the API (and will be default in future versions of CDP).
    params["autoAttach"] = newJBool(autoAttach)
    params["waitForDebuggerOnStart"] = newJBool(waitForDebuggerOnStart)
    params["flatten"] = newJBool(true)
    discard await browser.sendCommand("Target.setAutoAttach", params)
proc setAutoAttach*(browser: Browser; autoAttach, waitForDebuggerOnStart: bool) {.async.} =
    discard await browser.sendCommand("Target.setAutoAttach", %*{"autoAttach": autoAttach,
            "waitForDebuggerOnStart": waitForDebuggerOnStart, "flatten": true})

proc setDiscoverTargets*(browser: Browser; discover: bool; params: JsonNode) {.async.} =
    ## `Target.setDiscoverTargets <https://chromedevtools.github.io/devtools-protocol/1-3/Target/#method-setDiscoverTargets>`_
    ##
    ## Controls whether to discover available targets and notify via `Target.targetCreated`/`Target.targetDestroyed`/
    ## `Target.targetInfoChanged` events.
    params["discover"] = newJBool(discover)
    discard await browser.sendCommand("Target.setDiscoverTargets", params)
proc setDiscoverTargets*(browser: Browser; discover: bool) {.async.} =
    discard await browser.sendCommand("Target.setDiscoverTargets", %*{"discover": discover})