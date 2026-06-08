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

	main.debug_layer.toggle()
	await process_frame
	_assert(main.debug_layer.visible, "debug overlay visible")
	_assert(main.debug_layer.mouse_filter == Control.MOUSE_FILTER_IGNORE, "debug overlay does not block input")
	_assert(main.debug_layer.info_label.text.contains("Evidence"), "manual evidence visible")
	_assert(main.debug_layer.info_label.text.contains("Event"), "semantic event line visible")
	_assert(main.debug_layer.info_label.text.contains("green=safe"), "safe-area legend visible")
	_assert(main.debug_layer.info_label.text.contains("图标看"), "icon readability remains manual visual check")
	_assert(main.debug_layer.info_label.text.contains("游戏看"), "game-feel density remains manual visual check")
	_assert(main.debug_layer.info_label.text.contains("字体看"), "font item remains manual visual check")
	_assert(main.debug_layer.info_label.text.contains("单手看"), "one-hand reach remains manual visual check")
	_assert(main.debug_layer.get_manual_audit_items().size() >= 10, "manual audit item count")
	_assert(_has_audit_item(main, "fish_tap"), "fish tap checklist item")
	_assert(_has_audit_item(main, "sheet_drag"), "sheet drag checklist item")
	_assert(_has_audit_item(main, "panel_drag"), "panel drag checklist item")
	_assert(_has_audit_item(main, "dock_taps"), "dock taps checklist item")
	_assert(_has_audit_item(main, "safe_area"), "safe area checklist item")
	_assert(_has_audit_item(main, "text_fit"), "text fit checklist item")
	_assert(_has_audit_item(main, "icon_read"), "icon readability checklist item")
	_assert(_has_audit_item(main, "visual_density"), "visual density checklist item")
	_assert(_has_audit_item(main, "font_feel"), "font feel checklist item")
	_assert(_has_audit_item(main, "one_hand"), "one hand checklist item")

	var home_rects = main.debug_layer.get_audit_rects()
	_assert(_has_rect(home_rects, "HUD"), "hud rect visible")
	_assert(_has_rect(home_rects, "Partner"), "partner rect visible")
	_assert(_has_rect(home_rects, "ActionDock"), "action dock rect visible")
	_assert(_has_rect(home_rects, "ModeDock"), "mode dock rect visible")
	_assert(_rects_inside_viewport(home_rects), "home audit rects inside viewport")
	_send_debug_touch(main.debug_layer, _rect_center(_rect_by_label(home_rects, "ActionDock")))
	_assert(main.debug_layer.get_touch_audit_summary().get("target", "") == "ActionDock", "debug classifies action dock touch")
	_send_debug_touch(main.debug_layer, Vector2(195, 320))
	_assert(main.debug_layer.get_touch_audit_summary().get("target", "") == "World", "debug classifies world touch")
	var home_manual = main.debug_layer.get_touch_audit_summary().get("manual", {})
	_assert(not bool(home_manual.get("fish_tap", false)), "manual evidence does not treat empty water tap as fish selection")
	_assert(bool(home_manual.get("dock_taps", false)), "manual evidence records dock tap")
	_assert(bool(home_manual.get("safe_area", false)), "manual evidence has safe area before unsafe edge")
	var first_fish = main.controller.state.get("fish", [])[0]
	main._select_fish_from_pond(first_fish.get("id", ""))
	await process_frame
	var semantic_home = main.debug_layer.get_touch_audit_summary()
	_assert(bool(semantic_home.get("manual", {}).get("fish_tap", false)), "manual evidence records semantic fish selection")
	_assert(int(semantic_home.get("event_hits", {}).get("fish_selected", 0)) >= 1, "semantic event records fish selection")
	_send_debug_touch(main.debug_layer, Vector2(3, 3))
	_assert(main.debug_layer.get_touch_audit_summary().get("target", "") == "UnsafeEdge", "debug classifies unsafe edge touch")
	_assert(not bool(main.debug_layer.get_touch_audit_summary().get("manual", {}).get("safe_area", true)), "manual evidence warns unsafe edge touch")
	_assert(int(main.debug_layer.get_touch_audit_summary().get("count", 0)) >= 3, "debug touch counter records touches")

	main._feed_selected()
	await process_frame
	await create_timer(0.32).timeout
	var sheet_summary = main.debug_layer.get_touch_audit_summary()
	_assert(int(sheet_summary.get("event_hits", {}).get("action", 0)) >= 1, "semantic event records action dock command")
	_assert(int(sheet_summary.get("event_hits", {}).get("sheet_open", 0)) >= 1, "semantic event records sheet opening")
	var sheet_rects = main.debug_layer.get_audit_rects()
	_assert(_has_rect(sheet_rects, "Sheet"), "bottom sheet rect visible")
	_assert(_rects_inside_viewport(sheet_rects), "sheet audit rects inside viewport")
	_send_debug_drag(main.debug_layer, _rect_center(_rect_by_label(sheet_rects, "Sheet")), Vector2(0, -80))
	_assert(main.debug_layer.get_touch_audit_summary().get("drag_target", "") == "Sheet", "debug classifies sheet drag")
	_assert(bool(main.debug_layer.get_touch_audit_summary().get("manual", {}).get("sheet_drag", false)), "manual evidence records sheet drag")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

	main._select_mode("dex")
	await process_frame
	await create_timer(0.28).timeout
	var panel_summary = main.debug_layer.get_touch_audit_summary()
	_assert(int(panel_summary.get("event_hits", {}).get("mode", 0)) >= 1, "semantic event records mode switch")
	_assert(int(panel_summary.get("event_hits", {}).get("panel_open", 0)) >= 1, "semantic event records panel opening")
	var panel_rects = main.debug_layer.get_audit_rects()
	_assert(_has_rect(panel_rects, "Panel"), "panel rect visible")
	_assert(_rects_inside_viewport(panel_rects), "panel audit rects inside viewport")
	_send_debug_drag(main.debug_layer, _rect_center(_rect_by_label(panel_rects, "Panel")), Vector2(0, -80))
	_assert(main.debug_layer.get_touch_audit_summary().get("drag_target", "") == "Panel", "debug classifies panel drag")
	_assert(bool(main.debug_layer.get_touch_audit_summary().get("manual", {}).get("panel_drag", false)), "manual evidence records panel drag")

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	quit(0)

func _has_audit_item(main, id):
	for item in main.debug_layer.get_manual_audit_items():
		if str(item.get("id", "")) == id:
			return true
	return false

func _has_rect(rects, label):
	for item in rects:
		if str(item.get("label", "")) == label:
			return true
	return false

func _rect_by_label(rects, label):
	for item in rects:
		if str(item.get("label", "")) == label:
			return item.get("rect", Rect2())
	return Rect2()

func _rect_center(rect):
	return rect.position + rect.size * 0.5

func _send_debug_touch(debug_layer, position):
	var event = InputEventScreenTouch.new()
	event.pressed = true
	event.position = position
	debug_layer.record_input(event)

func _send_debug_drag(debug_layer, position, relative):
	var event = InputEventScreenDrag.new()
	event.position = position
	event.relative = relative
	debug_layer.record_input(event)

func _rects_inside_viewport(rects):
	var viewport = Rect2(Vector2.ZERO, Vector2(phone_viewport.size))
	for item in rects:
		var rect = item.get("rect", Rect2())
		if rect.position.x < -1.0 or rect.position.y < -1.0:
			return false
		if rect.end.x > viewport.end.x + 1.0 or rect.end.y > viewport.end.y + 1.0:
			return false
		if min(rect.size.x, rect.size.y) < 44.0:
			return false
	return true

func _assert(condition, label):
	if condition:
		return
	push_error("Manual debug overlay QA failed: %s" % label)
	quit(1)
