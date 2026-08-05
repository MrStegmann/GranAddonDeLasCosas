import { CombatStats } from "./Character"
import { Skill } from "./Skill";
import { Spell } from "./Spell";

export interface Pet extends CombatStats {
    id: string; // Getted from TRP3 Bridge.
    name: string; // Getted from TRP3 Bridge.
    level: number; // By default, is always 1.
    type: 'magical' | 'normal'

    attributes: {
        strength: number; // Define the physical power and attacks. All pet damage will be 1D4 + Strength by default.
        dexterity: number; // Define the pet's defense.
        constitution: number; // Define the pet's health points and his physical damage resistance. Add 1 HP for each constitution point. Add 1 physical resistance point for each 2 constitution point.
        intelligence: number; // Define the magic power and attacks. All pet magical damage will be 1D4 + Intelligence by default.
        willpower: number; // Define the magic resistance of the pet and other magic special capacities. Add 1 magic resistance point for each 2 willpower point.
        wisdom: number; // Define the capability of the pet to learn new orders and follow traces
    }

    skills?: Skill[];
    spells?: Spell[];
}