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

	_assert(UiStyle.TEXT_FONT is SystemFont, "text font uses system font")
	_assert(UiStyle.TEXT_FONT != UiStyle.DISPLAY_FONT, "display/text fonts are separated")
	_assert(UiStyle.TEXT_FONT.allow_system_fallback, "text font allows system fallback")
	_assert(UiStyle.TEXT_FONT.font_names.has("PingFang SC"), "text font prefers iOS Chinese font")
	_assert(main.theme.get_default_font() == UiStyle.TEXT_FONT, "app theme default font is text font")
	_assert(main.theme.get_font("font", "Button") == UiStyle.DISPLAY_FONT, "button theme uses display font")

	_audit_text_controls(main)
	_audit_home_microcopy(main)
	_audit_action_dock(main)
	_audit_mode_dock(main)

	main._feed_selected()
	await process_frame
	await create_timer(0.32).timeout
	_audit_text_controls(main.bottom_sheet)
	_audit_no_vertical_micro_labels(main.bottom_sheet, "food sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

	main._open_partner_details()
	await process_frame
	await create_timer(0.32).timeout
	_audit_text_controls(main.bottom_sheet)
	_audit_no_vertical_micro_labels(main.bottom_sheet, "partner sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

	main._try_evolution()
	await process_frame
	await create_timer(0.32).timeout
	_audit_text_controls(main.bottom_sheet)
	_audit_no_vertical_micro_labels(main.bottom_sheet, "evolution sheet")
	main.bottom_sheet.close()
	await create_timer(0.24).timeout

	for mode_id in ["hatchery", "dex", "adventure", "quests"]:
		main._select_mode(mode_id)
		await process_frame
		await create_timer(0.28).timeout
		_audit_text_controls(main.panel_host)
		_audit_no_vertical_micro_labels(main.panel_host, "%s panel" % mode_id)
		main.panel_host.close_panel()
		await create_timer(0.24).timeout

	root.remove_child(phone_viewport)
	phone_viewport.queue_free()
	quit(0)

func _audit_text_controls(node):
	for label in node.find_children("*", "Label", true, false):
		if not label.is_visible_in_tree():
			continue
		var text = str(label.text)
		if text.strip_edges().is_empty():
			continue
		var font = label.get_theme_font("font")
		var font_size = label.get_theme_font_size("font_size")
		_assert(font != null, "label has font: %s" % label.name)
		_assert(font_size >= 11, "label readable size: %s %d" % [label.name, font_size])
		_assert(not _has_replacement_glyph(text), "label has no replacement glyphs: %s" % label.name)
	for button in node.find_children("*", "Button", true, false):
		if not button.is_visible_in_tree():
			continue
		var font = button.get_theme_font("font")
		var font_size = button.get_theme_font_size("font_size")
		_assert(font != null, "button has font: %s" % button.name)
		_assert(font_size >= 12, "button readable size: %s %d" % [button.name, font_size])
		_assert(not _has_replacement_glyph(str(button.text)), "button has no replacement glyphs: %s" % button.name)

func _audit_action_dock(main):
	var buttons = main.action_dock.find_children("*", "Button", true, false)
	_assert(buttons.size() == 3, "action dock button count")
	for button in buttons:
		_assert(str(button.text).is_empty(), "action button uses icon content instead of raw text")
		_assert(button.has_meta("pokefish_action_kind"), "action button has kind metadata")
		_assert(button.tooltip_text.length() > 0, "action button keeps tooltip")
		var icon = button.find_child("ActionIcon", true, false)
		var label = button.find_child("ActionLabel", true, false)
		_assert(icon != null and icon is Control, "action button has drawn icon")
		_assert(label != null and label is Label, "action button has short label")
		_assert(str(label.text).length() <= 2, "action button label stays short")
		_assert(label.get_theme_font("font") == UiStyle.DISPLAY_FONT, "action button label uses display font")
		_assert(label.get_global_rect().size.y >= 16.0, "action button label has visible height")

func _audit_mode_dock(main):
	var buttons = main.mode_dock.find_children("*", "Button", true, false)
	_assert(buttons.size() == 5, "mode dock button count")
	for button in buttons:
		_assert(str(button.text).is_empty(), "mode button uses drawn icon instead of glyph text")
		_assert(button.has_meta("pokefish_mode_id"), "mode button has id metadata")
		_assert(button.tooltip_text.length() > 0, "mode button keeps tooltip")
		var icon = button.find_child("ModeIcon", true, false)
		var label = button.find_child("ModeLabel", true, false)
		_assert(icon != null and icon is Control, "mode button has drawn icon")
		_assert(label != null and label is Label, "mode button has short label")
		_assert(str(label.text).length() > 0, "mode button label is always visible")
		_assert(str(label.text).length() <= 2, "mode button label stays short")
		_assert(label.get_theme_font("font") == UiStyle.DISPLAY_FONT, "mode button label uses display font")
	var active_label = _active_mode_label(main)
	_assert(active_label != null, "mode dock has active label")
	_assert(active_label.get_global_rect().size.y >= 14.0, "active mode label has visible height")

func _audit_home_microcopy(main):
	var menu_buttons = main.resource_hud.find_children("*", "Button", true, false)
	_assert(menu_buttons.size() == 1, "resource hud has one menu button")
	var menu = menu_buttons[0]
	_assert(str(menu.text).is_empty(), "menu button uses drawn icon instead of glyph text")
	_assert(menu.tooltip_text.length() > 0, "menu button keeps tooltip")
	_assert(menu.find_child("MenuIcon", true, false) != null, "menu button has drawn icon")

	var rate_label = main.resource_hud.find_child("IdleRateValue", true, false)
	_assert(rate_label != null and rate_label is Label, "resource hud has icon rate value")
	_assert(str(rate_label.text).find("/分") < 0, "resource hud avoids raw per-minute unit text")

	var output_label = main.partner_float.find_child("OutputValue", true, false)
	_assert(output_label != null and output_label is Label, "partner float has icon output value")
	_assert(str(output_label.text).find("/分") < 0, "partner float avoids raw per-minute unit text")

func _audit_no_vertical_micro_labels(node, label_name):
	for label in node.find_children("*", "Label", true, false):
		if not label.is_visible_in_tree():
			continue
		var text = str(label.text).strip_edges()
		if text.is_empty() or text.length() > 12:
			continue
		var rect = label.get_global_rect()
		var lines = label.get_line_count()
		_assert(lines <= 2, "%s short label not wrapped into vertical text: %s lines=%d" % [label_name, text, lines])
		_assert(rect.size.x >= 18.0 or rect.size.y <= 32.0, "%s short label has usable width: %s %s" % [label_name, text, rect.size])
		if text.length() >= 3 and not _is_compact_numeric(text):
			var required_width = min(96.0, max(34.0, float(text.length()) * 9.0))
			_assert(rect.size.x >= required_width, "%s short label avoids vertical column: %s rect=%s required=%.1f" % [label_name, text, rect, required_width])
			_assert(rect.size.y / max(1.0, rect.size.x) < 1.35, "%s short label has sane aspect: %s rect=%s" % [label_name, text, rect])

func _active_mode_label(main):
	for button in main.mode_dock.find_children("*", "Button", true, false):
		if str(button.get_meta("pokefish_mode_id", "")) != main.mode_dock.current_mode:
			continue
		return button.find_child("ModeLabel", true, false)
	return null

func _has_replacement_glyph(text):
	return text.find("�") >= 0 or text.find("□") >= 0

func _is_compact_numeric(text):
	var stripped = text.strip_edges()
	if stripped.is_valid_int() or stripped.is_valid_float():
		return true
	return stripped.begins_with("+") and stripped.substr(1).is_valid_int()

func _assert(condition, label):
	if condition:
		return
	push_error("Text QA failed: %s" % label)
	quit(1)
