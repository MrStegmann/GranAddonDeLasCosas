--- SpellsDatabase
--- Master aggregator database for all spell metadata
local SpellsDatabase = {}

SpellsDatabase.SpellList = {}
SpellsDatabase.SpellsByCategory = {
    arcane = {},
    chi = {},
    elemental = {},
    elune = {},
    fel = {},
    light = {},
    nature = {},
    necromantic = {},
    shadow = {}
}

local categoryDatabases = {
    arcane = _G.GAC_ArcaneSpellsDatabase,
    chi = _G.GAC_ChiSpellsDatabase,
    elemental = _G.GAC_ElementalSpellsDatabase,
    elune = _G.GAC_EluneSpellsDatabase,
    fel = _G.GAC_FelSpellsDatabase,
    light = _G.GAC_HolyLightSpellsDatabase,
    nature = _G.GAC_NatureSpellsDatabase,
    necromantic = _G.GAC_NecromancySpellsDatabase,
    shadow = _G.GAC_ShadowSpellsDatabase
}

for catName, catDB in pairs(categoryDatabases) do
    if catDB and catDB.SpellList then
        for spellId, spellObj in pairs(catDB.SpellList) do
            SpellsDatabase.SpellList[spellId] = spellObj
            table.insert(SpellsDatabase.SpellsByCategory[catName], spellObj)
        end
    end
end

_G.GAC_SpellsDatabase = SpellsDatabase
return SpellsDatabase
