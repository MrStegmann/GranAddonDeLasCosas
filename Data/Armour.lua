local _, addon = ...

addon.armourData = {
    ["Armaduras"] = {
        ["Tela"] = {
            ["Reducción física"] = 0,
            ["Reducción mágica"] = 4,
            ["Durabilidad"] = 2,
            ["Perforante"] = "Vulnerable",
            ["Cortante"] = "Vulnerable",
            ["Contundente"] = "Vulnerable",
        },
        ["Cuero"] = {
            ["Reducción física"] = 2,
            ["Reducción mágica"] = 1,
            ["Durabilidad"] = 4,
            ["Perforante"] = "Vulnerable",
            ["Cortante"] = "Débil",
            ["Contundente"] = "Normal",
        },
        ["Malla"] = {
            ["Reducción física"] = 4,
            ["Reducción mágica"] = 0,
            ["Durabilidad"] = 3,
            ["Perforante"] = "Vulnerable",
            ["Cortante"] = "Resistente",
            ["Contundente"] = "Débil",
        },
        ["Placa"] = {
            ["Reducción física"] = 6,
            ["Reducción mágica"] = 0,
            ["Durabilidad"] = 5,
            ["Perforante"] = "Resistente",
            ["Cortante"] = "Muy Resistente",
            ["Contundente"] = "Vulnerable",
        },
    },
    ["Piezas"] = {
        ["Cabeza"] = {
            ["Placa"] = {
                ["Requisitos"] = {
                    { ["Brutalidad"] = 1 },
                },
                ["Penalizaciones"] = {
                    { ["Percepción"] = -1 },
                    { ["Acrobacias"] = -1 },
                    { ["Defensa Ágil"] = -1 },
                },
            },
        },
        ["Pecho"] = {
            ["Malla"] = {
                ["Requisitos"] = {
                    { ["Brutalidad"] = 1 },
                },
                ["Penalizaciones"] = {
                    { ["Movimiento"] = -1 },
                    { ["Acrobacias"] = -1 },
                    { ["Defensa Ágil"] = -1 },
                },
            },
            ["Placa"] = {
                ["Requisitos"] = {
                    { ["Brutalidad"] = 2 },
                },
                ["Penalizaciones"] = {
                    { ["Movimiento"] = -5 },
                    { ["Acrobacias"] = -2 },
                    { ["Defensa Ágil"] = -2 },
                    { ["Sigilo"] = -4 },
                },
            },
        },
        ["Guantes"] = {
            ["Malla"] = {
                ["Penalizaciones"] = {
                    { ["Juego de Manos"] = -1 },
                },
            },
            ["Placa"] = {
                ["Requisitos"] = {
                    { ["Brutalidad"] = 1 },
                },
                ["Penalizaciones"] = {
                    { ["Juego de Manos"] = -2 },
                    { ["Acrobacias"] = -1 },
                },
            },
        },
        ["Piernas"] = {
            ["Malla"] = {
                ["Requisitos"] = {
                    { ["Brutalidad"] = 1 },
                },
                ["Penalizaciones"] = {
                    { ["Movimiento"] = -1 },
                    { ["Acrobacias"] = -1 },
                    { ["Defensa Ágil"] = -1 },
                },
            },
            ["Placa"] = {
                ["Requisitos"] = {
                    { ["Brutalidad"] = 2 },
                },
                ["Penalizaciones"] = {
                    { ["Movimiento"] = -5 },
                    { ["Acrobacias"] = -2 },
                    { ["Defensa Ágil"] = -2 },
                    { ["Sigilo"] = -4 },
                },
            },
        },
    },
    ["Refuerzos"] = {
        ["Cuero"] = {
            ["Reducción física"] = 1,
            ["Reducción mágica"] = 0,
            ["Durabilidad"] = 1,
        },
        ["Malla"] = {
            ["Reducción física"] = 2,
            ["Reducción mágica"] = 0,
            ["Durabilidad"] = 2,
            ["Penalizaciones"] = {
                { ["Defensa Ágil"] = -1 },
            },
        },
        ["Placa"] = {
            ["Reducción física"] = 3,
            ["Reducción mágica"] = 0,
            ["Durabilidad"] = 3,
            ["Requisitos"] = {
                { ["Brutalidad"] = 1 },
            },
            ["Penalizaciones"] = {
                { ["Movimiento"] = -1 },
                { ["Defensa Ágil"] = -2 },
            },
        },
    },
}
