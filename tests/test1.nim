import std/[unittest, json, asyncdispatch]
import cdp


proc logGlobalEvent(event: JsonNode) {.async.} = echo "Logging Global Event: " & event["method"].to(string)
proc logSessionEvent(event: JsonNode) {.async.} = echo "Logging Session Event: " & event["method"].to(string)

test "Proof Of Concept":
    let browser = waitFor launchBrowser(headlessMode=HeadlessMode.Off)
    let tab = waitFor browser.newTab()
    discard waitFor tab.navigate("https://nim-lang.org")
    waitFor sleepAsync(2000) # for monitoring chrome process in task manager / activity monitor
    waitFor browser.close()

test "Basic Functionality":
    let browser = waitFor launchBrowser(portNo=5001, headlessMode= HeadlessMode.On,
                                    chromeArguments= @["--suppress-message-center-popups"])
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
    check(title == "Niminem (Leon Lysak) · GitHub")
    waitFor tab.disablePageDomain()
    browser.deleteGlobalEventCallback("Target.attachedToTarget")
    browser.deleteGlobalEventCallback("Target.detachedFromTarget")
    browser.deleteSessionEventCallback(tab.sessionId, $Page.frameNavigated)
    waitFor sleepAsync 3500 # for monitoring chrome process in task manager / activity monitor
    waitFor browser.close()