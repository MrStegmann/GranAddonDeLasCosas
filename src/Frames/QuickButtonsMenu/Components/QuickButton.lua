local addonName, GAC = ...

function GAC:CreateQuickButton(parent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0, 0, 0, 0.6)
    btn:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.5)

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetColorTexture(1, 1, 1, 0.2)
    highlight:SetPoint("TOPLEFT", 2, -2)
    highlight:SetPoint("BOTTOMRIGHT", -2, 2)

    btn:HookScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.25, 0.78, 0.94, 1)
    end)
    btn:HookScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.5)
    end)
    return btn
end
