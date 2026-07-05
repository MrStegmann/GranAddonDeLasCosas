local _, GAC = ...

function GAC:InitializePlayerPlate()
    if GAC.isPlayerPlateHooked then return end
    GAC.isPlayerPlateHooked = true
    
    if PlayerFrame_UpdateLevel then
        hooksecurefunc("PlayerFrame_UpdateLevel", function()
            local currentLevel = 1
            if GAC.playerCharacter then
                currentLevel = GAC.playerCharacter:GetLevel()
            end
            if PlayerLevelText then
                PlayerLevelText:SetText(currentLevel)
                PlayerLevelText:SetVertexColor(1, 0.82, 0)
                PlayerLevelText:SetDrawLayer("OVERLAY", 7)
            end
        end)
    end
    
    if UnitFrameHealthBar_Update then
        hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar, unit)
            if unit == "player" and statusbar == PlayerFrameHealthBar then
                local currentLevel = 1
                local category = "normal"
                local constitution = 0
                local currentHealth = nil
                local currentShield = 0
                
                if GAC.playerCharacter then
                    currentLevel = GAC.playerCharacter:GetLevel()
                    category = GAC.playerCharacter:GetCategory()
                    local attributes = GAC.playerCharacter:GetAttributes()
                    constitution = attributes["constitution"] or 0
                    local hp = GAC.playerCharacter:GetHealthPoints()
                    currentHealth = hp.current
                    local sp = GAC.playerCharacter:GetShieldPoints()
                    currentShield = sp and sp.current or 0
                end
                
                local levelEntry = GAC:GetLevelEntry(category, currentLevel)
                local baseHealth = levelEntry and levelEntry.maxHealth or 10
                local maxHealth = baseHealth + constitution
                if maxHealth < 1 then maxHealth = 1 end
                if currentHealth == nil then currentHealth = maxHealth end
                
                local displayHealth = math.max(0, currentHealth)
                statusbar:SetMinMaxValues(0, maxHealth)
                statusbar:SetValue(displayHealth)

                if not statusbar.GAC_NegativeHealthBar then
                    statusbar.GAC_NegativeHealthBar = statusbar:CreateTexture(nil, "BORDER")
                    statusbar.GAC_NegativeHealthBar:SetColorTexture(0.5, 0.05, 0.05, 1)
                end
                
                if currentHealth < 0 then
                    local barWidth = statusbar:GetWidth()
                    if barWidth == 0 then barWidth = 119 end
                    
                    local negPercent = math.abs(currentHealth) / maxHealth
                    if negPercent > 1 then negPercent = 1 end
                    local negWidth = negPercent * barWidth
                    
                    if negWidth > 0 then
                        statusbar.GAC_NegativeHealthBar:SetWidth(negWidth)
                        statusbar.GAC_NegativeHealthBar:ClearAllPoints()
                        statusbar.GAC_NegativeHealthBar:SetPoint("TOPLEFT", statusbar, "TOPLEFT", 0, 0)
                        statusbar.GAC_NegativeHealthBar:SetPoint("BOTTOMLEFT", statusbar, "BOTTOMLEFT", 0, 0)
                        statusbar.GAC_NegativeHealthBar:Show()
                    else
                        statusbar.GAC_NegativeHealthBar:Hide()
                    end
                else
                    if statusbar.GAC_NegativeHealthBar then
                        statusbar.GAC_NegativeHealthBar:Hide()
                    end
                end

                if not statusbar.GAC_ShieldBar then
                    statusbar.GAC_ShieldBar = statusbar:CreateTexture(nil, "BORDER")
                    statusbar.GAC_ShieldBar:SetTexture("Interface\\RaidFrame\\Shield-Fill")
                    
                    statusbar.GAC_OverShieldGlow = statusbar:CreateTexture(nil, "ARTWORK")
                    statusbar.GAC_OverShieldGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
                    statusbar.GAC_OverShieldGlow:SetBlendMode("ADD")
                    statusbar.GAC_OverShieldGlow:SetSize(16, statusbar:GetHeight() or 12)
                end

                if currentShield > 0 then
                    local barWidth = statusbar:GetWidth()
                    if barWidth == 0 then barWidth = 119 end
                    
                    local healthPercent = currentHealth / maxHealth
                    local shieldPercent = currentShield / maxHealth
                    
                    local healthWidth = healthPercent * barWidth
                    local shieldWidth = shieldPercent * barWidth
                    
                    statusbar.GAC_ShieldBar:Show()
                    statusbar.GAC_ShieldBar:ClearAllPoints()
                    statusbar.GAC_ShieldBar:SetPoint("TOPLEFT", statusbar, "TOPLEFT", healthWidth, 0)
                    statusbar.GAC_ShieldBar:SetPoint("BOTTOMLEFT", statusbar, "BOTTOMLEFT", healthWidth, 0)
                    
                    if (healthWidth + shieldWidth) > barWidth then
                        local remainingSpace = barWidth - healthWidth
                        if remainingSpace <= 0 then
                            statusbar.GAC_ShieldBar:Hide()
                        else
                            statusbar.GAC_ShieldBar:SetWidth(remainingSpace)
                            statusbar.GAC_ShieldBar:Show()
                        end
                        statusbar.GAC_OverShieldGlow:Show()
                        statusbar.GAC_OverShieldGlow:ClearAllPoints()
                        statusbar.GAC_OverShieldGlow:SetPoint("RIGHT", statusbar, "RIGHT", 4, 0)
                    else
                        if shieldWidth > 0 then
                            statusbar.GAC_ShieldBar:SetWidth(shieldWidth)
                            statusbar.GAC_ShieldBar:Show()
                        else
                            statusbar.GAC_ShieldBar:Hide()
                        end
                        statusbar.GAC_OverShieldGlow:Hide()
                    end
                else
                    if statusbar.GAC_ShieldBar then
                        statusbar.GAC_ShieldBar:Hide()
                        statusbar.GAC_OverShieldGlow:Hide()
                    end
                end
            end
        end)
    end
    
    if TextStatusBar_UpdateTextString then
        hooksecurefunc("TextStatusBar_UpdateTextString", function(textStatusBar)
            if textStatusBar == PlayerFrameHealthBar then
                local currentLevel = 1
                local category = "normal"
                local constitution = 0
                local currentHealth = nil
                local currentShield = 0
                
                if GAC.playerCharacter then
                    currentLevel = GAC.playerCharacter:GetLevel()
                    category = GAC.playerCharacter:GetCategory()
                    local attributes = GAC.playerCharacter:GetAttributes()
                    constitution = attributes["constitution"] or 0
                    local hp = GAC.playerCharacter:GetHealthPoints()
                    currentHealth = hp.current
                    local sp = GAC.playerCharacter:GetShieldPoints()
                    currentShield = sp and sp.current or 0
                end
                
                local levelEntry = GAC:GetLevelEntry(category, currentLevel)
                local baseHealth = levelEntry and levelEntry.maxHealth or 10
                local maxHealth = baseHealth + constitution
                if maxHealth < 1 then maxHealth = 1 end
                if currentHealth == nil then currentHealth = maxHealth end
                
                if textStatusBar.TextString then
                    if currentShield > 0 then
                        textStatusBar.TextString:SetText(currentHealth .. " (" .. currentShield .. ") / " .. maxHealth)
                    else
                        textStatusBar.TextString:SetText(currentHealth .. " / " .. maxHealth)
                    end
                end
            end
        end)
    end

    if PlayerFrame_Update then
        hooksecurefunc("PlayerFrame_Update", function()
            if GAC.UpdatePlayerPlate then
                GAC:UpdatePlayerPlate()
            end
        end)
    end

    if PlayerFrame_Update then PlayerFrame_Update() end
    if PlayerFrame_UpdateLevel then PlayerFrame_UpdateLevel() end
    if PlayerFrameHealthBar then UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player") end
end
