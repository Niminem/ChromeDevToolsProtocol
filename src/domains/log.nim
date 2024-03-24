## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Log Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Log/>`_.
##
## Provides access to log entries.

import std/[json, asyncdispatch]
import ../core/base

type
    Log* {.pure} = enum ## **Log Domain** events
        entryAdded = "Log.entryAdded"

proc clear*(context: Browser | Tab) {.async.} =
    ## `Log.clear <https://chromedevtools.github.io/devtools-protocol/1-3/Log/#method-clear>`_
    ##
    ## Clears the log.
    discard await context.sendCommand("Log.clear")

proc disableLogDomain*(context: Browser | Tab) {.async.} =
    ## `Log.disable <https://chromedevtools.github.io/devtools-protocol/1-3/Log/#method-disable>`_
    ##
    ## Disables log domain, prevents further log entries from being reported to the client.
    discard await context.sendCommand("Log.disable")

proc enableLogDomain*(context: Browser | Tab) {.async.} =
    ## `Log.enable <https://chromedevtools.github.io/devtools-protocol/1-3/Log/#method-enable>`_
    ##
    ## Enables log domain, sends the entries collected so far to the client by means of the entryAdded notification.
    discard await context.sendCommand("Log.enable")

proc startViolationsReport*(context: Browser | Tab; config: JsonNode) {.async.} =
    ## `Log.startViolationsReport
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Log/#method-startViolationsReport>`_
    ##
    ## start violation reporting.
    discard await context.sendCommand("Log.startViolationsReport", %*{"config": config})

proc stopViolationsReport*(context: Browser | Tab) {.async.} =
    ## `Log.stopViolationsReport
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Log/#method-stopViolationsReport>`_
    ##
    ## Stop violation reporting.
    discard await context.sendCommand("Log.stopViolationsReport")