--- Verification script for 003-Metadata implementation

-- Mock global state if running in standalone Lua 5.1
_G = _G or {}

-- Load databases
local ArmorDatabase = dofile("src/main/domain/database/ArmorDatabase.lua")
local AttributesTalentsDatabase = dofile("src/main/domain/database/AttributesTalentsDatabase.lua")
local LevelDatabase = dofile("src/main/domain/database/LevelDatabase.lua")
local RaceDatabase = dofile("src/main/domain/database/RaceDatabase.lua")
local ShieldDatabase = dofile("src/main/domain/database/ShieldDatabase.lua")
local TraitsDatabase = dofile("src/main/domain/database/TraitsDatabase.lua")
local WeaponsDatabase = dofile("src/main/domain/database/WeaponsDatabase.lua")

-- Load ports
local ArmorPort = dofile("src/main/ports/metadata/ArmorPort.lua")
local AttributesTalentsPort = dofile("src/main/ports/metadata/AttributesTalentsPort.lua")
local LevelPort = dofile("src/main/ports/metadata/LevelPort.lua")
local RacePort = dofile("src/main/ports/metadata/RacePort.lua")
local ShieldPort = dofile("src/main/ports/metadata/ShieldPort.lua")
local TraitsPort = dofile("src/main/ports/metadata/TraitsPort.lua")
local WeaponsPort = dofile("src/main/ports/metadata/WeaponsPort.lua")

-- Load trait services
local CombatTraitsService = dofile("src/main/adapters/services/traits/combatTraitsService.lua")
local TalentTraitsService = dofile("src/main/adapters/services/traits/talentTraitsService.lua")
local ProgressionTraitsService = dofile("src/main/adapters/services/traits/progressionTraitsService.lua")

-- Load models
local ArmorModel = dofile("src/main/domain/models/Armor.lua")
local ShieldModel = dofile("src/main/domain/models/Shield.lua")
local WeaponModel = dofile("src/main/domain/models/Weapon.lua")
local CharacterModel = dofile("src/main/domain/models/Character.lua")

print("--- Testing Database Tables ---")
assert(ArmorDatabase.ArmorList.plate.physicalReduction == 6, "Plate physicalReduction failed")
assert(#AttributesTalentsDatabase.Attributes == 7, "Attributes length failed")
assert(LevelDatabase.levelTable.normal[5].maxHealth == 49, "Level matrix health failed")
assert(RaceDatabase.RaceList.human.special[1] == "adaptability", "Human race special failed")
assert(ShieldDatabase.ShieldList.heavy.durability == 20, "Shield heavy durability failed")
assert(#TraitsDatabase.PositiveTraitList > 0, "Positive traits failed")
assert(WeaponsDatabase.WeaponList.dagger.damage == 4, "Dagger weapon damage failed")

print("--- Testing Read-Only Ports ---")
assert(ArmorPort.getArmor("plate").physicalReduction == 6, "ArmorPort getArmor failed")
assert(#AttributesTalentsPort.getAttributes() == 7, "AttributesTalentsPort getAttributes failed")
assert(LevelPort.getMaxHealth("normal", 5) == 49, "LevelPort getMaxHealth failed")
assert(RacePort.getRace("orc").special[1] == "superStrength", "RacePort getRace failed")
assert(ShieldPort.getShield("heavy").durability == 20, "ShieldPort getShield failed")
assert(TraitsPort.getPositiveTrait("bully").name == "Abusón/a", "TraitsPort getPositiveTrait failed")
assert(WeaponsPort.getWeapon("shotgun").damage == 12, "WeaponsPort getWeapon failed")

print("--- Testing Trait Services ---")
assert(CombatTraitsService.getAgileAmbidextrousModifier(1, -4) == 0, "Agile ambidextrous L1 failed")
assert(CombatTraitsService.getStrongAmbidextrousModifier(1, -4) == -2, "Strong ambidextrous L1 failed")
assert(CombatTraitsService.getBullyCriticalRangeBonus(2) == 2, "Bully critical bonus failed")
local talentBonuses = TalentTraitsService.getTraitTalentBonuses("agile", 3)
assert(talentBonuses.agileDefense == 2 and talentBonuses.acrobatics == 1, "Agile talent bonuses failed")
assert(ProgressionTraitsService.calculateFinalExperience(100, false, true) == 50, "Disastrous exp failed")

print("--- Testing Domain Models Schema Parity ---")
local testPlate = ArmorModel.create(ArmorDatabase.ArmorList.plate)
assert(testPlate.id == "plate" and testPlate.physicalReduction == 6, "Armor model create failed")

local testShield = ShieldModel.create(ShieldDatabase.ShieldList.heavy)
assert(testShield.id == "heavy" and testShield.movementPenalty == 2, "Shield model create failed")

local testWeapon = WeaponModel.create(WeaponsDatabase.WeaponList.spear)
assert(testWeapon.id == "spear" and testWeapon.twoHanded.damage == 8, "Weapon model create failed")

local testCharacter = CharacterModel.createDefault()
assert(testCharacter.category == "normal" and testCharacter.healthPoints == 20, "Character model create failed")

print("=== ALL VERIFICATION CHECKS PASSED SUCCESSFULLY ===")
