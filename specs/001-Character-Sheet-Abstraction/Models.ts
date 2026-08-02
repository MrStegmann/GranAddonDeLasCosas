interface Armor {
    name: string; // Getted from TRP3_Extends Bridge.
    quality: string; // Getted from TRP3_Extends Bridge.
    physicalReduction: number;
    magicalReduction: number;
    durability: number;
    type: string; // Getted from TRP3_Extends Bridge.
    slot: 'head' | 'chest' | 'hands' | 'legs'; // Getted from TRP3_Extends Bridge.
    stats: {
        pircing: string;
        slashing: string;
        concussion: string;
    }
}

interface Weapon {
    name: string; // Getted from TRP3_Extends Bridge.
    quality: string; // Getted from TRP3_Extends Bridge.
    damageMod: number; // Getted from TRP3_Extends Bridge.
    weaponId: string; // Getted from TRP3_Extends Bridge.
    slot: 'mainHand' | 'offHand' | 'ranged';
}

interface Shield {
    name: string; // Getted from TRP3_Extends Bridge.
    quality: string; // Getted from TRP3_Extends Bridge.
    type: 'light' | 'medium' | 'heavy'; // Por defecto es 'medium'.
    slot: 'offHand'; // Getted from TRP3_Extends Bridge as a "Escudo", must be parsed.
    durability: number;
}

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

export interface Character extends CombatStats {
    fullName: string; // Getted from TRP3 Bridge.
    class: string; // Getted from TRP3 Bridge.
    category: 'noob' | 'normal' | 'elite' | 'boss'; // By default, is always 'normal'.
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

    pets?: string[];


}