# Package
version       = "0.1.0"
author        = "Niminem"
description   = "Low-level Nim wrapper for Chrome DevTools Protocol (CDP) v1.3 stable. Bend Chrome to your will with complete control over your browser. Scrape dynamic webpages, create browser automations, and beyond."
license       = "MIT"
skipDirs      = @["docs"]
srcDir        = "src"

# Dependencies
requires "nim >= 2.0.0"
requires "ws >= 0.5.0"