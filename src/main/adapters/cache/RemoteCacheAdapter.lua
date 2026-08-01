--- @module adapters.cache.RemoteCacheAdapter
-- Volatile in-memory TTL/versioned remote player data cache.

local RemoteCacheAdapter = {}
RemoteCacheAdapter.__index = RemoteCacheAdapter

function RemoteCacheAdapter.create()
    local instance = setmetatable({}, RemoteCacheAdapter)
    instance.cache = {}
    return instance
end

function RemoteCacheAdapter:Get(key)
    return self.cache[key]
end

function RemoteCacheAdapter:Set(key, value)
    self.cache[key] = value
end

function RemoteCacheAdapter:Clear()
    self.cache = {}
end

return RemoteCacheAdapter
