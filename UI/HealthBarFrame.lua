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

local function createCategoryOverlayTexture(parentFrame, relativeFrame, texturePath, globalName)
	if type(parentFrame) ~= "table" or type(parentFrame.CreateTexture) ~= "function" or not relativeFrame then
		return nil
	end

	local overlay = parentFrame:CreateTexture(globalName, "ARTWORK")
	overlay:SetSize(256, 128)
	overlay:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", 0, 0)
	overlay:SetTexture(texturePath)
	overlay:SetTexCoord(1, 0, 0, 1)
	overlay:Hide()

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

function addon:UpdatePlayerCategoryOverlay()
	local overlays = self.playerCategoryOverlays
	if not overlays then
		return
	end

	local snapshot = self.GetExperienceProgressSnapshot and self:GetExperienceProgressSnapshot() or nil
	local category = snapshot and snapshot.category or nil

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
		targetOverlay:Hide()
		self:UpdateDefaultLevelTextVisibility("target", true)
		return
	end

	if UnitIsUnit("target", "player") then
		targetOverlay:Hide()
		self:UpdateDefaultLevelTextVisibility("target", true)
		return
	end

	local shortName = self.GetUnitShortName and self:GetUnitShortName("target")
	local level = self.GetCachedProgressLevelForShortName and self:GetCachedProgressLevelForShortName(shortName)

	if level then
		updateLevelOverlayPosition(targetOverlay, level)
		targetOverlay:SetText(tostring(level))
		targetOverlay:Show()
		self:UpdateDefaultLevelTextVisibility("target", false)
		return
	end

	targetOverlay:Hide()
	self:UpdateDefaultLevelTextVisibility("target", true)
	self:RequestTargetLevelData(false)
end

function addon:RefreshLevelOverlays()
	if not self.levelOverlayTexts or not self.levelOverlayTexts.player or not self.levelOverlayTexts.target then
		self:CreateLevelOverlayFrame()
	end

	self:RefreshPlayerLevelOverlay()
	self:RefreshTargetLevelOverlay()
end

function addon:OnCustomProgressUpdated()
	self:RefreshPlayerLevelOverlay()
	self:UpdatePlayerCategoryOverlay()

	if self.BroadcastTooltipSyncPayload then
		self:BroadcastTooltipSyncPayload()
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
	end

	self:InstallLevelOverlayProgressHooks()
	self:RefreshLevelOverlays()
	self:UpdatePlayerCategoryOverlay()
end
