extends SceneTree

const PHONE_VIEWPORTS = [
	Vector2i(375, 667),
	Vector2i(390, 844),
	Vector2i(430, 932),
]

func _init():
	call_deferred("_run")

func _run():
	for viewport_size in PHONE_VIEWPORTS:
		var phone_viewport = SubViewport.new()
		phone_viewport.size = viewport_size
		phone_viewport.disable_3d = true
		phone_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(phone_viewport)
		var main = load("res://godot/scenes/ui/main_game.tscn").instantiate()
		phone_viewport.add_child(main)
		await process_frame
		await process_frame
		await process_frame
		await _audit_main(main, viewport_size)
		root.remove_child(phone_viewport)
		phone_viewport.queue_free()
		await process_frame
	quit(0)

func _audit_main(main, expected_size):
	var viewport = main.get_viewport_rect()
	var hud = main.resource_hud.get_global_rect()
	var partner = main.partner_float.get_global_rect()
	var action = main.action_dock.get_global_rect()
	var mode = main.mode_dock.get_global_rect()

	_assert(abs(viewport.size.x - expected_size.x) <= 1 and abs(viewport.size.y - expected_size.y) <= 1, "portrait viewport %s" % expected_size)
	_assert(hud.position.y >= 0, "hud inside top")
	_assert(hud.size.y <= 72.0, "v3 hud stays lightweight %s" % hud.size)
	_assert(not main.mode_dock.expanded, "module tray collapsed on home")
	_assert(mode.size.x <= 84.0, "home module button remains compact %s" % mode.size)
	_assert(mode.end.y <= viewport.size.y + 1, "mode dock inside bottom")
	_assert(_inside_viewport(partner, viewport), "partner float inside viewport")
	_assert(not action.intersects(mode), "action dock and module menu do not overlap")
	_assert(abs(action.position.y - mode.position.y) <= 2.0, "action dock and module button share one row")
	_assert(abs(action.end.y - mode.end.y) <= 2.0, "bottom controls share one baseline")
	_assert(partner.end.y <= action.position.y + 1, "partner float above action dock")
	_assert(not hud.intersects(action), "hud/action not overlapping")
	_assert(not hud.intersects(mode), "hud/mode not overlapping")
	_assert(not partner.intersects(action), "partner/action not overlapping")
	_assert(_home_ui_footprint([hud, partner, action, mode], viewport) <= 0.29, "home persistent UI footprint under 29%")
	_assert_fish_clear_top_hud(main, hud)

	_assert_buttons(main, 44.0)
	_assert_scrolls(main)

	main._feed_selected()
	await process_frame
	await create_timer(0.32).timeout
	_assert(main.bottom_sheet.visible, "bottom sheet visible")
	_assert(_inside_viewport(main.bottom_sheet.sheet.get_global_rect(), viewport), "bottom sheet inside viewport")
	_assert_buttons(main.bottom_sheet, 44.0)
	_assert_scrolls(main.bottom_sheet)
	main.bottom_sheet.close()
	await create_timer(0.24).timeout
	await process_frame

	for mode_id in ["hatchery", "dex", "adventure", "quests"]:
		main._select_mode(mode_id)
		await process_frame
		await create_timer(0.28).timeout
		_assert(main.panel_host.visible, "%s visible" % mode_id)
		var panel_rect = main.panel_host.panel.get_global_rect()
		_assert(_inside_viewport(panel_rect, viewport), "%s panel inside viewport" % mode_id)
		_assert(panel_rect.end.y <= action.position.y + 8.0, "%s panel stops above bottom actions" % mode_id)
		_assert_buttons(main.panel_host, 44.0)
		_assert_scrolls(main.panel_host)
		main.panel_host.close_panel()
		await create_timer(0.24).timeout
		await process_frame

func _assert_buttons(node, min_size):
	for button in node.find_children("*", "Button", true, false):
		if not button.is_visible_in_tree():
			continue
		var size = button.get_global_rect().size
		_assert(size.x >= min_size and size.y >= min_size, "button hit target %s %s" % [button.name, size])

func _assert_scrolls(node):
	for scroll in node.find_children("*", "ScrollContainer", true, false):
		_assert(scroll.clip_contents, "scroll clips content")
		_assert(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "scroll horizontal disabled")
		_assert(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "scroll vertical auto")
		var vbar = scroll.get_v_scroll_bar()
		if vbar != null:
			_assert(vbar.mouse_filter == Control.MOUSE_FILTER_IGNORE, "vertical scrollbar is not a touch target")
			_assert(vbar.modulate.a <= 0.05, "vertical scrollbar hidden")
		var hbar = scroll.get_h_scroll_bar()
		if hbar != null:
			_assert(hbar.mouse_filter == Control.MOUSE_FILTER_IGNORE, "horizontal scrollbar is not a touch target")
			_assert(hbar.modulate.a <= 0.05, "horizontal scrollbar hidden")

func _inside_viewport(rect, viewport):
	return rect.position.x >= -1 and rect.position.y >= -1 and rect.end.x <= viewport.size.x + 1 and rect.end.y <= viewport.size.y + 1

func _home_ui_footprint(rects, viewport):
	var area = 0.0
	for rect in rects:
		area += max(0.0, rect.size.x) * max(0.0, rect.size.y)
	var viewport_area = max(1.0, viewport.size.x * viewport.size.y)
	return area / viewport_area

func _assert_fish_clear_top_hud(main, hud):
	var hud_bottom = hud.end.y
	for fish in main.controller.state.get("fish", []):
		var swim = fish.get("swim", {})
		var app = fish.get("appearance", {})
		var center_y = float(swim.get("y", 0.0))
		var radius = 34.0 * float(app.get("size", 1.0)) * float(swim.get("depth", 1.0))
		_assert(center_y - radius >= hud_bottom - 1.0, "fish clears top hud: %.1f >= %.1f" % [center_y - radius, hud_bottom])

func _assert(condition, label):
	if condition:
		return
	push_error("Layout QA failed: %s" % label)
	quit(1)
