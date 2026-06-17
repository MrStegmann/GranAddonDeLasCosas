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
        C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:TAL:" .. talStr, "WHISPER", shortSender)
        
    elseif string.sub(text, 1, 9) == "TTIP:ATT:" then
        local data = string.sub(text, 10)
        GAC.tooltipCache[shortSender] = GAC.tooltipCache[shortSender] or { attributes = {}, talents = {} }
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tooltipCache[shortSender].attributes[k] = tonumber(v) or 0
            end
        end
        
    elseif string.sub(text, 1, 9) == "TTIP:TAL:" then
        local data = string.sub(text, 10)
        GAC.tooltipCache[shortSender] = GAC.tooltipCache[shortSender] or { attributes = {}, talents = {} }
        for pair in string.gmatch(data, "([^;]+)") do
            local k, v = strsplit("=", pair)
            if k and v then
                GAC.tooltipCache[shortSender].talents[k] = tonumber(v) or 0
            end
        end
        
        -- TAL is the last packet, show tooltip if still hovering
        if TargetFrame and TargetFrame:IsMouseOver() and UnitName("target") then
            local fullName = GetUnitName("target", true)
            if fullName then fullName = Ambiguate(fullName, "none") end
            if fullName == shortSender then
                GAC:ShowTargetTooltip(TargetFrame, GAC.tooltipCache[shortSender].attributes, GAC.tooltipCache[shortSender].talents)
            end
        end
        end
    end)
end)

function GAC:RequestTooltipData(targetName)
    if not targetName or targetName == "" then return end
    C_ChatInfo.SendAddonMessage(commPrefix, "TTIP:REQ", "WHISPER", targetName)
end

local isTargetTooltipHooked = false

function GAC:ShowTargetTooltip(anchorFrame, attributes, talents)
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
    
    local talAdded = false
    if talents then
        if attAdded then GACTargetTooltip:AddLine(" ") end
        for k, v in pairs(talents) do
            if v and type(v) == "number" and v > 0 then
                if not talAdded then
                    GACTargetTooltip:AddLine("Talentos:", 0.25, 0.78, 0.94)
                    talAdded = true
                end
                GACTargetTooltip:AddDoubleLine(GAC:_(k), tostring(v), 1, 1, 1, 1, 1, 1)
                hasAny = true
            end
        end
    end
    
    if not hasAny then
        GACTargetTooltip:AddLine("No tiene atributos o talentos con valor.", 0.5, 0.5, 0.5)
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
                GAC:ShowTargetTooltip(self, attributes, talents)
            else
                local cached = GAC.tooltipCache[fullName]
                if cached then
                    GAC:ShowTargetTooltip(self, cached.attributes, cached.talents)
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
