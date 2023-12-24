local new_string = {}

function new_string.split(str, split)
     local saved = {}
     for words in str:gmatch('[^'..split..']+') do
          table.insert(saved, words)
     end
     return saved
end

function new_string.chars(str)
     local results = {}
     for match in str:gmatch('.') do
          table.insert(results, match)
     end
     return results
end

function new_string.trim(str)
     return str:gsub('%s*', '')
end

function new_string.trimStart(str)
     return str:gsub('^%s*', '')
end

function new_string.trimEnd(str)
     return str:gsub('%s*$', '')
end

function new_string.startsWith(str, pattern)
     return str:match('^['..pattern..']*') == pattern
end

function new_string.endsWith(str, pattern)
     return str:match('['..pattern..']$*') == pattern
end

function new_string.padStart(str, limit, pattern)
     local result = ''
     for i = 1, limit do
          result = result .. pattern
     end
     return result..str
end

function new_string.padEnd(str, limit, pattern)
     local result = ''
     for i = 1, limit do
          result = result .. pattern
     end
     return str..result
end

function new_string.capAt(str, startPos, endPos)
     return str:sub(startPos, endPos):upper()..str:sub(endPos + 1)
end

for k,v in pairs(string) do
     new_string[k] = v
end
return new_string