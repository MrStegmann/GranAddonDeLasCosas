local _, addon = ...

addon.rollMessagePrefix = "GAC_ROLL_V1"

function addon:GetRollDisplayName()
    return self:GetActiveTRP3ProfileName() or UnitName("player") or self.name
end

function addon:GetRollDisplayNameWithColor()
    local name = self:GetRollDisplayName()
    local color = self:GetActiveTRP3ProfileColor()

    if not color then
        return name
    end

    return "|cff" .. color .. name .. "|r"
end

local function getDistributionChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    end

    if IsInRaid() then
        return "RAID"
    end

    if IsInGroup() then
        return "PARTY"
    end

    if IsInGuild() then
        return "GUILD"
    end

    return nil
end

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

function addon:ColorizeSystemRollMessage(message)
    local pattern = self.randomRollPattern or buildRandomRollPattern()
    self.randomRollPattern = pattern

    local plain = stripColorCodes(message)
    local _, rollText = plain:match(pattern)
    if not rollText then
        return message
    end

    local rollValue = tonumber(rollText)
    if rollValue == 1 then
        return "|cffff4040" .. plain .. "|r"
    end

    if rollValue == 20 then
        return "|cff40ff40" .. plain .. "|r"
    end

    return message
end

function addon:InstallRollMessageFilter()
    if self.rollMessageFilterInstalled then
        return
    end

    self.rollMessageFilterInstalled = true

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message, ...)
        return false, addon:ColorizeSystemRollMessage(message), ...
    end)
end

function addon:RegisterRollCommunication()
    if type(C_ChatInfo) ~= "table" then
        return
    end

    C_ChatInfo.RegisterAddonMessagePrefix(self.rollMessagePrefix)
    self:InstallRollMessageFilter()

    if self.eventFrame then
        self.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
    end
end

function addon:BroadcastRollMessage(message)
    if type(C_ChatInfo) ~= "table" then
        return
    end

    local channel = getDistributionChannel()
    if not channel then
        return
    end

    C_ChatInfo.SendAddonMessage(self.rollMessagePrefix, message, channel)
end

function addon:CHAT_MSG_ADDON(prefix, message, _, sender)
    if prefix ~= self.rollMessagePrefix or type(message) ~= "string" or message == "" then
        return
    end

    if self.HandleTooltipSyncAddonMessage and self:HandleTooltipSyncAddonMessage(message, sender) then
        return
    end

    if self.HandleTurnOrderAddonMessage and self:HandleTurnOrderAddonMessage(message, sender) then
        return
    end

    local playerName = UnitName("player")
    local senderName = sender and Ambiguate(sender, "none") or nil
    if senderName and playerName and senderName == playerName then
        return
    end

    print("|cff40c7ff[GAC]|r " .. message)
end
