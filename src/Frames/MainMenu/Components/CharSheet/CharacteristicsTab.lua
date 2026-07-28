--- @module Frames.MainMenu.Components.CharSheet.CharacteristicsTab
-- Orchestrator tab for character sheet race, traits, and characteristics configuration.

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
            local newRaces = {}
            if ctx.currentRaces[1] ~= "Ninguna" then table.insert(newRaces, ctx.currentRaces[1]) end
            if ctx.currentRaces[2] ~= "Ninguna" then table.insert(newRaces, ctx.currentRaces[2]) end
            if #newRaces == 0 then table.insert(newRaces, "human") end
            GAC.playerCharacter:SetRace(newRaces)
            
            local raceTalents = {}
            if ctx.adaptTarget then raceTalents.adaptTarget = ctx.adaptTarget end
            if ctx.perfTarget then raceTalents.perfTarget = ctx.perfTarget end
            
            if ctx.currentRaces[2] == "Ninguna" and ctx.currentRaces[1] ~= "Ninguna" then
                local data = GAC:GetRaceData(ctx.currentRaces[1])
                if data then
                    if data.advantages then for k, v in pairs(data.advantages) do raceTalents[k] = v end end
                    if data.disadvantages then for k, v in pairs(data.disadvantages) do raceTalents[k] = v end end
                    if data.special then for k, v in pairs(data.special) do raceTalents[k] = v end end
                end
            elseif ctx.currentRaces[1] ~= "Ninguna" and ctx.currentRaces[2] ~= "Ninguna" then
                local allAdv, allDis, allSpec = GAC.Utils.MainMenu:MergeRaceTraits(ctx.currentRaces)
                for k, v in pairs(ctx.mestizoTraits or {}) do
                    if allAdv[k] then raceTalents[k] = v end
                    if allDis[k] then raceTalents[k] = v end
                end
                for k, v in pairs(allSpec) do
                    raceTalents[v] = true
                end
            end
            
            GAC.playerCharacter._data.raceTalents = raceTalents
            GAC.playerCharacter:IncrementVersion()
            GAC.characterData.modelData = GAC.playerCharacter:Serialize()
        end
        
        if ctx.mainFrame.UpdateHeaderInfoText then ctx.mainFrame:UpdateHeaderInfoText() end
        ctx.EvaluateDynamicRacialBonuses()
        print("|cFF40C7EB[GAC]|r: Características guardadas correctamente.")
    end)
end

--- Creates character sheet characteristics tab UI.
-- @param tab Frame Parent tab frame
-- @param mainFrame Frame Top level main frame
-- @return void
function GAC.Components.MainMenu:CreateCharacteristicsTab(tab, mainFrame)
    local scroll, bg = GAC.Components.MainMenu:CreateScrollableTab(tab, 450, 500)
    GAC.characterData.characteristics = GAC.characterData.characteristics or {}
    
    local currentRaces = { "human", "Ninguna" }
    local mestizoTraits = {}
    local adaptTarget, perfTarget = nil, nil
    
    if GAC.playerCharacter then
        local r = GAC.playerCharacter:GetRace()
        if r and #r > 0 then
            currentRaces[1] = r[1] or "Ninguna"
            currentRaces[2] = r[2] or "Ninguna"
        end
        local rt = GAC.playerCharacter:GetRaceTalents() or {}
        adaptTarget = rt.adaptTarget
        perfTarget = rt.perfTarget
        
        for k, v in pairs(rt) do
            if k ~= "adaptTarget" and k ~= "perfTarget" then
                mestizoTraits[k] = v
            end
        end
    end
    
    local ctx = {
        tab = tab,
        mainFrame = mainFrame,
        scroll = scroll,
        bg = bg,
        currentRaces = currentRaces,
        mestizoTraits = mestizoTraits,
        adaptTarget = adaptTarget,
        perfTarget = perfTarget,
        ui = {}
    }

    BuildSaveButton(ctx)
    
    local CharSheetComponents = GAC.Components.MainMenu.CharSheet
    CharSheetComponents.BuildRaceDropdowns(ctx)
    CharSheetComponents.BuildRaceSummaries(ctx)
    CharSheetComponents.BuildMestizoBuilder(ctx)
    CharSheetComponents.BuildDynamicBonuses(ctx)
    CharSheetComponents.SetupLayoutManager(ctx)
    
    ctx.UpdateDynamicLayout()

    if ctx.currentRaces[1] == "Ninguna" then
        UIDropDownMenu_DisableDropDown(ctx.ui.raceDrop2)
    end
    
    ctx.EvaluateDynamicRacialBonuses()

    tab:SetScript("OnShow", function()
        if GAC.characterData then
            ctx.ui.worgenCurseCheckbox:SetChecked(GAC.characterData.isWorgenCurse or false)
            ctx.EvaluateDynamicRacialBonuses()
        end
    end)
end
