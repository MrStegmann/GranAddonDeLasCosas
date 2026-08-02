--- @class Shield
--- Domain model for shields equipped in offHand.
local Shield = {}
Shield.__index = Shield

--- Creates a new Shield model instance with schema validation.
--- @param raw table|nil
--- @return Shield
function Shield.create(raw)
    raw = type(raw) == "table" and raw or {}

    local validTypes = { light = true, medium = true, heavy = true }
    local shieldType = validTypes[raw.type] and raw.type or "medium"

    local instance = {
        name = type(raw.name) == "string" and raw.name or "",
        quality = type(raw.quality) == "string" and raw.quality or "common",
        type = shieldType,
        slot = "offHand",
        durability = type(raw.durability) == "number" and raw.durability or 100,
    }

    return setmetatable(instance, Shield)
end

return Shield
