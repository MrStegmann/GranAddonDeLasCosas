local addonName, addonTable = ...

local CharacterBookController = {}
addonTable.UI.CharacterBook.Controller = CharacterBookController

local Frame = addonTable.UI.CharacterBook.Frame
local Presenter = addonTable.UI.CharacterBook.Presenter

-- API Modules
local LevelAPI = addonTable.API and addonTable.API.LevelPort -- Placeholder, will be required properly
local RaceAPI = addonTable.API and addonTable.API.RacePort

function CharacterBookController.Init()
    Frame.Init()
    local ui = Frame.GetFrame()
    
    -- Setup close behavior
    ui:SetScript("OnHide", CharacterBookController.OnHide)
    
    -- Setup Tab Clicks
    for i, tab in ipairs(ui.tabs) do
        tab:SetScript("OnClick", function()
            CharacterBookController.SelectTab(i)
        end)
    end
    
    -- Load initial data
    CharacterBookController.LoadBasicInfo()
end

function CharacterBookController.SelectTab(tabIndex)
    local ui = Frame.GetFrame()
    PanelTemplates_SetTab(ui, tabIndex)
    
    -- Hide all pages
    for i, page in ipairs(ui.pages) do
        if i == tabIndex then
            page:Show()
        else
            page:Hide()
        end
    end
end

function CharacterBookController.LoadBasicInfo()
    -- Task 3.1: Fetch Name and Class from TRP3
    CharacterBookController.FetchTRP3Data()
    
    -- Task 3.2: Bind LevelDatabase to Category/Level dropdowns
    CharacterBookController.InitCategoryDropdown()
    
    -- Task 3.3: Bind RaceDatabase to Race dropdowns
    CharacterBookController.InitRaceDropdowns()
    
    -- Task 3.5: Worgen Tooltip
    CharacterBookController.SetupWorgenTooltip()
end

function CharacterBookController.FetchTRP3Data()
    local ui = Frame.GetFrame()
    local page = ui.pages[1]
    
    local name = UnitName("player")
    local class = UnitClass("player")
    
    if TRP3_API then
        name = TRP3_API.register.getUnitRPName("player")
        if TRP3_API.register.isUnitKnown("player") then
            local unitID = TRP3_API.utils.str.getUnitID("player")
            local charData = TRP3_API.register.getUnitIDCharacter(unitID)
            if charData and charData.profileID then
                local profile = TRP3_API.profile.getProfileByID(charData.profileID)
                if profile and profile.characteristics and profile.characteristics.CL then
                    class = profile.characteristics.CL
                end
            end
        end
    end
    
    page.nameLabel:SetText("Name: " .. (name or "Unknown"))
    page.classLabel:SetText("Class: " .. (class or "Unknown"))
end

function CharacterBookController.InitCategoryDropdown()
    local ui = Frame.GetFrame()
    local page = ui.pages[1]
    
    UIDropDownMenu_Initialize(page.categoryDropdown, function(self, level, menuList)
        local categories = LevelAPI.GetCategories()
        for _, cat in ipairs(categories) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = cat
            info.func = function()
                UIDropDownMenu_SetSelectedID(page.categoryDropdown, cat)
                UIDropDownMenu_SetText(page.categoryDropdown, cat)
                -- Refresh level dropdown based on new category
                CharacterBookController.InitLevelDropdown(cat)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end

function CharacterBookController.InitLevelDropdown(category)
    local ui = Frame.GetFrame()
    local page = ui.pages[1]
    
    UIDropDownMenu_SetText(page.levelDropdown, "Level")
    
    UIDropDownMenu_Initialize(page.levelDropdown, function(self, level, menuList)
        local levels = LevelAPI.GetLevelsByCategory(category)
        for _, lvl in ipairs(levels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = tostring(lvl)
            info.func = function()
                UIDropDownMenu_SetSelectedID(page.levelDropdown, lvl)
                UIDropDownMenu_SetText(page.levelDropdown, tostring(lvl))
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end

function CharacterBookController.InitRaceDropdowns()
    local ui = Frame.GetFrame()
    local page = ui.pages[1]
    
    local function CreateRaceMenu(dropdown, otherDropdown, isRace1)
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            local races = RaceAPI.GetAllRaces()
            
            -- Add a "None" option for Race 2
            if not isRace1 then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "None"
                info.func = function()
                    UIDropDownMenu_SetSelectedID(dropdown, nil)
                    UIDropDownMenu_SetText(dropdown, "None")
                    CharacterBookController.UpdateTraitsDisplay()
                end
                UIDropDownMenu_AddButton(info)
            end
            
            for raceID, _ in pairs(races) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = raceID
                info.func = function()
                    UIDropDownMenu_SetSelectedID(dropdown, raceID)
                    UIDropDownMenu_SetText(dropdown, raceID)
                    CharacterBookController.UpdateTraitsDisplay()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
    
    CreateRaceMenu(page.race1Dropdown, page.race2Dropdown, true)
    CreateRaceMenu(page.race2Dropdown, page.race1Dropdown, false)
end

function CharacterBookController.UpdateTraitsDisplay()
    local ui = Frame.GetFrame()
    local page = ui.pages[1]
    
    local race1 = UIDropDownMenu_GetSelectedID(page.race1Dropdown)
    local race2 = UIDropDownMenu_GetSelectedID(page.race2Dropdown)
    
    -- Clear previous UI
    page.traitsText:SetText("")
    if page.traitCheckboxes then
        for _, cb in ipairs(page.traitCheckboxes) do
            cb:Hide()
        end
    end
    page.traitCheckboxes = page.traitCheckboxes or {}
    
    if not race1 and not race2 then
        page.traitsText:SetText("Select a race to view traits.")
        return
    end
    
    -- Single race logic
    if (race1 and not race2) or (race2 and not race1) then
        local activeRace = race1 or race2
        local traits = RaceAPI.GetRaceTraits(activeRace)
        if traits then
            local text = "Advantages:\n"
            for k, _ in pairs(traits.positive) do
                text = text .. "- " .. k .. "\n"
            end
            text = text .. "\nDisadvantages:\n"
            for k, _ in pairs(traits.negative) do
                text = text .. "- " .. k .. "\n"
            end
            page.traitsText:SetText(text)
        else
            page.traitsText:SetText("No traits found for this race.")
        end
        return
    end
    
    -- Dual race (Half-race) logic
    page.traitsText:SetText(Presenter.FormatTraitLimits(0, 3, 0, 3))
    
    -- We would normally spawn checkboxes dynamically here.
    -- For simplicity in this specification implementation, we represent it with text.
    -- (A full production version would use an object pool of CheckButtons)
    local traits1 = RaceAPI.GetRaceTraits(race1) or {positive={}, negative={}}
    local traits2 = RaceAPI.GetRaceTraits(race2) or {positive={}, negative={}}
    
    local combinedText = "\n[Half-Race Trait Selection UI]\n"
    combinedText = combinedText .. "Combined Advantages (Select 3):\n"
    for k, _ in pairs(traits1.positive) do combinedText = combinedText .. "[ ] " .. k .. "\n" end
    for k, _ in pairs(traits2.positive) do combinedText = combinedText .. "[ ] " .. k .. "\n" end
    
    combinedText = combinedText .. "\nCombined Disadvantages (Select 3):\n"
    for k, _ in pairs(traits1.negative) do combinedText = combinedText .. "[ ] " .. k .. "\n" end
    for k, _ in pairs(traits2.negative) do combinedText = combinedText .. "[ ] " .. k .. "\n" end
    
    page.traitsText:SetText(page.traitsText:GetText() .. "\n" .. combinedText)
end

function CharacterBookController.SetupWorgenTooltip()
    local ui = Frame.GetFrame()
    local page = ui.pages[1]
    
    page.worgenCheckbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Worgen Curse")
        GameTooltip:AddLine("Applies specific Worgen curse modifiers.", 1, 1, 1, true)
        GameTooltip:AddLine("See WorgenCurseDatabase for specific stat changes.", 0.5, 0.5, 0.5, true)
        GameTooltip:Show()
    end)
    page.worgenCheckbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function CharacterBookController.OnHide()
    -- Handle any cleanup when closed
end
