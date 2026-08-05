export type Slot = "head" | "chest" | "hands" | "legs";
export type ArmorType = "clothes" | "leather" | "mail" | "plate";
export type CombinableType = "notAllowed" | "doubleDisadvantage" | "doubleRequirements" | "allowed"


interface Requirement {
    slot: Slot;
    talents: {
        talentId: string;
        value: number;
    }[];
}

interface Penalty {
    slot: Slot;
    talents: {
        talentId: string;
        value: number;
    }[];
    movementPenalty: number;
}

interface Combinable {
    clothes: CombinableType[];
    leather: CombinableType[];
    mail: CombinableType[];
    plate: CombinableType[];
}

export interface ArmorMetadata {
    physicalReduction: number;
    magicalReduction: number;
    durability: number;
    requirements?: Requirement[];
    penalties?: Penalty[];
}

export interface Reinforcement {
    id: string;
    type: ArmorType;
    physicalReduction: number;
    magicalReduction: number;
    durability: number;
    requirements?: { talentId: string, value: number }[];
    penalties?: { talentId: string, value: number }[];
    movementPenalty?: number;
}

export interface Armor extends ArmorMetadata {
    id: string;
    type: ArmorType;
    piercingDamage: number;
    slashingDamage: number;
    crushingDamage: number;
    combinable: Combinable
}

export const ArmorList: Record<ArmorType, Armor> = {
    clothes: {
        id: "clothes",
        type: "clothes",
        physicalReduction: 0,
        magicalReduction: 4,
        durability: 2,
        piercingDamage: -2,
        slashingDamage: -2,
        crushingDamage: -2,
        combinable: {
            clothes: ["notAllowed"],
            leather: ["allowed"],
            mail: ["allowed"],
            plate: ["allowed"],
        },
    },
    leather: {
        id: "leather",
        type: "leather",
        physicalReduction: 2,
        magicalReduction: 1,
        durability: 4,
        piercingDamage: -2,
        slashingDamage: -1,
        crushingDamage: 0,
        combinable: {
            clothes: ["allowed"],
            leather: ["notAllowed"],
            mail: ["doubleDisadvantage"],
            plate: ["doubleDisadvantage"],
        },
    },
    mail: {
        id: "mail",
        type: "mail",
        physicalReduction: 4,
        magicalReduction: 0,
        durability: 6,
        piercingDamage: -2,
        slashingDamage: 1,
        crushingDamage: -1,
        combinable: {
            clothes: ["allowed"],
            leather: ["doubleDisadvantage"],
            mail: ["notAllowed"],
            plate: ["doubleDisadvantage", "doubleRequirements"],
        },
        requirements: [
            {
                slot: "chest",
                talents: [
                    {
                        talentId: "brutality",
                        value: 1
                    }
                ]
            },
            {
                slot: "legs",
                talents: [
                    {
                        talentId: "brutality",
                        value: 1
                    }
                ]
            }
        ],
        penalties: [
            {
                slot: "chest",
                talents: [
                    {
                        talentId: "acrobatics",
                        value: -1
                    },
                    {
                        talentId: "agileDefense",
                        value: -1
                    }
                ],
                movementPenalty: 1
            },
            {
                slot: "hands",
                talents: [
                    {
                        talentId: "sleightOfHand",
                        value: -1
                    }
                ],
                movementPenalty: 0
            },
            {
                slot: "legs",
                talents: [
                    {
                        talentId: "acrobatics",
                        value: -1
                    },
                    {
                        talentId: "agileDefense",
                        value: -1
                    }
                ],
                movementPenalty: 1
            }
        ]
    },
    plate: {
        id: "plate",
        type: "plate",
        physicalReduction: 6,
        magicalReduction: 0,
        durability: 8,
        piercingDamage: 1,
        slashingDamage: 2,
        crushingDamage: -2,
        combinable: {
            clothes: ["allowed"],
            leather: ["doubleDisadvantage"],
            mail: ["doubleDisadvantage", "doubleRequirements"],
            plate: ["notAllowed"],
        },
        requirements: [
            {
                slot: "chest",
                talents: [
                    {
                        talentId: "brutality",
                        value: 2
                    }
                ]
            },
            {
                slot: "legs",
                talents: [
                    {
                        talentId: "brutality",
                        value: 2
                    }
                ]
            },
            {
                slot: "head",
                talents: [
                    {
                        talentId: "brutality",
                        value: 1
                    }
                ]
            },
            {
                slot: "hands",
                talents: [
                    {
                        talentId: "brutality",
                        value: 1
                    }
                ]
            }
        ],
        penalties: [
            {
                slot: "head",
                talents: [
                    {
                        talentId: "perception",
                        value: -1
                    },
                    {
                        talentId: "acrobatics",
                        value: -1
                    },
                    {
                        talentId: "agileDefense",
                        value: -1
                    }
                ],
                movementPenalty: 0
            },
            {
                slot: "chest",
                talents: [
                    {
                        talentId: "acrobatics",
                        value: -2
                    },
                    {
                        talentId: "agileDefense",
                        value: -4
                    },
                    {
                        talentId: "stealth",
                        value: -4
                    }
                ],
                movementPenalty: 5
            },
            {
                slot: "hands",
                talents: [
                    {
                        talentId: "sleightOfHand",
                        value: -2
                    },
                    {
                        talentId: "acrobatics",
                        value: -1
                    }
                ],
                movementPenalty: 0
            },
            {
                slot: "legs",
                talents: [
                    {
                        talentId: "acrobatics",
                        value: -2
                    },
                    {
                        talentId: "agileDefense",
                        value: -4
                    },
                    {
                        talentId: "stealth",
                        value: -4
                    }
                ],
                movementPenalty: 5
            }
        ]
    }
}

export const ArmorReinforcement: Record<"leather" | "mail" | "plate", Reinforcement> = {
    leather: {
        id: "leatherReinforcement",
        type: "leather",
        physicalReduction: 1,
        magicalReduction: 0,
        durability: 1
    },
    mail: {
        id: "mailReinforcement",
        type: "mail",
        physicalReduction: 2,
        magicalReduction: 0,
        durability: 2,
        penalties: [{
            talentId: "agileDefense",
            value: 1
        }],
        movementPenalty: 0
    },
    plate: {
        id: "plateReinforcement",
        type: "plate",
        physicalReduction: 3,
        magicalReduction: 0,
        durability: 3,
        requirements: [{
            talentId: "brutality",
            value: 1
        }],
        penalties: [{
            talentId: "agileDefense",
            value: 2
        }],
        movementPenalty: 1
    }
}