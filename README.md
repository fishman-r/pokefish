# Pokefish

中文 | [English](#english)

## 中文

Pokefish 是一款使用 Godot 开发的竖屏手机养成游戏。项目已移除旧 Web 和 Capacitor 版本，当前只保留 Godot App 工程，目标是优先支持 iPhone 真机测试，并保留后续扩展到 Android 的空间。

当前版本采用像素风鱼类素材和移动端优先 UI，核心玩法包括伙伴鱼养成、投喂、资源收取、孵化、进化、图鉴、远行和目标任务。

### 打开项目

使用 Godot 4.6.3 或更新版本打开仓库根目录：

```text
project.godot
```

主场景：

```text
res://godot/scenes/ui/main_game.tscn
```

本地默认工程路径：

```text
/Users/rpy/Documents/github/pokefish
```

### 运行和调试

在 Godot 中点击 Run 即可启动主场景。项目配置为手机竖屏尺寸：

```text
390 x 844
```

触摸输入配置已开启鼠标模拟，方便在桌面调试手机交互：

```text
pointing/emulate_mouse_from_touch=true
pointing/emulate_touch_from_mouse=true
```

### iPhone 真机测试

需要先安装：

- macOS
- Xcode
- Godot 4.6.3 或更新版本
- Godot iOS export template
- Apple ID 或 Apple Developer Team

执行调试导出和安装：

```bash
./godot/scripts/qa/ios_debug_deploy.sh
```

iOS 导出说明见：

```text
godot/IOS_EXPORT.md
```

### QA

QA 脚本位于：

```text
godot/scripts/qa/
```

该目录带有 `.gdignore`，不会作为运行时 App 资源被 Godot 扫描。运行测试时请使用文件系统路径。

常用验证命令：

```bash
./godot/scripts/qa/run_all_qa.sh
```

视觉快照输出目录：

```text
godot/build/qa_snapshots/
```

### 项目结构

```text
project.godot                         Godot 项目入口
export_presets.cfg                    导出配置
godot/scenes/ui/main_game.tscn        主场景
godot/scripts/                        游戏逻辑和 UI 脚本
godot/assets/                         已选用的游戏资源
godot/assets/pixel_fish_pack/         像素风鱼类素材
godot/scripts/qa/                     QA 和真机测试脚本
docs/design/                          设计方案和 UI 重构文档
docs/qa/                              真机测试记录和验收文档
resource_packages/                    原始素材包，仅用于本地挑选资源
```

### 说明

- `resource_packages/` 是本地素材来源目录，不会进入 App 导出包。
- iOS App 图标和启动图资源位于 `godot/assets/`。
- iOS 导出产物默认写入 `godot/build/ios/`。
- 本项目当前以 iPhone 竖屏体验为主。

## English

Pokefish is a portrait-first mobile fish raising game built with Godot. The old Web and Capacitor versions have been removed; this repository now keeps only the Godot app project. The current target is iPhone device testing, with room to support Android later.

The current build uses pixel-style fish assets and mobile-first UI. Core gameplay includes partner fish care, feeding, resource collection, hatching, evolution, dex collection, adventures, and quests.

### Opening The Project

Open the repository root with Godot 4.6.3 or newer:

```text
project.godot
```

Main scene:

```text
res://godot/scenes/ui/main_game.tscn
```

Default local workspace path:

```text
/Users/rpy/Documents/github/pokefish
```

### Running And Debugging

Press Run in Godot to launch the main scene. The project is configured for a portrait mobile viewport:

```text
390 x 844
```

Touch and mouse emulation are enabled for desktop interaction testing:

```text
pointing/emulate_mouse_from_touch=true
pointing/emulate_touch_from_mouse=true
```

### iPhone Device Testing

Requirements:

- macOS
- Xcode
- Godot 4.6.3 or newer
- Godot iOS export template
- Apple ID or Apple Developer Team

Run the debug export and install flow:

```bash
./godot/scripts/qa/ios_debug_deploy.sh
```

See the iOS export guide:

```text
godot/IOS_EXPORT.md
```

### QA

QA scripts live in:

```text
godot/scripts/qa/
```

The directory has a `.gdignore` file, so it is not scanned as runtime app resources by Godot. Run QA scripts through filesystem paths.

Common verification command:

```bash
./godot/scripts/qa/run_all_qa.sh
```

Generated visual snapshots are written to:

```text
godot/build/qa_snapshots/
```

### Project Layout

```text
project.godot                         Godot project entry
export_presets.cfg                    Export configuration
godot/scenes/ui/main_game.tscn        Main scene
godot/scripts/                        Gameplay and UI scripts
godot/assets/                         Selected game assets
godot/assets/pixel_fish_pack/         Pixel-style fish assets
godot/scripts/qa/                     QA and device testing scripts
docs/design/                          Design plans and UI refactor notes
docs/qa/                              Device testing records and acceptance notes
resource_packages/                    Raw local asset packs for selection only
```

### Notes

- `resource_packages/` is a local source library and is excluded from app exports.
- iOS app icon and launch splash assets live under `godot/assets/`.
- iOS export output is written under `godot/build/ios/`.
- The current experience is designed primarily for portrait iPhone play.
