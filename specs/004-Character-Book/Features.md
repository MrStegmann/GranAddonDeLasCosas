# Feature Brief - Character Book

## Feature 1 - Main Content
The Character Book should be opened by a minimap button with and book icon. The minimap button must be draggable and be able to change the position around the minimap. The last positión after dragging should be saved and persist between disconects and reloads.
The minimap button should open the Character Book main frame. This frame must use the 50% of the width of the viewport and 30% of heigh. The frame should have a thini border and a minimal padding inside. The content should be separated by two columns layout: a index column aside align to the left and a main content to show the content of the selected index.
Character Book will contains the following indexes:
- Character Information
- Attributes and talents
- Traits
- Equipment
- Pets
- Skills & Spells

---
## Global Variables
Character information must come from `SavedVariablesPerCharacter.Character`.

---
## Feature 2 - Character Information
This tab content should show the Character data information. As a Header, should be showed the Fullname character, below separated by a straigh line: level, category, race and class following the next formmat: `{Level} - {Category} | {Race or Mestizo if have two races selected} | Class `. As a Main or Body, layout of one-column, first row must have thow columns with inner box with borders and rounded corners. First box is Advantages races and second disadvengtages races. Next row should show special race traits in one column. Next row should show the actual level benefits in a grid of 3 columns (maxHealth, expToLevel, attPoints, skillPoints, heroicPoints, maxPositiveTraits) defined in `src\main\domain\database\LevelDatabase.lua`. Last Row must show a grid of two columns of Heroics Cards. The heroic cards have a Header with the name, type (active o pasive) and the Cooldown, and a body with a description. A floating button aligned to the top-right with with text "Edit" to activate edit mode to change the race(or races if mestizo, and if so able to changes Adventages and disadventages by selectin +3/-3 of both races), level and category. Each heroic card should have a edit and delete button (delete with a popup message for ensure the user want to delete it and edit whould open a small modal windows with save or cancel button). Also, must show a add Heroic that opens a small modal window with inputs name, slector for type (active-default or pasive), a numeric input for Cooldown and a text area for description. In edit mode should show Save and Cancel button instead "Edit".
When saves data, should be automatically save persistantly by SavedVariablesPerCharacter. Cancel restore the previous data.

---

## Feature 3 - Attributes and Talents
This tab should show a grid of two columns of Attributes Cards. Attributes cards contain a Header with the Attribute name and the actual Value, below has a TalentPoints that is calculated by the attribute value * 2. The AttributeBodyCard will have a bullepoint list of the talent tree of the attribute defined by `src\main\domain\database\AttributesTalentsDatabase.lua` and the actual value in the same row.
The tab have a floating button aligned to the top-right with with text "Edit" to activate edit mode that allow user to modified values of the Attributes and his talents. Attributes will be validated by the current attPoints defined by the category+level in `src\main\domain\database\LevelDatabase.lua`. Talents value will be validate by attPoints in the attribute value * 2 (the sum of all talents must be less or iqual to attribute value * 2).
If the users overpass the attPoints limits, a yellow toast warning appears aligned to the Top-center describing he has reached the limits and the Attribute value that reach the limit (the one that have more points) will be displayed with a red color feedback visual. For talents, plus warning toast, will change the color of the Card border to red and the talents that have more points colored with red to add feedback visual.
Mode Edit change button edit for Save and Cancel. Save will aumatically save persistantly the data in SavedVariablesPerCharacter. Cancel will restore previous data.

---

## Feature 3 - Traits
This tab should show a one-column layout. The first row should show the POSITIVE traits selected (empty if non-selected pòsitive traits). Below second row should show the NEGATIVE traits selected (empty if non-selected negative traits). Last row should show the HERIOIC traits selected (empty if non-selected heroic traits).
A floating button aligned to the top-right with with text "Edit" to activate edit mode that allow the user to add or remove traits. A Save and Cancel button replace Edit button.

---

## Feature 4 - Equipment
This tab show a two columns layout. Left column will display Head, Chest, Hands, Legs, MainHand, offHand, Range equipment slots. Right column show a resume of the requirements, panlties and damage per weapon with the min - max damage can do based on dice result + talent (min iqual to the lowest result + talent and max iqual to the highest result + talent). Requirements & penalties are the total of all equiped items.
Each slot must be filled with Icon item fetched from TRP3_Extends Inventory byt using `getEquipedItems` function (return table with {id, name, icon, quality, description, tooltipLeft, tooltipRight}). Should show a tooltip with the info of the item following tooltip items from WoW Game
---
Name (Based on quality item: Poor, unCommon, Common, Rare, Epic, Lengedary, Artifact)
LeftTooltip | RightTooltip (White color)
Damege Min - Max (Orange color)
Dice Roll (e.g. 1D8) (White color)
Requirements list (Green color)
Penalties list (Red Color)
Description
---
If the player has not allowed combination armor type. This effects are describe inside `src\main\domain\database\ArmorDatabase.lua` indicate by 'doubleDisadvantage' and 'doubleRequirements'.
If character does not have enought talents point for the requirements, penalties are duplicated. If character has enought talents, just apply the penalties normaly. If flag doubleDisadvantage is activated, has enought talents to reach the requierement, will be activated anyway. If character has not enought talents to reach the requierement, penalties will duplicate by normal plus double from doubleDisadvantage.

If any flag are actived (doubleRequirements, doubleDisadvantage, notAllowed) must be reflected has a visual feedback in the border icon and in the data resume
doubleRequirements -> border color is blue
doubleDisadvantage -> border color is orange
notAllowed -> border color is red

---

## Feature 5 - Pets
This tab should show a list of character pets sheet. This content have a Header with the Name of the pet, below short description of the pet (e.g. Magical Pet with lightning power). Below the description must show Level. In the body, a grid of two columns of pet attributes (no talents, only attributes). Each listed pet will have a edit button that allow to edit the pet data: name (string), level(number), description(string) and attributesValues (number). And delete button to delete the pet shet. Floating button aligned top-right to add new pet opening a modal form with the same fields of pet data edit but without delete button. 
When edit.

---

## Feature 6 - Skills & Spells
In this tab will show a dinamically list of spaces that represents the skills and spells the player can learn. Must be divided in two sections. Bot, skills & spells cost the sames points `skillPoints`.
Whe a player click over the empty field, a new windows opens by asking if the player want see skill list or spell list.
If skills is selected, mus have a header with: search input, filter by category (strenght, dexterity, constitution, widowm, charisma), slotCost and type (active or passive). List must be one column with skillCard. SkillCard have a Header with the Name, Turns, Cooldown and type. Body with the description.
If spells is selected, must have a header with: search input, filter by category (arcane, fel, nature, necromantic, shadows, light, elune, chi, elemental), type (cantrip, fast, basic, potent) and slotCost. List must be one column with spellCard. SpellCard have a Header with the Name, Power, Turns, Cooldown and Type. Body with the description.
If players already have learned skill o spell, must be unselected and opacity 50%. If one skill or spell is selected, must have a yellow-gold border and Learn button to learn it.

All spells or skills that character does not have enought skillsPoint must be disabled and have a 75% opacity. In each list, must show the total skillspoints that character have yet.

We need to create the database of ours spells and skills to create the list.
---
