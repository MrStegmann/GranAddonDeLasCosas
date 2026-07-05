local _, GAC = ...

GAC.Receiver:OnEvent(GAC.Enums.Events.REQ, function(sender, channel)
    if GAC.Transmitter then
        GAC.requestersCache = GAC.requestersCache or {}
        GAC.requestersCache[sender] = GetTime()
        GAC.Transmitter:Trigger(GAC.Enums.Events.RES, sender, false)
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.RES, function(sender, channel, guid, level, category, maxHealth, currentHealth, currentShield)
    if not guid or guid == "UNKNOWN" then return end
    if level and category and maxHealth then
        if not GAC.inspectedPlayersCache[guid] then
            if GAC.Character then
                GAC.inspectedPlayersCache[guid] = GAC.Character:new({
                    name = sender,
                    level = tonumber(level) or 1,
                    category = category,
                    healthPoints = { max = tonumber(maxHealth) or 10, current = tonumber(currentHealth) or tonumber(maxHealth) or 10 },
                    shieldPoints = { current = tonumber(currentShield) or 0 },
                    version = 0,
                    timestamp = GetTime()
                })
            end
        else
            local char = GAC.inspectedPlayersCache[guid]
            char:SetLevel(tonumber(level) or 1)
            char:SetCategory(category)
            char:SetHealthPoints(tonumber(currentHealth) or 0)
            char:SetShieldPoints(tonumber(currentShield) or 0)
            char._data.timestamp = GetTime()
            -- We can't update max health directly via a setter if it doesn't match constitution/level,
            -- but for this minimal update, it's fine.
        end
        
        local currentTargetName = UnitName("target")
        if currentTargetName and currentTargetName == sender then
            if GAC.UpdateTargetPlate then
                GAC:UpdateTargetPlate()
            end
            if GAC.UpdateTargetInspectButtonVisibility then
                GAC:UpdateTargetInspectButtonVisibility()
            end
        end
    end
end)
