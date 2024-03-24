## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Profiler Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/>`_.

import std/[json, asyncdispatch]
import ../core/base

type
    Profiler* {.pure} = enum ## **Profiler Domain** events
        consoleProfileFinished = "Profiler.consoleProfileFinished"
        consoleProfileStarted = "Profiler.consoleProfileStarted"

proc disableProfileDomain*(tab: Tab) {.async.} =
    ## `Profiler.disable <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-disable>`_
    discard await tab.sendCommand("Profiler.disable")

proc enableProfileDomain*(tab: Tab) {.async.} =
    ## `Profiler.enable <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-enable>`_
    discard await tab.sendCommand("Profiler.enable")

proc getBestEffortCoverage*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Profiler.getBestEffortCoverage
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-getBestEffortCoverage>`_
    result = await tab.sendCommand("Profiler.getBestEffortCoverage")

proc setSamplingInterval*(tab: Tab; interval: int) {.async.} =
    ## `Profiler.setSamplingInterval
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-setSamplingInterval>`_
    ##
    ## Changes CPU profiler sampling interval. Must be called before CPU profiles recording started.
    discard await tab.sendCommand("Profiler.setSamplingInterval", %*{"interval": interval})

proc start*(tab: Tab) {.async.} =
    ## `Profiler.start <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-start>`_
    discard await tab.sendCommand("Profiler.start")

proc startPreciseCoverage*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Profiler.startPreciseCoverage
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-startPreciseCoverage>`_
    ##
    ## Enable precise code coverage. Coverage data for JavaScript executed before enabling precise code
    ## coverage may be incomplete. Enabling prevents running optimized code and resets execution counters.
    result = await tab.sendCommand("Profiler.startPreciseCoverage", params)
proc startPreciseCoverage*(tab: Tab): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Profiler.startPreciseCoverage")

proc stop*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Profiler.stop <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-stop>`_
    result = await tab.sendCommand("Profiler.stop")

proc stopPreciseCoverage*(tab: Tab) {.async.} =
    ## `Profiler.stopPreciseCoverage
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-stopPreciseCoverage>`_
    discard await tab.sendCommand("Profiler.stopPreciseCoverage")

proc takePreciseCoverage*(tab: Tab): Future[JsonNode] {.async.} =
    ## `Profiler.takePreciseCoverage
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Profiler/#method-takePreciseCoverage>`_
    result = await tab.sendCommand("Profiler.takePreciseCoverage")