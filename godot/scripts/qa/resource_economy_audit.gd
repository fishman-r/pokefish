extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	var controller = GameStateController.new()
	root.add_child(controller)
	_install_state(controller)

	var fish = controller.get_selected_fish()
	var coins_before = int(controller.get_resources().get("bubbleCoins", 0))
	var eggs_before = int(controller.get_resources().get("eggs", 0))
	var start = controller.run_explore("driftwood")
	_assert(bool(start.get("success", false)), "explore starts")
	_assert(str(start.get("status", "")) == "started", "explore returns started status")
	_assert(not controller.state.get("activeExplore", {}).is_empty(), "explore stores active trip")
	_assert(int(controller.get_resources().get("bubbleCoins", 0)) == coins_before, "explore start gives no coins")
	_assert(int(start.get("remaining", 0)) < int(GameData.explore_routes()[0].get("duration_seconds", 900)), "ideal appetite shortens route")

	var pending = controller.run_explore("driftwood")
	_assert(not bool(pending.get("success", false)) and str(pending.get("reason", "")) == "explore_pending", "same route waits until return")
	var busy = controller.run_explore("shipwreck")
	_assert(not bool(busy.get("success", false)) and str(busy.get("reason", "")) == "explore_busy", "second route blocked while busy")

	controller.state["activeExplore"]["endsAt"] = int(Time.get_unix_time_from_system()) - 1
	var fullness_before = int(fish.get("hunger", 0))
	var claim = controller.run_explore("driftwood")
	_assert(bool(claim.get("success", false)), "explore claim succeeds")
	_assert(str(claim.get("status", "")) == "claimed", "explore returns claimed status")
	_assert(controller.state.get("activeExplore", {}).is_empty(), "claim clears active trip")
	_assert(int(controller.get_resources().get("bubbleCoins", 0)) > coins_before, "claim grants coins")
	_assert(int(controller.get_resources().get("eggs", 0)) >= eggs_before + 1, "claim grants eggs")
	_assert(int(controller.state["stats"].get("exploreCount", 0)) == 1, "claim records explore count")
	_assert(int(fish.get("hunger", 0)) < fullness_before, "trip consumes fullness")

	controller.state["lastCollectAt"] = int(Time.get_unix_time_from_system()) - 180
	var collect = controller.collect_idle_reward()
	_assert(int(collect.get("bubbleCoins", 0)) > 0, "idle collection grants coins")
	_assert(int(collect.get("shells", 0)) >= 1, "idle collection grants shells")
	_assert(int(controller.state["stats"].get("collectCount", 0)) == 1, "idle collection records stat")

	root.remove_child(controller)
	controller.queue_free()
	quit(0)

func _install_state(controller):
	var rng = RandomNumberGenerator.new()
	rng.seed = 6060703
	var fish = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[0]})
	fish["hunger"] = 60
	fish["mood"] = 70
	fish["traits"] = [{"id": "curious", "label": "好奇", "mood": 8, "chance": 0.03}]
	var now = int(Time.get_unix_time_from_system())
	controller.state = {
		"resources": {"bubbleCoins": 200, "shells": 10, "eggs": 0, "pearls": 0},
		"foodInventory": SaveStore.default_food_inventory(),
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
	push_error("Resource economy QA failed: %s" % label)
	quit(1)
