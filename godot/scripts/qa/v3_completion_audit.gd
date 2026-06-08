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

	_install_v3_state(main)
	await process_frame
	var base_nodes = _count_nodes(main)

	_audit_v3_structure(main)
	await _audit_repeated_handfeel_flow(main)
	await create_timer(2.5).timeout
	await process_frame
	_audit_cleanup(main, base_nodes)

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	quit(0)

func _install_v3_state(main):
	var rng = RandomNumberGenerator.new()
	rng.seed = 6062026
	var species = GameData.species_catalog()
	var fish_list = [
		FishFactory.create_fish(rng, {"species": species[0]}),
		FishFactory.create_fish(rng, {"species": species[1]}),
		FishFactory.create_fish(rng, {"species": species[2]}),
	]
	for index in range(fish_list.size()):
		fish_list[index]["swim"] = {
			"x": 110.0 + index * 82.0,
			"y": 225.0 + index * 28.0,
			"vx": 0.0,
			"depth": 1.0,
			"wiggle": 0.0,
			"wave": 0.0,
		}
	var stats = SaveStore.default_stats()
	stats["feedCount"] = 4
	stats["hatchCount"] = 1
	stats["exploreCount"] = 1
	main.controller.state = {
		"resources": {"bubbleCoins": 1800, "shells": 90, "eggs": 8, "pearls": 8},
		"fish": fish_list,
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()) - 3600,
		"stats": stats,
		"claimedQuests": [],
	}
	main.controller.active_pond_id = "starter"
	main.controller.selected_fish_id = fish_list[0]["id"]
	main._refresh_home()

func _audit_v3_structure(main):
	_assert(main.resource_hud.get_global_rect().size.y <= 72.0, "v3 lightweight HUD height")
	_assert(not main.mode_dock.expanded, "module menu starts collapsed")
	_assert(_has_press_feedback(main.mode_dock.menu_button), "module pocket has press feedback")
	_assert(_has_press_feedback(_find_first_button(main.resource_hud)), "HUD menu has press feedback")
	_assert(main.mode_dock.menu_button.tooltip_text == "模块", "module pocket starts as module entry")

	for mode_id in ["hatchery", "dex", "adventure", "quests"]:
		var button = _find_control_with_meta(main.mode_dock, "pokefish_mode_id", mode_id)
		_assert(button != null, "%s module button exists" % mode_id)
		_assert(_has_press_feedback(button), "%s module button has press feedback" % mode_id)
		var icon = button.find_child("ModeIcon", true, false)
		_assert(icon != null, "%s module button has icon" % mode_id)

func _audit_repeated_handfeel_flow(main):
	for round_index in range(3):
		await _open_and_close_food(main)
		await _tap_pointer(_control_center(_find_control_with_meta(main.action_dock, "pokefish_action_kind", "collect")))
		await create_timer(0.16).timeout
		await _open_and_close_evolution(main)
		for mode_id in ["hatchery", "dex", "adventure", "quests"]:
			await _open_mode_via_pocket(main, mode_id)
			await _audit_open_panel(main, mode_id)
			await _tap_pointer(_control_center(_find_control_with_meta(main.mode_dock, "pokefish_mode_id", "pond")))
			await create_timer(0.32).timeout
			_assert(not main.panel_host.visible, "%s returns to pond on round %d" % [mode_id, round_index + 1])
			_assert(main.mode_dock.current_mode == "pond", "mode dock returns to pond")
	_assert(not main.bottom_sheet.visible, "bottom sheet closed after repeated flow")
	_assert(not main.panel_host.visible, "panel host closed after repeated flow")
	_assert(not main.mode_dock.expanded, "module menu collapsed after repeated flow")

func _open_and_close_food(main):
	await _tap_pointer(_control_center(_find_control_with_meta(main.action_dock, "pokefish_action_kind", "feed")))
	await create_timer(0.34).timeout
	_assert(main.bottom_sheet.visible, "feed sheet opens during repeated flow")
	await _assert_scroll_can_drag_if_needed(main.bottom_sheet.scroll, main.bottom_sheet.sheet.get_global_rect(), "food sheet")
	main.bottom_sheet.close()
	await create_timer(0.28).timeout

func _open_and_close_evolution(main):
	await _tap_pointer(_control_center(_find_control_with_meta(main.action_dock, "pokefish_action_kind", "evolve")))
	await create_timer(0.34).timeout
	_assert(main.bottom_sheet.visible, "evolution sheet opens during repeated flow")
	var first_content = main.bottom_sheet.holder.get_child(0)
	await _tap_pointer(_control_center(_find_control_with_meta(main.action_dock, "pokefish_action_kind", "evolve")))
	await create_timer(0.12).timeout
	_assert(main.bottom_sheet.holder.get_child_count() == 1, "evolution sheet remains single after repeated action tap")
	_assert(main.bottom_sheet.holder.get_child(0) == first_content, "evolution sheet does not reopen over itself")
	var confirm = _find_button_with_text(main.bottom_sheet, "开始共鸣")
	_assert(confirm != null and _has_press_feedback(confirm), "evolution confirm has press feedback")
	main.bottom_sheet.close()
	await create_timer(0.28).timeout

func _open_mode_via_pocket(main, mode_id):
	await _tap_pointer(_control_center(main.mode_dock.menu_button))
	await create_timer(0.16).timeout
	_assert(main.mode_dock.expanded, "module pocket opens for %s" % mode_id)
	await _tap_pointer(_control_center(_find_control_with_meta(main.mode_dock, "pokefish_mode_id", mode_id)))
	await create_timer(0.38).timeout
	_assert(main.panel_host.visible, "%s panel opens from pocket" % mode_id)
	_assert(not main.mode_dock.expanded, "%s selection collapses pocket" % mode_id)

func _audit_open_panel(main, mode_id):
	var content = main.panel_host.content_holder.get_child(0)
	_assert(content != null, "%s content exists" % mode_id)
	_assert(content.has_method("play_intro"), "%s content has v3 intro animation" % mode_id)
	var back = _find_first_button(main.panel_host)
	_assert(back != null and _has_press_feedback(back), "%s back button has press feedback" % mode_id)
	var scroll = main.panel_host.scroll
	var rect = main.panel_host.panel.get_global_rect()
	if mode_id == "hatchery" and content is HatcheryPanel and content.content_scroll != null:
		scroll = content.content_scroll
		rect = content.content_scroll.get_global_rect()
	elif mode_id == "dex" and content is DexPanel and content.content_scroll != null:
		scroll = content.content_scroll
		rect = content.content_scroll.get_global_rect()
	await _assert_scroll_can_drag_if_needed(scroll, rect, "%s panel" % mode_id)
	if mode_id == "hatchery":
		var hatch = _find_button_with_text(content, "开蛋")
		_assert(hatch != null and _has_press_feedback(hatch), "hatch button has press feedback")
	if mode_id == "quests":
		_assert(content.claim_button != null and _has_press_feedback(content.claim_button), "quest claim has press feedback")

func _assert_scroll_can_drag_if_needed(scroll, rect, label):
	if _max_scroll(scroll) <= 16.0:
		return
	var before = int(scroll.scroll_vertical)
	var start = rect.position + Vector2(rect.size.x * 0.46, rect.size.y * 0.58)
	start.x = clamp(start.x, rect.position.x + 64.0, rect.end.x - 64.0)
	await _drag(start, Vector2(0, -64), 3)
	await process_frame
	_assert(scroll.scroll_vertical > before + 40, "%s scroll remains draggable from content" % label)

func _audit_cleanup(main, base_nodes):
	_assert(main.fx_layer.get_child_count() == 0, "FX layer cleaned after repeated flow")
	_assert(main.bottom_sheet.holder.get_child_count() == 0, "bottom sheet holder cleaned after repeated flow")
	_assert(main.panel_host.content_holder.get_child_count() == 0, "panel holder cleaned after repeated flow")
	var final_nodes = _count_nodes(main)
	_assert(final_nodes <= base_nodes + 10, "node count stable after v3 repeated flow: %d -> %d" % [base_nodes, final_nodes])
	for button in main.mode_dock.find_children("*", "Button", true, false):
		_assert(button.scale.distance_to(Vector2.ONE) <= 0.04, "mode button scale reset: %s" % button.name)
	for button in main.action_dock.find_children("*", "Button", true, false):
		_assert(button.scale.distance_to(Vector2.ONE) <= 0.04, "action button scale reset: %s" % button.name)

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

func _drag(start, relative, steps):
	var press = InputEventScreenTouch.new()
	press.index = 0
	press.position = start
	press.pressed = true
	phone_viewport.push_input(press)
	await process_frame
	var position = start
	for _index in range(steps):
		position += relative
		var drag = InputEventScreenDrag.new()
		drag.index = 0
		drag.position = position
		drag.relative = relative
		drag.velocity = relative * 60.0
		phone_viewport.push_input(drag)
		await process_frame
	var release = InputEventScreenTouch.new()
	release.index = 0
	release.position = position
	release.pressed = false
	phone_viewport.push_input(release)
	await process_frame

func _find_control_with_meta(root_node, key, value):
	for child in root_node.find_children("*", "Control", true, false):
		if child.has_meta(key) and str(child.get_meta(key)) == str(value):
			return child
	return null

func _find_first_button(root_node):
	for button in root_node.find_children("*", "Button", true, false):
		if button.is_visible_in_tree():
			return button
	return null

func _find_button_with_text(root_node, text):
	for button in root_node.find_children("*", "Button", true, false):
		if button.is_visible_in_tree() and str(button.text).find(text) >= 0:
			return button
	return null

func _control_center(control):
	_assert(control != null, "control exists")
	var rect = control.get_global_rect()
	return rect.position + rect.size * 0.5

func _has_press_feedback(button):
	return button != null and button.has_meta("_pokefish_press_feedback")

func _max_scroll(scroll):
	if scroll == null:
		return 0.0
	var bar = scroll.get_v_scroll_bar()
	if bar == null:
		return 0.0
	return max(0.0, float(bar.max_value) - float(bar.page))

func _count_nodes(node):
	var count = 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count

func _assert(condition, label):
	if condition:
		return
	push_error("V3 completion QA failed: %s" % label)
	quit(1)
