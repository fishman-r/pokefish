extends Control
class_name ActionDock

signal feed_pressed
signal collect_pressed
signal evolve_pressed

var action_buttons = {}

func _ready():
	set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	offset_left = safe["left"] + 10
	offset_right = -safe["right"] - 88
	offset_top = -92 - safe["bottom"]
	offset_bottom = -10 - safe["bottom"]
	mouse_filter = Control.MOUSE_FILTER_PASS

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.72), UiStyle.INK, 2, 22, 7, false))
	add_child(panel)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	panel.add_child(row)

	var feed = _button("feed", "投喂", UiStyle.action_color("feed"), UiStyle.action_pressed_color("feed"))
	feed.pressed.connect(func(): feed_pressed.emit())
	row.add_child(feed)

	var collect = _button("collect", "收取", UiStyle.action_color("collect"), UiStyle.action_pressed_color("collect"))
	collect.pressed.connect(func(): collect_pressed.emit())
	row.add_child(collect)

	var evolve = _button("evolve", "进化", UiStyle.action_color("evolve"), UiStyle.action_pressed_color("evolve"))
	evolve.pressed.connect(func(): evolve_pressed.emit())
	row.add_child(evolve)
	update_action_state(true, true, 0)

func _button(kind, text, bg, pressed_bg):
	var button = Button.new()
	button.text = ""
	button.tooltip_text = text
	button.set_meta("pokefish_action_kind", kind)
	button.set_meta("pokefish_action_label", text)
	button.set_meta("pokefish_action_bg", bg)
	button.set_meta("pokefish_action_pressed_bg", pressed_bg)
	button.custom_minimum_size = Vector2(0, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.apply_button(button, bg, pressed_bg, true)
	var icon = UiComponents.action_icon(kind, Vector2(30, 30))
	icon.anchor_left = 0.5
	icon.anchor_top = 0.0
	icon.anchor_right = 0.5
	icon.anchor_bottom = 0.0
	icon.offset_left = -15
	icon.offset_top = 5
	icon.offset_right = 15
	icon.offset_bottom = 35
	button.add_child(icon)
	var label = UiStyle.label(text, 17, UiStyle.INK, true)
	label.name = "ActionLabel"
	label.anchor_left = 0.0
	label.anchor_top = 1.0
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = 4
	label.offset_top = -24
	label.offset_right = -4
	label.offset_bottom = -3
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)
	button.resized.connect(func(): button.pivot_offset = button.size * 0.5)
	button.button_down.connect(_press_feedback.bind(button))
	button.button_up.connect(_release_feedback.bind(button))
	action_buttons[kind] = button
	return button

func update_action_state(has_fish, collect_ready, evolution_percent):
	_apply_action_visual("feed", 0.86 if has_fish else 0.46, has_fish)
	_apply_action_visual("collect", 1.0 if collect_ready else 0.54, collect_ready)
	var evolve_ready = has_fish and int(evolution_percent) >= 18
	_apply_action_visual("evolve", 1.0 if evolve_ready else (0.62 if has_fish else 0.42), evolve_ready)

func set_actions_enabled(enabled):
	for button in find_children("*", "Button", true, false):
		button.disabled = not enabled

func _apply_action_visual(kind, strength, prominent):
	if not action_buttons.has(kind):
		return
	var button = action_buttons[kind]
	var base = button.get_meta("pokefish_action_bg", UiStyle.CONFIRM)
	var pressed = button.get_meta("pokefish_action_pressed_bg", UiStyle.COST)
	var bg = base.lerp(Color(1, 1, 1, 0.9), 0.34 * (1.0 - strength))
	bg.a = 0.88 + 0.1 * strength
	var border_width = 3 if prominent else 2
	var radius = 18 if prominent else 16
	var styles = {
		"normal": UiStyle.panel_style(bg, UiStyle.INK, border_width, radius, 7, prominent),
		"hover": UiStyle.panel_style(bg.lightened(0.04), UiStyle.INK, border_width, radius, 7, prominent),
		"pressed": UiStyle.panel_style(pressed, UiStyle.INK, 3, radius, 7, true),
		"disabled": UiStyle.panel_style(UiStyle.DISABLED, UiStyle.INK, 2, radius, 7, false),
	}
	for key in styles.keys():
		button.add_theme_stylebox_override(key, styles[key])
	button.modulate = Color(1, 1, 1, 0.72 + 0.28 * strength)

func _press_feedback(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.96, 0.96), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _release_feedback(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
