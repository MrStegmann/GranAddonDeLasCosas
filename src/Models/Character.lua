local _, GAC = ...

-- Definición de la clase Character
local Character = {}
Character.__index = Character

-- Constructor
function Character:new(savedData)
    local instance = {}
    setmetatable(instance, Character)
    
    savedData = savedData or {}
    
    -- Inicialización de datos privados
    instance._data = {
        version = savedData.version or 1,
        name = savedData.name or (GAC.GetActiveTRP3ProfileName and GAC:GetActiveTRP3ProfileName()) or UnitName("player") or "Desconocido",
        level = savedData.level or 1,
        category = savedData.category or "normal",
        class = savedData.class or "Desconocida",
        race = savedData.race or { "human" },
        raceTalents = savedData.raceTalents or {},
        attributes = savedData.attributes or {},
        talents = savedData.talents or {},
        positiveTraits = savedData.positiveTraits or {},
        negativeTraits = savedData.negativeTraits or {},
        advantages = savedData.advantages or {},
        disadvantages = savedData.disadvantages or {},
        special = savedData.special or {},
        worgenCurse = savedData.worgenCurse or false,
        healthPoints = savedData.healthPoints or { current = 10, max = 10 },
        shieldPoints = savedData.shieldPoints or { current = 0 },
        manapoints = savedData.manapoints or { current = 0, max = 0 },
        spiritPoints = savedData.spiritPoints or { current = 0, max = 0 },
        experience = savedData.experience or { current = 0, max = 100 },
        skills = savedData.skills or {},
        spells = savedData.spells or {}
    }

    local equippedItems = {}
    local rawEquip = savedData.equippedItems or {}
    for slot, itemData in pairs(rawEquip) do
        if type(itemData) == "table" and itemData.classType then
            if itemData.classType == "Armor" and GAC.Armor then
                equippedItems[slot] = GAC.Armor:new(itemData)
            elseif itemData.classType == "Weapon" and GAC.Weapon then
                equippedItems[slot] = GAC.Weapon:new(itemData)
            else
                equippedItems[slot] = GAC.Item:new(itemData)
            end
        else
            equippedItems[slot] = itemData
        end
    end
    local defaultSlots = {"head", "chest", "legs", "hands", "mainHand", "secondWeapon", "thirdWeapon"}
    for _, s in ipairs(defaultSlots) do
        if not equippedItems[s] then equippedItems[s] = "" end
    end
    instance._data.equippedItems = equippedItems
    
    return instance
end

-- Getters y Setters
function Character:GetName()
    return self._data.name
end

function Character:SetName(name)
    if type(name) == "string" then
        self._data.name = name
    end
end

function Character:GetVersion()
    return self._data.version
end

function Character:SetVersion(v)
    if type(v) == "number" then
        self._data.version = v
    end
end

function Character:IncrementVersion()
    self._data.version = (self._data.version or 0) + 1
end

function Character:GetLevel()
    return self._data.level
end

function Character:SetLevel(level)
    if type(level) == "number" and level >= 1 then
        self._data.level = level
    end
end

function Character:GetCategory()
    return self._data.category
end

function Character:SetCategory(category)
    if type(category) == "string" then
        self._data.category = category
    end
end

function Character:GetClass()
    return self._data.class
end

function Character:SetClass(class)
    if type(class) == "string" then
        self._data.class = class
    end
end

function Character:GetRace()
    return self._data.race
end

function Character:SetRace(racesArray)
    if type(racesArray) == "table" and #racesArray > 0 and #racesArray <= 2 then
        self._data.race = racesArray
    end
end

function Character:GetRaceTalents()
    return self._data.raceTalents
end

function Character:SetRaceTalents(talentsTable)
    if type(talentsTable) == "table" then
        self._data.raceTalents = talentsTable
    end
end

function Character:GetAttributes()
    return self._data.attributes
end

function Character:SetAttribute(attrName, value)
    if type(attrName) == "string" and type(value) == "number" then
        self._data.attributes[attrName] = value
    end
end

function Character:GetTalents()
    return self._data.talents
end

function Character:SetTalent(talentName, value)
    if type(talentName) == "string" and type(value) == "number" then
        self._data.talents[talentName] = value
    end
end

function Character:GetPositiveTraits()
    return self._data.positiveTraits
end

function Character:SetPositiveTraits(traitsArray)
    if type(traitsArray) == "table" then
        self._data.positiveTraits = traitsArray
    end
end

function Character:GetNegativeTraits()
    return self._data.negativeTraits
end

function Character:SetNegativeTraits(traitsArray)
    if type(traitsArray) == "table" then
        self._data.negativeTraits = traitsArray
    end
end

function Character:GetWorgenCurse()
    return self._data.worgenCurse
end

function Character:SetWorgenCurse(value)
    if type(value) == "boolean" then
        self._data.worgenCurse = value
    end
end

function Character:GetMaxHealth()
    local levelEntry = GAC:GetLevelEntry(self:GetCategory(), self:GetLevel())
    local baseHealth = levelEntry and levelEntry.maxHealth or 10
    local constitution = self:GetAttributes()["constitution"] or 0
    return math.max(1, baseHealth + constitution)
end

function Character:GetHealthPoints()
    self._data.healthPoints.max = self:GetMaxHealth()
    if self._data.healthPoints.current > self._data.healthPoints.max then
        self._data.healthPoints.current = self._data.healthPoints.max
    end
    return self._data.healthPoints
end

function Character:SetHealthPoints(current, max)
    if type(max) == "number" then self._data.healthPoints.max = max end
    self._data.healthPoints.max = self:GetMaxHealth()
    if type(current) == "number" then 
        self._data.healthPoints.current = math.min(current, self._data.healthPoints.max)
    end
end

function Character:GetShieldPoints()
    return self._data.shieldPoints
end

function Character:SetShieldPoints(current)
    if type(current) == "number" then
        self._data.shieldPoints.current = math.max(current, 0)
    end
end

function Character:GetManaPoints()
    return self._data.manapoints
end

function Character:SetManaPoints(current, max)
    if type(max) == "number" then self._data.manapoints.max = max end
    if type(current) == "number" then 
        self._data.manapoints.current = math.min(math.max(current, 0), self._data.manapoints.max)
    end
end

function Character:GetSpiritPoints()
    return self._data.spiritPoints
end

function Character:SetSpiritPoints(current, max)
    if type(max) == "number" then self._data.spiritPoints.max = max end
    if type(current) == "number" then 
        self._data.spiritPoints.current = math.min(math.max(current, 0), self._data.spiritPoints.max)
    end
end

function Character:GetExperience()
    return self._data.experience
end

function Character:SetExperience(current, max)
    if type(max) == "number" then self._data.experience.max = max end
    if type(current) == "number" then 
        self._data.experience.current = math.max(current, 0)
    end
end

function Character:GetEquippedItems()
    return self._data.equippedItems
end

function Character:SetEquippedItem(slot, itemInstance)
    if self._data.equippedItems[slot] ~= nil then
        self._data.equippedItems[slot] = itemInstance
    end
end

function Character:GetSkills()
    return self._data.skills
end

function Character:SetSkills(skillsArray)
    if type(skillsArray) == "table" then
        self._data.skills = skillsArray
    end
end

function Character:GetSpells()
    return self._data.spells
end

function Character:SetSpells(spellsArray)
    if type(spellsArray) == "table" then
        self._data.spells = spellsArray
    end
end

-- Utilidades
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

-- Exportar / Serializar datos
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
                if type(obj) ~= 'table' then return obj end
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

function Character:GetExportData()
    -- Método para obtener los datos estructurados
    return self:Serialize()
end

GAC.Character = Character
