---
trigger: always_on
---

---
description: Micro-frontend UI rules, feature encapsulation, component hierarchy, and IPC interaction standards
globs: src/ui/**
---

# 03 - UI Micro-Frontends & Feature Encapsulation

## 1. Feature Autonomy & Boundary Isolation
* **Standalone Micro-Menus:** Each feature folder inside `src/ui/[feature]/` acts as an autonomous, self-contained UI window/menu (e.g., `sheet/`, `combat/`).
* **Zero Cross-Feature Imports:** UI features MUST NOT directly import, call, or reference frames, scripts, or hooks from other UI feature directories.
* **Zero Raw WoW Engine Events:** UI features MUST NOT attach raw Blizzard event handlers (`OnEvent`). All external data updates must be received asynchronously via the feature's local `api/[feature]Api.lua` IPC client.
* **Visibility & Navigation Lifecycle:** UI menus MUST NOT directly show/hide sibling frames or toggle cross-feature visibility. Views and sub-tabs MUST register as manageable pages via `GAC.navigation.page.registerPage({ id, frame, onPageShow, onPageHide })` and register sidebar/sub-menu options via `GAC.navigation.menu.registerMenu({ id, text, icon, pageId, isChildOf })` as specified in `DESIGN.md`.

## 2. Directory & Architectural Layers
Every feature directory (`src/ui/[feature]/`) must enforce a strict 4-layer separation:
* **`components/` (Views):** Owns XML frame definitions and visual templates. Strictly layout and styling; zero business calculations allowed.
* **`hooks/` (Local UI Handlers):** Encapsulates local visual state, tab switches, hover tooltips, frame dragging, and animation triggers.
* **`api/` (Isolated IPC Client):** Houses `[feature]Api.lua`, which serves as the exclusive communication bridge between the feature and `src/main/` via `LocalIPCAdapter`.
* **`index.lua` (Feature Orchestrator):** Serves as the single entry point that initializes the feature, binding `api/` data streams to `hooks/` and triggering visual component re-renders.

## 3. IPC Communication & Data Flow
* **Command Dispatching:** Features dispatch user intents to the backend exclusively using their local API client (e.g., `SheetAPI.requestStatUpgrade(statId)` -> `LocalIPCAdapter:Send(...)`).
* **Event Subscriptions:** Features subscribe to backend updates via internal IPC listeners in their API client (e.g., `SheetAPI.onSheetUpdated(callback)`).
* **Read-Only Visual Presentation:** UI components must never calculate game formulas (such as armor mitigation or initiative order); they only render final calculated values provided in IPC payloads.