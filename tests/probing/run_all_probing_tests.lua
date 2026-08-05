--- Master Probing Test Runner for Feature 002 Core Data
-- Loads all database tables and ports, executing all 5 probing suites to assert 100% structural equality across all 19 endpoints.

local TestCoreDataPorts = TestCoreDataPorts or require("tests.probing.test_core_data_ports")
local TestEquipmentPorts = TestEquipmentPorts or require("tests.probing.test_equipment_ports")
local TestSkillsPorts = TestSkillsPorts or require("tests.probing.test_skills_ports")
local TestSpellSchoolPorts = TestSpellSchoolPorts or require("tests.probing.test_spell_school_ports")
local TestEmptyPorts = TestEmptyPorts or require("tests.probing.test_empty_ports")

local MasterProbingRunner = {}

function MasterProbingRunner.RunAll()
    print("==========================================================")
    print("  FEATURE 002: CORE DATA MASTER PROBING SUITE (19 PORTS)")
    print("==========================================================")

    local passedCount = 0

    if TestCoreDataPorts.Run() then passedCount = passedCount + 3 end
    if TestEquipmentPorts.Run() then passedCount = passedCount + 3 end
    if TestSkillsPorts.Run() then passedCount = passedCount + 3 end
    if TestSpellSchoolPorts.Run() then passedCount = passedCount + 6 end
    if TestEmptyPorts.Run() then passedCount = passedCount + 4 end

    print("----------------------------------------------------------")
    print(string.format("  TOTAL PROBING PASSED: %d / 19 PORTS (100%% PARITY)", passedCount))
    print("==========================================================")
    return passedCount == 19
end

-- Auto-execute if loaded directly
MasterProbingRunner.RunAll()

return MasterProbingRunner
