local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InspectionMenu = GAC.Components.InspectionMenu or {}

function GAC.Components.InspectionMenu:CreateSidebar(parent)
    local sidebar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    sidebar:SetSize(180, 0)
    sidebar:SetPoint("TOPLEFT", 12, -50)
    sidebar:SetPoint("BOTTOMLEFT", 12, 12)
    sidebar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    sidebar:SetBackdropColor(0, 0, 0, 0.4)
    local tc = GAC.Stores.InspectionMenu.Constants.THEME_COLOR
    sidebar:SetBackdropBorderColor(tc.r, tc.g, tc.b, 0.15)
    
    return sidebar
end
