--- @class Armor
--- Domain model for armor pieces equipped on a character.
local Armor = {}
Armor.__index = Armor

--- Creates a new Armor model instance with schema validation.
--- @param raw table|nil
--- @return Armor
function Armor.create(raw)
    raw = type(raw) == "table" and raw or {}
    local rawStats = type(raw.stats) == "table" and raw.stats or {}

    local instance = {
        name = type(raw.name) == "string" and raw.name or "",
        quality = type(raw.quality) == "string" and raw.quality or "common",
        physicalReduction = type(raw.physicalReduction) == "number" and raw.physicalReduction or 0,
        magicalReduction = type(raw.magicalReduction) == "number" and raw.magicalReduction or 0,
        durability = type(raw.durability) == "number" and raw.durability or 100,
        type = type(raw.type) == "string" and raw.type or "Cloth",
        slot = (raw.slot == "head" or raw.slot == "chest" or raw.slot == "hands" or raw.slot == "legs") and raw.slot or "head",
        stats = {
            pircing = type(rawStats.pircing) == "string" and rawStats.pircing or "0",
            slashing = type(rawStats.slashing) == "string" and rawStats.slashing or "0",
            concussion = type(rawStats.concussion) == "string" and rawStats.concussion or "0",
        },
    }

    return setmetatable(instance, Armor)
end

return Armor
