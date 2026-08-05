local RaceDatabase = RaceDatabase or require("src.main.domain.database.RaceDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local RacePort = {}

--- Retrieves the full race database table
-- @return table read-only proxy of all races
function RacePort.GetAll()
    return ReadOnlyHelper.makeReadOnly(RaceDatabase)
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

return RacePort
