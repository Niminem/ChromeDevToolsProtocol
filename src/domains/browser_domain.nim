## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Browser Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Browser/>`_.
## 
## **Browser Domain** defines methods and events for browser managing.

import std/[json, asyncdispatch]
import ../core/base

proc addPrivacySandboxEnrollmentOverride*(tab: Tab; url: string) {.async.} =
    ## `Browser.addPrivacySandboxEnrollmentOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Browser/#method-addPrivacySandboxEnrollmentOverride>`_
    ##
    ## Allows a site to use privacy sandbox features that require enrollment without the site actually being enrolled.
    ## **Only supported on page targets**.
    discard await tab.sendCommand("Browser.addPrivacySandboxEnrollmentOverride", %*{"url": url})

proc closeBrowserDomain*(browser: Browser) {.async.} =
    ## `Browser.close
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Browser/#method-close>`_
    ##
    ## Close browser gracefully.
    discard await browser.sendCommand("Browser.close")

proc getVersion*(browser: Browser): Future[Future] {.async.} =
    ## `Browser.getVersion
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Browser/#method-getVersion>`_
    ##
    ## Returns version information.
    result = await browser.sendCommand("Browser.getVersion")

proc resetPermissions*(browser: Browser; browserContextId: string) {.async.} =
    ## `Browser.resetPermissions
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Browser/#method-resetPermissions>`_
    ##
    ## Reset all permission management for all origins.
    discard await browser.sendCommand("Browser.resetPermissions", %*{"browserContextId": browserContextId})
proc resetPermissions*(browser: Browser) {.async.} =
    discard await browser.sendCommand("Browser.resetPermissions")