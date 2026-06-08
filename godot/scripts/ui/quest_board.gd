extends Control
class_name QuestBoard

const GameData = preload("res://godot/scripts/game_data.gd")

signal claim_requested

var controller
var claim_button
var quest_scroll
var quest_box

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_process_input(true)
	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_theme_constant_override("separation", 8)
	add_child(box)

	claim_button = UiComponents.game_button("领取", UiStyle.REWARD, UiStyle.COST, true, 54)
	claim_button.name = "ClaimChestButton"
	claim_button.custom_minimum_size = Vector2(0, 50)
	var chest = _chest_icon()
	chest.anchor_left = 0.0
	chest.anchor_top = 0.5
	chest.anchor_right = 0.0
	chest.anchor_bottom = 0.5
	chest.offset_left = 18
	chest.offset_top = -18
	chest.offset_right = 54
	chest.offset_bottom = 18
	claim_button.add_child(chest)
	claim_button.pressed.connect(func(): claim_requested.emit())
	box.add_child(claim_button)

	var board = PanelContainer.new()
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	board.mouse_filter = Control.MOUSE_FILTER_PASS
	board.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1.0, 0.96, 0.78, 0.62), UiStyle.INK, 1, 20, 8, false))
	box.add_child(board)

	quest_scroll = ScrollContainer.new()
	quest_scroll.name = "QuestScroll"
	quest_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quest_scroll.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	quest_scroll.custom_minimum_size = Vector2(0, 392)
	quest_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	quest_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	board.add_child(quest_scroll)

	quest_box = VBoxContainer.new()
	quest_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quest_box.mouse_filter = Control.MOUSE_FILTER_PASS
	quest_box.add_theme_constant_override("separation", 8)
	quest_scroll.add_child(quest_box)
	_refresh_touch_scroll()

	if controller != null:
		refresh()

func set_controller(value):
	controller = value
	if is_inside_tree():
		refresh()

func play_intro():
	var nodes = []
	if claim_button != null:
		nodes.append(claim_button)
	if quest_box != null:
		nodes.append_array(quest_box.get_children())
	UiComponents.play_staggered_entry(self, nodes, 0.025, 0.96)

func refresh():
	if controller == null:
		return
	_clear(quest_box)
	var claimable = 0
	var first = []
	var rest = []
	for quest in GameData.quest_catalog():
		var progress = min(int(controller.state.get("stats", {}).get(quest.get("stat", ""), 0)), int(quest.get("target", 1)))
		var completed = progress >= int(quest.get("target", 1))
		var claimed = controller.state.get("claimedQuests", []).has(quest.get("id", ""))
		if completed and not claimed:
			first.append(quest)
			claimable += 1
		else:
			rest.append(quest)
	claim_button.disabled = claimable <= 0
	claim_button.text = "领取 x%d" % claimable if claimable > 0 else "领取 0"

	for quest in first + rest:
		quest_box.add_child(_quest_card(quest))

	var log_panel = PanelContainer.new()
	log_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	log_panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(1, 1, 1, 0.78), UiStyle.INK, 2, 20, 10))
	quest_box.add_child(log_panel)
	var log_box = VBoxContainer.new()
	log_box.mouse_filter = Control.MOUSE_FILTER_PASS
	log_box.add_theme_constant_override("separation", 4)
	log_panel.add_child(log_box)
	log_box.add_child(UiStyle.label("记录", 18, UiStyle.INK, true))
	for entry in controller.state.get("eventLog", []).slice(0, 6):
		log_box.add_child(UiStyle.label(entry.get("text", ""), 12, UiStyle.MUTED, false))
	_refresh_touch_scroll()

func _input(event):
	if quest_scroll == null or not is_visible_in_tree():
		return
	if UiStyle.handle_drag_scroll_event(quest_scroll, event, quest_scroll.get_global_rect()):
		get_viewport().set_input_as_handled()

func _quest_card(quest):
	var progress = min(int(controller.state.get("stats", {}).get(quest.get("stat", ""), 0)), int(quest.get("target", 1)))
	var target = int(quest.get("target", 1))
	var completed = progress >= target
	var claimed = controller.state.get("claimedQuests", []).has(quest.get("id", ""))
	var panel = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(UiStyle.REWARD.lightened(0.1) if completed and not claimed else Color(1, 1, 1, 0.76), UiStyle.INK, 2 if completed and not claimed else 1, 14, 7, false))
	var box = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)
	var row = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	row.add_child(_sticker_icon(completed, claimed))
	var title = UiStyle.label(quest.get("title", "目标"), 15, UiStyle.INK, true)
	title.custom_minimum_size = Vector2(150, 0)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title)
	row.add_child(_stamp("已领" if claimed else ("可领" if completed else "%d/%d" % [progress, target]), completed, claimed))
	box.add_child(UiComponents.stat_bar(progress, UiStyle.SUCCESS if completed else UiStyle.RESOURCE, target, 12))
	box.add_child(UiComponents.reward_row(quest.get("reward", {})))
	_allow_touch_scroll(panel)
	return panel

func _sticker_icon(completed, claimed):
	var node = PanelContainer.new()
	node.custom_minimum_size = Vector2(34, 34)
	var bg = UiStyle.DISABLED if claimed else (UiStyle.SUCCESS if completed else UiStyle.RESOURCE)
	node.add_theme_stylebox_override("panel", UiStyle.panel_style(bg, UiStyle.INK, 2, 12, 4, false))
	var label = UiStyle.label("✓" if completed else "★", 15, Color.WHITE, true)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.add_child(label)
	return node

func _stamp(text, completed, claimed):
	var bg = Color(0.9, 0.92, 0.95) if claimed else (UiStyle.REWARD if completed else Color(1, 1, 1, 0.6))
	var stamp = UiComponents.tag_chip(text, bg, UiStyle.MUTED if claimed else UiStyle.INK)
	stamp.rotation_degrees = -5 if completed else 0
	return stamp

func _allow_touch_scroll(node):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_PASS
		_allow_touch_scroll(child)

func _refresh_touch_scroll():
	if quest_scroll != null and quest_box != null:
		UiStyle.configure_touch_scroll(quest_scroll, quest_box)

func _chest_icon():
	var icon = Control.new()
	icon.name = "ChestIcon"
	icon.custom_minimum_size = Vector2(36, 36)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func():
		var center = icon.size * 0.5
		var body = Rect2(center + Vector2(-15, -2), Vector2(30, 18))
		var lid = Rect2(center + Vector2(-15, -12), Vector2(30, 13))
		icon.draw_rect(body, UiStyle.COST, true)
		icon.draw_rect(lid, UiStyle.REWARD, true)
		icon.draw_rect(body, UiStyle.INK, false, 2.0)
		icon.draw_rect(lid, UiStyle.INK, false, 2.0)
		icon.draw_line(center + Vector2(-15, -1), center + Vector2(15, -1), UiStyle.INK, 2.0)
		icon.draw_rect(Rect2(center + Vector2(-4, -3), Vector2(8, 10)), Color(1, 1, 1, 0.85), true)
		icon.draw_rect(Rect2(center + Vector2(-4, -3), Vector2(8, 10)), UiStyle.INK, false, 1.4)
	)
	icon.resized.connect(func(): icon.queue_redraw())
	return icon

func _clear(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
