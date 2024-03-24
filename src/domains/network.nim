## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Network Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Network/>`_.
##
## Network domain allows tracking network activities of the page. It exposes information about http, file,
## data and other requests and responses, their headers, bodies, timing, etc.

import std/[json, asyncdispatch]
import ../core/base

type
    Network* {.pure} = enum ## **Network Domain** events
        dataReceived = "Network.dataReceived",
        eventSourceMessageReceived = "Network.eventSourceMessageReceived",
        loadingFailed = "Network.loadingFailed",
        loadingFinished = "Network.loadingFinished",
        requestServedFromCache = "Network.requestServedFromCache",
        requestWillBeSent = "Network.requestWillBeSent",
        responseReceived = "Network.responseReceived",
        webSocketClosed = "Network.webSocketClosed",
        webSocketCreated = "Network.webSocketCreated",
        webSocketFrameError = "Network.webSocketFrameError",
        webSocketFrameReceived = "Network.webSocketFrameReceived",
        webSocketFrameSent = "Network.webSocketFrameSent",
        webSocketHandshakeResponseReceived = "Network.webSocketHandshakeResponseReceived",
        webSocketWillSendHandshakeRequest = "Network.webSocketWillSendHandshakeRequest",
        webTransportClosed = "Network.webTransportClosed",
        webTransportConnectionEstablished = "Network.webTransportConnectionEstablished",
        webTransportCreated = "Network.webTransportCreated"

proc clearBrowserCache*(tab: Tab) {.async.} =
    ## `Network.clearBrowserCache
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-clearBrowserCache>`_
    ##
    ## Clears browser cache.
    discard await tab.sendCommand("Network.clearBrowserCache")

proc clearBrowserCookies*(tab: Tab) {.async.} =
    ## `Network.clearBrowserCookies
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-clearBrowserCookies>`_
    ##
    ## Clears browser cookies.
    discard await tab.sendCommand("Network.clearBrowserCookies")

proc deleteCookies*(tab: Tab; name: string; params: JsonNode) {.async.} =
    ## `Network.deleteCookies
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-deleteCookies>`_
    ##
    ## Deletes browser cookies with matching name and url or domain/path/partitionKey pair.
    params["name"] = newJString(name)
    discard await tab.sendCommand("Network.deleteCookies", params)
proc deleteCookies*(tab: Tab; name: string) {.async.} =
    discard await tab.sendCommand("Network.deleteCookies", %*{"name": name})

proc disableNetworkDomain*(tab: Tab) {.async.} =
    ## `Network.disable
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-disable>`_
    ##
    ## Disables network tracking, prevents network events from being sent to the client.
    discard await tab.sendCommand("Network.disable")

proc emulateNetworkConditions*(tab: Tab; offline: bool; latency: float | int;
                              downloadThroughput: float | int; uploadThroughput: float | int;
                              params: JsonNode) {.async.} =
    ## `Network.emulateNetworkConditions
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-emulateNetworkConditions>`_
    ##
    ## Activates emulation of network conditions.
    params["offline"] = newJBool(offline)
    params["latency"] = %latency
    params["downloadThroughput"] = %downloadThroughput
    params["uploadThroughput"] = %uploadThroughput
    discard await tab.sendCommand("Network.emulateNetworkConditions", params)
proc emulateNetworkConditions*(tab: Tab; offline: bool; latency: float | int;
                              downloadThroughput: float | int; uploadThroughput: float | int) {.async.} =
    discard await tab.sendCommand("Network.emulateNetworkConditions", %*{
        "offline": offline, "latency": latency,
        "downloadThroughput": downloadThroughput,
        "uploadThroughput": uploadThroughput})

proc enableNetworkDomain*(tab: Tab; params: JsonNode) {.async.} =
    ## `Network.enable <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-enable>`_
    ##
    ## Enables network tracking, network events will now be delivered to the client.
    discard await tab.sendCommand("Network.enable", params)
proc enableNetworkDomain*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Network.enable")

proc getCookies*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `Network.getCookies
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-getCookies>`_
    ##
    ## Returns all browser cookies for the current URL. Depending on the backend support, will return
    ## detailed cookie information in the `cookies` field.
    result = await tab.sendCommand("Network.getCookies", params)
proc getCookies*(tab: Tab): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("Network.getCookies")

proc getRequestPostData*(tab: Tab; requestId: string): Future[JsonNode] {.async.} =
    ## `Network.getRequestPostData
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-getRequestPostData>`_
    ##
    ## Returns post data sent with the request. Returns an error when no data was sent with the request.
    result = await tab.sendCommand("Network.getRequestPostData", %*{"requestId": requestId})

proc getResponseBodyNetworkDomain*(tab: Tab; requestId: string): Future[JsonNode] {.async.} =
    ## `Network.getReponseBody
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-getReponseBody>`_
    ##
    ## Returns content served for the given request.
    result = await tab.sendCommand("Network.getReponseBody", %*{"requestId": requestId})

proc setBypassServiceWorker*(tab: Tab; bypass: bool) {.async.} =
    ## `Network.setBypassServiceWorker
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-setBypassServiceWorker>`_
    ##
    ## Toggles ignoring cache for each request.
    discard await tab.sendCommand("Network.setBypassServiceWorker", %*{"bypass": bypass})

proc setCacheDisabled*(tab: Tab; cacheDisabled: bool) {.async.} =
    ## `Network.setCacheDisabled
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-setCacheDisabled>`_
    ##
    ## Toggles ignoring cache for each request.
    discard await tab.sendCommand("Network.setCacheDisabled", %*{"cacheDisabled": cacheDisabled})

proc setCookie*(tab: Tab; name, value: string; params: JsonNode) {.async.} =
    ## `Network.setCookie
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-setCookie>`_
    ##
    ## Sets a cookie with the given cookie data; may overwrite equivalent cookies if they exist.
    ##
    ## Note: return object is deprecated, so we are not returning it.
    params["name"] = newJString(name)
    params["value"] = newJString(value)
    discard await tab.sendCommand("Network.setCookie", params)
proc setCookie*(tab: Tab; name, value: string) {.async.} =
    discard await tab.sendCommand("Network.setCookie", %*{"name": name, "value": value})

proc setCookies*(tab: Tab; cookies: seq[JsonNode]) {.async.} =
    ## `Network.setCookies
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-setCookies>`_
    ##
    ## Sets given cookies.
    discard await tab.sendCommand("Network.setCookies", %*{"cookies": cookies})

proc setExtraHTTPHeaders*(tab: Tab; headers: JsonNode) {.async.} =
    ## `Network.setExtraHTTPHeaders
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-setExtraHTTPHeaders>`_
    ##
    ## Specifies whether to always send extra HTTP headers with the requests from this page.
    discard await tab.sendCommand("Network.setExtraHTTPHeaders", %*{"headers": headers})

proc setUserAgentOverrideNetworkDomain*(tab: Tab; userAgent: string; params: JsonNode) {.async.} =
    ## `Network.setUserAgentOverride
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Network/#method-setUserAgentOverride>`_
    ##
    ## Allows overriding user agent with the given string.
    params["userAgent"] = newJString(userAgent)
    discard await tab.sendCommand("Network.setUserAgentOverride", params)
proc setUserAgentOverrideNetworkDomain*(tab: Tab; userAgent: string) {.async.} =
    discard await tab.sendCommand("Network.setUserAgentOverride", %*{"userAgent": userAgent})