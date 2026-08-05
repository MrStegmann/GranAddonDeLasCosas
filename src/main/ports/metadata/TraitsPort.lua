local TraitsDatabase = TraitsDatabase or require("src.main.domain.database.TraitsDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local TraitsPort = {}

--- Retrieves the full traits database (both positive and negative traits)
-- @return table read-only proxy of all traits
function TraitsPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(TraitsDatabase)
end

--- Retrieves the list of positive traits
-- @return table read-only proxy of positive traits
function TraitsPort.GetPositiveTraits()
    return ReadOnlyHelper.makeReadOnly(TraitsDatabase.PositiveTraits)
end

--- Retrieves the list of negative traits
-- @return table read-only proxy of negative traits
function TraitsPort.GetNegativeTraits()
    return ReadOnlyHelper.makeReadOnly(TraitsDatabase.NegativeTraits)
end

--- Retrieves a specific positive trait by its ID
-- @param id string
-- @return table|nil read-only proxy of trait or nil
function TraitsPort.GetPositiveTraitById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, trait in ipairs(TraitsDatabase.PositiveTraits) do
        if trait.id == id then
            return ReadOnlyHelper.makeReadOnly(trait)
        end
    end
    return nil
end

--- Retrieves a specific negative trait by its ID
-- @param id string
-- @return table|nil read-only proxy of trait or nil
function TraitsPort.GetNegativeTraitById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, trait in ipairs(TraitsDatabase.NegativeTraits) do
        if trait.id == id then
            return ReadOnlyHelper.makeReadOnly(trait)
        end
    end
    return nil
end

--- Retrieves a specific trait by its ID (checking positive first, then negative)
-- @param id string
-- @return table|nil read-only proxy of trait or nil
function TraitsPort.GetById(id)
    local trait = TraitsPort.GetPositiveTraitById(id)
    if trait then
        return trait
    end
    return TraitsPort.GetNegativeTraitById(id)
end

return TraitsPort
