--- @module ports.RemotePlayerPort
-- Abstract interface defining contract for external player & add-on profile adapters.

local RemotePlayerPort = {}
RemotePlayerPort.__index = RemotePlayerPort

function RemotePlayerPort.create()
    local instance = setmetatable({}, RemotePlayerPort)
    return instance
end

function RemotePlayerPort:GetPlayerProfileName()
    error("RemotePlayerPort:GetPlayerProfileName must be implemented by adapter")
end

function RemotePlayerPort:GetPlayerProfileRace()
    error("RemotePlayerPort:GetPlayerProfileRace must be implemented by adapter")
end

function RemotePlayerPort:GetPlayerProfileClass()
    error("RemotePlayerPort:GetPlayerProfileClass must be implemented by adapter")
end

return RemotePlayerPort
