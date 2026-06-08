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

	await _audit_bottom_sheet_drag(main)
	await _audit_food_sheet_drag(main)
	await _audit_panel_host_drag(main)
	await _audit_live_panels_if_scrollable(main)

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	quit(0)

func _audit_bottom_sheet_drag(main):
	main.bottom_sheet.open_with(_make_tall_content("Sheet"), 360)
	await process_frame
	await create_timer(0.32).timeout
	await _assert_scroll_moves_from_content_area(main.bottom_sheet.scroll, main.bottom_sheet.sheet.get_global_rect(), "bottom sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

func _audit_food_sheet_drag(main):
	main.controller.state["foodInventory"] = SaveStore.ensure_food_inventory({"basic": 6, "glow": 2, "coral": 2, "spicy": 1})
	main._feed_selected()
	await process_frame
	await create_timer(0.32).timeout
	_assert(main.bottom_sheet.visible, "food sheet opens for drag audit")
	_assert(main.bottom_sheet.holder.get_child_count() == 1, "food sheet content exists")
	var food_sheet = main.bottom_sheet.holder.get_child(0)
	_assert(food_sheet is FoodSheet, "real food sheet is used")
	food_sheet.custom_minimum_size.y = 760.0
	if food_sheet.food_grid != null:
		food_sheet.food_grid.custom_minimum_size.y = 700.0
		food_sheet.food_grid.update_minimum_size()
	food_sheet.update_minimum_size()
	main.bottom_sheet.refresh_scroll_bindings()
	await process_frame
	await _assert_scroll_moves_from_content_area(main.bottom_sheet.scroll, main.bottom_sheet.sheet.get_global_rect(), "real food sheet")
	await _assert_scroll_moves_from_live_child_if_needed(main.bottom_sheet.scroll, main.bottom_sheet.sheet.get_global_rect(), "real food sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

func _audit_panel_host_drag(main):
	main.panel_host.open_panel(_make_tall_content("Panel"), "滚动测试", "qa_scroll")
	await process_frame
	await create_timer(0.28).timeout
	await _assert_scroll_moves_from_content_area(main.panel_host.scroll, main.panel_host.panel.get_global_rect(), "panel host")
	main.panel_host.close_panel()
	await create_timer(0.24).timeout

func _audit_live_panels_if_scrollable(main):
	for mode_id in ["hatchery", "dex", "adventure", "quests"]:
		main._select_mode(mode_id)
		await process_frame
		await create_timer(0.28).timeout
		if mode_id == "hatchery":
			_force_content_overflow(main, "hatchery")
			await process_frame
			await _assert_hatchery_inner_scroll(main)
			main.panel_host.close_panel()
			await create_timer(0.24).timeout
			continue
		if mode_id == "dex":
			_force_content_overflow(main, "dex")
			await process_frame
			await _assert_dex_inner_scroll(main)
			main.panel_host.close_panel()
			await create_timer(0.24).timeout
			continue
		if mode_id == "quests":
			_force_quest_overflow(main)
			await process_frame
			await _assert_quest_inner_scroll(main)
			main.panel_host.close_panel()
			await create_timer(0.24).timeout
			continue
		await _assert_scroll_moves_if_needed(main.panel_host.scroll, main.panel_host.panel.get_global_rect(), "%s panel" % mode_id)
		await _assert_scroll_moves_from_live_child_if_needed(main.panel_host.scroll, main.panel_host.panel.get_global_rect(), "%s panel" % mode_id)
		main.panel_host.close_panel()
		await create_timer(0.24).timeout

func _force_content_overflow(main, mode_id):
	if main.panel_host == null or main.panel_host.content_holder.get_child_count() == 0:
		return
	var content = main.panel_host.content_holder.get_child(0)
	if mode_id == "hatchery" and content is HatcheryPanel and content.content_box != null:
		content.content_box.custom_minimum_size.y = 900.0
		content.content_box.update_minimum_size()
	elif mode_id == "dex" and content is DexPanel and content.content_box != null:
		content.content_box.custom_minimum_size.y = 1100.0
		content.content_box.update_minimum_size()

func _assert_hatchery_inner_scroll(main):
	var content = main.panel_host.content_holder.get_child(0)
	_assert(content != null and content is HatcheryPanel, "hatchery content exists")
	_assert(content.content_scroll != null, "hatchery owns touch scroll")
	await process_frame
	await _assert_scroll_moves_from_content_area(content.content_scroll, content.content_scroll.get_global_rect(), "hatchery inner scroll")
	await _assert_scroll_moves_from_live_child_if_needed(content.content_scroll, content.content_scroll.get_global_rect(), "hatchery inner scroll")

func _assert_dex_inner_scroll(main):
	var content = main.panel_host.content_holder.get_child(0)
	_assert(content != null and content is DexPanel, "dex content exists")
	_assert(content.content_scroll != null, "dex owns touch scroll")
	await process_frame
	await _assert_scroll_moves_from_content_area(content.content_scroll, content.content_scroll.get_global_rect(), "dex inner scroll")
	await _assert_scroll_moves_from_live_child_if_needed(content.content_scroll, content.content_scroll.get_global_rect(), "dex inner scroll")

func _force_quest_overflow(main):
	if main.panel_host == null or main.panel_host.content_holder.get_child_count() == 0:
		return
	var content = main.panel_host.content_holder.get_child(0)
	if content == null or not content is QuestBoard:
		return
	if content.quest_box != null:
		content.quest_box.custom_minimum_size.y = 900.0
		content.quest_box.update_minimum_size()

func _assert_quest_inner_scroll(main):
	var content = main.panel_host.content_holder.get_child(0)
	_assert(content != null and content is QuestBoard, "quest content exists")
	_assert(content.quest_scroll != null, "quest board owns touch scroll")
	await process_frame
	await _assert_scroll_moves_from_content_area(content.quest_scroll, content.quest_scroll.get_global_rect(), "quest inner scroll")
	await _assert_scroll_moves_from_live_child_if_needed(content.quest_scroll, content.quest_scroll.get_global_rect(), "quest inner scroll")

func _make_tall_content(prefix):
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	for index in range(18):
		if index == 0:
			var drag_button = UiComponents.game_button("%s drag button" % prefix, Color(0.94, 0.98, 1.0), UiStyle.YELLOW, false, 58)
			drag_button.name = "DragButton"
			box.add_child(drag_button)
			continue
		var row = PanelContainer.new()
		row.custom_minimum_size = Vector2(0, 58)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1.0, 1.0, 1.0, 0.72), UiStyle.WATER_DARK, 1, 16, 8, false))
		var label = UiStyle.label("%s drag row %02d" % [prefix, index + 1], 14, UiStyle.INK, false)
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_child(label)
		box.add_child(row)
	return box

func _assert_scroll_moves_if_needed(scroll, rect, label):
	if _max_scroll(scroll) <= 16.0:
		return
	await _assert_scroll_moves_from_content_area(scroll, rect, label)

func _assert_scroll_moves_from_content_area(scroll, rect, label):
	_assert(_max_scroll(scroll) > 16.0, "%s has overflow content" % label)
	scroll.scroll_vertical = 0
	await process_frame
	var start = rect.position + Vector2(rect.size.x * 0.48, rect.size.y * 0.58)
	start.x = min(start.x, rect.end.x - 72.0)
	start.x = max(start.x, rect.position.x + 72.0)
	await _drag(start, Vector2(0, -72), 4)
	await process_frame
	_assert(scroll.scroll_vertical >= 80, "%s scrolls from content drag, got %d" % [label, scroll.scroll_vertical])
	var drag_button = scroll.find_child("DragButton", true, false)
	if drag_button != null and drag_button is Control:
		scroll.scroll_vertical = 0
		await process_frame
		await _drag(drag_button.get_global_rect().get_center(), Vector2(0, -72), 4)
		await process_frame
		_assert(scroll.scroll_vertical >= 80, "%s scrolls from a button drag, got %d" % [label, scroll.scroll_vertical])

func _assert_scroll_moves_from_live_child_if_needed(scroll, rect, label):
	if _max_scroll(scroll) <= 16.0:
		return
	var target = _first_visible_drag_target(scroll, rect)
	_assert(target != null, "%s has a visible child drag target" % label)
	scroll.scroll_vertical = 0
	await process_frame
	await _drag(target.get_global_rect().get_center(), Vector2(0, -72), 4)
	await process_frame
	_assert(scroll.scroll_vertical >= 80, "%s scrolls from a live child drag, got %d" % [label, scroll.scroll_vertical])

func _first_visible_drag_target(scroll, rect):
	for button in scroll.find_children("*", "Button", true, false):
		if button is Control and button.is_visible_in_tree() and button.get_global_rect().intersects(rect.grow(-8.0)):
			return button
	for panel in scroll.find_children("*", "PanelContainer", true, false):
		if panel is Control and panel.is_visible_in_tree() and panel.get_global_rect().intersects(rect.grow(-8.0)):
			return panel
	return null

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

func _max_scroll(scroll):
	if scroll == null:
		return 0.0
	var bar = scroll.get_v_scroll_bar()
	if bar == null:
		return 0.0
	return max(0.0, float(bar.max_value) - float(bar.page))

func _assert(condition, label):
	if condition:
		return
	push_error("Scroll drag QA failed: %s" % label)
	quit(1)
