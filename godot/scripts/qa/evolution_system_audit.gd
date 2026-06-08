extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	var controller = GameStateController.new()
	controller.rng.seed = 6060704
	root.add_child(controller)
	_install_state(controller)

	var fish = controller.get_selected_fish()
	fish["evolutionPity"] = 0.11
	var with_pity = controller.calculate_evolution(fish, "starter", "basic")
	fish["evolutionPity"] = 0.0
	var without_pity = controller.calculate_evolution(fish, "starter", "basic")
	_assert(float(with_pity.get("chance", 0.0)) > float(without_pity.get("chance", 0.0)), "pity raises preview chance")

	var exp_before = int(fish.get("exp", 0))
	var fullness_before = int(fish.get("hunger", 0))
	var result = controller.try_evolution("basic")
	_assert(int(controller.get_food_inventory().get("basic", 0)) == 0, "evolution consumes catalyst stock")
	_assert(int(controller.state["stats"].get("feedCount", 0)) == 0, "evolution does not record feeding")
	_assert(int(fish.get("exp", 0)) == exp_before, "evolution does not grant feed exp")
	_assert(int(fish.get("hunger", 0)) == fullness_before, "evolution does not change fullness")
	_assert(int(controller.state["stats"].get("evolveAttempts", 0)) == 1, "evolution records attempt")
	if bool(result.get("success", false)):
		_assert(float(fish.get("evolutionPity", 0.0)) == 0.0, "successful evolution clears pity")
	else:
		_assert(float(fish.get("evolutionPity", 0.0)) > 0.0, "failed evolution adds pity")

	controller.state["foodInventory"]["basic"] = 1
	fish["evolutionStage"] = 3
	var capped = controller.try_evolution("basic")
	_assert(not bool(capped.get("success", false)) and str(capped.get("reason", "")) == "max_stage", "max stage blocks evolution")
	_assert(int(controller.get_food_inventory().get("basic", 0)) == 1, "max stage keeps catalyst stock")

	var rule = GameData.evolution_rules()[0]
	fish["evolutionStage"] = 0
	fish["speciesName"] = "%s%s" % [rule.get("target_name", ""), GameData.species_catalog()[0].get("name", "鱼")]
	var name_before = fish["speciesName"]
	controller._apply_evolution(fish, rule)
	_assert(str(fish.get("speciesName", "")) == name_before, "same evolution prefix is not duplicated")

	root.remove_child(controller)
	controller.queue_free()
	quit(0)

func _install_state(controller):
	var rng = RandomNumberGenerator.new()
	rng.seed = 6060704
	var fish = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[0]})
	fish["hunger"] = 46
	fish["exp"] = 12
	fish["mood"] = 68
	fish["level"] = 1
	fish["intimacy"] = 5
	fish["evolutionStage"] = 0
	fish["evolutionPity"] = 0.0
	var now = int(Time.get_unix_time_from_system())
	controller.state = {
		"resources": {"bubbleCoins": 200, "shells": 10, "eggs": 0, "pearls": 0},
		"foodInventory": {"basic": 1, "glow": 0, "coral": 0, "spicy": 0},
		"foodPurchaseState": SaveStore.default_food_purchase_state(),
		"fish": [fish],
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": now,
		"activeExplore": {},
		"stats": SaveStore.default_stats(),
		"claimedQuests": [],
	}
	controller.active_pond_id = "starter"
	controller.selected_fish_id = fish["id"]

func _assert(condition, label):
	if condition:
		return
	push_error("Evolution system QA failed: %s" % label)
	quit(1)
