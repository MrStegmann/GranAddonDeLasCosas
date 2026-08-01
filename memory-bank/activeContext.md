# Active Context & Current Focus

## Current Phase: Sprint 1 — Architectural Realignment & Hexagonal Migration

## Recent Changes
- Performed project health audit and generated `SUMMARY.md` documenting legacy monolith status and architectural drift.
- Created `sprint.md` establishing Sprint 1 backlog with 5 Epics, 10 User Stories, and 34 Story Points.

## Immediate Next Steps (Sprint 1 Backlog Execution)
1. **Physical Directory & Manifest Setup (Epic 1 - Story 1.1):**
   * Scaffold `src/main/` (`domain/`, `ports/`, `adapters/`) and `src/ui/` (`sheet/`, `combat/`, `shared/`).
   * Create `src/src.xml`, `src/main/main.xml`, `src/ui/ui.xml`, and sub-folder XML manifests.
2. **Domain Model Refactoring (Epic 2 - Story 2.1):**
   * Migrate `Character.lua` into `src/main/domain/` with pure Lua schema validation (`Character.create(raw_data)`) and zero WoW API dependencies (`UnitName`).
3. **IPC & Event Infrastructure (Epic 3 - Stories 3.1 & 3.2):**
   * Implement `EventDispatcher.lua` and `LocalIPCAdapter.lua`.

## Active Architectural Decisions
* **Hexagonal Domain Purity:** Files inside `src/main/domain/` MUST NOT reference WoW Client APIs (`UnitName`, `CreateFrame`, `RegisterEvent`, etc.).
* **Micro-Frontend UI Isolation:** UI features inside `src/ui/` communicate with backend strictly via `api/[feature]Api.lua` client adapters over `LocalIPCAdapter`.
* **XML Manifest Cascading:** All dependencies load bottom-up via cascading `[folder].xml` files.
