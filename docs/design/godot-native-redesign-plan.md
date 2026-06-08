# Pokefish Godot-Native 全面重构方案

版本：v1.0  
目标：放弃“网页式 UI 面板”思路，改成 Godot 原生的场景化手机游戏界面。  
结论：当前玩法数据可保留，UI Shell 和主界面需要重写。

## 为什么上一版仍然不满意

上一版已经减少了文字，也换了更游戏化的字体，但它仍然有一个根本问题：它还是“手机 App UI 稿”，不是“Godot 游戏界面”。

具体问题：

1. 画面仍然像三个静态 App 页面，而不是一个可交互的游戏场景。
2. 水域、鱼、按钮、资源条还是分离的 UI 元件，没有形成一个活的世界。
3. 设计过度依赖卡片、Tab、Sheet，这些是 App 逻辑，不是游戏逻辑。
4. 字体和颜色变了，但底层体验仍然是“看面板、点按钮、读状态”。
5. Godot 的强项没有发挥出来：场景树、CanvasLayer、动画、粒子、Shader、Tween、触摸手势、节点组合都没有成为设计核心。

所以这次不再继续修 SVG 稿，而是按 Godot 的能力重新定义产品形态。

## Godot 能力如何影响设计

### 1. 场景树

Godot 擅长把游戏拆成节点，而不是把所有 UI 写在一个脚本里。

新的界面应该由这些场景组成：

```text
Main.tscn
├── GameWorldLayer        # 水域、鱼、环境、可互动对象
├── HudLayer              # 顶部资源、状态、轻提示
├── DockLayer             # 底部主操作和模块入口
├── SheetLayer            # 伙伴详情、投喂、孵化、进化确认
├── FxLayer               # 资源飞行、闪光、孵化、进化特效
└── DebugLayer            # 开发期调试，发布时关闭
```

### 2. CanvasLayer

顶部 HUD、底部操作、弹层、特效应该分层，不应该塞进一个 ScrollContainer。

设计影响：

- 水域场景永远在最底层，像游戏世界。
- HUD 永远固定，不随页面滚动。
- 主操作 Dock 永远在拇指区。
- 弹层独立于场景，不挤压主画面。

### 3. Node2D / Control 混合

水域和鱼应该用 Node2D 或自绘 Control 表现；按钮、资源、弹层用 Control。

设计影响：

- 首页不是纯 UI，而是“场景 + HUD”。
- 鱼不是列表项，而是可点选、可高亮、可游动的游戏对象。
- UI 只覆盖必要信息，不统治画面。

### 4. Tween / AnimationPlayer

Godot 的动效应该成为反馈系统，而不是装饰。

设计影响：

- 收取资源：泡泡从水域飞入 HUD。
- 投喂：食物从 Dock 抛入水面，鱼靠近。
- 进化：水域变暗、鱼发光、镜头轻震、结果弹出。
- 切换模块：不换整页，打开不同的游戏面板。
- 孵化：蛋在槽位里震动、发光、裂开。

### 5. Particles / Shader

移动端要克制使用，但可以做出明显游戏感。

设计影响：

- 水面使用轻量 Shader 或自绘波浪。
- 泡泡、光点、进化闪光使用 CPUParticles2D 或少量 GPUParticles2D。
- 稀有鱼可以有微弱描边光，而不是文字强调。

### 6. Theme / Font / Resource

Godot 可以用 Theme 统一 UI，但不能让所有控件看起来像默认表单。

设计影响：

- 建立 `PokefishTheme.tres` 或主题脚本。
- 展示字体用于鱼名、按钮、标题。
- 信息字体用于小数字、小标签。
- 按钮应该是游戏按钮，不是默认 Control 按钮。

### 7. Signals

UI 和玩法逻辑应通过信号连接，不要让主脚本越来越大。

设计影响：

- `PondStage.fish_selected`
- `ActionDock.feed_pressed`
- `ActionDock.evolve_pressed`
- `Hud.resources_tapped`
- `BottomSheet.closed`
- `GameState.changed`

主界面只协调，不直接构建所有细节。

## 新产品形态

新的 Pokefish 应该像一个“口袋水族箱”，不是一个“养鱼管理后台”。

核心体验：

1. 打开 App，玩家先进入一个活的水域。
2. 鱼在画面中游动，资源泡泡从水里冒出。
3. 玩家点击鱼，鱼被选中并有明确反馈。
4. 玩家在底部用三颗大按钮完成主要动作。
5. 图鉴、孵化、远行、目标都以游戏面板进入，不抢走主场景的存在感。

## 首页重新设计

### 画面结构

```text
┌─────────────────────────┐
│  资源 HUD / 当前水域     │
│                         │
│                         │
│      水域主场景          │
│   鱼、泡泡、水草、光斑    │
│                         │
│    当前伙伴浮标 / 产出泡泡 │
│                         │
│  [投喂] [收取] [进化]     │
│  水域 孵化 图鉴 远行 目标  │
└─────────────────────────┘
```

### 首页原则

- 不出现长滚动。
- 不出现大面积白卡片。
- 不出现解释性段落。
- 主场景至少占屏幕 65%。
- 当前伙伴信息只做成小浮标，不做完整详情。
- 详情通过底部 Sheet 呼出。

### 首页组件

1. PondStage  
   负责水域、鱼、水草、泡泡、选中光圈、场景点击。

2. ResourceHud  
   顶部半透明胶囊，显示四类资源图标和数字。

3. PartnerFloat  
   当前伙伴浮标：头像、名字、稀有徽章、等级、短进度条。

4. ActionDock  
   三个大动作：投喂、收取、进化。

5. ModeDock  
   五个模块入口，图标优先，当前项显示文字。

## 二级系统重新设计

### 孵化

不再是列表商店。改成“孵化舱场景”。

结构：

- 中央 3 个孵化槽。
- 鱼蛋作为可拖动/可选择物体。
- 点击槽位弹出鱼蛋选择。
- 孵化完成用获得新伙伴动画。

Godot 实现：

- `HatcheryPanel.tscn`
- `EggSlot.tscn`
- `EggRevealSheet.tscn`
- Tween 做蛋震动和裂光。

### 图鉴

不再是长列表。改成“图鉴册/标本册”。

结构：

- 顶部收集进度。
- 中央两列鱼卡。
- 未发现物种用剪影。
- 点击鱼卡打开伙伴详情 Sheet。

Godot 实现：

- `DexPanel.tscn`
- `FishCard.tscn`
- `RarityBadge.tscn`
- 可用 GridContainer，但必须在独立面板内，不影响首页。

### 远行

不再是任务列表。改成“路线地图”。

结构：

- 水域地图节点。
- 路线点显示奖励图标和时间。
- 当前伙伴拖到路线点或点击派遣。
- 远行中显示倒计时。

Godot 实现：

- `AdventureMap.tscn`
- `RouteNode.tscn`
- Line2D 连接路线。
- Tween 做路线点脉冲。

### 目标

不再是文字任务清单。改成“贴纸板/训练手册”。

结构：

- 可领取目标置顶。
- 每个目标使用图标、进度条、奖励图标。
- 已完成目标盖章。

Godot 实现：

- `QuestBoard.tscn`
- `QuestSticker.tscn`
- AnimationPlayer 做盖章反馈。

## 视觉方向

### 关键词

- 口袋水族箱
- 活的场景
- 玩具感
- 清澈水色
- 软硬结合的粗描边
- 低文字、高反馈

### 不再采用

- 大量白色 UI 卡片。
- 顶部横排模块按钮。
- 长文本说明。
- 默认 OptionButton。
- 所有内容放入 ScrollContainer。
- 纯静态 SVG 稿作为最终设计依据。

### 新视觉骨架

1. 主画面是水域，不是卡片。
2. UI 是浮在水域上的玻璃/玩具贴片。
3. 重要动作是大按钮，次要动作是图标入口。
4. 鱼的稀有度由光、描边、徽章表达。
5. 成功反馈必须动起来。

## 字体策略

当前 v0.4 中使用 `ZCOOL KuaiLe` 是正确方向，但要收敛使用。

建议：

- 鱼名、标题、按钮：`ZCOOL KuaiLe`
- 小数字、资源、说明：信息字体
- Godot 开发期可继续使用当前 STHeiti 兜底
- 发布前替换为开源中文信息字体

不要：

- 全屏所有字都用展示字体。
- 为了风格牺牲小字可读性。

## 技术架构重构

### 保留

这些可以保留：

- `game_data.gd`
- `fish_factory.gd`
- `save_store.gd`
- 进化计算逻辑
- 鱼的程序化绘制思路

### 重写

这些应重写：

- `main.gd` UI 构建方式
- 当前 Header / Resource / Nav / Content 滚动结构
- 当前鱼详情和进化实验室长页面
- 当前列表式孵化、探索、任务

### 新增场景建议

```text
godot/scenes/ui/main_game.tscn
godot/scenes/ui/pond_stage.tscn
godot/scenes/ui/resource_hud.tscn
godot/scenes/ui/action_dock.tscn
godot/scenes/ui/mode_dock.tscn
godot/scenes/ui/bottom_sheet.tscn
godot/scenes/ui/partner_sheet.tscn
godot/scenes/ui/hatchery_panel.tscn
godot/scenes/ui/dex_panel.tscn
godot/scenes/ui/adventure_map.tscn
godot/scenes/ui/quest_board.tscn
godot/scenes/ui/fx_layer.tscn
```

### 新增脚本建议

```text
godot/scripts/ui/main_game.gd
godot/scripts/ui/game_state_controller.gd
godot/scripts/ui/resource_hud.gd
godot/scripts/ui/action_dock.gd
godot/scripts/ui/mode_dock.gd
godot/scripts/ui/bottom_sheet.gd
godot/scripts/ui/partner_sheet.gd
godot/scripts/ui/fx_layer.gd
godot/scripts/ui/ui_theme.gd
```

## 交互状态机

首页不应该靠页面滚动表达状态，而应该靠模式切换：

```text
Idle
├── SelectFish
├── Feeding
├── Collecting
├── Evolving
├── SheetOpen
└── PanelOpen
```

状态含义：

- Idle：鱼自由游动，等待操作。
- SelectFish：选中某条鱼，浮标更新。
- Feeding：玩家选择饲料，食物动画进入水域。
- Collecting：资源飞入 HUD。
- Evolving：锁定输入，播放进化反馈。
- SheetOpen：底部详情打开，水域变暗但继续轻微运动。
- PanelOpen：孵化/图鉴/远行/目标面板打开。

## 动效标准

必须做：

1. 鱼选中：光圈 + 轻微放大。
2. 收取：资源泡泡飞入顶部 HUD。
3. 投喂：食物抛物线进入水面。
4. 进化成功：短暂闪光、鱼变形、结果卡。
5. 切换面板：底部或侧边滑入。

可后续做：

- 触觉反馈。
- 水波 Shader。
- 稀有鱼光效。
- 孵化裂蛋动画。

## 分阶段实施计划

### 阶段 1：新 Shell

目标：搭出 Godot 原生分层结构。

任务：

- 新建 `main_game.tscn`
- 拆出 `GameWorldLayer / HudLayer / DockLayer / SheetLayer / FxLayer`
- 底部 Dock 固定
- 顶部 HUD 固定
- 移除首页主 ScrollContainer

验收：

- 首页无长滚动。
- 主场景占屏幕大部分。
- Tab 永远可见。

### 阶段 2：PondStage 升级

目标：让水域成为真正主场景。

任务：

- 把现有 `pond_view.gd` 改造成 `PondStage`
- 增加选中光圈、泡泡资源、环境层
- 鱼点击更新 PartnerFloat
- 水域背景全屏，不放在卡片里

验收：

- 打开 App 就像进入鱼塘。
- 点击鱼有游戏反馈。

### 阶段 3：动作 Dock 和反馈

目标：让投喂、收取、进化从按钮变成游戏行为。

任务：

- 新建 `ActionDock`
- 收取动画接入资源变化
- 投喂 Sheet 接入饲料选择
- 进化 Sheet 接入概率和结果

验收：

- 每个主动作都有动画反馈。
- 玩家不需要读长文案也知道发生了什么。

### 阶段 4：二级系统面板

目标：重写孵化、图鉴、远行、目标。

任务：

- `HatcheryPanel`
- `DexPanel`
- `AdventureMap`
- `QuestBoard`

验收：

- 每个面板都像游戏系统，不像表单。
- 每个面板只处理自己的主任务。

### 阶段 5：主题和字体

目标：统一视觉语言。

任务：

- 引入展示字体到 Godot 资源
- 建立主题脚本或 Theme 资源
- 重写按钮、徽章、进度条、弹层样式

验收：

- 标题、按钮、鱼名有游戏感。
- 小信息仍然清晰。

### 阶段 6：真机调优

目标：iPhone 上舒服。

任务：

- 安全区适配
- 拇指区测试
- 性能检查
- iOS 导出安装

验收：

- iPhone 上无遮挡。
- 触摸手感自然。
- 动效不卡。

## 具体第一步建议

不要继续改旧 `main.gd`。第一步应该新建一套 `main_game.tscn` 原型；完成验证后以 `main_game.tscn` 作为唯一 App 入口，旧原型入口从 App 工程中移除。

建议本轮实现：

1. 新建 Godot UI Shell。
2. 迁移 PondView 到全屏 PondStage。
3. 加顶部 HUD 和底部 Dock。
4. 只实现水域首页一个模块。
5. 真机安装测试。

这样可以在 1 天内看到方向是否正确。方向正确后，再迁移孵化、图鉴、远行、目标。

## 成败标准

成功的新版应该满足：

- 截屏看起来像游戏，不像 App 管理页。
- 不读文字也能知道主操作在哪。
- 水域和鱼是视觉主角。
- 动效承担反馈，而不是弹日志。
- 代码结构能继续扩展。

失败的新版会表现为：

- 只是换了一套字体和颜色。
- 仍然有大量卡片和长滚动。
- 所有信息还是靠文字解释。
- Godot 只是承载 UI，没有发挥游戏引擎价值。
