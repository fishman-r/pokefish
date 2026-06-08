extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	var controller = GameStateController.new()
	root.add_child(controller)
	_install_state(controller)

	var fish_before = controller.state["fish"].size()
	var start = controller.hatch_fish({"slot": 0, "egg_type": "color"})
	_assert(bool(start.get("success", false)) and str(start.get("status", "")) == "started", "hatch starts incubation")
	_assert(int(controller.get_egg_inventory().get("color", 0)) == 0, "incubation consumes selected egg type")
	_assert(int(controller.get_resources().get("eggs", 0)) == 1, "incubation updates total eggs")
	_assert(controller.state["fish"].size() == fish_before, "incubation does not add fish immediately")
	_assert(int(controller.state["stats"].get("hatchCount", 0)) == 0, "incubation does not record hatch yet")

	var pending = controller.hatch_fish({"slot": 0})
	_assert(not bool(pending.get("success", false)) and str(pending.get("reason", "")) == "incubating", "slot blocks early claim")

	controller.state["hatchSlots"][0]["readyAt"] = int(Time.get_unix_time_from_system()) - 1
	var claim = controller.hatch_fish({"slot": 0})
	_assert(bool(claim.get("success", false)) and str(claim.get("status", "")) == "claimed", "ready slot claims fish")
	_assert(controller.state["fish"].size() == fish_before + 1, "claim adds fish")
	_assert(controller.state["hatchSlots"][0].is_empty(), "claim clears slot")
	_assert(int(controller.state["stats"].get("hatchCount", 0)) == 1, "claim records hatch")
	_assert(str(claim.get("egg_type", "")) == "color", "claim remembers egg type")

	var deep_before = int(controller.get_egg_inventory().get("deep", 0))
	var eggs_before = int(controller.get_resources().get("eggs", 0))
	var buy = controller.buy_shop_item("deep_egg")
	_assert(bool(buy.get("success", false)), "buy deep egg succeeds")
	_assert(int(controller.get_egg_inventory().get("deep", 0)) == deep_before + 1, "shop adds deep egg inventory")
	_assert(int(controller.get_resources().get("eggs", 0)) == eggs_before + 1, "shop updates total egg resource")

	controller.state["resources"]["shells"] = 0
	var locked = controller.hatch_fish({"slot": 1})
	_assert(not bool(locked.get("success", false)) and str(locked.get("reason", "")) == "slot_locked", "locked hatch slot blocks start")

	root.remove_child(controller)
	controller.queue_free()
	quit(0)

func _install_state(controller):
	var rng = RandomNumberGenerator.new()
	rng.seed = 6060705
	var fish = FishFactory.create_fish(rng, {"species": GameData.species_catalog()[0]})
	controller.state = {
		"resources": {"bubbleCoins": 200, "shells": 20, "eggs": 2, "pearls": 2},
		"eggInventory": {"common": 1, "color": 1, "deep": 0},
		"hatchSlots": SaveStore.default_hatch_slots(),
		"foodInventory": SaveStore.default_food_inventory(),
		"foodPurchaseState": SaveStore.default_food_purchase_state(),
		"fish": [fish],
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()),
		"activeExplore": {},
		"stats": SaveStore.default_stats(),
		"claimedQuests": [],
	}
	controller.active_pond_id = "starter"
	controller.selected_fish_id = fish["id"]

func _assert(condition, label):
	if condition:
		return
	push_error("Hatchery system QA failed: %s" % label)
	quit(1)
