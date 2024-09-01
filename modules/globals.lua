local globals = {}

function globals.getTextFileContent(path)
     local file = io.open(path)
     local content = ''
     for line in file:lines() do  
          content = content .. line .. '\n'
     end
     return content:sub(1, #content - 1)
end

function globals.switch(value) -- calling operation (); first argument value
     return function(cases)    -- calling operation (); "second" argument table
          if cases[value] or cases.default then -- checks if any cases or default case exists
               return (cases[value] or cases.default)()
          end
          return -- if not, return nothing
     end
end

function globals.ternary(condition, valueMain, valueFailed)
     if condition == nil then
          return valueMain ~= nil and valueMain or valueFailed
     end
     return condition and valueMain or valueFailed
end

function globals.tuplenary(tupleConds, tupleValue)
     for operands, values in pairs(tupleValue) do
          if tupleConds == operands then return values end
     end
end

function globals.path(modDirectory)
     if modDirectory == 'path' then
          return debug.getinfo(2, "S").source:sub(2):match('(.-/.-/).+')
     elseif modDirectory == 'folder' then
          return debug.getinfo(2, "S").source:sub(2):match('.-/(.-)/.+')
     end
     return debug.getinfo(2, "S").source:sub(2)
end

function globals.closureCount()
     local i = 0
     return function() i = i + 1; return i end
end

return globals