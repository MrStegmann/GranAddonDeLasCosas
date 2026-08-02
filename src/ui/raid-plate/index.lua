--- @module ui.raid-plate.index
-- Orchestrator for RaidPlate UI micro-frontend.

local raidPlateApi = require and pcall(require, "src.ui.raid-plate.api.raidPlateApi") and require("src.ui.raid-plate.api.raidPlateApi") or nil

local RaidPlateModule = {}
RaidPlateModule.__index = RaidPlateModule

function RaidPlateModule.create(ipcAdapter)
    local instance = setmetatable({}, RaidPlateModule)
    local factory = raidPlateApi or (GAC and GAC.raidPlateApi)
    if factory and factory.create then
        instance.api = factory.create(ipcAdapter)
    end
    return instance
end

function RaidPlateModule:Init()
    if self.api then
        self.api:OnRosterUpdated(function(data)
            self:Render(data)
        end)
    end
end

function RaidPlateModule:Render(data)
    -- Visual RaidPlate update rendering logic
end

return RaidPlateModule
