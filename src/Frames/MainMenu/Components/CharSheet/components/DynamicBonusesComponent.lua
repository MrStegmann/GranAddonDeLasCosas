--- @module Frames.MainMenu.Components.CharSheet.Components.DynamicBonusesComponent
-- Handles dynamic adaptability and perfectionism bonuses along with Worgen Curse option.

local _, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}
GAC.Components.MainMenu.CharSheet = GAC.Components.MainMenu.CharSheet or {}

--- Builds dynamic racial bonus controls and layout manager.
-- @param ctx table
-- @return void
function GAC.Components.MainMenu.CharSheet.BuildDynamicBonuses(ctx)
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
        local isChecked = self:GetChecked()
        GAC.characterData.isWorgenCurse = isChecked
        if GAC.playerCharacter then
            GAC.playerCharacter:SetWorgenCurse(isChecked)
        end
        ctx.ui.saveCharBtn:Show()
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
                        if targetKey == "adaptTarget" then ctx.adaptTarget = cand end
                        if targetKey == "perfTarget" then ctx.perfTarget = cand end
                        UIDropDownMenu_SetText(drop, info.text)
                        ctx.ui.saveCharBtn:Show()
                        ctx.UpdateRaceSummary(ctx.ui.summary1, ctx.currentRaces[1])
                        ctx.UpdateRaceSummary(ctx.ui.summary2, ctx.currentRaces[2])
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
        local isHuman = (ctx.currentRaces[1] == "human" or ctx.currentRaces[2] == "human")
        local isGnome = (ctx.currentRaces[1] == "gnome" or ctx.currentRaces[2] == "gnome")
        
        ProcessDynamicBonus(isHuman, adaptDrop, adaptLabel, true, "adaptLocked", "adaptTarget")
        ProcessDynamicBonus(isGnome, perfDrop, perfLabel, false, "perfLocked", "perfTarget")
        ctx.UpdateDynamicLayout()
    end
end

--- Configures dynamic scroll height layout manager.
-- @param ctx table
-- @return void
function GAC.Components.MainMenu.CharSheet.SetupLayoutManager(ctx)
    ctx.UpdateDynamicLayout = function()
        local relativeFrame
        local baseOffset = -20
        if ctx.currentRaces[2] ~= "Ninguna" then
            ctx.ui.summary1:Hide()
            ctx.ui.summary2:Hide()
            ctx.ui.mestizoBuilderFrame:Show()
            ctx.RefreshMestizoBuilder()
            relativeFrame = ctx.ui.mestizoBuilderFrame
        else
            ctx.ui.mestizoBuilderFrame:Hide()
            if ctx.currentRaces[1] ~= "Ninguna" then
                ctx.UpdateRaceSummary(ctx.ui.summary1, ctx.currentRaces[1])
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
