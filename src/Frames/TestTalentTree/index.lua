local addonName, GAC = ...
print("Test Talent Tree Index Loaded")
-- Mock Icons for generic grid of spells
local MOCK_ICONS = {
    "Interface\\Icons\\Spell_Fire_Fireball",
    "Interface\\Icons\\Spell_Frost_FrostBolt",
    "Interface\\Icons\\Spell_Nature_Lightning",
    "Interface\\Icons\\Spell_Holy_HolyBolt",
    "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    "Interface\\Icons\\Ability_Warrior_Charge",
    "Interface\\Icons\\Ability_Rogue_Eviscerate",
    "Interface\\Icons\\Spell_Nature_HealingTouch",
    "Interface\\Icons\\Spell_Holy_FlashHeal",
    "Interface\\Icons\\Spell_Nature_Rejuvenation",
    "Interface\\Icons\\Spell_Fire_FlameShock",
    "Interface\\Icons\\Spell_Frost_FrostNova"
}

local function UpdateTalentGrid(tabID)
    local scrollChild = GACTestTalentTreeFrameScrollFrameScrollChild
    
    -- Hide all existing buttons
    if not GACTestTalentTreeFrame.talentButtons then
        GACTestTalentTreeFrame.talentButtons = {}
    end
    for _, btn in ipairs(GACTestTalentTreeFrame.talentButtons) do
        btn:Hide()
    end
    
    -- Generate mock talents in a generic grid based on tabID
    local numCols = 4
    local numRows = 7
    local iconSize = 38
    local spacingX = 40
    local spacingY = 40
    local startX = 20
    local startY = -20
    
    local buttonIndex = 1
    
    for row = 1, numRows do
        for col = 1, numCols do
            -- Pseudo random to have some empty slots but distinct for each tab
            local shouldShow = ((row + col * 3 + tabID * 5) % 3) ~= 0
            
            if shouldShow then
                local btn = GACTestTalentTreeFrame.talentButtons[buttonIndex]
                if not btn then
                    btn = CreateFrame("Button", "GACTestTalentButton"..buttonIndex, scrollChild, "ActionButtonTemplate")
                    btn:SetSize(iconSize, iconSize)
                    table.insert(GACTestTalentTreeFrame.talentButtons, btn)
                end
                
                local iconIndex = ((row * col + tabID) % #MOCK_ICONS) + 1
                btn.icon:SetTexture(MOCK_ICONS[iconIndex])
                btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Zoom slightly to remove borders
                
                -- Simulate talent border by adding a normal texture if missing
                if not btn:GetNormalTexture() then
                    btn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
                end
                
                btn:SetPoint("TOPLEFT", startX + (col - 1) * (iconSize + spacingX), startY - (row - 1) * (iconSize + spacingY))
                btn:Show()
                
                buttonIndex = buttonIndex + 1
            end
        end
    end
end

local function SelectTab(id)
    PanelTemplates_SetTab(GACTestTalentTreeFrame, id)
    GAC:SafeCall(UpdateTalentGrid, id)
end

GACTestTalentTreeFrame:SetScript("OnShow", function(self)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    if not self.initialized then
        PanelTemplates_SetNumTabs(self, 3)
        
        -- Hook tabs
        GACTestTalentTreeFrameTab1:SetScript("OnClick", function() SelectTab(1) end)
        GACTestTalentTreeFrameTab2:SetScript("OnClick", function() SelectTab(2) end)
        GACTestTalentTreeFrameTab3:SetScript("OnClick", function() SelectTab(3) end)
        
        GACTestTalentTreeFrameTab1:SetText("Tree 1")
        GACTestTalentTreeFrameTab2:SetText("Tree 2")
        GACTestTalentTreeFrameTab3:SetText("Tree 3")
        PanelTemplates_TabResize(GACTestTalentTreeFrameTab1, 0)
        PanelTemplates_TabResize(GACTestTalentTreeFrameTab2, 0)
        PanelTemplates_TabResize(GACTestTalentTreeFrameTab3, 0)
        
        SelectTab(1)
        self.initialized = true
    end
end)

GACTestTalentTreeFrame:SetScript("OnHide", function(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end)

-- Slash command
SLASH_GACTESTTALENTTREE1 = "/testtalenttree"
SlashCmdList["GACTESTTALENTTREE"] = function()
    if GACTestTalentTreeFrame:IsShown() then
        GACTestTalentTreeFrame:Hide()
    else
        GACTestTalentTreeFrame:Show()
    end
end
