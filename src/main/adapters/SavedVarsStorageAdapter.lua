--- @module adapters.SavedVarsStorageAdapter
-- Technical storage gateway encapsulating SavedVariablesPerCharacter (GAC_CharacterDB).

local Character = require and pcall(require, "src.main.domain.Character") and require("src.main.domain.Character") or nil

local SavedVarsStorageAdapter = {}
SavedVarsStorageAdapter.__index = SavedVarsStorageAdapter

--- Factory method to create SavedVarsStorageAdapter.
-- @param dbName string|nil Global SavedVariable key (defaults to "GAC_CharacterDB")
-- @return table Adapter instance
function SavedVarsStorageAdapter.create(dbName)
    local instance = setmetatable({}, SavedVarsStorageAdapter)
    instance.dbName = dbName or "GAC_CharacterDB"
    return instance
end

--- Reads saved character data from global SavedVariables and validates schema defaults.
-- @return table Character domain entity instance
function SavedVarsStorageAdapter:LoadCharacter()
    local rawDB = _G[self.dbName]
    if type(rawDB) ~= "table" then
        rawDB = {}
        _G[self.dbName] = rawDB
    end

    local charFactory = Character or (GAC and GAC.Character)
    if charFactory and charFactory.create then
        return charFactory.create(rawDB)
    end

    return rawDB
end

--- Serializes character domain entity and persists state to global SavedVariables table.
-- @param characterInstance table Character domain instance
-- @return boolean Success status
function SavedVarsStorageAdapter:SaveCharacter(characterInstance)
    if type(characterInstance) ~= "table" then return false end

    local serialized = nil
    if type(characterInstance.Serialize) == "function" then
        serialized = characterInstance:Serialize()
    else
        serialized = characterInstance
    end

    _G[self.dbName] = serialized
    return true
end

--- Flushes or validates current persistent storage.
function SavedVarsStorageAdapter:Flush()
    -- Reserved for storage validation or sync routines
end

return SavedVarsStorageAdapter
