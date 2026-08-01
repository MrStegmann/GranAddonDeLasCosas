--- @module adapters.network.NetworkAdapter
-- Technical network adapter for P2P transport and message serialization.

local NetworkAdapter = {}
NetworkAdapter.__index = NetworkAdapter

function NetworkAdapter.create()
    local instance = setmetatable({}, NetworkAdapter)
    return instance
end

function NetworkAdapter:SendMessage(target, prefix, payload)
    -- Transport wrapper for C_ChatInfo.SendAddonMessage
    if type(C_ChatInfo) == "table" and type(C_ChatInfo.SendAddonMessage) == "function" then
        return pcall(C_ChatInfo.SendAddonMessage, prefix, payload, "WHISPER", target)
    end
    return false
end

return NetworkAdapter
