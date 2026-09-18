-- Standalone Lua Test Runner for GAC_DEV RPG Math Modules
local passes = 0
local fails = 0
local total = 0

_G.GAC = _G.GAC or {}
local GAC = _G.GAC

-- Minimal SafeCall mock for standalone execution if not already defined
if not GAC.SafeCall then
    function GAC:ErrorHandler(err)
        print("  [ERROR HANDLER] " .. tostring(err))
    end

    function GAC:SafeCall(func, ...)
        if type(func) ~= "function" then return false, "Not a function" end
        local results = { pcall(func, ...) }
        local ok = table.remove(results, 1)
        if not ok then
            local err = results[1]
            GAC:ErrorHandler(err)
            return false, err
        end
        return true, unpack(results)
    end
end

local function assert_equal(actual, expected, message)
    total = total + 1
    if actual == expected then
        passes = passes + 1
        print(string.format("  [PASS] %s", message or "Assertion passed"))
    else
        fails = fails + 1
        print(string.format("  [FAIL] %s: Expected '%s', got '%s'", message or "Assertion failed", tostring(expected), tostring(actual)))
    end
end

local function assert_true(condition, message)
    assert_equal(not not condition, true, message)
end

local function assert_not_nil(value, message)
    assert_true(value ~= nil, message)
end

GAC.TestRunner = {
    AssertEqual = assert_equal,
    AssertTrue = assert_true,
    AssertNotNil = assert_not_nil,
    RunModule = function(name, fn)
        print("\n--- Running Suite: " .. name .. " ---")
        local ok, err = pcall(fn)
        if not ok then
            fails = fails + 1
            print("  [ERROR] Suite crashed: " .. tostring(err))
        end
    end,
    PrintSummary = function()
        print("\n=========================================")
        print(string.format("Test Results: %d Total | %d Passed | %d Failed", total, passes, fails))
        print("=========================================\n")
        return fails == 0
    end
}

print("GAC_DEV Unit Test Suite Initialized.")

-- Load source files for standalone execution
local function loadSourceFile(filePath)
    local fn, err = loadfile(filePath)
    if fn then
        fn("GAC_DEV", GAC)
    end
end

loadSourceFile("src/Utils/Helpers.lua")
loadSourceFile("src/Data/LevelTable.lua")
loadSourceFile("src/Data/Armor.lua")
loadSourceFile("src/Data/Weapons.lua")

-- Load test modules
local function loadTestModule(filePath)
    local fn = loadfile(filePath)
    if fn then
        fn("GAC_DEV", GAC)
    end
end

loadTestModule("tests/test_helpers.lua")
loadTestModule("tests/test_leveltable.lua")
loadTestModule("tests/test_armor.lua")
loadTestModule("tests/test_weapons.lua")

if GAC.TestRunner then
    GAC.TestRunner.PrintSummary()
end
