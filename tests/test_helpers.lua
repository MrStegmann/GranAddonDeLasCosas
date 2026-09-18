local _, GAC = ...
GAC = GAC or _G.GAC

if not GAC or not GAC.TestRunner then
    return
end

local runner = GAC.TestRunner

runner.RunModule("Helpers Utility Tests", function()
    -- Test StripColorCodes
    if GAC.StripColorCodes then
        local coloredText = "|cff00ff00Jugador|r"
        local cleanText = GAC:StripColorCodes(coloredText)
        runner.AssertEqual(cleanText, "Jugador", "StripColorCodes removes hex color codes")
    end

    -- Test FormatRollValue
    if GAC.FormatRollValue then
        runner.AssertTrue(string.find(GAC:FormatRollValue(1), "Pifia") ~= nil, "FormatRollValue(1) produces Pifia")
        runner.AssertTrue(string.find(GAC:FormatRollValue(20), "Critico") ~= nil, "FormatRollValue(20) produces Critico")
        runner.AssertTrue(string.find(GAC:FormatRollValue(10), "10") ~= nil, "FormatRollValue(10) produces formatted number")
    end

    -- Test SafeCall
    if GAC.SafeCall then
        local ok, result = GAC:SafeCall(function(a, b) return a + b end, 5, 10)
        runner.AssertTrue(ok, "SafeCall returns true for successful function")
        runner.AssertEqual(result, 15, "SafeCall correctly forwards arguments and return values")

        local errOk, errVal = GAC:SafeCall(function() error("test error") end)
        runner.AssertEqual(errOk, false, "SafeCall returns false on thrown exception")
    end
end)
