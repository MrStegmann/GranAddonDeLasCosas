---
name: trp3-extended-api-integration
description: Query character profiles, characteristics, and inventory item data from Total RP 3 and Total RP 3 Extended APIs. Use when you are connecting to Total RP 3 or Total RP 3 Extended APIs to query character profile characteristics, names, titles, or inspect equipped items.
---

# Skill: Total RP 3 & Extended API Integration

## Objective
Query character identity data, roleplay characteristics, and inventory items from Total RP 3 (`TRP3_API`) and Total RP 3 Extended (`TRP3_API.inventory`) while safely providing fallback defaults when TRP3 is missing or disabled.

---

## Documented Inputs
- **`unit`** (string): Target WoW unit ID (e.g. `"player"`, `"target"`, `"party1"`).
- **`unitID`** (string): Normalized character name identifier (e.g. `"Einarr-Epsilon"`).
- **`profileID`** (optional string): Specific TRP3 profile string ID.
- **`classID`** (optional string): TRP3 Extended item class ID.
- **`container`** (optional table): TRP3 Extended container object.

---

## Scanned API Surface Reference

### 1. Total RP 3 Core Profile & Register APIs (`totalRP3`)
- **`TRP3_API.profile.getData(path, profile)`**: Fetches structured profile fields (e.g. `"player/characteristics"`, `"player/about"`).
- **`TRP3_API.profile.getPlayerCurrentProfile()`**: Returns local player's active TRP3 profile table.
- **`TRP3_API.profile.getPlayerCurrentProfileID()`**: Returns local player's active profile string ID.
- **`TRP3_API.register.getUnitID(unit)`**: Normalizes unit string to full character name (e.g. `"target"` -> `"Vrykingul-Epsilon"`).
- **`TRP3_API.register.getCompleteName(profileData, fallbackName, useTitle)`**: Generates complete character title and full name string.
- **`TRP3_API.register.hasProfile(unitID)`**: Returns `true` if a target unit has a cached TRP3 profile.
- **`TRP3_API.register.getUnitData(unitID)`**: Retrieves remote inspected player profile data.

### 2. Total RP 3 Extended Inventory APIs (`totalRP3_Extended`)
- **`TRP3_API.inventory.getInventory(profileID)`**: Returns the main inventory container table.
- **`TRP3_API.inventory.getItemCount(classID, container)`**: Returns total item count of a specific item class in container.
- **`TRP3_API.inventory.getContainerWeight(container)`**: Returns total weight of container items.
- **`TRP3_API.inventory.getItemLink(itemClass, instanceID)`**: Generates clickable item link string.
- **`TRP3_API.inventory.getQualityColor(quality)`**: Returns hexadecimal color code for item quality level.

### 3. TRP3 Event Bus (`TRP3_API.events`)
- **`TRP3_API.events.registerHandler(eventName, handlerFunc)`**: Listens for internal TRP3 events (e.g. `REGISTER_DATA_UPDATED`, `EVENT_REFRESH_BAG`).
- **`TRP3_API.events.fireEvent(eventName, ...)`**: Triggers internal TRP3 event broadcast.

---

## Explicit and Verifiable Acceptance Criteria
- [ ] Returns valid character profile names, titles, and characteristics when TRP3 is active.
- [ ] Returns safe default fallback values (e.g. `"Unknown Hero"`, `{}`) cleanly without raising Lua runtime errors when `TRP3_API` is `nil`.
- [ ] Correctly queries custom TRP3 Extended inventory items, item counts, and quality hex colors when TRP3 Extended is enabled.
- [ ] Encapsulates all TRP3 client calls strictly within adapter/bridge ports (`src/main/ports/TR3Bridge/`), leaving domain models 100% pure.

---

## How to Use & Examples

### Example 1: Querying Character Full Name & Title (Characteristics Bridge)
```lua
local function GetTRP3CharacterIdentity(unit)
    if not _G.TRP3_API or not _G.TRP3_API.profile then
        -- Fallback when TRP3 is not loaded
        return UnitName(unit or "player"), "No Title", "Warrior"
    end

    local unitID = TRP3_API.register.getUnitID(unit or "player")
    local profile = TRP3_API.profile.getPlayerCurrentProfile()
    
    if profile and profile.player and profile.player.characteristics then
        local chars = profile.player.characteristics
        local fullName = TRP3_API.register.getCompleteName(chars, UnitName(unit), true)
        local icon = chars.IC or "Interface\\Icons\\INV_Misc_QuestionMark"
        local class = chars.CL or "Warrior"
        return fullName, class, icon
    end

    return UnitName(unit or "player"), "Warrior", "Interface\\Icons\\INV_Misc_QuestionMark"
end
```

### Example 2: Querying Equipped Items & Quality Colors (Inventory Bridge)
```lua
local function GetEquippedTRP3Items()
    if not _G.TRP3_API or not _G.TRP3_API.inventory then
        -- Return empty item list fallback if TRP3 Extended is missing
        return {}
    end

    local profileID = TRP3_API.profile.getPlayerCurrentProfileID()
    local inventory = TRP3_API.inventory.getInventory(profileID)
    if not inventory then return {} end

    local items = {}
    -- Iterate container slots
    for slotID, itemInstance in pairs(inventory.content or {}) do
        local qualityColor = TRP3_API.inventory.getQualityColor(itemInstance.quality or 1)
        table.insert(items, {
            id = itemInstance.id,
            count = itemInstance.count or 1,
            colorHex = qualityColor,
            link = TRP3_API.inventory.getItemLink(itemInstance, slotID)
        })
    end

    return items
end
```

### Example 3: Subscribing to TRP3 Event Refresh Notifications
```lua
local function RegisterTRP3EventHooks(onProfileUpdateCallback, onInventoryUpdateCallback)
    if not _G.TRP3_API or not _G.TRP3_API.events then return end

    -- Listen for TRP3 profile data changes
    TRP3_API.events.registerHandler("REGISTER_DATA_UPDATED", function(unitID, profileID)
        onProfileUpdateCallback(unitID, profileID)
    end)

    -- Listen for TRP3 Extended inventory updates
    if TRP3_API.inventory and TRP3_API.inventory.EVENT_REFRESH_BAG then
        TRP3_API.events.registerHandler(TRP3_API.inventory.EVENT_REFRESH_BAG, function(container)
            onInventoryUpdateCallback(container)
        end)
    end
end
```
