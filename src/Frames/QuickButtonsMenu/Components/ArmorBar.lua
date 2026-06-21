local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.QuickButtonsMenu = GAC.Components.QuickButtonsMenu or {}

function GAC.Components.QuickButtonsMenu:CreateArmorBar(frame)
    local c = GAC.Stores.QuickButtonsMenu.Constants
    frame.armorButtons = {}
    
    for i, slotData in ipairs(GAC.Stores.QuickButtonsMenu.ArmorSlots) do
        local btn = GAC:CreateQuickButton(frame)
        btn:SetSize(c.ARMOR_ICON_SIZE, c.ARMOR_ICON_SIZE)
        
        local col = slotData.col
        local row = slotData.row
        local xOffset = -5 - ((2 - col) * (c.ARMOR_ICON_SIZE + c.ARMOR_SPACING))
        local yOffset = -5 - (row * (c.ARMOR_ICON_SIZE + c.ARMOR_SPACING))
        btn:SetPoint("TOPRIGHT", frame, "TOPLEFT", xOffset, yOffset)
        
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(slotData.icon)
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn.icon = icon
        btn.slotID = slotData.id
        btn.numId = slotData.numId
        btn.emptyIconPath = slotData.icon
        
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetScript("OnClick", function(_, b)
            GAC.Utils.QuickButtonsMenu:HandleArmorClick(b, slotData)
            if GameTooltip:IsOwned(btn) then
                local onEnter = btn:GetScript("OnEnter")
                if onEnter then onEnter(btn) end
            end
        end)
        btn:SetScript("OnEnter", function(self)
            GAC.Utils.QuickButtonsMenu:DrawArmorTooltip(self, slotData)
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        table.insert(frame.armorButtons, btn)
    end
end
