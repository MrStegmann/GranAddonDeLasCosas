local addonName, GAC = ...

function GAC:CreateMinimapButton()
    if self.minimapButton then return end

    -- Asegurar que existan las tablas de datos para la posición
    self.characterData = self.characterData or {}
    self.characterData.ui = self.characterData.ui or {}
    if self.characterData.ui.minimapPos == nil then
        self.characterData.ui.minimapPos = 45 -- Ángulo inicial por defecto
    end

    local button = CreateFrame("Button", "GACMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameLevel(8)
    button:SetToplevel(true)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Dice_01")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")

    local function UpdatePosition()
        local angle = self.characterData.ui.minimapPos
        local x = math.cos(math.rad(angle)) * 80
        local y = math.sin(math.rad(angle)) * 80
        button:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(s) s:LockHighlight(); s.isDragging = true end)
    button:SetScript("OnDragStop", function(s) s:UnlockHighlight(); s.isDragging = false end)
    button:SetScript("OnUpdate", function(s)
        if s.isDragging then
            local x, y = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            local cx, cy = Minimap:GetCenter()
            local angle = math.deg(math.atan2(y / scale - cy, x / scale - cx))
            self.characterData.ui.minimapPos = angle
            UpdatePosition()
        end
    end)

    button:SetScript("OnClick", function() self:ToggleMainMenu() end)
    button:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_LEFT")
        GameTooltip:SetText("Gran Addon de las Cosas")
        GameTooltip:AddLine("Click: Abrir menú principal", 1, 1, 1)
        GameTooltip:AddLine("Arrastrar: Mover botón", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    UpdatePosition()
    self.minimapButton = button
end
