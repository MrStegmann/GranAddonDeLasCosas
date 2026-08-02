--- @module ui.initiative.index
local InitiativeModule = {}
function InitiativeModule.create() return setmetatable({}, {__index = InitiativeModule}) end
return InitiativeModule
