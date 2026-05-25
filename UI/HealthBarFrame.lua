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

local function getHealthBarWidth(healthBar)
	if not healthBar then
		return 0
	end

	local width = tonumber(healthBar:GetWidth()) or 0
	if width > 0 then
		return width
	end

	if type(healthBar.GetStatusBarTexture) == "function" then
		local statusTexture = healthBar:GetStatusBarTexture()
		if statusTexture then
			local textureWidth = tonumber(statusTexture:GetWidth()) or 0
			if textureWidth > 0 then
				return textureWidth
			end
		end
	end

	return 0
end

local function findPlayerHealthText(healthBar)
	local directCandidates = {
		_G.PlayerFrameHealthBarText,
		_G.PlayerFrameHealthBarTextLeft,
		_G.PlayerFrameHealthBarTextRight,
	}

	for _, candidate in ipairs(directCandidates) do
		if candidate and type(candidate.GetText) == "function" and type(candidate.SetText) == "function" then
			return candidate
		end
	end

	if healthBar then
		local barCandidates = {
			healthBar.TextString,
			healthBar.LeftText,
			healthBar.rightText,
			healthBar.RightText,
		}

		for _, candidate in ipairs(barCandidates) do
			if candidate and type(candidate.GetText) == "function" and type(candidate.SetText) == "function" then
				return candidate
			end
		end
	end

	if type(_G.PlayerFrame) == "table" then
		local frame = _G.PlayerFrame
		local content = frame.PlayerFrameContent
		local main = content and content.PlayerFrameContentMain
		local healthText = main and main.HealthBarArea and main.HealthBarArea.HealthBar and main.HealthBarArea.HealthBar.TextString
		if healthText and type(healthText.GetText) == "function" and type(healthText.SetText) == "function" then
			return healthText
		end
	end

	return nil
end

local function findTargetHealthText(healthBar)
	local directCandidates = {
		_G.TargetFrameHealthBarText,
		_G.TargetFrameHealthBarTextLeft,
		_G.TargetFrameHealthBarTextRight,
	}

	for _, candidate in ipairs(directCandidates) do
		if candidate and type(candidate.GetText) == "function" and type(candidate.SetText) == "function" then
			return candidate
		end
	end

	if healthBar then
		local barCandidates = {
			healthBar.TextString,
			healthBar.LeftText,
			healthBar.rightText,
			healthBar.RightText,
		}

		for _, candidate in ipairs(barCandidates) do
			if candidate and type(candidate.GetText) == "function" and type(candidate.SetText) == "function" then
				return candidate
			end
		end
	end

	if type(_G.TargetFrame) == "table" then
		local frame = _G.TargetFrame
		local content = frame.TargetFrameContent
		local main = content and content.TargetFrameContentMain
		local healthText = main and main.HealthBarArea and main.HealthBarArea.HealthBar and main.HealthBarArea.HealthBar.TextString
		if healthText and type(healthText.GetText) == "function" and type(healthText.SetText) == "function" then
			return healthText
		end
	end

	return nil
end

local function collectAbsorbCandidates(frame, out, depth)
	if not frame or depth > 3 then
		return
	end

	local frameName = type(frame.GetName) == "function" and frame:GetName() or nil
	if type(frameName) == "string" and string.find(frameName, "TotalAbsorb") then
		out[#out + 1] = frame
	end

	if type(frame.GetChildren) == "function" then
		local children = { frame:GetChildren() }
		for _, child in ipairs(children) do
			collectAbsorbCandidates(child, out, depth + 1)
		end
	end
end

local function resolveNativeAbsorbWidgets(healthBar)
	if not healthBar then
		return nil, nil
	end

	local absorbBar = healthBar.totalAbsorbBar or healthBar.TotalAbsorbBar or nil
	local absorbFrame = healthBar.totalAbsorb or healthBar.TotalAbsorb or nil
	local ownerFrame = type(healthBar.GetParent) == "function" and healthBar:GetParent() or nil

	if not absorbFrame and ownerFrame then
		absorbFrame = ownerFrame.totalAbsorb or ownerFrame.TotalAbsorb or nil
	end

	if not absorbFrame and type(_G.PlayerFrame) == "table" then
		local playerFrame = _G.PlayerFrame
		absorbFrame = playerFrame.totalAbsorb or playerFrame.TotalAbsorb or absorbFrame
	end

	if not absorbBar and absorbFrame and absorbFrame.bar then
		absorbBar = absorbFrame.bar
	end

	if not absorbBar and absorbFrame and type(absorbFrame.SetMinMaxValues) == "function" then
		absorbBar = absorbFrame
	end

	if absorbBar then
		return absorbBar, absorbFrame
	end

	local parent = ownerFrame
	local candidates = {}
	collectAbsorbCandidates(parent, candidates, 0)
	if type(_G.PlayerFrame) == "table" then
		collectAbsorbCandidates(_G.PlayerFrame, candidates, 0)
	end

	for _, candidate in ipairs(candidates) do
		if not absorbFrame and type(candidate) == "table" and type(candidate.Show) == "function" then
			absorbFrame = candidate
		end

		if not absorbBar and type(candidate.SetMinMaxValues) == "function" then
			absorbBar = candidate
		elseif not absorbBar and type(candidate) == "table" and candidate.bar and type(candidate.bar.SetMinMaxValues) == "function" then
			absorbBar = candidate.bar
			absorbFrame = candidate
		end

		if absorbBar then
			break
		end
	end

	return absorbBar, absorbFrame
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

	if (GetTime() - (cached.timestamp or 0)) > TOOLTIP_CACHE_TTL then
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

function addon:EnsurePlayerShieldVisuals(healthBar)
	if not healthBar then
		return
	end

	if not self.playerShieldBar then
		local shieldBar = CreateFrame("StatusBar", nil, healthBar)
		shieldBar:SetFrameStrata(healthBar:GetFrameStrata())
		shieldBar:SetFrameLevel((healthBar:GetFrameLevel() or 1) + 1)
		shieldBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		shieldBar:SetStatusBarColor(0.00, 1.00, 1.00, 1.00)
		shieldBar:SetMinMaxValues(0, 1)
		shieldBar:SetValue(1)
		shieldBar:SetSize(1, 3)
		shieldBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", 0, 0)
		shieldBar:Hide()
		self.playerShieldBar = shieldBar
	end

	if not self.playerShieldText then
		local shieldText = healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		shieldText:SetPoint("LEFT", healthBar, "LEFT", 6, 0)
		shieldText:SetTextColor(0.45, 0.75, 1.0)
		shieldText:SetShadowColor(0, 0, 0, 1)
		shieldText:SetShadowOffset(1, -1)
		shieldText:Hide()
		self.playerShieldText = shieldText
	end
end

function addon:UpdatePlayerShieldVisuals(healthBar, currentHealth, customMaxHealth)
	if not healthBar then
		return
	end

	self:EnsurePlayerShieldVisuals(healthBar)

	local shieldBar = self.playerShieldBar
	local shieldText = self.playerShieldText
	if not shieldText then
		return
	end

	local healthText = findPlayerHealthText(healthBar)
	local function updateHealthTextWithShield(shieldAmount)
		if not healthText then
			return
		end

		local currentText = healthText:GetText() or ""
		local cleanText = string.gsub(currentText, "%s*%(%+%d+%)", "")
		if cleanText == "" then
			cleanText = tostring(math.max(0, math.floor(currentHealth))) .. " / " .. tostring(math.max(1, math.floor(customMaxHealth)))
		end

		if shieldAmount and shieldAmount > 0 then
			healthText:SetText(cleanText .. " (+" .. tostring(shieldAmount) .. ")")
		else
			healthText:SetText(cleanText)
		end
	end

	local shieldValue = self.GetPlayerHealthShieldValue and self:GetPlayerHealthShieldValue() or 0
	if shieldValue <= 0 or customMaxHealth <= 0 or not shieldBar then
		if shieldBar and type(shieldBar.Hide) == "function" then
			shieldBar:Hide()
		end
		shieldText:Hide()
		updateHealthTextWithShield(0)
		return
	end

	local cappedShield = math.max(0, math.floor(shieldValue))
	local clampedShield = math.min(cappedShield, customMaxHealth)
	if clampedShield <= 0 then
		if type(shieldBar.Hide) == "function" then
			shieldBar:Hide()
		end
		shieldText:Hide()
		updateHealthTextWithShield(0)
		return
	end

	local barWidth = getHealthBarWidth(healthBar)
	if barWidth <= 0 then
		shieldBar:Hide()
		shieldText:Hide()
		updateHealthTextWithShield(0)
		return
	end

	local shieldRatio = math.max(0, math.min(1, clampedShield / customMaxHealth))
	local shieldWidth = math.max(1, math.floor((barWidth * shieldRatio) + 0.5))
	local shieldHeight = 3

	shieldBar:ClearAllPoints()
	shieldBar:SetMinMaxValues(0, 1)
	shieldBar:SetValue(1)
	shieldBar:SetSize(shieldWidth, shieldHeight)
	shieldBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", 0, 0)
	shieldBar:Show()

	shieldText:Hide()
	updateHealthTextWithShield(cappedShield)
end

function addon:HideTargetShieldVisuals()
	if self.targetShieldBar and type(self.targetShieldBar.Hide) == "function" then
		self.targetShieldBar:Hide()
	end

	if self.targetShieldText and type(self.targetShieldText.Hide) == "function" then
		self.targetShieldText:Hide()
	end

	local targetHealthBar = findTargetHealthBar()
	local healthText = findTargetHealthText(targetHealthBar)
	if healthText and type(healthText.GetText) == "function" and type(healthText.SetText) == "function" then
		local currentText = healthText:GetText() or ""
		healthText:SetText(string.gsub(currentText, "%s*%(%+%d+%)", ""))
	end
end

function addon:EnsureTargetShieldVisuals(healthBar)
	if not healthBar then
		return
	end

	if not self.targetShieldBar then
		local shieldBar = CreateFrame("StatusBar", nil, healthBar)
		shieldBar:SetFrameStrata(healthBar:GetFrameStrata())
		shieldBar:SetFrameLevel((healthBar:GetFrameLevel() or 1) + 1)
		shieldBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		shieldBar:SetStatusBarColor(0.00, 1.00, 1.00, 1.00)
		shieldBar:SetMinMaxValues(0, 1)
		shieldBar:SetValue(1)
		shieldBar:SetSize(1, 3)
		shieldBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", 0, 0)
		shieldBar:Hide()
		self.targetShieldBar = shieldBar
	end

	if not self.targetShieldText then
		local shieldText = healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		shieldText:SetPoint("LEFT", healthBar, "LEFT", 6, 0)
		shieldText:SetTextColor(0.45, 0.75, 1.0)
		shieldText:SetShadowColor(0, 0, 0, 1)
		shieldText:SetShadowOffset(1, -1)
		shieldText:Hide()
		self.targetShieldText = shieldText
	end
end

function addon:UpdateTargetShieldVisuals(healthBar, currentHealth, customMaxHealth)
	if not healthBar then
		self:HideTargetShieldVisuals()
		return
	end

	self:EnsureTargetShieldVisuals(healthBar)

	local shieldBar = self.targetShieldBar
	local shieldText = self.targetShieldText
	if not shieldBar or not shieldText or customMaxHealth <= 0 then
		self:HideTargetShieldVisuals()
		return
	end

	local healthText = findTargetHealthText(healthBar)
	local function updateHealthTextWithShield(shieldAmount)
		if not healthText then
			return
		end

		local currentText = healthText:GetText() or ""
		local cleanText = string.gsub(currentText, "%s*%(%+%d+%)", "")
		if cleanText == "" then
			cleanText = tostring(math.max(0, math.floor(currentHealth))) .. " / " .. tostring(math.max(1, math.floor(customMaxHealth)))
		end

		if shieldAmount and shieldAmount > 0 then
			healthText:SetText(cleanText .. " (+" .. tostring(shieldAmount) .. ")")
		else
			healthText:SetText(cleanText)
		end
	end

	local shieldValue = self.GetConfiguredTargetShieldValue and self:GetConfiguredTargetShieldValue() or 0
	if shieldValue <= 0 then
		self:HideTargetShieldVisuals()
		updateHealthTextWithShield(0)
		return
	end

	local clampedShield = math.min(shieldValue, customMaxHealth)
	if clampedShield <= 0 then
		self:HideTargetShieldVisuals()
		updateHealthTextWithShield(0)
		return
	end

	local barWidth = getHealthBarWidth(healthBar)
	if barWidth <= 0 then
		self:HideTargetShieldVisuals()
		updateHealthTextWithShield(0)
		return
	end

	local shieldRatio = math.max(0, math.min(1, clampedShield / customMaxHealth))
	local shieldWidth = math.max(1, math.floor((barWidth * shieldRatio) + 0.5))
	local shieldHeight = 3

	shieldBar:ClearAllPoints()
	shieldBar:SetMinMaxValues(0, 1)
	shieldBar:SetValue(1)
	shieldBar:SetSize(shieldWidth, shieldHeight)
	shieldBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", 0, 0)
	shieldBar:Show()

	shieldText:Hide()
	updateHealthTextWithShield(shieldValue)
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

	local state = self.GetHealthConfigState and self:GetHealthConfigState() or nil
	local lifeDelta = state and tonumber(state.lifeDelta) or 0

	local displayHealth = math.floor((customMaxHealth * healthRatio) + 0.5)
	displayHealth = displayHealth + math.floor(lifeDelta or 0)
	displayHealth = math.max(0, math.min(customMaxHealth, displayHealth))
	if state then
		state.lifeDelta = displayHealth - math.floor((customMaxHealth * healthRatio) + 0.5)
	end

	healthBar:SetMinMaxValues(0, customMaxHealth)
	healthBar:SetValue(displayHealth)
	self:UpdatePlayerShieldVisuals(healthBar, displayHealth, customMaxHealth)
end

function addon:RefreshTargetHealthBarMaxHealth()
	local healthBar = findTargetHealthBar()
	if not healthBar then
		if self.HideTargetShieldVisuals then
			self:HideTargetShieldVisuals()
		end
		return
	end

	if not UnitExists("target") or not UnitIsPlayer("target") then
		if self.HideTargetShieldVisuals then
			self:HideTargetShieldVisuals()
		end
		return
	end

	local customMaxHealth = self.GetConfiguredTargetMaxHealth and self:GetConfiguredTargetMaxHealth() or nil
	if not customMaxHealth then
		if self.HideTargetShieldVisuals then
			self:HideTargetShieldVisuals()
		end
		return
	end

	local currentHealth = tonumber(UnitHealth("target")) or 0
	local gameMaxHealth = tonumber(UnitHealthMax("target")) or 0
	local healthRatio = 0
	if gameMaxHealth > 0 then
		healthRatio = math.max(0, math.min(1, currentHealth / gameMaxHealth))
	end

	local displayHealth = math.floor((customMaxHealth * healthRatio) + 0.5)
	if not UnitIsUnit("target", "player") then
		local shortName = self.GetUnitShortName and self:GetUnitShortName("target")
		local cached = shortName and self.tooltipSyncCache and self.tooltipSyncCache[shortName] or nil
		if cached and (GetTime() - (cached.timestamp or 0)) <= TOOLTIP_CACHE_TTL then
			local lifeDelta = cached.healthConfig and tonumber(cached.healthConfig.lifeDelta) or 0
			displayHealth = displayHealth + math.floor(lifeDelta or 0)
		end
	end
	displayHealth = math.max(0, math.min(customMaxHealth, displayHealth))

	healthBar:SetMinMaxValues(0, customMaxHealth)
	healthBar:SetValue(displayHealth)
	self:UpdateTargetShieldVisuals(healthBar, displayHealth, customMaxHealth)
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
