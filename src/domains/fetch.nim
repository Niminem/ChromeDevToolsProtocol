## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `Fetch Domain <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/>`_.

import std/[json, asyncdispatch]
import ../core/base

type
    Fetch* {.pure.} = enum  ## **Fetch Domain** events
        authRequired = "Fetch.authRequired"
        requestPaused = "Fetch.requestPaused"

proc continueRequest*(tab: Tab; requestId: string; params: JsonNode) {.async.} =
    ## `Fetch.continueRequest
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/#method-continueRequest>`_
    ##
    ## Continues the request, optionally modifying some of its parameters.
    params["requestId"] = newJString(requestId)
    discard await tab.sendCommand("Fetch.continueRequest", params)
proc continueRequest*(tab: Tab; requestId: string) {.async.} =
    discard await tab.sendCommand("Fetch.continueRequest", %*{"requestId": requestId})

proc continueWithAuth*(tab: Tab; requestId: string; authChallengeResponse: JsonNode) {.async.} =
    ## `Fetch.continueWithAuth
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/#method-continueWithAuth>`_
    ##
    ## Continues a request supplying authChallengeResponse following authRequired event.
    discard await tab.sendCommand("Fetch.continueWithAuth", %*{"requestId": requestId, "authChallengeResponse": authChallengeResponse})

proc disableFetchDomain*(tab: Tab) {.async.} =
    ## `Fetch.disable
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/#method-disable>`_
    ##
    ## Disables the fetch domain.
    discard await tab.sendCommand("Fetch.disable")

proc enableFetchDomain*(tab: Tab; params: JsonNode) {.async.} =
    ## `Fetch.enable
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/#method-enable>`_
    ##
    ## Enables issuing of requestPaused events. A request will be paused until client
    ## calls one of failRequest, fulfillRequest or continueRequest/continueWithAuth.
    discard await tab.sendCommand("Fetch.enable", params)
proc enableFetchDomain*(tab: Tab) {.async.} =
    discard await tab.sendCommand("Fetch.enable")

proc failRequest*(tab: Tab; requestId, errorReason: string) {.async.} =
    ## `Fetch.failRequest
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/#method-failRequest>`_
    ##
    ## Causes the request to fail with specified reason.
    discard await tab.sendCommand("Fetch.failRequest", %*{"requestId": requestId, "errorReason": errorReason})

proc fulfillRequest*(tab: Tab; requestId: string; responseCode: int; params: JsonNode) {.async.} =
    ## `Fetch.fulfillRequest
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/#method-fulfillRequest>`_
    ##
    ## Provides response to the request.
    params["requestId"] = newJString(requestId)
    params["responseCode"] = newJInt(responseCode)
    discard await tab.sendCommand("Fetch.fulfillRequest", params)
proc fulfillRequest*(tab: Tab; requestId: string; responseCode: int) {.async.} =
    discard await tab.sendCommand("Fetch.fulfillRequest", %*{"requestId": requestId, "responseCode": responseCode})

proc getResponseBodyFetchDomain*(tab: Tab; requestId: string): Future[JsonNode] {.async.} =
    ## `Fetch.getResponseBody
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/#method-getResponseBody>`_
    ##
    ## Causes the body of the response to be received from the server and returned as a single string. May only
    ## be issued for a request that is paused in the Response stage and is mutually exclusive with
    ## takeResponseBodyForInterceptionAsStream. Calling other methods that affect the request or disabling
    ## fetch domain before body is received results in an undefined behavior.
    ## 
    ## Note that the response body is not available for redirects. Requests paused in the redirect received
    ## state may be differentiated by responseCode and presence of location response header, see comments
    ## to requestPaused for details.
    result = await tab.sendCommand("Fetch.getResponseBody", %*{"requestId": requestId})

proc takeResponseBodyAsStream*(tab: Tab; requestId: string): Future[JsonNode] {.async.} =
    ## `Fetch.takeResponseBodyAsStream
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/Fetch/#method-takeResponseBodyAsStream>`_
    ## 
    ## Returns a handle to the stream representing the response body. The request must be paused in the
    ## HeadersReceived stage.
    ## 
    ## Note that after this command the request can't be continued as is- client
    ## either needs to cancel it or to provide the response body. The stream only supports sequential
    ## read, IO.read will fail if the position is specified. This method is mutually exclusive with
    ## getResponseBody. Calling other methods that affect the request or disabling fetch domain before
    ## body is received results in an undefined behavior.
    result = await tab.sendCommand("Fetch.takeResponseBodyAsStream", %*{"requestId": requestId})