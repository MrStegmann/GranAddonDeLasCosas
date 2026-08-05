local ChiDatabase = ChiDatabase or require("src.main.domain.database.ChiDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local ChiPort = {}

--- Retrieves all chi spells
-- @return table read-only proxy of all chi spells
function ChiPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(ChiDatabase)
end

--- Retrieves a specific chi spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function ChiPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(ChiDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return ChiPort
