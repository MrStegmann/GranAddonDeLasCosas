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

export interface Character {
    fullName: string; // Getted from TRP3 Bridge.
    class: string; // Getted from TRP3 Bridge.
    category: 'noob' | 'normal' | 'elite' | 'boss'; // By default, is always 'normal'.
    level: number; // By default, is always 1.
    healthPoints: number; // Defined by metadata LevelsTable.lua by given Category-Level plus Constitution Attribute. By Default is 20.
    resources: { // All resources are always 10. Increased by Intelligence (mana) or Willpower (spirit).
        mana: number;
        spirit: number;
    }

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
            sturdyDefense: number;
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