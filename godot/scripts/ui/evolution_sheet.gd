extends Control
class_name EvolutionSheet

const FishArt = preload("res://godot/scripts/ui/fish_art.gd")

signal confirmed

var title_label
var chance_label
var chance_bar
var condition_box
var preview_icon
var current_fish = {}

func _ready():
	custom_minimum_size = Vector2(0, 330)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation", 10)
	add_child(box)

	var grab = CenterContainer.new()
	var bar = ColorRect.new()
	bar.color = Color(0.7, 0.77, 0.84)
	bar.custom_minimum_size = Vector2(72, 5)
	grab.add_child(bar)
	box.add_child(grab)

	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	box.add_child(title_row)
	preview_icon = _preview_icon()
	title_row.add_child(preview_icon)
	var title_box = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 2)
	title_row.add_child(title_box)
	title_label = UiStyle.label("进化", 24, UiStyle.INK, true)
	title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_box.add_child(title_label)
	title_box.add_child(UiStyle.label("形态共鸣", 13, UiStyle.MUTED, false))

	var chance_panel = PanelContainer.new()
	chance_panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.78), UiStyle.INK, 2, 18, 10))
	box.add_child(chance_panel)
	var chance_row = HBoxContainer.new()
	chance_row.add_theme_constant_override("separation", 10)
	chance_panel.add_child(chance_row)
	var chance_title = UiStyle.label("概率", 14, UiStyle.MUTED, false)
	chance_title.custom_minimum_size = Vector2(38, 0)
	chance_title.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	chance_title.autowrap_mode = TextServer.AUTOWRAP_OFF
	chance_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	chance_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chance_row.add_child(chance_title)
	chance_bar = UiComponents.stat_bar(0, UiStyle.CONFIRM, 100, 14)
	chance_row.add_child(chance_bar)
	chance_label = UiStyle.label("0%", 16, UiStyle.INK, true)
	chance_label.custom_minimum_size = Vector2(48, 0)
	chance_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	chance_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	chance_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	chance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	chance_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chance_row.add_child(chance_label)

	condition_box = HFlowContainer.new()
	condition_box.add_theme_constant_override("h_separation", 6)
	condition_box.add_theme_constant_override("v_separation", 6)
	box.add_child(condition_box)

	var confirm = Button.new()
	confirm.text = "开始共鸣"
	confirm.custom_minimum_size = Vector2(0, 48)
	UiStyle.apply_button(confirm, UiStyle.GROWTH, UiStyle.CONFIRM, true)
	UiComponents.attach_press_feedback(confirm, 0.96)
	confirm.pressed.connect(_confirm)
	box.add_child(confirm)

func _confirm():
	confirmed.emit()

func update_preview(fish, result):
	if fish == null or fish.is_empty() or result == null or result.is_empty():
		return
	current_fish = fish
	if preview_icon != null:
		preview_icon.queue_redraw()
	title_label.text = "%s" % fish.get("name", "伙伴")
	var percent = int(round(float(result.get("chance", 0.0)) * 100.0))
	chance_bar.value = percent
	chance_label.text = "%d%%" % percent
	for child in condition_box.get_children():
		condition_box.remove_child(child)
		child.queue_free()
	for condition in result.get("conditions", []).slice(0, 4):
		condition_box.add_child(UiComponents.tag_chip(condition.get("label", "")))

func _preview_icon():
	var icon = Control.new()
	icon.custom_minimum_size = Vector2(78, 66)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func():
		var center = icon.size * 0.5
		var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 260.0)
		icon.draw_circle(center, 30 + pulse * 4.0, Color(UiStyle.CONFIRM.r, UiStyle.CONFIRM.g, UiStyle.CONFIRM.b, 0.18))
		icon.draw_arc(center, 30 + pulse * 4.0, 0, TAU, 38, UiStyle.CONFIRM, 2.0)
		_draw_preview_fish(icon, center, current_fish)
	)
	icon.resized.connect(func(): icon.queue_redraw())
	return icon

func _draw_preview_fish(canvas, center, fish):
	FishArt.draw(canvas, fish, center, Vector2(66, 48), 1, false)
	return
	var app = fish.get("appearance", {})
	var body = Color.html(str(app.get("bodyColor", "#58b7d8")).replace("#", ""))
	var fin = Color.html(str(app.get("finColor", "#7fd8b7")).replace("#", ""))
	var accent = Color.html(str(app.get("accentColor", "#ffffff")).replace("#", ""))
	var line = UiStyle.INK
	var tail = PackedVector2Array([
		center + Vector2(-16, 0),
		center + Vector2(-31, -12),
		center + Vector2(-27, 0),
		center + Vector2(-31, 12),
	])
	canvas.draw_colored_polygon(tail, fin.lightened(0.08))
	var tail_closed = PackedVector2Array(tail)
	tail_closed.append(tail[0])
	canvas.draw_polyline(tail_closed, line, 1.7, true)
	canvas.draw_set_transform(center + Vector2(4, 0), 0.0, Vector2(22, 13))
	canvas.draw_circle(Vector2.ZERO, 1.0, body)
	canvas.draw_arc(Vector2.ZERO, 1.0, 0, TAU, 36, line, 0.12, true)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for i in range(3):
		canvas.draw_circle(center + Vector2(-5 + i * 7, sin(i) * 4), 2.0, accent)
	var eye = center + Vector2(20, -5)
	canvas.draw_circle(eye, 3.8, Color.WHITE)
	canvas.draw_circle(eye + Vector2(1.0, 0.5), 1.5, line)
