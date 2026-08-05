--- @class Skill
--- Domain model for actionable skills matching Skill.ts schema interface.
local Skill = {}
Skill.__index = Skill

--- Creates a new Skill model instance with schema validation.
--- @param raw table|nil
--- @return Skill
function Skill.create(raw)
    raw = type(raw) == "table" and raw or {}

    local validTypes = { active = true, passive = true }
    local skillType = validTypes[raw.type] and raw.type or "active"

    local instance = {
        id = type(raw.id) == "string" and raw.id or "skill_1",
        name = type(raw.name) == "string" and raw.name or "Skill",
        type = skillType,
        description = type(raw.description) == "string" and raw.description or "",
        slotCost = type(raw.slotCost) == "number" and raw.slotCost or 1,
        actionCost = type(raw.actionCost) == "number" and raw.actionCost or 1,
        effectTurns = type(raw.effectTurns) == "number" and raw.effectTurns or 1,
        cooldownTurns = type(raw.cooldownTurns) == "number" and raw.cooldownTurns or 0,
    }

    return setmetatable(instance, Skill)
end

_G.Skill = Skill
return Skill
