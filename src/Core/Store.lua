local addonName, GAC = ...

local Store = {}
GAC.Store = Store

local subscribers = {}

function Store:Initialize(characterData)
    self.state = characterData or GranAddonDeLasCosasCharDB or {}
    
    -- Register action handlers with Dispatcher
    if GAC.Dispatcher then
        GAC.Dispatcher:Register(GAC.Actions.UPDATE_PROGRESS, function(payload)
            self:HandleUpdateProgress(payload)
        end)
        GAC.Dispatcher:Register(GAC.Actions.ADD_EXPERIENCE, function(payload)
            self:HandleAddExperience(payload)
        end)
        GAC.Dispatcher:Register(GAC.Actions.MODIFY_HEALTH, function(payload)
            self:HandleModifyHealth(payload)
        end)
        GAC.Dispatcher:Register(GAC.Actions.MODIFY_SHIELD, function(payload)
            self:HandleModifyShield(payload)
        end)
        GAC.Dispatcher:Register(GAC.Actions.UPDATE_STORY, function(payload)
            self:HandleUpdateStory(payload)
        end)
    end
end

function Store:GetState()
    return self.state or GranAddonDeLasCosasCharDB or {}
end

function Store:Subscribe(callback)
    if type(callback) ~= "function" then
        return
    end
    table.insert(subscribers, callback)
end

function Store:NotifySubscribers()
    local state = self:GetState()
    for _, callback in ipairs(subscribers) do
        if GAC.SafeCall then
            GAC:SafeCall(callback, state)
        else
            pcall(callback, state)
        end
    end
end

function Store:HandleUpdateProgress(payload)
    if not payload then return end
    local state = self:GetState()
    state.progress = state.progress or {}

    if payload.category then
        state.progress.category = payload.category
    end
    if payload.level then
        state.progress.level = payload.level
    end

    if GAC.SetExperienceCategory then
        GAC:SetExperienceCategory(state.progress.category or "normal")
    end
    if GAC.SetExperienceLevel then
        GAC:SetExperienceLevel(state.progress.level or 1)
    end

    self:NotifySubscribers()
end

function Store:HandleAddExperience(payload)
    if not payload or not payload.expAmount then return end
    if GAC.AddExperience then
        GAC:AddExperience(payload.expAmount)
    end
    self:NotifySubscribers()
end

function Store:HandleModifyHealth(payload)
    if not payload then return end
    local state = self:GetState()
    if payload.delta and GAC.ModifyHealth then
        GAC:ModifyHealth(payload.delta)
    elseif payload.currentHealth ~= nil then
        state.health = payload.currentHealth
        if payload.maxHealth ~= nil then
            state.maxHealth = payload.maxHealth
        end
    end
    self:NotifySubscribers()
end

function Store:HandleModifyShield(payload)
    if not payload then return end
    local state = self:GetState()
    if payload.delta and GAC.ModifyShield then
        GAC:ModifyShield(payload.delta)
    elseif payload.currentShield ~= nil then
        state.shield = payload.currentShield
    end
    self:NotifySubscribers()
end

function Store:HandleUpdateStory(payload)
    if not payload or not payload.text then return end
    local state = self:GetState()
    state.story = payload.text
    self:NotifySubscribers()
end
