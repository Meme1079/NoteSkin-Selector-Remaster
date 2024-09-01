local string = require 'mods.NoteSkin Selector Remastered.libraries.string' 
local table  = table

--- Returns the table's key by finding its value
---@param tab table The table itself to use
---@param value any The value from the table to find its keys
---@return any
function table.find(tab, value)
     for k,v in pairs(tab) do
          if v == value then return k end
     end
end

--- Moves the selection(s) of table values to another new table
---@param tab table The table to move the selection(s) of values
---@param startPos number The starting position to start
---@param endPos number The starting position to end
---@param dest table The new destination to store the selection(s) of values
---@param ind number An optional parameter, The table index to place the values; Default value: 1
---@return table
function table.move(tab, startPos, endPos, dest, ind)
     local ind = ind or 1
     for i = startPos, endPos do
          table.insert(dest, ind, tab[i])
     end
     return dest
end

--- Copies the elements from a table
---@param tab table The table to copy its value
---@return table
function table.clone(tab)
     local result = {}
     for k,v in pairs(tab) do
          result[k] = v
     end
     return result
end

--- Repeats the elements inside a table
---@param size number The size to inherit
---@param element number The element to repeat each value
---@return value
function table.rep(size, element)
     local result = {}
     for i = 1, size do
          result[i] = element
     end
     return result
end

--- Subtring, works exactly the same as string:sub() function but for tables
--- Removes any elements that isn't selected
---@param tab table The table's specific values to be extracted.
---@param startPos number The starting position of the value to be extracted.
---@param endPos number The ending position of the value to end the extraction.
---@return table
function table.sub(tab, startPos, endPos)
     local faker = {}
     for i = startPos, endPos or #tab do
          table.insert(faker, tab[i])
     end
     return faker
end

--- Merges two or more array-like table into one
---@param tab table The table to merge the contents with other tables
---@param extras table The extra table(s) to merge with
---@return table
function table.merge(tab, ...)
     local tabMerge      = table.concat(tab, ', ') .. ', '
     local tabArgMerge   = ''
     local tabArgContent = ({...})
     for i = 1, #tabArgContent do
          tabArgMerge = tabArgMerge .. table.concat(tabArgContent[i], ', ') .. ', '
     end
     return (tabMerge .. tabArgMerge):split(', ')
end

--- Filters any elements from a table, provided by the `func` parameter
---@param tab table The table to filter its elements
---@param func function The function to provide the filter code
---@return table
function table.filter(tab, func)
     local result = {}
     for i = 1, #tab do
          if func(tab[i]) == true then
               table.insert(result, tab[i])
          end
     end
     return result
end

return table