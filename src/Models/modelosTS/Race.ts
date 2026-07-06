class Race {
    primary: string;
    secondary: string;
    adventages: string[];
    disadventages: string[];
    special: string[];

    constructor(primary: string, secondary: string) {
        this.primary = primary;
        this.secondary = secondary;
        this.adventages = [];
        this.disadventages = [];
        this.special = [];
    }
}