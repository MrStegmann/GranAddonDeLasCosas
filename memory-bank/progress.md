# Project Progress & Roadmap Tracker

## Current Sprint: Sprint 1 — Architectural Realignment & Hexagonal Migration (34 SP)

- [ ] **Epic 1: Physical Directory Scaffolding & Cascading Manifests (6 SP)**
  - [ ] Story 1.1: Scaffold `src/main/` and `src/ui/` directory hierarchy & XML manifests (3 SP)
  - [ ] Story 1.2: Update `GAC_DEV.toc` entry point to `src/src.xml` (2 SP)
  - [ ] Story 1.3: Clean up legacy TypeScript files (`src/Models/modelosTS/*.ts`) (1 SP)

- [ ] **Epic 2: Core Domain Purity & Entity Factory Refactoring (11 SP)**
  - [ ] Story 2.1: Refactor `Character.lua` into `src/main/domain/` with pure schema factory `Character.create()` (5 SP)
  - [ ] Story 2.2: Refactor Item, Armor & Weapon entities to pure Lua modules (3 SP)
  - [ ] Story 2.3: Decouple `CharacterService.lua` into `CharacterCalculator.lua` (3 SP)

- [ ] **Epic 3: Infrastructure, Event Dispatching & Local IPC Backbone (12 SP)**
  - [ ] Story 3.1: Implement `EventDispatcher.lua` in `src/main/adapters/events/` (4 SP)
  - [ ] Story 3.2: Implement `LocalIPCAdapter.lua` bus for backend-to-frontend messaging (5 SP)
  - [ ] Story 3.3: Implement `SavedVarsStorageAdapter.lua` and `TRP3Adapter.lua` (3 SP)

- [ ] **Epic 4: UI Micro-Frontend Isolation & Component Refactoring (4 SP)**
  - [ ] Story 4.1: Establish base UI architecture & shared templates (`src/ui/shared/`) (2 SP)
  - [ ] Story 4.2: Refactor Character Sheet UI micro-frontend (`src/ui/sheet/`) (2 SP)

- [x] **Epic 5: Memory Bank Synchronization & Governance (1 SP)**
  - [x] Story 5.1: Realign `activeContext.md`, `progress.md`, and generate `sprint.md` backlog (1 SP)

---

## Known Gaps & Tech Debt Tracked in Backlog
* Physical directory structure in `src/` currently uses legacy monolithic layout (`Communication/`, `Frames/`, `Models/`, `Services/`).
* Domain models (`Character.lua`) currently call WoW APIs directly (`UnitName("player")`).
* Central `index.lua` listens directly to WoW events rather than routing through `EventDispatcher.lua`.