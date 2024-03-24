## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Security Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Security/>`_.

import std/[json, asyncdispatch]
import ../core/base

proc disableSecurityDomain*(context: Browser | Tab) {.async.} =
    ## `Security.disable <https://chromedevtools.github.io/devtools-protocol/1-3/Security/#method-disable>`_
    ##
    ## Disables tracking security state changes.
    discard await context.sendCommand("Security.disable")

proc enableSecurityDomain*(context: Browser | Tab) {.async.} =
    ## `Security.enable <https://chromedevtools.github.io/devtools-protocol/1-3/Security/#method-enable>`_
    ##
    ## Enables tracking security state changes.
    discard await context.sendCommand("Security.enable")

proc setIgnoreCertificateErrors*(context: Browser | Tab; ignore: bool) {.async.} =
    ## `Security.setIgnoreCertificateErrors <https://chromedevtools.github.io/devtools-protocol/1-3/Security/#method-setIgnoreCertificateErrors>`_
    ##
    ## Enable/disable whether all certificate errors should be ignored.
    discard await context.sendCommand("Security.setIgnoreCertificateErrors", %*{"ignore": ignore})