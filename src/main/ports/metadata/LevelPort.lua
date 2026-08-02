--- LevelPort
--- Read-only access port for LevelDatabase metadata matrix.
local LevelPort = {}

local function getDB()
    return _G.GAC_LevelDatabase or (require and pcall(require, "src.main.domain.database.LevelDatabase") and _G.GAC_LevelDatabase or nil)
end

--- Returns level entry for category and level.
--- @param category string 'noob'|'normal'|'elite'|'boss'
--- @param level number
--- @return table|nil
function LevelPort.getLevelEntry(category, level)
    local db = getDB()
    if db and db.levelTable and db.levelTable[category] then
        return db.levelTable[category][level]
    end
    return nil
end

--- Returns max health for category and level.
--- @param category string
--- @param level number
--- @return number|nil
function LevelPort.getMaxHealth(category, level)
    local entry = LevelPort.getLevelEntry(category, level)
    return entry and entry.maxHealth or nil
end

--- Returns exp required to level for category and level.
--- @param category string
--- @param level number
--- @return number|nil
function LevelPort.getExpToLevel(category, level)
    local entry = LevelPort.getLevelEntry(category, level)
    return entry and entry.expToLevel or nil
end

--- Returns full category level table.
--- @param category string
--- @return table|nil
function LevelPort.getCategoryLevelTable(category)
    local db = getDB()
    if db and db.levelTable then
        return db.levelTable[category]
    end
    return nil
end

_G.GAC_LevelPort = LevelPort
return LevelPort
