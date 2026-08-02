--- WeaponsPort
--- Read-only access port for WeaponsDatabase metadata.
local WeaponsPort = {}

local function getDB()
    return _G.GAC_WeaponsDatabase or (require and pcall(require, "src.main.domain.database.WeaponsDatabase") and _G.GAC_WeaponsDatabase or nil)
end

--- Returns Weapon object for specified weapon ID.
--- @param weaponId string
--- @return table|nil
function WeaponsPort.getWeapon(weaponId)
    local db = getDB()
    if db and db.WeaponList then
        return db.WeaponList[weaponId]
    end
    return nil
end

--- Returns all defined weapons.
--- @return table
function WeaponsPort.getAllWeapons()
    local db = getDB()
    return db and db.WeaponList or {}
end

_G.GAC_WeaponsPort = WeaponsPort
return WeaponsPort
