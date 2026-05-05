# DST mod development guide

## Goal

This project is a Don't Starve Together mod named `dst-vast-world`. The long-term goal is to support worlds much larger than the vanilla `huge` preset.

## Repository layout

| Path                      | Purpose                                               |
| ------------------------- | ----------------------------------------------------- |
| `modinfo.lua`             | DST mod metadata and server compatibility flags       |
| `modmain.lua`             | Runtime entrypoint for non-worldgen hooks             |
| `modworldgenmain.lua`     | World generation entrypoint                           |
| `scripts/vast_world/`     | Project Lua modules                                   |
| `docs/`                   | Documentation                                         |
| `dev-scripts/`            | Helper scripts (fetch game scripts, install mod)      |
| `.local-reference-files/` | Local copied game/workshop references, ignored by git |
| `.env.example`            | Template for local environment variables (`DST_PATH`) |

## Primary references

- [Getting started with modding DST](https://forums.kleientertainment.com/forums/topic/47353-guide-getting-started-with-modding-dst-and-some-general-tips-for-ds-as-well/) — official starter reference from Klei's forum

## Local reference setup

This project relies on the official DST scripts for reverse-engineering. These files are **not** tracked by git — each developer sets them up locally under `.local-reference-files/`.

1. Copy `.env.example` to `.env` and set `DST_PATH` to your DST installation root. The default Steam (Linux) path is `~/.steam/root/steamapps/common/Don't Starve Together` — adjust if you used a custom install location.
2. Run the setup script:

   ```sh
   ./dev-scripts/fetch-game-scripts.sh
   ```

   This copies `scripts.zip` and `scripts_readme.txt` from the game data, then extracts the Lua sources into `.local-reference-files/game-scripts/`.

After setup, the extracted Lua sources are available at `.local-reference-files/game-scripts/scripts/`. You can also browse installed workshop mods under `$DST_PATH/mods/` for real-world mod structure reference.

## Reading server logs

DST writes logs under `~/.klei/`, with the exact directory depending on the release branch:

| Branch           | Log directory                            |
| ---------------- | ---------------------------------------- |
| Stable (default) | `~/.klei/DoNotStarveTogether/`           |
| Beta             | `~/.klei/DoNotStarveTogetherBetaBranch/` |

Since this is a **server-only mod**, the relevant log is `master_server_log.txt` at the top level:

```
# Beta branch
~/.klei/DoNotStarveTogetherBetaBranch/master_server_log.txt

# Stable
~/.klei/DoNotStarveTogether/master_server_log.txt
```

Search for the mod tag to filter relevant output:

```sh
grep "dst-vast-world" ~/.klei/DoNotStarveTogetherBetaBranch/master_server_log.txt
```

## Installing the mod for testing

After setting `DST_PATH` in `.env`:

```sh
./dev-scripts/install-mod.sh
```

This copies the mod files (`modinfo.lua`, `modmain.lua`, `modworldgenmain.lua`, `scripts/`) into `$DST_PATH/mods/dst-vast-world/`, mirroring the layout of workshop mods. Run it again to update after code changes.

## Distilled modding practices

1. Prefer mod hooks over editing base game files directly.
2. Keep copied official scripts and workshop mods out of version control.
3. Treat `modmain.lua` and `modworldgenmain.lua` as separate entrypoints:
   - `modmain.lua` for runtime hooks
   - `modworldgenmain.lua` for world generation hooks
4. Use small Lua modules under `scripts/` instead of placing everything in one giant entrypoint.
5. When changing world generation, inspect the vanilla pipeline before overriding behavior:
   - customization/UI option definitions
   - level/location defaults
   - worldgen functions that convert overrides into map size and topology
6. Prefer additive customization items and level pre-init hooks before considering large source overrides.
7. Keep experimental behavior clearly labeled when it depends on deeper engine or worldgen patches.
