local _, GAC = ...

local isRaidPlateHooked = false
GAC.activeRaidFrames = GAC.activeRaidFrames or {}

function GAC:UpdateRaidPlate(frame)
    if not frame or not frame.unit or not frame.healthBar then return end
    
    -- Almacenar referencia para el bucle de actualización
    GAC.activeRaidFrames[frame] = true

    local unitName = UnitName(frame.unit)
    if not unitName then return end

    local shortName = Ambiguate(unitName, "none")
    local isPlayer = UnitIsUnit(frame.unit, "player")
    
    local unitData = nil
    
    if isPlayer then
        local progress = self.characterData and self.characterData.progress or {}
        local currentLevel = progress.level or 1
        local category = progress.category or "normal"
        local levelEntry = self:GetLevelEntry(category, currentLevel)
        local baseHealth = levelEntry and levelEntry.maxHealth or 10
        local attributes = self.characterData and self.characterData.attributes or {}
        local maxHealth = baseHealth + (attributes["constitution"] or 0)
        
        local currentHealth = self.characterData and self.characterData.currentHealth
        if currentHealth == nil then currentHealth = maxHealth end
        local currentShield = self.characterData and self.characterData.currentShield or 0
        
        unitData = {
            maxHealth = math.max(1, maxHealth),
            currentHealth = currentHealth,
            currentShield = currentShield
        }
    elseif self.targetDataCache and self.targetDataCache[shortName] then
        unitData = self.targetDataCache[shortName]
    end

    if unitData then
        local maxHealth = unitData.maxHealth
        local currentHealth = unitData.currentHealth or maxHealth
        local currentShield = unitData.currentShield or 0
        
        -- Override Blizzard's min/max and value
        frame.healthBar:SetMinMaxValues(0, maxHealth)
        frame.healthBar:SetValue(currentHealth)
        
        -- Shield logic
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
        
        -- Update text to show Addon Health
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
        -- Request data if missing and connected
        if not isPlayer and UnitIsConnected(frame.unit) and UnitIsPlayer(frame.unit) then
            GAC.pendingTargetRequests = GAC.pendingTargetRequests or {}
            local now = GetTime()
            if not GAC.pendingTargetRequests[shortName] or (now - GAC.pendingTargetRequests[shortName]) > 10 then
                GAC.pendingTargetRequests[shortName] = now
                if GAC.RequestTargetData then
                    GAC:RequestTargetData(shortName)
                end
            end
        end

        -- Hide custom UI if not an addon user
        if frame.healthBar and frame.healthBar.GAC_ShieldBar then
            frame.healthBar.GAC_ShieldBar:Hide()
            frame.healthBar.GAC_OverShieldGlow:Hide()
        end
    end
end

function GAC:InitializeRaidPlate()
    if isRaidPlateHooked then return end
    isRaidPlateHooked = true
    
    -- Bucle para forzar actualizaciones cuando cambian los valores internos del addon
    local f = CreateFrame("Frame")
    local elapsed = 0
    f:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed >= 0.5 then
            elapsed = 0
            for frame in pairs(GAC.activeRaidFrames) do
                if frame and frame.IsVisible and frame:IsVisible() and frame.unit then
                    if GAC.UpdateRaidPlate then
                        GAC:UpdateRaidPlate(frame)
                    end
                elseif frame and (not frame.IsVisible or not frame:IsVisible()) then
                    GAC.activeRaidFrames[frame] = nil
                end
            end
        end
    end)
    
    if CompactUnitFrame_UpdateHealth then
        hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
            if GAC.UpdateRaidPlate then GAC:UpdateRaidPlate(frame) end
        end)
    end
    
    if CompactUnitFrame_UpdateMaxHealth then
        hooksecurefunc("CompactUnitFrame_UpdateMaxHealth", function(frame)
            if GAC.UpdateRaidPlate then GAC:UpdateRaidPlate(frame) end
        end)
    end
    
    if CompactUnitFrame_UpdateStatusText then
        hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
            if GAC.UpdateRaidPlate then GAC:UpdateRaidPlate(frame) end
        end)
    end
end
