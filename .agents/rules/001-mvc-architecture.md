---
trigger: always_on
---

---
name: "MVC Architecture Pattern"
description: "Ensure AI Agent always create files following the MVC Architecture Pattern for every business logic, persistant data, save data and load data."
globs: `src/main/**/*.lua`
---

# MVC Architecture

## Core Mandate
Enforce a strict Model-View-Controller (MVC) architectural pattern adapted for World of Warcraft Lua AddOns.

Under this headless architecture:
- **Model** = `SavedVariables`, `SavedVariablesPerCharacter`, data persistence, normalization, static literals, and state stores.
- **View / Presenter** = Public API surface, DTO serializers, data contracts, and outbound third-party event dispatchers (e.g., LibDataBroker / CallbackHandler / AceEvent-style custom messages). **Strictly NO UI/Frames/Widgets.**
- **Controller** = WoW engine lifecycle orchestrator (`ADDON_LOADED`, `PLAYER_LOGIN`, `CHAT_MSG_ADDON`, combat log events) and mediator between incoming external API calls and the internal data models.

## Layer Constraints & Rules

### 1. Models (`/Models`)
* **Responsibility:** Manages all data integrity, `SavedVariables` persistence, table schema sanitization, caching, and mutation logic.
* **Constraints:**
* Must never listen to Blizzard engine events (`Frame:RegisterEvent`) directly.
* Must never access or mutate the global environment (`_G`) directly outside the private addon namespace.
* Must never format data specifically for consumer convenience; expose raw, validated domain state only.



### 2. View / Public API Layer (`/API`)
* **Responsibility:** Serves as the consumer-facing interface.
* Exposes public global entry points (e.g., `_G.MyAddonAPI` or `LibStub` integration).
* Serializes internal state into read-only, sanitized Data Transfer Objects (DTOs) to prevent third-party AddOns from mutating internal model tables directly (e.g., deep copy or read-only metatable proxies).
* Dispatches standardized public custom events/callbacks to subscriber AddOns.
* **Constraints:**
* **STRICTLY ZERO UI:** Do not create visual `Frame`, `FontString`, `Texture`, or `XML` elements.
* Must not mutate `SavedVariables` or `SavedVariablesPerCharacter` directly; all write operations must delegate to a Controller.



### 3. Controllers (`/Controllers`)
* **Responsibility:** Acts as the mediator and orchestration layer.
* Owns the hidden event frame (e.g., `CreateFrame("Frame")`) to capture Blizzard engine events.
* Handles AddOn lifecycle events (`ADDON_LOADED`, `PLAYER_ENTERING_WORLD`, `PLAYER_LOGOUT`).
* Processes intra-addon communication (`RegisterAddonMessagePrefix`, `SendAddonMessage`).
* Intercepts calls received by `PublicAPI.lua`, validates consumer parameters, calls the appropriate Model method, and triggers downstream outbound API events.
* **Constraints:**
* Keep controllers thin: orchestrate actions, do not embed schema/storage structures (delegate to Models).
* Never return internal mutable references directly across the API boundary without passing through `/API/Serializers.lua`.


## Code Quality & Safety Guardrails
* **Taint & State Protection:** Always deep-copy or proxy internal table references returned by public API getters so consuming addons cannot corrupt addon state.
* **Defensive API Contracts:** Validate types and values on every public API entry point (`assert` or clear error handling) before passing data to Controllers.
* **Namespace Isolation:** All internal modules must communicate strictly via the private namespace table passed by the WoW Lua loader (`local addonName, addonTable = ...`).
