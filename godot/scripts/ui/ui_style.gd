extends RefCounted
class_name UiStyle

const DISPLAY_FONT = preload("res://godot/assets/fonts/ZCOOLKuaiLe-Regular.ttf")
static var TEXT_FONT = _create_text_font()

const INK = Color(0.05, 0.09, 0.18)
const MUTED = Color(0.32, 0.4, 0.5)
const WATER = Color(0.22, 0.73, 0.92)
const WATER_DARK = Color(0.05, 0.38, 0.57)
const PAPER = Color(0.93, 0.98, 1.0)
const GLASS = Color(0.97, 0.99, 1.0, 0.94)
const YELLOW = Color(1.0, 0.84, 0.2)
const GREEN = Color(0.18, 0.78, 0.42)
const ORANGE = Color(1.0, 0.52, 0.18)
const PURPLE = Color(0.58, 0.35, 0.92)
const RED = Color(0.94, 0.22, 0.28)
const DISABLED = Color(0.75, 0.81, 0.88)
const SECONDARY = Color(0.92, 0.96, 1.0, 0.9)
const PIXEL_HILITE = Color(1.0, 1.0, 1.0, 0.54)
const PIXEL_SHADE = Color(0.02, 0.06, 0.12, 0.22)

const SELECTED = YELLOW
const REWARD = YELLOW
const CONFIRM = YELLOW
const GROWTH = GREEN
const SUCCESS = GREEN
const RESOURCE = WATER
const ACTION_COLLECT = WATER
const EGG = ORANGE
const COST = ORANGE
const RARE = PURPLE

static func _create_text_font():
	var font = SystemFont.new()
	font.font_names = PackedStringArray([
		"PingFang SC",
		"SF Pro Text",
		"Hiragino Sans GB",
		"Noto Sans CJK SC",
		"Noto Sans SC",
		"Helvetica Neue",
		"Arial Unicode MS",
	])
	font.allow_system_fallback = true
	return font

static func ui_font(display := false):
	if display or OS.get_name() == "iOS":
		return DISPLAY_FONT
	return TEXT_FONT

static func panel_style(bg := GLASS, border := INK, border_width := 3, radius := 22, margin := 10, shadow := true):
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(max(2, int(border_width)))
	style.set_corner_radius_all(0)
	style.content_margin_left = int(margin)
	style.content_margin_top = int(margin)
	style.content_margin_right = int(margin)
	style.content_margin_bottom = int(margin)
	style.anti_aliasing = false
	style.corner_detail = 1
	if shadow:
		style.shadow_color = Color(0.02, 0.06, 0.12, 0.28)
		style.shadow_size = 0
		style.shadow_offset = Vector2(4, 4)
	return style

static func button_style(bg := YELLOW, pressed_bg := ORANGE, radius := 18):
	return {
		"normal": panel_style(bg, INK, 3, 0, 8),
		"hover": panel_style(bg.lightened(0.05), INK, 3, 0, 8),
		"pressed": panel_style(pressed_bg, INK, 3, 0, 8),
		"disabled": panel_style(DISABLED, INK, 2, 0, 8, false),
	}

static func apply_button(button, bg := YELLOW, pressed_bg := ORANGE, display := true):
	button.focus_mode = Control.FOCUS_NONE
	var styles = button_style(bg, pressed_bg)
	for key in styles.keys():
		button.add_theme_stylebox_override(key, styles[key])
	button.add_theme_font_override("font", ui_font(display))
	button.add_theme_font_size_override("font_size", 17 if display else 14)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_constant_override("outline_size", 0)

static func label(text, size := 16, color := INK, display := false):
	var node = Label.new()
	node.text = str(text)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_override("font", ui_font(display))
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	return node

static func configure_touch_scroll(scroll, root_node = null):
	if scroll == null:
		return
	scroll.clip_contents = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_set_property_if_exists(scroll, "follow_focus", false)
	_set_property_if_exists(scroll, "scroll_deadzone", 2)
	_hide_scroll_bars(scroll)
	_bind_touch_scroll(scroll, root_node if root_node != null else scroll)

static func handle_drag_scroll_event(scroll, event, hit_rect := Rect2()):
	if scroll == null or not is_instance_valid(scroll):
		return false
	if scroll is Control and not scroll.is_visible_in_tree():
		return false
	var rect = hit_rect if hit_rect.size != Vector2.ZERO else scroll.get_global_rect()
	if event is InputEventScreenTouch:
		var touch_key = "_pokefish_touch_scroll_active_%d" % event.index
		if event.pressed:
			scroll.set_meta(touch_key, rect.grow(10.0).has_point(event.position))
		else:
			scroll.set_meta(touch_key, false)
		return false
	var position = Vector2.ZERO
	var relative = Vector2.ZERO
	var active_touch = false
	if event is InputEventScreenDrag:
		position = event.position
		relative = event.relative
		active_touch = bool(scroll.get_meta("_pokefish_touch_scroll_active_%d" % event.index, false))
	elif event is InputEventPanGesture:
		position = event.position
		relative = event.delta
		active_touch = true
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position = event.position
		relative = event.relative
	else:
		return false
	if abs(relative.y) < max(2.0, abs(relative.x)):
		return false
	if not active_touch and not rect.grow(10.0).has_point(position):
		return false
	_apply_scroll_relative(scroll, relative)
	return true

static func _apply_scroll_relative(scroll, relative):
	var next_scroll = max(0.0, float(scroll.scroll_vertical) - relative.y)
	var bar = scroll.get_v_scroll_bar()
	if bar != null:
		var max_scroll = max(0.0, float(bar.max_value) - float(bar.page))
		if max_scroll > 0.0:
			next_scroll = min(next_scroll, max_scroll)
	scroll.scroll_vertical = int(round(next_scroll))

static func resource_color(key):
	return {
		"bubbleCoins": RESOURCE,
		"shells": GROWTH,
		"eggs": EGG,
		"pearls": RARE,
	}.get(key, RESOURCE)

static func rarity_color(rarity):
	return {
		"common": GROWTH,
		"rare": RESOURCE,
		"epic": RARE,
		"legendary": EGG,
	}.get(rarity, RESOURCE)

static func semantic_color(kind):
	return {
		"selected": SELECTED,
		"reward": REWARD,
		"confirm": CONFIRM,
		"growth": GROWTH,
		"success": SUCCESS,
		"water": WATER,
		"resource": RESOURCE,
		"collect": ACTION_COLLECT,
		"egg": EGG,
		"cost": COST,
		"rare": RARE,
		"disabled": DISABLED,
		"secondary": SECONDARY,
	}.get(kind, RESOURCE)

static func action_color(kind):
	return {
		"feed": COST,
		"collect": ACTION_COLLECT,
		"evolve": GROWTH,
	}.get(kind, CONFIRM)

static func action_pressed_color(kind):
	return {
		"feed": CONFIRM,
		"collect": CONFIRM,
		"evolve": CONFIRM,
	}.get(kind, COST)

static func module_color(kind, active := false):
	if active:
		return SELECTED
	return {
		"hatchery": Color(1.0, 0.93, 0.66, 0.95),
		"dex": Color(0.72, 0.9, 1.0, 0.95),
		"adventure": Color(0.68, 0.95, 0.78, 0.95),
		"quests": Color(1.0, 0.78, 0.48, 0.95),
		"pond": Color(0.72, 0.92, 1.0, 0.95),
		"menu": Color(0.9, 0.95, 1.0, 0.95),
	}.get(kind, SECONDARY)

static func rarity_short(rarity):
	return {
		"common": "C",
		"rare": "R",
		"epic": "E",
		"legendary": "L",
	}.get(rarity, "?")

static func safe_insets(viewport_size := Vector2.ZERO):
	if viewport_size == Vector2.ZERO:
		viewport_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width", 390), ProjectSettings.get_setting("display/window/size/viewport_height", 844))
	var is_phone_portrait = viewport_size.x <= 480.0 and viewport_size.y >= 640.0
	var min_top = 44.0 if OS.get_name() == "iOS" or is_phone_portrait else 12.0
	var min_bottom = 28.0 if OS.get_name() == "iOS" or is_phone_portrait else 14.0
	var result = {"left": 12.0, "top": min_top, "right": 12.0, "bottom": min_bottom}
	var safe_area = DisplayServer.get_display_safe_area()
	var screen_size = DisplayServer.screen_get_size()
	if safe_area.size.x <= 0 or safe_area.size.y <= 0 or screen_size.x <= 0 or screen_size.y <= 0:
		return result
	var scale_x = viewport_size.x / float(screen_size.x)
	var scale_y = viewport_size.y / float(screen_size.y)
	result["left"] = max(result["left"], float(safe_area.position.x) * scale_x + 8.0)
	result["top"] = max(result["top"], float(safe_area.position.y) * scale_y + 8.0)
	result["right"] = max(result["right"], float(screen_size.x - safe_area.position.x - safe_area.size.x) * scale_x + 8.0)
	result["bottom"] = max(result["bottom"], float(screen_size.y - safe_area.position.y - safe_area.size.y) * scale_y + 8.0)
	return result

static func _set_property_if_exists(node, property_name, value):
	for item in node.get_property_list():
		if str(item.get("name", "")) == property_name:
			node.set(property_name, value)
			return

static func _hide_scroll_bars(scroll):
	for bar in [scroll.get_v_scroll_bar(), scroll.get_h_scroll_bar()]:
		if bar == null:
			continue
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.modulate = Color(1.0, 1.0, 1.0, 0.0)
		bar.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
		bar.custom_minimum_size = Vector2.ZERO
		for key in ["scroll", "scroll_focus", "grabber", "grabber_highlight", "grabber_pressed"]:
			bar.add_theme_stylebox_override(key, StyleBoxEmpty.new())

static func _bind_touch_scroll(scroll, node):
	if node == null:
		return
	if node is Control:
		var meta_key = "_pokefish_touch_scroll_%s" % scroll.get_instance_id()
		if not node.has_meta(meta_key):
			node.set_meta(meta_key, true)
			node.gui_input.connect(func(event):
				if not is_instance_valid(scroll):
					return
				if event is InputEventScreenTouch:
					scroll.set_meta("_pokefish_touch_scroll_active_%d" % event.index, event.pressed)
				elif event is InputEventScreenDrag:
					if abs(event.relative.y) >= abs(event.relative.x):
						_apply_scroll_relative(scroll, event.relative)
						node.accept_event()
				elif event is InputEventPanGesture:
					if abs(event.delta.y) >= abs(event.delta.x):
						_apply_scroll_relative(scroll, event.delta)
						node.accept_event()
				elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
					if abs(event.relative.y) >= max(2.0, abs(event.relative.x)):
						_apply_scroll_relative(scroll, event.relative)
						node.accept_event()
			)
	for child in node.get_children():
		_bind_touch_scroll(scroll, child)
