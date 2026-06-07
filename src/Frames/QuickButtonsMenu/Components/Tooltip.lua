local addonName, GAC = ...

function GAC:SetupQuickTooltip(button, title, ...)
    local lines = {...}
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(title)
        for _, line in ipairs(lines) do
            if type(line) == "table" then 
                GameTooltip:AddLine(unpack(line)) 
            else 
                GameTooltip:AddLine(line, 1, 1, 1) 
            end
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end
