--- @module ui.player-plate.api.playerPlateApi
-- Client API adapter connecting PlayerPlate micro-frontend to LocalIPCAdapter.

local playerPlateApi = {}
playerPlateApi.__index = playerPlateApi

function playerPlateApi.create(ipcAdapter)
    local instance = setmetatable({}, playerPlateApi)
    instance.ipc = ipcAdapter
    return instance
end

function playerPlateApi:OnCharacterUpdated(callback)
    if self.ipc and type(self.ipc.Subscribe) == "function" then
        self.ipc:Subscribe("CHARACTER_UPDATED", callback)
    end
end

return playerPlateApi
