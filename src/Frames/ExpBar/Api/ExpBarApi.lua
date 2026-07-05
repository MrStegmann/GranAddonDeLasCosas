local _, GAC = ...

GAC.isExpBarHooked = false

function GAC:UpdateGameExpBar()
    if not StatusTrackingBarManager then return end

    local progress = self.characterData and self.characterData.progress or {}
    local currentExp = progress.currentExperience or 0
    local category = progress.category or "normal"
    local level = progress.level or 1
    local maxExp = self:GetRequiredExperience(category, level) or 1
    if maxExp <= 0 then maxExp = 1 end
    local percent = math.floor((currentExp / maxExp) * 100)

    if self.UpdatePlayerPlate then
        self:UpdatePlayerPlate()
    end

    local bars = StatusTrackingBarManager.bars
    if bars and #bars > 0 then
        local expBar = bars[1]

        if not self.isExpBarHooked then
            if expBar.ShouldBeVisible then
                expBar.ShouldBeVisible = function() return true end
            end
            
            if expBar.Update then
                expBar.Update = function(self_bar) 
                    GAC:UpdateGameExpBar()
                end
            end
            
            self.isExpBarHooked = true
            StatusTrackingBarManager:UpdateBars()
            return
        end

        if expBar.StatusBar then
            expBar.StatusBar:SetMinMaxValues(0, maxExp)
            expBar.StatusBar:SetValue(currentExp)
            
            if expBar.OverlayFrame and expBar.OverlayFrame.Text then
                expBar.OverlayFrame.Text:SetText(string.format("%d / %d (%d%%)", currentExp, maxExp, percent))
            end
        end
    end
end
