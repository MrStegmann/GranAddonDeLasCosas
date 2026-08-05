local LevelDatabase = LevelDatabase or require("src.main.domain.database.LevelDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local LevelPort = {}

--- Retrieves the full level progression database
-- @return table read-only proxy of all level categories
function LevelPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(LevelDatabase)
end

--- Retrieves a specific level category or level entry by category ID
-- @param id string Category ID ("noob", "normal", "elite", "boss")
-- @return table|nil read-only proxy of the category table or nil
function LevelPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    local category = LevelDatabase[id]
    if not category then
        return nil
    end
    return ReadOnlyHelper.makeReadOnly(category)
end

return LevelPort
