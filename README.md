# macos-md-preview

A minimal Quick Look extension for macOS. Select a `.md` file in Finder, press <kbd>Space</kbd>, and see it rendered.

- GitHub Flavored Markdown (tables, task lists, strikethrough, autolinks)
- Syntax-highlighted code blocks (GitHub light/dark themes)
- Follows the system light/dark appearance
- No Xcode project, no dependencies to install, just `swiftc`

## Requirements

- macOS 13+
- Xcode or the Command Line Tools (for `swiftc` and `codesign`)

## Install

```sh
git clone https://github.com/jozefcipa/macos-md-preview.git
cd macos-md-preview
make install
killall Finder
```

| Target | What it does |
|---|---|
| `make` | Build and ad-hoc sign `build/MDPreview.app` (incremental) |
| `make install` | Build, copy to `~/Applications`, register the extension, reset Quick Look |
| `make uninstall` | Unregister and remove the installed app |
| `make reload` | Reset Quick Look's generator list and cache |
| `make clean` | Remove `build/` |

If Finder still shows the plain-text preview, run `make reload` and relaunch Finder (or log out and back in).

## How it works

Quick Look extensions must live inside an app bundle, so `MDPreview.app` is an empty host app (`Sources/MDPreview/main.swift`) that carries `MDPreviewExtension.appex`.

The extension (`Sources/MDPreviewExtension/PreviewProvider.swift`) is a data-based `QLPreviewProvider`. It reads the file, converts Markdown to HTML with [marked](https://github.com/markedjs/marked) and highlights code with [highlight.js](https://highlightjs.org), both running in JavaScriptCore, and returns the HTML to Quick Look. Rendering happens in Swift because Quick Look does not run JavaScript in HTML previews.

## Project layout

```
Sources/
  MDPreview/               empty host app (main.swift, Info.plist)
  MDPreviewExtension/      the Quick Look extension (PreviewProvider.swift, Info.plist)
Assets/                    vendored marked, highlight.js and GitHub themes
MDPreview.entitlements     App Sandbox entitlements (required for extensions)
Makefile                   build, sign, install, uninstall
```

Supported content types are listed in `Sources/MDPreviewExtension/Info.plist`.

## Uninstall

```sh
make uninstall
```

## Third-party licenses

- marked v15.0.12, MIT
- highlight.js v11.9.0, BSD-3-Clause
