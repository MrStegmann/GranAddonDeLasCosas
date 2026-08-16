---
trigger: always_on
---

---
name: "Feature-based Architecture Pattern"
description: "Ensure AI Agent always create files following the Feature-based Architecture Pattern for every Frame created. All Frames created must be treaty as a isolated independent UI with is main folder (e.g., the main menu will live in `src/ui/MainMenu/`, and the folder is builder as a UI project that does not now about other UI frames, only backend)."
globs: `src/ui/**/*.lua`
---

# Feature-Based UI Architecture Rule

## 1. Core Principles
* **Feature Isolation:** Every UI Frame or distinct view is a standalone feature located in its own dedicated directory (`src/ui/<FeatureName>/`).
* **Zero Cross-UI Knowledge:** A feature frame must never require, import, reference, or mutate another feature frame directly. Intra-UI coordination must occur strictly through `src/main/` layers.
* **One-Way Dependency:** UI features may consume backend services, APIs, and data models (`src/main/core/`, `src/main/services/`, `src/main/api/`, etc.), but the backend must never import or depend on UI components.

## 2. Directory Structure per Feature Frame
Every feature frame inside `src/ui/<FeatureName>/` must strictly adhere to the following internal layout:

```text
src/ui/<FeatureName>/
├── <FeatureName>Frame.lua      -- Root frame definition, layout, and visual hierarchy
├── <FeatureName>Controller.lua -- Event subscriptions, user input handling, and backend bridge
├── <FeatureName>Presenter.lua  -- Data-to-view formatting, string localization, and view-models
├── Components/                 -- Local, private sub-widgets used ONLY by this frame
│   ├── SubComponentA.lua
│   └── SubComponentB.lua
└── index.lua                   -- Public entrypoint: initializes and exposes mount/unmount/toggle

```

## 3. Layer Responsibilities & Boundaries

### 3.1. Frame (`<FeatureName>Frame.lua` & `Components/`)

* **Role:** Pure visual definition, frame instantiation (`CreateFrame`), layouts, anchors, templates, fonts, and textures.
* **Constraints:**
* Must **NOT** contain business logic, direct backend API queries, or persistence logic.
* Must expose explicit UI mutation methods (e.g., `SetTitleText(str)`, `RenderList(items)`) instead of allowing external modules to manipulate child elements directly.
* Sub-components in `Components/` are private to this feature and must not be imported outside `src/ui/<FeatureName>/`.


### 3.2. Presenter (`<FeatureName>Presenter.lua`)

* **Role:** Transforms raw backend data/DTOs into formatted view-models suitable for display (e.g., color formatting, timestamps, currency strings).
* **Constraints:**
* Must be pure/deterministic Lua functions where possible.
* Must **NOT** mutate the actual backend models or database state.

### 3.3. Controller (`<FeatureName>Controller.lua`)

* **Role:** The orchestration bridge between the UI and the Backend.
* Handles frame script hooks (`OnClick`, `OnShow`, `OnHide`, `OnDrag`).
* Subscribes to backend event messages / callbacks.
* Calls backend APIs to fetch or mutate domain state, passes returned data to the Presenter, and updates the Frame.

* **Constraints:**
* Must **NOT** contain hardcoded UI layout logic or direct visual coordinate definitions.

### 3.4. Entrypoint (`index.lua`)

* **Role:** Initializes the feature module within the addon namespace and exposes standard lifecycle control.
* **Standard Interface:**
* `Init(parent)`
* `Show()`
* `Hide()`
* `Toggle()`
* `Destroy()` / `Reset()`


## 4. Architectural Constraints & Code Guardrails

1. **Forbidden Cross-Imports:** Never access `_G.AnotherFeatureFrame` or `addonTable.UI.AnotherFeature` inside `<FeatureName>`.
2. **Global Namespace Hygiene:** Never declare local frame variables in the global scope `_G`. Attach elements exclusively to the private addon table (`local addonName, addonTable = ...`).
3. **Dynamic Child Allocation:** If a frame uses dynamic rows/buttons (e.g., list views), use an internal object pool or sub-component factory strictly contained within the feature's `Components/` folder.
4. **TOC Load Order:** When registering files in the `.toc` file, always maintain this internal feature load order:
1. `Components/*.lua`
2. `<FeatureName>Presenter.lua`
3. `<FeatureName>Frame.lua`
4. `<FeatureName>Controller.lua`
5. `index.lua`
