local addonName, GAC = ...

-- Helper for TRP3 style sub-tab buttons
function GAC:CreateSubTabButton(parent, text, width)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 26)
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0, 0, 0, 0.6)
    btn:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.5)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)

    btn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.25, 0.78, 0.94, 0.3) end)
    btn:SetScript("OnLeave", function(self)
        if not self.selected then 
            self:SetBackdropColor(0, 0, 0, 0.6) 
            self.text:SetTextColor(1, 1, 1)
        else 
            self:SetBackdropColor(0.25, 0.78, 0.94, 0.15) 
            self.text:SetTextColor(0.25, 0.78, 0.94)
        end
    end)

    return btn
end