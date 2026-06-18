local addonName, GAC = ...

function GAC:CreateCharSheetAttributesTab(tab, mainFrame)
    local attBg = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    attBg:SetAllPoints()
    attBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    attBg:SetBackdropColor(0, 0, 0, 0.3)
    attBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local scrollFrameAtt = CreateFrame("ScrollFrame", nil, attBg, "UIPanelScrollFrameTemplate")
    scrollFrameAtt:SetPoint("TOPLEFT", 8, -8)
    scrollFrameAtt:SetPoint("BOTTOMRIGHT", -28, 45)

    local contentContainer = CreateFrame("Frame", nil, scrollFrameAtt)
    contentContainer:SetSize(400, 10)
    scrollFrameAtt:SetScrollChild(contentContainer)

    scrollFrameAtt:SetScript("OnSizeChanged", function(self, width)
        contentContainer:SetWidth(width)
    end)

    local statInputs = {}

    local saveStatsBtn = CreateFrame("Button", nil, attBg, "UIPanelButtonTemplate")
    saveStatsBtn:SetSize(140, 26)
    saveStatsBtn:SetPoint("BOTTOM", 0, 10)
    saveStatsBtn:SetText("Guardar Cambios")
    saveStatsBtn:Hide()

    saveStatsBtn:SetScript("OnClick", function()
        saveStatsBtn:Hide()
        print("|cFF40C7EB[GAC]|r: Atributos y talentos guardados correctamente.")
        for key, data in pairs(statInputs) do
            local v = tonumber(data.input:GetText()) or 0
            if GAC.characterData then
                if data.isTalent then GAC.characterData.talents[key] = v
                else GAC.characterData.attributes[key] = v end
            end
        end
    end)

    local function RefreshStats()
        saveStatsBtn:Hide()
        if not GAC.characterData then return end
        
        local attributes = (type(GAC.characterData) == "table" and GAC.characterData.attributes) or {}
        local talents = (type(GAC.characterData) == "table" and GAC.characterData.talents) or {}

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
