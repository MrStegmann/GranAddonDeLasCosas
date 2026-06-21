local addonName, GAC = ...

GAC.Stores = GAC.Stores or {}
GAC.Stores.QuickButtonsMenu = {
    Constants = {
        FRAME_WIDTH = 360,
        FRAME_HEIGHT = 65,
        DEFAULT_ANCHOR = "CENTER",
        DEFAULT_REL_ANCHOR = "CENTER",
        DEFAULT_X = -260,
        DEFAULT_Y = -120,
        
        BUTTON_X = 10,
        BUTTON_SPACING = 0,
        BUTTON_SIZE = 25,
        
        ARMOR_ICON_SIZE = 25,
        ARMOR_SPACING = 5,
        
        BACKGROUND_COLOR = { r = 0.05, g = 0.06, b = 0.08, a = 0.78 },
        BORDER_COLOR = { r = 0.25, g = 0.78, b = 0.94, a = 0.75 },
    },
    
    ArmorSlots = {
        { id = "shield", numId = 17, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand", label = "Escudo", col=0, row=0 },
        { id = "head", numId = 1, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head", label = "Cabeza", col=1, row=0 },
        { id = "chest", numId = 5, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest", label = "Pecho", col=2, row=0 },
        { id = "hands", numId = 10, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands", label = "Manos", col=1, row=1 },
        { id = "legs", numId = 7, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs", label = "Piernas", col=2, row=1 }
    },
    
    WeaponSlotsData = {
        { id = 16, label = "Arma Principal" },
        { id = 17, label = "Arma Secundaria" },
        { id = 18, label = "Arma A Distancia" }
    }
}
