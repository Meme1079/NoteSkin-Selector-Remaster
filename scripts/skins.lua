local json  = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/json')
local table = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/table')

local function getTextFileContent(path)
     local file = io.open(path)
     local content = ''
     for line in file:lines() do  
          content = content .. line .. '\n'
     end
     return content
end

local function getNoteSkins()
     local results = {'NOTE_assets', 'NOTE_assets-future', 'NOTE_assets-chip'}
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/noteSkins') do
          if v:match('^(NOTE_assets%-.+)%.png$') then
               table.insert(results, v:match('^(NOTE_assets%-.+)%.png$'))
          end
     end
     return results
end

local function altValue(main, alt)
     return main ~= nil and main or alt
end

local noteSkins_getNoteSkins = getNoteSkins()
local noteSave_curNoteSkinPlayer, noteSave_curNoteSkinOpponent
function onCreate()
     addHScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/other/globalfunk')
     initSaveData('noteskin_selector-save', 'noteskin_selector')
     noteSave_curNoteSkinPlayer   = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_curNoteSkinPlayer'), 'NOTE_assets')
     noteSave_curNoteSkinOpponent = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_curNoteSkinOpponent'), 'NOTE_assets')
end

local function noteSplashesRGBDefaultColor()
     local noteSplashesRGB = {{194, 75, 153}, {0, 255, 255}, {18, 250, 5}, {249, 57, 63}}
     for j = 1, 4 do
          setPropertyFromGroup('unspawnNotes', j - 1, 'noteSplashData.r', noteSplashesRGB[j][1])
          setPropertyFromGroup('unspawnNotes', j - 1, 'noteSplashData.g', noteSplashesRGB[j][2])
          setPropertyFromGroup('unspawnNotes', j - 1, 'noteSplashData.b', noteSplashesRGB[j][3])
     end
end

local supportRGBPath = 'mods/NoteSkin Selector Remastered/jsons/doesSupport_RGB.json'
local noteSkins_supportSupportRGB = getTextFileContent(supportRGBPath):gsub('//%s*.-(\n)', '%1')
local noteSkins_jsonSupportRGB    = json.decode(noteSkins_supportSupportRGB)
local function initSplashesRGB(charInd, ind)
     local supportsRGB = function(k)
          local getNoteSkinName = noteSkins_getNoteSkins[k]:gsub('NOTE_assets%-', ''):lower()
          local checkIfNone     = getNoteSkinName == 'note_assets' and 'normal' or getNoteSkinName
          return table.find(noteSkins_jsonSupportRGB, checkIfNone) ~= nil
     end


     if supportsRGB(ind) == false then 
          local forPlayer = function(i)
               if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                    setPropertyFromGroup('unspawnNotes', i, 'rgbShader.enabled', false)
                    noteSplashesRGBDefaultColor()
               end
          end
          local forOpponent = function(i)
               if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                    setPropertyFromGroup('unspawnNotes', i, 'rgbShader.enabled', false)
               end
          end
     
          local chars = {'player', 'opponent'}
          for i = 0, getProperty('unspawnNotes.length')-1 do
               if charInd == 1 then forPlayer(i)   end
               if charInd == 2 then forOpponent(i) end
               setPropertyFromGroup(chars[charInd]..'Strums', i, 'noteSplashData.useRGBShader', false)
          end
          for i = 0,3 do
               setPropertyFromGroup(chars[charInd]..'Strums', i, 'useRGBShader', false)
          end
     end
end

function onCreatePost()
     for k = 1, #noteSkins_getNoteSkins do
          if noteSkins_getNoteSkins[k] == noteSave_curNoteSkinPlayer   then initSplashesRGB(1, k) end
          if noteSkins_getNoteSkins[k] == noteSave_curNoteSkinOpponent then initSplashesRGB(2, k) end
     end

     for i = 0, getProperty('unspawnNotes.length')-1 do
          if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
               setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/'..noteSave_curNoteSkinPlayer)
          else
               setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/'..noteSave_curNoteSkinOpponent)
          end

          setPropertyFromGroup('playerStrums', i, 'texture', 'noteSkins/'..noteSave_curNoteSkinPlayer)
          setPropertyFromGroup('opponentStrums', i, 'texture', 'noteSkins/'..noteSave_curNoteSkinOpponent)
     end
end

function onUpdate(elapsed)
     if keyboardJustPressed('TAB') and songName ~= 'NoteSkin Settings' then
          setDataFromSave('noteskin_selector-save', 'curSongName', songName)
          setDataFromSave('noteskin_selector-save', 'curDiffID', difficulty)
          loadNewSong('NoteSkin Settings')
     end
end 