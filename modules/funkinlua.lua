local globals   = require 'mods.NoteSkin Selector Remastered.modules.globals'
local json      = require 'mods.NoteSkin Selector Remastered.libraries.json.json'
local funkinlua = {}

function funkinlua.clickObject(obj)
     return objectsOverlap(obj, 'mouseHitBox') and mouseClicked('left')
end

function funkinlua.setSave(field, value) -- shortcuts
     setDataFromSave('noteselector', 'skinNote_'..field, value)
end

function funkinlua.getSave(field)        -- shortcuts
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

function funkinlua.getJson(path)
     local getJsonFile = globals.getTextFileContent(path):gsub('//%s*.-(\n)', '%1')
     return json.parse(getJsonFile, true)
end

local doubleClicked = 0
local enableTimer   = false
local closureCount  = globals.closureCount()
function funkinlua.keyboardJustDoublePressed(key)
     if keyboardJustPressed(key:upper()) then
          doubleClicked = doubleClicked + 1
          enableTimer   = true
     end

     if enableTimer == true then
          funkinlua.createTimer('pressedDuraction'..closureCount(), 0.3, function()
               doubleClicked = 0
               enableTimer   = false
          end)
          enableTimer = 'maybe'
     end
     if doubleClicked >= 2 then
          return true
     end
     return false
end

local timers = {}
function funkinlua.createTimer(tag, timer, callback)
     table.insert(timers, {tag, callback})
     runTimer(tag, timer)
end
     
function onTimerCompleted(tag, loops, loopsLeft)
     for _,v in pairs(timers) do
          if v[1] == tag then v[2]() end
     end
end

return funkinlua