local _, GAC = ...

function GAC:InitializeRaidPlate()
    if GAC.isRaidPlateHooked then return end
    GAC.isRaidPlateHooked = true
    
    local f = CreateFrame("Frame")
    local elapsed = 0
    f:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed >= 0.5 then
            elapsed = 0
            for frame in pairs(GAC.activeRaidFrames) do
                if frame and frame.IsVisible and frame:IsVisible() and frame.unit then
                    if GAC.UpdateRaidPlate then
                        GAC:UpdateRaidPlate(frame)
                    end
                elseif frame and (not frame.IsVisible or not frame:IsVisible()) then
                    GAC.activeRaidFrames[frame] = nil
                end
            end
        end
    end)
    
    if CompactUnitFrame_UpdateHealth then
        hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
            if GAC.UpdateRaidPlate then GAC:UpdateRaidPlate(frame) end
        end)
    end
    
    if CompactUnitFrame_UpdateMaxHealth then
        hooksecurefunc("CompactUnitFrame_UpdateMaxHealth", function(frame)
            if GAC.UpdateRaidPlate then GAC:UpdateRaidPlate(frame) end
        end)
    end
    
    if CompactUnitFrame_UpdateStatusText then
        hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
            if GAC.UpdateRaidPlate then GAC:UpdateRaidPlate(frame) end
        end)
    end
end
