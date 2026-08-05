local WeaponsDatabase = WeaponsDatabase or require("src.main.domain.database.WeaponsDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local WeaponsPort = {}

--- Retrieves the full weapons database table
-- @return table read-only proxy of all weapons
function WeaponsPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(WeaponsDatabase)
end

--- Retrieves a specific weapon entry by its ID
-- @param id string
-- @return table|nil read-only proxy of the weapon entry or nil
function WeaponsPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    local weapon = WeaponsDatabase[id]
    if not weapon then
        return nil
    end
    return ReadOnlyHelper.makeReadOnly(weapon)
end

return WeaponsPort
