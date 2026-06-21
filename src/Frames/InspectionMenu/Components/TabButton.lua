local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InspectionMenu = GAC.Components.InspectionMenu or {}

function GAC.Components.InspectionMenu:CreateTabButton(parent, id, label, index)
    local btnWidth = parent:GetWidth() - 4
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(btnWidth, 36)
    btn:SetPoint("TOPLEFT", 2, -10 - (index * 38))
    btn:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground" })
    btn:SetBackdropColor(0, 0, 0, 0)

    local tc = GAC.Stores.InspectionMenu.Constants.THEME_COLOR

    local indicator = btn:CreateTexture(nil, "OVERLAY")
    indicator:SetSize(3, 22)
    indicator:SetPoint("LEFT", 2, 0)
    indicator:SetColorTexture(tc.r, tc.g, tc.b, tc.a)
    indicator:Hide()
    btn.indicator = indicator

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 15, 0)
    text:SetText(label:upper())
    btn.text = text

    btn:SetScript("OnEnter", function(s) 
        s:SetBackdropColor(GAC.Stores.InspectionMenu.Constants.TAB_HOVER_BG_COLOR.r, GAC.Stores.InspectionMenu.Constants.TAB_HOVER_BG_COLOR.g, GAC.Stores.InspectionMenu.Constants.TAB_HOVER_BG_COLOR.b, GAC.Stores.InspectionMenu.Constants.TAB_HOVER_BG_COLOR.a)
        s.text:SetTextColor(tc.r, tc.g, tc.b, tc.a)
    end)
    btn:SetScript("OnLeave", function(s)
        if GAC.Stores.InspectionMenu.Tabs[id] and not GAC.Stores.InspectionMenu.Tabs[id].content:IsShown() then
            s:SetBackdropColor(GAC.Stores.InspectionMenu.Constants.TAB_INACTIVE_BG_COLOR.r, GAC.Stores.InspectionMenu.Constants.TAB_INACTIVE_BG_COLOR.g, GAC.Stores.InspectionMenu.Constants.TAB_INACTIVE_BG_COLOR.b, GAC.Stores.InspectionMenu.Constants.TAB_INACTIVE_BG_COLOR.a)
            s.text:SetTextColor(GAC.Stores.InspectionMenu.Constants.TEXT_COLOR_WHITE.r, GAC.Stores.InspectionMenu.Constants.TEXT_COLOR_WHITE.g, GAC.Stores.InspectionMenu.Constants.TEXT_COLOR_WHITE.b, GAC.Stores.InspectionMenu.Constants.TEXT_COLOR_WHITE.a)
        end
    end)

    return btn
end
