local string    = require 'mods.NoteSkin Selector Remastered.libraries.string'
local json      = require 'mods.NoteSkin Selector Remastered.libraries.json.json'
local funkinlua = {}

function funkinlua.getTextFileContent(path)
     local file = io.open(path)
     local content = ''
     for line in file:lines() do  
          content = content .. line .. '\n'
     end
     return content:sub(1, #content - 1)
end

function funkinlua.ternary(condition, valueMain, valueFailed)
     if condition == nil then
          return valueMain ~= nil and valueMain or valueFailed
     end
     return condition and valueMain or valueFailed
end

function funkinlua.setSave(field, value)
     setDataFromSave('noteselector', 'skinNote_'..field, value)
end

function funkinlua.getSave(field)
     return getDataFromSave('noteselector', 'skinNote_'..field)
end

function funkinlua.setProperties(tag, values)
     for k,v in pairs(values) do
          setProperty(tag..'.'..k, v)
     end
end

function funkinlua.getProperties(tag, values)
     local result = {}
     for index = 1, #values do
          result[#index + 1] = getProperty(tag..'.'..values[index])
     end
     return result
end

function funkinlua.calculateByEachX(x, y)
     return (x + ((x * y) / 2)) - x / 2 
end

function funkinlua.clickObject(obj)
     return objectsOverlap(obj, 'mouseHitBox') and mouseClicked('left')
end

function funkinlua.createTimer(tag, timer, callback)
     timers = {}
     table.insert(timers, {tag, callback})
     runTimer(tag, timer)
end

function onTimerCompleted(tag, loops, loopsLeft)
     for _,v in pairs(timers) do
          if v[1] == tag then v[2]() end
     end
end

return funkinlua