--- ArmorPort
--- Read-only access port for ArmorDatabase metadata.
local ArmorPort = {}

local function getDB()
    return _G.GAC_ArmorDatabase or (require and pcall(require, "src.main.domain.database.ArmorDatabase") and _G.GAC_ArmorDatabase or nil)
end

--- Returns the Armor metadata object for a given armor type (clothes, leather, mail, plate).
--- @param armorType string
--- @return table|nil
function ArmorPort.getArmor(armorType)
    local db = getDB()
    if db and db.ArmorList then
        return db.ArmorList[armorType]
    end
    return nil
end

--- Returns all armor metadata definitions.
--- @return table
function ArmorPort.getAllArmor()
    local db = getDB()
    return db and db.ArmorList or {}
end

--- Returns the combinable rules for a given armor type.
--- @param armorType string
--- @return table|nil
function ArmorPort.getCombinableRules(armorType)
    local armor = ArmorPort.getArmor(armorType)
    return armor and armor.combinable or nil
end

_G.GAC_ArmorPort = ArmorPort
return ArmorPort
