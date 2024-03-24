## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Performance Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Performance/>`_.

import std/[json, asyncdispatch]
import ../core/base

type
    Performance* {.pure} = enum ## **Performance Domain** events
        metrics = "Performance.metrics"

proc disablePerformanceDomain*(tab: Tab) {.async.} =
    ## `Performance.disable <https://chromedevtools.github.io/devtools-protocol/1-3/Performance/#method-disable>`_
    ##
    ## Disable collecting and reporting metrics.
    discard await tab.sendCommand("Performance.disable")

proc enablePerformanceDomain*(tab: Tab; timeDomain: string) {.async.} =
    ## `Performance.enable <https://chromedevtools.github.io/devtools-protocol/1-3/Performance/#method-enable>`_
    ##
    ## Enable collecting and reporting metrics.
    discard await tab.sendCommand("Performance.enable", %*{"timeDomain": timeDomain})
proc enablePerformanceDomain*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Performance.enable")

proc getMetrics*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Performance.getMetrics <https://chromedevtools.github.io/devtools-protocol/1-3/Performance/#method-getMetrics>`_
    ##
    ## Retrieve current values of run-time metrics.
    result = await tab.sendCommand("Performance.getMetrics")