local addonName, addon = ...

local TOOLTIP_REQUEST_TAG = "ATTR_REQ"
local TOOLTIP_DATA_TAG = "ATTR_DAT"
local EXP_GRANT_TAG = "EXP_GIV"
local TOOLTIP_CACHE_TTL = 300
local MAX_ADDON_MESSAGE_BYTES = 240

local function buildExperienceGrantMessage(leaderName, experienceAmount, recipientDisplayName)
    local leaderText = leaderName or "Lider"
    local amountText = tostring(math.max(0, math.floor(tonumber(experienceAmount) or 0)))
    local recipientText = recipientDisplayName or "Objetivo"
    return leaderText .. " ha dado #" .. amountText .. " EXP a " .. recipientText
end

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

local function getTooltipSyncBroadcastChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    end

    if IsInRaid() then
        return "RAID"
    end

    if IsInGroup() then
        return "PARTY"
    end

    return nil
end

function addon:BroadcastTooltipSyncPayload()
    if type(C_ChatInfo) ~= "table" then
        return
    end

    local channel = getTooltipSyncBroadcastChannel()
    if not channel then
        return
    end

    local payload = self:BuildTooltipSyncPayload()
    if type(payload) ~= "string" or payload == "" then
        return
    end

    C_ChatInfo.SendAddonMessage(self.rollMessagePrefix, payload, channel)
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

    -- Prioritize progression data so it is included even if payload gets truncated.
    local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
    if snapshot then
        if not appendEntry("P:C", snapshot.category or "normal") then
            return message
        end
        if not appendEntry("P:L", tonumber(snapshot.level) or 1) then
            return message
        end
        if not appendEntry("P:X", tonumber(snapshot.currentExperience) or 0) then
            return message
        end

        local maxExp = snapshot.requiredExperience
        if maxExp == nil then
            maxExp = -1
        end
        if not appendEntry("P:M", tonumber(maxExp) or -1) then
            return message
        end
    end

    local profileDisplayName = self.GetRollDisplayName and self:GetRollDisplayName() or UnitName("player") or "Jugador"
    if not appendEntry("R:N", profileDisplayName) then
        return message
    end

    local profileColor = self.GetActiveTRP3ProfileColor and self:GetActiveTRP3ProfileColor() or nil
    if profileColor then
        if not appendEntry("R:C", profileColor) then
            return message
        end
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

    local shieldValue = self.GetPlayerHealthShieldValue and self:GetPlayerHealthShieldValue() or 0
    if shieldValue and shieldValue > 0 then
        if not appendEntry("H:S", math.floor(shieldValue)) then
            return message
        end
    end

    local healthState = self.GetHealthConfigState and self:GetHealthConfigState() or nil
    local lifeDeltaValue = healthState and tonumber(healthState.lifeDelta) or 0
    lifeDeltaValue = math.floor(lifeDeltaValue or 0)
    if lifeDeltaValue ~= 0 then
        if not appendEntry("H:L", lifeDeltaValue) then
            return message
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
        progress = {},
        profile = {},
        healthConfig = {},
        timestamp = GetTime(),
    }

    local index = 2
    while index <= #parts do
        local label = parts[index]
        local rawValue = parts[index + 1]
        local value = tonumber(rawValue)
        if type(label) == "string" then
            if string.sub(label, 1, 2) == "A:" and value ~= nil then
                data.attributes[string.sub(label, 3)] = value
            elseif string.sub(label, 1, 2) == "T:" and value ~= nil then
                data.talents[string.sub(label, 3)] = value
            elseif label == "P:C" then
                data.progress.category = rawValue
            elseif label == "P:L" and value ~= nil then
                data.progress.level = math.floor(value)
            elseif label == "P:X" and value ~= nil then
                data.progress.currentExperience = math.floor(value)
            elseif label == "P:M" and value ~= nil then
                local maxExp = math.floor(value)
                data.progress.requiredExperience = maxExp >= 0 and maxExp or nil
            elseif label == "R:N" then
                data.profile.name = rawValue
            elseif label == "R:C" then
                data.profile.color = rawValue
            elseif label == "H:S" and value ~= nil then
                data.healthConfig.shield = math.max(0, math.floor(value))
            elseif label == "H:L" and value ~= nil then
                data.healthConfig.lifeDelta = math.floor(value)
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
        return shortName, nil, fullName
    end

    return shortName, cached, fullName
end

function addon:CanGrantExperienceToInspectedTarget()
    if not IsInGroup() then
        return false
    end

    return UnitIsGroupLeader("player") and self.inspectTargetShortName ~= nil
end

function addon:GrantExperienceToInspectedTarget(experienceAmount)
    if type(C_ChatInfo) ~= "table" then
        return false, "No disponible en este cliente."
    end

    if not self:CanGrantExperienceToInspectedTarget() then
        return false, "Solo el lider del grupo o banda puede entregar EXP."
    end

    local amount = math.floor(tonumber(experienceAmount) or 0)
    if amount <= 0 then
        return false, "La EXP a entregar debe ser mayor que 0."
    end

    local targetWhisperName = self.inspectTargetWhisperName or self.inspectTargetShortName
    if not targetWhisperName then
        return false, "No hay un objetivo inspeccionado valido."
    end

    local leaderDisplayName = self.GetRollDisplayName and self:GetRollDisplayName() or UnitName("player") or addonName
    local recipientDisplayWithColor = self.inspectTargetDisplayNameWithColor
        or self.inspectTargetDisplayName
        or self.inspectTargetShortName
        or "Objetivo"

    C_ChatInfo.SendAddonMessage(
        self.rollMessagePrefix,
        EXP_GRANT_TAG .. "\t" .. tostring(amount) .. "\t" .. tostring(leaderDisplayName),
        "WHISPER",
        targetWhisperName
    )

    print(buildExperienceGrantMessage(leaderDisplayName, amount, recipientDisplayWithColor))
    return true
end

function addon:OpenTargetAttributesFromUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then
        print("Selecciona a otro jugador para inspeccionarlo.")
        return
    end

    local shortName, cached, fullName = self:GetTooltipSyncCachedDataForUnit(unit)
    if not shortName then
        print("No se pudo obtener informacion del objetivo.")
        return
    end

    self.inspectTargetShortName = shortName
    self.inspectTargetWhisperName = fullName

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
                talentLines[#talentLines + 1] = addon:GetLocalizedText(talentName) .. ": " .. talentValue
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
                attribute = "others",
                value = nil,
                talents = { addon:GetLocalizedText(talentName) .. ": " .. talentValue },
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
        local attrName = addon:GetLocalizedText(groupEntry.attribute)
        if groupEntry.value ~= nil then
            GameTooltip:AddLine("  " .. attrName .. ": " .. groupEntry.value, 1, 1, 1)
        else
            GameTooltip:AddLine("  " .. attrName .. ":", 1, 1, 1)
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

    if string.sub(message, 1, #EXP_GRANT_TAG) == EXP_GRANT_TAG then
        local parts = splitMessage(message)
        local amount = tonumber(parts[2])
        local leaderDisplayName = parts[3]
        if amount and amount > 0 then
            if self.AddExperience then
                self:AddExperience(amount)
            end

            if self.UpdateQuickExperienceBar then
                self:UpdateQuickExperienceBar()
            end

            if self.RefreshExperienceConfigFrame then
                self:RefreshExperienceConfigFrame()
            end

            if self.BroadcastTooltipSyncPayload then
                self:BroadcastTooltipSyncPayload()
            end

            local recipientDisplayWithColor = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or self.GetRollDisplayName and self:GetRollDisplayName()
                or UnitName("player")
                or "Jugador"
            local leaderText = leaderDisplayName or normalizeSenderName(sender) or addonName
            print(buildExperienceGrantMessage(leaderText, amount, recipientDisplayWithColor))
        end

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

        parsed.sender = sender

        self.tooltipSyncCache = self.tooltipSyncCache or {}
        self.tooltipSyncCache[shortSender] = parsed

        if self.currentInspectTargetName == shortSender and self.RefreshTargetInspectUI then
            self:RefreshTargetInspectUI(shortSender, parsed)
        end

        local profileName = parsed.profile and parsed.profile.name
        local profileColor = parsed.profile and parsed.profile.color
        self.inspectTargetDisplayName = profileName or shortSender
        if profileName and profileColor then
            self.inspectTargetDisplayNameWithColor = "|cff" .. profileColor .. profileName .. "|r"
        else
            self.inspectTargetDisplayNameWithColor = self.inspectTargetDisplayName
        end

        if self.pendingTargetInspectName == shortSender then
            self.pendingTargetInspectName = nil
            self.pendingTargetInspectAt = nil
            self.inspectTargetShortName = shortSender
            self.inspectTargetWhisperName = sender
            if self.ShowTargetAttributesUI then
                self:ShowTargetAttributesUI(shortSender, parsed)
            end
        end

        if self.tooltipSyncCurrentTarget == shortSender then
            self:AddTooltipDataLines(shortSender, parsed)
        end

        if self.RefreshTargetLevelOverlay and self.GetUnitShortName then
            local currentTargetShortName = self:GetUnitShortName("target")
            if currentTargetShortName and currentTargetShortName == shortSender then
                self:RefreshTargetLevelOverlay()
                if self.RefreshTargetHealthBarMaxHealth then
                    self:RefreshTargetHealthBarMaxHealth()
                end
            end
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
