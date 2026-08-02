--- @class Weapon
--- Domain model for weapons matching weapons-type.ts schema interface.
local Weapon = {}
Weapon.__index = Weapon

--- Helper to sanitize attack metadata block (for throwable / twoHanded).
local function sanitizeAttackMetaData(meta)
    if type(meta) ~= "table" then return nil end
    return {
        talent = type(meta.talent) == "table" and meta.talent or {},
        damage = type(meta.damage) == "number" and meta.damage or 0,
        diceNumber = type(meta.diceNumber) == "number" and meta.diceNumber or 1,
        damageType = (meta.damageType == "slashing" or meta.damageType == "piercing" or meta.damageType == "crushing") and meta.damageType or "slashing",
    }
end

--- Creates a new Weapon model instance with schema validation.
--- @param raw table|nil
--- @return Weapon
function Weapon.create(raw)
    raw = type(raw) == "table" and raw or {}

    local instance = {
        id = type(raw.id) == "string" and raw.id or (type(raw.weaponId) == "string" and raw.weaponId or "dagger"),
        talent = type(raw.talent) == "table" and raw.talent or { "agileCombat" },
        damage = type(raw.damage) == "number" and raw.damage or 4,
        diceNumber = type(raw.diceNumber) == "number" and raw.diceNumber or 1,
        damageType = (raw.damageType == "slashing" or raw.damageType == "piercing" or raw.damageType == "crushing") and raw.damageType or "piercing",
        throwable = sanitizeAttackMetaData(raw.throwable),
        twoHanded = sanitizeAttackMetaData(raw.twoHanded),
    }

    return setmetatable(instance, Weapon)
end

_G.Weapon = Weapon
return Weapon
