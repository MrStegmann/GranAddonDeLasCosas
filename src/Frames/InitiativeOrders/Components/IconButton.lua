local addonName, GAC = ...

function GAC:CreateIconButton(parent, size, iconTexture, tooltipTitle, tooltipText, onClickFunc)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(size, size)
    btn:SetNormalTexture(iconTexture)
    
    if onClickFunc then
        btn:SetScript("OnClick", onClickFunc)
    end
    
    if tooltipTitle or tooltipText then
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if tooltipTitle then
                GameTooltip:SetText(tooltipTitle)
            end
            if tooltipText then
                GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    
    return btn
end
