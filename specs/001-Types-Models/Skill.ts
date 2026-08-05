export interface Skill {
    id: string;
    name: string;
    type: 'passive' | 'active';
    description: string;
    slotCost: number;
    actionCost: number;
    effectTurns: number;
    cooldownTurns: number;
}