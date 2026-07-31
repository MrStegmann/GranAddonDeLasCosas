# Active Context & Current Focus

## Current Phase: Phase 1 — Skeleton Wiring & Architecture Setup

## Recent Changes
- Completed Phase 1 skeleton: created `THE-GAG.toc`, master `src/src.xml`, base `[folder].xml` manifests under `src/main/` and `src/ui/`, and startup script `src/main/index.lua` (`print("Hello World")`).

## Immediate Next Steps
1. **Core Event & IPC Dispatcher (Phase 2):**
   * Implement `EventDispatcher.lua` inside `src/main/adapters/events/` to catch `ADDON_LOADED`.
   * Implement `LocalIPCAdapter.lua` to establish the backend-to-frontend message bus.

## Active Architectural Decisions
* **WoW Engine Events:** Placed inside `src/main/adapters/events/` as an incoming driving adapter to preserve Hexagonal purity.
* **UI Features:** Modeled after independent micro-frontend landing pages with encapsulated `components/`, `hooks/`, `api/`, and `index.lua`.
* **Remote Player Inspection:** Uses an in-memory TTL/versioned cache in `src/main/adapters/cache/` to prevent network throttling.
