local globals = {}

function globals.getTextFileContent(path)
     local file = io.open(path)
     local content = ''
     for line in file:lines() do  
          content = content .. line .. '\n'
     end
     return content:sub(1, #content - 1)
end

function globals.ternary(condition, valueMain, valueFailed)
     if condition == nil then
          return valueMain ~= nil and valueMain or valueFailed
     end
     return condition and valueMain or valueFailed
end

function globals.closureCount()
     local i = 0
     return function()
          i = i + 1
          return i
     end
end

return globals