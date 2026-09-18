# Quickstart & Verification Guide: Critical Infrastructure Setup

## Setup Instructions

1. Ensure `GranAddonDeLasCosas.xml` correctly references `src\GAC.xml` via `<Include>`.
2. Ensure all submanifest XML files (`Communication.xml`, `Data.xml`, `Utils.xml`, `UI.xml`, `Components.xml`, `Screens.xml`, `Hooks.xml`) use `<Script file="*.lua"/>`.
3. Ensure `src/index.lua` binds `_G.GAC = GAC` and `_G.GranAddonDeLasCosas = GAC`.

## Validation Scenarios

### Scenario 1: Client Load & XML Schema Validation
- **Action**: Launch WoW Client (Interface 90207) or execute `/reload` in game.
- **Expected Outcome**: No XML schema errors or script load failures appear in the frame error window or Swatter/BugSack console.

### Scenario 2: Global Namespace Accessibility
- **Action**: Open chat and execute `/run print(GAC.name)` and `/run print(GranAddonDeLasCosas.version)`.
- **Expected Outcome**: Outputs `GAC_DEV` and `1.3.0` (or current version) into the chat frame without throwing `attempt to index global 'GAC' (a nil value)`.

### Scenario 3: Slash Command `/gac` Execution
- **Action**: Type `/gac` in the chat edit box.
- **Expected Outcome**: The main menu frame opens cleanly.
