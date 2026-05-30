const STORAGE_KEY = "pokefish.prototype.v1";

const speciesCatalog = [
  {
    id: "blue_minifish",
    name: "小蓝鱼",
    family: "溪流系",
    baseRarity: "common",
    output: 8,
    genes: ["moon", "coral", "spark", "transparent"],
    palette: ["#58b7d8", "#7fd8b7", "#f2d37b"],
  },
  {
    id: "sun_koi",
    name: "日纹锦鲤",
    family: "锦鲤系",
    baseRarity: "common",
    output: 11,
    genes: ["sun", "dragon", "pearl", "coral"],
    palette: ["#f26d5b", "#f2b84b", "#fff1c7"],
  },
  {
    id: "bubble_puffer",
    name: "泡泡河豚",
    family: "圆鼓系",
    baseRarity: "rare",
    output: 14,
    genes: ["thorn", "storm", "transparent", "spark"],
    palette: ["#f5d86e", "#77c9a6", "#f4a28c"],
  },
  {
    id: "lantern_fry",
    name: "灯影幼鱼",
    family: "深海系",
    baseRarity: "rare",
    output: 16,
    genes: ["deepsea", "moon", "spark", "storm"],
    palette: ["#4665b0", "#6f5ea8", "#84e6cf"],
  },
  {
    id: "ribbon_betta",
    name: "缎尾斗鱼",
    family: "华丽系",
    baseRarity: "epic",
    output: 20,
    genes: ["pearl", "dragon", "sun", "moon"],
    palette: ["#8e5fd3", "#ef6f8f", "#f2b84b"],
  },
];

const geneCatalog = {
  moon: { label: "月光基因", note: "夜间和月光湖会放大进化意外。" },
  coral: { label: "珊瑚基因", note: "更容易长出彩色鳍和枝角。" },
  deepsea: { label: "深海基因", note: "低概率触发深水形态。" },
  transparent: { label: "透明基因", note: "可能出现玻璃鳞和隐身轮廓。" },
  thorn: { label: "棘刺基因", note: "受刺激时可能突变防御形态。" },
  dragon: { label: "龙鳞基因", note: "传说路线的早期线索。" },
  spark: { label: "荧光基因", note: "发光饲料会提高响应。" },
  pearl: { label: "珍珠基因", note: "更容易产出贝壳和珍珠色花纹。" },
  storm: { label: "风暴基因", note: "强波动事件中更活跃。" },
  sun: { label: "日纹基因", note: "暖色饲料会诱导明亮形态。" },
};

const traitCatalog = [
  { id: "curious", label: "好奇", mood: 8, chance: 0.03 },
  { id: "shy", label: "胆小", mood: 4, chance: 0.01 },
  { id: "greedy", label: "贪吃", mood: 6, chance: 0.025 },
  { id: "loner", label: "孤僻", mood: 2, chance: 0.015 },
  { id: "gentle", label: "亲人", mood: 10, chance: 0.02 },
  { id: "restless", label: "爱冒险", mood: 5, chance: 0.035 },
  { id: "proud", label: "爱炫耀", mood: 7, chance: 0.03 },
];

const pondCatalog = {
  starter: {
    name: "新手池塘",
    colorA: "#bcefe1",
    colorB: "#3389a2",
    geneBias: ["transparent", "pearl"],
    bonusLabel: "稳定成长",
    chanceBonus: 0.02,
    outputMultiplier: 1,
  },
  coral: {
    name: "珊瑚浅湾",
    colorA: "#ffd0b7",
    colorB: "#269fa1",
    geneBias: ["coral", "sun", "pearl"],
    bonusLabel: "花纹与鳍形",
    chanceBonus: 0.04,
    outputMultiplier: 1.16,
  },
  moon: {
    name: "月光湖",
    colorA: "#cfcbff",
    colorB: "#2b5f82",
    geneBias: ["moon", "spark", "deepsea"],
    bonusLabel: "发光与突变",
    chanceBonus: 0.05,
    outputMultiplier: 1.24,
  },
};

const foodCatalog = {
  basic: {
    name: "基础浮游生物",
    tags: ["growth"],
    chanceBonus: 0.01,
    exp: 24,
    mood: 4,
  },
  glow: {
    name: "发光浮游生物",
    tags: ["spark", "moon"],
    chanceBonus: 0.05,
    exp: 18,
    mood: 8,
  },
  coral: {
    name: "珊瑚粉",
    tags: ["coral", "pearl"],
    chanceBonus: 0.045,
    exp: 16,
    mood: 7,
  },
  spicy: {
    name: "刺激海藻",
    tags: ["thorn", "storm", "dragon"],
    chanceBonus: 0.035,
    exp: 30,
    mood: -5,
  },
};

const evolutionRules = [
  {
    id: "moonveil",
    title: "月纱化",
    targetName: "月纱",
    rarityBump: 1,
    genes: ["moon", "spark"],
    pond: "moon",
    foodTags: ["moon", "spark"],
    colors: ["#bfc9ff", "#84e6cf"],
    pattern: "stars",
    glow: true,
    story: "{name}追着一串发亮的浮游生物游进月影里。水面安静下来时，它的尾鳍像薄纱一样亮了起来。",
  },
  {
    id: "coralbloom",
    title: "珊瑚绽放",
    targetName: "珊瑚鳍",
    rarityBump: 1,
    genes: ["coral", "pearl", "sun"],
    pond: "coral",
    foodTags: ["coral", "pearl"],
    colors: ["#ff806d", "#ffd37d"],
    pattern: "petals",
    glow: false,
    story: "{name}在浅湾蹭过新生珊瑚，鳍边悄悄长出细小分枝，像一朵会游泳的花。",
  },
  {
    id: "abyss",
    title: "深渊回声",
    targetName: "深渊灯",
    rarityBump: 2,
    genes: ["deepsea", "storm", "spark"],
    pond: "moon",
    foodTags: ["spark", "storm"],
    colors: ["#243b6b", "#52ffd6"],
    pattern: "lantern",
    glow: true,
    story: "{name}忽然潜到鱼塘最暗的角落。再浮上来时，它额前多了一点幽幽的光。",
  },
  {
    id: "thorncrest",
    title: "棘冠突变",
    targetName: "棘冠",
    rarityBump: 1,
    genes: ["thorn", "storm"],
    pond: "starter",
    foodTags: ["thorn", "storm"],
    colors: ["#7fd8b7", "#f26d5b"],
    pattern: "spikes",
    glow: false,
    story: "{name}被刺激海藻呛了一下，绕着池壁冲刺三圈，身侧冒出了漂亮又危险的小棘。",
  },
  {
    id: "dragonwake",
    title: "龙鳞苏醒",
    targetName: "龙纹",
    rarityBump: 2,
    genes: ["dragon", "sun", "pearl"],
    pond: "coral",
    foodTags: ["dragon", "pearl"],
    colors: ["#f2b84b", "#f26d5b"],
    pattern: "scales",
    glow: true,
    story: "{name}绕着一枚金色贝壳盘旋，鳞片一片片亮起，像有很古老的东西正在醒来。",
  },
];

const rarityOrder = ["common", "rare", "epic", "legendary"];
const rarityLabel = {
  common: "普通",
  rare: "稀有",
  epic: "史诗",
  legendary: "传说",
};

const nameBitsA = ["泡泡", "鳞光", "小潮", "啵啵", "银尾", "圆圆", "浮灯", "浅星", "珊珊", "麦浪"];
const nameBitsB = ["一号", "闪闪", "阿蓝", "果冻", "海盐", "月牙", "风铃", "花火", "薄荷", "贝塔"];

const state = loadState();
let selectedFishId = state.fish[0]?.id;
let activePondId = state.activePondId || "starter";
let sortByRarity = false;
let lastFrame = performance.now();
const bubbles = Array.from({ length: 34 }, createBubble);

const shopItems = [
  { id: "common_egg", name: "普通鱼蛋", desc: "稳定获得一条基础鱼。", cost: { bubbleCoins: 120 }, eggs: 1 },
  { id: "color_egg", name: "彩纹鱼蛋", desc: "更容易出现稀有颜色和花纹。", cost: { bubbleCoins: 260, shells: 6 }, eggs: 1 },
  { id: "deep_egg", name: "深海鱼蛋", desc: "带来高概率深海或荧光基因。", cost: { shells: 18, pearls: 2 }, eggs: 1 },
];

const exploreRoutes = [
  {
    id: "driftwood",
    name: "漂流木湾",
    time: "15 分钟",
    desc: "适合新鱼练胆，常带回鱼蛋和泡泡币。",
    rewards: { bubbleCoins: 180, eggs: 1 },
    traitBonus: ["curious", "gentle"],
  },
  {
    id: "shipwreck",
    name: "沉船遗迹",
    time: "45 分钟",
    desc: "需要一点勇气，可能发现贝壳和稀有进化线索。",
    rewards: { shells: 8, bubbleCoins: 260 },
    traitBonus: ["restless", "proud"],
  },
  {
    id: "glow_trench",
    name: "发光海沟",
    time: "2 小时",
    desc: "高风险高惊喜，深海和荧光基因会更占优势。",
    rewards: { pearls: 1, shells: 12 },
    traitBonus: ["restless", "greedy"],
  },
];

const questCatalog = [
  { id: "collect", title: "收取一次放置产出", stat: "collectCount", target: 1, reward: { bubbleCoins: 120, shells: 2 } },
  { id: "hatch", title: "孵化一枚鱼蛋", stat: "hatchCount", target: 1, reward: { eggs: 1, bubbleCoins: 80 } },
  { id: "evolve_try", title: "尝试两次进化", stat: "evolveAttempts", target: 2, reward: { shells: 10 } },
  { id: "explore", title: "完成一次探索", stat: "exploreCount", target: 1, reward: { pearls: 1 } },
  { id: "share", title: "生成一张鱼卡", stat: "shareCount", target: 1, reward: { bubbleCoins: 160 } },
];

const els = {
  bubbleCoins: document.querySelector("#bubbleCoins"),
  shells: document.querySelector("#shells"),
  eggs: document.querySelector("#eggs"),
  pearls: document.querySelector("#pearls"),
  pondName: document.querySelector("#pondName"),
  idleRate: document.querySelector("#idleRate"),
  fishDetail: document.querySelector("#fishDetail"),
  fishRoster: document.querySelector("#fishRoster"),
  collectionSummary: document.querySelector("#collectionSummary"),
  speciesDex: document.querySelector("#speciesDex"),
  hatchSlots: document.querySelector("#hatchSlots"),
  eggShop: document.querySelector("#eggShop"),
  exploreList: document.querySelector("#exploreList"),
  exploreDetail: document.querySelector("#exploreDetail"),
  questList: document.querySelector("#questList"),
  eventLog: document.querySelector("#eventLog"),
  evolutionChance: document.querySelector("#evolutionChance"),
  chanceFill: document.querySelector("#chanceFill"),
  conditionList: document.querySelector("#conditionList"),
  foodSelect: document.querySelector("#foodSelect"),
  pondCanvas: document.querySelector("#pondCanvas"),
  shareModal: document.querySelector("#shareModal"),
  shareCard: document.querySelector("#shareCard"),
};

const ctx = els.pondCanvas.getContext("2d");

document.querySelector("#collectButton").addEventListener("click", collectIdleReward);
document.querySelector("#hatchButton").addEventListener("click", hatchFish);
document.querySelector("#quickHatchButton").addEventListener("click", hatchFish);
document.querySelector("#shareButton").addEventListener("click", openShareCard);
document.querySelector("#closeShareButton").addEventListener("click", closeShareCard);
document.querySelector("#claimAllButton").addEventListener("click", claimAllRewards);
document.querySelector("#sortButton").addEventListener("click", () => {
  sortByRarity = !sortByRarity;
  document.querySelector("#sortButton").textContent = sortByRarity ? "按获得时间排序" : "按稀有度排序";
  renderCollection();
});
document.querySelector("#resetButton").addEventListener("click", () => {
  localStorage.removeItem(STORAGE_KEY);
  location.reload();
});
document.querySelector("#evolveButton").addEventListener("click", tryEvolution);
els.foodSelect.addEventListener("change", renderEvolutionLab);
document.querySelectorAll(".nav-button").forEach((button) => {
  button.addEventListener("click", () => showScreen(button.dataset.screenTarget));
});
document.querySelectorAll(".mode-button").forEach((button) => {
  button.addEventListener("click", () => {
    activePondId = button.dataset.pond;
    state.activePondId = activePondId;
    recordStat("pondSwitches", 1);
    document.querySelectorAll(".mode-button").forEach((item) => item.classList.remove("active"));
    button.classList.add("active");
    addLog(`水域切换到 ${pondCatalog[activePondId].name}，进化倾向变为 ${pondCatalog[activePondId].bonusLabel}。`);
    saveAndRender();
  });
});

els.pondCanvas.addEventListener("click", (event) => {
  const rect = els.pondCanvas.getBoundingClientRect();
  const x = ((event.clientX - rect.left) / rect.width) * els.pondCanvas.width;
  const y = ((event.clientY - rect.top) / rect.height) * els.pondCanvas.height;
  const hit = [...state.fish].reverse().find((fish) => {
    const dx = x - fish.swim.x;
    const dy = y - fish.swim.y;
    return Math.sqrt(dx * dx + dy * dy) < 54 * fish.appearance.size;
  });

  if (hit) {
    selectedFishId = hit.id;
    render();
  }
});

function loadState() {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (saved) {
    try {
      const parsed = JSON.parse(saved);
      return ensureState(parsed);
    } catch {
      localStorage.removeItem(STORAGE_KEY);
    }
  }

  return ensureState({
    resources: { bubbleCoins: 260, shells: 18, eggs: 3, pearls: 1 },
    fish: Array.from({ length: 5 }, () => createFish()),
    eventLog: [],
    activePondId: "starter",
    lastCollectAt: Date.now() - 1000 * 60 * 18,
    stats: {},
    claimedQuests: [],
  });
}

function ensureState(input) {
  const initial = {
    resources: { bubbleCoins: 0, shells: 0, eggs: 0, pearls: 0 },
    fish: [],
    eventLog: [],
    activePondId: "starter",
    lastCollectAt: Date.now(),
    stats: {
      collectCount: 0,
      hatchCount: 0,
      evolveAttempts: 0,
      evolutionCount: 0,
      exploreCount: 0,
      shareCount: 0,
      pondSwitches: 0,
    },
    claimedQuests: [],
  };
  const next = { ...initial, ...input };
  next.resources = { ...initial.resources, ...input.resources };
  next.stats = { ...initial.stats, ...input.stats };
  next.claimedQuests = Array.isArray(input.claimedQuests) ? input.claimedQuests : [];
  next.fish = Array.isArray(input.fish) ? input.fish.map(ensureFish) : [];
  if (!next.fish.length) {
    next.fish = Array.from({ length: 5 }, () => createFish());
  }
  next.eventLog = Array.isArray(input.eventLog) ? input.eventLog.slice(0, 40) : [];
  return next;
}

function ensureFish(fish) {
  return {
    ...fish,
    swim: fish.swim || createSwim(),
    evolutionHistory: fish.evolutionHistory || [],
  };
}

function createFish(options = {}) {
  const species = options.species || pickWeightedSpecies();
  const genes = pickGenes(species);
  const trait = randomFrom(traitCatalog);
  const secondaryTrait = randomFrom(traitCatalog.filter((item) => item.id !== trait.id));
  const appearance = createAppearance(species, genes);
  const rarity = options.rarity || rollRarity(species.baseRarity, genes);

  return {
    id: createId(),
    speciesId: species.id,
    speciesName: species.name,
    family: species.family,
    name: `${randomFrom(nameBitsA)}${randomFrom(nameBitsB)}`,
    rarity,
    level: randomInt(1, 4),
    exp: randomInt(0, 65),
    age: randomInt(1, 12),
    mood: randomInt(58, 94),
    hunger: randomInt(18, 46),
    intimacy: randomInt(8, 38),
    genes,
    traits: [trait, secondaryTrait],
    appearance,
    output: species.output + randomInt(-2, 4),
    evolutionStage: 0,
    evolutionHistory: [],
    createdAt: Date.now(),
    swim: createSwim(),
  };
}

function pickWeightedSpecies() {
  const pool = speciesCatalog.flatMap((species) => {
    const count = species.baseRarity === "common" ? 5 : species.baseRarity === "rare" ? 3 : 1;
    return Array.from({ length: count }, () => species);
  });
  return randomFrom(pool);
}

function pickGenes(species) {
  const visible = shuffle(species.genes).slice(0, 2);
  const hiddenPool = Object.keys(geneCatalog).filter((gene) => !visible.includes(gene));
  return {
    visible,
    hidden: Math.random() < 0.72 ? randomFrom(species.genes) : randomFrom(hiddenPool),
  };
}

function rollRarity(baseRarity, genes) {
  let index = rarityOrder.indexOf(baseRarity);
  if (genes.hidden === "dragon" && Math.random() < 0.24) index += 1;
  if (genes.visible.includes("deepsea") && Math.random() < 0.18) index += 1;
  if (Math.random() < 0.04) index += 1;
  return rarityOrder[Math.min(index, rarityOrder.length - 1)];
}

function createAppearance(species, genes) {
  const bodyColor = randomFrom(species.palette);
  const accentPool = [
    "#ffffff",
    "#f2b84b",
    "#f26d5b",
    "#7fd8b7",
    "#6f5ea8",
    "#172326",
  ].filter((color) => color !== bodyColor);
  const patternByGene = {
    moon: "stars",
    coral: "petals",
    deepsea: "lantern",
    transparent: "glass",
    thorn: "spikes",
    dragon: "scales",
    spark: "dots",
    pearl: "pearls",
    storm: "stripes",
    sun: "sunburst",
  };

  return {
    bodyColor,
    accentColor: randomFrom(accentPool),
    finColor: randomFrom(species.palette),
    pattern: patternByGene[randomFrom([...genes.visible, genes.hidden])] || "dots",
    tail: randomFrom(["fork", "round", "veil"]),
    size: randomFloat(0.82, 1.22),
    body: randomFrom(["oval", "round", "slender"]),
    glow: genes.visible.includes("spark") || genes.hidden === "moon",
    eyeStyle: randomFrom(["bright", "sleepy", "wide"]),
    cheek: randomFrom(["soft", "dot", "stripe"]),
  };
}

function createSwim() {
  const direction = Math.random() > 0.5 ? 1 : -1;
  return {
    x: randomFloat(120, 820),
    y: randomFloat(120, 440),
    vx: randomFloat(24, 52) * direction,
    wave: randomFloat(0, Math.PI * 2),
    wiggle: randomFloat(0.86, 1.24),
    depth: randomFloat(0.72, 1.16),
  };
}

function createBubble() {
  return {
    x: randomFloat(20, 940),
    y: randomFloat(0, 560),
    r: randomFloat(2, 8),
    speed: randomFloat(12, 42),
    wobble: randomFloat(0, Math.PI * 2),
  };
}

function collectIdleReward() {
  const now = Date.now();
  const minutes = Math.min(480, Math.max(1, Math.floor((now - state.lastCollectAt) / 60000)));
  const rate = getIdleRate();
  const coins = Math.round(rate * minutes);
  const shells = Math.max(1, Math.floor(coins / 120));
  state.resources.bubbleCoins += coins;
  state.resources.shells += shells;
  if (minutes >= 30) state.resources.pearls += 1;
  state.lastCollectAt = now;
  recordStat("collectCount", 1);
  addLog(`收取了 ${minutes} 分钟放置产出：${coins} 泡泡币和 ${shells} 贝壳。`);
  saveAndRender();
}

function hatchFish(options = {}) {
  if (state.resources.eggs <= 0) {
    addLog("鱼蛋不足。可以去孵化页购买鱼蛋，或完成任务获得奖励。");
    renderLog();
    return;
  }

  state.resources.eggs -= 1;
  const fish = createFish(options);
  fish.level = 1;
  fish.exp = 0;
  fish.age = 0;
  state.fish.push(fish);
  selectedFishId = fish.id;
  recordStat("hatchCount", 1);
  addLog(`一枚鱼蛋孵化了：${fish.name} 是 ${rarityLabel[fish.rarity]}的${fish.speciesName}，带有 ${geneCatalog[fish.genes.visible[0]].label}。`);
  saveAndRender();
}

function tryEvolution() {
  const fish = getSelectedFish();
  if (!fish) return;

  const food = foodCatalog[els.foodSelect.value];
  const result = calculateEvolution(fish, activePondId, els.foodSelect.value);
  recordStat("evolveAttempts", 1);
  fish.exp += food.exp;
  fish.mood = clamp(fish.mood + food.mood, 0, 100);
  fish.hunger = clamp(fish.hunger - 18, 0, 100);
  fish.intimacy = clamp(fish.intimacy + 5, 0, 100);
  maybeLevelUp(fish);

  const roll = Math.random();
  if (roll <= result.chance) {
    applyEvolution(fish, result.rule);
  } else {
    const nearMiss = roll - result.chance < 0.08 ? "它离变化只差一点点。" : "这次没有进化，但状态更稳定了。";
    addLog(`${fish.name} 吃下${food.name}后绕着${pondCatalog[activePondId].name}游了一圈。${nearMiss}`);
  }

  saveAndRender();
}

function calculateEvolution(fish, pondId, foodId) {
  const pond = pondCatalog[pondId];
  const food = foodCatalog[foodId];
  const traits = fish.traits.reduce((sum, trait) => sum + trait.chance, 0);
  const baseChance = 0.05 + fish.level * 0.012 + fish.intimacy * 0.0012 + traits;
  const fishGenes = [...fish.genes.visible, fish.genes.hidden];

  const scored = evolutionRules.map((rule) => {
    let score = baseChance;
    const conditions = [
      { label: `基础成长：等级 ${fish.level}，亲密度 ${fish.intimacy}`, value: baseChance },
    ];

    if (rule.pond === pondId) {
      score += pond.chanceBonus;
      conditions.push({ label: `${pond.name}适配 ${rule.title}`, value: pond.chanceBonus });
    } else if (pond.geneBias.some((gene) => rule.genes.includes(gene))) {
      score += 0.018;
      conditions.push({ label: `${pond.name}仍有相关生态倾向`, value: 0.018 });
    }

    const matchedGenes = rule.genes.filter((gene) => fishGenes.includes(gene));
    if (matchedGenes.length) {
      const visibleHits = matchedGenes.filter((gene) => fish.genes.visible.includes(gene)).length;
      const hiddenHits = matchedGenes.includes(fish.genes.hidden) ? 1 : 0;
      const geneBonus = visibleHits * 0.055 + hiddenHits * 0.075;
      score += geneBonus;
      conditions.push({
        label: `基因共鸣：${matchedGenes.map((gene) => geneCatalog[gene].label).join("、")}`,
        value: geneBonus,
      });
    }

    const foodHits = food.tags.filter((tag) => rule.foodTags.includes(tag));
    if (foodHits.length) {
      const foodBonus = food.chanceBonus + foodHits.length * 0.025;
      score += foodBonus;
      conditions.push({ label: `${food.name}匹配进化方向`, value: foodBonus });
    }

    if (fish.mood >= 80) {
      score += 0.025;
      conditions.push({ label: "心情高，愿意尝试新形态", value: 0.025 });
    }

    if (fish.evolutionStage === 0) {
      score += 0.025;
      conditions.push({ label: "第一次进化更容易被触发", value: 0.025 });
    } else {
      score -= fish.evolutionStage * 0.025;
      conditions.push({ label: "已有进化历史，变化更挑剔", value: -fish.evolutionStage * 0.025 });
    }

    if (fish.rarity === "epic" || fish.rarity === "legendary") {
      score += 0.02;
      conditions.push({ label: "高稀有度个体有额外潜能", value: 0.02 });
    }

    return {
      rule,
      chance: clamp(score, 0.03, 0.72),
      conditions,
    };
  });

  scored.sort((a, b) => b.chance - a.chance);
  return scored[0];
}

function applyEvolution(fish, rule) {
  const oldName = fish.speciesName;
  const oldRarity = fish.rarity;
  const nextRarityIndex = Math.min(rarityOrder.indexOf(fish.rarity) + rule.rarityBump, rarityOrder.length - 1);

  fish.speciesName = `${rule.targetName}${oldName}`;
  fish.rarity = rarityOrder[nextRarityIndex];
  fish.evolutionStage += 1;
  fish.level += 1;
  fish.output += 5 + rule.rarityBump * 4;
  fish.mood = clamp(fish.mood + 12, 0, 100);
  fish.intimacy = clamp(fish.intimacy + 10, 0, 100);
  fish.appearance.bodyColor = rule.colors[0];
  fish.appearance.accentColor = rule.colors[1];
  fish.appearance.pattern = rule.pattern;
  fish.appearance.glow = fish.appearance.glow || rule.glow;
  fish.appearance.size = clamp(fish.appearance.size + 0.08, 0.78, 1.38);

  const story = rule.story.replace("{name}", fish.name);
  fish.evolutionHistory.unshift({
    ruleId: rule.id,
    title: rule.title,
    from: oldName,
    to: fish.speciesName,
    rarityFrom: oldRarity,
    rarityTo: fish.rarity,
    story,
    time: Date.now(),
  });

  recordStat("evolutionCount", 1);
  addLog(`${story} ${oldName}进化为${fish.speciesName}。`);
}

function maybeLevelUp(fish) {
  const needed = 80 + fish.level * 30;
  if (fish.exp >= needed) {
    fish.exp -= needed;
    fish.level += 1;
    fish.output += 2;
    addLog(`${fish.name} 升到了 ${fish.level} 级，放置产出提升了。`);
  }
}

function getIdleRate() {
  const pond = pondCatalog[activePondId];
  const total = state.fish.reduce((sum, fish) => {
    const moodMultiplier = 0.78 + fish.mood / 220;
    const rarityMultiplier = 1 + rarityOrder.indexOf(fish.rarity) * 0.18;
    return sum + Math.max(1, fish.output) * moodMultiplier * rarityMultiplier;
  }, 0);
  return Math.round(total * pond.outputMultiplier);
}

function getSelectedFish() {
  return state.fish.find((fish) => fish.id === selectedFishId) || state.fish[0];
}

function render() {
  const selected = getSelectedFish();
  selectedFishId = selected?.id;
  document.querySelectorAll(".mode-button").forEach((button) => {
    button.classList.toggle("active", button.dataset.pond === activePondId);
  });
  renderResources();
  renderDetail();
  renderEvolutionLab();
  renderHatchery();
  renderCollection();
  renderExplore();
  renderQuests();
  renderLog();
}

function saveAndRender() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  render();
}

function renderResources() {
  els.bubbleCoins.textContent = formatNumber(state.resources.bubbleCoins);
  els.shells.textContent = formatNumber(state.resources.shells);
  els.eggs.textContent = formatNumber(state.resources.eggs);
  els.pearls.textContent = formatNumber(state.resources.pearls);
  els.pondName.textContent = pondCatalog[activePondId].name;
  els.idleRate.textContent = `${formatNumber(getIdleRate())} / 分钟`;
}

function renderDetail() {
  const fish = getSelectedFish();
  if (!fish) {
    els.fishDetail.innerHTML = "<p>还没有鱼。</p>";
    return;
  }

  const latestEvolution = fish.evolutionHistory[0];
  els.fishDetail.innerHTML = `
    <div class="portrait">
      <canvas class="mini-canvas" width="196" height="156" data-mini="${fish.id}"></canvas>
      <div>
        <div class="fish-name-row">
          <h3 class="fish-name">${escapeHtml(fish.name)}</h3>
          <span class="rarity-pill rarity-${fish.rarity}">${rarityLabel[fish.rarity]}</span>
        </div>
        <p class="detail-copy">${escapeHtml(fish.speciesName)} · ${escapeHtml(fish.family)} · ${fish.appearance.patternName || patternLabel(fish.appearance.pattern)}</p>
        <p class="detail-copy">隐性基因不会直接展示在正式版里；原型先显示，方便观察进化判定。</p>
      </div>
    </div>
    <div class="stat-grid">
      <div><span>等级</span><strong>${fish.level}</strong></div>
      <div><span>心情</span><strong>${fish.mood}</strong></div>
      <div><span>亲密</span><strong>${fish.intimacy}</strong></div>
      <div><span>饥饿</span><strong>${fish.hunger}</strong></div>
      <div><span>产出</span><strong>${fish.output}/分</strong></div>
      <div><span>进化</span><strong>${fish.evolutionStage} 次</strong></div>
    </div>
    <div>
      <h3>基因与性格</h3>
      <div class="tag-cloud">
        ${fish.genes.visible.map((gene) => `<span>${geneCatalog[gene].label}</span>`).join("")}
        <span>隐性：${geneCatalog[fish.genes.hidden].label}</span>
        ${fish.traits.map((trait) => `<span>${trait.label}</span>`).join("")}
      </div>
    </div>
    <div>
      <h3>个体故事</h3>
      <p class="detail-copy">${latestEvolution ? escapeHtml(latestEvolution.story) : `${escapeHtml(fish.name)} 还没有进化记录。它的外观、性格和隐藏基因已经决定了未来会偏向哪些意外。`}</p>
    </div>
  `;

  const canvas = els.fishDetail.querySelector(`[data-mini="${fish.id}"]`);
  const miniCtx = canvas.getContext("2d");
  miniCtx.clearRect(0, 0, canvas.width, canvas.height);
  drawFish(miniCtx, fish, 98, 80, 1.4, 1, true);
}

function renderEvolutionLab() {
  const fish = getSelectedFish();
  if (!fish) return;

  const result = calculateEvolution(fish, activePondId, els.foodSelect.value);
  const percent = Math.round(result.chance * 100);
  els.evolutionChance.textContent = `${percent}%`;
  els.chanceFill.style.width = `${percent}%`;
  els.conditionList.innerHTML = result.conditions
    .map((condition) => {
      const sign = condition.value >= 0 ? "+" : "";
      return `<li><strong>${escapeHtml(condition.label)}</strong><br>${sign}${Math.round(condition.value * 100)}% 权重</li>`;
    })
    .join("");
}

function renderHatchery() {
  const slotCount = 3;
  els.hatchSlots.innerHTML = Array.from({ length: slotCount }, (_, index) => {
    const isOpen = index === 0 || state.resources.shells >= index * 8;
    const label = isOpen ? "可用孵化舱" : "待解锁孵化舱";
    const hint = isOpen ? "消耗 1 枚鱼蛋，立即获得一条独一无二的新鱼。" : `需要 ${index * 8} 贝壳解锁更多孵化空间。`;
    return `
      <div class="hatch-slot">
        <div class="hatch-egg" aria-hidden="true"></div>
        <span>${label} ${index + 1}</span>
        <h3>${isOpen ? "准备孵化" : "贝壳扩建"}</h3>
        <p>${hint}</p>
        <button class="${isOpen ? "primary-button" : "tool-button"} full" data-hatch-slot="${index}" ${isOpen ? "" : "disabled"}>${isOpen ? "孵化鱼蛋" : "未解锁"}</button>
      </div>
    `;
  }).join("");

  els.hatchSlots.querySelectorAll("[data-hatch-slot]").forEach((button) => {
    button.addEventListener("click", () => hatchFish());
  });

  els.eggShop.innerHTML = shopItems.map((item) => `
    <div class="shop-item">
      <span>${formatCost(item.cost)}</span>
      <h3>${item.name}</h3>
      <p>${item.desc}</p>
      <button class="tool-button" data-shop-id="${item.id}">购买</button>
    </div>
  `).join("");

  els.eggShop.querySelectorAll("[data-shop-id]").forEach((button) => {
    button.addEventListener("click", () => buyShopItem(button.dataset.shopId));
  });
}

function renderCollection() {
  renderCollectionSummary();
  renderRoster();
  renderSpeciesDex();
}

function renderCollectionSummary() {
  const discoveredSpecies = new Set(state.fish.map((fish) => fish.speciesId));
  const evolved = state.fish.filter((fish) => fish.evolutionStage > 0).length;
  const highestRarity = state.fish.reduce((best, fish) => {
    return rarityOrder.indexOf(fish.rarity) > rarityOrder.indexOf(best) ? fish.rarity : best;
  }, "common");

  els.collectionSummary.innerHTML = [
    ["鱼群数量", `${state.fish.length}`],
    ["发现物种", `${discoveredSpecies.size}/${speciesCatalog.length}`],
    ["进化个体", `${evolved}`],
    ["最高稀有", rarityLabel[highestRarity]],
  ].map(([label, value]) => `
    <div class="summary-tile">
      <span>${label}</span>
      <strong>${value}</strong>
    </div>
  `).join("");
}

function renderRoster() {
  const fishList = [...state.fish];
  if (sortByRarity) {
    fishList.sort((a, b) => rarityOrder.indexOf(b.rarity) - rarityOrder.indexOf(a.rarity) || b.level - a.level);
  } else {
    fishList.sort((a, b) => a.createdAt - b.createdAt);
  }

  els.fishRoster.innerHTML = fishList
    .map(
      (fish) => `
        <button class="fish-card ${fish.id === selectedFishId ? "active" : ""}" data-fish-id="${fish.id}">
          <canvas width="140" height="116" data-card="${fish.id}"></canvas>
          <span>
            <h3>${escapeHtml(fish.name)}</h3>
            <p>${rarityLabel[fish.rarity]} · Lv.${fish.level} · ${escapeHtml(fish.speciesName)}</p>
            <p>${fish.genes.visible.map((gene) => geneCatalog[gene].label.replace("基因", "")).join(" / ")}</p>
          </span>
        </button>
      `,
    )
    .join("");

  els.fishRoster.querySelectorAll(".fish-card").forEach((button) => {
    button.addEventListener("click", () => {
      selectedFishId = button.dataset.fishId;
      render();
    });
  });

  fishList.forEach((fish) => {
    const canvas = els.fishRoster.querySelector(`[data-card="${fish.id}"]`);
    if (!canvas) return;
    const cardCtx = canvas.getContext("2d");
    cardCtx.clearRect(0, 0, canvas.width, canvas.height);
    drawFish(cardCtx, fish, 70, 58, 0.88, 1, fish.id === selectedFishId);
  });
}

function renderSpeciesDex() {
  const discoveredSpecies = new Set(state.fish.map((fish) => fish.speciesId));
  const evolutionTitles = new Set(state.fish.flatMap((fish) => fish.evolutionHistory.map((item) => item.title)));
  els.speciesDex.innerHTML = speciesCatalog.map((species) => {
    const discovered = discoveredSpecies.has(species.id);
    const matchingRoutes = evolutionRules.filter((rule) => rule.genes.some((gene) => species.genes.includes(gene)));
    const routeText = matchingRoutes.map((rule) => evolutionTitles.has(rule.title) ? rule.title : "???").slice(0, 3).join(" / ");
    return `
      <div class="species-item">
        <div>
          <span>${species.family}</span>
          <h3>${discovered ? species.name : "未知鱼种"}</h3>
          <p>${discovered ? `潜在路线：${routeText || "等待发现"}` : "继续孵化和探索，有机会遇见它。"}</p>
        </div>
        <strong class="dex-badge">${discovered ? "已发现" : "未发现"}</strong>
      </div>
    `;
  }).join("");
}

function renderExplore() {
  const fish = getSelectedFish();
  const traitIds = fish ? fish.traits.map((trait) => trait.id) : [];
  els.exploreList.innerHTML = exploreRoutes.map((route) => {
    const bonus = route.traitBonus.some((trait) => traitIds.includes(trait));
    return `
      <div class="explore-card">
        <span>${route.time}${bonus ? " · 性格适配" : ""}</span>
        <h3>${route.name}</h3>
        <p>${route.desc}</p>
        <div class="explore-rewards">
          ${Object.entries(route.rewards).map(([key, value]) => `<span>${resourceLabel(key)} +${value}</span>`).join("")}
        </div>
        <button class="primary-button" data-explore-id="${route.id}">出发</button>
      </div>
    `;
  }).join("");

  els.exploreList.querySelectorAll("[data-explore-id]").forEach((button) => {
    button.addEventListener("click", () => runExplore(button.dataset.exploreId));
  });

  if (!fish) {
    els.exploreDetail.innerHTML = "<p>暂无可探索的鱼。</p>";
    return;
  }

  const bestRoutes = exploreRoutes
    .filter((route) => route.traitBonus.some((trait) => traitIds.includes(trait)))
    .map((route) => route.name);
  els.exploreDetail.innerHTML = `
    <h3>${escapeHtml(fish.name)}</h3>
    <p>${escapeHtml(fish.speciesName)} · ${rarityLabel[fish.rarity]} · Lv.${fish.level}</p>
    <div class="tag-cloud">
      ${fish.traits.map((trait) => `<span>${trait.label}</span>`).join("")}
      ${fish.genes.visible.map((gene) => `<span>${geneCatalog[gene].label}</span>`).join("")}
    </div>
    <p style="margin-top: 12px;">推荐路线：${bestRoutes.length ? bestRoutes.join("、") : "任意短途路线"}</p>
  `;
}

function renderQuests() {
  els.questList.innerHTML = questCatalog.map((quest) => {
    const progress = Math.min(state.stats[quest.stat] || 0, quest.target);
    const completed = progress >= quest.target;
    const claimed = state.claimedQuests.includes(quest.id);
    return `
      <div class="quest-card ${completed ? "completed" : ""} ${claimed ? "claimed" : ""}">
        <div>
          <span>奖励：${formatCost(quest.reward)}</span>
          <h3>${quest.title}</h3>
          <div class="quest-progress"><span>${progress}/${quest.target}</span></div>
        </div>
        <strong class="quest-badge">${claimed ? "已领取" : completed ? "可领取" : "进行中"}</strong>
      </div>
    `;
  }).join("");
}

function renderLog() {
  if (!state.eventLog.length) {
    addLog("原型已启动：先观察鱼塘、点选鱼，再尝试投喂和进化。");
  }

  els.eventLog.innerHTML = state.eventLog
    .slice(0, 24)
    .map((entry) => {
      const time = new Date(entry.time).toLocaleTimeString("zh-CN", {
        hour: "2-digit",
        minute: "2-digit",
      });
      return `<li><time>${time}</time>${escapeHtml(entry.text)}</li>`;
    })
    .join("");
}

function addLog(text) {
  state.eventLog.unshift({ text, time: Date.now() });
  state.eventLog = state.eventLog.slice(0, 50);
}

function showScreen(screenId) {
  document.querySelectorAll(".nav-button").forEach((button) => {
    button.classList.toggle("active", button.dataset.screenTarget === screenId);
  });
  document.querySelectorAll(".app-screen").forEach((screen) => {
    screen.classList.toggle("active", screen.dataset.screen === screenId);
  });
  if (screenId === "pond") resizeCanvas();
}

function buyShopItem(itemId) {
  const item = shopItems.find((entry) => entry.id === itemId);
  if (!item) return;

  if (!canAfford(item.cost)) {
    addLog(`${item.name} 需要 ${formatCost(item.cost)}，当前资源不足。`);
    saveAndRender();
    return;
  }

  payCost(item.cost);
  state.resources.eggs += item.eggs;
  addLog(`购买了 ${item.name}，鱼蛋 +${item.eggs}。`);
  saveAndRender();
}

function runExplore(routeId) {
  const route = exploreRoutes.find((entry) => entry.id === routeId);
  const fish = getSelectedFish();
  if (!route || !fish) return;

  const traitIds = fish.traits.map((trait) => trait.id);
  const bonus = route.traitBonus.some((trait) => traitIds.includes(trait));
  const rewards = { ...route.rewards };
  if (bonus) {
    rewards.bubbleCoins = (rewards.bubbleCoins || 0) + 80;
    fish.intimacy = clamp(fish.intimacy + 5, 0, 100);
  }
  fish.mood = clamp(fish.mood + (bonus ? 8 : 3), 0, 100);
  fish.hunger = clamp(fish.hunger + 10, 0, 100);
  addRewards(rewards);
  recordStat("exploreCount", 1);
  addLog(`${fish.name} 完成了 ${route.name} 探索，带回 ${formatCost(rewards)}。${bonus ? "它的性格非常适合这条路线。" : ""}`);
  saveAndRender();
}

function claimAllRewards() {
  let claimed = 0;
  questCatalog.forEach((quest) => {
    const completed = (state.stats[quest.stat] || 0) >= quest.target;
    if (!completed || state.claimedQuests.includes(quest.id)) return;
    addRewards(quest.reward);
    state.claimedQuests.push(quest.id);
    claimed += 1;
  });

  addLog(claimed ? `领取了 ${claimed} 个任务奖励。` : "暂时没有可领取的任务奖励。");
  saveAndRender();
}

function openShareCard() {
  const fish = getSelectedFish();
  if (!fish) return;

  recordStat("shareCount", 1);
  els.shareModal.hidden = false;
  els.shareCard.innerHTML = `
    <canvas width="720" height="380" data-share-fish="${fish.id}"></canvas>
    <p class="eyebrow">Pokefish 鱼卡</p>
    <h3>${escapeHtml(fish.name)}</h3>
    <p class="detail-copy">${rarityLabel[fish.rarity]} · ${escapeHtml(fish.speciesName)} · Lv.${fish.level}</p>
    <div class="tag-cloud">
      ${fish.genes.visible.map((gene) => `<span>${geneCatalog[gene].label}</span>`).join("")}
      ${fish.traits.map((trait) => `<span>${trait.label}</span>`).join("")}
    </div>
  `;

  const canvas = els.shareCard.querySelector("canvas");
  const cardCtx = canvas.getContext("2d");
  const gradient = cardCtx.createLinearGradient(0, 0, canvas.width, canvas.height);
  gradient.addColorStop(0, "#bcefe1");
  gradient.addColorStop(0.62, "#f8dca0");
  gradient.addColorStop(1, "#f7fbf8");
  cardCtx.fillStyle = gradient;
  cardCtx.fillRect(0, 0, canvas.width, canvas.height);
  drawPondFloor(canvas.width, canvas.height, "#143137", cardCtx);
  drawFish(cardCtx, fish, canvas.width / 2, canvas.height / 2 - 20, 2.8, 1, true, performance.now() / 1000);
  addLog(`生成了 ${fish.name} 的鱼卡。`);
  saveAndRender();
}

function closeShareCard() {
  els.shareModal.hidden = true;
}

function recordStat(key, amount) {
  state.stats[key] = (state.stats[key] || 0) + amount;
}

function canAfford(cost) {
  return Object.entries(cost).every(([key, value]) => state.resources[key] >= value);
}

function payCost(cost) {
  Object.entries(cost).forEach(([key, value]) => {
    state.resources[key] -= value;
  });
}

function addRewards(rewards) {
  Object.entries(rewards).forEach(([key, value]) => {
    state.resources[key] = (state.resources[key] || 0) + value;
  });
}

function formatCost(cost) {
  return Object.entries(cost).map(([key, value]) => `${resourceLabel(key)} ${value}`).join(" · ");
}

function resourceLabel(key) {
  return {
    bubbleCoins: "泡泡币",
    shells: "贝壳",
    eggs: "鱼蛋",
    pearls: "珍珠",
  }[key] || key;
}

function animate(now) {
  if (now - lastFrame < 1000 / 30) {
    requestAnimationFrame(animate);
    return;
  }
  const delta = Math.min(0.05, (now - lastFrame) / 1000);
  lastFrame = now;
  updateSwim(delta, now / 1000);
  drawPond(now / 1000);
  requestAnimationFrame(animate);
}

function updateSwim(delta, time) {
  const width = els.pondCanvas.width;
  const height = els.pondCanvas.height;

  state.fish.forEach((fish, index) => {
    fish.swim.wave += delta * (4.6 + index * 0.11) * (fish.swim.wiggle || 1);
    fish.swim.x += fish.swim.vx * delta;
    fish.swim.y += Math.sin(fish.swim.wave * 0.64 + time * 1.2) * delta * 24;

    const margin = 86 * fish.appearance.size;
    if (fish.swim.x > width - margin) {
      fish.swim.x = width - margin;
      fish.swim.vx *= -1;
    }
    if (fish.swim.x < margin) {
      fish.swim.x = margin;
      fish.swim.vx *= -1;
    }
    fish.swim.y = clamp(fish.swim.y, 92, height - 74);
  });

  bubbles.forEach((bubble) => {
    bubble.y -= bubble.speed * delta;
    bubble.x += Math.sin(time * 1.4 + bubble.wobble) * delta * 10;
    if (bubble.y < -20) {
      bubble.y = height + randomFloat(8, 80);
      bubble.x = randomFloat(20, width - 20);
      bubble.r = randomFloat(2, 8);
    }
  });
}

function drawPond(time) {
  const { width, height } = els.pondCanvas;
  const pond = pondCatalog[activePondId];

  drawCartoonWater(width, height, pond, time);
  drawWaterLight(width, height, time);
  drawBubbles();

  const sortedFish = [...state.fish].sort((a, b) => a.swim.depth - b.swim.depth);
  sortedFish.forEach((fish) => {
    const direction = fish.swim.vx >= 0 ? 1 : -1;
    drawFish(ctx, fish, fish.swim.x, fish.swim.y, fish.appearance.size * fish.swim.depth, direction, fish.id === selectedFishId, time);
  });

  drawPlants(width, height, time);
}

function drawCartoonWater(width, height, pond, time) {
  const lineColor = "#143137";
  const top = lighten(pond.colorA, 0.18);
  const middle = "#72d4cf";
  const bottom = darken(pond.colorB, 0.08);

  ctx.save();
  ctx.fillStyle = top;
  ctx.fillRect(0, 0, width, height);

  ctx.fillStyle = middle;
  ctx.beginPath();
  ctx.moveTo(0, height * 0.28);
  for (let x = 0; x <= width + 40; x += 44) {
    const y = height * 0.28 + Math.sin(x * 0.018 + time * 0.55) * 11;
    ctx.lineTo(x, y);
  }
  ctx.lineTo(width, height);
  ctx.lineTo(0, height);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = bottom;
  ctx.beginPath();
  ctx.moveTo(0, height * 0.72);
  for (let x = 0; x <= width + 40; x += 42) {
    const y = height * 0.72 + Math.sin(x * 0.016 + time * 0.62 + 1.8) * 13;
    ctx.lineTo(x, y);
  }
  ctx.lineTo(width, height);
  ctx.lineTo(0, height);
  ctx.closePath();
  ctx.fill();

  ctx.globalAlpha = 0.08;
  ctx.fillStyle = "#ffffff";
  ctx.beginPath();
  ctx.ellipse(width * 0.22, height * 0.18, width * 0.28, height * 0.16, -0.1, 0, Math.PI * 2);
  ctx.ellipse(width * 0.78, height * 0.22, width * 0.24, height * 0.13, 0.18, 0, Math.PI * 2);
  ctx.fill();
  ctx.globalAlpha = 1;

  drawPondFloor(width, height, lineColor);
  ctx.restore();
}

function drawPondFloor(width, height, lineColor, targetCtx = ctx) {
  const floorTop = height - 54;
  targetCtx.save();
  targetCtx.fillStyle = "#f4d58a";
  targetCtx.strokeStyle = lineColor;
  targetCtx.lineWidth = 5;
  targetCtx.beginPath();
  targetCtx.moveTo(-12, floorTop + 18);
  for (let x = -12; x <= width + 24; x += 48) {
    const y = floorTop + Math.sin(x * 0.03) * 7;
    targetCtx.quadraticCurveTo(x + 22, y - 10, x + 48, y);
  }
  targetCtx.lineTo(width + 24, height + 20);
  targetCtx.lineTo(-12, height + 20);
  targetCtx.closePath();
  targetCtx.fill();
  targetCtx.stroke();

  const pebbles = [
    [0.07, 0.93, 24, 12, "#f7efe1"],
    [0.14, 0.91, 18, 10, "#9ad5c8"],
    [0.27, 0.94, 28, 13, "#f2b84b"],
    [0.39, 0.92, 20, 10, "#f7efe1"],
    [0.54, 0.94, 26, 12, "#f26d5b"],
    [0.66, 0.91, 19, 10, "#9ad5c8"],
    [0.8, 0.94, 30, 14, "#f7efe1"],
    [0.93, 0.92, 22, 11, "#f2b84b"],
  ];
  pebbles.forEach(([px, py, rx, ry, color]) => {
    targetCtx.fillStyle = color;
    targetCtx.strokeStyle = lineColor;
    targetCtx.lineWidth = 3;
    targetCtx.beginPath();
    targetCtx.ellipse(width * px, height * py, rx, ry, 0, 0, Math.PI * 2);
    targetCtx.fill();
    targetCtx.stroke();
  });
  targetCtx.restore();
}

function drawWaterLight(width, height, time) {
  ctx.save();
  ctx.globalAlpha = 0.48;
  ctx.strokeStyle = "rgba(255, 255, 255, 0.82)";
  ctx.lineWidth = 4;
  ctx.lineCap = "round";
  for (let i = 0; i < 6; i += 1) {
    ctx.beginPath();
    const y = 58 + i * 64;
    for (let x = -42; x <= width + 42; x += 36) {
      const waveY = y + Math.sin(x * 0.022 + time * 0.9 + i) * 8;
      if (x === -42) ctx.moveTo(x, waveY);
      else ctx.quadraticCurveTo(x - 18, waveY - 9, x, waveY);
    }
    ctx.stroke();
  }
  ctx.restore();
}

function drawPlants(width, height, time) {
  ctx.save();
  const lineColor = "#143137";
  const clusters = [
    { x: 0.08, color: "#21a585", height: 86, count: 4 },
    { x: 0.2, color: "#f2b84b", height: 118, count: 3 },
    { x: 0.36, color: "#1e8b7f", height: 96, count: 4 },
    { x: 0.5, color: "#f26d5b", height: 78, count: 3 },
    { x: 0.63, color: "#21a585", height: 112, count: 4 },
    { x: 0.76, color: "#f2b84b", height: 80, count: 3 },
    { x: 0.9, color: "#f26d5b", height: 110, count: 4 },
  ];

  drawCoralCluster(width * 0.3, height - 42, 0.86, "#ff8c78", lineColor, time);
  drawCoralCluster(width * 0.72, height - 42, 1, "#ffd06e", lineColor, time + 1.2);

  clusters.forEach((cluster, clusterIndex) => {
    for (let i = 0; i < cluster.count; i += 1) {
      const offset = (i - (cluster.count - 1) / 2) * 18;
      const x = width * cluster.x + offset;
      const heightScale = cluster.height * (0.76 + (i % 3) * 0.14);
      const sway = Math.sin(time * 1.1 + clusterIndex + i * 0.8) * 10;
      drawSeaweedBlade(ctx, x, height - 35, heightScale, sway, cluster.color, lineColor, i % 2 === 0 ? 1 : -1);
    }
  });
  ctx.restore();
}

function drawSeaweedBlade(targetCtx, x, baseY, length, sway, fillColor, lineColor, side) {
  const width = 15;
  targetCtx.save();
  targetCtx.fillStyle = fillColor;
  targetCtx.strokeStyle = lineColor;
  targetCtx.lineWidth = 4;
  targetCtx.beginPath();
  targetCtx.moveTo(x - width * 0.45, baseY + 7);
  targetCtx.bezierCurveTo(x - width + sway * 0.15, baseY - length * 0.35, x + sway - width * side, baseY - length * 0.72, x + sway * 0.55, baseY - length);
  targetCtx.bezierCurveTo(x + sway + width * side, baseY - length * 0.7, x + width + sway * 0.14, baseY - length * 0.32, x + width * 0.45, baseY + 7);
  targetCtx.closePath();
  targetCtx.fill();
  targetCtx.stroke();

  targetCtx.strokeStyle = withAlpha("#ffffff", 0.38);
  targetCtx.lineWidth = 2;
  targetCtx.beginPath();
  targetCtx.moveTo(x, baseY - 4);
  targetCtx.bezierCurveTo(x + sway * 0.1, baseY - length * 0.38, x + sway * 0.42, baseY - length * 0.68, x + sway * 0.45, baseY - length + 12);
  targetCtx.stroke();
  targetCtx.restore();
}

function drawCoralCluster(x, baseY, scale, fillColor, lineColor, time) {
  ctx.save();
  ctx.translate(x, baseY);
  ctx.scale(scale, scale);
  ctx.strokeStyle = lineColor;
  ctx.lineWidth = 9;
  ctx.lineCap = "round";
  ctx.lineJoin = "round";
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.quadraticCurveTo(-4 + Math.sin(time) * 2, -25, -20, -48);
  ctx.moveTo(0, 0);
  ctx.quadraticCurveTo(6 + Math.sin(time + 1) * 2, -32, 8, -66);
  ctx.moveTo(0, -28);
  ctx.quadraticCurveTo(22, -43, 30, -66);
  ctx.moveTo(2, -42);
  ctx.quadraticCurveTo(-18, -58, -28, -78);
  ctx.stroke();

  ctx.strokeStyle = fillColor;
  ctx.lineWidth = 5;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.quadraticCurveTo(-4 + Math.sin(time) * 2, -25, -20, -48);
  ctx.moveTo(0, 0);
  ctx.quadraticCurveTo(6 + Math.sin(time + 1) * 2, -32, 8, -66);
  ctx.moveTo(0, -28);
  ctx.quadraticCurveTo(22, -43, 30, -66);
  ctx.moveTo(2, -42);
  ctx.quadraticCurveTo(-18, -58, -28, -78);
  ctx.stroke();

  ctx.fillStyle = fillColor;
  ctx.strokeStyle = lineColor;
  ctx.lineWidth = 3;
  [[-20, -48], [8, -66], [30, -66], [-28, -78]].forEach(([cx, cy]) => {
    ctx.beginPath();
    ctx.arc(cx, cy, 7, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
  });
  ctx.restore();
}

function drawBubbles() {
  ctx.save();
  bubbles.forEach((bubble) => {
    ctx.globalAlpha = 0.7;
    ctx.fillStyle = "rgba(255, 255, 255, 0.22)";
    ctx.strokeStyle = "rgba(20, 49, 55, 0.28)";
    ctx.lineWidth = 2.2;
    ctx.beginPath();
    ctx.arc(bubble.x, bubble.y, bubble.r, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
  });
  ctx.restore();
}

function drawFish(targetCtx, fish, x, y, scale = 1, direction = 1, selected = false, time = 0) {
  const lineColor = "#143137";
  const phase = fish.swim ? fish.swim.wave + time * 0.8 : time;
  const swimBend = Math.sin(phase) * 10;
  const tailSwing = Math.sin(phase + 0.86) * 0.46;
  const finSwing = Math.sin(phase + 1.65) * 0.28;
  const bodyBob = Math.sin(phase * 1.8) * 1.8;

  targetCtx.save();
  targetCtx.translate(x, y + bodyBob);
  targetCtx.scale(direction * scale, scale);
  targetCtx.lineJoin = "round";
  targetCtx.lineCap = "round";

  if (selected) {
    targetCtx.save();
    targetCtx.scale(direction, 1);
    targetCtx.globalAlpha = 0.18;
    targetCtx.fillStyle = "#f2b84b";
    targetCtx.beginPath();
    targetCtx.ellipse(0, 6, 70, 44, 0, 0, Math.PI * 2);
    targetCtx.fill();
    targetCtx.restore();
  }

  if (fish.appearance.glow) {
    targetCtx.save();
    targetCtx.scale(direction, 1);
    targetCtx.globalAlpha = 0.18;
    targetCtx.fillStyle = fish.appearance.accentColor;
    targetCtx.beginPath();
    targetCtx.ellipse(0, 0, 82, 50, 0, 0, Math.PI * 2);
    targetCtx.fill();
    targetCtx.restore();
  }

  drawTail(targetCtx, fish, tailSwing, swimBend, lineColor);
  drawFins(targetCtx, fish, finSwing, swimBend, lineColor);
  drawBody(targetCtx, fish, swimBend, lineColor);
  drawPattern(targetCtx, fish, swimBend, lineColor);
  drawFace(targetCtx, fish, swimBend, lineColor);

  targetCtx.restore();
}

function drawTail(targetCtx, fish, tailSwing, swimBend, lineColor) {
  const { accentColor, finColor, tail } = fish.appearance;
  targetCtx.save();
  targetCtx.translate(-31, swimBend * 0.52);
  targetCtx.rotate(tailSwing);
  targetCtx.fillStyle = lighten(finColor, 0.12);
  targetCtx.strokeStyle = lineColor;
  targetCtx.lineWidth = 4.5;

  if (tail === "veil") {
    targetCtx.beginPath();
    targetCtx.moveTo(0, 0);
    targetCtx.bezierCurveTo(-28, -38, -62, -30, -50, 0);
    targetCtx.bezierCurveTo(-66, 34, -26, 39, 0, 7);
    targetCtx.closePath();
  } else if (tail === "round") {
    targetCtx.beginPath();
    targetCtx.ellipse(-25, 0, 27, 31, 0, 0, Math.PI * 2);
  } else {
    targetCtx.beginPath();
    targetCtx.moveTo(0, 0);
    targetCtx.quadraticCurveTo(-24, -34, -54, -30);
    targetCtx.quadraticCurveTo(-42, -8, -24, 0);
    targetCtx.quadraticCurveTo(-42, 8, -54, 30);
    targetCtx.quadraticCurveTo(-24, 34, 0, 5);
    targetCtx.closePath();
  }
  targetCtx.fill();
  targetCtx.stroke();

  targetCtx.strokeStyle = withAlpha(accentColor, 0.7);
  targetCtx.lineWidth = 2.2;
  targetCtx.beginPath();
  targetCtx.moveTo(-8, -18);
  targetCtx.quadraticCurveTo(-27, -8, -44, -20);
  targetCtx.moveTo(-8, 18);
  targetCtx.quadraticCurveTo(-27, 8, -44, 20);
  targetCtx.stroke();
  targetCtx.restore();
}

function drawFins(targetCtx, fish, finSwing, swimBend, lineColor) {
  targetCtx.save();
  targetCtx.fillStyle = lighten(fish.appearance.finColor, 0.1);
  targetCtx.strokeStyle = lineColor;
  targetCtx.lineWidth = 4;
  targetCtx.beginPath();
  targetCtx.moveTo(-4, -19 + swimBend * 0.18);
  targetCtx.quadraticCurveTo(5 + finSwing * 12, -48, 27, -19);
  targetCtx.closePath();
  targetCtx.fill();
  targetCtx.stroke();

  targetCtx.beginPath();
  targetCtx.moveTo(-8, 20 + swimBend * 0.14);
  targetCtx.quadraticCurveTo(7 - finSwing * 10, 47, 28, 19);
  targetCtx.closePath();
  targetCtx.fill();
  targetCtx.stroke();
  targetCtx.restore();
}

function drawBody(targetCtx, fish, swimBend, lineColor) {
  const body = fish.appearance.body;
  const dimensions = {
    oval: [44, 28],
    round: [39, 34],
    slender: [49, 23],
  }[body];
  const bodyW = dimensions[0];
  const bodyH = dimensions[1];
  const headY = -swimBend * 0.18;
  const midY = swimBend * 0.18;
  const tailY = swimBend * 0.48;

  const gradient = targetCtx.createLinearGradient(-30, -24, 38, 26);
  gradient.addColorStop(0, lighten(fish.appearance.bodyColor, 0.38));
  gradient.addColorStop(0.56, fish.appearance.bodyColor);
  gradient.addColorStop(1, darken(fish.appearance.bodyColor, 0.14));

  targetCtx.save();
  targetCtx.fillStyle = fish.appearance.pattern === "glass" ? withAlpha(fish.appearance.bodyColor, 0.62) : gradient;
  targetCtx.strokeStyle = lineColor;
  targetCtx.lineWidth = 4.8;
  targetCtx.beginPath();
  targetCtx.moveTo(-bodyW + 8, tailY);
  targetCtx.bezierCurveTo(-bodyW + 10, -bodyH + tailY, -10, -bodyH - midY, 24, -bodyH * 0.82 + headY);
  targetCtx.bezierCurveTo(51, -bodyH * 0.55 + headY, 51, bodyH * 0.62 + headY, 22, bodyH * 0.88 + headY);
  targetCtx.bezierCurveTo(-10, bodyH + midY, -bodyW + 12, bodyH + tailY, -bodyW + 8, tailY);
  targetCtx.closePath();
  targetCtx.fill();
  targetCtx.stroke();

  targetCtx.globalAlpha = 0.35;
  targetCtx.fillStyle = "#ffffff";
  targetCtx.beginPath();
  targetCtx.ellipse(13, -bodyH * 0.42 + headY, bodyW * 0.4, bodyH * 0.24, -0.1, 0, Math.PI * 2);
  targetCtx.fill();
  targetCtx.restore();
}

function drawPattern(targetCtx, fish, swimBend, lineColor) {
  const pattern = fish.appearance.pattern;
  targetCtx.save();
  targetCtx.translate(0, swimBend * 0.12);
  targetCtx.strokeStyle = lineColor;
  targetCtx.fillStyle = fish.appearance.accentColor;
  targetCtx.lineWidth = 3;

  if (pattern === "stripes" || pattern === "sunburst") {
    targetCtx.strokeStyle = withAlpha(lineColor, 0.72);
    for (let i = -19; i <= 17; i += 12) {
      targetCtx.beginPath();
      targetCtx.moveTo(i, -20 + swimBend * 0.12);
      targetCtx.quadraticCurveTo(i + 8, 0, i, 20 + swimBend * 0.18);
      targetCtx.stroke();
    }
  }

  if (pattern === "dots" || pattern === "pearls") {
    for (let i = 0; i < 6; i += 1) {
      targetCtx.strokeStyle = withAlpha(lineColor, 0.75);
      targetCtx.beginPath();
      targetCtx.arc(-18 + i * 10, Math.sin(i) * 9 + swimBend * (0.12 + i * 0.01), pattern === "pearls" ? 4.3 : 3.5, 0, Math.PI * 2);
      targetCtx.fill();
      targetCtx.stroke();
    }
  }

  if (pattern === "stars") {
    for (let i = 0; i < 5; i += 1) {
      drawStar(targetCtx, -19 + i * 11, Math.cos(i) * 10 + swimBend * 0.12, 4.6);
    }
  }

  if (pattern === "petals") {
    for (let i = 0; i < 4; i += 1) {
      targetCtx.beginPath();
      targetCtx.ellipse(-16 + i * 12, Math.sin(i) * 7 + swimBend * 0.14, 4.8, 8.6, Math.PI / 4, 0, Math.PI * 2);
      targetCtx.fill();
      targetCtx.stroke();
    }
  }

  if (pattern === "spikes") {
    targetCtx.fillStyle = fish.appearance.accentColor;
    for (let i = -18; i <= 18; i += 12) {
      targetCtx.beginPath();
      targetCtx.moveTo(i, -23);
      targetCtx.lineTo(i + 5, -38);
      targetCtx.lineTo(i + 11, -22);
      targetCtx.closePath();
      targetCtx.fill();
      targetCtx.stroke();
    }
  }

  if (pattern === "scales") {
    targetCtx.strokeStyle = withAlpha(lineColor, 0.7);
    for (let row = -1; row <= 1; row += 1) {
      for (let col = -2; col <= 2; col += 1) {
        targetCtx.beginPath();
        targetCtx.arc(col * 11, row * 8, 5, Math.PI * 0.05, Math.PI * 0.95);
        targetCtx.stroke();
      }
    }
  }

  if (pattern === "lantern") {
    targetCtx.fillStyle = "#d8fff5";
    targetCtx.beginPath();
    targetCtx.arc(37, -15, 6, 0, Math.PI * 2);
    targetCtx.fill();
    targetCtx.strokeStyle = lineColor;
    targetCtx.stroke();
    targetCtx.strokeStyle = withAlpha(lineColor, 0.75);
    targetCtx.beginPath();
    targetCtx.moveTo(27, -17);
    targetCtx.quadraticCurveTo(33, -31, 42, -20);
    targetCtx.stroke();
  }

  if (pattern === "glass") {
    targetCtx.globalAlpha = 0.72;
    targetCtx.strokeStyle = "#ffffff";
    targetCtx.beginPath();
    targetCtx.moveTo(-21, -14);
    targetCtx.lineTo(27, 15);
    targetCtx.stroke();
  }

  targetCtx.restore();
}

function drawFace(targetCtx, fish, swimBend, lineColor) {
  const eyeY = fish.appearance.eyeStyle === "sleepy" ? -7 : -10;
  const headY = -swimBend * 0.18;
  const eyeSize = fish.appearance.eyeStyle === "wide" ? 9 : 8;

  targetCtx.save();
  targetCtx.translate(0, headY);
  targetCtx.strokeStyle = lineColor;
  targetCtx.lineWidth = 3.4;
  targetCtx.fillStyle = "#ffffff";
  targetCtx.beginPath();
  targetCtx.arc(29, eyeY, eyeSize, 0, Math.PI * 2);
  targetCtx.fill();
  targetCtx.stroke();

  targetCtx.fillStyle = "#172326";
  targetCtx.beginPath();
  targetCtx.arc(32, eyeY + 1, 3.4, 0, Math.PI * 2);
  targetCtx.fill();

  targetCtx.fillStyle = "#ffffff";
  targetCtx.beginPath();
  targetCtx.arc(33.5, eyeY - 1.2, 1.4, 0, Math.PI * 2);
  targetCtx.fill();

  targetCtx.strokeStyle = lineColor;
  targetCtx.lineWidth = 2.6;
  targetCtx.beginPath();
  if (fish.appearance.eyeStyle === "sleepy") {
    targetCtx.moveTo(21, eyeY - 9);
    targetCtx.quadraticCurveTo(29, eyeY - 13, 37, eyeY - 9);
  } else {
    targetCtx.moveTo(20, eyeY - 13);
    targetCtx.quadraticCurveTo(29, eyeY - 17, 38, eyeY - 12);
  }
  targetCtx.stroke();

  targetCtx.fillStyle = withAlpha("#ff8da1", fish.appearance.cheek === "soft" ? 0.58 : 0.42);
  targetCtx.beginPath();
  targetCtx.ellipse(24, 10, 8, 4.5, -0.1, 0, Math.PI * 2);
  targetCtx.fill();

  targetCtx.strokeStyle = lineColor;
  targetCtx.lineWidth = 2.4;
  targetCtx.beginPath();
  targetCtx.moveTo(43, 1);
  targetCtx.quadraticCurveTo(49, 4, 43, 7);
  targetCtx.stroke();
  targetCtx.restore();
}

function drawStar(targetCtx, x, y, r) {
  targetCtx.beginPath();
  for (let i = 0; i < 10; i += 1) {
    const angle = -Math.PI / 2 + (i * Math.PI) / 5;
    const radius = i % 2 === 0 ? r : r * 0.45;
    const px = x + Math.cos(angle) * radius;
    const py = y + Math.sin(angle) * radius;
    if (i === 0) targetCtx.moveTo(px, py);
    else targetCtx.lineTo(px, py);
  }
  targetCtx.closePath();
  targetCtx.fill();
}

function resizeCanvas() {
  const rect = els.pondCanvas.getBoundingClientRect();
  els.pondCanvas.width = Math.round(rect.width);
  els.pondCanvas.height = Math.round(rect.height);
  state.fish.forEach((fish) => {
    const margin = 92 * fish.appearance.size;
    fish.swim.x = clamp(fish.swim.x, margin, els.pondCanvas.width - margin);
    fish.swim.y = clamp(fish.swim.y, 92, els.pondCanvas.height - 74);
  });
}

function patternLabel(pattern) {
  return (
    {
      stars: "星点花纹",
      petals: "花瓣花纹",
      lantern: "灯影器官",
      glass: "玻璃鳞片",
      spikes: "棘刺轮廓",
      scales: "龙鳞纹",
      dots: "斑点花纹",
      pearls: "珍珠斑",
      stripes: "波纹条纹",
      sunburst: "日纹放射",
    }[pattern] || "未知花纹"
  );
}

function createId() {
  return `fish_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;
}

function randomFrom(items) {
  return items[Math.floor(Math.random() * items.length)];
}

function randomInt(min, max) {
  return Math.floor(randomFloat(min, max + 1));
}

function randomFloat(min, max) {
  return min + Math.random() * (max - min);
}

function shuffle(items) {
  return [...items].sort(() => Math.random() - 0.5);
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function formatNumber(value) {
  return new Intl.NumberFormat("zh-CN").format(Math.round(value));
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function withAlpha(hex, alpha) {
  const { r, g, b } = hexToRgb(hex);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function lighten(hex, amount) {
  const { r, g, b } = hexToRgb(hex);
  return rgbToHex(
    Math.round(r + (255 - r) * amount),
    Math.round(g + (255 - g) * amount),
    Math.round(b + (255 - b) * amount),
  );
}

function darken(hex, amount) {
  const { r, g, b } = hexToRgb(hex);
  return rgbToHex(Math.round(r * (1 - amount)), Math.round(g * (1 - amount)), Math.round(b * (1 - amount)));
}

function hexToRgb(hex) {
  const normalized = hex.replace("#", "");
  return {
    r: parseInt(normalized.slice(0, 2), 16),
    g: parseInt(normalized.slice(2, 4), 16),
    b: parseInt(normalized.slice(4, 6), 16),
  };
}

function rgbToHex(r, g, b) {
  return `#${[r, g, b].map((value) => value.toString(16).padStart(2, "0")).join("")}`;
}

if (!state.eventLog.length) {
  addLog("鱼塘初始化完成：5 条测试鱼已生成，每条鱼都有不同外观、性格和隐藏基因。");
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

window.addEventListener("resize", resizeCanvas);
resizeCanvas();
render();
requestAnimationFrame(animate);
