--- @module Events.PersistenceEvents
-- Centralized event controller for GAC data persistence, migration, and lifecycle events.

local _, GAC = ...

--- Hydrates character data and initializes persistence state trees on ADDON_LOADED.
-- @param loadedAddonName string The name of the loaded addon
-- @return boolean Success status
function GAC:InitPersistence(loadedAddonName)
    if loadedAddonName ~= self.name then
        return false
    end

    -- Support legacy DB name and standardized GAC_CharacterDB
    _G.GranAddonDeLasCosasDB = _G.GranAddonDeLasCosasDB or {}
    _G.GAC_CharacterDB = _G.GAC_CharacterDB or _G.GranAddonDeLasCosasCharDB or {}
    _G.GranAddonDeLasCosasCharDB = _G.GAC_CharacterDB

    self.db = _G.GranAddonDeLasCosasDB
    self.characterData = _G.GAC_CharacterDB

    self.characterData.progress = self.characterData.progress or { category = "normal", level = 1 }
    if type(self.characterData.progress.level) ~= "number" or self.characterData.progress.level < 1 then
        self.characterData.progress.level = 1
    end
    self.characterData.ui = self.characterData.ui or {}

    self:MigratePersistenceData()

    if self.Character then
        self.playerCharacter = self.Character:new(self.characterData.modelData)
    end

    self.inspectedPlayersCache = {}
    self.tempInsp = {}
    self.targetDataCache = self.inspectedPlayersCache

    if self.InitializeAttributeSystemData then
        self:InitializeAttributeSystemData()
    end

    print("¡|cFF00FF00[" .. self.name .. "]|r listo! Version: " .. self.version)
    return true
end

--- Performs data migrations from older persistence structures to current format.
-- @return void
function GAC:MigratePersistenceData()
    local charDB = _G.GAC_CharacterDB
    local globalDB = _G.GranAddonDeLasCosasDB

    if not charDB.attributes then charDB.attributes = {} end
    if not charDB.talents then charDB.talents = {} end

    local hasMigratedData = next(charDB.attributes) ~= nil or next(charDB.talents) ~= nil
    if not hasMigratedData and globalDB and globalDB.attributes and globalDB.talents then
        for key, value in pairs(globalDB.attributes) do
            charDB.attributes[self:NormalizeAttributeNameThroughtVersions(key)] = value
        end

        for key, value in pairs(globalDB.talents) do
            charDB.talents[self:NormalizeTalentNameThroughtVersions(key)] = value
        end
    end

    local oldAttrKeys = {}
    for key, _ in pairs(charDB.attributes) do
        local normalizedKey = self:NormalizeAttributeNameThroughtVersions(key)
        if normalizedKey ~= key then
            oldAttrKeys[key] = normalizedKey
        end
    end
    for oldKey, newKey in pairs(oldAttrKeys) do
        if charDB.attributes[newKey] == nil or charDB.attributes[newKey] == 0 then
            charDB.attributes[newKey] = charDB.attributes[oldKey]
        end
        charDB.attributes[oldKey] = nil
    end

    local oldTalentKeys = {}
    for key, _ in pairs(charDB.talents) do
        local normalizedKey = self:NormalizeTalentNameThroughtVersions(key)
        if normalizedKey ~= key then
            oldTalentKeys[key] = normalizedKey
        end
    end
    for oldKey, newKey in pairs(oldTalentKeys) do
        if charDB.talents[newKey] == nil or charDB.talents[newKey] == 0 then
            charDB.talents[newKey] = charDB.talents[oldKey]
        end
        charDB.talents[oldKey] = nil
    end
end

--- Flushes character state trees back to persistent storage on PLAYER_LOGOUT.
-- @return void
function GAC:FlushPersistence()
    if self.playerCharacter then
        _G.GAC_CharacterDB.modelData = self.playerCharacter:Serialize()
    end
end
