--- @module ui.inspection.index
-- Orchestrator for Inspection UI micro-frontend.

local InspectionModule = {}
InspectionModule.__index = InspectionModule

function InspectionModule.create(ipcAdapter)
    local instance = setmetatable({}, InspectionModule)
    instance.ipc = ipcAdapter
    return instance
end

function InspectionModule:Init()
    -- Initialize inspection UI listeners
end

return InspectionModule
