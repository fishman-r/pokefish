#!/bin/sh
set -eu

ROOT="${POKEFISH_ROOT:-/Users/rpy/Documents/Claude/pokefish}"
APP="${1:-$ROOT/godot/build/ios/DerivedData/Build/Products/Debug-iphoneos/Pokefish.app}"
PCK="$APP/Pokefish.pck"
PROJECT="$ROOT/godot/build/ios/Pokefish.xcodeproj/project.pbxproj"
ICON_SRC="$ROOT/godot/assets/app_icon_1024.png"
APP_ICON="$APP/AppIcon60x60@2x.png"
SPLASH_SRC_2X="$ROOT/godot/assets/launch_splash_2x.png"
SPLASH_SRC_3X="$ROOT/godot/assets/launch_splash_3x.png"
SPLASH_EXPORT_2X="$ROOT/godot/build/ios/Pokefish/Images.xcassets/SplashImage.imageset/splash@2x.png"
SPLASH_EXPORT_3X="$ROOT/godot/build/ios/Pokefish/Images.xcassets/SplashImage.imageset/splash@3x.png"

if [ ! -d "$APP" ]; then
  echo "iOS package QA failed: app bundle not found: $APP" >&2
  exit 1
fi

if [ ! -f "$PCK" ]; then
  echo "iOS package QA failed: PCK not found: $PCK" >&2
  exit 1
fi

if [ ! -f "$PROJECT" ]; then
  echo "iOS package QA failed: Xcode project not found: $PROJECT" >&2
  exit 1
fi

if [ ! -f "$ICON_SRC" ]; then
  echo "iOS package QA failed: app icon source not found: $ICON_SRC" >&2
  exit 1
fi

if [ ! -f "$APP_ICON" ]; then
  echo "iOS package QA failed: bundled app icon not found: $APP_ICON" >&2
  exit 1
fi

for splash in "$SPLASH_SRC_2X" "$SPLASH_SRC_3X" "$SPLASH_EXPORT_2X" "$SPLASH_EXPORT_3X"; do
  if [ ! -f "$splash" ]; then
    echo "iOS package QA failed: splash image not found: $splash" >&2
    exit 1
  fi
done

icon_width="$(sips -g pixelWidth "$ICON_SRC" | awk '/pixelWidth/ { print $2 }')"
icon_height="$(sips -g pixelHeight "$ICON_SRC" | awk '/pixelHeight/ { print $2 }')"
icon_alpha="$(sips -g hasAlpha "$ICON_SRC" | awk '/hasAlpha/ { print $2 }')"
if [ "$icon_width" != "1024" ] || [ "$icon_height" != "1024" ] || [ "$icon_alpha" != "no" ]; then
  echo "iOS package QA failed: app icon source must be 1024x1024 RGB/no-alpha, got ${icon_width}x${icon_height} alpha=${icon_alpha}" >&2
  exit 1
fi

bundled_icon_alpha="$(sips -g hasAlpha "$APP_ICON" | awk '/hasAlpha/ { print $2 }')"
if [ "$bundled_icon_alpha" != "no" ]; then
  echo "iOS package QA failed: bundled app icon must not have alpha, got alpha=${bundled_icon_alpha}" >&2
  exit 1
fi

for splash in "$SPLASH_SRC_2X" "$SPLASH_SRC_3X" "$SPLASH_EXPORT_2X" "$SPLASH_EXPORT_3X"; do
  splash_width="$(sips -g pixelWidth "$splash" | awk '/pixelWidth/ { print $2 }')"
  splash_height="$(sips -g pixelHeight "$splash" | awk '/pixelHeight/ { print $2 }')"
  splash_alpha="$(sips -g hasAlpha "$splash" | awk '/hasAlpha/ { print $2 }')"
  if [ "$splash_width" != "800" ] || [ "$splash_height" != "600" ] || [ "$splash_alpha" != "no" ]; then
    echo "iOS package QA failed: splash image must be 800x600 RGB/no-alpha: $splash got ${splash_width}x${splash_height} alpha=${splash_alpha}" >&2
    exit 1
  fi
done

python3 - "$APP/Info.plist" "$PROJECT" <<'PY'
import plistlib
import re
import sys

info_path, project_path = sys.argv[1], sys.argv[2]
with open(info_path, "rb") as handle:
    info = plistlib.load(handle)

device_family = info.get("UIDeviceFamily")
if device_family != [1]:
    raise SystemExit(f"iOS package QA failed: UIDeviceFamily must be iPhone-only [1], got {device_family!r}")

for key in ("UISupportedInterfaceOrientations", "UISupportedInterfaceOrientations~ipad"):
    values = info.get(key, [])
    if values and values != ["UIInterfaceOrientationPortrait"]:
        raise SystemExit(f"iOS package QA failed: {key} must be portrait-only, got {values!r}")

with open(project_path, "r", encoding="utf-8", errors="ignore") as handle:
    project = handle.read()
families = sorted(set(re.findall(r'TARGETED_DEVICE_FAMILY = "([^"]+)"', project)))
if families != ["1"]:
    raise SystemExit(f"iOS package QA failed: TARGETED_DEVICE_FAMILY must be 1, got {families!r}")
PY

if strings "$PCK" | rg -q "resource_packages|kenney_fish-pack_2|godot/assets/kenney_fish_pack/fish_|godot/scripts/qa|godot/scripts/tools|qa_snapshots|STHeiti|node_modules|Capacitor|package\\.json|src/app\\.js|dist/index\\.html|index\\.html|styles\\.css|ios/App|godot/scenes/main\\.tscn|godot/scripts/main\\.gd"; then
  echo "iOS package QA failed: forbidden development or web path found in PCK" >&2
  exit 1
fi

python3 - "$PCK" <<'PY'
import re
import subprocess
import sys

pck_path = sys.argv[1]
allowed_godot_prefixes = (
    ".godot/exported/",
    ".godot/imported/",
    ".godot/global_script_class_cache.cfg",
    ".godot/uid_cache.bin",
)

try:
    output = subprocess.check_output(["strings", pck_path], text=True, errors="ignore")
except subprocess.CalledProcessError as exc:
    raise SystemExit(f"iOS package QA failed: unable to inspect PCK strings: {exc}")

bad_paths = []
for line in output.splitlines():
    for match in re.findall(r"(?:res://)?\.godot/[A-Za-z0-9_./@-]+", line):
        path = match.removeprefix("res://")
        if not path.startswith(allowed_godot_prefixes):
            bad_paths.append(path)

if bad_paths:
    sample = ", ".join(sorted(set(bad_paths))[:8])
    raise SystemExit(f"iOS package QA failed: unexpected .godot paths in PCK: {sample}")
PY

echo "iOS package QA passed: iPhone-only, portrait-only, clean PCK, valid app icon, valid launch splash"
