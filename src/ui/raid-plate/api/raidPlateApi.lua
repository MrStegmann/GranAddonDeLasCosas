--- @module ui.raid-plate.api.raidPlateApi
-- Client API adapter connecting RaidPlate micro-frontend to LocalIPCAdapter.

local raidPlateApi = {}
raidPlateApi.__index = raidPlateApi

function raidPlateApi.create(ipcAdapter)
    local instance = setmetatable({}, raidPlateApi)
    instance.ipc = ipcAdapter
    return instance
end

function raidPlateApi:OnRosterUpdated(callback)
    if self.ipc and type(self.ipc.Subscribe) == "function" then
        self.ipc:Subscribe("ROSTER_UPDATED", callback)
    end
end

return raidPlateApi
