--- @module Frames.MainMenu.Components.CharSheet.TraitsTab
-- Main orchestrator tab for character positive trait selection.

local _, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}

local function BuildSaveButton(ctx)
    local btn = GAC:CreateButton(ctx.tab, "Guardar Cambios", {140, 26}, {"BOTTOMRIGHT", ctx.tab, "BOTTOMRIGHT", -55, 10}, true)
    btn:SetFrameLevel(ctx.scroll:GetFrameLevel() + 5)
    ctx.ui.saveCharBtn = btn

    btn:SetScript("OnClick", function()
        btn:Hide()
        
        if GAC.playerCharacter then
            GAC.playerCharacter:SetPositiveTraits(ctx.selectedTraits)
            GAC.playerCharacter:IncrementVersion()
            GAC.characterData.modelData = GAC.playerCharacter:Serialize()
        end
        
        GAC.characterData = GAC.characterData or {}
        GAC.characterData.positiveTraits = ctx.selectedTraits
        
        print("|cFF40C7EB[GAC]|r: Rasgos positivos guardados correctamente.")
    end)
end

--- Creates the positive traits selection tab UI.
-- @param tab Frame Parent tab frame
-- @param mainFrame Frame Top level main frame
-- @return void
function GAC.Components.MainMenu:CreateTraitsTab(tab, mainFrame)
    local scroll, bg = GAC.Components.MainMenu:CreateScrollableTab(tab, 450, 500)
    
    local category = "normal"
    local level = 1
    if GAC.playerCharacter then
        category = GAC.playerCharacter:GetCategory() or "normal"
        level = GAC.playerCharacter:GetLevel() or 1
    elseif GAC.characterData and GAC.characterData.progress then
        category = GAC.characterData.progress.category or "normal"
        level = GAC.characterData.progress.level or 1
    end
    
    local levelEntry = GAC:GetLevelEntry(category, level)
    local maxPoints = levelEntry and levelEntry.maxPositiveTraits or 0

    local rawTraits = {}
    if GAC.playerCharacter then
        rawTraits = GAC.playerCharacter:GetPositiveTraits() or {}
    elseif GAC.characterData and GAC.characterData.positiveTraits then
        rawTraits = GAC.characterData.positiveTraits
    end

    local selectedTraits = {}
    for k, v in pairs(rawTraits) do
        selectedTraits[k] = tonumber(v) or 0
    end

    local function GetTotalSpentPoints()
        local spent = 0
        for _, lvl in pairs(selectedTraits) do
            spent = spent + (tonumber(lvl) or 0)
        end
        return spent
    end

    local ctx = {
        tab = tab,
        mainFrame = mainFrame,
        scroll = scroll,
        bg = bg,
        maxPoints = maxPoints,
        selectedTraits = selectedTraits,
        GetTotalSpentPoints = GetTotalSpentPoints,
        ui = {}
    }

    BuildSaveButton(ctx)

    -- Header point counter
    local headerText = GAC:CreateFontString(bg, "", "GameFontNormalLarge", { "TOPLEFT", 15, -15 }, { 0.25, 0.78, 0.94 })
    
    local function UpdatePointsHeader()
        local spent = GetTotalSpentPoints()
        local colorMarkup = (spent > maxPoints) and "|cFFFF4444" or "|cFF00FF00"
        headerText:SetText(string.format("Puntos de Rasgos Positivos: %s%d|r / %d", colorMarkup, spent, maxPoints))
    end

    local traitCards = {}

    ctx.OnTraitsUpdated = function()
        UpdatePointsHeader()
        for _, card in ipairs(traitCards) do
            if card.Refresh then card:Refresh() end
        end
    end

    UpdatePointsHeader()

    -- Render all positive traits dynamically
    local currentY = -45
    if GAC.PositiveTraits and #GAC.PositiveTraits > 0 then
        for _, traitData in ipairs(GAC.PositiveTraits) do
            local card = GAC.Components.MainMenu.CharSheet.CreateTraitCard(bg, traitData, ctx)
            card:SetPoint("TOPLEFT", 15, currentY)
            card:SetPoint("TOPRIGHT", -15, currentY)
            table.insert(traitCards, card)
            currentY = currentY - (card:GetHeight() + 10)
        end
    else
        local noTraitsText = GAC:CreateFontString(bg, "No hay rasgos positivos disponibles.", "GameFontHighlight", { "TOPLEFT", 15, currentY }, { 0.6, 0.6, 0.6 })
        currentY = currentY - 30
    end

    -- Update dynamic scroll height to prevent overflow
    local neededHeight = math.abs(currentY) + 30
    bg:SetHeight(math.max(neededHeight, scroll:GetHeight()))

    tab:SetScript("OnShow", function()
        if GAC.playerCharacter then
            local pTraits = GAC.playerCharacter:GetPositiveTraits() or {}
            for k, v in pairs(pTraits) do
                ctx.selectedTraits[k] = tonumber(v) or 0
            end
        end
        ctx.OnTraitsUpdated()
    end)
end
