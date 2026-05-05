# Architecture & vanilla analysis

## Vanilla hooks relevant to map size

### `scripts/map/customize.lua`

- The built-in `world_size` worldgen option is declared here.
- Vanilla frontend values are: `small`, `medium`, `default`, `huge`.
- This is the UI/config side of map size, not the final tile-size implementation.

### `scripts/map/locations.lua`

- Default world locations for `forest` and `cave` both start with `world_size = "default"`.
- Mod hooks can adjust these overrides before generation.

### `scripts/map/forest_map.lua`

- The actual tile size is resolved here in `Generate(...)`.
- Current vanilla mappings on non-console platforms:

  | Option  | Tiles |
  | ------- | ----- |
  | small   | 50    |
  | medium  | 400   |
  | default | 425   |
  | large   | 425   |
  | huge    | 450   |

- The function then calls `WorldSim:SetWorldSize(map_width, map_height)`.

### `scripts/worldgen_main.lua`

- The worldgen driver uses `forest_map.Generate(...)`.
- It currently sets `max_map_width = 1024` and `max_map_height = 1024` before generation.

## Implications for `dst-vast-world`

- A mod can expose its own worldgen option and mutate `level.overrides` with `AddLevelPreInitAny(...)`.
- That alone is **not enough** to exceed vanilla `huge`.
- Real vast-world support requires a deeper patch or replacement path for `forest_map.Generate(...)` so custom sizes larger than `450` are honored.

## Current approach

The current implementation does three things:

1. Registers a custom `vast_world_size` worldgen option.
2. Converts that option into a vanilla-safe `world_size = "huge"` fallback plus metadata such as `vast_world_target_tiles`.
3. Installs a targeted shim around `forest_map.Generate(...)` that swaps in `vast_world_target_tiles` immediately before vanilla assigns `map_width` and `map_height` from `min_size`.

## Shim design

Keep the shim narrow. The stable point to intervene is the vanilla size-resolution block inside `forest_map.Generate(...)`, right before `WorldSim:SetWorldSize(...)`.

Avoid broad debug hooks that scan arbitrary frames throughout worldgen; they add overhead and are more likely to interfere with generation. Prefer a one-shot override that patches the resolved size and then restores the previous debug state immediately.
