## This module provides the `HeadlessMode` enum and `startChrome` procedure. `startChrome`
## will find the path to `chrome` executable on the system and launch a new Chrome browser
## instance.
import std/[strutils, os, sequtils, osproc, streams]

type
    BrowserError = object of CatchableError
    ProcessError = object of CatchableError
    HeadlessMode* {.pure.} = enum ## Headless mode options for Chrome.
        On = " --headless=new"
        Off = ""
        Legacy = " --headless"


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
                raise newException(BrowserError, "could not find Chrome using `mdfind`")

    except:
        raise newException(BrowserError, "could not find Chrome in Applications dir or via `mdfind` on macOS system")

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
        raise newException(BrowserError, "could not find Chrome via default/backup paths or registry on Windows system")

proc findChromeLinux: string =
    const chromeNames = ["google-chrome", "google-chrome-stable", "chromium-browser", "chromium"]
    for name in chromeNames:
        if execCmd("which " & name) == 0:
            return name
    raise newException(BrowserError, "could not find Chrome or Chromium via `which` on Linux system")

proc findChromePath: string =
    when hostOS == "macosx":
        result = findChromeMac()
    elif hostOS == "windows":
        result = findChromeWindows()
    elif hostOS == "linux":
        result = findChromeLinux()
    else:
        raise newException(BrowserError, "unkown OS in `findPath` procedure: " & hostOS)

proc startChrome*(portNo: int; userDataDir: string; headless: HeadlessMode;
                  chromeArguments: seq[string]): tuple[chrome: Process, cdpEndPoint: string] =
    ## Launches a new Chrome browser instance.
    ## 
    ## Returns a `tuple` containing the chrome process (`Process`) and the CDP endpoint (`string`).
    var command = findChromePath() & " --remote-debugging-port=" & $portNo &
                " --user-data-dir=" & userDataDir & " --no-first-run" & $headless
    for arg in chromeArguments:
        command.add(" " & arg.strip())

    let
        process = startProcess(command, options={poStdErrToStdOut, poUsePath, poEvalCommand})
        outputStream = process.outputStream()
    while process.running() and not outputStream.atEnd():
        let line = outputStream.readLine()
        if "DevTools listening" in line:
            result.cdpEndPoint = line[22 .. ^1] # path to CDP websocket endpoint
            break
        elif "Opening in existing browser session" in line:
            process.terminate()
            process.close()
            raise newException(ProcessError,
                "chrome is using an existing session.\nend all other chrome processes and try again.\n" &
                "note: you can leave your normal browser window/session alone.")
        elif line == "": continue
        else:
            process.terminate()
            process.close()
            raise newException(ProcessError, "unexpected output from Chrome: " & line)
    if result.cdpEndPoint == "":
        if process.running():
            process.terminate()
            process.close()
        raise newException(ProcessError, "result is empty. could not find CDP websocket endpoint in Chrome output.")
    result.chrome = process