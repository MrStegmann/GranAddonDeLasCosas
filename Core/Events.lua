local addonName, addon = ...

function addon:ADDON_LOADED(loadedAddonName)
    if loadedAddonName ~= addonName then
        return
    end

    if addon.InitializeAttributeSystem then
        addon:InitializeAttributeSystem()
    end

    if GranAddonDeLasCosasDB.debug then
        print("|cff00ff00" .. addonName .. "|r cargado. Usa /gac para ayuda.")
    end
end

function addon:PLAYER_LOGIN()
    if addon.RegisterRollCommunication then
        addon:RegisterRollCommunication()
    end

    if addon.RegisterTooltipSync then
        addon:RegisterTooltipSync()
    end

    if addon.RegisterCommands then
        addon:RegisterCommands()
    end

    if addon.CreateMinimapButton then
        addon:CreateMinimapButton()
    end

    if addon.CreateQuickActionsFrame then
        addon:CreateQuickActionsFrame()
    end

    if addon.CreateTurnOrderFrame then
        addon:CreateTurnOrderFrame()
    end

    if addon.CreateLevelOverlayFrame then
        addon:CreateLevelOverlayFrame()
    end

    if addon.eventFrame then
        addon.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        addon.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        addon.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        addon.eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
        addon.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
        addon.eventFrame:RegisterEvent("UNIT_LEVEL")
        addon.eventFrame:RegisterEvent("UNIT_HEALTH")
        addon.eventFrame:RegisterEvent("UNIT_MAXHEALTH")
        addon.eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    end
end

function addon:GROUP_ROSTER_UPDATE()
    if addon.UpdateTurnOrderFrameVisibility then
        addon:UpdateTurnOrderFrameVisibility()
    end
end

function addon:PLAYER_ENTERING_WORLD()
    if addon.UpdateTurnOrderFrameVisibility then
        addon:UpdateTurnOrderFrameVisibility()
    end

    if addon.UpdateTargetInspectButtonVisibility then
        addon:UpdateTargetInspectButtonVisibility()
    end

    if addon.UpdateQuickExperienceBar then
        addon:UpdateQuickExperienceBar()
    end

    if addon.RefreshLevelOverlays then
        addon:RefreshLevelOverlays()
    end

    if addon.RefreshPlayerHealthBarMaxHealth then
        addon:RefreshPlayerHealthBarMaxHealth()
    end

    if addon.RefreshTargetHealthBarMaxHealth then
        addon:RefreshTargetHealthBarMaxHealth()
    end

end

function addon:PLAYER_TARGET_CHANGED()
    if addon.UpdateTargetInspectButtonVisibility then
        addon:UpdateTargetInspectButtonVisibility()
    end

    if addon.RequestTargetLevelData then
        addon:RequestTargetLevelData(true)
    end

    if addon.RefreshTargetLevelOverlay then
        addon:RefreshTargetLevelOverlay()
    end

    if addon.RefreshTargetHealthBarMaxHealth then
        addon:RefreshTargetHealthBarMaxHealth()
    end
end

function addon:PLAYER_XP_UPDATE()
    if addon.UpdateQuickExperienceBar then
        addon:UpdateQuickExperienceBar()
    end

end

function addon:PLAYER_LEVEL_UP()
    if addon.UpdateQuickExperienceBar then
        addon:UpdateQuickExperienceBar()
    end

    if addon.RefreshPlayerLevelOverlay then
        addon:RefreshPlayerLevelOverlay()
    end

    if addon.RefreshPlayerHealthBarMaxHealth then
        addon:RefreshPlayerHealthBarMaxHealth()
    end

    if addon.PrintLevelUpMessage then
        addon:PrintLevelUpMessage()
    end
end

function addon:UNIT_LEVEL(unit)
    if unit == "player" then
        if addon.RefreshPlayerLevelOverlay then
            addon:RefreshPlayerLevelOverlay()
        end
        if addon.RefreshPlayerHealthBarMaxHealth then
            addon:RefreshPlayerHealthBarMaxHealth()
        end
        return
    end

    if unit == "target" then
        if addon.RefreshTargetLevelOverlay then
            addon:RefreshTargetLevelOverlay()
        end
        if addon.RefreshTargetHealthBarMaxHealth then
            addon:RefreshTargetHealthBarMaxHealth()
        end
    end
end

function addon:UNIT_HEALTH(unit)
    if unit == "player" and addon.RefreshPlayerHealthBarMaxHealth then
        addon:RefreshPlayerHealthBarMaxHealth()
        return
    end

    if unit == "target" and addon.RefreshTargetHealthBarMaxHealth then
        addon:RefreshTargetHealthBarMaxHealth()
    end
end

function addon:UNIT_MAXHEALTH(unit)
    if unit == "player" and addon.RefreshPlayerHealthBarMaxHealth then
        addon:RefreshPlayerHealthBarMaxHealth()
        return
    end

    if unit == "target" and addon.RefreshTargetHealthBarMaxHealth then
        addon:RefreshTargetHealthBarMaxHealth()
    end
end

function addon:UNIT_ABSORB_AMOUNT_CHANGED(unit)
    if unit == "player" and addon.RefreshPlayerHealthBarMaxHealth then
        addon:RefreshPlayerHealthBarMaxHealth()
        return
    end

    if unit == "target" and addon.RefreshTargetHealthBarMaxHealth then
        addon:RefreshTargetHealthBarMaxHealth()
    end
end
