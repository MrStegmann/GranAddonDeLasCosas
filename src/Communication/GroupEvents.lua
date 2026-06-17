function GAC:GROUP_ROSTER_UPDATE()
    if self.RequestGroupData then
        self:RequestGroupData()
    end
end

function GAC:PLAYER_ENTERING_WORLD()
    if self.RequestGroupData then
        self:RequestGroupData()
    end
end
