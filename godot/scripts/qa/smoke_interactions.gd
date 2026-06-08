extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	var main = load("res://godot/scenes/ui/main_game.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_assert(not main.controller.state.is_empty(), "controller state")
	_assert(not main.controller.get_selected_fish().is_empty(), "selected fish")

	main._feed_selected()
	await process_frame
	_assert(main.bottom_sheet.visible, "food sheet opened")
	main.bottom_sheet.close()
	await process_frame

	main._open_partner_details()
	await process_frame
	_assert(main.bottom_sheet.visible, "partner sheet opened")
	main.bottom_sheet.close()
	await process_frame

	main._try_evolution()
	await process_frame
	_assert(main.bottom_sheet.visible, "evolution sheet opened")
	main.bottom_sheet.close()
	await process_frame

	for mode in ["hatchery", "dex", "adventure", "quests"]:
		main._select_mode(mode)
		await process_frame
		_assert(main.panel_host.visible, "%s panel opened" % mode)
		main.panel_host.close_panel()
		await process_frame

	var fish = main.controller.get_selected_fish().duplicate(true)
	fish.erase("genes")
	fish.erase("appearance")
	fish.erase("traits")
	var migrated = SaveStore.ensure_fish(fish, RandomNumberGenerator.new())
	_assert(typeof(migrated.get("genes")) == TYPE_DICTIONARY, "fish genes migration")
	_assert(typeof(migrated.get("appearance")) == TYPE_DICTIONARY, "fish appearance migration")
	_assert(typeof(migrated.get("traits")) == TYPE_ARRAY, "fish traits migration")

	quit(0)

func _assert(condition, label):
	if condition:
		return
	push_error("QA failed: %s" % label)
	quit(1)
