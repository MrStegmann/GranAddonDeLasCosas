local addonName, GAC = ...

SLASH_GACMENU1 = "/gac"
SlashCmdList["GACMENU"] = function() 
    GAC:SafeCall(function()
        if GAC.Screens and GAC.Screens.MainMenu then
            GAC.Screens.MainMenu:Toggle()
        end
    end)
end
