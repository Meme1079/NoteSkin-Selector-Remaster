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

local supportRGBPath = 'mods/NoteSkin Selector Remastered/jsons/doesSupport_RGB.json'
local noteSkins_supportSupportRGB = getTextFileContent(supportRGBPath):gsub('//%s*.-(\n)', '%1')
local noteSkins_jsonSupportRGB    = json.decode(noteSkins_supportSupportRGB)
local function initSplashesRGB(charInd, ind)
     local supportsRGB = function(k)
          local getNoteSkinName = noteSkins_getNoteSkins[k]:gsub('NOTE_assets%-', ''):lower()
          local checkIfNone     = getNoteSkinName == 'note_assets' and 'normal' or getNoteSkinName
          return table.find(noteSkins_jsonSupportRGB, checkIfNone) ~= nil
     end

     local chars = {'player', 'opponent'}
     if supportsRGB(ind) == false then           
          for i = 0, getProperty('unspawnNotes.length')-1 do
               if charInd == 1 then 
                    if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                         setPropertyFromGroup('unspawnNotes', i, 'rgbShader.enabled', false)
                         setPropertyFromGroup('playerStrums', i, 'useRGBShader', false)
                         setPropertyFromGroup('playerStrums', i, 'noteSplashData.useRGBShader', false)
                    end
               end
               if charInd == 2 then 
                    if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                         setPropertyFromGroup('unspawnNotes', i, 'rgbShader.enabled', false)
                         setPropertyFromGroup('opponentStrums', i, 'useRGBShader', false)
                    end
               end
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