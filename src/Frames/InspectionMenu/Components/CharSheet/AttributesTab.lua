local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InspectionMenu = GAC.Components.InspectionMenu or {}

function GAC.Components.InspectionMenu:CreateAttributesTab(parent)
    local attBg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    attBg:SetAllPoints()
    attBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    attBg:SetBackdropColor(0, 0, 0, 0.3)
    attBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local scrollFrameAtt = CreateFrame("ScrollFrame", nil, attBg, "UIPanelScrollFrameTemplate")
    scrollFrameAtt:SetPoint("TOPLEFT", 8, -8)
    scrollFrameAtt:SetPoint("BOTTOMRIGHT", -28, 15)

    local contentContainer = CreateFrame("Frame", nil, scrollFrameAtt)
    contentContainer:SetSize(400, 10)
    scrollFrameAtt:SetScrollChild(contentContainer)

    scrollFrameAtt:SetScript("OnSizeChanged", function(self, width)
        contentContainer:SetWidth(width)
    end)

    local statLabels = {}

    local function InitCards()
        if contentContainer.cardsCreated then return end
        if not GAC.attributeGroups then return end
        
        local currentY = -10

        for i, group in ipairs(GAC.attributeGroups) do
            local card = GAC:CreateReadOnlyCard(contentContainer, group, statLabels)
            card:SetPoint("TOPLEFT", 10, currentY)
            card:SetPoint("TOPRIGHT", -10, currentY)
            
            currentY = currentY - card:GetHeight() - 10
        end

        contentContainer:SetHeight((currentY * -1) + 20)
        contentContainer.cardsCreated = true
    end

    attBg:SetScript("OnShow", function()
        InitCards()
        if GAC.inspectedPlayer then
            for key, data in pairs(statLabels) do
                local tval = GAC.inspectedPlayer.talents and GAC.inspectedPlayer.talents[key] or 0
                local aval = GAC.inspectedPlayer.attributes and GAC.inspectedPlayer.attributes[key] or 0
                if data.isTalent then
                    data.val:SetText(tostring(tval))
                else
                    data.val:SetText(tostring(aval))
                end
            end
        end
    end)

    attBg.Update = function(self, p)
        if self:IsShown() then
            self:GetScript("OnShow")()
        end
    end

    return attBg
end
