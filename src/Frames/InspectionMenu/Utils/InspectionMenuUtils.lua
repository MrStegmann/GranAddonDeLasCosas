local addonName, GAC = ...

GAC.Utils = GAC.Utils or {}
GAC.Utils.InspectionMenu = GAC.Utils.InspectionMenu or {}

function GAC.Utils.InspectionMenu:SafeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        print("|cffff0000[GAC Error]|r InspectionMenu: " .. tostring(err))
    end
end

function GAC.Utils.InspectionMenu:SelectTab(tabID)
    local store = GAC.Stores.InspectionMenu
    local frame = GAC.inspectionMenuFrame
    if not frame then return end

    for id, data in pairs(store.Tabs) do
        data.button.indicator:SetShown(false)
        data.button:SetBackdropColor(store.Constants.TAB_INACTIVE_BG_COLOR.r, store.Constants.TAB_INACTIVE_BG_COLOR.g, store.Constants.TAB_INACTIVE_BG_COLOR.b, store.Constants.TAB_INACTIVE_BG_COLOR.a)
        data.button.text:SetTextColor(store.Constants.TEXT_COLOR_WHITE.r, store.Constants.TEXT_COLOR_WHITE.g, store.Constants.TEXT_COLOR_WHITE.b)
        data.content:Hide()
    end
    
    if store.Tabs[tabID] then
        local data = store.Tabs[tabID]
        data.button.indicator:SetShown(true)
        data.button:SetBackdropColor(store.Constants.TAB_ACTIVE_BG_COLOR.r, store.Constants.TAB_ACTIVE_BG_COLOR.g, store.Constants.TAB_ACTIVE_BG_COLOR.b, store.Constants.TAB_ACTIVE_BG_COLOR.a)
        data.button.text:SetTextColor(store.Constants.TEXT_COLOR_RED.r, store.Constants.TEXT_COLOR_RED.g, store.Constants.TEXT_COLOR_RED.b)
        data.content:Show()
        frame.currentTab = tabID
        
        if data.content.Update then
            self:SafeCall(data.content.Update, data.content)
        end
    end
end

function GAC.Utils.InspectionMenu:AddTab(id, label, createFunc, sidebar, contentArea)
    local store = GAC.Stores.InspectionMenu
    local content = createFunc(contentArea)
    content:Hide()

    local btn = GAC.Components.InspectionMenu:CreateTabButton(sidebar, id, label, store.TabCount)
    btn:SetScript("OnClick", function() GAC.Utils.InspectionMenu:SelectTab(id) end)

    store.Tabs[id] = { button = btn, content = content }
    store.TabCount = store.TabCount + 1
end

function GAC.Utils.InspectionMenu:FormatStatList(list)
    if type(list) == "table" then
        local t = {}
        if #list > 0 then
            for _, v in ipairs(list) do
                table.insert(t, GAC:_(v) or v)
            end
        else
            local hasElements = false
            local sortedKeys = {}
            for k in pairs(list) do table.insert(sortedKeys, k) end
            table.sort(sortedKeys)
            for _, k in ipairs(sortedKeys) do
                local v = list[k]
                hasElements = true
                local sign = v > 0 and "+" or ""
                table.insert(t, sign .. v .. " " .. (GAC:_(k) or k))
            end
            if not hasElements then return "Ninguna" end
        end
        return table.concat(t, ", ")
    end
    return "Ninguna"
end
