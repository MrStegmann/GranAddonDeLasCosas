local addonName, GAC = ...
local Economy = {}

GAC.Data = GAC.Data or {}
GAC.Data.Economy = Economy

Economy.Weights = {
    Material = 0.30,
    Rarity   = 0.25,
    Time     = 0.20,
    Skill    = 0.15,
    Quality  = 0.10
}

-- Constante de calibración.
-- Con este valor un pan cuesta aproximadamente 10 monedas.
Economy.K = 8.33

Economy.Materials = {
    CLOTH = 1,
    WOOD = 2,
    LEATHER = 3,
    COPPER = 4,
    BRONZE = 4,
    IRON = 5,
    STEEL = 6,
    SILVER = 7,
    GOLD = 8,
    MITHRIL = 9,
    THORIUM = 10,
    FEL_IRON = 11,
    ADAMANTITE = 12,
    COBALT = 13,
    SARONITE = 14,
    TITANIUM = 15,
    ELEMENTIUM = 16,
    TRILLIUM = 17,
    GHOST_IRON = 18,
    TRUESTEEL = 19,
    OBSIDIAN = 20,
    TOPAZ = 21,
    EMERALD = 22,
    RUBY = 23,
    SAPPHIRE = 24,
    DIAMOND = 25,
    COAL = 2,
    ESSENCE_OF_FIRE = 12,
    ESSENCE_OF_AIR = 13,
    ESSENCE_OF_WATER = 14,
    ESSENCE_OF_EARTH = 15,
    ESSENCE_OF_LIFE = 16,
    ESSENCE_OF_SHADOW = 17
}

Economy.Location = {
    STORMWIND = 1.15,
    ORGRIMMAR = 1.05,
    IRONFORGE = 1.12,
    DARNASSUS = 1.02,
    THUNDER_BLUFF = 0.96,
    UNDERCITY = 1.08,
    SILVERMOON = 1.07,
    EXODAR = 0.94,
    SHATTRATH = 1.20,
    DALARAN = 1.35,
    GADGETZAN = 1.28,
    BOOTY_BAY = 1.30,
    CROSSROADS = 0.90,
    GOLDSHIRE = 0.86,
    RAZOR_HILL = 0.84
}

Economy.Condition = {

    BROKEN = 0.20,

    POOR = 0.45,

    USED = 0.70,

    GOOD = 0.90,

    NEW = 1.00,

    MASTERWORK = 1.15
}

Economy.Skill = {

    NOVICE = 1,

    APPRENTICE = 2,

    JOURNEYMAN = 4,

    EXPERT = 6,

    MASTER = 8,

    GRANDMASTER = 10
}

Economy.Rarity = {

    COMMON = 1,

    UNCOMMON = 3,

    RARE = 6,

    EPIC = 8,

    LEGENDARY = 10
}

Economy.Catalog = {

    Bread = {
        Material = Economy.Materials.CLOTH,
        Rarity = Economy.Rarity.COMMON,
        Time = 1,
        Skill = Economy.Skill.NOVICE,
        Quality = 5
    },

    IronSword = {
        Material = Economy.Materials.IRON,
        Rarity = Economy.Rarity.COMMON,
        Time = 5,
        Skill = Economy.Skill.EXPERT,
        Quality = 7
    },

    SteelSword = {
        Material = Economy.Materials.STEEL,
        Rarity = Economy.Rarity.COMMON,
        Time = 6,
        Skill = Economy.Skill.EXPERT,
        Quality = 8
    },

    PlateArmor = {
        Material = Economy.Materials.STEEL,
        Rarity = Economy.Rarity.RARE,
        Time = 20,
        Skill = Economy.Skill.MASTER,
        Quality = 9
    },

    Horse = {
        Material = 4,
        Rarity = Economy.Rarity.UNCOMMON,
        Time = 60,
        Skill = Economy.Skill.EXPERT,
        Quality = 8
    },

    Ship = {
        Material = Economy.Materials.WOOD,
        Rarity = Economy.Rarity.RARE,
        Time = 600,
        Skill = Economy.Skill.MASTER,
        Quality = 8
    }
}

function Economy:GetBaseValue(material,
                              rarity,
                              time,
                              skill,
                              quality)

    local W = self.Weights

    return
        (material ^ W.Material) *
        (rarity  ^ W.Rarity) *
        (time    ^ W.Time) *
        (skill   ^ W.Skill) *
        (quality ^ W.Quality)

end

--- How to Use
-- local sword = {

--     Material = Economy.Materials.STEEL,

--     Rarity = Economy.Rarity.COMMON,

--     Time = 5,

--     Skill = Economy.Skill.EXPERT,

--     Quality = 7,

--     Location = Economy.Location.STORMWIND,

--     Demand = 1.10,

--     Tax = 0.05,

--     Prestige = 1.00,

--     Condition = Economy.Condition.NEW
-- }

-- print(Economy:GetPrice(sword))

function Economy:GetPrice(data)

    local base = self:GetBaseValue(
        data.Material,
        data.Rarity,
        data.Time,
        data.Skill,
        data.Quality
    )

    local price =
        self.K *
        base *
        data.Location *
        data.Demand *
        (1 + data.Tax) *
        data.Prestige *
        data.Condition

    return math.ceil(price)
end