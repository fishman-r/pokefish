extends Control
class_name PartnerFloat

const FishArt = preload("res://godot/scripts/ui/fish_art.gd")

signal details_pressed

var name_label
var meta_label
var output_label
var badge_label
var mood_bar
var icon
var details_hit_button
var current_fish = {}

func _ready():
	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	anchor_left = 0.0
	anchor_top = 1.0
	anchor_right = 0.0
	anchor_bottom = 1.0
	offset_left = safe["left"] + 10
	offset_right = safe["left"] + 194
	offset_top = -164 - safe["bottom"]
	offset_bottom = -110 - safe["bottom"]
	mouse_filter = Control.MOUSE_FILTER_STOP

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.62), UiStyle.INK, 1, 18, 6, false))
	add_child(panel)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	panel.add_child(row)

	icon = _fish_icon()
	row.add_child(icon)

	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)
	row.add_child(box)

	name_label = UiStyle.label("伙伴", 14, UiStyle.INK, true)
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(name_label)

	var meta = HBoxContainer.new()
	meta.add_theme_constant_override("separation", 2)
	box.add_child(meta)
	badge_label = UiStyle.label("C", 11, Color.WHITE, false)
	var badge = PanelContainer.new()
	badge.add_theme_stylebox_override("panel", UiStyle.panel_style(UiStyle.RESOURCE, UiStyle.INK, 1, 9, 2, false))
	badge.add_child(badge_label)
	meta.add_child(badge)
	meta_label = UiStyle.label("Lv.1", 11, UiStyle.MUTED, false)
	meta_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	meta_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	meta.add_child(meta_label)
	meta.add_child(_output_chip())

	mood_bar = ProgressBar.new()
	mood_bar.show_percentage = false
	mood_bar.max_value = 100
	mood_bar.custom_minimum_size = Vector2(0, 5)
	mood_bar.add_theme_stylebox_override("background", UiStyle.panel_style(Color(0.85, 0.91, 0.96), Color(1, 1, 1, 0), 0, 4, 0, false))
	mood_bar.add_theme_stylebox_override("fill", UiStyle.panel_style(UiStyle.GROWTH, Color(1, 1, 1, 0), 0, 4, 0, false))
	box.add_child(mood_bar)

	details_hit_button = Button.new()
	details_hit_button.name = "PartnerDetailsHitButton"
	details_hit_button.text = ""
	details_hit_button.tooltip_text = "伙伴详情"
	details_hit_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	details_hit_button.focus_mode = Control.FOCUS_NONE
	details_hit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	for key in ["normal", "hover", "pressed", "focus", "disabled"]:
		details_hit_button.add_theme_stylebox_override(key, StyleBoxEmpty.new())
	details_hit_button.pressed.connect(func(): details_pressed.emit())
	add_child(details_hit_button)

func update_fish(fish):
	if fish == null or fish.is_empty():
		visible = false
		return
	visible = true
	current_fish = fish
	if icon != null:
		icon.queue_redraw()
	name_label.text = fish.get("name", "伙伴")
	var level = int(round(float(fish.get("level", 1))))
	meta_label.text = "Lv.%s" % level
	output_label.text = "+%s" % fish.get("output", 0)
	badge_label.text = UiStyle.rarity_short(fish.get("rarity", "common"))
	mood_bar.value = int(fish.get("mood", 0))

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		details_pressed.emit()
	elif event is InputEventScreenTouch and event.pressed:
		details_pressed.emit()

func _fish_icon():
	var node = Control.new()
	node.custom_minimum_size = Vector2(40, 40)
	node.draw.connect(func():
		var center = node.size * 0.5
		var rarity = current_fish.get("rarity", "common")
		node.draw_circle(center, 18, UiStyle.rarity_color(rarity).lightened(0.18))
		node.draw_arc(center, 18, 0, TAU, 40, UiStyle.INK, 1.8)
		_draw_preview_fish(node, center, current_fish)
	)
	return node

func _output_chip():
	var panel = PanelContainer.new()
	panel.tooltip_text = "每分钟收益"
	panel.custom_minimum_size = Vector2(46, 18)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.56), Color(1, 1, 1, 0), 0, 12, 4, false))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	panel.add_child(row)
	row.add_child(UiComponents.resource_icon("bubbleCoins", Vector2(15, 15)))
	output_label = UiStyle.label("+0", 11, UiStyle.MUTED, false)
	output_label.name = "OutputValue"
	output_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	output_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	output_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	output_label.custom_minimum_size = Vector2(22, 0)
	row.add_child(output_label)
	return panel

func _draw_preview_fish(canvas, center, fish):
	FishArt.draw(canvas, fish, center, Vector2(35, 27), 1, false)
	return
	var app = fish.get("appearance", {})
	var body = _html_color(app.get("bodyColor", "#58b7d8"))
	var fin = _html_color(app.get("finColor", "#7fd8b7"))
	var accent = _html_color(app.get("accentColor", "#ffffff"))
	var line = UiStyle.INK
	var tail = PackedVector2Array([
		center + Vector2(-14, 1),
		center + Vector2(-28, -10),
		center + Vector2(-24, 1),
		center + Vector2(-28, 12),
	])
	canvas.draw_colored_polygon(tail, fin.lightened(0.08))
	var tail_closed = PackedVector2Array(tail)
	tail_closed.append(tail[0])
	canvas.draw_polyline(tail_closed, line, 1.8, true)
	var body_size = Vector2(17, 10)
	if app.get("body", "oval") == "round":
		body_size = Vector2(15, 13)
	elif app.get("body", "oval") == "slender":
		body_size = Vector2(22, 8)
	_draw_ellipse(canvas, center + Vector2(3, 0), body_size, body, line, 2.0)
	for i in range(3):
		canvas.draw_circle(center + Vector2(-5 + i * 6, sin(i) * 3), 1.8, accent)
	var eye = center + Vector2(15, -4)
	canvas.draw_circle(eye, 3.2, Color.WHITE)
	canvas.draw_circle(eye + Vector2(0.8, 0.5), 1.35, line)

func _draw_ellipse(canvas, center, radii, fill, stroke, stroke_width):
	canvas.draw_set_transform(center, 0.0, radii)
	canvas.draw_circle(Vector2.ZERO, 1.0, fill)
	if stroke_width > 0.0:
		canvas.draw_arc(Vector2.ZERO, 1.0, 0, TAU, 32, stroke, stroke_width / max(1.0, max(radii.x, radii.y)), true)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _html_color(hex):
	return Color.html(str(hex).replace("#", ""))
