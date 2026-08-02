--- RacePort
--- Read-only access port for RaceDatabase metadata.
local RacePort = {}

local function getDB()
    return _G.GAC_RaceDatabase or (require and pcall(require, "src.main.domain.database.RaceDatabase") and _G.GAC_RaceDatabase or nil)
end

--- Returns Race object by race ID.
--- @param raceId string
--- @return table|nil
function RacePort.getRace(raceId)
    local db = getDB()
    if db and db.RaceList then
        return db.RaceList[raceId]
    end
    return nil
end

--- Returns Worgen curse race object for specified form ('human' or 'worgen').
--- @param form string
--- @return table|nil
function RacePort.getWorgenCurse(form)
    local db = getDB()
    if db and db.WorgenCurse then
        return db.WorgenCurse[form]
    end
    return nil
end

--- Returns all defined races.
--- @return table
function RacePort.getAllRaces()
    local db = getDB()
    return db and db.RaceList or {}
end

_G.GAC_RacePort = RacePort
return RacePort
