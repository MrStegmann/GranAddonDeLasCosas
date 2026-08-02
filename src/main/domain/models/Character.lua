--- @class Character
--- Domain model representing character sheet data and persistent stats.
local Character = {}
Character.__index = Character

--- Returns default raw character sheet data structure.
--- @return table
function Character.createDefaultData()
    return {
        fullName = "",
        class = "",
        category = "normal",
        level = 1,
        healthPoints = 20,
        resources = {
            mana = 10,
            spirit = 10,
        },
        initiative = 100,
        offensiveActions = 2,
        canAttack = true,
        criticalStrickRange = 20,
        criticalFailureRange = 1,
        isAmbushActive = false,
        defensiveActions = 1,
        canIntercept = true,
        movement = 20,
        canPhysicalPerceptionCheck = true,
        canMagicPerceptionCheck = true,
        canTrade = true,
        canAskAction = true,
        isFlanked = false,
        isDowned = false,
        isStunned = false,
        isHighest = false,
        isBacked = false,
        isBlinded = false,
        states = {},
        attributes = {
            strength = 0,
            dexterity = 0,
            constitution = 0,
            intelligence = 0,
            willpower = 0,
            wisdom = 0,
            charisma = 0,
        },
        talents = {
            strength = {
                twoHandedCombat = 0,
                oneHandedCombat = 0,
                athletics = 0,
                brutality = 0,
                sturdyDefense = 0,
            },
            dexterity = {
                precision = 0,
                agileCombat = 0,
                acrobatics = 0,
                stealth = 0,
                sleightOfHand = 0,
                agileDefense = 0,
            },
            constitution = {
                resilience = 0,
                stunResistance = 0,
                knockdownResistance = 0,
                coldResistance = 0,
                heatResistance = 0,
                fortitude = 0,
            },
            intelligence = {
                arcane = 0,
                fel = 0,
                nature = 0,
                shadow = 0,
                necromancy = 0,
            },
            willpower = {
                magicResistance = 0,
                lossOfControlResistance = 0,
                faith = 0,
                elementalConnection = 0,
                chi = 0,
                manaRegeneration = 0,
            },
            wisdom = {
                animalConnection = 0,
                survival = 0,
                perception = 0,
            },
            charisma = {
                persuasion = 0,
                diplomacy = 0,
                commerce = 0,
                provocation = 0,
                seduction = 0,
                performance = 0,
            },
        },
        race = {
            main = "Humano",
            secondary = nil,
            talents = {},
        },
        isWorgen = false,
        positiveTraits = {},
        negativeTraits = {},
        equipment = {
            head = nil,
            chest = nil,
            hands = nil,
            legs = nil,
            mainHand = nil,
            offHand = nil,
            ranged = nil,
        },
        pets = {},
    }
end

--- Helper function to sanitize a numeric attribute value.
local function sanitizeNum(val, default)
    return type(val) == "number" and val or (default or 0)
end

--- Helper function to sanitize a boolean attribute value.
local function sanitizeBool(val, default)
    if type(val) == "boolean" then
        return val
    end
    return default
end

--- Sanitizes equipment slots and wraps item sub-tables into domain models if available.
local function sanitizeEquipment(eq)
    eq = type(eq) == "table" and eq or {}
    local result = {}

    local ArmorModel = _G.Armor or (require and pcall(require, "src.main.domain.models.Armor") and require("src.main.domain.models.Armor") or nil)
    local WeaponModel = _G.Weapon or (require and pcall(require, "src.main.domain.models.Weapon") and require("src.main.domain.models.Weapon") or nil)
    local ShieldModel = _G.Shield or (require and pcall(require, "src.main.domain.models.Shield") and require("src.main.domain.models.Shield") or nil)

    local armorSlots = { head = true, chest = true, hands = true, legs = true }
    for slot, _ in pairs(armorSlots) do
        if type(eq[slot]) == "table" then
            result[slot] = (ArmorModel and ArmorModel.create) and ArmorModel.create(eq[slot]) or eq[slot]
        else
            result[slot] = nil
        end
    end

    if type(eq.mainHand) == "table" then
        result.mainHand = (WeaponModel and WeaponModel.create) and WeaponModel.create(eq.mainHand) or eq.mainHand
    else
        result.mainHand = nil
    end

    if type(eq.offHand) == "table" then
        if eq.offHand.durability ~= nil and eq.offHand.damageMod == nil then
            result.offHand = (ShieldModel and ShieldModel.create) and ShieldModel.create(eq.offHand) or eq.offHand
        else
            result.offHand = (WeaponModel and WeaponModel.create) and WeaponModel.create(eq.offHand) or eq.offHand
        end
    else
        result.offHand = nil
    end

    if type(eq.ranged) == "table" then
        result.ranged = (WeaponModel and WeaponModel.create) and WeaponModel.create(eq.ranged) or eq.ranged
    else
        result.ranged = nil
    end

    return result
end

--- Creates a Character model instance from raw input data with schema validation.
--- @param raw table|nil
--- @return Character
function Character.create(raw)
    local defaults = Character.createDefaultData()
    raw = type(raw) == "table" and raw or {}

    local validCategories = { noob = true, normal = true, elite = true, boss = true }

    local rawRes = type(raw.resources) == "table" and raw.resources or {}
    local rawAttr = type(raw.attributes) == "table" and raw.attributes or {}
    local rawTalents = type(raw.talents) == "table" and raw.talents or {}
    local rawRace = type(raw.race) == "table" and raw.race or {}

    local strT = type(rawTalents.strength) == "table" and rawTalents.strength or {}
    local dexT = type(rawTalents.dexterity) == "table" and rawTalents.dexterity or {}
    local conT = type(rawTalents.constitution) == "table" and rawTalents.constitution or {}
    local intT = type(rawTalents.intelligence) == "table" and rawTalents.intelligence or {}
    local wilT = type(rawTalents.willpower) == "table" and rawTalents.willpower or {}
    local wisT = type(rawTalents.wisdom) == "table" and rawTalents.wisdom or {}
    local chaT = type(rawTalents.charisma) == "table" and rawTalents.charisma or {}

    local instance = {
        fullName = type(raw.fullName) == "string" and raw.fullName or defaults.fullName,
        class = type(raw.class) == "string" and raw.class or defaults.class,
        category = validCategories[raw.category] and raw.category or defaults.category,
        level = sanitizeNum(raw.level, defaults.level),
        healthPoints = sanitizeNum(raw.healthPoints, defaults.healthPoints),
        resources = {
            mana = sanitizeNum(rawRes.mana, defaults.resources.mana),
            spirit = sanitizeNum(rawRes.spirit, defaults.resources.spirit),
        },
        initiative = sanitizeNum(raw.initiative, defaults.initiative),
        offensiveActions = sanitizeNum(raw.offensiveActions, defaults.offensiveActions),
        canAttack = sanitizeBool(raw.canAttack, defaults.canAttack),
        criticalStrickRange = sanitizeNum(raw.criticalStrickRange, defaults.criticalStrickRange),
        criticalFailureRange = sanitizeNum(raw.criticalFailureRange, defaults.criticalFailureRange),
        isAmbushActive = sanitizeBool(raw.isAmbushActive, defaults.isAmbushActive),
        defensiveActions = sanitizeNum(raw.defensiveActions, defaults.defensiveActions),
        canIntercept = sanitizeBool(raw.canIntercept, defaults.canIntercept),
        movement = sanitizeNum(raw.movement, defaults.movement),
        canPhysicalPerceptionCheck = sanitizeBool(raw.canPhysicalPerceptionCheck, defaults.canPhysicalPerceptionCheck),
        canMagicPerceptionCheck = sanitizeBool(raw.canMagicPerceptionCheck, defaults.canMagicPerceptionCheck),
        canTrade = sanitizeBool(raw.canTrade, defaults.canTrade),
        canAskAction = sanitizeBool(raw.canAskAction, defaults.canAskAction),
        isFlanked = sanitizeBool(raw.isFlanked, defaults.isFlanked),
        isDowned = sanitizeBool(raw.isDowned, defaults.isDowned),
        isStunned = sanitizeBool(raw.isStunned, defaults.isStunned),
        isHighest = sanitizeBool(raw.isHighest, defaults.isHighest),
        isBacked = sanitizeBool(raw.isBacked, defaults.isBacked),
        isBlinded = sanitizeBool(raw.isBlinded, defaults.isBlinded),
        states = type(raw.states) == "table" and raw.states or {},
        attributes = {
            strength = sanitizeNum(rawAttr.strength, 0),
            dexterity = sanitizeNum(rawAttr.dexterity, 0),
            constitution = sanitizeNum(rawAttr.constitution, 0),
            intelligence = sanitizeNum(rawAttr.intelligence, 0),
            willpower = sanitizeNum(rawAttr.willpower, 0),
            wisdom = sanitizeNum(rawAttr.wisdom, 0),
            charisma = sanitizeNum(rawAttr.charisma, 0),
        },
        talents = {
            strength = {
                twoHandedCombat = sanitizeNum(strT.twoHandedCombat, 0),
                oneHandedCombat = sanitizeNum(strT.oneHandedCombat, 0),
                athletics = sanitizeNum(strT.athletics, 0),
                brutality = sanitizeNum(strT.brutality, 0),
                sturdyDefense = sanitizeNum(strT.sturdyDefense, 0),
            },
            dexterity = {
                precision = sanitizeNum(dexT.precision, 0),
                agileCombat = sanitizeNum(dexT.agileCombat, 0),
                acrobatics = sanitizeNum(dexT.acrobatics, 0),
                stealth = sanitizeNum(dexT.stealth, 0),
                sleightOfHand = sanitizeNum(dexT.sleightOfHand, 0),
                agileDefense = sanitizeNum(dexT.agileDefense, 0),
            },
            constitution = {
                resilience = sanitizeNum(conT.resilience, 0),
                stunResistance = sanitizeNum(conT.stunResistance, 0),
                knockdownResistance = sanitizeNum(conT.knockdownResistance, 0),
                coldResistance = sanitizeNum(conT.coldResistance, 0),
                heatResistance = sanitizeNum(conT.heatResistance, 0),
                fortitude = sanitizeNum(conT.fortitude, 0),
            },
            intelligence = {
                arcane = sanitizeNum(intT.arcane, 0),
                fel = sanitizeNum(intT.fel, 0),
                nature = sanitizeNum(intT.nature, 0),
                shadow = sanitizeNum(intT.shadow, 0),
                necromancy = sanitizeNum(intT.necromancy, 0),
            },
            willpower = {
                magicResistance = sanitizeNum(wilT.magicResistance, 0),
                lossOfControlResistance = sanitizeNum(wilT.lossOfControlResistance, 0),
                faith = sanitizeNum(wilT.faith, 0),
                elementalConnection = sanitizeNum(wilT.elementalConnection, 0),
                chi = sanitizeNum(wilT.chi, 0),
                manaRegeneration = sanitizeNum(wilT.manaRegeneration, 0),
            },
            wisdom = {
                animalConnection = sanitizeNum(wisT.animalConnection, 0),
                survival = sanitizeNum(wisT.survival, 0),
                perception = sanitizeNum(wisT.perception, 0),
            },
            charisma = {
                persuasion = sanitizeNum(chaT.persuasion, 0),
                diplomacy = sanitizeNum(chaT.diplomacy, 0),
                commerce = sanitizeNum(chaT.commerce, 0),
                provocation = sanitizeNum(chaT.provocation, 0),
                seduction = sanitizeNum(chaT.seduction, 0),
                performance = sanitizeNum(chaT.performance, 0),
            },
        },
        race = {
            main = type(rawRace.main) == "string" and rawRace.main or defaults.race.main,
            secondary = type(rawRace.secondary) == "string" and rawRace.secondary or nil,
            talents = type(rawRace.talents) == "table" and rawRace.talents or {},
        },
        isWorgen = raw.isWorgen == true,
        positiveTraits = type(raw.positiveTraits) == "table" and raw.positiveTraits or {},
        negativeTraits = type(raw.negativeTraits) == "table" and raw.negativeTraits or {},
        equipment = sanitizeEquipment(raw.equipment),
        pets = type(raw.pets) == "table" and raw.pets or {},
    }

    return setmetatable(instance, Character)
end

--- Instantiates a new default Character.
--- @return Character
function Character.createDefault()
    return Character.create(Character.createDefaultData())
end

return Character
