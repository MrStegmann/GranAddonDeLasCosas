local _, GAC = ...

GAC.Receiver:OnEvent(GAC.Enums.Events.INSPECT_REQ, function(sender, channel, version, guid)
    if GAC.SendInspectionData then
        GAC:SendInspectionData(sender, version)
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_INFO, function(sender, channel, guid, level, category, class, maxHealth, maxExp, version)
    if not guid or guid == "UNKNOWN" then return end
    GAC.tempInsp[guid] = {
        name = sender,
        version = tonumber(version) or 1,
        level = tonumber(level) or 1,
        category = category or "normal",
        class = class or "Desconocida",
        healthPoints = { current = tonumber(maxHealth) or 10, max = tonumber(maxHealth) or 10 },
        experience = { current = 0, max = tonumber(maxExp) or 0 },
        shieldPoints = { current = 0 },
        manapoints = { current = 0, max = 0 },
        spiritPoints = { current = 0, max = 0 },
        attributes = {},
        talents = {},
        positiveTraits = {},
        negativeTraits = {},
        special = {},
        equippedItems = {}
    }
    -- Compatibility mappings for existing UI
    GAC.tempInsp[guid].maxHealth = GAC.tempInsp[guid].healthPoints.max
    GAC.tempInsp[guid].maxExp = GAC.tempInsp[guid].experience.max
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_ATT, function(sender, channel, data)
    local guid = nil
    for g, d in pairs(GAC.tempInsp) do if d.name == sender then guid = g break end end
    if guid and GAC.tempInsp[guid] and data then
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tempInsp[guid].attributes[k] = tonumber(v) or 0
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_TAL, function(sender, channel, data)
    local guid = nil
    for g, d in pairs(GAC.tempInsp) do if d.name == sender then guid = g break end end
    if guid and GAC.tempInsp[guid] and data then
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tempInsp[guid].talents[k] = tonumber(v) or 0
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_ADV, function(sender, channel, data)
    local guid = nil
    for g, d in pairs(GAC.tempInsp) do if d.name == sender then guid = g break end end
    if guid and GAC.tempInsp[guid] and data then
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tempInsp[guid].positiveTraits[k] = tonumber(v) or 0
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_DIS, function(sender, channel, data)
    local guid = nil
    for g, d in pairs(GAC.tempInsp) do if d.name == sender then guid = g break end end
    if guid and GAC.tempInsp[guid] and data then
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tempInsp[guid].negativeTraits[k] = tonumber(v) or 0
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_SPC, function(sender, channel, data)
    local guid = nil
    for g, d in pairs(GAC.tempInsp) do if d.name == sender then guid = g break end end
    if guid and GAC.tempInsp[guid] and data then
        for spc in string.gmatch(data, "([^;]+)") do
            table.insert(GAC.tempInsp[guid].special, spc)
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_RAC, function(sender, channel, r1, r2, worgen)
    local guid = nil
    for g, d in pairs(GAC.tempInsp) do if d.name == sender then guid = g break end end
    if guid and GAC.tempInsp[guid] then
        GAC.tempInsp[guid].race = {}
        if r1 and r1 ~= "Ninguna" then table.insert(GAC.tempInsp[guid].race, r1) end
        if r2 and r2 ~= "Ninguna" then table.insert(GAC.tempInsp[guid].race, r2) end
        if #GAC.tempInsp[guid].race == 0 then table.insert(GAC.tempInsp[guid].race, "human") end
        
        GAC.tempInsp[guid].worgenCurse = (worgen == "1")
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_EQP, function(sender, channel, data)
    local guid = nil
    for g, d in pairs(GAC.tempInsp) do if d.name == sender then guid = g break end end
    if guid and GAC.tempInsp[guid] and data then
        for pair in string.gmatch(data, "([^;]+)") do
            local slot, itemId = strsplit("=", pair)
            if slot and itemId then
                GAC.tempInsp[guid].equippedItems[slot] = { id = itemId }
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_VOL, function(sender, channel, guid, hp, sp, mp, spp, exp)
    if not guid or guid == "UNKNOWN" then return end
    
    if GAC.inspectedPlayersCache and GAC.inspectedPlayersCache[guid] then
        local char = GAC.inspectedPlayersCache[guid]
        char:SetHealthPoints(tonumber(hp) or 0)
        char:SetShieldPoints(tonumber(sp) or 0)
        char:SetManaPoints(tonumber(mp) or 0)
        char:SetSpiritPoints(tonumber(spp) or 0)
        
        local expVal = tonumber(exp) or 0
        local oldExp = char:GetExperience()
        if oldExp then
            char:SetExperience(expVal, oldExp.max)
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_END, function(sender, channel, version)
    local guid = nil
    -- If tempInsp exists, we are building a new Character
    for g, d in pairs(GAC.tempInsp) do if d.name == sender then guid = g break end end
    
    -- If not, we might be just receiving INSP_VOL and already have the Character in cache
    if not guid then
        for g, d in pairs(GAC.inspectedPlayersCache) do 
            if d._data and d._data.name == sender then guid = g break end 
        end
    end

    if guid then
        if GAC.tempInsp[guid] then
            if GAC.Character then
                GAC.inspectedPlayersCache[guid] = GAC.Character:new(GAC.tempInsp[guid])
                GAC.inspectedPlayer = GAC.inspectedPlayersCache[guid]._data
            end
            GAC.tempInsp[guid] = nil -- clean up
        elseif GAC.inspectedPlayersCache[guid] then
            GAC.inspectedPlayer = GAC.inspectedPlayersCache[guid]._data
        end
        
        if GAC.OpenInspectionMenu then
            GAC:OpenInspectionMenu()
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.ADD_EXP, function(sender, channel, amountStr)
    local amount = tonumber(amountStr)
    if amount and GAC.AddExperience then
        GAC:AddExperience(amount)
        if GAC.UpdateGameExpBar then
            GAC:UpdateGameExpBar()
        end
    end
end)
