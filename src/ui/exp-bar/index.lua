--- @module ui.exp-bar.index
local ExpBarModule = {}
function ExpBarModule.create() return setmetatable({}, {__index = ExpBarModule}) end
return ExpBarModule
