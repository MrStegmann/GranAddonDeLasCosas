# Technical Context & Environmental Constraints

## WoW Lua Execution Environment
* **Lua Version:** WoW Lua 5.1 (LuaJIT subset runtime).
* **No Standard I/O or File System:** All disk persistence must go through Blizzard's `SavedVariables` system upon UI reload or logout.
* **Global Scope Hygiene:** Avoid global variable pollution. Explicitly namespace modules or localize within Lua files.

## Persistence Constraint: `SavedVariablesPerCharacter`
* **Declaration:** Declared in `[AddonName].toc` as `## SavedVariablesPerCharacter: CustomRPAddon_CharDB`.
* **Character Isolation:** Stores player character sheets, custom action keybindings, and combat configurations per character.
* **No Global Leaking:** Account-wide global `SavedVariables` are strictly prohibited.

## Peer-to-Peer (P2P) Messaging Protocol
* **Channel:** Built on `C_ChatInfo.SendAddonMessage` and `CHAT_MSG_ADDON` events.
* **Rate-Limit Safeguards:** To avoid Blizzard's client message throttling:
  * Remote character inspections send a lightweight `VERSION_CHECK` ping first.
  * Target sheets are returned only if the local `RemotePlayerCacheAdapter` version is out of date.
  * Combat encounters broadcast minimal **delta updates** (e.g., `-10 HP`) rather than full sheet payloads.
* **Cache Lifetime:** The remote cache is volatile, in-memory only, and purged on `/reload` or logout.