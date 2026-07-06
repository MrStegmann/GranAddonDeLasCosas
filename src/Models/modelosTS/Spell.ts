class Spell {
    name: string;
    description: string;
    level: number;
    manaCost: number;
    cooldown: number;

    constructor(name: string, description: string, level: number, manaCost: number, cooldown: number) {
        this.name = name;
        this.description = description;
        this.level = level;
        this.manaCost = manaCost;
        this.cooldown = cooldown;
    }
}