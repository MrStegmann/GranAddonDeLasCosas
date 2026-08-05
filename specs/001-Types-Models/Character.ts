import { Heroic } from "./Heroic";
import { Armor, Weapon, Shield } from "./Item"
import { Pet } from "./Pet"
import { Profession } from "./Profession";
import { Skill } from "./Skill";
import { Spell } from "./Spell";


/** This Model defines the combat system for the player as a Definition of Truth.
 * Combat system will use this stats to now what to do next during the combat.
 * 
 */
export interface CombatStats {
    healthPoints: number; // Defined by metadata LevelsTable.lua by given Category-Level plus Constitution Attribute. By Default is 20.
    resources: { // All resources are always 10. Increased by Intelligence (mana) or Willpower (spirit).
        mana: number;
        spirit: number;
    };
    initiative: number; // By default for all charracters is 100
    offensiveActions: number; // By default for all characters is 2. Needed to do actions during ofensive turn.
    canAttack: boolean; // By default for all characters is true. Used to determine if character can attack.
    criticalStrickRange: number; // By default for all characters is 20. Determinate the range for a critical strike in a D20 roll.
    criticalFailureRange: number; // By default for all characters is 1. Determinate the range for a critical failure in a D20 roll.
    isAmbushActive: boolean; // By default for all characters is false. Used to determine if character is ambushing.

    defensiveActions: number; // By default for all characters is 1. Needed to do actions during defensive turn.
    canIntercept: boolean; // By default for all characters is true. Used to determine if character can intercept an offensive attack to other nearby players


    movement: number; // By default for all characters is 20. Determinates the distance the charactar can move.

    canPhysicalPerceptionCheck: boolean; // By default for all characters is true. Used to determine if character can make physical perception checks.
    canMagicPerceptionCheck: boolean; // By default for all characters is true. Used to determine if character can make magic perception checks.

    canTrade: boolean; // By default for all characters is true. Used to determine if character can make trades.
    canAskAction: boolean; // By default for all characters is true. Used to determine if character can ask other to do an action during his turn.

    isFlanked: boolean; // By default for all characters is false. Used to determine if character is flanked.
    isDowned: boolean; // By default for all characters is false. Used to determine if character is downed.
    isStunned: boolean; // By default for all characters is false. Used to determine if character is stunned.
    isHighest: boolean; // By default for all characters is false. Used to determine if character have the highest adventage.
    isBacked: boolean; // By default for all characters is false. Used to determine if character have a enemy at his back.
    isBlinded: boolean; // By default for all characters is false. Used to determine if character is blinded by darkness or reduced visibility.

    states: string[];
}

/** This Model define how should be the Character data structure for the Addon to work. It is mandatory to follow this structure for all character data (player character, characters from other players and non-player characters)
 * This Model represent the Definition of Thruth for how must work the system around the player character.
 * Defines the level, category, attributes, talents, race, skills and spells, etc.
 * Defines the combat system for the character and how should be interacts with the system.
 */
export interface Character extends CombatStats {
    fullName: string; // Getted from TRP3 Bridge.
    class: string; // Getted from TRP3 Bridge.
    category: 'noob' | 'normal' | 'elite' | 'boss'; // By default, is always 'normal'.
    level: number; // By default, is always 1.
    type: 'player' | 'npc';


    attributes: {
        strength: number;
        dexterity: number;
        constitution: number;
        intelligence: number;
        willpower: number;
        wisdom: number;
        charisma: number;
    }

    talents: {
        strength: {
            twoHandedCombat: number;
            oneHandedCombat: number;
            athletics: number;
            brutality: number;
            robustDefense: number;
        };
        dexterity: {
            precision: number;
            agileCombat: number;
            acrobatics: number;
            stealth: number;
            sleightOfHand: number;
            agileDefense: number;
        };
        constitution: {
            resilience: number;
            stunResistance: number;
            knockdownResistance: number;
            coldResistance: number;
            heatResistance: number;
            fortitude: number;
        };
        intelligence: {
            arcane: number;
            fel: number;
            nature: number;
            shadow: number;
            necromancy: number;
        };
        willpower: {
            magicResistance: number;
            lossOfControlResistance: number;
            faith: number;
            elementalConnection: number;
            chi: number;
            manaRegeneration: number;
        };
        wisdom: {
            animalConnection: number;
            survival: number;
            perception: number;
        };
        charisma: {
            persuasion: number;
            diplomacy: number;
            commerce: number;
            provocation: number;
            seduction: number;
            performance: number;
        };

    }

    race: {
        main: string; // Raza principal, obligatorio
        secondary: string | null; // Raza secundaria, nullable. Si se especifica activa "Mestizo" y el personaje deberá elegir entre +3/-3 ventajas/desventajas entre ambas razas seleccionadas
        talents?: { talent: string, value: number }[] // Solo se activa para seleccionara las ventajas y desventajas de raza por mestizo.
    }

    isWorgen: boolean; // Activa para personajes Con la maldición Worgens.

    positiveTraits: { traitId: string, traitLevel: number }[]; // Contiene una lista de las ids de los rasgos positivos y el nivel activado.
    negativeTraits: string[]; // Contiene una lista de las id's de los rasgos negativos.

    equipment: {
        head: Armor | null;
        chest: Armor | null;
        hands: Armor | null;
        legs: Armor | null;
        mainHand: Weapon | null;
        offHand: Weapon | Shield | null;
        ranged: Weapon | null;
    };

    pets?: Pet[];


    heroics: Heroic[];
    skills: Skill[];
    spells: Spell[];

    professions: Profession[];
}