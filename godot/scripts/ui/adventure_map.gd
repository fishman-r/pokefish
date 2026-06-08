extends Control
class_name AdventureMap

const GameData = preload("res://godot/scripts/game_data.gd")

signal route_requested(route_id)

var controller
var partner_label
var route_box
var route_paths = []

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	var partner_card = PanelContainer.new()
	partner_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	partner_card.custom_minimum_size = Vector2(0, 58)
	partner_card.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.72), UiStyle.WATER_DARK, 1, 18, 8, false))
	box.add_child(partner_card)
	partner_label = UiStyle.label("伙伴", 17, UiStyle.INK, true)
	partner_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	partner_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	partner_label.custom_minimum_size = Vector2(220, 30)
	partner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	partner_card.add_child(partner_label)

	route_box = Control.new()
	route_box.custom_minimum_size = Vector2(0, 390)
	route_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	route_box.draw.connect(_draw_routes)
	route_box.resized.connect(func(): route_box.queue_redraw())
	box.add_child(route_box)

	if controller != null:
		refresh()

func set_controller(value):
	controller = value
	if is_inside_tree():
		refresh()

func play_intro():
	if route_box == null:
		return
	UiComponents.play_staggered_entry(self, route_box.get_children(), 0.04, 0.94)

func refresh():
	if controller == null:
		return
	_clear(route_box)
	var fish = controller.get_selected_fish()
	if fish.is_empty():
		partner_label.text = "请选择伙伴"
	else:
		var level = int(round(float(fish.get("level", 1))))
		partner_label.text = "%s  Lv.%s  %s" % [fish.get("name", "伙伴"), level, fish.get("speciesName", "鱼")]
	var trait_ids = []
	for trait_data in fish.get("traits", []):
		trait_ids.append(trait_data.get("id", ""))

	for index in range(GameData.explore_routes().size()):
		var route = GameData.explore_routes()[index]
		var status = {}
		if controller != null and controller.has_method("get_explore_status"):
			status = controller.get_explore_status(route.get("id", ""))
		var bonus = false
		for trait_id in route.get("trait_bonus", []):
			if trait_ids.has(trait_id):
				bonus = true
				break
		var card = Button.new()
		card.text = ""
		card.tooltip_text = route.get("name", "路线")
		card.anchor_left = 0.0
		card.anchor_right = 0.0
		var node_pos = _route_node_position(index, Vector2(330, 390))
		card.offset_left = node_pos.x - 72
		card.offset_right = node_pos.x + 72
		card.offset_top = node_pos.y - 64
		card.offset_bottom = node_pos.y + 64
		card.pivot_offset = Vector2(72, 64)
		var bg = Color(0.9, 1.0, 0.91, 0.9) if bonus else Color(1, 1, 1, 0.78)
		if bool(status.get("is_active", false)) and bool(status.get("ready", false)):
			bg = Color(0.82, 1.0, 0.72, 0.94)
		elif bool(status.get("is_active", false)):
			bg = Color(0.88, 0.96, 1.0, 0.9)
		elif bool(status.get("has_active", false)):
			bg = Color(0.92, 0.94, 0.96, 0.72)
		UiStyle.apply_button(card, bg, UiStyle.CONFIRM, true)
		card.add_theme_stylebox_override("normal", UiStyle.panel_style(bg, UiStyle.INK, 2, 28, 7, false))
		card.add_theme_stylebox_override("hover", UiStyle.panel_style(bg.lightened(0.04), UiStyle.INK, 2, 28, 7, false))
		card.add_theme_stylebox_override("pressed", UiStyle.panel_style(UiStyle.CONFIRM, UiStyle.INK, 2, 28, 7, false))
		card.pressed.connect(_route_pressed.bind(route.get("id", ""), card))
		route_box.add_child(card)
		card.scale = Vector2(0.92, 0.92)
		card.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(index * 0.045)
		tween.tween_property(card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var margin = MarginContainer.new()
		margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 7)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_right", 7)
		margin.add_theme_constant_override("margin_bottom", 6)
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(margin)
		var copy = VBoxContainer.new()
		copy.add_theme_constant_override("separation", 3)
		copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.add_child(copy)
		var top = HBoxContainer.new()
		top.add_theme_constant_override("separation", 5)
		top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		copy.add_child(top)
		top.add_child(_node_badge(str(index + 1), UiStyle.SUCCESS if bonus else UiStyle.RESOURCE))
		var title = UiStyle.label(route.get("name", "路线"), 15, UiStyle.INK, true)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.autowrap_mode = TextServer.AUTOWRAP_OFF
		title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		top.add_child(title)
		copy.add_child(_route_meta(route, status))
	route_box.queue_redraw()

func _route_pressed(route_id, card):
	var tween = create_tween()
	tween.tween_property(card, "scale", Vector2(1.04, 1.04), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	route_requested.emit(route_id)

func _draw_routes():
	var width = max(260.0, route_box.size.x)
	var map_size = Vector2(width, max(320.0, route_box.size.y))
	_draw_map_backdrop(map_size)
	var points = PackedVector2Array()
	for index in range(GameData.explore_routes().size()):
		points.append(_route_node_position(index, map_size))
	if points.size() >= 2:
		route_box.draw_polyline(points, Color(UiStyle.RESOURCE.r, UiStyle.RESOURCE.g, UiStyle.RESOURCE.b, 0.42), 8.0, true)
		route_box.draw_polyline(points, Color(1.0, 1.0, 1.0, 0.48), 2.0, true)
		for i in range(points.size() - 1):
			var a = points[i]
			var b = points[i + 1]
			for step in range(1, 4):
				var t = float(step) / 4.0
				var p = a.lerp(b, t) + Vector2(sin(Time.get_ticks_msec() / 700.0 + step + i) * 4.0, 0)
				route_box.draw_circle(p, 3.0, Color(1, 1, 1, 0.55))
	for point in points:
		route_box.draw_circle(point, 8, UiStyle.REWARD)
		route_box.draw_arc(point, 8, 0, TAU, 24, UiStyle.INK, 2.0)

func _route_node_position(index, map_size):
	var points = [
		Vector2(map_size.x * 0.34, 68),
		Vector2(map_size.x * 0.7, 178),
		Vector2(map_size.x * 0.42, 292),
	]
	return points[index % points.size()]

func _draw_map_backdrop(map_size):
	var island_a = PackedVector2Array([
		Vector2(map_size.x * 0.08, map_size.y * 0.66),
		Vector2(map_size.x * 0.26, map_size.y * 0.56),
		Vector2(map_size.x * 0.43, map_size.y * 0.7),
		Vector2(map_size.x * 0.32, map_size.y * 0.82),
		Vector2(map_size.x * 0.12, map_size.y * 0.78),
	])
	route_box.draw_colored_polygon(island_a, Color(0.54, 0.83, 0.76, 0.28))
	var island_b = PackedVector2Array([
		Vector2(map_size.x * 0.58, map_size.y * 0.18),
		Vector2(map_size.x * 0.78, map_size.y * 0.12),
		Vector2(map_size.x * 0.92, map_size.y * 0.25),
		Vector2(map_size.x * 0.82, map_size.y * 0.38),
		Vector2(map_size.x * 0.62, map_size.y * 0.34),
	])
	route_box.draw_colored_polygon(island_b, Color(1.0, 0.84, 0.22, 0.14))
	for i in range(4):
		var y = map_size.y * (0.18 + i * 0.16)
		var points = PackedVector2Array()
		for x in range(-20, int(map_size.x) + 40, 26):
			points.append(Vector2(x, y + sin(x * 0.035 + Time.get_ticks_msec() / 900.0 + i) * 5.0))
		route_box.draw_polyline(points, Color(0.18, 0.72, 0.94, 0.14), 2.0, true)

func _node_badge(text, color):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(40, 44)
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(color, UiStyle.INK, 2, 22, 5, false))
	var label = UiStyle.label(text, 17, UiStyle.INK, true)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return panel

func _route_meta(route, status := {}):
	var row = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 3)
	row.add_theme_constant_override("v_separation", 3)
	row.custom_minimum_size = Vector2(0, 40)
	if bool(status.get("is_active", false)) and bool(status.get("ready", false)):
		row.add_child(UiComponents.tag_chip("可领取", UiStyle.CONFIRM, UiStyle.INK))
	elif bool(status.get("is_active", false)):
		row.add_child(UiComponents.tag_chip(_format_remaining(int(status.get("remaining", 0))), Color(0.86, 0.96, 1.0), UiStyle.MUTED))
	elif bool(status.get("has_active", false)):
		row.add_child(UiComponents.tag_chip("等待", Color(0.92, 0.94, 0.96), UiStyle.MUTED))
	else:
		row.add_child(UiComponents.tag_chip(route.get("time", ""), Color(1, 1, 1, 0.62), UiStyle.MUTED))
	var rewards = route.get("rewards", {})
	var added = 0
	for key in rewards.keys():
		if added >= 2:
			break
		row.add_child(UiComponents.resource_badge(key, rewards[key], Color(1, 1, 1, 0.6)))
		added += 1
	return row

func _format_remaining(seconds):
	var minutes = int(ceil(max(1, seconds) / 60.0))
	if minutes >= 60:
		var hours = int(floor(minutes / 60.0))
		var rest = minutes % 60
		if rest == 0:
			return "%d小时" % hours
		return "%d小时%d分" % [hours, rest]
	return "%d分钟" % minutes

func _clear(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
