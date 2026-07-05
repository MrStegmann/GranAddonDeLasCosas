local addonName, GAC = ...

GAC.Screens = GAC.Screens or {}
GAC.Screens.EconomyCalculator = GAC.Screens.EconomyCalculator or {}

SLASH_GACECONOMY1 = "/gaceco"
SLASH_GACECONOMY2 = "/gaceconomy"
SlashCmdList["GACECONOMY"] = function()
    if GAC.SafeCall then
        GAC:SafeCall(function()
            if GAC.Screens and GAC.Screens.EconomyCalculator then
                GAC.Screens.EconomyCalculator:Toggle()
            end
        end)
    else
        if GAC.Screens and GAC.Screens.EconomyCalculator then
            GAC.Screens.EconomyCalculator:Toggle()
        end
    end
end

function GAC.Screens.EconomyCalculator:Create()
    if self.frame then return end
    if self.CreateScreen then
        self:CreateScreen()
    end
end

function GAC.Screens.EconomyCalculator:Toggle()
    self:Create()
    if self.frame then
        if self.frame:IsShown() then
            self.frame:Hide()
        else
            self.frame:Show()
            if self.UpdateDisplay then
                self:UpdateDisplay()
            end
        end
    end
end
