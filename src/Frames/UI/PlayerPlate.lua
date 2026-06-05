local _, GAC = ...

local isPlayerPlateHooked = false

function GAC:UpdatePlayerPlate()
    if not isPlayerPlateHooked then return end
    if PlayerFrame_UpdateLevel then PlayerFrame_UpdateLevel() end
    if PlayerFrameHealthBar then 
        UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
        if TextStatusBar_UpdateTextString then TextStatusBar_UpdateTextString(PlayerFrameHealthBar) end
    end
    
    -- 3. Modificar el dragón y su color según categoría
    local progress = self.characterData and self.characterData.progress or {}
    local category = string.lower(progress.category or "normal")
    
    local parentForOverlay = PlayerFrameTexture and PlayerFrameTexture:GetParent() or PlayerFrame
    
    if not parentForOverlay.GACDragonOverlay then
        local overlay = parentForOverlay:CreateTexture("GACPlayerDragonOverlay", "OVERLAY")
        overlay:SetSize(256, 128)
        -- Anclamos exactamente igual que en el TargetFrame pero del lado izquierdo
        overlay:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 0, 0)
        -- Usar BORDER para que no tape los textos (como el nivel), el FrameLevel del parent ya tapa la barra de vida
        overlay:SetDrawLayer("BORDER") 
        
        parentForOverlay.GACDragonOverlay = overlay
    end

    local overlay = parentForOverlay.GACDragonOverlay

    if category == "noob" then
        -- Restauramos el por defecto para "noob"
        if PlayerFrameTexture then
            PlayerFrameTexture:SetAlpha(1)
        end
        overlay:Hide()
    else
        -- Ocultamos la base y mostramos nuestro dragón
        if PlayerFrameTexture then
            PlayerFrameTexture:SetAlpha(0)
        end
        overlay:Show()
        
        -- Reiniciamos el color para que no arrastre tintes anteriores
        overlay:SetVertexColor(1, 1, 1)

        if category == "normal" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
            overlay:SetTexCoord(1, 0, 0, 1) -- Voltear horizontalmente
            overlay:SetVertexColor(1, 1, 1) -- Plata / Piedra (original)
        elseif category == "elite" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            overlay:SetTexCoord(1, 0, 0, 1) -- Voltear horizontalmente
        elseif category == "boss" then
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            overlay:SetTexCoord(1, 0, 0, 1) -- Voltear horizontalmente
            overlay:SetVertexColor(1, 0.7, 0.7) -- Teñido de rojo
        else
            overlay:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
            overlay:SetTexCoord(1, 0, 0, 1) -- Por defecto Rare
            overlay:SetVertexColor(1, 1, 1) -- Plata / Piedra (original)
        end
    end
end

function GAC:InitializePlayerPlate()
    if isPlayerPlateHooked then return end
    isPlayerPlateHooked = true
    
    -- 1. Hook para el nivel
    if PlayerFrame_UpdateLevel then
        hooksecurefunc("PlayerFrame_UpdateLevel", function()
            local progress = GAC.characterData and GAC.characterData.progress or {}
            local currentLevel = progress.level or 1
            if PlayerLevelText then
                PlayerLevelText:SetText(currentLevel)
                PlayerLevelText:SetVertexColor(1, 0.82, 0)
                -- Forzar que el texto siempre se renderice por encima de cualquier textura del mismo marco
                PlayerLevelText:SetDrawLayer("OVERLAY", 7)
            end
        end)
    end
    
    -- 2. Hook para la barra de vida (visual)
    if UnitFrameHealthBar_Update then
        hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar, unit)
            if unit == "player" and statusbar == PlayerFrameHealthBar then
                local progress = GAC.characterData and GAC.characterData.progress or {}
                local currentLevel = progress.level or 1
                local category = progress.category or "normal"
                local levelEntry = GAC:GetLevelEntry(category, currentLevel)
                local baseHealth = levelEntry and levelEntry.maxHealth or 10
                
                local attributes = GAC.characterData and GAC.characterData.attributes or {}
                local constitution = attributes["constitution"] or 0
                local maxHealth = baseHealth + constitution
                if maxHealth < 1 then maxHealth = 1 end
                
                local currentHealth = GAC.characterData and GAC.characterData.currentHealth
                if currentHealth == nil then currentHealth = maxHealth end
                
                local currentShield = GAC.characterData and GAC.characterData.currentShield or 0
                
                statusbar:SetMinMaxValues(0, maxHealth)
                statusbar:SetValue(currentHealth)

                -- Lógica visual del escudo
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
    
    -- 3. Hook para el texto de la barra de vida
    if TextStatusBar_UpdateTextString then
        hooksecurefunc("TextStatusBar_UpdateTextString", function(textStatusBar)
            if textStatusBar == PlayerFrameHealthBar then
                local progress = GAC.characterData and GAC.characterData.progress or {}
                local currentLevel = progress.level or 1
                local category = progress.category or "normal"
                local levelEntry = GAC:GetLevelEntry(category, currentLevel)
                local baseHealth = levelEntry and levelEntry.maxHealth or 10
                
                local attributes = GAC.characterData and GAC.characterData.attributes or {}
                local constitution = attributes["constitution"] or 0
                local maxHealth = baseHealth + constitution
                if maxHealth < 1 then maxHealth = 1 end
                
                local currentHealth = GAC.characterData and GAC.characterData.currentHealth
                if currentHealth == nil then currentHealth = maxHealth end
                
                local currentShield = GAC.characterData and GAC.characterData.currentShield or 0
                
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

    -- 4. Hook para que WoW no sobrescriba nuestra textura de dragón y mantenga oculto el base
    if PlayerFrame_Update then
        hooksecurefunc("PlayerFrame_Update", function()
            if GAC.UpdatePlayerPlate then
                GAC:UpdatePlayerPlate()
            end
        end)
    end

    -- Forzamos la actualización inicial
    if PlayerFrame_Update then PlayerFrame_Update() end
    if PlayerFrame_UpdateLevel then PlayerFrame_UpdateLevel() end
    if PlayerFrameHealthBar then UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player") end
end
