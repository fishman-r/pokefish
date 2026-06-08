extends SceneTree

const OUT_PATH = "res://godot/build/qa_snapshots/pixel_fish_sheet.png"
const SCALE = 3
const CELL = Vector2i(180, 120)
const COLUMNS = 2
const BG = Color(0.85, 0.96, 1.0, 1.0)

const FISH_ASSETS = [
	["blue", "res://godot/assets/pixel_fish_pack/fish_blue_pixel.png"],
	["green", "res://godot/assets/pixel_fish_pack/fish_green_pixel.png"],
	["orange", "res://godot/assets/pixel_fish_pack/fish_orange_pixel.png"],
	["pink", "res://godot/assets/pixel_fish_pack/fish_pink_pixel.png"],
	["red", "res://godot/assets/pixel_fish_pack/fish_red_pixel.png"],
	["brown", "res://godot/assets/pixel_fish_pack/fish_brown_pixel.png"],
	["moonveil", "res://godot/assets/pixel_fish_pack/fish_moonveil_pixel.png"],
	["coralbloom", "res://godot/assets/pixel_fish_pack/fish_coralbloom_pixel.png"],
	["abyss", "res://godot/assets/pixel_fish_pack/fish_abyss_pixel.png"],
	["thorncrest", "res://godot/assets/pixel_fish_pack/fish_thorncrest_pixel.png"],
	["dragonwake", "res://godot/assets/pixel_fish_pack/fish_dragonwake_pixel.png"],
	["unknown", "res://godot/assets/pixel_fish_pack/fish_grey_long_a_pixel.png"],
]

func _init():
	call_deferred("_run")

func _run():
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_PATH.get_base_dir()))
	var rows = int(ceil(float(FISH_ASSETS.size()) / float(COLUMNS)))
	var sheet = Image.create(CELL.x * COLUMNS, CELL.y * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(BG)
	for index in range(FISH_ASSETS.size()):
		var row = int(index / COLUMNS)
		var col = index % COLUMNS
		var origin = Vector2i(col * CELL.x, row * CELL.y)
		_draw_cell(sheet, origin, str(FISH_ASSETS[index][1]))
	var err = sheet.save_png(OUT_PATH)
	if err != OK:
		push_error("Pixel fish sheet save failed: %s" % OUT_PATH)
		quit(1)
	quit(0)

func _draw_cell(sheet, origin, path):
	var image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		push_error("Pixel fish sheet cannot load: %s" % path)
		quit(1)
	image.resize(image.get_width() * SCALE, image.get_height() * SCALE, Image.INTERPOLATE_NEAREST)
	var pos = origin + Vector2i((CELL.x - image.get_width()) / 2, (CELL.y - image.get_height()) / 2)
	_draw_frame(sheet, Rect2i(origin + Vector2i(8, 8), CELL - Vector2i(16, 16)))
	sheet.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), pos)

func _draw_frame(image, rect):
	var ink = Color.html("123047")
	var light = Color.html("ffffff")
	image.fill_rect(rect, light)
	image.fill_rect(Rect2i(rect.position, Vector2i(rect.size.x, 4)), ink)
	image.fill_rect(Rect2i(rect.position + Vector2i(0, rect.size.y - 4), Vector2i(rect.size.x, 4)), ink)
	image.fill_rect(Rect2i(rect.position, Vector2i(4, rect.size.y)), ink)
	image.fill_rect(Rect2i(rect.position + Vector2i(rect.size.x - 4, 0), Vector2i(4, rect.size.y)), ink)
