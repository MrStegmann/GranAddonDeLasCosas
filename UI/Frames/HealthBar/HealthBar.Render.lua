local _, addon = ...
local hb = addon.healthBar or {}

local function applyCategoryToOverlays(overlays, category)
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

function addon:UpdatePlayerCategoryOverlay()
	local overlays = self.playerCategoryOverlays
	if not overlays then
		return
	end

	local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
	local category = snapshot and snapshot.category or nil
	applyCategoryToOverlays(overlays, category)
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

	if (GetTime() - (cached.timestamp or 0)) > hb.TOOLTIP_CACHE_TTL then
		applyCategoryToOverlays(overlays, nil)
		return
	end

	local progress = cached.progress
	local category = type(progress) == "table" and progress.category or nil
	applyCategoryToOverlays(overlays, category)
end

function addon:UpdateDefaultLevelTextVisibility(unit, shouldShow)
	local fontString = nil
	if unit == "player" then
		fontString = hb.findPlayerDefaultLevelFontString()
	elseif unit == "target" then
		fontString = hb.findTargetDefaultLevelFontString()
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
		hb.updateLevelOverlayPosition(playerOverlay, level)
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
			hb.updateTargetLevelOverlayPosition(targetOverlay, level)
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
		hb.updateTargetLevelOverlayPosition(targetOverlay, level)
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

	local healthText = hb.findPlayerHealthText(healthBar)
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

	local barWidth = hb.getHealthBarWidth(healthBar)
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

	local targetHealthBar = hb.findTargetHealthBar()
	local healthText = hb.findTargetHealthText(targetHealthBar)
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

	local healthText = hb.findTargetHealthText(healthBar)
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

	local barWidth = hb.getHealthBarWidth(healthBar)
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


function addon:RefreshPlayerHealthBarMaxHealth()
	local healthBar = hb.findPlayerHealthBar()
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
	local healthBar = hb.findTargetHealthBar()
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
		if cached and (GetTime() - (cached.timestamp or 0)) <= hb.TOOLTIP_CACHE_TTL then
			local lifeDelta = cached.healthConfig and tonumber(cached.healthConfig.lifeDelta) or 0
			displayHealth = displayHealth + math.floor(lifeDelta or 0)
		end
	end
	displayHealth = math.max(0, math.min(customMaxHealth, displayHealth))

	healthBar:SetMinMaxValues(0, customMaxHealth)
	healthBar:SetValue(displayHealth)
	self:UpdateTargetShieldVisuals(healthBar, displayHealth, customMaxHealth)
end


function addon:CreateLevelOverlayFrame()
	self.levelOverlayTexts = self.levelOverlayTexts or {}
	self.playerCategoryOverlays = self.playerCategoryOverlays or {}
	self.targetCategoryOverlays = self.targetCategoryOverlays or {}

	if not self.levelOverlayTexts.player then
		local playerParent = hb.getFirstExistingGlobal({ "PlayerFrame", "UIParent" })
		local playerAnchor = hb.findPlayerAnchorFrame() or playerParent
		self.levelOverlayTexts.player = hb.createOverlayFontString(playerParent, playerAnchor, "GACPlayerLevelOverlayText")

		if not self.playerCategoryOverlays.rareElite then
			self.playerCategoryOverlays.rareElite = hb.createCategoryOverlayTexture(
				playerParent,
				playerParent,
				"Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
				"GACPlayerCategoryRareEliteOverlay"
			)
		end

		if not self.playerCategoryOverlays.rare then
			self.playerCategoryOverlays.rare = hb.createCategoryOverlayTexture(
				playerParent,
				playerParent,
				"Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
				"GACPlayerCategoryRareOverlay"
			)
		end
	end

	if not self.levelOverlayTexts.target then
		local targetParent = hb.getFirstExistingGlobal({ "TargetFrame", "UIParent" })
		local targetAnchor = hb.findTargetAnchorFrame() or targetParent
		self.levelOverlayTexts.target = hb.createOverlayFontString(targetParent, targetAnchor, "GACTargetLevelOverlayText")

		if not self.targetCategoryOverlays.rareElite then
			self.targetCategoryOverlays.rareElite = hb.createCategoryOverlayTexture(
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
			self.targetCategoryOverlays.rare = hb.createCategoryOverlayTexture(
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
