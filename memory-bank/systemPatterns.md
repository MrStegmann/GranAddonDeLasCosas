# System Patterns & Architecture Specs

## 1. Hexagonal Backend (`src/main/`)
The backend is completely decoupled from WoW client APIs and frame lifecycle events.

```text
src/main/
├── domain/             # Pure Lua game logic (Sheet math, Combat state machine, Dice engine)
├── ports/              # Interface definitions (StoragePort, RemotePlayerPort, IPCMessagePort)
└── adapters/           # Technical implementations
    ├── events/         # Incoming Driving Adapter (WoW EventDispatcher frame listener)
    ├── network/        # P2P Transport (C_ChatInfo.SendAddonMessage wrapper & Serializer)
    ├── cache/          # In-memory volatile TTL/Versioned remote player cache
    ├── SavedVarsStorageAdapter.lua  # Reads/writes SavedVariablesPerCharacter
    ├── TRP3Adapter.lua              # Read-only adapter for TRP3 globals
    └── LocalIPCAdapter.lua          # Main IPC bus connecting main/ to UI features

```

### Critical Hexagonal Rules

* **Domain Purity:** Files inside `src/main/domain/` MUST NOT contain WoW API calls (e.g., `CreateFrame`, `RegisterEvent`, `DEFAULT_CHAT_FRAME`).
* **Adapters Fulfill Ports:** All external communication (storage, TRP3, P2P network, UI IPC) MUST go through explicit `ports/` interfaces.

---

## 2. Micro-Frontend UI Isolation (`src/ui/`)

Each UI feature (e.g., `sheet/`, `combat/`) functions as an autonomous, zero-dependency "landing page" micro-application.

```text
src/ui/[feature]/
├── [feature].xml       # Feature Manifest (Loads components XML & scripts bottom-up)
├── components/         # XML layout views and UI frame templates
├── hooks/              # Visual state handlers (hover effects, tab toggles, frame dragging)
├── api/                # Feature-specific IPC client adapter ([feature]Api.lua)
└── index.lua           # Feature Orchestrator (Binds components, hooks, & API)

```

### Critical UI Isolation Rules

* **No Cross-UI Imports:** A feature (`src/ui/combat/`) MUST NEVER directly reference or call another feature's frames or scripts (`src/ui/sheet/`).
* **No Direct WoW Events:** UI features MUST NOT register raw WoW client events (`OnEvent`). They ONLY listen to backend IPC broadcasts via their local `api/` client.
* **Visibility Lifecycle:** Features do not unmount script memory; they toggle visibility via `Frame:Show()` and `Frame:Hide()`.

---

## 3. Cascading XML Manifest Load Pattern

WoW loads Lua scripts synchronously via XML `<Include>` and `<Script>` tags. Every folder inside `src/` MUST contain a `[folder].xml` manifest that resolves dependencies bottom-up.

* **Root Manifest (`src/src.xml`):** Loads `main/main.xml` first, then `ui/ui.xml`.
* **Backend Manifest (`src/main/main.xml`):** Loads `ports/` → `domain/` → `adapters/`.
* **Adapters Manifest (`src/main/adapters/adapters.xml`):** Loads `events/`, `network/`, `cache/`, then remaining adapters.