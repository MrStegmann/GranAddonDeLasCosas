--- Probing unit test for Skills Ports: StrengthSkillsPort, DexSkillsPort, ConstitutionSkillsPort
-- Probes every GetAll() and GetById(id) endpoint for 100% structural parity.

local StrengthSkillsDatabase = StrengthSkillsDatabase or require("src.main.domain.database.StrengthSkillsDatabase")
local DexSkillsDatabase = DexSkillsDatabase or require("src.main.domain.database.DexSkillsDatabase")
local ConstitutionSkillsDatabase = ConstitutionSkillsDatabase or require("src.main.domain.database.ConstitutionSkillsDatabase")

local StrengthSkillsPort = StrengthSkillsPort or require("src.main.ports.metadata.StrengthSkillsPort")
local DexSkillsPort = DexSkillsPort or require("src.main.ports.metadata.DexSkillsPort")
local ConstitutionSkillsPort = ConstitutionSkillsPort or require("src.main.ports.metadata.ConstitutionSkillsPort")

local TestSkillsPorts = {}

function TestSkillsPorts.Run()
    print("[TEST] Running Skills Ports Probing Suite...")

    -- 1. StrengthSkillsPort Probing
    local strAll = StrengthSkillsPort.GetAll()
    assert(strAll ~= nil, "StrengthSkillsPort.GetAll() returned nil")
    assert(#strAll == 40, "StrengthSkillsPort length mismatch (expected 40)")

    local strSkill = StrengthSkillsPort.GetById(strAll[1].id)
    assert(strSkill ~= nil, "StrengthSkillsPort.GetById first element failed")
    assert(strSkill.category == "strength", "StrengthSkillsPort category mismatch")
    assert(StrengthSkillsPort.GetById("non_existent_str_skill") == nil, "StrengthSkillsPort invalid ID check failed")

    -- 2. DexSkillsPort Probing
    local dexAll = DexSkillsPort.GetAll()
    assert(dexAll ~= nil, "DexSkillsPort.GetAll() returned nil")
    assert(#dexAll == 40, "DexSkillsPort length mismatch (expected 40)")

    local dexSkill = DexSkillsPort.GetById(dexAll[1].id)
    assert(dexSkill ~= nil, "DexSkillsPort.GetById first element failed")
    assert(dexSkill.category == "dexterity", "DexSkillsPort category mismatch")
    assert(DexSkillsPort.GetById("non_existent_dex_skill") == nil, "DexSkillsPort invalid ID check failed")

    -- 3. ConstitutionSkillsPort Probing
    local conAll = ConstitutionSkillsPort.GetAll()
    assert(conAll ~= nil, "ConstitutionSkillsPort.GetAll() returned nil")
    assert(#conAll == 40, "ConstitutionSkillsPort length mismatch (expected 40)")

    local conSkill = ConstitutionSkillsPort.GetById(conAll[1].id)
    assert(conSkill ~= nil, "ConstitutionSkillsPort.GetById first element failed")
    assert(conSkill.category == "constitution", "ConstitutionSkillsPort category mismatch")
    assert(ConstitutionSkillsPort.GetById("non_existent_con_skill") == nil, "ConstitutionSkillsPort invalid ID check failed")

    print("[SUCCESS] Skills Ports Probing Suite Passed 100%!")
    return true
end

return TestSkillsPorts
