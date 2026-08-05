local DexSkillsDatabase = DexSkillsDatabase or require("src.main.domain.database.DexSkillsDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local DexSkillsPort = {}

--- Retrieves all dexterity skills
-- @return table read-only proxy of all dexterity skills
function DexSkillsPort.GetAll()
    return ReadOnlyHelper.makeReadOnly(DexSkillsDatabase)
end

--- Retrieves a specific dexterity skill by ID
-- @param id string
-- @return table|nil read-only proxy of skill entry or nil
function DexSkillsPort.GetById(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    for _, skill in ipairs(DexSkillsDatabase) do
        if skill.id == id then
            return ReadOnlyHelper.makeReadOnly(skill)
        end
    end
    return nil
end

return DexSkillsPort
