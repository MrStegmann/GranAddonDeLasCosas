# Project Progress & Roadmap Tracker

## Implementation Milestones

- [x] **Phase 1: Skeleton Wiring & Manifest Validation**
  - [x] Configure `THE-GAG.toc` with `SavedVariablesPerCharacter`.
  - [x] Scaffold `src/main/` and `src/ui/` folders with valid `[folder].xml` manifests.
  - [x] Verify error-free initialization with `src/main/index.lua` startup message.

- [ ] **Phase 2: Infrastructure & IPC Backbone**
  - [ ] Implement `EventDispatcher.lua` for lifecycle signals (`ADDON_LOADED`, `PLAYER_ENTERING_WORLD`).
  - [ ] Implement `LocalIPCAdapter.lua` and `IPCMessagePort.lua`.
  - [ ] Implement `SavedVarsStorageAdapter.lua` for local character persistence.
  - [ ] Implement `P2PNetworkAdapter.lua` and `RemotePlayerCacheAdapter.lua`.

- [ ] **Phase 3: Hexagonal Core Domain**
  - [ ] Implement character sheet model & stat calculator (`src/main/domain/sheet/`).
  - [ ] Implement turn-based combat state engine & dice roll math (`src/main/domain/combat/`).
  - [ ] Implement TRP3 read-only profile adapter (`src/main/adapters/TRP3Adapter.lua`).

- [ ] **Phase 4: Feature-Based UI Micro-Menus**
  - [ ] Build **Character Sheet Menu** (`src/ui/sheet/` - components, hooks, API, index).
  - [ ] Build **Combat Tracker Menu** (`src/ui/combat/` - components, hooks, API, index).
  - [ ] Verify zero direct dependencies between Sheet and Combat UI modules.

- [ ] **Phase 5: P2P Integration & Polish**
  - [ ] End-to-end testing of remote player inspection and versioned cache invalidation.
  - [ ] Live turn-based combat delta broadcast testing.

## Known Gaps & Tech Debt
* *None currently — project is in initial setup phase.*