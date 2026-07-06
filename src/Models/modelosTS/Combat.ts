class Combat {
    turn: number;
    initiativeOrder: Map<number, any>; // donde number es el resultado de la iniciativa. Y any es un personaje o monstruo
    currentOrder: any;



    constructor() {
        this.turn = 0;
        this.initiativeOrder = new Map<number, any>();
        this.currentOrder = null;
    }



}