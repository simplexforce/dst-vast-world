-- modmain.lua runs at runtime, not during worldgen. Most of the work lives in
-- modworldgenmain.lua; this file only handles runtime-side concerns like UI
-- strings and config-driven logging.
local log_level = GetModConfigData("worldgen_log_level")

if log_level == "verbose" then
    print("[dst-vast-world] Runtime entrypoint loaded.")
end

if GLOBAL.STRINGS then
    GLOBAL.STRINGS.UI.CUSTOMIZATIONSCREEN.VAST_WORLD_SIZE = "Vast World Size"
end
