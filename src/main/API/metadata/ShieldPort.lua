local ShieldDatabase = ShieldDatabase or require("src.main.domain.database.ShieldDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local ShieldPort = {}

--- Retrieves the full shield database table
-- @return table read-only proxy of all shields
function ShieldPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(ShieldDatabase)
end

--- Retrieves a specific shield entry by its ID ("light", "medium", "heavy")
-- @param id string
-- @return table|nil read-only proxy of shield entry or nil
function ShieldPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    local shield = ShieldDatabase[id]
    if not shield then
        return nil
    end
    return ReadOnlyHelper.makeReadOnly(shield)
end

return ShieldPort
