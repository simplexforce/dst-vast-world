-- Registers the "Vast World Size" option in the worldgen customization
-- screen and hooks into every level to apply the selected preset.
local presets = require("vast_world/presets")

presets.RegisterCustomizationStrings(GLOBAL.STRINGS)

-- Adds a custom option group and a single dropdown item to the worldgen
-- customization UI. The dropdown exposes every preset from WORLD_SIZE_OPTIONS.
local function RegisterWorldgenOptions()
    AddCustomizeGroup(
        LEVELCATEGORY.WORLDGEN,
        presets.WORLDGEN_GROUP,
        "DST Vast World",
        "Vast World Size",
        "images/worldgen_customization.xml",
        90
    )

    AddCustomizeItem(LEVELCATEGORY.WORLDGEN, presets.WORLDGEN_GROUP, presets.WORLDGEN_OPTION, {
        value = "disabled",
        image = "world_size.tex",
        options_remap = { img = "blank_world.tex", atlas = "images/customisation.xml" },
        desc = presets.WORLD_SIZE_OPTIONS,
        order = 1,
        world = { "forest", "cave" },
    })
end

-- Called via AddLevelPreInitAny for every level (forest, cave, etc.).
-- Resolves the user's chosen preset into override fields that the
-- forest_map_shim reads during generation.
local function ApplyWorldgenPreset(level)
    local preset, preset_key, effective_target_tiles = presets.ApplyWorldSizePreset(level)
    if preset == nil or preset_key == nil then
        return
    end

    print(string.format(
        "[dst-vast-world] %s requested for %s. target_tiles=%d, effective_target_tiles=%d, vanilla_world_size=%s, status=%s",
        preset_key,
        tostring(level.location),
        preset.target_tiles,
        effective_target_tiles,
        tostring(preset.vanilla_world_size),
        tostring(preset.status)
    ))
end

RegisterWorldgenOptions()
AddLevelPreInitAny(ApplyWorldgenPreset)
