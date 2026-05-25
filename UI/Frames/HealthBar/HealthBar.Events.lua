local _, addon = ...

function addon:RequestTargetLevelData(force)
	if not UnitExists("target") or not UnitIsPlayer("target") or UnitIsUnit("target", "player") then
		return
	end

	local now = GetTime()
	if not force and self.lastTargetLevelRequestAt and (now - self.lastTargetLevelRequestAt) < 1.0 then
		return
	end

	self.lastTargetLevelRequestAt = now

	if self.RequestTooltipDataForUnit then
		self:RequestTooltipDataForUnit("target")
	end
end

function addon:OnUpdate(elapsed)
	self.targetSyncPollElapsed = (self.targetSyncPollElapsed or 0) + (tonumber(elapsed) or 0)
	if self.targetSyncPollElapsed < 1.0 then
		return
	end

	self.targetSyncPollElapsed = 0

	if not UnitExists("target") or not UnitIsPlayer("target") or UnitIsUnit("target", "player") then
		return
	end

	if self.RequestTargetLevelData then
		self:RequestTargetLevelData(false)
	end
end


function addon:OnCustomProgressUpdated()
	self:RefreshPlayerLevelOverlay()
	self:UpdatePlayerCategoryOverlay()
	self:RefreshPlayerHealthBarMaxHealth()
	self:RefreshTargetHealthBarMaxHealth()

	if self.BroadcastTooltipSyncPayload then
		self:BroadcastTooltipSyncPayload()
	end
end

function addon:InstallPlayerHealthBarHooks()
	if self.playerHealthBarHooksInstalled then
		return
	end

	self.playerHealthBarHooksInstalled = true

	if type(hooksecurefunc) == "function" then
		hooksecurefunc("UnitFrameHealthBar_Update", function(_, unit)
			if unit == "player" then
				addon:RefreshPlayerHealthBarMaxHealth()
			elseif unit == "target" then
				addon:RefreshTargetHealthBarMaxHealth()
			end
		end)
	end
end

function addon:InstallLevelOverlayProgressHooks()
	if self.levelOverlayHooksInstalled then
		return
	end

	self.levelOverlayHooksInstalled = true

	if type(hooksecurefunc) ~= "function" then
		return
	end

	local trackedMethods = {
		"SetExperienceCategory",
		"SetExperienceLevel",
		"SetCurrentExperience",
		"AddExperience",
		"PrestigeToNextCategory",
		"SaveAttributesUIValues",
		"ResetAttributesUIValues",
	}

	for _, methodName in ipairs(trackedMethods) do
		if type(self[methodName]) == "function" then
			hooksecurefunc(self, methodName, function()
				addon:OnCustomProgressUpdated()
			end)
		end
	end
end

