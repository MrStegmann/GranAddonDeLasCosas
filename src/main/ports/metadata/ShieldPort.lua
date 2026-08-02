--- ShieldPort
--- Read-only access port for ShieldDatabase metadata.
local ShieldPort = {}

local function getDB()
    return _G.GAC_ShieldDatabase or (require and pcall(require, "src.main.domain.database.ShieldDatabase") and _G.GAC_ShieldDatabase or nil)
end

--- Returns Shield object for specified shield type ('light', 'medium', 'heavy').
--- @param shieldType string
--- @return table|nil
function ShieldPort.getShield(shieldType)
    local db = getDB()
    if db and db.ShieldList then
        return db.ShieldList[shieldType]
    end
    return nil
end

--- Returns all defined shield types.
--- @return table
function ShieldPort.getAllShields()
    local db = getDB()
    return db and db.ShieldList or {}
end

_G.GAC_ShieldPort = ShieldPort
return ShieldPort
