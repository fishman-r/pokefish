extends Control
class_name ResourceHud

const GameData = preload("res://godot/scripts/game_data.gd")

signal menu_pressed

var pond_label
var rate_label
var primary_resource_label
var resource_labels = {}

func _ready():
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	offset_left = safe["left"] + 8
	offset_top = safe["top"] + 6
	offset_right = -safe["right"] - 8
	offset_bottom = safe["top"] + 68
	mouse_filter = Control.MOUSE_FILTER_PASS

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.58), UiStyle.INK, 1, 20, 6, false))
	add_child(panel)

	var top = HBoxContainer.new()
	top.add_theme_constant_override("separation", 5)
	top.custom_minimum_size = Vector2(0, 42)
	panel.add_child(top)

	var level = _chip("Lv.7", UiStyle.SELECTED, UiStyle.INK)
	top.add_child(level)

	pond_label = UiStyle.label("水域", 18, UiStyle.INK, true)
	pond_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	pond_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	pond_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pond_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top.add_child(pond_label)

	var primary = _primary_resource_chip()
	top.add_child(primary)

	var rate_chip = _rate_chip()
	top.add_child(rate_chip)

	var menu = Button.new()
	menu.text = ""
	menu.tooltip_text = "菜单"
	menu.custom_minimum_size = Vector2(44, 44)
	UiStyle.apply_button(menu, Color(1, 1, 1, 0.62), UiStyle.CONFIRM, true)
	menu.add_theme_stylebox_override("normal", UiStyle.panel_style(Color(1, 1, 1, 0.48), UiStyle.INK, 2, 17, 4, false))
	menu.add_theme_stylebox_override("hover", UiStyle.panel_style(Color(1, 1, 1, 0.58), UiStyle.INK, 2, 17, 4, false))
	menu.add_theme_stylebox_override("pressed", UiStyle.panel_style(UiStyle.CONFIRM, UiStyle.INK, 2, 17, 4, false))
	UiComponents.attach_press_feedback(menu, 0.94)
	var menu_icon = UiComponents.menu_icon(Vector2(24, 24))
	menu_icon.anchor_left = 0.5
	menu_icon.anchor_top = 0.5
	menu_icon.anchor_right = 0.5
	menu_icon.anchor_bottom = 0.5
	menu_icon.offset_left = -12
	menu_icon.offset_top = -12
	menu_icon.offset_right = 12
	menu_icon.offset_bottom = 12
	menu.add_child(menu_icon)
	menu.pressed.connect(func(): menu_pressed.emit())
	top.add_child(menu)

func update_view(resources, pond_name, idle_rate):
	if pond_label != null:
		pond_label.text = pond_name
	if rate_label != null:
		rate_label.text = "+%s" % _format_number(idle_rate)
	if primary_resource_label != null:
		primary_resource_label.text = _format_number(resources.get("bubbleCoins", 0))
	for key in resource_labels.keys():
		resource_labels[key].text = _format_number(resources.get(key, 0))

func _resource_pill(key):
	var panel = UiComponents.resource_pill(key, 0)
	resource_labels[key] = panel.get_node("Row/Value")
	return panel

func _primary_resource_chip():
	var panel = PanelContainer.new()
	panel.tooltip_text = "泡泡币"
	panel.custom_minimum_size = Vector2(58, 32)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.48), Color(1, 1, 1, 0), 0, 14, 4, false))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	panel.add_child(row)
	row.add_child(UiComponents.resource_icon("bubbleCoins", Vector2(19, 19)))
	primary_resource_label = UiStyle.label("0", 12, UiStyle.MUTED, false)
	primary_resource_label.name = "PrimaryResourceValue"
	primary_resource_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	primary_resource_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	primary_resource_label.custom_minimum_size = Vector2(30, 20)
	primary_resource_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(primary_resource_label)
	return panel

func _rate_chip():
	var panel = PanelContainer.new()
	panel.tooltip_text = "每分钟收益"
	panel.custom_minimum_size = Vector2(52, 32)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.54), Color(1, 1, 1, 0), 0, 15, 5, false))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	panel.add_child(row)
	row.add_child(UiComponents.resource_icon("bubbleCoins", Vector2(20, 20)))
	rate_label = UiStyle.label("+0", 12, UiStyle.MUTED, false)
	rate_label.name = "IdleRateValue"
	rate_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	rate_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	rate_label.custom_minimum_size = Vector2(28, 22)
	rate_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(rate_label)
	return panel

func _chip(text, bg, color):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(50, 38)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(bg, UiStyle.INK, 1, 13, 4, false))
	var label = UiStyle.label(text, 12, color, false)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return panel

func _format_number(value):
	return str(int(round(float(value))))
