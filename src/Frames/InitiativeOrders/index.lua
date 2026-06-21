local _, GAC = ...

GAC.initiativeOrder = {}
GAC.activeInitiativeView = "current"
GAC.currentLinkedHistory = nil

function GAC:InitializeInitiativeFrame()
    if self.initiativeFrame then return end
    self.initiativeFrame = GAC.Screens.InitiativeOrders:CreateMainFrame()
end
