# Pokefish Godot

中文 | [English](#english)

## 中文

此目录包含 Pokefish 的 Godot App 代码、场景、资源和 QA 脚本。项目入口仍在仓库根目录，请用 Godot 打开：

```text
project.godot
```

主场景：

```text
res://godot/scenes/ui/main_game.tscn
```

当前版本面向 iPhone 竖屏真机测试，主要内容包括：

- 全屏水域舞台、像素风鱼类素材和 Kenney 环境资源
- 图标优先的移动端 HUD、伙伴浮层、动作 Dock 和模式 Dock
- 伙伴、投喂、进化、孵化、图鉴、远行、目标和本地存档流程

存档位置：

```text
user://pokefish_save_v1.json
```

iPhone 真机测试和导出流程请查看仓库根目录 `README.md` 或 `godot/IOS_EXPORT.md`。

## English

This folder contains the Godot app code, scenes, assets, and QA scripts for Pokefish. The project entry is still at the repository root. Open this file in Godot:

```text
project.godot
```

Main scene:

```text
res://godot/scenes/ui/main_game.tscn
```

The current build targets portrait iPhone device testing and includes:

- a full-screen pond stage, pixel-style fish assets, and selected Kenney environment assets
- icon-first mobile HUD, partner float, action dock, and mode dock
- partner, feeding, evolution, hatchery, dex, adventure, quest, and local save flows

Save data is stored in:

```text
user://pokefish_save_v1.json
```

For iPhone testing and export commands, see the root `README.md` or `godot/IOS_EXPORT.md`.
