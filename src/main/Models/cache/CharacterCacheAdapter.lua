local CharacterCacheAdapter = {}
CharacterCacheAdapter.__index = CharacterCacheAdapter

local cachedCharacter = nil

--- Retrieves the in-memory session character model instance.
--- @return table|nil
function CharacterCacheAdapter.getCharacter()
    return cachedCharacter
end

--- Updates the in-memory session character model instance.
--- @param characterModel table
function CharacterCacheAdapter.setCharacter(characterModel)
    cachedCharacter = characterModel
end

--- Clears the cached character instance.
function CharacterCacheAdapter.clearCache()
    cachedCharacter = nil
end

_G.CharacterCacheAdapter = CharacterCacheAdapter
return CharacterCacheAdapter
