local _, GAC = ...

function GAC:AddInitiativeRoll(playerName, total)
    if not IsInGroup() and not IsInRaid() then return end
    
    if not self.initiativeFrame then
        self:InitializeInitiativeFrame()
    end
    
    self.initiativeFrame:Show()
    
    table.insert(self.initiativeOrder, { name = playerName, total = total })
    
    if self.activeInitiativeView == "current" then
        self:UpdateInitiativeFrame()
    end
end

function GAC:ClearInitiativeOrder()
    self.initiativeOrder = {}
    self.currentLinkedHistory = nil
    if self.activeInitiativeView == "current" then
        self:UpdateInitiativeFrame()
    end
end

function GAC:SyncCurrentHistory()
    if self.currentLinkedHistory and self.characterData and self.characterData.initiativeHistory then
        local hist = self.characterData.initiativeHistory[self.currentLinkedHistory]
        if hist then
            local copy = {}
            for i, v in ipairs(self.initiativeOrder) do
                table.insert(copy, {name = v.name, total = v.total, icon = v.icon})
            end
            hist.rolls = copy
        end
    end
end

function GAC:SortInitiativeOrder()
    if #self.initiativeOrder == 0 then return end
    
    table.sort(self.initiativeOrder, function(a, b)
        local valA = tonumber(a.total) or 0
        local valB = tonumber(b.total) or 0
        return valA > valB
    end)
    
    -- Guardar copia en el historial persistente
    self.characterData = self.characterData or {}
    self.characterData.initiativeHistory = self.characterData.initiativeHistory or {}
    
    local copy = {}
    for i, v in ipairs(self.initiativeOrder) do
        table.insert(copy, {name = v.name, total = v.total, icon = v.icon})
    end
    
    if self.currentLinkedHistory and self.characterData.initiativeHistory[self.currentLinkedHistory] then
        -- Si ya hay un historial vinculado, solo lo actualizamos para no crear spam
        self.characterData.initiativeHistory[self.currentLinkedHistory].rolls = copy
    else
        local currentDate = date("%Y-%m-%d %H:%M:%S")
        table.insert(self.characterData.initiativeHistory, { date = currentDate, rolls = copy })
        self.currentLinkedHistory = #self.characterData.initiativeHistory
    end
    
    self:UpdateInitiativeFrame()
end

function GAC:MoveInitiativeIndex(fromIndex, toIndex)
    if not self.initiativeOrder[fromIndex] then return end
    if toIndex < 1 then toIndex = 1 end
    if toIndex > #self.initiativeOrder then toIndex = #self.initiativeOrder end
    
    local element = table.remove(self.initiativeOrder, fromIndex)
    table.insert(self.initiativeOrder, toIndex, element)
    
    self:SyncCurrentHistory()
    
    if self.activeInitiativeView == "current" then
        self:UpdateInitiativeFrame()
    end
end

function GAC:SetInitiativeIcon(index, iconID)
    if not self.initiativeOrder[index] then return end
    self.initiativeOrder[index].icon = iconID
    
    self:SyncCurrentHistory()
    
    if self.activeInitiativeView == "current" then
        self:UpdateInitiativeFrame()
    end
end
