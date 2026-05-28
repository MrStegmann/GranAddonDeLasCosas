
local _, addon = ...

local MAX_TURN_ROWS = 18
local TURN_ORDER_EXPANDED_HEIGHT = 420
local TURN_ORDER_MINIMIZED_HEIGHT = 64
local TURN_ORDER_SORT_SYNC_TAG = "TURN_SORT_SYNC"
local TURN_ORDER_RESET_SYNC_TAG = "TURN_RESET_SYNC"
local TURN_ORDER_MARKER_SYNC_TAG = "TURN_MARKER_SYNC"

local RAID_MARKER_OPTIONS = {
    { text = "Calavera", icon = 8 },
    { text = "Cruz", icon = 7 },
    { text = "Cuadrado", icon = 6 },
    { text = "Luna", icon = 5 },
    { text = "Triangulo", icon = 4 },
    { text = "Diamante", icon = 3 },
    { text = "Circulo", icon = 2 },
    { text = "Estrella", icon = 1 },
}

local function buildRandomRollPattern()
    local pattern = RANDOM_ROLL_RESULT or "%s rolls %d (%d-%d)"
    pattern = pattern:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    pattern = pattern:gsub("%%%%s", "(.+)")
    pattern = pattern:gsub("%%%%d", "(%%d+)")
    return "^" .. pattern .. "$"
end

local function stripColorCodes(text)
    if type(text) ~= "string" then
        return text
    end

    local clean = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    clean = clean:gsub("|r", "")
    return clean
end

local function rebuildTurnList(source)
    local list = {}

    for _, entry in ipairs(source or {}) do
        list[#list + 1] = entry
    end

    return list
end

local function isNameInRaid(name)
    if type(name) ~= "string" or name == "" then
        return false
    end

    local shortTarget = Ambiguate(name, "none")
    local members = GetNumGroupMembers() or 0
    for index = 1, members do
        local rosterName = GetRaidRosterInfo(index)
        if rosterName then
            if rosterName == name or Ambiguate(rosterName, "none") == shortTarget then
                return true
            end
        end
    end

    return false
end

-- Etiqueta para sincronización manual
local TURN_ORDER_MANUAL_SYNC_TAG = "TURN_MANUAL_SYNC"
-- Serializa la lista de turnos para sincronización
local function serializeTurnOrderList(list)
    local parts = {}
    for _, entry in ipairs(list or {}) do
        local marker = entry.marker or ""
        local key = entry.key or ""
        table.insert(parts, table.concat({entry.name, entry.roll, marker, key}, ":"))
    end
    return table.concat(parts, ",")
end

-- Deserializa la lista de turnos recibida
local function deserializeTurnOrderList(serialized)
    local list = {}
    for entryStr in string.gmatch(serialized or "", "[^,]+") do
        local name, roll, marker, key = strsplit(":", entryStr)
        table.insert(list, {
            name = name,
            roll = tonumber(roll),
            marker = tonumber(marker) or nil,
            key = key ~= "" and key or nil,
        })
    end
    -- Reasignar secuencia
    for i, entry in ipairs(list) do
        entry.sequence = i
    end
    return list
end
function addon:BroadcastTurnOrderManualSync()
    if type(C_ChatInfo) ~= "table" then return end
    if not IsInRaid() then return end
    if not self.initiativeRollHistory or #self.initiativeRollHistory == 0 then return end
    local serialized = serializeTurnOrderList(self.initiativeRollHistory)
    local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
    C_ChatInfo.SendAddonMessage(self.rollMessagePrefix, TURN_ORDER_MANUAL_SYNC_TAG .. "\t" .. serialized, channel)
end

local function buildMarkerInlineTexture(markerIndex)
    if type(markerIndex) ~= "number" then
        return ""
    end

    return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. markerIndex .. ":14:14:0:0|t"
end

local function buildRaidCompositionKey()
    if not IsInRaid() then
        return nil
    end

    local memberNames = {}
    local members = GetNumGroupMembers() or 0
    for index = 1, members do
        local rosterName = GetRaidRosterInfo(index)
        if rosterName and rosterName ~= "" then
            memberNames[#memberNames + 1] = rosterName
        end
    end

    if #memberNames == 0 then
        return nil
    end

    table.sort(memberNames)
    return tostring(#memberNames) .. "::" .. table.concat(memberNames, "|")
end

local function isSenderRaidLeader(sender)
    if not IsInRaid() or type(sender) ~= "string" then
        return false
    end

    local senderShortName = Ambiguate(sender, "none")
    local members = GetNumGroupMembers() or 0
    for index = 1, members do
        local rosterName, rank = GetRaidRosterInfo(index)
        if rosterName and Ambiguate(rosterName, "none") == senderShortName then
            return rank == 2
        end
    end

    return false
end

function addon:CanShowTurnOrderFrame()
    return IsInRaid()
end

function addon:CanEditTurnOrderFrame()
    return IsInRaid() and UnitIsGroupLeader("player")
end

function addon:GetTurnOrderStorage()
    if not self.characterData then
        return nil
    end

    self.characterData.turnOrder = self.characterData.turnOrder or {}
    self.characterData.turnOrder.byGroup = self.characterData.turnOrder.byGroup or {}
    self.characterData.turnOrder.sequence = tonumber(self.characterData.turnOrder.sequence) or 0
    self.characterData.turnOrder.ui = self.characterData.turnOrder.ui or {}
    self.characterData.turnOrder.ui.framePosition = self.characterData.turnOrder.ui.framePosition or {
        point = "TOP",
        relativePoint = "TOP",
        x = 0,
        y = -180,
    }

    return self.characterData.turnOrder
end

function addon:ApplyTurnOrderFramePosition(frame)
    local storage = self:GetTurnOrderStorage()
    local saved = storage and storage.ui and storage.ui.framePosition
    if not saved then
        frame:SetPoint("TOP", UIParent, "TOP", 0, -180)
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint(saved.point or "TOP", UIParent, saved.relativePoint or "TOP", saved.x or 0, saved.y or -180)
end

function addon:PersistTurnOrderFramePosition(frame)
    local storage = self:GetTurnOrderStorage()
    if not storage or not storage.ui then
        return
    end

    local point, _, relativePoint, x, y = frame:GetPoint(1)
    storage.ui.framePosition = {
        point = point or "TOP",
        relativePoint = relativePoint or "TOP",
        x = math.floor((x or 0) + 0.5),
        y = math.floor((y or 0) + 0.5),
    }
end

function addon:ActivateTurnOrderForCurrentRaid()
    local storage = self:GetTurnOrderStorage()
    if not storage then
        self.activeTurnOrderGroupKey = nil
        self.initiativeRollHistory = {}
        return
    end

    local groupKey = buildRaidCompositionKey()
    if not groupKey then
        self.activeTurnOrderGroupKey = nil
        self.initiativeRollHistory = {}
        return
    end

    storage.byGroup[groupKey] = storage.byGroup[groupKey] or {}

    self.activeTurnOrderGroupKey = groupKey
    self.initiativeRollHistory = storage.byGroup[groupKey]
end

function addon:IsOwnTurnOrderEntry(entry)
    if type(entry) ~= "table" then
        return false
    end

    local playerName = UnitName("player")
    if not playerName then
        return false
    end

    return entry.name == playerName
end

function addon:BroadcastTurnOrderMarkerSync(sequence, markerIndex, entryKey)
    if type(C_ChatInfo) ~= "table" then
        return
    end

    if not IsInRaid() then
        return
    end

    if type(sequence) ~= "number" then
        return
    end

    local markerValue = tonumber(markerIndex) or 0
    local safeEntryKey = type(entryKey) == "string" and entryKey or ""
    local payload = TURN_ORDER_MARKER_SYNC_TAG .. "\t" .. sequence .. "\t" .. markerValue .. "\t" .. safeEntryKey
    local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
    C_ChatInfo.SendAddonMessage(self.rollMessagePrefix, payload, channel)
end

function addon:SetTurnOrderEntryMarker(sequence, markerIndex, fromSyncMessage, entryKey)
    if not fromSyncMessage and not self:CanEditTurnOrderFrame() then
        return
    end

    if type(sequence) ~= "number" then
        return
    end

    local matchedEntry = nil
    for _, entry in ipairs(self.initiativeRollHistory or {}) do
        if entry.sequence == sequence then
            matchedEntry = entry
            break
        end
    end

    if not matchedEntry and type(entryKey) == "string" and entryKey ~= "" then
        for _, entry in ipairs(self.initiativeRollHistory or {}) do
            if entry.key == entryKey or entry.name == entryKey then
                matchedEntry = entry
                break
            end
        end
    end

    if not matchedEntry then
        return
    end

    matchedEntry.marker = markerIndex
    self:RefreshTurnOrderFrame()

    -- if not fromSyncMessage then
    --     self:BroadcastTurnOrderMarkerSync(matchedEntry.sequence or sequence, markerIndex, matchedEntry.key or matchedEntry.name)
    -- end
end

function addon:OpenTurnOrderMarkerMenu(entry, anchorFrame)
    if not self:CanEditTurnOrderFrame() then
        return
    end

    if not self.turnOrderMarkerMenuFrame then
        self.turnOrderMarkerMenuFrame = CreateFrame("Frame", "GACTurnOrderMarkerMenuFrame", UIParent, "UIDropDownMenuTemplate")
    end

    local menu = {
        {
            text = "Opciones de turno",
            isTitle = true,
            notCheckable = true,
        },
        {
            text = "Subir 1 puesto",
            notCheckable = true,
            func = function()
                addon:MoveTurnOrderEntry(entry.sequence, "up")
            end,
        },
        {
            text = "Bajar 1 puesto",
            notCheckable = true,
            func = function()
                addon:MoveTurnOrderEntry(entry.sequence, "down")
            end,
        },
        {
            text = "Situar primero",
            notCheckable = true,
            func = function()
                addon:MoveTurnOrderEntry(entry.sequence, "first")
            end,
        },
        {
            text = "Situar último",
            notCheckable = true,
            func = function()
                addon:MoveTurnOrderEntry(entry.sequence, "last")
            end,
        },
        {
            text = "-",
            notCheckable = true,
            disabled = true,
        },
        {
            text = "Icono de tirada",
            isTitle = true,
            notCheckable = true,
        },
    }

    for _, option in ipairs(RAID_MARKER_OPTIONS) do
        local iconString = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. option.icon .. ":14:14:0:0|t"
        menu[#menu + 1] = {
            text = iconString .. " " .. option.text,
            notCheckable = true,
            func = function()
                addon:SetTurnOrderEntryMarker(entry.sequence, option.icon)
            end,
        }
    end

    menu[#menu + 1] = {
        text = "Quitar icono",
        notCheckable = true,
        func = function()
            addon:SetTurnOrderEntryMarker(entry.sequence, nil)
        end,
    }

    EasyMenu(menu, self.turnOrderMarkerMenuFrame, "cursor", 0, 0, "MENU", 2)
end

function addon:MoveTurnOrderEntry(sequence, action, fromSyncMessage)
    local storage = self:GetTurnOrderStorage()
    if not storage or not storage.byGroup or not self.activeTurnOrderGroupKey then return end
    local list = storage.byGroup[self.activeTurnOrderGroupKey]
    if not list then return end

    local idx
    for i, entry in ipairs(list) do
        if entry.sequence == sequence then
            idx = i
            break
        end
    end
    if not idx then return end

    if action == "up" and idx > 1 then
        list[idx], list[idx-1] = list[idx-1], list[idx]
    elseif action == "down" and idx < #list then
        list[idx], list[idx+1] = list[idx+1], list[idx]
    elseif action == "first" and idx > 1 then
        table.insert(list, 1, table.remove(list, idx))
    elseif action == "last" and idx < #list then
        local entry = table.remove(list, idx)
        table.insert(list, #list+1, entry)
    else
        return
    end
    -- Reasignar sequence para reflejar el nuevo orden
    for i, entry in ipairs(list) do
        entry.sequence = i
    end

    if not self.turnOrderRows then
        return
    end

    local rebuildList = rebuildTurnList(list)

    for i, row in ipairs(self.turnOrderRows) do
        local entry = rebuildList[i]
        if entry then
            row.entry = entry
            local markerText = buildMarkerInlineTexture(entry.marker)
            if markerText ~= "" then
                markerText = " " .. markerText
            end

            row.label:SetText(i .. ". " .. entry.name .. markerText .. " - " .. entry.roll)
        else
            row.entry = nil
            row.label:SetText("")
        end
    end

    self:RefreshTurnOrderFrame()

    if not fromSyncMessage then
        self:BroadcastTurnOrderSortSync()
    end
    
end

function addon:SetTurnOrderMinimized(isMinimized)
    self.turnOrderMinimized = isMinimized and true or false

    if not self.turnOrderFrame then
        if self.UpdateTurnOrderExpandButtonVisibility then
            self:UpdateTurnOrderExpandButtonVisibility()
        end
        return
    end

    if self.turnOrderMinimized then
        self.turnOrderFrame:Hide()
    elseif self:CanShowTurnOrderFrame() then
        self.turnOrderFrame:Show()
    end

    self.turnOrderFrame:SetHeight(self.turnOrderMinimized and TURN_ORDER_MINIMIZED_HEIGHT or TURN_ORDER_EXPANDED_HEIGHT)

    local showContent = not self.turnOrderMinimized
    local canEdit = self:CanEditTurnOrderFrame()

    if self.turnOrderResetButton then
        self.turnOrderResetButton:SetShown(showContent and canEdit)
    end

    if self.turnOrderSortButton then
        self.turnOrderSortButton:SetShown(showContent and canEdit)
    end

    for _, row in ipairs(self.turnOrderRows or {}) do
        row:SetShown(showContent)
    end

    if self.turnOrderToggleButton then
        self.turnOrderToggleButton:SetShown(self:CanShowTurnOrderFrame())
        self.turnOrderToggleButton:SetText(self.turnOrderMinimized and "+" or "-")
    end

    if self.UpdateTurnOrderExpandButtonVisibility then
        self:UpdateTurnOrderExpandButtonVisibility()
    end
end

function addon:ToggleTurnOrderMinimized()
    self:SetTurnOrderMinimized(not self.turnOrderMinimized)
end

function addon:BroadcastTurnOrderSortSync()
    if type(C_ChatInfo) ~= "table" then
        return
    end

    if not IsInRaid() then
        return
    end


    local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"

    C_ChatInfo.SendAddonMessage(self.rollMessagePrefix, TURN_ORDER_SORT_SYNC_TAG, channel)
end

function addon:BroadcastTurnOrderResetSync()
    if type(C_ChatInfo) ~= "table" then
        return
    end

    if not IsInRaid() then
        return
    end

    local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
    C_ChatInfo.SendAddonMessage(self.rollMessagePrefix, TURN_ORDER_RESET_SYNC_TAG, channel)
end

function addon:HandleTurnOrderAddonMessage(message, sender)
    local tag, rest = strsplit("\t", message, 2)
    local playerName = UnitName("player")
    local senderName = sender and Ambiguate(sender, "none") or nil
    if senderName and playerName and senderName == playerName then
        return true
    end
    if not self:CanShowTurnOrderFrame() then
        return true
    end
    if not isSenderRaidLeader(sender) then
        return true
    end

    if tag == TURN_ORDER_MARKER_SYNC_TAG then
        local sequenceText, markerText, entryKey = strsplit("\t", rest or "")
        local sequence = tonumber(sequenceText)
        if not sequence then return true end
        local markerValue = tonumber(markerText)
        if markerValue == 0 then markerValue = nil end
        self:SetTurnOrderEntryMarker(sequence, markerValue, true, entryKey)
    elseif tag == TURN_ORDER_SORT_SYNC_TAG then
        self:SortTurnOrderResults(true)
    elseif tag == TURN_ORDER_RESET_SYNC_TAG then
        self:ResetTurnOrderList(true)
    elseif tag == TURN_ORDER_MANUAL_SYNC_TAG then
        -- Recibido orden manual: deserializar y aplicar
        local newList = deserializeTurnOrderList(rest)
        if #newList > 0 then
            local storage = self:GetTurnOrderStorage()
            if storage and self.activeTurnOrderGroupKey then
                storage.byGroup[self.activeTurnOrderGroupKey] = newList
                self.initiativeRollHistory = newList
                self:RefreshTurnOrderFrame()
            end
        end
    end
    return true
end

function addon:SortTurnOrderResults(fromSyncMessage)
    if not fromSyncMessage and not self:CanEditTurnOrderFrame() then
        return
    end

    if not self.initiativeRollHistory then
        return
    end

    table.sort(self.initiativeRollHistory, function(a, b)
        if a.roll == b.roll then
            return a.sequence < b.sequence
        end

        return a.roll > b.roll
    end)

    self:RefreshTurnOrderFrame()

    if not fromSyncMessage then
        self:BroadcastTurnOrderSortSync()
    end
end

function addon:RefreshTurnOrderFrame()
    if not self.turnOrderRows then
        return
    end

    local sortedList = rebuildTurnList(self.initiativeRollHistory)

    for i, row in ipairs(self.turnOrderRows) do
        local entry = sortedList[i]
        if entry then
            row.entry = entry
            local markerText = buildMarkerInlineTexture(entry.marker)
            if markerText ~= "" then
                markerText = " " .. markerText
            end

            row.label:SetText(i .. ". " .. entry.name .. markerText .. " - " .. entry.roll)
        else
            row.entry = nil
            row.label:SetText("")
        end
    end
end

function addon:RecordInitiativeRoll(entryKey, displayName, rollValue)
    if type(displayName) ~= "string" or displayName == "" then
        return
    end

    local numericRoll = tonumber(rollValue)
    if not numericRoll then
        return
    end

    if not self.initiativeRollHistory then
        self:ActivateTurnOrderForCurrentRaid()
    end

    self.initiativeRollHistory = self.initiativeRollHistory or {}

    local storage = self:GetTurnOrderStorage()
    if storage then
        storage.sequence = storage.sequence + 1
    end

    local sequence = storage and storage.sequence or (#self.initiativeRollHistory + 1)
    self.initiativeRollHistory[#self.initiativeRollHistory + 1] = {
        key = entryKey,
        name = displayName,
        roll = numericRoll,
        sequence = sequence,
    }

    self:RefreshTurnOrderFrame()
end

function addon:CaptureRaidRollForTurnOrder(message)
    if not self:CanShowTurnOrderFrame() then
        return
    end

    self.turnOrderRollPattern = self.turnOrderRollPattern or buildRandomRollPattern()

    local plainMessage = stripColorCodes(message)
    local rollerName, rollText, lowText, highText = plainMessage:match(self.turnOrderRollPattern)
    if not rollerName or not rollText or not lowText or not highText then
        return
    end

    local rollValue = tonumber(rollText)
    local lowValue = tonumber(lowText)
    local highValue = tonumber(highText)
    if not rollValue or not lowValue or not highValue then
        return
    end

    if lowValue ~= 1 or highValue ~= 100 then
        return
    end

    if not isNameInRaid(rollerName) then
        return
    end

    local shortName = Ambiguate(rollerName, "none")
    self:RecordInitiativeRoll(shortName, shortName, rollValue)
end

function addon:ResetTurnOrderList(fromSyncMessage)
    if not fromSyncMessage and not self:CanEditTurnOrderFrame() then
        return
    end

    local storage = self:GetTurnOrderStorage()
    if storage and self.activeTurnOrderGroupKey then
        storage.byGroup[self.activeTurnOrderGroupKey] = {}
        self.initiativeRollHistory = storage.byGroup[self.activeTurnOrderGroupKey]
    else
        self.initiativeRollHistory = {}
    end

    self:RefreshTurnOrderFrame()

    if not fromSyncMessage then
        self:BroadcastTurnOrderResetSync()
    end
end

function addon:UpdateTurnOrderFrameVisibility()
    if not self.turnOrderFrame then
        return
    end

    if self:CanShowTurnOrderFrame() then
        self:ActivateTurnOrderForCurrentRaid()
        self.turnOrderFrame:SetShown(not self.turnOrderMinimized)

        self:SetTurnOrderMinimized(self.turnOrderMinimized)
        self:RefreshTurnOrderFrame()

        if self.turnOrderResetButton then
            self.turnOrderResetButton:SetEnabled(self:CanEditTurnOrderFrame())
        end

        if self.turnOrderSortButton then
            self.turnOrderSortButton:SetEnabled(self:CanEditTurnOrderFrame())
        end
    else
        self.turnOrderFrame:Hide()
    end

    if self.UpdateTurnOrderExpandButtonVisibility then
        self:UpdateTurnOrderExpandButtonVisibility()
    end
end

function addon:UpdateTurnOrderExpandButtonVisibility()
    if not self.turnOrderExpandQuickButton then
        return
    end

    local shouldShow = self.turnOrderMinimized and self:CanShowTurnOrderFrame()
    self.turnOrderExpandQuickButton:SetShown(shouldShow)
end

function addon:CreateTurnOrderFrame()

    if self.turnOrderFrame then
        return
    end

    local frame = CreateFrame("Frame", "GACTurnOrderFrame", UIParent, "BackdropTemplate")
    frame:SetSize(240, TURN_ORDER_EXPANDED_HEIGHT)
    self:ApplyTurnOrderFramePosition(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.04, 0.05, 0.08, 0.85)
    frame:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.9)

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        addon:PersistTurnOrderFramePosition(self)
    end)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Orden de turnos")

    local toggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    toggleButton:SetSize(24, 20)
    toggleButton:SetPoint("TOPRIGHT", -10, -8)
    toggleButton:SetText("-")
    toggleButton:SetScript("OnClick", function()
        addon:ToggleTurnOrderMinimized()
    end)
    self.turnOrderToggleButton = toggleButton

    local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetButton:SetSize(40, 40)
    resetButton:SetPoint("BOTTOMLEFT", 14, 12)
    local resetIcon = resetButton:CreateTexture(nil, "ARTWORK")
    resetIcon:SetTexture("Interface\\Icons\\inv_misc_noteblank2a")
    resetIcon:SetPoint("CENTER")
    resetIcon:SetSize(30, 30)

    resetButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Reiniciar")
        GameTooltip:AddLine("Reinicia el orden de turnos", 1, 1, 1)
        GameTooltip:Show()
    end)
    resetButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    resetButton:SetScript("OnClick", function()
        if addon:CanEditTurnOrderFrame() then
            addon:ResetTurnOrderList()
        end
    end)
    self.turnOrderResetButton = resetButton

    local sortButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    sortButton:SetSize(40, 40)
    sortButton:SetPoint("BOTTOMRIGHT", -14, 12)

    local sortIcon = sortButton:CreateTexture(nil, "ARTWORK")
    sortIcon:SetTexture("Interface\\Icons\\inv_misc_scrollunrolled01")
    sortIcon:SetPoint("CENTER")
    sortIcon:SetSize(30, 30)

    sortButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Ordenar")
        GameTooltip:AddLine("Ordena el orden de turnos", 1, 1, 1)
        GameTooltip:Show()
    end)
    sortButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    sortButton:SetScript("OnClick", function()
        addon:SortTurnOrderResults()
    end)
    self.turnOrderSortButton = sortButton

            -- Botón de sincronización manual (solo líder)
        local syncButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        syncButton:SetSize(40, 40)
        syncButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12)
        -- syncButton:SetTexture("Interface\\Icons\\eps_bg3_blink")
        local syncIcon = syncButton:CreateTexture(nil, "ARTWORK")
        syncIcon:SetTexture("Interface\\Icons\\eps_bg3_blink")
        syncIcon:SetPoint("CENTER")
        syncIcon:SetSize(30, 30)
        
        syncButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Sincronizar")
            GameTooltip:AddLine("Sincroniza el orden de turnos con el resto de miembros del grupo de banda", 1, 1, 1)
            GameTooltip:Show()
        end)
        syncButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        syncButton:SetScript("OnClick", function()
            if addon:CanEditTurnOrderFrame() then
                addon:BroadcastTurnOrderManualSync()
            end
        end)
        syncButton:Show()
        self.turnOrderSyncButton = syncButton
        if self.turnOrderSyncButton then
            self.turnOrderSyncButton:SetShown((not self.turnOrderMinimized) and self:CanEditTurnOrderFrame())
        end

    self.turnOrderRows = {}

    local startY = -42
    for i = 1, MAX_TURN_ROWS do
        local row = CreateFrame("Button", nil, frame)
        row:SetPoint("TOPLEFT", 12, startY - ((i - 1) * 19))
        row:SetPoint("TOPRIGHT", -12, startY - ((i - 1) * 19))
        row:SetHeight(18)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", 0, 0)
        label:SetPoint("RIGHT", -2, 0)
        label:SetJustifyH("LEFT")
        label:SetText("")
        row.label = label

        row:RegisterForClicks("RightButtonUp")
        row:SetScript("OnClick", function(self, button)
            if button == "RightButton" and self.entry then
                addon:OpenTurnOrderMarkerMenu(self.entry, self)
            end
        end)

        self.turnOrderRows[i] = row
    end

    self.turnOrderFrame = frame
    self.initiativeRollHistory = self.initiativeRollHistory or {}
    self.turnOrderMinimized = false

    self:ActivateTurnOrderForCurrentRaid()
    self:RefreshTurnOrderFrame()
    self:SetTurnOrderMinimized(false)
    self:UpdateTurnOrderFrameVisibility()
end
