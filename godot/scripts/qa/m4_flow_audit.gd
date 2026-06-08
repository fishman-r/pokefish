extends SceneTree

const SAVE_PATH = "user://pokefish_save_v1.json"

var had_save = false
var save_text = ""

func _init():
	call_deferred("_run")

func _run():
	_backup_save()
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
	await _audit_hatchery(main)
	await _audit_dex(main)
	await _audit_adventure(main)
	await _audit_quests(main)

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	_restore_save()
	quit(0)

func _backup_save():
	had_save = FileAccess.file_exists(SAVE_PATH)
	if had_save:
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			save_text = file.get_as_text()

func _restore_save():
	if had_save:
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if file:
			file.store_string(save_text)
	elif FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _install_test_state(main):
	var rng = RandomNumberGenerator.new()
	rng.seed = 1337
	var fish_list = [
		FishFactory.create_fish(rng, {"species": GameData.species_catalog()[0]}),
		FishFactory.create_fish(rng, {"species": GameData.species_catalog()[2]}),
	]
	fish_list[0]["traits"] = [{"id": "curious", "label": "好奇", "mood": 8, "chance": 0.03}]
	var state = {
		"resources": {"bubbleCoins": 1000, "shells": 40, "eggs": 3, "pearls": 4},
		"fish": fish_list,
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()) - 3600,
		"activeExplore": {},
		"stats": SaveStore.default_stats(),
		"claimedQuests": [],
	}
	main.controller.state = state
	main.controller.active_pond_id = "starter"
	main.controller.selected_fish_id = fish_list[0]["id"]
	main._refresh_home()

func _audit_hatchery(main):
	main._select_mode("hatchery")
	await process_frame
	await create_timer(0.28).timeout
	_assert(main.panel_host.visible, "hatchery panel opens")
	var hatchery = main.panel_host.content_holder.get_child(0)
	_assert(hatchery.slots_box.get_child_count() == 3, "hatchery has three slots")
	_assert(str(hatchery.egg_label.text).find("3") >= 0, "hatchery shows egg inventory")

	var fish_before = main.controller.state["fish"].size()
	var eggs_before = int(main.controller.get_resources().get("eggs", 0))
	hatchery._hatch_pressed()
	await process_frame
	await process_frame
	_assert(not main.controller.state.get("hatchSlots", [])[0].is_empty(), "hatch starts in first slot")
	_assert(int(main.controller.get_resources().get("eggs", 0)) == eggs_before - 1, "hatch start consumes egg")
	main.controller.state["hatchSlots"][0]["readyAt"] = int(Time.get_unix_time_from_system()) - 1
	hatchery._hatch_pressed()
	await process_frame
	await process_frame
	_assert(main.controller.state["fish"].size() == fish_before + 1, "hatch adds fish")
	_assert(int(main.controller.state["stats"].get("hatchCount", 0)) == 1, "hatch records stat")
	_assert(not main.controller.get_selected_fish().is_empty(), "new hatch is selected")
	main.panel_host.close_panel()
	await create_timer(0.24).timeout

func _audit_dex(main):
	main._select_mode("dex")
	await process_frame
	await create_timer(0.28).timeout
	var dex = main.panel_host.content_holder.get_child(0)
	_assert(dex.filter_box.get_child_count() >= 6, "dex has readable rarity and evolution filters")
	_assert(_contains_text(dex.filter_box, "稀有"), "dex filter uses readable rarity labels")
	_assert(_contains_text(dex.filter_box, "已进化"), "dex filter exposes evolved category")
	_assert(dex.card_grid.get_child_count() > 0, "dex shows fish cards")
	dex._set_filter("rare")
	await process_frame
	_assert(dex.filter_id == "rare", "dex filter updates")
	dex._set_filter("evolved")
	await process_frame
	_assert(dex.filter_id == "evolved", "dex evolved filter updates")
	dex._set_filter("all")
	await process_frame
	_assert(_contains_label(dex.species_box, "???"), "dex shows undiscovered silhouettes")

	dex._open_fish(main.controller.state["fish"][0]["id"])
	await process_frame
	await create_timer(0.32).timeout
	_assert(main.bottom_sheet.visible, "dex fish opens partner sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout
	main.panel_host.close_panel()
	await create_timer(0.24).timeout

func _audit_adventure(main):
	main._select_mode("adventure")
	await process_frame
	await create_timer(0.28).timeout
	var adventure = main.panel_host.content_holder.get_child(0)
	_assert(adventure.route_box.get_child_count() == GameData.explore_routes().size(), "adventure has route nodes")
	_assert(str(adventure.partner_label.text).find("Lv.") >= 0, "adventure shows current partner")

	var coins_before = int(main.controller.get_resources().get("bubbleCoins", 0))
	var eggs_before = int(main.controller.get_resources().get("eggs", 0))
	adventure._route_pressed("driftwood", adventure.route_box.get_child(0))
	await process_frame
	await process_frame
	_assert(not main.controller.state.get("activeExplore", {}).is_empty(), "adventure starts a timed trip")
	_assert(int(main.controller.get_resources().get("bubbleCoins", 0)) == coins_before, "adventure does not reward before return")
	main.controller.state["activeExplore"]["endsAt"] = int(Time.get_unix_time_from_system()) - 1
	adventure._route_pressed("driftwood", adventure.route_box.get_child(0))
	await process_frame
	await process_frame
	_assert(int(main.controller.get_resources().get("bubbleCoins", 0)) >= coins_before + 180, "adventure rewards coins")
	_assert(int(main.controller.get_resources().get("eggs", 0)) >= eggs_before + 1, "adventure rewards eggs")
	_assert(int(main.controller.state["stats"].get("exploreCount", 0)) == 1, "adventure records stat")
	main.panel_host.close_panel()
	await create_timer(0.24).timeout

func _audit_quests(main):
	main._select_mode("quests")
	await process_frame
	await create_timer(0.28).timeout
	var quests = main.panel_host.content_holder.get_child(0)
	_assert(str(quests.claim_button.text).find("领取") >= 0, "quest claim is prominent")
	var coins_before = int(main.controller.get_resources().get("bubbleCoins", 0))
	var pearls_before = int(main.controller.get_resources().get("pearls", 0))
	quests.claim_button.emit_signal("pressed")
	await process_frame
	await process_frame
	_assert(main.controller.state["claimedQuests"].has("hatch"), "hatch quest claimed")
	_assert(main.controller.state["claimedQuests"].has("explore"), "explore quest claimed")
	_assert(int(main.controller.get_resources().get("bubbleCoins", 0)) >= coins_before + 80, "quest rewards coins")
	_assert(int(main.controller.get_resources().get("pearls", 0)) >= pearls_before + 1, "quest rewards pearls")
	_assert(_contains_label(quests.quest_box, "已领"), "quest board shows claimed stamp")
	main.panel_host.close_panel()
	await create_timer(0.24).timeout

func _contains_text(node, text):
	if node is Label and str(node.text).find(text) >= 0:
		return true
	if node is Button and str(node.text).find(text) >= 0:
		return true
	for child in node.get_children():
		if _contains_text(child, text):
			return true
	return false

func _contains_label(node, text):
	for child in node.get_children():
		if child is Label and str(child.text).find(text) >= 0:
			return true
		if _contains_label(child, text):
			return true
	return false

func _assert(condition, label):
	if condition:
		return
	_restore_save()
	push_error("M4 flow QA failed: %s" % label)
	quit(1)
