extends Control
class_name PondView

const GameData = preload("res://godot/scripts/game_data.gd")
const FishArt = preload("res://godot/scripts/ui/fish_art.gd")
const TAP_THRESHOLD = 12.0
const FISH_TOP_CLEARANCE = 78.0
const FISH_BOTTOM_CLEARANCE = 92.0
const KENNEY_BUBBLE_TEXTURES = [
	preload("res://godot/assets/kenney_fish_pack/bubble_a.png"),
	preload("res://godot/assets/kenney_fish_pack/bubble_b.png"),
	preload("res://godot/assets/kenney_fish_pack/bubble_c.png"),
]
const KENNEY_SAND_TEXTURES = [
	preload("res://godot/assets/kenney_fish_pack/terrain_sand_a.png"),
	preload("res://godot/assets/kenney_fish_pack/terrain_sand_b.png"),
	preload("res://godot/assets/kenney_fish_pack/terrain_sand_c.png"),
	preload("res://godot/assets/kenney_fish_pack/terrain_sand_d.png"),
]
const KENNEY_SAND_TOP_TEXTURES = [
	preload("res://godot/assets/kenney_fish_pack/terrain_sand_top_a.png"),
	preload("res://godot/assets/kenney_fish_pack/terrain_sand_top_b.png"),
	preload("res://godot/assets/kenney_fish_pack/terrain_sand_top_c.png"),
	preload("res://godot/assets/kenney_fish_pack/terrain_sand_top_d.png"),
]
const KENNEY_ROCK_A = preload("res://godot/assets/kenney_fish_pack/rock_a.png")
const KENNEY_ROCK_B = preload("res://godot/assets/kenney_fish_pack/rock_b.png")
const KENNEY_SEAWEED_GREEN_A = preload("res://godot/assets/kenney_fish_pack/seaweed_green_a.png")
const KENNEY_SEAWEED_GREEN_B = preload("res://godot/assets/kenney_fish_pack/seaweed_green_b.png")
const KENNEY_SEAWEED_GREEN_C = preload("res://godot/assets/kenney_fish_pack/seaweed_green_c.png")
const KENNEY_SEAWEED_ORANGE_A = preload("res://godot/assets/kenney_fish_pack/seaweed_orange_a.png")
const KENNEY_SEAWEED_PINK_A = preload("res://godot/assets/kenney_fish_pack/seaweed_pink_a.png")

signal fish_selected(fish_id)

var state = {}
var active_pond_id = "starter"
var selected_fish_id = ""
var rng = RandomNumberGenerator.new()
var bubbles = []
var pending_tap = false
var pending_tap_distance = 0.0

func _ready():
	custom_minimum_size = Vector2(0, 320)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	rng.randomize()
	_create_bubbles()
	set_process(true)

func set_game_state(next_state, pond_id, fish_id):
	state = next_state
	active_pond_id = pond_id
	selected_fish_id = fish_id
	queue_redraw()

func _process(delta):
	if state.is_empty():
		return
	_update_swim(delta)
	queue_redraw()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pending_tap = true
			pending_tap_distance = 0.0
		else:
			_finish_tap(event.position)
	elif event is InputEventScreenTouch:
		if event.pressed:
			pending_tap = true
			pending_tap_distance = 0.0
		else:
			_finish_tap(event.position)
	elif event is InputEventMouseMotion and pending_tap:
		pending_tap_distance += event.relative.length()
	elif event is InputEventScreenDrag and pending_tap:
		pending_tap_distance += event.relative.length()

func _finish_tap(position):
	if not pending_tap:
		return
	pending_tap = false
	if pending_tap_distance >= TAP_THRESHOLD:
		return
	var hit = _hit_fish(position)
	if hit != "":
		fish_selected.emit(hit)

func _draw():
	var pond = GameData.pond_catalog().get(active_pond_id, GameData.pond_catalog()["starter"])
	var view_size = size
	var line = _color("#143137")
	draw_rect(Rect2(Vector2.ZERO, view_size), _color(pond["color_a"]), true)
	_draw_water_band(view_size, 0.32, _color("#72d4cf"), 10.0, 0.45)
	_draw_water_band(view_size, 0.72, _color(pond["color_b"]), 14.0, 0.62)
	_draw_soft_rays(view_size)
	_draw_light_lines(view_size)
	_draw_surface_foam(view_size)
	_draw_distant_fish(view_size)
	_draw_bubbles()
	_draw_floor(view_size, line)
	_draw_background_decor(view_size)
	var fish_list = state.get("fish", []).duplicate()
	fish_list.sort_custom(func(a, b): return float(a.get("swim", {}).get("depth", 1.0)) < float(b.get("swim", {}).get("depth", 1.0)))
	for fish in fish_list:
		var swim = fish.get("swim", {})
		var direction = 1 if float(swim.get("vx", 1.0)) >= 0.0 else -1
		var fish_scale = float(fish.get("appearance", {}).get("size", 1.0)) * float(swim.get("depth", 1.0))
		var pos = Vector2(float(swim.get("x", view_size.x * 0.5)), float(swim.get("y", view_size.y * 0.5)))
		pos.y = clamp(pos.y, _fish_min_y(view_size, fish_scale), max(_fish_min_y(view_size, fish_scale) + 42.0, view_size.y - FISH_BOTTOM_CLEARANCE))
		_draw_fish(fish, pos, fish_scale, direction, fish.get("id", "") == selected_fish_id)
	_draw_plants(view_size, line)

func has_kenney_decor():
	return KENNEY_BUBBLE_TEXTURES.size() == 3 and KENNEY_SAND_TEXTURES.size() == 4 and KENNEY_SAND_TOP_TEXTURES.size() == 4 and FishArt.has_assets()

func _create_bubbles():
	bubbles.clear()
	for _i in range(30):
		bubbles.append({
			"x": rng.randf_range(12.0, 360.0),
			"y": rng.randf_range(0.0, 420.0),
			"r": rng.randf_range(2.0, 7.0),
			"speed": rng.randf_range(16.0, 42.0),
			"wobble": rng.randf_range(0.0, TAU),
		})

func _update_swim(delta):
	var view_size = size
	for fish in state.get("fish", []):
		var swim = fish.get("swim", {})
		var appearance = fish.get("appearance", {})
		var wave = float(swim.get("wave", 0.0)) + delta * 4.8 * float(swim.get("wiggle", 1.0))
		var x = float(swim.get("x", view_size.x * 0.5)) + float(swim.get("vx", 26.0)) * delta
		var y = float(swim.get("y", view_size.y * 0.5)) + sin(wave * 0.7 + Time.get_ticks_msec() / 900.0) * delta * 24.0
		var fish_scale = float(appearance.get("size", 1.0)) * float(swim.get("depth", 1.0))
		var margin = 64.0 * fish_scale
		if x > view_size.x - margin:
			x = view_size.x - margin
			swim["vx"] = -abs(float(swim.get("vx", 26.0)))
		elif x < margin:
			x = margin
			swim["vx"] = abs(float(swim.get("vx", 26.0)))
		swim["x"] = x
		var min_y = _fish_min_y(view_size, fish_scale)
		swim["y"] = clamp(y, min_y, max(min_y + 42.0, view_size.y - FISH_BOTTOM_CLEARANCE))
		swim["wave"] = wave
		fish["swim"] = swim
	for bubble in bubbles:
		bubble["y"] = float(bubble["y"]) - float(bubble["speed"]) * delta
		bubble["x"] = float(bubble["x"]) + sin(Time.get_ticks_msec() / 700.0 + float(bubble["wobble"])) * delta * 8.0
		if float(bubble["y"]) < -20.0:
			bubble["y"] = view_size.y + rng.randf_range(8.0, 80.0)
			bubble["x"] = rng.randf_range(20.0, max(21.0, view_size.x - 20.0))
			bubble["r"] = rng.randf_range(2.0, 7.0)

func _hit_fish(position):
	var fish_list = state.get("fish", []).duplicate()
	fish_list.reverse()
	for fish in fish_list:
		var swim = fish.get("swim", {})
		var appearance = fish.get("appearance", {})
		var center = Vector2(float(swim.get("x", 0.0)), float(swim.get("y", 0.0)))
		var radius = 62.0 * float(appearance.get("size", 1.0)) * float(swim.get("depth", 1.0))
		if center.distance_to(position) < radius:
			return fish.get("id", "")
	return ""

func _fish_min_y(view_size, fish_scale):
	var safe = UiStyle.safe_insets(view_size)
	return safe["top"] + FISH_TOP_CLEARANCE + 34.0 * fish_scale

func _draw_water_band(view_size, start_ratio, fill, amplitude, phase):
	var points = PackedVector2Array()
	points.append(Vector2(0.0, view_size.y * start_ratio))
	for x in range(0, int(view_size.x) + 48, 24):
		var y = view_size.y * start_ratio + sin(x * 0.035 + Time.get_ticks_msec() / 900.0 + phase) * amplitude
		points.append(Vector2(x, y))
	points.append(Vector2(view_size.x, view_size.y))
	points.append(Vector2(0.0, view_size.y))
	draw_colored_polygon(points, fill)

func _draw_light_lines(view_size):
	for i in range(5):
		var points = PackedVector2Array()
		var y = 58.0 + i * 58.0
		for x in range(-28, int(view_size.x) + 32, 28):
			points.append(Vector2(x, y + sin(x * 0.04 + Time.get_ticks_msec() / 850.0 + i) * 6.0))
		draw_polyline(points, Color(1.0, 1.0, 1.0, 0.45), 3.0, true)

func _draw_soft_rays(view_size):
	var time = Time.get_ticks_msec() / 1800.0
	for i in range(4):
		var x = view_size.x * (0.12 + i * 0.25) + sin(time + i) * 14.0
		var top_width = 22.0 + i * 7.0
		var bottom_width = 72.0 + i * 16.0
		var ray = PackedVector2Array([
			Vector2(x - top_width, 0.0),
			Vector2(x + top_width, 0.0),
			Vector2(x + bottom_width, view_size.y * 0.72),
			Vector2(x - bottom_width, view_size.y * 0.72),
		])
		draw_colored_polygon(ray, Color(1.0, 1.0, 1.0, 0.035 + 0.01 * sin(time + i)))

func _draw_surface_foam(view_size):
	var time = Time.get_ticks_msec() / 760.0
	for i in range(9):
		var x = fmod(i * 57.0 + time * 12.0, view_size.x + 80.0) - 40.0
		var y = view_size.y * 0.32 + sin(i * 1.7 + time) * 9.0
		var radius = 2.2 + (i % 3) * 1.2
		draw_circle(Vector2(x, y), radius, Color(1.0, 1.0, 1.0, 0.42))
		draw_arc(Vector2(x, y), radius + 1.4, 0, TAU, 18, Color(1.0, 1.0, 1.0, 0.28), 1.0)

func _draw_distant_fish(view_size):
	var time = Time.get_ticks_msec() / 1400.0
	for i in range(4):
		var depth = 0.54 + i * 0.08
		var x = fmod(time * (18.0 + i * 4.0) + i * 112.0, view_size.x + 96.0) - 48.0
		if i % 2 == 1:
			x = view_size.x - x
		var y = view_size.y * depth + sin(time + i * 1.3) * 12.0
		var scale = 0.42 + i * 0.06
		var alpha = 0.08 + i * 0.015
		var color = Color(0.04, 0.28, 0.36, alpha)
		var direction = 1 if i % 2 == 0 else -1
		var center = Vector2(x, y)
		_draw_ellipse(center, Vector2(34.0, 13.0) * scale, color, Color(0, 0, 0, 0), 0.0)
		var tail = PackedVector2Array([
			center + Vector2(-direction * 21.0 * scale, 0.0),
			center + Vector2(-direction * 38.0 * scale, -11.0 * scale),
			center + Vector2(-direction * 32.0 * scale, 0.0),
			center + Vector2(-direction * 38.0 * scale, 11.0 * scale),
		])
		draw_colored_polygon(tail, color)

func _draw_bubbles():
	for i in range(bubbles.size()):
		var bubble = bubbles[i]
		var center = Vector2(float(bubble["x"]), float(bubble["y"]))
		var texture = KENNEY_BUBBLE_TEXTURES[i % KENNEY_BUBBLE_TEXTURES.size()]
		var bubble_size = clamp(float(bubble["r"]) * 5.7, 16.0, 42.0)
		var texture_size = Vector2.ONE * bubble_size
		var rect = Rect2(center - texture_size * 0.5, texture_size)
		draw_texture_rect(texture, rect, false, Color(1.0, 1.0, 1.0, 0.72))

func _draw_floor(view_size, line):
	var top = view_size.y - 48.0
	var points = PackedVector2Array()
	points.append(Vector2(-10.0, top + 14.0))
	for x in range(-10, int(view_size.x) + 44, 32):
		points.append(Vector2(x, top + sin(x * 0.05) * 6.0))
	points.append(Vector2(view_size.x + 12.0, view_size.y + 12.0))
	points.append(Vector2(-12.0, view_size.y + 12.0))
	draw_colored_polygon(points, _color("#f4d58a"))
	var fill_rect = Rect2(0.0, top + 34.0, view_size.x, max(24.0, view_size.y - top + 20.0))
	draw_texture_rect(KENNEY_SAND_TEXTURES[0], fill_rect, true, Color(1.0, 1.0, 1.0, 0.26))
	var tile_index = 0
	for x in range(-24, int(view_size.x) + 96, 70):
		var texture = KENNEY_SAND_TOP_TEXTURES[tile_index % KENNEY_SAND_TOP_TEXTURES.size()]
		var tile_size = Vector2(88.0, 88.0)
		var tile_y = top - 2.0 + sin(float(x) * 0.045) * 3.5
		draw_texture_rect(texture, Rect2(Vector2(float(x), tile_y), tile_size), false, Color(1.0, 1.0, 1.0, 0.94))
		tile_index += 1
	var closed = PackedVector2Array(points)
	closed.append(points[0])
	draw_polyline(closed, line, 3.0, true)

func _draw_background_decor(view_size):
	var base_y = view_size.y - 42.0
	var decor = [
		[KENNEY_SEAWEED_GREEN_B, 0.16, 0.42, 0.34],
		[KENNEY_SEAWEED_GREEN_C, 0.39, 0.32, 0.26],
		[KENNEY_SEAWEED_PINK_A, 0.63, 0.36, 0.28],
		[KENNEY_SEAWEED_GREEN_A, 0.86, 0.38, 0.3],
	]
	for i in range(decor.size()):
		var item = decor[i]
		var x = view_size.x * float(item[1])
		var y = base_y + sin(Time.get_ticks_msec() / 900.0 + i) * 2.0
		_draw_texture_bottom(item[0], Vector2(x, y), float(item[2]), Color(1.0, 1.0, 1.0, float(item[3])))

func _draw_plants(view_size, _line):
	var base_y = view_size.y - 18.0
	var decor = [
		[KENNEY_SEAWEED_GREEN_A, 0.06, 0.6, 0.96],
		[KENNEY_ROCK_A, 0.22, 0.46, 0.86],
		[KENNEY_SEAWEED_ORANGE_A, 0.31, 0.52, 0.95],
		[KENNEY_SEAWEED_GREEN_B, 0.48, 0.67, 0.98],
		[KENNEY_ROCK_B, 0.62, 0.52, 0.88],
		[KENNEY_SEAWEED_PINK_A, 0.73, 0.62, 0.94],
		[KENNEY_SEAWEED_GREEN_C, 0.91, 0.55, 0.96],
	]
	for i in range(decor.size()):
		var item = decor[i]
		var sway = sin(Time.get_ticks_msec() / 760.0 + i) * 2.5
		var base = Vector2(view_size.x * float(item[1]) + sway, base_y)
		_draw_texture_bottom(item[0], base, float(item[2]), Color(1.0, 1.0, 1.0, float(item[3])))

func _draw_texture_bottom(texture, bottom_center, scale, modulate):
	var texture_size = texture.get_size() * scale
	var rect = Rect2(Vector2(bottom_center.x - texture_size.x * 0.5, bottom_center.y - texture_size.y), texture_size)
	draw_texture_rect(texture, rect, false, modulate)

func _draw_fish(fish, pos, fish_scale, direction, selected):
	FishArt.draw(self, fish, pos, Vector2(118.0, 82.0) * fish_scale, direction, selected)
	return
	var app = fish.get("appearance", {})
	var line = _color("#143137")
	var body = _color(app.get("bodyColor", "#58b7d8"))
	var accent = _color(app.get("accentColor", "#ffffff"))
	var fin = _color(app.get("finColor", "#7fd8b7"))
	var s = 0.9 * fish_scale
	var phase = float(fish.get("swim", {}).get("wave", 0.0))
	var wiggle = sin(phase) * 6.0 * s
	var body_size = Vector2(50.0, 30.0)
	if app.get("body", "oval") == "round":
		body_size = Vector2(42.0, 38.0)
	elif app.get("body", "oval") == "slender":
		body_size = Vector2(60.0, 24.0)
	var center = pos + Vector2(direction * 4.0 * s, sin(phase * 0.45) * 1.8 * s)
	_draw_ellipse(pos + Vector2(0, 24 * s), Vector2(54 * s, 10 * s), Color(0.03, 0.14, 0.2, 0.12), Color(0, 0, 0, 0), 0.0)
	if selected:
		var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 260.0)
		_draw_ellipse(pos + Vector2(0, 7 * s), Vector2((72 + pulse * 12) * s, (40 + pulse * 7) * s), Color(0.95, 0.72, 0.28, 0.18), Color(1.0, 0.84, 0.22, 0.22), 2.0 * s)
		_draw_ellipse(pos + Vector2(0, 7 * s), Vector2((90 + pulse * 18) * s, (50 + pulse * 10) * s), Color(0, 0, 0, 0), Color(1.0, 1.0, 1.0, 0.22 - pulse * 0.1), 1.6 * s)
	if bool(app.get("glow", false)):
		_draw_ellipse(center, Vector2(88 * s, 52 * s), Color(accent.r, accent.g, accent.b, 0.16), Color(0, 0, 0, 0), 0.0)
	_draw_tail(app.get("tail", "fork"), center, body_size, s, direction, wiggle, fin, line)
	_draw_side_fin(center, body_size, s, direction, fin, line)
	_draw_top_fin(center, body_size, s, direction, fin, line)
	_draw_ellipse(center, body_size * s, body, line, max(2.8, 4.0 * s))
	_draw_ellipse(center + Vector2(direction * 8 * s, -8 * s), Vector2(body_size.x * 0.58, body_size.y * 0.32) * s, Color(1.0, 1.0, 1.0, 0.18), Color(0, 0, 0, 0), 0.0)
	_draw_pattern(app.get("pattern", "dots"), center, s, direction, accent, line, body_size)
	var eye_pos = center + Vector2(direction * body_size.x * 0.58 * s, -body_size.y * 0.32 * s)
	draw_circle(eye_pos, 7.5 * s, Color.WHITE)
	draw_arc(eye_pos, 7.5 * s, 0.0, TAU, 24, line, max(1.7, 2.5 * s), true)
	draw_circle(eye_pos + Vector2(direction * 2.5 * s, 1.0 * s), 3.0 * s, _color("#172326"))
	draw_line(center + Vector2(direction * body_size.x * 0.36 * s, -5 * s), center + Vector2(direction * body_size.x * 0.31 * s, 10 * s), Color(line.r, line.g, line.b, 0.42), max(1.2, 1.8 * s), true)
	draw_arc(center + Vector2(direction * body_size.x * 0.72 * s, 4 * s), 7.0 * s, 0.15 * PI if direction > 0 else 0.85 * PI, 0.45 * PI if direction > 0 else 1.15 * PI, 10, line, max(1.1, 1.6 * s), true)
	draw_circle(center + Vector2(direction * body_size.x * 0.42 * s, 12 * s), 5.0 * s, Color(1.0, 0.55, 0.64, 0.38))

func _draw_tail(kind, center, body_size, s, direction, wiggle, fin, line):
	var root = center + Vector2(-direction * body_size.x * 0.84 * s, wiggle * 0.3)
	if kind == "round":
		_draw_ellipse(root + Vector2(-direction * 26 * s, wiggle * 0.45), Vector2(22 * s, 25 * s), fin.lightened(0.08), line, max(2.0, 3.0 * s))
		return
	var tail
	if kind == "veil":
		tail = PackedVector2Array([
			root + Vector2(direction * 4 * s, -11 * s),
			root + Vector2(-direction * 42 * s, -31 * s + wiggle),
			root + Vector2(-direction * 34 * s, 0),
			root + Vector2(-direction * 45 * s, 32 * s + wiggle),
			root + Vector2(direction * 5 * s, 13 * s),
		])
	else:
		tail = PackedVector2Array([
			root,
			root + Vector2(-direction * 38 * s, -27 * s + wiggle),
			root + Vector2(-direction * 24 * s, 0),
			root + Vector2(-direction * 38 * s, 27 * s + wiggle),
		])
	draw_colored_polygon(tail, fin.lightened(0.08))
	var closed = PackedVector2Array(tail)
	closed.append(tail[0])
	draw_polyline(closed, line, max(2.2, 3.4 * s), true)

func _draw_top_fin(center, body_size, s, direction, fin, line):
	var top = center + Vector2(-direction * body_size.x * 0.08 * s, -body_size.y * 0.7 * s)
	var top_fin = PackedVector2Array([
		top + Vector2(-direction * 14 * s, 7 * s),
		top + Vector2(direction * 7 * s, -24 * s),
		top + Vector2(direction * 25 * s, 8 * s),
	])
	draw_colored_polygon(top_fin, fin.lightened(0.16))
	var closed = PackedVector2Array(top_fin)
	closed.append(top_fin[0])
	draw_polyline(closed, line, max(1.8, 2.6 * s), true)

func _draw_side_fin(center, body_size, s, direction, fin, line):
	var side = center + Vector2(direction * body_size.x * 0.08 * s, body_size.y * 0.34 * s)
	var side_fin = PackedVector2Array([
		side + Vector2(-direction * 4 * s, -4 * s),
		side + Vector2(direction * 20 * s, 12 * s),
		side + Vector2(-direction * 8 * s, 23 * s),
	])
	draw_colored_polygon(side_fin, fin.lightened(0.2))
	var closed = PackedVector2Array(side_fin)
	closed.append(side_fin[0])
	draw_polyline(closed, line, max(1.4, 2.0 * s), true)

func _draw_pattern(pattern, pos, s, direction, accent, line, body_size := Vector2(45.0, 29.0)):
	if pattern == "stripes" or pattern == "sunburst":
		for i in range(-2, 3):
			var x = i * 10.0 * s
			draw_line(pos + Vector2(x, -body_size.y * 0.48 * s), pos + Vector2(x + direction * 7 * s, body_size.y * 0.48 * s), Color(line.r, line.g, line.b, 0.48), max(1.2, 1.8 * s), true)
	elif pattern == "stars":
		for i in range(4):
			draw_circle(pos + Vector2(direction * (-18 + i * 12) * s, sin(i) * 9 * s), 3.4 * s, accent)
	elif pattern == "glass":
		_draw_ellipse(pos + Vector2(-direction * 4 * s, 2 * s), Vector2(body_size.x * 0.46, body_size.y * 0.42) * s, Color(1.0, 1.0, 1.0, 0.2), Color(accent.r, accent.g, accent.b, 0.36), 1.0 * s)
		for i in range(3):
			draw_circle(pos + Vector2(direction * (-16 + i * 16) * s, (-4 + i % 2 * 8) * s), 2.7 * s, Color(1.0, 1.0, 1.0, 0.42))
	elif pattern == "scales":
		for row in range(2):
			for i in range(4):
				var p = pos + Vector2(direction * (-18 + i * 11) * s, (-8 + row * 12) * s)
				draw_arc(p, 4.4 * s, 0.0, PI, 12, Color(line.r, line.g, line.b, 0.32), max(0.9, 1.2 * s), true)
	elif pattern == "pearls":
		for i in range(4):
			var p = pos + Vector2(direction * (-16 + i * 12) * s, sin(i * 1.4) * 7 * s)
			draw_circle(p, 3.2 * s, Color(1.0, 1.0, 1.0, 0.8))
			draw_arc(p, 3.2 * s, 0, TAU, 16, Color(line.r, line.g, line.b, 0.36), max(0.8, 1.0 * s), true)
	elif pattern == "petals":
		for i in range(4):
			_draw_ellipse(pos + Vector2(direction * (-18 + i * 12) * s, sin(i) * 8 * s), Vector2(4.0 * s, 8.0 * s), accent, line, 1.2 * s)
	elif pattern == "spikes":
		for i in range(-2, 3):
			var spike = PackedVector2Array([
				pos + Vector2(i * 11.0 * s, -23.0 * s),
				pos + Vector2((i * 11.0 + 5.0) * s, -36.0 * s),
				pos + Vector2((i * 11.0 + 10.0) * s, -22.0 * s),
			])
			draw_colored_polygon(spike, accent)
			var closed = PackedVector2Array(spike)
			closed.append(spike[0])
			draw_polyline(closed, line, 1.6 * s, true)
	elif pattern == "lantern":
		draw_circle(pos + Vector2(direction * 38.0 * s, -18.0 * s), 5.5 * s, _color("#d8fff5"))
	else:
		for i in range(6):
			draw_circle(pos + Vector2(direction * (-18 + i * 9) * s, sin(i) * 8 * s), 3.0 * s, accent)

func _draw_ellipse(center, radii, fill, stroke, stroke_width):
	draw_set_transform(center, 0.0, radii)
	draw_circle(Vector2.ZERO, 1.0, fill)
	if stroke_width > 0.0 and stroke.a > 0.0:
		draw_arc(Vector2.ZERO, 1.0, 0.0, TAU, 48, stroke, stroke_width / max(1.0, max(radii.x, radii.y)), true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _color(hex):
	return Color.html(str(hex).replace("#", ""))
