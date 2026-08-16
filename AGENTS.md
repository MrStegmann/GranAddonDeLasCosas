# AGENTS.md

> Operational guidelines and runtime directives for AI Agents working within this repository.

---

## 1. Core Principle: Spec-Driven Development (SDD)

This repository strictly enforces **Spec-Driven Development**. No feature code, refactoring, or architectural modifications may be introduced without an approved specification and updated context files.


```

┌─────────────────┐      ┌─────────────────┐     ┌─────────────────┐
│   memory-bank/  │  ──> │ specs/[feature] │ ──> │ Implementation  │
│ (System State)  │      │ (Feature Scope) │     │   & Validation  │
└─────────────────┘      └─────────────────┘     └─────────────────┘

```

### Golden Rules
1. **Never write code before specs**: If a task touches business logic or features, verify or create its corresponding entry in `specs/[xxx-feature]/`.
2. **Preserve hierarchy of truth**: Global design rules (`DESIGN.md`) override local feature specs. System memory (`memory-bank/`) reflects active repository reality.
3. **Atomic changes**: Each unit of work must trace directly back to an unchecked item in a feature's `tasks.md`.

---

## 2. Context Architecture & Hierarchy of Truth

| Artifact | Purpose | Read When | Update When |
| :--- | :--- | :--- | :--- |
| `memory-bank/` | Global agent state, active goals, tech stack, patterns | Starting any session | New patterns emerge, session goals finish |
| `specs/[feature]/` | Feature-level specs, task breakdown, criteria, tests | Implementing specific tasks | Feature planning, task completion |
| Source Code (`src/`) | Concrete implementation | Executing tasks | Actively coding |

---

## 3. Directory Layout for Features

Every new capability or major refactor lives inside `specs/[xxx-feature]/` using kebab-case:


```

specs/
└── 001-user-auth/
├── spec.md         # Requirements, user stories, edge cases, acceptance criteria
├── tasks.md        # Granular, checklist-driven execution plan
└── test-plan.md    # Unit, integration, and E2E scenarios

```

### Standard `specs/[xxx-feature]/spec.md` Structure
```markdown
# Feature: [Feature Name]

## 1. Context & Motivation
Brief explanation of why this feature exists and the problem it solves.

## 2. Requirements
- **FR-1**: Functional requirement with clear invariants.
- **NFR-1**: Performance, security, or design constraints.

## 3. Interface & Contract Changes
- API endpoints, schemas, database models, or UI contracts.

## 4. Edge Cases & Failure Modes
- Explicit listing of edge cases and error-handling behavior.

## 5. Acceptance Criteria
- [ ] Criterion 1 (measurable, verifiable)
- [ ] Criterion 2

```

### Standard `specs/[xxx-feature]/tasks.md` Structure

```markdown
# Tasks: [Feature Name]

- [ ] **Phase 1: Contracts & Interfaces**
  - [ ] Task 1.1: Define TypeScript/Schema types
  - [ ] Task 1.2: Mock endpoint/data layer
- [ ] **Phase 2: Core Implementation**
  - [ ] Task 2.1: Write failing unit tests
  - [ ] Task 2.2: Implement domain logic
- [ ] **Phase 3: Integration & Polish**
  - [ ] Task 3.1: Integration tests
  - [ ] Task 3.2: Update memory-bank and close feature

```

---

## 4. Agent Execution Lifecycle

When assigned a prompt or task, execute in strictly ordered phases:

### Phase 1: Context Hydration

1. Read `memory-bank/activeContext.md` and `DESIGN.md` to understand existing paradigms.
2. Locate the active feature in `specs/`. If none exists, initiate the **Spec Authoring Workflow**.

### Phase 2: Spec Alignment

1. Compare user requirements against `specs/[feature]/spec.md`.
2. Break down implementation into checklist items in `specs/[feature]/tasks.md`.
3. Stop and confirm with the user if architectural conflicts with `DESIGN.md` arise.

### Phase 3: Test-First Execution

1. Implement test cases defined in `specs/[feature]/test-plan.md`.
2. Implement code incrementally to pass the tests.
3. Check off completed items in `specs/[feature]/tasks.md` as they are finalized.

### Phase 4: Sync & Memory Consolidation

1. Run linter, type checks, and test suites to ensure zero regressions.
2. Update `memory-bank/` files (`progress.md`, `activeContext.md`) with the new status.
3. If new architectural patterns were introduced, document them in `DESIGN.md`.

---

## 5. Agent Operational Constraints

* **No Premature Deletions:** Do not remove files in `specs/` after completion; mark them as completed/archived in `memory-bank/progress.md`.
* **No Ad-Hoc Dependencies:** Adding third-party packages requires updating `DESIGN.md` or `memory-bank/techContext.md` first.
* **Deterministic Responses:** When reporting progress to the user, reference specific task IDs (e.g., `Task 2.1 in specs/001-user-auth/tasks.md completed`).
