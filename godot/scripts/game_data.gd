extends RefCounted
class_name GameData

static func species_catalog():
	return [
		{
			"id": "blue_minifish",
			"name": "小蓝鱼",
			"family": "溪流系",
			"base_rarity": "common",
			"output": 8,
			"genes": ["moon", "coral", "spark", "transparent"],
			"palette": ["#58b7d8", "#7fd8b7", "#f2d37b"],
		},
		{
			"id": "sun_koi",
			"name": "日纹锦鲤",
			"family": "锦鲤系",
			"base_rarity": "common",
			"output": 11,
			"genes": ["sun", "dragon", "pearl", "coral"],
			"palette": ["#f26d5b", "#f2b84b", "#fff1c7"],
		},
		{
			"id": "bubble_puffer",
			"name": "泡泡河豚",
			"family": "圆鼓系",
			"base_rarity": "rare",
			"output": 14,
			"genes": ["thorn", "storm", "transparent", "spark"],
			"palette": ["#f5d86e", "#77c9a6", "#f4a28c"],
		},
		{
			"id": "lantern_fry",
			"name": "灯影幼鱼",
			"family": "深海系",
			"base_rarity": "rare",
			"output": 16,
			"genes": ["deepsea", "moon", "spark", "storm"],
			"palette": ["#4665b0", "#6f5ea8", "#84e6cf"],
		},
		{
			"id": "ribbon_betta",
			"name": "缎尾斗鱼",
			"family": "华丽系",
			"base_rarity": "epic",
			"output": 20,
			"genes": ["pearl", "dragon", "sun", "moon"],
			"palette": ["#8e5fd3", "#ef6f8f", "#f2b84b"],
		},
	]

static func gene_catalog():
	return {
		"moon": {"label": "月光基因", "note": "夜间和月光湖会放大进化意外。"},
		"coral": {"label": "珊瑚基因", "note": "更容易长出彩色鳍和枝角。"},
		"deepsea": {"label": "深海基因", "note": "低概率触发深水形态。"},
		"transparent": {"label": "透明基因", "note": "可能出现玻璃鳞和隐身轮廓。"},
		"thorn": {"label": "棘刺基因", "note": "活力粮会提高防御形态响应。"},
		"dragon": {"label": "龙鳞基因", "note": "传说路线的早期线索。"},
		"spark": {"label": "荧光基因", "note": "蛋白粮会提高活跃响应。"},
		"pearl": {"label": "珍珠基因", "note": "更容易产出贝壳和珍珠色花纹。"},
		"storm": {"label": "风暴基因", "note": "强波动事件中更活跃。"},
		"sun": {"label": "日纹基因", "note": "暖色饲料会诱导明亮形态。"},
	}

static func trait_catalog():
	return [
		{"id": "curious", "label": "好奇", "mood": 8, "chance": 0.03},
		{"id": "shy", "label": "胆小", "mood": 4, "chance": 0.01},
		{"id": "greedy", "label": "贪吃", "mood": 6, "chance": 0.025},
		{"id": "loner", "label": "孤僻", "mood": 2, "chance": 0.015},
		{"id": "gentle", "label": "亲人", "mood": 10, "chance": 0.02},
		{"id": "restless", "label": "爱冒险", "mood": 5, "chance": 0.035},
		{"id": "proud", "label": "爱炫耀", "mood": 7, "chance": 0.03},
	]

static func pond_catalog():
	return {
		"starter": {
			"name": "新手池塘",
			"color_a": "#bcefe1",
			"color_b": "#3389a2",
			"gene_bias": ["transparent", "pearl"],
			"bonus_label": "稳定成长",
			"chance_bonus": 0.02,
			"output_multiplier": 1.0,
		},
		"coral": {
			"name": "珊瑚浅湾",
			"color_a": "#ffd0b7",
			"color_b": "#269fa1",
			"gene_bias": ["coral", "sun", "pearl"],
			"bonus_label": "花纹与鳍形",
			"chance_bonus": 0.04,
			"output_multiplier": 1.16,
		},
		"moon": {
			"name": "月光湖",
			"color_a": "#cfcbff",
			"color_b": "#2b5f82",
			"gene_bias": ["moon", "spark", "deepsea"],
			"bonus_label": "发光与突变",
			"chance_bonus": 0.05,
			"output_multiplier": 1.24,
		},
	}

static func food_catalog():
	return {
		"basic": {
			"name": "日常颗粒鱼粮",
			"short": "颗粒粮",
			"desc": "普通小颗粒，适合日常喂养。",
			"tags": ["growth"],
			"chance_bonus": 0.01,
			"exp": 22,
			"mood": 4,
			"satiety": 22,
			"cost": {"bubbleCoins": 45},
			"bundle": 3,
			"max_stock": 12,
			"daily_limit": 4,
			"overfeed_at": 86,
			"overfeed_mood_penalty": 12,
		},
		"glow": {
			"name": "高蛋白虫粮",
			"short": "蛋白粮",
			"desc": "虫干和蛋白粉，帮助成长和活跃。",
			"tags": ["spark", "moon"],
			"chance_bonus": 0.05,
			"exp": 30,
			"mood": 3,
			"satiety": 30,
			"cost": {"bubbleCoins": 90},
			"bundle": 2,
			"max_stock": 8,
			"daily_limit": 3,
			"overfeed_at": 78,
			"overfeed_mood_penalty": 18,
		},
		"coral": {
			"name": "增色片状鱼粮",
			"short": "增色粮",
			"desc": "含虾红素和矿物质，偏向颜色表现。",
			"tags": ["coral", "pearl"],
			"chance_bonus": 0.045,
			"exp": 18,
			"mood": 6,
			"satiety": 24,
			"cost": {"bubbleCoins": 70, "shells": 2},
			"bundle": 2,
			"max_stock": 8,
			"daily_limit": 3,
			"overfeed_at": 82,
			"overfeed_mood_penalty": 14,
		},
		"spicy": {
			"name": "活力混合鱼粮",
			"short": "活力粮",
			"desc": "高能混合粮，见效快但不适合连喂。",
			"tags": ["thorn", "storm", "dragon"],
			"chance_bonus": 0.035,
			"exp": 36,
			"mood": -2,
			"satiety": 34,
			"cost": {"bubbleCoins": 120, "shells": 3},
			"bundle": 1,
			"max_stock": 5,
			"daily_limit": 2,
			"overfeed_at": 72,
			"overfeed_mood_penalty": 24,
		},
	}

static func evolution_rules():
	return [
		{
			"id": "moonveil",
			"title": "月纱化",
			"target_name": "月纱",
			"rarity_bump": 1,
			"genes": ["moon", "spark"],
			"pond": "moon",
			"food_tags": ["moon", "spark"],
			"colors": ["#bfc9ff", "#84e6cf"],
			"pattern": "stars",
			"glow": true,
			"story": "{name}追着一串发亮的浮游生物游进月影里，尾鳍像薄纱一样亮了起来。",
		},
		{
			"id": "coralbloom",
			"title": "珊瑚绽放",
			"target_name": "珊瑚鳍",
			"rarity_bump": 1,
			"genes": ["coral", "pearl", "sun"],
			"pond": "coral",
			"food_tags": ["coral", "pearl"],
			"colors": ["#ff806d", "#ffd37d"],
			"pattern": "petals",
			"glow": false,
			"story": "{name}蹭过新生珊瑚，鳍边长出细小分枝，像一朵会游泳的花。",
		},
		{
			"id": "abyss",
			"title": "深渊回声",
			"target_name": "深渊灯",
			"rarity_bump": 2,
			"genes": ["deepsea", "storm", "spark"],
			"pond": "moon",
			"food_tags": ["spark", "storm"],
			"colors": ["#243b6b", "#52ffd6"],
			"pattern": "lantern",
			"glow": true,
			"story": "{name}潜到鱼塘最暗的角落，再浮上来时额前多了一点幽幽的光。",
		},
		{
			"id": "thorncrest",
			"title": "棘冠突变",
			"target_name": "棘冠",
			"rarity_bump": 1,
			"genes": ["thorn", "storm"],
			"pond": "starter",
			"food_tags": ["thorn", "storm"],
			"colors": ["#7fd8b7", "#f26d5b"],
			"pattern": "spikes",
			"glow": false,
			"story": "{name}绕着池壁冲刺三圈，身侧冒出了漂亮又危险的小棘。",
		},
		{
			"id": "dragonwake",
			"title": "龙鳞苏醒",
			"target_name": "龙纹",
			"rarity_bump": 2,
			"genes": ["dragon", "sun", "pearl"],
			"pond": "coral",
			"food_tags": ["dragon", "pearl"],
			"colors": ["#f2b84b", "#f26d5b"],
			"pattern": "scales",
			"glow": true,
			"story": "{name}绕着金色贝壳盘旋，鳞片一片片亮起，像古老的东西正在醒来。",
		},
	]

static func shop_items():
	return [
		{"id": "common_egg", "name": "普通鱼蛋", "desc": "稳定获得一条基础鱼。", "egg_type": "common", "cost": {"bubbleCoins": 120}, "eggs": 1},
		{"id": "color_egg", "name": "彩纹鱼蛋", "desc": "更容易出现稀有颜色和花纹。", "egg_type": "color", "cost": {"bubbleCoins": 260, "shells": 6}, "eggs": 1},
		{"id": "deep_egg", "name": "深海鱼蛋", "desc": "带来高概率深海或荧光基因。", "egg_type": "deep", "cost": {"shells": 18, "pearls": 2}, "eggs": 1},
	]

static func egg_catalog():
	return {
		"common": {
			"name": "普通鱼蛋",
			"short": "普通",
			"duration_seconds": 300,
			"rarity": "common",
			"species_ids": ["blue_minifish", "sun_koi", "bubble_puffer"],
		},
		"color": {
			"name": "彩纹鱼蛋",
			"short": "彩纹",
			"duration_seconds": 900,
			"rarity": "rare",
			"species_ids": ["sun_koi", "bubble_puffer", "ribbon_betta"],
		},
		"deep": {
			"name": "深海鱼蛋",
			"short": "深海",
			"duration_seconds": 1800,
			"rarity": "epic",
			"species_ids": ["lantern_fry", "bubble_puffer", "ribbon_betta"],
		},
	}

static func explore_routes():
	return [
		{"id": "driftwood", "name": "漂流木湾", "time": "15 分钟", "duration_seconds": 900, "desc": "适合新鱼练胆，常带回鱼蛋和泡泡币。", "rewards": {"bubbleCoins": 180, "eggs": 1}, "trait_bonus": ["curious", "gentle"]},
		{"id": "shipwreck", "name": "沉船遗迹", "time": "45 分钟", "duration_seconds": 2700, "desc": "需要一点勇气，可能发现贝壳和稀有进化线索。", "rewards": {"shells": 8, "bubbleCoins": 260}, "trait_bonus": ["restless", "proud"]},
		{"id": "glow_trench", "name": "发光海沟", "time": "2 小时", "duration_seconds": 7200, "desc": "高风险高惊喜，深海和荧光基因会更占优势。", "rewards": {"pearls": 1, "shells": 12}, "trait_bonus": ["restless", "greedy"]},
	]

static func quest_catalog():
	return [
		{"id": "collect", "title": "收取一次放置产出", "stat": "collectCount", "target": 1, "reward": {"bubbleCoins": 120, "shells": 2}},
		{"id": "hatch", "title": "孵化一枚鱼蛋", "stat": "hatchCount", "target": 1, "reward": {"eggs": 1, "bubbleCoins": 80}},
		{"id": "evolve_try", "title": "尝试两次进化", "stat": "evolveAttempts", "target": 2, "reward": {"shells": 10}},
		{"id": "explore", "title": "完成一次探索", "stat": "exploreCount", "target": 1, "reward": {"pearls": 1}},
		{"id": "share", "title": "生成一张鱼卡", "stat": "shareCount", "target": 1, "reward": {"bubbleCoins": 160}},
	]

static func rarity_order():
	return ["common", "rare", "epic", "legendary"]

static func rarity_label(rarity):
	return {"common": "普通", "rare": "稀有", "epic": "史诗", "legendary": "传说"}.get(rarity, "未知")

static func resource_label(key):
	return {"bubbleCoins": "泡泡币", "shells": "贝壳", "eggs": "鱼蛋", "pearls": "珍珠"}.get(key, key)

static func pattern_label(pattern):
	return {
		"stars": "星点花纹",
		"petals": "花瓣花纹",
		"lantern": "灯影器官",
		"glass": "玻璃鳞片",
		"spikes": "棘刺轮廓",
		"scales": "龙鳞纹",
		"dots": "斑点花纹",
		"pearls": "珍珠斑",
		"stripes": "波纹条纹",
		"sunburst": "日纹放射",
	}.get(pattern, "未知花纹")
