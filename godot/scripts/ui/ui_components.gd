extends RefCounted
class_name UiComponents

const GameData = preload("res://godot/scripts/game_data.gd")

static func game_button(text, bg := UiStyle.CONFIRM, pressed_bg := UiStyle.COST, display := true, min_height := 48):
	var button = Button.new()
	button.text = str(text)
	button.custom_minimum_size = Vector2(0, min_height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	UiStyle.apply_button(button, bg, pressed_bg, display)
	attach_press_feedback(button)
	return button

static func attach_press_feedback(button, pressed_scale := 0.96):
	if button == null or button.has_meta("_pokefish_press_feedback"):
		return
	button.set_meta("_pokefish_press_feedback", true)
	button.resized.connect(func():
		if is_instance_valid(button):
			button.pivot_offset = button.size * 0.5
	)
	button.button_down.connect(func():
		if not is_instance_valid(button):
			return
		var tween = button.create_tween()
		tween.tween_property(button, "scale", Vector2(pressed_scale, pressed_scale), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	)
	button.button_up.connect(func():
		if not is_instance_valid(button):
			return
		var tween = button.create_tween()
		tween.tween_property(button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)

static func play_staggered_entry(owner, nodes, delay_step := 0.045, start_scale := 0.96):
	if owner == null:
		return
	var index = 0
	for node in nodes:
		if node == null or not is_instance_valid(node) or not (node is Control):
			continue
			if not node.is_visible_in_tree():
				continue
			node.pivot_offset = node.size * 0.5
			node.scale = Vector2(start_scale, start_scale)
			node.modulate.a = 1.0
			var tween = owner.create_tween()
			tween.tween_interval(index * delay_step)
			tween.tween_property(node, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			index += 1

static func panel(bg := UiStyle.GLASS, border := UiStyle.INK, border_width := 3, radius := 22, margin := 10):
	var node = PanelContainer.new()
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.add_theme_stylebox_override("panel", UiStyle.panel_style(bg, border, border_width, radius, margin))
	return node

static func tag_chip(text, bg := Color(0.94, 0.98, 1.0), color := UiStyle.INK):
	var chip = PanelContainer.new()
	var chip_text = str(text)
	var min_width = max(42, chip_text.length() * 15 + 20)
	chip.custom_minimum_size = Vector2(min_width, 28)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip.add_theme_stylebox_override("panel", UiStyle.panel_style(bg, UiStyle.INK, 1, 14, 7, false))
	var label = UiStyle.label(chip_text, 12, color, false)
	label.custom_minimum_size = Vector2(max(22, min_width - 14), 0)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chip.add_child(label)
	return chip

static func resource_icon(key, min_size := Vector2(22, 22)):
	var icon = Control.new()
	icon.custom_minimum_size = min_size
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func():
		var side = floor(min(icon.size.x, icon.size.y))
		var origin = ((icon.size - Vector2(side, side)) * 0.5).floor()
		var color = UiStyle.resource_color(key)
		_pixel_rect(icon, Rect2(origin + Vector2(side * 0.1, side * 0.1), Vector2(side * 0.8, side * 0.8)), Color(1, 1, 1, 0.96), UiStyle.INK, max(2.0, side * 0.09))
		if key == "bubbleCoins":
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.27, side * 0.3), Vector2(side * 0.27, side * 0.27)), color, Color(0, 0, 0, 0), 0)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.49, side * 0.48), Vector2(side * 0.2, side * 0.2)), color.lightened(0.18), Color(0, 0, 0, 0), 0)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.3, side * 0.25), Vector2(side * 0.1, side * 0.1)), Color.WHITE, Color(0, 0, 0, 0), 0)
		elif key == "shells":
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.22, side * 0.44), Vector2(side * 0.56, side * 0.22)), color, UiStyle.INK, max(1.5, side * 0.08))
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.32, side * 0.28), Vector2(side * 0.36, side * 0.18)), color.lightened(0.08), UiStyle.INK, max(1.0, side * 0.05))
			for i in range(3):
				var x = origin.x + side * (0.36 + i * 0.14)
				icon.draw_line(Vector2(x, origin.y + side * 0.32).round(), Vector2(origin.x + side * 0.5, origin.y + side * 0.66).round(), Color(1, 1, 1, 0.55), 1.0)
		elif key == "eggs":
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.36, side * 0.22), Vector2(side * 0.28, side * 0.12)), color.lightened(0.08), Color(0, 0, 0, 0), 0)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.28, side * 0.34), Vector2(side * 0.44, side * 0.36)), color, UiStyle.INK, max(1.5, side * 0.08))
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.38, side * 0.34), Vector2(side * 0.09, side * 0.09)), Color.WHITE, Color(0, 0, 0, 0), 0)
		elif key == "pearls":
			var diamond = PackedVector2Array([
				(origin + Vector2(side * 0.5, side * 0.24)).round(),
				(origin + Vector2(side * 0.72, side * 0.5)).round(),
				(origin + Vector2(side * 0.5, side * 0.76)).round(),
				(origin + Vector2(side * 0.28, side * 0.5)).round(),
			])
			icon.draw_colored_polygon(diamond, color.lightened(0.18))
			diamond.append(diamond[0])
			icon.draw_polyline(diamond, UiStyle.INK, max(1.4, side * 0.08), true)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.42, side * 0.36), Vector2(side * 0.12, side * 0.12)), Color.WHITE, Color(0, 0, 0, 0), 0)
		else:
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.3, side * 0.3), Vector2(side * 0.4, side * 0.4)), color, Color(0, 0, 0, 0), 0)
	)
	icon.resized.connect(func(): icon.queue_redraw())
	return icon

static func action_icon(kind, min_size := Vector2(30, 30)):
	var icon = Control.new()
	icon.name = "ActionIcon"
	icon.custom_minimum_size = min_size
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func():
		var side = floor(min(icon.size.x, icon.size.y))
		var origin = ((icon.size - Vector2(side, side)) * 0.5).floor()
		var color = {
			"feed": UiStyle.action_color("feed"),
			"collect": UiStyle.action_color("collect"),
			"evolve": UiStyle.action_color("evolve"),
		}.get(kind, UiStyle.CONFIRM)
		_pixel_rect(icon, Rect2(origin + Vector2(side * 0.08, side * 0.08), Vector2(side * 0.84, side * 0.84)), Color(1, 1, 1, 0.92), UiStyle.INK, max(2.0, side * 0.1))
		if kind == "feed":
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.24, side * 0.52), Vector2(side * 0.52, side * 0.18)), color, UiStyle.INK, max(1.3, side * 0.06))
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.3, side * 0.34), Vector2(side * 0.12, side * 0.12)), UiStyle.ORANGE, UiStyle.INK, 1)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.48, side * 0.26), Vector2(side * 0.12, side * 0.12)), UiStyle.GREEN, UiStyle.INK, 1)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.62, side * 0.38), Vector2(side * 0.1, side * 0.1)), UiStyle.YELLOW, UiStyle.INK, 1)
		elif kind == "collect":
			for index in range(3):
				_pixel_rect(icon, Rect2(origin + Vector2(side * (0.25 + index * 0.18), side * (0.22 + abs(index - 1) * 0.05)), Vector2(side * 0.15, side * 0.15)), color.lightened(0.12 * index), UiStyle.INK, 1)
			icon.draw_line((origin + Vector2(side * 0.5, side * 0.44)).round(), (origin + Vector2(side * 0.5, side * 0.68)).round(), UiStyle.INK, 2.0)
			icon.draw_line((origin + Vector2(side * 0.38, side * 0.58)).round(), (origin + Vector2(side * 0.5, side * 0.7)).round(), UiStyle.INK, 2.0)
			icon.draw_line((origin + Vector2(side * 0.62, side * 0.58)).round(), (origin + Vector2(side * 0.5, side * 0.7)).round(), UiStyle.INK, 2.0)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.32, side * 0.72), Vector2(side * 0.36, side * 0.08)), Color(0, 0, 0, 0), UiStyle.INK, 2)
		elif kind == "evolve":
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.44, side * 0.2), Vector2(side * 0.12, side * 0.58)), color, UiStyle.INK, 1.5)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.24, side * 0.4), Vector2(side * 0.52, side * 0.16)), color, UiStyle.INK, 1.5)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.34, side * 0.3), Vector2(side * 0.32, side * 0.32)), UiStyle.CONFIRM.lightened(0.12), UiStyle.INK, 1.5)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.46, side * 0.42), Vector2(side * 0.08, side * 0.08)), Color.WHITE, Color(0, 0, 0, 0), 0)
		else:
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.3, side * 0.3), Vector2(side * 0.4, side * 0.4)), color, UiStyle.INK, 1)
	)
	icon.resized.connect(func(): icon.queue_redraw())
	return icon

static func mode_icon(kind, min_size := Vector2(28, 28)):
	var icon = Control.new()
	icon.name = "ModeIcon"
	icon.custom_minimum_size = min_size
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.set_meta("active", false)
	icon.set_meta("kind", kind)
	icon.draw.connect(func():
		var active = bool(icon.get_meta("active", false))
		var visual_kind = str(icon.get_meta("kind", kind))
		var center = icon.size * 0.5
		var radius = min(icon.size.x, icon.size.y) * 0.42
		var ink = UiStyle.INK
		var fill = UiStyle.module_color(visual_kind, active)
		if visual_kind == "pond":
			icon.draw_circle(center, radius * 0.78, Color(1, 1, 1, 0.92))
			icon.draw_arc(center, radius * 0.78, 0.0, TAU, 24, ink, max(1.2, radius * 0.11))
			for index in range(2):
				var y = center.y - radius * 0.18 + index * radius * 0.34
				var points = PackedVector2Array()
				for step in range(12):
					var x = center.x - radius * 0.58 + step * radius * 0.11
					points.append(Vector2(x, y + sin(step * 0.9) * radius * 0.12))
				icon.draw_polyline(points, UiStyle.WATER_DARK if active else UiStyle.WATER, 1.8, false)
		elif visual_kind == "menu":
			var body = PackedVector2Array([
				center + Vector2(-radius * 0.62, -radius * 0.16),
				center + Vector2(-radius * 0.48, radius * 0.58),
				center + Vector2(radius * 0.48, radius * 0.58),
				center + Vector2(radius * 0.62, -radius * 0.16),
			])
			icon.draw_colored_polygon(body, fill)
			body.append(body[0])
			icon.draw_polyline(body, ink, 1.7, true)
			icon.draw_arc(center + Vector2(0, -radius * 0.18), radius * 0.36, PI, TAU, 18, ink, 1.6)
			icon.draw_circle(center + Vector2(-radius * 0.24, radius * 0.12), radius * 0.08, UiStyle.WATER)
			icon.draw_circle(center + Vector2(radius * 0.08, radius * 0.08), radius * 0.08, UiStyle.EGG)
			icon.draw_line(center + Vector2(-radius * 0.36, radius * 0.32), center + Vector2(radius * 0.36, radius * 0.32), ink, 1.4)
		elif visual_kind == "hatchery":
			icon.draw_set_transform(center, 0.0, Vector2(radius * 0.55, radius * 0.74))
			icon.draw_circle(Vector2.ZERO, 1.0, fill)
			icon.draw_arc(Vector2.ZERO, 1.0, 0.0, TAU, 32, ink, 0.14, true)
			icon.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			icon.draw_line(center + Vector2(-radius * 0.32, radius * 0.04), center + Vector2(-radius * 0.06, -radius * 0.12), ink, 1.3)
			icon.draw_line(center + Vector2(-radius * 0.06, -radius * 0.12), center + Vector2(radius * 0.18, radius * 0.04), ink, 1.3)
		elif visual_kind == "dex":
			var left = Rect2(center + Vector2(-radius * 0.58, -radius * 0.5), Vector2(radius * 0.52, radius * 1.04))
			var right = Rect2(center + Vector2(-radius * 0.02, -radius * 0.5), Vector2(radius * 0.58, radius * 1.04))
			icon.draw_rect(left, fill.darkened(0.04), true)
			icon.draw_rect(right, fill, true)
			icon.draw_rect(left, ink, false, 1.5)
			icon.draw_rect(right, ink, false, 1.5)
			icon.draw_line(center + Vector2(-radius * 0.02, -radius * 0.5), center + Vector2(-radius * 0.02, radius * 0.54), ink, 1.4)
			icon.draw_circle(center + Vector2(radius * 0.24, radius * 0.12), radius * 0.16, UiStyle.WATER)
			icon.draw_line(center + Vector2(-radius * 0.42, -radius * 0.18), center + Vector2(-radius * 0.16, -radius * 0.18), ink, 1.2)
		elif visual_kind == "adventure":
			var map = PackedVector2Array([
				center + Vector2(-radius * 0.62, -radius * 0.34),
				center + Vector2(-radius * 0.18, -radius * 0.52),
				center + Vector2(radius * 0.24, -radius * 0.34),
				center + Vector2(radius * 0.62, -radius * 0.52),
				center + Vector2(radius * 0.48, radius * 0.46),
				center + Vector2(radius * 0.06, radius * 0.28),
				center + Vector2(-radius * 0.32, radius * 0.48),
				center + Vector2(-radius * 0.68, radius * 0.26),
			])
			icon.draw_colored_polygon(map, fill)
			map.append(map[0])
			icon.draw_polyline(map, ink, 1.5, true)
			icon.draw_circle(center + Vector2(-radius * 0.28, radius * 0.08), radius * 0.09, UiStyle.ORANGE)
			icon.draw_circle(center + Vector2(radius * 0.28, -radius * 0.04), radius * 0.09, UiStyle.GREEN)
		elif visual_kind == "quests":
			var stamp = Rect2(center + Vector2(-radius * 0.5, -radius * 0.36), Vector2(radius, radius * 0.72))
			icon.draw_rect(stamp, fill, true)
			icon.draw_rect(stamp, ink, false, 1.6)
			var handle = Rect2(center + Vector2(-radius * 0.22, -radius * 0.66), Vector2(radius * 0.44, radius * 0.28))
			icon.draw_rect(handle, fill.lightened(0.05), true)
			icon.draw_rect(handle, ink, false, 1.4)
			icon.draw_line(center + Vector2(-radius * 0.26, radius * 0.02), center + Vector2(-radius * 0.08, radius * 0.2), ink, 1.5)
			icon.draw_line(center + Vector2(-radius * 0.08, radius * 0.2), center + Vector2(radius * 0.3, -radius * 0.18), ink, 1.5)
		else:
			icon.draw_circle(center, radius * 0.5, fill)
	)
	icon.resized.connect(func(): icon.queue_redraw())
	return icon

static func menu_icon(min_size := Vector2(24, 24)):
	var icon = Control.new()
	icon.name = "MenuIcon"
	icon.custom_minimum_size = min_size
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func():
		var side = floor(min(icon.size.x, icon.size.y))
		var origin = ((icon.size - Vector2(side, side)) * 0.5).floor()
		_pixel_rect(icon, Rect2(origin + Vector2(side * 0.12, side * 0.12), Vector2(side * 0.76, side * 0.76)), Color(1.0, 1.0, 1.0, 0.92), UiStyle.INK, max(2.0, side * 0.09))
		for index in range(3):
			var y = origin.y + side * (0.32 + index * 0.18)
			icon.draw_line(Vector2(origin.x + side * 0.32, y).round(), Vector2(origin.x + side * 0.72, y).round(), UiStyle.INK, 2.0)
			_pixel_rect(icon, Rect2(origin + Vector2(side * 0.22, side * (0.28 + index * 0.18)), Vector2(side * 0.08, side * 0.08)), UiStyle.WATER, Color(0, 0, 0, 0), 0)
	)
	icon.resized.connect(func(): icon.queue_redraw())
	return icon

static func resource_badge(key, value := 0, bg := Color(1, 1, 1, 0.68)):
	var badge = PanelContainer.new()
	var value_text = str(value)
	badge.custom_minimum_size = Vector2(max(54, value_text.length() * 9 + 34), 28)
	badge.add_theme_stylebox_override("panel", UiStyle.panel_style(bg, UiStyle.INK, 1, 14, 5, false))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	badge.add_child(row)
	row.add_child(resource_icon(key, Vector2(20, 20)))
	var label = UiStyle.label(value_text, 12, UiStyle.INK, true)
	label.custom_minimum_size = Vector2(max(16, value_text.length() * 8), 0)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	return badge

static func reward_row(rewards, bg := Color(1, 1, 1, 0.62)):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key in rewards.keys():
		row.add_child(resource_badge(key, rewards[key], bg))
	return row

static func rarity_badge(rarity, short := true):
	var badge = PanelContainer.new()
	badge.custom_minimum_size = Vector2(36, 28)
	badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.add_theme_stylebox_override("panel", UiStyle.panel_style(UiStyle.rarity_color(rarity), UiStyle.INK, 1, 13, 6, false))
	var text = UiStyle.rarity_short(rarity) if short else GameData.rarity_label(rarity)
	var label = UiStyle.label(text, 13, Color.WHITE, false)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_child(label)
	return badge

static func resource_pill(key, value := 0):
	var pill = PanelContainer.new()
	pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pill.custom_minimum_size = Vector2(0, 28)
	pill.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.52), Color(1, 1, 1, 0), 0, 14, 5, false))
	var row = HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", 4)
	pill.add_child(row)
	row.add_child(resource_icon(key, Vector2(18, 18)))
	var label = UiStyle.label(value, 11, UiStyle.MUTED, false)
	label.name = "Value"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(label)
	return pill

static func stat_bar(value, color := UiStyle.RESOURCE, max_value := 100, min_height := 12):
	var bar = ProgressBar.new()
	bar.max_value = max_value
	bar.value = value
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.custom_minimum_size = Vector2(0, min_height)
	bar.add_theme_stylebox_override("background", UiStyle.panel_style(Color(0.86, 0.91, 0.96), Color(1, 1, 1, 0), 0, int(min_height * 0.5), 0, false))
	bar.add_theme_stylebox_override("fill", UiStyle.panel_style(color, Color(1, 1, 1, 0), 0, int(min_height * 0.5), 0, false))
	return bar

static func toast_card(text):
	var card = panel(Color(0.06, 0.15, 0.27, 0.9), Color(1, 1, 1, 0), 0, 17, 7)
	card.name = "ToastCard"
	var label = UiStyle.label(text, 14, Color.WHITE, false)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = Vector2(0, 20)
	card.add_child(label)
	return card

static func result_card(title, body, color := UiStyle.REWARD):
	var card = panel(Color(1, 1, 1, 0.94), UiStyle.INK, 2, 18, 7)
	card.name = "ResultCard"
	var box = HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(box)
	var badge = tag_chip(title, color, UiStyle.INK)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(badge)
	var copy = UiStyle.label(body, 13, UiStyle.INK, false)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.autowrap_mode = TextServer.AUTOWRAP_OFF
	copy.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	copy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	copy.custom_minimum_size = Vector2(120, 24)
	box.add_child(copy)
	return card

static func _pixel_rect(canvas, rect, fill, stroke := Color(0, 0, 0, 0), stroke_width := 0.0):
	var clean = Rect2(rect.position.round(), rect.size.round())
	if fill.a > 0.0:
		canvas.draw_rect(clean, fill, true)
	if stroke.a > 0.0 and stroke_width > 0.0:
		canvas.draw_rect(clean, stroke, false, max(1.0, round(stroke_width)))
