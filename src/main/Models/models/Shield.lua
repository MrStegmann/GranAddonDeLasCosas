--- @class Shield
--- Domain model for shields matching Item.ts (Shield) schema interface.
local Shield = {}
Shield.__index = Shield

--- Creates a new Shield model instance with schema validation.
--- @param raw table|nil
--- @return Shield
function Shield.create(raw)
    raw = type(raw) == "table" and raw or {}

    local validTypes = { light = true, medium = true, heavy = true }
    local shieldType = validTypes[raw.type] and raw.type or (validTypes[raw.id] and raw.id or "medium")

    local reqs = {}
    if type(raw.requirements) == "table" then
        for _, req in ipairs(raw.requirements) do
            if type(req) == "table" and type(req.talentId) == "string" and type(req.value) == "number" then
                table.insert(reqs, { talentId = req.talentId, value = req.value })
            end
        end
    end

    local pens = {}
    if type(raw.penalties) == "table" then
        for _, pen in ipairs(raw.penalties) do
            if type(pen) == "table" and type(pen.talentId) == "string" and type(pen.value) == "number" then
                table.insert(pens, { talentId = pen.talentId, value = pen.value })
            end
        end
    end

    local instance = {
        id = type(raw.id) == "string" and raw.id or shieldType,
        name = type(raw.name) == "string" and raw.name or "Shield",
        quality = type(raw.quality) == "string" and raw.quality or "common",
        description = type(raw.description) == "string" and raw.description or "",
        type = shieldType,
        slot = "offHand",
        talent = type(raw.talent) == "table" and raw.talent or { "brutality" },
        damage = type(raw.damage) == "number" and raw.damage or 6,
        diceNumber = type(raw.diceNumber) == "number" and raw.diceNumber or 1,
        damageType = (raw.damageType == "slashing" or raw.damageType == "piercing" or raw.damageType == "crushing") and raw.damageType or "crushing",
        physicalReduction = type(raw.physicalReduction) == "number" and raw.physicalReduction or 1,
        magicalReduction = type(raw.magicalReduction) == "number" and raw.magicalReduction or 0,
        durability = type(raw.durability) == "number" and raw.durability or 15,
        movementPenalty = type(raw.movementPenalty) == "number" and raw.movementPenalty or 0,
        requirements = reqs,
        penalties = pens,
    }

    return setmetatable(instance, Shield)
end

_G.Shield = Shield
return Shield
