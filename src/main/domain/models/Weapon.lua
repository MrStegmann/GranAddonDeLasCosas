--- @class Weapon
--- Domain model for weapons equipped by a character.
local Weapon = {}
Weapon.__index = Weapon

--- Creates a new Weapon model instance with schema validation.
--- @param raw table|nil
--- @return Weapon
function Weapon.create(raw)
    raw = type(raw) == "table" and raw or {}

    local validSlots = { mainHand = true, offHand = true, ranged = true }
    local slot = validSlots[raw.slot] and raw.slot or "mainHand"

    local instance = {
        name = type(raw.name) == "string" and raw.name or "",
        quality = type(raw.quality) == "string" and raw.quality or "common",
        damageMod = type(raw.damageMod) == "number" and raw.damageMod or 0,
        weaponId = type(raw.weaponId) == "string" and raw.weaponId or "",
        slot = slot,
    }

    return setmetatable(instance, Weapon)
end

return Weapon
