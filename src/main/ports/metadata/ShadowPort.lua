local ShadowDatabase = ShadowDatabase or require("src.main.domain.database.ShadowDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local ShadowPort = {}

--- Retrieves all shadow spells
-- @return table read-only proxy of all shadow spells
function ShadowPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(ShadowDatabase)
end

--- Retrieves a specific shadow spell by ID
-- @param id string
-- @return table|nil read-only proxy of spell entry or nil
function ShadowPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, spell in ipairs(ShadowDatabase) do
        if spell.id == id then
            return ReadOnlyHelper.makeReadOnly(spell)
        end
    end
    return nil
end

return ShadowPort
