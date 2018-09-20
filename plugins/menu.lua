local Menu = {}
function Menu:new(love,game)
local menu = {}

-- nivel del menu
menu.nivel = 1

-- guarda las posiciones del menu
menu.ultima = {}

-- cuerpo del menu
menu.cuerpo = {}

-----------------------------------------------------------------------------------------------------------------
-- (1) Menu principal
-----------------------------------------------------------------------------------------------------------------
menu.cuerpo[1] = {
	titulo = "Puzzles",
    opciones = {{
        txt = "Un Jugador",
        nxt = 2
    },{
        txt = "Multi-jugador",
        nxt = 3,
    },{
        txt = "Opciones",
        nxt = 4,
    },{
        txt = "Salir",
        act = function()
            love.event.quit()
        end
    }},
    posicion = 1
}

-----------------------------------------------------------------------------------------------------------------
-- (2) Seleccion de modos de juego
-----------------------------------------------------------------------------------------------------------------
menu.cuerpo[2] = {
	titulo = "Modos de juego",
	opciones = {{
	    txt = "Tetris",
	    nxt = 5,
	    act = function ()
	    	game.players.mode("tetris")
	    end
	},{
	    txt = "Dr.Mario",
	    nxt = 6,
	    act = function ()
	        game.players.mode("drmario")
	    end
	},{
	    txt = "Puyo Puyo",
	    nxt = 7,
	    act = function ()
	        game.players.mode("puyo")
	    end
	},{
	    txt = "Columns",
	    nxt = 8,
	    act = function ()
	        game.players.mode("columns")
	    end
	},{
	    txt = "Combinado",
	    nxt = 9,
	    act = function ()
	        game.players.mode("mixed")
	    end
	},{
	    txt = "Fusion",
	    nxt = 10,
	    act = function ()
	        game.players.mode("fusion")
	    end
	}},
    posicion = 1
}

-----------------------------------------------------------------------------------------------------------------
-- (3) : Seleccion de tipos de jugadores
-----------------------------------------------------------------------------------------------------------------
menu.cuerpo[3] = {
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
            menu.nivel = 2
        else
            return false
        end
    end,
    posicion = 1
}

function menu.update(key)

	local mm = menu.cuerpo[menu.nivel]
	if key == 'up' then
        if mm.posicion > 1 then
            mm.posicion = mm.posicion - 1
        else
            mm.posicion = #mm.opciones
        end
    elseif key == 'down' then
        if mm.posicion < #mm.opciones then
            mm.posicion = mm.posicion + 1
        else
            mm.posicion = 1
        end
    elseif key == 'left' then
        local opcion = mm.opciones[mm.posicion]
        if opcion.opt ~= nil then
            if opcion.def > 1 then
                opcion.def = opcion.def - 1
            else
                opcion.def = #opcion.opt
            end
            opcion.change(opcion.opt[opcion.def])
        end
    elseif key == 'right' then
        local opcion = mm.opciones[mm.posicion]
        if opcion.opt ~= nil then
            if opcion.def < #opcion.opt then
                opcion.def = opcion.def + 1
            else
                opcion.def = 1
            end
            opcion.change(opcion.opt[opcion.def])
        end
    elseif key == 'return' then
    	local nivel_actual = menu.nivel
    	if mm.act ~= nil then mm.act() end
    	if mm.opciones[mm.posicion].act ~= nil then mm.opciones[mm.posicion].act() end
        if mm.nxt ~= nil then menu.nivel = mm.nxt end
        if mm.opciones[mm.posicion].nxt ~= nil then menu.nivel = mm.opciones[mm.posicion].nxt end
    	if menu.nivel ~= nivel_actual then
    		table.insert(menu.ultima,nivel_actual) 
    	end
    elseif key == 'escape' then
        if #menu.ultima > 0 then
            menu.nivel = table.remove(menu.ultima)
        else
            love.event.quit()
        end
    end
end

function menu.render()
    if game.estado == "Menu" then

        local mm = menu.cuerpo[menu.nivel]
        for i=1,#mm.opciones,1 do
            local opciones = mm.opciones[i]
            local txt = opciones.txt
            if opciones.opt ~= nil then
                txt = string.gsub(txt,"%$",opciones.opt[opciones.def])
            end
            if i == mm.posicion then love.graphics.print("*",16,16 + 16*i) end 
            love.graphics.print(txt,32,16 + 16*i)
        end

        -- Se dibuja el titulo del menu
        local font = love.graphics.getFont()
        local tx = (love.graphics.getWidth()/game.scale-font:getWidth(mm.titulo))/2
        love.graphics.print(mm.titulo,tx,16)
    
    end
end

return menu
end
return Menu