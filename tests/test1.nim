import std/[unittest, json, asyncdispatch]
import cdp

# NOTE: The interaction with CDP events in Puppeteer can be broadly categorized
# into two types: listening to events and triggering functions based on those events.

let browser = waitFor launchBrowser(headlessMode= HeadlessMode.On,
                                    chromeArguments= @["--suppress-message-center-popups"])

proc logGlobalEvent(event: JsonNode) {.async.} =
    echo "Logging Global CDP Event: " & event["method"].getStr()

proc logSessionEvent(event: JsonNode) {.async.} =
    echo "Logging Session CDP Event: " & event["method"].getStr()

test "Proof Of Concept":
    browser.addGlobalEventCallback("Target.attachedToTarget", logGlobalEvent)
    browser.addGlobalEventCallback("Target.detachedFromTarget", logGlobalEvent)
    let tab = waitFor browser.newTab()
    browser.addSessionEventCallback(tab.sessionId, $Page.frameNavigated, logSessionEvent)
    waitFor tab.enablePageDomain()
    discard waitFor tab.navigate("https://github.com/Niminem")
    discard waitFor browser.waitForSessionEvent(tab.sessionId, $Page.domContentEventFired)
    let
        resp = waitFor tab.evaluate("document.title", %*{"returnByValue": true})
        title = resp["result"]["result"]["value"].to(string)
    echo "Title is: " & title
    check(title == "Niminem (Leon Lysak) · GitHub")
    discard waitFor tab.navigate("https://nim-lang.org")
    waitFor tab.disablePageDomain()
    browser.deleteGlobalEventCallback("Target.attachedToTarget")
    browser.deleteGlobalEventCallback("Target.detachedFromTarget")
    browser.deleteSessionEventCallback(tab.sessionId, $Page.frameNavigated)
    # waitFor sleepAsync(5000) # monitoring Task Manager for the browser process
    waitFor browser.close()