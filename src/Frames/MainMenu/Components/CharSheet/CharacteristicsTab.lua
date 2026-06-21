local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}

-------------------------------------------------------------------------------
-- Utilidades
-------------------------------------------------------------------------------
local function ParseStatValue(statString)
    local val = statString:match("([%+%-]%d+)")
    return val and tonumber(val) or 0
end

local function FormatRacialStatList(list)
    if type(list) == "table" then
        local t = {}
        if #list > 0 then
            for _, v in ipairs(list) do table.insert(t, "• " .. (GAC:_(v) or v)) end
        else
            local hasElements = false
            local sortedKeys = {}
            for k in pairs(list) do table.insert(sortedKeys, k) end
            table.sort(sortedKeys)
            
            for _, k in ipairs(sortedKeys) do
                local v = list[k]
                hasElements = true
                local sign = v > 0 and "+" or ""
                local suffix = ""
                if k == "adaptability" and GAC.characterData and GAC.characterData.characteristics and GAC.characterData.characteristics.adaptTarget then
                    suffix = " (" .. (GAC:_(GAC.characterData.characteristics.adaptTarget) or GAC.characterData.characteristics.adaptTarget) .. ")"
                elseif k == "perfectionism" and GAC.characterData and GAC.characterData.characteristics and GAC.characterData.characteristics.perfTarget then
                    suffix = " (" .. (GAC:_(GAC.characterData.characteristics.perfTarget) or GAC.characterData.characteristics.perfTarget) .. ")"
                end
                table.insert(t, "• " .. sign .. v .. " " .. (GAC:_(k) or k) .. suffix)
            end
            if not hasElements then return "Ninguna" end
        end
        return table.concat(t, "\n")
    end
    return "Ninguna"
end

-------------------------------------------------------------------------------
-- Sub-módulos
-------------------------------------------------------------------------------

local function BuildSaveButton(ctx)
    local btn = GAC:CreateButton(ctx.tab, "Guardar Cambios", {140, 26}, {"BOTTOMRIGHT", ctx.tab, "BOTTOMRIGHT", -55, 10}, true)
    btn:SetFrameLevel(ctx.scroll:GetFrameLevel() + 5)
    ctx.ui.saveCharBtn = btn

    btn:SetScript("OnClick", function()
        btn:Hide()
        GAC.characterData.characteristics.race1 = ctx.currentRace1
        GAC.characterData.characteristics.race2 = ctx.currentRace2
        GAC.characterData.characteristics.adaptLocked = true
        GAC.characterData.characteristics.perfLocked = true
        
        GAC.Utils.MainMenu:SafeCall(function()
            if ctx.currentRace2 == "Ninguna" and ctx.currentRace1 ~= "Ninguna" then
                local data = GAC:GetRaceData(ctx.currentRace1)
                if data then
                    GAC.characterData.characteristics.activeAdvantages = data.advantages
                    GAC.characterData.characteristics.activeDisadvantages = data.disadvantages
                    GAC.characterData.characteristics.activeSpecial = data.special
                end
            elseif ctx.currentRace1 ~= "Ninguna" and ctx.currentRace2 ~= "Ninguna" then
                local allAdv, allDis, allSpec = GAC.Utils.MainMenu:MergeRaceTraits(ctx.currentRace1, ctx.currentRace2)
                local mestizoTraits = GAC.characterData.characteristics.mestizoTraits or {}
                
                local activeAdv, activeDis = {}, {}
                for k, v in pairs(mestizoTraits) do
                    if allAdv[k] then activeAdv[k] = v end
                    if allDis[k] then activeDis[k] = v end
                end
                
                GAC.characterData.characteristics.activeAdvantages = activeAdv
                GAC.characterData.characteristics.activeDisadvantages = activeDis
                GAC.characterData.characteristics.activeSpecial = allSpec
            else
                GAC.characterData.characteristics.activeAdvantages = nil
                GAC.characterData.characteristics.activeDisadvantages = nil
                GAC.characterData.characteristics.activeSpecial = nil
            end
        end)
        
        if ctx.mainFrame.UpdateHeaderInfoText then ctx.mainFrame:UpdateHeaderInfoText() end
        ctx.EvaluateDynamicRacialBonuses()
        print("|cFF40C7EB[GAC]|r: Características guardadas correctamente.")
    end)
end

local function BuildRaceDropdowns(ctx)
    local raceLabel1 = GAC:CreateFontString(ctx.bg, "Raza Principal:", "GameFontNormal", { "TOPLEFT", 15, -20 }, {1, 1, 1})
    local raceDrop1 = CreateFrame("Frame", "GAC_CharSheetRaceDrop1", ctx.bg, "UIDropDownMenuTemplate")
    raceDrop1:SetPoint("TOPLEFT", raceLabel1, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(raceDrop1, 150)

    local raceLabel2 = GAC:CreateFontString(ctx.bg, "Raza Secundaria:", "GameFontNormal", { "TOPLEFT", 220, -20 }, {1, 1, 1})
    local raceDrop2 = CreateFrame("Frame", "GAC_CharSheetRaceDrop2", ctx.bg, "UIDropDownMenuTemplate")
    raceDrop2:SetPoint("TOPLEFT", raceLabel2, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(raceDrop2, 150)

    ctx.ui.raceDrop1 = raceDrop1
    ctx.ui.raceDrop2 = raceDrop2

    local function InitializeRaceDropdown(dropdown, getValue, isSecondary, onChange)
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            info.text = "Ninguna"
            info.func = function()
                if getValue() ~= "Ninguna" then ctx.ui.saveCharBtn:Show() end
                onChange("Ninguna")
                UIDropDownMenu_SetText(dropdown, info.text)
                ctx.UpdateDynamicLayout()
            end
            UIDropDownMenu_AddButton(info)

            local currentRaces = GAC:GetFlatRaces()
            for _, raceName in ipairs(currentRaces) do
                local infoRace = UIDropDownMenu_CreateInfo()
                infoRace.text = GAC:_(raceName) or raceName
                infoRace.func = function()
                    if getValue() ~= raceName then ctx.ui.saveCharBtn:Show() end
                    onChange(raceName)
                    UIDropDownMenu_SetText(dropdown, infoRace.text)
                    ctx.EvaluateDynamicRacialBonuses()
                    ctx.UpdateDynamicLayout()
                end
                UIDropDownMenu_AddButton(infoRace)
            end
        end)
    end

    InitializeRaceDropdown(raceDrop1, function() return ctx.currentRace1 end, false, function(newVal)
        ctx.currentRace1 = newVal
        if newVal == "Ninguna" then
            ctx.currentRace2 = "Ninguna"
            UIDropDownMenu_SetText(raceDrop2, "Ninguna")
            UIDropDownMenu_DisableDropDown(raceDrop2)
        else
            UIDropDownMenu_EnableDropDown(raceDrop2)
        end
    end)
    UIDropDownMenu_SetText(raceDrop1, GAC:_(ctx.currentRace1) or ctx.currentRace1)
    
    InitializeRaceDropdown(raceDrop2, function() return ctx.currentRace2 end, true, function(newVal)
        ctx.currentRace2 = newVal
    end)
    UIDropDownMenu_SetText(raceDrop2, GAC:_(ctx.currentRace2) or ctx.currentRace2)
end

local function BuildRaceSummaries(ctx)
    local consts = GAC.Stores.MainMenu.Constants
    
    local function CreateRaceSummary(anchorFrame)
        local f = CreateFrame("Frame", nil, ctx.bg)
        f:SetSize(200, 80)
        f:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 15, -15)
        
        f.advLabel = GAC:CreateFontString(f, "Ventajas", "GameFontNormalSmall", { "TOPLEFT", 0, 0 }, consts.COLOR_ADVANTAGE)
        f.advText = GAC:CreateFontString(f, "", "GameFontHighlightSmall", { "TOPLEFT", f.advLabel, "BOTTOMLEFT", 0, -2 }, {1, 1, 1})
        f.advText:SetWidth(100)
        f.advText:SetJustifyH("LEFT")
        f.advText:SetJustifyV("TOP")
        
        f.disLabel = GAC:CreateFontString(f, "Desventajas", "GameFontNormalSmall", { "TOPLEFT", 105, 0 }, consts.COLOR_DISADVANTAGE)
        f.disText = GAC:CreateFontString(f, "", "GameFontHighlightSmall", { "TOPLEFT", f.disLabel, "BOTTOMLEFT", 0, -2 }, {1, 1, 1})
        f.disText:SetWidth(100)
        f.disText:SetJustifyH("LEFT")
        f.disText:SetJustifyV("TOP")
        
        f.specLabel = GAC:CreateFontString(f, "Especial", "GameFontNormalSmall", { "TOPLEFT", 0, -60 }, consts.COLOR_SPECIAL)
        f.specText = GAC:CreateFontString(f, "", "GameFontHighlightSmall", { "TOPLEFT", f.specLabel, "BOTTOMLEFT", 0, -2 }, {1, 1, 1})
        f.specText:SetWidth(205)
        f.specText:SetJustifyH("LEFT")
        f.specText:SetJustifyV("TOP")

        f:Hide()
        return f
    end

    ctx.ui.summary1 = CreateRaceSummary(ctx.ui.raceDrop1)
    ctx.ui.summary2 = CreateRaceSummary(ctx.ui.raceDrop2)

    ctx.UpdateRaceSummary = function(summaryFrame, raceName)
        if raceName == "Ninguna" then
            summaryFrame:Hide()
            return
        end
        local data = GAC:GetRaceData(raceName)
        if not data then
            summaryFrame:Hide()
            return
        end
        
        summaryFrame:Show()
        summaryFrame.advText:SetText(FormatRacialStatList(data.advantages))
        summaryFrame.disText:SetText(FormatRacialStatList(data.disadvantages))
        summaryFrame.specText:SetText(FormatRacialStatList(data.special))
        
        local advHeight = summaryFrame.advText:GetStringHeight() or 20
        local disHeight = summaryFrame.disText:GetStringHeight() or 20
        local maxListHeight = math.max(advHeight, disHeight)
        
        summaryFrame.specLabel:ClearAllPoints()
        summaryFrame.specLabel:SetPoint("TOPLEFT", summaryFrame.advLabel, "BOTTOMLEFT", 0, -(maxListHeight + 10))
        
        if not data.special or #data.special == 0 then
            summaryFrame.specLabel:Hide()
            summaryFrame.specText:Hide()
        else
            summaryFrame.specLabel:Show()
            summaryFrame.specText:Show()
        end
    end
end

local function BuildMestizoBuilder(ctx)
    local consts = GAC.Stores.MainMenu.Constants
    
    local f = CreateFrame("Frame", nil, ctx.bg)
    ctx.ui.mestizoBuilderFrame = f
    f:SetPoint("TOPLEFT", ctx.ui.raceDrop1, "BOTTOMLEFT", 15, -15)
    f:SetPoint("TOPRIGHT", ctx.ui.raceDrop2, "BOTTOMRIGHT", -15, -15)
    f:SetHeight(150)
    f:Hide()

    local advTitle = GAC:CreateFontString(f, "Ventajas (0/3)", "GameFontNormalSmall", { "TOPLEFT", 0, 0 }, consts.COLOR_ADVANTAGE)
    local disTitle = GAC:CreateFontString(f, "Desventajas (0/3)", "GameFontNormalSmall", { "TOPLEFT", 190, 0 }, consts.COLOR_DISADVANTAGE)
    
    local advContainer = CreateFrame("Frame", nil, f)
    advContainer:SetPoint("TOPLEFT", advTitle, "BOTTOMLEFT", 0, -10)
    advContainer:SetSize(180, 100)

    local disContainer = CreateFrame("Frame", nil, f)
    disContainer:SetPoint("TOPLEFT", disTitle, "BOTTOMLEFT", 0, -10)
    disContainer:SetSize(180, 100)
    
    local specLabel = GAC:CreateFontString(f, "Especial Combinado", "GameFontNormalSmall", { "TOPLEFT", advContainer, "BOTTOMLEFT", 0, -15 }, consts.COLOR_SPECIAL)
    local specText = GAC:CreateFontString(f, "", "GameFontHighlightSmall", { "TOPLEFT", specLabel, "BOTTOMLEFT", 0, -2 }, {1, 1, 1})
    specText:SetWidth(380)
    specText:SetJustifyH("LEFT")
    specText:SetJustifyV("TOP")
    
    local checkboxes = {}
    local function GetMestizoCheckbox(index, parent)
        if not checkboxes[index] then
            local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
            cb:SetSize(20, 20)
            cb.label = GAC:CreateFontString(cb, "", "GameFontHighlightSmall", { "LEFT", cb, "RIGHT", 5, 0 }, {1, 1, 1})
            checkboxes[index] = cb
        end
        checkboxes[index]:SetParent(parent)
        return checkboxes[index]
    end

    ctx.RefreshMestizoBuilder = function()
        for _, cb in pairs(checkboxes) do cb:Hide() end
        if ctx.currentRace1 == "Ninguna" or ctx.currentRace2 == "Ninguna" then return end

        local allAdv, allDis, allSpec = GAC.Utils.MainMenu:MergeRaceTraits(ctx.currentRace1, ctx.currentRace2)
        
        GAC.characterData.characteristics.mestizoTraits = GAC.characterData.characteristics.mestizoTraits or {}
        local mestizoTraits = GAC.characterData.characteristics.mestizoTraits
        
        -- Clean old traits
        for k in pairs(mestizoTraits) do
            if not allAdv[k] and not allDis[k] then mestizoTraits[k] = nil end
        end
        
        local currentAdvSum, currentDisSum = 0, 0
        for k, v in pairs(mestizoTraits) do
            if allAdv[k] then currentAdvSum = currentAdvSum + math.abs(v)
            elseif allDis[k] then currentDisSum = currentDisSum + math.abs(v) end
        end
        
        advTitle:SetText(string.format("Ventajas (%d/3)", currentAdvSum))
        disTitle:SetText(string.format("Desventajas (%d/3)", currentDisSum))

        local cbIndex = 1
        local function RenderDict(dict, container, currentSum)
            local yOffset = 0
            local sortedKeys = {}
            for k in pairs(dict) do table.insert(sortedKeys, k) end
            table.sort(sortedKeys)
            
            for _, k in ipairs(sortedKeys) do
                local v = dict[k]
                local cb = GetMestizoCheckbox(cbIndex, container)
                cbIndex = cbIndex + 1
                cb:SetPoint("TOPLEFT", 0, yOffset)
                cb:Show()
                
                local sign = v > 0 and "+" or ""
                cb.label:SetText(sign .. v .. " " .. (GAC:_(k) or k))
                
                local traitVal = math.abs(v)
                local isChecked = (mestizoTraits[k] ~= nil)
                cb:SetChecked(isChecked)
                
                if not isChecked and (currentSum + traitVal > 3) then
                    cb:Disable()
                    cb.label:SetTextColor(0.5, 0.5, 0.5)
                else
                    cb:Enable()
                    cb.label:SetTextColor(1, 1, 1)
                end
                
                cb:SetScript("OnClick", function(self)
                    if self:GetChecked() then mestizoTraits[k] = v else mestizoTraits[k] = nil end
                    ctx.ui.saveCharBtn:Show()
                    ctx.RefreshMestizoBuilder()
                end)
                yOffset = yOffset - 25
            end
            return yOffset
        end
        
        local advHeight = math.abs(RenderDict(allAdv, advContainer, currentAdvSum))
        local disHeight = math.abs(RenderDict(allDis, disContainer, currentDisSum))
        local maxListHeight = math.max(advHeight, disHeight)
        
        advContainer:SetHeight(maxListHeight)
        disContainer:SetHeight(maxListHeight)
        specLabel:SetPoint("TOPLEFT", advContainer, "BOTTOMLEFT", 0, -15)
        
        if #allSpec > 0 then
            specLabel:Show()
            specText:Show()
            local t = {}
            for _, v in ipairs(allSpec) do table.insert(t, GAC:_(v) or v) end
            specText:SetText(table.concat(t, "\n"))
            f:SetHeight(maxListHeight + 40 + specText:GetHeight())
        else
            specLabel:Hide()
            specText:Hide()
            f:SetHeight(maxListHeight + 30)
        end
    end
end

local function BuildDynamicBonuses(ctx)
    local adaptLabel = GAC:CreateFontString(ctx.bg, "Mejora Adaptabilidad:", "GameFontNormal", { "TOPLEFT", ctx.bg, "TOPLEFT", 15, -160 }, {1, 1, 1})
    local adaptDrop = CreateFrame("Frame", "GAC_CharSheetAdaptDrop", ctx.bg, "UIDropDownMenuTemplate")
    adaptDrop:SetPoint("TOPLEFT", adaptLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(adaptDrop, 150)
    adaptLabel:Hide()
    adaptDrop:Hide()

    local perfLabel = GAC:CreateFontString(ctx.bg, "Mejora Perfeccionismo:", "GameFontNormal", { "TOPLEFT", ctx.bg, "TOPLEFT", 220, -160 }, {1, 1, 1})
    local perfDrop = CreateFrame("Frame", "GAC_CharSheetPerfDrop", ctx.bg, "UIDropDownMenuTemplate")
    perfDrop:SetPoint("TOPLEFT", perfLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(perfDrop, 150)
    perfLabel:Hide()
    perfDrop:Hide()

    local worgenCurseCheckbox = CreateFrame("CheckButton", nil, ctx.bg, "UICheckButtonTemplate")
    worgenCurseCheckbox:SetPoint("TOPLEFT", ctx.bg, "TOPLEFT", 20, -210)
    local worgenCurseLabel = GAC:CreateFontString(ctx.bg, "Maldición Huargen", "GameFontHighlight", { "LEFT", worgenCurseCheckbox, "RIGHT", 5, 0 }, {1, 1, 1})

    worgenCurseCheckbox:SetScript("OnClick", function(self)
        if not GAC.characterData then return end
        GAC.characterData.isWorgenCurse = self:GetChecked()
    end)

    ctx.ui.adaptLabel = adaptLabel
    ctx.ui.adaptDrop = adaptDrop
    ctx.ui.perfLabel = perfLabel
    ctx.ui.perfDrop = perfDrop
    ctx.ui.worgenCurseCheckbox = worgenCurseCheckbox

    local function ProcessDynamicBonus(isMatch, drop, label, isMin, lockedKey, targetKey)
        if not isMatch then
            label:Hide()
            drop:Hide()
            GAC.characterData.characteristics[targetKey] = nil
            GAC.characterData.characteristics[lockedKey] = false
            return
        end
        
        if GAC.characterData.characteristics[lockedKey] and GAC.characterData.characteristics[targetKey] then
            label:Hide()
            drop:Hide()
            return
        end
        
        local talents = GAC.characterData.talents or {}
        local targetVal = isMin and math.huge or -1
        local candidates = {}
        
        for k, v in pairs(talents) do
            local val = tonumber(v) or 0
            if (isMin and val > 0 and val < targetVal) or (not isMin and val > targetVal) then
                targetVal = val
                candidates = {k}
            elseif val == targetVal then
                table.insert(candidates, k)
            end
        end
        
        if isMin and #candidates == 0 then
            for k, _ in pairs(talents) do table.insert(candidates, k) end
        end
        
        if #candidates == 1 then
            GAC.characterData.characteristics[targetKey] = candidates[1]
            label:Hide()
            drop:Hide()
        else
            label:Show()
            drop:Show()
            UIDropDownMenu_Initialize(drop, function(self, level, menuList)
                for _, cand in ipairs(candidates) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = GAC:_(cand) or cand
                    info.func = function()
                        GAC.characterData.characteristics[targetKey] = cand
                        UIDropDownMenu_SetText(drop, info.text)
                        ctx.ui.saveCharBtn:Show()
                        ctx.UpdateRaceSummary(ctx.ui.summary1, ctx.currentRace1)
                        ctx.UpdateRaceSummary(ctx.ui.summary2, ctx.currentRace2)
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end)
            local currentTarget = GAC.characterData.characteristics[targetKey]
            if currentTarget and tContains(candidates, currentTarget) then
                UIDropDownMenu_SetText(drop, GAC:_(currentTarget) or currentTarget)
            else
                UIDropDownMenu_SetText(drop, "Elige un talento...")
            end
        end
    end

    ctx.EvaluateDynamicRacialBonuses = function()
        if not GAC.characterData then return end
        local isHuman = (ctx.currentRace1 == "human" or ctx.currentRace2 == "human")
        local isGnome = (ctx.currentRace1 == "gnome" or ctx.currentRace2 == "gnome")
        
        ProcessDynamicBonus(isHuman, adaptDrop, adaptLabel, true, "adaptLocked", "adaptTarget")
        ProcessDynamicBonus(isGnome, perfDrop, perfLabel, false, "perfLocked", "perfTarget")
        ctx.UpdateDynamicLayout()
    end
end

local function SetupLayoutManager(ctx)
    ctx.UpdateDynamicLayout = function()
        local relativeFrame
        local baseOffset = -20
        if ctx.currentRace2 ~= "Ninguna" then
            ctx.ui.summary1:Hide()
            ctx.ui.summary2:Hide()
            ctx.ui.mestizoBuilderFrame:Show()
            ctx.RefreshMestizoBuilder()
            relativeFrame = ctx.ui.mestizoBuilderFrame
        else
            ctx.ui.mestizoBuilderFrame:Hide()
            if ctx.currentRace1 ~= "Ninguna" then
                ctx.UpdateRaceSummary(ctx.ui.summary1, ctx.currentRace1)
                relativeFrame = ctx.ui.summary1
            else
                ctx.UpdateRaceSummary(ctx.ui.summary1, "Ninguna")
                relativeFrame = ctx.ui.raceDrop1
                baseOffset = -15
            end
            ctx.UpdateRaceSummary(ctx.ui.summary2, "Ninguna")
        end
        
        ctx.ui.adaptLabel:SetPoint("TOPLEFT", relativeFrame, "BOTTOMLEFT", 0, baseOffset)
        ctx.ui.perfLabel:SetPoint("TOPLEFT", relativeFrame, "BOTTOMLEFT", 205, baseOffset)
        ctx.ui.worgenCurseCheckbox:SetPoint("TOPLEFT", ctx.ui.adaptDrop, "BOTTOMLEFT", 5, -20)
        
        local function UpdateScrollHeight()
            if not ctx.bg:GetTop() or not ctx.ui.worgenCurseCheckbox:GetBottom() then
                C_Timer.After(0.05, UpdateScrollHeight)
                return
            end
            local neededHeight = ctx.bg:GetTop() - ctx.ui.worgenCurseCheckbox:GetBottom() + 30
            ctx.bg:SetHeight(math.max(neededHeight, ctx.scroll:GetHeight()))
        end
        UpdateScrollHeight()
    end
end

-------------------------------------------------------------------------------
-- Función Principal
-------------------------------------------------------------------------------
function GAC.Components.MainMenu:CreateCharacteristicsTab(tab, mainFrame)
    local scroll, bg = GAC.Components.MainMenu:CreateScrollableTab(tab, 450, 500)
    GAC.characterData.characteristics = GAC.characterData.characteristics or {}
    
    local ctx = {
        tab = tab,
        mainFrame = mainFrame,
        scroll = scroll,
        bg = bg,
        currentRace1 = GAC.characterData.characteristics.race1 or "Ninguna",
        currentRace2 = GAC.characterData.characteristics.race2 or "Ninguna",
        ui = {}
    }

    BuildSaveButton(ctx)
    BuildRaceDropdowns(ctx)
    BuildRaceSummaries(ctx)
    BuildMestizoBuilder(ctx)
    BuildDynamicBonuses(ctx)
    SetupLayoutManager(ctx)
    
    ctx.UpdateDynamicLayout()

    if ctx.currentRace1 == "Ninguna" then
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
