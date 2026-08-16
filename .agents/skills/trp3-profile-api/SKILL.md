---
name: trp3-profile-api
description: Documentation for Total RP 3 (TRP3) public APIs relating to reading character profiles and registry data. Use this skill when you need to interact with TRP3 to get RP names, check if a unit is known to TRP3, or read profile data like characteristics, about, and misc info.
---

# TRP3 Profile API

The `Total RP 3` addon stores data using two main structures:
- **Characters Registry (`characters`)**: Stores data linked directly to a `unitID` (e.g., `Player-Realm`). This includes their current `profileID`, client version, race, class, etc.
- **Profiles Registry (`profiles`)**: Stores the actual RP data (characteristics, about, misc) under a unique `profileID`. Multiple characters can share the same `profileID`.

> **Note:** A `unitID` in TRP3 is the full name and realm (e.g., `"PlayerName-RealmName"`). A `targetType` is a standard WoW unit token (e.g., `"player"`, `"target"`, `"mouseover"`).

## Reading Unit Information

### `TRP3_API.register.getUnitRPName(targetType)`
Returns the full roleplay name of the unit if they have a TRP3 profile, otherwise returns their standard WoW name.
- **Input:** `targetType` (string) - WoW unit token like `"target"` or `"player"`.
- **Output:** `string` - The RP Name.

### `TRP3_API.register.getUnitRPFirstName(targetType)`
Returns the RP first name of the unit.
- **Input:** `targetType` (string) - WoW unit token.
- **Output:** `string` - The RP First Name.

### `TRP3_API.register.getUnitRPLastName(targetType)`
Returns the RP last name of the unit.
- **Input:** `targetType` (string) - WoW unit token.
- **Output:** `string` - The RP Last Name.

### `TRP3_API.register.isUnitKnown(targetType)`
Checks if the unit has been seen by TRP3 and exists in the local registry.
- **Input:** `targetType` (string) - WoW unit token.
- **Output:** `boolean` - True if known, false otherwise.

### `TRP3_API.register.getUnitIDCharacter(unitID)`
Returns the character registry data for a specific `unitID`.
- **Input:** `unitID` (string) - Formatted as `"Player-Realm"`.
- **Output:** `table` - Character data table containing fields like `profileID`, `client`, `clientVersion`, `race`, `class`, `gender`.

## Reading Profiles Directly

### `TRP3_API.profile.getPlayerCurrentProfileID()`
Returns the profile ID currently active for the player.
- **Output:** `string` - The active `profileID`.

### `TRP3_API.profile.getPlayerCharacter()`
Returns the character registry data for the local player.
- **Output:** `table` - The local player's character data table (same structure as `getUnitIDCharacter`).

### `TRP3_API.profile.getProfileByID(profileID)`
Returns the complete profile data table for a given `profileID`.
- **Input:** `profileID` (string) - The unique ID of the profile.
- **Output:** `table` - The profile data table. Contains subtables:
  - `characteristics`: Contains RP name (`FN`, `LN`), titles (`TI`), race (`RA`), class (`CL`), etc.
  - `about`: Contains the character's backstory and about text (`TE`), music (`MU`), etc.
  - `misc`: Contains currently active glances/peek icons (`PE`).

### `TRP3_API.register.getCharacterList()`
Returns the entire characters registry table.
- **Output:** `table` - Dictionary of `[unitID] = characterData`.

### `TRP3_API.register.getProfileList()`
Returns the entire profiles registry table.
- **Output:** `table` - Dictionary of `[profileID] = profileData`.

## Example Usage
```lua
-- Get the RP name of your target
local rpName = TRP3_API.register.getUnitRPName("target")
print("Target is: " .. rpName)

-- Check if your target is known, and print their client version
if TRP3_API.register.isUnitKnown("target") then
    local unitID = TRP3_API.utils.str.getUnitID("target")
    local charData = TRP3_API.register.getUnitIDCharacter(unitID)
    print("Using TRP3 Client: " .. tostring(charData.client))
    
    -- If they have a profile, we can read it
    if charData.profileID then
        local profile = TRP3_API.profile.getProfileByID(charData.profileID)
        if profile and profile.characteristics then
            print("RP Race: " .. tostring(profile.characteristics.RA))
        end
    end
end
```
