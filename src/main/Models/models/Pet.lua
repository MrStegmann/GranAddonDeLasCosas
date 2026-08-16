--- @class Pet
--- Domain model for pet companions matching Pet.ts schema interface.
local Pet = {}
Pet.__index = Pet

--- Creates a new Pet model instance with schema validation.
--- @param raw table|nil
--- @return Pet
function Pet.create(raw)
    raw = type(raw) == "table" and raw or {}

    local SkillModel = _G.Skill
    local SpellModel = _G.Spell

    local validTypes = { magical = true, normal = true }
    local petType = validTypes[raw.type] and raw.type or "normal"

    local rawRes = type(raw.resources) == "table" and raw.resources or {}
    local rawAttr = type(raw.attributes) == "table" and raw.attributes or {}

    local skillsList = {}
    if type(raw.skills) == "table" then
        for _, s in ipairs(raw.skills) do
            local skillObj = (SkillModel and SkillModel.create) and SkillModel.create(s) or s
            table.insert(skillsList, skillObj)
        end
    end

    local spellsList = {}
    if type(raw.spells) == "table" then
        for _, s in ipairs(raw.spells) do
            local spellObj = (SpellModel and SpellModel.create) and SpellModel.create(s) or s
            table.insert(spellsList, spellObj)
        end
    end

    local instance = {
        id = type(raw.id) == "string" and raw.id or "pet_1",
        name = type(raw.name) == "string" and raw.name or "Pet",
        level = type(raw.level) == "number" and math.max(1, raw.level) or 1,
        type = petType,

        -- Base CombatStats for Pet
        healthPoints = type(raw.healthPoints) == "number" and raw.healthPoints or (20 + (type(rawAttr.constitution) == "number" and rawAttr.constitution or 0)),
        resources = {
            mana = type(rawRes.mana) == "number" and rawRes.mana or 10,
            spirit = type(rawRes.spirit) == "number" and rawRes.spirit or 10,
        },
        initiative = type(raw.initiative) == "number" and raw.initiative or 100,
        offensiveActions = type(raw.offensiveActions) == "number" and raw.offensiveActions or 2,
        canAttack = raw.canAttack ~= false,
        criticalStrickRange = type(raw.criticalStrickRange) == "number" and raw.criticalStrickRange or 20,
        criticalFailureRange = type(raw.criticalFailureRange) == "number" and raw.criticalFailureRange or 1,
        isAmbushActive = raw.isAmbushActive == true,
        defensiveActions = type(raw.defensiveActions) == "number" and raw.defensiveActions or 1,
        canIntercept = raw.canIntercept ~= false,
        movement = type(raw.movement) == "number" and raw.movement or 20,
        canPhysicalPerceptionCheck = raw.canPhysicalPerceptionCheck ~= false,
        canMagicPerceptionCheck = raw.canMagicPerceptionCheck ~= false,
        canTrade = raw.canTrade ~= false,
        canAskAction = raw.canAskAction ~= false,
        isFlanked = raw.isFlanked == true,
        isDowned = raw.isDowned == true,
        isStunned = raw.isStunned == true,
        isHighest = raw.isHighest == true,
        isBacked = raw.isBacked == true,
        isBlinded = raw.isBlinded == true,
        states = type(raw.states) == "table" and raw.states or {},

        attributes = {
            strength = type(rawAttr.strength) == "number" and rawAttr.strength or 0,
            dexterity = type(rawAttr.dexterity) == "number" and rawAttr.dexterity or 0,
            constitution = type(rawAttr.constitution) == "number" and rawAttr.constitution or 0,
            intelligence = type(rawAttr.intelligence) == "number" and rawAttr.intelligence or 0,
            willpower = type(rawAttr.willpower) == "number" and rawAttr.willpower or 0,
            wisdom = type(rawAttr.wisdom) == "number" and rawAttr.wisdom or 0,
        },

        skills = skillsList,
        spells = spellsList,
    }

    return setmetatable(instance, Pet)
end

_G.Pet = Pet
return Pet
