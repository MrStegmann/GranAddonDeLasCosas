local _, GAC = ...

-- Elementos de la UI
local FRAME_WIDTH = 250
local ROW_HEIGHT = 20
local MAX_ROWS = 20

function GAC:InitializeInitiativeFrame()
    if self.initiativeFrame then return end
    
    -- Marco principal
    local frame = CreateFrame("Frame", "GACInitiativeFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, 300)
    frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.05, 0.06, 0.08, 0.95)
    frame:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.8)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Título
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("Orden de Turnos")
    
    -- ScrollFrame para la lista
    local scrollFrame = CreateFrame("ScrollFrame", "GACInitiativeScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(FRAME_WIDTH - 40, MAX_ROWS * ROW_HEIGHT)
    scrollFrame:SetScrollChild(scrollChild)
    
    -- Menú Contextual para Líder
    local contextMenu = CreateFrame("Frame", "GACInitiativeContextMenu", frame, "UIDropDownMenuTemplate")
    
    -- Array visual de filas
    frame.rows = {}
    for i = 1, MAX_ROWS do
        local row = CreateFrame("Button", nil, scrollChild)
        row:SetSize(FRAME_WIDTH - 40, ROW_HEIGHT)
        if i == 1 then
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
        else
            row:SetPoint("TOPLEFT", frame.rows[i-1], "BOTTOMLEFT", 0, 0)
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
        
        row.index = i
        row:SetScript("OnClick", function(self, button)
            if button == "RightButton" and GAC.activeInitiativeView == "current" then
                if UnitIsGroupLeader("player") or not IsInGroup() then
                    GAC.contextMenuIndex = self.index
                    ToggleDropDownMenu(1, nil, contextMenu, "cursor", 0, 0)
                end
            end
        end)
        
        row:Hide()
        table.insert(frame.rows, row)
    end
    
    -- Botón Ordenar
    local sortBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    sortBtn:SetSize(25, 25)
    sortBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    sortBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Book_08")
    sortBtn:SetScript("OnClick", function()
        if GAC.activeInitiativeView == "current" then
            GAC:SortInitiativeOrder()
            if GAC.BroadcastInitiativeAction then
                GAC:BroadcastInitiativeAction("SORT")
            end
        end
    end)
    sortBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Ordenar y guardar historial")
        GameTooltip:Show()
    end)
    sortBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    -- Botón Cargar Historial
    local loadBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    loadBtn:SetSize(25, 25)
    loadBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    loadBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_EngGizmos_18")
    loadBtn:Hide()
    loadBtn:SetScript("OnClick", function()
        if GAC.activeInitiativeView ~= "current" then
            -- Borramos la red actual
            GAC:ClearInitiativeOrder()
            if GAC.BroadcastInitiativeAction then
                GAC:BroadcastInitiativeAction("CLEAR")
            end
            
            -- Recorremos el historial y enviamos los paquetes
            local hist = GAC.characterData.initiativeHistory[GAC.activeInitiativeView]
            if hist and hist.rolls then
                for i, roll in ipairs(hist.rolls) do
                    -- ADD local and remote
                    table.insert(GAC.initiativeOrder, {name = roll.name, total = roll.total})
                    -- Forzamos enviar el addon message manual imitando un add normal
                    local payload = "INIT:ADD:" .. tostring(roll.name) .. ":" .. tostring(roll.total)
                    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "INSTANCE_CHAT")
                    elseif IsInRaid() then
                        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "RAID")
                    elseif IsInGroup() then
                        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "PARTY")
                    end
                end
                
                -- ICON local and remote
                for i, roll in ipairs(hist.rolls) do
                    if roll.icon and roll.icon > 0 then
                        GAC:SetInitiativeIcon(i, roll.icon)
                        if GAC.BroadcastInitiativeIcon then
                            GAC:BroadcastInitiativeIcon(i, roll.icon)
                        end
                    end
                end
            end
            
            -- Nos vinculamos al historial que acabamos de cargar
            GAC.currentLinkedHistory = GAC.activeInitiativeView
            GAC.activeInitiativeView = "current"
            UIDropDownMenu_SetText(frame.historyDropdown, "Combate Actual")
            GAC:UpdateInitiativeFrame()
            if frame.UpdateButtonVisibility then frame.UpdateButtonVisibility() end
        end
    end)
    loadBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Cargar historial a toda la banda")
        GameTooltip:Show()
    end)
    loadBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    -- Botón Limpiar
    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(25, 25)
    clearBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    clearBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Bag_08")
    clearBtn:SetScript("OnClick", function()
        if GAC.activeInitiativeView == "current" then
            GAC:ClearInitiativeOrder()
            if GAC.BroadcastInitiativeAction then
                GAC:BroadcastInitiativeAction("CLEAR")
            end
        else
            -- Borrar el historial seleccionado
            if GAC.characterData and GAC.characterData.initiativeHistory then
                table.remove(GAC.characterData.initiativeHistory, GAC.activeInitiativeView)
                GAC.activeInitiativeView = "current"
                GAC:UpdateInitiativeFrame()
                UIDropDownMenu_SetText(frame.historyDropdown, "Combate Actual")
                if frame.UpdateButtonVisibility then frame.UpdateButtonVisibility() end
            end
        end
    end)
    clearBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if GAC.activeInitiativeView == "current" then
            GameTooltip:SetText("Limpiar lista actual")
        else
            GameTooltip:SetText("Borrar este historial")
        end
        GameTooltip:Show()
    end)
    clearBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    -- Menú Desplegable (Dropdown)
    local dropdown = CreateFrame("Frame", "GACInitiativeHistoryDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("BOTTOM", frame, "BOTTOM", 0, 7)
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
                    if GAC.BroadcastInitiativeMove then
                        GAC:BroadcastInitiativeMove(index, targetIdx)
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
                    if GAC.BroadcastInitiativeIcon then
                        GAC:BroadcastInitiativeIcon(index, iconID)
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

    frame.historyDropdown = dropdown
    
    -- Botón de minimizar
    local minimizeBtn = CreateFrame("Button", nil, frame)
    minimizeBtn:SetSize(20, 20)
    minimizeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up")
    minimizeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Down")
    minimizeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    
    local isMinimized = false
    minimizeBtn:SetScript("OnClick", function()
        isMinimized = not isMinimized
        if isMinimized then
            frame:SetHeight(30)
            scrollFrame:Hide()
            sortBtn:Hide()
            loadBtn:Hide()
            clearBtn:Hide()
            dropdown:Hide()
            minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up")
            minimizeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Down")
        else
            frame:SetHeight(300)
            scrollFrame:Show()
            minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up")
            minimizeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Down")
            if frame.UpdateButtonVisibility then frame.UpdateButtonVisibility() end
        end
    end)
    
    local function UpdateButtonVisibility()
        if isMinimized then return end
        if IsInGroup() and not UnitIsGroupLeader("player") then
            sortBtn:Hide()
            loadBtn:Hide()
            clearBtn:Hide()
            dropdown:Hide()
        else
            if GAC.activeInitiativeView == "current" then 
                sortBtn:Show()
                loadBtn:Hide()
            else
                sortBtn:Hide()
                loadBtn:Show()
            end
            clearBtn:Show()
            dropdown:Show()
        end
    end
    frame.UpdateButtonVisibility = UpdateButtonVisibility

    -- Eventos de grupo para mostrar/ocultar y permisos
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("PARTY_LEADER_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            if IsInGroup() or IsInRaid() then
                self:Show()
            else
                self:Hide()
                GAC:ClearInitiativeOrder() -- Auto limpia al salir
            end
        end
        UpdateButtonVisibility()
    end)
    
    self.initiativeFrame = frame
    
    -- Chequeo inicial
    if IsInGroup() or IsInRaid() then
        frame:Show()
    else
        frame:Hide()
    end
    UpdateButtonVisibility()
end

function GAC:UpdateInitiativeFrame()
    if not self.initiativeFrame then return end
    local rows = self.initiativeFrame.rows
    
    local dataList = self.initiativeOrder
    if self.activeInitiativeView ~= "current" and self.characterData and self.characterData.initiativeHistory then
        local hist = self.characterData.initiativeHistory[self.activeInitiativeView]
        if hist and hist.rolls then
            dataList = hist.rolls
        end
    end
    
    for i, row in ipairs(rows) do
        local data = dataList[i]
        if data then
            row.text:SetText(data.name)
            row.val:SetText(data.total)
            if data.icon and data.icon > 0 then
                SetRaidTargetIconTexture(row.icon, data.icon)
                row.icon:Show()
            else
                row.icon:Hide()
            end
            row:Show()
        else
            row:Hide()
        end
    end
end

function GAC:AddInitiativeRoll(playerName, total)
    if not IsInGroup() and not IsInRaid() then return end
    
    if not self.initiativeFrame then
        self:InitializeInitiativeFrame()
    end
    
    self.initiativeFrame:Show()
    
    table.insert(self.initiativeOrder, { name = playerName, total = total })
    
    if self.activeInitiativeView == "current" then
        self:UpdateInitiativeFrame()
    end
end

function GAC:ClearInitiativeOrder()
    self.initiativeOrder = {}
    self.currentLinkedHistory = nil
    if self.activeInitiativeView == "current" then
        self:UpdateInitiativeFrame()
    end
end

function GAC:SyncCurrentHistory()
    if self.currentLinkedHistory and self.characterData and self.characterData.initiativeHistory then
        local hist = self.characterData.initiativeHistory[self.currentLinkedHistory]
        if hist then
            local copy = {}
            for i, v in ipairs(self.initiativeOrder) do
                table.insert(copy, {name = v.name, total = v.total, icon = v.icon})
            end
            hist.rolls = copy
        end
    end
end

function GAC:SortInitiativeOrder()
    if #self.initiativeOrder == 0 then return end
    
    table.sort(self.initiativeOrder, function(a, b)
        local valA = tonumber(a.total) or 0
        local valB = tonumber(b.total) or 0
        return valA > valB
    end)
    
    -- Guardar copia en el historial persistente
    self.characterData = self.characterData or {}
    self.characterData.initiativeHistory = self.characterData.initiativeHistory or {}
    
    local copy = {}
    for i, v in ipairs(self.initiativeOrder) do
        table.insert(copy, {name = v.name, total = v.total, icon = v.icon})
    end
    
    if self.currentLinkedHistory and self.characterData.initiativeHistory[self.currentLinkedHistory] then
        -- Si ya hay un historial vinculado, solo lo actualizamos para no crear spam
        self.characterData.initiativeHistory[self.currentLinkedHistory].rolls = copy
    else
        local currentDate = date("%Y-%m-%d %H:%M:%S")
        table.insert(self.characterData.initiativeHistory, { date = currentDate, rolls = copy })
        self.currentLinkedHistory = #self.characterData.initiativeHistory
    end
    
    self:UpdateInitiativeFrame()
end

function GAC:MoveInitiativeIndex(fromIndex, toIndex)
    if not self.initiativeOrder[fromIndex] then return end
    if toIndex < 1 then toIndex = 1 end
    if toIndex > #self.initiativeOrder then toIndex = #self.initiativeOrder end
    
    local element = table.remove(self.initiativeOrder, fromIndex)
    table.insert(self.initiativeOrder, toIndex, element)
    
    self:SyncCurrentHistory()
    
    if self.activeInitiativeView == "current" then
        self:UpdateInitiativeFrame()
    end
end

function GAC:SetInitiativeIcon(index, iconID)
    if not self.initiativeOrder[index] then return end
    self.initiativeOrder[index].icon = iconID
    
    self:SyncCurrentHistory()
    
    if self.activeInitiativeView == "current" then
        self:UpdateInitiativeFrame()
    end
end
