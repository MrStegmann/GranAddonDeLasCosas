--- @class Spell
--- Domain model for actionable spells matching Spell.ts schema interface.
local Spell = {}
Spell.__index = Spell

--- Creates a new Spell model instance with schema validation.
--- @param raw table|nil
--- @return Spell
function Spell.create(raw)
    raw = type(raw) == "table" and raw or {}

    local validSpellTypes = { cantrip = true, fast = true, basic = true, potent = true }
    local spellType = validSpellTypes[raw.spellType] and raw.spellType or "basic"

    local instance = {
        id = type(raw.id) == "string" and raw.id or "spell_1",
        name = type(raw.name) == "string" and raw.name or "Spell",
        description = type(raw.description) == "string" and raw.description or "",
        slotCost = type(raw.slotCost) == "number" and raw.slotCost or 1,
        actionCost = type(raw.actionCost) == "number" and raw.actionCost or 1,
        turnEffects = type(raw.turnEffects) == "number" and raw.turnEffects or 1,
        cooldownTurns = type(raw.cooldownTurns) == "number" and raw.cooldownTurns or 0,
        category = type(raw.category) == "string" and raw.category or "arcane",
        spellType = spellType,
        type = type(raw.type) == "string" and raw.type or "arcane",
        resourceCost = type(raw.resourceCost) == "number" and raw.resourceCost or 0,
        power = type(raw.power) == "number" and raw.power or 0,
        triggerOpportunityAttack = raw.triggerOpportunityAttack == true,
        isCanalizable = raw.isCanalizable == true,
    }

    return setmetatable(instance, Spell)
end

_G.Spell = Spell
return Spell
