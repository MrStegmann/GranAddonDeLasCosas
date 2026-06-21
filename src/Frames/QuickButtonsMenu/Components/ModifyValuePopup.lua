local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.QuickButtonsMenu = GAC.Components.QuickButtonsMenu or {}

function GAC.Components.QuickButtonsMenu:ShowModifyValuePopup(title, callback)
    if not GAC.modifyValuePopup then
        local f = CreateFrame("Frame", "GACModifyValuePopup", UIParent, "BackdropTemplate")
        f:SetSize(220, 110)
        f:SetPoint("CENTER")
        f:SetFrameStrata("DIALOG")
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
        
        local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("TOP", 0, -20)
        f.text = text
        
        local editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        editBox:SetSize(80, 20)
        editBox:SetPoint("CENTER", 0, 0)
        editBox:SetAutoFocus(true)
        f.editBox = editBox
        
        local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        btn:SetSize(80, 22)
        btn:SetPoint("BOTTOM", 0, 15)
        btn:SetText("Aceptar")
        f.btn = btn
        
        local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -5, -5)
        
        local function submit()
            local val = tonumber(f.editBox:GetText())
            if val then
                if f.callback then f.callback(val) end
            end
            f:Hide()
        end
        
        btn:SetScript("OnClick", submit)
        editBox:SetScript("OnEnterPressed", submit)
        editBox:SetScript("OnEscapePressed", function() f:Hide() end)
        
        GAC.modifyValuePopup = f
    end
    
    GAC.modifyValuePopup.text:SetText(title)
    GAC.modifyValuePopup.editBox:SetText("")
    GAC.modifyValuePopup.callback = callback
    GAC.modifyValuePopup:Show()
    GAC.modifyValuePopup.editBox:SetFocus()
end
