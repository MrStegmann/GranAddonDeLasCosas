local HolyLightDatabase = HolyLightDatabase or require("src.main.domain.database.HolyLightDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local HolyLightPort = {}

--- Retrieves all holy light spells
-- @return table read-only proxy of all holy light spells
function HolyLightPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(HolyLightDatabase)
end

--- Retrieves a specific holy light spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function HolyLightPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(HolyLightDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return HolyLightPort
