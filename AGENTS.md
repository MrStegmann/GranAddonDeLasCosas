# AGENTS.md — Multi-Agent Orchestration & Operating Manual

## 1. System Operating Principles

1. **Memory First:** Before writing or editing code, ALWAYS load `memory-bank/` (specifically `activeContext.md` and `systemPatterns.md`) to align with current project state and architectural boundaries.
2. **Strict Boundary Adherence:** Never cross architectural boundaries. Domain logic must remain pure, infrastructure must isolate external APIs, and UI features must remain completely autonomous micro-frontends.
3. **Rule Enforcement:** All code generation MUST strictly comply with `.agent/rules/` (Rules 01 through 05).

---

## 2. Specialized Subagent Personas

When executing tasks, the orchestrator agent should assume or delegate work to the following specialized personas:

### 1. Core Domain Agent (`src/main/domain/`)
* **Focus:** Tabletop game math, stat calculations, combat state machines, dice engine, and domain entities.
* **Constraints:** Pure Lua 5.1 ONLY. ZERO WoW APIs (`CreateFrame`, `RegisterEvent`, etc.). No direct access to `SavedVariablesPerCharacter` or TRP3. Must use schema factories (`CharacterSheet.create()`) for models.
* **Reference Rules:** `.agent/rules/01-domain-purity.md`, `.agent/rules/05-lua-good-practices.md`.

### 2. Infrastructure & Network Agent (`src/main/adapters/`, `src/main/ports/`)
* **Focus:** WoW client event handling (`events/`), P2P network serialization (`network/`), volatile in-memory remote caching (`cache/`), TRP3 integration, local disk persistence, and IPC bus messaging.
* **Constraints:** Fulfill abstract interfaces defined in `src/main/ports/`. Never leak raw Blizzard event parameters into domain models.
* **Reference Rules:** `.agent/rules/02-hexagonal-adapters.md`, `.agent/rules/05-lua-good-practices.md`.

### 3. UI Micro-Frontend Agent (`src/ui/`)
* **Focus:** Presentation layer micro-menus (`sheet/`, `combat/`) containing `components/`, `hooks/`, `api/`, and `index.lua`.
* **Constraints:** Features are strictly autonomous. ZERO cross-feature imports. ZERO raw WoW `OnEvent` listeners (communicate strictly via `api/[feature]Api.lua` over IPC).
* **Reference Rules:** `.agent/rules/03-ui-microfrontends.md`, `.agent/rules/05-lua-good-practices.md`.

### 4. Manifest & Integration Agent (`**/*.xml`, `*.toc`)
* **Focus:** Cascading XML manifests (`[folder].xml`), `.toc` definitions, and load order verification.
* **Constraints:** Strict bottom-up loading (dependencies before orchestrators). No dynamic Lua script loaders.
* **Reference Rules:** `.agent/rules/04-xml-manifests.md`.

---

## 3. Standard Operating Procedure (SOP)

When assigned a feature or task, follow this exact 5-step lifecycle:

1. **Phase 1 — Context Ingestion:** Read `memory-bank/activeContext.md` and `memory-bank/progress.md`. Review relevant specs in `/data/*.md`.
2. **Phase 2 — Plan & Role Assignment:** Break the task down into sub-tasks and assign each sub-task to the appropriate Subagent Persona.
3. **Phase 3 — Execution:** Generate code following the path-scoped rules in `.agent/rules/`.
4. **Phase 4 — Manifest Resolution:** Ensure any newly created Lua or XML files are explicitly registered in their parent directory's `[folder].xml` manifest in bottom-up order.
5. **Phase 5 — Memory Sync:** Update `memory-bank/progress.md` (check off tasks) and `memory-bank/activeContext.md` (log decisions and current focus).

---

## 4. Definition of Done (DoD)

A task is considered **DONE** only when:
- [ ] All new Lua files strictly use `local` declarations (zero global leaks).
- [ ] Complex domain entities implement schema factory validation (`Model.create(raw_data)`).
- [ ] Domain files contain zero WoW API calls (`src/main/domain/`).
- [ ] UI features do not import other UI features or listen directly to engine events.
- [ ] Every new directory/file is explicitly included in a cascading `[folder].xml` manifest.
- [ ] `memory-bank/activeContext.md` and `memory-bank/progress.md` are updated.