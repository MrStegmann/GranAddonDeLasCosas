local _, GAC = ...

local isExpBarHooked = false

-- Función para actualizar la barra de experiencia por defecto del juego
function GAC:UpdateGameExpBar()
    if not StatusTrackingBarManager then return end

    -- Obtenemos el progreso de experiencia del addon
    
    local progress = self.characterData and self.characterData.progress or {}
    local currentExp = progress.currentExperience or 0
    local category = progress.category or "normal"
    local level = progress.level or 1
    local maxExp = self:GetRequiredExperience(category, level) or 1
    if maxExp <= 0 then maxExp = 1 end
    local percent = math.floor((currentExp / maxExp) * 100)

    if self.UpdatePlayerPlate then
        self:UpdatePlayerPlate()
    end

    local bars = StatusTrackingBarManager.bars
    if bars and #bars > 0 then
        local expBar = bars[1] -- En las interfaces modernas, la primera barra es la de experiencia

        -- Si es la primera vez, forzamos su visibilidad y anulamos el comportamiento de WoW
        if not isExpBarHooked then
            -- Forzamos que la barra siempre se muestre, incluso a nivel máximo (ej. nivel 70 en Epsilon)
            if expBar.ShouldBeVisible then
                expBar.ShouldBeVisible = function() return true end
            end
            
            -- Sobrescribimos Update para que el juego no intente poner la experiencia real de WoW
            -- Y hacemos que cada vez que el juego intente actualizarla, ponga nuestros valores
            if expBar.Update then
                expBar.Update = function(self) 
                    GAC:UpdateGameExpBar()
                end
            end
            
            isExpBarHooked = true
            StatusTrackingBarManager:UpdateBars()
            return
        end

        -- Actualizamos los valores visuales de la barra
        if expBar.StatusBar then
            expBar.StatusBar:SetMinMaxValues(0, maxExp)
            expBar.StatusBar:SetValue(currentExp)
            
            if expBar.OverlayFrame and expBar.OverlayFrame.Text then
                expBar.OverlayFrame.Text:SetText(string.format("%d / %d (%d%%)", currentExp, maxExp, percent))
            end
        end
    end
end

-- Configuramos los eventos para la inicialización
local ExpBarEvents = CreateFrame("Frame")
ExpBarEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
ExpBarEvents:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if StatusTrackingBarManager then
            -- Primera actualización
            GAC:UpdateGameExpBar()
            
            -- Aseguramos que la barra mantenga nuestros valores si el UI la actualiza (ej. al cambiar de zona)
            hooksecurefunc(StatusTrackingBarManager, "UpdateBars", function()
                GAC:UpdateGameExpBar()
            end)

            -- Hookeamos la función del addon que se llama cada vez que cambia la experiencia
            if GAC.NormalizeExperienceProgressData then
                hooksecurefunc(GAC, "NormalizeExperienceProgressData", function(self_gac)
                    self_gac:UpdateGameExpBar()
                end)
            end
        end
        
        -- Ya no necesitamos este evento
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
