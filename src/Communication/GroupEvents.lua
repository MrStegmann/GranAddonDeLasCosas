function GAC:GROUP_ROSTER_UPDATE()
    if self.Transmitter then
        self.Transmitter:Trigger(GAC.Enums.Events.REQ, nil, true)
    end
end

function GAC:PLAYER_ENTERING_WORLD()
    if self.Transmitter then
        self.Transmitter:Trigger(GAC.Enums.Events.REQ, nil, true)
    end
end
