# Memory Bank System — Custom RP & Turn-Based Combat Addon

This directory functions as the **AI Memory & Context Layer** for the project. It translates the master Software Design Document ([`CONTEXT.md`](../CONTEXT.md)) into structured, domain-specific memory files designed to keep AI coding assistants aligned with our system boundaries, architectural patterns, and execution context.

---

## 1. File Structure & Responsibilities

The memory bank consists of six specialized markdown files. Each file serves a distinct role in guiding AI development:

| File | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **`projectbrief.md`** | Core Scope & Purpose | Mission, target platform (Epsilon WoW Server), key dependencies (TRP3), and high-level boundaries. |
| **`productContext.md`** | Domain & System Rules | RPG tabletop mechanics, stat derivation rules, action point economy, and combat mechanics sourced from `/data/*.md`. |
| **`systemPatterns.md`** | Code Architecture | **Hexagonal Backend (`src/main/`)**, **Micro-Frontend UI Isolation (`src/ui/`)**, IPC Contracts, and Cascading XML Manifest rules. |
| **`techContext.md`** | Platform Constraints | WoW Lua 5.1/LuaJIT runtime rules, `SavedVariablesPerCharacter` constraints, and P2P messaging protocols. |
| **`activeContext.md`** | Current Focus State | Immediate sprint/phase tasks, active design decisions, and active work items. |
| **`progress.md`** | Roadmap & Status | Milestone tracker (Phase 1–5), completed features, remaining tasks, and known technical debt. |

---

## 2. Core Architectural Rules (For AI Agents)

When writing or refactoring code for this repository, AI engines **MUST** strictly adhere to the rules defined across the memory bank:

1. **Hexagonal Backend Boundary (`src/main/`):**
   * Files in `src/main/domain/` MUST remain pure Lua. **Zero WoW client APIs** (`CreateFrame`, `RegisterEvent`, `DEFAULT_CHAT_FRAME`) allowed.
   * WoW Client Events belong strictly in `src/main/adapters/events/` as incoming driving adapters.
2. **Micro-Frontend UI Isolation (`src/ui/`):**
   * UI features (`sheet/`, `combat/`) operate as standalone micro-applications with their own `components/`, `hooks/`, `api/`, and `index.lua`.
   * UI features MUST NOT directly import or call files from other UI features.
   * UI features MUST NOT register raw WoW client events—they communicate with the backend strictly via their local `api/[feature]Api.lua` IPC client.
3. **Storage Isolation:**
   * Player data uses `SavedVariablesPerCharacter` declared in the `.toc`.
   * Remote player sheet data (inspections) exists **only in memory** in `src/main/adapters/cache/` (volatile session cache) to prevent storage bloat.
4. **Cascading XML Manifests:**
   * Every directory under `src/` requires a `[folder].xml` manifest loaded bottom-up. Never inject dynamic Lua script loaders.

---

## 3. Memory Bank Maintenance Protocol

To prevent context drift and ensure continuity across AI coding sessions, follow this protocol:

### When Starting a New Task/Session
1. Read **`activeContext.md`** to identify the current phase and active focus.
2. Cross-reference **`systemPatterns.md`** and **`techContext.md`** before generating code.

### During Development
* Keep changes modular and adhere strictly to the Hexagonal / Micro-UI layer boundaries.

### When Ending a Task/Session
1. Update **`progress.md`** to check off completed tasks and mark new milestones.
2. Update **`activeContext.md`** with the next immediate steps or architectural decisions made during the session.

---

## 4. Relationship to `CONTEXT.md`

* **`CONTEXT.md` (Repository Root):** The immutable, human-readable master Software Design Document (SDD).
* **`memory-bank/` (This Directory):** The dynamic, machine-optimized context layer derived from `CONTEXT.md`. It tracks real-time progress, file locations, and implementation details during active coding.