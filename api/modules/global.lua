local global = {}

function global.switch(value) -- calling operation (); first argument value
     return function(cases)   -- calling operation (); "second" argument table
          if cases[value] or cases.default then -- checks if any cases or default case exists
               return (cases[value] or cases.default)()
          end
          return -- if not, return nothing
     end
end

return global