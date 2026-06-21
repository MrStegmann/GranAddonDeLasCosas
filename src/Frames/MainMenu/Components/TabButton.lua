local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}

function GAC.Components.MainMenu:CreateTabButton(parent, id, label, index)
    local consts = GAC.Stores.MainMenu.Constants
    local btnWidth = parent:GetWidth() - 4

    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(btnWidth, 36)
    btn:SetPoint("TOPLEFT", 2, -10 - (index * 38))
    btn:SetBackdrop({ bgFile = consts.BACKDROP_BG })
    btn:SetBackdropColor(0, 0, 0, 0)

    -- Indicador lateral (TRP3 Style)
    local indicator = btn:CreateTexture(nil, "OVERLAY")
    indicator:SetSize(3, 22)
    indicator:SetPoint("LEFT", 2, 0)
    indicator:SetColorTexture(
        consts.TAB_ACTIVE_TEXT_COLOR.r, 
        consts.TAB_ACTIVE_TEXT_COLOR.g, 
        consts.TAB_ACTIVE_TEXT_COLOR.b, 
        consts.TAB_ACTIVE_TEXT_COLOR.a
    )
    indicator:Hide()
    btn.indicator = indicator

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 15, 0)
    text:SetText(label:upper())
    btn.text = text

    btn:SetScript("OnEnter", function(s) 
        s:SetBackdropColor(
            consts.TAB_HOVER_COLOR.r, 
            consts.TAB_HOVER_COLOR.g, 
            consts.TAB_HOVER_COLOR.b, 
            consts.TAB_HOVER_COLOR.a
        )
        s.text:SetTextColor(
            consts.TAB_ACTIVE_TEXT_COLOR.r, 
            consts.TAB_ACTIVE_TEXT_COLOR.g, 
            consts.TAB_ACTIVE_TEXT_COLOR.b
        )
    end)
    
    btn:SetScript("OnLeave", function(s)
        local store = GAC.Stores.MainMenu
        local isActive = (store.ActiveTab == id)
        
        if not isActive then
            s:SetBackdropColor(0, 0, 0, 0)
            s.text:SetTextColor(
                consts.TAB_INACTIVE_TEXT_COLOR.r, 
                consts.TAB_INACTIVE_TEXT_COLOR.g, 
                consts.TAB_INACTIVE_TEXT_COLOR.b
            )
        else
            s:SetBackdropColor(
                consts.TAB_ACTIVE_BG_COLOR.r, 
                consts.TAB_ACTIVE_BG_COLOR.g, 
                consts.TAB_ACTIVE_BG_COLOR.b, 
                consts.TAB_ACTIVE_BG_COLOR.a
            )
            s.text:SetTextColor(
                consts.TAB_ACTIVE_TEXT_COLOR.r, 
                consts.TAB_ACTIVE_TEXT_COLOR.g, 
                consts.TAB_ACTIVE_TEXT_COLOR.b
            )
        end
    end)

    return btn
end
