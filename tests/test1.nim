import std/[unittest, json, asyncdispatch, os]
import cdp

let browser = waitFor launchBrowser("", 5001, HeadlessMode.Off, @["--enable-automation"])
                                                        # --suppress-message-center-popups
test "Proof Of Concept":
    let tab = waitFor browser.newTab()
    discard waitFor tab.navigate("https://github.com/Niminem")
    let title = waitFor tab.evaluate("document.title", %*{"returnByValue": true})
    echo "Title of the page is: ", $(title)
    sleep 8000
    waitFor browser.close()
    echo "Browser closed."