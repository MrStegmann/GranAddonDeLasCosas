local _, GAC = ...

GAC.Receiver:OnEvent(GAC.Enums.Events.REQ, function(sender, channel)
    if GAC.Transmitter then
        GAC.requestersCache = GAC.requestersCache or {}
        GAC.requestersCache[sender] = GetTime()
        GAC.Transmitter:Trigger(GAC.Enums.Events.RES, sender, false)
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.RES, function(sender, channel, level, category, maxHealth, currentHealth, currentShield)
    if level and category and maxHealth then
        GAC.targetDataCache = GAC.targetDataCache or {}
        GAC.targetDataCache[sender] = {
            level = tonumber(level) or 1,
            category = category,
            maxHealth = tonumber(maxHealth) or 10,
            currentHealth = tonumber(currentHealth) or tonumber(maxHealth) or 10,
            currentShield = tonumber(currentShield) or 0,
            timestamp = GetTime()
        }
        
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
