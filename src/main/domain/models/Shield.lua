--- @class Shield
--- Domain model for shields matching shield-types.ts schema interface.
local Shield = {}
Shield.__index = Shield

--- Creates a new Shield model instance with schema validation.
--- @param raw table|nil
--- @return Shield
function Shield.create(raw)
    raw = type(raw) == "table" and raw or {}

    local validTypes = { light = true, medium = true, heavy = true }
    local shieldType = validTypes[raw.id] and raw.id or (validTypes[raw.type] and raw.type or "medium")

    local instance = {
        id = shieldType,
        talent = type(raw.talent) == "table" and raw.talent or { "brutality" },
        damage = type(raw.damage) == "number" and raw.damage or 6,
        diceNumber = type(raw.diceNumber) == "number" and raw.diceNumber or 1,
        damageType = (raw.damageType == "slashing" or raw.damageType == "piercing" or raw.damageType == "crushing") and raw.damageType or "crushing",
        physicalReduction = type(raw.physicalReduction) == "number" and raw.physicalReduction or 1,
        magicalReduction = type(raw.magicalReduction) == "number" and raw.magicalReduction or 0,
        durability = type(raw.durability) == "number" and raw.durability or 15,
        movementPenalty = type(raw.movementPenalty) == "number" and raw.movementPenalty or 0,
        requirements = type(raw.requirements) == "table" and raw.requirements or nil,
        penalties = type(raw.penalties) == "table" and raw.penalties or nil,
    }

    return setmetatable(instance, Shield)
end

_G.Shield = Shield
return Shield
