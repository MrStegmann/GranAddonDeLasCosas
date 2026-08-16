local ConstitutionSkillsDatabase = ConstitutionSkillsDatabase or require("src.main.domain.database.ConstitutionSkillsDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local ConstitutionSkillsPort = {}

--- Retrieves all constitution skills
-- @return table read-only proxy of all constitution skills
function ConstitutionSkillsPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(ConstitutionSkillsDatabase)
end

--- Retrieves a specific constitution skill by ID
-- @param id string
-- @return table|nil read-only proxy of skill entry or nil
function ConstitutionSkillsPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, skill in ipairs(ConstitutionSkillsDatabase) do
        if skill.id == id then
            return ReadOnlyHelper.makeReadOnly(skill)
        end
    end
    return nil
end

return ConstitutionSkillsPort
