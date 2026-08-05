local ArmorDatabase = ArmorDatabase or require("src.main.domain.database.ArmorDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local ArmorPort = {}

--- Retrieves the full armor database (both ArmorList and ArmorReinforcement)
-- @return table read-only proxy of armor database
function ArmorPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(ArmorDatabase)
end

--- Retrieves armor data by armor type ID ("clothes", "leather", "mail", "plate")
-- @param id string
-- @return table|nil read-only proxy of armor entry or nil
function ArmorPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    local armor = ArmorDatabase.ArmorList and ArmorDatabase.ArmorList[id]
    if not armor then
        return nil
    end
    return ReadOnlyHelper.makeReadOnly(armor)
end

--- Retrieves reinforcement data by type ID ("leather", "mail", "plate")
-- @param id string
-- @return table|nil read-only proxy of reinforcement entry or nil
function ArmorPort.GetReinforcementById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    local reinf = ArmorDatabase.ArmorReinforcement and ArmorDatabase.ArmorReinforcement[id]
    if not reinf then
        return nil
    end
    return ReadOnlyHelper.makeReadOnly(reinf)
end

return ArmorPort
