local _, GAC = ...
GAC.Enums = GAC.Enums or {}

GAC.Enums.Events = {
    -- QuickButtonsMenu
    ROLL = "ROLL",
    ARMOR_HIT = "ARMOR_HIT",
    MSG_ARMOR = "MSG_ARMOR",
    MODIFY_LIFE = "MODIFY_LIFE",
    MODIFY_SHIELD = "MODIFY_SHIELD",
    
    -- MainMenu
    REQ = "REQ",
    RES = "RES",
    
    -- InspectionMenu
    INSPECT_REQ = "INSPECT:REQ",
    INSP_INFO = "INSP:INFO",
    INSP_ATT = "INSP:ATT",
    INSP_TAL = "INSP:TAL",
    INSP_ADV = "INSP:ADV",
    INSP_DIS = "INSP:DIS",
    INSP_SPC = "INSP:SPC",
    INSP_RAC = "INSP:RAC",
    INSP_END = "INSP:END",
    ADD_EXP = "ADD_EXP",
    
    -- InitiativeOrders
    INIT_ADD = "INIT:ADD",
    INIT_ACTION = "INIT:ACTION",
    INIT_MOVE = "INIT:MOVE",
    INIT_ICON = "INIT:ICON"
}
