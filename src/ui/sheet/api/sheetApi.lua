--- @module ui.sheet.api.sheetApi
-- Client API adapter connecting Character Sheet micro-frontend strictly over LocalIPCAdapter.

local sheetApi = {}
sheetApi.__index = sheetApi

function sheetApi.create(ipcAdapter)
    local instance = setmetatable({}, sheetApi)
    instance.ipc = ipcAdapter
    instance.characterListeners = {}
    return instance
end

function sheetApi:OnCharacterUpdated(callback)
    if type(callback) ~= "function" then return end
    table.insert(self.characterListeners, callback)

    if self.ipc and type(self.ipc.Subscribe) == "function" then
        self.ipc:Subscribe("CHARACTER_UPDATED", callback)
    end
end

function sheetApi:RequestCharacterUpdate(updatePayload)
    if self.ipc and type(self.ipc.Publish) == "function" then
        self.ipc:Publish("CHARACTER_UPDATED", updatePayload)
    end
end

return sheetApi
