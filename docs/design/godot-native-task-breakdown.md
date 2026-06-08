# Pokefish Godot-Native 重构子任务计划

版本：v1.0  
来源方案：[godot-native-redesign-plan.md](./godot-native-redesign-plan.md)  
目标：把 Godot-native 重构方案拆成可执行、可验收、可排期的工程任务。

## 当前执行进度

更新时间：2026-06-06 18:42（Asia/Shanghai）

| 里程碑 | 状态 | 当前结论 |
|---|---|---|
| M0 准备与隔离 | 已完成 | 新 Godot UI 目录、入口场景、Controller 已建立；旧 Web/Capacitor 代码已移除，工程已转为 Godot App-only。 |
| M1 首页原型 | 已完成 | 全屏水域、顶部 HUD、伙伴浮标、图标化动作 Dock、模式 Dock 已接入新版主场景；水域已接入精选 Kenney CC0 环境素材。 |
| M2 主动作反馈 | 已完成 | 收取冷却与资源飞行、投喂抛物动画、进化锁定与结果卡已实现。 |
| M3 BottomSheet | 已完成 | 伙伴、投喂、进化弹层已接入；投喂弹层已改成图形饲料卡；伙伴详情和首页伙伴浮标已显示真实鱼外观缩略图。 |
| M4 二级系统面板 | 已完成 | 孵化、图鉴、远行、目标已迁移；孵化、图鉴点击、远行奖励、目标领取均已有流程 QA 覆盖；图鉴鱼卡已改为更少文字的竖向卡片，等级显示为整数并避免卡片内外溢。 |
| M5 主题字体组件 | 已完成代码侧收口 | 展示字体保留项目内 ZCOOL；正文/小字已切到 iOS 系统字体 fallback；STHeiti 已移除；资源奖励和主动作已改成图形组件。 |
| M6 真机调优 | 部分完成 | iPhone 13 Pro 已可构建、安装、启动；导出包已通过 iPhone-only、portrait-only、PCK 内容、App 图标和启动图审计；DebugLayer 已接入 FPS/节点峰值/安全区/UI 状态/触点可视化、触点命中归类、语义事件计数、安全区/关键 UI 外框和手测清单，图标识别、游戏感、字体观感、单手可达均显示为 App 内人工判读项；弹层/面板已统一竖向滚动和内容拖拽滚动，遮罩层不再吃掉底部 Dock 触摸；2026-06-06 18:42 已根据首轮手测反馈修复内容拖拽、图标识别和单手手感，并重新部署到 iPhone；常驻 smoke/layout/flow/text/performance/touch/scroll-drag/manual-debug/ergonomics/ios-package/visual/kenney QA 已加入并改为文件系统路径运行；真实触控/视觉满意度仍需复测反馈。 |

最新已验证链路：

- Godot `4.6.3.stable.official.7d41c59c4` 导入通过。
- 项目已按 App-only 方向清理：旧 Web 源码、静态构建产物、npm 配置、`node_modules/` 和 Capacitor iOS 工程已移除；当前只保留 Godot App 工程、精选游戏素材、任务文档和 Godot iOS 导出产物。
- README 和 `godot/IOS_EXPORT.md` 已改为 Godot/iOS App 专用说明，不再包含 npm、浏览器或 Capacitor 工作流。
- iOS export preset 已移除旧 Web 目录排除项，保留 Godot App 开发资料、原始素材库、构建产物和 QA 脚本排除规则；旧 Godot 原型入口 `godot/scenes/main.tscn` 和 `godot/scripts/main.gd` 已移除；`godot/scripts/qa/` 已加 `.gdignore`，QA 可用文件系统路径运行但不会再进入 Godot 资源扫描。
- 主场景、FoodSheet、DexPanel、AdventureMap、QuestBoard、HatcheryPanel 无头启动通过。
- 临时 smoke test 已用真实 `GameStateController` 接入 FoodSheet 和 DexPanel 跑过，测试脚本已删除。
- 临时交互 smoke test 已自动打开投喂、伙伴、进化、孵化、图鉴、远行、目标，测试脚本已删除。
- 常驻 QA 脚本已加入：`godot/scripts/qa/smoke_interactions.gd`，可用 Godot headless 自动验证主要面板打开、旧存档鱼数据迁移和动态内容挂载。
- 常驻布局 QA 脚本已加入：`godot/scripts/qa/layout_audit.gd`，可用 Godot headless 自动验证 375x667、390x844、430x932 三种竖屏视口，覆盖 HUD/伙伴浮标/Dock 非遮挡、BottomSheet/二级面板不越界、可见按钮最小 44px 命中区、ScrollContainer 横向禁用和竖向滚动开启。
- 常驻文字 QA 脚本已加入：`godot/scripts/qa/text_render_audit.gd`，可用 Godot headless 自动验证展示字体/正文字体分层、正文使用 `SystemFont`、优先 `PingFang SC`、按钮和文字最小字号、无替换字形。
- 常驻二级系统流程 QA 已加入：`godot/scripts/qa/m4_flow_audit.gd`，可用 Godot headless 自动验证 3 个孵化槽、鱼蛋库存、孵化加鱼/扣蛋/记录统计、图鉴筛选/未知剪影/鱼卡打开伙伴弹层、远行路线奖励到账、目标领取与盖章状态。
- 常驻性能预算 QA 已加入：`godot/scripts/qa/performance_budget_audit.gd`，可用 Godot headless 自动验证 36 条鱼仍保持低节点预算、资源飞行/投喂/Toast/结果卡特效结束后清理、BottomSheet/PanelHost 反复开关不持续增长。
- 常驻触控冲突 QA 已加入：`godot/scripts/qa/touch_conflict_audit.gd`，可用 Godot headless 推送真实触控事件和 GUI pointer 点击，验证首页触鱼可选中、DebugLayer 不拦截触鱼、BottomSheet/PanelHost 打开时底层鱼不会被误选，同时底部 ActionDock/ModeDock 不会被弹层或面板遮罩层挡住。
- 常驻内容区拖拽滚动 QA 已加入：`godot/scripts/qa/scroll_drag_audit.gd`，可用 Godot headless 推送真实 `InputEventScreenDrag`，从弹层/面板内容区中心以及按钮控件上起滑拖动，验证 BottomSheet、PanelHost 和实际二级面板不依赖最右侧滚动条也能滚动。
- 常驻手测辅助层 QA 已加入：`godot/scripts/qa/manual_debug_overlay_audit.gd`，可用 Godot headless 自动验证 DebugLayer 不拦截输入、手测清单存在、HUD/伙伴浮标/Dock/弹层/面板审计外框在视口内且不小于 44px，并确认空白水域触点不会误计为点鱼成功。
- 常驻人体工学 QA 已加入：`godot/scripts/qa/ergonomics_audit.gd`，可用 Godot headless 自动验证 375x667、390x844、430x932 三种竖屏下主动作和模式 Dock 位于拇指热区、避开 Home Indicator，BottomSheet 和 PanelHost 不侵入底部常驻操作区，并保持足够内容拖拽面。
- 常驻视觉快照 QA 已加入：`godot/scripts/qa/visual_snapshot_audit.gd`，用 macOS 显示驱动渲染 390x844 竖屏，自动覆盖首页、投喂、伙伴、进化、孵化、图鉴、远行、目标和 DebugLayer 9 个关键状态；快照保存到 `godot/build/qa_snapshots/`。
- 常驻 Kenney 资源边界 QA 已加入：`godot/scripts/qa/kenney_asset_audit.gd`，自动验证精选资源可加载、尺寸为 128px、PondStage 接入环境素材、原始资源包被导出配置排除。
- iOS 导出已排除 `godot/scripts/qa/*` 和 `resource_packages/*`；PCK 字符串扫描确认未包含旧 Web/Capacitor 文件、旧 Godot 原型入口、原始素材包路径、QA 路径或 `STHeiti`；`.godot` 路径仅允许 Godot 生成的 imported/exported 运行资源和必要 metadata。
- 常驻 iOS 包级 QA 已加入：`godot/scripts/qa/ios_package_audit.sh`，自动验证构建产物存在、`UIDeviceFamily=[1]`、Xcode `TARGETED_DEVICE_FAMILY=1`、方向为 portrait-only，扫描 PCK 中是否混入旧 Web/Capacitor、旧 Godot 原型入口、原始素材包、QA 脚本或开发路径，并用白名单约束 `.godot` 生成路径；同时检查 App 图标源为 1024x1024 RGB/no-alpha、实际 App 包图标无 alpha、自定义启动图 `splash@2x/@3x` 为 800x600 RGB/no-alpha。
- 常驻 iOS 真机设备 smoke 已加入：`godot/scripts/qa/ios_device_smoke.sh`，自动从已连接 iPhone 读取安装列表、运行进程、显示状态和设备生成的 App 图标，确认 `com.pokefish.game` 已安装、`Pokefish` 进程运行、屏幕为 portrait、主屏尺寸为竖屏 Retina，且设备返回非占位 App 图标。
- 统一 QA 入口已加入：`godot/scripts/qa/run_all_qa.sh`，串联 Godot 无头逻辑 QA、390x844 视觉快照、iOS 包级审计和真机设备 smoke；无设备时可临时设置 `POKEFISH_SKIP_DEVICE_QA=1` 只跑本机侧 QA。
- 一键真机部署入口已加入：`godot/scripts/qa/ios_debug_deploy.sh`，串联 Godot 导入/导出、Xcode Debug 构建、iOS 包级审计、安装、启动和真机设备 smoke；可设置 `POKEFISH_RUN_FULL_QA=1` 在部署后追加完整 QA。
- PartnerSheet 已从通用占位图改为根据当前鱼 `appearance` 绘制真实缩略鱼。
- PartnerFloat 已从通用占位图改为根据当前鱼 `appearance` 绘制真实缩略鱼。
- ActionDock 已从纯文字按钮改为自绘动作图标 + 两字短标签，减少首页底部的生硬文字；`text_render_audit.gd` 已加入断言，防止主动作退回纯文字按钮。
- ModeDock 已从符号文字按钮改为自绘模式图标 + 两字短标签；首轮真机反馈显示纯图标不可读后，5 个模式入口改为常驻短标签，以牺牲少量文字密度换取手机游戏入口可识别性。
- ResourceHud 顶部菜单已从 `≡` 字符改为自绘图标；顶部收益和伙伴收益已从 `+/分` 单位文字改为资源图标 + 数字，减少首页常驻系统式文本。
- App 图标已从通用占位图替换为项目内自绘 Pokefish 鱼图标；`godot/assets/icon.svg` 为可编辑 SVG 源，`godot/assets/app_icon_1024.png` 为 iOS 导出使用的 1024x1024 RGB/no-alpha PNG。iOS 启动图也已替换为自定义 Pokefish 图，`godot/assets/launch_splash.svg` 为可编辑源，`launch_splash_2x.png` 和 `launch_splash_3x.png` 为导出使用的 800x600 RGB/no-alpha PNG。
- 已调研 `resource_packages/kenney_fish-pack_2`：Kenney Fish Pack 2.0，授权为 CC0，可个人、教育、商业使用；署名可选。
- 已选择性使用 Kenney `PNG/Double` 的 18 个 128px 环境素材：气泡、岩石、海草、沙地和沙地顶部块，并复制到 `godot/assets/kenney_fish_pack/`。
- 暂未使用 Kenney 静态鱼图：当前鱼由基因和外观参数程序绘制，能表达体型、配色、纹样、发光等养成差异；直接替换成静态鱼图会削弱这条核心线。
- `PondView` 已改为“程序鱼 + 贴图环境”的混合绘制：气泡、沙地、背景海草、前景岩石/海草使用精选 Kenney PNG。
- 原始素材包已通过 `resource_packages/.gdignore` 和 iOS `exclude_filter` 双重排除，保留在工程目录供后续挑选，但不会进入导出包。
- 顶部菜单、返回、购买、图鉴筛选等小按钮已补齐 44px 级别最小触控区。
- BottomSheet 和二级系统面板已接入内容区触屏拖拽滚动，减少只能拖动最右侧滚动条的问题。
- BottomSheet 已修正为从底部升起并停在主动作区上方，不再错误贴到屏幕顶部；PanelHost 底部也已避开 ActionDock/ModeDock。两者的遮罩层现在同样只覆盖 Dock 上方区域，避免视觉留白但触摸仍被上层吃掉的问题。
- `project.godot` 已显式启用 `input_devices/pointing/emulate_mouse_from_touch=true`，让 iOS 触摸更稳定地触发 Godot Button 的点击路径。
- 手机竖屏视口默认启用 44px 顶部和 28px 底部安全区兜底，Headless QA 会按手机安全区逻辑检查布局。
- DebugLayer 已补充当前/平均/最低 FPS、节点数/节点峰值、当前模式、UI 状态、触点计数、触点位置、触点命中模块、是否落在安全区、底部距离、各模块触点计数、语义事件计数、视口尺寸和 L/T/R/B 安全区读数；可显示触点十字、安全区框、关键 UI 外框和手测清单，辅助真机排查误触/遮挡/滚动问题。Evidence 中的水域项现在只由真实鱼选择事件点亮，空白水域触点不会冒充点鱼成功；图标识别、游戏感、字体观感和单手可达不再硬编码为通过，面板 Evidence 行显示“图标看 / 游戏看 / 字体看 / 单手看”，保留给手持真机确认。
- 视觉快照 QA 曾暴露顶部 HUD 收益文字竖排、等级芯片被撑高、伙伴详情页数值/标签被压成竖排、投喂标题竖排、进化概率行竖排、图鉴统计/物种名竖排、目标标题竖排、图鉴鱼卡等级标签外溢的问题；已通过 ResourceHud、PartnerFloat、PartnerSheet、FoodSheet、EvolutionSheet、DexPanel、QuestBoard、ResourceBadge 和 TagChip 的 nowrap/ellipsis/fixed touch size 修正；图鉴鱼卡进一步移除了低价值文字标签，减少卡片拥挤感。
- 新版 `UiTheme` 已将标题/按钮展示字体和正文/小字字体拆开；小字不再全部使用 ZCOOL 展示字体。
- 旧存档鱼数据缺少 `genes / appearance / traits` 时会自动迁移并写回。
- `STHeiti` 引用和资源文件已移除，iOS 导出日志仅包含项目内 ZCOOL 字体资源；正文通过系统字体 fallback 提供。
- DebugLayer 已通过无头启动验证，可通过顶部菜单按钮切换 QA 面板。
- 统一 QA 入口 `run_all_qa.sh` 已通过，输出为 `Pokefish QA passed`；其中 Godot headless `smoke_interactions.gd`、多尺寸 `layout_audit.gd`、`text_render_audit.gd`、`m4_flow_audit.gd`、`performance_budget_audit.gd`、`touch_conflict_audit.gd`、`scroll_drag_audit.gd`、`manual_debug_overlay_audit.gd`、`ergonomics_audit.gd` 和 `kenney_asset_audit.gd` 均已通过；iOS 包级 `ios_package_audit.sh` 输出为 `iPhone-only, portrait-only, clean PCK, valid app icon, valid launch splash`；iOS 设备侧 `ios_device_smoke.sh` 最新输出为 `installed com.pokefish.game, running PID 2575, portrait 1170x2532@3x, real app icon`。
- `manual_debug_overlay_audit.gd` 已新增触点命中归类和语义事件验证，自动确认 ActionDock、水域空白和安全区外缘的触点会被 DebugLayer 正确标记，空白水域触点不会点亮鱼选择证据，真实点鱼、主动作、弹层、面板和模式切换事件会进入 Event 计数，并确认字体项显示为手动目检状态。
- `text_render_audit.gd` 已新增首页微文案、弹层和二级面板短文本宽度约束，自动防止菜单按钮退回文字字形、顶部/伙伴收益退回 `+/分` 单位文字，以及短标签、数字、任务标题被挤成竖排。
- macOS 显示驱动 `visual_snapshot_audit.gd` 已通过，9 张 390x844 关键 UI 快照均已生成；首页快照已确认环境素材未遮挡核心 HUD、伙伴浮标和 Dock，顶部/伙伴收益图标化后布局稳定；投喂和图鉴快照已确认弹层/面板下方 Dock 清晰可见，图鉴鱼卡不再外溢；DebugLayer 快照已确认触点命中行和 Event 行可读，Evidence 行包含“图标看 / 游戏看 / 字体看 / 单手看”。
- iOS Debug 包已导出、Xcode 构建成功、已安装并启动到 `com.pokefish.game`。最近一次一键部署验证时间：2026-06-06 18:42；`ios_debug_deploy.sh` 输出为 `Pokefish iPhone deploy passed`；`devicectl` 确认设备显示为 1170x2532、3x、portrait，`Pokefish` 进程 PID 为 2575；包级 QA 确认产物为 iPhone-only、portrait-only，PCK 内容干净且不包含旧 Godot 原型入口，`.godot` 生成路径已受白名单约束，App 图标源和打包图标均无 alpha，自定义启动图已进入导出的 Xcode 资源；设备侧 smoke 确认 App 已安装、进程运行、竖屏显示和非占位 App 图标。

当前最重要的剩余工作：

1. 在手机上实际点按所有模块，重点确认弹层/面板打开时底部 Dock 是否符合预期可点，是否仍有遮挡、滚动死角、触控误触。
2. 根据真机反馈继续调整按钮命中区、底部 Home Indicator 空间和面板滚动手感；内容区拖拽滚动和底部 Dock 可点性已有自动 QA 覆盖，但最终手感仍需手持确认。
3. 在真机上确认正文系统字体的实际观感；如果仍觉得太普通，再换成体积可接受的 OFL 信息字体。
4. 真机打开顶部菜单 QA 面板，按面板内清单确认点鱼、弹层拖动、面板拖动、Dock、底部安全区、主动作图标识别度、游戏感、文字观感和单手可达是否稳定；其中 Event 行会累计点鱼、主动作、弹层、面板和模式切换，Evidence 行保留“图标看 / 游戏看 / 字体看 / 单手看”作为人工判断。

手持验收清单已整理到：[iphone-hand-test-checklist.md](../qa/iphone-hand-test-checklist.md)。

手持验收结果记录到：[iphone-hand-test-result.md](../qa/iphone-hand-test-result.md)。

完成度审计已整理到：[completion-audit.md](../qa/completion-audit.md)。

## 总体策略

早期重构采用过“新主场景并行开发，旧版保留可回退”的方式。  
当前已切换为 App-only 收口：`main_game.tscn` 是唯一运行入口，旧 `main.tscn/main.gd` 原型入口已移除，避免 iOS 包和文档继续暴露过期路径。

第一目标不是一次性完成所有模块，而是先做出一个可上 iPhone 的新版首页原型：

```text
新版首页原型 = 全屏水域 + 顶部 HUD + 底部 Dock + 当前伙伴浮标 + 3 个主动作
```

只要这个原型在真机上感觉像游戏，后续孵化、图鉴、远行、目标再逐步迁移。

## 里程碑总览

| 里程碑 | 名称 | 目标 | 建议工期 |
|---|---|---|---|
| M0 | 准备与隔离 | 建立新 UI 目录和入口，最终收口为 App-only | 0.5 天 |
| M1 | Godot-native 首页原型 | 水域主场景 + HUD + Dock 跑起来 | 1-2 天 |
| M2 | 主动作反馈 | 收取、投喂、进化有动画反馈 | 1-2 天 |
| M3 | BottomSheet 系统 | 伙伴详情、投喂、进化确认进入弹层 | 1 天 |
| M4 | 二级系统面板 | 孵化、图鉴、远行、目标逐个迁移 | 2-4 天 |
| M5 | 主题、字体、动效统一 | 统一组件风格和游戏感 | 1-2 天 |
| M6 | iPhone 真机调优 | 安全区、触摸、性能、导出 | 0.5-1 天 |

## M0：准备与隔离

### T0.1 建立新目录结构

目标：为新 UI 建立独立目录，完成验证后收口为唯一 App 入口。

新增目录：

```text
godot/scenes/ui/
godot/scripts/ui/
godot/assets/fonts/
godot/assets/theme/
```

产出：

- UI 场景目录存在
- UI 脚本目录存在
- 字体和主题资源目录存在

依赖：无

验收：

- `project.godot` 指向 `res://godot/scenes/ui/main_game.tscn`
- 旧 `godot/scenes/main.tscn` 和 `godot/scripts/main.gd` 不再存在
- iOS 构建仍可通过

### T0.2 创建新版入口场景

目标：创建并接入新版主场景，完成验证后作为唯一 App 入口。

建议新增：

```text
godot/scenes/ui/main_game.tscn
godot/scripts/ui/main_game.gd
```

实现：

- `main_game.tscn` 根节点用 `Control`
- 暂不替换 `project.godot` 的主场景
- 先手动运行或临时切换测试

依赖：T0.1

验收：

- Godot 能打开新场景
- Headless 导入不报错
- 旧主场景不受影响

### T0.3 建立 GameStateController

目标：把加载、保存、选中鱼、当前水域等状态从 UI 中抽离。

新增：

```text
godot/scripts/ui/game_state_controller.gd
```

职责：

- 加载/创建存档
- 暴露当前资源、鱼群、选中鱼、当前水域
- 封装收取、投喂、进化、探索、任务领取调用
- 发出 `state_changed`、`fish_selected`、`resources_changed` 信号

依赖：T0.1

验收：

- 不依赖任何 UI 控件即可加载当前存档
- 能返回当前选中鱼
- 能触发资源更新信号

## M1：Godot-native 首页原型

### T1.1 创建分层 Shell

目标：搭出新首页的层级结构。

`main_game.tscn` 结构：

```text
MainGame
├── GameWorldLayer
├── HudLayer
├── DockLayer
├── SheetLayer
├── FxLayer
└── DebugLayer
```

实现建议：

- `GameWorldLayer` 使用 `Control` 或 `Node2D` 承载水域
- `HudLayer / DockLayer / SheetLayer / FxLayer` 使用 `CanvasLayer` 或全屏 `Control`
- 不使用主 ScrollContainer

依赖：T0.2

验收：

- 运行后各层能显示占位块
- 底部 Dock 和顶部 HUD 不随任何内容滚动
- 层级顺序正确，Sheet 能覆盖世界层

### T1.2 迁移 PondView 为 PondStage

目标：把现有鱼塘组件升级为全屏主场景。

新增：

```text
godot/scenes/ui/pond_stage.tscn
godot/scripts/ui/pond_stage.gd
```

迁移内容：

- 复用 `pond_view.gd` 的水面、鱼、水草、泡泡绘制思路
- 去掉卡片边界和固定 320 高度
- 自适应可用屏幕
- 支持 `set_game_state(state, pond_id, selected_fish_id)`
- 发出 `fish_selected(fish_id)` 信号

依赖：T1.1、T0.3

验收：

- 水域占据首页大部分面积
- 鱼能游动
- 点击鱼能选中
- 不出现横向溢出

### T1.3 增加鱼选中反馈

目标：鱼不再只是被点击，必须有游戏反馈。

实现：

- 选中鱼出现光圈或描边
- 选中瞬间轻微放大或闪光
- PartnerFloat 更新当前鱼

依赖：T1.2

验收：

- 点击鱼 100ms 内有视觉反馈
- 切换鱼时反馈明确
- 滑动/误触不会频繁误选

### T1.4 创建 ResourceHud

目标：顶部显示资源和当前水域，不占用主场景。

新增：

```text
godot/scenes/ui/resource_hud.tscn
godot/scripts/ui/resource_hud.gd
```

内容：

- 当前水域名
- 泡泡币、贝壳、鱼蛋、珍珠四类资源
- 设置/菜单入口占位

依赖：T1.1、T0.3

验收：

- HUD 固定在顶部安全区下方
- 资源变化后数字刷新
- 不遮挡鱼塘核心区域

### T1.5 创建 PartnerFloat

目标：首页只显示当前伙伴的轻量状态，而不是完整详情。

新增：

```text
godot/scenes/ui/partner_float.tscn
godot/scripts/ui/partner_float.gd
```

内容：

- 鱼名
- 稀有度徽章
- 等级
- 1 条短状态条或产出值

交互：

- 点击打开 PartnerSheet

依赖：T1.2、T1.3

验收：

- 选中鱼后浮标更新
- 浮标不遮挡主要按钮
- 点击浮标能发出 `details_pressed`

### T1.6 创建 ActionDock

目标：首页底部三大主动作固定在拇指区。

新增：

```text
godot/scenes/ui/action_dock.tscn
godot/scripts/ui/action_dock.gd
```

按钮：

- 投喂
- 收取
- 进化

视觉：

- 每个主动作使用自绘图标为主
- 两字短标签为辅
- Button 原始文字保持为空，避免回到纯文字按钮

信号：

- `feed_pressed`
- `collect_pressed`
- `evolve_pressed`

依赖：T1.1

验收：

- 三个按钮固定在底部 Tab 上方
- iPhone 上单手可触达
- 按下有缩放/高亮反馈
- `text_render_audit.gd` 验证动作按钮存在图标、短标签和可见标签高度

### T1.7 创建 ModeDock

目标：固定底部模块入口，替代旧顶部导航。

新增：

```text
godot/scenes/ui/mode_dock.tscn
godot/scripts/ui/mode_dock.gd
```

模块：

- 水域
- 孵化
- 图鉴
- 远行
- 目标

交互：

- 当前项高亮
- 其他项图标化
- 点击发出 `mode_selected(mode_id)`

依赖：T1.1

验收：

- Tab 永远可见
- 切换模块不需要滚动
- 当前项状态明确

### T1.8 首页原型真机验证

目标：尽快判断方向是否正确。

验证内容：

- Godot 导入检查
- iOS 导出
- Xcode 编译
- 安装到 iPhone
- 打开后首屏是否像游戏

依赖：T1.1-T1.7

验收：

- App 可启动
- 首页无长滚动
- 水域占主视觉
- HUD、Dock 不遮挡

## M2：主动作反馈

### T2.1 实现 FxLayer

目标：集中管理资源飞行、闪光、短提示。

新增：

```text
godot/scenes/ui/fx_layer.tscn
godot/scripts/ui/fx_layer.gd
```

职责：

- 播放资源飞行动画
- 播放鱼选中小闪光
- 播放短提示 Toast
- 播放进化闪光

依赖：T1.1

验收：

- `FxLayer.play_resource_fly(from, to, type, amount)` 可被调用
- 特效不阻塞 UI
- 特效结束后自动清理节点

### T2.2 收取动作重构

目标：收取不再只是数字变化和日志，而是有动画反馈。

实现：

- 点击收取
- GameStateController 计算收益
- 水域内生成若干资源泡泡
- 泡泡飞向 HUD
- HUD 数字更新

依赖：T0.3、T1.4、T1.6、T2.1

验收：

- 收取后资源数字正确变化
- 有飞行动画
- 多次点击不会重复爆量或卡住

### T2.3 投喂动作重构

目标：投喂成为场景行为。

实现：

- 点击投喂打开 FoodSheet
- 选择食物
- 食物从 Dock 抛入水域
- 当前鱼靠近或闪一下
- 状态变化

依赖：T1.2、T1.6、T2.1、M3 BottomSheet 基础

验收：

- 食物选择不使用默认 OptionButton
- 投喂有动画
- 经验/心情/饥饿变化正确

### T2.4 进化动作重构

目标：进化从“概率按钮”变成仪式感反馈。

实现：

- 点击进化打开 EvolutionSheet
- 显示概率、主要条件徽章
- 确认后锁定输入
- 播放闪光/水波/鱼体变化
- 成功或失败用结果卡反馈

依赖：T1.2、T1.6、T2.1、M3 BottomSheet 基础

验收：

- 成功/失败反馈明确
- 进化后鱼外观更新
- 动画中不会重复触发

## M3：BottomSheet 系统

### T3.1 实现 BottomSheet 基础组件

目标：统一底部弹层。

新增：

```text
godot/scenes/ui/bottom_sheet.tscn
godot/scripts/ui/bottom_sheet.gd
```

能力：

- 打开/关闭动画
- 背景遮罩
- 点击遮罩关闭
- 支持动态挂载内容
- 打开时水域继续轻微运动

依赖：T1.1

验收：

- 弹层从底部滑入
- 关闭后节点清理
- 不影响 HUD 和 Dock 层级

### T3.2 实现 PartnerSheet

目标：完整伙伴详情进入弹层。

新增：

```text
godot/scenes/ui/partner_sheet.tscn
godot/scripts/ui/partner_sheet.gd
```

内容：

- 大鱼像或缩略鱼
- 鱼名、稀有度、等级
- 心情、亲密、饥饿、产出
- 基因和性格
- 进化记录摘要

依赖：T3.1、T1.5

验收：

- 点击 PartnerFloat 打开详情
- 文案不过长
- 小屏不溢出

### T3.3 实现 FoodSheet

目标：替代默认 OptionButton。

新增：

```text
godot/scenes/ui/food_sheet.tscn
godot/scripts/ui/food_sheet.gd
```

内容：

- 饲料卡片
- 每张卡显示图标、名字、效果图标
- 选中后执行投喂

依赖：T3.1

验收：

- 选择饲料手感自然
- 不出现默认下拉控件
- 选择后关闭并触发投喂动画

### T3.4 实现 EvolutionSheet

目标：进化确认和结果统一管理。

新增：

```text
godot/scenes/ui/evolution_sheet.tscn
godot/scripts/ui/evolution_sheet.gd
```

内容：

- 当前概率
- 主要影响条件徽章
- 确认按钮
- 成功/失败结果状态

依赖：T3.1

验收：

- 概率和当前计算一致
- 结果不靠日志表达

## M4：二级系统面板

### T4.1 PanelHost

目标：统一承载孵化、图鉴、远行、目标面板。

新增：

```text
godot/scenes/ui/panel_host.tscn
godot/scripts/ui/panel_host.gd
```

能力：

- 从底部或右侧滑入
- 支持返回水域
- 支持切换不同面板
- 背景水域可保留暗化

依赖：T1.7

验收：

- ModeDock 点击能打开对应面板
- 返回水域不重建整个游戏状态

### T4.2 HatcheryPanel

目标：孵化系统游戏化。

新增：

```text
godot/scenes/ui/hatchery_panel.tscn
godot/scripts/ui/hatchery_panel.gd
godot/scenes/ui/egg_slot.tscn
```

内容：

- 3 个孵化槽
- 鱼蛋库存
- 孵化按钮
- 获得新鱼结果

依赖：T4.1、T2.1

验收：

- 鱼蛋数量正确
- 孵化成功后新鱼加入鱼群
- 有孵化反馈

### T4.3 DexPanel

目标：图鉴像收集册，不像列表。

新增：

```text
godot/scenes/ui/dex_panel.tscn
godot/scripts/ui/dex_panel.gd
godot/scenes/ui/fish_card.tscn
```

内容：

- 收集进度
- 稀有度筛选
- 鱼卡网格
- 未发现剪影

依赖：T4.1、T3.2

验收：

- 鱼卡点击打开 PartnerSheet
- 筛选可用
- 不出现长文本列表

### T4.4 AdventureMap

目标：探索系统从列表变成路线地图。

新增：

```text
godot/scenes/ui/adventure_map.tscn
godot/scripts/ui/adventure_map.gd
godot/scenes/ui/route_node.tscn
```

内容：

- 路线点
- 奖励图标
- 时间
- 推荐伙伴/当前伙伴

依赖：T4.1、T2.1

验收：

- 点击路线可派遣
- 奖励正确到账
- 路线点有脉冲或选中反馈

### T4.5 QuestBoard

目标：任务系统变成训练手册/贴纸板。

新增：

```text
godot/scenes/ui/quest_board.tscn
godot/scripts/ui/quest_board.gd
godot/scenes/ui/quest_sticker.tscn
```

内容：

- 可领取置顶
- 任务进度条
- 奖励图标
- 已完成盖章

依赖：T4.1、T2.1

验收：

- 可领取任务明显
- 领取后状态变化
- 没有长任务说明堆叠

## M5：主题、字体、组件统一

### T5.1 引入展示字体

目标：把设计稿中的展示字体迁入 Godot。

任务：

- 将 `ZCOOLKuaiLe-Regular.ttf` 放入 `godot/assets/fonts/`
- 保留中文信息字体兜底
- 建立标题/按钮/鱼名字体引用

依赖：M1 基础 UI

验收：

- Godot 导入字体成功
- 标题、按钮、鱼名字体生效
- 小字仍清晰

### T5.2 建立 UI Theme

目标：减少散落样式代码。

新增：

```text
godot/scripts/ui/ui_theme.gd
```

或：

```text
godot/assets/theme/pokefish_theme.tres
```

统一：

- 颜色
- 描边
- 圆角
- 阴影
- 字号
- 按钮状态

依赖：T5.1

验收：

- 新组件能复用主题
- 不再每个脚本手写一堆 `_style()`

### T5.3 组件库收口

目标：建立少量游戏 UI 基础组件。

建议组件：

- `GameButton`
- `ResourcePill`
- `RarityBadge`
- `IconTab`
- `StatBar`
- `Toast`

依赖：T5.2

验收：

- 二级面板复用组件
- 视觉一致
- 主脚本减少样式细节

## M6：真机调优与发布准备

### T6.1 安全区适配

目标：适配 iPhone 刘海和 Home Indicator。

任务：

- 顶部 HUD 避开刘海
- 底部 Dock 避开 Home Indicator
- 左右边距适配不同 iPhone 宽度

依赖：M1

验收：

- iPhone 13 Pro 上无遮挡
- 竖屏锁定正常

### T6.2 触摸手感验证

目标：确保按钮、鱼点击、弹层不冲突。

测试：

- 点击鱼
- 点击浮标
- 打开/关闭 Sheet
- 连续点击收取
- 切换模块
- 返回水域

依赖：M1-M4

验收：

- 没有误触高发区域
- 弹层打开后底层不会误响应
- 主要操作单手可达

### T6.3 性能检查

目标：保证移动端流畅。

测试：

- 鱼数量增加时 FPS
- 泡泡/粒子数量
- Sheet 动画
- 进化特效

依赖：M2-M4

验收：

- iPhone 真机上无明显卡顿
- 特效结束后节点清理
- 内存不持续增长

### T6.4 iOS 构建安装

目标：每个里程碑都能真机验证。

命令流程：

```bash
/Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/ios_debug_deploy.sh
```

依赖：每个可运行里程碑

验收：

- 构建成功
- 安装成功
- 启动成功
- 设备侧 smoke 确认 App 已安装、进程运行、屏幕为竖屏、App 图标不是占位图

### T6.5 视觉快照验收

目标：在真机手测前，用固定竖屏视口先抓出明显的遮挡、越界、文字异常和空白渲染。

命令流程：

```bash
/Applications/Godot.app/Contents/MacOS/Godot --display-driver macos --audio-driver Dummy --resolution 390x844 --path /Users/rpy/Documents/Claude/pokefish --script /Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/visual_snapshot_audit.gd
```

覆盖状态：

- 首页
- 投喂弹层
- 伙伴弹层
- 进化弹层
- 孵化面板
- 图鉴面板
- 远行面板
- 目标面板
- DebugLayer

验收：

- 9 张 390x844 快照写入 `godot/build/qa_snapshots/`
- 画面非空白，颜色和亮度分布正常
- HUD、伙伴浮标、Dock、弹层、二级面板没有明显遮挡或越界
- 小字不竖排、不被挤压成乱码、不溢出核心控件

### T6.6 真机手测辅助层

目标：让手机上排查问题时不用猜坐标和层级，直接在 QA 面板看到关键调试信息。

入口：

- 点击顶部菜单按钮切换 DebugLayer

显示内容：

- 当前/平均/最低 FPS
- 当前节点数/节点峰值
- 当前模式和 UI 状态
- 触点计数和最近触点坐标
- L/T/R/B 安全区读数
- 绿色安全区框、蓝色关键 UI 外框、黄色触点标记
- 点鱼、弹层拖动、面板拖动、Dock、底部安全区、文字观感手测清单

自动验收：

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/rpy/Documents/Claude/pokefish --script /Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/manual_debug_overlay_audit.gd
```

验收：

- DebugLayer 不拦截底层触摸
- 手测清单可见
- HUD、伙伴浮标、ActionDock、ModeDock、BottomSheet、PanelHost 审计外框在竖屏视口内
- 审计外框命中尺寸不小于 44px

### T6.7 内容区拖拽滚动验收

目标：确保上下滑动可以直接在弹层/面板内容区完成，而不是只能拖动最右侧滚动条。

自动验收：

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/rpy/Documents/Claude/pokefish --script /Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/scroll_drag_audit.gd
```

覆盖：

- BottomSheet 通用容器
- PanelHost 通用容器
- 孵化、图鉴、远行、目标面板中实际存在溢出内容的面板

验收：

- 拖拽起点位于内容区中心，避开最右侧滚动条
- 推送真实 `InputEventScreenTouch` 和 `InputEventScreenDrag`
- 有溢出内容时，`scroll_vertical` 必须随拖拽增加
- 弹层/面板打开关闭后仍能继续响应内容区拖动

### T6.8 拇指区与常驻操作区验收

目标：把“手机游戏手感”里的基础布局要求自动化，避免弹层、二级面板或按钮再次侵入底部常驻操作区。

自动验收：

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/rpy/Documents/Claude/pokefish --script /Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/ergonomics_audit.gd
```

覆盖：

- 375x667、390x844、430x932 三种竖屏
- ActionDock 和 ModeDock 的拇指热区位置
- Home Indicator 底部安全留白
- PartnerFloat 与主动作区间距
- BottomSheet 和 PanelHost 是否避开底部常驻 Dock
- 弹层/面板内容区是否保留足够拖拽面积

验收：

- 主动作和模式入口中心点位于底部拇指热区
- BottomSheet 从底部出现但不压住 ActionDock/ModeDock
- PanelHost 不侵入常驻操作区
- 顶部安全区、底部 Home Indicator 和关键按钮命中区均满足手机竖屏约束

### T6.9 iOS 包级发布验收

目标：确保导出的 App 真正是手机竖屏 App，不把 Web 旧工程、QA 脚本或原始素材库带进包内。

自动验收：

```bash
/Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/ios_package_audit.sh
```

覆盖：

- Debug `.app` 和 `Pokefish.pck` 构建产物存在
- `Info.plist` 的 `UIDeviceFamily` 为 `[1]`
- Xcode 工程 `TARGETED_DEVICE_FAMILY` 为 `1`
- iPhone 和 iPad 方向配置均为 portrait-only
- PCK 字符串扫描不包含旧 Web/Capacitor、旧 Godot 原型入口、原始素材包、QA 脚本、开发快照或字体旧引用路径
- `.godot` 路径只允许 imported/exported 运行资源和 Godot 必要 metadata
- App 图标源、打包图标和 iOS 启动图符合无 alpha 的 App Store 资源要求

验收：

- 产物是 iPhone-only
- 产物是 portrait-only
- App 包只携带运行所需 Godot 资源
- App 包包含自定义 Pokefish 图标和启动图

## 推荐执行顺序

第一轮只做 M0 + M1：

```text
T0.1 -> T0.2 -> T0.3
T1.1 -> T1.2 -> T1.4 -> T1.5 -> T1.6 -> T1.7 -> T1.3 -> T1.8
```

原因：

- 先验证新首页形态是否成立。
- 不急着迁移二级系统。
- 避免把时间花在错误方向的完整实现上。

第二轮做 M2 + M3：

```text
T2.1 -> T3.1 -> T3.2 -> T3.3 -> T3.4 -> T2.2 -> T2.3 -> T2.4
```

原因：

- 先有弹层和 FX，再实现主动作会更干净。
- 投喂和进化都依赖 Sheet。

第三轮做 M4：

```text
T4.1 -> T4.2 -> T4.3 -> T4.4 -> T4.5
```

原因：

- 二级系统互相独立，可以逐个迁移。
- 先做孵化和图鉴，远行和目标可稍后。

第四轮做 M5 + M6：

```text
T5.1 -> T5.2 -> T5.3 -> T6.1 -> T6.2 -> T6.3 -> T6.4 -> T6.5 -> T6.6 -> T6.7 -> T6.8 -> T6.9
```

原因：

- 等主要结构稳定后再统一主题，避免反复返工。
- 真机调优应贯穿每个里程碑，但最终还需要集中收尾。

## 最小可行重构范围

如果只想先验证方向，最小范围是：

1. `main_game.tscn`
2. `main_game.gd`
3. `pond_stage.gd`
4. `resource_hud.gd`
5. `partner_float.gd`
6. `action_dock.gd`
7. `mode_dock.gd`

只实现：

- 首页水域
- 鱼游动
- 鱼选中
- 顶部资源
- 底部动作
- 底部模块入口占位

暂不实现：

- 孵化面板
- 图鉴面板
- 远行面板
- 任务面板
- 完整进化弹层
- 完整投喂弹层

## 风险与控制

### 风险 1：重构范围过大

控制：

- 旧版原型入口不保留在 App 包内，必要历史只通过 git 追溯。
- 先做首页原型。
- 每个里程碑都真机安装。

### 风险 2：Godot UI 组件过度自绘

控制：

- 水域和鱼用自绘。
- 按钮、面板仍用 Control。
- 不为了风格牺牲维护性。

### 风险 3：动效影响性能

控制：

- 优先 Tween 和少量 CPUParticles2D。
- 粒子数量受控。
- 特效结束清理节点。

### 风险 4：字体和中文授权

控制：

- 展示字体使用项目内 ZCOOL 字体。
- STHeiti 已从代码、资源和导出包中移除。
- 正文和小字使用 iOS 系统字体 fallback，不额外嵌入大体积中文字库。
- 若真机观感仍不够贴合风格，再选择体积可接受、授权明确的 OFL 信息字体替换 `TEXT_FONT`。

## 每日执行建议

### Day 1

- T0.1 新目录
- T0.2 新入口
- T0.3 GameStateController
- T1.1 分层 Shell
- T1.2 PondStage 初版

产出：能打开全屏水域首页。

### Day 2

- T1.3 鱼选中反馈
- T1.4 ResourceHud
- T1.5 PartnerFloat
- T1.6 ActionDock
- T1.7 ModeDock
- T1.8 真机验证

产出：iPhone 上能看到 Godot-native 首页原型。

### Day 3

- T2.1 FxLayer
- T3.1 BottomSheet
- T3.2 PartnerSheet
- T2.2 收取反馈

产出：首页开始有游戏反馈。

### Day 4

- T3.3 FoodSheet
- T3.4 EvolutionSheet
- T2.3 投喂反馈
- T2.4 进化反馈初版

产出：三大主动作闭环。

### Day 5+

- 逐步迁移孵化、图鉴、远行、目标
- 主题字体统一
- 真机调优

## 完成定义

本重构计划完成时，应满足：

1. 旧版滚动卡片式首页被新版 Godot-native 首页替代。
2. 水域是视觉和交互主角。
3. 顶部 HUD、底部 Dock、弹层、特效分层清晰。
4. 主动作有动画反馈。
5. 二级系统从列表/表单变成游戏面板。
6. iPhone 真机运行稳定。
7. 自动 QA 覆盖 smoke、layout、text、flow、performance、touch、scroll-drag、manual debug overlay 和 visual snapshot。
