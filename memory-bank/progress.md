# Project Progress & Roadmap Tracker

## Sprint 2: Legacy Decoupling & Micro-Frontend Migration (38 SP) — COMPLETED

- [x] **Epic 1: Legacy Model & Service Deprecation (10 SP)**
  - [x] Story 1.1: Legacy entity redirection & global alias cleanup in `index.lua` (4 SP)
  - [x] Story 1.2: CharacterService deprecation & `CharacterCalculator` integration (4 SP)
  - [x] Story 1.3: Legacy model and service file deletion (`src/Models/`, `src/Services/`) (2 SP)

- [x] **Epic 2: Status Plates Micro-Frontend Migration (12 SP)**
  - [x] Story 2.1: PlayerPlate micro-frontend refactoring (`src/ui/player-plate/`) (4 SP)
  - [x] Story 2.2: TargetPlate micro-frontend refactoring (`src/ui/target-plate/`) (4 SP)
  - [x] Story 2.3: RaidPlate micro-frontend refactoring (`src/ui/raid-plate/`) (4 SP)

- [x] **Epic 3: Menu, Inspection & Action Micro-Frontends Migration (10 SP)**
  - [x] Story 3.1: MainMenu & Character Sheet sub-tabs migration (`src/ui/main-menu/`) (4 SP)
  - [x] Story 3.2: InspectionMenu & QuickButtons migration (`src/ui/inspection/`, `src/ui/quick-actions/`) (3 SP)
  - [x] Story 3.3: Economy, Initiative & ExpBar migration (`src/ui/economy/`, `src/ui/initiative/`, `src/ui/exp-bar/`) (3 SP)

- [x] **Epic 4: Infrastructure Realignment & Legacy Manifest Cleanup (6 SP)**
  - [x] Story 4.1: Network communication & TRP3 adapter realignment (`NetworkAdapter`, `TRP3Adapter`) (3 SP)
  - [x] Story 4.2: Data & Locales integration (`DataTables.lua`, `LocalesAdapter.lua`) (2 SP)
  - [x] Story 4.3: Legacy directory deletion & TOC consolidation (`GAC_DEV.toc`) (1 SP)

---

## Completed Milestones
* **Sprint 1 Complete:** Hexagonal Backend (`src/main/`) and autonomous UI micro-frontend infrastructure (`src/ui/`) bootstrapped.
* **Sprint 2 Complete:** 100% legacy monolithic directories (`Models/`, `Services/`, `Frames/`, `Communication/`, `Constants/`, `Enums/`, `Events/`, `Hooks/`, `Locales/`, `Utils/`) removed.
* **Pure Directory Tree:** `src/` contains ONLY `main/`, `ui/`, and `src.xml`.
* **Micro-Frontend Architecture:** All UI components operate as autonomous micro-frontends communicating strictly over `LocalIPCAdapter`.