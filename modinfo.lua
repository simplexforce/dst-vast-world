name = "DST Vast World"
description = [[
Experimental DST world generation scaffold for maps far larger than the vanilla presets.
This version sets up the mod structure, worldgen hooks, and reference docs for future giant-map work.
]]
author = "simplex"
version = "0.1.0"

forumthread = ""

api_version_dst = 10
dont_starve_compatible = false
dst_compatible = true
all_clients_require_mod = false
server_only_mod = true

icon_atlas = nil
icon = nil

server_filter_tags = {
    "worldgen",
    "map",
    "vast-world",
}

configuration_options = {
    {
        name = "worldgen_log_level",
        label = "Worldgen Logging",
        hover = "Controls how much DST Vast World logs during world generation.",
        options = {
            { description = "Normal", data = "normal" },
            { description = "Verbose", data = "verbose" },
        },
        default = "normal",
    },
}
