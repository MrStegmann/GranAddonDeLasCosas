local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InitiativeOrders = GAC.Components.InitiativeOrders or {}

function GAC.Components.InitiativeOrders:InitHistoryDropdown(dropdown, frame)
    UIDropDownMenu_SetWidth(dropdown, 110)
    UIDropDownMenu_SetText(dropdown, "Combate Actual")
    
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        
        info.text = "Combate Actual"
        info.func = function()
            GAC.activeInitiativeView = "current"
            UIDropDownMenu_SetText(dropdown, "Combate Actual")
            GAC:UpdateInitiativeFrame()
            if frame.UpdateButtonVisibility then frame.UpdateButtonVisibility() end
        end
        info.checked = (GAC.activeInitiativeView == "current")
        UIDropDownMenu_AddButton(info)
        
        if GAC.characterData and GAC.characterData.initiativeHistory then
            for i, historyEntry in ipairs(GAC.characterData.initiativeHistory) do
                local infoHist = UIDropDownMenu_CreateInfo()
                infoHist.text = historyEntry.date
                infoHist.func = function()
                    GAC.activeInitiativeView = i
                    UIDropDownMenu_SetText(dropdown, historyEntry.date)
                    GAC:UpdateInitiativeFrame()
                    if frame.UpdateButtonVisibility then frame.UpdateButtonVisibility() end
                end
                infoHist.checked = (GAC.activeInitiativeView == i)
                UIDropDownMenu_AddButton(infoHist)
            end
        end
    end)
end

function GAC.Components.InitiativeOrders:InitContextMenu(contextMenu)
    UIDropDownMenu_Initialize(contextMenu, function(self, level, menuList)
        local index = GAC.contextMenuIndex
        if not index then return end
        local currentData = GAC.initiativeOrder[index]
        if not currentData then return end
        
        if level == 1 then
            local info = UIDropDownMenu_CreateInfo()
            info.text = currentData.name
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            info = UIDropDownMenu_CreateInfo()
            info.text = "Mover..."
            info.hasArrow = true
            info.menuList = "MOVE"
            info.notCheckable = true
            info.keepShownOnClick = true
            UIDropDownMenu_AddButton(info, level)
            
            info = UIDropDownMenu_CreateInfo()
            info.text = "Icono..."
            info.hasArrow = true
            info.menuList = "ICON"
            info.notCheckable = true
            info.keepShownOnClick = true
            UIDropDownMenu_AddButton(info, level)
        elseif level == 2 then
            if menuList == "MOVE" then
                local function MoveAction(targetIdx)
                    GAC:MoveInitiativeIndex(index, targetIdx)
                    if GAC.Transmitter then
                        GAC.Transmitter:Trigger(GAC.Enums.Events.INIT_MOVE, index, targetIdx)
                    end
                    CloseDropDownMenus()
                end
                
                local info = UIDropDownMenu_CreateInfo()
                info.notCheckable = true
                info.text = "Subir al primero"
                info.disabled = (index == 1)
                info.func = function() MoveAction(1) end
                UIDropDownMenu_AddButton(info, level)
                
                info = UIDropDownMenu_CreateInfo()
                info.notCheckable = true
                info.text = "Subir 1 puesto"
                info.disabled = (index == 1)
                info.func = function() MoveAction(index - 1) end
                UIDropDownMenu_AddButton(info, level)
                
                info = UIDropDownMenu_CreateInfo()
                info.notCheckable = true
                info.text = "Bajar 1 puesto"
                info.disabled = (index == #GAC.initiativeOrder)
                info.func = function() MoveAction(index + 1) end
                UIDropDownMenu_AddButton(info, level)
                
                info = UIDropDownMenu_CreateInfo()
                info.notCheckable = true
                info.text = "Bajar al último"
                info.disabled = (index == #GAC.initiativeOrder)
                info.func = function() MoveAction(#GAC.initiativeOrder) end
                UIDropDownMenu_AddButton(info, level)
                
            elseif menuList == "ICON" then
                local iconsMap = {
                    {id = 1, name = "Estrella"},
                    {id = 2, name = "Círculo"},
                    {id = 3, name = "Diamante"},
                    {id = 4, name = "Triángulo"},
                    {id = 5, name = "Luna"},
                    {id = 6, name = "Cuadrado"},
                    {id = 7, name = "Cruz"},
                    {id = 8, name = "Calavera"}
                }
                
                local function SetIconAction(iconID)
                    GAC:SetInitiativeIcon(index, iconID)
                    if GAC.Transmitter then
                        GAC.Transmitter:Trigger(GAC.Enums.Events.INIT_ICON, index, iconID)
                    end
                end
                
                for _, ic in ipairs(iconsMap) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = ic.name
                    info.func = function() SetIconAction(ic.id) end
                    info.checked = (currentData.icon == ic.id)
                    UIDropDownMenu_AddButton(info, level)
                end
                
                local info = UIDropDownMenu_CreateInfo()
                info.text = "Quitar Icono"
                info.func = function() SetIconAction(0) end
                info.checked = (not currentData.icon or currentData.icon == 0)
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end, "MENU")
end
