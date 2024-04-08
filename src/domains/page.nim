## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Page Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Page/>`_.
##
## Actions and events related to the inspected page belong to the page domain.

import std/[json, asyncdispatch]
import ../core/base

type
    Page* {.pure} = enum ## **Page Domain** events
        domContentEventFired = "Page.domContentEventFired"
        fileChooserOpened = "Page.fileChooserOpened"
        frameAttached = "Page.frameAttached"
        frameDetached = "Page.frameDetached"
        frameNavigated = "Page.frameNavigated"
        interstitialHidden = "Page.interstitialHidden"
        interstitialShown = "Page.interstitialShown"
        javascriptDialogClosed = "Page.javascriptDialogClosed"
        javascriptDialogOpening = "Page.javascriptDialogOpening"
        lifecycleEvent = "Page.lifecycleEvent"
        loadEventFired = "Page.loadEventFired"
        windowOpen = "Page.windowOpen"

proc addScriptToEvaluateOnNewDocument*(tab: Tab; source: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Page.addScriptToEvaluateOnNewDocument
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-addScriptToEvaluateOnNewDocument>`_
    ##
    ## Evaluates given script in every frame upon creation (before loading frame's scripts).
    params["source"] = newJString(source)
    result = await tab.sendCommand("Page.addScriptToEvaluateOnNewDocument", params)
proc addScriptToEvaluateOnNewDocument*(tab: Tab; source: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Page.addScriptToEvaluateOnNewDocument", %*{"source": source})

proc bringToFront*(tab: Tab) {.async.} =
    ## `Page.bringToFront <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-bringToFront>`_
    ##
    ## Brings page to front (activates tab).
    discard await tab.sendCommand("Page.bringToFront")

proc captureScreenshot*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Page.captureScreenshot <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-captureScreenshot>`_
    ##
    ## Capture page screenshot.
    result = await tab.sendCommand("Page.captureScreenshot", params)
proc captureScreenshot*(tab: Tab): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Page.captureScreenshot")

proc closePageDomain*(tab: Tab) {.async.} =
    ## `Page.close <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-close>`_
    ##
    ## Tries to close page, running its beforeunload hooks, if any.
    discard await tab.sendCommand("Page.close")

proc createIsolatedWorld*(tab: Tab; frameId: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Page.createIsolatedWorld
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-createIsolatedWorld>`_
    ##
    ## Creates an isolated world for the given frame.
    params["frameId"] = newJString(frameId)
    result = await tab.sendCommand("Page.createIsolatedWorld", params)
proc createIsolatedWorld*(tab: Tab; frameId: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Page.createIsolatedWorld", %*{"frameId": frameId})

proc disablePageDomain*(tab: Tab) {.async.} =
    ## `Page.disable <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-disable>`_
    ##
    ## Disables page domain notifications.
    discard await tab.sendCommand("Page.disable")

proc enablePageDomain*(tab: Tab) {.async.} =
    ## `Page.enable <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-enable>`_
    ##
    ## Enables page domain notifications.
    discard await tab.sendCommand("Page.enable")

proc getAppManifest*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Page.getAppManifest <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-getAppManifest>`_
    result = await tab.sendCommand("Page.getAppManifest")

proc getFrameTree*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Page.getFrameTree <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-getFrameTree>`_
    ##
    ## Returns present frame tree structure.
    result = await tab.sendCommand("Page.getFrameTree")

proc getLayoutMetrics*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Page.getLayoutMetrics <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-getLayoutMetrics>`_
    ##
    ## Returns metrics relating to the layouting of the page, such as viewport bounds/scale.
    result = await tab.sendCommand("Page.getLayoutMetrics")

proc getNavigationHistory*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Page.getNavigationHistory
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-getNavigationHistory>`_
    ##
    ## Returns navigation history for the current page.
    result = await tab.sendCommand("Page.getNavigationHistory")

proc handleJavaScriptDialog*(tab: Tab; accept: bool; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Page.handleJavaScriptDialog
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-handleJavaScriptDialog>`_
    ##
    ## Accepts or dismisses a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload).
    params["accept"] = newJBool(accept)
    result = await tab.sendCommand("Page.handleJavaScriptDialog", params)
proc handleJavaScriptDialog*(tab: Tab; accept: bool): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Page.handleJavaScriptDialog", %*{"accept": accept})

proc navigate*(tab: Tab; url: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Page.navigate <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-navigate>`_
    ##
    ## Navigates current page to the given URL.
    params["url"] = newJString(url)
    result = await tab.sendCommand("Page.navigate", params)
proc navigate*(tab: Tab; url: string): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Page.navigate", %*{"url": url})

proc navigateToHistoryEntry*(tab: Tab; entryId: int) {.async.} =
    ## `Page.navigateToHistoryEntry
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-navigateToHistoryEntry>`_
    ##
    ## Navigates current page to the given history entry.
    discard await tab.sendCommand("Page.navigateToHistoryEntry", %*{"entryId": entryId})

proc printToPDF*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Page.printToPDF <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-printToPDF>`_
    ##
    ## Print page as PDF.
    result = await tab.sendCommand("Page.printToPDF", params)

proc reload*(tab: Tab; params: JsonNode) {.async.} =
    ## `Page.reload <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-reload>`_
    ##
    ## Reloads given page optionally ignoring the cache.
    discard await tab.sendCommand("Page.reload", params)
proc reload*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Page.reload")

proc removeScriptToEvaluateOnNewDocument*(tab: Tab; identifier: string) {.async.} =
    ## `Page.removeScriptToEvaluateOnNewDocument
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-removeScriptToEvaluateOnNewDocument>`_
    ##
    ## Removes given script from the list.
    discard await tab.sendCommand("Page.removeScriptToEvaluateOnNewDocument", %*{"identifier": identifier})

proc resetNavigationHistory*(tab: Tab) {.async.} =
    ## `Page.resetNavigationHistory
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-resetNavigationHistory>`_
    ##
    ## Resets navigation history for the current page.
    discard await tab.sendCommand("Page.resetNavigationHistory")

proc setBypassCSP*(tab: Tab; enabled: bool) {.async.} =
    ## `Page.setBypassCSP <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-setBypassCSP>`_
    ##
    ## Enable page Content Security Policy by-passing.
    discard await tab.sendCommand("Page.setBypassCSP", %*{"enabled": enabled})

proc setDocumentContent*(tab: Tab; frameId, html: string) {.async.} =
    ## `Page.setDocumentContent <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-setDocumentContent>`_
    ##
    ## Sets given markup as the document's HTML.
    discard await tab.sendCommand("Page.setDocumentContent", %*{"frameId": frameId, "html": html})

proc setInterceptFileChooserDialog*(tab: Tab; enabled: bool) {.async.} =
    ## `Page.setInterceptFileChooserDialog
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-setInterceptFileChooserDialog>`_
    ##
    ## Intercept file chooser requests and transfer control to protocol clients. When file chooser interception
    ## is enabled, native file chooser dialog is not shown. Instead, a protocol event Page.fileChooserOpened is
    ## emitted.
    discard await tab.sendCommand("Page.setInterceptFileChooserDialog", %*{"enabled": enabled})

proc setLifecycleEventsEnabled*(tab: Tab; enabled: bool) {.async.} =
    ## `Page.setLifecycleEventsEnabled
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-setLifecycleEventsEnabled>`_
    ##
    ## Controls whether page will emit lifecycle events.
    discard await tab.sendCommand("Page.setLifecycleEventsEnabled", %*{"enabled": enabled})

proc stopLoading*(tab: Tab) {.async.} =
    ## `Page.stopLoading <https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-stopLoading>`_
    ##
    ## Force the page stop all navigations and pending resource fetches.
    discard await tab.sendCommand("Page.stopLoading")
