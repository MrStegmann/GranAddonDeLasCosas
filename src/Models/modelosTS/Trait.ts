class Trait {
    name: string;
    description: string;

    constructor(name: string, description: string) {
        this.name = name;
        this.description = description;
    }
}

class PositiveTrait extends Trait {
    level1: string;
    level2: string;
    level3: string;

    constructor(name: string, description: string, level1: string, level2: string, level3: string) {
        super(name, description);
        this.level1 = level1;
        this.level2 = level2;
        this.level3 = level3;
    }
}

class NegativeTrait extends Trait {
    level1: string;

    constructor(name: string, description: string, level1: string) {
        super(name, description);
        this.level1 = level1;
    }
}