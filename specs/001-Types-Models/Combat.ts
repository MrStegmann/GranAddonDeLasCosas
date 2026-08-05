

interface InitiativeOrder {
    characterId: string;
    initiativeResult: number;
}

/**This model is the Definition of Thruth for the combat system.
 * Determinate how will work the combat system and will manage the turns, initiatives, etc.
 *  This model combined with the CombatStat of the players stablish how combat will work.
 */

export interface Combat {
    id: string; // The combat id
    activeCharacterId: string; // The id of the character that is currently in turn
    actualRound: number; // The current round of the combat. Increase each time that all characters have done their turn.
    initiativeOrder: InitiativeOrder[]; // The order of the characters in the combat
    combatLog: string[]; // The log of the combat

}