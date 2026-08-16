local addonName, addonTable = ...

local CharacterBookFrame = {}
addonTable.UI = addonTable.UI or {}
addonTable.UI.CharacterBook = addonTable.UI.CharacterBook or {}
addonTable.UI.CharacterBook.Frame = CharacterBookFrame

local frame = nil

function CharacterBookFrame.Init()
    if frame then return end
    
    -- Main Window Frame
    frame = CreateFrame("Frame", "GAC_CharacterBookFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(800, 600)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:Hide()
    
    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.title:SetText("GAC - Character Book")
    
    -- Enable dragging
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Close Button (handled by BasicFrameTemplate)
    
    -- Navigation Bar (Tabs)
    CharacterBookFrame.CreateNavigationBar()
    
    -- Sub-Frames (Content Areas)
    CharacterBookFrame.CreateContentAreas()
end

function CharacterBookFrame.CreateNavigationBar()
    local tabs = {
        "Basic Info",
        "Attributes",
        "Talent Tree",
        "Traits",
        "Heroics",
        "Spells",
        "Skills"
    }
    
    frame.tabs = {}
    
    for i, tabName in ipairs(tabs) do
        local tab = CreateFrame("Button", "GAC_CharacterBookFrameTab" .. i, frame, "CharacterFrameTabButtonTemplate")
        if i == 1 then
            tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 10, 2)
        else
            tab:SetPoint("LEFT", frame.tabs[i-1], "RIGHT", -15, 0)
        end
        tab:SetID(i)
        tab:SetText(tabName)
        PanelTemplates_TabResize(tab, 0)
        frame.tabs[i] = tab
    end
    
    -- Select tab 1 by default
    PanelTemplates_SetNumTabs(frame, #tabs)
    PanelTemplates_SetTab(frame, 1)
end

function CharacterBookFrame.CreateContentAreas()
    -- Content container inside the inset
    frame.content = CreateFrame("Frame", nil, frame)
    frame.content:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -65)
    frame.content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 30)
    
    frame.pages = {}
    
    for i = 1, 7 do
        local page = CreateFrame("Frame", nil, frame.content)
        page:SetAllPoints()
        page:Hide()
        frame.pages[i] = page
    end
    
    -- Default page
    frame.pages[1]:Show()
    
    CharacterBookFrame.CreateBasicInfoUI()
end

function CharacterBookFrame.CreateBasicInfoUI()
    local page = frame.pages[1]
    
    -- Name Label
    page.nameLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    page.nameLabel:SetPoint("TOPLEFT", page, "TOPLEFT", 20, -20)
    page.nameLabel:SetText("Name: Unknown")
    
    -- Class Label
    page.classLabel = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.classLabel:SetPoint("TOPLEFT", page.nameLabel, "BOTTOMLEFT", 0, -10)
    page.classLabel:SetText("Class: Unknown")
    
    -- Category Dropdown
    page.categoryDropdown = CreateFrame("Frame", "GAC_CharacterBookCategoryDropdown", page, "UIDropDownMenuTemplate")
    page.categoryDropdown:SetPoint("TOPLEFT", page.classLabel, "BOTTOMLEFT", -15, -20)
    UIDropDownMenu_SetWidth(page.categoryDropdown, 120)
    UIDropDownMenu_SetText(page.categoryDropdown, "Select Category")
    
    -- Level Dropdown
    page.levelDropdown = CreateFrame("Frame", "GAC_CharacterBookLevelDropdown", page, "UIDropDownMenuTemplate")
    page.levelDropdown:SetPoint("LEFT", page.categoryDropdown, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(page.levelDropdown, 80)
    UIDropDownMenu_SetText(page.levelDropdown, "Level")
    
    -- Race 1 Dropdown
    page.race1Dropdown = CreateFrame("Frame", "GAC_CharacterBookRace1Dropdown", page, "UIDropDownMenuTemplate")
    page.race1Dropdown:SetPoint("TOPLEFT", page.categoryDropdown, "BOTTOMLEFT", 0, -20)
    UIDropDownMenu_SetWidth(page.race1Dropdown, 150)
    UIDropDownMenu_SetText(page.race1Dropdown, "Select Race 1")
    
    -- Race 2 Dropdown (Half-race)
    page.race2Dropdown = CreateFrame("Frame", "GAC_CharacterBookRace2Dropdown", page, "UIDropDownMenuTemplate")
    page.race2Dropdown:SetPoint("LEFT", page.race1Dropdown, "RIGHT", 10, 0)
    UIDropDownMenu_SetWidth(page.race2Dropdown, 150)
    UIDropDownMenu_SetText(page.race2Dropdown, "Select Race 2 (Optional)")
    
    -- Worgen Curse Checkbox
    page.worgenCheckbox = CreateFrame("CheckButton", "GAC_CharacterBookWorgenCheck", page, "ChatConfigCheckButtonTemplate")
    page.worgenCheckbox:SetPoint("TOPLEFT", page.race1Dropdown, "BOTTOMLEFT", 15, -20)
    _G[page.worgenCheckbox:GetName() .. "Text"]:SetText("Worgen Curse")
    
    -- Traits Display Area
    page.traitsFrame = CreateFrame("Frame", nil, page, "BackdropTemplate")
    page.traitsFrame:SetPoint("TOPLEFT", page.worgenCheckbox, "BOTTOMLEFT", -15, -20)
    page.traitsFrame:SetSize(400, 200)
    
    page.traitsText = page.traitsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.traitsText:SetPoint("TOPLEFT", page.traitsFrame, "TOPLEFT", 10, -10)
    page.traitsText:SetWidth(380)
    page.traitsText:SetJustifyH("LEFT")
    page.traitsText:SetJustifyV("TOP")
    page.traitsText:SetText("Traits will appear here...")
end

function CharacterBookFrame.GetFrame()
    return frame
end

function CharacterBookFrame.Show()
    if frame then frame:Show() end
end

function CharacterBookFrame.Hide()
    if frame then frame:Hide() end
end

function CharacterBookFrame.Toggle()
    if frame then
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
end
