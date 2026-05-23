local addonName, addon = ...

local TOOLTIP_REQUEST_TAG = "ATTR_REQ"
local TOOLTIP_DATA_TAG = "ATTR_DAT"
local TOOLTIP_CACHE_TTL = 300
local MAX_ADDON_MESSAGE_BYTES = 240

local function splitMessage(message)
    local parts = {}
    for value in string.gmatch(message .. "\t", "(.-)\t") do
        parts[#parts + 1] = value
    end
    return parts
end

local function getFullUnitName(unit)
    local name, realm = UnitName(unit)
    if not name or name == "" then
        return nil
    end

    if realm and realm ~= "" then
        return name .. "-" .. realm
    end

    return name
end

local function normalizeSenderName(sender)
    if type(sender) ~= "string" then
        return nil
    end

    return Ambiguate(sender, "none")
end

function addon:BuildTooltipSyncPayload()
    if not self.characterData then
        return TOOLTIP_DATA_TAG
    end

    local message = TOOLTIP_DATA_TAG

    local function appendEntry(label, value)
        local valueText = tostring(value)
        local nextPart = "\t" .. label .. "\t" .. valueText
        if (#message + #nextPart) > MAX_ADDON_MESSAGE_BYTES then
            return false
        end

        message = message .. nextPart
        return true
    end

    for _, group in ipairs(self.attributeGroups or {}) do
        local current = tonumber(self.characterData.attributes[group.name]) or 0
        if current ~= 0 then
            if not appendEntry("A:" .. group.name, current) then
                return message
            end
        end
    end

    for _, group in ipairs(self.attributeGroups or {}) do
        for _, talent in ipairs(group.talents or {}) do
            local current = tonumber(self.characterData.talents[talent]) or 0
            if current ~= 0 then
                if not appendEntry("T:" .. talent, current) then
                    return message
                end
            end
        end
    end

    return message
end

function addon:ParseTooltipSyncPayload(message)
    local parts = splitMessage(message)
    if parts[1] ~= TOOLTIP_DATA_TAG then
        return nil
    end

    local data = {
        attributes = {},
        talents = {},
        timestamp = GetTime(),
    }

    local index = 2
    while index <= #parts do
        local label = parts[index]
        local value = tonumber(parts[index + 1])
        if type(label) == "string" and value ~= nil then
            if string.sub(label, 1, 2) == "A:" then
                data.attributes[string.sub(label, 3)] = value
            elseif string.sub(label, 1, 2) == "T:" then
                data.talents[string.sub(label, 3)] = value
            end
        end

        index = index + 2
    end

    return data
end

function addon:RequestTooltipDataForUnit(unit)
    if type(C_ChatInfo) ~= "table" then
        return
    end

    local fullName = getFullUnitName(unit)
    if not fullName then
        return
    end

    C_ChatInfo.SendAddonMessage(self.rollMessagePrefix, TOOLTIP_REQUEST_TAG, "WHISPER", fullName)
end

function addon:GetTooltipSyncCachedDataForUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) then
        return nil, nil
    end

    local fullName = getFullUnitName(unit)
    if not fullName then
        return nil, nil
    end

    local shortName = normalizeSenderName(fullName)
    if not shortName then
        return nil, nil
    end

    local cached = self.tooltipSyncCache and self.tooltipSyncCache[shortName]
    if not cached or (GetTime() - cached.timestamp) > TOOLTIP_CACHE_TTL then
        return shortName, nil
    end

    return shortName, cached
end

function addon:OpenTargetAttributesFromUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then
        print("Selecciona a otro jugador para inspeccionarlo.")
        return
    end

    local shortName, cached = self:GetTooltipSyncCachedDataForUnit(unit)
    if not shortName then
        print("No se pudo obtener informacion del objetivo.")
        return
    end

    if cached then
        if self.ShowTargetAttributesUI then
            self:ShowTargetAttributesUI(shortName, cached)
        end
        return
    end

    self.pendingTargetInspectName = shortName
    self.pendingTargetInspectAt = GetTime()
    self:RequestTooltipDataForUnit(unit)
    print("Solicitando atributos de " .. shortName .. "...")

    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        local requestedName = shortName
        C_Timer.After(2.0, function()
            if addon.pendingTargetInspectName == requestedName then
                addon.pendingTargetInspectName = nil
                addon.pendingTargetInspectAt = nil
                print("No se pudo abrir la ficha. El objetivo debe tener GranAddonDeLasCosas activo.")
            end
        end)
    end
end

function addon:AddTooltipDataLines(targetName, data)
    if not GameTooltip:IsShown() then
        return
    end

    if self.tooltipSyncRenderedFor == targetName and self.tooltipSyncRenderedAt == data.timestamp then
        return
    end

    local groupedLines = {}
    local includedTalents = {}

    for _, group in ipairs(self.attributeGroups or {}) do
        local attributeName = group.name
        local attributeValue = tonumber((data.attributes or {})[attributeName]) or 0
        local hasAttributeValue = (data.attributes or {})[attributeName] ~= nil and attributeValue ~= 0

        local talentLines = {}
        for _, talentName in ipairs(group.talents or {}) do
            local talentValue = tonumber((data.talents or {})[talentName]) or 0
            if talentValue ~= 0 then
                talentLines[#talentLines + 1] = talentName .. ": " .. talentValue
                includedTalents[talentName] = true
            end
        end

        table.sort(talentLines)

        if hasAttributeValue or #talentLines > 0 then
            groupedLines[#groupedLines + 1] = {
                attribute = attributeName,
                value = attributeValue,
                talents = talentLines,
            }
        end
    end

    for talentName, talentValue in pairs(data.talents or {}) do
        if talentValue ~= 0 and not includedTalents[talentName] then
            groupedLines[#groupedLines + 1] = {
                attribute = "Otros",
                value = nil,
                talents = { talentName .. ": " .. talentValue },
            }
        end
    end

    if #groupedLines == 0 then
        return
    end

    table.sort(groupedLines, function(a, b)
        return a.attribute < b.attribute
    end)

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cff40c7ff" .. addonName .. "|r")

    GameTooltip:AddLine("Atributos y talentos", 0.75, 0.87, 1)
    for _, groupEntry in ipairs(groupedLines) do
        if groupEntry.value ~= nil then
            GameTooltip:AddLine("  " .. groupEntry.attribute .. ": " .. groupEntry.value, 1, 1, 1)
        else
            GameTooltip:AddLine("  " .. groupEntry.attribute .. ":", 1, 1, 1)
        end

        for _, talentLine in ipairs(groupEntry.talents) do
            GameTooltip:AddLine("    - " .. talentLine, 1, 1, 1)
        end
    end

    GameTooltip:Show()
    self.tooltipSyncRenderedFor = targetName
    self.tooltipSyncRenderedAt = data.timestamp
end

function addon:HandleTooltipUnit()
    local _, unit = GameTooltip:GetUnit()
    if not unit or not UnitExists(unit) or not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then
        return
    end

    local fullName = getFullUnitName(unit)
    if not fullName then
        return
    end

    local shortName = normalizeSenderName(fullName)
    if not shortName then
        return
    end

    self.tooltipSyncCurrentTarget = shortName
    self.tooltipSyncCache = self.tooltipSyncCache or {}

    local cached = self.tooltipSyncCache[shortName]
    if cached and (GetTime() - cached.timestamp) <= TOOLTIP_CACHE_TTL then
        self:AddTooltipDataLines(shortName, cached)
    else
        self:RequestTooltipDataForUnit(unit)
    end
end

function addon:HandleTooltipSyncAddonMessage(message, sender)
    if type(message) ~= "string" or message == "" then
        return false
    end

    if message == TOOLTIP_REQUEST_TAG then
        if type(C_ChatInfo) ~= "table" then
            return true
        end

        local payload = self:BuildTooltipSyncPayload()
        C_ChatInfo.SendAddonMessage(self.rollMessagePrefix, payload, "WHISPER", sender)
        return true
    end

    if string.sub(message, 1, #TOOLTIP_DATA_TAG) == TOOLTIP_DATA_TAG then
        local shortSender = normalizeSenderName(sender)
        if not shortSender then
            return true
        end

        local parsed = self:ParseTooltipSyncPayload(message)
        if not parsed then
            return true
        end

        self.tooltipSyncCache = self.tooltipSyncCache or {}
        self.tooltipSyncCache[shortSender] = parsed

        if self.pendingTargetInspectName == shortSender then
            self.pendingTargetInspectName = nil
            self.pendingTargetInspectAt = nil
            if self.ShowTargetAttributesUI then
                self:ShowTargetAttributesUI(shortSender, parsed)
            end
        end

        if self.tooltipSyncCurrentTarget == shortSender then
            self:AddTooltipDataLines(shortSender, parsed)
        end

        return true
    end

    return false
end

function addon:RegisterTooltipSync()
    if self.tooltipSyncRegistered then
        return
    end

    self.tooltipSyncRegistered = true
    self.tooltipSyncCache = self.tooltipSyncCache or {}

    GameTooltip:HookScript("OnTooltipSetUnit", function()
        addon:HandleTooltipUnit()
    end)

    GameTooltip:HookScript("OnHide", function()
        addon.tooltipSyncCurrentTarget = nil
        addon.tooltipSyncRenderedFor = nil
        addon.tooltipSyncRenderedAt = nil
    end)
end
