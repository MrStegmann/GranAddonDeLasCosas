local _, GAC = ...

GAC.tooltipCache = GAC.tooltipCache or {}

local commPrefix = "GAC_Sync"
local commFrame = CreateFrame("Frame")
commFrame:RegisterEvent("CHAT_MSG_ADDON")
commFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
    GAC:SafeCall(function()
        if prefix ~= commPrefix then return end
        local shortSender = Ambiguate(sender, "none")
    
    if text == "TTIP:REQ" then
        if not GAC.characterData then return end
        
        -- Send Attributes
        local attributes = GAC.characterData.attributes or {}
        local attStr = ""
        for k, v in pairs(attributes) do
            attStr = attStr .. tostring(k) .. "=" .. tostring(v) .. ";"
        end
        if attStr ~= "" then
            C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:ATT:" .. attStr, "WHISPER", shortSender)
        end
        
        -- Send Talents
        local talents = GAC.characterData.talents or {}
        local talStr = ""
        for k, v in pairs(talents) do
            talStr = talStr .. tostring(k) .. "=" .. tostring(v) .. ";"
        end
        if talStr ~= "" then
            C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:TAL:" .. talStr, "WHISPER", shortSender)
        end
        
        -- Send Advantages
        local advantages = GAC.characterData.characteristics and GAC.characterData.characteristics.activeAdvantages or {}
        local advStr = ""
        for k, v in pairs(advantages) do
            advStr = advStr .. tostring(k) .. "=" .. tostring(v) .. ";"
        end
        if advStr ~= "" then
            C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:ADV:" .. advStr, "WHISPER", shortSender)
        end
        
        -- Send Disadvantages
        local disadvantages = GAC.characterData.characteristics and GAC.characterData.characteristics.activeDisadvantages or {}
        local disStr = ""
        for k, v in pairs(disadvantages) do
            disStr = disStr .. tostring(k) .. "=" .. tostring(v) .. ";"
        end
        if disStr ~= "" then
            C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:DIS:" .. disStr, "WHISPER", shortSender)
        end
        
        -- Send Special
        local special = GAC.characterData.characteristics and GAC.characterData.characteristics.activeSpecial or {}
        local spcStr = ""
        for _, v in ipairs(special) do
            spcStr = spcStr .. tostring(v) .. ";"
        end
        if spcStr ~= "" then
            C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:SPC:" .. spcStr, "WHISPER", shortSender)
        end
        
        C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:END", "WHISPER", shortSender)
        
    elseif string.sub(text, 1, 9) == "TTIP:ATT:" then
        local data = string.sub(text, 10)
        GAC.tooltipCache[shortSender] = GAC.tooltipCache[shortSender] or { attributes = {}, talents = {}, advantages = {}, disadvantages = {}, special = {} }
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tooltipCache[shortSender].attributes[k] = tonumber(v) or 0
            end
        end
        
    elseif string.sub(text, 1, 9) == "TTIP:TAL:" then
        local data = string.sub(text, 10)
        GAC.tooltipCache[shortSender] = GAC.tooltipCache[shortSender] or { attributes = {}, talents = {}, advantages = {}, disadvantages = {}, special = {} }
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tooltipCache[shortSender].talents[k] = tonumber(v) or 0
            end
        end
        
    elseif string.sub(text, 1, 9) == "TTIP:ADV:" then
        local data = string.sub(text, 10)
        GAC.tooltipCache[shortSender] = GAC.tooltipCache[shortSender] or { attributes = {}, talents = {}, advantages = {}, disadvantages = {}, special = {} }
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tooltipCache[shortSender].advantages[k] = tonumber(v) or 0
            end
        end
        
    elseif string.sub(text, 1, 9) == "TTIP:DIS:" then
        local data = string.sub(text, 10)
        GAC.tooltipCache[shortSender] = GAC.tooltipCache[shortSender] or { attributes = {}, talents = {}, advantages = {}, disadvantages = {}, special = {} }
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tooltipCache[shortSender].disadvantages[k] = tonumber(v) or 0
            end
        end
        
    elseif string.sub(text, 1, 9) == "TTIP:SPC:" then
        local data = string.sub(text, 10)
        GAC.tooltipCache[shortSender] = GAC.tooltipCache[shortSender] or { attributes = {}, talents = {}, advantages = {}, disadvantages = {}, special = {} }
        for spc in string.gmatch(data, "([^;]+)") do
            table.insert(GAC.tooltipCache[shortSender].special, spc)
        end
        
    elseif text == "TTIP:END" then
        if TargetFrame and TargetFrame:IsMouseOver() and UnitName("target") then
            local fullName = GetUnitName("target", true)
            if fullName then fullName = Ambiguate(fullName, "none") end
            if fullName == shortSender then
                local cached = GAC.tooltipCache[shortSender]
                GAC:ShowTargetTooltip(TargetFrame, cached.attributes, cached.talents, cached.advantages, cached.disadvantages, cached.special)
            end
        end
        end
    end)
end)

function GAC:RequestTooltipData(targetName)
    if not targetName or targetName == "" then return end
    GAC.tooltipCache[targetName] = { attributes = {}, talents = {}, advantages = {}, disadvantages = {}, special = {} }
    C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:REQ", "WHISPER", targetName)
end

local isTargetTooltipHooked = false

function GAC:ShowTargetTooltip(anchorFrame, attributes, talents, advantages, disadvantages, special)
    if not GACTargetTooltip then
        GACTargetTooltip = CreateFrame("GameTooltip", "GACTargetTooltip", UIParent, "GameTooltipTemplate")
    end
    
    GACTargetTooltip:SetOwner(anchorFrame, "ANCHOR_RIGHT")
    GACTargetTooltip:ClearLines()
    GACTargetTooltip:AddLine("Estadísticas", 1, 0.82, 0)
    GACTargetTooltip:AddLine(" ")
    
    local hasAny = false
    
    local attAdded = false
    if attributes then
        for k, v in pairs(attributes) do
            if v and type(v) == "number" and v > 0 then
                if not attAdded then
                    GACTargetTooltip:AddLine("Atributos:", 0.25, 0.78, 0.94)
                    attAdded = true
                end
                GACTargetTooltip:AddDoubleLine(GAC:_(k), tostring(v), 1, 1, 1, 1, 1, 1)
                hasAny = true
            end
        end
    end
    
    local combinedTalents = {}
    if talents then
        for k, v in pairs(talents) do
            combinedTalents[k] = tonumber(v) or 0
        end
    end
    if advantages then
        for k, v in pairs(advantages) do
            combinedTalents[k] = (combinedTalents[k] or 0) + (tonumber(v) or 0)
        end
    end
    if disadvantages then
        for k, v in pairs(disadvantages) do
            combinedTalents[k] = (combinedTalents[k] or 0) + (tonumber(v) or 0)
        end
    end
    
    local sortedTalents = {}
    for k in pairs(combinedTalents) do table.insert(sortedTalents, k) end
    table.sort(sortedTalents)

    local talAdded = false
    for _, k in ipairs(sortedTalents) do
        local v = combinedTalents[k]
        if v ~= 0 then
            if not talAdded then
                if attAdded then GACTargetTooltip:AddLine(" ") end
                GACTargetTooltip:AddLine("Talentos:", 0.25, 0.78, 0.94)
                talAdded = true
            end
            
            local r, g, b = 1, 1, 1
            if v < 0 then
                r, g, b = 1, 0.2, 0.2
            end
            
            GACTargetTooltip:AddDoubleLine(GAC:_(k), tostring(v), 1, 1, 1, r, g, b)
            hasAny = true
        end
    end

    local spcAdded = false
    if special and #special > 0 then
        if hasAny then GACTargetTooltip:AddLine(" ") end
        GACTargetTooltip:AddLine("Especial:", 0.8, 0.4, 0.8)
        for _, v in ipairs(special) do
            GACTargetTooltip:AddLine(GAC:_(v) or v, 1, 1, 1)
            hasAny = true
        end
    end
    
    if not hasAny then
        GACTargetTooltip:AddLine("No tiene estadísticas ni características.", 0.5, 0.5, 0.5)
    end
    
    GACTargetTooltip:Show()
end

function GAC:InitializeTargetTooltip()
    if isTargetTooltipHooked then return end
    isTargetTooltipHooked = true
    
    if TargetFrame then
        TargetFrame:HookScript("OnEnter", function(self)
            GAC:SafeCall(function()
                if not UnitExists("target") or not UnitIsPlayer("target") then return end
                
                local fullName = GetUnitName("target", true)
            if fullName then fullName = Ambiguate(fullName, "none") end
            
            local isPlayer = UnitIsUnit("target", "player")
            
            if isPlayer then
                local attributes = GAC.characterData and GAC.characterData.attributes or {}
                local talents = GAC.characterData and GAC.characterData.talents or {}
                local chars = GAC.characterData and GAC.characterData.characteristics or {}
                GAC:ShowTargetTooltip(self, attributes, talents, chars.activeAdvantages, chars.activeDisadvantages, chars.activeSpecial)
            else
                local cached = GAC.tooltipCache[fullName]
                if cached then
                    GAC:ShowTargetTooltip(self, cached.attributes, cached.talents, cached.advantages, cached.disadvantages, cached.special)
                else
                    GAC:RequestTooltipData(fullName)
                end
                end
            end)
        end)
        
        TargetFrame:HookScript("OnLeave", function(self)
            if GACTargetTooltip then
                GACTargetTooltip:Hide()
            end
        end)
    end
end
