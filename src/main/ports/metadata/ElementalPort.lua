local ElementalDatabase = ElementalDatabase or require("src.main.domain.database.ElementalDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local ElementalPort = {}

--- Retrieves all elemental spells
-- @return table read-only proxy of all elemental spells
function ElementalPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(ElementalDatabase)
end

--- Retrieves a specific elemental spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function ElementalPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(ElementalDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return ElementalPort
