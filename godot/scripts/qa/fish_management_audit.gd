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

	_install_test_state(main)
	await process_frame
	await _audit_top_swim_clearance(main)
	await _audit_release_flow(main)
	await _audit_sheet_auto_height(main)

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	quit(0)

func _install_test_state(main):
	var rng = RandomNumberGenerator.new()
	rng.seed = 424242
	var species = GameData.species_catalog()
	var fish_list = [
		FishFactory.create_fish(rng, {"species": species[0]}),
		FishFactory.create_fish(rng, {"species": species[1]}),
		FishFactory.create_fish(rng, {"species": species[2]}),
	]
	for index in range(fish_list.size()):
		fish_list[index]["swim"]["x"] = 95.0 + index * 95.0
		fish_list[index]["swim"]["y"] = 60.0 + index * 20.0
		fish_list[index]["swim"]["vx"] = 0.0
	main.controller.state = {
		"resources": {"bubbleCoins": 1000, "shells": 80, "eggs": 4, "pearls": 3},
		"fish": fish_list,
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()) - 3600,
		"stats": SaveStore.default_stats(),
		"claimedQuests": [],
	}
	main.controller.active_pond_id = "starter"
	main.controller.selected_fish_id = fish_list[0]["id"]
	main._refresh_home()

func _audit_top_swim_clearance(main):
	await process_frame
	await process_frame
	var hud_bottom = main.resource_hud.get_global_rect().end.y
	for fish in main.controller.state.get("fish", []):
		var swim = fish.get("swim", {})
		var app = fish.get("appearance", {})
		var center_y = float(swim.get("y", 0.0))
		var radius = 34.0 * float(app.get("size", 1.0)) * float(swim.get("depth", 1.0))
		_assert(center_y - radius >= hud_bottom - 1.0, "fish stays below top hud: %.1f >= %.1f" % [center_y - radius, hud_bottom])

func _audit_release_flow(main):
	main._open_partner_details()
	await process_frame
	await create_timer(0.32).timeout
	_assert(main.bottom_sheet.visible, "partner sheet opens")
	var release_button = _find_button_with_text(main.bottom_sheet, "送回海域")
	_assert(release_button != null, "partner sheet exposes release button")
	var before = main.controller.state["fish"].size()
	var released_id = main.controller.selected_fish_id
	release_button.emit_signal("pressed")
	await process_frame
	await create_timer(0.28).timeout
	_assert(main.controller.state["fish"].size() == before - 1, "release removes one fish")
	_assert(main.controller.selected_fish_id != released_id, "release selects another fish")
	_assert(not main.controller.get_selected_fish().is_empty(), "release leaves active selected fish")

	var guard_one = main.controller.state["fish"][0]
	main.controller.state["fish"] = [guard_one]
	main.controller.selected_fish_id = guard_one.get("id", "")
	var result = main.controller.release_fish(guard_one.get("id", ""))
	_assert(not bool(result.get("success", false)), "release protects the final fish")
	_assert(main.controller.state["fish"].size() == 1, "final fish remains after rejected release")

func _audit_sheet_auto_height(main):
	var tiny = VBoxContainer.new()
	tiny.custom_minimum_size = Vector2(0, 92)
	tiny.add_child(UiStyle.label("短内容", 18, UiStyle.INK, true))
	main.bottom_sheet.open_with(tiny, 430)
	await process_frame
	await create_timer(0.32).timeout
	_assert(main.bottom_sheet.visible, "tiny sheet opens")
	_assert(main.bottom_sheet.sheet.size.y < 300.0, "tiny sheet height adapts: %.1f" % main.bottom_sheet.sheet.size.y)
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

func _find_button_with_text(node, text):
	for button in node.find_children("*", "Button", true, false):
		if str(button.text).find(text) >= 0:
			return button
	return null

func _assert(condition, label):
	if condition:
		return
	push_error("Fish management QA failed: %s" % label)
	quit(1)
