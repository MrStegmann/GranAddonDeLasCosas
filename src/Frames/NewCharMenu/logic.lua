local addonName, GAC = ...

-- Obtiene los talentos resultantes de combinar dos razas (Mestizo)
function GAC:GetMestizoTalents(race1Key, race2Key)
    local races = self.racesTable
    if not races then return {}, {} end

    local r1Data = races[race1Key]
    local r2Data = races[race2Key]

    local mergedTalents = {}
    local function ProcessTalents(raceData)
        if not raceData or not raceData.talents then return end
        for t, v in pairs(raceData.talents) do
            mergedTalents[t] = (mergedTalents[t] or 0) + v
        end
    end

    ProcessTalents(r1Data)
    ProcessTalents(r2Data)

    local advTalents = {}
    local disTalents = {}
    for t, v in pairs(mergedTalents) do
        if v > 0 then
            advTalents[t] = v
        elseif v < 0 then
            disTalents[t] = v
        end
    end

    return advTalents, disTalents
end

-- Valida si el Paso 1 está completo y correcto
function GAC:IsStep1Valid(state)
    if not state.race1 then
        return false
    end
    if state.race2 then
        if state.advPoints ~= 3 or state.disPoints ~= -3 then
            return false
        end
    end
    return true
end

-- Obtiene el total de puntos de atributos ya repartidos en el Paso 2
function GAC:GetTotalAllocatedAttributes(state)
    local total = 0
    if state and state.allocatedAttributes then
        for _, v in pairs(state.allocatedAttributes) do
            total = total + v
        end
    end
    return total
end

-- Obtiene los talentos gastados en una rama concreta
function GAC:GetAllocatedTalentsInGroup(state, groupName)
    local total = 0
    if not self.attributeGroups or not state or not state.allocatedTalents then return total end

    for _, group in ipairs(self.attributeGroups) do
        if group.name == groupName then
            for _, talent in ipairs(group.talents) do
                total = total + (state.allocatedTalents[talent] or 0)
            end
            break
        end
    end
    return total
end

-- Guarda los datos del Paso 1
function GAC:SaveNewCharStep1(state)
    if not self.characterData then return end
    
    self.characterData.progress = self.characterData.progress or {}
    self.characterData.progress.category = state.category
    
    self.characterData.race1 = state.race1
    
    if state.race2 then
        self.characterData.race2 = state.race2
    else
        self.characterData.race2 = nil
    end
end

-- Aplica las ventajas y desventajas de la raza antes del guardado final
function GAC:ApplyRaceTalents(state)
    if not self.characterData then return end
    self.characterData.talents = self.characterData.talents or {}
    
    if state.race2 then
        for t, v in pairs(state.selectedTalents) do
            self.characterData.talents[t] = (self.characterData.talents[t] or 0) + v
        end
    else
        local r1Data = self.racesTable and self.racesTable[state.race1]
        if r1Data and r1Data.talents then
            for t, v in pairs(r1Data.talents) do
                self.characterData.talents[t] = (self.characterData.talents[t] or 0) + v
            end
        end
    end
end

-- Guarda los datos y finaliza la creación
function GAC:SaveNewCharFinal(state)
    if not self.characterData then return end

    self.characterData.attributes = self.characterData.attributes or {}
    self.characterData.talents = self.characterData.talents or {}
    self.characterData.positiveTraits = self.characterData.positiveTraits or {}

    for k, v in pairs(state.allocatedAttributes) do
        self.characterData.attributes[k] = (self.characterData.attributes[k] or 0) + v
    end
    for k, v in pairs(state.allocatedTalents) do
        self.characterData.talents[k] = (self.characterData.talents[k] or 0) + v
    end

    -- Guardar y aplicar rasgos positivos
    for traitKey, traitLevel in pairs(state.positiveTraits or {}) do
        self.characterData.positiveTraits[traitKey] = {
            level = traitLevel
        }
        
        -- Si este rasgo requiere selección de talento
        if state.positiveTraitsTalents and state.positiveTraitsTalents[traitKey] then
            self.characterData.positiveTraits[traitKey].selectedTalent = state.positiveTraitsTalents[traitKey]
        end

        -- Buscar los modificadores y aplicarlos
        for _, traitDef in ipairs(self.PositiveTraits or {}) do
            if traitDef.name == traitKey and traitDef.modifiers then
                local mods = traitDef.modifiers[traitLevel]
                if mods then
                    for modKey, modValue in pairs(mods) do
                        if modKey == "_selected" then
                            local selectedTalent = state.positiveTraitsTalents and state.positiveTraitsTalents[traitKey]
                            if selectedTalent then
                                self.characterData.talents[selectedTalent] = (self.characterData.talents[selectedTalent] or 0) + modValue
                            end
                        else
                            -- Asumimos que modifica un talento
                            self.characterData.talents[modKey] = (self.characterData.talents[modKey] or 0) + modValue
                        end
                    end
                end
                break
            end
        end
    end

    if self.ApplyRaceSpecialUpgrades then
        self:ApplyRaceSpecialUpgrades()
    end

    self.characterData.isCreated = true
end
