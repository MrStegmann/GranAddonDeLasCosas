class Item {
    id: string;
    name: string;
    description: string;
    type: string;
    icon: string;
    quality: number;
    variable: Map<string, any>;


    constructor(id: string, name: string, description: string, type: string, icon: string, quality: number, variable: Map<string, any>) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.type = type;
        this.icon = icon;
        this.quality = quality;
        this.variable = variable;
    }
}

class Armor extends Item {
    slot: string;
    material: string;

    constructor(id: string, name: string, description: string, type: string, icon: string, quality: number, variable: Map<string, any>, slot: string, material: string) {
        super(id, name, description, type, icon, quality, variable);
        this.slot = slot;
        this.material = material;
    }
}

class Weapon extends Item {
    type: string;
    modificator: string;

    constructor(id: string, name: string, description: string, type: string, icon: string, quality: number, variable: Map<string, any>, modificator: string) {
        super(id, name, description, type, icon, quality, variable);
        this.type = type;
        this.modificator = modificator;
    }
}

class Shield extends Item {
    type: string;

    constructor(id: string, name: string, description: string, icon: string, quality: number, variable: Map<string, any>, type: string) {
        super(id, name, description, "shield", icon, quality, variable);
        this.type = type;
    }
}