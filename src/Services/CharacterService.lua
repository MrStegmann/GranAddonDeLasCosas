--- @module Services.CharacterService
-- Decoupled service layer for character management and inter-feature communications.

local _, GAC = ...

GAC.Services = GAC.Services or {}
GAC.Services.CharacterService = {}

--- Gets the active player character model instance.
-- @return table|nil Player character instance
function GAC.Services.CharacterService:GetPlayerCharacter()
    return GAC.playerCharacter
end

--- Gets character attributes map.
-- @return table Attributes map
function GAC.Services.CharacterService:GetAttributes()
    if GAC.playerCharacter then
        return GAC.playerCharacter:GetAttributes()
    end
    return GAC.characterData and GAC.characterData.attributes or {}
end

--- Gets character talents map.
-- @return table Talents map
function GAC.Services.CharacterService:GetTalents()
    if GAC.playerCharacter then
        return GAC.playerCharacter:GetTalents()
    end
    return GAC.characterData and GAC.characterData.talents or {}
end
