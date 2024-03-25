## This module will find the path to `chrome` or `chromium` executable on the system
## and start it with *remote debugging port* and *user data directory*.
##
## By default, it will start the browser in **headless mode** using the old version.
## If you want to use the new version of headless mode, you can pass `HeadlessMode.New`
## as the third argument as long as you're using Chrome Version >= 112. This is
## recommended as the old version of headless mode will be deprecated, and the new
## version is the actual browser rather than a separate browser implementation.

import std/[strutils, os, sequtils, osproc, streams]
import base

type
    BrowserNotFound = object of CatchableError
    HeadlessMode* {.pure.} = enum ## Headless mode for Chrome
        On, Off, Legacy


proc findChromeMac: string =
    const defaultPath :string = r"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    const name = "Google Chrome.app"

    try:
        if fileExists(absolutePath(defaultPath)):
            result = defaultPath.replace(" ", r"\ ")
        else:
            var alternateDirs = execProcess("mdfind", args = [name], options = {poUsePath}).split("\n")
            alternateDirs.keepItIf(it.contains(name))
        
            if alternateDirs != @[]:
                result = alternateDirs[0] & "/Contents/MacOS/Google Chrome"
            else:
                raise newException(BrowserNotFound, "could not find Chrome using `mdfind`")

    except:
        raise newException(BrowserNotFound, "could not find Chrome in Applications directory")

when defined(Windows):
    import std/registry

proc findChromeWindows: string =
    const defaultPath = r"\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    const backupPath = r"\Program Files\Google\Chrome\Application\chrome.exe"
    if fileExists(absolutePath(defaultPath)):
        result = defaultPath
    elif fileExists(absolutePath(backupPath)):
        result = backupPath
    else:
        when defined(Windows):
            result = getUnicodeValue(
                path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe",
                key = "", handle = HKEY_LOCAL_MACHINE)
        discard

    if result.len == 0:
        raise newException(BrowserNotFound, "could not find Chrome")

proc findChromeLinux: string =
    const chromeNames = ["google-chrome", "google-chrome-stable", "chromium-browser", "chromium"]
    for name in chromeNames:
        if execCmd("which " & name) == 0:
            return name
    raise newException(BrowserNotFound, "could not find Chrome")

proc findChromePath: string =
    when hostOS == "macosx":
        result = findChromeMac()
    elif hostOS == "windows":
        result = findChromeWindows()
    elif hostOS == "linux":
        result = findChromeLinux()
    else:
        raise newException(BrowserNotFound, "unkown OS in findPath(): " & hostOS)

proc startChrome*(portNo: int; userDataDir: string; headless: HeadlessMode;
                  chromeArguments: seq[string]): string =
    var command = findChromePath() & " --remote-debugging-port=" & $portNo &
                " --user-data-dir=" & userDataDir & " --no-first-run"
    command.add(
        case headless
            of HeadlessMode.On: " --headless=new"
            of HeadlessMode.Off: ""
            of HeadlessMode.Legacy: " --headless=new"
            )
    
    for arg in chromeArguments:
        command.add(" " & arg.strip())

    let
        process = startProcess(command, options={poStdErrToStdOut, poUsePath, poEvalCommand})
        outputStream = process.outputStream()
    while process.running() and not outputStream.atEnd():
        let line = outputStream.readLine()
        if "DevTools listening" in line:
            result = line[22 .. ^1] # path to websocket endpoint # https://github.com/aslushnikov/getting-started-with-cdp/blob/master/README.md#protocol-fundamentals
            break
        elif "Opening in existing browser session" in line:
            process.close()
            raise newException(CatchableError, "Chrome is using an existing session. Something is wrong.")
            # TODO: better error handling
        elif line == "": continue
        else:
            when defined(debug): log("Chrome instance line: " & line)
            discard
        # TODO: do we need to handle errors here?
    # TODO: for some reason... process stops running before the while loop or maybe
    # after the while loop runs once. Need to investigate this.
    process.close()