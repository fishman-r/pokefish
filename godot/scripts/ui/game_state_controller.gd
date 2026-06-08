extends Node
class_name GameStateController

const GameData = preload("res://godot/scripts/game_data.gd")
const FishFactory = preload("res://godot/scripts/fish_factory.gd")
const SaveStore = preload("res://godot/scripts/save_store.gd")

const DIGEST_SECONDS_PER_POINT = 720
const STUFFED_SECONDS = 1800
const REFUSE_FULLNESS = 98
const HUNGRY_FULLNESS = 20
const IDEAL_FULLNESS_MIN = 35
const IDEAL_FULLNESS_MAX = 78
const FULL_FULLNESS = 86
const MAX_EVOLUTION_STAGE = 3
const EVOLUTION_PITY_STEP = 0.055
const EVOLUTION_PITY_MAX = 0.22

signal state_changed(state)
signal resources_changed(resources, delta)
signal fish_selected(fish)
signal log_added(text)

var rng = RandomNumberGenerator.new()
var state = {}
var selected_fish_id = ""
var active_pond_id = "starter"
var selected_food_id = "basic"

func setup():
	rng.randomize()
	state = SaveStore.load_or_create(rng)
	_ensure_food_system()
	_ensure_hatch_system()
	_ensure_dex_system()
	if _apply_passive_digestion():
		SaveStore.save(state)
	active_pond_id = state.get("activePondId", "starter")
	if not state.get("fish", []).is_empty():
		selected_fish_id = state["fish"][0].get("id", "")
	state_changed.emit(state)
	fish_selected.emit(get_selected_fish())
	resources_changed.emit(get_resources(), {})

func get_resources():
	return state.get("resources", {})

func get_appetite_label(fish):
	var appetite = _sync_appetite_state(fish, int(Time.get_unix_time_from_system()))
	return _appetite_label(appetite)

func get_food_inventory():
	_ensure_food_system()
	return state.get("foodInventory", {})

func get_egg_inventory():
	_ensure_hatch_system()
	return state.get("eggInventory", {})

func get_hatch_slot_status(index):
	_ensure_hatch_system()
	var slots = state.get("hatchSlots", [])
	if index < 0 or index >= slots.size():
		return {"open": false, "active": false, "ready": false, "remaining": 0}
	var slot = slots[index]
	var now = int(Time.get_unix_time_from_system())
	var open = _hatch_slot_open(index)
	if typeof(slot) != TYPE_DICTIONARY or slot.is_empty():
		return {"open": open, "active": false, "ready": false, "remaining": 0}
	var remaining = max(0, int(slot.get("readyAt", now)) - now)
	return {
		"open": open,
		"active": true,
		"ready": remaining <= 0,
		"remaining": remaining,
		"egg_type": str(slot.get("eggType", "common")),
		"slot": slot,
	}

func get_dex_data():
	_ensure_dex_system()
	return state.get("dex", SaveStore.default_dex_state())

func get_food_purchase_info(food_id):
	_ensure_food_system()
	var food = GameData.food_catalog().get(food_id, GameData.food_catalog()["basic"])
	var inventory = get_food_inventory()
	var purchase_state = state.get("foodPurchaseState", {})
	var counts = purchase_state.get("counts", {})
	var stock = int(inventory.get(food_id, 0))
	var max_stock = int(food.get("max_stock", 12))
	var daily_limit = int(food.get("daily_limit", 3))
	var daily_used = int(counts.get(food_id, 0))
	var bundle = int(food.get("bundle", 1))
	var amount = min(bundle, max(0, max_stock - stock))
	var affordable = _can_afford(food.get("cost", {}))
	var can_buy = amount > 0 and daily_used < daily_limit and affordable
	var reason = ""
	if amount <= 0:
		reason = "stock_full"
	elif daily_used >= daily_limit:
		reason = "daily_limit"
	elif not affordable:
		reason = "not_enough"
	return {
		"food": food,
		"food_id": food_id,
		"stock": stock,
		"max_stock": max_stock,
		"daily_used": daily_used,
		"daily_limit": daily_limit,
		"amount": amount,
		"cost": food.get("cost", {}),
		"can_buy": can_buy,
		"reason": reason,
	}

func get_explore_status(route_id):
	_ensure_active_explore()
	var active = state.get("activeExplore", {})
	if active.is_empty():
		return {"has_active": false, "is_active": false, "ready": false, "remaining": 0}
	var now = int(Time.get_unix_time_from_system())
	var remaining = max(0, int(active.get("endsAt", now)) - now)
	return {
		"has_active": true,
		"is_active": str(active.get("routeId", "")) == route_id,
		"ready": remaining <= 0,
		"remaining": remaining,
		"active": active,
	}

func get_active_pond():
	return GameData.pond_catalog().get(active_pond_id, GameData.pond_catalog()["starter"])

func get_active_pond_name():
	return get_active_pond().get("name", "水域")

func get_selected_fish():
	_apply_passive_digestion()
	for fish in state.get("fish", []):
		if fish.get("id", "") == selected_fish_id:
			return fish
	if not state.get("fish", []).is_empty():
		selected_fish_id = state["fish"][0].get("id", "")
		return state["fish"][0]
	return {}

func select_fish(fish_id):
	selected_fish_id = fish_id
	fish_selected.emit(get_selected_fish())
	state_changed.emit(state)

func release_fish(fish_id := ""):
	var fish_list = state.get("fish", [])
	if fish_list.size() <= 1:
		_add_log("至少保留一位伙伴。")
		state_changed.emit(state)
		return {"success": false, "reason": "last_fish"}
	if fish_id == "":
		fish_id = selected_fish_id
	var remove_index = -1
	var released = {}
	for index in range(fish_list.size()):
		var fish = fish_list[index]
		if fish.get("id", "") == fish_id:
			remove_index = index
			released = fish
			break
	if remove_index < 0:
		return {"success": false, "reason": "missing"}
	fish_list.remove_at(remove_index)
	state["fish"] = fish_list
	if selected_fish_id == fish_id or get_selected_fish().is_empty():
		var next_index = min(remove_index, fish_list.size() - 1)
		selected_fish_id = fish_list[next_index].get("id", "")
	_add_log("%s 回到大海。" % released.get("name", "伙伴"))
	SaveStore.save(state)
	fish_selected.emit(get_selected_fish())
	state_changed.emit(state)
	return {"success": true, "fish": released}

func collect_idle_reward():
	_apply_passive_digestion()
	var now = int(Time.get_unix_time_from_system())
	var elapsed = max(0, now - int(state.get("lastCollectAt", now)))
	if elapsed < 60:
		return {"reason": "cooldown", "remaining": 60 - elapsed}
	var minutes = min(480, int(elapsed / 60))
	var coins = int(round(get_idle_rate() * minutes))
	var shells = max(1, int(coins / 120))
	var delta = {"bubbleCoins": coins, "shells": shells}
	if minutes >= 30:
		delta["pearls"] = 1
	_add_rewards(delta)
	state["lastCollectAt"] = now
	_record_stat("collectCount", 1)
	_add_log("收取 +%d 泡泡币，+%d 贝壳。" % [coins, shells])
	_save_and_emit(delta)
	return delta

func feed_selected(food_id := ""):
	_apply_passive_digestion()
	if food_id == "":
		food_id = selected_food_id
	var fish = get_selected_fish()
	if fish.is_empty():
		return {}
	_ensure_food_system()
	selected_food_id = food_id
	var food = GameData.food_catalog().get(food_id, GameData.food_catalog()["basic"])
	var inventory = state.get("foodInventory", {})
	var stock = int(inventory.get(food_id, 0))
	if stock <= 0:
		_add_log("%s 不够了，需要先购买。" % food.get("name", "饲料"))
		state_changed.emit(state)
		return {"success": false, "reason": "no_stock", "fish": fish, "food": food, "food_id": food_id}
	var now = int(Time.get_unix_time_from_system())
	inventory[food_id] = stock - 1
	state["foodInventory"] = inventory
	var fullness_before = int(fish.get("hunger", 0))
	if fullness_before >= REFUSE_FULLNESS:
		inventory[food_id] = stock
		state["foodInventory"] = inventory
		fish["appetiteState"] = "stuffed"
		fish["appetiteUntil"] = max(int(fish.get("appetiteUntil", 0)), now + STUFFED_SECONDS)
		_record_stat("refusedFeedCount", 1)
		_add_log("%s 已经吃不下了。" % fish.get("name", "伙伴"))
		SaveStore.save(state)
		fish_selected.emit(fish)
		state_changed.emit(state)
		return {"success": false, "reason": "too_full", "fish": fish, "food": food, "food_id": food_id, "stock": stock}
	var satiety = int(food.get("satiety", 22))
	var overfed = fullness_before >= int(food.get("overfeed_at", 86)) or str(fish.get("appetiteState", "")) == "stuffed"
	var exp_gain = int(food.get("exp", 0))
	var mood_delta = int(food.get("mood", 0))
	var intimacy_delta = 5
	if overfed:
		exp_gain = int(round(float(exp_gain) * 0.35))
		mood_delta -= int(food.get("overfeed_mood_penalty", 14))
		intimacy_delta = -2
	fish["exp"] = int(fish.get("exp", 0)) + exp_gain
	fish["mood"] = clamp(int(fish.get("mood", 0)) + mood_delta, 0, 100)
	fish["hunger"] = clamp(fullness_before + satiety, 0, 100)
	fish["lastFedAt"] = now
	fish["lastDigestAt"] = now
	fish["intimacy"] = clamp(int(fish.get("intimacy", 0)) + intimacy_delta, 0, 100)
	_record_stat("feedCount", 1)
	if overfed:
		_record_stat("overfeedCount", 1)
		fish["lastOverfedAt"] = now
		fish["appetiteState"] = "stuffed"
		fish["appetiteUntil"] = now + STUFFED_SECONDS
	else:
		_sync_appetite_state(fish, now)
	_maybe_level_up(fish)
	if overfed:
		_add_log("%s 吃太撑了，心情下降。" % fish.get("name", "伙伴"))
	else:
		_add_log("%s 吃下了 %s。" % [fish.get("name", "伙伴"), food.get("name", "饲料")])
	SaveStore.save(state)
	fish_selected.emit(fish)
	state_changed.emit(state)
	return {
		"success": true,
		"fish": fish,
		"food": food,
		"food_id": food_id,
		"stock": int(inventory.get(food_id, 0)),
		"overfed": overfed,
		"exp_gain": exp_gain,
		"mood_delta": mood_delta,
	}

func try_evolution(food_id := ""):
	_apply_passive_digestion()
	if food_id == "":
		food_id = selected_food_id
	var fish = get_selected_fish()
	if fish.is_empty():
		return {"success": false, "reason": "no_fish"}
	if int(fish.get("evolutionStage", 0)) >= MAX_EVOLUTION_STAGE:
		return {"success": false, "reason": "max_stage", "fish": fish}
	selected_food_id = food_id
	_ensure_food_system()
	var food = GameData.food_catalog().get(food_id, GameData.food_catalog()["basic"])
	var inventory = state.get("foodInventory", {})
	var stock = int(inventory.get(food_id, 0))
	if stock <= 0:
		_add_log("%s 不够了，无法共鸣。" % food.get("name", "饲料"))
		state_changed.emit(state)
		return {"success": false, "reason": "no_stock", "fish": fish, "food": food}
	var result = calculate_evolution(fish, active_pond_id, food_id)
	inventory[food_id] = stock - 1
	state["foodInventory"] = inventory
	_record_stat("evolveAttempts", 1)
	var success = rng.randf() <= float(result["chance"])
	if success:
		fish["evolutionPity"] = 0.0
		_apply_evolution(fish, result["rule"])
	else:
		fish["evolutionPity"] = clamp(float(fish.get("evolutionPity", 0.0)) + EVOLUTION_PITY_STEP, 0.0, EVOLUTION_PITY_MAX)
		_add_log("%s 的形态波动了一下，还没有进化。" % fish.get("name", "伙伴"))
	SaveStore.save(state)
	fish_selected.emit(fish)
	state_changed.emit(state)
	return {
		"success": success,
		"fish": fish,
		"food": food,
		"stock": int(inventory.get(food_id, 0)),
		"result": result,
	}

func hatch_fish(options := {}):
	_apply_passive_digestion()
	_ensure_hatch_system()
	var slot_index = clamp(int(options.get("slot", 0)), 0, 2)
	if not _hatch_slot_open(slot_index):
		_add_log("孵化槽还没有解锁。")
		state_changed.emit(state)
		return {"success": false, "reason": "slot_locked", "slot": slot_index}
	var slots = state.get("hatchSlots", SaveStore.default_hatch_slots())
	var now = int(Time.get_unix_time_from_system())
	var slot = slots[slot_index]
	if typeof(slot) == TYPE_DICTIONARY and not slot.is_empty():
		var remaining = max(0, int(slot.get("readyAt", now)) - now)
		if remaining > 0:
			return {"success": false, "reason": "incubating", "slot": slot_index, "remaining": remaining, "egg_type": str(slot.get("eggType", "common"))}
		var egg_type = str(slot.get("eggType", "common"))
		var fish = FishFactory.create_fish(rng, _egg_options(egg_type))
		fish["level"] = 1
		fish["exp"] = 0
		fish["age"] = 0
		state["fish"].append(fish)
		slots[slot_index] = {}
		state["hatchSlots"] = slots
		selected_fish_id = fish["id"]
		_record_fish_discovery(fish, true)
		_record_stat("hatchCount", 1)
		_add_log("孵化：%s。" % fish.get("name", "新伙伴"))
		SaveStore.save(state)
		fish_selected.emit(fish)
		state_changed.emit(state)
		return {"success": true, "status": "claimed", "fish": fish, "slot": slot_index, "egg_type": egg_type}
	var egg_type = str(options.get("egg_type", _preferred_egg_type()))
	if egg_type == "" or int(state["eggInventory"].get(egg_type, 0)) <= 0:
		_add_log("鱼蛋不足。")
		state_changed.emit(state)
		return {"success": false, "reason": "no_eggs", "slot": slot_index}
	var egg = GameData.egg_catalog().get(egg_type, GameData.egg_catalog()["common"])
	state["eggInventory"][egg_type] = int(state["eggInventory"].get(egg_type, 0)) - 1
	_sync_egg_total()
	var duration = int(egg.get("duration_seconds", 300))
	slots[slot_index] = {
		"eggType": egg_type,
		"startedAt": now,
		"readyAt": now + duration,
	}
	state["hatchSlots"] = slots
	_add_log("%s 放入 %d 号孵化槽。" % [egg.get("name", "鱼蛋"), slot_index + 1])
	_save_and_emit({"eggs": -1})
	return {"success": true, "status": "started", "slot": slot_index, "egg_type": egg_type, "egg": egg, "remaining": duration}

func buy_shop_item(item_id):
	_apply_passive_digestion()
	_ensure_hatch_system()
	for item in GameData.shop_items():
		if item.get("id", "") != item_id:
			continue
		if not _can_afford(item.get("cost", {})):
			_add_log("%s 资源不足。" % item.get("name", "道具"))
			state_changed.emit(state)
			return {"success": false, "reason": "not_enough", "item": item}
		var delta = {}
		for key in item.get("cost", {}).keys():
			delta[key] = -int(item["cost"][key])
		_add_rewards(delta)
		var egg_count = int(item.get("eggs", 0))
		if egg_count > 0:
			_add_eggs(str(item.get("egg_type", "common")), egg_count)
			delta["eggs"] = int(delta.get("eggs", 0)) + egg_count
		_add_log("购买 %s，鱼蛋 +%d。" % [item.get("name", "道具"), egg_count])
		SaveStore.save(state)
		resources_changed.emit(get_resources(), delta)
		state_changed.emit(state)
		return {"success": true, "item": item, "delta": delta}
	return {"success": false, "reason": "missing"}

func buy_food(food_id):
	_ensure_food_system()
	if not GameData.food_catalog().has(food_id):
		return {"success": false, "reason": "missing"}
	var info = get_food_purchase_info(food_id)
	var food = info.get("food", {})
	if not bool(info.get("can_buy", false)):
		_add_log(_food_buy_fail_text(food, str(info.get("reason", ""))))
		state_changed.emit(state)
		return {
			"success": false,
			"reason": info.get("reason", ""),
			"food": food,
			"info": info,
		}
	var delta = {}
	for key in food.get("cost", {}).keys():
		delta[key] = -int(food["cost"][key])
	_add_rewards(delta)
	var inventory = state.get("foodInventory", {})
	var amount = int(info.get("amount", 1))
	inventory[food_id] = int(inventory.get(food_id, 0)) + amount
	state["foodInventory"] = inventory
	var purchase_state = state.get("foodPurchaseState", {})
	var counts = purchase_state.get("counts", {})
	counts[food_id] = int(counts.get(food_id, 0)) + 1
	purchase_state["counts"] = counts
	state["foodPurchaseState"] = purchase_state
	_record_stat("foodPurchaseCount", 1)
	_add_log("购买 %s +%d。" % [food.get("name", "饲料"), amount])
	_save_and_emit(delta)
	return {
		"success": true,
		"food": food,
		"food_id": food_id,
		"amount": amount,
		"stock": int(inventory.get(food_id, 0)),
		"delta": delta,
		"info": get_food_purchase_info(food_id),
	}

func run_explore(route_id):
	_apply_passive_digestion()
	var fish = get_selected_fish()
	if fish.is_empty():
		return {"success": false, "reason": "no_fish"}
	_ensure_active_explore()
	var route = _route_for(route_id)
	if route.is_empty():
		return {"success": false, "reason": "missing"}
	var now = int(Time.get_unix_time_from_system())
	var active = state.get("activeExplore", {})
	if not active.is_empty():
		var remaining = max(0, int(active.get("endsAt", now)) - now)
		if str(active.get("routeId", "")) != route_id:
			return {"success": false, "reason": "explore_busy", "active": active, "remaining": remaining}
		if remaining > 0:
			return {"success": false, "reason": "explore_pending", "route": route, "active": active, "remaining": remaining}
		return _claim_explore(active, route)
	var bonus = _fish_matches_route(fish, route)
	var duration = int(route.get("duration_seconds", 900))
	var appetite = _sync_appetite_state(fish, now)
	if appetite == "ideal":
		duration = int(round(duration * 0.92))
	elif appetite == "hungry" or appetite == "stuffed":
		duration = int(round(duration * 1.18))
	duration = max(60, duration)
	active = {
		"routeId": route_id,
		"fishId": fish.get("id", ""),
		"startedAt": now,
		"endsAt": now + duration,
		"bonus": bonus,
	}
	state["activeExplore"] = active
	_add_log("%s 出发前往 %s。" % [fish.get("name", "伙伴"), route.get("name", "远行")])
	SaveStore.save(state)
	fish_selected.emit(fish)
	state_changed.emit(state)
	return {"success": true, "status": "started", "route": route, "fish": fish, "active": active, "remaining": duration, "bonus": bonus}

func _claim_explore(active, route):
	var now = int(Time.get_unix_time_from_system())
	var fish = _find_fish_by_id(str(active.get("fishId", "")))
	if fish.is_empty():
		state["activeExplore"] = {}
		SaveStore.save(state)
		state_changed.emit(state)
		return {"success": false, "reason": "fish_missing", "route": route}
	var rewards = route.get("rewards", {}).duplicate()
	var bonus = bool(active.get("bonus", false))
	if bonus:
		rewards["bubbleCoins"] = int(rewards.get("bubbleCoins", 0)) + 80
		fish["intimacy"] = clamp(int(fish.get("intimacy", 0)) + 5, 0, 100)
	var appetite = _sync_appetite_state(fish, now)
	if appetite == "ideal":
		rewards = _scale_trip_rewards(rewards, 1.08)
	elif appetite == "hungry" or appetite == "stuffed":
		rewards = _scale_trip_rewards(rewards, 0.9)
	var duration_minutes = max(1, int(int(route.get("duration_seconds", 900)) / 60))
	var satiety_cost = clamp(8 + int(duration_minutes / 12), 10, 22)
	fish["mood"] = clamp(int(fish.get("mood", 0)) + (8 if bonus else 3), 0, 100)
	fish["hunger"] = clamp(int(fish.get("hunger", 0)) - satiety_cost, 0, 100)
	fish["lastDigestAt"] = now
	_sync_appetite_state(fish, now)
	state["activeExplore"] = {}
	_add_rewards(rewards)
	_record_stat("exploreCount", 1)
	_add_log("%s 从 %s 回来了。" % [fish.get("name", "伙伴"), route.get("name", "远行")])
	SaveStore.save(state)
	fish_selected.emit(fish)
	resources_changed.emit(get_resources(), rewards)
	state_changed.emit(state)
	return {"success": true, "status": "claimed", "route": route, "fish": fish, "rewards": rewards, "bonus": bonus}

func _scale_trip_rewards(rewards, multiplier):
	var scaled = rewards.duplicate()
	for key in ["bubbleCoins", "shells"]:
		if scaled.has(key):
			scaled[key] = max(1, int(round(int(scaled[key]) * multiplier)))
	return scaled

func _route_for(route_id):
	for route in GameData.explore_routes():
		if route.get("id", "") == route_id:
			return route
	return {}

func _fish_matches_route(fish, route):
	var trait_ids = []
	for trait_data in fish.get("traits", []):
		if typeof(trait_data) == TYPE_DICTIONARY:
			trait_ids.append(trait_data.get("id", ""))
	for trait_id in route.get("trait_bonus", []):
		if trait_ids.has(trait_id):
			return true
	return false

func _find_fish_by_id(fish_id):
	for fish in state.get("fish", []):
		if typeof(fish) == TYPE_DICTIONARY and fish.get("id", "") == fish_id:
			return fish
	return {}

func claim_all_rewards():
	var claimed = 0
	var rewards = {}
	for quest in GameData.quest_catalog():
		var completed = int(state.get("stats", {}).get(quest.get("stat", ""), 0)) >= int(quest.get("target", 1))
		if not completed or state.get("claimedQuests", []).has(quest.get("id", "")):
			continue
		for key in quest.get("reward", {}).keys():
			rewards[key] = int(rewards.get(key, 0)) + int(quest["reward"][key])
		state["claimedQuests"].append(quest.get("id", ""))
		claimed += 1
	if claimed > 0:
		_add_rewards(rewards)
		_add_log("领取 %d 个目标奖励。" % claimed)
		_save_and_emit(rewards)
	else:
		_add_log("暂时没有可领取奖励。")
		state_changed.emit(state)
	return {"claimed": claimed, "rewards": rewards}

func get_idle_rate():
	_apply_passive_digestion()
	var pond = get_active_pond()
	var total = 0.0
	for fish in state.get("fish", []):
		var mood_multiplier = 0.78 + int(fish.get("mood", 0)) / 220.0
		var appetite_multiplier = _appetite_output_multiplier(fish)
		var rarity_multiplier = 1.0 + GameData.rarity_order().find(fish.get("rarity", "common")) * 0.18
		total += max(1, int(fish.get("output", 1))) * mood_multiplier * appetite_multiplier * rarity_multiplier
	return int(round(total * float(pond.get("output_multiplier", 1.0))))

func calculate_evolution(fish, pond_id, food_id):
	_apply_passive_digestion()
	if int(fish.get("evolutionStage", 0)) >= MAX_EVOLUTION_STAGE:
		return {"rule": {}, "chance": 0.0, "conditions": [{"label": "完全体", "value": 0.0}]}
	var pond = GameData.pond_catalog()[pond_id]
	var food = GameData.food_catalog().get(food_id, GameData.food_catalog()["basic"])
	var trait_bonus = 0.0
	for trait_data in fish.get("traits", []):
		trait_bonus += float(trait_data.get("chance", 0.0))
	var pity_bonus = clamp(float(fish.get("evolutionPity", 0.0)), 0.0, EVOLUTION_PITY_MAX)
	var base_chance = 0.05 + int(fish.get("level", 1)) * 0.012 + int(fish.get("intimacy", 0)) * 0.0012 + trait_bonus
	var fish_genes = fish["genes"]["visible"].duplicate()
	fish_genes.append(fish["genes"]["hidden"])
	var scored = []
	for rule in GameData.evolution_rules():
		var score = base_chance
		var conditions = [{"label": "成长", "value": base_chance}]
		if pity_bonus > 0.0:
			score += pity_bonus
			conditions.append({"label": "保底", "value": pity_bonus})
		if rule["pond"] == pond_id:
			score += float(pond["chance_bonus"])
			conditions.append({"label": pond["name"], "value": pond["chance_bonus"]})
		else:
			for gene in pond["gene_bias"]:
				if rule["genes"].has(gene):
					score += 0.018
					conditions.append({"label": "生态", "value": 0.018})
					break
		var matched_genes = []
		for gene in rule["genes"]:
			if fish_genes.has(gene):
				matched_genes.append(gene)
		if not matched_genes.is_empty():
			var visible_hits = 0
			for gene in matched_genes:
				if fish["genes"]["visible"].has(gene):
					visible_hits += 1
			var hidden_hits = 1 if matched_genes.has(fish["genes"]["hidden"]) else 0
			var gene_bonus = visible_hits * 0.055 + hidden_hits * 0.075
			score += gene_bonus
			conditions.append({"label": "基因", "value": gene_bonus})
		var food_hits = []
		for tag in food["tags"]:
			if rule["food_tags"].has(tag):
				food_hits.append(tag)
		if not food_hits.is_empty():
			var food_bonus = float(food["chance_bonus"]) + food_hits.size() * 0.025
			score += food_bonus
			conditions.append({"label": "饲料", "value": food_bonus})
		if int(fish.get("mood", 0)) >= 80:
			score += 0.025
		var appetite = _sync_appetite_state(fish, int(Time.get_unix_time_from_system()))
		if appetite == "ideal":
			score += 0.012
			conditions.append({"label": "状态", "value": 0.012})
		elif appetite == "hungry" or appetite == "stuffed":
			score -= 0.045
			conditions.append({"label": "状态", "value": -0.045})
		if int(fish.get("evolutionStage", 0)) == 0:
			score += 0.025
		else:
			score -= int(fish.get("evolutionStage", 0)) * 0.025
		if fish.get("rarity", "common") == "epic" or fish.get("rarity", "common") == "legendary":
			score += 0.02
		scored.append({"rule": rule, "chance": clamp(score, 0.03, 0.72), "conditions": conditions})
	scored.sort_custom(func(a, b): return float(a["chance"]) > float(b["chance"]))
	return scored[0]

func _apply_evolution(fish, rule):
	var old_name = fish["speciesName"]
	var old_rarity = fish["rarity"]
	var order = GameData.rarity_order()
	var next_index = min(order.find(fish["rarity"]) + int(rule["rarity_bump"]), order.size() - 1)
	if str(old_name).begins_with(str(rule["target_name"])):
		fish["speciesName"] = old_name
	else:
		fish["speciesName"] = "%s%s" % [rule["target_name"], old_name]
	fish["rarity"] = order[next_index]
	fish["evolutionStage"] = int(fish.get("evolutionStage", 0)) + 1
	fish["evolutionPity"] = 0.0
	fish["level"] = int(fish.get("level", 1)) + 1
	fish["output"] = int(fish.get("output", 1)) + 5 + int(rule["rarity_bump"]) * 4
	fish["mood"] = clamp(int(fish.get("mood", 0)) + 12, 0, 100)
	fish["intimacy"] = clamp(int(fish.get("intimacy", 0)) + 10, 0, 100)
	if typeof(fish.get("appearance")) != TYPE_DICTIONARY:
		fish["appearance"] = {}
	var old_form = fish["appearance"].get("formId", "base")
	fish["appearance"]["formId"] = rule["id"]
	fish["appearance"]["formTitle"] = rule["title"]
	fish["appearance"]["bodyColor"] = rule["colors"][0]
	fish["appearance"]["accentColor"] = rule["colors"][1]
	fish["appearance"]["finColor"] = rule["colors"][1]
	fish["appearance"]["pattern"] = rule["pattern"]
	fish["appearance"]["glow"] = bool(fish["appearance"].get("glow", false)) or bool(rule["glow"])
	fish["appearance"]["tail"] = {
		"moonveil": "veil",
		"coralbloom": "round",
		"abyss": "fork",
		"thorncrest": "fork",
		"dragonwake": "veil",
	}.get(rule["id"], fish["appearance"].get("tail", "round"))
	fish["appearance"]["body"] = {
		"moonveil": "slender",
		"coralbloom": "round",
		"abyss": "slender",
		"thorncrest": "oval",
		"dragonwake": "slender",
	}.get(rule["id"], fish["appearance"].get("body", "oval"))
	fish["appearance"]["size"] = clamp(float(fish["appearance"].get("size", 1.0)) + 0.12 + int(rule["rarity_bump"]) * 0.03, 0.78, 1.42)
	var story = str(rule["story"]).replace("{name}", fish["name"])
	fish["evolutionHistory"].push_front({
		"ruleId": rule["id"],
		"title": rule["title"],
		"from": old_name,
		"to": fish["speciesName"],
		"formFrom": old_form,
		"formTo": rule["id"],
		"rarityFrom": old_rarity,
		"rarityTo": fish["rarity"],
		"story": story,
		"time": int(Time.get_unix_time_from_system()),
	})
	_record_fish_discovery(fish, true)
	_record_stat("evolutionCount", 1)
	_add_log("%s 进化为 %s。" % [fish["name"], fish["speciesName"]])

func _maybe_level_up(fish):
	var needed = 80 + int(fish.get("level", 1)) * 30
	if int(fish.get("exp", 0)) >= needed:
		fish["exp"] = int(fish.get("exp", 0)) - needed
		fish["level"] = int(fish.get("level", 1)) + 1
		fish["output"] = int(fish.get("output", 1)) + 2
		_add_log("%s 升到 %d 级。" % [fish["name"], fish["level"]])

func _record_stat(key, amount):
	if typeof(state.get("stats")) != TYPE_DICTIONARY:
		state["stats"] = SaveStore.default_stats()
	state["stats"][key] = int(state.get("stats", {}).get(key, 0)) + amount

func _add_log(text):
	state["eventLog"].push_front({"text": text, "time": int(Time.get_unix_time_from_system())})
	state["eventLog"] = state["eventLog"].slice(0, 50)
	log_added.emit(text)

func _add_rewards(rewards):
	if not state.has("resources") or typeof(state.get("resources")) != TYPE_DICTIONARY:
		state["resources"] = {"bubbleCoins": 0, "shells": 0, "eggs": 0, "pearls": 0}
	for key in rewards.keys():
		if key == "eggs":
			_add_eggs("common", int(rewards[key]))
		else:
			state["resources"][key] = int(state["resources"].get(key, 0)) + int(rewards[key])

func _can_afford(cost):
	if not state.has("resources") or typeof(state.get("resources")) != TYPE_DICTIONARY:
		state["resources"] = {"bubbleCoins": 0, "shells": 0, "eggs": 0, "pearls": 0}
	for key in cost.keys():
		if int(state["resources"].get(key, 0)) < int(cost[key]):
			return false
	return true

func _ensure_food_system():
	if state.is_empty():
		return
	var inventory = {}
	if typeof(state.get("foodInventory")) == TYPE_DICTIONARY:
		inventory = state["foodInventory"]
	state["foodInventory"] = SaveStore.ensure_food_inventory(inventory)
	var purchase_state = {}
	if typeof(state.get("foodPurchaseState")) == TYPE_DICTIONARY:
		purchase_state = state["foodPurchaseState"]
	state["foodPurchaseState"] = SaveStore.ensure_food_purchase_state(purchase_state)
	_reset_food_purchase_if_needed()

func _ensure_hatch_system():
	if state.is_empty():
		return
	if typeof(state.get("eggInventory")) != TYPE_DICTIONARY:
		state["eggInventory"] = SaveStore.default_egg_inventory(int(state.get("resources", {}).get("eggs", 0)))
	else:
		state["eggInventory"] = SaveStore.ensure_egg_inventory(state["eggInventory"], int(state.get("resources", {}).get("eggs", 0)))
	if typeof(state.get("hatchSlots")) != TYPE_ARRAY:
		state["hatchSlots"] = SaveStore.default_hatch_slots()
	else:
		state["hatchSlots"] = SaveStore.ensure_hatch_slots(state["hatchSlots"])
	_sync_egg_total()

func _ensure_dex_system():
	if state.is_empty():
		return
	if typeof(state.get("dex")) != TYPE_DICTIONARY:
		state["dex"] = SaveStore.default_dex_state()
	else:
		state["dex"] = SaveStore.ensure_dex_state(state["dex"])
	for fish in state.get("fish", []):
		if typeof(fish) == TYPE_DICTIONARY:
			_record_fish_discovery(fish, false)

func _record_fish_discovery(fish, grant_rewards := false):
	_ensure_dex_container()
	var dex = state["dex"]
	var species_id = str(fish.get("speciesId", ""))
	if species_id == "":
		return {}
	var rewards = {}
	var species_seen = dex["species"].has(species_id)
	if not species_seen:
		dex["species"][species_id] = {
			"firstSeenAt": int(Time.get_unix_time_from_system()),
			"name": fish.get("speciesName", "鱼"),
			"family": fish.get("family", "鱼系"),
			"bestRarity": fish.get("rarity", "common"),
			"sampleFishId": fish.get("id", ""),
		}
	else:
		var entry = dex["species"][species_id]
		var old_rank = GameData.rarity_order().find(str(entry.get("bestRarity", "common")))
		var new_rank = GameData.rarity_order().find(str(fish.get("rarity", "common")))
		if new_rank > old_rank:
			entry["bestRarity"] = fish.get("rarity", "common")
			entry["sampleFishId"] = fish.get("id", "")
			dex["species"][species_id] = entry
	if grant_rewards and not species_seen and not dex["rewardedSpecies"].has(species_id):
		dex["rewardedSpecies"].append(species_id)
		rewards["bubbleCoins"] = int(rewards.get("bubbleCoins", 0)) + 60
	var form_id = str(fish.get("appearance", {}).get("formId", "base"))
	if form_id != "" and form_id != "base":
		var form_key = "%s:%s" % [species_id, form_id]
		var form_seen = dex["forms"].has(form_key)
		if not form_seen:
			dex["forms"][form_key] = {
				"firstSeenAt": int(Time.get_unix_time_from_system()),
				"speciesId": species_id,
				"formId": form_id,
				"title": fish.get("appearance", {}).get("formTitle", form_id),
				"sampleFishId": fish.get("id", ""),
			}
		if grant_rewards and not form_seen and not dex["rewardedForms"].has(form_key):
			dex["rewardedForms"].append(form_key)
			rewards["shells"] = int(rewards.get("shells", 0)) + 4
	state["dex"] = dex
	if not rewards.is_empty():
		_add_rewards(rewards)
	return rewards

func _ensure_dex_container():
	if typeof(state.get("dex")) != TYPE_DICTIONARY:
		state["dex"] = SaveStore.default_dex_state()
	state["dex"] = SaveStore.ensure_dex_state(state["dex"])

func _sync_egg_total():
	if not state.has("resources") or typeof(state.get("resources")) != TYPE_DICTIONARY:
		state["resources"] = {"bubbleCoins": 0, "shells": 0, "eggs": 0, "pearls": 0}
	state["resources"]["eggs"] = SaveStore.total_eggs(state.get("eggInventory", {}))

func _add_eggs(egg_type, amount):
	_ensure_hatch_system()
	if not GameData.egg_catalog().has(egg_type):
		egg_type = "common"
	state["eggInventory"][egg_type] = max(0, int(state["eggInventory"].get(egg_type, 0)) + int(amount))
	_sync_egg_total()

func _preferred_egg_type():
	_ensure_hatch_system()
	for egg_type in ["deep", "color", "common"]:
		if int(state["eggInventory"].get(egg_type, 0)) > 0:
			return egg_type
	return ""

func _egg_options(egg_type):
	var egg = GameData.egg_catalog().get(egg_type, GameData.egg_catalog()["common"])
	var species = _species_for_egg(egg)
	var rarity = egg.get("rarity", species.get("base_rarity", "common"))
	return {"species": species, "rarity": rarity}

func _species_for_egg(egg):
	var species_ids = egg.get("species_ids", [])
	if species_ids.is_empty():
		return GameData.species_catalog()[0]
	var species_id = species_ids[rng.randi_range(0, species_ids.size() - 1)]
	for species in GameData.species_catalog():
		if species.get("id", "") == species_id:
			return species
	return GameData.species_catalog()[0]

func _hatch_slot_open(index):
	if index <= 0:
		return true
	return int(state.get("resources", {}).get("shells", 0)) >= index * 8

func _ensure_active_explore():
	if state.is_empty():
		return
	if typeof(state.get("activeExplore")) != TYPE_DICTIONARY:
		state["activeExplore"] = {}

func _reset_food_purchase_if_needed():
	var today = int(floor(float(Time.get_unix_time_from_system()) / 86400.0))
	var purchase_state = state.get("foodPurchaseState", {})
	if int(purchase_state.get("day", today)) == today:
		return
	purchase_state["day"] = today
	purchase_state["counts"] = {}
	state["foodPurchaseState"] = purchase_state

func _apply_passive_digestion():
	if state.is_empty():
		return false
	var now = int(Time.get_unix_time_from_system())
	var changed = false
	for fish in state.get("fish", []):
		if typeof(fish) != TYPE_DICTIONARY:
			continue
		_ensure_feeding_fields(fish, now)
		var last_digest_at = int(fish.get("lastDigestAt", now))
		var elapsed = max(0, now - last_digest_at)
		var digest_points = int(elapsed / DIGEST_SECONDS_PER_POINT)
		if digest_points > 0:
			fish["hunger"] = clamp(int(fish.get("hunger", 0)) - digest_points, 0, 100)
			fish["lastDigestAt"] = last_digest_at + digest_points * DIGEST_SECONDS_PER_POINT
			changed = true
		var before = str(fish.get("appetiteState", "normal"))
		var synced = _sync_appetite_state(fish, now)
		if synced != before:
			changed = true
	return changed

func _ensure_feeding_fields(fish, now):
	if not fish.has("lastDigestAt"):
		fish["lastDigestAt"] = now
	if not fish.has("lastFedAt"):
		fish["lastFedAt"] = 0
	if not fish.has("appetiteState"):
		fish["appetiteState"] = "normal"
	if not fish.has("appetiteUntil"):
		fish["appetiteUntil"] = 0
	fish["hunger"] = clamp(int(fish.get("hunger", 0)), 0, 100)

func _sync_appetite_state(fish, now):
	_ensure_feeding_fields(fish, now)
	var fullness = int(fish.get("hunger", 0))
	var current = str(fish.get("appetiteState", "normal"))
	var until = int(fish.get("appetiteUntil", 0))
	var state_id = "normal"
	if current == "stuffed" and until > now:
		state_id = "stuffed"
	elif fullness <= HUNGRY_FULLNESS:
		state_id = "hungry"
	elif fullness >= FULL_FULLNESS:
		state_id = "full"
	elif fullness >= IDEAL_FULLNESS_MIN and fullness <= IDEAL_FULLNESS_MAX:
		state_id = "ideal"
	fish["appetiteState"] = state_id
	if state_id != "stuffed" and until <= now:
		fish["appetiteUntil"] = 0
	return state_id

func _appetite_label(appetite):
	return {
		"hungry": "有点饿",
		"ideal": "状态正好",
		"normal": "正常",
		"full": "偏饱",
		"stuffed": "吃撑了",
	}.get(appetite, "正常")

func _appetite_output_multiplier(fish):
	var appetite = _sync_appetite_state(fish, int(Time.get_unix_time_from_system()))
	match appetite:
		"hungry":
			return 0.86
		"ideal":
			return 1.06
		"full":
			return 0.94
		"stuffed":
			return 0.78
		_:
			return 1.0

func _food_buy_fail_text(food, reason):
	var name = food.get("name", "饲料")
	match reason:
		"stock_full":
			return "%s 库存已满。" % name
		"daily_limit":
			return "%s 今日购买次数用完。" % name
		"not_enough":
			return "购买 %s 的资源不足。" % name
		_:
			return "%s 暂时不能购买。" % name

func _save_and_emit(delta := {}):
	SaveStore.save(state)
	resources_changed.emit(get_resources(), delta)
	state_changed.emit(state)
