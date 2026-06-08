# Pokefish

Pokefish is now a Godot-only iOS app project. The old Web and Capacitor code has been removed; the active app entry is the Godot project at the repository root.

## Project Entry

Open this folder in Godot 4.6.3 or newer:

```text
project.godot
```

Main scene:

```text
res://godot/scenes/ui/main_game.tscn
```

The current mobile build is portrait-first and targets iPhone testing through Godot iOS export.

## iPhone Debug Build

```bash
/Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/ios_debug_deploy.sh
```

## QA

The QA scripts live under `godot/scripts/qa/`, but that directory is marked with `.gdignore` so it is not scanned as runtime app resources. Run QA scripts from filesystem paths instead of `res://` paths.

Common verification:

```bash
/Users/rpy/Documents/Claude/pokefish/godot/scripts/qa/run_all_qa.sh
```

Generated visual snapshots are written to:

```text
godot/build/qa_snapshots/
```

## Notes

- `resource_packages/` is a local source library for selecting assets and is excluded from export.
- Selected game assets live under `godot/assets/`.
- iOS App icon and launch splash sources live under `godot/assets/`.
- iOS export output lives under `godot/build/ios/`.
