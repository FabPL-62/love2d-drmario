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

	-- ancho y alto del tablero [celdas]
	game.ancho = 10
	game.alto  = 20

	-- largo del lado de una celda [pixeles]
	game.largo = 10

	-- para pausar el juego
	game.pausar = false

	-- Se definen las piezas
	game.piezas = {

		-- Piezas
		colores = {
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

		-- Escojidas
		seleccion = {1,8,12}
	}

	-- cola de piezas por lanzar
	game.cola = {

		-- maximo de piezas que se muestran
		maximo = 7,

		-- cola de piezas (de 0 en adelante)
		pieza = {}
	}

	-- llenamos la cola de piezas
	for i=1,game.cola.maximo,1 do
		game.cola.pieza[i] = {
			love.math.random(1,#game.piezas.seleccion),
			love.math.random(1,#game.piezas.seleccion)
		}
	end

	-----------------------------------------------------------------------------------------------------------------
	-- Iniciamos los jugadores del juego
	-----------------------------------------------------------------------------------------------------------------

	-- arreglo de jugadores
	game.player = {}

	-- Jugadores activos
	game.players = 4

	-- Jugador 1
	game.player[1] = {

		-- Nivel de dificultad (1->20)
		dificultad = 21,

		-- Nivel de velocidad (1: bajo, 2:medio, 3:alto)
		velocidad = 1,

		-- Cantidad de virus total
		virus = 0,

		-- pieza actual utilizada de la cola
		pieza = 1,

		-- posicion de la pieza
		posicion = {game.ancho/2,1},

		-- rotacion de la pieza (0H, 1V)
		rotacion = 0,

		-- Controles
		keys = {
			left = "left",
			right = "right",
			down = "down",
			rot = "up",
			push = "space"
		},

		-- Para guardar el tablero
		tablero = {}
	}

	game.player[2] = {

		-- Nivel de dificultad (1->20)
		dificultad = 20,

		-- Nivel de velocidad (1: bajo, 2:medio, 3:alto)
		velocidad = 1,

		-- Cantidad de virus total
		virus = 0,

		-- pieza actual utilizada de la cola
		pieza = 1,

		-- posicion de la pieza
		posicion = {game.ancho/2,1},

		-- rotacion de la pieza (0H, 1V)
		rotacion = 0,

		-- Controles
		keys = {
			left = "left",
			right = "right",
			down = "down",
			rot = "up",
			push = "space"
		},

		-- Para guardar el tablero
		tablero = {}
	}

	game.player[3] = {

		-- Nivel de dificultad (1->20)
		dificultad = 20,

		-- Nivel de velocidad (1: bajo, 2:medio, 3:alto)
		velocidad = 1,

		-- Cantidad de virus total
		virus = 0,

		-- pieza actual utilizada de la cola
		pieza = 1,

		-- posicion de la pieza
		posicion = {game.ancho/2,1},

		-- rotacion de la pieza (0H, 1V)
		rotacion = 0,

		-- Controles
		keys = {
			left = "left",
			right = "right",
			down = "down",
			rot = "up",
			push = "space"
		},

		-- Para guardar el tablero
		tablero = {}
	}

	game.player[4] = {

		-- Nivel de dificultad (1->20)
		dificultad = 20,

		-- Nivel de velocidad (1: bajo, 2:medio, 3:alto)
		velocidad = 1,

		-- Cantidad de virus total
		virus = 0,

		-- pieza actual utilizada de la cola
		pieza = 1,

		-- posicion de la pieza
		posicion = {game.ancho/2,1},

		-- rotacion de la pieza (0H, 1V)
		rotacion = 0,

		-- Controles
		keys = {
			left = "left",
			right = "right",
			down = "down",
			rot = "up",
			push = "space"
		},

		-- Para guardar el tablero
		tablero = {}
	}

	-- Se obtiene la maxima cantidad de virus
	-- y se llena el tablero de inicio
	local max_dificultad = 1
	for i=1,game.players,1 do
		if (game.player[i].dificultad > max_dificultad) then
			max_dificultad = game.player[i].dificultad
		end
	end
	local max_virus = math.min(4*(max_dificultad+1),(game.alto-3)*game.ancho);
	game.tablero = {}
	for i=1,max_virus,1 do
		local color = love.math.random(1,#game.piezas.seleccion)
		local px,py,existe = nil,nil,true
		while (existe == true) do
			px = love.math.random(1,game.ancho)
			py = love.math.random(4,game.alto)
			existe = false
			for j=1,#game.tablero,1 do
				if (game.tablero[j][2] == px) and (game.tablero[j][3] == py) then
					existe = true
					break
				end
			end
		end
		game.tablero[i] = {color,px,py}
	end

	-- Ahora que el tablero inicial esta listo
	-- se cargan los datos a los tableros de los jugadores
	for i=1,#game.tablero,1 do
		for j=1,game.players,1 do
			local max_virus = math.min(4*(game.player[j].dificultad+1),(game.alto-3)*game.ancho)
			if (i <= max_virus) then
				table.insert(game.player[j].tablero,game.tablero[i])
			end
		end
	end

	-- para esperar la limpieza
	game.esperar = false

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

	-- Salir del juego
	if key == 'escape' then
		love.event.quit()

	-- Reseteamos el juego
	elseif (key == 'r') then 
		love.load()

	-- elseif (key == 'c') then
	-- 	game.funcion.hold()
	end
end

-- dibujar el juego
function love.draw()

	-- escalamos el juego
	love.graphics.scale(game.scale,game.scale)
		
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

	-- json = require("json")
	-- encoded = json.encode(game.player);
	-- love.graphics.print(encoded, 16, 16, 0, 1)

	-- love.graphics.setColor(255,255,255,1)
	-- local joysticks = love.joystick.getJoysticks()
 --    for i, joystick in ipairs(joysticks) do
 --        love.graphics.print(joystick:getName(), 10, i * 20)
 --    end

end