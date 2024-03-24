## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Emulation Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/>`_.
##
## This domain emulates different environments for the page.

import std/[json, asyncdispatch]
import ../core/base

proc clearDeviceMetricsOverride*(tab: Tab) {.async.} =
    ## `Emulation.clearDeviceMetricsOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-clearDeviceMetricsOverride>`_
    ##
    ## Clears the overriden device metrics.
    discard await tab.sendCommand("Emulation.clearDeviceMetricsOverride")

proc clearGeolocationOverride*(tab: Tab) {.async.} =
    ## `Emulation.clearGeolocationOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-clearGeolocationOverride>`_
    ##
    ## Clears the overriden Geolocation Position and Error.
    discard await tab.sendCommand("Emulation.clearGeolocationOverride")

proc clearIdleOverride*(tab: Tab) {.async.} =
    ## `Emulation.clearIdleOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-clearIdleOverride>`_
    ##
    ## Clears Idle state overrides.
    discard await tab.sendCommand("Emulation.clearIdleOverride")

proc setCPUThrottlingRate*(tab: Tab; rate: int | float) {.async.} =
    ## `Emulation.setCPUThrottlingRate
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setCPUThrottlingRate>`_
    ##
    ## Enables CPU throttling to emulate slow CPUs.
    discard await tab.sendCommand("Emulation.setCPUThrottlingRate", %*{"rate": rate})

proc setDefaultBackgroundColorOverride*(tab: Tab; color: JsonNode) {.async.} =
    ## `Emulation.setDefaultBackgroundColorOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setDefaultBackgroundColorOverride>`_
    ##
    ## Sets or clears an override of the default background color of the frame.
    ## This override is used if the content does not specify one.
    discard await tab.sendCommand("Emulation.setDefaultBackgroundColorOverride", %*{"color": color})

proc setDeviceMetricsOverride*(tab: Tab; width, height: int; deviceScaleFactor: float | int; mobile: bool;
                               params: JsonNode) {.async.} =
    ## `Emulation.setDeviceMetricsOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setDeviceMetricsOverride>`_
    ## 
    ## Overrides the values of device screen dimensions (window.screen.width, window.screen.height,
    ## window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS media query results).
    params["width"] = newJInt(width)
    params["height"] = newJInt(height)
    params["deviceScaleFactor"] = %deviceScaleFactor
    params["mobile"] = newJBool(mobile)
    discard await tab.sendCommand("Emulation.setDeviceMetricsOverride", params)
proc setDeviceMetricsOverride*(tab: Tab; width, heigh: int; deviceScaleFactor: float | int; mobile: bool) {.async.} =
    discard await tab.sendCommand("Emulation.setDeviceMetricsOverride", %*{"width": width, "height": height,
                                          "deviceScaleFactor": deviceScaleFactor, "mobile": mobile})

proc setEmulatedMedia*(tab: Tab; params: JsonNode) {.async.} =
    ## `Emulation.setEmulatedMedia
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setEmulatedMedia>`_
    ##
    ## Emulates the given media type or media feature for CSS media queries.
    discard await tab.sendCommand("Emulation.setEmulatedMedia", params)
proc setEmulatedMedia*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Emulation.setEmulatedMedia")

proc setEmulatedVisionDeficiency*(tab: Tab; `type`: string) {.async} =
    ## `Emulation.setEmulatedVisionDeficiency
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setEmulatedVisionDeficiency>`_
    ##
    ## Emulates the given vision deficiency.
    discard await tab.sendCommand("Emulation.setEmulatedVisionDeficiency", %*{"type": `type`})

proc setGeolocationOverride*(tab: Tab; params: JsonNode) {.async.} =
    ## `Emulation.setGeolocationOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setGeolocationOverride>`_
    ##
    ## Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position unavailable.
    discard await tab.sendCommand("Emulation.setGeolocationOverride", params)
proc setGeolocationOverride*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Emulation.setGeolocationOverride")

proc setIdleOverride*(tab: Tab; isUserActive, isScreenUnlocked: bool) {.async.} =
    ## `Emulation.setIdleOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setIdleOverride>`_
    ##
    ## Overrides the Idle state.
    discard await tab.sendCommand("Emulation.setIdleOverride",
                            %*{"isUserActive": isUserActive, "isScreenUnlocked": isScreenUnlocked})

proc setScriptExecutionDisabled*(tab: Tab; value: bool) {.async.} =
    ## `Emulation.setScriptExecutionDisabled
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setScriptExecutionDisabled>`_
    ##
    ## Switches script execution in the page.
    discard await tab.sendCommand("Emulation.setScriptExecutionDisabled", %*{"value": value})

proc setTimezoneOverride*(tab: Tab; timezoneId: string) {.async.} =
    ## `Emulation.setTimezoneOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setTimezoneOverride>`_
    ##
    ## Overrides default host system timezone with the specified one.
    discard await tab.sendCommand("Emulation.setTimezoneOverride", %*{"timezoneId": timezoneId})

proc setTouchEmulationEnabled*(tab: Tab; enabled: bool; params: JsonNode) {.async.} =
    ## `Emulation.setTouchEmulationEnabled
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setTouchEmulationEnabled>`_
    ##
    ## Enables touch on platforms which do not support them.
    params["enabled"] = newJBool(enabled)
    discard await tab.sendCommand("Emulation.setTouchEmulationEnabled", params)
proc setTouchEmulationEnabled*(tab: Tab; enabled: bool) {.async.} =
    discard await tab.sendCommand("Emulation.setTouchEmulationEnabled", %*{"enabled": enabled})

proc setUserAgentOverrideEmulationDomain*(tab: Tab; userAgent: string; params: JsonNode) {.async.} =
    ## `Emulation.setUserAgentOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Emulation/#method-setUserAgentOverride>`_
    ##
    ## Allows overriding user agent with the given string. Allows overriding user agent with the given string.
    ## `userAgentMetadata` must be set for `Client Hint` headers to be sent.
    params["userAgent"] = newJString(userAgent)
    discard await tab.sendCommand("Emulation.setUserAgentOverride", params)
proc setUserAgentOverrideEmulationDomain*(tab: Tab; userAgent: string) {.async.} =
    discard await tab.sendCommand("Emulation.setUserAgentOverride", %*{"userAgent": userAgent})