--- @module Frames.MainMenu.Components.CharSheet.Components.TraitCardComponent
-- Card UI component for selecting positive trait levels.

local _, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}
GAC.Components.MainMenu.CharSheet = GAC.Components.MainMenu.CharSheet or {}

--- Creates an interactive card for a positive trait.
-- @param parent Frame Parent container frame
-- @param traitData table Trait data table from GAC.PositiveTraits
-- @param ctx table UI Context table containing selectedTraits, maxPoints, and callbacks
-- @return Frame Created trait card frame
function GAC.Components.MainMenu.CharSheet.CreateTraitCard(parent, traitData, ctx)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    card:SetBackdropColor(0, 0, 0, 0.4)
    card:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.4)

    -- Header Title
    local title = GAC:CreateFontString(card, traitData.label or traitData.name, "GameFontNormalLarge", { "TOPLEFT", 10, -8 }, { 0.25, 0.78, 0.94 })

    -- Description
    local desc = GAC:CreateFontString(card, traitData.description or "", "GameFontHighlightSmall", { "TOPLEFT", title, "BOTTOMLEFT", 0, -4 }, { 0.8, 0.8, 0.8 })
    desc:SetWidth(400)
    desc:SetJustifyH("LEFT")
    desc:SetJustifyV("TOP")

    -- Determine max level supported by this trait
    local maxSupportedLevel = 1
    if traitData.level3 then
        maxSupportedLevel = 3
    elseif traitData.level2 then
        maxSupportedLevel = 2
    end

    -- Container for level buttons
    local buttonContainer = CreateFrame("Frame", nil, card)
    buttonContainer:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)
    buttonContainer:SetSize(400, 24)

    local levelButtons = {}

    local function RefreshButtons()
        local currentLevel = ctx.selectedTraits[traitData.name] or 0
        local totalSpent = ctx.GetTotalSpentPoints()

        for level = 0, maxSupportedLevel do
            local btn = levelButtons[level]
            if btn then
                local isCurrent = (currentLevel == level)
                if isCurrent then
                    btn:LockHighlight()
                    if type(btn.SetBackdropBorderColor) == "function" then
                        btn:SetBackdropBorderColor(0.25, 0.78, 0.94, 1)
                    end
                else
                    btn:UnlockHighlight()
                    if type(btn.SetBackdropBorderColor) == "function" then
                        btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.4)
                    end
                end

                if level > 0 then
                    local costDiff = level - currentLevel
                    local canAfford = (totalSpent + costDiff <= ctx.maxPoints)
                    if not canAfford and not isCurrent then
                        if btn.Disable then btn:Disable() end
                        btn:SetAlpha(0.5)
                    else
                        if btn.Enable then btn:Enable() end
                        btn:SetAlpha(1.0)
                    end
                end
            end
        end
    end

    local function OnLevelClicked(targetLevel)
        local currentLevel = ctx.selectedTraits[traitData.name] or 0
        if currentLevel == targetLevel then return end

        local costDiff = targetLevel - currentLevel
        local totalSpent = ctx.GetTotalSpentPoints()

        if targetLevel > 0 and (totalSpent + costDiff > ctx.maxPoints) then
            print(string.format("|cFFFF4444[GAC]|r: No tienes suficientes puntos de rasgos disponibles (Máximo: %d).", ctx.maxPoints))
            return
        end

        if targetLevel > 0 then
            ctx.selectedTraits[traitData.name] = targetLevel
        else
            ctx.selectedTraits[traitData.name] = nil
        end

        if ctx.ui.saveCharBtn then ctx.ui.saveCharBtn:Show() end
        if ctx.OnTraitsUpdated then ctx.OnTraitsUpdated() end
    end

    -- Create Level 0 (None) button
    local btn0 = GAC:CreateButton(buttonContainer, "0", {35, 20}, {"TOPLEFT", 0, 0}, false)
    btn0:SetScript("OnClick", function() OnLevelClicked(0) end)
    levelButtons[0] = btn0

    local lastBtn = btn0
    for level = 1, maxSupportedLevel do
        local btnText = string.format("Lvl %d (%dp)", level, level)
        local btn = GAC:CreateButton(buttonContainer, btnText, {75, 20}, {"LEFT", lastBtn, "RIGHT", 6, 0}, false)
        btn:SetScript("OnClick", function() OnLevelClicked(level) end)
        levelButtons[level] = btn
        lastBtn = btn
    end

    card.Refresh = RefreshButtons
    RefreshButtons()

    local descHeight = desc:GetStringHeight() or 20
    card:SetHeight(12 + title:GetStringHeight() + descHeight + 35)

    return card
end
