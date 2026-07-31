# CONTEXT.md — Project Overview & Architecture Blueprint

## 1. Executive Summary & Vision
**Project Name:** Custom RP & Turn-Based Combat Manager (Epsilon Server)  
**Target Environment:** World of Warcraft Client (Epsilon Roleplaying Server)  
**Core Purpose:** Provide an in-game system for managing custom tabletop-style character sheets and executing turn-based combat mechanics, while offloading standard roleplay profiles to Total RP 3.

---

## 2. Technical Stack & Architecture Constraints
* **Languages:** Native WoW Lua 5.1 (LuaJIT subset), XML (UI frame definitions).
* **Dependencies & Integrations:**
  * **TotalRP3 (TRP3):** Source of truth for base RP metadata (names, titles, base profiles).
  * **TotalRP3 Extended (TRP3-E):** Optional item/inventory integration.
* **Storage & Persistence:**
  * **`SavedVariablesPerCharacter`:** Local runtime player data (own sheets, custom combat states, keybindings) is explicitly isolated per character.
  * **In-Memory Volatile Remote Cache:** Inspected sheets and remote player stats exist **only in memory** during the session to avoid bloating disk storage and prevent stale state pollution.
  * Static game data and reference rules reside in split markdown specs inside `/data/*.md`.
* **Execution & Architectural Paradigms:**
  * **Backend (`src/main/`):** Strict **Ports & Adapters (Hexagonal Architecture)**. Domain logic remains completely decoupled from WoW client APIs, frame event listeners, storage mechanisms, network protocols, and presentation layers.
  * **Network & Remote Caching (`src/main/adapters/network/` & `cache/`):** Communication between players uses custom addon messaging (`C_ChatInfo.SendAddonMessage`). To prevent Blizzard rate-limit throttling, all remote player queries pass through a versioned in-memory cache adapter.
  * **WoW Event Handling (`src/main/adapters/events/`):** Client engine signals (e.g., `ADDON_LOADED`, `CHAT_MSG_ADDON`) act strictly as **Incoming Driving Adapters**.
  * **Frontend (`src/ui/`):** Completely **Isolated Micro-Menu Features**. Each feature acts as a self-contained "landing page" micro-frontend with its own components, internal UI hooks, dedicated IPC API bridge, and central orchestrator (`index.lua`).
  * **Cascading XML Manifests:** Bottom-up XML manifest loading (`[folder].xml`) ensures predictable dependency resolution.

---

## 3. Architecture & File Structure

```text
[AddonName]/
├── [AddonName].toc             # Entry point; declares SavedVariablesPerCharacter & loads src/src.xml
├── data/                       # Split markdown reference specifications
│   ├── abilities/
│   │   └── abilities_data.md
│   ├── spells/
│   │   └── spells_data.md
│   ├── amor_data.md
│   ├── attributes-and-talents.md
│   ├── combat_mechanics.md
│   ├── heroic-skill.md
│   ├── levels.md
│   ├── pets_data.md
│   ├── profession_data.md
│   ├── racial-data.md
│   ├── resource_mechanics.md
│   ├── sheet_creation.md
│   ├── shield_data.md
│   ├── special-characteristics_mechanics.md
│   ├── states_mechanics.md
│   ├── traits_mechanics.md
│   ├── trp3-guidance.md
│   └── weapons_data.md
└── src/
    ├── src.xml                 # Master manifest (Loads main/main.xml then ui/ui.xml)
    ├── main/                   # Backend Layer (Ports & Adapters Architecture)
    │   ├── main.xml
    │   ├── domain/             # Business Rules Core (Pure Lua, zero WoW APIs)
    │   │   ├── domain.xml
    │   │   └── database/       # Data Layer
    │   │      └── database.xml
    │   ├── ports/              # Core Input/Output Interfaces
    │   │   └── ports.xml
    │   └── adapters/           # Concrete Infrastructure Adapters
    │       ├── adapters.xml
    │       ├── events/         # Incoming Driving Adapter: WoW Client Event Listeners
    │       │   ├── events.xml
    │       │   ├── EventDispatcher.lua    # Hidden frame created to register/listen to Blizzard events
    │       │   ├── LifecycleEvents.lua    # Handlers for ADDON_LOADED & PLAYER_ENTERING_WORLD
    │       ├── network/        # P2P Transport Layer
    │       │   ├── network.xml
    │       │   ├── P2PNetworkAdapter.lua  # Wraps C_ChatInfo.SendAddonMessage
    │       │   └── PayloadSerializer.lua  # Compresses/decompresses network payloads
    │       ├── cache/          # Remote Data Cache
    │       │   ├── cache.xml
    │       │   └── RemotePlayerCacheAdapter.lua # Volatile in-memory store (TTL & Versioning)
    │       ├── SavedVarsStorageAdapter.lua    # Reads/writes local SavedVariablesPerCharacter
    │       ├── TRP3Adapter.lua                # Reads TRP3 profile data
    │       └── LocalIPCAdapter.lua            # Main IPC Event/Message Bus implementation
    └── ui/                     # Presentation Layer (Isolated Micro-Menus / Landing Pages)
        ├── ui.xml              # Loads shared assets and feature manifests
        └── shared/             # General XML templates & global UI helpers
            ├── shared.xml
            └── Templates.xml

```

---

## 4. Architectural Boundaries & Communication Flow

### 1. Remote Data Sync & Caching Architecture

* **`RemotePlayerPort` Interface:** Exposes methods to query player data (e.g., `FetchPlayerSheet(targetGuid, callback)`).
* **`RemotePlayerCacheAdapter`:** Manages an in-memory dictionary (`{ [targetGuid] = { data, version, lastUpdated } }`).
* **Version-Header Ping:** When querying a remote player, a lightweight version ping (`VERSION_CHECK`) is sent over `P2PNetworkAdapter`. If the target's data version matches the local cache, cached data is returned instantly with 0 network overhead.
* **Roleplay/Inspection Strategy:** Uses TTL-based caching (3–5 minutes) before prompting for a version re-check.
* **Turn-Based Combat Strategy:** Caches static character stats while subscribing to minimal **delta broadcasts** (e.g., health drops or AP spending) during active combat encounters.
* **Memory Isolation:** Cache is session-only and never saved to `SavedVariablesPerCharacter`.



### 2. Events Adapter (`src/main/adapters/events/`)

* Listens for raw engine events (e.g., `ADDON_LOADED`, `CHAT_MSG_ADDON`).
* Routes incoming P2P messaging payloads from `CHAT_MSG_ADDON` directly to `P2PNetworkAdapter` for processing.

### 3. Backend Hexagon (`src/main/`)

* **Domain (`domain/`):** Contains tabletop game math, combat sequence rules, and stat spending formulas. Zero WoW client dependencies.
* **Ports & Adapters (`ports/`, `adapters/`):** Connects storage, external TRP3 integrations, network protocols, and local UI messaging.

### 4. UI Features (`src/ui/[feature]/`)

* Functions as independent micro-frontend "landing pages".
* Consumes backend data strictly via its dedicated `api/[feature]Api.lua` IPC adapter.
* Fully isolated: never imports other UI feature files, never mutates global state, and never listens directly to Blizzard engine events.

---

## 5. Master Manifest Cascading Rules (`[folder].xml`)

Sub-manifests load bottom-up to ensure dependencies exist before higher-level modules instantiate.

#### Adapters Manifest Example (`src/main/adapters/adapters.xml`)

```xml
<Ui xmlns="[http://www.blizzard.com/wow/ui/](http://www.blizzard.com/wow/ui/)" xmlns:xsi="[http://www.w3.org/2001/XMLSchema-instance](http://www.w3.org/2001/XMLSchema-instance)">
    <!-- Network & Remote Cache Sub-manifests -->
    <Include file="network\network.xml"/>
    <Include file="cache\cache.xml"/>
    
    <!-- Client Event Dispatcher Adapter -->
    <Include file="events\events.xml"/>
    
    <!-- Infrastructure Adapters -->
    <Script file="SavedVarsStorageAdapter.lua"/>
    <Script file="TRP3Adapter.lua"/>
    <Script file="LocalIPCAdapter.lua"/>
</Ui>

```

---

## 6. Implementation Roadmap

1. **Phase 1: TOC & Manifest Skeleton**
* Setup `.toc` with `SavedVariablesPerCharacter`.
* Establish cascading XML structure (`src.xml` down to all feature/module manifests).


2. **Phase 2: Core Messaging & Infrastructure**
* Implement `EventDispatcher.lua` for lifecycle and addon network channels (`CHAT_MSG_ADDON`).
* Build `P2PNetworkAdapter.lua` and `RemotePlayerCacheAdapter.lua` for remote inspections.
* Implement `LocalIPCAdapter.lua` for backend-to-frontend communication.


3. **Phase 3: Hexagonal Domain Engine**
* Implement local character sheet rules (`domain/sheet/`) and turn-based combat controllers (`domain/combat/`).
* Hook up `SavedVarsStorageAdapter.lua` and `TRP3Adapter.lua`.


4. **Phase 4: Feature Micro-Menus**
* Build the **Sheet** micro-frontend using `components/`, `hooks/`, `api/`, and `index.lua`.
* Build the **Combat** micro-frontend following identical micro-app encapsulation.