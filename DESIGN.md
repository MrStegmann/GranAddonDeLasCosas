# DESIGN.md (Project Constitution)

Welcome to the **Gran Addon De Las Cosas (GAC)**. This document serves as the overarching "Constitution" and global design rulebook for the repository. 

As established in `AGENTS.md`, this document sits at the very top of the **Hierarchy of Truth**. All feature specifications (`specs/[feature]/spec.md`), AI agents, and manual code implementations MUST adhere strictly to these governing principles.

---

## 1. The Core Philosophy: Spec-Driven Development (SDD)

No code may be written, refactored, or modified without an approved specification and updated context files. 
- **Specs First:** If a task touches business logic or features, it must have a corresponding entry in `specs/[xxx-feature]/`.
- **Atomic Execution:** Each unit of work must trace directly back to an unchecked item in a feature's `tasks.md`.
- **System Memory:** The `memory-bank/` directory is the snapshot of reality. It must be updated as paradigms emerge and session goals finish.

---

## 2. Backend Architecture: Strict MVC

The addon's core logic adheres to a headless Model-View-Controller (MVC) architectural pattern.

### Models (`/Models`)
- **Responsibility:** Manages all data integrity, `SavedVariables` persistence, table schema sanitization, caching, and mutation logic.
- **Constraints:**
  - Must never listen to Blizzard engine events (`Frame:RegisterEvent`) directly.
  - Must never access or mutate the global environment (`_G`) directly outside the private addon namespace.
  - Must never format data specifically for consumer convenience; expose raw, validated domain state only.

### View / Public API Layer (`/API`)
- **Responsibility:** Serves as the consumer-facing interface (e.g., `_G.MyAddonAPI` or `LibStub` integration).
- **Constraints:**
  - **STRICTLY ZERO UI:** Do not create visual `Frame`, `FontString`, `Texture`, or `XML` elements.
  - Serializes internal state into read-only, sanitized Data Transfer Objects (DTOs) to prevent third-party AddOns from mutating internal model tables directly.
  - Must not mutate `SavedVariables` or `SavedVariablesPerCharacter` directly; all write operations must delegate to a Controller.

### Controllers (`/Controllers`)
- **Responsibility:** Acts as the mediator and orchestration layer between the WoW engine and the internal data models.
- **Constraints:**
  - Owns the hidden event frame to capture Blizzard engine events (`ADDON_LOADED`, `PLAYER_ENTERING_WORLD`).
  - Processes intra-addon communication (P2P syncing).
  - Keep controllers thin: orchestrate actions, do not embed schema/storage structures (delegate to Models).

---

## 3. Frontend Architecture: Feature-Based UI

Every UI Frame or distinct view is a standalone feature located in its own dedicated directory (e.g., `src/ui/<FeatureName>/` or `src/Frames/<FeatureName>/`).

### Principles of UI Isolation
- **Zero Cross-UI Knowledge:** A feature frame must never require, import, reference, or mutate another feature frame directly. Intra-UI coordination must occur strictly through the backend (`src/main/` layers).
- **One-Way Dependency:** UI features may consume backend services, APIs, and data models, but the backend must never import or depend on UI components.
- **Global Namespace Hygiene:** Never declare local frame variables in the global scope `_G`. Attach elements exclusively to the private addon table (`local addonName, addonTable = ...`).

### Standard Feature Directory Layout
```text
<FeatureName>/
├── <FeatureName>Frame.lua      -- Root frame definition, layout, and visual hierarchy. No business logic.
├── <FeatureName>Controller.lua -- Event subscriptions, user input handling, and backend bridge.
├── <FeatureName>Presenter.lua  -- Data-to-view formatting, string localization, and view-models. Pure functions.
├── Components/                 -- Local, private sub-widgets used ONLY by this frame.
│   ├── SubComponentA.lua
│   └── SubComponentB.lua
└── index.lua                   -- Public entrypoint: initializes and exposes mount/unmount/toggle.
```

### UI Loading Constraints
When registering files in the `.toc` or `[feature].xml` manifest, always maintain this internal feature load order:
1. `Components/*.lua`
2. `<FeatureName>Presenter.lua`
3. `<FeatureName>Frame.lua`
4. `<FeatureName>Controller.lua`
5. `index.lua`

---

## 4. Code Quality & Safety Guardrails

- **Taint & State Protection:** Always deep-copy or proxy internal table references returned by public API getters so consuming addons cannot corrupt addon state.
- **Defensive API Contracts:** Validate types and values on every public API entry point (`assert` or clear error handling) before passing data to Controllers.
- **Namespace Isolation:** All internal modules must communicate strictly via the private namespace table passed by the WoW Lua loader (`local addonName, addonTable = ...`).
- **Dynamic Child Allocation:** If a frame uses dynamic rows/buttons (e.g., list views), use an internal object pool or sub-component factory strictly contained within the feature's `Components/` folder.
- **No Ad-Hoc Dependencies:** Adding third-party packages or Libs requires updating this `DESIGN.md` or `memory-bank/techContext.md` first.

---

> *By contributing to this repository, you agree to adhere to these principles. Any deviation must be explicitly justified and documented in a feature specification.*
