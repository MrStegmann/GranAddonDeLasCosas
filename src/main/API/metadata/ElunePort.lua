local EluneDatabase = EluneDatabase or require("src.main.domain.database.EluneDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local ElunePort = {}

--- Retrieves all elune spells
-- @return table read-only proxy of all elune spells
function ElunePort.GetAll()
    return ReadOnlyHelper.makeReadOnly(EluneDatabase)
end

--- Retrieves a specific elune spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function ElunePort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(EluneDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return ElunePort
