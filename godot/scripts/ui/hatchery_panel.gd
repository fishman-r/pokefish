extends Control
class_name HatcheryPanel

const GameData = preload("res://godot/scripts/game_data.gd")
const MIN_TOUCH_SCROLL_HEIGHT = 430.0

signal hatch_requested(slot_index)
signal buy_requested(item_id)

var controller
var egg_label
var slots_box
var shop_box
var content_scroll
var content_box

func _ready():
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(0, MIN_TOUCH_SCROLL_HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll = ScrollContainer.new()
	content_scroll.name = "HatcheryScroll"
	content_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.custom_minimum_size = Vector2(0, MIN_TOUCH_SCROLL_HEIGHT)
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(content_scroll)

	var box = VBoxContainer.new()
	box.name = "HatcheryContent"
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	content_scroll.add_child(box)
	content_box = box

	var header = PanelContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.mouse_filter = Control.MOUSE_FILTER_PASS
	header.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1.0, 0.97, 0.86, 0.78), UiStyle.EGG, 1, 16, 7, false))
	box.add_child(header)
	var header_row = HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 8)
	header.add_child(header_row)
	header_row.add_child(_egg_icon(Vector2(42, 42), UiStyle.EGG))
	var header_copy = VBoxContainer.new()
	header_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_copy.add_theme_constant_override("separation", 1)
	header_row.add_child(header_copy)
	header_copy.add_child(UiStyle.label("孵化台", 20, UiStyle.INK, true))
	egg_label = UiStyle.label("鱼蛋 x0", 13, UiStyle.MUTED, false)
	egg_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	egg_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header_copy.add_child(egg_label)

	var incubator = PanelContainer.new()
	incubator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	incubator.mouse_filter = Control.MOUSE_FILTER_PASS
	incubator.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.92, 0.98, 1.0, 0.66), UiStyle.RESOURCE, 1, 18, 8, false))
	box.add_child(incubator)
	var incubator_box = VBoxContainer.new()
	incubator_box.add_theme_constant_override("separation", 6)
	incubator.add_child(incubator_box)
	var rail = Control.new()
	rail.custom_minimum_size = Vector2(0, 18)
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rail.draw.connect(func():
		var y = rail.size.y * 0.5
		rail.draw_line(Vector2(18, y), Vector2(max(18.0, rail.size.x - 18.0), y), Color(UiStyle.RESOURCE.r, UiStyle.RESOURCE.g, UiStyle.RESOURCE.b, 0.46), 4.0, true)
		for x in range(28, int(max(29.0, rail.size.x - 20.0)), 42):
			rail.draw_circle(Vector2(x, y), 4.0, Color(1, 1, 1, 0.78))
			rail.draw_arc(Vector2(x, y), 4.0, 0, TAU, 16, UiStyle.INK, 1.0)
	)
	rail.resized.connect(func(): rail.queue_redraw())
	incubator_box.add_child(rail)

	slots_box = GridContainer.new()
	slots_box.columns = 3
	slots_box.add_theme_constant_override("h_separation", 8)
	slots_box.add_theme_constant_override("v_separation", 8)
	slots_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	incubator_box.add_child(slots_box)

	var shop_title = UiStyle.label("鱼蛋补给", 19, UiStyle.INK, true)
	box.add_child(shop_title)
	var shelf = PanelContainer.new()
	shelf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf.mouse_filter = Control.MOUSE_FILTER_PASS
	shelf.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1.0, 0.96, 0.82, 0.48), UiStyle.EGG, 1, 16, 7, false))
	box.add_child(shelf)
	shop_box = HFlowContainer.new()
	shop_box.add_theme_constant_override("h_separation", 8)
	shop_box.add_theme_constant_override("v_separation", 8)
	shelf.add_child(shop_box)

	if controller != null:
		refresh()
	_refresh_touch_scroll()
	call_deferred("_refresh_touch_scroll")

func _input(event):
	if content_scroll == null or not is_visible_in_tree():
		return
	if UiStyle.handle_drag_scroll_event(content_scroll, event, content_scroll.get_global_rect()):
		get_viewport().set_input_as_handled()

func set_controller(value):
	controller = value
	if is_inside_tree():
		refresh()

func set_panel_viewport_height(height):
	var target_height = max(MIN_TOUCH_SCROLL_HEIGHT, float(height))
	custom_minimum_size = Vector2(0, target_height)
	if content_scroll != null:
		content_scroll.custom_minimum_size = Vector2(0, target_height)
	update_minimum_size()
	_refresh_touch_scroll()

func play_intro():
	var nodes = []
	if slots_box != null:
		for child in slots_box.get_children():
			nodes.append(child)
	if shop_box != null:
		for child in shop_box.get_children():
			nodes.append(child)
	UiComponents.play_staggered_entry(self, nodes, 0.025, 0.95)

func refresh():
	if controller == null:
		return
	var resources = controller.get_resources()
	var egg_inventory = controller.get_egg_inventory() if controller.has_method("get_egg_inventory") else {}
	egg_label.text = _egg_inventory_text(egg_inventory)
	_clear(slots_box)
	_clear(shop_box)

	for index in range(3):
		var is_open = index == 0 or int(resources.get("shells", 0)) >= index * 8
		slots_box.add_child(_slot_card(index, is_open, resources, egg_inventory))

	for item in GameData.shop_items():
		var card = _card(Color(1.0, 0.98, 0.9, 0.84), UiStyle.EGG, 1, 16)
		card.custom_minimum_size = Vector2(150, 64)
		shop_box.add_child(card)
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		card.add_child(row)
		row.add_child(_egg_icon(Vector2(38, 38), UiStyle.EGG))
		var copy = VBoxContainer.new()
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.add_theme_constant_override("separation", 1)
		row.add_child(copy)
		var name = UiStyle.label(item.get("name", "鱼蛋"), 14, UiStyle.INK, true)
		name.autowrap_mode = TextServer.AUTOWRAP_OFF
		name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		copy.add_child(name)
		copy.add_child(UiComponents.reward_row(item.get("cost", {})))
		var buy = Button.new()
		buy.text = "购"
		buy.custom_minimum_size = Vector2(56, 44)
		UiStyle.apply_button(buy, Color(1, 1, 1, 0.88), UiStyle.CONFIRM, true)
		UiComponents.attach_press_feedback(buy, 0.94)
		buy.pressed.connect(_buy_pressed.bind(item.get("id", "")))
		row.add_child(buy)
	_refresh_touch_scroll()
	call_deferred("_refresh_touch_scroll")

func _hatch_pressed(slot_index := 0):
	hatch_requested.emit(slot_index)

func _buy_pressed(item_id):
	buy_requested.emit(item_id)

func _slot_card(index, is_open, resources, egg_inventory):
	var slot_status = controller.get_hatch_slot_status(index) if controller != null and controller.has_method("get_hatch_slot_status") else {}
	var active = bool(slot_status.get("active", false))
	var ready = bool(slot_status.get("ready", false))
	var egg_type = str(slot_status.get("egg_type", _preferred_egg_type(egg_inventory)))
	var card = _card(Color(1, 1, 1, 0.8) if is_open else Color(0.86, 0.9, 0.95, 0.72), UiStyle.INK, 2, 18)
	card.custom_minimum_size = Vector2(0, 132)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)
	var top = HBoxContainer.new()
	top.add_theme_constant_override("separation", 4)
	box.add_child(top)
	top.add_child(_badge(str(index + 1), UiStyle.SELECTED if is_open else Color(0.72, 0.78, 0.84)))
	var status_text = "空槽"
	if not is_open:
		status_text = "锁定"
	elif active and ready:
		status_text = "可领取"
	elif active:
		status_text = "孵化中"
	var status = UiStyle.label(status_text, 13, UiStyle.MUTED if is_open else Color(0.46, 0.52, 0.6), false)
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_OFF
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top.add_child(status)
	var egg_wrap = CenterContainer.new()
	egg_wrap.custom_minimum_size = Vector2(0, 42)
	box.add_child(egg_wrap)
	egg_wrap.add_child(_egg_icon(Vector2(52, 44), _egg_color(egg_type) if is_open else Color(0.68, 0.74, 0.82)))
	box.add_child(_slot_meta(index, is_open, active, ready, egg_type, egg_inventory, slot_status))
	var button = Button.new()
	var has_eggs = int(resources.get("eggs", 0)) > 0
	button.text = "开蛋"
	if active and ready:
		button.text = "领取"
	elif active:
		button.text = _format_remaining(int(slot_status.get("remaining", 0)))
	elif not is_open:
		button.text = "锁"
	elif not has_eggs:
		button.text = "缺蛋"
	button.custom_minimum_size = Vector2(0, 44)
	button.disabled = not is_open or (active and not ready) or (not active and not has_eggs)
	UiStyle.apply_button(button, UiStyle.CONFIRM if is_open else UiStyle.DISABLED, UiStyle.COST, true)
	UiComponents.attach_press_feedback(button, 0.94)
	button.pressed.connect(_hatch_pressed.bind(index))
	box.add_child(button)
	return card

func _slot_meta(index, is_open, active, ready, egg_type, egg_inventory, slot_status):
	var row = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 3)
	row.add_theme_constant_override("v_separation", 3)
	if not is_open:
		row.add_child(UiComponents.resource_badge("shells", index * 8, Color(1, 1, 1, 0.62)))
	elif active and ready:
		row.add_child(UiComponents.tag_chip(_egg_short(egg_type), UiStyle.CONFIRM, UiStyle.INK))
	elif active:
		row.add_child(UiComponents.tag_chip(_egg_short(egg_type), Color(0.86, 0.96, 1.0), UiStyle.MUTED))
	else:
		var next_type = _preferred_egg_type(egg_inventory)
		row.add_child(UiComponents.tag_chip(_egg_short(next_type) if next_type != "" else "无蛋", Color(1.0, 0.98, 0.86), UiStyle.MUTED))
	return row

func _egg_inventory_text(inventory):
	var parts = []
	for egg_type in ["common", "color", "deep"]:
		var count = int(inventory.get(egg_type, 0))
		if count > 0:
			parts.append("%s x%d" % [_egg_short(egg_type), count])
	if parts.is_empty():
		return "鱼蛋 x0"
	return "  ".join(parts)

func _preferred_egg_type(inventory):
	for egg_type in ["deep", "color", "common"]:
		if int(inventory.get(egg_type, 0)) > 0:
			return egg_type
	return ""

func _egg_short(egg_type):
	return GameData.egg_catalog().get(egg_type, {"short": "鱼蛋"}).get("short", "鱼蛋")

func _egg_color(egg_type):
	return {
		"common": UiStyle.EGG,
		"color": UiStyle.REWARD,
		"deep": UiStyle.RESOURCE,
	}.get(egg_type, UiStyle.EGG)

func _format_remaining(seconds):
	var minutes = int(ceil(max(1, seconds) / 60.0))
	if minutes >= 60:
		var hours = int(floor(minutes / 60.0))
		var rest = minutes % 60
		if rest == 0:
			return "%d小时" % hours
		return "%d小时%d分" % [hours, rest]
	return "%d分" % minutes

func _card(bg, border := UiStyle.INK, border_width := 2, radius := 20):
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(bg, border, border_width, radius, 7))
	return panel

func _badge(text, bg):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(44, 44)
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(bg, UiStyle.INK, 2, 18, 6, false))
	var label = UiStyle.label(text, 17, UiStyle.INK, true)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return panel

func _egg_icon(min_size, color):
	var icon = Control.new()
	icon.custom_minimum_size = min_size
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func():
		var center = icon.size * 0.5
		var radius = min(icon.size.x, icon.size.y) * 0.42
		icon.draw_set_transform(center, 0.0, Vector2(radius * 0.72, radius))
		icon.draw_circle(Vector2.ZERO, 1.0, color)
		icon.draw_arc(Vector2.ZERO, 1.0, 0, TAU, 36, UiStyle.INK, 0.12, true)
		icon.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		icon.draw_circle(center + Vector2(-radius * 0.18, -radius * 0.22), radius * 0.13, Color.WHITE)
		icon.draw_line(center + Vector2(-radius * 0.24, radius * 0.02), center + Vector2(-radius * 0.02, -radius * 0.1), UiStyle.INK, 1.2)
		icon.draw_line(center + Vector2(-radius * 0.02, -radius * 0.1), center + Vector2(radius * 0.2, radius * 0.02), UiStyle.INK, 1.2)
	)
	icon.resized.connect(func(): icon.queue_redraw())
	return icon

func _clear(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _refresh_touch_scroll():
	if content_scroll != null and content_box != null:
		UiStyle.configure_touch_scroll(content_scroll, content_box)
