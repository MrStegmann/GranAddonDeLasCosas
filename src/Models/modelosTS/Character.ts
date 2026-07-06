// Este es la madre de toda las vergotas. El putaso máximo. Este hioeputa es un cabron malparido.
class Character {
    name: string;
    level: number;
    category: string;

    attributes: Map<string, number>;
    talents: Map<string, number>;

    race: Race;
    isWorgen: boolean;

    positiveTraits: Trait[];
    negativeTraits: Trait[];

    inventory: Item[];

    spells: Spell[];
    skills: Skill[];

    health: number;
    maxHealth: number;
    shield: number;

    mana: number;
    maxMana: number;
    manaRegeneration: number;

    spirit: number;
    maxSpirit: number;

    movement: number;
    combatActions: number;
    criticalRange: number;
    aditionalAction: number;

    states: Map<string, boolean>;


    constructor(name: string, level: number, category: string) {
        this.name = name;
        this.level = level;
        this.category = category;

        this.attributes = new Map<string, number>();
        this.talents = new Map<string, number>();

        this.race = new Race("", "");
        this.isWorgen = false;
        this.positiveTraits = [];
        this.negativeTraits = [];

        this.inventory = [];
        this.spells = [];
        this.skills = [];

        this.health = 10;
        this.maxHealth = 10;
        this.shield = 0;
        this.mana = 0;
        this.maxMana = 0;
        this.manaRegeneration = 0;

        this.spirit = 0;
        this.maxSpirit = 0;
        this.movement = 20;
        this.combatActions = 2;
        this.criticalRange = 20;
        this.aditionalAction = 1;

        this.states = new Map<string, boolean>();
    }

}