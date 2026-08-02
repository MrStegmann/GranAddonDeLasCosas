--- @module ui.economy.index
local EconomyModule = {}
function EconomyModule.create() return setmetatable({}, {__index = EconomyModule}) end
return EconomyModule
