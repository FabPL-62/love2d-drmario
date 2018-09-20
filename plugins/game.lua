local baton = require "plugins/baton"
local Menu = require "plugins/menu"
local Game = {}

-----------------------------------------------------------------------------------------------------------------
-- Funcion que genera el objeto game
-----------------------------------------------------------------------------------------------------------------
function Game:new(love)
local game = {}

-- Escala del juego
game.scale = 3

-- Estado actual del juego
game.estado = "Menu"

-- ancho y alto del tablero [celdas]
game.ancho = 10
game.alto  = 20

-- largo del lado de una celda [pixeles]
game.largo = 10

-- para pausar el juego
game.pausar = false

-- colores de las piezas
game.colores = {

    -- colores juego dr.mario
    drmario = {
        0x109CFF, -- Celeste
        0xF7E721, -- Amarillo
        0xFF0000, -- Rojo
        0x0C4402, -- Verde
        0x4D1163, -- Morado
        0x25259E, -- Azul
        0xFF7300, -- Naranjo
        0xFFFFFF, -- Blanco
        0x1FE71F, -- Lima
        0x650909, -- Marron
        0x5C5C5C, -- Gris
        0x87791D -- Cafe paja
    },

    -- colores juego tetris
    tetris = {
        0x0000FF, -- Azul
        0xFFF600, -- Amarillo
        0xFF0000, -- Rojo
        0x0080FF, -- Azul claro
        0xFF80FF, -- Violeta claro
        0x00FF0C, -- Lima
        0x00FFE4, -- Aqua
        0x00850D, -- Verde
        0xFFFFFF, -- Blanco
        0x969696, -- Gris
        0x510101, -- Cafe rojo
        0x627100, -- Cafe amarillo
        0xFC00FF, -- Fucsia
        0xFF8400, -- Naranja
        0x000342, -- Azul oscuro
    },

    -- colores de columns
    colums = {
        0xFF0000, -- Rojo
        0xC324E0, -- Violeta
        0xE3E600, -- Amarillo
        0xFFC46F, -- Naranja palido
        0x00DAD7, -- Celeste
        0x5FF923, -- Verde claro
    },

    -- colores de puyo
    puyo = {
        0xFF0000, -- Rojo
        0x18AC00, -- Verde
        0x1041DE, -- Azul
        0xFFCD10, -- Amarillo
        0x8308B4, -- Morado
        0x00DBBF, -- Celeste
        0xFF7DD6, -- Rosado
    }
}

-- cola de piezas por lanzar
game.cola = {

    -- maximo de piezas que se muestran
    maximo = 3,

    -- Cola por cada juego
    tetris = {},
    drmario = {},
    columns = {}
}

 -- para esperar la limpieza
game.esperar = false

-- arreglo de jugadores
game.player = {}

-- Jugadores
for i=1,4,1 do

    -- Se crea el arreglo del jugador
    game.player[i] = {}

    -- Tipo de jugador
    if i == 1 then
        game.player[i].tipo = "jugador"
    else
        game.player[i].tipo = "desactivado"
    end

    -- modos de tablero que utiliza
    game.player[i].modo = nil

    -- Nivel de dificultad (1->20)
    game.player[i].dificultad = 1

    -- Nivel de velocidad (1: bajo, 2:medio, 3:alto)
    game.player[i].velocidad = 1

    -- variables por modo
    game.player[i].tetris = {

        -- cantidad de lineas realizadas
        lineas = 0
    }
    game.player[i].drmario = {

        -- cantidad de virus
        virus = 0
    }

    -- Cantidad de combos realizados
    game.player[i].combos = 0

    -- Cantidad de puntos acumulado
    game.player[i].puntos = 0

    -- Cantidad de victorias
    game.player[i].victorias = 0

    -- pieza actual utilizada de la cola
    game.player[i].pieza = 1

    -- posicion de la pieza
    game.player[i].posicion = {game.ancho/2,1}

    -- rotacion de la pieza
    game.player[i].rotacion = 0

    -- Controles
    game.player[i].keys = {
        left = "left",
        right = "right",
        down = "down",
        rot = "up",
        push = "space",
        hold = "c"
    }

    -- Para guardar el tablero
    game.player[i].tablero = {}
end

-----------------------------------------------------------------------------------------------------------------
-- Menu principal
-----------------------------------------------------------------------------------------------------------------
game.menu = Menu:new(love,game)

-----------------------------------------------------------------------------------------------------------------
-- Font principal
-----------------------------------------------------------------------------------------------------------------
game.font = love.graphics.newFont("assets/fonts/Pixel Emulator.otf", 10)

-----------------------------------------------------------------------------------------------------------------
-- Iniciamos las imagenes del juego
-----------------------------------------------------------------------------------------------------------------

-- las imagenes se guardan en una tabla
game.images = {}

-- hay diferentes grupos de imagenes para un mayor orden

-- imagenes de las piezas
game.images.tab = {
    back = love.graphics.newImage("assets/images/Piezas/back.png"),
    capp = love.graphics.newImage("assets/images/Piezas/cap-p.png"),
    capu = love.graphics.newImage("assets/images/Piezas/cap-u.png"),
    capd = love.graphics.newImage("assets/images/Piezas/cap-d.png"),
    capl = love.graphics.newImage("assets/images/Piezas/cap-l.png"),
    capr = love.graphics.newImage("assets/images/Piezas/cap-r.png")
}

-----------------------------------------------------------------------------------------------------------------
-- Iniciamos los efectos de sonido
-----------------------------------------------------------------------------------------------------------------

-- los sonidos se guardan en una tabla
game.sfx = {}

-- game.sfx[1] = love.audio.newSource("Sonidos/sfx/piece_move.wav", "static")

-- funcion para reproducir un sonido
function game.sfx_play(n)
    love.audio.stop(game.sfx[n])
    love.audio.play(game.sfx[n])
end

-----------------------------------------------------------------------------------------------------------------
-- Creamos los shaders
-----------------------------------------------------------------------------------------------------------------
game.shaders = {}

-- Shader de reemplazo de colores
game.shaders.colorReplace = love.graphics.newShader("assets/shaders/replaceColorTol.glsl")
game.shaders.colorReplace:send("colorI",{1,0,0})
game.shaders.colorReplace:send("colorT",{0.5,0.8,0.9})

-----------------------------------------------------------------------------------------------------------------
-- Dibujar el juego
-----------------------------------------------------------------------------------------------------------------
function game.render()
    game.menu.render()
end

return game
end

return Game