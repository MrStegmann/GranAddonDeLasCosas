local addonName, addonTable = ...
local LevelDatabase = addonTable.Models.LevelDatabase
local ReadOnlyHelper = addonTable.API.ReadOnlyHelper

addonTable.API = addonTable.API or {}
local LevelPort = {}
addonTable.API.LevelPort = LevelPort

--- Retrieves the full level progression database
-- @return table read-only proxy of all level categories
function LevelPort.GetAll()
    return ReadOnlyHelper.copyTable(LevelDatabase)
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

--- Retrieves all available categories
-- @return table Array of category names
function LevelPort.GetCategories()
    local categories = {}
    for k, _ in pairs(LevelDatabase) do
        table.insert(categories, k)
    end
    return categories
end

--- Retrieves the list of levels for a specific category
-- @param category string Category ID
-- @return table Array of level numbers (as strings or numbers) available in that category
function LevelPort.GetLevelsByCategory(category)
    local catData = LevelDatabase[category]
    if not catData then return {} end
    
    local levels = {}
    for level, _ in pairs(catData) do
        table.insert(levels, level)
    end
    -- Sort levels numerically
    table.sort(levels, function(a, b) return tonumber(a) < tonumber(b) end)
    return levels
end

