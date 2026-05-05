# AGENTS.md

AI Agent working guide. Read [docs/dev-guide.md](docs/dev-guide.md) first — it covers the project goal, local reference setup, mod installation, and the vanilla worldgen hooks that are essential context for any change.

## Project Overview

DST (Don't Starve Together) mod that aims to support worlds larger than the vanilla `huge` preset. Written in Lua.

## Directory Structure

```
.
├── modinfo.lua            # Mod metadata and config options
├── modmain.lua            # Runtime entrypoint
├── modworldgenmain.lua    # World generation entrypoint
├── scripts/
│   └── vast_world/
│       └── worldgen.lua   # Custom worldgen option registration and level hooks
├── docs/
│   └── dev-guide.md       # Required reading before any development
├── dev-scripts/           # Helper scripts (fetch game scripts, install mod)
└── .local-reference-files/  # Extracted DST source (not tracked by git)
```

## Key Rules

- DST uses `modmain.lua` for runtime and `modworldgenmain.lua` for worldgen — keep concerns separate.
- Mod hooks (`AddLevelPreInitAny`, `AddCustomizeGroup`, `AddCustomizeItem`) are preferred over patching base game files.
- When adding new worldgen presets, update both `WORLD_SIZE_PRESETS` and `WORLD_SIZE_OPTIONS` in `scripts/vast_world/worldgen.lua`. Consult the vanilla `customize.lua` for the correct API format.
- Local reference files under `.local-reference-files/` are the authoritative source for vanilla DST behavior — consult them before overriding anything.
- When installing a freshly changed mod for manual testing, clear the relevant DST log files first so the next run is easy to read. After that, explicitly ask the user to verify the new test result instead of assuming success from stale logs.
