local _, GAC = ...
GAC = GAC or _G.GAC

if not GAC or not GAC.TestRunner then
    return
end

local runner = GAC.TestRunner

runner.RunModule("LevelTable RPG Math Tests", function()
    runner.AssertNotNil(GAC.levelsTable, "GAC.levelsTable is loaded")
    runner.AssertNotNil(GAC.levelCategories, "GAC.levelCategories is loaded")

    -- Test Level 1 Normal Category Data
    if GAC.GetLevelEntry then
        local entryNormal1 = GAC:GetLevelEntry("normal", 1)
        runner.AssertNotNil(entryNormal1, "Normal level 1 entry exists")
        runner.AssertEqual(entryNormal1.maxHealth, 20, "Normal level 1 maxHealth is 20")
        runner.AssertEqual(entryNormal1.expToLevel, 30, "Normal level 1 expToLevel is 30")
        runner.AssertEqual(entryNormal1.attPoints, 5, "Normal level 1 attPoints is 5")

        -- Test Level 10 Normal Category Data
        local entryNormal10 = GAC:GetLevelEntry("normal", 10)
        runner.AssertNotNil(entryNormal10, "Normal level 10 entry exists")
        runner.AssertEqual(entryNormal10.maxHealth, 92, "Normal level 10 maxHealth is 92")

        -- Test Elite Category Level 1 Data
        local entryElite1 = GAC:GetLevelEntry("elite", 1)
        runner.AssertNotNil(entryElite1, "Elite level 1 entry exists")
        runner.AssertEqual(entryElite1.maxHealth, 40, "Elite level 1 maxHealth is 40")
    end

    -- Test Max Level calculation
    if GAC.GetMaxLevelForCategory then
        runner.AssertEqual(GAC:GetMaxLevelForCategory("normal"), 10, "Max level for normal category is 10")
        runner.AssertEqual(GAC:GetMaxLevelForCategory("noob"), 5, "Max level for noob category is 5")
    end
end)
