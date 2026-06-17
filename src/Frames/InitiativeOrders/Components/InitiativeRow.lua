local addonName, GAC = ...

function GAC:CreateInitiativeRow(parent, width, height, index, contextMenu, prevRow)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(width, height)
    if index == 1 then
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    else
        row:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, 0)
    end
    row:RegisterForClicks("RightButtonUp")
    
    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")
    
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(14, 14)
    icon:SetPoint("LEFT", row, "LEFT", 2, 0)
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    icon:Hide()
    row.icon = icon
    
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
    text:SetPoint("RIGHT", row, "RIGHT", -30, 0)
    text:SetJustifyH("LEFT")
    row.text = text
    
    local val = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    val:SetPoint("RIGHT", row, "RIGHT", -5, 0)
    val:SetJustifyH("RIGHT")
    row.val = val
    
    row.index = index
    row:SetScript("OnClick", function(self, button)
        if button == "RightButton" and GAC.activeInitiativeView == "current" then
            if UnitIsGroupLeader("player") or not IsInGroup() then
                GAC.contextMenuIndex = self.index
                ToggleDropDownMenu(1, nil, contextMenu, "cursor", 0, 0)
            end
        end
    end)
    
    row:Hide()
    return row
end
