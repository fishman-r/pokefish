# Godot iOS 真机测试

本项目只保留 Godot App 版本，旧 Web/Capacitor 工程不再维护。

## 环境

- macOS
- Xcode
- Godot 4.6.3 或更新版本
- Godot iOS export template
- Apple ID 或 Apple Developer Team

## 打开项目

1. 打开 Godot。
2. 选择 `Import`。
3. 选择仓库根目录里的 `project.godot`。
4. 主场景为：

```text
res://godot/scenes/ui/main_game.tscn
```

## 命令行导出和安装

```bash
/Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/ios_debug_deploy.sh
```

最近一次验证：2026-06-06 18:21（Asia/Shanghai），`ios_debug_deploy.sh` 已完成 Godot 导入/导出、Xcode Debug 构建、包体审计、安装、启动和真机 smoke，输出为 `Pokefish iPhone deploy passed`。Debug 构建已安装并启动到已连接 iPhone，Bundle ID 为 `com.pokefish.game`；设备显示为 1170x2532、3x、portrait，`Pokefish` 进程 PID 为 2299。导出包已通过 `ios_package_audit.sh`：iPhone-only、portrait-only、PCK 内无旧 Web/Capacitor、旧 Godot 原型入口、原始素材包或 QA 脚本路径，App 图标源为 1024x1024 RGB/no-alpha，实际 App 包图标无 alpha，启动图 `splash@2x/@3x` 为自定义 Pokefish 图且均为 800x600 RGB/no-alpha；`.godot` 路径仅允许 Godot 生成的 imported/exported 运行资源和必要 metadata。真机设备侧已通过 `ios_device_smoke.sh`：`installed com.pokefish.game, running PID 2299, portrait 1170x2532@3x, real app icon`。顶部 QA 面板已显示语义事件计数，可区分点鱼、主动作、弹层、面板和模式切换；弹层/面板遮罩已限制在底部 Dock 以上；图标识别、游戏感、字体观感和单手可达均保留为真机手动确认项。

## QA 运行

`godot/scripts/qa/` 已用 `.gdignore` 从 App 资源扫描中隔离，测试脚本请用文件系统路径运行：

```bash
/Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/run_all_qa.sh
```

手持体验按 `/Users/rpy/Documents/Claude/pokefish/docs/qa/iphone-hand-test-checklist.md` 做最终人工确认，结果记录到 `/Users/rpy/Documents/Claude/pokefish/docs/qa/iphone-hand-test-result.md`；完成度证据见 `/Users/rpy/Documents/Claude/pokefish/docs/qa/completion-audit.md`。

第一次安装后，如果手机提示不受信任，去：

```text
设置 > 通用 > VPN与设备管理
```

信任你的开发者证书。
