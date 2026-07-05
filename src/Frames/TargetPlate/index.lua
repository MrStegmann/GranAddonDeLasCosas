local _, GAC = ...

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if GAC.InitializeTargetPlate then
            GAC:InitializeTargetPlate()
        end
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)