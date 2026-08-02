--- @module ui.player-plate.index
-- Orchestrator for PlayerPlate UI micro-frontend.

local playerPlateApi = require and pcall(require, "src.ui.player-plate.api.playerPlateApi") and require("src.ui.player-plate.api.playerPlateApi") or nil

local PlayerPlateModule = {}
PlayerPlateModule.__index = PlayerPlateModule

function PlayerPlateModule.create(ipcAdapter)
    local instance = setmetatable({}, PlayerPlateModule)
    local factory = playerPlateApi or (GAC and GAC.playerPlateApi)
    if factory and factory.create then
        instance.api = factory.create(ipcAdapter)
    end
    return instance
end

function PlayerPlateModule:Init()
    if self.api then
        self.api:OnCharacterUpdated(function(data)
            self:Render(data)
        end)
    end
end

function PlayerPlateModule:Render(data)
    -- Visual PlayerPlate update rendering logic
end

return PlayerPlateModule
