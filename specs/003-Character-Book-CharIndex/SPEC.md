# Character Book

## Context & Goal
- **Goal**: UI Frame for managing player Character Sheet. 
- **Relevant Files**:
  - `src/ui/CharacterBook/CharacterBook.xml` (Manifest)
  - `src/ui/CharacterBook/index.xml` (Main Frame)
  - `src/ui/CharacterBook/components/**/*.xml` (Components Frames)
  - `src/ui/CharacterBook/api/*.lua` (Local API calls to domain adapters grouped by components/feature)
  - `src/ui/CharacterBook/hooks/*.lua` (Local Hooks)
  - `src/ui/CharacterBook/utils/*.lua` (Local Utils)

## Requirements
- [ ] Must have a minimap button with a Book icon AND draggable and movable around minimap AND persist last position.
- [ ] Must have a main frame with 45% VW x 75% VH AND border AND "X" close button AND background AND two columns with a sidebar with 25%W x full H AND main content area with 75%W x full H.
- [ ] Must have a "Personaje" option in sidebar for main navigation index preselected.
- [ ] Must have a ["Información", "Atributos", "Rasgos", "Heroicas", "Hechizos y Habilidades"] tabs in the content area in "Personaje".
- [ ] Must use Character model `src/main/domain/models/Character.lua` for save all data data.
- [ ] Must use Heroic model `src/main/domain/models/Heroic.lua` for save all data data.
- [ ] Must use Skill model `src/main/domain/models/Skill.lua` for save all data data.
- [ ] Must use Spell model `src/main/domain/models/Spell.lua` for save all data data.

## Technical Approach & Constraints
- **Pattern**: TRP3 Abstracted Declarative Navigation & Page Container Pattern (`GAC.navigation.page.registerPage`, `GAC.navigation.menu.registerMenu`, `GAC.navigation.menu.selectMenu`) as specified in [DESIGN.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/DESIGN.md) & Micro-Frontend UI Architecture (`src/ui/CharacterBook/`).
- **Dependencies**: `LibDBIcon-1.0` (Minimap Button position persistence), `LocalIPCAdapter` (IPC Communication bridge via `src/ui/CharacterBook/api/`), `GAC.navigation` (Page Container Engine).
- **Data Models**: `src/main/domain/models/Character.lua`, `src/main/domain/models/Heroic.lua`, `src/main/domain/models/Skill.lua`, `src/main/domain/models/Spell.lua`.


## Acceptance Criteria & Testing

1. **Automated Test**: 
2. **Success Check**: 
3. **Manual Verification**:
* [ ] Trigger action X -> expect output Y in console/UI


---

**Essential Elements to Include**

*   **File Anchor References**: 
*   **Explicit Non-Goals ("Must NOT")**:
*   **Exact Verification Commands**: 
