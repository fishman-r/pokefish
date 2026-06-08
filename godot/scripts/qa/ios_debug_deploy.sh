#!/bin/sh
set -eu

ROOT="${POKEFISH_ROOT:-/Users/rpy/Documents/Claude/pokefish}"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
DEVICE="${POKEFISH_DEVICE:-00008110-0019746634EA801E}"
BUNDLE_ID="${POKEFISH_BUNDLE_ID:-com.pokefish.game}"
TEAM_ID="${POKEFISH_TEAM_ID:-6QCBJZN8AG}"

IOS_DIR="$ROOT/godot/build/ios"
APP="$IOS_DIR/DerivedData/Build/Products/Debug-iphoneos/Pokefish.app"
EXPORT_LOG="$IOS_DIR/export.log"
XCODEBUILD_LOG="$IOS_DIR/xcodebuild.log"
INSTALL_LOG="$IOS_DIR/device_install.log"
LAUNCH_LOG="$IOS_DIR/device_launch.log"

mkdir -p "$IOS_DIR"

echo "Pokefish iPhone deploy: import"
"$GODOT_BIN" --headless --path "$ROOT" --import --quit

echo "Pokefish iPhone deploy: export iOS project"
if ! "$GODOT_BIN" --headless --path "$ROOT" --export-debug iOS "$IOS_DIR/Pokefish.zip" > "$EXPORT_LOG" 2>&1; then
  tail -80 "$EXPORT_LOG" >&2 || true
  echo "Pokefish iPhone deploy failed: Godot export failed, see $EXPORT_LOG" >&2
  exit 1
fi

echo "Pokefish iPhone deploy: xcodebuild"
if ! xcodebuild \
  -project "$IOS_DIR/Pokefish.xcodeproj" \
  -scheme Pokefish \
  -configuration Debug \
  -destination generic/platform=iOS \
  -derivedDataPath "$IOS_DIR/DerivedData" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
  CODE_SIGN_STYLE=Automatic \
  build > "$XCODEBUILD_LOG" 2>&1; then
  tail -120 "$XCODEBUILD_LOG" >&2 || true
  echo "Pokefish iPhone deploy failed: Xcode build failed, see $XCODEBUILD_LOG" >&2
  exit 1
fi

echo "Pokefish iPhone deploy: package audit"
"$ROOT/godot/scripts/qa/ios_package_audit.sh" "$APP"

echo "Pokefish iPhone deploy: install"
if ! xcrun devicectl device install app --device "$DEVICE" "$APP" > "$INSTALL_LOG" 2>&1; then
  cat "$INSTALL_LOG" >&2 || true
  echo "Pokefish iPhone deploy failed: device install failed, see $INSTALL_LOG" >&2
  exit 1
fi

echo "Pokefish iPhone deploy: launch"
if ! xcrun devicectl device process launch --device "$DEVICE" --terminate-existing "$BUNDLE_ID" > "$LAUNCH_LOG" 2>&1; then
  cat "$LAUNCH_LOG" >&2 || true
  echo "Pokefish iPhone deploy failed: device launch failed, see $LAUNCH_LOG" >&2
  exit 1
fi

echo "Pokefish iPhone deploy: device smoke"
POKEFISH_ROOT="$ROOT" \
POKEFISH_DEVICE="$DEVICE" \
POKEFISH_BUNDLE_ID="$BUNDLE_ID" \
"$ROOT/godot/scripts/qa/ios_device_smoke.sh"

if [ "${POKEFISH_RUN_FULL_QA:-0}" = "1" ]; then
  echo "Pokefish iPhone deploy: full QA"
  POKEFISH_ROOT="$ROOT" GODOT_BIN="$GODOT_BIN" "$ROOT/godot/scripts/qa/run_all_qa.sh"
fi

echo "Pokefish iPhone deploy passed"
