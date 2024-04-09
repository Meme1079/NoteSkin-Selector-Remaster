local string = string

--- Splits a string by using a pattern
---@param string string The string to split
---@param delimiter string The pattern to split the string
---@return string
function string:split(delimiter)
     local result = {};
     for match in (self..delimiter):gmatch("(.-)"..delimiter) do
         table.insert(result, match);
     end
     return result;
end

--- Checks if the string begins with the specified pattern, returning `true` if detected
---@param string string The string to use
---@param startPattern string The starting pattern for the string to find
---@return string
function string:startsWith(startPattern)
     return self:match('^'..startPattern) and true or false
end

--- Checks if the string ends with the specified pattern, returning `true` if detected
---@param string string The string to use
---@param endPattern string The ending pattern for the string to find
---@return string
function string:endsWith(endPattern)
     return self:match(startPattern..'$') and true or false
end

--- Capitalize the first character of the string
---@return string
function string:upperAtStart()
     return self:sub(1,1):upper()..self:sub(2, #self)
end

--- Removes any whitespaces from a string
---@param string string The string to trim
---@param direction string The direcftion to trim `l` for left and `r` for right
---@return string
function string:trim(direction)
     local direct = direction ~= nil and direction:lower()
     if direction == 'l' then
          return self:gsub('^%s*', '')
     elseif direction == 'r' then
          return self:gsub('%s*$', '')
     end
     return self:gsub('%s*', '')
end

--- Shorthand for "Interpolation", is a process substituting values of variables into placeholders in a string
--- This uses the `${variable}` format to insert variable's value inside the string
--- It uses two methods to use this function, it uses global variables or tables on the `template` parameter
---@param string string The string to interpolate with variables
---@param template string The template to reference the variables inside the string
---@return string
function string:interpol(template)
     local function deepCopy(original)
          local copy = ''
          for k,v in pairs(original) do
               if type(v) == "table" then
                    v = deepCopy(v)
               end
               copy = copy .. k..' = '..tostring(v)..', '
          end
          return '@LCBRACK'..copy:gsub('[,%s*]+@RCBRACK', ', '):sub(1, #copy - 2)..'@RCBRACK'
     end
     if type(template) == 'table' then
          local result = {}
          for k,v in next, template do
               if type(v) == 'table' then
                    result[k] = deepCopy(v)
               else
                    result[k] = tostring(v)
               end
          end
          return self:gsub('%${(.-)}', result):gsub('@LCBRACK', '{'):gsub('@RCBRACK', '}')
     end

     local captured = {}
     for temp in self:gmatch('%${.-}') do
          captured[#captured + 1] = temp:gsub('%${(.-)}', '\"..%1..\"')
     end
     local result = ''
     for k,v in next, template do
          result = self:gsub('%${.-}', v)
     end
     return load('return '..'"'..result..'"')()
end

return string