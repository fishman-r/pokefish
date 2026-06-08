#!/bin/sh
set -eu

ROOT="${POKEFISH_ROOT:-/Users/rpy/Documents/Claude/pokefish}"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"

for script in \
  "$ROOT/godot/scripts/qa/smoke_interactions.gd" \
  "$ROOT/godot/scripts/qa/layout_audit.gd" \
  "$ROOT/godot/scripts/qa/text_render_audit.gd" \
  "$ROOT/godot/scripts/qa/m4_flow_audit.gd" \
  "$ROOT/godot/scripts/qa/resource_economy_audit.gd" \
  "$ROOT/godot/scripts/qa/food_economy_audit.gd" \
  "$ROOT/godot/scripts/qa/evolution_system_audit.gd" \
  "$ROOT/godot/scripts/qa/evolution_visual_audit.gd" \
  "$ROOT/godot/scripts/qa/hatchery_system_audit.gd" \
  "$ROOT/godot/scripts/qa/dex_system_audit.gd" \
  "$ROOT/godot/scripts/qa/pixel_style_audit.gd" \
	  "$ROOT/godot/scripts/qa/performance_budget_audit.gd" \
	  "$ROOT/godot/scripts/qa/fish_management_audit.gd" \
	  "$ROOT/godot/scripts/qa/touch_conflict_audit.gd" \
  "$ROOT/godot/scripts/qa/scroll_drag_audit.gd" \
  "$ROOT/godot/scripts/qa/v3_completion_audit.gd" \
  "$ROOT/godot/scripts/qa/manual_debug_overlay_audit.gd" \
  "$ROOT/godot/scripts/qa/ergonomics_audit.gd" \
  "$ROOT/godot/scripts/qa/kenney_asset_audit.gd"
do
  "$GODOT_BIN" --headless --path "$ROOT" --script "$script"
done

"$GODOT_BIN" \
  --display-driver macos \
  --audio-driver Dummy \
  --resolution 390x844 \
  --path "$ROOT" \
  --script "$ROOT/godot/scripts/qa/visual_snapshot_audit.gd"

"$ROOT/godot/scripts/qa/ios_package_audit.sh"

if [ "${POKEFISH_SKIP_DEVICE_QA:-0}" != "1" ]; then
  "$ROOT/godot/scripts/qa/ios_device_smoke.sh"
fi

echo "Pokefish QA passed"
