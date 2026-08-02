--- @module ui.quick-actions.index
-- Orchestrator for QuickActions UI micro-frontend.

local QuickActionsModule = {}
QuickActionsModule.__index = QuickActionsModule

function QuickActionsModule.create(ipcAdapter)
    local instance = setmetatable({}, QuickActionsModule)
    instance.ipc = ipcAdapter
    return instance
end

function QuickActionsModule:Init()
    -- Initialize quick action buttons
end

return QuickActionsModule
