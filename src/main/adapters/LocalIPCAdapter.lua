--- @module adapters.LocalIPCAdapter
-- Main IPC event bus adapter connecting backend domain ports to UI micro-frontend client APIs.

local LocalIPCAdapter = {}
LocalIPCAdapter.__index = LocalIPCAdapter

--- Supported IPC system channel constants.
LocalIPCAdapter.CHANNELS = {
    CHARACTER_UPDATED = "CHARACTER_UPDATED",
    COMBAT_STATE_CHANGED = "COMBAT_STATE_CHANGED",
    INSPECTION_DATA_READY = "INSPECTION_DATA_READY"
}

--- Factory method to instantiate LocalIPCAdapter.
-- @return table LocalIPCAdapter instance
function LocalIPCAdapter.create()
    local instance = setmetatable({}, LocalIPCAdapter)
    instance.subscribers = {}
    return instance
end

--- Subscribes a callback listener to a specific IPC channel.
-- @param channel string Target channel name
-- @param callback function Callback handler
-- @return boolean Success status
function LocalIPCAdapter:Subscribe(channel, callback)
    if type(channel) ~= "string" or type(callback) ~= "function" then
        return false
    end

    if not self.subscribers[channel] then
        self.subscribers[channel] = {}
    end

    for _, cb in ipairs(self.subscribers[channel]) do
        if cb == callback then
            return true -- Already registered
        end
    end

    table.insert(self.subscribers[channel], callback)
    return true
end

--- Unsubscribes a callback listener from an IPC channel.
-- @param channel string Target channel name
-- @param callback function Callback handler to remove
-- @return boolean Success status
function LocalIPCAdapter:Unsubscribe(channel, callback)
    if type(channel) ~= "string" or not self.subscribers[channel] then
        return false
    end

    for i = #self.subscribers[channel], 1, -1 do
        if self.subscribers[channel][i] == callback then
            table.remove(self.subscribers[channel], i)
            if #self.subscribers[channel] == 0 then
                self.subscribers[channel] = nil
            end
            return true
        end
    end

    return false
end

--- Publishes a message payload to all subscribers of an IPC channel.
-- Safely ignores unmapped or empty channel broadcasts without errors.
-- @param channel string Channel name
-- @param payload any Data payload passed to subscribers
function LocalIPCAdapter:Publish(channel, payload)
    if type(channel) ~= "string" then return end

    local listeners = self.subscribers[channel]
    if not listeners or #listeners == 0 then
        return -- Silent handling for channels without active subscribers
    end

    for _, callback in ipairs(listeners) do
        local ok, err = pcall(callback, payload)
        if not ok and err then
            if geterrorhandler then
                geterrorhandler()(err)
            end
        end
    end
end

return LocalIPCAdapter
