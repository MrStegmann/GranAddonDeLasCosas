--- SkillsDatabase
--- Master aggregator database for all skill metadata
local SkillsDatabase = {}

SkillsDatabase.SkillList = {}
SkillsDatabase.SkillsByCategory = {
    strength = {},
    dexterity = {},
    constitution = {},
    wisdom = {},
    charisma = {}
}

local categoryDatabases = {
    strength = _G.GAC_StrengthSkillsDatabase,
    dexterity = _G.GAC_DexteritySkillsDatabase,
    constitution = _G.GAC_ConstitutionSkillsDatabase,
    wisdom = _G.GAC_WisdomSkillsDatabase,
    charisma = _G.GAC_CharismaSkillsDatabase
}

for catName, catDB in pairs(categoryDatabases) do
    if catDB and catDB.SkillList then
        for skillId, skillObj in pairs(catDB.SkillList) do
            SkillsDatabase.SkillList[skillId] = skillObj
            table.insert(SkillsDatabase.SkillsByCategory[catName], skillObj)
        end
    end
end

_G.GAC_SkillsDatabase = SkillsDatabase
return SkillsDatabase
