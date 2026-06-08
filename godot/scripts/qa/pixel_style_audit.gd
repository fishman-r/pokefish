extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	var phone_viewport = SubViewport.new()
	phone_viewport.size = Vector2i(390, 844)
	phone_viewport.disable_3d = true
	phone_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(phone_viewport)

	var main = load("res://godot/scenes/ui/main_game.tscn").instantiate()
	phone_viewport.add_child(main)
	await process_frame
	await process_frame
	await process_frame

	_audit_stylebox(UiStyle.panel_style(), "default panel style")
	_audit_stylebox(UiStyle.button_style()[ "normal" ], "default button style")
	var chip = UiComponents.tag_chip("像素")
	_audit_stylebox(chip.get_theme_stylebox("panel"), "tag chip style")
	chip.queue_free()

	_assert(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "canvas texture filter is nearest")
	_assert(_stylebox_is_pixel(main.resource_hud.find_child("*", true, false).get_theme_stylebox("panel")), "hud panel uses pixel style")

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	await process_frame
	quit(0)

func _audit_stylebox(style, label):
	_assert(_stylebox_is_pixel(style), "%s has square pixel corners" % label)
	_assert(int(style.shadow_offset.x) == 4 and int(style.shadow_offset.y) == 4 or int(style.shadow_size) == 0, "%s avoids soft shadow blur" % label)

func _stylebox_is_pixel(style):
	if style == null or not style is StyleBoxFlat:
		return false
	for corner in [
		style.corner_radius_top_left,
		style.corner_radius_top_right,
		style.corner_radius_bottom_right,
		style.corner_radius_bottom_left,
	]:
		if int(corner) != 0:
			return false
	return int(style.border_width_left) >= 2 and int(style.border_width_top) >= 2

func _assert(condition, label):
	if condition:
		return
	push_error("Pixel style QA failed: %s" % label)
	quit(1)
