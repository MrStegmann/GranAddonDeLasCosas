local _, GAC = ...

function GAC:CreateCharSheetContent(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetAllPoints()

    -- ScrollFrame para manejar muchos talentos
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(520, 1)
    scrollFrame:SetScrollChild(content)

    -- Función para refrescar los datos de la ficha
    local function UpdateSheet()
        -- Limpieza de elementos dinámicos previos
        local regions = {content:GetRegions()}
        for _, region in ipairs(regions) do region:Hide() end

        local yPos = 15
        local attributeGroups = GAC.attributeGroups or {}
        local charData = GAC.characterData or { attributes = {}, talents = {} }

        for _, group in ipairs(attributeGroups) do
            -- Título del grupo de Atributo
            local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", 10, -yPos)
            title:SetText(group.name)
            title:SetTextColor(0.25, 0.78, 0.94)
            yPos = yPos + 22

            -- Puntuación base del atributo
            local attrVal = charData.attributes[group.name] or 0
            local attrDesc = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            attrDesc:SetPoint("TOPLEFT", 15, -yPos)
            attrDesc:SetText("Puntuación actual: |cffffffff" .. attrVal .. "|r")
            yPos = yPos + 25

            -- Lista de Talentos
            local hasTalents = false
            local talentHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            talentHeader:SetPoint("TOPLEFT", 20, -yPos)
            talentHeader:SetText("TALENTOS:")
            talentHeader:SetTextColor(0.6, 0.6, 0.6)
            yPos = yPos + 18

            for _, talentName in ipairs(group.talents or {}) do
                local tVal = charData.talents[talentName] or 0
                if tVal > 0 then
                    local tText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    tText:SetPoint("TOPLEFT", 30, -yPos)
                    tText:SetText("• " .. talentName .. ": |cffffffff" .. tVal .. "|r")
                    yPos = yPos + 16
                    hasTalents = true
                end
            end

            if not hasTalents then
                local noneText = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                noneText:SetPoint("TOPLEFT", 30, -yPos)
                noneText:SetText("(Sin talentos aprendidos)")
                yPos = yPos + 16
            end

            -- Línea separadora tenue
            local line = content:CreateTexture(nil, "ARTWORK")
            line:SetSize(480, 1)
            line:SetPoint("TOPLEFT", 10, -yPos - 10)
            line:SetColorTexture(1, 1, 1, 0.05)
            yPos = yPos + 30
        end
        content:SetHeight(yPos)
    end

    frame.Update = UpdateSheet
    return frame
end