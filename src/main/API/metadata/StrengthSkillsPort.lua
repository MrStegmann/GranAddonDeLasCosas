local StrengthSkillsDatabase = StrengthSkillsDatabase or require("src.main.domain.database.StrengthSkillsDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local StrengthSkillsPort = {}

--- Retrieves all strength skills
-- @return table read-only proxy of all strength skills
function StrengthSkillsPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(StrengthSkillsDatabase)
end

--- Retrieves a specific strength skill by ID
-- @param id string
-- @return table|nil read-only proxy of skill entry or nil
function StrengthSkillsPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, skill in ipairs(StrengthSkillsDatabase) do
        if skill.id == id then
            return ReadOnlyHelper.makeReadOnly(skill)
        end
    end
    return nil
end

return StrengthSkillsPort
