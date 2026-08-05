local FelDatabase = FelDatabase or require("src.main.domain.database.FelDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local FelPort = {}

--- Retrieves all fel spells
-- @return table read-only proxy of all fel spells
function FelPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(FelDatabase)
end

--- Retrieves a specific fel spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function FelPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(FelDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return FelPort
