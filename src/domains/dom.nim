## This module provides a direct mapping of CDP events and commands for v1.3 (stable) of the
## `DOM Domain <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/>`_.
## 
## The **DOM Domain** exposes DOM read/write operations. Each DOM Node is represented with its mirror object
## that has an `id`. This `id` can be used to get additional information on the Node, resolve it into the
## JavaScript object wrapper, etc. It is important that client receives DOM events only for the nodes
## that are known to the client.
## 
## Backend keeps track of the nodes that were sent to the client and
## never sends the same node twice. It is client's responsibility to collect information about the
## nodes that were sent to the client. Note that `iframe` owner elements will return corresponding
## document elements as their child nodes.

import std/[json, asyncdispatch]
import ../core/base

type
    DOM* {.pure.} = enum ## **DOM Domain** events
        attributeModified = "DOM.attributeModified"
        attributeRemoved = "DOM.attributeRemoved"
        characterDataModified = "DOM.characterDataModified"
        childNodeCountUpdated = "DOM.childNodeCountUpdated"
        childNodeInserted = "DOM.childNodeInserted"
        childNodeRemoved = "DOM.childNodeRemoved"
        documentUpdated = "DOM.documentUpdated"
        setChildNodes = "DOM.setChildNodes"

proc describeNode*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `DOM.describeNode
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-describeNode>`_
    ##
    ## Describes node given its id, does not require domain to be enabled. Does not start
    ## tracking any objects, can be used for automation.
    result = await tab.sendCommand("DOM.describeNode", params)
proc describeNode*(tab: Tab): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("DOM.describeNode")

proc disableDOMDomain*(tab: Tab) {.async} =
    ## `DOM.disable
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-disable>`_
    ##
    ## Disables the DOM agent for the given page.
    discard await tab.sendCommand("DOM.disable")

proc enableDOMDomain*(tab: Tab; params: JsonNode) {.async.} =
    ## `DOM.enable
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-enable>`_
    ##
    ## Enables the DOM agent for the given page.
    discard await tab.sendCommand("DOM.enable", params)
proc enableDOMDomain*(tab: Tab) {.async.} =
    discard await tab.sendCommand("DOM.enable")

proc focus*(tab: Tab; params: JsonNode) {.async.} =
    ## `DOM.focus
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-focus>`_
    ##
    ## Focuses the given element.
    discard await tab.sendCommand("DOM.focus", params)
proc focus*(tab: Tab) {.async.} =
    discard await tab.sendCommand("DOM.focus")

proc getAttributes*(tab: Tab; nodeId: string): Future[JsonNode] {.async.} =
    ## `DOM.getAttributes
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-getAttributes>`_
    ##
    ## Returns attributes for the specified node.
    result = await tab.sendCommand("DOM.getAttributes", %*{"nodeId": nodeId})

proc getBoxModel*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `DOM.getBoxModel
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-getBoxModel>`_
    ##
    ## Returns boxes for the given node.
    result = await tab.sendCommand("DOM.getBoxModel", params)
proc getBoxModel*(tab: Tab): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("DOM.getBoxModel")

proc getDocument*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `DOM.getDocument
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-getDocument>`_
    ##
    ## Returns the root DOM node (and optionally the subtree) to the caller. Implicitly
    ## enables the DOM domain events for the current target.
    result = await tab.sendCommand("DOM.getDocument")
proc getDocument*(tab: Tab): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("DOM.getDocument")

proc getNodeForLocation*(tab: Tab; x, y: int; params: JsonNode): Future[JsonNode] {.async.} =
    ## `DOM.getNodeForLocation
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-getNodeForLocation>`_
    ##
    ## Returns node id at given location. Depending on whether DOM domain is enabled, nodeId
    ## is either returned or not.
    params["x"] = newJInt(x)
    params["y"] = newJInt(y)
    result = await tab.sendCommand("DOM.getNodeForLocation", params)
proc getNodeForLocation*(tab: Tab; x, y: int): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("DOM.getNodeForLocation", %*{"x": x, "y": y})

proc getOuterHTML*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `DOM.getOuterHTML
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-getOuterHTML>`_
    ##
    ## Returns node's HTML markup.
    result = await tab.sendCommand("DOM.getOuterHTML", params)
proc getOuterHTML*(tab: Tab): Future[JsonNode] {.async.} =
    result = await tab.sendCommand("DOM.getOuterHTML")

proc hideHighlight*(tab: Tab) {.async.} =
    ## `DOM.hideHighlight
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-hideHighlight>`_
    ##
    ## Hides any highlight.
    discard await tab.sendCommand("DOM.hideHighlight")

proc highlightNode*(tab: Tab) {.async.} =
    ## `DOM.highlightNode
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-highlightNode>`_
    ##
    ## Highlights DOM node.
    discard await tab.sendCommand("DOM.highlightNode")

proc highlightRect*(tab: Tab) {.async.} =
    ## `DOM.highlightRect
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-highlightRect>`_
    ##
    ## Highlights given rectangle.
    discard await tab.sendCommand("DOM.highlightRect")

proc moveTo*(tab: Tab; nodeId, targetNodeId: string; params: JsonNode):  Future[JsonNode] {.async.} =
    ## `DOM.moveTo
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-moveTo>`_
    ##
    ## Moves node into the new container, places it before the given anchor.
    params["nodeId"] = newJString(nodeId)
    params["targetNodeId"] = newJString(targetNodeId)
    result = await tab.sendCommand("DOM.moveTo", params)
proc moveTo*(tab: Tab; nodeId, targetNodeId: string):  Future[JsonNode] {.async.} =
    result = await tab.sendCommand("DOM.moveTo", %*{"nodeId": nodeId, "targetNodeId": targetNodeId})

proc querySelector*(tab: Tab; nodeId, selector: string): Future[JsonNode] {.async.} =
    ## `DOM.querySelector
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-querySelector>`_
    ##
    ## Executes `querySelector` on a given node.
    result = await tab.sendCommand("DOM.querySelector", %*{"nodeId": nodeId, "selector": selector})

proc querySelectorAll*(tab: Tab; nodeId, selector: string): Future[JsonNode] {.async.} =
    ## `DOM.querySelectorAll
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-querySelectorAll>`_
    ##
    ## Executes `querySelectorAll` on a given node.
    result = await tab.sendCommand("DOM.querySelectorAll", %*{"nodeId": nodeId, "selector": selector})

proc removeAttribute*(tab: Tab; nodeId, name: string) {.async.} =
    ## `DOM.removeAttribute
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-removeAttribute>`_
    ##
    ## Removes attribute with given name from an element with given id.
    discard await tab.sendCommand("DOM.removeAttribute", %*{"nodeId": nodeId, "name": name})

proc removeNode*(tab: Tab; nodeId: string) {.async.} =
    ## `DOM.removeNode
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-removeNode>`_
    ##
    ## Removes node with given id.
    discard await tab.sendCommand("DOM.removeNode", %*{"nodeId": nodeId})

proc requestChildNodes*(tab: Tab; nodeId: string; params: JsonNode) {.async.} =
    ## `DOM.requestChildNodes
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-requestChildNodes>`_
    ##
    ## Requests that children of the node with given id are returned to the caller in form of
    ## `setChildNodes` events where not only immediate children are retrieved, but all children down to the specified depth.
    params["nodeId"] = newJString(nodeId)
    discard await tab.sendCommand("DOM.requestChildNodes", params)
proc requestChildNodes*(tab: Tab; nodeId: string) {.async.} =
    discard await tab.sendCommand("DOM.requestChildNodes", %*{"nodeId": nodeId})

proc requestNode*(tab: Tab; objectId: string): Future[JsonNode] {.async.} =
    ## `DOM.requestNode
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-requestNode>`_
    ##
    ## Requests that the node is sent to the caller given the JavaScript node object reference.
    ## All nodes that form the path from the node to the root are also sent to the client as a series
    ## of `setChildNodes` notifications.
    result = await tab.sendCommand("DOM.requestNode", %*{"objectId": objectId})

proc resolveNode*(tab: Tab; params: JsonNode): Future[JsonNode] {.async.} =
    ## `DOM.resolveNode
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-resolveNode>`_
    ##
    ## Resolves the JavaScript node object for a given `NodeId` or `BackendNodeId`.
    result = await tab.sendCommand("DOM.resolveNode", params)

proc scrollIntoViewIfNeeded*(tab: Tab; params: JsonNode) {.async.} =
    ## `DOM.scrollIntoViewIfNeeded
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-scrollIntoViewIfNeeded>`_
    ##
    ## Scrolls the specified rect of the given node into view if not already visible.
    ## Note: exactly one between `nodeId`, `backendNodeId` and `objectId` should be passed to identify the node.
    discard await tab.sendCommand("DOM.scrollIntoViewIfNeeded", params)

proc setAttributesAsText*(tab: Tab; nodeId, text: string; params: JsonNode) {.async} =
    ## `DOM.setAttributesAsText
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-setAttributesAsText>`_
    ##
    ## Sets attributes on element with given id. This method is useful when user edits some existing
    ## attribute value and types in several attribute name/value pairs.
    params["nodeId"] = newJString(nodeId)
    params["text"] = newJString(text)
    discard await tab.sendCommand("DOM.setAttributesAsText", params)
proc setAttributesAsText*(tab: Tab; nodeId, text: string) {.async} =
    discard await tab.sendCommand("DOM.setAttributesAsText", %*{"nodeId": nodeId, "text": text})

proc setAttributeValue*(tab: Tab; nodeId, name, value: string) {.async.} =
    ## `DOM.setAttributeValue
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-setAttributeValue>`_
    ##
    ## Sets attribute for an element with given id.
    discard await tab.sendCommand("DOM.setAttributeValue", %*{"nodeId": nodeId, "name": name, "value": value})

proc setFileInputFiles*(tab: Tab; files: seq[string]; params: JsonNode) {.async.} =
    ## `DOM.setFileInputFiles
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-setFileInputFiles>`_
    ##
    ## Sets files for the given file input element.
    params["files"] = %files
    discard await tab.sendCommand("DOM.setFileInputFiles", params)
proc setFileInputFiles*(tab: Tab; files: seq[string]) {.async.} =
    discard await tab.sendCommand("DOM.setFileInputFiles", %*{"files": files})

proc setNodeName*(tab: Tab; nodeId, name: string): Future[JsonNode] {.async.} =
    ## `DOM.setNodeName
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-setNodeName>`_
    ##
    ## Sets node name for a node with given id.
    result = await tab.sendCommand("DOM.setNodeName", %*{"nodeId": nodeId, "name": name})

proc setNodeValue*(tab: Tab; nodeId, value: string) {.async.} =
    ## `DOM.setNodeValue
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-setNodeValue>`_
    ##
    ## Sets node value for a node with given id.
    discard await tab.sendCommand("DOM.setNodeValue", %*{"nodeId": nodeId, "value": value})

proc setOuterHTML*(tab: Tab; nodeId, outerHTML: string) {.async.} =
    ## `DOM.setOuterHTML
    ## <https://chromedevtools.github.io/devtools-protocol/1-3/DOM/#method-setOuterHTML>`_
    ##
    ## Sets node HTML markup, returns new node id.
    discard await tab.sendCommand("DOM.setOuterHTML", %*{"nodeId": nodeId, "outerHTML": outerHTML})