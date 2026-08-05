--- @class Armor
--- Domain model for armor pieces matching Item.ts (Armor) schema interface.
local Armor = {}
Armor.__index = Armor

--- Creates a new Armor model instance with schema validation.
--- @param raw table|nil
--- @return Armor
function Armor.create(raw)
    raw = type(raw) == "table" and raw or {}

    local validTypes = { clothes = true, leather = true, mail = true, plate = true }
    local armorType = validTypes[raw.type] and raw.type or "clothes"
    local armorId = type(raw.id) == "string" and raw.id or armorType

    local validSlots = { head = true, chest = true, hands = true, legs = true }
    local slot = validSlots[raw.slot] and raw.slot or "chest"

    local combinableRaw = type(raw.combinable) == "table" and raw.combinable or {}
    local combinable = {
        clothes = type(combinableRaw.clothes) == "table" and combinableRaw.clothes or { "allowed" },
        leather = type(combinableRaw.leather) == "table" and combinableRaw.leather or { "allowed" },
        mail = type(combinableRaw.mail) == "table" and combinableRaw.mail or { "allowed" },
        plate = type(combinableRaw.plate) == "table" and combinableRaw.plate or { "allowed" },
    }

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
        id = armorId,
        name = type(raw.name) == "string" and raw.name or "Armor Piece",
        quality = type(raw.quality) == "string" and raw.quality or "common",
        description = type(raw.description) == "string" and raw.description or "",
        type = armorType,
        slot = slot,
        physicalReduction = type(raw.physicalReduction) == "number" and raw.physicalReduction or 0,
        magicalReduction = type(raw.magicalReduction) == "number" and raw.magicalReduction or 0,
        durability = type(raw.durability) == "number" and raw.durability or 10,
        piercingDamage = type(raw.piercingDamage) == "number" and raw.piercingDamage or 0,
        slashingDamage = type(raw.slashingDamage) == "number" and raw.slashingDamage or 0,
        crushingDamage = type(raw.crushingDamage) == "number" and raw.crushingDamage or 0,
        movementPenalty = type(raw.movementPenalty) == "number" and raw.movementPenalty or 0,
        combinable = combinable,
        requirements = reqs,
        penalties = pens,
    }

    return setmetatable(instance, Armor)
end

_G.Armor = Armor
return Armor
