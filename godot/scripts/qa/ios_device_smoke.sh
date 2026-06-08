#!/bin/sh
set -eu

ROOT="${POKEFISH_ROOT:-/Users/rpy/Documents/Claude/pokefish}"
DEVICE="${POKEFISH_DEVICE:-00008110-0019746634EA801E}"
BUNDLE_ID="${POKEFISH_BUNDLE_ID:-com.pokefish.game}"
APP_NAME="${POKEFISH_APP_NAME:-Pokefish}"
OUT_DIR="${POKEFISH_DEVICE_QA_DIR:-$ROOT/godot/build/ios/device}"

mkdir -p "$OUT_DIR"

APPS_JSON="$OUT_DIR/apps.json"
DISPLAYS_JSON="$OUT_DIR/displays.json"
PROCESSES_JSON="$OUT_DIR/processes.json"
APP_ICON_JSON="$OUT_DIR/app_icon.json"
APP_ICON_PNG="$OUT_DIR/pokefish-device-icon.png"

xcrun devicectl device info apps \
  --device "$DEVICE" \
  --bundle-id "$BUNDLE_ID" \
  --json-output "$APPS_JSON" \
  > "$OUT_DIR/apps.txt"

xcrun devicectl device info displays \
  --device "$DEVICE" \
  --json-output "$DISPLAYS_JSON" \
  > "$OUT_DIR/displays.txt"

xcrun devicectl device info processes \
  --device "$DEVICE" \
  --filter "executable.path CONTAINS '$APP_NAME'" \
  --json-output "$PROCESSES_JSON" \
  > "$OUT_DIR/processes.txt"

xcrun devicectl device info appIcon \
  --device "$DEVICE" \
  --app-bundle-id "$BUNDLE_ID" \
  --width 120 \
  --height 120 \
  --scale 2 \
  --destination "$APP_ICON_PNG" \
  --json-output "$APP_ICON_JSON" \
  > "$OUT_DIR/app_icon.txt"

python3 - "$APPS_JSON" "$DISPLAYS_JSON" "$PROCESSES_JSON" "$APP_ICON_JSON" "$APP_ICON_PNG" "$BUNDLE_ID" "$APP_NAME" <<'PY'
import json
import pathlib
import sys

apps_path, displays_path, processes_path, icon_path, icon_png, bundle_id, app_name = sys.argv[1:]


def load(path):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


apps = load(apps_path)
installed = [
    app
    for app in apps.get("result", {}).get("apps", [])
    if app.get("bundleIdentifier") == bundle_id
]
if len(installed) != 1:
    raise SystemExit(f"iOS device QA failed: expected one installed {bundle_id}, got {len(installed)}")

app = installed[0]
if app.get("name") != app_name:
    raise SystemExit(f"iOS device QA failed: expected app name {app_name!r}, got {app.get('name')!r}")
if app.get("version") != "1.0" or app.get("bundleVersion") != "1":
    raise SystemExit(
        "iOS device QA failed: expected version 1.0 (1), "
        f"got {app.get('version')!r} ({app.get('bundleVersion')!r})"
    )

displays = load(displays_path)
display_result = displays.get("result", {})
orientation = display_result.get("orientation", {})
device_orientation = orientation.get("currentDeviceOrientation")
non_flat_orientation = orientation.get("currentDeviceNonFlatOrientation")
portrait_orientations = {"portrait", "portraitUpsideDown"}
flat_orientations = {"faceUp", "faceDown"}
is_portrait = device_orientation in portrait_orientations
is_flat_but_last_portrait = device_orientation in flat_orientations and non_flat_orientation in portrait_orientations
if not is_portrait and not is_flat_but_last_portrait:
	raise SystemExit(f"iOS device QA failed: device must be portrait, got {orientation!r}")
if display_result.get("backlightState") != "activeOn":
    raise SystemExit(f"iOS device QA failed: display backlight must be activeOn, got {display_result.get('backlightState')!r}")

primary = None
for display in display_result.get("displays", []):
    if display.get("primary"):
        primary = display
        break
if not primary:
    raise SystemExit("iOS device QA failed: primary display not found")

native_size = primary.get("nativeSize", [])
if len(native_size) != 2 or native_size[1] <= native_size[0]:
    raise SystemExit(f"iOS device QA failed: primary display must be portrait, got nativeSize={native_size!r}")
if primary.get("pointScale", 0) < 2:
    raise SystemExit(f"iOS device QA failed: expected retina display scale, got {primary.get('pointScale')!r}")

processes = load(processes_path)
running = []
for process in processes.get("result", {}).get("runningProcesses", []):
    executable = process.get("executable", "")
    if f"/{app_name}.app/{app_name}" in executable:
        running.append(process)
if not running:
    raise SystemExit(f"iOS device QA failed: running {app_name} process not found")

pid = running[0].get("processIdentifier")
if not isinstance(pid, int) or pid <= 0:
    raise SystemExit(f"iOS device QA failed: invalid {app_name} process id {pid!r}")

icon = load(icon_path).get("result", {}).get("icon", {})
if icon.get("placeholder") is not False:
    raise SystemExit(f"iOS device QA failed: device returned placeholder app icon: {icon!r}")
pixel_size = icon.get("pixelSize", {})
if pixel_size.get("width", 0) <= 0 or pixel_size.get("height", 0) <= 0:
    raise SystemExit(f"iOS device QA failed: invalid device app icon pixel size: {pixel_size!r}")

icon_file = pathlib.Path(icon_png)
if not icon_file.is_file() or icon_file.stat().st_size <= 0:
    raise SystemExit(f"iOS device QA failed: device app icon file not written: {icon_file}")

width = int(primary["nativeSize"][0])
height = int(primary["nativeSize"][1])
scale = primary.get("pointScale")
print(
    "iOS device QA passed: "
    f"installed {bundle_id}, running PID {pid}, portrait {width}x{height}@{scale}x, real app icon"
)
PY
