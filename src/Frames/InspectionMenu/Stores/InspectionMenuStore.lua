local addonName, GAC = ...

GAC.Stores = GAC.Stores or {}
GAC.Stores.InspectionMenu = {
    Tabs = {},
    TabCount = 0,
    Constants = {
        THEME_COLOR = { r = 0.94, g = 0.25, b = 0.25, a = 1 }, -- Red theme for Inspection
        TAB_ACTIVE_BG_COLOR = { r = 1, g = 1, b = 1, a = 0.08 },
        TAB_INACTIVE_BG_COLOR = { r = 0, g = 0, b = 0, a = 0 },
        TAB_HOVER_BG_COLOR = { r = 1, g = 1, b = 1, a = 0.05 },
        TEXT_COLOR_WHITE = { r = 1, g = 1, b = 1, a = 1 },
        TEXT_COLOR_RED = { r = 0.94, g = 0.25, b = 0.25, a = 1 },
        TEXT_COLOR_GREEN = { r = 0.2, g = 1, b = 0.2, a = 1 },
        TEXT_COLOR_GOLD = { r = 1, g = 0.8, b = 0, a = 1 },
    }
}
