local NatureDatabase = NatureDatabase or require("src.main.domain.database.NatureDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local NaturePort = {}

--- Retrieves all nature spells
-- @return table read-only proxy of all nature spells
function NaturePort.GetAll()
    return ReadOnlyHelper.makeReadOnly(NatureDatabase)
end

--- Retrieves a specific nature spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function NaturePort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(NatureDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return NaturePort
