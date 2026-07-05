local _, GAC = ...

GAC.Receiver:OnEvent(GAC.Enums.Events.INSPECT_REQ, function(sender, channel)
    if GAC.SendInspectionData then
        GAC:SendInspectionData(sender)
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_INFO, function(sender, channel, level, category, race, class, maxHealth, currentShield, currentExp, maxExp)
    GAC.inspectedPlayer = {
        name = sender,
        level = tonumber(level) or 1,
        category = category or "normal",
        race = race or "Desconocida",
        class = class or "Desconocida",
        maxHealth = tonumber(maxHealth) or 10,
        currentShield = tonumber(currentShield) or 0,
        currentExp = tonumber(currentExp) or 0,
        maxExp = tonumber(maxExp) or 0,
        attributes = {},
        talents = {}
    }
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_ATT, function(sender, channel, data)
    if GAC.inspectedPlayer and GAC.inspectedPlayer.name == sender and data then
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.inspectedPlayer.attributes[k] = tonumber(v) or 0
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_TAL, function(sender, channel, data)
    if GAC.inspectedPlayer and GAC.inspectedPlayer.name == sender and data then
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.inspectedPlayer.talents[k] = tonumber(v) or 0
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_ADV, function(sender, channel, data)
    if GAC.inspectedPlayer and GAC.inspectedPlayer.name == sender and data then
        GAC.inspectedPlayer.advantages = GAC.inspectedPlayer.advantages or {}
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.inspectedPlayer.advantages[k] = tonumber(v) or 0
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_DIS, function(sender, channel, data)
    if GAC.inspectedPlayer and GAC.inspectedPlayer.name == sender and data then
        GAC.inspectedPlayer.disadvantages = GAC.inspectedPlayer.disadvantages or {}
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.inspectedPlayer.disadvantages[k] = tonumber(v) or 0
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_SPC, function(sender, channel, data)
    if GAC.inspectedPlayer and GAC.inspectedPlayer.name == sender and data then
        GAC.inspectedPlayer.special = GAC.inspectedPlayer.special or {}
        for spc in string.gmatch(data, "([^;]+)") do
            table.insert(GAC.inspectedPlayer.special, spc)
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_RAC, function(sender, channel, r1, r2, worgen)
    if GAC.inspectedPlayer and GAC.inspectedPlayer.name == sender then
        GAC.inspectedPlayer.race1 = r1 or "Ninguna"
        GAC.inspectedPlayer.race2 = r2 or "Ninguna"
        GAC.inspectedPlayer.worgenCurse = (worgen == "1")
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INSP_END, function(sender, channel)
    if GAC.inspectedPlayer and GAC.inspectedPlayer.name == sender then
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
