local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.QuickButtonsMenu = GAC.Components.QuickButtonsMenu or {}

function GAC.Components.QuickButtonsMenu:CreateHitZonePopup()
    if GAC.HitZonePopup then return GAC.HitZonePopup end
    
    local c = GAC.Stores.QuickButtonsMenu.Constants
    local frame = CreateFrame("Frame", "GACHitZonePopup", UIParent, "BackdropTemplate")
    frame:SetSize(250, 200)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(c.BACKGROUND_COLOR.r, c.BACKGROUND_COLOR.g, c.BACKGROUND_COLOR.b, 0.95)
    frame:SetBackdropBorderColor(c.BORDER_COLOR.r, c.BORDER_COLOR.g, c.BORDER_COLOR.b, 1)
    
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("Selecciona Zona de Impacto")
    
    local zones = {
        { label = "Cabeza", slotId = 1 },
        { label = "Pecho", slotId = 5 },
        { label = "Manos", slotId = 10 },
        { label = "Piernas", slotId = 7 }
    }
    
    frame.buttons = {}
    for i, zone in ipairs(zones) do
        local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        btn:SetSize(210, 30)
        if i == 1 then
            btn:SetPoint("TOP", title, "BOTTOM", 0, -15)
        else
            btn:SetPoint("TOP", frame.buttons[i-1], "BOTTOM", 0, -5)
        end
        btn:SetText(zone.label)
        
        btn:SetScript("OnClick", function()
            frame:Hide()
            if frame.onZoneSelectedCallback then
                frame.onZoneSelectedCallback(zone.label, zone.slotId)
            end
        end)
        
        table.insert(frame.buttons, btn)
    end
    
    -- Close button (X)
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    frame:Hide()
    GAC.HitZonePopup = frame
    return frame
end

function GAC:ShowHitZonePopup(callback)
    local popup = GAC.Components.QuickButtonsMenu:CreateHitZonePopup()
    popup.onZoneSelectedCallback = callback
    popup:Show()
end

function GAC.Components.QuickButtonsMenu:CreateDamageTypePopup()
    if GAC.DamageTypePopup then return GAC.DamageTypePopup end
    
    local c = GAC.Stores.QuickButtonsMenu.Constants
    local frame = CreateFrame("Frame", "GACDamageTypePopup", UIParent, "BackdropTemplate")
    frame:SetSize(250, 160)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(c.BACKGROUND_COLOR.r, c.BACKGROUND_COLOR.g, c.BACKGROUND_COLOR.b, 0.95)
    frame:SetBackdropBorderColor(c.BORDER_COLOR.r, c.BORDER_COLOR.g, c.BORDER_COLOR.b, 1)
    
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("Selecciona Tipo de Daño")
    
    local types = {
        { label = "Perforante", key = "piercing" },
        { label = "Cortante", key = "slashing" },
        { label = "Contundente", key = "crushing" }
    }
    
    frame.buttons = {}
    for i, dtype in ipairs(types) do
        local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        btn:SetSize(210, 30)
        if i == 1 then
            btn:SetPoint("TOP", title, "BOTTOM", 0, -15)
        else
            btn:SetPoint("TOP", frame.buttons[i-1], "BOTTOM", 0, -5)
        end
        btn:SetText(dtype.label)
        
        btn:SetScript("OnClick", function()
            frame:Hide()
            if frame.onTypeSelectedCallback then
                frame.onTypeSelectedCallback(dtype.label, dtype.key)
            end
        end)
        
        table.insert(frame.buttons, btn)
    end
    
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    frame:Hide()
    GAC.DamageTypePopup = frame
    return frame
end

function GAC:ShowDamageTypePopup(callback)
    local popup = GAC.Components.QuickButtonsMenu:CreateDamageTypePopup()
    popup.onTypeSelectedCallback = callback
    popup:Show()
end
