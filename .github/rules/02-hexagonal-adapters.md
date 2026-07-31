---
trigger: always_on
---

---
description: Infrastructure adapters, network protocols, storage persistence, and event integration rules
globs: src/main/adapters/**, src/main/ports/**
---

# 02 - Hexagonal Adapters & Infrastructure Isolation

## 1. Port Fulfillments & Architectural Boundaries
* **Strict Interface Contracts:** All adapters in `src/main/adapters/` MUST implement a corresponding abstract interface contract defined in `src/main/ports/`.
* **Encapsulated Technical Concerns:** Low-level environment details (WoW client frame events, network sockets, disk persistence, third-party global reads) must be completely encapsulated within adapters.
* **No Direct Domain Invasions:** Adapters map external payloads into clean domain entities before passing them into `src/main/domain/`. Domain objects must never receive raw Blizzard event parameters or network strings.

## 2. Infrastructure Layer Responsibilities
* **Event Dispatcher (`adapters/events/`):** Listens for raw WoW client signals (e.g., `ADDON_LOADED`, `CHAT_MSG_ADDON`) via a dedicated hidden frame and translates them into domain or IPC triggers.
* **Storage Adapter (`SavedVarsStorageAdapter.lua`):** Manages read/write operations strictly against `SavedVariablesPerCharacter`.
* **Remote Cache Adapter (`adapters/cache/`):** Manages in-memory volatile session data for inspected players. MUST NOT write remote player data to disk (`SavedVariablesPerCharacter`).
* **P2P Transport (`adapters/network/`):** Handles serialization, version-header pings (`VERSION_CHECK`), and delta payload broadcasting via `C_ChatInfo.SendAddonMessage`.
* **TRP3 Integration (`TRP3Adapter.lua`):** Provides read-only adapter access to TRP3 character identity data. NEVER mutate TRP3 global tables.
* **IPC Bus (`LocalIPCAdapter.lua`):** Serves as the sole communication channel between the backend (`main/`) and UI features (`ui/`).

## 3. Communication & Network Best Practices
* **Throttling Protection:** P2P network calls must use versioning/hashes to query remote players. Always check the in-memory cache before initiating full network payloads.
* **Defensive Deserialization:** Incoming network strings (`CHAT_MSG_ADDON`) must be safely unwrapped and validated before being dispatched to domain services or IPC subscribers.