local _, addon = ...

addon.healthBar = addon.healthBar or {}
local hb = addon.healthBar


hb.TOOLTIP_CACHE_TTL = 300

function hb.getUnitFullName(unit)
	local name, realm = UnitName(unit)
	if not name or name == "" then
		return nil
	end

	if realm and realm ~= "" then
		return name .. "-" .. realm
	end

	return name
end

function hb.getFirstExistingGlobal(globalNames)
	for _, globalName in ipairs(globalNames) do
		local object = _G[globalName]
		if object then
			return object
		end
	end

	return nil
end

function hb.canCreateFontString(object)
	return type(object) == "table" and type(object.CreateFontString) == "function"
end

function hb.findPlayerAnchorFrame()
	return hb.getFirstExistingGlobal({
		"PlayerPortrait",
		"PlayerFramePortrait",
		"PlayerFrame",
	})
end

function hb.findTargetAnchorFrame()
	return hb.getFirstExistingGlobal({
		"TargetFramePortrait",
		"TargetPortrait",
		"TargetFrame",
	})
end

function hb.findPlayerDefaultLevelFontString()
	return hb.getFirstExistingGlobal({
		"PlayerLevelText",
		"PlayerFrameTextureFrameLevelText",
	})
end

function hb.findTargetDefaultLevelFontString()
	return hb.getFirstExistingGlobal({
		"TargetFrameTextureFrameLevelText",
		"TargetLevelText",
	})
end

function hb.findPlayerHealthBar()
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

function hb.findTargetHealthBar()
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

function hb.getHealthBarWidth(healthBar)
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

function hb.findPlayerHealthText(healthBar)
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

function hb.findTargetHealthText(healthBar)
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

function hb.collectAbsorbCandidates(frame, out, depth)
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
			hb.collectAbsorbCandidates(child, out, depth + 1)
		end
	end
end

function hb.resolveNativeAbsorbWidgets(healthBar)
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
	hb.collectAbsorbCandidates(parent, candidates, 0)
	if type(_G.PlayerFrame) == "table" then
		hb.collectAbsorbCandidates(_G.PlayerFrame, candidates, 0)
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

function hb.createOverlayFontString(parentFrame, relativeFrame, globalName)
	if not hb.canCreateFontString(parentFrame) or not relativeFrame then
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

function hb.createCategoryOverlayTexture(parentFrame, relativeFrame, texturePath, globalName, isMirrored)
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

function hb.updateLevelOverlayPosition(text, level)
	if not text or not text.container then
		return
	end

	local numericLevel = tonumber(level) or 0
	local xOffset = (numericLevel == 10) and -43 or -47

	text:ClearAllPoints()
	text:SetPoint("BOTTOMRIGHT", text.container, "BOTTOMRIGHT", xOffset, 3)
end

function hb.updateTargetLevelOverlayPosition(text, level)
	if not text or not text.container then
		return
	end

	local numericLevel = tonumber(level) or 0
	local xOffset = (numericLevel == 10) and -5 or -7

	text:ClearAllPoints()
	text:SetPoint("BOTTOMRIGHT", text.container, "BOTTOMRIGHT", xOffset, 3)
end

-- Shared helper namespace only.

