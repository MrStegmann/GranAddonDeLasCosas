local _, GAC = ...

function GAC:InitializeTargetPlate()
    if GAC.isTargetPlateHooked then return end
    GAC.isTargetPlateHooked = true
    
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:SetScript("OnEvent", function()
        if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player") then
            local shortName = Ambiguate(UnitName("target"), "none")
            local targetGUID = UnitGUID("target")
            
            local cached = GAC.targetDataCache and targetGUID and GAC.targetDataCache[targetGUID]
            -- If we only have the minimal Character from RES, it's fine. We check timestamp if it's there.
            if not cached or (GetTime() - (cached._data and cached._data.timestamp or 0) > 300) then
                if GAC.Transmitter then
                    GAC.Transmitter:Trigger(GAC.Enums.Events.REQ, shortName, false)
                end
            end
        end
        
        GAC:UpdateTargetPlate()
    end)

    local elapsed = 0
    f:SetScript("OnUpdate", function(self, dt)
        if not UnitExists("target") then return end
        elapsed = elapsed + dt
        if elapsed >= 0.5 then
            elapsed = 0
            if GAC.UpdateTargetPlate then
                GAC:UpdateTargetPlate()
            end
        end
    end)
    
    if TargetFrame_Update then
        hooksecurefunc("TargetFrame_Update", function()
            if GAC.UpdateTargetPlate then GAC:UpdateTargetPlate() end
        end)
    end
    
    if UnitFrameHealthBar_Update then
        hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar, unit)
            if unit == "target" and statusbar == TargetFrameHealthBar then
                if GAC.UpdateTargetPlate then GAC:UpdateTargetPlate() end
            end
        end)
    end
    
    if TextStatusBar_UpdateTextString then
        hooksecurefunc("TextStatusBar_UpdateTextString", function(textStatusBar)
            if textStatusBar == TargetFrameHealthBar then
                if GAC.UpdateTargetPlate then GAC:UpdateTargetPlate() end
            end
        end)
    end
end
