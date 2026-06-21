local addonName, GAC = ...

function GAC:CreateQuickActionsFrame()
    if self.quickActionsFrame then return end
    self.quickActionsFrame = GAC.Screens.QuickButtonsMenu:CreateMainFrame()
    
    -- Exponer funciones en GAC globalmente para retrocompatibilidad
    self.GetQuickModifierValue = function(self)
        return GAC.Utils.QuickButtonsMenu:GetQuickModifierValue()
    end
    
    self.UpdateTargetInspectButtonVisibility = function(self)
        return GAC.Utils.QuickButtonsMenu:UpdateTargetInspectButtonVisibility()
    end
    
    -- Registro de eventos para visibilidad
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:SetScript("OnEvent", function() GAC:UpdateTargetInspectButtonVisibility() end)
    
    GAC:UpdateTargetInspectButtonVisibility()
end
