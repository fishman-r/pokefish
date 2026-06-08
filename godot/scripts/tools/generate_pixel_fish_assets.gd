extends SceneTree

const OUT_DIR = "res://godot/assets/pixel_fish_pack"
const W = 48
const H = 32

func _init():
	call_deferred("_run")

func _run():
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_save("fish_blue_pixel.png", Color.html("2f8fd6"), Color.html("66d0f0"), "oval", "dots")
	_save("fish_green_pixel.png", Color.html("2bbf6a"), Color.html("72e09b"), "round", "spots")
	_save("fish_orange_pixel.png", Color.html("f28b22"), Color.html("ffd166"), "oval", "stripe")
	_save("fish_pink_pixel.png", Color.html("d86bd9"), Color.html("ff9bd7"), "veil", "spark")
	_save("fish_red_pixel.png", Color.html("e34a4a"), Color.html("ff9a68"), "oval", "coral")
	_save("fish_brown_pixel.png", Color.html("9a6a3a"), Color.html("d6a15b"), "long", "scale")
	_save("fish_grey_pixel.png", Color.html("7b8794"), Color.html("b7c0ca"), "oval", "plain")
	_save("fish_grey_long_a_pixel.png", Color.html("66717e"), Color.html("aeb9c4"), "long", "plain")
	_save("fish_grey_long_b_pixel.png", Color.html("445e86"), Color.html("62d6e8"), "long", "lamp")
	_save("fish_moonveil_pixel.png", Color.html("b96de4"), Color.html("a5f3ff"), "veil", "spark")
	_save("fish_coralbloom_pixel.png", Color.html("f45f5f"), Color.html("ffd36f"), "round", "coral")
	_save("fish_abyss_pixel.png", Color.html("203b6d"), Color.html("54ffe4"), "long", "lamp")
	_save("fish_thorncrest_pixel.png", Color.html("38bc72"), Color.html("ff704a"), "spike", "thorn")
	_save("fish_dragonwake_pixel.png", Color.html("f2a733"), Color.html("ff5a3c"), "dragon", "scale")
	quit(0)

func _save(filename, body, accent, shape, pattern):
	var image = Image.create(W, H, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_fish(image, body, accent, shape, pattern)
	var path = "%s/%s" % [OUT_DIR, filename]
	var err = image.save_png(path)
	if err != OK:
		push_error("Pixel fish asset save failed: %s" % path)
		quit(1)

func _draw_fish(image, body, accent, shape, pattern):
	var ink = Color.html("0b1728")
	var shade = body.darkened(0.22)
	var light = body.lightened(0.28)
	_draw_shadow(image)
	if shape == "long" or shape == "dragon":
		_body_long(image, body, shade, light, ink)
	elif shape == "round":
		_body_round(image, body, shade, light, ink)
	elif shape == "veil":
		_body_veil(image, body, shade, light, ink)
	elif shape == "spike":
		_body_spike(image, body, shade, light, ink)
	else:
		_body_oval(image, body, shade, light, ink)
	_apply_pattern(image, accent, ink, pattern)
	_draw_eye(image, ink)

func _draw_shadow(image):
	_rect(image, 15, 24, 21, 2, Color(0.03, 0.08, 0.12, 0.18))
	_rect(image, 18, 26, 14, 1, Color(0.03, 0.08, 0.12, 0.12))

func _body_oval(image, body, shade, light, ink):
	_tail(image, body, shade, ink, 12, 12)
	_rect(image, 15, 9, 18, 2, ink)
	_rect(image, 12, 11, 25, 2, ink)
	_rect(image, 10, 13, 29, 6, ink)
	_rect(image, 12, 19, 25, 2, ink)
	_rect(image, 15, 21, 18, 2, ink)
	_rect(image, 15, 11, 18, 10, body)
	_rect(image, 12, 13, 25, 6, body)
	_rect(image, 26, 11, 8, 10, light)
	_rect(image, 16, 19, 13, 2, shade)
	_fin(image, 21, 7, body.lightened(0.12), ink)
	_fin(image, 22, 21, shade, ink)

func _body_round(image, body, shade, light, ink):
	_tail(image, body, shade, ink, 10, 13)
	_rect(image, 14, 8, 18, 2, ink)
	_rect(image, 11, 10, 25, 3, ink)
	_rect(image, 9, 13, 29, 8, ink)
	_rect(image, 11, 21, 25, 3, ink)
	_rect(image, 14, 24, 18, 2, ink)
	_rect(image, 14, 10, 18, 14, body)
	_rect(image, 11, 13, 25, 8, body)
	_rect(image, 27, 11, 6, 12, light)
	_rect(image, 14, 21, 14, 3, shade)
	_fin(image, 20, 6, body.lightened(0.12), ink)

func _body_long(image, body, shade, light, ink):
	_tail(image, body, shade, ink, 13, 13)
	_rect(image, 14, 10, 24, 2, ink)
	_rect(image, 11, 12, 30, 2, ink)
	_rect(image, 10, 14, 32, 5, ink)
	_rect(image, 11, 19, 30, 2, ink)
	_rect(image, 14, 21, 24, 2, ink)
	_rect(image, 14, 12, 24, 9, body)
	_rect(image, 11, 14, 30, 5, body)
	_rect(image, 29, 12, 8, 9, light)
	_rect(image, 15, 19, 16, 2, shade)
	_fin(image, 23, 8, body.lightened(0.12), ink)

func _body_veil(image, body, shade, light, ink):
	_tail(image, body, shade, ink, 13, 10)
	_rect(image, 5, 8, 6, 3, shade)
	_rect(image, 4, 12, 8, 3, body.lightened(0.1))
	_rect(image, 5, 17, 7, 4, body.lightened(0.2))
	_body_oval(image, body, shade, light, ink)
	_rect(image, 5, 8, 2, 13, ink)
	_rect(image, 7, 9, 2, 12, body.lightened(0.22))
	_rect(image, 9, 11, 2, 8, body.lightened(0.12))

func _body_spike(image, body, shade, light, ink):
	_body_oval(image, body, shade, light, ink)
	for x in [18, 23, 28, 33]:
		_rect(image, x, 6, 3, 3, ink)
		_rect(image, x + 1, 5, 1, 1, ink)
		_rect(image, x + 1, 7, 1, 2, body.lightened(0.16))

func _tail(image, body, shade, ink, x, y):
	_rect(image, x - 7, y + 2, 8, 2, ink)
	_rect(image, x - 9, y, 5, 2, ink)
	_rect(image, x - 9, y + 6, 5, 2, ink)
	_rect(image, x - 7, y + 3, 6, 4, shade)
	_rect(image, x - 8, y + 1, 4, 1, body.lightened(0.12))
	_rect(image, x - 8, y + 7, 4, 1, body.lightened(0.12))

func _fin(image, x, y, color, ink):
	_rect(image, x, y, 7, 2, ink)
	_rect(image, x + 2, y - 1, 3, 1, ink)
	_rect(image, x + 1, y, 5, 2, color)

func _draw_eye(image, ink):
	_rect(image, 33, 13, 5, 5, ink)
	_rect(image, 34, 14, 3, 3, Color.WHITE)
	_rect(image, 36, 15, 1, 1, ink)

func _apply_pattern(image, accent, ink, pattern):
	match pattern:
		"dots":
			for p in [Vector2i(18, 14), Vector2i(23, 17), Vector2i(28, 14)]:
				_rect(image, p.x, p.y, 2, 2, accent)
		"spots":
			_rect(image, 17, 13, 5, 4, accent.darkened(0.08))
			_rect(image, 25, 16, 4, 3, accent.darkened(0.04))
		"stripe":
			for x in [18, 24, 30]:
				_rect(image, x, 12, 2, 9, accent)
		"spark":
			for p in [Vector2i(17, 12), Vector2i(23, 15), Vector2i(29, 18)]:
				_rect(image, p.x, p.y, 2, 2, accent)
				_rect(image, p.x + 1, p.y - 1, 1, 4, Color.WHITE)
		"coral":
			_rect(image, 18, 12, 2, 7, accent)
			_rect(image, 20, 13, 4, 2, accent)
			_rect(image, 27, 12, 2, 8, accent.lightened(0.1))
		"lamp":
			_rect(image, 36, 8, 2, 5, ink)
			_rect(image, 37, 6, 3, 3, accent)
			_rect(image, 38, 7, 1, 1, Color.WHITE)
			_rect(image, 19, 15, 12, 2, accent.darkened(0.1))
		"thorn":
			for x in [16, 22, 28]:
				_rect(image, x, 21, 3, 3, accent)
		"scale":
			for x in [17, 22, 27, 32]:
				_rect(image, x, 14, 3, 2, accent)
				_rect(image, x + 1, 16, 3, 2, accent.lightened(0.1))
		_:
			pass

func _rect(image, x, y, w, h, color):
	for yy in range(y, y + h):
		if yy < 0 or yy >= H:
			continue
		for xx in range(x, x + w):
			if xx < 0 or xx >= W:
				continue
			image.set_pixel(xx, yy, color)
