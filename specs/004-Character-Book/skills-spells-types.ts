interface Meta {
    id: string;
    name: string;
    description: string;
    turnCooldown: number;
    costActions: number;
    costSlots: number;
    turnEffects: number;
}

export interface Skill extends Meta {
    type: 'passive' | 'active';
    category: 'strength' | 'dexterity' | 'constitution' | 'wisdom' | 'charisma';
}

export interface Spell extends Meta {
    spellType: 'cantrip' | 'fast' | 'basic' | 'potent';
    type: string;
    resourceCost: number;
    power: number;
    triggerOpportunityAttack: boolean;
    isCanalizable: boolean;

}