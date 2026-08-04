---
trigger: always_on
---

---
description: Domain layer purity rules for business logic, math, and tabletop rules
globs: src/main/domain/**
---

# 01 - Domain Purity & Business Logic Isolation

## 1. Domain Boundary & Environment Isolation
* **Pure Lua Execution:** All files inside `src/main/domain/` MUST consist strictly of pure Lua 5.1 logic.
* **Zero Client Coupling:** NEVER invoke World of Warcraft Client APIs (e.g., `CreateFrame`, `RegisterEvent`, `C_ChatInfo`, `DEFAULT_CHAT_FRAME`, `UnitName`).
* **Zero UI Awareness:** Domain models must have zero knowledge of frames, buttons, XML layouts, or presentation states.
* **No Storage or Third-Party Globals:** Do NOT directly reference `SavedVariablesPerCharacter`, `TRP3`, or external addon globals.

## 2. Ports & Data Contracts
* **Inbound Communication:** Domain logic must only be triggered via direct function calls or through contracts defined in `src/main/ports/`.
* **Outbound Communication:** All external interactions (e.g., persisting state, sending messages over network, fetching remote profiles) MUST route through abstract Ports.
* **Stateless Calculations:** Math calculators (e.g., stat derived values, dice engine rolls) should prefer pure, deterministic inputs and returns without side-effects.

## 3. Data Specification Alignment
* **Single Source of Rules:** Business formulas, combat initiative sequencing, and stat allocation algorithms must strictly implement the specs defined in `/data/*.md`.
* **No Spec Hardcoding:** Dynamic rules (such as skill lists or attribute cost tables) should be loaded via data structures rather than hardcoded string logic.
* **Explicit Returns:** Domain entities and state engines must explicitly return clean data tables without injecting Blizzard UI or environment metadata.