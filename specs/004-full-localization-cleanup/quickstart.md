# Quickstart & Verification Guide: Full Localization & Code Cleanup

## Setup & Verification Instructions

### In-Game Verification Scenarios

#### Scenario 1: Character Sheet Localization (`CharSheetContent.lua`)
- **Action**: Open main menu `/gac` and navigate to Ficha de Personaje.
- **Expected Outcome**: Tab titles, section labels ("Salud Máxima", "Puntos de Atributo", etc.), and button text ("Guardar Historia", "Guardar Progresión") render cleanly via `GAC:_("KEY")`.

#### Scenario 2: Experience Configurator Localization (`ExperienceConfigurator.lua`)
- **Action**: Navigate to Experiencia screen.
- **Expected Outcome**: Header, level label pattern, and input text resolve dynamically via `GAC:_("KEY")`.

#### Scenario 3: Inventory Content Localization (`InventoryContent.lua`)
- **Action**: Navigate to Inventory screen.
- **Expected Outcome**: Requirement warnings and combination labels resolve dynamically via `GAC:_("KEY")`.

#### Scenario 4: Quick Action Menu Localization (`QuickButtonsMenu/index.lua`)
- **Action**: Open Quick Action Menu and trigger life/shield popups.
- **Expected Outcome**: Popup titles ("Modificar Vida", "Modificar Escudo") and button labels ("Aceptar") resolve dynamically via `GAC:_("KEY")`.
