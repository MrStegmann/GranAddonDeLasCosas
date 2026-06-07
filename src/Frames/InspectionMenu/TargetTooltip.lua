local _, GAC = ...

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
            if not UnitExists("target") or not UnitIsPlayer("target") then return end
            
            local tName, tRealm = UnitName("target")
            local fullName = tName
            if tRealm and tRealm ~= "" then
                fullName = tName .. "-" .. tRealm
            end
            
            local isPlayer = UnitIsUnit("target", "player")
            local attributes, talents
            
            if isPlayer then
                attributes = GAC.characterData and GAC.characterData.attributes or {}
                talents = GAC.characterData and GAC.characterData.talents or {}
            elseif GAC.inspectedPlayer and GAC.inspectedPlayer.name == fullName then
                attributes = GAC.inspectedPlayer.attributes or {}
                talents = GAC.inspectedPlayer.talents or {}
            end
            
            if attributes or talents then
                GAC:ShowTargetTooltip(self, attributes, talents)
            else
                if GAC.RequestInspection then
                    GAC.silentInspections = GAC.silentInspections or {}
                    GAC.silentInspections[fullName] = true
                    GAC:RequestInspection(fullName)
                end
            end
        end)
        
        TargetFrame:HookScript("OnLeave", function(self)
            if GACTargetTooltip then
                GACTargetTooltip:Hide()
            end
        end)
    end
end
