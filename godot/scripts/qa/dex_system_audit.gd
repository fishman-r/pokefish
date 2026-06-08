extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	var controller = GameStateController.new()
	root.add_child(controller)
	_install_state(controller)

	var dex = controller.get_dex_data()
	_assert(dex.get("species", {}).has("blue_minifish"), "dex records first species")
	_assert(dex.get("species", {}).has("sun_koi"), "dex records second species")

	var released_id = controller.state["fish"][1]["id"]
	var released_species = controller.state["fish"][1]["speciesId"]
	var release = controller.release_fish(released_id)
	_assert(bool(release.get("success", false)), "release succeeds")
	dex = controller.get_dex_data()
	_assert(dex.get("species", {}).has(released_species), "released species stays discovered")

	var species = GameData.species_catalog()[2]
	var rng = RandomNumberGenerator.new()
	rng.seed = 6060706
	var new_fish = FishFactory.create_fish(rng, {"species": species})
	var coins_before = int(controller.get_resources().get("bubbleCoins", 0))
	controller._record_fish_discovery(new_fish, true)
	dex = controller.get_dex_data()
	_assert(dex.get("species", {}).has(species.get("id", "")), "new species is discovered")
	_assert(int(controller.get_resources().get("bubbleCoins", 0)) >= coins_before + 60, "new species grants dex reward")

	var fish = controller.get_selected_fish()
	var shells_before = int(controller.get_resources().get("shells", 0))
	controller._apply_evolution(fish, GameData.evolution_rules()[0])
	dex = controller.get_dex_data()
	var form_key = "%s:%s" % [fish.get("speciesId", ""), GameData.evolution_rules()[0].get("id", "")]
	_assert(dex.get("forms", {}).has(form_key), "evolved form is discovered")
	_assert(int(controller.get_resources().get("shells", 0)) >= shells_before + 4, "new form grants dex reward")

	root.remove_child(controller)
	controller.queue_free()
	quit(0)

func _install_state(controller):
	var rng = RandomNumberGenerator.new()
	rng.seed = 6060706
	var fish_a = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[0]})
	var fish_b = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[1]})
	controller.state = {
		"resources": {"bubbleCoins": 200, "shells": 10, "eggs": 0, "pearls": 0},
		"eggInventory": SaveStore.default_egg_inventory(0),
		"hatchSlots": SaveStore.default_hatch_slots(),
		"dex": SaveStore.default_dex_state(),
		"foodInventory": SaveStore.default_food_inventory(),
		"foodPurchaseState": SaveStore.default_food_purchase_state(),
		"fish": [fish_a, fish_b],
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()),
		"activeExplore": {},
		"stats": SaveStore.default_stats(),
		"claimedQuests": [],
	}
	controller.active_pond_id = "starter"
	controller.selected_fish_id = fish_a["id"]

func _assert(condition, label):
	if condition:
		return
	push_error("Dex system QA failed: %s" % label)
	quit(1)
