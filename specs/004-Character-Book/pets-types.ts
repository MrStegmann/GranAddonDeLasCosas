import { Skill, Spell } from "./skills-spells-types";

interface CombatStats {
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

export interface Pet extends CombatStats {
    id: string;
    name: string;
    description: string;
    owner: string;
    level: number; // By default, is always 1.

    attributes: {
        strength: number;
        dexterity: number;
        constitution: number;
        intelligence: number;
        willpower: number;
        wisdom: number;
        charisma: number;
    }

    spells: Spell[];
    skills: Skill[];
}