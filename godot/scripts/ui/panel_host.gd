extends Control
class_name PanelHost

signal closed

var overlay
var panel
var title_label
var scroll
var content_holder
var current_mode = "pond"
const DOCK_RESERVE = 104.0

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_process_input(true)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var safe = UiStyle.safe_insets(get_viewport_rect().size)

	overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.03, 0.08, 0.16, 0.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(_on_overlay_input)
	add_child(overlay)

	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.95, 0.99, 1.0, 0.97), UiStyle.INK, 3, 28, 12))
	add_child(panel)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)

	var back = Button.new()
	back.text = "←"
	back.custom_minimum_size = Vector2(44, 44)
	UiStyle.apply_button(back, Color(0.94, 0.98, 1.0), UiStyle.CONFIRM, true)
	UiComponents.attach_press_feedback(back, 0.94)
	back.pressed.connect(close_panel)
	header.add_child(back)

	title_label = UiStyle.label("面板", 24, UiStyle.INK, true)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title_label)

	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(scroll)

	content_holder = VBoxContainer.new()
	content_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_holder.add_theme_constant_override("separation", 10)
	scroll.add_child(content_holder)
	_apply_panel_offsets()
	_apply_overlay_offsets()
	_refresh_touch_scroll_bindings()

func open_panel(content, title, mode_id):
	current_mode = mode_id
	title_label.text = title
	for child in content_holder.get_children():
		content_holder.remove_child(child)
		child.queue_free()
	content_holder.add_child(content)
	scroll.scroll_vertical = 0
	_apply_panel_offsets()
	call_deferred("_fit_content_to_viewport")
	_refresh_touch_scroll_bindings()
	call_deferred("_refresh_touch_scroll_bindings")
	visible = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(0.03, 0.08, 0.16, 0.0)
	panel.position.x = get_viewport_rect().size.x + 24
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "color", Color(0.03, 0.08, 0.16, 0.26), 0.16)
	tween.tween_property(panel, "position:x", 0.0, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	call_deferred("_play_content_intro")

func close_panel():
	if not visible:
		return
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "color", Color(0.03, 0.08, 0.16, 0.0), 0.14)
	tween.tween_property(panel, "position:x", get_viewport_rect().size.x + 24, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_finish_close)

func refresh_content():
	if content_holder == null or content_holder.get_child_count() == 0:
		return
	var content = content_holder.get_child(0)
	if content.has_method("refresh"):
		content.refresh()
		_fit_content_to_viewport()
		_refresh_touch_scroll_bindings()
		call_deferred("_refresh_touch_scroll_bindings")

func _finish_close():
	visible = false
	current_mode = "pond"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in content_holder.get_children():
		content_holder.remove_child(child)
		child.queue_free()
	closed.emit()

func _play_content_intro():
	if not visible or content_holder == null or content_holder.get_child_count() == 0:
		return
	var content = content_holder.get_child(0)
	if content != null and content.has_method("play_intro"):
		content.play_intro()
		call_deferred("_refresh_touch_scroll_bindings")
		return
	UiComponents.play_staggered_entry(self, content_holder.get_children(), 0.04, 0.97)
	call_deferred("_refresh_touch_scroll_bindings")

func _on_overlay_input(event):
	if event is InputEventMouseButton and event.pressed:
		close_panel()
	elif event is InputEventScreenTouch and event.pressed:
		close_panel()

func _input(event):
	if not visible or scroll == null:
		return
	var hit_rect = panel.get_global_rect() if panel != null else scroll.get_global_rect()
	if UiStyle.handle_drag_scroll_event(scroll, event, hit_rect):
		get_viewport().set_input_as_handled()

func _notification(what):
	if what == NOTIFICATION_RESIZED and panel != null:
		_apply_panel_offsets()
		_apply_overlay_offsets()
		call_deferred("_fit_content_to_viewport")

func _apply_panel_offsets():
	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	panel.offset_left = safe["left"]
	panel.offset_top = safe["top"] + 46
	panel.offset_right = -safe["right"]
	panel.offset_bottom = -safe["bottom"] - DOCK_RESERVE

func _apply_overlay_offsets():
	var safe = UiStyle.safe_insets(get_viewport_rect().size)
	overlay.offset_left = 0.0
	overlay.offset_top = 0.0
	overlay.offset_right = 0.0
	overlay.offset_bottom = -safe["bottom"] - DOCK_RESERVE

func _refresh_touch_scroll_bindings():
	if scroll != null and content_holder != null:
		UiStyle.configure_touch_scroll(scroll, content_holder)

func _fit_content_to_viewport():
	if not visible or scroll == null or content_holder == null or content_holder.get_child_count() == 0:
		return
	if scroll.size.y <= 1.0:
		call_deferred("_fit_content_to_viewport")
		return
	var content = content_holder.get_child(0)
	if content != null and content.has_method("set_panel_viewport_height"):
		content.set_panel_viewport_height(scroll.size.y)
