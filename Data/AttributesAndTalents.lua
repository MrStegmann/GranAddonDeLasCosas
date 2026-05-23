local _, addon = ...

addon.attributeGroups = {
    {
        name = "Destreza",
        talents = {
            "Precisión",
            "Combate Ágil",
            "Acrobacias",
            "Sigilo",
            "Juego de Manos",
            "Defensa Ágil",
        },
    },
    {
        name = "Fuerza",
        talents = {
            "Combate a 2 manos",
            "Combate a 1 mano",
            "Atletismo",
            "Brutalidad",
            "Defensa Robusta",
        },
    },
    {
        name = "Inteligencia",
        talents = {
            "Arcano",
            "Vil",
            "Naturaleza",
            "Sombras",
            "Nigromancia",
        },
    },
    {
        name = "Voluntad",
        talents = {
            "Resistencia Mágica",
            "Resistencia a la Pérdida de Control",
            "Fe",
            "Conexión Elemental",
            "Chi",
            "Regeneración de Maná",
        },
    },
    {
        name = "Constitución",
        talents = {
            "Resiliencia",
            "Resistencia a Aturdimientos",
            "Resistencia a Derribos",
            "Resistencia al Frío",
            "Resistencia al Calor",
            "Fortaleza",
        },
    },
    {
        name = "Sabiduría",
        talents = {
            "Conexión con los animales",
            "Supervivencia",
            "Percepción",
        },
    },
    {
        name = "Carisma",
        talents = {
            "Persuasión",
            "Diplomacia",
            "Comercio",
            "Provocación",
            "Seducción",
            "Interpretación",
        },
    },
}

function addon:InitializeAttributeSystem()
    GranAddonDeLasCosasDB = GranAddonDeLasCosasDB or {}
    GranAddonDeLasCosasDB.debug = GranAddonDeLasCosasDB.debug ~= false

    GranAddonDeLasCosasCharDB = GranAddonDeLasCosasCharDB or {}
    GranAddonDeLasCosasCharDB.attributes = GranAddonDeLasCosasCharDB.attributes or {}
    GranAddonDeLasCosasCharDB.talents = GranAddonDeLasCosasCharDB.talents or {}
    GranAddonDeLasCosasCharDB.ui = GranAddonDeLasCosasCharDB.ui or {}
    if GranAddonDeLasCosasCharDB.ui.minimapAngle == nil then
        GranAddonDeLasCosasCharDB.ui.minimapAngle = 220
    end
    GranAddonDeLasCosasCharDB.ui.quickFrame = GranAddonDeLasCosasCharDB.ui.quickFrame or {
        anchor = "CENTER",
        relativeAnchor = "CENTER",
        x = -260,
        y = -120,
    }
    GranAddonDeLasCosasCharDB.turnOrder = GranAddonDeLasCosasCharDB.turnOrder or {
        byGroup = {},
        sequence = 0,
    }

    addon.characterData = GranAddonDeLasCosasCharDB

    local hasMigratedData = next(GranAddonDeLasCosasCharDB.attributes) ~= nil or next(GranAddonDeLasCosasCharDB.talents) ~= nil
    if not hasMigratedData and GranAddonDeLasCosasDB.attributes and GranAddonDeLasCosasDB.talents then
        for key, value in pairs(GranAddonDeLasCosasDB.attributes) do
            GranAddonDeLasCosasCharDB.attributes[key] = value
        end

        for key, value in pairs(GranAddonDeLasCosasDB.talents) do
            GranAddonDeLasCosasCharDB.talents[key] = value
        end
    end

    for _, group in ipairs(self.attributeGroups) do
        if GranAddonDeLasCosasCharDB.attributes[group.name] == nil then
            GranAddonDeLasCosasCharDB.attributes[group.name] = 0
        end

        for _, talent in ipairs(group.talents) do
            if GranAddonDeLasCosasCharDB.talents[talent] == nil then
                GranAddonDeLasCosasCharDB.talents[talent] = 0
            end
        end
    end
end
