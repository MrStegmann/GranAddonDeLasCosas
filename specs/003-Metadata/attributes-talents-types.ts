export type Attributes = "strength" | "dexterity" | "intelligence" | "willpower" | "constitution" | "wisdom" | "charisma";

// Talents related to Attributes
export type StrengthTalents = "twoHandedCombat" | "oneHandedCombat" | "athletics" | "brutality" | "robustDefense";
export type DexterityTalents = "precision" | "agileCombat" | "acrobatics" | "stealth" | "sleightOfHand" | "agileDefense";
export type IntelligenceTalents = "arcane" | "fel" | "nature" | "shadow" | "necromancy";
export type WillpowerTalents = "magicResistance" | "lossOfControlResistance" | "faith" | "elementalConnection" | "chi" | "manaRegeneration";
export type ConstitutionTalents = "resilience" | "stunResistance" | "knockdownResistance" | "coldResistance" | "heatResistance" | "fortitude";
export type WisdomTalents = "animalConnection" | "survival" | "perception";
export type CharismaTalents = "persuasion" | "diplomacy" | "commerce" | "provocation" | "seduction" | "performance";

export type Talents =
    | StrengthTalents
    | DexterityTalents
    | IntelligenceTalents
    | WillpowerTalents
    | ConstitutionTalents
    | WisdomTalents
    | CharismaTalents;

export type AttributeGroup = {
    name: Attributes;
    talents: Talents[];
};