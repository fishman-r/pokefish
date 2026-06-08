# Pokefish UI v3 手机游戏化优化方案与子任务拆解

更新时间：2026-06-06 21:06（Asia/Shanghai）

依据：

- 当前 Godot 竖屏工程：`project.godot`、`godot/scenes/ui/main_game.tscn`
- 最新自动截图：`godot/build/qa_snapshots/01_home.png` 到 `09_debug_overlay.png`
- 手持验收记录：`docs/qa/iphone-hand-test-result.md`
- v2 执行记录：`docs/design/ui-v2-optimization-task-plan.md`

## 直言不讳的判断

v2 已经把“能不能在 iPhone 上竖屏运行、能不能点、能不能滚、能不能看清文字”的基础问题压住了，但它还没有真正像成熟手机游戏。

当前最大问题不是某一个按钮难看，而是视觉组织方式仍然偏工具型 App：

- 首页仍被顶部 HUD 和底部 Dock 框住，水域和鱼还不是绝对主角。
- 面板虽然换了孵化台、图鉴册、小地图、任务板的雏形，但很多内容仍像“卡片列表换皮”。
- 图标有区分，但还没有形成一套稳定的游戏符号语言。
- 颜色仍有语义重叠，黄色、绿色、蓝色的使用不够克制。
- 动效主要停在按钮反馈和少量结果反馈，还没有把行为连接到水域世界里。
- QA 能抓布局硬伤，但还不能充分判断“这是不是像手机游戏”。

所以 v3 不应该继续做零散微调，而应该围绕“水域是主角、操作像游戏、模块像场景、反馈有生命感”重构。

## 设计方向

参考宝可梦式的设计语言，但只取方法，不做复制：

- 明亮、干净、低压力的色彩。
- 粗轮廓用于主角、主按钮、重要反馈；小信息降低描边。
- 大图标 + 短标签，减少说明文字。
- 功能入口像随身工具、地图、图鉴、任务板，而不是后台导航。
- 每个模块有自己的场景隐喻：孵化台、收集册、海域地图、公告任务板。
- 交互反馈尽量发生在游戏世界里，而不是只在按钮上闪一下。

## v3 体验目标

1. 首页第一眼看到的是鱼和水域，而不是一套 UI 框架。
2. 常驻 UI 面积可控，顶部和底部不再夹住游戏画面。
3. 低频模块入口收纳，主动作永远清晰。
4. 字体、图标、颜色、描边形成统一语义。
5. 投喂、收取、进化、孵化、远行都有场景化反馈。
6. iPhone 单手操作自然，滚动不依赖最右侧滚动条。
7. 自动 QA 覆盖安全区、遮挡、竖排文字、UI 占屏面积、模块溢出。

## 信息架构

### 首页

首页只承载三件事：

- 看鱼和水域状态。
- 做高频动作：投喂、收取、进化。
- 进入低频模块：孵化、图鉴、远行、目标。

### 模块

- 孵化：孵化台，而不是商品列表。
- 图鉴：收集册，而不是筛选后台。
- 远行：竖向海域地图，而不是路线表格。
- 目标：任务板和宝箱，而不是待办列表。
- 伙伴详情：鱼的个人资料页，而不是业务详情表。

### 弹层

- 投喂：食物盘。
- 进化：进化预览和确认仪式。
- 结果：短反馈，不挡住太久。

## 子任务拆解

### P0：建立 v3 基线和回归防线

#### UIV3-00 固化当前问题清单

目标：把肉眼问题转成可跟踪项，避免每轮只凭感觉讨论。

工作：

- 记录首页、孵化、远行、目标四张核心截图的问题。
- 将问题按“遮挡、溢出、工具感、文字过多、图标不清、动效不足”分类。
- 在文档中保留每轮修复前后对比。

涉及文件：

- `docs/design/ui-v3-mobile-game-optimization-plan.md`
- `docs/qa/iphone-hand-test-result.md`

验收：

- 每个问题都有截图来源和复测入口。
- 后续修改能明确对应到问题编号。

#### UIV3-01 强化布局 QA

目标：自动抓住底部遮挡、模块溢出、安全区压迫。

工作：

- 首页常驻 UI 占屏面积增加阈值检查。
- 禁止首页出现两排常驻 Dock。
- 检查 HUD、伙伴浮标、主动作、模块按钮互不遮挡。
- 检查所有 Panel 不压到 Home Indicator 区。

涉及文件：

- `godot/scripts/qa/layout_audit.gd`
- `godot/scripts/qa/touch_conflict_audit.gd`

验收：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 可在结构回退时失败。

#### UIV3-02 强化文字和滚动 QA

目标：解决“文字异常”和“只能拖滚动条”的复发风险。

工作：

- 短中文标签禁止竖排。
- 弹层和面板中间区域必须可拖动滚动。
- 滚动必须覆盖从真实按钮/卡片上起滑，而不只是从空白内容区起滑。
- iOS 真机文字必须优先保证可见，正文可在真机上使用内置字体兜底。
- 复杂按钮内部文字不得外溢或被图标挤压。

涉及文件：

- `godot/scripts/qa/text_render_audit.gd`
- `godot/scripts/qa/scroll_drag_audit.gd`
- `godot/scripts/ui/ui_style.gd`

验收：

- 孵化、图鉴、远行、目标、投喂弹层均通过拖动测试。
- 视觉截图无竖排中文。

### P1：首页水域重构

#### UIV3-10 重做首页视觉重心

目标：首页第一眼必须是水域和鱼。

工作：

- 压低 HUD 和 Dock 的视觉重量。
- 增加水面层、前景水草、泡泡和鱼影层。
- 底部素材避开主动作按钮，不再被 Dock 切掉。
- 选中鱼时使用水波、光圈或轻描边，而不是靠卡片解释。

涉及文件：

- `godot/scripts/ui/pond_stage.gd`
- `godot/scripts/pond_view.gd`
- `godot/scripts/ui/main_game.gd`
- `godot/assets/kenney_fish_pack/`

验收：

- 首页截图中水域主体面积明显大于 UI 面积。
- 选中状态不用读文字也能看出来。

#### UIV3-11 HUD 轻量化二次优化

目标：HUD 从状态栏变成游戏内轻提示。

工作：

- 只常驻等级、池塘名、主货币、收益提示。
- 次级资源进入菜单或轻展开。
- HUD 边框从强描边改为轻玻璃或分段胶囊。
- 顶部菜单图标改成更像随身包/设置入口。

涉及文件：

- `godot/scripts/ui/resource_hud.gd`
- `godot/scripts/ui/ui_components.gd`
- `godot/scripts/ui/ui_style.gd`

验收：

- 390x844 下 HUD 高度不超过 72px。
- 顶部不形成一整条厚重卡片。

#### UIV3-12 伙伴信息场景化

目标：伙伴信息不再像业务卡片。

工作：

- 常驻伙伴浮标改成鱼旁名字牌或小状态气泡。
- 详情信息点击鱼或头像后展开。
- 心情、等级、收益用图标和条形表达，减少文字。

涉及文件：

- `godot/scripts/ui/partner_float.gd`
- `godot/scripts/ui/partner_sheet.gd`
- `godot/scripts/ui/main_game.gd`

验收：

- 伙伴 UI 不遮挡鱼、不顶住主动作 Dock。
- 单手点击鱼、查看伙伴、返回水域流畅。

### P2：底部操作和模块入口重构

#### UIV3-20 主动作 Dock 游戏化

目标：投喂、收取、进化像游戏操作，不像三枚表单按钮。

工作：

- 投喂使用食碗图标和食物抛物线反馈。
- 收取使用泡泡袋/资源流入 HUD 反馈。
- 进化使用星光鱼/形态共鸣反馈。
- 根据当前状态调整强弱：可收取最强、可进化发光、不可用变轻。

涉及文件：

- `godot/scripts/ui/action_dock.gd`
- `godot/scripts/ui/fx_layer.gd`
- `godot/scripts/ui/main_game.gd`

验收：

- 不看按钮文字也能判断三个动作的大致含义。
- 同一时刻只有一个最强 CTA。

#### UIV3-21 模块入口改为“口袋菜单”

目标：模块入口不再像底部导航栏。

工作：

- 右下模块按钮改为口袋/菜单图标。
- 展开后显示四个大图标入口：孵化蛋、图鉴书、地图、任务章。
- 面板打开后入口变成“返回水域”。
- 展开层不遮挡主动作区，不吞掉滚动和面板触摸。

涉及文件：

- `godot/scripts/ui/mode_dock.gd`
- `godot/scripts/ui/ui_components.gd`
- `godot/scripts/qa/touch_conflict_audit.gd`

验收：

- 模块切换不超过 2 次点击。
- 入口图标在短标签辅助下能一眼理解。

#### UIV3-22 页面切换动效

目标：模块切换不只是面板出现，而是进入一个小游戏场景。

工作：

- 进入孵化：面板从下方浮起，蛋槽轻弹。
- 进入图鉴：页面翻开感。
- 进入远行：地图节点依次出现。
- 进入目标：任务便签盖章或弹入。

涉及文件：

- `godot/scripts/ui/panel_host.gd`
- `godot/scripts/ui/hatchery_panel.gd`
- `godot/scripts/ui/dex_panel.gd`
- `godot/scripts/ui/adventure_map.gd`
- `godot/scripts/ui/quest_board.gd`

验收：

- 切换不突兀。
- 动效结束后节点清理，不造成性能增长。

### P3：二级模块场景化

#### UIV3-30 孵化台二次重构

目标：孵化像一个可互动设施。

工作：

- 三个槽位做成稳定孵化器布局。
- 蛋状态用裂纹、亮光、进度表达。
- 鱼蛋补给从列表改成横向货架或抽屉。
- 开蛋加入震动、光效、结果卡。

涉及文件：

- `godot/scripts/ui/hatchery_panel.gd`
- `godot/scripts/ui/fx_layer.gd`
- `godot/scripts/qa/m4_flow_audit.gd`

验收：

- 一屏内能看清三槽状态。
- 货架不溢出面板边界。

#### UIV3-31 图鉴册二次重构

目标：图鉴像收集册，不像筛选页。

工作：

- 顶部显示收集进度和页签。
- 已发现鱼卡更大，未发现鱼以剪影格显示。
- 稀有度色只用于角标，不大面积铺色。
- 筛选文字减少，使用图标或短标签。

涉及文件：

- `godot/scripts/ui/dex_panel.gd`
- `godot/scripts/ui/ui_components.gd`

验收：

- 未发现/已发现差异明确。
- 卡片文字不拥挤、不外溢。

#### UIV3-32 远行地图二次重构

目标：远行不只是节点列表，而是竖向海域地图。

工作：

- 路线节点沿海流路径排布。
- 当前可出发节点更强，未解锁节点变淡。
- 奖励从文字变成资源徽章。
- 出发后有小船/泡泡路线动效。

涉及文件：

- `godot/scripts/ui/adventure_map.gd`
- `godot/scripts/ui/fx_layer.gd`

验收：

- 无竖排文字。
- 第一眼能看出是地图。
- 节点点击目标不小于 44px。

#### UIV3-33 目标任务板二次重构

目标：目标页像游戏任务板。

工作：

- 宝箱领取按钮改成奖励宝箱区域。
- 已完成任务用盖章、绿色进度、轻动效表达。
- 未完成任务降低视觉重量。
- 奖励信息尽量图标化。

涉及文件：

- `godot/scripts/ui/quest_board.gd`
- `godot/scripts/ui/ui_components.gd`

验收：

- 已完成任务一眼可见。
- 列表滚动不依赖右侧滚动条。

#### UIV3-34 投喂和进化弹层仪式感

目标：高频弹层短、清楚、有反馈。

工作：

- 投喂保留 2x2 食物盘，加入推荐食物强调。
- 食物点击后从按钮飞向鱼。
- 进化弹层突出概率、消耗、结果预览。
- 成功/失败用短动效结束，不长时间挡住主界面。

涉及文件：

- `godot/scripts/ui/food_sheet.gd`
- `godot/scripts/ui/evolution_sheet.gd`
- `godot/scripts/ui/fx_layer.gd`
- `godot/scripts/ui/main_game.gd`

验收：

- 投喂 1 次操作不需要滚动。
- 进化信息层级清晰，无大块空白。

### P4：视觉系统统一

#### UIV3-40 颜色语义系统

目标：颜色不再随页面临时使用。

规则：

- 黄色：当前选中、奖励、主确认。
- 绿色：成长、完成、可进化、成功。
- 蓝色：水域、资源、收取。
- 橙色：蛋、消耗、稀有材料。
- 紫色：稀有、神秘、远行奖励。
- 灰白：未知、不可用、次级信息。

涉及文件：

- `godot/scripts/ui/ui_style.gd`
- `godot/scripts/ui/action_dock.gd`
- `godot/scripts/ui/mode_dock.gd`
- `godot/scripts/ui/hatchery_panel.gd`
- `godot/scripts/ui/quest_board.gd`

验收：

- 同类行为颜色一致。
- 每个页面最多一个最强黄色 CTA。

#### UIV3-41 图标系统

目标：主动作、模块、资源三类图标有明显区别。

工作：

- 主动作：大形状、大面积留白、强轮廓。
- 模块：蛋、书、地图、印章四种外形差异。
- 资源：小徽章，保持轻量。
- 顶部菜单：不与模块入口混淆。

涉及文件：

- `godot/scripts/ui/ui_components.gd`
- `godot/scripts/ui/action_dock.gd`
- `godot/scripts/ui/mode_dock.gd`

验收：

- 关闭短标签时仍能大致区分入口。
- 图标不再全部像圆章。

#### UIV3-42 字体和字号层级

目标：字体贴合风格，同时正文清晰。

工作：

- 标题和按钮使用当前圆润字体。
- 正文、小数字、资源数继续使用系统中文字体，保证可读。
- 建立字号阶梯：标题、按钮、标签、数字、说明。
- 禁止小容器使用过大的 display 字体。

涉及文件：

- `godot/scripts/ui/ui_style.gd`
- `godot/scripts/qa/text_render_audit.gd`

验收：

- 中文不竖排。
- 数字不挤压图标。
- 字体可爱但不牺牲可读性。

#### UIV3-43 组件库收口

目标：不要每个页面各自画一套卡片。

工作：

- 抽象主 CTA、次 CTA、资源徽章、状态条、任务便签、地图节点。
- 统一描边等级：主 3px，容器 2px，小标签 0-1px。
- 统一按钮最小高度和安全点击区域。

涉及文件：

- `godot/scripts/ui/ui_components.gd`
- `godot/scripts/ui/ui_style.gd`

验收：

- 新增模块不需要重新发明按钮和徽章。
- 小标签不再和主按钮同样抢眼。

### P5：Godot 动效和反馈系统

#### UIV3-50 FX 层统一

目标：所有反馈走统一 FX 层，便于清理和 QA。

工作：

- 收取：资源泡泡飞入 HUD。
- 投喂：食物飞入水域。
- 进化：聚光、闪白、结果弹出。
- 孵化：蛋震动、裂光、结果卡。
- 远行：路线节点亮起。

涉及文件：

- `godot/scripts/ui/fx_layer.gd`
- `godot/scripts/ui/main_game.gd`

验收：

- 特效结束后临时节点全部释放。
- 性能 QA 无持续节点增长。

#### UIV3-51 触摸反馈统一

目标：所有可点元素都有一致触摸反馈。

工作：

- 主按钮按下缩放。
- 模块入口弹性展开。
- 鱼点击水波。
- 卡片点击只做轻反馈，避免所有元素都很弹。

涉及文件：

- `godot/scripts/ui/action_dock.gd`
- `godot/scripts/ui/mode_dock.gd`
- `godot/scripts/ui/pond_stage.gd`
- `godot/scripts/ui/ui_components.gd`

验收：

- 高频操作反馈明确。
- 滚动列表中按钮不会干扰拖动。

### P6：真机验证和交付节奏

#### UIV3-60 每轮自动验证

每轮修改必须运行：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh`
- 必要时重新生成 `godot/build/qa_snapshots/`

验收：

- QA 全绿。
- 截图没有明显遮挡、溢出、竖排、过密。

#### UIV3-61 每轮 iPhone 部署

每轮可手测版本必须运行：

- `godot/scripts/qa/ios_debug_deploy.sh`

验收：

- `com.pokefish.game` 安装成功。
- 设备 smoke 显示竖屏真实 App 图标。
- 更新 `docs/qa/iphone-hand-test-result.md`。

#### UIV3-62 手测清单更新

目标：手测不再只测“能不能点”，还要测“像不像手机游戏”。

工作：

- 增加水域主角感。
- 增加图标理解。
- 增加单手连续操作。
- 增加 3-5 分钟长时间操作疲劳度。
- 增加模块场景感。

涉及文件：

- `docs/qa/iphone-hand-test-checklist.md`
- `docs/qa/iphone-hand-test-result.md`

验收：

- 手测结果能直接指导下一轮调优。

## 推荐执行顺序

### Sprint 1：先建立回归防线

1. UIV3-01 强化布局 QA。
2. UIV3-02 强化文字和滚动 QA。
3. UIV3-40 颜色语义系统。
4. UIV3-41 图标系统第一版。

目标：先防止问题反复出现。

### Sprint 2：首页主体验

1. UIV3-10 重做首页视觉重心。
2. UIV3-11 HUD 轻量化二次优化。
3. UIV3-12 伙伴信息场景化。
4. UIV3-20 主动作 Dock 游戏化。
5. UIV3-50 FX 层统一第一版。

目标：首页从“工具覆盖在水域上”变成“在水域里玩”。

### Sprint 3：模块场景化

1. UIV3-30 孵化台二次重构。
2. UIV3-31 图鉴册二次重构。
3. UIV3-32 远行地图二次重构。
4. UIV3-33 目标任务板二次重构。
5. UIV3-34 投喂和进化弹层仪式感。

目标：每个模块有明确游戏隐喻。

### Sprint 4：动效和真机收口

1. UIV3-21 模块入口改为口袋菜单。
2. UIV3-22 页面切换动效。
3. UIV3-51 触摸反馈统一。
4. UIV3-60 每轮自动验证。
5. UIV3-61 每轮 iPhone 部署。
6. UIV3-62 手测清单更新。

目标：把视觉、交互、QA、真机手感打通。

## 完成判定

v3 完成必须同时满足：

1. 首页第一眼焦点在鱼和水域。
2. 首页常驻 UI 不形成顶部和底部双重夹击。
3. 主动作和模块入口图标无需长文字也能理解。
4. 孵化、图鉴、远行、目标都不像表单列表。
5. 投喂、收取、进化至少各有一个发生在水域里的反馈。
6. 9 张 QA 截图无竖排文字、无边界溢出、无明显遮挡。
7. `run_all_qa.sh` 通过。
8. `ios_debug_deploy.sh` 通过。
9. iPhone 手测中“内容拖拽、图标看、游戏看、单手看、长时间手感”全部达到通过或轻微需调整。

## 当前建议先做

下一步最值得先做的不是新增功能，而是这 5 件：

1. 颜色语义收口。
2. 图标系统收口。
3. 首页 UI 占屏面积 QA。
4. 收取、投喂、进化的水域内反馈。
5. 重新部署 iPhone，并让用户按 v3 清单复测。

这 5 件完成后，应用才会明显从“可爱的管理界面”往“手机游戏”靠近。

## 2026-06-06 19:44 已落地进展

本轮已完成“当前建议先做”的第一版：

1. 颜色语义已收口：`UiStyle` 增加语义色，主动作和关键模块改用语义调用。
2. 图标系统已收口第一版：模块入口改为口袋/工具包，孵化/图鉴/远行/目标分别强化为蛋、册页、地图、印章。
3. 首页 UI 占屏面积 QA 已加入：`layout_audit.gd` 增加常驻 UI 面积、底部单排、模块菜单默认收起等断言。
4. 收取、投喂、进化的水域内反馈已加入：水波、飞入 HUD、短闪光和鱼身 burst 已通过 FX 层实现。
5. 已重新部署 iPhone：`ios_debug_deploy.sh` 通过，设备 smoke PID `2999`。

仍需后续继续推进：

- Sprint 2 的首页主体验二次重构。
- Sprint 3 的模块二次场景化。
- Sprint 4 的页面切换动效和手测收口。

## 2026-06-06 19:51 已落地进展

本轮推进 Sprint 2 首页主体验第一版：

1. `UIV3-10` 已推进：水域新增自绘柔光光束、水面浮沫、远景鱼影，继续复用 Kenney 素材，不增加常驻节点。
2. `UIV3-11` 已推进：顶部 HUD 改为更轻的半透明玻璃条，描边从 2px 降为 1px，阴影移除，高度 QA 阈值收紧到 72px。
3. `UIV3-12` 已推进：伙伴浮标缩成更小的水域状态气泡，降低描边和背景重量，保留名字、等级、收益和心情条。
4. `UIV3-20` 已推进：底部主动作外层底座减少厚描边和阴影，保持按钮命中区和状态色不变。

本轮验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3036, portrait 1170x2532@3x, real app icon`。

仍需后续继续推进：

- 首页伙伴信息还可以进一步贴近鱼本体，而不是固定在左下角。
- Sprint 3 的孵化、图鉴、远行、目标二次场景化仍未完成。
- 仍需用户 iPhone 复测来确认 `游戏看`、`单手看` 和 `长时间手感` 是否真正改善。

## 2026-06-06 20:01 已落地进展

本轮推进 Sprint 3 模块场景化第一版：

1. `UIV3-30` 已推进：孵化三槽外增加孵化器框和导轨，鱼蛋补给放进货架式区域，孵化页更像设施而不是三张业务卡。
2. `UIV3-31` 已推进：图鉴鱼卡从整块强色按钮改为册页贴纸样式，稀有度变成顶部色带和角标，剪影册保持轻量。
3. `UIV3-32` 已推进：远行节点从矩形流程卡调整为更圆的目的地岛牌，路径改成海流线和浮泡，节点入场增加轻弹反馈。
4. `UIV3-33` 已推进：目标页领取按钮增加宝箱图标，任务板整体降低边框重量，可领取任务仍保持奖励黄和完成状态。
5. `UIV3-34` 已部分覆盖：投喂/进化的水域反馈已在上一轮实现，本轮保持流程稳定，未继续扩大弹层改造。

本轮验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3108, portrait 1170x2532@3x, real app icon`。

仍需后续继续推进：

- Sprint 4 的页面切换动效和触摸反馈统一还未系统完成。
- 模块场景化已有第一版，但孵化货架、图鉴翻页感、远行路线动效仍可继续打磨。
- 仍需用户 iPhone 复测确认 `内容拖拽`、`图标看`、`游戏看`、`单手看`、`长时间手感`。

## 2026-06-06 20:10 已落地进展

本轮推进 Sprint 4 动效和真机收口第一版：

1. `UIV3-21` 已推进：右下模块口袋菜单展开增加轻弹和淡入，模块入口保留口袋/水域双态。
2. `UIV3-22` 已推进：`PanelHost` 打开模块时触发内容入场；孵化槽、图鉴格、远行节点、目标便签依次出现。
3. `UIV3-51` 已推进：新增 `UiComponents.attach_press_feedback()`，统一模块入口、返回、领取、孵化、购买、进化确认等按钮的按压反馈。
4. `UIV3-60` 已完成本轮验证：完整自动 QA 通过，截图稳定，无半透明残影、竖排文字或明显溢出。
5. `UIV3-61` 已完成本轮部署：重新安装并启动到 iPhone。
6. `UIV3-62` 已更新：手测清单补充水域主角感、模块场景感、切换动效、触摸反馈、长时间手感。

本轮验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3111, portrait 1170x2532@3x, real app icon`。

仍需最终确认：

- v3 自动化、截图和 iPhone 部署均已完成第一版闭环。
- 最终完成判定第 9 条仍依赖用户在 iPhone 上复测：`内容拖拽`、`图标看`、`游戏看`、`单手看`、`长时间手感` 必须达到通过或仅轻微需调整。

## 2026-06-06 20:17 已落地进展

本轮补强最终完成前的自动化防线：

1. 新增 `godot/scripts/qa/v3_completion_audit.gd`：模拟多轮投喂、收取、进化弹层、模块菜单展开、孵化/图鉴/远行/目标切换和返回水域。
2. `v3_completion_audit.gd` 检查模块入口、HUD 菜单、返回、领取、孵化、进化确认等关键按钮是否接入统一按压反馈。
3. `v3_completion_audit.gd` 检查四个模块是否具备 `play_intro()` 入场动效，并验证面板/弹层滚动仍可从内容区拖动。
4. `v3_completion_audit.gd` 检查重复操作后 FX、BottomSheet、PanelHost 临时内容会清理，节点数量不异常增长。
5. `run_all_qa.sh` 已接入该 QA，未来每次完整验证都会覆盖这条 v3 连续操作代理链。

本轮验证：

- `godot/scripts/qa/v3_completion_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3118, portrait 1170x2532@3x, real app icon`。

仍需最终确认：

- 自动化已覆盖大部分稳定性和交互回归，但不能替代玩家肉眼判断。
- 最终完成判定第 9 条仍需用户在 iPhone 上复测 `图标看`、`游戏看`、`单手看`、`长时间手感`。

## 2026-06-06 20:36 已落地进展

本轮根据 iPhone 手测反馈做真机优先修复：

1. `UIV3-02` 已加固：`scroll_drag_audit.gd` 增加真实模块内按钮/卡片起滑检查，覆盖孵化、图鉴、远行、目标等可滚页面。
2. 文字显示修复：`UiStyle.ui_font()` 在 iOS 上让标签和按钮正文使用内置字体兜底，降低系统字体回退导致文字不显示的风险。
3. 弹窗显示修复：`FxLayer`、`UiComponents.play_staggered_entry()`、`ModeDock`、`AdventureMap` 去掉文字承载控件的初始全透明淡入，保留缩放反馈。
4. 滚动交互修复：`BottomSheet` 和 `PanelHost` 的拖拽命中区改为整块 sheet/panel；触控绑定记录子控件上的 `ScreenTouch`，再用 `ScreenDrag` 驱动所属滚动容器。
5. 面板刷新修复：模块内容入场后再次刷新滚动绑定，避免动态生成的按钮/卡片漏绑。

本轮验证：

- `godot/scripts/qa/scroll_drag_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3126, portrait 1170x2532@3x, real app icon`。

仍需最终确认：

- 需要用户在 iPhone 上复测：投喂、收取、进化、远行、目标弹窗文字是否显示。
- 需要用户在 iPhone 上复测：孵化、图鉴、目标是否能直接用手指在内容区上下滑动。

## 2026-06-06 20:50 已落地进展

本轮根据 iPhone 手测反馈继续做手机游戏化修复：

1. 顶部遮挡修复：`PondView` 根据安全区和顶部 HUD 预留鱼身半径，鱼不会再游到顶部菜单下方；`layout_audit.gd` 增加对应断言。
2. 鱼模型重做：主水域鱼从简单椭圆改为程序化角色模型，包含主体、尾鳍、背鳍、侧鳍、阴影、高光、鳃线、嘴、眼睛和更多基因花纹。
3. 鱼群清理：`GameStateController.release_fish()` 支持移除当前鱼，伙伴详情新增“送回海域”入口，并保护最后 1 条鱼不被移除。
4. 弹窗自适应：`BottomSheet` 不再把传入高度当固定值，而是按内容最小高度和最大允许高度计算；toast/result 卡片也按文本长度调整尺寸。
5. QA 补强：新增 `fish_management_audit.gd`，覆盖顶部鱼避让、放生流程、最后一条保护和短内容弹窗自适应。

本轮验证：

- `godot/scripts/qa/fish_management_audit.gd` 单独通过。
- `godot/scripts/qa/layout_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3205, portrait 1170x2532@3x, real app icon`。

仍需最终确认：

- 需要用户在 iPhone 上判断新鱼造型是否达到预期；如果仍不满意，下一轮应改为导入 Kenney 鱼类素材或绘制专门的 sprite sheet。
- 需要用户确认“送回海域”是否足够作为清理鱼群手段，还是需要图鉴批量管理。

## 2026-06-06 20:57 已落地进展

本轮针对“送回海域入口不可见”做可见性修复：

1. `PartnerSheet` 将“送回海域”从页面底部移到顶部信息区，和稀有度/收益并列，打开详情第一屏即可看到。
2. 移除底部隐藏入口，避免玩家需要滚动寻找关键管理功能。
3. 已用 `fish_management_audit.gd`、`text_render_audit.gd`、`smoke_interactions.gd` 和完整 QA 验证。

本轮验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3275, portrait 1170x2532@3x, real app icon`。

## 2026-06-06 21:06 已落地进展

本轮针对“首页伙伴入口打不开”做触摸命中修复：

1. `PartnerFloat` 增加全尺寸透明 `Button` 命中层，避免内部 `PanelContainer/HBox/Label` 子控件吞掉真机触摸。
2. `touch_conflict_audit.gd` 增加点击伙伴小卡片打开伙伴详情的真实触控路径。
3. 完整 QA 和 iPhone 部署均已通过。

本轮验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3332, portrait 1170x2532@3x, real app icon`。

## 2026-06-06 22:14 已落地进展

本轮针对最新真机反馈继续收敛手机游戏体验：

1. 投喂弹层滚动条已隐藏：`UiStyle.configure_touch_scroll()` 统一隐藏滚动条轨道/滑块，同时保留内容区手指拖拽。
2. 图鉴重做为单列收集册：鱼卡从 2 列小卡改为 1 列贴纸行，减少拥挤和误触；物种区调整为贴纸页。
3. 目标手指滚动修复：修正 `UiStyle._bind_touch_scroll()` 不可达缩进问题，目标卡片/记录区透传触摸，QA 强制覆盖目标卡片起滑。
4. 鱼画风换为 Kenney sprite：新增 `FishArt` 统一管理鱼类素材，主水域、图鉴、伙伴浮层、伙伴详情均使用同一套 PNG 鱼。
5. 真机脚本增强：`ios_debug_deploy.sh` 默认使用当前 iPhone UDID；`ios_device_smoke.sh` 兼容手机平放时的 `faceUp` 姿态读数。

本轮验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3713, portrait 1170x2532@3x, real app icon`。

## 2026-06-06 22:59 已落地进展

本轮针对新一轮 iPhone 反馈继续修正：

1. 目标页滚动重做：`QuestBoard` 新增内层 `QuestScroll`，并在 `_input()` 内直接处理目标内容区手势；`scroll_drag_audit.gd` 改为强制验证目标卡片起滑能驱动内层滚动。
2. 页面宽度修复：`HatcheryPanel`、`DexPanel`、`QuestBoard`、`AdventureMap` 的根 `VBoxContainer` 改为 full rect，避免只按最小宽度布局造成右侧空白。
3. 间距收敛：孵化/图鉴/目标统一 8px 主间距和更紧的卡片内边距，减少页面缝隙不齐。
4. 提醒降遮挡：`FxLayer.show_toast()` 和 `show_result()` 改成顶部轻量条；`UiComponents.result_card()` 改为横向单行信息，避免中心大弹窗遮挡操作。
5. 进化重复修复：进化确认按钮改名为“开始共鸣”，`MainGame._try_evolution()` 在底部弹层已打开时直接返回，避免重复打开。

本轮验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3889, portrait 1170x2532@3x, real app icon`。

## 2026-06-06 23:16 已落地进展

本轮针对最新 iPhone 手测反馈继续修正交互手感：

1. 投喂/收取反馈统一：投喂成功、收取成功和收取冷却都改用与进化一致的顶部 `result` 结果条；`MainGame._on_log_added()` 不再自动展示日志 toast，避免同一动作出现两层反馈。
2. 投喂防重复：新增 `feed_locked`，投喂弹层打开或投喂处理中时不会重复打开或重复提交，降低双弹层/双提示概率。
3. 孵化内层滚动：`HatcheryPanel` 新增 `HatcheryScroll`，并在 `_input()` 中直接处理内容区拖拽；从“开蛋”“购买”等按钮上起滑也能滚动。
4. 图鉴内层滚动：`DexPanel` 新增 `DexScroll`，从鱼卡和贴纸区起滑也能滚动。
5. 自适应可视高度：`PanelHost` 会把实际内容视口高度同步给孵化/图鉴面板，内部滚动区在大屏不留大块空白，小屏仍保留可拖拽高度。
6. QA 补强：`scroll_drag_audit.gd` 强制覆盖孵化/图鉴真实子控件起滑；`ergonomics_audit.gd` 验证投喂成功只出现一个结果条且没有重复 toast。

本轮验证：

- `scroll_drag_audit.gd`、`layout_audit.gd`、`v3_completion_audit.gd`、`ergonomics_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 4005, portrait 1170x2532@3x, real app icon`。

## 2026-06-07 08:26 已落地进展

本轮针对“进化成功后没有新鱼形态”和“图鉴分类不清晰”做体验修复：

1. 进化形态落地：`GameStateController._apply_evolution()` 现在会写入 `appearance.formId`、`formTitle`、新体色、新鳍色、形态尾型和体型变化。
2. 进化视觉表现：`FishArt.texture_for()` 优先读取 `formId`，每条进化路线都会换成不同 Kenney 鱼贴图；`FishArt.draw()` 叠加月纱、珊瑚花、深渊灯、棘冠、龙纹等路线特征。
3. 图鉴分类清晰化：图鉴筛选从 `C/R/E/L` 改为 `全部 / 普通 / 稀有 / 史诗 / 传说 / 已进化`，减少内部缩写感。
4. 鱼卡信息增强：图鉴鱼卡显示中文稀有度、`原生/1阶` 进化状态、家族和等级，让分类依据直接出现在卡片上。
5. QA 补强：新增 `evolution_visual_audit.gd`，并把进化后首页快照加入 `visual_snapshot_audit.gd` 的 `09_evolved_home.png`。

本轮验证：

- `evolution_visual_audit.gd`、`m4_flow_audit.gd`、`text_render_audit.gd`、`layout_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 4545, portrait 1170x2532@3x, real app icon`。

## 2026-06-07 08:54 已落地进展

本轮按“像素画风更容易扩展素材”的方向完成 UI 第一版重皮：

1. 全局像素主题：`UiStyle.panel_style()` 改为 0 圆角、粗描边、硬边块状阴影；按钮、面板、标签、结果条、进度条统一变成像素游戏式硬边控件。
2. 高频图标像素化：`UiComponents.resource_icon()`、`action_icon()`、`menu_icon()` 从圆形/弧线图标改为方块像素符号，首页 HUD 和底部主动作更像像素游戏操作栏。
3. 字体硬边处理：当前展示字体的导入参数关闭抗锯齿、hinting 和 subpixel positioning，先保证按钮/标题有硬边像素感；真正的像素中文字体下载因 GitHub release 传输失败暂未纳入。
4. 图鉴和首页视觉快照已更新：`01_home.png`、`06_dex.png` 显示像素边框、像素资源符号和方块鱼卡。
5. QA 补强：新增 `pixel_style_audit.gd`，验证主题不会回退到圆角软阴影，并确认 canvas texture filter 为 nearest。

本轮验证：

- `pixel_style_audit.gd`、`text_render_audit.gd`、`layout_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_debug_deploy.sh` 首次安装阶段因 iPhone 13 Pro 为 `unavailable` 失败；重新接线后已在 13:14 重新安装并启动成功，设备 smoke 输出 `installed com.pokefish.game, running PID 6297, portrait 1170x2532@3x, real app icon`。

## 2026-06-07 13:30 已落地进展

本轮把鱼类素材从“Kenney 卡通鱼”改为和像素 UI 匹配的低分辨率像素鱼：

1. 新增 `godot/assets/pixel_fish_pack/`，生成 14 张 48x32 透明 PNG，覆盖基础蓝/绿/橙/粉/红/棕/灰鱼、未知长鱼，以及 `moonveil`、`coralbloom`、`abyss`、`thorncrest`、`dragonwake` 五条进化形态。
2. `FishArt.texture_for()` 改为优先返回像素鱼贴图；基础物种、颜色兜底和进化 `formId` 都能映射到明确素材。
3. `FishArt.draw()` 改为整数像素缩放、方块阴影、方框选中态和块状发光，移除旧版圆形光圈/平滑曲线形态叠加。
4. 删除 Godot 资源目录里的旧 Kenney 鱼 PNG 和 `.import`，仅保留环境装饰；iOS 包审计新增旧鱼路径拦截。
5. 新增 `pixel_fish_sheet.gd` 生成 `godot/build/qa_snapshots/pixel_fish_sheet.png`，用于快速肉眼检查鱼素材画风一致性。

本轮验证：

- `kenney_asset_audit.gd`、`evolution_visual_audit.gd`、`pixel_style_audit.gd` 单独通过。
- `visual_snapshot_audit.gd` 通过，首页、图鉴、进化后首页快照已更新为像素鱼。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_debug_deploy.sh` 已通过导出、Xcode 构建、PCK 清洁审计和安装；自动启动失败，原因是 iPhone 锁屏，需解锁后手动打开或重跑启动烟测。

下一步建议：

- 如果当前手工像素鱼的角色感仍不够强，继续接入免费像素鱼 sprite sheet，并把每条鱼拆成 idle/swim 两帧动画。
- 图鉴可以进一步按“生态/水域/进化线”重排，让像素鱼素材成为收集目标，而不只是图标替换。

## 2026-06-07 15:11 已落地进展

本轮把投喂从“无限按钮”改成有资源约束的养成循环：

1. 饲料命名重做：`基础/发光/珊瑚/刺激` 改为 `颗粒粮/蛋白粮/增色粮/活力粮`，对应常见鱼粮类型。
2. `GameData.food_catalog()` 增加饲料价格、每包数量、库存上限、每日购买上限、饱食值和过量投喂惩罚参数。
3. `SaveStore` 增加 `foodInventory` 和 `foodPurchaseState` 存档迁移，老存档会自动获得初始库存。
4. `GameStateController.feed_selected()` 现在会消耗 1 份库存；库存不足时失败；饱食过高继续喂会降低经验收益、心情和亲密度。
5. `GameStateController.buy_food()` 新增购买逻辑，扣泡泡币/贝壳，并拦截库存满、今日次数用完和资源不足。
6. `FoodSheet` 重构为库存卡片，展示库存、价格、今日购买次数，并提供独立的投喂/购买按钮。
7. 进化共鸣沿用当前选中的饲料库存，没有库存时不再免费尝试。

本轮验证：

- `food_economy_audit.gd` 单独通过，覆盖投喂消耗、购买限制和过量投喂负面效果。
- `layout_audit.gd`、`text_render_audit.gd`、`ergonomics_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 6541, portrait 1170x2532@3x, real app icon`。

## 2026-06-07 15:28 已落地进展

本轮继续把喂养系统从“单次消耗”深化成可持续的手机养成规则：

1. 新鱼和旧存档鱼都会拥有 `lastDigestAt`、`lastFedAt`、`appetiteState` 和 `appetiteUntil`，用于记录饱腹变化。
2. 饱腹会按时间自然下降，不再只能由玩家手动喂到满或通过远行扣减。
3. 食欲状态新增 `有点饿 / 状态正好 / 正常 / 偏饱 / 吃撑了`，伙伴详情会显示当前状态标签。
4. 饱腹过高时鱼会拒绝继续进食，拒食不消耗饲料库存，并记录 `refusedFeedCount`。
5. 吃撑状态会持续一段时间，期间资源产出效率下降；理想饱腹状态会略微提升产出。
6. 进化概率现在也受食欲状态影响：状态正好略加成，饥饿或吃撑会扣分。
7. 投喂 UI 中的“饱食”统一改为“饱腹”，减少概念误导。

本轮验证：

- `food_economy_audit.gd` 单独通过，新增覆盖自然消化、食欲状态刷新、拒食不扣库存和拒食统计。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- iOS 导出、Xcode 构建和 `ios_package_audit.sh` 通过；安装阶段两次失败，设备从 `connected` 变为 `available (paired)`，CoreDevice 报 `peer is no longer reachable`，需重新接线或解锁后重跑安装。

## 2026-06-07 15:46 已落地进展

本轮按“喂养、资源获取、进化、孵化、图鉴”的顺序完成玩法系统优化：

1. 喂养系统：增加自然消化、食欲状态、拒食、吃撑持续影响；饱腹状态影响放置产出和进化概率。
2. 资源获取系统：远行从秒结算改为真实的出发、等待、领取流程；同一时间只允许一条路线进行中，路线到点后才发放奖励并记录目标进度。
3. 进化系统：进化共鸣不再调用投喂逻辑，只消耗 1 份选中鱼粮作为材料；失败会累积保底概率，成功清零；完全体阶段会拦截继续进化。
4. 孵化系统：新增普通、彩纹、深海三类鱼蛋；孵化槽从装饰变成真实状态槽，先放蛋倒计时，到点后领取新鱼。
5. 图鉴系统：新增永久 `dex` 记录，物种被送回海域后仍保持已发现；进化形态会写入图鉴记录；新物种和新形态会给小额发现奖励。

新增 QA：

- `resource_economy_audit.gd`：验证远行出发不领奖、未到点不可领取、忙碌时不能开第二条路线、到点领取才计数。
- `evolution_system_audit.gd`：验证进化消耗材料但不投喂、保底提高概率、完全体拦截、重复前缀不堆叠。
- `hatchery_system_audit.gd`：验证蛋型库存、孵化开始、未到点拦截、到点破壳、购买具体蛋型。
- `dex_system_audit.gd`：验证永久物种记录、释放后仍发现、新物种奖励、新形态奖励。

本轮验证：

- `resource_economy_audit.gd`、`evolution_system_audit.gd`、`hatchery_system_audit.gd`、`dex_system_audit.gd` 均已加入 `run_all_qa.sh`。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- 视觉快照 `05_hatchery.png`、`06_dex.png`、`07_adventure.png` 已更新，孵化槽、永久图鉴进度和远行时间标签显示正常。
- iOS 包体审计通过；当前 iPhone 13 Pro 仍显示 `available (paired)`，未恢复 `connected`，真机重装待重新接线或解锁后执行。
- 2026-06-07 15:58 重新接线后 `ios_debug_deploy.sh` 通过，已安装并启动到 iPhone 13 Pro，设备 smoke PID `6621`。

## 2026-06-07 16:09 已落地进展

本轮针对投喂页真机反馈修复显示和触摸滚动：

1. `FoodSheet` 从 2 列高卡改为单列紧凑卡，四种饲料在 390x844 视觉快照中完整显示。
2. 饲料卡信息从多枚标签改为两行紧凑文字，避免窄屏换行撑高卡片。
3. 投喂弹层目标高度从 450 调整为 560，仍避开底部主操作 Dock。
4. `FoodSheet` 新增 `content_changed` 信号，刷新卡片后让 `BottomSheet` 重新绑定触摸滚动，解决购买/刷新后新按钮起滑无效的问题。
5. `scroll_drag_audit.gd` 增加真实投喂页场景，强制从投喂/购买按钮等实际子控件起滑验证滚动。

本轮验证：

- `scroll_drag_audit.gd`、`layout_audit.gd`、`text_render_audit.gd` 单独通过。
- `visual_snapshot_audit.gd` 通过，`02_food_sheet.png` 显示完整投喂页。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_debug_deploy.sh` 通过，设备 smoke PID `6639`。
