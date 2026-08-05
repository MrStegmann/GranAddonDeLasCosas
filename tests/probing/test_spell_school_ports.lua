--- Probing unit test for Spell School Ports: ArcanePort, ElementalPort, ElunePort, HolyLightPort, ShadowPort, WorgenCursePort
-- Probes every GetAll() and GetById(id) endpoint for 100% structural parity.

local ArcaneDatabase = ArcaneDatabase or require("src.main.domain.database.ArcaneDatabase")
local ElementalDatabase = ElementalDatabase or require("src.main.domain.database.ElementalDatabase")
local EluneDatabase = EluneDatabase or require("src.main.domain.database.EluneDatabase")
local HolyLightDatabase = HolyLightDatabase or require("src.main.domain.database.HolyLightDatabase")
local ShadowDatabase = ShadowDatabase or require("src.main.domain.database.ShadowDatabase")
local WorgenCurseDatabase = WorgenCurseDatabase or require("src.main.domain.database.WorgenCurseDatabase")

local ArcanePort = ArcanePort or require("src.main.ports.metadata.ArcanePort")
local ElementalPort = ElementalPort or require("src.main.ports.metadata.ElementalPort")
local ElunePort = ElunePort or require("src.main.ports.metadata.ElunePort")
local HolyLightPort = HolyLightPort or require("src.main.ports.metadata.HolyLightPort")
local ShadowPort = ShadowPort or require("src.main.ports.metadata.ShadowPort")
local WorgenCursePort = WorgenCursePort or require("src.main.ports.metadata.WorgenCursePort")

local TestSpellSchoolPorts = {}

function TestSpellSchoolPorts.Run()
    print("[TEST] Running Spell School Ports Probing Suite...")

    -- 1. ArcanePort Probing
    local arcaneAll = ArcanePort.GetAll()
    assert(arcaneAll ~= nil and #arcaneAll == 40, "ArcanePort.GetAll() failed")
    local arcaneSpell = ArcanePort.GetById(arcaneAll[1].id)
    assert(arcaneSpell ~= nil and arcaneSpell.category == "arcane", "ArcanePort.GetById failed")
    assert(ArcanePort.GetById("non_existent_arcane") == nil, "ArcanePort invalid ID check failed")

    -- 2. ElementalPort Probing
    local elementalAll = ElementalPort.GetAll()
    assert(elementalAll ~= nil and #elementalAll == 56, "ElementalPort.GetAll() failed")
    local elementalSpell = ElementalPort.GetById("rockShield")
    assert(elementalSpell ~= nil and elementalSpell.name == "Escudo de roca", "ElementalPort.GetById failed")
    assert(ElementalPort.GetById("non_existent_elemental") == nil, "ElementalPort invalid ID check failed")

    -- 3. ElunePort Probing
    local eluneAll = ElunePort.GetAll()
    assert(eluneAll ~= nil and #eluneAll == 45, "ElunePort.GetAll() failed")
    local eluneSpell = ElunePort.GetById("moonSpark")
    assert(eluneSpell ~= nil and eluneSpell.name == "Chispa lunar", "ElunePort.GetById failed")
    assert(ElunePort.GetById("non_existent_elune") == nil, "ElunePort invalid ID check failed")

    -- 4. HolyLightPort Probing
    local holyAll = HolyLightPort.GetAll()
    assert(holyAll ~= nil and #holyAll == 56, "HolyLightPort.GetAll() failed")
    local holySpell = HolyLightPort.GetById("searingLight")
    assert(holySpell ~= nil and holySpell.name == "Luz abrasadora", "HolyLightPort.GetById failed")
    assert(HolyLightPort.GetById("non_existent_holy") == nil, "HolyLightPort invalid ID check failed")

    -- 5. ShadowPort Probing
    local shadowAll = ShadowPort.GetAll()
    assert(shadowAll ~= nil and #shadowAll == 48, "ShadowPort.GetAll() failed")
    local shadowSpell = ShadowPort.GetById("corruptingTouch")
    assert(shadowSpell ~= nil and shadowSpell.name == "Toque corruptor", "ShadowPort.GetById failed")
    assert(ShadowPort.GetById("non_existent_shadow") == nil, "ShadowPort invalid ID check failed")

    -- 6. WorgenCursePort Probing
    local worgenAll = WorgenCursePort.GetAll()
    assert(worgenAll ~= nil and worgenAll.humanoid ~= nil and worgenAll.worgen ~= nil, "WorgenCursePort.GetAll() failed")
    local worgenForm = WorgenCursePort.GetByForm("worgen")
    assert(worgenForm ~= nil and #worgenForm.advantages == 5, "WorgenCursePort.GetByForm('worgen') failed")
    local worgenById = WorgenCursePort.GetById("humanoid")
    assert(worgenById ~= nil and #worgenById.advantages == 5, "WorgenCursePort.GetById('humanoid') failed")
    assert(WorgenCursePort.GetById("invalid_form") == nil, "WorgenCursePort invalid ID check failed")

    print("[SUCCESS] Spell School Ports Probing Suite Passed 100%!")
    return true
end

return TestSpellSchoolPorts
