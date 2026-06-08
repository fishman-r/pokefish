extends RefCounted
class_name SaveStore

const GameData = preload("res://godot/scripts/game_data.gd")
const FishFactory = preload("res://godot/scripts/fish_factory.gd")

const SAVE_PATH = "user://pokefish_save_v1.json"

static func load_or_create(rng):
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				var migrated = ensure_state(parsed, rng)
				save(migrated)
				return migrated
	return create_default_state(rng)

static func create_default_state(rng):
	var fish = []
	for _i in range(5):
		fish.append(FishFactory.create_fish(rng))
	var state = {
		"resources": {"bubbleCoins": 260, "shells": 18, "eggs": 3, "pearls": 1},
		"eggInventory": default_egg_inventory(3),
		"hatchSlots": default_hatch_slots(),
		"dex": default_dex_state(),
		"foodInventory": default_food_inventory(),
		"foodPurchaseState": default_food_purchase_state(),
		"fish": fish,
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()) - 60 * 18,
		"activeExplore": {},
		"stats": default_stats(),
		"claimedQuests": [],
	}
	state["eventLog"].append({"text": "鱼塘初始化完成：5 条测试鱼已生成。", "time": int(Time.get_unix_time_from_system())})
	save(state)
	return state

static func ensure_state(input, rng):
	var state = {
		"resources": {"bubbleCoins": 0, "shells": 0, "eggs": 0, "pearls": 0},
		"eggInventory": default_egg_inventory(0),
		"hatchSlots": default_hatch_slots(),
		"dex": default_dex_state(),
		"foodInventory": default_food_inventory(),
		"foodPurchaseState": default_food_purchase_state(),
		"fish": [],
		"eventLog": [],
		"activePondId": "starter",
		"lastCollectAt": int(Time.get_unix_time_from_system()),
		"activeExplore": {},
		"stats": default_stats(),
		"claimedQuests": [],
	}
	if typeof(input.get("resources")) == TYPE_DICTIONARY:
		for key in input["resources"].keys():
			state["resources"][key] = input["resources"][key]
	if typeof(input.get("eggInventory")) == TYPE_DICTIONARY:
		state["eggInventory"] = ensure_egg_inventory(input["eggInventory"], int(state["resources"].get("eggs", 0)))
	else:
		state["eggInventory"] = default_egg_inventory(int(state["resources"].get("eggs", 0)))
	state["resources"]["eggs"] = total_eggs(state["eggInventory"])
	if typeof(input.get("hatchSlots")) == TYPE_ARRAY:
		state["hatchSlots"] = ensure_hatch_slots(input["hatchSlots"])
	if typeof(input.get("dex")) == TYPE_DICTIONARY:
		state["dex"] = ensure_dex_state(input["dex"])
	if typeof(input.get("foodInventory")) == TYPE_DICTIONARY:
		state["foodInventory"] = ensure_food_inventory(input["foodInventory"])
	if typeof(input.get("foodPurchaseState")) == TYPE_DICTIONARY:
		state["foodPurchaseState"] = ensure_food_purchase_state(input["foodPurchaseState"])
	if typeof(input.get("fish")) == TYPE_ARRAY:
		for fish in input["fish"]:
			if typeof(fish) == TYPE_DICTIONARY:
				state["fish"].append(ensure_fish(fish, rng))
	if state["fish"].is_empty():
		for _i in range(5):
			state["fish"].append(FishFactory.create_fish(rng))
	if typeof(input.get("eventLog")) == TYPE_ARRAY:
		state["eventLog"] = input["eventLog"].slice(0, 50)
	if typeof(input.get("stats")) == TYPE_DICTIONARY:
		for key in input["stats"].keys():
			state["stats"][key] = input["stats"][key]
	if typeof(input.get("claimedQuests")) == TYPE_ARRAY:
		state["claimedQuests"] = input["claimedQuests"]
	state["activePondId"] = input.get("activePondId", "starter")
	state["lastCollectAt"] = int(input.get("lastCollectAt", state["lastCollectAt"]))
	if typeof(input.get("activeExplore")) == TYPE_DICTIONARY:
		state["activeExplore"] = ensure_active_explore(input["activeExplore"])
	return state

static func ensure_active_explore(input):
	if input.is_empty():
		return {}
	var route_id = str(input.get("routeId", ""))
	var fish_id = str(input.get("fishId", ""))
	if route_id == "" or fish_id == "":
		return {}
	return {
		"routeId": route_id,
		"fishId": fish_id,
		"startedAt": int(input.get("startedAt", Time.get_unix_time_from_system())),
		"endsAt": int(input.get("endsAt", Time.get_unix_time_from_system())),
		"bonus": bool(input.get("bonus", false)),
	}

static func default_food_inventory():
	return {
		"basic": 6,
		"glow": 2,
		"coral": 2,
		"spicy": 1,
	}

static func default_egg_inventory(common_count := 0):
	return {
		"common": max(0, int(common_count)),
		"color": 0,
		"deep": 0,
	}

static func ensure_egg_inventory(input, fallback_common := 0):
	var inventory = default_egg_inventory(fallback_common)
	for egg_type in GameData.egg_catalog().keys():
		inventory[egg_type] = max(0, int(input.get(egg_type, inventory.get(egg_type, 0))))
	return inventory

static func total_eggs(inventory):
	var total = 0
	if typeof(inventory) != TYPE_DICTIONARY:
		return 0
	for egg_type in GameData.egg_catalog().keys():
		total += int(inventory.get(egg_type, 0))
	return total

static func default_hatch_slots():
	return [{}, {}, {}]

static func ensure_hatch_slots(input):
	var slots = default_hatch_slots()
	for index in range(min(3, input.size())):
		var slot = input[index]
		if typeof(slot) != TYPE_DICTIONARY or slot.is_empty():
			continue
		var egg_type = str(slot.get("eggType", "common"))
		if not GameData.egg_catalog().has(egg_type):
			egg_type = "common"
		slots[index] = {
			"eggType": egg_type,
			"startedAt": int(slot.get("startedAt", Time.get_unix_time_from_system())),
			"readyAt": int(slot.get("readyAt", Time.get_unix_time_from_system())),
		}
	return slots

static func default_dex_state():
	return {
		"species": {},
		"forms": {},
		"rewardedSpecies": [],
		"rewardedForms": [],
	}

static func ensure_dex_state(input):
	var dex = default_dex_state()
	if typeof(input.get("species")) == TYPE_DICTIONARY:
		dex["species"] = input["species"]
	if typeof(input.get("forms")) == TYPE_DICTIONARY:
		dex["forms"] = input["forms"]
	if typeof(input.get("rewardedSpecies")) == TYPE_ARRAY:
		dex["rewardedSpecies"] = input["rewardedSpecies"]
	if typeof(input.get("rewardedForms")) == TYPE_ARRAY:
		dex["rewardedForms"] = input["rewardedForms"]
	return dex

static func ensure_food_inventory(input):
	var inventory = default_food_inventory()
	for food_id in GameData.food_catalog().keys():
		var food = GameData.food_catalog()[food_id]
		var max_stock = int(food.get("max_stock", 12))
		inventory[food_id] = clamp(int(input.get(food_id, inventory.get(food_id, 0))), 0, max_stock)
	return inventory

static func default_food_purchase_state():
	return {
		"day": _today_key(),
		"counts": {},
	}

static func ensure_food_purchase_state(input):
	var state = default_food_purchase_state()
	state["day"] = int(input.get("day", state["day"]))
	if typeof(input.get("counts")) == TYPE_DICTIONARY:
		for food_id in GameData.food_catalog().keys():
			state["counts"][food_id] = max(0, int(input["counts"].get(food_id, 0)))
	return state

static func _today_key():
	return int(floor(float(Time.get_unix_time_from_system()) / 86400.0))

static func ensure_fish(fish, rng):
	var fallback = FishFactory.create_fish(rng, {"species": _species_for(fish)})
	for key in fallback.keys():
		if not fish.has(key):
			fish[key] = fallback[key]
	if typeof(fish.get("genes")) != TYPE_DICTIONARY:
		fish["genes"] = fallback["genes"]
	if typeof(fish["genes"].get("visible")) != TYPE_ARRAY:
		fish["genes"]["visible"] = fallback["genes"]["visible"]
	if not fish["genes"].has("hidden") or str(fish["genes"]["hidden"]) == "":
		fish["genes"]["hidden"] = fallback["genes"]["hidden"]
	if typeof(fish.get("traits")) != TYPE_ARRAY or fish["traits"].is_empty():
		fish["traits"] = fallback["traits"]
	else:
		var safe_traits = []
		for trait_data in fish["traits"]:
			if typeof(trait_data) == TYPE_DICTIONARY and trait_data.has("id"):
				safe_traits.append(trait_data)
		if safe_traits.is_empty():
			safe_traits = fallback["traits"]
		fish["traits"] = safe_traits
	if typeof(fish.get("appearance")) != TYPE_DICTIONARY:
		fish["appearance"] = fallback["appearance"]
	for key in fallback["appearance"].keys():
		if not fish["appearance"].has(key):
			fish["appearance"][key] = fallback["appearance"][key]
	if not fish.has("swim") or typeof(fish["swim"]) != TYPE_DICTIONARY:
		fish["swim"] = fallback["swim"]
	if not fish.has("evolutionHistory") or typeof(fish["evolutionHistory"]) != TYPE_ARRAY:
		fish["evolutionHistory"] = []
	if not fish.has("evolutionPity"):
		fish["evolutionPity"] = 0.0
	if not fish.has("createdAt"):
		fish["createdAt"] = int(Time.get_unix_time_from_system())
	if not fish.has("lastDigestAt"):
		fish["lastDigestAt"] = int(Time.get_unix_time_from_system())
	if not fish.has("lastFedAt"):
		fish["lastFedAt"] = 0
	if not fish.has("appetiteState"):
		fish["appetiteState"] = "normal"
	if not fish.has("appetiteUntil"):
		fish["appetiteUntil"] = 0
	return fish

static func _species_for(fish):
	var species_id = str(fish.get("speciesId", ""))
	for species in GameData.species_catalog():
		if species.get("id", "") == species_id:
			return species
	return GameData.species_catalog()[0]

static func default_stats():
	return {
		"collectCount": 0,
		"feedCount": 0,
		"overfeedCount": 0,
		"refusedFeedCount": 0,
		"foodPurchaseCount": 0,
		"hatchCount": 0,
		"evolveAttempts": 0,
		"evolutionCount": 0,
		"exploreCount": 0,
		"shareCount": 0,
		"pondSwitches": 0,
	}

static func save(state):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state))

static func reset():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
