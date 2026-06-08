extends "res://godot/scripts/pond_view.gd"
class_name PondStage

func _ready():
	super._ready()
	custom_minimum_size = Vector2.ZERO
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS

func pulse_selected():
	var tween = create_tween()
	modulate = Color(1.2, 1.2, 1.2, 1.0)
	tween.tween_property(self, "modulate", Color.WHITE, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func get_selected_fish_global_position():
	var local_position = size * 0.5
	for fish in state.get("fish", []):
		if fish.get("id", "") == selected_fish_id:
			var swim = fish.get("swim", {})
			local_position = Vector2(
				float(swim.get("x", local_position.x)),
				float(swim.get("y", local_position.y))
			)
			break
	return global_position + local_position
