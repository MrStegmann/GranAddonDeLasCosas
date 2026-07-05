local addonName, GAC = ...

GAC.Utils = GAC.Utils or {}
GAC.Utils.MainMenu = {}

-- SafeCall is required by GEMINI.md
local function SafeCall(func, ...)
    if type(func) == "function" then
        local success, err = pcall(func, ...)
        if not success then
            print("|cffff0000[GAC Error]|r " .. tostring(err))
        end
        return success
    end
    return false
end

function GAC.Utils.MainMenu:SelectTab(tabID)
    local store = GAC.Stores.MainMenu
    local consts = store.Constants
    local tabs = store.Tabs

    -- Ocultamos todas
    for id, data in pairs(tabs) do
        data.button.indicator:SetShown(false)
        data.button:SetBackdropColor(0, 0, 0, 0)
        data.button.text:SetTextColor(consts.TAB_INACTIVE_TEXT_COLOR.r, consts.TAB_INACTIVE_TEXT_COLOR.g, consts.TAB_INACTIVE_TEXT_COLOR.b)
        data.content:Hide()
    end
    
    -- Mostramos la seleccionada
    if tabs[tabID] then
        local data = tabs[tabID]
        data.button.indicator:SetShown(true)
        data.button:SetBackdropColor(consts.TAB_ACTIVE_BG_COLOR.r, consts.TAB_ACTIVE_BG_COLOR.g, consts.TAB_ACTIVE_BG_COLOR.b, consts.TAB_ACTIVE_BG_COLOR.a)
        data.button.text:SetTextColor(consts.TAB_ACTIVE_TEXT_COLOR.r, consts.TAB_ACTIVE_TEXT_COLOR.g, consts.TAB_ACTIVE_TEXT_COLOR.b)
        data.content:Show()
        
        -- Llamamos a Update de forma segura
        if data.content.Update then
            SafeCall(data.content.Update, data.content)
        end
        
        store.ActiveTab = tabID
    end
end

function GAC.Utils.MainMenu:SavePosition(frame)
    local pos = GAC.characterData.ui.mainMenu
    if not pos then return end
    local a, _, ra, ox, oy = frame:GetPoint(1)
    ra = ra or a
    pos.anchor = a
    pos.relativeAnchor = ra
    pos.x = math.floor(ox + 0.5)
    pos.y = math.floor(oy + 0.5)
end

function GAC.Utils.MainMenu:AddTab(id, label, createFunc, sidebar, contentArea)
    local store = GAC.Stores.MainMenu
    
    local content = createFunc(contentArea)
    content:Hide()

    local btn = GAC.Components.MainMenu:CreateTabButton(sidebar, id, label, store.TabCount)
    btn:SetScript("OnClick", function() GAC.Utils.MainMenu:SelectTab(id) end)

    store.Tabs[id] = { button = btn, content = content }
    store.TabCount = store.TabCount + 1
end

function GAC.Utils.MainMenu:MergeRaceTraits(racesArray)
    local allAdv = {}
    local allDis = {}
    local allSpec = {}
    
    local function AddToDict(targetDict, sourceDict)
        if not sourceDict then return end
        for k, v in pairs(sourceDict) do targetDict[k] = v end
    end
    
    local function AddToList(targetList, sourceList)
        if not sourceList then return end
        for _, v in ipairs(sourceList) do
            if not tContains(targetList, v) then table.insert(targetList, v) end
        end
    end

    if type(racesArray) == "table" then
        for _, raceName in ipairs(racesArray) do
            if raceName and raceName ~= "Ninguna" then
                local data = GAC:GetRaceData(raceName)
                if data then
                    AddToDict(allAdv, data.advantages)
                    AddToDict(allDis, data.disadvantages)
                    AddToList(allSpec, data.special)
                end
            end
        end
    end
    
    return allAdv, allDis, allSpec
end

