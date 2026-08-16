# Test Plan: CharacterBook Minimap Button

## Unit & Integration Scenarios

### Scenario 1: Icon Registration and Rendering
- **Action**: Log into the game.
- **Expected Result**: A new minimap icon for GAC appears on the edge of the minimap.

### Scenario 2: Toggle Functionality
- **Action**: Left-click the minimap icon.
- **Expected Result**: The `CharacterBook` UI frame opens.
- **Action**: Left-click the minimap icon again while the frame is open.
- **Expected Result**: The `CharacterBook` UI frame closes.

### Scenario 3: Tooltip Rendering
- **Action**: Hover the mouse over the minimap icon.
- **Expected Result**: A standard GameTooltip appears displaying the addon name ("GAC - Character Book") and instructions (e.g., "Left-click to open").

### Scenario 4: Position Persistence
- **Action**: Drag the minimap icon to a new position on the minimap ring.
- **Action**: Type `/reload` in the chat to reload the UI.
- **Expected Result**: The minimap icon remains exactly where it was dragged, verifying `GAC_CharacterDB.minimap` saved variables integration.
