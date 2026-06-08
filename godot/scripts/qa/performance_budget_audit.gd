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

	_install_many_fish_state(main, 36)
	await process_frame
	await process_frame
	var base_nodes = _count_nodes(main)
	_assert(main.controller.state["fish"].size() == 36, "large fish state installed")
	_assert(base_nodes < 220, "large pond keeps node budget: %d" % base_nodes)

	main.fx_layer.play_resource_burst(Vector2(80, 640), Vector2(180, 72), UiStyle.WATER, 24)
	main.fx_layer.play_food_throw(Vector2(210, 700), Vector2(190, 320), UiStyle.ORANGE)
	main.fx_layer.show_toast("性能检查")
	main.fx_layer.show_result("特效检查", "节点会在动画结束后清理", UiStyle.YELLOW)
	await process_frame
	_assert(main.fx_layer.get_child_count() >= 4, "fx nodes appear")
	await create_timer(2.4).timeout
	await process_frame
	_assert(main.fx_layer.get_child_count() == 0, "fx nodes cleaned")

	for _i in range(5):
		main._feed_selected()
		await process_frame
		await create_timer(0.32).timeout
		main.bottom_sheet.close()
		await create_timer(0.24).timeout
		await process_frame
	_assert(not main.bottom_sheet.visible, "bottom sheet closes after repeated use")
	_assert(main.bottom_sheet.holder.get_child_count() == 0, "bottom sheet content cleaned")

	for mode_id in ["hatchery", "dex", "adventure", "quests"]:
		main._select_mode(mode_id)
		await process_frame
		await create_timer(0.28).timeout
		main.panel_host.close_panel()
		await create_timer(0.24).timeout
		await process_frame
	_assert(not main.panel_host.visible, "panel host closes after mode cycle")
	_assert(main.panel_host.content_holder.get_child_count() == 0, "panel content cleaned")

	var final_nodes = _count_nodes(main)
	_assert(final_nodes <= base_nodes + 8, "node count stable after cycles: %d -> %d" % [base_nodes, final_nodes])

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	quit(0)

func _install_many_fish_state(main, fish_count):
	var rng = RandomNumberGenerator.new()
	rng.seed = 20260606
	var fish_list = []
	var species = GameData.species_catalog()
	for index in range(fish_count):
		var fish = FishFactory.create_fish(rng, {"species": species[index % species.size()]})
		fish["swim"]["x"] = 30.0 + fmod(index * 37.0, 330.0)
		fish["swim"]["y"] = 150.0 + fmod(index * 29.0, 420.0)
		fish_list.append(fish)
	main.controller.state = {
		"resources": {"bubbleCoins": 1200, "shells": 80, "eggs": 6, "pearls": 6},
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

func _count_nodes(node):
	var count = 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count

func _assert(condition, label):
	if condition:
		return
	push_error("Performance QA failed: %s" % label)
	quit(1)
