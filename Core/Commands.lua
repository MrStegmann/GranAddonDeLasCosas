local addonName, addon = ...

local function printHelp()
    print("|cffffff00" .. addonName .. " comandos:|r")
    print("/gac help - Muestra esta ayuda")
    print("/gac debug - Activa o desactiva modo debug")
    print("/gac ui - Abre o cierra la interfaz de atributos y talentos")
    print("/gacExp - Abre o cierra configuracion de EXP")
end

function addon:RegisterCommands()
    SLASH_GRANADDONDELASCOSAS1 = "/gac"
    SLASH_GRANADDONDELASCOSASEXP1 = "/gacExp"

    SlashCmdList.GRANADDONDELASCOSAS = function(msg)
        local command = (msg or ""):lower():match("^%s*(.-)%s*$")

        if command == "" or command == "ui" then
            if addon.ToggleAttributesUI then
                addon:ToggleAttributesUI()
            end
            return
        end

        if command == "help" then
            printHelp()
            return
        end

        if command == "debug" then
            GranAddonDeLasCosasDB.debug = not GranAddonDeLasCosasDB.debug
            local state = GranAddonDeLasCosasDB.debug and "ON" or "OFF"
            print("Debug: " .. state)
            return
        end

        print("Comando no reconocido: " .. command)
        printHelp()
    end

    SlashCmdList.GRANADDONDELASCOSASEXP = function()
        if addon.ToggleExperienceConfigUI then
            addon:ToggleExperienceConfigUI()
        end
    end
end
