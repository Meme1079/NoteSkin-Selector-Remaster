local new_table = {}

function new_table.clear(tab)
     for k,v in pairs(tab) do
          tab[k] = nil
     end
     return tab
end

function new_table.copy(tab)
     local fake = {}
     for k,v in pairs(tab) do
          fake[k] = v
     end
     return fake
end

function new_table.find(tab, value)
     for k,v in pairs(tab) do
          if v == value then return k end
     end
end

function new_table.match(tab, value)
     for k,v in pairs(tab) do
          if v == value then return v end
     end
end

function new_table.sub(tab, startPos, endPos)
     local faker = {}
     for i = startPos, endPos or #tab do
          table.insert(faker, tab[i])
     end
     return faker
end

function new_table.switch(tab, value, newPos)
     local function find(tab, value)
          for k,v in pairs(tab) do
               if v == value then return k end
          end
     end

     table.remove(tab, find(tab, value))
     table.insert(tab, newPos, value)
     return tab
end

function new_table.move(tab, startPos, endPos, dest, ind)
     local ind = ind or 1
     for i = startPos, endPos do
          table.insert(dest, ind, tab[i])
     end
     return dest
end

function new_table.merge(tab1, tab2)
     local result = {}
     for _,v in pairs(tab1) do
          table.insert(result, v)
     end
     for _,v in pairs(tab2) do
          table.insert(result, v)
     end
     return result
end

function new_table.pack(...)
     return {...}
end

function new_table.reverse(tab)
     local result = {}
     for i = #tab, 1, -1 do
          table.insert(result, tab[i])
     end
     return result
end

function new_table.filter(tab, func)
     local result = {}
     for i = 1, #tab do
          if func(tab[i]) == true then
               table.insert(result, tab[i])
          end
     end
     return result
end

function new_table.foreach(tab, func)
     for k,v in pairs(tab) do
          func(k, v)
     end
end

function new_table.foreachi(tab, func)
     for k,v in ipairs(tab) do
          func(k, v)
     end
end

for k,v in pairs(table) do
     new_table[k] = v
end
return new_table