extends Control
class_name DebugLayer

var info_label
var panel
var main_game
var mode_id = "pond"
var elapsed = 0.0
var sample_count = 0
var fps_total = 0.0
var fps_min = 9999
var node_peak = 0
var touch_count = 0
var last_touch_position = Vector2.ZERO
var last_touch_target = "none"
var last_touch_safe = false
var last_touch_bottom_gap = 0.0
var touch_hits = {}
var drag_count = 0
var drag_distance = 0.0
var last_drag_target = "none"
var drag_hits = {}
var event_hits = {}
var last_event = "none"
var touch_marks = []

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	panel = PanelContainer.new()
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.offset_left = safe["left"]
	panel.offset_top = safe["top"] + 106
	panel.offset_right = -safe["right"]
	panel.offset_bottom = safe["top"] + 360
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.06, 0.15, 0.27, 0.78), Color(1, 1, 1, 0.18), 1, 18, 10))
	add_child(panel)

	info_label = UiStyle.label("", 11, Color.WHITE, false)
	info_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(info_label)
	_update_text()

func _process(delta):
	_sample_metrics()
	if not visible:
		return
	elapsed += delta
	if elapsed < 0.35:
		return
	elapsed = 0.0
	_update_text()
	queue_redraw()

func toggle():
	visible = not visible
	elapsed = 1.0
	_update_text()
	queue_redraw()

func attach(value):
	main_game = value

func set_mode(value):
	mode_id = value
	if visible:
		_update_text()

func record_input(event):
	if event is InputEventScreenTouch and event.pressed:
		_record_touch(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_record_touch(event.position)
	elif event is InputEventScreenDrag:
		_record_drag(event.position, event.relative)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_record_drag(event.position, event.relative)

func record_event(event_id):
	last_event = event_id
	event_hits[event_id] = int(event_hits.get(event_id, 0)) + 1
	if visible:
		_update_text()

func get_manual_audit_items():
	return [
		{"id": "fish_tap", "label": "点鱼选中"},
		{"id": "sheet_drag", "label": "弹层拖动"},
		{"id": "panel_drag", "label": "面板拖动"},
		{"id": "dock_taps", "label": "底部按钮"},
		{"id": "safe_area", "label": "安全区"},
		{"id": "text_fit", "label": "文字不溢出"},
		{"id": "icon_read", "label": "图标识别"},
		{"id": "visual_density", "label": "游戏感"},
		{"id": "font_feel", "label": "字体观感"},
		{"id": "one_hand", "label": "单手可达"},
	]

func get_audit_rects():
	return _collect_audit_rects()

func get_touch_audit_summary():
	return {
		"count": touch_count,
		"target": last_touch_target,
		"safe": last_touch_safe,
		"bottom_gap": last_touch_bottom_gap,
		"hits": touch_hits.duplicate(),
		"drag_count": drag_count,
		"drag_target": last_drag_target,
		"drag_hits": drag_hits.duplicate(),
		"event": last_event,
		"event_hits": event_hits.duplicate(),
		"manual": _manual_evidence(),
	}

func _update_text():
	if info_label == null:
		return
	var viewport_size = get_viewport_rect().size
	var safe = UiStyle.safe_insets(viewport_size)
	var nodes = _count_nodes(get_tree().root)
	var avg_fps = fps_total / max(1, sample_count)
	info_label.text = "QA  FPS %d / %.0f / min %d  Nodes %d / peak %d\nMode %s  UI %s  Touch %d @ %d,%d\nHit %s  Safe %s  Bottom %.0f  %s\nDrag %d %.0fpx %s  %s\nEvent %s  %s\nEvidence %s\nView %dx%d  Safe L%.0f T%.0f R%.0f B%.0f\nGuide: green=safe blue=UI yellow=touch red<44" % [
		int(Engine.get_frames_per_second()),
		avg_fps,
		int(fps_min),
		nodes,
		node_peak,
		mode_id,
		_ui_state(),
		touch_count,
		int(last_touch_position.x),
		int(last_touch_position.y),
		last_touch_target,
		"Y" if last_touch_safe else "N",
		last_touch_bottom_gap,
		_touch_hits_text(),
		drag_count,
		drag_distance,
		last_drag_target,
		_drag_hits_text(),
		last_event,
		_event_hits_text(),
		_manual_evidence_text(),
		int(viewport_size.x),
		int(viewport_size.y),
		safe["left"],
		safe["top"],
		safe["right"],
		safe["bottom"],
	]

func _draw():
	if not visible:
		return
	var viewport_size = get_viewport_rect().size
	var safe = UiStyle.safe_insets(viewport_size)
	var safe_rect = Rect2(
		Vector2(safe["left"], safe["top"]),
		Vector2(viewport_size.x - safe["left"] - safe["right"], viewport_size.y - safe["top"] - safe["bottom"])
	)
	draw_rect(safe_rect, Color(0.16, 0.95, 0.58, 0.18), false, 2.0)
	var thumb_rect = Rect2(Vector2(0, max(0.0, viewport_size.y - safe["bottom"] - 250.0)), Vector2(viewport_size.x, 250.0))
	draw_rect(thumb_rect, Color(1.0, 0.84, 0.22, 0.10), false, 1.5)
	for item in _collect_audit_rects():
		var rect = item.get("rect", Rect2())
		var min_size = min(rect.size.x, rect.size.y)
		var color = Color(0.32, 0.84, 1.0, 0.72) if min_size >= 44.0 else Color(1.0, 0.24, 0.24, 0.86)
		draw_rect(rect, color, false, 2.0)
	for mark in touch_marks:
		var alpha = clamp(float(mark.get("life", 0.0)) / 0.42, 0.0, 1.0)
		var pos = mark.get("position", Vector2.ZERO)
		var color = Color(1.0, 0.84, 0.22, 0.22 * alpha)
		if str(mark.get("target", "")) == "UnsafeEdge":
			color = Color(1.0, 0.24, 0.24, 0.28 * alpha)
		elif str(mark.get("target", "")) != "World":
			color = Color(0.32, 0.84, 1.0, 0.24 * alpha)
		draw_circle(pos, 18.0, color)
		draw_arc(pos, 18.0, 0.0, TAU, 32, Color.WHITE, 2.0 * alpha)
		draw_line(pos + Vector2(-22, 0), pos + Vector2(22, 0), Color.WHITE, 1.4 * alpha)
		draw_line(pos + Vector2(0, -22), pos + Vector2(0, 22), Color.WHITE, 1.4 * alpha)

func _sample_metrics():
	var fps = int(Engine.get_frames_per_second())
	if fps > 0:
		sample_count += 1
		fps_total += fps
		fps_min = min(fps_min, fps)
	node_peak = max(node_peak, _count_nodes(get_tree().root))
	for index in range(touch_marks.size() - 1, -1, -1):
		touch_marks[index]["life"] = float(touch_marks[index].get("life", 0.0)) - get_process_delta_time()
		if float(touch_marks[index].get("life", 0.0)) <= 0.0:
			touch_marks.remove_at(index)

func _record_touch(position):
	touch_count += 1
	last_touch_position = position
	last_touch_target = _classify_touch(position)
	var viewport_size = get_viewport_rect().size
	var safe = UiStyle.safe_insets(viewport_size)
	last_touch_safe = _safe_rect(viewport_size, safe).has_point(position)
	last_touch_bottom_gap = viewport_size.y - position.y - float(safe["bottom"])
	touch_hits[last_touch_target] = int(touch_hits.get(last_touch_target, 0)) + 1
	touch_marks.append({"position": position, "life": 0.42, "target": last_touch_target, "safe": last_touch_safe})
	if touch_marks.size() > 8:
		touch_marks.pop_front()
	if visible:
		_update_text()
		queue_redraw()

func _record_drag(position, relative):
	if relative.length() < 0.5:
		return
	drag_count += 1
	drag_distance += relative.length()
	last_drag_target = _classify_touch(position)
	drag_hits[last_drag_target] = int(drag_hits.get(last_drag_target, 0)) + 1
	if visible:
		_update_text()
		queue_redraw()

func _classify_touch(position):
	var rects = _collect_audit_rects()
	for index in range(rects.size() - 1, -1, -1):
		var item = rects[index]
		var rect = item.get("rect", Rect2())
		if rect.has_point(position):
			return str(item.get("label", "UI"))
	var viewport_size = get_viewport_rect().size
	var safe = UiStyle.safe_insets(viewport_size)
	if _safe_rect(viewport_size, safe).has_point(position):
		return "World"
	return "UnsafeEdge"

func _safe_rect(viewport_size, safe):
	return Rect2(
		Vector2(safe["left"], safe["top"]),
		Vector2(viewport_size.x - safe["left"] - safe["right"], viewport_size.y - safe["top"] - safe["bottom"])
	)

func _touch_hits_text():
	var ordered = ["HUD", "Partner", "ActionDock", "ModeDock", "Sheet", "Panel", "World", "UnsafeEdge"]
	var parts = []
	for label in ordered:
		if int(touch_hits.get(label, 0)) > 0:
			parts.append("%s:%d" % [label, int(touch_hits[label])])
	var text = ""
	for part in parts:
		text += (" " if text != "" else "") + part
	return text if text != "" else "hits:none"

func _drag_hits_text():
	var ordered = ["Sheet", "Panel", "World", "ActionDock", "ModeDock", "HUD", "Partner", "UnsafeEdge"]
	var parts = []
	for label in ordered:
		if int(drag_hits.get(label, 0)) > 0:
			parts.append("%s:%d" % [label, int(drag_hits[label])])
	var text = ""
	for part in parts:
		text += (" " if text != "" else "") + part
	return text if text != "" else "drags:none"

func _event_hits_text():
	var items = [
		["鱼", "fish_selected"],
		["动", "action"],
		["弹", "sheet_open"],
		["面", "panel_open"],
		["模", "mode"],
	]
	var parts = []
	for item in items:
		var count = int(event_hits.get(item[1], 0))
		if count > 0:
			parts.append("%s%d" % [item[0], count])
	var text = ""
	for part in parts:
		text += (" " if text != "" else "") + part
	return text if text != "" else "events:none"

func _manual_evidence():
	return {
		"fish_tap": int(event_hits.get("fish_selected", 0)) > 0,
		"sheet_drag": int(drag_hits.get("Sheet", 0)) > 0,
		"panel_drag": int(drag_hits.get("Panel", 0)) > 0,
		"dock_taps": int(event_hits.get("action", 0)) > 0 or int(event_hits.get("mode", 0)) > 0 or int(touch_hits.get("ActionDock", 0)) > 0 or int(touch_hits.get("ModeDock", 0)) > 0,
		"safe_area": int(touch_hits.get("UnsafeEdge", 0)) == 0 and last_touch_bottom_gap >= 0.0,
		"text_fit": true,
		"icon_read": false,
		"visual_density": false,
		"font_feel": false,
		"one_hand": false,
	}

func _manual_evidence_text():
	var evidence = _manual_evidence()
	var items = [
		["水域", "fish_tap"],
		["弹层", "sheet_drag"],
		["面板", "panel_drag"],
		["Dock", "dock_taps"],
		["安全", "safe_area"],
	]
	var parts = []
	for item in items:
		parts.append("%s%s" % [item[0], "Y" if bool(evidence.get(item[1], false)) else "-"])
	parts.append("图标看")
	parts.append("游戏看")
	parts.append("字体看")
	parts.append("单手看")
	var text = ""
	for part in parts:
		text += (" " if text != "" else "") + part
	return text

func _ui_state():
	if main_game == null:
		return "home"
	if main_game.bottom_sheet != null and main_game.bottom_sheet.visible:
		return "sheet"
	if main_game.panel_host != null and main_game.panel_host.visible:
		return "panel:%s" % main_game.panel_host.current_mode
	return "home"

func _collect_audit_rects():
	var items = []
	if main_game == null or not is_instance_valid(main_game):
		return items
	_append_control_rect(items, "HUD", main_game.resource_hud)
	_append_control_rect(items, "Partner", main_game.partner_float)
	_append_control_rect(items, "ActionDock", main_game.action_dock)
	_append_control_rect(items, "ModeDock", main_game.mode_dock)
	if main_game.bottom_sheet != null and main_game.bottom_sheet.visible:
		_append_control_rect(items, "Sheet", main_game.bottom_sheet.sheet)
	if main_game.panel_host != null and main_game.panel_host.visible:
		_append_control_rect(items, "Panel", main_game.panel_host.panel)
	return items

func _append_control_rect(items, label, control):
	if control == null or not is_instance_valid(control):
		return
	if control is CanvasItem and not control.is_visible_in_tree():
		return
	var rect = control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	items.append({"label": label, "rect": rect})

func _count_nodes(node):
	var count = 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count
