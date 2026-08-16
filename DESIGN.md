# DESIGN.md — Architecture & Design Pattern Standard (Total RP 3 Abstraction)

This document establishes the official design patterns and architectural standards for **GAC_DEV**, abstracted directly from the proven architecture of **Total RP 3** (`totalRP3`) and adapted to our **Hexagonal Backend + Micro-Frontend UI Architecture**.

All developers and **AI Code Assistants MUST strictly adhere to the patterns documented herein** when designing, refactoring, or implementing features.

---

## 1. Executive Architecture Summary

GAC_DEV combines Hexagonal Domain Isolation with Total RP 3's **Declarative Navigation & Page Container Pattern**.

```text
┌───────────────────────────────────────────────────────────────────────────────────┐
│                                   AddOn Orchestrator                              │
│             (Lifecycle Manager: OnInitialize -> applyPatches -> startModules)     │
└─────────────────────────┬─────────────────────────────────┬───────────────────────┘
                          │                                 │
                          ▼                                 ▼
┌─────────────────────────────────────────┐     ┌───────────────────────────────────┐
│            UI Micro-Frontends           │     │          Hexagonal Backend        │
│          (src/ui/[feature]/)            │     │            (src/main/)            │
│ ┌─────────────────────────────────────┐ │     │ ┌───────────────────────────────┐ │
│ │ GAC.navigation (Page Container API) │ │     │ │ Domain Core (Pure Lua 5.1)    │ │
│ ├─────────────────────────────────────┤ │ IPC │ ├───────────────────────────────┤ │
│ │ Local IPC API Client ([feature]Api) ├─┼─────┼─┤ Ports & Adapters (DB/Network) │ │
│ └─────────────────────────────────────┘ │ Bus │ └───────────────────────────────┘ │
└─────────────────────────────────────────┘     └───────────────────────────────────┘
```

---

## 2. Core Abstracted Design Patterns

### Pattern 1: Declarative Navigation & Page Container Pattern (`GAC.navigation`)

UI features MUST NOT manually toggle visibility (`Show()` / `Hide()`) of other feature frames or couple directly to sibling frames. All UI windows and tabs interact strictly with a central **Page Container Engine** (`GAC.navigation`).

#### 1. Main Frame Hierarchy (XML Structure)
The main window contains two primary sub-containers:
* `GAC_MainFrameMenuContainer`: Left sidebar containing dynamically generated navigation buttons.
* `GAC_MainFramePageContainer`: Right content view hosting exactly **one active page frame** at a time.

```xml
<Frame name="GAC_MainFrame" parent="UIParent" inheritable="true" hidden="true">
    <Frames>
        <!-- Sidebar Navigation Menu Container -->
        <Frame name="GAC_MainFrameMenuContainer" parentKey="MenuContainer">
            <Anchors>
                <Anchor point="TOPLEFT" x="10" y="-30"/>
                <Anchor point="BOTTOMLEFT" x="10" y="10"/>
            </Anchors>
        </Frame>
        <!-- Active Page Content Container -->
        <Frame name="GAC_MainFramePageContainer" parentKey="PageContainer">
            <Anchors>
                <Anchor point="TOPLEFT" relativeTo="GAC_MainFrameMenuContainer" relativePoint="TOPRIGHT" x="10" y="0"/>
                <Anchor point="BOTTOMRIGHT" x="-10" y="10"/>
            </Anchors>
        </Frame>
    </Frames>
</Frame>
```

#### 2. Declarative Page Registration (`registerPage`)
Every content view frame registers itself as a manageable page:

```lua
GAC.navigation.page.registerPage({
    id = "character_info",
    frame = GAC_CharacterInfoFrame,
    onPageShow = function(pageID, ...)
        -- Fetch refreshed state via local IPC client API
        CharacterInfoAPI.refreshView();
    end,
    onPageHide = function(pageID)
        -- Cleanup tooltips, local state, or active animations
    end,
})
```

#### 3. Declarative Menu/Tab Registration (`registerMenu`)
Sidebar categories and nested sub-tabs register declaratively:

```lua
-- Top-Level Category
GAC.navigation.menu.registerMenu({
    id = "main_01_character",
    text = "Personaje",
    icon = "Interface\\Icons\\Achievement_GuildPerk_MobileBanking",
    pageId = "character_info",
    isChildOf = nil,
})

-- Nested Sub-Tab under "Personaje"
GAC.navigation.menu.registerMenu({
    id = "character_02_attributes",
    text = "Atributos",
    icon = "Interface\\Icons\\Attribute_Icon",
    pageId = "character_attributes",
    isChildOf = "main_01_character",
})
```

#### 4. Navigation Controller Lifecycle (`selectMenu`)
When a user clicks a navigation button:
1. `GAC.navigation.menu.selectMenu(menuID)` is invoked.
2. Hides all currently mounted frames inside `GAC_MainFramePageContainer`.
3. Highlights the active menu button in `GAC_MainFrameMenuContainer`.
4. Reparents and anchors the target page `frame` inside `GAC_MainFramePageContainer` and calls `Frame:Show()`.
5. Fires the target page's `onPageShow(pageID, ...)` callback.

---

### Pattern 2: Application Lifecycle & Module Manager (`GAC.module`)

The addon initialization sequence follows a deterministic multi-stage lifecycle to prevent race conditions:

```lua
local function loadingSequence()
    -- Stage 1: Load environment globals and SavedVariables schema patches
    GAC.flyway.applyPatches();

    -- Stage 2: Initialize Localization Service
    GAC.Locale.init();

    -- Stage 3: Module Structures Initialization
    GAC.module.init();
    GAC.module.initModules();

    -- Stage 4: Navigation Core Setup
    GAC.navigation.init();

    -- Stage 5: Signal Workflow Pre-Load Event
    GAC.events.fireEvent(GAC.events.WORKFLOW_ON_LOAD);

    -- Stage 6: Start Sub-Modules
    GAC.module.startModules();

    -- Stage 7: Select Default Initial Menu
    GAC.navigation.menu.selectMenu("main_01_character");

    -- Stage 8: Signal Workflow Completion Events
    GAC.events.fireEvent(GAC.events.WORKFLOW_ON_LOADED);
    GAC.events.fireEvent(GAC.events.WORKFLOW_ON_FINISH);
end
```

---

### Pattern 3: Decoupled Workflow & Event Bus (`GAC.events`)

Modules publish and subscribe to system lifecycle signals without direct module-to-module dependencies:

```lua
-- Register subscriber
GAC.events.registerEvent(GAC.events.CHARACTER_DATA_UPDATED, function(characterData)
    -- Handle updated character data
end);

-- Dispatch publisher event
GAC.events.fireEvent(GAC.events.CHARACTER_DATA_UPDATED, updatedData);
```

**Standard Workflow Events:**
* `WORKFLOW_ON_LOAD`: Triggered before modules activate.
* `WORKFLOW_ON_LOADED`: Triggered after all modules are initialized.
* `WORKFLOW_ON_FINISH`: Triggered when UI navigation and initial views are ready.
* `CHARACTER_DATA_UPDATED`: Dispatched when backend character attributes or stats mutate.
* `NAVIGATION_RESIZED`: Dispatched when main container dimensions change.

---

### Pattern 4: Flyway Schema Migration Pattern (`GAC.flyway`)

To ensure persistence compatibility across addon updates, `SavedVariablesPerCharacter` changes route through sequential migration patches executed during startup:

```lua
local patches = {
    [1] = function(savedDB)
        -- Migrate v1 schema (flat stats) to v2 schema (nested attributes)
        savedDB.attributes = savedDB.attributes or {};
        savedDB.schemaVersion = 1;
    end,
    [2] = function(savedDB)
        -- Migrate v2 schema (heroic points addition)
        savedDB.heroicPoints = savedDB.heroicPoints or 0;
        savedDB.schemaVersion = 2;
    end,
}

function GAC.flyway.applyPatches()
    local db = GAC_CharacterDB;
    local currentVersion = db.schemaVersion or 0;
    for version = currentVersion + 1, #patches do
        patches[version](db);
    end
end
```

---

### Pattern 5: Template-Based XML Component Factories

UI controls use reusable XML templates declared with `Virtual="true"`, ensuring visual consistency and performance reuse:

* `GAC_CategoryButton`: Standardized menu button with label, icon, and highlight textures.
* `GAC_ScrollableContainer`: Reusable scroll frame container for long forms or tab content.
* `GAC_CommonButton`: Standardized action button component.

---

## 3. Mandatory AI Code Assistant Rules

Whenever an AI Code Assistant works on UI features, navigation, or module orchestration, it MUST follow these rules:

1. **NEVER call `Show()` or `Hide()` across UI feature boundaries directly.** Always route tab switching and view activation through `GAC.navigation.menu.selectMenu(menuID)`.
2. **Every UI view frame MUST register as a page** using `GAC.navigation.page.registerPage(...)`.
3. **Every sidebar option or sub-tab MUST register declaratively** using `GAC.navigation.menu.registerMenu(...)`.
4. **UI components MUST NOT attach raw Blizzard engine event listeners (`OnEvent`).** All external updates must be received asynchronously via `LocalIPCAdapter` or `GAC.events`.
5. **SavedVariables schema modifications MUST include a Flyway migration script** in `GAC.flyway`.
