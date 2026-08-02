--- @module ui.inspection.api.inspectionApi
-- Client API adapter connecting Inspection micro-frontend to LocalIPCAdapter.

local inspectionApi = {}
inspectionApi.__index = inspectionApi

function inspectionApi.create(ipcAdapter)
    local instance = setmetatable({}, inspectionApi)
    instance.ipc = ipcAdapter
    return instance
end

function inspectionApi:OnInspectionDataReady(callback)
    if self.ipc and type(self.ipc.Subscribe) == "function" then
        self.ipc:Subscribe("INSPECTION_DATA_READY", callback)
    end
end

return inspectionApi
