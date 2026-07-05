local _, GAC = ...

local ExpBarEvents = CreateFrame("Frame")
ExpBarEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
ExpBarEvents:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if StatusTrackingBarManager then
            GAC:UpdateGameExpBar()
        end
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
