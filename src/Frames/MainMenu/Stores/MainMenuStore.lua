local addonName, GAC = ...

GAC.Stores = GAC.Stores or {}
GAC.Stores.MainMenu = {
    -- State
    Tabs = {},
    ActiveTab = nil,
    TabCount = 0,

    -- Constants
    Constants = {
        FRAME_WIDTH = 750,
        FRAME_HEIGHT = 550,
        BACKDROP_BG = "Interface\\ChatFrame\\ChatFrameBackground",
        BACKDROP_EDGE = "Interface\\Tooltips\\UI-Tooltip-Border",
        BG_COLOR = { r = 0.05, g = 0.06, b = 0.08, a = 0.95 },
        BORDER_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 0.8 },
        TITLE_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 1 },
        LINE_COLOR = { r = 1, g = 1, b = 1, a = 0.1 },
        SIDEBAR_WIDTH = 180,
        SIDEBAR_BG_COLOR = { r = 0, g = 0, b = 0, a = 0.4 },
        SIDEBAR_BORDER_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 0.15 },
        TAB_HOVER_COLOR = { r = 1, g = 1, b = 1, a = 0.05 },
        TAB_ACTIVE_BG_COLOR = { r = 1, g = 1, b = 1, a = 0.08 },
        TAB_ACTIVE_TEXT_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 1 },
        TAB_INACTIVE_TEXT_COLOR = { r = 1, g = 1, b = 1, a = 1 },
        
        -- Additional Semantic Colors
        COLOR_ADVANTAGE = { r = 0.2, g = 1, b = 0.2, a = 1 },
        COLOR_DISADVANTAGE = { r = 1, g = 0.2, b = 0.2, a = 1 },
        COLOR_SPECIAL = { r = 1, g = 0.8, b = 0, a = 1 },
    }
}
