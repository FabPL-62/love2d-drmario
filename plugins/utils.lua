local utils = {}

-----------------------------------------------------------------------------------------------------------------
-- matematicas
-----------------------------------------------------------------------------------------------------------------
utils.math = {}

-- funcion para redondear un numero de forma simetrica
function utils.math.round(num) 
    if num >= 0 then return math.floor(num+.5) 
    else return math.ceil(num-.5) end
end

-- obtenemos un color {r,g,b} desde un valor decimal
function utils.math.color(color)
    local r = math.floor(color/256^2) % 256 / 255
    local g = math.floor(color/256) % 256 / 255
    local b = color % 256 / 255
    return {r,g,b}
end

-----------------------------------------------------------------------------------------------------------------
-- tablas
-----------------------------------------------------------------------------------------------------------------
utils.table = {}

-- copiar una tabla sin referencia
function utils.table.copy(object)
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

return utils