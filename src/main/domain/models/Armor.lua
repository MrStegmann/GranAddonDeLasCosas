--- @class Armor
--- Domain model for armor pieces matching armor-types.ts schema interface.
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

    local combinableRaw = type(raw.combinable) == "table" and raw.combinable or {}
    local combinable = {
        clothes = type(combinableRaw.clothes) == "table" and combinableRaw.clothes or { "allowed" },
        leather = type(combinableRaw.leather) == "table" and combinableRaw.leather or { "allowed" },
        mail = type(combinableRaw.mail) == "table" and combinableRaw.mail or { "allowed" },
        plate = type(combinableRaw.plate) == "table" and combinableRaw.plate or { "allowed" },
    }

    local instance = {
        id = armorId,
        type = armorType,
        physicalReduction = type(raw.physicalReduction) == "number" and raw.physicalReduction or 0,
        magicalReduction = type(raw.magicalReduction) == "number" and raw.magicalReduction or 0,
        durability = type(raw.durability) == "number" and raw.durability or 10,
        piercingDamage = type(raw.piercingDamage) == "number" and raw.piercingDamage or 0,
        slashingDamage = type(raw.slashingDamage) == "number" and raw.slashingDamage or 0,
        crushingDamage = type(raw.crushingDamage) == "number" and raw.crushingDamage or 0,
        combinable = combinable,
        requirements = type(raw.requirements) == "table" and raw.requirements or nil,
        penalties = type(raw.penalties) == "table" and raw.penalties or nil,
    }

    return setmetatable(instance, Armor)
end

_G.Armor = Armor
return Armor
