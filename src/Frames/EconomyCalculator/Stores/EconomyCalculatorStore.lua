local addonName, GAC = ...

GAC.Stores = GAC.Stores or {}
GAC.Stores.EconomyCalculator = {
    Selections = {
        Material = "CLOTH",
        Rarity = "COMMON",
        Location = "STORMWIND",
        Condition = "NEW",
        Skill = "NOVICE",
        Time = 1,
        Quality = 5,
        Demand = 1.0,
        Tax = 0.0,
        Prestige = 1.0,
    },
    
    Weights = {
        Material = 0.30,
        Rarity   = 0.25,
        Time     = 0.20,
        Skill    = 0.15,
        Quality  = 0.10,
        K        = 8.33,
    },

    Constants = {
        FRAME_WIDTH = 580,
        FRAME_HEIGHT = 440,
        BACKDROP_BG = "Interface\\ChatFrame\\ChatFrameBackground",
        BACKDROP_EDGE = "Interface\\Tooltips\\UI-Tooltip-Border",
        BG_COLOR = { r = 0.05, g = 0.06, b = 0.08, a = 0.95 },
        BORDER_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 0.8 },
        TITLE_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 1 },
        LINE_COLOR = { r = 1, g = 1, b = 1, a = 0.1 },
        
        LABEL_COLOR = { r = 0.8, g = 0.82, b = 0.85, a = 1 },
        VALUE_COLOR = { r = 1, g = 1, b = 1, a = 1 },
        ACCENT_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 1 },
    }
}
