local NecromanceDatabase = NecromanceDatabase or require("src.main.domain.database.NecromanceDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local NecromancePort = {}

--- Retrieves all necromance spells
-- @return table read-only proxy of all necromance spells
function NecromancePort.GetAll()
    return ReadOnlyHelper.makeReadOnly(NecromanceDatabase)
end

--- Retrieves a specific necromance spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function NecromancePort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(NecromanceDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return NecromancePort
