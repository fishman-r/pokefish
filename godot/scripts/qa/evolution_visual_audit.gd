extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	var rng = RandomNumberGenerator.new()
	rng.seed = 6060701
	var base_fish = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[0]})
	base_fish["rarity"] = "common"
	base_fish["evolutionStage"] = 0
	base_fish["evolutionHistory"] = []
	base_fish["appearance"]["formId"] = "base"
	var base_texture = FishArt.texture_for(base_fish)
	_assert(base_texture != null, "base fish has texture")

	var controller = GameStateController.new()
	controller.state = {
		"resources": {"bubbleCoins": 0, "shells": 0, "eggs": 0, "pearls": 0},
		"fish": [],
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()),
		"stats": SaveStore.default_stats(),
		"claimedQuests": [],
	}
	root.add_child(controller)

	for rule in GameData.evolution_rules():
		var fish = base_fish.duplicate(true)
		controller._apply_evolution(fish, rule)
		var form_id = str(fish.get("appearance", {}).get("formId", ""))
		var texture = FishArt.texture_for(fish)
		_assert(form_id == rule.get("id", ""), "%s writes form id" % rule.get("id", "rule"))
		_assert(texture != null, "%s has evolved texture" % rule.get("id", "rule"))
		_assert(texture != base_texture, "%s changes visible fish texture" % rule.get("id", "rule"))
		_assert(int(fish.get("evolutionStage", 0)) == 1, "%s bumps evolution stage" % rule.get("id", "rule"))
		_assert(str(fish.get("speciesName", "")).find(str(rule.get("target_name", ""))) >= 0, "%s changes species display name" % rule.get("id", "rule"))
		_assert(not fish.get("evolutionHistory", []).is_empty(), "%s records evolution history" % rule.get("id", "rule"))

	root.remove_child(controller)
	controller.queue_free()
	quit(0)

func _assert(condition, label):
	if condition:
		return
	push_error("Evolution visual QA failed: %s" % label)
	quit(1)
