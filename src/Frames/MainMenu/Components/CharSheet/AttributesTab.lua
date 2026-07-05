local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}

function GAC.Components.MainMenu:CreateCharSheetAttributesTab(tab, mainFrame)
    local scrollFrameAtt, contentContainer = GAC.Components.MainMenu:CreateScrollableTab(tab, 400, 10)

    local statInputs = {}

    local saveStatsBtn = CreateFrame("Button", nil, tab, "UIPanelButtonTemplate")
    saveStatsBtn:SetSize(140, 26)
    saveStatsBtn:SetPoint("BOTTOM", scrollFrameAtt, "BOTTOM", 0, -35)
    saveStatsBtn:SetText("Guardar Cambios")
    saveStatsBtn:Hide()

    saveStatsBtn:SetScript("OnClick", function()
        saveStatsBtn:Hide()
        print("|cFF40C7EB[GAC]|r: Atributos y talentos guardados correctamente.")
        for key, data in pairs(statInputs) do
            local v = tonumber(data.input:GetText()) or 0
            if GAC.playerCharacter then
                if data.isTalent then 
                    GAC.playerCharacter:SetTalent(key, v)
                else 
                    GAC.playerCharacter:SetAttribute(key, v)
                end
            end
        end
        if GAC.playerCharacter then
            GAC.playerCharacter:IncrementVersion()
            GAC.characterData.modelData = GAC.playerCharacter:Serialize()
        end
    end)

    local function RefreshStats()
        saveStatsBtn:Hide()
        local attributes = {}
        local talents = {}
        
        if GAC.playerCharacter then
            attributes = GAC.playerCharacter:GetAttributes() or {}
            talents = GAC.playerCharacter:GetTalents() or {}
        end

        for key, data in pairs(statInputs) do
            if data.isTalent then
                data.input:SetText(tostring(tonumber(talents[key]) or 0))
            else
                data.input:SetText(tostring(tonumber(attributes[key]) or 0))
            end
            data.input:SetCursorPosition(0) -- Ensures text is not scrolled out of view
        end
    end

    local function InitCards()
        if contentContainer.cardsCreated then return end
        if not GAC.attributeGroups then return end
        
        local currentY = -10

        for i, group in ipairs(GAC.attributeGroups) do
            local card = GAC:CreateCard(contentContainer, group, function() saveStatsBtn:Show() end, statInputs)
            card:SetPoint("TOPLEFT", 10, currentY)
            card:SetPoint("TOPRIGHT", -10, currentY)
            
            currentY = currentY - card:GetHeight() - 10
        end

        contentContainer:SetHeight((currentY * -1) + 20)
        contentContainer.cardsCreated = true
    end

    tab:SetScript("OnShow", function()
        InitCards()
        RefreshStats()
    end)
end
