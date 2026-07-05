local _, GAC = ...

GAC.isRaidPlateHooked = false
GAC.activeRaidFrames = GAC.activeRaidFrames or {}

function GAC:UpdateRaidPlate(frame)
    if not frame or not frame.unit or not frame.healthBar then return end
    
    GAC.activeRaidFrames[frame] = true

    local unitName = UnitName(frame.unit)
    if not unitName then return end

    local shortName = Ambiguate(unitName, "none")
    local isPlayer = UnitIsUnit(frame.unit, "player")
    
    local unitGUID = UnitGUID(frame.unit)
    local unitData = nil
    
    if isPlayer then
        if self.playerCharacter then
            local hp = self.playerCharacter:GetHealthPoints()
            local sp = self.playerCharacter:GetShieldPoints()
            unitData = {
                maxHealth = math.max(1, hp.max),
                currentHealth = hp.current,
                currentShield = sp and sp.current or 0
            }
        end
    elseif unitGUID and self.targetDataCache and self.targetDataCache[unitGUID] then
        local char = self.targetDataCache[unitGUID]
        local hp = char:GetHealthPoints()
        local sp = char:GetShieldPoints()
        unitData = {
            maxHealth = math.max(1, hp.max),
            currentHealth = hp.current,
            currentShield = sp and sp.current or 0
        }
    end

    if unitData then
        local maxHealth = unitData.maxHealth
        local currentHealth = unitData.currentHealth or maxHealth
        local currentShield = unitData.currentShield or 0
        
        local displayHealth = math.max(0, currentHealth)
        frame.healthBar:SetMinMaxValues(0, maxHealth)
        frame.healthBar:SetValue(displayHealth)
        
        if not frame.healthBar.GAC_NegativeHealthBar then
            frame.healthBar.GAC_NegativeHealthBar = frame.healthBar:CreateTexture(nil, "BORDER")
            frame.healthBar.GAC_NegativeHealthBar:SetColorTexture(0.5, 0.05, 0.05, 1)
        end
        
        if currentHealth < 0 then
            local barWidth = frame.healthBar:GetWidth()
            if barWidth == 0 then barWidth = frame:GetWidth() or 1 end
            
            local negPercent = math.abs(currentHealth) / maxHealth
            if negPercent > 1 then negPercent = 1 end
            local negWidth = negPercent * barWidth
            
            if negWidth > 0 then
                frame.healthBar.GAC_NegativeHealthBar:SetWidth(negWidth)
                frame.healthBar.GAC_NegativeHealthBar:ClearAllPoints()
                frame.healthBar.GAC_NegativeHealthBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                frame.healthBar.GAC_NegativeHealthBar:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                frame.healthBar.GAC_NegativeHealthBar:Show()
            else
                frame.healthBar.GAC_NegativeHealthBar:Hide()
            end
        else
            if frame.healthBar.GAC_NegativeHealthBar then
                frame.healthBar.GAC_NegativeHealthBar:Hide()
            end
        end
        
        if not frame.healthBar.GAC_ShieldBar then
            frame.healthBar.GAC_ShieldBar = frame.healthBar:CreateTexture(nil, "BORDER")
            frame.healthBar.GAC_ShieldBar:SetTexture("Interface\\RaidFrame\\Shield-Fill")
            
            frame.healthBar.GAC_OverShieldGlow = frame.healthBar:CreateTexture(nil, "ARTWORK")
            frame.healthBar.GAC_OverShieldGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
            frame.healthBar.GAC_OverShieldGlow:SetBlendMode("ADD")
            frame.healthBar.GAC_OverShieldGlow:SetSize(16, frame.healthBar:GetHeight() or 12)
        end
        
        if currentShield > 0 then
            local barWidth = frame.healthBar:GetWidth()
            if barWidth == 0 then barWidth = frame:GetWidth() or 1 end
            
            local healthPercent = currentHealth / maxHealth
            local shieldPercent = currentShield / maxHealth
            
            local healthWidth = healthPercent * barWidth
            local shieldWidth = shieldPercent * barWidth
            
            frame.healthBar.GAC_ShieldBar:Show()
            frame.healthBar.GAC_ShieldBar:ClearAllPoints()
            frame.healthBar.GAC_ShieldBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", healthWidth, 0)
            frame.healthBar.GAC_ShieldBar:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", healthWidth, 0)
            
            if (healthWidth + shieldWidth) > barWidth then
                local remainingSpace = barWidth - healthWidth
                if remainingSpace <= 0 then
                    frame.healthBar.GAC_ShieldBar:Hide()
                else
                    frame.healthBar.GAC_ShieldBar:SetWidth(remainingSpace)
                    frame.healthBar.GAC_ShieldBar:Show()
                end
                
                frame.healthBar.GAC_OverShieldGlow:Show()
                frame.healthBar.GAC_OverShieldGlow:ClearAllPoints()
                frame.healthBar.GAC_OverShieldGlow:SetPoint("RIGHT", frame.healthBar, "RIGHT", 4, 0)
            else
                if shieldWidth > 0 then
                    frame.healthBar.GAC_ShieldBar:SetWidth(shieldWidth)
                    frame.healthBar.GAC_ShieldBar:Show()
                else
                    frame.healthBar.GAC_ShieldBar:Hide()
                end
                frame.healthBar.GAC_OverShieldGlow:Hide()
            end
        else
            if frame.healthBar.GAC_ShieldBar then
                frame.healthBar.GAC_ShieldBar:Hide()
                frame.healthBar.GAC_OverShieldGlow:Hide()
            end
        end
        
        if frame.statusText then
            frame.statusText:SetTextColor(1, 1, 1, 1)
            if not frame.statusText:IsShown() and UnitIsConnected(frame.unit) then
                frame.statusText:Show()
            end
            if currentShield > 0 then
                frame.statusText:SetText(currentHealth .. "(" .. currentShield .. ")")
            else
                frame.statusText:SetText(currentHealth)
            end
        end
    else
        if not isPlayer and UnitIsConnected(frame.unit) and UnitIsPlayer(frame.unit) then
            GAC.pendingTargetRequests = GAC.pendingTargetRequests or {}
            local now = GetTime()
            if not GAC.pendingTargetRequests[unitGUID] or (now - GAC.pendingTargetRequests[unitGUID]) > 10 then
                GAC.pendingTargetRequests[unitGUID] = now
                if GAC.Transmitter then
                    GAC.Transmitter:Trigger(GAC.Enums.Events.REQ, shortName, false)
                end
            end
        end

        if frame.healthBar and frame.healthBar.GAC_ShieldBar then
            frame.healthBar.GAC_ShieldBar:Hide()
            frame.healthBar.GAC_OverShieldGlow:Hide()
        end
    end
end
