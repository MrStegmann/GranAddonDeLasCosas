local addonName, addonTable = ...
local RaceDatabase = addonTable.Models.RaceDatabase
local ReadOnlyHelper = addonTable.API.ReadOnlyHelper

addonTable.API = addonTable.API or {}
local RacePort = {}
addonTable.API.RacePort = RacePort

--- Retrieves the full race database table
-- @return table read-only proxy of all races
function RacePort.GetAll()
    return ReadOnlyHelper.copyTable(RaceDatabase)
end

--- Alias for GetAll to match requirements
function RacePort.GetAllRaces()
    return RacePort.GetAll()
end

--- Retrieves a specific race entry by its ID
-- @param id string
-- @return table|nil read-only proxy of the race entry or nil
function RacePort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    local race = RaceDatabase[id]
    if not race then
        return nil
    end
    return ReadOnlyHelper.makeReadOnly(race)
end

--- Retrieves race traits (advantages and disadvantages)
-- @param raceID string
-- @return table|nil Table containing positive and negative traits, or nil
function RacePort.GetRaceTraits(raceID)
    local race = RaceDatabase[raceID]
    if not race then return nil end
    
    local traits = {
        positive = race.positiveTraits or {},
        negative = race.negativeTraits or {}
    }
    return ReadOnlyHelper.makeReadOnly(traits)
end

