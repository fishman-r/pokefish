extends RefCounted
class_name FishFactory

const GameData = preload("res://godot/scripts/game_data.gd")

static func create_fish(rng, options := {}):
	var species = options.get("species", pick_weighted_species(rng))
	var genes = pick_genes(rng, species)
	var traits = GameData.trait_catalog()
	var primary_trait = random_from(rng, traits)
	var second_pool = []
	for item in traits:
		if item["id"] != primary_trait["id"]:
			second_pool.append(item)
	var secondary_trait = random_from(rng, second_pool)
	var appearance = create_appearance(rng, species, genes)
	var rarity = options.get("rarity", roll_rarity(rng, species["base_rarity"], genes))
	var now = int(Time.get_unix_time_from_system())

	return {
		"id": create_id(rng),
		"speciesId": species["id"],
		"speciesName": species["name"],
		"family": species["family"],
		"name": "%s%s" % [random_from(rng, name_bits_a()), random_from(rng, name_bits_b())],
		"rarity": rarity,
		"level": rng.randi_range(1, 4),
		"exp": rng.randi_range(0, 65),
		"age": rng.randi_range(1, 12),
		"mood": rng.randi_range(58, 94),
		"hunger": rng.randi_range(18, 46),
		"lastDigestAt": now,
		"lastFedAt": 0,
		"appetiteState": "normal",
		"appetiteUntil": 0,
		"intimacy": rng.randi_range(8, 38),
		"genes": genes,
		"traits": [primary_trait.duplicate(true), secondary_trait.duplicate(true)],
		"appearance": appearance,
		"output": int(species["output"]) + rng.randi_range(-2, 4),
		"evolutionStage": 0,
		"evolutionPity": 0.0,
		"evolutionHistory": [],
		"createdAt": now,
		"swim": create_swim(rng),
	}

static func pick_weighted_species(rng):
	var pool = []
	for species in GameData.species_catalog():
		var count = 1
		if species["base_rarity"] == "common":
			count = 5
		elif species["base_rarity"] == "rare":
			count = 3
		for _i in range(count):
			pool.append(species)
	return random_from(rng, pool)

static func pick_genes(rng, species):
	var visible = shuffle_copy(rng, species["genes"]).slice(0, 2)
	var hidden_pool = []
	for gene in GameData.gene_catalog().keys():
		if not visible.has(gene):
			hidden_pool.append(gene)
	var hidden = random_from(rng, species["genes"]) if rng.randf() < 0.72 else random_from(rng, hidden_pool)
	return {"visible": visible, "hidden": hidden}

static func roll_rarity(rng, base_rarity, genes):
	var order = GameData.rarity_order()
	var index = order.find(base_rarity)
	if genes["hidden"] == "dragon" and rng.randf() < 0.24:
		index += 1
	if genes["visible"].has("deepsea") and rng.randf() < 0.18:
		index += 1
	if rng.randf() < 0.04:
		index += 1
	return order[min(index, order.size() - 1)]

static func create_appearance(rng, species, genes):
	var body_color = random_from(rng, species["palette"])
	var accent_pool = ["#ffffff", "#f2b84b", "#f26d5b", "#7fd8b7", "#6f5ea8", "#172326"]
	accent_pool.erase(body_color)
	var pattern_by_gene = {
		"moon": "stars",
		"coral": "petals",
		"deepsea": "lantern",
		"transparent": "glass",
		"thorn": "spikes",
		"dragon": "scales",
		"spark": "dots",
		"pearl": "pearls",
		"storm": "stripes",
		"sun": "sunburst",
	}
	var pattern_source = genes["visible"].duplicate()
	pattern_source.append(genes["hidden"])
	return {
		"bodyColor": body_color,
		"accentColor": random_from(rng, accent_pool),
		"finColor": random_from(rng, species["palette"]),
		"pattern": pattern_by_gene.get(random_from(rng, pattern_source), "dots"),
		"tail": random_from(rng, ["fork", "round", "veil"]),
		"size": rng.randf_range(0.82, 1.22),
		"body": random_from(rng, ["oval", "round", "slender"]),
		"glow": genes["visible"].has("spark") or genes["hidden"] == "moon",
		"eyeStyle": random_from(rng, ["bright", "sleepy", "wide"]),
		"cheek": random_from(rng, ["soft", "dot", "stripe"]),
	}

static func create_swim(rng):
	var direction = 1 if rng.randf() > 0.5 else -1
	return {
		"x": rng.randf_range(80.0, 320.0),
		"y": rng.randf_range(120.0, 360.0),
		"vx": rng.randf_range(24.0, 52.0) * direction,
		"wave": rng.randf_range(0.0, TAU),
		"wiggle": rng.randf_range(0.86, 1.24),
		"depth": rng.randf_range(0.72, 1.16),
	}

static func random_from(rng, items):
	if items.is_empty():
		return null
	return items[rng.randi_range(0, items.size() - 1)]

static func shuffle_copy(rng, items):
	var result = items.duplicate()
	for i in range(result.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = result[i]
		result[i] = result[j]
		result[j] = temp
	return result

static func create_id(rng):
	return "fish_%d_%d" % [Time.get_ticks_usec(), rng.randi_range(100000, 999999)]

static func name_bits_a():
	return ["泡泡", "鳞光", "小潮", "啵啵", "银尾", "圆圆", "浮灯", "浅星", "珊珊", "麦浪"]

static func name_bits_b():
	return ["一号", "闪闪", "阿蓝", "果冻", "海盐", "月牙", "风铃", "花火", "薄荷", "贝塔"]
