export type DamageType = "slashing" | "piercing" | "crushing";


export interface AttackMetaData {
    talent: string[];
    damage: number;
    diceNumber: number;
    damageType: DamageType;
}



interface Weapon extends AttackMetaData {
    id: string;
    throwable?: AttackMetaData;
    twoHanded?: AttackMetaData;
}


const WeaponList: Record<string, Weapon> = {
    dagger: {
        id: "dagger",
        talent: ["agileCombat"],
        damage: 4,
        diceNumber: 1,
        damageType: "piercing",
        throwable: {
            talent: ["precision"],
            damage: 4,
            diceNumber: 1,
            damageType: "piercing",
        },

    },
    whip: {
        id: "whip",
        talent: ["agileCombat"],
        damage: 4,
        diceNumber: 1,
        damageType: "slashing",
    },
    handAxe: {
        id: "handAxe",
        talent: ["agileCombat", "oneHandedCombat"],
        damage: 6,
        diceNumber: 1,
        damageType: "slashing",
        throwable: {
            talent: ["precision"],
            damage: 6,
            diceNumber: 1,
            damageType: "slashing",
        },
    },
    staff: {
        id: "staff",
        talent: ["agileCombat"],
        damage: 6,
        diceNumber: 1,
        damageType: "crushing",
    },
    sickle: {
        id: "sickle",
        talent: ["agileCombat"],
        damage: 4,
        diceNumber: 1,
        damageType: "slashing",
    },
    spear: {
        id: "spear",
        talent: ["agileCombat"],
        damage: 6,
        diceNumber: 1,
        damageType: "piercing",
        throwable: {
            talent: ["precision"],
            damage: 6,
            diceNumber: 1,
            damageType: "piercing",
        },
        twoHanded: {
            talent: ["twoHandedCombat"],
            damage: 8,
            diceNumber: 1,
            damageType: "piercing",
        },
    },
    rapier: {
        id: "rapier",
        talent: ["agileCombat"],
        damage: 8,
        diceNumber: 1,
        damageType: "piercing",
        throwable: {
            talent: ["precision"],
            damage: 4,
            diceNumber: 1,
            damageType: "piercing",
        },

    },
    scimitar: {
        id: "scimitar",
        talent: ["agileCombat"],
        damage: 6,
        diceNumber: 1,
        damageType: "piercing",
    },
    shortSword: {
        id: "shortSword",
        talent: ["agileCombat", "oneHandedCombat"],
        damage: 6,
        diceNumber: 1,
        damageType: "slashing",
    },
    javelin: {
        id: "javelin",
        talent: ["precision"],
        damage: 6,
        diceNumber: 1,
        damageType: "piercing",
    },
    lightCrossbow: {
        id: "lightCrossbow",
        talent: ["precision"],
        damage: 8,
        diceNumber: 1,
        damageType: "piercing",
    },
    shortBow: {
        id: "shortBow",
        talent: ["precision"],
        damage: 6,
        diceNumber: 1,
        damageType: "piercing",
    },
    handCrossbow: {
        id: "handCrossbow",
        talent: ["precision"],
        damage: 6,
        diceNumber: 1,
        damageType: "piercing",
    },
    longBow: {
        id: "longBow",
        talent: ["precision"],
        damage: 8,
        diceNumber: 1,
        damageType: "piercing",
    },
    heavyCrossbow: {
        id: "heavyCrossbow",
        talent: ["precision"],
        damage: 10,
        diceNumber: 1,
        damageType: "piercing",
    },
    pistol: {
        id: "pistol",
        talent: ["precision"],
        damage: 6,
        diceNumber: 1,
        damageType: "piercing",
    },
    rifle: {
        id: "rifle",
        talent: ["precision"],
        damage: 8,
        diceNumber: 1,
        damageType: "piercing",
    },
    shotgun: {
        id: "shotgun",
        talent: ["precision"],
        damage: 12,
        diceNumber: 1,
        damageType: "piercing",
    },
    rocketLauncher: {
        id: "rocketLauncher",
        talent: ["precision"],
        damage: 8,
        diceNumber: 2,
        damageType: "crushing",
    },
    club: {
        id: "club",
        talent: ["oneHandedCombat"],
        damage: 8,
        diceNumber: 1,
        damageType: "crushing",
    },
    lightMace: {
        id: "lightMace",
        talent: ["oneHandedCombat"],
        damage: 4,
        diceNumber: 1,
        damageType: "crushing",
    },
    mace: {
        id: "mace",
        talent: ["oneHandedCombat"],
        damage: 6,
        diceNumber: 1,
        damageType: "crushing",
    },
    warAxe: {
        id: "warAxe",
        talent: ["oneHandedCombat"],
        damage: 8,
        diceNumber: 1,
        damageType: "slashing",
        twoHanded: {
            talent: ["twoHandedCombat"],
            damage: 10,
            diceNumber: 1,
            damageType: "slashing",
        },
    },
    mayal: {
        id: "mayal",
        talent: ["oneHandedCombat"],
        damage: 8,
        diceNumber: 1,
        damageType: "crushing",
    },
    longSword: {
        id: "longSword",
        talent: ["oneHandedCombat"],
        damage: 8,
        diceNumber: 1,
        damageType: "slashing",
        twoHanded: {
            talent: ["twoHandedCombat"],
            damage: 10,
            diceNumber: 1,
            damageType: "slashing",
        },
    },
    morningStar: {
        id: "morningStar",
        talent: ["oneHandedCombat"],
        damage: 8,
        diceNumber: 1,
        damageType: "crushing",
    },
    trident: {
        id: "trident",
        talent: ["oneHandedCombat"],
        damage: 6,
        diceNumber: 1,
        damageType: "piercing",
        twoHanded: {
            talent: ["twoHandedCombat"],
            damage: 8,
            diceNumber: 1,
            damageType: "piercing",
        },
    },
    warHammer: {
        id: "warHammer",
        talent: ["oneHandedCombat"],
        damage: 8,
        diceNumber: 1,
        damageType: "crushing",
        twoHanded: {
            talent: ["twoHandedCombat"],
            damage: 10,
            diceNumber: 1,
            damageType: "crushing",
        },
    },
    warPick: {
        id: "warPick",
        talent: ["oneHandedCombat"],
        damage: 8,
        diceNumber: 1,
        damageType: "piercing",
    },
    greatClub: {
        id: "greatClub",
        talent: ["twoHandedCombat"],
        damage: 12,
        diceNumber: 1,
        damageType: "crushing",
    },
    glaive: {
        id: "glaive",
        talent: ["twoHandedCombat"],
        damage: 10,
        diceNumber: 1,
        damageType: "slashing",
    },
    heavyAxe: {
        id: "heavyAxe",
        talent: ["twoHandedCombat"],
        damage: 12,
        diceNumber: 1,
        damageType: "slashing",
    },
    greatSword: {
        id: "greatSword",
        talent: ["twoHandedCombat"],
        damage: 12,
        diceNumber: 1,
        damageType: "slashing",
    },
    halberd: {
        id: "halberd",
        talent: ["twoHandedCombat"],
        damage: 10,
        diceNumber: 1,
        damageType: "slashing",
    },
    greatMace: {
        id: "greatMace",
        talent: ["twoHandedCombat"],
        damage: 12,
        diceNumber: 1,
        damageType: "crushing",
    },
    pike: {
        id: "pike",
        talent: ["twoHandedCombat"],
        damage: 10,
        diceNumber: 1,
        damageType: "piercing",
    },
}