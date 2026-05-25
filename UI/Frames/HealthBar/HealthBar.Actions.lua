local _, addon = ...
local hb = addon.healthBar or {}

function addon:GetUnitShortName(unit)
	if not UnitExists(unit) or not UnitIsPlayer(unit) then
		return nil
	end

	local fullName = hb.getUnitFullName(unit)
	if not fullName then
		return nil
	end

	return Ambiguate(fullName, "none")
end

function addon:GetCachedProgressLevelForShortName(shortName)
	if type(shortName) ~= "string" then
		return nil
	end

	local cached = self.tooltipSyncCache and self.tooltipSyncCache[shortName]
	if not cached then
		return nil
	end

	if (GetTime() - (cached.timestamp or 0)) > hb.TOOLTIP_CACHE_TTL then
		return nil
	end

	local progress = cached.progress
	if type(progress) ~= "table" then
		return nil
	end

	local level = tonumber(progress.level)
	if not level then
		return nil
	end

	return math.max(1, math.floor(level))
end


function addon:GetConfiguredPlayerMaxHealth()
	local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
	if not snapshot then
		return nil
	end

	local levelEntry = self.GetLevelEntry and self:GetLevelEntry(snapshot.category, snapshot.level) or nil
	local baseHealth = levelEntry and tonumber(levelEntry.maxHealth) or nil
	if not baseHealth then
		return nil
	end

	local attributes = self.characterData and self.characterData.attributes or nil
	local constitution = attributes and tonumber(attributes["Constitución"]) or 0
	local constitutionValue = math.max(0, math.floor(constitution or 0))
	local maxModifier = self.GetPlayerHealthMaxModifier and self:GetPlayerHealthMaxModifier() or 0

	return math.max(1, math.floor(baseHealth) + constitutionValue + maxModifier)
end

function addon:GetHealthConfigState()
	if not self.characterData then
		return nil
	end

	self.characterData.healthConfig = self.characterData.healthConfig or {
		maxHealthModifier = 0,
		lifeDelta = 0,
		shield = 0,
	}

	local state = self.characterData.healthConfig
	state.maxHealthModifier = math.floor(tonumber(state.maxHealthModifier) or 0)
	state.lifeDelta = math.floor(tonumber(state.lifeDelta) or 0)
	state.shield = math.max(0, math.floor(tonumber(state.shield) or 0))

	return state
end

function addon:GetPlayerHealthMaxModifier()
	local state = self.GetHealthConfigState and self:GetHealthConfigState() or nil
	return state and state.maxHealthModifier or 0
end

function addon:GetPlayerHealthShieldValue()
	local state = self.GetHealthConfigState and self:GetHealthConfigState() or nil
	return state and state.shield or 0
end

function addon:GetConfiguredTargetShieldValue()
	if not UnitExists("target") or not UnitIsPlayer("target") then
		return 0
	end

	if UnitIsUnit("target", "player") then
		return math.max(0, math.floor(self.GetPlayerHealthShieldValue and self:GetPlayerHealthShieldValue() or 0))
	end

	local shortName = self.GetUnitShortName and self:GetUnitShortName("target")
	local cached = shortName and self.tooltipSyncCache and self.tooltipSyncCache[shortName] or nil
	if not cached then
		return 0
	end

	if (GetTime() - (cached.timestamp or 0)) > hb.TOOLTIP_CACHE_TTL then
		return 0
	end

	local shield = cached.healthConfig and tonumber(cached.healthConfig.shield) or 0
	return math.max(0, math.floor(shield or 0))
end

function addon:AddPlayerHealthMaxModifier(amount)
	local state = self.GetHealthConfigState and self:GetHealthConfigState() or nil
	if not state then
		return
	end

	local delta = math.floor(tonumber(amount) or 0)
	if delta == 0 then
		return
	end

	state.maxHealthModifier = state.maxHealthModifier + delta

	if self.RefreshPlayerHealthBarMaxHealth then
		self:RefreshPlayerHealthBarMaxHealth()
	end

	if self.RefreshMainHealthConfigPanel then
		self:RefreshMainHealthConfigPanel()
	end
end

function addon:ModifyPlayerLife(amount)
	local state = self.GetHealthConfigState and self:GetHealthConfigState() or nil
	if not state then
		return
	end

	local delta = math.floor(tonumber(amount) or 0)
	if delta == 0 then
		return
	end

	state.lifeDelta = state.lifeDelta + delta

	if self.RefreshPlayerHealthBarMaxHealth then
		self:RefreshPlayerHealthBarMaxHealth()
	end

	if self.RefreshMainHealthConfigPanel then
		self:RefreshMainHealthConfigPanel()
	end

	if self.BroadcastTooltipSyncPayload then
		self:BroadcastTooltipSyncPayload()
	end
end

function addon:ModifyPlayerShield(amount)
	local state = self.GetHealthConfigState and self:GetHealthConfigState() or nil
	if not state then
		return
	end

	local delta = math.floor(tonumber(amount) or 0)
	if delta == 0 then
		return
	end

	state.shield = math.max(0, state.shield + delta)

	if self.RefreshPlayerHealthBarMaxHealth then
		self:RefreshPlayerHealthBarMaxHealth()
	end

	if self.RefreshMainHealthConfigPanel then
		self:RefreshMainHealthConfigPanel()
	end

	if self.BroadcastTooltipSyncPayload then
		self:BroadcastTooltipSyncPayload()
	end
end


function addon:GetConfiguredTargetMaxHealth()
	if not UnitExists("target") or not UnitIsPlayer("target") then
		return nil
	end

	local category = nil
	local level = nil
	local constitutionValue = 0

	if UnitIsUnit("target", "player") then
		local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
		if not snapshot then
			return nil
		end

		category = snapshot.category
		level = tonumber(snapshot.level)

		local attributes = self.characterData and self.characterData.attributes or nil
		local constitution = attributes and tonumber(attributes["Constitución"]) or 0
		constitutionValue = math.max(0, math.floor(constitution or 0))
	else
		local shortName = self.GetUnitShortName and self:GetUnitShortName("target")
		local cached = shortName and self.tooltipSyncCache and self.tooltipSyncCache[shortName] or nil
		if not cached then
			return nil
		end

		if (GetTime() - (cached.timestamp or 0)) > hb.TOOLTIP_CACHE_TTL then
			return nil
		end

		local progress = cached.progress
		local attributes = cached.attributes
		if type(progress) ~= "table" then
			return nil
		end

		category = progress.category
		level = tonumber(progress.level)
		local constitution = type(attributes) == "table" and tonumber(attributes["Constitución"]) or 0
		constitutionValue = math.max(0, math.floor(constitution or 0))
	end

	if not category or not level then
		return nil
	end

	local levelEntry = self.GetLevelEntry and self:GetLevelEntry(category, math.floor(level)) or nil
	local baseHealth = levelEntry and tonumber(levelEntry.maxHealth) or nil
	if not baseHealth then
		return nil
	end

	return math.max(1, math.floor(baseHealth) + constitutionValue)
end

