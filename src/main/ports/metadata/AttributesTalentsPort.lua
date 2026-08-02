--- AttributesTalentsPort
--- Read-only access port for Attributes and Talents metadata.
local AttributesTalentsPort = {}

local function getDB()
    return _G.GAC_AttributesTalentsDatabase or (require and pcall(require, "src.main.domain.database.AttributesTalentsDatabase") and _G.GAC_AttributesTalentsDatabase or nil)
end

--- Returns list of primary attributes.
--- @return table
function AttributesTalentsPort.getAttributes()
    local db = getDB()
    return db and db.Attributes or {}
end

--- Returns attribute groups with their talents.
--- @return table
function AttributesTalentsPort.getAttributeGroups()
    local db = getDB()
    return db and db.AttributeGroups or {}
end

--- Returns talent array for a specific attribute name.
--- @param attrName string
--- @return table|nil
function AttributesTalentsPort.getTalentsByAttribute(attrName)
    local db = getDB()
    if not db or not db.AttributeGroups then return nil end
    for _, group in ipairs(db.AttributeGroups) do
        if group.name == attrName then
            return group.talents
        end
    end
    return nil
end

--- Returns the attribute name associated with a specific talent ID.
--- @param talentId string
--- @return string|nil
function AttributesTalentsPort.getAttributeByTalent(talentId)
    local db = getDB()
    if db and db.TalentToAttributeMap then
        return db.TalentToAttributeMap[talentId]
    end
    return nil
end

_G.GAC_AttributesTalentsPort = AttributesTalentsPort
return AttributesTalentsPort
