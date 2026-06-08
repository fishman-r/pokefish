extends Control
class_name FxLayer

var rng = RandomNumberGenerator.new()

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rng.randomize()

func show_toast(text):
	var panel = UiComponents.toast_card(text)
	add_child(panel)
	var viewport_size = get_viewport_rect().size
	var safe = UiStyle.safe_insets(viewport_size)
	var panel_width = clamp(96.0 + str(text).length() * 7.0, 146.0, viewport_size.x - 40.0)
	panel.custom_minimum_size = Vector2(panel_width, 34)
	panel.size = panel.custom_minimum_size
	panel.position = Vector2((viewport_size.x - panel_width) * 0.5, safe["top"] + 76.0)
	panel.modulate.a = 1.0
	panel.scale = Vector2(0.94, 0.94)
	panel.pivot_offset = panel.size * 0.5
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.72)
	tween.tween_property(panel, "modulate:a", 0.0, 0.18)
	tween.tween_callback(panel.queue_free)
	return panel

func show_result(title, body, color := UiStyle.REWARD):
	var card = UiComponents.result_card(title, body, color)
	add_child(card)
	var viewport_size = get_viewport_rect().size
	var safe = UiStyle.safe_insets(viewport_size)
	var card_width = viewport_size.x - safe["left"] - safe["right"] - 24.0
	var card_height = clamp(58.0 + ceil(str(body).length() / 26.0) * 10.0, 64.0, 86.0)
	card.custom_minimum_size = Vector2(card_width, card_height)
	card.size = card.custom_minimum_size
	card.position = Vector2(safe["left"] + 12.0, safe["top"] + 76.0)
	card.scale = Vector2(0.96, 0.96)
	card.pivot_offset = card.size * 0.5
	card.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(card, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.95)
	tween.tween_property(card, "modulate:a", 0.0, 0.18)
	tween.tween_callback(card.queue_free)
	return card

func play_resource_fly(from_position, to_position, resource_type := "bubbleCoins", amount := 8):
	var color = UiStyle.WATER
	if typeof(resource_type) == TYPE_COLOR:
		color = resource_type
	else:
		color = UiStyle.resource_color(str(resource_type))
	play_resource_burst(from_position, to_position, color, clamp(int(amount), 1, 24))

func play_resource_burst(from_position, to_position, color := UiStyle.RESOURCE, count := 8):
	for i in range(count):
		var dot = _fx_dot(color, 12)
		dot.size = Vector2(12, 12)
		dot.position = from_position + Vector2(rng.randf_range(-28, 28), rng.randf_range(-18, 18))
		add_child(dot)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(dot, "position", to_position + Vector2(rng.randf_range(-12, 12), rng.randf_range(-8, 8)), 0.55 + i * 0.025).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(dot, "modulate:a", 0.0, 0.55 + i * 0.025)
		tween.chain().tween_callback(dot.queue_free)

func play_water_ripple(position, color := UiStyle.RESOURCE, max_size := 112.0):
	var ring = Control.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.size = Vector2(max_size, max_size)
	ring.position = position - ring.size * 0.5
	ring.scale = Vector2(0.18, 0.18)
	ring.pivot_offset = ring.size * 0.5
	ring.modulate.a = 0.82
	ring.draw.connect(func():
		var center = ring.size * 0.5
		var radius = min(ring.size.x, ring.size.y) * 0.34
		ring.draw_arc(center, radius, 0, TAU, 42, color, 3.0)
		ring.draw_arc(center, radius * 0.62, 0, TAU, 36, color.lightened(0.18), 1.8)
		ring.draw_circle(center, radius * 0.12, Color(1, 1, 1, 0.35))
	)
	add_child(ring)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2.ONE, 0.46).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.46).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(ring.queue_free)

func play_screen_flash(color := UiStyle.CONFIRM, duration := 0.28):
	var flash = ColorRect.new()
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(color.r, color.g, color.b, 0.16)
	add_child(flash)
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(flash.queue_free)

func play_food_throw(from_position, to_position, color := UiStyle.COST):
	var pellet = Control.new()
	pellet.custom_minimum_size = Vector2(24, 24)
	pellet.size = Vector2(24, 24)
	pellet.position = from_position - pellet.size * 0.5
	pellet.scale = Vector2(0.6, 0.6)
	pellet.draw.connect(func():
		var center = pellet.size * 0.5
		pellet.draw_circle(center, 11, color)
		pellet.draw_arc(center, 11, 0, TAU, 32, UiStyle.INK, 2.5)
		pellet.draw_circle(center + Vector2(4, -3), 3, UiStyle.REWARD)
	)
	add_child(pellet)
	var mid = (from_position + to_position) * 0.5 + Vector2(0, -96) - pellet.size * 0.5
	var target = to_position - pellet.size * 0.5
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(pellet, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(pellet, "position", mid, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(pellet, "position", target, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(pellet, "scale", Vector2(0.25, 0.25), 0.08)
	tween.parallel().tween_property(pellet, "modulate:a", 0.0, 0.08)
	tween.tween_callback(pellet.queue_free)

func _fx_dot(color, diameter):
	var dot = Control.new()
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.custom_minimum_size = Vector2(diameter, diameter)
	dot.draw.connect(func():
		var center = dot.size * 0.5
		var radius = min(dot.size.x, dot.size.y) * 0.46
		dot.draw_circle(center, radius, color)
		dot.draw_circle(center + Vector2(-radius * 0.22, -radius * 0.24), radius * 0.22, Color(1, 1, 1, 0.55))
		dot.draw_arc(center, radius, 0, TAU, 20, UiStyle.INK, max(1.1, radius * 0.16))
	)
	dot.resized.connect(func(): dot.queue_redraw())
	return dot
