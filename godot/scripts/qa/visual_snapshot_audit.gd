extends SceneTree

const SNAPSHOT_DIR = "res://godot/build/qa_snapshots"
const VIEWPORT_SIZE = Vector2i(390, 844)

var phone_viewport

func _init():
	call_deferred("_run")

func _run():
	_prepare_snapshot_dir()
	phone_viewport = SubViewport.new()
	phone_viewport.size = VIEWPORT_SIZE
	phone_viewport.disable_3d = true
	phone_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(phone_viewport)

	var main = load("res://godot/scenes/ui/main_game.tscn").instantiate()
	phone_viewport.add_child(main)
	await process_frame
	await process_frame
	await _capture("01_home", "home boot")

	main._feed_selected()
	await process_frame
	await create_timer(0.32).timeout
	await _capture("02_food_sheet", "food sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

	main._open_partner_details()
	await process_frame
	await create_timer(0.32).timeout
	await _capture("03_partner_sheet", "partner sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

	main._try_evolution()
	await process_frame
	await create_timer(0.32).timeout
	await _capture("04_evolution_sheet", "evolution sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

	for item in [
		["05_hatchery", "hatchery", "hatchery panel"],
		["06_dex", "dex", "dex panel"],
		["07_adventure", "adventure", "adventure panel"],
		["08_quests", "quests", "quest panel"],
	]:
		main._select_mode(item[1])
		await process_frame
		await create_timer(0.28).timeout
		await _capture(item[0], item[2])
		main.panel_host.close_panel()
		await create_timer(0.24).timeout

	var fish = main.controller.get_selected_fish()
	if not fish.is_empty():
		main.controller._apply_evolution(fish, GameData.evolution_rules()[0])
		main._refresh_home()
		await process_frame
		await create_timer(0.32).timeout
		await _capture("09_evolved_home", "evolved home")

	main.debug_layer.toggle()
	await process_frame
	await create_timer(0.4).timeout
	await _capture("10_debug_overlay", "debug overlay")

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	quit(0)

func _prepare_snapshot_dir():
	var absolute = ProjectSettings.globalize_path(SNAPSHOT_DIR)
	DirAccess.make_dir_recursive_absolute(absolute)

func _capture(name, label):
	await process_frame
	await process_frame
	await process_frame
	var texture = phone_viewport.get_texture()
	_assert(texture != null, "%s has viewport texture" % label)
	var image = texture.get_image()
	_assert(image != null, "%s has rendered image; run without --headless if this fails" % label)
	_assert(image.get_size() == VIEWPORT_SIZE, "%s size %s" % [label, image.get_size()])
	_assert(_has_visual_content(image), "%s has visual content" % label)
	var path = "%s/%s.png" % [SNAPSHOT_DIR, name]
	var err = image.save_png(path)
	_assert(err == OK, "%s saved snapshot" % label)

func _has_visual_content(image):
	var size = image.get_size()
	var sample_count = 0
	var non_empty = 0
	var min_luma = 999.0
	var max_luma = -999.0
	var buckets = {}
	for y in range(0, size.y, 16):
		for x in range(0, size.x, 16):
			var color = image.get_pixel(x, y)
			sample_count += 1
			if color.a > 0.1:
				non_empty += 1
			var luma = color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			min_luma = min(min_luma, luma)
			max_luma = max(max_luma, luma)
			var bucket = "%02d-%02d-%02d" % [
				int(color.r * 7.0),
				int(color.g * 7.0),
				int(color.b * 7.0),
			]
			buckets[bucket] = true
	return non_empty > sample_count * 0.85 and buckets.size() >= 8 and max_luma - min_luma > 0.08

func _assert(condition, label):
	if condition:
		return
	push_error("Visual QA failed: %s" % label)
	quit(1)
