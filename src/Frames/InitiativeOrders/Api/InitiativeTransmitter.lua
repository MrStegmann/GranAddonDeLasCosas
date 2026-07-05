local _, GAC = ...

GAC.Transmitter:AddEvent(GAC.Enums.Events.INIT_ADD, function(playerName, total)
    if not playerName or not total then return end
    local payload = GAC.Enums.Events.INIT_ADD .. ":" .. tostring(playerName) .. ":" .. tostring(total)
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "PARTY")
    end
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INIT_ACTION, function(action)
    if not action then return end
    local payload = GAC.Enums.Events.INIT_ACTION .. ":" .. tostring(action)
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "PARTY")
    end
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INIT_MOVE, function(fromIndex, toIndex)
    if not fromIndex or not toIndex then return end
    local payload = GAC.Enums.Events.INIT_MOVE .. ":" .. tostring(fromIndex) .. ":" .. tostring(toIndex)
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "PARTY")
    end
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INIT_ICON, function(index, iconID)
    if not index or not iconID then return end
    local payload = GAC.Enums.Events.INIT_ICON .. ":" .. tostring(index) .. ":" .. tostring(iconID)
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "PARTY")
    end
end)
