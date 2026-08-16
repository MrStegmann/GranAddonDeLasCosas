# CONTEXT.md — Project Overview & Architecture Blueprint

## 1. Executive Summary & Vision
**Project Name:** Custom RP & Turn-Based Combat Manager (Epsilon Server)  
**TOC Name:** GAC_DEV  
**Target Environment:** World of Warcraft Client (Epsilon Roleplaying Server - Shadowlands 9.2.7)  
**Core Purpose:** Provide an in-game system for managing custom tabletop-style character sheets and executing turn-based combat mechanics, while offloading standard roleplay profiles to Total RP 3.

---

## 2. Technical Stack & Architecture Constraints
* **Languages:** Native WoW Lua 5.1 (LuaJIT subset), XML (UI frame definitions & manifests).
* **Dependencies & Integrations:**
  * **TotalRP3 (TRP3):** Source of truth for base RP metadata (names, titles, base profiles).
  * **TotalRP3 Extended (TRP3-E):** Optional item/inventory integration.
* **Storage & Persistence:**
  * **`SavedVariables` (`GranAddonDeLasCosasDB`):** Account-wide persistent configuration and global data.
  * **`SavedVariablesPerCharacter` (`GAC_CharacterDB`):** Local runtime player data (character sheet, attributes, custom combat state) isolated per character.
  * **In-Memory Volatile Remote Cache:** Inspected sheets and remote player stats exist **only in memory** during the session to avoid bloating disk storage and prevent stale state pollution.
  * **Game Data & RPG Mechanics Specifications:** Reside in root `Data/` (Lua data tables) and `Data/sistema_de_rol/` (JSON schemas, markdown mechanics specs, professions, and spell definitions).
* **Execution & Architectural Paradigms:**
  * **Entry Point & Orchestrator (`index.lua` & `GAC_DEV.toc`):** `GAC_DEV.toc` loads `src/src.xml` followed by `index.lua`. `index.lua` initializes the addon namespace, registers Blizzard events (`ADDON_LOADED`, `CHAT_MSG_SYSTEM`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`, `PLAYER_LOGOUT`), and binds hexagonal domain modules and adapters.
  * **Backend (`src/main/`):** Strict **Ports & Adapters (Hexagonal Architecture)**. Domain logic remains completely decoupled from WoW client APIs, frame event listeners, storage mechanisms, network protocols, and presentation layers.
  * **Network & Remote Caching (`src/main/adapters/network/` & `cache/`):** Communication between players uses custom addon messaging (`C_ChatInfo.SendAddonMessage`). To prevent Blizzard rate-limit throttling, all remote player queries pass through a versioned in-memory cache adapter.
  * **WoW Event Handling (`src/main/adapters/events/`):** Client engine signals (e.g., `ADDON_LOADED`, `CHAT_MSG_ADDON`) act strictly as **Incoming Driving Adapters**.
  * **Localization (`src/main/adapters/locales/`):** Encapsulates multi-language strings and translation tables.
  * **Frontend (`src/ui/`):** Isolated **Micro-Frontend Architecture**. Features act as self-contained micro-applications with dedicated IPC API bridges and UI components.
  * **Cascading XML Manifests:** Bottom-up XML manifest loading (`[folder].xml`) ensures predictable dependency resolution.

---

## 3. Architecture & File Structure

```text
GAC_DEV/
├── GAC_DEV.toc                 # Entry point TOC; declares SavedVariables & loads src/src.xml & index.lua
├── AGENTS.md                   # Multi-agent operating manual & architecture rules
├── CONTEXT.md                  # Project overview & architecture blueprint
├── README.md                   # Project overview & setup instructions
├── memory-bank/                # Architectural memory bank
│   ├── activeContext.md        # Active context & focus
│   ├── productContext.md       # Product vision & goals
│   ├── progress.md             # Project progress tracker
│   ├── projectbrief.md        # Core project brief
│   ├── systemPatterns.md       # Architectural system patterns
│   └── techContext.md          # Technical stack context
└── src/                        # Source Code Manifest Tree
    ├── src.xml                 # Master manifest (Loads main/main.xml then ui/ui.xml)
    ├── Data/                   # Data manifest directory
    │   └── sistema_de_rol/
    ├── main/                   # Backend Layer (Ports & Adapters Architecture)
    │   ├── main.xml            # Loads ports.xml -> domain.xml -> adapters.xml
    │   ├── domain/             # Business Rules Core (Pure Lua, zero WoW APIs)
    │   │   ├── models/         # Lua Metatables for domain entities
    │   │   │   └── models.xml  # XML Manifest for Lua Metatables
    │   │   └── domain.xml      # XML Manifest for Domain
    │   ├── ports/              # Core Input/Output Interfaces
    │   │   └── ports.xml
    │   └── adapters/           # Concrete Infrastructure Adapters
    │       ├── adapters.xml
    │       ├── cache/          # Volatile In-Memory Remote Cache Sub-Manifest
    │       │   └── cache.xm
    │       ├── events/         # Incoming Driving Adapter (WoW Client Events) Sub-Manifest
    │       │   └── events.xml
    │       ├── locales/        # Localization Adapter Sub-Manifest
    │       │   └── locales.xml
    │       └── network/        # P2P Network Serialization & Transport Sub-Manifest
    │           └── network.xml
    └── ui/                     # Presentation Layer (Isolated Micro-Menus)
        └── ui.xml              # Master UI Manifest
```

---

## 4. Architectural Boundaries & Communication Flow

### 1. Remote Data Sync & Caching Architecture (`src/main/adapters/cache/`)

* **`RemotePlayerPort` Interface:** Exposes methods to query remote player data.
* **`RemotePlayerCacheAdapter`:** Manages an in-memory dictionary (`{ [targetGuid] = { data, version, lastUpdated } }`).
* **Version-Header Ping:** Lightweight version pings (`VERSION_CHECK`) over `P2PNetworkAdapter` ensure cached remote character data is returned with 0 unnecessary network overhead.
* **Roleplay/Inspection Strategy:** Uses TTL-based caching (3–5 minutes) before prompting for a version re-check.
* **Turn-Based Combat Strategy:** Caches static character stats while subscribing to minimal **delta broadcasts** (e.g., health changes or AP spending) during active combat encounters.
* **Memory Isolation:** Cache is strictly volatile in-memory and never persisted to `SavedVariablesPerCharacter`.

### 2. Events Adapter (`src/main/adapters/events/`)

* Listens for raw WoW client engine events (e.g., `ADDON_LOADED`, `CHAT_MSG_ADDON`).
* Routes incoming P2P messaging payloads from `CHAT_MSG_ADDON` directly to `P2PNetworkAdapter` for payload deserialization and domain processing.

### 3. Backend Hexagon (`src/main/`)

* **Domain (`src/main/domain/`):** Contains tabletop game math, combat sequence rules, dice engine, and stat spending formulas. Operates in pure Lua 5.1 with zero WoW client dependencies.
* **Ports & Adapters (`src/main/ports/`, `src/main/adapters/`):** Connects storage adapters, external TRP3 integrations, network protocols, localization, and local UI IPC messaging.

### 4. Primary Entry Orchestrator (`index.lua`)

* Primary script loaded by `GAC_DEV.toc`.
* Binds Hexagonal Domain modules (`DataTables`, `Character`, `CharacterCalculator`, `Item`, `Armor`, `Weapon`) and instantiates adapters (`EventDispatcher`, `LocalIPCAdapter`, `SavedVarsStorageAdapter`, `TRP3Adapter`, `LocalesAdapter`).
* Dispatches lifecycle events (`ADDON_LOADED`, `PLAYER_ENTERING_WORLD`, `PLAYER_LOGOUT`) and publishes initial character state over IPC (`CHARACTER_UPDATED`).

### 5. UI Micro-Frontends (`src/ui/`)

* Functions as independent micro-frontend features.
* Consumes backend data strictly via dedicated `api/[feature]Api.lua` IPC adapters.
* Fully isolated: features never import other UI feature files, never mutate global state directly, and never listen directly to Blizzard engine events.

---

## 5. Master Manifest Cascading Rules (`[folder].xml`)

Sub-manifests load bottom-up to ensure dependencies exist before higher-level modules instantiate.

#### 1. Entry Point Load Sequence (`GAC_DEV.toc`)
```toc
src\src.xml
index.lua
```

#### 2. Master XML Manifest (`src/src.xml`)
```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Include file="main\main.xml"/>
    <Include file="ui\ui.xml"/>
</Ui>
```

#### 3. Backend Manifest (`src/main/main.xml`)
```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Include file="ports\ports.xml"/>
    <Include file="domain\domain.xml"/>
    <Include file="adapters\adapters.xml"/>
</Ui>
```

---

## 6. Implementation Roadmap & Architectural Status

1. **Phase 1: TOC & Cascading XML Manifest Skeleton (Completed)**
   * Established `GAC_DEV.toc` loading `src\src.xml` and `index.lua`.
   * Built cascading XML directory tree (`src.xml` -> `main.xml` -> `ports.xml`, `domain.xml`, `adapters.xml`, `ui.xml`).

2. **Phase 2: Legacy Decoupling & Directory Cleanup (Completed)**
   * Consolidated legacy files into clean Hexagonal architecture structure (`src/main/` and `src/ui/`).
   * Cleaned up legacy subdirectories.

3. **Phase 3: Hexagonal Domain & Adapter Implementation (In Progress)**
   * Implementing domain entities, character calculator, and combat state machines under `src/main/domain/`.
   * Wiring infrastructure adapters (`SavedVarsStorageAdapter`, `TRP3Adapter`, `EventDispatcher`, `P2PNetworkAdapter`, `LocalesAdapter`, `LocalIPCAdapter`).

4. **Phase 4: Feature Micro-Frontends (Planned)**
   * Build micro-frontend menus (`sheet`, `combat`, `inspection`, `main-menu`) following isolated component, hook, and API patterns.