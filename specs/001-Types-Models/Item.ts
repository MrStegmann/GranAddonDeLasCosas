

/** Items are the most important model throught the character and the TRP3_Extended inventory. It's define how must be the Items getted by TRP3_Extended bridge and how must be the Items in general to works with the system.
 * If Items not follow this architecture, it's will not work with the system.
 */
export interface Item {
    id: string; // Getted from TRP3_Extends Bridge.
    name: string; // Getted from TRP3_Extends Bridge.
    quality: string; // Getted from TRP3_Extends Bridge.
    description: string;
}

interface Requirement {
    talentId: string;
    value: number;
}

interface Penalty {
    talentId: string;
    value: number;
}

export interface Armor extends Item {
    physicalReduction: number;
    magicalReduction: number;
    durability: number;
    type: string; // Getted from TRP3_Extends Bridge.
    slot: 'head' | 'chest' | 'hands' | 'legs'; // Getted from TRP3_Extends Bridge.
    piercingDamage: number;
    slashingDamage: number;
    crushingDamage: number;
    requirements: Requirement[];
    penalties: Penalty[];
    movementPenalty: number;
}

export interface Weapon extends Item {
    damage: number;
    diceNumber: number;
    weaponId: string;
}

export interface Shield extends Item {
    type: 'light' | 'medium' | 'heavy'; // Getted from TRP3_Extends Bridge.
    slot: 'offHand'; // Getted from TRP3_Extends Bridge as a "Escudo", must be parsed.
    durability: number;
    requirements: Requirement[];
    penalties: Penalty[];
    movementPenalty: number;
}