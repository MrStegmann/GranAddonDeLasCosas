export interface Spell {
    id: string;
    name: string;
    description: string;
    slotCost: number;
    actionCost: number;
    turnEffects: number;
    cooldownTurns: number;
    category: string;
    spellType: 'cantrip' | 'fast' | 'basic' | 'potent';
    type: string;
    resourceCost: number;
    power: number;
    triggerOpportunityAttack: boolean;
    isCanalizable: boolean;
}