--- @class Profession
--- Domain model for trade professions matching Profession.ts schema interface.
local Profession = {}
Profession.__index = Profession

--- Creates a new Profession model instance with schema validation.
--- @param raw table|nil
--- @return Profession
function Profession.create(raw)
    raw = type(raw) == "table" and raw or {}

    local instance = {
        id = type(raw.id) == "string" and raw.id or "profession_1",
        name = type(raw.name) == "string" and raw.name or "Profession",
        description = type(raw.description) == "string" and raw.description or "",
        level = type(raw.level) == "number" and math.max(1, raw.level) or 1,
        currentExp = type(raw.currentExp) == "number" and math.max(0, raw.currentExp) or 0,
    }

    return setmetatable(instance, Profession)
end

_G.Profession = Profession
return Profession
