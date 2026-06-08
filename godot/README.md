# Pokefish Godot

This folder contains the Godot iOS app version of Pokefish.

Open the repository root in Godot 4.6.3 or newer. The main scene is:

```text
res://godot/scenes/ui/main_game.tscn
```

The current Godot app version is portrait-first for iPhone testing:

- full-screen pond stage with procedural fish drawing and selected Kenney environment assets
- icon-first mobile HUD, partner float, action dock, and mode dock
- partner, feeding, evolution, hatchery, dex, adventure, quest, and local save flows

Save data is stored in:

```text
user://pokefish_save_v1.json
```

For iPhone testing, use the root `README.md` or `godot/IOS_EXPORT.md` command flow.
