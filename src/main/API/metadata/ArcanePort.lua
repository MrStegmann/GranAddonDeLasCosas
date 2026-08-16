local ArcaneDatabase = ArcaneDatabase or require("src.main.domain.database.ArcaneDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local ArcanePort = {}

--- Retrieves all arcane spells
-- @return table read-only proxy of all arcane spells
function ArcanePort.GetAll()
    return ReadOnlyHelper.makeReadOnly(ArcaneDatabase)
end

--- Retrieves a specific arcane spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function ArcanePort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(ArcaneDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return ArcanePort
