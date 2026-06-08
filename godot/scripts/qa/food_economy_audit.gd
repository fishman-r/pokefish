extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	var controller = GameStateController.new()
	root.add_child(controller)
	_install_state(controller)

	var fish = controller.get_selected_fish()
	var now = int(Time.get_unix_time_from_system())
	fish["hunger"] = 60
	fish["lastDigestAt"] = now - 1440
	var digested = controller.get_selected_fish()
	_assert(int(digested.get("hunger", 0)) == 58, "passive digestion lowers fullness over time")
	_assert(str(digested.get("appetiteState", "")) == "ideal", "digestion refreshes appetite state")

	fish["hunger"] = 20
	fish["lastDigestAt"] = now
	fish["appetiteState"] = "hungry"
	fish["appetiteUntil"] = 0
	var exp_before = int(fish.get("exp", 0))
	var fullness_before = int(fish.get("hunger", 0))
	var result = controller.feed_selected("basic")
	_assert(bool(result.get("success", false)), "feed succeeds with stock")
	_assert(int(controller.get_food_inventory().get("basic", 0)) == 0, "feed consumes one food")
	_assert(int(fish.get("exp", 0)) > exp_before, "feed grants growth")
	_assert(int(fish.get("hunger", 0)) > fullness_before, "feed raises fullness")
	_assert(int(controller.state["stats"].get("feedCount", 0)) == 1, "feed records stat")

	var failed = controller.feed_selected("basic")
	_assert(not bool(failed.get("success", false)), "feed fails without stock")
	_assert(str(failed.get("reason", "")) == "no_stock", "feed failure reason is stock")

	controller.state["foodInventory"]["basic"] = 1
	fish["hunger"] = 96
	fish["mood"] = 70
	var overfed = controller.feed_selected("basic")
	_assert(bool(overfed.get("overfed", false)), "overfeeding is flagged")
	_assert(int(fish.get("mood", 0)) < 70, "overfeeding lowers mood")
	_assert(int(controller.state["stats"].get("overfeedCount", 0)) == 1, "overfeeding records stat")
	_assert(str(fish.get("appetiteState", "")) == "stuffed", "overfeeding marks stuffed state")

	controller.state["foodInventory"]["basic"] = 1
	fish["hunger"] = 99
	fish["lastDigestAt"] = int(Time.get_unix_time_from_system())
	var refused = controller.feed_selected("basic")
	_assert(not bool(refused.get("success", false)) and str(refused.get("reason", "")) == "too_full", "too-full fish refuses food")
	_assert(int(controller.get_food_inventory().get("basic", 0)) == 1, "refused feed keeps food stock")
	_assert(int(controller.state["stats"].get("refusedFeedCount", 0)) == 1, "refused feed records stat")

	controller.state["resources"] = {"bubbleCoins": 200, "shells": 10, "eggs": 0, "pearls": 0}
	controller.state["foodInventory"]["basic"] = 0
	controller.state["foodPurchaseState"] = SaveStore.default_food_purchase_state()
	var buy = controller.buy_food("basic")
	_assert(bool(buy.get("success", false)), "food purchase succeeds when affordable")
	_assert(int(controller.get_food_inventory().get("basic", 0)) == int(GameData.food_catalog()["basic"].get("bundle", 1)), "purchase adds bundle stock")
	_assert(int(controller.get_resources().get("bubbleCoins", 0)) == 155, "purchase spends coins")

	controller.state["foodInventory"]["basic"] = int(GameData.food_catalog()["basic"].get("max_stock", 12))
	var full = controller.buy_food("basic")
	_assert(not bool(full.get("success", false)) and str(full.get("reason", "")) == "stock_full", "purchase stops at stock cap")

	controller.state["foodInventory"]["basic"] = 0
	controller.state["foodPurchaseState"]["counts"]["basic"] = int(GameData.food_catalog()["basic"].get("daily_limit", 4))
	var limited = controller.buy_food("basic")
	_assert(not bool(limited.get("success", false)) and str(limited.get("reason", "")) == "daily_limit", "purchase stops at daily cap")

	controller.state["foodPurchaseState"] = SaveStore.default_food_purchase_state()
	controller.state["resources"] = {"bubbleCoins": 0, "shells": 0, "eggs": 0, "pearls": 0}
	var poor = controller.buy_food("basic")
	_assert(not bool(poor.get("success", false)) and str(poor.get("reason", "")) == "not_enough", "purchase requires resources")

	controller.state["foodInventory"]["basic"] = 0
	var evo = controller.try_evolution("basic")
	_assert(not bool(evo.get("success", false)) and str(evo.get("reason", "")) == "no_stock", "evolution requires selected food stock")

	root.remove_child(controller)
	controller.queue_free()
	quit(0)

func _install_state(controller):
	var rng = RandomNumberGenerator.new()
	rng.seed = 6060702
	var fish = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[0]})
	fish["hunger"] = 20
	fish["mood"] = 60
	controller.state = {
		"resources": {"bubbleCoins": 200, "shells": 10, "eggs": 0, "pearls": 0},
		"foodInventory": {"basic": 1, "glow": 0, "coral": 0, "spicy": 0},
		"foodPurchaseState": SaveStore.default_food_purchase_state(),
		"fish": [fish],
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()),
		"stats": SaveStore.default_stats(),
		"claimedQuests": [],
	}
	controller.active_pond_id = "starter"
	controller.selected_fish_id = fish["id"]

func _assert(condition, label):
	if condition:
		return
	push_error("Food economy QA failed: %s" % label)
	quit(1)
