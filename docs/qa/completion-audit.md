# Pokefish 任务完成度审计

更新时间：2026-06-06 18:42（Asia/Shanghai）

目的：把“按照任务计划完成开发”的范围拆成可证明项，避免把自动化通过和手持主观满意度混在一起。

## 结论

- 自动化和工程侧已完成：Godot App-only、iPhone 竖屏、旧 Web/Capacitor 清理、iOS 导出/构建/安装/启动、包体干净、App 图标、启动图、核心 UI 流程、文字异常防回归、遮挡/滚动/触控冲突防回归、Kenney 素材边界、QA 总入口。
- 仍需用户手持确认：真实触控手感、图标识别、游戏感/视觉密度、字体观感、单手可达。这些已经在 App 内 DebugLayer 和 `iphone-hand-test-checklist.md` 中暴露为人工判读项，但不能由自动脚本替用户判定满意。2026-06-06 18:42 已根据首轮手测“不通过/需调整”记录完成一轮修复并重新部署到 iPhone，等待复测。

## 证据索引

- 主工程入口：`project.godot` -> `res://godot/scenes/ui/main_game.tscn`
- iOS 导出配置：`export_presets.cfg`
- 统一 QA 入口：`godot/scripts/qa/run_all_qa.sh`
- 一键真机部署：`godot/scripts/qa/ios_debug_deploy.sh`
- iOS 包审计：`godot/scripts/qa/ios_package_audit.sh`
- 真机 smoke：`godot/scripts/qa/ios_device_smoke.sh`
- 手持验收：`docs/qa/iphone-hand-test-checklist.md`
- 手持验收结果：`docs/qa/iphone-hand-test-result.md`
- 任务计划：`docs/design/godot-native-task-breakdown.md`
- 最近真机证据：`godot/build/ios/device/processes.json`、`godot/build/ios/device/displays.json`

## 要求逐项审计

| 要求 | 状态 | 当前证据 | 备注 |
|---|---|---|---|
| 只做 App，Web 版代码不保留 | 已证明 | `rg --files` 未发现 `package.json`、`index.html`、`src/app.js`、`styles.css`、`capacitor.config.json`、旧 `ios/App`；Git 状态显示这些旧文件为删除 | 文档中的 Web/Capacitor 字样仅为“已移除/禁止打包”说明和包体黑名单 |
| 使用 Godot 重写 | 已证明 | `project.godot` 主场景为 `res://godot/scenes/ui/main_game.tscn`；`godot/scenes/ui/`、`godot/scripts/ui/` 为当前实现 | README 和 iOS 文档已改为 Godot-only |
| iPhone 竖屏 App | 已证明 | `project.godot` 设置 390x844、orientation=portrait；`export_presets.cfg` targeted device family 为 iPhone；`ios_package_audit.sh` 验证 iPhone-only/portrait-only | 真机 display JSON 为 1170x2532@3x portrait |
| 能在用户 iPhone 上测试 | 已证明 | `ios_device_smoke.sh` 输出 `installed com.pokefish.game, running PID 2575, portrait 1170x2532@3x, real app icon` | Bundle ID 为 `com.pokefish.game` |
| 解决显示文字异常 | 已证明到自动化范围 | `text_render_audit.gd` 覆盖字体分层、按钮/短文本宽度、无替换字形；`visual_snapshot_audit.gd` 生成 9 张快照 | 字体“好不好看”仍需手持主观确认 |
| 参考宝可梦式设计语言重做 UI | 已实现，主观满意待确认 | 首页、HUD、伙伴浮标、Dock、弹层、二级面板均为 Godot-native 游戏 UI；ActionDock/ModeDock 图标化；首轮反馈后 ModeDock 改为常驻短标签，ActionDock 图标强化语义；App 图标和启动图已定制 | “像不像手机游戏、是否满意”不能由脚本证明 |
| 减少生硬文字元素 | 已证明到自动化范围 | ActionDock/ModeDock 自绘图标 + 短标签；ResourceHud 收益图标化；`text_render_audit.gd` 防止退回 `+/分` 等文字 | 用户仍可要求进一步压缩文案 |
| 更换并匹配字体风格 | 已实现，观感待确认 | 展示字体为项目内 ZCOOL；正文/小字使用 iOS 系统字体 fallback；`STHeiti` 已移除；包体审计扫描 `STHeiti` | `字体看` 保留为人工判读 |
| 不同模块之间不遮挡 | 已证明到自动化范围 | `layout_audit.gd`、`ergonomics_audit.gd`、`touch_conflict_audit.gd` 验证 HUD/浮标/Dock/Sheet/Panel 不越界、不挡 Dock | 手持仍需确认是否有“感觉上碍手”的情况 |
| 上下滑动不只能拖最右侧滚动条 | 已证明 | `scroll_drag_audit.gd` 使用真实 `InputEventScreenDrag` 从内容区中心和按钮控件上起滑拖动 BottomSheet/PanelHost/实际面板 | 已接入 `UiStyle.configure_touch_scroll` 和原始触摸输入兜底 |
| 伙伴水域 UI 溢出边界 | 已证明到自动化范围 | `layout_audit.gd` 检查伙伴浮标和关键控件在 375x667、390x844、430x932 视口内；视觉快照覆盖首页和伙伴弹层 | 真机肉眼仍可提出微调 |
| 使用鱼类素材包并选择性使用 | 已证明 | `kenney_asset_audit.gd` 验证精选 Kenney 环境素材可加载、尺寸正确、PondStage 接入；`resource_packages/` 被 `.gdignore` 和 iOS exclude_filter 排除 | 静态鱼图未使用，理由是当前鱼由基因程序绘制 |
| App 图标和启动图 | 已证明 | `ios_package_audit.sh` 验证 App 图标源/包内图标无 alpha，启动图 800x600 RGB/no-alpha；真机 appIcon 非占位 | 启动图已经替换成 Pokefish 图 |
| 自动 QA 总入口 | 已证明 | `run_all_qa.sh` 最近输出 `Pokefish QA passed` | 串联 Godot QA、视觉快照、包体审计、真机 smoke |
| 一键部署到 iPhone | 已证明 | `ios_debug_deploy.sh` 已跑通并输出 `Pokefish iPhone deploy passed` | 可设置 `POKEFISH_RUN_FULL_QA=1` 在部署后追加完整 QA |

## 最近通过的命令

```text
godot/scripts/qa/ios_package_audit.sh
-> iOS package QA passed: iPhone-only, portrait-only, clean PCK, valid app icon, valid launch splash

godot/scripts/qa/ios_device_smoke.sh
-> iOS device QA passed: installed com.pokefish.game, running PID 2575, portrait 1170x2532@3x, real app icon

godot/scripts/qa/ios_debug_deploy.sh
-> Pokefish iPhone deploy passed

POKEFISH_SKIP_DEVICE_QA=1 godot/scripts/qa/run_all_qa.sh
-> Pokefish QA passed
```

## 未完成闭环

这些项目无法被当前机器直接证明，需要用户拿 iPhone 判断；首轮反馈中的内容拖拽、图标识别、单手和长时间手感问题已完成一轮修复，以下项目等待复测：

1. `图标看`：主动作和模式入口的图标含义是否一眼能懂。
2. `游戏看`：首页是否已经像手机游戏，而不是网页或后台工具。
3. `字体看`：正文/小字是否贴合风格，是否仍显得太普通。
4. `单手看`：单手握持时点鱼、收取、切模块、打开/关闭弹层是否自然。
5. 真实触控手感：自动化已证明无明显遮挡/滚动死角，但用户仍需确认长时间操作是否顺手。

## 完成判定

在用户手持确认上面的人工项通过之前，目标不应标记为完成。手持结果记录到 `docs/qa/iphone-hand-test-result.md`；若所有项目均为 `通过`，则当前证据足以支持将 Godot iOS App 重构任务标记为完成。
