--- @module ui.target-plate.api.targetPlateApi
-- Client API adapter connecting TargetPlate micro-frontend to LocalIPCAdapter.

local targetPlateApi = {}
targetPlateApi.__index = targetPlateApi

function targetPlateApi.create(ipcAdapter)
    local instance = setmetatable({}, targetPlateApi)
    instance.ipc = ipcAdapter
    return instance
end

function targetPlateApi:OnInspectionDataReady(callback)
    if self.ipc and type(self.ipc.Subscribe) == "function" then
        self.ipc:Subscribe("INSPECTION_DATA_READY", callback)
    end
end

return targetPlateApi
