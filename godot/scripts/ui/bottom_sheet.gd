extends Control
class_name BottomSheet

signal closed

var overlay
var sheet
var scroll
var holder
var sheet_height = 420
var safe_bottom = 14.0
const DOCK_RESERVE = 104.0
const MIN_SHEET_HEIGHT = 220.0
const CONTENT_PADDING = 28.0

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	safe_bottom = UiStyle.safe_insets(get_viewport_rect().size)["bottom"]

	overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.03, 0.08, 0.16, 0.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(_on_overlay_input)
	add_child(overlay)

	sheet = PanelContainer.new()
	sheet.anchor_left = 0.0
	sheet.anchor_top = 0.0
	sheet.anchor_right = 0.0
	sheet.anchor_bottom = 0.0
	sheet.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.96, 0.99, 1.0, 0.98), UiStyle.INK, 3, 28, 14))
	add_child(sheet)

	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	sheet.add_child(scroll)

	holder = VBoxContainer.new()
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.add_theme_constant_override("separation", 10)
	scroll.add_child(holder)
	_apply_sheet_offsets()
	_apply_overlay_offsets()
	_refresh_touch_scroll_bindings()

func open_with(content, height := 420):
	for child in holder.get_children():
		holder.remove_child(child)
		child.queue_free()
	holder.add_child(content)
	if content != null and content.has_signal("content_changed"):
		content.content_changed.connect(refresh_scroll_bindings)
	sheet_height = _resolved_height(_target_height_for_content(content, height))
	scroll.scroll_vertical = 0
	_apply_sheet_offsets()
	_refresh_touch_scroll_bindings()
	call_deferred("_refresh_touch_scroll_bindings")
	visible = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(0.03, 0.08, 0.16, 0.0)
	var final_y = sheet.position.y
	sheet.position.y = get_viewport_rect().size.y + 24.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "color", Color(0.03, 0.08, 0.16, 0.32), 0.18)
	tween.tween_property(sheet, "position:y", final_y, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func close():
	if not visible:
		return
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "color", Color(0.03, 0.08, 0.16, 0.0), 0.16)
	tween.tween_property(sheet, "position:y", get_viewport_rect().size.y + 24.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_finish_close)

func _finish_close():
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in holder.get_children():
		holder.remove_child(child)
		child.queue_free()
	closed.emit()

func _on_overlay_input(event):
	if event is InputEventMouseButton and event.pressed:
		close()
	elif event is InputEventScreenTouch and event.pressed:
		close()

func _input(event):
	if not visible or scroll == null:
		return
	var hit_rect = sheet.get_global_rect() if sheet != null else scroll.get_global_rect()
	if UiStyle.handle_drag_scroll_event(scroll, event, hit_rect):
		get_viewport().set_input_as_handled()

func refresh_scroll_bindings():
	_refresh_touch_scroll_bindings()
	call_deferred("_refresh_touch_scroll_bindings")

func _notification(what):
	if what == NOTIFICATION_RESIZED and sheet != null:
		_apply_sheet_offsets()
		_apply_overlay_offsets()

func _resolved_height(requested_height):
	var viewport_size = get_viewport_rect().size
	var safe = UiStyle.safe_insets(viewport_size)
	var max_height = max(300.0, viewport_size.y - safe["top"] - safe["bottom"] - DOCK_RESERVE - 12.0)
	return min(float(requested_height), max_height)

func _target_height_for_content(content, max_requested_height):
	var content_height = 0.0
	if content != null:
		content_height = max(float(content.custom_minimum_size.y), float(content.get_combined_minimum_size().y))
	var wanted = max(MIN_SHEET_HEIGHT, content_height + CONTENT_PADDING)
	if float(max_requested_height) > 0.0:
		wanted = min(wanted, float(max_requested_height))
	return wanted

func _apply_sheet_offsets():
	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	var viewport_size = get_viewport_rect().size
	safe_bottom = safe["bottom"]
	var bottom = viewport_size.y - safe_bottom - DOCK_RESERVE
	var top = bottom - sheet_height
	sheet.position = Vector2(safe["left"], top)
	sheet.size = Vector2(max(1.0, viewport_size.x - safe["left"] - safe["right"]), sheet_height)

func _apply_overlay_offsets():
	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	overlay.offset_left = 0.0
	overlay.offset_top = 0.0
	overlay.offset_right = 0.0
	overlay.offset_bottom = -safe["bottom"] - DOCK_RESERVE

func _refresh_touch_scroll_bindings():
	if scroll != null and holder != null:
		UiStyle.configure_touch_scroll(scroll, holder)
