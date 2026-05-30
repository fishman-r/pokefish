# Pokefish

`Pokefish` is a playable app demo for an idle WeChat mini-game about collecting, raising, and unexpectedly evolving unique fish.

## Features

1. Unique fish generation with species, rarity, appearance, traits, visible genes, and hidden genes.
2. Weighted evolution based on pond type, food, level, mood, intimacy, traits, and genes.
3. A cartoon pond scene where fish swim with visible body, fin, and tail motion.
4. Five app screens: Pond, Hatchery, Collection, Explore, and Quests.
5. A long-term loop around hatching fish, expanding the collection, exploring, completing quests, and earning resources.

The current visual direction uses a clear chibi cartoon style with bold outlines across fish, background, plants, coral, and pond floor.

## Run

```bash
python3 -m http.server 4173
```

Open:

```text
http://127.0.0.1:4173/
```

Progress is saved in browser `localStorage`.
