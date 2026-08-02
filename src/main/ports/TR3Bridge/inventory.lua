--- @module TR3Bridge.inventory
--- Port bridge for interacting with TRP3 Extended inventory database and equipped items.

local addonName, GAC = ...
GAC = GAC or {}
GAC.TR3Bridge = GAC.TR3Bridge or {}

local inventory = {}

--- Returns a list of equipped items matching the ItemsResponse (Item[]) schema.
--- @return table Array of item objects { id, name, icon, quality, description, tooltipLeft, tooltipRight }
function inventory.getEquipedItems()
    local result = {}

    -- Check if TRP3 Extended inventory container is accessible at runtime
    if _G.TRP3_API and _G.TRP3_API.inventory and type(_G.TRP3_API.inventory.getEquippedItems) == "function" then
        local rawItems = _G.TRP3_API.inventory.getEquippedItems()
        if type(rawItems) == "table" then
            for _, rawItem in ipairs(rawItems) do
                if type(rawItem) == "table" then
                    table.insert(result, {
                        id = type(rawItem.id) == "string" and rawItem.id or "",
                        name = type(rawItem.name) == "string" and rawItem.name or "",
                        icon = type(rawItem.icon) == "string" and rawItem.icon or "",
                        quality = type(rawItem.quality) == "string" and rawItem.quality or "",
                        description = type(rawItem.description) == "string" and rawItem.description or "",
                        tooltipLeft = type(rawItem.tooltipLeft) == "string" and rawItem.tooltipLeft or "",
                        tooltipRight = type(rawItem.tooltipRight) == "string" and rawItem.tooltipRight or "",
                    })
                end
            end
        end
    end

    -- Return empty list if no items are equipped
    return result
end

--- Updates an item entry within the TRP3 Extended database.
--- @param itemData table Item data to update
--- @return boolean Success status
function inventory.updateItem(itemData)
    if type(itemData) ~= "table" or not itemData.id then
        return false
    end

    if _G.TRP3_API and _G.TRP3_API.inventory and type(_G.TRP3_API.inventory.updateItem) == "function" then
        return _G.TRP3_API.inventory.updateItem(itemData)
    elseif _G.TRP3_DB and type(_G.TRP3_DB.items) == "table" then
        _G.TRP3_DB.items[itemData.id] = itemData
        return true
    end

    return false
end

GAC.TR3Bridge.inventory = inventory
return inventory
