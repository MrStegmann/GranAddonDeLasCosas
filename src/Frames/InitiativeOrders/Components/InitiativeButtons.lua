local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InitiativeOrders = GAC.Components.InitiativeOrders or {}

function GAC.Components.InitiativeOrders:CreateSortButton(frame)
    local sortBtn = GAC:CreateIconButton(frame, 25, "Interface\\Icons\\INV_Misc_Book_08", "Ordenar", "Ordenar y guardar historial", function()
        if GAC.activeInitiativeView == "current" then
            GAC:SortInitiativeOrder()
            if GAC.Transmitter then
                GAC.Transmitter:Trigger(GAC.Enums.Events.INIT_ACTION, "SORT")
            end
        end
    end)
    sortBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    return sortBtn
end

function GAC.Components.InitiativeOrders:CreateLoadButton(frame, dropdown)
    local loadBtn = GAC:CreateIconButton(frame, 25, "Interface\\Icons\\INV_Misc_EngGizmos_18", "Cargar", "Cargar historial a toda la banda", function()
        if GAC.activeInitiativeView ~= "current" then
            GAC:ClearInitiativeOrder()
            if GAC.Transmitter then
                GAC.Transmitter:Trigger(GAC.Enums.Events.INIT_ACTION, "CLEAR")
            end
            
            local hist = GAC.characterData.initiativeHistory[GAC.activeInitiativeView]
            if hist and hist.rolls then
                for i, roll in ipairs(hist.rolls) do
                    table.insert(GAC.initiativeOrder, {name = roll.name, total = roll.total})
                    local payload = "INIT:ADD:" .. tostring(roll.name) .. ":" .. tostring(roll.total)
                    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "INSTANCE_CHAT")
                    elseif IsInRaid() then
                        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "RAID")
                    elseif IsInGroup() then
                        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "PARTY")
                    end
                end
                
                for i, roll in ipairs(hist.rolls) do
                    if roll.icon and roll.icon > 0 then
                        GAC:SetInitiativeIcon(i, roll.icon)
                        if GAC.Transmitter then
                            GAC.Transmitter:Trigger(GAC.Enums.Events.INIT_ICON, i, roll.icon)
                        end
                    end
                end
            end
            
            GAC.currentLinkedHistory = GAC.activeInitiativeView
            GAC.activeInitiativeView = "current"
            UIDropDownMenu_SetText(dropdown, "Combate Actual")
            GAC:UpdateInitiativeFrame()
            if frame.UpdateButtonVisibility then frame.UpdateButtonVisibility() end
        end
    end)
    loadBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    loadBtn:Hide()
    return loadBtn
end

function GAC.Components.InitiativeOrders:CreateClearButton(frame, dropdown)
    local clearBtn = GAC:CreateIconButton(frame, 25, "Interface\\Icons\\INV_Misc_Bag_08", "Limpiar", "Limpiar lista actual / Borrar historial", function()
        if GAC.activeInitiativeView == "current" then
            GAC:ClearInitiativeOrder()
            if GAC.Transmitter then
                GAC.Transmitter:Trigger(GAC.Enums.Events.INIT_ACTION, "CLEAR")
            end
        else
            if GAC.characterData and GAC.characterData.initiativeHistory then
                table.remove(GAC.characterData.initiativeHistory, GAC.activeInitiativeView)
                GAC.activeInitiativeView = "current"
                GAC:UpdateInitiativeFrame()
                UIDropDownMenu_SetText(dropdown, "Combate Actual")
                if frame.UpdateButtonVisibility then frame.UpdateButtonVisibility() end
            end
        end
    end)
    clearBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    clearBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if GAC.activeInitiativeView == "current" then
            GameTooltip:SetText("Limpiar lista actual")
        else
            GameTooltip:SetText("Borrar este historial")
        end
        GameTooltip:Show()
    end)
    return clearBtn
end

function GAC.Components.InitiativeOrders:CreateMinimizeButton(frame)
    local minimizeBtn = CreateFrame("Button", nil, frame)
    minimizeBtn:SetSize(20, 20)
    minimizeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up")
    minimizeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Down")
    minimizeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    
    minimizeBtn:SetScript("OnClick", function()
        local isMinimized = GAC.Utils.InitiativeOrders:GetMinimizedState()
        isMinimized = not isMinimized
        GAC.Utils.InitiativeOrders:SetMinimizedState(isMinimized)
        GAC.Utils.InitiativeOrders:ApplyMinimizedState(frame, isMinimized)
    end)
    
    return minimizeBtn
end
