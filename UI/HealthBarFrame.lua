local _, addon = ...

local TOOLTIP_CACHE_TTL = 300

local function getUnitFullName(unit)
	local name, realm = UnitName(unit)
	if not name or name == "" then
		return nil
	end

	if realm and realm ~= "" then
		return name .. "-" .. realm
	end

	return name
end

local function getFirstExistingGlobal(globalNames)
	for _, globalName in ipairs(globalNames) do
		local object = _G[globalName]
		if object then
			return object
		end
	end

	return nil
end

local function canCreateFontString(object)
	return type(object) == "table" and type(object.CreateFontString) == "function"
end

local function findPlayerAnchorFrame()
	return getFirstExistingGlobal({
		"PlayerPortrait",
		"PlayerFramePortrait",
		"PlayerFrame",
	})
end

local function findTargetAnchorFrame()
	return getFirstExistingGlobal({
		"TargetFramePortrait",
		"TargetPortrait",
		"TargetFrame",
	})
end

local function findPlayerDefaultLevelFontString()
	return getFirstExistingGlobal({
		"PlayerLevelText",
		"PlayerFrameTextureFrameLevelText",
	})
end

local function findTargetDefaultLevelFontString()
	return getFirstExistingGlobal({
		"TargetFrameTextureFrameLevelText",
		"TargetLevelText",
	})
end

local function findPlayerHealthBar()
	if _G.PlayerFrameHealthBar and type(_G.PlayerFrameHealthBar.SetMinMaxValues) == "function" then
		return _G.PlayerFrameHealthBar
	end

	if type(_G.PlayerFrame) == "table" then
		local playerFrame = _G.PlayerFrame
		if playerFrame.healthbar and type(playerFrame.healthbar.SetMinMaxValues) == "function" then
			return playerFrame.healthbar
		end

		local content = playerFrame.PlayerFrameContent
		local main = content and content.PlayerFrameContentMain
		local healthBar = main and main.HealthBar
		if healthBar and type(healthBar.SetMinMaxValues) == "function" then
			return healthBar
		end
	end

	return nil
end

local function findTargetHealthBar()
	if _G.TargetFrameHealthBar and type(_G.TargetFrameHealthBar.SetMinMaxValues) == "function" then
		return _G.TargetFrameHealthBar
	end

	if type(_G.TargetFrame) == "table" then
		local targetFrame = _G.TargetFrame
		if targetFrame.healthbar and type(targetFrame.healthbar.SetMinMaxValues) == "function" then
			return targetFrame.healthbar
		end

		local content = targetFrame.TargetFrameContent
		local main = content and content.TargetFrameContentMain
		local healthBar = main and main.HealthBar
		if healthBar and type(healthBar.SetMinMaxValues) == "function" then
			return healthBar
		end
	end

	return nil
end

local function createOverlayFontString(parentFrame, relativeFrame, globalName)
	if not canCreateFontString(parentFrame) or not relativeFrame then
		return nil
	end

	local container = CreateFrame("Frame", nil, parentFrame)
	container:SetAllPoints(relativeFrame)
	container:SetFrameStrata("HIGH")
	container:SetFrameLevel((parentFrame:GetFrameLevel() or 1) + 10)

	local text = container:CreateFontString(globalName, "OVERLAY", "GameFontNormal")
	text:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -43, 3)
	text:SetTextColor(0.95, 0.82, 0.18)
	text:SetShadowColor(0, 0, 0, 1)
	text:SetShadowOffset(1, -1)
	text:Hide()
	text.container = container
	return text
end

local function createCategoryOverlayTexture(parentFrame, relativeFrame, texturePath, globalName, isMirrored)
	if type(parentFrame) ~= "table" or type(parentFrame.CreateTexture) ~= "function" or not relativeFrame then
		return nil
	end

	local container = CreateFrame("Frame", nil, parentFrame)
	container:SetAllPoints(relativeFrame)
	container:SetFrameStrata("HIGH")
	container:SetFrameLevel((parentFrame:GetFrameLevel() or 1) + 10)

	local overlay = container:CreateTexture(globalName, "OVERLAY")
	overlay:SetSize(256, 128)
	overlay:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	overlay:SetTexture(texturePath)
	if isMirrored then
		overlay:SetTexCoord(0, 1, 0, 1)
	else
		overlay:SetTexCoord(1, 0, 0, 1)
	end
	overlay:Hide()
	overlay.container = container

	return overlay
end

local function updateLevelOverlayPosition(text, level)
	if not text or not text.container then
		return
	end

	local numericLevel = tonumber(level) or 0
	local xOffset = (numericLevel == 10) and -43 or -47

	text:ClearAllPoints()
	text:SetPoint("BOTTOMRIGHT", text.container, "BOTTOMRIGHT", xOffset, 3)
end

local function updateTargetLevelOverlayPosition(text, level)
	if not text or not text.container then
		return
	end

	local numericLevel = tonumber(level) or 0
	local xOffset = (numericLevel == 10) and -5 or -7

	text:ClearAllPoints()
	text:SetPoint("BOTTOMRIGHT", text.container, "BOTTOMRIGHT", xOffset, 3)
end

local applyCategoryToOverlays

function addon:UpdatePlayerCategoryOverlay()
	local overlays = self.playerCategoryOverlays
	if not overlays then
		return
	end

	local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
	local category = snapshot and snapshot.category or nil
	applyCategoryToOverlays(overlays, category)
end

applyCategoryToOverlays = function(overlays, category)
	if not overlays then
		return
	end

	if overlays.rare then
		overlays.rare:SetShown(category == "Normal")
	end

	if overlays.rareElite then
		overlays.rareElite:SetShown(category == "Élite" or category == "Jefe")
		if category == "Jefe" then
			overlays.rareElite:SetVertexColor(1.0, 0.82, 0.15, 1.0)
		else
			overlays.rareElite:SetVertexColor(1.0, 1.0, 1.0, 1.0)
		end
	end
end

function addon:UpdateTargetCategoryOverlay()
	local overlays = self.targetCategoryOverlays
	if not overlays then
		return
	end

	if not UnitExists("target") or not UnitIsPlayer("target") then
		applyCategoryToOverlays(overlays, nil)
		return
	end

	if UnitIsUnit("target", "player") then
		local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
		local category = snapshot and snapshot.category or nil
		applyCategoryToOverlays(overlays, category)
		return
	end

	local shortName = self.GetUnitShortName and self:GetUnitShortName("target")
	local cached = shortName and self.tooltipSyncCache and self.tooltipSyncCache[shortName] or nil
	if not cached then
		applyCategoryToOverlays(overlays, nil)
		return
	end

	if (GetTime() - (cached.timestamp or 0)) > TOOLTIP_CACHE_TTL then
		applyCategoryToOverlays(overlays, nil)
		return
	end

	local progress = cached.progress
	local category = type(progress) == "table" and progress.category or nil
	applyCategoryToOverlays(overlays, category)
end
function addon:GetUnitShortName(unit)
	if not UnitExists(unit) or not UnitIsPlayer(unit) then
		return nil
	end

	local fullName = getUnitFullName(unit)
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

	if (GetTime() - (cached.timestamp or 0)) > TOOLTIP_CACHE_TTL then
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

function addon:UpdateDefaultLevelTextVisibility(unit, shouldShow)
	local fontString = nil
	if unit == "player" then
		fontString = findPlayerDefaultLevelFontString()
	elseif unit == "target" then
		fontString = findTargetDefaultLevelFontString()
	end

	if not fontString then
		return
	end

	if shouldShow then
		fontString:Show()
	else
		fontString:Hide()
	end
end

function addon:RefreshPlayerLevelOverlay()
	local overlays = self.levelOverlayTexts
	local playerOverlay = overlays and overlays.player
	if not playerOverlay then
		return
	end

	local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
	local level = snapshot and tonumber(snapshot.level) or nil

	if level then
		updateLevelOverlayPosition(playerOverlay, level)
		playerOverlay:SetText(tostring(math.max(1, math.floor(level))))
		playerOverlay:Show()
		self:UpdateDefaultLevelTextVisibility("player", false)
		return
	end

	playerOverlay:Hide()
	self:UpdateDefaultLevelTextVisibility("player", true)
end

function addon:RefreshTargetLevelOverlay()
	local overlays = self.levelOverlayTexts
	local targetOverlay = overlays and overlays.target
	if not targetOverlay then
		return
	end

	if not UnitExists("target") or not UnitIsPlayer("target") then
		if self.UpdateTargetCategoryOverlay then
			self:UpdateTargetCategoryOverlay()
		end
		targetOverlay:Hide()
		self:UpdateDefaultLevelTextVisibility("target", true)
		return
	end

	if UnitIsUnit("target", "player") then
		local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
		local level = snapshot and tonumber(snapshot.level) or nil

		if level then
			updateTargetLevelOverlayPosition(targetOverlay, level)
			targetOverlay:SetText(tostring(math.max(1, math.floor(level))))
			targetOverlay:Show()
			self:UpdateDefaultLevelTextVisibility("target", false)
			if self.UpdateTargetCategoryOverlay then
				self:UpdateTargetCategoryOverlay()
			end
			return
		end

		if self.UpdateTargetCategoryOverlay then
			self:UpdateTargetCategoryOverlay()
		end
		targetOverlay:Hide()
		self:UpdateDefaultLevelTextVisibility("target", true)
		return
	end

	local shortName = self.GetUnitShortName and self:GetUnitShortName("target")
	local level = self.GetCachedProgressLevelForShortName and self:GetCachedProgressLevelForShortName(shortName)

	if level then
		updateTargetLevelOverlayPosition(targetOverlay, level)
		targetOverlay:SetText(tostring(level))
		targetOverlay:Show()
		self:UpdateDefaultLevelTextVisibility("target", false)
		if self.UpdateTargetCategoryOverlay then
			self:UpdateTargetCategoryOverlay()
		end
		return
	end

	targetOverlay:Hide()
	self:UpdateDefaultLevelTextVisibility("target", true)
	if self.UpdateTargetCategoryOverlay then
		self:UpdateTargetCategoryOverlay()
	end
	self:RequestTargetLevelData(false)
end

function addon:RefreshLevelOverlays()
	if not self.levelOverlayTexts or not self.levelOverlayTexts.player or not self.levelOverlayTexts.target then
		self:CreateLevelOverlayFrame()
	end

	self:RefreshPlayerLevelOverlay()
	self:RefreshTargetLevelOverlay()
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

	return math.max(1, math.floor(baseHealth) + constitutionValue)
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

		if (GetTime() - (cached.timestamp or 0)) > TOOLTIP_CACHE_TTL then
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

function addon:RefreshPlayerHealthBarMaxHealth()
	local healthBar = findPlayerHealthBar()
	if not healthBar then
		return
	end

	local customMaxHealth = self.GetConfiguredPlayerMaxHealth and self:GetConfiguredPlayerMaxHealth() or nil
	if not customMaxHealth then
		return
	end

	local currentHealth = tonumber(UnitHealth("player")) or 0
	local gameMaxHealth = tonumber(UnitHealthMax("player")) or 0
	local healthRatio = 0
	if gameMaxHealth > 0 then
		healthRatio = math.max(0, math.min(1, currentHealth / gameMaxHealth))
	end

	local displayHealth = math.floor((customMaxHealth * healthRatio) + 0.5)
	displayHealth = math.max(0, math.min(customMaxHealth, displayHealth))

	healthBar:SetMinMaxValues(0, customMaxHealth)
	healthBar:SetValue(displayHealth)
end

function addon:RefreshTargetHealthBarMaxHealth()
	local healthBar = findTargetHealthBar()
	if not healthBar then
		return
	end

	local customMaxHealth = self.GetConfiguredTargetMaxHealth and self:GetConfiguredTargetMaxHealth() or nil
	if not customMaxHealth then
		return
	end

	local currentHealth = tonumber(UnitHealth("target")) or 0
	local gameMaxHealth = tonumber(UnitHealthMax("target")) or 0
	local healthRatio = 0
	if gameMaxHealth > 0 then
		healthRatio = math.max(0, math.min(1, currentHealth / gameMaxHealth))
	end

	local displayHealth = math.floor((customMaxHealth * healthRatio) + 0.5)
	displayHealth = math.max(0, math.min(customMaxHealth, displayHealth))

	healthBar:SetMinMaxValues(0, customMaxHealth)
	healthBar:SetValue(displayHealth)
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

function addon:CreateLevelOverlayFrame()
	self.levelOverlayTexts = self.levelOverlayTexts or {}
	self.playerCategoryOverlays = self.playerCategoryOverlays or {}
	self.targetCategoryOverlays = self.targetCategoryOverlays or {}

	if not self.levelOverlayTexts.player then
		local playerParent = getFirstExistingGlobal({ "PlayerFrame", "UIParent" })
		local playerAnchor = findPlayerAnchorFrame() or playerParent
		self.levelOverlayTexts.player = createOverlayFontString(playerParent, playerAnchor, "GACPlayerLevelOverlayText")

		if not self.playerCategoryOverlays.rareElite then
			self.playerCategoryOverlays.rareElite = createCategoryOverlayTexture(
				playerParent,
				playerParent,
				"Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
				"GACPlayerCategoryRareEliteOverlay"
			)
		end

		if not self.playerCategoryOverlays.rare then
			self.playerCategoryOverlays.rare = createCategoryOverlayTexture(
				playerParent,
				playerParent,
				"Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
				"GACPlayerCategoryRareOverlay"
			)
		end
	end

	if not self.levelOverlayTexts.target then
		local targetParent = getFirstExistingGlobal({ "TargetFrame", "UIParent" })
		local targetAnchor = findTargetAnchorFrame() or targetParent
		self.levelOverlayTexts.target = createOverlayFontString(targetParent, targetAnchor, "GACTargetLevelOverlayText")

		if not self.targetCategoryOverlays.rareElite then
			self.targetCategoryOverlays.rareElite = createCategoryOverlayTexture(
				targetParent,
				targetParent,
				"Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
				"GACTargetCategoryRareEliteOverlay",
				true
			)
			if self.targetCategoryOverlays.rareElite then
				self.targetCategoryOverlays.rareElite:ClearAllPoints()
				self.targetCategoryOverlays.rareElite:SetPoint("TOPLEFT", targetParent, "TOPLEFT", -25, 0)
			end
		end

		if not self.targetCategoryOverlays.rare then
			self.targetCategoryOverlays.rare = createCategoryOverlayTexture(
				targetParent,
				targetParent,
				"Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
				"GACTargetCategoryRareOverlay",
				true
			)			if self.targetCategoryOverlays.rare then
				self.targetCategoryOverlays.rare:ClearAllPoints()
				self.targetCategoryOverlays.rare:SetPoint("TOPLEFT", targetParent, "TOPLEFT", -25, 0)
			end
		end
	end

	self:InstallLevelOverlayProgressHooks()
	self:InstallPlayerHealthBarHooks()
	self:RefreshLevelOverlays()
	self:UpdatePlayerCategoryOverlay()
	self:UpdateTargetCategoryOverlay()
	self:RefreshPlayerHealthBarMaxHealth()
	self:RefreshTargetHealthBarMaxHealth()
end
