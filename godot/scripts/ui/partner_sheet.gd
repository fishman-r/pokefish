extends Control
class_name PartnerSheet

const GameData = preload("res://godot/scripts/game_data.gd")
const FishArt = preload("res://godot/scripts/ui/fish_art.gd")

signal release_requested(fish_id)

var icon
var name_label
var meta_label
var rarity_label
var output_label
var mood_bar
var intimacy_bar
var hunger_bar
var mood_value_label
var intimacy_value_label
var hunger_value_label
var tags_line
var story_label
var current_fish = {}

func _ready():
	custom_minimum_size = Vector2(0, 390)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	var grabber = ColorRect.new()
	grabber.color = Color(0.7, 0.77, 0.84)
	grabber.custom_minimum_size = Vector2(74, 5)
	var grab_center = CenterContainer.new()
	grab_center.add_child(grabber)
	box.add_child(grab_center)

	var top = HBoxContainer.new()
	top.custom_minimum_size = Vector2(0, 98)
	top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top.add_theme_constant_override("separation", 12)
	box.add_child(top)

	icon = _fish_icon()
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(icon)

	var title_box = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_box.add_theme_constant_override("separation", 5)
	top.add_child(title_box)
	name_label = UiStyle.label("伙伴", 24, UiStyle.INK, true)
	_make_one_line(name_label, 0)
	title_box.add_child(name_label)
	meta_label = UiStyle.label("物种 · Lv.1", 13, UiStyle.MUTED, false)
	_make_one_line(meta_label, 0)
	title_box.add_child(meta_label)
	var badge_row = HBoxContainer.new()
	badge_row.custom_minimum_size = Vector2(0, 42)
	badge_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge_row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	badge_row.add_theme_constant_override("separation", 6)
	title_box.add_child(badge_row)
	rarity_label = UiComponents.rarity_badge("common", true)
	badge_row.add_child(rarity_label)
	var rate_pill = _rate_pill()
	badge_row.add_child(rate_pill)
	var release_button = _release_button()
	badge_row.add_child(release_button)

	var stats_box = VBoxContainer.new()
	stats_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_box.add_theme_constant_override("separation", 7)
	box.add_child(stats_box)
	stats_box.add_child(_stat_row(UiStyle.GREEN, "mood", "心情"))
	stats_box.add_child(_stat_row(UiStyle.WATER, "intimacy", "默契"))
	stats_box.add_child(_stat_row(UiStyle.ORANGE, "hunger", "饱腹"))

	var label = UiStyle.label("特性", 19, UiStyle.INK, true)
	_make_one_line(label, 0)
	box.add_child(label)
	tags_line = HFlowContainer.new()
	tags_line.custom_minimum_size = Vector2(0, 70)
	tags_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tags_line.add_theme_constant_override("h_separation", 6)
	tags_line.add_theme_constant_override("v_separation", 6)
	box.add_child(tags_line)

	story_label = UiStyle.label("", 13, UiStyle.MUTED, false)
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.custom_minimum_size = Vector2(0, 40)
	story_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(story_label)

func _release_button():
	var release_button = UiComponents.game_button("送回海域", Color(1.0, 0.94, 0.92, 0.86), UiStyle.COST, true, 40)
	release_button.name = "ReleaseFishButton"
	release_button.custom_minimum_size = Vector2(86, 40)
	release_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	release_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	release_button.tooltip_text = "从当前水域移除这条鱼"
	release_button.pressed.connect(func():
		release_requested.emit(current_fish.get("id", ""))
	)
	return release_button

func update_fish(fish):
	if fish == null or fish.is_empty():
		return
	current_fish = fish
	if icon != null:
		icon.queue_redraw()
	name_label.text = fish.get("name", "伙伴")
	var level = int(round(float(fish.get("level", 1))))
	meta_label.text = "%s  Lv.%s" % [fish.get("speciesName", "鱼"), level]
	output_label.text = str(int(fish.get("output", 0)))
	rarity_label.get_child(0).text = UiStyle.rarity_short(fish.get("rarity", "common"))
	rarity_label.add_theme_stylebox_override("panel", UiStyle.panel_style(UiStyle.rarity_color(fish.get("rarity", "common")), UiStyle.INK, 2, 13, 6, false))
	var mood = int(fish.get("mood", 0))
	var intimacy = int(fish.get("intimacy", 0))
	var hunger = int(fish.get("hunger", 0))
	mood_bar.value = mood
	intimacy_bar.value = intimacy
	hunger_bar.value = hunger
	mood_value_label.text = str(mood)
	intimacy_value_label.text = str(intimacy)
	hunger_value_label.text = str(hunger)
	for child in tags_line.get_children():
		tags_line.remove_child(child)
		child.queue_free()
	tags_line.add_child(_tag(_appetite_label(fish)))
	for tag in _fish_tags(fish):
		tags_line.add_child(_tag(tag))
	if fish.get("evolutionHistory", []).is_empty():
		story_label.text = "还没有进化记录。"
	else:
		story_label.text = fish["evolutionHistory"][0].get("story", "")

func _stat_row(color, key, label_text):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 24)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", 8)
	var dot = ColorRect.new()
	dot.color = color
	dot.custom_minimum_size = Vector2(12, 12)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot)
	var text = UiStyle.label(label_text, 13, UiStyle.MUTED, false)
	_make_one_line(text, 38)
	row.add_child(text)
	var bar = UiComponents.stat_bar(0, color, 100, 12)
	row.add_child(bar)
	var value_label = UiStyle.label("0", 12, UiStyle.INK, false)
	_make_one_line(value_label, 30)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)
	if key == "mood":
		mood_bar = bar
		mood_value_label = value_label
	elif key == "intimacy":
		intimacy_bar = bar
		intimacy_value_label = value_label
	else:
		hunger_bar = bar
		hunger_value_label = value_label
	return row

func _rate_pill():
	var pill = PanelContainer.new()
	pill.custom_minimum_size = Vector2(76, 28)
	pill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pill.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.68), UiStyle.INK, 2, 14, 5, false))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	pill.add_child(row)
	row.add_child(UiComponents.resource_icon("bubbleCoins", Vector2(18, 18)))
	output_label = UiStyle.label("0", 12, UiStyle.INK, true)
	_make_one_line(output_label, 28)
	output_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(output_label)
	return pill

func _make_one_line(label, min_width):
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL if min_width <= 0 else Control.SIZE_SHRINK_BEGIN
	label.custom_minimum_size = Vector2(min_width, 0)

func _badge(text, color):
	return UiComponents.tag_chip(text, color, Color.WHITE)

func _tag(text):
	return UiComponents.tag_chip(text)

func _fish_tags(fish):
	var genes = GameData.gene_catalog()
	var tags = []
	var fish_genes = fish.get("genes", {})
	for gene in fish_genes.get("visible", []):
		if genes.has(gene):
			tags.append(genes[gene]["label"])
	for trait_data in fish.get("traits", []):
		if typeof(trait_data) == TYPE_DICTIONARY:
			tags.append(trait_data.get("label", trait_data.get("id", "")))
	return tags.slice(0, 5)

func _appetite_label(fish):
	return {
		"hungry": "有点饿",
		"ideal": "状态正好",
		"normal": "正常",
		"full": "偏饱",
		"stuffed": "吃撑了",
	}.get(str(fish.get("appetiteState", "normal")), "正常")

func _fish_icon():
	var node = Control.new()
	node.custom_minimum_size = Vector2(86, 86)
	node.draw.connect(func():
		var center = node.size * 0.5
		var rarity = current_fish.get("rarity", "common")
		node.draw_circle(center, 39, UiStyle.rarity_color(rarity).lightened(0.2))
		node.draw_circle(center + Vector2(0, 3), 31, Color(1, 1, 1, 0.32))
		node.draw_arc(center, 39, 0, TAU, 54, UiStyle.INK, 3)
		_draw_preview_fish(node, center, current_fish)
	)
	return node

func _draw_preview_fish(canvas, center, fish):
	FishArt.draw(canvas, fish, center, Vector2(74, 54), 1, false)
	return
	var app = fish.get("appearance", {})
	var line = UiStyle.INK
	var body = _html_color(app.get("bodyColor", "#58b7d8"))
	var fin = _html_color(app.get("finColor", "#7fd8b7"))
	var accent = _html_color(app.get("accentColor", "#ffffff"))
	var scale = 0.82
	if bool(app.get("glow", false)):
		_draw_ellipse(canvas, center, Vector2(38, 24), Color(accent.r, accent.g, accent.b, 0.24), Color(0, 0, 0, 0), 0.0)
	var tail = PackedVector2Array([
		center + Vector2(-24, 2) * scale,
		center + Vector2(-50, -19) * scale,
		center + Vector2(-42, 2) * scale,
		center + Vector2(-50, 23) * scale,
	])
	canvas.draw_colored_polygon(tail, fin.lightened(0.08))
	var tail_closed = PackedVector2Array(tail)
	tail_closed.append(tail[0])
	canvas.draw_polyline(tail_closed, line, 2.4, true)
	var top_fin = PackedVector2Array([
		center + Vector2(-4, -14) * scale,
		center + Vector2(12, -34) * scale,
		center + Vector2(25, -12) * scale,
	])
	canvas.draw_colored_polygon(top_fin, fin.lightened(0.16))
	var top_closed = PackedVector2Array(top_fin)
	top_closed.append(top_fin[0])
	canvas.draw_polyline(top_closed, line, 2.0, true)
	var body_size = Vector2(31, 19)
	if app.get("body", "oval") == "round":
		body_size = Vector2(27, 24)
	elif app.get("body", "oval") == "slender":
		body_size = Vector2(38, 16)
	_draw_ellipse(canvas, center + Vector2(5, 1), body_size, body, line, 2.7)
	_draw_pattern(canvas, app.get("pattern", "dots"), center + Vector2(5, 1), scale, accent, line)
	var eye = center + Vector2(25, -7) * scale
	canvas.draw_circle(eye, 5.4, Color.WHITE)
	canvas.draw_arc(eye, 5.4, 0, TAU, 20, line, 1.4)
	canvas.draw_circle(eye + Vector2(1.4, 0.7), 2.2, line)

func _draw_pattern(canvas, pattern, center, scale, accent, line):
	if pattern == "stripes" or pattern == "sunburst":
		for i in range(-1, 3):
			var x = (-12 + i * 8) * scale
			canvas.draw_line(center + Vector2(x, -11 * scale), center + Vector2(x + 4 * scale, 11 * scale), Color(line.r, line.g, line.b, 0.58), 1.5, true)
	elif pattern == "stars":
		for i in range(4):
			canvas.draw_circle(center + Vector2(-13 + i * 8, sin(i) * 6) * scale, 2.5, accent)
	elif pattern == "petals":
		for i in range(3):
			_draw_ellipse(canvas, center + Vector2(-10 + i * 9, sin(i) * 6) * scale, Vector2(2.5, 5), accent, line, 0.9)
	elif pattern == "spikes":
		for i in range(-1, 2):
			var spike = PackedVector2Array([
				center + Vector2(i * 9, -16) * scale,
				center + Vector2(i * 9 + 4, -26) * scale,
				center + Vector2(i * 9 + 8, -15) * scale,
			])
			canvas.draw_colored_polygon(spike, accent)
	else:
		for i in range(5):
			canvas.draw_circle(center + Vector2(-13 + i * 7, sin(i) * 6) * scale, 2.2, accent)

func _draw_ellipse(canvas, center, radii, fill, stroke, stroke_width):
	canvas.draw_set_transform(center, 0.0, radii)
	canvas.draw_circle(Vector2.ZERO, 1.0, fill)
	if stroke_width > 0.0 and stroke.a > 0.0:
		canvas.draw_arc(Vector2.ZERO, 1.0, 0, TAU, 44, stroke, stroke_width / max(1.0, max(radii.x, radii.y)), true)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _html_color(hex):
	return Color.html(str(hex).replace("#", ""))
