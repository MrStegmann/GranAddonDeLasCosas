--- ConstitutionSkillsDatabase
--- Transpiled skill metadata for constitution
local ConstitutionSkillsDatabase = {}

ConstitutionSkillsDatabase.SkillList = {
    ["ultimo_aliento"] = {
        id = "ultimo_aliento",
        name = "Último aliento",
        description = "Una vez por combate, cuando recibes un ataque te mataría, en vez de eso recuperas una cantidad igual a tu Fortaleza.",
        turnCooldown = 0,
        costActions = 0,
        costSlots = 1,
        turnEffects = 0,
        type = "passive",
        category = "constitution",
    },
}

_G.GAC_ConstitutionSkillsDatabase = ConstitutionSkillsDatabase
return ConstitutionSkillsDatabase
