--- TraitsPort
--- Read-only access port for TraitsDatabase metadata.
local TraitsPort = {}

local function getDB()
    return _G.GAC_TraitsDatabase or (require and pcall(require, "src.main.domain.database.TraitsDatabase") and _G.GAC_TraitsDatabase or nil)
end

--- Returns PositiveTrait object by ID.
--- @param traitId string
--- @return table|nil
function TraitsPort.getPositiveTrait(traitId)
    local db = getDB()
    if not db or not db.PositiveTraitList then return nil end
    for _, trait in ipairs(db.PositiveTraitList) do
        if trait.id == traitId then
            return trait
        end
    end
    return nil
end

--- Returns NegativeTrait object by ID.
--- @param traitId string
--- @return table|nil
function TraitsPort.getNegativeTrait(traitId)
    local db = getDB()
    if not db or not db.NegativeTraitList then return nil end
    for _, trait in ipairs(db.NegativeTraitList) do
        if trait.id == traitId then
            return trait
        end
    end
    return nil
end

--- Returns list of all positive traits.
--- @return table
function TraitsPort.getAllPositiveTraits()
    local db = getDB()
    return db and db.PositiveTraitList or {}
end

--- Returns list of all negative traits.
--- @return table
function TraitsPort.getAllNegativeTraits()
    local db = getDB()
    return db and db.NegativeTraitList or {}
end

_G.GAC_TraitsPort = TraitsPort
return TraitsPort
