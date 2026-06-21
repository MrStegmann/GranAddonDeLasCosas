local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}

function GAC.Components.MainMenu:CreateSidebar(parent)
    local consts = GAC.Stores.MainMenu.Constants

    local sidebar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    sidebar:SetSize(consts.SIDEBAR_WIDTH, 0)
    sidebar:SetPoint("TOPLEFT", 12, -50)
    sidebar:SetPoint("BOTTOMLEFT", 12, 12)
    
    sidebar:SetBackdrop({
        bgFile = consts.BACKDROP_BG,
        edgeFile = consts.BACKDROP_EDGE,
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    
    sidebar:SetBackdropColor(
        consts.SIDEBAR_BG_COLOR.r, 
        consts.SIDEBAR_BG_COLOR.g, 
        consts.SIDEBAR_BG_COLOR.b, 
        consts.SIDEBAR_BG_COLOR.a
    )
    sidebar:SetBackdropBorderColor(
        consts.SIDEBAR_BORDER_COLOR.r, 
        consts.SIDEBAR_BORDER_COLOR.g, 
        consts.SIDEBAR_BORDER_COLOR.b, 
        consts.SIDEBAR_BORDER_COLOR.a
    )

    return sidebar
end
