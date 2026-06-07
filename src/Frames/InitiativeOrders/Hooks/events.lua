local _, GAC = ...

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if GAC.InitializeInitiativeFrame then
            GAC:InitializeInitiativeFrame()
        end
    end
end)
