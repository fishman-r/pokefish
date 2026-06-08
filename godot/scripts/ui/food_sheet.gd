extends Control
class_name FoodSheet

const GameData = preload("res://godot/scripts/game_data.gd")

signal food_selected(food_id)
signal buy_requested(food_id)
signal content_changed

var food_grid
var hint_label
var controller
const FOOD_CARD_HEIGHT = 108
const FOOD_GRID_GAP = 7

func set_controller(next_controller):
	controller = next_controller
	if is_inside_tree():
		_refresh_cards()

func _ready():
	custom_minimum_size = Vector2(0, 526)
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

	var header = HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 42)
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var title = UiStyle.label("投喂", 24, UiStyle.INK, true)
	title.custom_minimum_size = Vector2(64, 0)
	title.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)
	hint_label = UiStyle.label("库存有限，饱腹会随时间下降", 12, UiStyle.MUTED, false)
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	hint_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header.add_child(hint_label)

	food_grid = GridContainer.new()
	food_grid.columns = 1
	food_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	food_grid.add_theme_constant_override("h_separation", 0)
	food_grid.add_theme_constant_override("v_separation", FOOD_GRID_GAP)
	box.add_child(food_grid)

	_refresh_cards()

func _select_food(food_id):
	food_selected.emit(food_id)

func _buy_food(food_id):
	buy_requested.emit(food_id)

func refresh():
	_refresh_cards()

func _refresh_cards():
	if food_grid == null:
		return
	for child in food_grid.get_children():
		food_grid.remove_child(child)
		child.queue_free()
	for food_id in GameData.food_catalog().keys():
		var food = GameData.food_catalog()[food_id]
		food_grid.add_child(_food_card(food_id, food))
	var count = GameData.food_catalog().size()
	food_grid.custom_minimum_size = Vector2(0, count * FOOD_CARD_HEIGHT + max(0, count - 1) * FOOD_GRID_GAP)
	custom_minimum_size = Vector2(0, 5 + 42 + food_grid.custom_minimum_size.y + 36)
	content_changed.emit()

func _food_card(food_id, food):
	var info = _purchase_info(food_id, food)
	var stock = int(info.get("stock", 0))
	var max_stock = int(info.get("max_stock", 0))
	var panel = PanelContainer.new()
	panel.name = "FoodCard_%s" % food_id
	panel.custom_minimum_size = Vector2(0, FOOD_CARD_HEIGHT)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.88), _food_color(food_id).lightened(0.08), 3, 0, 7))

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(row)
	row.add_child(_food_icon(food_id, _food_color(food_id)))
	var title_box = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_box.add_theme_constant_override("separation", 4)
	row.add_child(title_box)
	var title = UiStyle.label("%s  +%s" % [_food_short_name(food_id, food), food.get("exp", 0)], 15, UiStyle.INK, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_box.add_child(title)
	var desc = UiStyle.label(food.get("desc", ""), 11, UiStyle.MUTED, false)
	desc.autowrap_mode = TextServer.AUTOWRAP_OFF
	desc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_box.add_child(desc)

	var meta_one = UiStyle.label("库存 %d/%d  饱腹 +%d" % [stock, max_stock, int(food.get("satiety", 0))], 11, UiStyle.INK, false)
	_make_compact_line(meta_one)
	title_box.add_child(meta_one)
	var meta_two = UiStyle.label("%s  今日 %d/%d" % [_cost_text(food.get("cost", {})), int(info.get("daily_used", 0)), int(info.get("daily_limit", 0))], 11, UiStyle.MUTED, false)
	_make_compact_line(meta_two)
	title_box.add_child(meta_two)

	var action_col = VBoxContainer.new()
	action_col.custom_minimum_size = Vector2(76, 0)
	action_col.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	action_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	action_col.add_theme_constant_override("separation", 4)
	row.add_child(action_col)
	var feed = Button.new()
	feed.text = "投喂"
	feed.custom_minimum_size = Vector2(76, 44)
	feed.disabled = stock <= 0
	UiStyle.apply_button(feed, _food_color(food_id), UiStyle.CONFIRM, true)
	UiComponents.attach_press_feedback(feed, 0.95)
	feed.pressed.connect(_select_food.bind(food_id))
	action_col.add_child(feed)
	var buy = Button.new()
	buy.text = "购+%d" % int(info.get("amount", food.get("bundle", 1)))
	buy.custom_minimum_size = Vector2(76, 44)
	buy.disabled = not bool(info.get("can_buy", false))
	UiStyle.apply_button(buy, UiStyle.SECONDARY, _food_color(food_id).lightened(0.12), true)
	UiComponents.attach_press_feedback(buy, 0.95)
	buy.pressed.connect(_buy_food.bind(food_id))
	action_col.add_child(buy)
	return panel

func _make_compact_line(label):
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(0, 15)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _food_icon(food_id, color):
	var icon = Control.new()
	icon.custom_minimum_size = Vector2(46, 42)
	icon.draw.connect(func():
		var center = icon.size * 0.5
		var radius = min(icon.size.x, icon.size.y) * 0.45
		icon.draw_circle(center, radius, Color(1, 1, 1, 0.96))
		icon.draw_arc(center, radius, 0, TAU, 32, UiStyle.INK, 2.4)
		icon.draw_circle(center, radius * 0.64, color)
		if food_id == "glow":
			icon.draw_circle(center, 5, Color.WHITE)
			for i in range(6):
				var angle = TAU * float(i) / 6.0
				var from = center + Vector2(cos(angle), sin(angle)) * 21.0
				var to = center + Vector2(cos(angle), sin(angle)) * 25.0
				icon.draw_line(from, to, color.lightened(0.35), 2.0)
		elif food_id == "coral":
			icon.draw_line(center, center + Vector2(-10, -14), UiStyle.COST, 3.0)
			icon.draw_line(center, center + Vector2(0, -16), UiStyle.COST, 3.0)
			icon.draw_line(center, center + Vector2(10, -13), UiStyle.COST, 3.0)
		elif food_id == "spicy":
			icon.draw_polygon(PackedVector2Array([center + Vector2(-11, 11), center + Vector2(13, 2), center + Vector2(-3, -15)]), PackedColorArray([UiStyle.RED]))
			icon.draw_arc(center + Vector2(5, -8), 8, 3.8, 5.4, 12, UiStyle.REWARD, 2.0)
		else:
			icon.draw_circle(center + Vector2(-7, -5), 5, Color.WHITE)
			icon.draw_circle(center + Vector2(8, 3), 4, Color.WHITE)
	)
	icon.resized.connect(func(): icon.queue_redraw())
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon

func _food_color(food_id):
	return {
		"basic": UiStyle.GROWTH,
		"glow": UiStyle.RESOURCE,
		"coral": UiStyle.COST,
		"spicy": UiStyle.RED,
	}.get(food_id, UiStyle.REWARD)

func _tag_label(tag):
	return {
		"growth": "成长",
		"spark": "荧光",
		"moon": "月光",
		"coral": "珊瑚",
		"pearl": "珍珠",
		"thorn": "棘刺",
		"storm": "风暴",
		"dragon": "龙鳞",
	}.get(tag, tag)

func _food_short_name(food_id, food):
	return food.get("short", food.get("name", "饲料"))

func _purchase_info(food_id, food):
	if controller != null and controller.has_method("get_food_purchase_info"):
		return controller.get_food_purchase_info(food_id)
	return {
		"stock": 0,
		"max_stock": int(food.get("max_stock", 0)),
		"daily_used": 0,
		"daily_limit": int(food.get("daily_limit", 0)),
		"amount": int(food.get("bundle", 1)),
		"can_buy": false,
		"cost": food.get("cost", {}),
	}

func _cost_text(cost):
	if cost.is_empty():
		return "免费"
	var parts = []
	for key in cost.keys():
		parts.append("%s%d" % [GameData.resource_label(key), int(cost[key])])
	return "+".join(parts)
