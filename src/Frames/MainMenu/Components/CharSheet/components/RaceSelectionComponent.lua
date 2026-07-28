--- @module Frames.MainMenu.Components.CharSheet.Components.RaceSelectionComponent
-- Race dropdowns, summaries, and mestizo trait selection builder.

local _, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}
GAC.Components.MainMenu.CharSheet = GAC.Components.MainMenu.CharSheet or {}

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

--- Builds primary and secondary race selection dropdowns.
-- @param ctx table
-- @return void
function GAC.Components.MainMenu.CharSheet.BuildRaceDropdowns(ctx)
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

    local function InitializeRaceDropdown(dropdown, getIndex, isSecondary, onChange)
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            info.text = "Ninguna"
            info.func = function()
                if ctx.currentRaces[getIndex] ~= "Ninguna" then ctx.ui.saveCharBtn:Show() end
                onChange("Ninguna")
                UIDropDownMenu_SetText(dropdown, info.text)
                ctx.UpdateDynamicLayout()
                if ctx.mainFrame.UpdateHeaderInfoText then
                    ctx.mainFrame:UpdateHeaderInfoText(ctx.currentRaces[1], ctx.currentRaces[2])
                end
            end
            UIDropDownMenu_AddButton(info)

            local currentAvailableRaces = GAC:GetFlatRaces()
            for _, raceName in ipairs(currentAvailableRaces) do
                local infoRace = UIDropDownMenu_CreateInfo()
                infoRace.text = GAC:_(raceName) or raceName
                infoRace.func = function()
                    if ctx.currentRaces[getIndex] ~= raceName then ctx.ui.saveCharBtn:Show() end
                    onChange(raceName)
                    UIDropDownMenu_SetText(dropdown, infoRace.text)
                    ctx.EvaluateDynamicRacialBonuses()
                    ctx.UpdateDynamicLayout()
                    if ctx.mainFrame.UpdateHeaderInfoText then
                        ctx.mainFrame:UpdateHeaderInfoText(ctx.currentRaces[1], ctx.currentRaces[2])
                    end
                end
                UIDropDownMenu_AddButton(infoRace)
            end
        end)
    end

    InitializeRaceDropdown(raceDrop1, 1, false, function(newVal)
        ctx.currentRaces[1] = newVal
        if newVal == "Ninguna" then
            ctx.currentRaces[2] = "Ninguna"
            UIDropDownMenu_SetText(raceDrop2, "Ninguna")
            UIDropDownMenu_DisableDropDown(raceDrop2)
        else
            UIDropDownMenu_EnableDropDown(raceDrop2)
        end
    end)
    UIDropDownMenu_SetText(raceDrop1, GAC:_(ctx.currentRaces[1]) or ctx.currentRaces[1])
    
    InitializeRaceDropdown(raceDrop2, 2, true, function(newVal)
        ctx.currentRaces[2] = newVal
    end)
    UIDropDownMenu_SetText(raceDrop2, GAC:_(ctx.currentRaces[2]) or ctx.currentRaces[2])
end

--- Builds summary frames for chosen races.
-- @param ctx table
-- @return void
function GAC.Components.MainMenu.CharSheet.BuildRaceSummaries(ctx)
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

--- Builds mestizo trait selection builder interface.
-- @param ctx table
-- @return void
function GAC.Components.MainMenu.CharSheet.BuildMestizoBuilder(ctx)
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
        if ctx.currentRaces[1] == "Ninguna" or ctx.currentRaces[2] == "Ninguna" then return end

        local allAdv, allDis, allSpec = GAC.Utils.MainMenu:MergeRaceTraits(ctx.currentRaces)
        ctx.mestizoTraits = ctx.mestizoTraits or {}
        local mestizoTraits = ctx.mestizoTraits
        
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
