local addonName, GAC = ...

GAC.Screens = GAC.Screens or {}
GAC.Screens.InitiativeOrders = {}

function GAC.Screens.InitiativeOrders:CreateMainFrame()
    local c = GAC.Stores.InitiativeOrders.Constants
    local anchor, relAnchor, x, y = GAC.Utils.InitiativeOrders:EnsureFramePosition()
    
    local frame = CreateFrame("Frame", "GACInitiativeFrame", UIParent, "BackdropTemplate")
    frame:SetSize(c.FRAME_WIDTH, 300)
    frame:SetPoint(anchor, UIParent, relAnchor, x, y)
    
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(c.BACKGROUND_COLOR.r, c.BACKGROUND_COLOR.g, c.BACKGROUND_COLOR.b, c.BACKGROUND_COLOR.a)
    frame:SetBackdropBorderColor(c.BORDER_COLOR.r, c.BORDER_COLOR.g, c.BORDER_COLOR.b, c.BORDER_COLOR.a)
    frame:SetMovable(true)
    GAC:SetClampedWithVisiblePixels(frame, 20)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        GAC.Utils.InitiativeOrders:SaveFramePosition(s)
    end)
    
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("Orden de Turnos")
    
    local scrollFrame = CreateFrame("ScrollFrame", "GACInitiativeScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    frame.scrollFrame = scrollFrame
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(c.FRAME_WIDTH - 40, c.MAX_ROWS * c.ROW_HEIGHT)
    scrollFrame:SetScrollChild(scrollChild)
    
    local contextMenu = CreateFrame("Frame", "GACInitiativeContextMenu", frame, "UIDropDownMenuTemplate")
    GAC.Components.InitiativeOrders:InitContextMenu(contextMenu)
    
    frame.rows = {}
    local prevRow = nil
    for i = 1, c.MAX_ROWS do
        local row = GAC:CreateInitiativeRow(scrollChild, c.FRAME_WIDTH - 40, c.ROW_HEIGHT, i, contextMenu, prevRow)
        table.insert(frame.rows, row)
        prevRow = row
    end
    
    local dropdown = CreateFrame("Frame", "GACInitiativeHistoryDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("BOTTOM", frame, "BOTTOM", 0, 7)
    GAC.Components.InitiativeOrders:InitHistoryDropdown(dropdown, frame)
    frame.dropdown = dropdown
    
    frame.sortBtn = GAC.Components.InitiativeOrders:CreateSortButton(frame)
    frame.loadBtn = GAC.Components.InitiativeOrders:CreateLoadButton(frame, dropdown)
    frame.clearBtn = GAC.Components.InitiativeOrders:CreateClearButton(frame, dropdown)
    frame.minimizeBtn = GAC.Components.InitiativeOrders:CreateMinimizeButton(frame)
    
    frame.UpdateButtonVisibility = function()
        GAC.Utils.InitiativeOrders:UpdateButtonVisibility(frame, GAC.Utils.InitiativeOrders:GetMinimizedState())
    end

    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("PARTY_LEADER_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(self, event)
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            if IsInGroup() or IsInRaid() then
                self:Show()
            else
                self:Hide()
                GAC:ClearInitiativeOrder()
            end
        end
        self.UpdateButtonVisibility()
    end)
    
    if IsInGroup() or IsInRaid() then
        frame:Show()
    else
        frame:Hide()
    end
    
    frame.UpdateButtonVisibility()
    GAC.Utils.InitiativeOrders:ApplyMinimizedState(frame, GAC.Utils.InitiativeOrders:GetMinimizedState())
    
    return frame
end


function GAC:UpdateInitiativeFrame()
    if not self.initiativeFrame then return end
    local rows = self.initiativeFrame.rows
    
    local dataList = self.initiativeOrder
    if self.activeInitiativeView ~= "current" and self.characterData and self.characterData.initiativeHistory then
        local hist = self.characterData.initiativeHistory[self.activeInitiativeView]
        if hist and hist.rolls then
            dataList = hist.rolls
        end
    end
    
    for i, row in ipairs(rows) do
        local data = dataList[i]
        if data then
            row.text:SetText(data.name)
            row.val:SetText(data.total)
            if data.icon and data.icon > 0 then
                SetRaidTargetIconTexture(row.icon, data.icon)
                row.icon:Show()
            else
                row.icon:Hide()
            end
            row:Show()
        else
            row:Hide()
        end
    end
end
