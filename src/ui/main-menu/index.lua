--- @module ui.main-menu.index
-- Orchestrator for MainMenu UI micro-frontend.

local MainMenuModule = {}
MainMenuModule.__index = MainMenuModule

function MainMenuModule.create(ipcAdapter)
    local instance = setmetatable({}, MainMenuModule)
    instance.ipc = ipcAdapter
    return instance
end

function MainMenuModule:Init()
    -- Initialize MainMenu tab handlers
end

return MainMenuModule
