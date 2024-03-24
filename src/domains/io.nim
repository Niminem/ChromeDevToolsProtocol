## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `IO Domain <https://chromedevtools.github.io/devtools-protocol/1-3/IO/>`_.
## 
## Input/Output operations for streams produced by DevTools.

import std/[json, asyncdispatch]
import ../core/base

proc closeIODomain*(context: Browser | Tab) {.async.} =
    ## `IO.close <https://chromedevtools.github.io/devtools-protocol/1-3/IO/#method-close>`_
    ##
    ## Close the stream, discard any temporary backing storage.
    discard await context.sendCommand("IO.close")

proc read*(context: Browser | Tab; handle: string; params: JsonNode): Future[JsonNode] {.async.} =
    ## `IO.read <https://chromedevtools.github.io/devtools-protocol/1-3/IO/#method-read>`_
    ##
    ## Read a chunk of the stream
    params["handle"] = handle
    result = await context.sendCommand("IO.read", params)
proc read*(context: Browser | Tab; handle: string): Future[JsonNode] {.async.} =
    result = await context.sendCommand("IO.read", %*{"handle": handle})

proc resolveBlob*(context: Browser | Tab; objectId: string): Future[JsonNode] {.async.} =
    ## `IO.resolveBlob <https://chromedevtools.github.io/devtools-protocol/1-3/IO/#method-resolveBlob>`_
    ##
    ## Return UUID of Blob object specified by a remote object id.
    result = await context.sendCommand("IO.resolveBlob", %*{"objectId": objectId})