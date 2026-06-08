extends SceneTree

const FishArt = preload("res://godot/scripts/ui/fish_art.gd")

const KENNEY_DECOR_ASSETS = [
	"res://godot/assets/kenney_fish_pack/bubble_a.png",
	"res://godot/assets/kenney_fish_pack/bubble_b.png",
	"res://godot/assets/kenney_fish_pack/bubble_c.png",
	"res://godot/assets/kenney_fish_pack/rock_a.png",
	"res://godot/assets/kenney_fish_pack/rock_b.png",
	"res://godot/assets/kenney_fish_pack/seaweed_green_a.png",
	"res://godot/assets/kenney_fish_pack/seaweed_green_b.png",
	"res://godot/assets/kenney_fish_pack/seaweed_green_c.png",
	"res://godot/assets/kenney_fish_pack/seaweed_orange_a.png",
	"res://godot/assets/kenney_fish_pack/seaweed_pink_a.png",
	"res://godot/assets/kenney_fish_pack/terrain_sand_a.png",
	"res://godot/assets/kenney_fish_pack/terrain_sand_b.png",
	"res://godot/assets/kenney_fish_pack/terrain_sand_c.png",
	"res://godot/assets/kenney_fish_pack/terrain_sand_d.png",
	"res://godot/assets/kenney_fish_pack/terrain_sand_top_a.png",
	"res://godot/assets/kenney_fish_pack/terrain_sand_top_b.png",
	"res://godot/assets/kenney_fish_pack/terrain_sand_top_c.png",
	"res://godot/assets/kenney_fish_pack/terrain_sand_top_d.png",
]

const PIXEL_FISH_ASSETS = [
	"res://godot/assets/pixel_fish_pack/fish_blue_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_green_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_orange_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_pink_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_red_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_brown_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_grey_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_grey_long_a_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_grey_long_b_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_moonveil_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_coralbloom_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_abyss_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_thorncrest_pixel.png",
	"res://godot/assets/pixel_fish_pack/fish_dragonwake_pixel.png",
]

func _init():
	call_deferred("_run")

func _run():
	for path in KENNEY_DECOR_ASSETS:
		_assert(ResourceLoader.exists(path), "selected decor asset is imported: %s" % path)
		var texture = load(path)
		_assert(texture is Texture2D, "selected decor asset loads as texture: %s" % path)
		_assert(texture.get_size() == Vector2(128.0, 128.0), "selected decor asset has expected source size: %s" % path)

	for path in PIXEL_FISH_ASSETS:
		_assert(ResourceLoader.exists(path), "pixel fish asset is imported: %s" % path)
		var texture = load(path)
		_assert(texture is Texture2D, "pixel fish asset loads as texture: %s" % path)
		_assert(texture.get_size() == Vector2(48.0, 32.0), "pixel fish asset has expected source size: %s" % path)
		_assert(FileAccess.file_exists("%s.import" % path), "pixel fish has import metadata: %s" % path)

	_assert(FishArt.has_assets(), "FishArt preloads every pixel fish texture")

	var pond = load("res://godot/scenes/ui/pond_stage.tscn").instantiate()
	_assert(pond.has_method("has_kenney_decor"), "pond exposes Kenney decor audit hook")
	_assert(pond.has_kenney_decor(), "pond preloads selected Kenney decor")
	pond.queue_free()

	var export_config = FileAccess.get_file_as_string("res://export_presets.cfg")
	_assert(export_config.find("resource_packages/*") >= 0, "export excludes raw resource package")
	_assert(export_config.find("godot/scripts/qa/*") >= 0, "export excludes QA scripts")
	_assert(export_config.find("godot/scripts/tools/*") >= 0, "export excludes development tools")
	_assert(export_config.find("godot/assets/kenney_fish_pack/fish_*.png") >= 0, "export excludes old Kenney fish sprites")
	_assert(FileAccess.file_exists("res://resource_packages/.gdignore"), "raw resource package is ignored by Godot import")
	_assert(FileAccess.file_exists("res://godot/scripts/tools/.gdignore"), "development tool scripts are ignored by Godot import")

	quit(0)

func _assert(condition, label):
	if condition:
		return
	push_error("Kenney asset QA failed: %s" % label)
	quit(1)
