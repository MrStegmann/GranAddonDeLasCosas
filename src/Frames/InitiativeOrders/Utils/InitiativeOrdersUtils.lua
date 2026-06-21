local addonName, GAC = ...

GAC.Utils = GAC.Utils or {}
GAC.Utils.InitiativeOrders = {}

function GAC.Utils.InitiativeOrders:EnsureFramePosition()
    if not GAC.characterData then return end
    if not GAC.characterData.ui then GAC.characterData.ui = {} end
    if not GAC.characterData.ui.initiativeFrame then GAC.characterData.ui.initiativeFrame = {} end
    
    local pos = GAC.characterData.ui.initiativeFrame
    local c = GAC.Stores.InitiativeOrders.Constants
    local anchor, relAnchor, x, y = c.DEFAULT_ANCHOR, c.DEFAULT_REL_ANCHOR, c.DEFAULT_X, c.DEFAULT_Y
    if pos.anchor then
        anchor, relAnchor = pos.anchor, pos.relativeAnchor or pos.anchor
        x, y = tonumber(pos.x) or x, tonumber(pos.y) or y
    end
    return anchor, relAnchor, x, y
end

function GAC.Utils.InitiativeOrders:SaveFramePosition(frame)
    local a, _, ra, ox, oy = frame:GetPoint(1)
    if not GAC.characterData then return end
    if not GAC.characterData.ui then GAC.characterData.ui = {} end
    if not GAC.characterData.ui.initiativeFrame then GAC.characterData.ui.initiativeFrame = {} end
    ra = ra or a
    GAC.characterData.ui.initiativeFrame.anchor = a
    GAC.characterData.ui.initiativeFrame.relativeAnchor = ra
    GAC.characterData.ui.initiativeFrame.x = math.floor(ox + 0.5)
    GAC.characterData.ui.initiativeFrame.y = math.floor(oy + 0.5)
end

function GAC.Utils.InitiativeOrders:GetMinimizedState()
    local isMinimized = false
    if GAC.characterData and GAC.characterData.ui and GAC.characterData.ui.initiativeFrame then
        if GAC.characterData.ui.initiativeFrame.isMinimized ~= nil then
            isMinimized = GAC.characterData.ui.initiativeFrame.isMinimized
        end
    end
    return isMinimized
end

function GAC.Utils.InitiativeOrders:SetMinimizedState(isMinimized)
    if GAC.characterData then
        if not GAC.characterData.ui then GAC.characterData.ui = {} end
        if not GAC.characterData.ui.initiativeFrame then GAC.characterData.ui.initiativeFrame = {} end
        GAC.characterData.ui.initiativeFrame.isMinimized = isMinimized
    end
end

function GAC.Utils.InitiativeOrders:ApplyMinimizedState(frame, isMinimized)
    if not frame then return end
    if isMinimized then
        frame:SetHeight(30)
        if frame.scrollFrame then frame.scrollFrame:Hide() end
        if frame.sortBtn then frame.sortBtn:Hide() end
        if frame.loadBtn then frame.loadBtn:Hide() end
        if frame.clearBtn then frame.clearBtn:Hide() end
        if frame.dropdown then frame.dropdown:Hide() end
        if frame.minimizeBtn then
            frame.minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up")
            frame.minimizeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Down")
        end
    else
        frame:SetHeight(300)
        if frame.scrollFrame then frame.scrollFrame:Show() end
        if frame.minimizeBtn then
            frame.minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up")
            frame.minimizeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Down")
        end
        if frame.UpdateButtonVisibility then frame.UpdateButtonVisibility() end
    end
end

function GAC.Utils.InitiativeOrders:UpdateButtonVisibility(frame, isMinimized)
    if not frame then return end
    if isMinimized then return end
    if IsInGroup() and not UnitIsGroupLeader("player") then
        if frame.sortBtn then frame.sortBtn:Hide() end
        if frame.loadBtn then frame.loadBtn:Hide() end
        if frame.clearBtn then frame.clearBtn:Hide() end
        if frame.dropdown then frame.dropdown:Hide() end
    else
        if GAC.activeInitiativeView == "current" then 
            if frame.sortBtn then frame.sortBtn:Show() end
            if frame.loadBtn then frame.loadBtn:Hide() end
        else
            if frame.sortBtn then frame.sortBtn:Hide() end
            if frame.loadBtn then frame.loadBtn:Show() end
        end
        if frame.clearBtn then frame.clearBtn:Show() end
        if frame.dropdown then frame.dropdown:Show() end
    end
end
