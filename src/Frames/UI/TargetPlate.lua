local _, GAC = ...

local isTargetPlateHooked = false

function GAC:UpdateTargetPlate()
    if not isTargetPlateHooked then return end

    local targetName = UnitName("target")
    if not targetName then return end

    local shortName = Ambiguate(targetName, "none")
    local isPlayer = UnitIsPlayer("target")
    
    local targetData = nil
    
    if UnitIsUnit("target", "player") then
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
        
        targetData = {
            level = currentLevel,
            category = category,
            maxHealth = math.max(1, maxHealth),
            currentHealth = currentHealth,
            currentShield = currentShield
        }
    elseif isPlayer and self.targetDataCache and self.targetDataCache[shortName] then
        targetData = self.targetDataCache[shortName]
    end

    -- Si tenemos datos (nuestros o de otro jugador con addon)
    if targetData then
        -- 1. Nivel
        local levelText = TargetFrameTextureFrameLevelText or TargetLevelText
        if levelText then
            levelText:SetText(targetData.level)
            levelText:SetVertexColor(1, 0.82, 0)
            levelText:SetDrawLayer("OVERLAY", 7)
        end
        
        -- 2. Vida y Escudo
        if TargetFrameHealthBar then
            local maxHealth = targetData.maxHealth
            local currentHealth = targetData.currentHealth or maxHealth
            local currentShield = targetData.currentShield or 0
            
            TargetFrameHealthBar:SetMinMaxValues(0, maxHealth)
            TargetFrameHealthBar:SetValue(currentHealth)
            
            -- Dibujar el escudo
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

        -- 3. Dragón y categoría
        local parentForOverlay = TargetFrameTextureFrame or TargetFrame
        
        if not parentForOverlay.GACDragonOverlay then
            local overlay = parentForOverlay:CreateTexture("GACTargetDragonOverlay", "OVERLAY")
            overlay:SetSize(256, 128)
            -- En el TargetFrame, anclamos con un pequeño offset porque el retrato está a la derecha
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
            overlay:SetTexCoord(0, 1, 0, 1) -- NO voltear (nativo para target)
        elseif category == "élite" or category == "elite" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            overlay:SetTexCoord(0, 1, 0, 1)
        elseif category == "jefe" or category == "boss" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            overlay:SetTexCoord(0, 1, 0, 1)
            overlay:SetVertexColor(1, 0.7, 0.7) -- Teñido de rojo
        else
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
            overlay:SetTexCoord(0, 1, 0, 1)
        end
        
    else
        -- No es un jugador o no tiene el addon, limpiamos nuestra UI
        local levelText = TargetFrameTextureFrameLevelText or TargetLevelText
        if levelText then
            -- El juego se encarga de rellenarlo nativamente si restauramos la opacidad y color
            levelText:SetVertexColor(1, 0.82, 0)
        end
        
        -- Limpiamos el escudo visual si no es jugador o no tiene addon
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

function GAC:InitializeTargetPlate()
    if isTargetPlateHooked then return end
    isTargetPlateHooked = true
    
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:SetScript("OnEvent", function()
        if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player") then
            local shortName = Ambiguate(UnitName("target"), "none")
            
            -- Si la caché tiene más de 5 minutos, la refrescamos
            local cached = GAC.targetDataCache and GAC.targetDataCache[shortName]
            if not cached or (GetTime() - (cached.timestamp or 0) > 300) then
                if GAC.RequestTargetData then
                    GAC:RequestTargetData(shortName)
                end
            end
        end
        
        GAC:UpdateTargetPlate()
    end)

    local elapsed = 0
    f:SetScript("OnUpdate", function(self, dt)
        if not UnitExists("target") then return end
        elapsed = elapsed + dt
        if elapsed >= 0.5 then
            elapsed = 0
            if GAC.UpdateTargetPlate then
                GAC:UpdateTargetPlate()
            end
        end
    end)
    
    -- Hooks nativos para evitar que WoW sobrescriba nuestra UI
    if TargetFrame_Update then
        hooksecurefunc("TargetFrame_Update", function()
            if GAC.UpdateTargetPlate then GAC:UpdateTargetPlate() end
        end)
    end
    
    if UnitFrameHealthBar_Update then
        hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar, unit)
            if unit == "target" and statusbar == TargetFrameHealthBar then
                if GAC.UpdateTargetPlate then GAC:UpdateTargetPlate() end
            end
        end)
    end
    
    if TextStatusBar_UpdateTextString then
        hooksecurefunc("TextStatusBar_UpdateTextString", function(textStatusBar)
            if textStatusBar == TargetFrameHealthBar then
                if GAC.UpdateTargetPlate then GAC:UpdateTargetPlate() end
            end
        end)
    end
end
