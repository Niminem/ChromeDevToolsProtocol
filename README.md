# ChromeDevToolsProtocol
Low-level Nim wrapper for [Chrome DevTools Protocol (CDP) v1.3 stable](https://chromedevtools.github.io/devtools-protocol/1-3/).

***Bend Chrome to your will*** with complete control over your browser. Scrape dynamic webpages, create browser automations, and beyond. Wield responsibly ;)

> **Chrome v112 or higher recommended**. [It's better](https://developer.chrome.com/docs/chromium/new-headless),
    as the new `headless` flag uses the same browser binary rather than a completely seperate implemenation. It's likely your version of Chrome already has a more recent version.

This library is cross-platform (Windows, Mac, Linux) and supports both the C and C++ backends.

#### NOTE:

`cdp` is intended to be a low-level wrapper of CDP for use in a webcrawler and a few browser automation projects for my company [SEO Science](https://www.seo.science). We only target v1.3 stable version of CDP as we want to reduce the
amount of maintenance overhead, and ensure reliability of the library in
production use.

We may include some of the experimental Domains, methods, and events in the future. **PRs welcome**.

If you would like to use an experimental feature (like the [Animation Domain](https://chromedevtools.github.io/devtools-protocol/tot/Animation/)), you certainly can via the `sendCommand` procedure. Details below.

## Dependencies

**A Chrome browser**. Pretty cool right? No webdriver binary. No other dependencies outside of what you probably already have on your system.

*In the future, we do plan to add support for Chromium and Edge.*

## Installation

Install from nimble (pending as of 4/4/24): `nimble install cdp`

Alternatively clone via git: `git clone https://github.com/Niminem/ChromeDevToolsProtocol`

## Basic Usage

Check out the [tests directory](https://github.com/Niminem/ChromeDevToolsProtocol/tree/main/tests) for more examples.

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

I highly recommend reading Aslushnikov's [README](https://github.com/aslushnikov/getting-started-with-cdp) on using Chrome DevTools Protocol as a quick primer. I'll try my best to explain the concepts
and how they relate to this API.

### Introduction

The Chrome DevTools Protocol allows for tools to instrument, inspect, debug and profile Chromium, Chrome and other Blink-based browsers (like Microsoft Edge).

Even Chrome DevTools uses this protocol and the team maintains its API.

### Protocol Fundamentals

When Chrome is started with a `--remote-debugging-port=<number>` flag, it starts a Chrome DevTools Protocol server and creates a WebSocket URL. Clients can create a WebSocket to connect to the URL and start sending CDP commands.

Chrome DevTools protocol is mostly based on [JSONRPC](https://www.jsonrpc.org/specification): each comand is a JSON object with an `id`, a `method`, and an optional `params` (JSON object).

A few things to keep in mind:
- Every command that is sent over to CDP must have a unique `id` parameter. Message responses will be delivered over websocket and will have the same `id`.
- Incoming WebSocket messages *without* an `id` parameter are **protocol events**.
- Message order is important in CDP. For example, protocol events related to a CDP command that was sent will be reported before the response.
- There's a top-level "browser" target that always exists. More on this in the next section.

This library provides a level of abstraction by wrapping the various CDP commands (methods) in v1.3 stable:

```nim
# Navigates current page (tab) to the given URL.
proc navigate(tab: Tab; url: string; params: JsonNode): Future[JsonNode]
proc navigate(tab: Tab; url: string): Future[JsonNode]
# reference: https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-navigate
```

`cdp` also abstracts away other things, like the management of the unique `id` parameter for commands.

### Targets & Sessions

Chrome DevTools protocol has APIs to interact with many different parts of the browser - such as pages (this library refers to them as *tabs*), serviceworkers and extensions. These parts are called **Targets** and can be fetched/tracked using the [Target domain](https://chromedevtools.github.io/devtools-protocol/1-3/Target/).

When a client wants to interact with a target using CDP, it has to first attach to the target using `Target.attachToTarget` command. The command will establish a protocol session to the given target and return a `sessionId`.

In order to submit a CDP command to the target, every message should also include a `sessionId` parameter next to the usual JSONRPC’s `id`.

This library provides a level of abstraction for a page (tab) target:

```nim
...
let tab = await browser.newTab() # opens a new page (tab)
discard await tab.navigate("https://github.com/Niminem") # navigate to a page
...
```

With `browser.newTab()`, the procedure will create a target (page), attach to it, and the sessionId (a field of
the returned `Tab` object) will be used in all future commands from the `Tab`.

Some commands **set state** which is stored **per session** (ex: `Runtime.enable` and `Targets.setDiscoverTargets`). Each session is initialized with a set of domains, the exact set depends on the attached target. For example, sessions connected to a browser don't have a "Page" domain, but sessions connected to pages do.

We call sessions attached to a Browser target *browser sessions*. Similarly, there are *page sessions*, *worker sessions* and so on. In fact, the WebSocket connection is an implicitly created **browser session**.

Although this library currently provides an abstraction over a Page target (tab) and the implicit Browser target, you can create other targets with the generic `sendCommand` procedure. More on this below.

### Session Hierarchy

When a client connects over the WebSocket to the launched Chrome browser, a *root* browser session is created. This session is the one that receives commands if there's no `sessionId` specified. Essentially, this refers to the `Browser` object returned from the `launchBrowser` procedure. Later on, when the root browser session is used to attach to a page target, a new page session created (the `Tab` object).

The page session is created from inside the browser session and thus is a **child** of the browser session. When a parent session closes (ex: `Target.detachFromTarget`), all of its child sessions are closed as well.

As of `cdp` 0.1.0, the `browser.close()` procedure will close the browser session (thus closing all of the child sessions).
More granular closing procedures must be implemented on your end for now.

### Stable vs Experimental methods

The Chrome DevTools Protocol has stable and experimental parts. Events, methods, and sometimes whole domains might be marked as experimental. DevTools team doesn't commit to maintaining experimental APIs and changes/removes them regularly.

**!!! USE EXPERIMENTAL APIS AT YOUR OWN RISK !!!**

As history has shown, experimental APIs do change quite often. If possible, stick to the stable protocol (the wrapped commands
and events from this library).

## API Overview

Check out the full API documentation [here](https://niminem.github.io/CDP/cdp.html).

### The Browser Object

```nim
proc launchBrowser*(userDataDir = "";
                    portNo = 0; headlessMode = HeadlessMode.On;
                    chromeArguments: seq[string] = @[]): Future[Browser] {.async}
```

Using the `cdp` library begins with `Browser` instance.

Use this Browser instance (browser Target / browser session) to interact with the appropriate CDP domains/methods.

`launchBrowser` Launches a new Chrome browser instance and returns a `Browser` object.

- `userDataDir` parameter can be used to specify a directory where the
browser's user data will be stored. If an empty string is passed, a temporary
directory will be created and used.
- `portNo` parameter can be used to specify a port number for the browser to
listen on. If `portNo` is 0, chrome will choose a random port.
- `headlessMode` parameter can be used to specify whether the browser should be
launched in headless mode or not. `HeadlessMode.On` (the default) will launch
the new version of Chrome headless mode (for Chrome >= v112). **Use `HeadlessMode.Legacy`
to launch the browser in headless mode for Chrome < v112.** The new headless mode is
recommended as the old version of headless mode will be deprecated, and the new version
is the actual browser rather than a separate browser implementation.
- `chromeArguments` parameter can be used to pass additional arguments to the
Chrome browser instance. For a list of all available arguments, see:
https://peter.sh/experiments/chromium-command-line-switches/ or
https://github.com/puppeteer/puppeteer/blob/main/packages/puppeteer-core/src/node/ChromeLauncher.ts
for a list of arguments used by Puppeteer.

The following command-line arguments are *always* passed to Chrome:
- `--remote-debugging-port=<portNo>`
- `--user-data-dir=<userDataDir>`
- `--no-first-run`
- `--headless=new` or `--headless` (if `headlessMode` is `HeadlessMode.On` (default) or `HeadlessMode.Legacy`).
If `HeadlessMode.Off` is passed, Chrome will open a visible window.

**IMPORANT: Make sure you call `browser.close()` when finished with your program or else you will have a zombie process.**

### The Tab Object

```nim
proc newTab*(browser: Browser): Future[Tab] {.async.}
```

`newTab` procedure creates a new tab (Page) with the browser instance and returns a `Tab` object.

Use this `Tab` object to interact with a page session. You can monitor and intercept network events, execute javascript, and so much more via enabling the appropriate domains. This type of session will be used the most.

```nim
# Pulled from the 'Basic Usage' example above
...
await tab.enablePageDomain() # enable the Page domain (for monitoring page events)
discard await tab.navigate("https://github.com/Niminem")
discard await browser.waitForSessionEvent(tab.sessionId, $Page.domContentEventFired) # wait for page to load
...
# It's good practice to disable the domain when you are done
await tab.disablePageDomain()
...
```

Enabling the **Page Domain** allows you monitor page events, such as the `domContentEventFired` event. With this access you
can, for example, scape various parts of a web page after the DOM is ready. Some Domains may need to be enabled to use like
this one. In the [API documentation](https://niminem.github.io/CDP/cdp.html), I've provided direct references to each
domain and each domain's methods/events.

Notice the `tab.navigate` call. This is a wrapped method for the Tab object, directly corresponding to the [navigate CDP
method](https://chromedevtools.github.io/devtools-protocol/1-3/Page/#method-navigate). ALL CDP methods and events for browser and page targets have been wrapped for v1.3 stable.

### Global & Session Event Callbacks

```nim
type
    SessionId* = string
    ProtocolEvent* = string
    EventCallback* = proc(data: JsonNode) {.async.}
# Adds a callback function to the global event table for the specified event
proc addGlobalEventCallback*(browser: Browser; event: ProtocolEvent; cb: EventCallback)
# Adds a callback function to the session event table for the specified event.
proc addSessionEventCallback*(browser: Browser; sessionId: SessionId;
                              event: ProtocolEvent; cb: EventCallback)
# Returns a `Future` that completes when the specified global event is received.
proc waitForGlobalEvent*(browser: Browser; event: ProtocolEvent): Future[JsonNode] {.async.}
# Returns a `Future` that completes when the specified session event is received.
proc waitForSessionEvent*(browser: Browser; sessionId: string;
                          event: ProtocolEvent): Future[JsonNode] {.async.}
```

As of `cdp` 0.1.0, there are two kinds of callbacks- one for handling **Global events** (those without an `id` parameter)
and the other for **Session events** (those corresponding to a session, like a Tab/Page, which have a `sessionId` parameter).

There are two ways you can use them.

Either you register a callback procedure that executes each time the CDP event occurs via `addGlobalEventCallback` or `addSessionEventCallback`, or you can use the `waitFor` variant. `waitFor` should be used to pause execution until the event occurs, like the example above where we waited for `Page.domContentEventFired` before interacting with the tab(page).

**NOTE: Currently, there can only be one callback per *Global event*, and only one callback per event for
each session in *Session events*. If you try adding another callback for the same global/session event, the current callback will be overwritten.**

`deleteGlobalEventCallback` and `deleteSessionEventCallback` can be called to delete the event callbacks.

```nim
import std/[json, asyncdispatch]
import cdp

proc logGlobalEvent(event: JsonNode) {.async.} = echo "Logging Global Event: " & event["method"].to(string)
proc logSessionEvent(event: JsonNode) {.async.} = echo "Logging Session Event: " & event["method"].to(string)

proc main() {.async.} =
    let experimentalGlobalEvent = "Target.attachedToTarget"
    let browser = await launchBrowser()
    browser.addGlobalEventCallback(experimentalGlobalEvent, logGlobalEvent)
    let tab = await browser.newTab()
    browser.addSessionEventCallback(tab.sessionId, $Page.frameNavigated, logSessionEvent)
    await tab.enablePageDomain()
    discard await tab.navigate("https://github.com/Niminem")
    await tab.disablePageDomain()
    browser.deleteGlobalEventCallback(experimentalGlobalEvent)
    browser.deleteSessionEventCallback(tab.sessionId, $Page.frameNavigated)
    await browser.close()

waitFor main()
```

### Using Experimental Features

`cdp` wraps all CDP methods via the `sendCommand` procedure.

```nim
proc sendCommand*(browser: Browser; mthd: string; params: JsonNode): Future[JsonNode] {.async.}
proc sendCommand*(browser: Browser; mthd: string): Future[JsonNode] {.async.}
proc sendCommand*(tab: Tab; mthd: string; params: JsonNode): Future[JsonNode] {.async.}
proc sendCommand*(tab: Tab; mthd: string): Future[JsonNode] {.async.}
```

Wrapped CDP method example:

```nim
proc deleteCookies*(tab: Tab; name: string; params: JsonNode) {.async.} = # optional params exist
    params["name"] = newJString(name)
    discard await tab.sendCommand("Network.deleteCookies", params)
proc deleteCookies*(tab: Tab; name: string) {.async.} = # only 'name' parameter is required
    discard await tab.sendCommand("Network.deleteCookies", %*{"name": name})
```

You can easily use any experimental method with this generic procedure.

Similarly, you can easily use any experimental *CDP event* with the callback functions as they are just strings.
`cdp` provides enums for *stable* events as a convenience so I don't accidently shoot myself in the foot:

```nim
type
    Network* {.pure.} = enum
        dataReceived = "Network.dataReceived",
        eventSourceMessageReceived = "Network.eventSourceMessageReceived",
        loadingFailed = "Network.loadingFailed",
        ...
# used like this:
...
browser.addGlobalEventCallback($Network.dataReceived, procName)
...
# alternatively for experimental events:
...
browser.addGlobalEventCallback("Target.attachedToTarget", procName)
..
```

### Other API Notes
- ALL commands provide a generic `Future[Json]` response containing the `id` of the method called. This is how we can map methods to responses as CDP is a single multiplexed web socket connection (I think I said that right). Use `discard` statement as necessary.
- If any commands should have a non-generic response, it is still of
        the same `Future[Json]` type. This is because some CDP `return objects` return optional
        parameters. Example: [DOM.getNodeForLocation](https://chromedevtools.github.io/devtools-protocol/1-3/DOM/).
There is no efficient way to directly map them all into their return objects.
- Exception handling is basic, accounting mostly for setup and Chrome process stuff. For now, you have to roll your own for CDP methods. I'm certain that CDP provides error message/description in the response.
- Your mileage may vary with some of the methods as all aren't covered in testing. **PRs welcome**.


## Todo List:
- Create 'Getting Started With CDP' section in the README, similar to [this](https://github.com/aslushnikov/getting-started-with-cdp/blob/master/README.md) but with our API (ensure this also contains all of our API usage).
- Create **basic** error handling. Chrome process is priority (sometimes the process returns early or chrome itself breaks), followed by events, then CDP responses.
- Create more tests.
- We may want to allow multiple callbacks for session or global events (if so, modify the appropriate add/delete/waitFor procs)
- Create documentation pages for the API via `docgen` to help developers easily reference CDP methods/events (documentation is currently finished for ALL CDP Domains).
- Include how-to for wrapping currently unsupported experimental domains, and domain methods and events in the README.
