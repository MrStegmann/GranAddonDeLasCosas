--- @module domain.Character
-- Pure Lua entity representing a Character domain model.
-- Strictly isolated from WoW APIs and global client environment.

local CharacterCalculator = require and pcall(require, "src.main.domain.CharacterCalculator") and require("src.main.domain.CharacterCalculator") or nil

local Character = {}
Character.__index = Character

--- Factory method to validate and instantiate a Character domain model.
-- @param raw_data table|nil Raw character state
-- @return table Character instance
function Character.create(raw_data)
    local instance = setmetatable({}, Character)
    raw_data = type(raw_data) == "table" and raw_data or {}

    instance._data = {
        version = type(raw_data.version) == "number" and raw_data.version or 1,
        name = type(raw_data.name) == "string" and raw_data.name ~= "" and raw_data.name or "Desconocido",
        level = (type(raw_data.level) == "number" and raw_data.level >= 1) and raw_data.level or 1,
        category = type(raw_data.category) == "string" and raw_data.category or "normal",
        class = type(raw_data.class) == "string" and raw_data.class or "Desconocida",
        race = type(raw_data.race) == "table" and raw_data.race or { "human" },
        raceTalents = type(raw_data.raceTalents) == "table" and raw_data.raceTalents or {},
        attributes = type(raw_data.attributes) == "table" and raw_data.attributes or {},
        talents = type(raw_data.talents) == "table" and raw_data.talents or {},
        positiveTraits = type(raw_data.positiveTraits) == "table" and raw_data.positiveTraits or {},
        negativeTraits = type(raw_data.negativeTraits) == "table" and raw_data.negativeTraits or {},
        advantages = type(raw_data.advantages) == "table" and raw_data.advantages or {},
        disadvantages = type(raw_data.disadvantages) == "table" and raw_data.disadvantages or {},
        special = type(raw_data.special) == "table" and raw_data.special or {},
        worgenCurse = type(raw_data.worgenCurse) == "boolean" and raw_data.worgenCurse or false,
        healthPoints = type(raw_data.healthPoints) == "table" and raw_data.healthPoints or { current = 10, max = 10 },
        shieldPoints = type(raw_data.shieldPoints) == "table" and raw_data.shieldPoints or { current = 0 },
        manapoints = type(raw_data.manapoints) == "table" and raw_data.manapoints or { current = 0, max = 0 },
        spiritPoints = type(raw_data.spiritPoints) == "table" and raw_data.spiritPoints or { current = 0, max = 0 },
        movement = type(raw_data.movement) == "number" and raw_data.movement or 20,
        combatActions = type(raw_data.combatActions) == "number" and raw_data.combatActions or 2,
        criticalRange = type(raw_data.criticalRange) == "number" and raw_data.criticalRange or 20,
        experience = type(raw_data.experience) == "table" and raw_data.experience or { current = 0, max = 100 },
        skills = type(raw_data.skills) == "table" and raw_data.skills or {},
        spells = type(raw_data.spells) == "table" and raw_data.spells or {}
    }

    local equippedItems = {}
    local rawEquip = type(raw_data.equippedItems) == "table" and raw_data.equippedItems or {}
    for slot, itemData in pairs(rawEquip) do
        equippedItems[slot] = itemData
    end
    local defaultSlots = {"head", "chest", "legs", "hands", "mainHand", "secondWeapon", "thirdWeapon"}
    for _, s in ipairs(defaultSlots) do
        if not equippedItems[s] then equippedItems[s] = "" end
    end
    instance._data.equippedItems = equippedItems

    return instance
end

-- Getters & Setters
function Character:GetName() return self._data.name end
function Character:SetName(name)
    if type(name) == "string" and name ~= "" then self._data.name = name end
end

function Character:GetVersion() return self._data.version end
function Character:SetVersion(v)
    if type(v) == "number" then self._data.version = v end
end

function Character:GetLevel() return self._data.level end
function Character:SetLevel(level)
    if type(level) == "number" and level >= 1 then self._data.level = level end
end

function Character:GetCategory() return self._data.category end
function Character:SetCategory(category)
    if type(category) == "string" then self._data.category = category end
end

function Character:GetClass() return self._data.class end
function Character:SetClass(class)
    if type(class) == "string" then self._data.class = class end
end

function Character:GetRace() return self._data.race end
function Character:SetRace(racesArray)
    if type(racesArray) == "table" and #racesArray > 0 then self._data.race = racesArray end
end

function Character:GetAttributes() return self._data.attributes end
function Character:SetAttribute(attrName, value)
    if type(attrName) == "string" and type(value) == "number" then
        self._data.attributes[attrName] = value
    end
end

function Character:GetTalents() return self._data.talents end
function Character:SetTalent(talentName, value)
    if type(talentName) == "string" and type(value) == "number" then
        self._data.talents[talentName] = value
    end
end

function Character:GetPositiveTraits() return self._data.positiveTraits end
function Character:SetPositiveTraits(traitsArray)
    if type(traitsArray) == "table" then self._data.positiveTraits = traitsArray end
end

function Character:GetNegativeTraits() return self._data.negativeTraits end
function Character:SetNegativeTraits(traitsArray)
    if type(traitsArray) == "table" then self._data.negativeTraits = traitsArray end
end

function Character:GetMaxHealth()
    local calc = CharacterCalculator or (self._calcRef)
    if calc and calc.CalculateMaxHealth then
        local con = self._data.attributes and self._data.attributes["constitution"] or 0
        return calc.CalculateMaxHealth(self._data.category, self._data.level, con)
    end
    return self._data.healthPoints.max or 10
end

function Character:GetHealthPoints()
    self._data.healthPoints.max = self:GetMaxHealth()
    if self._data.healthPoints.current > self._data.healthPoints.max then
        self._data.healthPoints.current = self._data.healthPoints.max
    end
    return self._data.healthPoints
end

function Character:SetHealthPoints(current, max)
    if type(max) == "number" and max >= 1 then self._data.healthPoints.max = max end
    if type(current) == "number" then
        self._data.healthPoints.current = math.min(math.max(0, current), self._data.healthPoints.max)
    end
end

function Character:TakeDamage(amount)
    if type(amount) == "number" and amount > 0 then
        self:SetHealthPoints(self._data.healthPoints.current - amount)
    end
end

function Character:Heal(amount)
    if type(amount) == "number" and amount > 0 then
        self:SetHealthPoints(self._data.healthPoints.current + amount)
    end
end

function Character:GetShieldPoints() return self._data.shieldPoints end
function Character:SetShieldPoints(current)
    if type(current) == "number" then
        self._data.shieldPoints.current = math.max(current, 0)
    end
end

function Character:GetManaPoints() return self._data.manapoints end
function Character:SetManaPoints(current, max)
    if type(max) == "number" then self._data.manapoints.max = max end
    if type(current) == "number" then
        self._data.manapoints.current = math.min(math.max(current, 0), self._data.manapoints.max)
    end
end

function Character:GetSpiritPoints() return self._data.spiritPoints end
function Character:SetSpiritPoints(current, max)
    if type(max) == "number" then self._data.spiritPoints.max = max end
    if type(current) == "number" then
        self._data.spiritPoints.current = math.min(math.max(current, 0), self._data.spiritPoints.max)
    end
end

function Character:GetExperience() return self._data.experience end
function Character:SetExperience(current, max)
    if type(max) == "number" then self._data.experience.max = max end
    if type(current) == "number" then
        self._data.experience.current = math.max(current, 0)
    end
end

function Character:GetEquippedItems() return self._data.equippedItems end
function Character:SetEquippedItem(slot, itemInstance)
    if self._data.equippedItems and slot then
        self._data.equippedItems[slot] = itemInstance
    end
end

function Character:GetSkills() return self._data.skills end
function Character:SetSkills(skillsArray)
    if type(skillsArray) == "table" then self._data.skills = skillsArray end
end

function Character:GetSpells() return self._data.spells end
function Character:SetSpells(spellsArray)
    if type(spellsArray) == "table" then self._data.spells = spellsArray end
end

--- Serializes the Character entity into a plain Lua table.
-- @return table Serialized character table
function Character:Serialize()
    local res = {}
    for k, v in pairs(self._data) do
        if k == "equippedItems" then
            res.equippedItems = {}
            for slot, item in pairs(v) do
                if type(item) == "table" and item.Serialize then
                    res.equippedItems[slot] = item:Serialize()
                else
                    res.equippedItems[slot] = item
                end
            end
        elseif type(v) == "table" then
            local function copy(obj)
                if type(obj) ~= "table" then return obj end
                local t = {}
                for ok, ov in pairs(obj) do t[copy(ok)] = copy(ov) end
                return t
            end
            res[k] = copy(v)
        else
            res[k] = v
        end
    end
    return res
end

return Character
