local Game = require "plugins/game"

-- funcion de comienzo
function love.load()

    -----------------------------------------------------------------------------------------------------------------
    -- Variables generales para el juego
    -----------------------------------------------------------------------------------------------------------------

    -- Se inicializa el juego en pantalla completa
    love.window.setFullscreen(true, "desktop")
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    -- iniciamos el objeto general del juego
    game = Game:new(love)

end

-- loop principal
function love.update(dt)
end

-- funcion de tecla presionada
function love.keypressed(key)

    if game.estado == "Menu" then
        game.menu.update(key)
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
    love.graphics.setFont(game.font)
    game.render()

    -- json = require("json")
    -- encoded = json.encode(game.player);
    -- love.graphics.print(encoded, 16, 16, 0, 1)

    -- love.graphics.setColor(255,255,255,1)
    -- local joysticks = love.joystick.getJoysticks()
    -- for i, joystick in ipairs(joysticks) do
    --     love.graphics.print(joystick:getName(), 10, i * 20)
    -- end

end