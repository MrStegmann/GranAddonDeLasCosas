--- @class Heroic
--- Domain model for narrative Heroic capabilities matching Heroic.ts schema interface.
local Heroic = {}
Heroic.__index = Heroic

--- Creates a new Heroic model instance with schema validation.
--- @param raw table|nil
--- @return Heroic
function Heroic.create(raw)
    raw = type(raw) == "table" and raw or {}

    local validTypes = { active = true, passive = true }
    local heroicType = validTypes[raw.type] and raw.type or "active"

    local instance = {
        id = type(raw.id) == "string" and raw.id or "heroic_1",
        name = type(raw.name) == "string" and raw.name or "Heroic Action",
        type = heroicType,
        description = type(raw.description) == "string" and raw.description or "",
        version = type(raw.version) == "number" and raw.version or 1,
    }

    return setmetatable(instance, Heroic)
end

_G.Heroic = Heroic
return Heroic
