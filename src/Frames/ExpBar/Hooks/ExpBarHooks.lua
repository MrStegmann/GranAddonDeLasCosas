local _, GAC = ...

local HookEvents = CreateFrame("Frame")
HookEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
HookEvents:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if StatusTrackingBarManager then
            hooksecurefunc(StatusTrackingBarManager, "UpdateBars", function()
                GAC:UpdateGameExpBar()
            end)

            if GAC.NormalizeExperienceProgressData then
                hooksecurefunc(GAC, "NormalizeExperienceProgressData", function(self_gac)
                    self_gac:UpdateGameExpBar()
                end)
            end
        end
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
