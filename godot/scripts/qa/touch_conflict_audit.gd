extends SceneTree

var phone_viewport

func _init():
	call_deferred("_run")

func _run():
	phone_viewport = SubViewport.new()
	phone_viewport.size = Vector2i(390, 844)
	phone_viewport.disable_3d = true
	phone_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(phone_viewport)

	var main = load("res://godot/scenes/ui/main_game.tscn").instantiate()
	phone_viewport.add_child(main)
	await process_frame
	await process_frame
	await process_frame
	_install_touch_state(main)
	await process_frame

	var first_id = main.controller.state["fish"][0]["id"]
	var second_id = main.controller.state["fish"][1]["id"]
	var second_pos = main.pond_stage.global_position + Vector2(280, 240)

	main.controller.select_fish(first_id)
	await _tap_touch(second_pos)
	_assert(main.controller.selected_fish_id == second_id, "home tap selects fish")

	await _tap_pointer(_control_center(main.partner_float))
	await process_frame
	await create_timer(0.24).timeout
	_assert(main.bottom_sheet.visible, "partner float opens details sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

	main.controller.select_fish(first_id)
	main.debug_layer.toggle()
	var touches_before = main.debug_layer.touch_count
	await _tap_touch(second_pos)
	_assert(main.controller.selected_fish_id == second_id, "debug overlay does not block fish tap")
	_assert(main.debug_layer.touch_count == touches_before + 1, "debug overlay records touch")
	main.debug_layer.toggle()

	await _tap_pointer(_control_center(main.mode_dock.menu_button))
	await process_frame
	_assert(main.mode_dock.expanded, "module menu expands from bottom button")
	await _tap_pointer(_control_center(_find_control_with_meta(main.mode_dock, "pokefish_mode_id", "dex")))
	await create_timer(0.28).timeout
	_assert(main.panel_host.visible, "module menu opens dex panel")
	_assert(not main.mode_dock.expanded, "module menu collapses after selecting mode")
	await _tap_pointer(_control_center(_find_control_with_meta(main.mode_dock, "pokefish_mode_id", "pond")))
	await create_timer(0.24).timeout
	_assert(not main.panel_host.visible, "module menu button returns to pond when panel is open")

	main.controller.select_fish(first_id)
	main._feed_selected()
	await process_frame
	await create_timer(0.32).timeout
	await _tap_touch(second_pos)
	await process_frame
	_assert(main.controller.selected_fish_id == first_id, "bottom sheet blocks pond tap")
	var action_before = int(main.debug_layer.get_touch_audit_summary().get("event_hits", {}).get("action", 0))
	await _tap_pointer(_control_center(_find_control_with_meta(main.action_dock, "pokefish_action_kind", "collect")))
	await process_frame
	var action_after = int(main.debug_layer.get_touch_audit_summary().get("event_hits", {}).get("action", 0))
	_assert(action_after > action_before, "bottom sheet leaves action dock tappable")
	if main.bottom_sheet.visible:
		main.bottom_sheet.close()
		await create_timer(0.24).timeout

	main.controller.select_fish(first_id)
	main._select_mode("dex")
	await process_frame
	await create_timer(0.28).timeout
	await _tap_touch(second_pos)
	await process_frame
	_assert(main.controller.selected_fish_id == first_id, "panel host blocks pond tap")
	await _tap_pointer(_control_center(_find_control_with_meta(main.mode_dock, "pokefish_mode_id", "pond")))
	await create_timer(0.24).timeout
	_assert(not main.panel_host.visible, "panel host leaves mode dock tappable")
	if main.panel_host.visible:
		main.panel_host.close_panel()
		await create_timer(0.24).timeout

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	quit(0)

func _install_touch_state(main):
	var rng = RandomNumberGenerator.new()
	rng.seed = 42024
	var first = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[0]})
	var second = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[1]})
	first["swim"] = {"x": 120.0, "y": 240.0, "vx": 0.0, "depth": 1.0, "wiggle": 0.0, "wave": 0.0}
	second["swim"] = {"x": 280.0, "y": 240.0, "vx": 0.0, "depth": 1.0, "wiggle": 0.0, "wave": 0.0}
	main.controller.state = {
		"resources": {"bubbleCoins": 600, "shells": 30, "eggs": 4, "pearls": 3},
		"fish": [first, second],
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()) - 3600,
		"stats": SaveStore.default_stats(),
		"claimedQuests": [],
	}
	main.controller.active_pond_id = "starter"
	main.controller.selected_fish_id = first["id"]
	main._refresh_home()

func _tap_touch(position):
	var press = InputEventScreenTouch.new()
	press.index = 0
	press.position = position
	press.pressed = true
	phone_viewport.push_input(press)
	await process_frame
	var release = InputEventScreenTouch.new()
	release.index = 0
	release.position = position
	release.pressed = false
	phone_viewport.push_input(release)
	await process_frame

func _tap_pointer(position):
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = position
	press.global_position = position
	press.pressed = true
	phone_viewport.push_input(press)
	await process_frame
	var release = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = position
	release.global_position = position
	release.pressed = false
	phone_viewport.push_input(release)
	await process_frame

func _find_control_with_meta(root_node, key, value):
	for child in root_node.find_children("*", "Control", true, false):
		if child.has_meta(key) and str(child.get_meta(key)) == str(value):
			return child
	return null

func _control_center(control):
	_assert(control != null, "control exists")
	var rect = control.get_global_rect()
	return rect.position + rect.size * 0.5

func _assert(condition, label):
	if condition:
		return
	push_error("Touch QA failed: %s" % label)
	quit(1)
