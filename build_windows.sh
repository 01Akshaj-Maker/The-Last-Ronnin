#!/usr/bin/env bash
#
# build_windows.sh — re-export a fresh playable Windows build of The Last Ronin.
#
# Produces a single self-contained Build/TheLastRonin.exe (game data embedded).
# Run this from anywhere:  ./build_windows.sh
#
# Requirements (one-time, already set up):
#   - Godot 4.7.1 at the path below
#   - Windows export templates for 4.7.1 installed
#   - The "Windows Desktop" preset in export_presets.cfg
#
set -euo pipefail

GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$PROJECT_DIR"
mkdir -p Build

echo "==> Importing assets..."
"$GODOT" --headless --path "$PROJECT_DIR" --import >/dev/null 2>&1 || true

echo "==> Exporting Windows build..."
"$GODOT" --headless --path "$PROJECT_DIR" --export-release "Windows Desktop" "Build/TheLastRonin.exe"

echo "==> Zipping (the raw .exe is >100MB; git tracks the zip)..."
( cd Build && rm -f TheLastRonin-Windows.zip && zip -9 -q TheLastRonin-Windows.zip TheLastRonin.exe )

echo
echo "==> Done. Build/ now contains:"
ls -lh Build/
echo
echo "Commit these: Build/TheLastRonin-Windows.zip + Build/README.txt"
echo "(the raw TheLastRonin.exe is gitignored — regenerated each run)"
