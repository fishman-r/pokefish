# Pokefish iPhone 手持验收结果

状态：待用户复测  
测试设备：iPhone 13 Pro  
测试版本：`com.pokefish.game` Debug build  
最近自动部署：2026-06-07 16:09（Asia/Shanghai），`ios_debug_deploy.sh` 已通过，设备 smoke PID `6639`

填写方式：在手机上打开 `Pokefish`，点击顶部菜单打开 QA 面板，按下表逐项记录 `通过` / `不通过` / `需调整`。

| 项目                            | 判定  | 记录  |
| ----------------------------- | --- | --- |
| 点鱼：点击鱼能选中，空白水域不误判             | 待确认 | 通过  |
| 底部 Dock：弹层/面板打开时仍不遮挡、不吃触摸     | 待确认 | 通过  |
| 内容拖拽：弹层/面板中间区域可上下滑，不依赖右侧滚动条   | 待复测 | 不通过；23:16 已针对孵化/图鉴内层滚动再修复，待确认 |
| 返回水域：从孵化、图鉴、远行、目标返回后仍可正常操作    | 待确认 | 通过  |
| Home Indicator：底部按钮不贴边、不压手势区  | 待确认 | 通过  |
| `图标看`：主动作和模式入口能一眼理解           | 待确认 | 不通过 |
| `游戏看`：首页视觉密度、层次和趣味性像手机游戏      | 待复测 | 08:54 已改为像素风 UI，待真机确认 |
| `字体看`：正文/小字清楚且贴合风格            | 待复测 | 08:54 展示字体改为硬边导入；像素中文字体待网络可用后补 |
| `单手看`：单手握持时点鱼、收取、切模块、开关弹层自然   | 待确认 | 需调整 |
| 长时间手感：连续操作 3-5 分钟无明显误触、卡顿或别扭点 | 待确认 | 不通过 |

## 2026-06-07 08:54 已落地进展

本轮按“像素画风”方向完成第一版 UI 重皮：

- 全局 `Panel/Button/Chip/Toast/Result/ProgressBar` 改为 0 圆角、粗描边、硬边块状阴影，整体从圆润卡通卡片转为像素游戏面板。
- 资源图标、主动作图标、菜单图标改为方块像素符号，首页 HUD、底部 Dock、图鉴卡片和分类按钮均呈现像素边框。
- 项目纹理过滤保持 nearest；展示字体导入关闭抗锯齿、hinting 和 subpixel positioning，让按钮/标题更硬边。
- 新增 `pixel_style_audit.gd`，防止主题重新退回圆角软阴影。

本轮验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `visual_snapshot_audit.gd` 已生成像素风首页和图鉴快照。
- `ios_debug_deploy.sh` 首次安装阶段因 iPhone 13 Pro 为 `unavailable` 失败；重新接线后已在 13:14 重新安装并启动成功，设备 smoke 输出 `installed com.pokefish.game, running PID 6297, portrait 1170x2532@3x, real app icon`。

## 2026-06-07 08:26 已落地进展

本轮针对最新 iPhone 反馈完成两项修复：

- 进化新形态：进化成功现在会写入 `formId/formTitle`，并让 `FishArt` 按进化路线切换贴图和叠加形态特征。主水域、伙伴浮层、伙伴详情和图鉴都会看到新形态，不再只是改名字和稀有度。
- 图鉴分类：图鉴筛选从 `C/R/E/L` 改为中文分类：`全部 / 普通 / 稀有 / 史诗 / 传说 / 已进化`；鱼卡也新增中文稀有度和 `原生/1阶` 标签，分类依据更直观。

本轮自动验证：

- 新增 `evolution_visual_audit.gd`，验证每条进化路线都会产生不同贴图、写入形态 ID、提升进化阶段并记录历史。
- `m4_flow_audit.gd` 已验证图鉴存在中文稀有度筛选和已进化分类。
- `visual_snapshot_audit.gd` 新增 `09_evolved_home.png`，用于肉眼检查进化后首页新形态。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 4545, portrait 1170x2532@3x, real app icon`。

## 2026-06-06 23:16 已落地进展

本轮针对最新 iPhone 反馈完成四项修复：

- 投喂/收取反馈：投喂成功、收取成功和收取冷却统一改为与进化一致的 `result` 顶部结果条；控制器日志不再自动冒泡成视觉 toast，避免“日志 toast + 动作提示”双重弹出。
- 投喂防重复：新增 `feed_locked`，投喂底部弹层已打开或投喂处理中时不会重复打开/重复提交。
- 孵化手指滚动：孵化页新增内层 `HatcheryScroll`，从“开蛋/购买”等按钮或卡片区域直接起滑也会滚动。
- 图鉴手指滚动：图鉴页新增内层 `DexScroll`，从鱼卡/贴纸区域直接起滑也会滚动；同时让孵化/图鉴内部滚动高度按 `PanelHost` 可视区域自适应，消除大块底部空白。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `scroll_drag_audit.gd` 已强制验证孵化/图鉴从真实按钮、鱼卡上起滑能滚动。
- `ergonomics_audit.gd` 已验证投喂成功只出现一个结果条且没有重复 toast。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 4005, portrait 1170x2532@3x, real app icon`。

## 2026-06-06 22:59 已落地进展

本轮针对最新 iPhone 反馈完成四项修复：

- 目标页滚动：目标页新增独立 `QuestScroll`，固定为内容区内层滚动，不再依赖外层面板；自动 QA 已覆盖从目标卡片上直接手指起滑。
- 孵化/图鉴/目标布局：修复三个页面根容器没有铺满父控件的问题，并统一 8px 内容缝隙，消除右侧大块留白和不齐缝隙。
- 提醒遮挡：`toast` 和 `result` 从中心大卡改成顶部轻量条，文案单行省略，新增人体工学 QA 防止重新变成遮挡弹窗。
- 进化重复：进化弹层按钮改为“开始共鸣”，并阻止进化弹层已打开时再次点击底部进化导致重复打开。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3889, portrait 1170x2532@3x, real app icon`。

## 2026-06-06 22:14 已落地进展

本轮针对最新 iPhone 反馈完成四项修复：

- 投喂滚动条：`BottomSheet`/`PanelHost` 统一隐藏 `ScrollContainer` 系统滚动条，保留手指拖动；投喂卡片高度同步压缩，避免短内容出现突兀滚动条。
- 图鉴 UI：图鉴从拥挤两列卡片改为单列“鱼贴纸”收集册，左侧大鱼图标、中间名称/物种/等级、下方稀有度和产出；物种区改为贴纸页。
- 目标滚动：修复 `UiStyle._bind_touch_scroll()` 缩进导致子控件触摸绑定不可达的问题；目标卡片、记录面板改为手势透传，并补充目标面板卡片起滑 QA。
- 鱼画风：主水域、图鉴、伙伴浮层和伙伴详情统一改用 Kenney 鱼类 PNG 素材，替代原来的程序几何鱼。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，设备 smoke 输出 `installed com.pokefish.game, running PID 3713, portrait 1170x2532@3x, real app icon`。

## 2026-06-06 18:42 修复版

针对首轮手测记录，已做以下修复并重新安装到 iPhone：

- 内容拖拽：`BottomSheet` 和 `PanelHost` 增加原始触摸输入兜底，按“手势起点在内容区内”持续驱动滚动；从按钮/卡片上起滑也能滚动，不再依赖最右侧滚动条。
- 内容拖拽：关闭移动端滚动容器的焦点跟随，并禁用统一按钮焦点，避免按住按钮起滑时被焦点系统把滚动位置拉回顶部。
- 图标识别：底部模式入口改为 5 个入口都常驻两字短标签，不再只有当前模式显示文字；主动作图标加大，并强化投喂碗、收取下箭头、进化上箭头的图形含义。
- 单手手感：主动作按钮和模式按钮命中高度加大，底部 Dock 重新排布；伙伴浮标上移，避免与主动作区贴得太近。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`。

## 2026-06-06 19:09 v2 首轮优化版

针对 `ui-v2-optimization-task-plan.md` 已完成第一轮落地并重新安装到 iPhone：

- 首页：顶部 HUD 压缩为轻量单行；底部从双 Dock 改成单排主动作 + 右下模块按钮。
- 模块入口：点击右下“模块”展开孵化、图鉴、远行、目标；面板打开时右下按钮变为“水域”用于返回。
- 伙伴：伙伴浮标由大卡片缩成轻量状态牌。
- 水域：选中鱼增加自绘水波反馈。
- 远行：修复竖排文字、路线卡贴边裁切、等级小数显示问题。
- QA：文字 QA 增加短文本竖排检查；触控 QA 增加模块菜单真实点击路径。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`。

## 2026-06-06 19:20 v2 第二轮优化版

继续按 `ui-v2-optimization-task-plan.md` 推进并重新安装到 iPhone：

- 主动作：投喂、收取、进化会按当前状态动态调整强弱。
- 孵化：改为三槽孵化台 + 鱼蛋补给货架。
- 图鉴：鱼卡和剪影区放进册页式区域。
- 投喂：改为 2x2 食物选择盘，减少长列表感。
- 进化：增加鱼预览和形态共鸣光圈。
- 目标：加入宝箱领取和任务板外框。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`。

## 2026-06-06 19:27 v2 第三轮优化版

继续按 `ui-v2-optimization-task-plan.md` 推进并重新安装到 iPhone：

- 远行：从路线列表改为小地图节点，奖励徽章收进节点内部。
- 视觉层级：小标签、资源徽章、稀有度徽章描边降为 1px，降低卡片内噪声。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`。

## 2026-06-06 19:44 v2 第四轮收口版

继续按 `ui-v2-optimization-task-plan.md` 和 `ui-v3-mobile-game-optimization-plan.md` 的重叠高优先级项推进，并重新安装到 iPhone：

- 颜色：新增语义色体系，主动作从“多处黄色”收口为投喂橙、收取蓝、进化绿、奖励/确认黄。
- 图标：右下模块入口改成口袋/工具包；孵化、图鉴、远行、目标图标强化为蛋、册页、地图、印章。
- 动效：收取从鱼附近飞入 HUD，投喂落点出现水波，进化加入短闪光和鱼身水波。
- QA：布局检查新增模块菜单默认收起、底部单排、首页 UI 占屏面积、面板不压底部动作区。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `2999`。

## 2026-06-06 19:51 v3 首页主体验第一版

继续按 `ui-v3-mobile-game-optimization-plan.md` 的 Sprint 2 推进，并重新安装到 iPhone：

- 水域：新增柔光光束、水面浮沫、远景鱼影，让首页更像活的水域。
- HUD：顶部状态条改得更轻，高度 QA 阈值收紧到 72px。
- 伙伴：伙伴浮标缩成更小的水域状态气泡，降低背景和描边重量。
- 底部：主动作底座减少厚描边和阴影，保留投喂/收取/进化的大按钮命中区。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `3036`。

## 2026-06-06 20:01 v3 模块场景化第一版

继续按 `ui-v3-mobile-game-optimization-plan.md` 的 Sprint 3 推进，并重新安装到 iPhone：

- 孵化：三槽外增加孵化器框和导轨，鱼蛋补给放进货架区域。
- 图鉴：鱼卡改成册页贴纸样式，稀有度用顶部色带和角标表达。
- 远行：路线节点变成更圆的目的地岛牌，路径改成海流线和浮泡。
- 目标：领取区域加入宝箱图标，任务板降低边框重量。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `3108`。

## 2026-06-06 20:10 v3 动效和真机收口第一版

继续按 `ui-v3-mobile-game-optimization-plan.md` 的 Sprint 4 推进，并重新安装到 iPhone：

- 模块入口：右下口袋菜单展开增加轻弹和淡入。
- 页面切换：孵化槽、图鉴格、远行节点、目标便签打开时依次出现。
- 触摸反馈：模块入口、返回、领取、孵化、购买、进化确认按钮统一按压反馈。
- 手测清单：补充水域主角感、模块场景感、切换动效、触摸反馈和长时间手感。

本轮自动验证：

- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `3111`。

## 2026-06-06 20:17 v3 完成度代理 QA 版

继续按 `ui-v3-mobile-game-optimization-plan.md` 的最终完成判定补自动化防线，并重新安装到 iPhone：

- 新增 `v3_completion_audit.gd`，模拟多轮投喂、收取、进化弹层、模块切换、返回水域和内容拖拽。
- 检查关键按钮的统一按压反馈，检查四个模块具备入场动效。
- 检查重复操作后 FX、弹层、面板临时内容清理，节点数量不异常增长。
- `run_all_qa.sh` 已接入该检查。

本轮自动验证：

- `godot/scripts/qa/v3_completion_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `3118`。

## 2026-06-06 20:36 iPhone 文字和滚动修复版

针对本轮 iPhone 手测反馈，已修复并重新安装到 iPhone：

- 弹窗文字：投喂、收取、进化、远行、目标等反馈卡和面板不再从全透明开始入场，避免真机上 tween/透明度异常导致文字不可见。
- 弹窗文字：iOS 真机上的 `UiStyle.label()` 和按钮正文改用内置圆润字体兜底，不再依赖系统字体回退渲染正文。
- 内容拖拽：`BottomSheet` 和 `PanelHost` 的拖拽命中区扩大为整块 sheet/panel，不只依赖 `ScrollContainer` 自身区域。
- 内容拖拽：子控件上的 `ScreenTouch`/`ScreenDrag` 会绑定到所属滚动容器；孵化、图鉴、目标等页面可从实际按钮/卡片上起滑。
- QA：`scroll_drag_audit.gd` 增加“真实模块内按钮/卡片起滑”的断言，覆盖这次真机问题。

本轮自动验证：

- `godot/scripts/qa/scroll_drag_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `3126`。

待用户复测重点：

- 投喂、收取、进化、远行、目标的弹窗/结果卡文字是否都能显示。
- 孵化、图鉴、目标能否直接用手指在内容区上下滑动，不再只能拖最右侧滚动条。

## 2026-06-06 20:50 水域和鱼管理修复版

针对本轮 iPhone 手测反馈，已修复并重新安装到 iPhone：

- 顶部遮挡：鱼的游动中心线避开顶部 HUD，`layout_audit.gd` 增加鱼身不得进入顶部菜单区域的断言。
- 鱼模型：重画主水域鱼模型，增加更大的主体、尾鳍类型、背鳍、侧鳍、高光、鳃线、嘴和更多基因花纹表现。
- 鱼太多：伙伴详情新增“送回海域”按钮，可移除当前鱼；控制器会阻止删到最后 1 条，并自动切换选中鱼。
- 弹窗自适应：`BottomSheet` 改为按内容最小高度计算实际高度，小内容不会再硬撑成大弹窗；结果卡和 toast 也按文字长度自适应宽高。
- QA：新增 `fish_management_audit.gd`，覆盖顶部鱼避让、放生流程、最后一条保护、短内容弹窗自适应。

本轮自动验证：

- `godot/scripts/qa/fish_management_audit.gd` 单独通过。
- `godot/scripts/qa/layout_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `3205`。

待用户复测重点：

- 顶部区域的鱼是否不再被菜单挡住。
- 新鱼造型是否比上一版更像游戏角色。
- 伙伴详情里的“送回海域”是否能满足清理鱼群的需求。
- 投喂、进化、伙伴详情等弹窗高度是否更贴合内容。

## 2026-06-06 20:57 送回海域入口可见性修复版

针对“送回海域功能没看到”的反馈，已修复并重新安装到 iPhone：

- “送回海域”从伙伴详情底部移到顶部信息区，位于稀有度和收益旁边，打开伙伴详情第一屏即可看到。
- 保留原有保护逻辑：至少保留 1 条鱼，送回后自动选中下一条鱼。

本轮自动验证：

- `godot/scripts/qa/fish_management_audit.gd` 通过。
- `godot/scripts/qa/text_render_audit.gd` 通过。
- `godot/scripts/qa/smoke_interactions.gd` 通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `3275`。

待用户复测重点：

- 打开伙伴详情后，顶部是否能直接看到“送回海域”。

## 2026-06-06 21:06 伙伴卡片入口修复版

针对“第 1 个入口打不开”的反馈，已修复并重新安装到 iPhone：

- 首页左下伙伴小卡片新增全尺寸透明命中按钮，点卡片任意位置都会打开伙伴详情。
- `touch_conflict_audit.gd` 增加真实点击伙伴小卡片后必须打开伙伴详情的断言，防止入口再次失效。

本轮自动验证：

- `godot/scripts/qa/touch_conflict_audit.gd` 通过。
- `godot/scripts/qa/smoke_interactions.gd` 通过。
- `godot/scripts/qa/text_render_audit.gd` 通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `godot/scripts/qa/ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `3332`。

待用户复测重点：

- 点首页左下伙伴小卡片任意位置，是否能打开伙伴详情。

## 2026-06-07 13:30 像素鱼素材替换版

针对“鱼要换成像素风格的素材”，已完成并安装到 iPhone：

- 鱼类主素材已从 Kenney 旧鱼 PNG 切换为本地生成的 `pixel_fish_pack`，包含基础鱼、未知鱼和 5 条进化路线专属像素形态。
- `FishArt` 统一使用像素鱼贴图；主水域、图鉴、伙伴浮层、伙伴详情、进化预览都会走同一套像素素材。
- 鱼的阴影、选中框、发光效果改成方块像素风，去掉旧版圆滑形态叠加层，避免“UI 像素但鱼还是软边”的割裂感。
- 项目资源目录删除旧 Kenney 鱼 PNG，仅保留 Kenney 的水草、气泡、沙地等环境装饰；iOS PCK 审计已确认旧鱼路径不再进入安装包。
- 新增像素鱼预览图：`godot/build/qa_snapshots/pixel_fish_sheet.png`。

本轮自动验证：

- `kenney_asset_audit.gd` 通过，覆盖像素鱼资源尺寸、导入元数据、`FishArt.has_assets()` 和导出过滤。
- `evolution_visual_audit.gd` 通过，确认进化后会切换到不同鱼形态贴图。
- `pixel_style_audit.gd` 通过，确认像素 UI 风格未回退。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_debug_deploy.sh` 已完成导出、Xcode 构建、iOS 包审计和安装；自动启动失败，原因是 iPhone 锁屏，系统拒绝启动 `com.pokefish.game`。

待用户复测重点：

- 解锁 iPhone 后打开 Pokefish，确认首页、图鉴、伙伴详情、进化后的鱼都已经是像素画风。
- 观察新像素鱼是否比上一版更符合目标风格；如果仍不满意，下一步应改为接入外部免费像素鱼 sprite sheet 或继续手工扩展更精细的鱼类套图。

## 2026-06-07 14:55 鱼外框隐藏版

针对“鱼的外围有方框不好看”，已修复并重新安装到 iPhone：

- 移除 `FishArt.draw()` 中鱼选中态的外部方框。
- 同步关闭鱼外部块状发光框，只保留鱼自身像素描边和底部小阴影。
- 首页、进化后首页、伙伴详情快照均确认鱼外围不再出现方框。

本轮自动验证：

- `visual_snapshot_audit.gd` 通过。
- `evolution_visual_audit.gd` 通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `6529`。

待用户复测重点：

- 首页水域中被选中的鱼是否不再出现黄色/白色外框。
- 进化后或稀有鱼是否也没有额外方框感。

## 2026-06-07 15:11 饲料经济和过量投喂版

针对“饲料名字不通俗、投喂需要消耗、不能无限购买、鱼不能无限喂养”，已修复并重新安装到 iPhone：

- 饲料分类改为更常见的鱼粮表达：`颗粒粮`、`蛋白粮`、`增色粮`、`活力粮`。
- 投喂弹层改成库存卡片，显示库存、成长/饱食效果、价格和今日购买次数。
- 每次投喂会消耗 1 份对应饲料；库存为 0 时无法投喂。
- 购买饲料会消耗泡泡币/贝壳，并受库存上限和每日购买次数限制。
- 过量投喂会触发负面效果：经验收益降低、心情下降、亲密度下降，并记录 `overfeedCount`。
- 进化共鸣也会消耗当前选中的鱼粮；没有库存时会提示先购买。

本轮自动验证：

- 新增 `food_economy_audit.gd`，覆盖投喂扣库存、无库存失败、购买扣资源、库存上限、每日上限和过量投喂惩罚。
- `layout_audit.gd`、`text_render_audit.gd`、`ergonomics_audit.gd` 单独通过。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `6541`。

待用户复测重点：

- 投喂弹层上的饲料名称是否更容易理解。
- 投喂后对应库存是否减少。
- 购买按钮在库存满、今日次数用完、资源不足时是否符合预期。
- 连续喂到很饱后，是否能看到“吃太饱了”的负面反馈。

## 2026-06-07 15:28 喂养状态深化版

针对喂养系统“缺少长期状态、过量反馈偏浅”的问题，已完成代码和自动验证：

- 饱腹会按时间自然消化，不再永久停在上次投喂后的数值。
- 伙伴详情新增食欲状态标签：`有点饿`、`状态正好`、`正常`、`偏饱`、`吃撑了`。
- 鱼太饱时会拒绝投喂，提示“已经吃不下了”，并且不会扣对应饲料库存。
- 吃撑状态会持续一段时间，降低资源产出；理想饱腹会略微提升资源产出。
- 进化概率会受到食欲状态影响，状态正好略加成，饥饿或吃撑会降低概率。
- UI 文案将“饱食”统一调整为“饱腹”。

本轮自动验证：

- `food_economy_audit.gd` 通过，覆盖自然消化、状态刷新、吃撑、拒食、拒食不扣库存。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- iOS 导出、Xcode 构建和包体审计通过；真机安装阶段失败，原因是设备连接从 `connected` 变为 `available (paired)`，CoreDevice 报 `peer is no longer reachable`。

待用户复测重点：

- 重新接线/解锁后安装新版，确认伙伴详情中能看到食欲状态标签。
- 把鱼喂到接近满后继续投喂，确认会出现“已经吃不下了”，并且库存不减少。
- 放置一段时间后再打开，确认饱腹数值会下降。

## 2026-06-07 15:46 五系统玩法优化版

已按顺序完成喂养、资源获取、进化、孵化、图鉴五个系统的玩法逻辑优化：

- 喂养：饱腹自然消化，食欲状态进入伙伴详情；拒食不扣库存，吃撑会持续影响产出和进化。
- 资源获取：远行不再秒结算，改为出发、等待、到点领取；忙碌时不能开启第二条路线。
- 进化：共鸣只消耗鱼粮材料，不再偷偷投喂；失败增加保底概率，成功清零；完全体阶段会拦截。
- 孵化：普通、彩纹、深海鱼蛋分库存；孵化槽变为真实倒计时槽，到点后领取新鱼。
- 图鉴：新增永久发现记录；鱼送回海域后物种仍点亮，进化形态会单独记录，新发现有少量奖励。

本轮自动验证：

- 新增并通过：`resource_economy_audit.gd`、`evolution_system_audit.gd`、`hatchery_system_audit.gd`、`dex_system_audit.gd`。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_package_audit.sh` 通过，iOS 包仍是 iPhone-only、竖屏、PCK 干净。
- 当前真机未重装成功：iPhone 13 Pro 状态为 `available (paired)`，不是可安装的 `connected`，CoreDevice 无法建立连接。
- 2026-06-07 15:58 重新接线后已安装并启动成功，设备 smoke 输出 `installed com.pokefish.game, running PID 6621, portrait 1170x2532@3x, real app icon`。

待用户复测重点：

- 重新接线/解锁后安装新版。
- 远行：第一次点路线应显示“出发”，等待到点后再点同一路线领取奖励。
- 孵化：第一次点“开蛋”应进入槽位倒计时，到点后按钮变为领取。
- 图鉴：送回某个物种后，图鉴物种贴纸仍应保持已发现。

## 2026-06-07 16:09 投喂页显示和手指滚动修复版

针对“投喂页面显示不全、手指滑动有问题”，已修复并重新安装到 iPhone：

- 投喂页从 2 列高卡改成单列紧凑卡，四种饲料在 390x844 竖屏快照中都能完整显示。
- 库存、饱腹、价格、今日次数从多枚标签改为两行紧凑信息，避免窄屏自动换行把卡片撑高。
- 投喂弹层高度从 450 调整为 560，并仍保留底部 Dock 可见。
- `FoodSheet.refresh()` 后会触发 `BottomSheet` 重新绑定触摸滚动，解决购买/刷新后新按钮无法起滑滚动的问题。
- `scroll_drag_audit.gd` 增加真实投喂页测试，从投喂/购买按钮等真实子控件起滑也能滚动。

本轮自动验证：

- `scroll_drag_audit.gd`、`layout_audit.gd`、`text_render_audit.gd` 单独通过。
- `visual_snapshot_audit.gd` 通过，`02_food_sheet.png` 已确认四种饲料完整显示。
- `POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh` 通过。
- `ios_debug_deploy.sh` 通过，已安装并启动 `com.pokefish.game`，设备 smoke PID `6639`。

## 完成判定

- 全部项目为 `通过`：可将当前目标标记为完成。
- 任一项目为 `不通过` 或 `需调整`：记录具体位置和原因，继续下一轮调优。
