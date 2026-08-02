--- @module ui.quick-actions.api.quickActionsApi
-- Client API adapter connecting QuickActions micro-frontend to LocalIPCAdapter.

local quickActionsApi = {}
quickActionsApi.__index = quickActionsApi

function quickActionsApi.create(ipcAdapter)
    local instance = setmetatable({}, quickActionsApi)
    instance.ipc = ipcAdapter
    return instance
end

function quickActionsApi:TriggerAction(actionName, payload)
    if self.ipc and type(self.ipc.Publish) == "function" then
        self.ipc:Publish("QUICK_ACTION_TRIGGERED", { action = actionName, payload = payload })
    end
end

return quickActionsApi
