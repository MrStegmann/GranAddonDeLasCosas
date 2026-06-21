local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}

function GAC.Components.MainMenu:CreateDarkTabBackground(parent)
    local bg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    bg:SetAllPoints()
    bg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    bg:SetBackdropColor(0, 0, 0, 0.3)
    bg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
    return bg
end

function GAC.Components.MainMenu:CreateScrollableTab(parent, innerWidth, innerHeight)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -28, 4)

    local bg = GAC.Components.MainMenu:CreateDarkTabBackground(scrollFrame)
    bg:ClearAllPoints()
    bg:SetSize(innerWidth or 400, innerHeight or 500)
    scrollFrame:SetScrollChild(bg)

    scrollFrame:SetScript("OnSizeChanged", function(self, width, height)
        bg:SetWidth(width)
    end)

    return scrollFrame, bg
end
