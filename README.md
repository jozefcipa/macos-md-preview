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
./build.sh
open ~/Applications/MDPreview.app   # once, so macOS registers the extension
killall Finder
```

`build.sh` builds the app and extension into `build/`, ad-hoc signs them, copies `MDPreview.app` to `~/Applications`, and registers the extension with `pluginkit`.

If Finder still shows the plain-text preview, run `qlmanage -r` and relaunch Finder (or log out and back in).

## How it works

Quick Look extensions must live inside an app bundle, so `MDPreview.app` is an empty host app (`main.swift`) that carries `MDPreviewExtension.appex`.

The extension (`PreviewProvider.swift`) is a data-based `QLPreviewProvider`. It reads the file, converts Markdown to HTML with [marked](https://github.com/markedjs/marked) and highlights code with [highlight.js](https://highlightjs.org), both running in JavaScriptCore, and returns the HTML to Quick Look. Rendering happens in Swift because Quick Look does not run JavaScript in HTML previews.

## Files

| File | Purpose |
|---|---|
| `PreviewProvider.swift` | The Quick Look extension |
| `main.swift` | Empty host app |
| `Extension-Info.plist`, `App-Info.plist` | Bundle metadata; supported content types live in the extension plist |
| `sandbox.entitlements` | App Sandbox entitlements (required for extensions) |
| `marked.min.js`, `highlight.min.js`, `hl-*.css` | Vendored renderer, highlighter and themes |
| `build.sh` | Build, sign and install |

## Uninstall

```sh
pluginkit -r ~/Applications/MDPreview.app/Contents/PlugIns/MDPreviewExtension.appex
rm -rf ~/Applications/MDPreview.app
qlmanage -r
```

## Third-party licenses

- marked v15.0.12, MIT
- highlight.js v11.9.0, BSD-3-Clause
