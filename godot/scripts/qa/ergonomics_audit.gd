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

		await _audit_home(main, viewport_size)
		await _audit_bottom_sheet(main, viewport_size)
		await _audit_panel_host(main, viewport_size)
		await _audit_fx_banners(main, viewport_size)
		await _audit_action_feedback(main)

		root.remove_child(phone_viewport)
		phone_viewport.queue_free()
		await process_frame
	quit(0)

func _audit_home(main, viewport_size):
	var viewport_rect = main.get_viewport_rect()
	var safe = UiStyle.safe_insets(viewport_rect.size)
	var thumb_top = viewport_rect.size.y * 0.54
	var lower_safe_end = viewport_rect.size.y - safe["bottom"]

	var hud = main.resource_hud.get_global_rect()
	var partner = main.partner_float.get_global_rect()
	var action = main.action_dock.get_global_rect()
	var mode = main.mode_dock.get_global_rect()

	_assert(abs(viewport_rect.size.x - viewport_size.x) <= 1 and abs(viewport_rect.size.y - viewport_size.y) <= 1, "portrait viewport %s" % viewport_size)
	_assert(hud.position.y >= safe["top"] - 2.0, "hud respects top safe area")
	_assert(mode.end.y <= viewport_rect.size.y - safe["bottom"] - 8.0, "mode dock leaves home indicator room")
	_assert(action.position.y >= thumb_top, "action dock is in thumb zone")
	_assert(action.end.y <= lower_safe_end, "action dock avoids bottom unsafe area")
	_assert(mode.position.y >= thumb_top, "mode dock is in thumb zone")
	_assert(mode.end.y <= lower_safe_end, "mode dock avoids bottom unsafe area")
	_assert(partner.position.y >= viewport_rect.size.y * 0.45, "partner float stays in lower glance zone")
	_assert(partner.end.y <= action.position.y - 2.0, "partner float stays clear of primary actions")
	_assert(not action.intersects(mode), "action dock and module menu stay separated")
	_assert(abs(action.get_center().y - mode.get_center().y) <= 8.0, "action dock and module menu share one bottom row")
	_assert(partner.size.x <= viewport_rect.size.x * 0.66, "partner float does not dominate pond width")

	_assert_primary_buttons(main.action_dock, thumb_top, lower_safe_end, safe, "action")
	_assert_primary_buttons(main.mode_dock, thumb_top, lower_safe_end, safe, "mode")

func _audit_bottom_sheet(main, viewport_size):
	main._feed_selected()
	await process_frame
	await create_timer(0.32).timeout
	var viewport_rect = main.get_viewport_rect()
	var safe = UiStyle.safe_insets(viewport_rect.size)
	var sheet = main.bottom_sheet.sheet.get_global_rect()
	var scroll = main.bottom_sheet.scroll.get_global_rect()
	var mode = main.mode_dock.get_global_rect()
	_assert(main.bottom_sheet.visible, "bottom sheet opens")
	_assert(sheet.end.y <= viewport_rect.size.y - safe["bottom"] - 8.0, "bottom sheet leaves home indicator room")
	_assert(sheet.position.y >= safe["top"] + 8.0, "bottom sheet keeps pond context visible top=%.1f threshold=%.1f viewport=%s" % [sheet.position.y, safe["top"] + 8.0, viewport_size])
	_assert(scroll.size.y >= viewport_size.y * 0.25, "bottom sheet keeps enough drag surface")
	_assert(not sheet.intersects(mode), "bottom sheet does not collide with mode dock")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

func _audit_panel_host(main, viewport_size):
	main._select_mode("dex")
	await process_frame
	await create_timer(0.28).timeout
	var viewport_rect = main.get_viewport_rect()
	var safe = UiStyle.safe_insets(viewport_rect.size)
	var panel = main.panel_host.panel.get_global_rect()
	var scroll = main.panel_host.scroll.get_global_rect()
	var action = main.action_dock.get_global_rect()
	var mode = main.mode_dock.get_global_rect()
	_assert(main.panel_host.visible, "panel host opens")
	_assert(panel.position.y >= safe["top"] + 40.0, "panel host respects top reach and safe area")
	_assert(panel.end.y <= action.position.y - 6.0, "panel host stays above primary action dock")
	_assert(panel.end.y <= mode.position.y - 6.0, "panel host stays above mode dock")
	_assert(scroll.size.y >= viewport_size.y * 0.42, "panel host keeps generous content drag surface")
	_assert(_back_button_is_reachable(main.panel_host, safe, viewport_rect), "panel back button remains visible and reachable")
	main.panel_host.close_panel()
	await create_timer(0.24).timeout

func _audit_fx_banners(main, viewport_size):
	var viewport_rect = main.get_viewport_rect()
	var safe = UiStyle.safe_insets(viewport_rect.size)
	var action = main.action_dock.get_global_rect()
	var toast = main.fx_layer.show_toast("投喂 +24")
	var result = main.fx_layer.show_result("奖励领取", "泡泡币 120 · 贝壳 2", UiStyle.REWARD)
	await process_frame
	var toast_rect = toast.get_global_rect()
	var result_rect = result.get_global_rect()
	_assert(toast_rect.size.y <= 38.0, "toast remains compact %s" % toast_rect.size)
	_assert(result_rect.size.y <= 90.0, "result banner remains compact %s" % result_rect.size)
	_assert(toast_rect.position.y <= safe["top"] + 90.0, "toast stays near top")
	_assert(result_rect.position.y <= safe["top"] + 90.0, "result banner stays near top")
	_assert(not toast_rect.intersects(action), "toast does not cover action dock")
	_assert(not result_rect.intersects(action), "result banner does not cover action dock")
	toast.queue_free()
	result.queue_free()
	await process_frame

func _audit_action_feedback(main):
	main.controller.state["foodInventory"] = SaveStore.ensure_food_inventory({"basic": 2, "glow": 1, "coral": 1, "spicy": 1})
	main._feed_selected()
	await process_frame
	await create_timer(0.32).timeout
	await main._feed_with_food("basic")
	await process_frame
	var result_count = _count_named(main.fx_layer, "ResultCard")
	var toast_count = _count_named(main.fx_layer, "ToastCard")
	_assert(result_count == 1, "feed success shows one result banner, got %d; fx=%s" % [result_count, _node_names(main.fx_layer)])
	_assert(toast_count == 0, "feed success does not duplicate toast, got %d; fx=%s" % [toast_count, _node_names(main.fx_layer)])
	for card in main.fx_layer.find_children("ResultCard", "PanelContainer", true, false):
		card.queue_free()
	if main.bottom_sheet.visible:
		main.bottom_sheet.close()
	await create_timer(0.24).timeout

func _assert_primary_buttons(node, thumb_top, lower_safe_end, safe, label):
	for button in node.find_children("*", "Button", true, false):
		if not button.is_visible_in_tree():
			continue
		var rect = button.get_global_rect()
		var center = rect.position + rect.size * 0.5
		_assert(rect.size.x >= 50.0 and rect.size.y >= 44.0, "%s button has finger target %s" % [label, rect.size])
		_assert(rect.position.x >= safe["left"] - 1.0, "%s button not clipped left" % label)
		_assert(rect.end.x <= node.get_viewport_rect().size.x - safe["right"] + 1.0, "%s button not clipped right" % label)
		_assert(center.y >= thumb_top and center.y <= lower_safe_end, "%s button center in thumb zone %s" % [label, center])

func _back_button_is_reachable(panel_host, safe, viewport_rect):
	var buttons = panel_host.find_children("*", "Button", true, false)
	if buttons.is_empty():
		return false
	var rect = buttons[0].get_global_rect()
	return rect.size.x >= 44.0 and rect.size.y >= 44.0 and rect.position.x >= safe["left"] - 1.0 and rect.position.y >= safe["top"] + 40.0 and rect.end.y <= viewport_rect.size.y * 0.32

func _count_named(node, target_name):
	var count = 0
	for child in node.get_children():
		if child.is_visible_in_tree() and str(child.name).begins_with(target_name):
			count += 1
		count += _count_named(child, target_name)
	return count

func _node_names(node):
	var names = []
	for child in node.get_children():
		names.append(str(child.name))
	return ",".join(names)

func _assert(condition, label):
	if condition:
		return
	push_error("Ergonomics QA failed: %s" % label)
	quit(1)
