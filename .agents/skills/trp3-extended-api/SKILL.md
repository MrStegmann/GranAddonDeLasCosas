---
name: trp3-extended-api
description: Documentation for Total RP 3 Extended (TRP3E) public APIs relating to inventory management and custom items. Use this skill when you need to interact with TRP3 Extended to add, remove, or modify items in a player's inventory, or read their inventory state.
---

# TRP3 Extended API (Inventory)

The `Total RP 3: Extended` addon manages custom items using an internal container system.
The main player inventory is the root container, which holds item slots.

## Accessing Inventory

### `TRP3_API.inventory.getInventory()`
Returns the player's main inventory container.
- **Output:** `table` - The container object representing the player's backpack. It contains a `content` field which is a dictionary of slot IDs to item slot data.

### `TRP3_API.inventory.getItem(container, slotID)`
Returns the slot data for a specific slot in a container.
- **Input:** 
  - `container` (table) - A container object (e.g., from `getInventory()`).
  - `slotID` (string) - The slot identifier (usually numeric strings like `"1"`, `"2"`, etc.).
- **Output:** `table|nil` - The slot data (contains `id`, `count`, `madeBy`, `vars`).

### `TRP3_API.inventory.getItemCount(classID, container)`
Counts how many instances of a specific item the player (or a specific container) has.
- **Input:** 
  - `classID` (string) - The full ID of the item class.
  - `container` (table|nil) - Optional. The container to check. If nil, defaults to the player's main inventory.
- **Output:** `number` - The total count of that item found.

## Managing Items

### `TRP3_API.inventory.addItem(givenContainer, classID, itemData, dropIfFull, toSlot)`
Adds an item to a container, handling stacking automatically.
- **Input:**
  - `givenContainer` (table|nil) - The container to add to. If nil, defaults to the player's main inventory.
  - `classID` (string) - The full ID of the item class to add.
  - `itemData` (table) - Data for the item instance. Often `{ count = 1 }`, but can include `{ count = 1, madeBy = "Player-Realm", vars = {} }`.
  - `dropIfFull` (boolean) - If true, drops the item on the ground if the inventory is full.
  - `toSlot` (string|nil) - Optional specific slot ID to try and place the item in.
- **Output:** Returns multiple values indicating success:
  - `returnType` (number) - 0 if OK, 1 if full, 2 if unique limit reached, 3 if not a container.
  - `count` (number) - How many items were successfully added.

### `TRP3_API.inventory.removeItem(classID, amount, container)`
Removes a specific amount of an item class from a container.
- **Input:**
  - `classID` (string) - The full ID of the item class to remove.
  - `amount` (number) - The quantity to remove.
  - `container` (table|nil) - Optional. The container to remove from (defaults to player inventory).

### `TRP3_API.inventory.removeSlotContent(container, slotID, slotInfo, manuallyDestroyed)`
Directly clears a slot in a container.
- **Input:**
  - `container` (table) - The container.
  - `slotID` (string) - The slot identifier.
  - `slotInfo` (table) - The slot data (must match `container.content[slotID]`).
  - `manuallyDestroyed` (boolean) - If true, triggers on-destroy scripts and messages.

### `TRP3_API.inventory.consumeItem(slotInfo, containerInfo, quantity)`
Lowers the stack count of an item in a slot, and automatically cleans up the slot if it reaches 0.
- **Input:**
  - `slotInfo` (table) - The slot data.
  - `containerInfo` (table) - The container holding the slot.
  - `quantity` (number) - The amount to subtract from the stack count.

## Example Usage
```lua
-- Add 5 instances of a custom item to the player's inventory
local myItemID = "my_custom_item_id"
local itemData = { count = 5 }
local status, addedCount = TRP3_API.inventory.addItem(nil, myItemID, itemData, false)

if status == 0 then
    print("Successfully added " .. addedCount .. " items!")
end

-- Consume 1 item from the first slot
local inventory = TRP3_API.inventory.getInventory()
local firstSlot = TRP3_API.inventory.getItem(inventory, "1")

if firstSlot and firstSlot.id == myItemID then
    TRP3_API.inventory.consumeItem(firstSlot, inventory, 1)
end
```
