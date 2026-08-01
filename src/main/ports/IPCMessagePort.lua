--- @module ports.IPCMessagePort
-- Abstract interface defining contract for local IPC message bus adapters.

local IPCMessagePort = {}
IPCMessagePort.__index = IPCMessagePort

function IPCMessagePort.create()
    local instance = setmetatable({}, IPCMessagePort)
    return instance
end

function IPCMessagePort:Subscribe(channel, callback)
    error("IPCMessagePort:Subscribe must be implemented by adapter")
end

function IPCMessagePort:Unsubscribe(channel, callback)
    error("IPCMessagePort:Unsubscribe must be implemented by adapter")
end

function IPCMessagePort:Publish(channel, payload)
    error("IPCMessagePort:Publish must be implemented by adapter")
end

return IPCMessagePort
