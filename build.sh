#!/bin/sh
set -e
cd "$(dirname "$0")"
APP=build/MDPreview.app
EXT=$APP/Contents/PlugIns/MDPreviewExtension.appex
rm -rf build
mkdir -p "$APP/Contents/MacOS" "$EXT/Contents/MacOS" "$EXT/Contents/Resources"

swiftc -O -module-name MDPreviewExtension -application-extension \
  -Xlinker -e -Xlinker _NSExtensionMain \
  PreviewProvider.swift -o "$EXT/Contents/MacOS/MDPreviewExtension"
cp Extension-Info.plist "$EXT/Contents/Info.plist"
cp marked.min.js highlight.min.js hl-light.css hl-dark.css "$EXT/Contents/Resources/"

swiftc -O main.swift -o "$APP/Contents/MacOS/MDPreview"
cp App-Info.plist "$APP/Contents/Info.plist"

codesign -f -s - --entitlements sandbox.entitlements "$EXT"
codesign -f -s - --entitlements sandbox.entitlements "$APP"

rm -rf ~/Applications/MDPreview.app
mkdir -p ~/Applications
cp -R "$APP" ~/Applications/
pluginkit -a ~/Applications/MDPreview.app/Contents/PlugIns/MDPreviewExtension.appex
qlmanage -r >/dev/null && qlmanage -r cache >/dev/null
echo "Installed to ~/Applications/MDPreview.app"
