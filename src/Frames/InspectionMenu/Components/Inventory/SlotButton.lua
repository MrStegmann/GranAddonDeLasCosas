local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InspectionMenu = GAC.Components.InspectionMenu or {}

function GAC.Components.InspectionMenu:CreateSlotButton(parent, slotData, x, y, isWeaponSlot, wXOffset)
    local slotButton = CreateFrame("Button", "GAC_InspectInventorySlot" .. slotData.id, parent)
    slotButton:SetSize(37, 37)
    slotButton:SetPoint("TOPLEFT", x, y)
    
    local icon = slotButton:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    slotButton.icon = icon
    
    local border = slotButton:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    border:SetSize(60, 60)
    border:SetPoint("CENTER", 0, 0)
    slotButton.customBorder = border
    
    slotButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    slotButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")

    slotButton.icon:SetTexture(slotData.icon)
    
    local label
    if isWeaponSlot then
        label = GAC:CreateFontString(parent, slotData.label, "GameFontNormal", { "BOTTOM", slotButton, "TOP", 0, 5 }, { 0.5, 0.5, 0.5 })
        
        local itemLabel = GAC:CreateFontString(parent, "", "GameFontNormalSmall", { "TOP", slotButton, "BOTTOM", 0, -5 }, { 0.5, 0.5, 0.5 })
        itemLabel:SetWidth(wXOffset - 10)
        itemLabel:SetWordWrap(false)
        slotButton.itemLabel = itemLabel
    else
        label = GAC:CreateFontString(parent, slotData.label, "GameFontNormal", { "LEFT", slotButton, "RIGHT", 15, 0 }, { 0.5, 0.5, 0.5 })
    end
    
    slotButton.slotID = slotData.id
    slotButton.slotName = slotData.name
    slotButton.emptyIcon = slotData.icon
    slotButton.emptyLabel = slotData.label
    slotButton.label = label

    slotButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.itemDataList and #self.itemDataList > 0 then
            GAC.Utils.InspectionInventory:DrawTooltip(GameTooltip, self.itemDataList[1], self.itemDataList.notAllowed)
            if self.itemDataList[2] then
                ShoppingTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE")
                ShoppingTooltip1:ClearAllPoints()
                ShoppingTooltip1:SetPoint("TOPLEFT", GameTooltip, "TOPRIGHT", 5, 0)
                GAC.Utils.InspectionInventory:DrawTooltip(ShoppingTooltip1, self.itemDataList[2], self.itemDataList.notAllowed)
            end
        else
            GameTooltip:SetText(self.emptyLabel)
            GameTooltip:Show()
        end
    end)
    slotButton:SetScript("OnLeave", function(self)
        if GameTooltip.originalBorderR then
            GameTooltip:SetBackdropBorderColor(GameTooltip.originalBorderR, GameTooltip.originalBorderG, GameTooltip.originalBorderB, GameTooltip.originalBorderA)
            GameTooltip.originalBorderR = nil
        end
        GameTooltip:Hide()
        if ShoppingTooltip1.originalBorderR then
            ShoppingTooltip1:SetBackdropBorderColor(ShoppingTooltip1.originalBorderR, ShoppingTooltip1.originalBorderG, ShoppingTooltip1.originalBorderB, ShoppingTooltip1.originalBorderA)
            ShoppingTooltip1.originalBorderR = nil
        end
        ShoppingTooltip1:Hide()
    end)
    
    return slotButton
end
