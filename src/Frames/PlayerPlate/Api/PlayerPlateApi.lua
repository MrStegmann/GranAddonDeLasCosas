local _, GAC = ...

GAC.isPlayerPlateHooked = false

function GAC:UpdatePlayerPlate()
    if not GAC.isPlayerPlateHooked then return end
    if PlayerFrame_UpdateLevel then PlayerFrame_UpdateLevel() end
    if PlayerFrameHealthBar then 
        UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
        if TextStatusBar_UpdateTextString then TextStatusBar_UpdateTextString(PlayerFrameHealthBar) end
    end
    
    local progress = self.characterData and self.characterData.progress or {}
    local category = string.lower(progress.category or "normal")
    
    local parentForOverlay = PlayerFrameTexture and PlayerFrameTexture:GetParent() or PlayerFrame
    
    if not parentForOverlay.GACDragonOverlay then
        local overlay = parentForOverlay:CreateTexture("GACPlayerDragonOverlay", "OVERLAY")
        overlay:SetSize(256, 128)
        overlay:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 0, 0)
        overlay:SetDrawLayer("BORDER") 
        
        parentForOverlay.GACDragonOverlay = overlay
    end

    local overlay = parentForOverlay.GACDragonOverlay

    if category == "noob" then
        if PlayerFrameTexture then
            PlayerFrameTexture:SetAlpha(1)
        end
        overlay:Hide()
    else
        if PlayerFrameTexture then
            PlayerFrameTexture:SetAlpha(0)
        end
        overlay:Show()
        
        overlay:SetVertexColor(1, 1, 1)

        if category == "normal" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
            overlay:SetTexCoord(1, 0, 0, 1)
            overlay:SetVertexColor(1, 1, 1)
        elseif category == "elite" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            overlay:SetTexCoord(1, 0, 0, 1)
        elseif category == "boss" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            overlay:SetTexCoord(1, 0, 0, 1)
            overlay:SetVertexColor(1, 0.7, 0.7)
        else
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
            overlay:SetTexCoord(1, 0, 0, 1)
            overlay:SetVertexColor(1, 1, 1)
        end
    end
end
