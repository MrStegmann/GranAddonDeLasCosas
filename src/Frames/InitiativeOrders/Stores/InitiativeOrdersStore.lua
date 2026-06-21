local addonName, GAC = ...

GAC.Stores = GAC.Stores or {}
GAC.Stores.InitiativeOrders = {
    Constants = {
        FRAME_WIDTH = 250,
        ROW_HEIGHT = 20,
        MAX_ROWS = 20,
        
        BACKGROUND_COLOR = { r = 0.05, g = 0.06, b = 0.08, a = 0.95 },
        BORDER_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 0.8 },
        
        DEFAULT_ANCHOR = "CENTER",
        DEFAULT_REL_ANCHOR = "CENTER",
        DEFAULT_X = 300,
        DEFAULT_Y = 0,
    }
}
