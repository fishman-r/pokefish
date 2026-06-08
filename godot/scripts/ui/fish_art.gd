extends RefCounted
class_name FishArt

const FISH_BLUE = preload("res://godot/assets/pixel_fish_pack/fish_blue_pixel.png")
const FISH_GREEN = preload("res://godot/assets/pixel_fish_pack/fish_green_pixel.png")
const FISH_ORANGE = preload("res://godot/assets/pixel_fish_pack/fish_orange_pixel.png")
const FISH_PINK = preload("res://godot/assets/pixel_fish_pack/fish_pink_pixel.png")
const FISH_RED = preload("res://godot/assets/pixel_fish_pack/fish_red_pixel.png")
const FISH_BROWN = preload("res://godot/assets/pixel_fish_pack/fish_brown_pixel.png")
const FISH_GREY = preload("res://godot/assets/pixel_fish_pack/fish_grey_pixel.png")
const FISH_GREY_LONG_A = preload("res://godot/assets/pixel_fish_pack/fish_grey_long_a_pixel.png")
const FISH_GREY_LONG_B = preload("res://godot/assets/pixel_fish_pack/fish_grey_long_b_pixel.png")
const FISH_MOONVEIL = preload("res://godot/assets/pixel_fish_pack/fish_moonveil_pixel.png")
const FISH_CORALBLOOM = preload("res://godot/assets/pixel_fish_pack/fish_coralbloom_pixel.png")
const FISH_ABYSS = preload("res://godot/assets/pixel_fish_pack/fish_abyss_pixel.png")
const FISH_THORNCREST = preload("res://godot/assets/pixel_fish_pack/fish_thorncrest_pixel.png")
const FISH_DRAGONWAKE = preload("res://godot/assets/pixel_fish_pack/fish_dragonwake_pixel.png")

static func has_assets():
	for texture in [FISH_BLUE, FISH_GREEN, FISH_ORANGE, FISH_PINK, FISH_RED, FISH_BROWN, FISH_GREY, FISH_GREY_LONG_A, FISH_GREY_LONG_B, FISH_MOONVEIL, FISH_CORALBLOOM, FISH_ABYSS, FISH_THORNCREST, FISH_DRAGONWAKE]:
		if texture == null or texture.get_size().x <= 0.0:
			return false
	return true

static func texture_for(fish, known := true):
	if not known:
		return FISH_GREY_LONG_A
	var app = fish.get("appearance", {})
	var form_id = str(app.get("formId", "base"))
	if form_id != "" and form_id != "base":
		return _texture_for_form(form_id, fish)
	var species_id = str(fish.get("speciesId", ""))
	if species_id == "blue_minifish":
		return FISH_BLUE
	if species_id == "sun_koi":
		return FISH_ORANGE
	if species_id == "bubble_puffer":
		return FISH_GREEN
	if species_id == "lantern_fry":
		return FISH_GREY_LONG_B
	if species_id == "ribbon_betta":
		return FISH_PINK

	var color = _html_color(app.get("bodyColor", "#58b7d8"))
	if color.r > 0.72 and color.g < 0.48 and color.b < 0.5:
		return FISH_RED
	if color.r > 0.72 and color.g > 0.42 and color.b < 0.42:
		return FISH_ORANGE
	if color.g > color.r and color.g > color.b:
		return FISH_GREEN
	if color.r > 0.52 and color.b > 0.52:
		return FISH_PINK
	if color.b > color.r and color.b > color.g:
		return FISH_BLUE
	return FISH_BROWN

static func _texture_for_form(form_id, fish):
	match form_id:
		"moonveil":
			return FISH_MOONVEIL
		"coralbloom":
			return FISH_CORALBLOOM
		"abyss":
			return FISH_ABYSS
		"thorncrest":
			return FISH_THORNCREST
		"dragonwake":
			return FISH_DRAGONWAKE
		_:
			return FISH_BROWN

static func make_icon(fish, known := true, min_size := Vector2(72, 48), selected := false):
	var node = Control.new()
	node.custom_minimum_size = min_size
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.draw.connect(func():
		var pad = Vector2(5.0, 5.0)
		var draw_size = Vector2(max(1.0, node.size.x - pad.x), max(1.0, node.size.y - pad.y))
		FishArt.draw(node, fish, node.size * 0.5, draw_size, 1, selected, 1.0, known)
	)
	node.resized.connect(func(): node.queue_redraw())
	return node

static func draw(canvas, fish, center, max_size, direction := 1, selected := false, alpha := 1.0, known := true):
	if canvas == null:
		return
	var texture = texture_for(fish, known)
	if texture == null:
		return
	var texture_size = texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var size = _fit(texture_size, max_size)
	var phase = float(fish.get("swim", {}).get("wave", 0.0))
	var dir = 1 if direction >= 0 else -1
	var bob = Vector2(0.0, sin(phase * 0.45) * max_size.y * 0.025)
	var pos = _round_vec(center + bob)
	_draw_pixel_shadow(canvas, pos, size, alpha)

	var modulate = Color(1.0, 1.0, 1.0, alpha) if known else Color(0.2, 0.27, 0.34, 0.66 * alpha)
	canvas.draw_set_transform(pos, 0.0, Vector2(float(dir), 1.0))
	canvas.draw_texture_rect(texture, Rect2(_round_vec(-size * 0.5), size), false, modulate)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func _fit(texture_size, max_size):
	var scale = min(float(max_size.x) / max(1.0, float(texture_size.x)), float(max_size.y) / max(1.0, float(texture_size.y)))
	if scale >= 1.0:
		scale = max(1.0, floor(scale))
	var size = texture_size * scale
	if size.x > max_size.x or size.y > max_size.y:
		var shrink = min(float(max_size.x) / max(1.0, float(texture_size.x)), float(max_size.y) / max(1.0, float(texture_size.y)))
		size = texture_size * shrink
	return _round_vec(Vector2(max(1.0, size.x), max(1.0, size.y)))

static func _round_vec(value):
	return Vector2(round(value.x), round(value.y))

static func _pixel_unit(size):
	return max(2.0, round(min(size.x, size.y) / 18.0))

static func _draw_pixel_shadow(canvas, pos, size, alpha):
	var unit = _pixel_unit(size)
	var shadow = Color(0.03, 0.1, 0.16, 0.12 * alpha)
	var y = round(pos.y + size.y * 0.34)
	var w = round(size.x * 0.52)
	canvas.draw_rect(Rect2(Vector2(round(pos.x - w * 0.5), y), Vector2(w, unit)), shadow, true)
	canvas.draw_rect(Rect2(Vector2(round(pos.x - w * 0.34), y + unit), Vector2(round(w * 0.68), unit)), Color(shadow.r, shadow.g, shadow.b, shadow.a * 0.74), true)

static func _html_color(hex):
	return Color.html(str(hex).replace("#", ""))
