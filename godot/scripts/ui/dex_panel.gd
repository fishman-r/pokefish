extends Control
class_name DexPanel

const GameData = preload("res://godot/scripts/game_data.gd")
const FishArt = preload("res://godot/scripts/ui/fish_art.gd")
const MIN_TOUCH_SCROLL_HEIGHT = 430.0

signal fish_selected(fish_id)
signal details_requested(fish_id)

var controller
var filter_id = "all"
var summary_box
var filter_box
var card_grid
var species_box
var content_scroll
var content_box

func _ready():
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(0, MIN_TOUCH_SCROLL_HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll = ScrollContainer.new()
	content_scroll.name = "DexScroll"
	content_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.custom_minimum_size = Vector2(0, MIN_TOUCH_SCROLL_HEIGHT)
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(content_scroll)

	var box = VBoxContainer.new()
	box.name = "DexContent"
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_theme_constant_override("separation", 8)
	content_scroll.add_child(box)
	content_box = box

	var header_page = PanelContainer.new()
	header_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_page.mouse_filter = Control.MOUSE_FILTER_PASS
	header_page.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.96, 0.99, 1.0, 0.86), UiStyle.WATER_DARK, 1, 16, 7, false))
	box.add_child(header_page)

	var header_box = VBoxContainer.new()
	header_box.mouse_filter = Control.MOUSE_FILTER_PASS
	header_box.add_theme_constant_override("separation", 8)
	header_page.add_child(header_box)

	var title_row = HBoxContainer.new()
	title_row.mouse_filter = Control.MOUSE_FILTER_PASS
	title_row.add_theme_constant_override("separation", 8)
	header_box.add_child(title_row)
	summary_box = HFlowContainer.new()
	summary_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_box.add_theme_constant_override("h_separation", 6)
	summary_box.add_theme_constant_override("v_separation", 6)
	title_row.add_child(summary_box)

	var filter_label = UiStyle.label("分类", 13, UiStyle.MUTED, false)
	filter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_box.add_child(filter_label)

	filter_box = HFlowContainer.new()
	filter_box.add_theme_constant_override("h_separation", 6)
	filter_box.add_theme_constant_override("v_separation", 6)
	header_box.add_child(filter_box)

	var book_page = PanelContainer.new()
	book_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book_page.mouse_filter = Control.MOUSE_FILTER_PASS
	book_page.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1.0, 0.98, 0.9, 0.68), UiStyle.INK, 1, 16, 7, false))
	box.add_child(book_page)
	card_grid = GridContainer.new()
	card_grid.columns = 1
	card_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_grid.add_theme_constant_override("h_separation", 8)
	card_grid.add_theme_constant_override("v_separation", 8)
	card_grid.mouse_filter = Control.MOUSE_FILTER_PASS
	book_page.add_child(card_grid)

	var species_page = PanelContainer.new()
	species_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	species_page.mouse_filter = Control.MOUSE_FILTER_PASS
	species_page.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1.0, 1.0, 1.0, 0.42), UiStyle.WATER_DARK, 1, 16, 7, false))
	box.add_child(species_page)
	var species_stack = VBoxContainer.new()
	species_stack.mouse_filter = Control.MOUSE_FILTER_PASS
	species_stack.add_theme_constant_override("separation", 7)
	species_page.add_child(species_stack)
	var species_label = UiStyle.label("物种贴纸", 17, UiStyle.INK, true)
	species_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	species_stack.add_child(species_label)
	species_box = HFlowContainer.new()
	species_box.add_theme_constant_override("h_separation", 6)
	species_box.add_theme_constant_override("v_separation", 6)
	species_box.mouse_filter = Control.MOUSE_FILTER_PASS
	species_stack.add_child(species_box)

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
	if summary_box != null:
		nodes.append_array(summary_box.get_children())
	if filter_box != null:
		nodes.append_array(filter_box.get_children())
	if card_grid != null:
		nodes.append_array(card_grid.get_children())
	if species_box != null:
		nodes.append_array(species_box.get_children())
	UiComponents.play_staggered_entry(self, nodes, 0.02, 0.96)

func refresh():
	if controller == null:
		return
	_clear(summary_box)
	_clear(filter_box)
	_clear(card_grid)
	_clear(species_box)

	var fish_list = controller.state.get("fish", [])
	var dex_data = controller.get_dex_data() if controller.has_method("get_dex_data") else {}
	var discovered = dex_data.get("species", {})
	var known_forms = dex_data.get("forms", {})
	var first_by_species = {}
	for fish in fish_list:
		var species_id = fish.get("speciesId", "")
		if not first_by_species.has(species_id):
			first_by_species[species_id] = fish
	summary_box.add_child(_summary_chip("%d条" % fish_list.size(), UiStyle.REWARD))
	summary_box.add_child(_summary_chip("%d/%d物种" % [discovered.size(), GameData.species_catalog().size()], Color(0.91, 0.97, 1.0)))
	summary_box.add_child(_summary_chip("%d形态" % known_forms.size(), Color(0.91, 1.0, 0.92)))

	for item in [
		["all", "全部"],
		["common", "普通"],
		["rare", "稀有"],
		["epic", "史诗"],
		["legendary", "传说"],
		["evolved", "已进化"],
	]:
		var button = Button.new()
		button.text = item[1]
		button.custom_minimum_size = Vector2(68 if item[0] == "legendary" or item[0] == "evolved" else 58, 44)
		button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		UiStyle.apply_button(button, UiStyle.REWARD if filter_id == item[0] else Color(1, 1, 1, 0.82), UiStyle.CONFIRM, false)
		UiComponents.attach_press_feedback(button, 0.95)
		button.pressed.connect(_set_filter.bind(item[0]))
		filter_box.add_child(button)

	var cards = fish_list.duplicate()
	cards.sort_custom(func(a, b):
		var ar = GameData.rarity_order().find(a.get("rarity", "common"))
		var br = GameData.rarity_order().find(b.get("rarity", "common"))
		if ar == br:
			return int(a.get("level", 1)) > int(b.get("level", 1))
		return ar > br
	)
	for fish in cards:
		if not _matches_filter(fish):
			continue
		card_grid.add_child(_fish_card(fish))

	for species in GameData.species_catalog():
		var species_id = species.get("id", "")
		var known = discovered.has(species_id)
		var sample = first_by_species.get(species_id, {})
		if known and sample.is_empty():
			sample = {
				"speciesId": species_id,
				"speciesName": species.get("name", "鱼"),
				"family": species.get("family", "鱼系"),
				"rarity": discovered.get(species_id, {}).get("bestRarity", species.get("base_rarity", "common")),
			}
		species_box.add_child(_species_chip(species, known, sample))
	_refresh_touch_scroll()
	call_deferred("_refresh_touch_scroll")

func _set_filter(value):
	filter_id = value
	refresh()

func _matches_filter(fish):
	if filter_id == "all":
		return true
	if filter_id == "evolved":
		return int(fish.get("evolutionStage", 0)) > 0
	return fish.get("rarity", "common") == filter_id

func _open_fish(fish_id):
	fish_selected.emit(fish_id)
	details_requested.emit(fish_id)

func _fish_card(fish):
	var button = Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(0, 88)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var color = UiStyle.rarity_color(fish.get("rarity", "common"))
	UiStyle.apply_button(button, Color(1.0, 0.98, 0.9, 0.9), color.lightened(0.18), true)
	button.add_theme_stylebox_override("normal", UiStyle.panel_style(Color(1.0, 0.98, 0.9, 0.9), UiStyle.INK, 2, 14, 7, false))
	button.add_theme_stylebox_override("hover", UiStyle.panel_style(Color(1.0, 0.99, 0.94, 0.94), UiStyle.INK, 2, 14, 7, false))
	button.add_theme_stylebox_override("pressed", UiStyle.panel_style(color.lightened(0.18), UiStyle.INK, 2, 14, 7, false))
	button.pressed.connect(_open_fish.bind(fish.get("id", "")))
	button.button_down.connect(_press_card.bind(button))
	button.button_up.connect(_release_card.bind(button))

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 7)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	var portrait = PanelContainer.new()
	portrait.custom_minimum_size = Vector2(72, 56)
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_theme_stylebox_override("panel", UiStyle.panel_style(color.lightened(0.25), UiStyle.INK, 1, 14, 5, false))
	row.add_child(portrait)
	var icon_wrap = CenterContainer.new()
	icon_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_child(icon_wrap)
	icon_wrap.add_child(_fish_icon(fish, true, Vector2(64, 46)))

	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_theme_constant_override("separation", 5)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(box)

	var name = UiStyle.label(fish.get("name", "伙伴"), 15, UiStyle.INK, true)
	name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name.autowrap_mode = TextServer.AUTOWRAP_OFF
	box.add_child(name)

	var info = UiStyle.label("%s · %s · Lv.%d" % [fish.get("speciesName", "鱼"), fish.get("family", "鱼系"), int(round(float(fish.get("level", 1))))], 12, UiStyle.MUTED, false)
	info.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	info.autowrap_mode = TextServer.AUTOWRAP_OFF
	box.add_child(info)

	var meta = HFlowContainer.new()
	meta.add_theme_constant_override("h_separation", 5)
	meta.add_theme_constant_override("v_separation", 4)
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(meta)
	meta.add_child(UiComponents.tag_chip(GameData.rarity_label(fish.get("rarity", "common")), UiStyle.rarity_color(fish.get("rarity", "common")), UiStyle.INK))
	meta.add_child(UiComponents.tag_chip(_stage_label(fish), Color(0.91, 1.0, 0.92), UiStyle.INK))
	meta.add_child(UiComponents.tag_chip("+%s" % fish.get("output", 0), Color(1, 1, 1, 0.66), UiStyle.INK))

	_ignore_mouse(button)
	return button

func _species_chip(species, known, fish):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(105, 46)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.94, 0.98, 1.0, 0.86) if known else Color(0.82, 0.87, 0.93, 0.86), UiStyle.INK, 1, 15, 6, false))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(row)
	if known and not fish.is_empty():
		row.add_child(_fish_icon(fish, true, Vector2(42, 32)))
	else:
		row.add_child(_fish_icon({"speciesId": species.get("id", "")}, false, Vector2(42, 32)))
	var label_text = species.get("name", "鱼") if known else "???"
	var label = UiStyle.label(label_text, 12, UiStyle.INK if known else UiStyle.MUTED, false)
	label.custom_minimum_size = Vector2(42, 0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	return panel

func _summary_chip(text, bg):
	var chip = UiComponents.tag_chip(text, bg, UiStyle.INK)
	chip.custom_minimum_size.x = max(58.0, chip.custom_minimum_size.x)
	return chip

func _stage_label(fish):
	var stage = int(fish.get("evolutionStage", 0))
	return "原生" if stage <= 0 else "%d阶" % stage

func _fish_icon(fish, known, min_size):
	return FishArt.make_icon(fish, known, min_size)

func _draw_ellipse(canvas, center, radii, fill, stroke, stroke_width):
	canvas.draw_set_transform(center, 0.0, radii)
	canvas.draw_circle(Vector2.ZERO, 1.0, fill)
	if stroke_width > 0.0:
		canvas.draw_arc(Vector2.ZERO, 1.0, 0.0, TAU, 40, stroke, stroke_width / max(1.0, max(radii.x, radii.y)), true)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _html_color(hex):
	return Color.html(str(hex).replace("#", ""))

func _press_card(card):
	var tween = create_tween()
	tween.tween_property(card, "scale", Vector2(0.98, 0.98), 0.06)

func _release_card(card):
	var tween = create_tween()
	tween.tween_property(card, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _ignore_mouse(node):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_mouse(child)

func _clear(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _refresh_touch_scroll():
	if content_scroll != null and content_box != null:
		UiStyle.configure_touch_scroll(content_scroll, content_box)
