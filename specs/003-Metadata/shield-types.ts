import type { AttackMetaData } from "./weapons-type";

type ShieldType = 'light' | 'medium' | 'heavy';
interface Requirement {
    talentId: string;
    value: number;
}

interface Penalty {
    talentId: string;
    value: number;
}

interface ShieldMetadata {
    physicalReduction: number;
    magicalReduction: number;
    durability: number;
    requirements?: Requirement[];
    penalties?: Penalty[];
    movementPenalty: number;
}

interface Shield extends AttackMetaData, ShieldMetadata {
    id: ShieldType;
}

export const ShieldList: Record<ShieldType, Shield> = {
    light: {
        id: "light",
        talent: ["brutality"],
        damage: 4,
        diceNumber: 1,
        damageType: "crushing",
        physicalReduction: 1,
        magicalReduction: 0,
        durability: 10,
        movementPenalty: 0,
    },
    medium: {
        id: "medium",
        talent: ["brutality"],
        damage: 6,
        diceNumber: 1,
        damageType: "crushing",
        physicalReduction: 2,
        magicalReduction: 0,
        durability: 15,
        movementPenalty: 0,
        requirements: [
            { talentId: "brutality", value: 1 },
        ],
        penalties: [
            { talentId: "agilityDefense", value: -1 },
            { talentId: "acrobatics", value: -1 },
        ],
    },
    heavy: {
        id: "heavy",
        talent: ["brutality"],
        damage: 8,
        diceNumber: 1,
        damageType: "slashing",
        physicalReduction: 3,
        magicalReduction: 0,
        durability: 20,
        movementPenalty: 2,
        requirements: [
            { talentId: "brutality", value: 2 },
        ],
        penalties: [
            { talentId: "agilityDefense", value: -4 },
            { talentId: "acrobatics", value: -4 },
        ],
    },
};