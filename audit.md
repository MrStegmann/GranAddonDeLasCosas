# Codebase Audit & Compliance Report: Gran Addon De Las Cosas (GAC_DEV)

**Date**: 2026-09-18  
**Target Client**: World of Warcraft Retail / Epsilon WoW (`Interface: 90207`)  
**Governing Document**: [.specify/memory/constitution.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/.specify/memory/constitution.md) (v1.2.0) & [AGENTS.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/AGENTS.md)

---

## Executive Summary

An exhaustive architectural audit was conducted across the `GAC_DEV` codebase, evaluating every XML manifest and Lua source module against the **8 Core Constitution Principles** and **AGENTS.md Guidelines**. 

While the codebase features a structured directory layout (`Communication/`, `Data/`, `Events/`, `Frames/`, `Locales/`, `Utils/`), it contains **systemic violations** of XML manifest syntax, widespread hardcoded user-facing strings, lack of TDD/unit testing, missing Flux unidirectional data architecture, violations of SOLID design principles, underutilized error handling, and unexposed global namespaces.

---

## Compliance Scorecard

| Principle / Rule | Compliance Status | Severity | Primary Deficiencies |
| :--- | :--- | :--- | :--- |
| **Principle I: Clean Global `_G` & Namespace** | ⚠️ Non-Compliant | HIGH | `_G.GAC` is never set; no clean global access point defined. |
| **Principle II: XML Manifest & UI Declarations** | ❌ Systemic Failure | CRITICAL | Inverted XML tags (`<Include file="*.lua"/>` & `<Script file="*.xml"/>`) throughout manifests; UI hardcoded imperatively in Lua rather than XML. |
| **Principle III: Separation of Concerns** | ⚠️ Non-Compliant | HIGH | Business logic, state mutations, and UI creation tightly coupled inside screen files. |
| **Principle IV: TDD & Safe API Calling** | ❌ Systemic Failure | CRITICAL | 0 unit tests exist; `SafeCall` underutilized (only 5 calls); duplicate `safeCall` implementation in `TRP3Bridge.lua`. |
| **Principle V: Addon Ecosystem & Libs** | ⚠️ Non-Compliant | MEDIUM | Raw global TRP3 checks without standard library support (LibStub/Ace3). |
| **Principle VI: Localization & Naming** | ❌ Systemic Failure | CRITICAL | Hundreds of hardcoded Spanish/English UI strings across components and screens instead of routing through `Locales`. |
| **Principle VII: Flux UI Architecture** | ❌ Not Implemented | CRITICAL | No Dispatcher/Store/Action architecture; UI OnClick handlers directly mutate `GranAddonDeLasCosasCharDB`. |
| **Principle VIII: SOLID Design Principles** | ⚠️ Non-Compliant | HIGH | Single Responsibility & Dependency Inversion violations across monolithic UI screen scripts and tightly coupled handlers. |

---

## Detailed Findings & Code Mismatches

### 1. Principle I: Clean Global `_G` & Private Addon Namespace
- **Issue**: `_G.GAC` or `_G.GranAddonDeLasCosas` is never initialized or exported in [src/index.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/index.lua).
- **Impact**: External macros, slash commands, or XML script handlers calling `GAC:Method()` will throw global nil runtime errors if `addonTable` is not in scope.
- **Affected File**: [src/index.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/index.lua#L1-L10)

---

### 2. Principle II: XML Manifest & UI Schema Violations
- **Issue A (Root Manifest Tag Misuse)**: In [GranAddonDeLasCosas.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/GranAddonDeLasCosas.xml#L3), line 3 uses `<Script file="src\GAC.xml"/>` to include an XML file. In WoW XML schema, loading XML requires `<Include file="..."/>`.
- **Issue B (Systemic Tag Inversion)**: Virtually all secondary XML manifests use `<Include file="*.lua"/>` to load Lua files instead of `<Script file="*.lua"/>`.
  - [src/Communication/Communication.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Communication/Communication.xml#L3-L6) (`TRP3Bridge.lua`, `Transmitter.lua`, `Receiver.lua`, `GroupEvents.lua`)
  - [src/Data/Data.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Data/Data.xml#L3-L8) (`AttributesAndTalents.lua`, `LevelTable.lua`, `WorgenTable.lua`, `Armor.lua`, `Weapons.lua`, `Shield.lua`)
  - [src/Utils/Utils.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Utils/Utils.xml#L3-L4) (`VersionBridge.lua`, `Helpers.lua`)
  - [src/Frames/UI/UI.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/UI/UI.xml#L3-L6) (`ExpBar.lua`, `PlayerPlate.lua`, `TargetPlate.lua`, `RaidPlate.lua`)
  - [src/Frames/MainMenu/Screens/Screens.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/MainMenu/Screens/Screens.xml#L3-L5)
  - [src/Frames/MainMenu/Components/Components.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/MainMenu/Components/Components.xml#L3-L7)
  - [src/Frames/QuickButtonsMenu/Components/Components.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/QuickButtonsMenu/Components/Components.xml#L3-L5)
  - [src/Frames/InitiativeOrders/Components/Components.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/InitiativeOrders/Components/Components.xml#L3-L4)
- **Issue C (Lack of XML UI Templates)**: UI panels and controls are imperatively created in Lua via `CreateFrame` rather than using XML frame templates for structural layout.

---

### 3. Principle III, VII & VIII: Separation of Concerns, Flux Architecture & SOLID Principles
- **Issue A (Direct State Mutation & Single Responsibility Violation)**: OnClick handlers in screen files directly mutate persistent saved variables (`GranAddonDeLasCosasCharDB`) and synchronously update UI components.
  - [src/Frames/MainMenu/Screens/CharSheetContent.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/MainMenu/Screens/CharSheetContent.lua#L166-L180) (`saveProgBtn:SetScript("OnClick", ...)` directly modifies `characterData.progress` and calls level calculations inline).
  - [src/Frames/MainMenu/Screens/ExperienceConfigurator.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/MainMenu/Screens/ExperienceConfigurator.lua#L30-L80)
  - [src/Frames/QuickButtonsMenu/index.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/QuickButtonsMenu/index.lua#L100-L140)
- **Issue B (Missing Flux Infrastructure)**: No `Dispatcher`, `Store`, or `Action` system exists to decouple user actions from application state updates and view re-rendering.
- **Issue C (Dependency Inversion Violation)**: High-level UI screens depend directly on concrete global WoW frames (e.g. `TargetFrameHealthBar`, `PlayerLevelText`) rather than depending on decoupled view adapters or event bus interfaces.

---

### 4. Principle IV: TDD & Safe API Calling Deficiencies
- **Issue A (Missing Unit Tests)**: Domain logic files ([src/Data/LevelTable.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Data/LevelTable.lua), [src/Data/Armor.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Data/Armor.lua), [src/Utils/Helpers.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Utils/Helpers.lua)) lack automated unit tests for math formulas, stat progression, and roll parsing.
- **Issue B (Underutilized `SafeCall`)**: `GAC:SafeCall` is defined in [src/Utils/Helpers.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Utils/Helpers.lua#L103) but only called in 5 places across the entire codebase.
- **Issue C (Duplicate `safeCall` Implementation)**: [src/Communication/TRP3Bridge.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Communication/TRP3Bridge.lua#L36) defines a local `safeCall(fn, ...)` using raw `pcall` instead of using `GAC:SafeCall`.

---

### 5. Principle VI: Localization Violations
- **Issue**: User-facing text strings are hardcoded directly into Lua files and XML definitions instead of referencing `GAC.Locales` / `GAC:_("key")`.
- **Primary Violation Examples**:
  - [src/Frames/MainMenu/Screens/CharSheetContent.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/MainMenu/Screens/CharSheetContent.lua#L112-L163) (`"Escribe aquí el trasfondo de tu personaje..."`, `"Guardar Historia"`, `"Guardar Progresión"`, `"Información de Nivel Disponible"`, `"Salud Máxima"`, `"Ranuras de hechisos/habilidadeh"`)
  - [src/Frames/MainMenu/Screens/ExperienceConfigurator.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/MainMenu/Screens/ExperienceConfigurator.lua#L10-L66) (`"Experiencia"`, `"Experiencia recibida:"`, `"Nivel Actual: %d (%s)"`, `"Nivel Máximo Alcanzado"`)
  - [src/Frames/MainMenu/Screens/InventoryContent.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/MainMenu/Screens/InventoryContent.lua#L474-L476) (`"* Comb. Inválidas:\n"`, `"* No cumples con los requisitos *"`)
  - [src/Frames/QuickButtonsMenu/index.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/QuickButtonsMenu/index.lua#L109-L430) (`"Aceptar"`, `"Mod"`, `"Dado"`)
  - [src/Frames/TestTalentTree/index.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/TestTalentTree/index.lua#L87-L89) (`"Tree 1"`, `"Tree 2"`, `"Tree 3"`)

---

## Remediation Task List

### Phase 1: Critical Fixes & Infrastructure Setup
- [ ] **Task 1.1: Fix Root Manifest XML Tag**
  - Change line 3 in `GranAddonDeLasCosas.xml` from `<Script file="src\GAC.xml"/>` to `<Include file="src\GAC.xml"/>`.
- [ ] **Task 1.2: Fix Submanifest XML/Lua Tag Inversion**
  - Audit and update all submanifest XML files (`Communication.xml`, `Data.xml`, `Utils.xml`, `UI.xml`, `Components.xml`, `Screens.xml`, `Hooks.xml`) to use `<Script file="*.lua"/>` for Lua source files.
- [ ] **Task 1.3: Expose Global `GAC` Namespace**
  - Update `src/index.lua` to bind `_G.GAC = GAC` and `_G.GranAddonDeLasCosas = GAC`.

### Phase 2: Flux UI Architecture & SOLID Refactoring
- [ ] **Task 2.1: Implement Core Flux Dispatcher & Store**
  - Create `src/Core/Dispatcher.lua` and `src/Core/Store.lua` for handling Action dispatching and state subscription listeners.
- [ ] **Task 2.2: Refactor UI Screens to Dispatch Actions (SRP & DIP)**
  - Refactor `CharSheetContent.lua`, `ExperienceConfigurator.lua`, and `QuickButtonsMenu/index.lua` OnClick handlers to dispatch Actions (`GAC.Dispatcher:Dispatch(GAC.Actions.UPDATE_PROGRESS, payload)`) instead of inline state mutation.
- [ ] **Task 2.3: Subscribe Views to Store Changes**
  - Bind UI views to Store change events (`GAC.Store:Subscribe(renderFunction)`).

### Phase 3: Error Handling & TDD Integration
- [ ] **Task 3.1: Enforce Central `GAC:SafeCall`**
  - Remove duplicate `safeCall` in `TRP3Bridge.lua`. Wrap all external TRP3 API calls, network handlers in `Receiver.lua`, and risky UI handlers with `GAC:SafeCall`.
- [ ] **Task 3.2: Establish Unit Test Suite**
  - Create unit tests for `LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua` to ensure RPG math calculations are fully test-backed.

### Phase 4: Full Localization & Code Cleanup
- [ ] **Task 4.1: Extract Hardcoded Strings to Locales**
  - Move all hardcoded UI strings from `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `InventoryContent.lua`, and `QuickButtonsMenu/index.lua` into `src/Locales/ES_es.lua`.
- [ ] **Task 4.2: Replace UI Labels with `GAC:_("key")`**
  - Update UI script code to reference locale keys via `GAC:_("KEY")`.
