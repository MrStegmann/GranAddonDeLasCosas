local _, GAC = ...

GAC.isTargetPlateHooked = false

function GAC:UpdateTargetPlate()
    if not GAC.isTargetPlateHooked then return end

    local targetName = UnitName("target")
    if not targetName then return end

    local targetGUID = UnitGUID("target")
    local isPlayer = UnitIsPlayer("target")
    
    local targetData = nil
    
    if UnitIsUnit("target", "player") then
        local currentLevel = 1
        local category = "normal"
        local constitution = 0
        local currentHealth = nil
        local currentShield = 0
        
        if self.playerCharacter then
            currentLevel = self.playerCharacter:GetLevel()
            category = self.playerCharacter:GetCategory()
            local attributes = self.playerCharacter:GetAttributes()
            constitution = attributes["constitution"] or 0
            local hp = self.playerCharacter:GetHealthPoints()
            currentHealth = hp.current
            local sp = self.playerCharacter:GetShieldPoints()
            currentShield = sp and sp.current or 0
        end
        
        local levelEntry = self:GetLevelEntry(category, currentLevel)
        local baseHealth = levelEntry and levelEntry.maxHealth or 10
        local maxHealth = baseHealth + constitution
        if maxHealth < 1 then maxHealth = 1 end
        if currentHealth == nil then currentHealth = maxHealth end
        
        targetData = {
            level = currentLevel,
            category = category,
            maxHealth = math.max(1, maxHealth),
            currentHealth = currentHealth,
            currentShield = currentShield
        }
    elseif isPlayer and self.targetDataCache and self.targetDataCache[targetGUID] then
        local char = self.targetDataCache[targetGUID]
        local hp = char:GetHealthPoints()
        local sp = char:GetShieldPoints()
        targetData = {
            level = char:GetLevel(),
            category = char:GetCategory(),
            maxHealth = math.max(1, hp.max),
            currentHealth = hp.current,
            currentShield = sp and sp.current or 0
        }
    end

    if targetData then
        local levelText = TargetFrameTextureFrameLevelText or TargetLevelText
        if levelText then
            levelText:SetText(targetData.level)
            levelText:SetVertexColor(1, 0.82, 0)
            levelText:SetDrawLayer("OVERLAY", 7)
        end
        
        if TargetFrameHealthBar then
            local maxHealth = targetData.maxHealth
            local currentHealth = targetData.currentHealth or maxHealth
            local currentShield = targetData.currentShield or 0
            
            local displayHealth = math.max(0, currentHealth)
            TargetFrameHealthBar:SetMinMaxValues(0, maxHealth)
            TargetFrameHealthBar:SetValue(displayHealth)
            
            if not TargetFrameHealthBar.GAC_NegativeHealthBar then
                TargetFrameHealthBar.GAC_NegativeHealthBar = TargetFrameHealthBar:CreateTexture(nil, "BORDER")
                TargetFrameHealthBar.GAC_NegativeHealthBar:SetColorTexture(0.5, 0.05, 0.05, 1)
            end
            
            if currentHealth < 0 then
                local barWidth = TargetFrameHealthBar:GetWidth()
                if barWidth == 0 then barWidth = 119 end
                
                local negPercent = math.abs(currentHealth) / maxHealth
                if negPercent > 1 then negPercent = 1 end
                local negWidth = negPercent * barWidth
                
                if negWidth > 0 then
                    TargetFrameHealthBar.GAC_NegativeHealthBar:SetWidth(negWidth)
                    TargetFrameHealthBar.GAC_NegativeHealthBar:ClearAllPoints()
                    TargetFrameHealthBar.GAC_NegativeHealthBar:SetPoint("TOPLEFT", TargetFrameHealthBar, "TOPLEFT", 0, 0)
                    TargetFrameHealthBar.GAC_NegativeHealthBar:SetPoint("BOTTOMLEFT", TargetFrameHealthBar, "BOTTOMLEFT", 0, 0)
                    TargetFrameHealthBar.GAC_NegativeHealthBar:Show()
                else
                    TargetFrameHealthBar.GAC_NegativeHealthBar:Hide()
                end
            else
                if TargetFrameHealthBar.GAC_NegativeHealthBar then
                    TargetFrameHealthBar.GAC_NegativeHealthBar:Hide()
                end
            end
            
            if not TargetFrameHealthBar.GAC_ShieldBar then
                TargetFrameHealthBar.GAC_ShieldBar = TargetFrameHealthBar:CreateTexture(nil, "BORDER")
                TargetFrameHealthBar.GAC_ShieldBar:SetTexture("Interface\\RaidFrame\\Shield-Fill")
                
                TargetFrameHealthBar.GAC_OverShieldGlow = TargetFrameHealthBar:CreateTexture(nil, "ARTWORK")
                TargetFrameHealthBar.GAC_OverShieldGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
                TargetFrameHealthBar.GAC_OverShieldGlow:SetBlendMode("ADD")
                TargetFrameHealthBar.GAC_OverShieldGlow:SetSize(16, TargetFrameHealthBar:GetHeight() or 12)
            end
            
            if currentShield > 0 then
                local barWidth = TargetFrameHealthBar:GetWidth()
                if barWidth == 0 then barWidth = 119 end
                
                local healthPercent = currentHealth / maxHealth
                local shieldPercent = currentShield / maxHealth
                
                local healthWidth = healthPercent * barWidth
                local shieldWidth = shieldPercent * barWidth
                
                TargetFrameHealthBar.GAC_ShieldBar:Show()
                TargetFrameHealthBar.GAC_ShieldBar:ClearAllPoints()
                TargetFrameHealthBar.GAC_ShieldBar:SetPoint("TOPLEFT", TargetFrameHealthBar, "TOPLEFT", healthWidth, 0)
                TargetFrameHealthBar.GAC_ShieldBar:SetPoint("BOTTOMLEFT", TargetFrameHealthBar, "BOTTOMLEFT", healthWidth, 0)
                
                if (healthWidth + shieldWidth) > barWidth then
                    local remainingSpace = barWidth - healthWidth
                    if remainingSpace <= 0 then
                        TargetFrameHealthBar.GAC_ShieldBar:Hide()
                    else
                        TargetFrameHealthBar.GAC_ShieldBar:SetWidth(remainingSpace)
                        TargetFrameHealthBar.GAC_ShieldBar:Show()
                    end
                    TargetFrameHealthBar.GAC_OverShieldGlow:Show()
                    TargetFrameHealthBar.GAC_OverShieldGlow:ClearAllPoints()
                    TargetFrameHealthBar.GAC_OverShieldGlow:SetPoint("RIGHT", TargetFrameHealthBar, "RIGHT", 4, 0)
                else
                    if shieldWidth > 0 then
                        TargetFrameHealthBar.GAC_ShieldBar:SetWidth(shieldWidth)
                        TargetFrameHealthBar.GAC_ShieldBar:Show()
                    else
                        TargetFrameHealthBar.GAC_ShieldBar:Hide()
                    end
                    TargetFrameHealthBar.GAC_OverShieldGlow:Hide()
                end
            else
                if TargetFrameHealthBar.GAC_ShieldBar then
                    TargetFrameHealthBar.GAC_ShieldBar:Hide()
                    TargetFrameHealthBar.GAC_OverShieldGlow:Hide()
                end
            end
            
            if TargetFrameHealthBar.TextString then
                if currentShield > 0 then
                    TargetFrameHealthBar.TextString:SetText(currentHealth .. " (" .. currentShield .. ") / " .. maxHealth)
                else
                    TargetFrameHealthBar.TextString:SetText(currentHealth .. " / " .. maxHealth)
                end
            end
        end

        local parentForOverlay = TargetFrameTextureFrame or TargetFrame
        
        if not parentForOverlay.GACDragonOverlay then
            local overlay = parentForOverlay:CreateTexture("GACTargetDragonOverlay", "OVERLAY")
            overlay:SetSize(256, 128)
            overlay:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", -25, 0)
            overlay:SetDrawLayer("BORDER")
            parentForOverlay.GACDragonOverlay = overlay
        end
        
        if TargetFrameTexture then
            TargetFrameTexture:SetAlpha(0)
        end
        
        local overlay = parentForOverlay.GACDragonOverlay
        local category = string.lower(targetData.category or "normal")
        
        overlay:Show()
        overlay:SetVertexColor(1, 1, 1)

        if category == "noob" then
            if TargetFrameTexture then TargetFrameTexture:SetAlpha(1) end
            overlay:Hide()
        elseif category == "normal" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
            overlay:SetTexCoord(0, 1, 0, 1)
        elseif category == "élite" or category == "elite" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            overlay:SetTexCoord(0, 1, 0, 1)
        elseif category == "jefe" or category == "boss" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            overlay:SetTexCoord(0, 1, 0, 1)
            overlay:SetVertexColor(1, 0.7, 0.7)
        else
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
            overlay:SetTexCoord(0, 1, 0, 1)
        end
        
    else
        local levelText = TargetFrameTextureFrameLevelText or TargetLevelText
        if levelText then
            levelText:SetVertexColor(1, 0.82, 0)
        end
        
        if TargetFrameHealthBar and TargetFrameHealthBar.GAC_ShieldBar then
            TargetFrameHealthBar.GAC_ShieldBar:Hide()
            TargetFrameHealthBar.GAC_OverShieldGlow:Hide()
        end
        
        local parentForOverlay = TargetFrameTextureFrame or TargetFrame
        if parentForOverlay.GACDragonOverlay then
            parentForOverlay.GACDragonOverlay:Hide()
        end
    end
end
