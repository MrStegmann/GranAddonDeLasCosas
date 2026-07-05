local _, GAC = ...

GAC.Receiver:OnEvent(GAC.Enums.Events.INIT_ADD, function(sender, channel, initName, initTotal)
    if sender ~= UnitName("player") then
        if initName and initTotal and GAC.AddInitiativeRoll then
            GAC:AddInitiativeRoll(initName, initTotal)
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INIT_ACTION, function(sender, channel, action)
    if sender ~= UnitName("player") then
        if action == "CLEAR" and GAC.ClearInitiativeOrder then
            GAC:ClearInitiativeOrder()
        elseif action == "SORT" and GAC.SortInitiativeOrder then
            GAC:SortInitiativeOrder()
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INIT_MOVE, function(sender, channel, fromIdxStr, toIdxStr)
    if sender ~= UnitName("player") then
        local fromIdx = tonumber(fromIdxStr)
        local toIdx = tonumber(toIdxStr)
        if fromIdx and toIdx and GAC.MoveInitiativeIndex then
            GAC:MoveInitiativeIndex(fromIdx, toIdx)
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.INIT_ICON, function(sender, channel, idxStr, iconIDStr)
    if sender ~= UnitName("player") then
        local idx = tonumber(idxStr)
        local iconID = tonumber(iconIDStr)
        if idx and iconID and GAC.SetInitiativeIcon then
            GAC:SetInitiativeIcon(idx, iconID)
        end
    end
end)
