# Phase 1 Data Model: Critical Fixes & Infrastructure Setup

## Entity 1: GAC Root Namespace (`_G.GAC` & `_G.GranAddonDeLasCosas`)

Singleton global table instance exposing all core add-on services, configuration handles, and database wrappers.

### Attributes
- `name` (`string`): Add-on folder and register identifier (`"GAC_DEV"`).
- `version` (`string`): Semantic version string (e.g., `"1.3.0"`).
- `db` (`table`): Reference to global `GranAddonDeLasCosasDB`.
- `characterData` (`table`): Reference to character-specific `GranAddonDeLasCosasCharDB`.
- `eventFrame` (`Frame`): Internal Blizzard frame handling event listeners (`ADDON_LOADED`, `PLAYER_ENTERING_WORLD`, `CHAT_MSG_SYSTEM`).

---

## Entity 2: XML Manifest Load Tree

Structural hierarchy defining the order in which XML manifests and Lua scripts are loaded by the WoW client.

### Manifest Hierarchy
1. `GAC_DEV.toc`
   └── `GranAddonDeLasCosas.xml` (`<Include file="src\GAC.xml"/>`)
       └── `src/GAC.xml`
           ├── `<Script file="index.lua"/>`
           ├── `<Include file="Locales\Locales.xml"/>`
           ├── `<Include file="Communication\Communication.xml"/>`
           ├── `<Include file="Utils\Utils.xml"/>`
           ├── `<Include file="Data\Data.xml"/>`
           └── `<Include file="Frames\Frames.xml"/>`
