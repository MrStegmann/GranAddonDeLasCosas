local _, GAC = ...

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if GAC.InitializeRaidPlate then
            GAC:InitializeRaidPlate()
        end
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)