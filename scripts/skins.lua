local json   = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/json')
local table  = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/table')

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

local notePropertyPath = 'mods/NoteSkin Selector Remastered/jsons/allowNoteProperties.json'
local strumsOffsetPath = 'mods/NoteSkin Selector Remastered/jsons/offsets_strums.json'

local noteSkins_noteProperty = getTextFileContent(notePropertyPath):gsub('//%s*.-(\n)', '%1')
local noteSkins_strumsOffset = getTextFileContent(strumsOffsetPath):gsub('//%s*.-(\n)', '%1')
local noteSkins_jsonNoteProperty = json.decode(noteSkins_noteProperty)
local noteSkins_jsonStrumsOffset = json.decode(noteSkins_strumsOffset)

local noteSkins_getNoteSkins = getNoteSkins()
local noteSave_curNoteSkinPlayer, noteSave_curNoteSkinOpponent
local noteSave_checkboxVisiblePlayer, noteSave_checkboxVisibleOpponent
function onCreate()
     setPropertyFromClass('backend.ClientPrefs', 'data.noteSkin', 'Default')

     addHScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/other/globalfunk')
     initSaveData('noteskin_selector-save', 'noteskin_selector')
     noteSave_curNoteSkinPlayer   = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_curNoteSkinPlayer'), 'NOTE_assets')
     noteSave_curNoteSkinOpponent = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_curNoteSkinOpponent'), 'NOTE_assets')
     noteSave_checkboxVisiblePlayer    = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_checkboxVisiblePlayer'), false)
     noteSave_checkboxVisibleOpponent  = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_checkboxVisibleOpponent'), false)
end

local function initNoteRGB(charInd, ind)
     local chars = {'player', 'opponent'}
     local supportsRGB = function(k)
          local getNoteSkinName = noteSkins_getNoteSkins[k]:gsub('NOTE_assets%-', ''):lower()
          local checkIfNone     = getNoteSkinName == 'note_assets' and 'normal' or getNoteSkinName
          return table.find(noteSkins_jsonNoteProperty.rgbshader, checkIfNone) ~= nil
     end

     local rgbShaderPlayerNotes = function(ind, noteType)
          if getPropertyFromGroup('unspawnNotes', ind, 'mustPress') then
               if getPropertyFromGroup('unspawnNotes', ind, 'noteType') == noteType then 
                    setPropertyFromGroup('unspawnNotes', ind, 'rgbShader.enabled', false) 
               end
          end
          setPropertyFromGroup('playerStrums', ind, 'useRGBShader', false)
          setPropertyFromGroup('playerStrums', ind, 'noteSplashData.useRGBShader', false)
     end
     local rgbShaderOpponentNotes = function(ind, noteType)
          if not getPropertyFromGroup('unspawnNotes', ind, 'mustPress') then
               if getPropertyFromGroup('unspawnNotes', ind, 'noteType') == noteType then 
                    setPropertyFromGroup('unspawnNotes', ind, 'rgbShader.enabled', false) 
               end
          end
          setPropertyFromGroup('opponentStrums', ind, 'useRGBShader', false)
     end
     if supportsRGB(ind) == false then
          for i = 0, getProperty('unspawnNotes.length')-1 do
               local noteProps_noteType = noteSkins_jsonNoteProperty.notetype
               local checkNoteType = getPropertyFromGroup('unspawnNotes', i, 'noteType')
               local getNoteType   = noteProps_noteType[table.find(noteProps_noteType, checkNoteType)]
               if charInd == 1 then rgbShaderPlayerNotes(i, getNoteType)   end
               if charInd == 2 then rgbShaderOpponentNotes(i, getNoteType) end
          end
     end
end

local function strumOffsets(charInd, ind)
     local chars = {noteSave_curNoteSkinPlayer, noteSave_curNoteSkinPlayer}
     local checkNoteSkinName = function(element, charNameInd)
          local getNoteSkinName_player   = noteSave_curNoteSkinPlayer:gsub('NOTE_assets%-', ''):lower()
          local getNoteSkinName_opponent = noteSave_curNoteSkinOpponent:gsub('NOTE_assets%-', ''):lower()
          local checkIfNone_player   = getNoteSkinName_player   == '' and 'normal' or getNoteSkinName_player
          local checkIfNone_opponent = getNoteSkinName_opponent == '' and 'normal' or getNoteSkinName_opponent
          local charNames = {checkIfNone_player, checkIfNone_opponent}

          if noteSkins_jsonStrumsOffset[charNames[charNameInd]] ~= nil then
               return noteSkins_jsonStrumsOffset[charNames[charNameInd]][element]
          end
          return nil
     end

     if checkNoteSkinName('scaleY', charInd) ~= nil then
          setPropertyFromGroup('unspawnNotes', ind, 'scale.y', checkNoteSkinName('scaleY', charInd))
     end
     if checkNoteSkinName('offsets', charInd) ~= nil and checkNoteSkinName('offsets', charInd)[1] ~= nil then
          setPropertyFromGroup('unspawnNotes', ind, 'offset.x', checkNoteSkinName('offsets', charInd)[1])
     end
     if checkNoteSkinName('offsets', charInd) ~= nil and checkNoteSkinName('offsets', charInd)[2] ~= nil then
          setPropertyFromGroup('unspawnNotes', ind, 'offset.y', checkNoteSkinName('offsets', charInd)[2])
     end
     if getPropertyFromGroup('unspawnNotes', ind, 'animation.name'):match('end') then
          if checkNoteSkinName('endOffsetY', charInd) ~= nil then
               setPropertyFromGroup('unspawnNotes', ind, 'offset.y', checkNoteSkinName('endOffsetY', charInd))
          end
     end
end

local function setUpNoteSkins() -- me praying to god that it doesn't lag the script becuase of this
     if not getPropertyFromClass('states.Playstate', 'isPixelStage') then
          for k = 1, #noteSkins_getNoteSkins do
               if noteSave_checkboxVisiblePlayer   and noteSkins_getNoteSkins[k] == noteSave_curNoteSkinPlayer   then 
                    initNoteRGB(1, k)
               end
               if noteSave_checkboxVisibleOpponent and noteSkins_getNoteSkins[k] == noteSave_curNoteSkinOpponent then 
                    initNoteRGB(2, k)
               end
          end
     end
     
     local reskinPlayerNotes = function(ind)
          if noteSave_checkboxVisiblePlayer then
               setPropertyFromGroup('unspawnNotes', ind, 'texture', 'noteSkins/'..noteSave_curNoteSkinPlayer)
               if getPropertyFromGroup('unspawnNotes', ind, 'isSustainNote') then strumOffsets(1, ind) end
          end
     end
     local reskinOpponentNotes = function(ind)
          if noteSave_checkboxVisibleOpponent then
               setPropertyFromGroup('unspawnNotes', ind, 'texture', 'noteSkins/'..noteSave_curNoteSkinOpponent)
               if getPropertyFromGroup('unspawnNotes', ind, 'isSustainNote') then strumOffsets(2, ind) end
          end
     end
     for i = 0, getProperty('unspawnNotes.length')-1 do
          local noteProps_noteType = noteSkins_jsonNoteProperty.notetype
          local checkNoteType = getPropertyFromGroup('unspawnNotes', i, 'noteType')
          local getNoteType   = noteProps_noteType[table.find(noteProps_noteType, checkNoteType)]
          if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then 
               if checkNoteType == getNoteType then reskinPlayerNotes(i)   end
          else 
               if checkNoteType == getNoteType then reskinOpponentNotes(i) end
          end
     end
     for i = 0, 3 do
          if noteSave_checkboxVisiblePlayer   then setPropertyFromGroup('playerStrums', i, 'texture', 'noteSkins/'..noteSave_curNoteSkinPlayer)     end
          if noteSave_checkboxVisibleOpponent then setPropertyFromGroup('opponentStrums', i, 'texture', 'noteSkins/'..noteSave_curNoteSkinOpponent) end
     end
end

function onCreatePost()
     setUpNoteSkins()
     createTimer('deley', 0.1, function() setUpNoteSkins() end) -- override
end

function onUpdate(elapsed)
     if keyboardJustPressed('TAB') and songName ~= 'NoteSkin Settings' then
          setDataFromSave('noteskin_selector-save', 'curSongName', songName)
          setDataFromSave('noteskin_selector-save', 'curDiffID', difficulty)
          loadNewSong('NoteSkin Settings')
     end
end 

function createTimer(tag, timer, callback)
     timers = {}
     table.insert(timers, {tag, callback})
     runTimer(tag, timer)
end

function onTimerCompleted(tag, loops, loopsLeft)
     for _,v in pairs(timers) do
          if v[1] == tag then v[2]() end
     end
end