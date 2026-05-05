local M = {}

M.WORLDGEN_GROUP = "dst_vast_world"
M.WORLDGEN_OPTION = "vast_world_size"
-- Engine limit: worldgen_main.lua caps max_map_width/height at 1024.
-- Any requested size above this is silently capped at generation time.
M.MAX_EFFECTIVE_WORLD_TILES = 1024

M.WORLD_SIZE_PRESETS = {
    disabled = {
        label = "Disabled",
    },
    -- Reference preset: identical to vanilla "huge". Useful for A/B testing
    -- without changing the worldgen option group.
    vanilla_huge = {
        label = "Vanilla Huge (450 tiles)",
        target_tiles = 450,
        vanilla_world_size = "huge",
        status = "vanilla",
    },
    vast_500 = {
        label = "Vast 500",
        target_tiles = 500,
        vanilla_world_size = "huge",
        status = "active",
    },
    vast_750 = {
        label = "Vast 750",
        target_tiles = 750,
        vanilla_world_size = "huge",
        status = "active",
    },
    vast_1000 = {
        label = "Vast 1000",
        target_tiles = 1000,
        vanilla_world_size = "huge",
        status = "active",
    },
}

M.WORLD_SIZE_OPTIONS = {
    { text = M.WORLD_SIZE_PRESETS.disabled.label, data = "disabled" },
    { text = M.WORLD_SIZE_PRESETS.vanilla_huge.label, data = "vanilla_huge" },
    { text = M.WORLD_SIZE_PRESETS.vast_500.label, data = "vast_500" },
    { text = M.WORLD_SIZE_PRESETS.vast_750.label, data = "vast_750" },
    { text = M.WORLD_SIZE_PRESETS.vast_1000.label, data = "vast_1000" },
}

function M.RegisterCustomizationStrings(strings)
    if strings == nil or strings.UI == nil or strings.UI.CUSTOMIZATIONSCREEN == nil then
        return
    end

    strings.UI.CUSTOMIZATIONSCREEN.VAST_WORLD_SIZE = "Vast World Size"
end

function M.GetWorldSizePreset(level)
    local preset_key = level ~= nil and level.overrides ~= nil and level.overrides[M.WORLDGEN_OPTION] or nil
    return preset_key ~= nil and M.WORLD_SIZE_PRESETS[preset_key] or nil, preset_key
end

function M.ApplyWorldSizePreset(level)
    local preset, preset_key = M.GetWorldSizePreset(level)
    if preset == nil or preset_key == nil or preset_key == "disabled" then
        return nil, preset_key
    end

    -- Cap at engine limit so the shim never requests an impossible size.
    local effective_target_tiles = preset.target_tiles
    if effective_target_tiles > M.MAX_EFFECTIVE_WORLD_TILES then
        effective_target_tiles = M.MAX_EFFECTIVE_WORLD_TILES
    end

    -- Set vanilla world_size so the base game's size-resolution block runs
    -- normally. The shim then overrides the resolved tile count.
    level.overrides.world_size = preset.vanilla_world_size
    -- requested = what the user asked for; target = what the shim will actually
    -- apply (may be lower due to engine cap).
    level.overrides.vast_world_requested_tiles = preset.target_tiles
    level.overrides.vast_world_target_tiles = effective_target_tiles
    level.overrides.vast_world_status = preset.status

    return preset, preset_key, effective_target_tiles
end

return M
