
/** This model defines the Heroics of the character, special and unique skills that define who the character is.
 * The heroics are, mostly, narrative side effects that allow the character to do unique things normally cannot do.
 * The difference between the Heroic and Skill is that the heroic is created by the player and doesn't have resource cost or action cost if the player does not explicit implement it.
 * As this is the most special thing of the system, the system must be flexible enough to allow the player to use his heroics and the master allowed it without system friction.
 * The system is strict, but need to be flexible so DM (dungeon master) and players can decide when follow the system and when not.
 */
export interface Heroic {
    id: string;
    name: string;
    type: 'active' | 'passive';
    description: string;
    version: number; // As the heroics can be improved with heroicPoints, version will increase each time the player wants to improve it by changing the description.
}