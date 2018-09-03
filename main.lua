json = require("json")

-- funcion para redondear un numero de forma simetrica
function math.round(num) 
    if num >= 0 then return math.floor(num+.5) 
    else return math.ceil(num-.5) end
end

-- obtenemos un color {r,g,b} desde un valor decimal
function math.color(color)
    local r = math.floor(color/256^2) % 256 / 255
    local g = math.floor(color/256) % 256 / 255
    local b = color % 256 / 255
    return {r,g,b}
end

-- copiar una tabla sin referencia
function tabla_copiar(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- funcion de comienzo
function love.load()

    -----------------------------------------------------------------------------------------------------------------
    -- Variables generales para el juego
    -----------------------------------------------------------------------------------------------------------------

    -- Se inicializa el juego en pantalla completa
    love.window.setFullscreen(true, "desktop")
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    -- iniciamos el objeto general del juego
    game = {}

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

    -- Se definen las piezas
    game.piezas = {

        -- piezas del tetris
        tetris = {

            -- [][][][]
            {2,{-1,0},{1,0},{2,0}},

            -- [][]
            -- [][]
            {1,{-1,0},{0,1},{-1,1}},

            -- [][][]
            -- []
            {4,{-1,0},{1,0},{-1,1}},

            -- [][][]
            --     []
            {4,{-1,0},{1,0},{1,1}},

            -- [][][]
            --   []
            {4,{-1,0},{1,0},{0,1}},

            -- [][]
            --   [][]
            {2,{-1,0},{0,1},{1,1}},

            --   [][]
            -- [][]
            {2,{1,0},{-1,1},{0,1}}
        },

        -- seleccion de colores dr mario
        drmario = {1,2,3},

        -- seleccion de colores columns
        columns = {1,2,3,4,5,6},

        -- seleccion de colores puyo
        puyo = {1,2,3,4,5}
    }

    -- cola de piezas por lanzar
    game.cola = {

        -- maximo de piezas que se muestran
        maximo = 4,

        -- Cola por cada juego
        tetris = {},
        drmario = {},
        columns = {}
    }

    -----------------------------------------------------------------------------------------------------------------
    -- Iniciamos los jugadores del juego
    -----------------------------------------------------------------------------------------------------------------

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

    -- Menu del juego
    game.menu = {

        -- Cursor del menu
        cursor = 1,

        -- Ultima posicion del cursor
        ultima = {},

        -- posicion en el menu
        posicion = 1,

        -- cuerpo del menu
        body = {{

            -----------------------------------------------------------------------------------------------------------------
            -- Menu 1 : principal
            -----------------------------------------------------------------------------------------------------------------
            titulo = "Puzzles",
            opciones = {{
                txt = "Un Jugador",
                act = function ()
                    game.menu.cursor = 2
                end
            },{
                txt = "Multi-jugador",
                act = function() 
                    game.menu.cursor = 3
                end
            },{
                txt = "Opciones",
                act = function()
                    game.menu.cursor = 4
                end
            },{
                txt = "Salir",
                act = function()
                    love.event.quit()
                end
            }}
        },{

            -----------------------------------------------------------------------------------------------------------------
            -- Menu 2 : Seleccion de modos de juego
            -----------------------------------------------------------------------------------------------------------------
            titulo = "Modos de juego",
            opciones = {{
                txt = "Tetris",
                act = function ()
                    for i=1,4 do
                        if game.player[i].tipo ~= "desactivado" then
                            game.player[i].modo = "tetris"
                        end
                    end
                    game.menu.cursor = 5
                end
            },{
                txt = "Dr.Mario",
                act = function ()
                    for i=1,4 do
                        if game.player[i].tipo ~= "desactivado" then
                            game.player[i].modo = "drmario"
                        end
                    end
                    game.menu.cursor = 6
                end
            },{
                txt = "Puyo Puyo",
                act = function ()
                    for i=1,4 do
                        if game.player[i].tipo ~= "desactivado" then
                            game.player[i].modo = "puyo"
                        end
                    end
                    game.menu.cursor = 7
                end
            },{
                txt = "Columns",
                act = function ()
                    for i=1,4 do
                        if game.player[i].tipo ~= "desactivado" then
                            game.player[i].modo = "columns"
                        end
                    end
                    game.menu.cursor = 8
                end
            },{
                txt = "Combinado",
                act = function ()
                    for i=1,4 do
                        if game.player[i].tipo ~= "desactivado" then
                            game.player[i].modo = {}
                        end
                    end
                    game.menu.cursor = 9
                end
            }}
        },{

            -----------------------------------------------------------------------------------------------------------------
            -- Menu 3 : Seleccion de tipos de jugadores
            -----------------------------------------------------------------------------------------------------------------
            titulo = "Cantidad de jugadores",
            opciones = {{
                txt = "Jugador 1: < $ >",
                opt = {"desactivado","jugador","cpu"},
                def = 2,
                change = function(val)
                    game.player[1].tipo = val
                end
            },{
                txt = "Jugador 2: < $ >",
                opt = {"desactivado","jugador","cpu"},
                def = 1,
                change = function(val)
                    game.player[2].tipo = val
                end
            },{
                txt = "Jugador 3: < $ >",
                opt = {"desactivado","jugador","cpu"},
                def = 1,
                change = function(val)
                    game.player[3].tipo = val
                end
            },{
                txt = "Jugador 4: < $ >",
                opt = {"desactivado","jugador","cpu"},
                def = 1,
                change = function(val)
                    game.player[4].tipo = val
                end
            }},
            act = function()
                local c = 0
                for i=1,4,1 do
                    if game.player[i].tipo == "desactivado" then
                        c = c + 1
                    end
                end
                if c < 4 then
                    game.menu.cursor = 2
                else
                    return false
                end
            end
        },{

            -----------------------------------------------------------------------------------------------------------------
            -- Menu 4 : Opciones
            -----------------------------------------------------------------------------------------------------------------
            titulo = "Opciones"
        },{

            
        }}
    }

    -- para esperar la limpieza
    game.esperar = false

    -----------------------------------------------------------------------------------------------------------------
    -- Font del menu
    -----------------------------------------------------------------------------------------------------------------
    game.font = love.graphics.newFont("Pixel Emulator.otf", 10)

    -----------------------------------------------------------------------------------------------------------------
    -- Iniciamos las imagenes del juego
    -----------------------------------------------------------------------------------------------------------------

    -- las imagenes se guardan en una tabla
    game.img = {}

    -- hay diferentes grupos de imagenes para un mayor orden

    -- imagenes de las piezas
    game.img.tab = {
        back = love.graphics.newImage("Imagenes/Piezas/back.png"),
        capp = love.graphics.newImage("Imagenes/Piezas/cap-p.png"),
        capu = love.graphics.newImage("Imagenes/Piezas/cap-u.png"),
        capd = love.graphics.newImage("Imagenes/Piezas/cap-d.png"),
        capl = love.graphics.newImage("Imagenes/Piezas/cap-l.png"),
        capr = love.graphics.newImage("Imagenes/Piezas/cap-r.png")
    }

    -----------------------------------------------------------------------------------------------------------------
    -- Iniciamos los efectos de sonido
    -----------------------------------------------------------------------------------------------------------------

    -- los sonidos se guardan en una tabla
    game.sfx = {}

    -- game.sfx[1] = love.audio.newSource("Sonidos/sfx/piece_move.wav", "static")

    -----------------------------------------------------------------------------------------------------------------
    -- Creamos los shaders
    -----------------------------------------------------------------------------------------------------------------

    -- Shader de reemplazo de colores
    ShRColor = love.graphics.newShader [[

        // aca iniciamos el color de entrada y salida
        extern vec3 colorI, colorO;

        // tolerancia de cambio
        extern vec3 colorT;

        // factor alpha externo
        extern number alpha;

        vec4 rgb_to_hsv(vec4 col)
        {
            number H = 0.0;
            number S = 0.0;
            number V = 0.0;
            
            number M = max(col.r, max(col.g, col.b));
            number m = min(col.r, min(col.g, col.b));
            
            V = M;
            
            number C = M - m;
            
            if (C > 0.0)
            {
                if (M == col.r) H = mod( (col.g - col.b) / C, 6.0);
                if (M == col.g) H = (col.b - col.r) / C + 2.0;
                if (M == col.b) H = (col.r - col.g) / C + 4.0;
                H /= 6.0;
                S = C / V;
            }
            
            return vec4(H, S, V, col.a);
        }
        
        vec4 hsv_to_rgb(vec4 col)
        {
            number H = col.r;
            number S = col.g;
            number V = col.b;
            
            number C = V * S;
            
            H *= 6.0;
            number X = C * (1.0 - abs( mod(H, 2.0) - 1.0 ));
            number m = V - C;
            C += m;
            X += m;
            
            if (H < 1.0) return vec4(C, X, m, col.a);
            if (H < 2.0) return vec4(X, C, m, col.a);
            if (H < 3.0) return vec4(m, C, X, col.a);
            if (H < 4.0) return vec4(m, X, C, col.a);
            if (H < 5.0) return vec4(X, m, C, col.a);
            else         return vec4(C, m, X, col.a);
        }

        // proceso principal
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 pixel = Texel(texture,texture_coords);
            vec4 pixel_hsv = rgb_to_hsv(pixel);
            vec4 input_hsv = rgb_to_hsv(vec4(colorI,1.0));
            vec4 delta     = pixel_hsv - input_hsv;

            if (all(lessThanEqual(abs(delta),vec4(colorT,1.0))))
            {
                number M = max(pixel.r, max(pixel.g, pixel.b));
                number m = min(pixel.r, min(pixel.g, pixel.b));
                pixel = vec4((colorO.rgb * (M - m) + ((colorO.r + colorO.g + colorO.b) * (1.0 - M) / 3.0 + 1.0) * m), pixel.a);
            }

            pixel = vec4(pixel.r,pixel.g,pixel.b,pixel.a*alpha);

            return pixel * color;
        }

    ]]

    ShRColor:send("colorI",{1,0,0})
    ShRColor:send("colorT",{0.5,0.8,0.9})

end

-- funcion para reproducir un sonido
function sfx_play(n)
    love.audio.stop(game.sfx[n])
    love.audio.play(game.sfx[n])
end

-- loop principal
function love.update(dt)

    -- vemos si no se esta esperando
    if (game.esperar == false)
    then
        
    else
        -- game.funcion.limpiar()
    end

end

-- funcion de tecla presionada
function love.keypressed(key)

    if game.estado == "Menu" then

        local menu = game.menu.body[game.menu.cursor]
        if key == 'up' then
            if game.menu.posicion > 1 then
                game.menu.posicion = game.menu.posicion - 1
            else
                game.menu.posicion = #menu.opciones
            end
        elseif key == 'down' then
            if game.menu.posicion < #menu.opciones then
                game.menu.posicion = game.menu.posicion + 1
            else
                game.menu.posicion = 1
            end
        elseif key == 'left' then
            local opcion = menu.opciones[game.menu.posicion]
            if opcion.opt ~= nil then
                if opcion.def > 1 then
                    opcion.def = opcion.def - 1
                else
                    opcion.def = #opcion.opt
                end
                opcion.change(opcion.opt[opcion.def])
            end
        elseif key == 'right' then
            local opcion = menu.opciones[game.menu.posicion]
            if opcion.opt ~= nil then
                if opcion.def < #opcion.opt then
                    opcion.def = opcion.def + 1
                else
                    opcion.def = 1
                end
                opcion.change(opcion.opt[opcion.def])
            end
        elseif key == 'return' then
            if menu.opciones[game.menu.posicion].act ~= nil then
                table.insert(game.menu.ultima,game.menu.cursor)
                local r = menu.opciones[game.menu.posicion].act()
                if r == false then
                    table.remove(game.menu.ultima)
                else
                    game.menu.posicion = 1
                end
            elseif menu.act ~= nil then
                table.insert(game.menu.ultima,game.menu.cursor)
                local r = menu.act()
                if r == false then
                    table.remove(game.menu.ultima)
                else
                    game.menu.posicion = 1
                end
            end
        elseif key == 'escape' then
            if #game.menu.ultima > 0 then
                game.menu.cursor = table.remove(game.menu.ultima)
                game.menu.posicion = 1
            else
                love.event.quit()
            end
        end

    elseif game.estado == "Juego" then

    end

    -- Reseteamos el juego
    if (key == 'r') then 
        love.load()

    -- elseif (key == 'c') then
    --  game.funcion.hold()
    end
end

-- dibujar el juego
function love.draw()

    -- escalamos el juego
    love.graphics.scale(game.scale,game.scale)

    -- Si se esta en modo menu
    if game.estado == "Menu" then

        love.graphics.setFont(game.font)

        local menu = game.menu.body[game.menu.cursor]
        for i=1,#menu.opciones,1 do
            local opciones = menu.opciones[i]
            local txt = opciones.txt
            if opciones.opt ~= nil then
                txt = string.gsub(txt,"%$",opciones.opt[opciones.def])
            end
            if i == game.menu.posicion then love.graphics.print("*",16,16 + 16*i) end 
            love.graphics.print(txt,32,16 + 16*i)
        end

        -- Se dibuja el titulo del menu
        local font = love.graphics.getFont()
        local tx = (love.graphics.getWidth()/game.scale-font:getWidth(menu.titulo))/2
        love.graphics.print(menu.titulo,tx,16)
    
    elseif game.estado == "Juego" then

        -- Se dibuja un solo tablero
        local start_x = love.graphics.getWidth()/((game.players*2)*game.scale)-(game.ancho*game.largo)/2
        local start_y = (love.graphics.getHeight()/game.scale-game.alto*game.largo)/2

        -- Se recorren los dos tableros
        for t=1,game.players,1 do

            local offset = (t-1)*love.graphics.getWidth()/(game.players*game.scale)

             -- Se dibuja el fondo del tablero
            for i=1,game.ancho,1 do
                for j=1,game.alto,1 do
                    love.graphics.draw(game.img.tab.back, start_x+(i-1)*game.largo+offset, start_y+(j-1)*game.largo)
                end
            end

            -- Se dibuja la capsula del jugador
            do
                local pieza_cola = game.cola.pieza[game.player[t].pieza]
                local px = game.player[t].posicion[1]
                local py = game.player[t].posicion[2]

                -- Se obtiene el color 1
                local col_index = game.piezas.seleccion[pieza_cola[1]]
                local col1 = math.color(game.piezas.colores[col_index])

                -- Se obtiene el color 2
                col_index = game.piezas.seleccion[pieza_cola[2]]
                local col2 = math.color(game.piezas.colores[col_index])

                if (game.player[t].rotacion == 0) then

                    ShRColor:send("colorO",col1)
                    ShRColor:send("alpha",1)

                    love.graphics.setShader(ShRColor)
                    love.graphics.draw(game.img.tab.capl, start_x+(px-1)*game.largo+offset, start_y+(py-1)*game.largo)
                    love.graphics.setShader()

                    ShRColor:send("colorO",col2)
                    ShRColor:send("alpha",1)

                    love.graphics.setShader(ShRColor)
                    love.graphics.draw(game.img.tab.capr, start_x+px*game.largo+offset, start_y+(py-1)*game.largo)
                    love.graphics.setShader()

                end
            end

            -- Se recorre el tablero y se dibujan los sprites
            for i=1,#game.player[t].tablero,1 do

                local px = game.player[t].tablero[i][2]
                local py = game.player[t].tablero[i][3]

                -- obtenemos el color
                local col_index = game.piezas.seleccion[game.player[t].tablero[i][1]]
                local color = math.color(game.piezas.colores[col_index])
                ShRColor:send("colorO",color)
                ShRColor:send("alpha",1)

                -- se dibujan los bloques con la imagen bloque.png
                love.graphics.setShader(ShRColor)
                love.graphics.draw(game.img.tab.capp, start_x+(px-1)*game.largo+offset, start_y+(py-1)*game.largo)
                love.graphics.setShader()

            end
        end
    end

    -- json = require("json")
    -- encoded = json.encode(game.player);
    -- love.graphics.print(encoded, 16, 16, 0, 1)

    -- love.graphics.setColor(255,255,255,1)
    -- local joysticks = love.joystick.getJoysticks()
    -- for i, joystick in ipairs(joysticks) do
    --     love.graphics.print(joystick:getName(), 10, i * 20)
    -- end

end