extends Control
class_name ModeDock

signal mode_selected(mode_id)

const ITEMS = [
	["hatchery", "孵化"],
	["dex", "图鉴"],
	["adventure", "远行"],
	["quests", "目标"],
]

var buttons = {}
var current_mode = "pond"
var expanded = false
var tray
var menu_button

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_tray()
	_build_menu_button()
	_apply_offsets()
	_update_buttons()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_apply_offsets()

func _build_tray():
	tray = PanelContainer.new()
	tray.name = "ModuleTray"
	tray.visible = false
	tray.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.92), UiStyle.INK, 2, 22, 6))
	add_child(tray)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	tray.add_child(row)

	for item in ITEMS:
		var button = _mode_button(item[0], item[1], false)
		button.pressed.connect(Callable(self, "_press_mode").bind(item[0]))
		buttons[item[0]] = {"button": button, "label": item[1]}
		row.add_child(button)

func _build_menu_button():
	menu_button = _mode_button("pond", "模块", true)
	menu_button.name = "ModuleMenuButton"
	menu_button.tooltip_text = "模块"
	menu_button.pressed.connect(_press_menu_button)
	buttons["pond"] = {"button": menu_button, "label": "模块"}
	add_child(menu_button)

func _mode_button(mode_id, label_text, is_menu):
	var button = Button.new()
	button.text = ""
	button.tooltip_text = label_text
	button.set_meta("pokefish_mode_id", mode_id)
	button.set_meta("pokefish_mode_label", label_text)
	button.custom_minimum_size = Vector2(68 if is_menu else 0, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(button, UiStyle.module_color("menu" if is_menu else mode_id), UiStyle.CONFIRM, true)
	UiComponents.attach_press_feedback(button, 0.94 if is_menu else 0.95)

	var icon_kind = "menu" if is_menu else mode_id
	var icon = UiComponents.mode_icon(icon_kind, Vector2(28 if is_menu else 25, 28 if is_menu else 25))
	icon.anchor_left = 0.5
	icon.anchor_top = 0.0
	icon.anchor_right = 0.5
	icon.anchor_bottom = 0.0
	icon.offset_left = -14 if is_menu else -12.5
	icon.offset_top = 6 if is_menu else 4
	icon.offset_right = 14 if is_menu else 12.5
	icon.offset_bottom = 34 if is_menu else 29
	button.add_child(icon)

	var label = UiStyle.label(label_text, 12 if is_menu else 11, UiStyle.INK, true)
	label.name = "ModeLabel"
	label.anchor_left = 0.0
	label.anchor_top = 1.0
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = 2
	label.offset_top = -21 if is_menu else -19
	label.offset_right = -2
	label.offset_bottom = -2
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)
	return button

func set_mode(mode_id):
	current_mode = mode_id
	if mode_id != "pond":
		expanded = false
	_apply_offsets()
	_update_buttons()

func close_menu():
	expanded = false
	_apply_offsets()
	_update_buttons()

func _press_menu_button():
	if current_mode != "pond":
		_press_mode("pond")
		return
	expanded = not expanded
	_apply_offsets()
	_update_buttons()
	if expanded:
		_animate_tray_open()

func _press_mode(mode_id):
	current_mode = mode_id
	expanded = false
	_apply_offsets()
	_update_buttons()
	mode_selected.emit(mode_id)

func _apply_offsets():
	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	anchor_top = 1.0
	anchor_bottom = 1.0
	if expanded:
		anchor_left = 0.0
		anchor_right = 1.0
		offset_left = 0.0
		offset_right = 0.0
		offset_top = -176 - safe["bottom"]
		offset_bottom = -10 - safe["bottom"]
	else:
		anchor_left = 1.0
		anchor_right = 1.0
		offset_left = -safe["right"] - 76
		offset_right = -safe["right"] - 8
		offset_top = -92 - safe["bottom"]
		offset_bottom = -10 - safe["bottom"]

	if menu_button != null:
		menu_button.anchor_left = 1.0
		menu_button.anchor_top = 1.0
		menu_button.anchor_right = 1.0
		menu_button.anchor_bottom = 1.0
		menu_button.offset_left = -68
		menu_button.offset_top = -72
		menu_button.offset_right = 0
		menu_button.offset_bottom = 0

	if tray != null:
		tray.anchor_left = 0.0
		tray.anchor_top = 0.0
		tray.anchor_right = 1.0
		tray.anchor_bottom = 0.0
		tray.offset_left = safe["left"] + 10
		tray.offset_top = 0
		tray.offset_right = -safe["right"] - 86
		tray.offset_bottom = 76
		tray.visible = expanded

func _animate_tray_open():
	if tray == null:
		return
	tray.pivot_offset = Vector2(tray.size.x, tray.size.y)
	tray.scale = Vector2(0.94, 0.94)
	tray.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(tray, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _update_buttons():
	for key in buttons.keys():
		var item = buttons[key]
		var button = item["button"]
		var active = key == current_mode
		var label_text = item["label"]
		if key == "pond":
			label_text = "水域" if current_mode != "pond" else "模块"
			button.tooltip_text = "返回水域" if current_mode != "pond" else "模块"
			var icon = button.find_child("ModeIcon", true, false)
			if icon != null:
				icon.set_meta("kind", "pond" if current_mode != "pond" else "menu")
		var icon = button.find_child("ModeIcon", true, false)
		if icon != null:
			icon.set_meta("active", active or (key == "pond" and expanded))
			icon.queue_redraw()
		var label = button.find_child("ModeLabel", true, false)
		if label != null:
			label.text = label_text
		var visual_key = "pond" if key == "pond" and current_mode != "pond" else ("menu" if key == "pond" else key)
		var bg = UiStyle.module_color(visual_key, active or (key == "pond" and expanded))
		button.add_theme_stylebox_override("normal", UiStyle.panel_style(bg, UiStyle.INK, 2, 18, 2, false))
		button.add_theme_stylebox_override("pressed", UiStyle.panel_style(UiStyle.CONFIRM, UiStyle.INK, 2, 18, 2, false))
		button.add_theme_stylebox_override("hover", UiStyle.panel_style(bg.lightened(0.04), UiStyle.INK, 2, 18, 2, false))
