--- @module ports.StoragePort
-- Abstract interface defining contract for character state storage adapters.

local StoragePort = {}
StoragePort.__index = StoragePort

function StoragePort.create()
    local instance = setmetatable({}, StoragePort)
    return instance
end

function StoragePort:LoadCharacter()
    error("StoragePort:LoadCharacter must be implemented by adapter")
end

function StoragePort:SaveCharacter(characterInstance)
    error("StoragePort:SaveCharacter must be implemented by adapter")
end

function StoragePort:Flush()
    error("StoragePort:Flush must be implemented by adapter")
end

return StoragePort
