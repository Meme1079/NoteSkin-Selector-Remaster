local new_math = {}

function new_math.type(num)
     local strNum = tostring(num)
     return strNum:match('%-?%d+%.%d+') and 'float' or 'integer'
end

function new_math.cqrt(radicand)
     return radicand^(1/3)
end

function new_math.root(radicand, index)
     local index = index or 2
     return radicand^(1/index)
end

function new_math.round(num, dp) -- i stole this
     local mult = 10^(dp or 0);
     return new_math.floor(num * mult + 0.5)/mult;
end

function new_math.trunc(num)
     local int, flt = new_math.modf(num)
     return int
end

function new_math.sign(num)
     return num == 0 and 0 or (num < 0 and -1 or 1)
end

function new_math.fact(num)
     local sum = 1
     for i = 2, num do 
          sum = sum * i 
     end
     return sum
end

new_math.e  = 2.718281828459
new_math.maxinteger = 922337203685477580
new_math.maxinteger = -9223372036854775808

for k,v in pairs(math) do
     new_math[k] = v
end
return new_math