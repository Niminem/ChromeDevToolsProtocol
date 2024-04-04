# ChromeDevToolsProtocol
Low-level Nim wrapper for [Chrome DevTools Protocol (CDP) v1.3 stable](https://chromedevtools.github.io/devtools-protocol/1-3/).

***Bend Chrome to your will*** with complete control over your browser. Scrape dynamic webpages, create browser automations, and beyond. Wield responsibly ;)

> **Chrome v112 or higher recommended**. [It's better](https://developer.chrome.com/docs/chromium/new-headless),
    as the new `headless` flag uses the same browser binary rather than a completely seperate implemenation. It's likely your version of Chrome is a more recent version.

#### NOTE:

This library is intended to be a low-level wrapper of CDP for use in a webcrawler and a few browser automation projects for my company [SEO Science](https://www.seo.science). We only target v1.3 stable version of CDP as we want to reduce the
amount of maintenance overhead, and ensure reliability of the library in
production use.

We may include some of the experimental Domains and methods in the future. **PRs welcome**.

If you would like to use an experimental feature (like the [Animation Domain](https://chromedevtools.github.io/devtools-protocol/tot/Animation/)), you will have to use the `sendCommand` procedure to access them. Details below.

## Installation

Install from nimble (pending as of 4/4/24): `nimble install cdp`

Alternatively clone via git: `git clone https://github.com/Niminem/ChromeDevToolsProtocol`

## Basic Usage

```nim
import std/[json, asyncdispatch]
import cdp

proc main() {.async.} =
    let
        browser = await launchBrowser() # launch a new browser
        tab = await browser.newTab() # open a new tab
    await tab.enablePageDomain() # enable the Page domain (for monitoring page events)
    discard await tab.navigate("https://github.com/Niminem") # navigate to a page
    discard await browser.waitForSessionEvent(tab.sessionId, $Page.domContentEventFired) # wait for page to load
    let
        resp = await tab.evaluate("document.title", %*{"returnByValue": true}) # evaluate a script on the page
        title = resp["result"]["result"]["value"].to(string) # get the title of the page
    echo "Title of the page: ", title # Title of the page: Niminem (Leon Lysak) · GitHub
    await tab.disablePageDomain() # disable the Page domain
    await browser.close() # close the browser / cdp, websocket, delete userdatadir, terminate browser process

waitFor main()
```

## Getting Started With CDP

I highly recommend reading Aslushnikov's [README](https://github.com/aslushnikov/getting-started-with-cdp) on using Chrome DevTools Protocol. I'll try my best to explain the concepts
and how this relates to this API.

### Introduction

The Chrome DevTools Protocol allows for tools to instrument, inspect, debug and profile Chromium, Chrome and other Blink-based browsers (like Microsoft Edge).

Even Chrome DevTools uses this protocol and the team maintains its API.

### Protocol Fundamentals

When Chromium is started with a `--remote-debugging-port=<number>` flag, it starts a Chrome DevTools Protocol server and prints a Websocket URL.













## Currently in development as of 3/24/24. Not ready for general use. ##

### Major Goals:

#### Compatability & Reliability
Since this is a low-level wrapper of CDP:
1. Event type enums for each domain will force the use the proper events.
2. Thin wrapper over **all** v1.3 stable methods (commands)
3. Granular session/global event functions. Force use of add/delete/waitFor for all events.

#### Flexibility & Extensibility

1. A general `sendCommand` procedure will be avaiable for Browser and Page
        targets so the developer can use domains/commands not in v1.3 stable docs.
        Example: the [Media Domain](https://chromedevtools.github.io/devtools-protocol/tot/Media/)
2. If any commands should have a response, it is of
        type `Future[Json]`. This is because some CDP `return objects` return optional
        parameters. Example: [DOM.getNodeForLocation](https://chromedevtools.github.io/devtools-protocol/1-3/DOM/).
3. Very basic error handling so the developer can roll their own handlers.

---

### Recent Updates:
- All of CDP v1.3 methods (commands) and events have been wrapped.
- Documentation for all CDP Domains are complete
- Simple convenience functions for adding/removing/waitingFor events exist. Events are currently seperated into two types- Global and Session, each with their own functions. (check out `tests/test1.nim`)
- There are a handful of methods that aren't direct mappings because multiple Domains use the same naming convention. In this case, we use the pattern `{method}{Domain}Domain`. Ex: `enablePageDomain` instead of `enable`.
- Some wrapped CDP methods contain both required and optional parameters. You can pass in a `JsonNode`
        for the optional parameters. Everything will be combined into the final JSON
        sent to the CDP connection.
- Here's a [complete list of chrome arguments](https://peter.sh/experiments/chromium-command-line-switches/) to use in your projects. [This page](https://github.com/puppeteer/puppeteer/blob/main/packages/puppeteer-core/src/node/ChromeLauncher.ts) contains chrome arguments that Puppeteer, a high-level API for CDP using Nodejs, uses.
- Your mileage may vary with some of the methods as all aren't covered in testing. **PRs welcome**.

---

### Todo List:
- Create 'Getting Started With CDP' section in the README, similar to [this](https://github.com/aslushnikov/getting-started-with-cdp/blob/master/README.md) but with our API (ensure this also contains all of our API usage).
- Create **basic** error handling. Chrome process is priority (sometimes the process returns early or chrome itself breaks), followed by events, then CDP responses.
- Create more tests.
- We may want to allow multiple callbacks for session or global events (if so, modify the appropriate add/delete/waitFor procs)
- Create documentation pages for the API via `docgen` to help developers easily reference CDP methods/events (documentation is currently finished for ALL CDP Domains).
- Include how-to for wrapping currently unsupported experimental domains, and domain methods and events in the README.

---
