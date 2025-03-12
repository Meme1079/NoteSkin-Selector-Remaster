local math = math

--- Check whether the given number is real or not. (I stole this code stole lmao)
---@return boolean
function math.isReal(num)
     return (type(num) == "number") and (num == num) and (math.abs(num) ~= math.huge)
end

return math