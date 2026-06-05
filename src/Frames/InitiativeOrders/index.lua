local _, GAC = ...

GAC.initiativeOrder = {}
GAC.activeInitiativeView = "current"
GAC.currentLinkedHistory = nil -- Para saber qué historial estamos editando ahora mismo

-- Hook para que se inicialice al cargar
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", function(self, event)
    GAC:InitializeInitiativeFrame()
end)
