-- Intercept forest_map.Generate to apply vast_world_target_tiles.
--
-- The previous shim installed a broad line hook and scanned multiple stack
-- frames for the entire duration of worldgen. That approach is fragile and
-- expensive. This version only hooks the specific vanilla line where
-- `map_width = min_size` runs, updates `min_size` once, and immediately
-- restores the prior debug hook.

local forest_map = require("map/forest_map")
local presets = require("vast_world/presets")
local original_generate = forest_map.Generate
local dbg = GLOBAL.debug
-- pcall protects against errors in the debug hook crashing worldgen entirely.
local protected_call = pcall or GLOBAL.pcall

-- Duplicated here (instead of reading from customize.lua) because the vanilla
-- size-resolution block is a local table inside forest_map.Generate.
local VANILLA_WORLD_SIZES = {
    tiny = 1,
    small = 50,
    medium = 400,
    default = 425,
    large = 425,
    huge = 450,
}

-- Line number of the `map_width = min_size` assignment in the vanilla
-- scripts/map/forest_map.lua. Must be updated if DST patches that file.
local APPLY_WORLD_SIZE_LINE = 489

-- hook_state holds the debug-hook context while the shim is active.
-- hook_applied tracks whether the size override actually fired this run.
local hook_state = nil
local hook_applied = false

-- Mirrors the vanilla size-resolution logic to predict what tile count
-- forest_map.Generate would use without the shim. Returns 350 (the vanilla
-- fallback) if the key is unrecognized.
local function GetResolvedVanillaSize(level)
    local overrides = level ~= nil and level.overrides or nil
    local size_key = overrides ~= nil and overrides.world_size or nil
    return VANILLA_WORLD_SIZES[size_key] or 350
end

local function RestoreHook()
    if hook_state == nil then
        return
    end

    dbg.sethook(hook_state.previous_hook, hook_state.previous_mask, hook_state.previous_count)
    hook_state = nil
end

-- Debug hook: fires on every line event but only acts on the exact line
-- where vanilla assigns `map_width = min_size`. At that point, replaces
-- min_size with the target tile count and immediately removes itself.
local function size_override_hook(event, line)
    if event ~= "line" or line ~= APPLY_WORLD_SIZE_LINE or hook_state == nil then
        return
    end

    local info = dbg.getinfo(2, "f")
    if info == nil or info.func ~= original_generate then
        return
    end

    local i = 1
    while true do
        local name, value = dbg.getlocal(2, i)
        if name == nil then
            break
        end

        if name == "min_size" then
            if value ~= hook_state.target_tiles then
                dbg.setlocal(2, i, hook_state.target_tiles)
                hook_state.applied = true
                hook_applied = true
                print(string.format(
                    "[dst-vast-world] Applied world size override: %s %s -> %d tiles",
                    tostring(hook_state.location),
                    tostring(value),
                    hook_state.target_tiles
                ))
            end

            RestoreHook()
            return
        end

        i = i + 1
    end
end

-- Replacement for forest_map.Generate. If a vast-world preset is active and
-- the requested tiles exceed vanilla, installs a one-shot debug hook to patch
-- the resolved size. Otherwise, delegates to the original function unchanged.
forest_map.Generate = function(prefab, map_width, map_height, tasks, level, level_type)
    local preset, preset_key = presets.ApplyWorldSizePreset(level)
    local vast_tiles = level and level.overrides and level.overrides.vast_world_target_tiles
    hook_applied = false

    if preset ~= nil then
        print(string.format(
            "[dst-vast-world] Resolved %s for %s inside forest_map.Generate",
            tostring(preset_key),
            tostring(prefab or (level and level.location) or "unknown")
        ))
    end

    local resolved_vanilla_size = GetResolvedVanillaSize(level)
    if type(vast_tiles) ~= "number" or vast_tiles <= resolved_vanilla_size then
        return original_generate(prefab, map_width, map_height, tasks, level, level_type)
    end

    local previous_hook, previous_mask, previous_count = dbg.gethook()
    hook_state = {
        location = prefab or (level and level.location) or "unknown",
        previous_hook = previous_hook,
        previous_mask = previous_mask,
        previous_count = previous_count,
        applied = false,
        target_tiles = vast_tiles,
    }

    print(string.format(
        "[dst-vast-world] Shim activating: %s %d -> %d tiles",
        tostring(hook_state.location),
        resolved_vanilla_size,
        vast_tiles
    ))

    dbg.sethook(size_override_hook, "l")

    local ok, result
    if protected_call ~= nil then
        ok, result = protected_call(
            original_generate,
            prefab,
            map_width,
            map_height,
            tasks,
            level,
            level_type
        )
    else
        result = original_generate(prefab, map_width, map_height, tasks, level, level_type)
        ok = true
    end

    local applied = hook_applied
    local location = hook_state ~= nil and hook_state.location or prefab or (level and level.location) or "unknown"
    RestoreHook()

    if not ok then
        print(string.format(
            "[dst-vast-world] ERROR: forest_map.Generate failed for %s: %s",
            tostring(location),
            tostring(result)
        ))
        return nil
    end

    if not applied then
        print(string.format(
            "[dst-vast-world] WARNING: world size override did not apply for %s. Check forest_map.lua line drift; target=%d, vanilla=%d",
            tostring(location),
            vast_tiles,
            resolved_vanilla_size
        ))
    end

    return result
end
