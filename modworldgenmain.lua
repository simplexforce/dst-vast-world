-- Order matters: worldgen.lua registers the preset and sets level overrides;
-- forest_map_shim.lua reads those overrides during generation.
modimport("scripts/vast_world/worldgen.lua")
modimport("scripts/vast_world/forest_map_shim.lua")
