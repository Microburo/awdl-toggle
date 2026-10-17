#!/bin/bash
# Build AWDLToggle.prefPane and install it in ~/Library/PreferencePanes
set -euo pipefail
cd "$(dirname "$0")"
B=build/AWDLToggle.prefPane/Contents
mkdir -p "$B/MacOS"
cp Info.plist "$B/Info.plist"
mkdir -p "$B/Resources"
cp Resources/AWDLToggle.icns "$B/Resources/"
swiftc -O -emit-library -module-name AWDLToggle -target arm64-apple-macos14 \
  -framework AppKit -framework PreferencePanes \
  -o "$B/MacOS/AWDLToggle" src/AWDLPane.swift
codesign --force --sign - build/AWDLToggle.prefPane
mkdir -p ~/Library/PreferencePanes
rm -rf ~/Library/PreferencePanes/AWDLToggle.prefPane
cp -R build/AWDLToggle.prefPane ~/Library/PreferencePanes/
echo "installed ~/Library/PreferencePanes/AWDLToggle.prefPane"
