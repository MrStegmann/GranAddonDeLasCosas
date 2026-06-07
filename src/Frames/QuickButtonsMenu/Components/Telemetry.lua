local addonName, GAC = ...

local function GetUnitDistance(unit)
    -- Intento 1: Epsilon API (C_Epsilon.GetUnitWorldPosition o GetUnitWorldPosition global)
    if C_Epsilon and type(C_Epsilon.GetUnitWorldPosition) == "function" then
        print("entra aqui")
        local pcallOk1, pX, pY, pZ = pcall(C_Epsilon.GetUnitWorldPosition, "player")
        local pcallOk2, uX, uY, uZ = pcall(C_Epsilon.GetUnitWorldPosition, unit)
        if pcallOk1 and pcallOk2 and pX and pY and pZ and uX and uY and uZ then
            return string.format("%.1f yd", math.sqrt((pX-uX)^2 + (pY-uY)^2 + (pZ-uZ)^2))
        end
    elseif type(GetUnitWorldPosition) == "function" then
        local pcallOk1, pX, pY, pZ = pcall(GetUnitWorldPosition, "player")
        local pcallOk2, uX, uY, uZ = pcall(GetUnitWorldPosition, unit)
        if pcallOk1 and pcallOk2 and pX and pY and pZ and uX and uY and uZ then
            return string.format("%.1f yd", math.sqrt((pX-uX)^2 + (pY-uY)^2 + (pZ-uZ)^2))
        end
    end

    -- Intento 2: UnitPosition (Preciso, pero restringido a grupo/banda por Blizzard)
    local y1, x1, z1 = UnitPosition("player")
    local y2, x2, z2 = UnitPosition(unit)
    if x1 and y1 and z1 and x2 and y2 and z2 then
        return string.format("%.1f yd", math.sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2))
    end
    
    -- Intento 3: UnitDistanceSquared (Posible en clientes de servidores privados)
    if type(UnitDistanceSquared) == "function" then
        local pcallOk, sqDist = pcall(UnitDistanceSquared, unit)
        if pcallOk and type(sqDist) == "number" and sqDist > 0 then
            return string.format("%.1f yd", math.sqrt(sqDist))
        end
        pcallOk, sqDist = pcall(UnitDistanceSquared, "player", unit)
        if pcallOk and type(sqDist) == "number" and sqDist > 0 then
            return string.format("%.1f yd", math.sqrt(sqDist))
        end
    end

    -- Intento 4: Aproximación por CheckInteractDistance (Fallback para NPCs)
    if CheckInteractDistance(unit, 3) then
        return "< 10 yd"
    elseif CheckInteractDistance(unit, 2) then
        return "< 11 yd"
    elseif CheckInteractDistance(unit, 4) then
        return "< 28 yd"
    else
        return "> 28 yd"
    end
end

function GAC:UpdateTelemetry()
    if not self.telemetryFrame or not self.telemetryFrame:IsVisible() then return end
    
    local distanceText = nil
    
    -- Priority 1: Target
    if UnitExists("target") then
        distanceText = GetUnitDistance("target")
    -- Priority 2: Unit with selected Marker
    elseif self.telemetryTargetMarker then
        local foundUnit = nil
        
        -- Check Raid
        for i=1, 40 do
            local unit = "raid"..i
            if UnitExists(unit) and GetRaidTargetIndex(unit) == self.telemetryTargetMarker then
                foundUnit = unit
                break
            end
        end
        
        -- Check Party
        if not foundUnit then
            for i=1, 4 do
                local unit = "party"..i
                if UnitExists(unit) and GetRaidTargetIndex(unit) == self.telemetryTargetMarker then
                    foundUnit = unit
                    break
                end
            end
        end
        
        -- Check Nameplates
        if not foundUnit then
            for i=1, 40 do
                local unit = "nameplate"..i
                if UnitExists(unit) and GetRaidTargetIndex(unit) == self.telemetryTargetMarker then
                    foundUnit = unit
                    break
                end
            end
        end
        
        if foundUnit then
            distanceText = GetUnitDistance(foundUnit)
        end
    end
    
    if distanceText then
        self.telemetryFrame.distanceText:SetText(distanceText)
    else
        self.telemetryFrame.distanceText:SetText("--")
    end
end

function GAC:CreateTelemetryFrame(parentFrame)
    if self.telemetryFrame then return end

    local toggleBtn = CreateFrame("Button", "GACTelemetryToggleBtn", parentFrame, "UIPanelButtonTemplate")
    toggleBtn:SetSize(16, 40)
    toggleBtn:SetText("<")

    local frame = CreateFrame("Frame", "GACTelemetryFrame", UIParent, "BackdropTemplate")
    frame:SetSize(120, 55)
    frame:SetPoint("RIGHT", parentFrame, "LEFT", 2, 0)
    frame:SetFrameStrata("MEDIUM")
    
    toggleBtn:SetPoint("RIGHT", frame, "LEFT", 2, 0)
    
    local isExpanded = true
    toggleBtn:SetScript("OnClick", function()
        isExpanded = not isExpanded
        if isExpanded then
            if GAC.telemetryFrame then GAC.telemetryFrame:Show() end
            toggleBtn:ClearAllPoints()
            toggleBtn:SetPoint("RIGHT", GAC.telemetryFrame, "LEFT", 2, 0)
            toggleBtn:SetText(">")
        else
            if GAC.telemetryFrame then GAC.telemetryFrame:Hide() end
            toggleBtn:ClearAllPoints()
            toggleBtn:SetPoint("RIGHT", parentFrame, "LEFT", 2, 0)
            toggleBtn:SetText("<")
        end
    end)
    
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.05, 0.06, 0.08, 0.78)
    frame:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.75)
    
    -- ROW 1: Marker Selector (Dropdown)
    local dropdown = CreateFrame("Frame", "GACTelemetryMarkerDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, -2)
    UIDropDownMenu_SetWidth(dropdown, 80)
    UIDropDownMenu_SetText(dropdown, "Ninguna")
    
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        
        info.text = "Ninguna marca"
        info.func = function()
            GAC.telemetryTargetMarker = nil
            UIDropDownMenu_SetText(dropdown, "Ninguna")
            GAC:UpdateTelemetry()
        end
        info.checked = (GAC.telemetryTargetMarker == nil)
        UIDropDownMenu_AddButton(info)
        
        local iconsMap = {
            {id = 1, name = "Estrella"},
            {id = 2, name = "Círculo"},
            {id = 3, name = "Diamante"},
            {id = 4, name = "Triángulo"},
            {id = 5, name = "Luna"},
            {id = 6, name = "Cuadrado"},
            {id = 7, name = "Cruz"},
            {id = 8, name = "Calavera"}
        }
        
        for _, ic in ipairs(iconsMap) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = ic.name
            info.func = function()
                GAC.telemetryTargetMarker = ic.id
                UIDropDownMenu_SetText(dropdown, ic.name)
                GAC:UpdateTelemetry()
            end
            info.checked = (GAC.telemetryTargetMarker == ic.id)
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- ROW 2: Distance Info
    local distLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    distLabel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 8)
    distLabel:SetText("Distancia:")

    local distText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    distText:SetPoint("LEFT", distLabel, "RIGHT", 5, 0)
    distText:SetText("--")
    frame.distanceText = distText

    -- Automatic Update Loop (1 second)
    local timer = 0
    frame:SetScript("OnUpdate", function(self, elapsed)
        timer = timer + elapsed
        if timer >= 1.0 then
            timer = 0
            GAC:UpdateTelemetry()
        end
    end)
    
    -- Trigger on target change to update instantly
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_TARGET_CHANGED" then
            GAC:UpdateTelemetry()
        end
    end)
    
    -- Hide if quick buttons is hidden
    frame:SetScript("OnShow", function() GAC:UpdateTelemetry() end)

    self.telemetryFrame = frame
    
    -- Initial update
    GAC:UpdateTelemetry()
end
