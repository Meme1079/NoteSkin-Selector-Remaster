local funkinlua = require 'mods.NoteSkin Selector Remastered.modules.funkinlua'
local globals   = require 'mods.NoteSkin Selector Remastered.modules.globals'
local string    = require 'mods.NoteSkin Selector Remastered.libraries.string'
local table     = require 'mods.NoteSkin Selector Remastered.libraries.table'
local json      = require 'mods.NoteSkin Selector Remastered.libraries.json.json'

local setSave = funkinlua.setSave
local getSave = funkinlua.getSave
local ternary = funkinlua.ternary

initSaveData('noteselector', 'NoteSkin Selector')
local saveNote_noteStateIndex         = ternary(nil, getSave('noteStateIndex'), 1)
local saveNote_noteCheckPlayerIndex   = ternary(nil, getSave('noteCheckPlayerIndex'), 0)
local saveNote_noteCheckOpponentIndex = ternary(nil, getSave('noteCheckOpponentIndex'), 0)
local saveNote_noteCurSkinPlayer      = ternary(nil, getSave('noteCurSkinPlayer'), 'NOTE_assets-')
local saveNote_noteCurSkinOpponent    = ternary(nil, getSave('noteCurSkinOpponent'), 'NOTE_assets-')

local noteOffsetPath  = 'mods/NoteSkin Selector Remastered/jsons/note/offsets.json'
local noteOffsetFetch = funkinlua.getTextFileContent(noteOffsetPath):gsub('//%s*.-(\n)', '%1')
local noteOffsetJson  = json.parse(noteOffsetFetch, true)

local notePropsPath  = 'mods/NoteSkin Selector Remastered/jsons/note/properties.json'
local notePropsFetch = funkinlua.getTextFileContent(notePropsPath):gsub('//%s*.-(\n)', '%1')
local notePropsJson  = json.parse(notePropsFetch)

local getNotes = globals.getSkins('note')
local function initNoteRGB(charInd, ind)
     local chars = {'player', 'opponent'}
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

     local getNoteSkinObject = getNotes[ind]:gsub('NOTE_assets%-', ''):lower()
     local getNoteSkinName   = getNoteSkinObject == 'note_assets' and 'normal' or getNoteSkinObject
     if table.find(notePropsJson.rgbshader, getNoteSkinName) == nil then
          for i = 0, getProperty('unspawnNotes.length')-1 do
               local getNoteTypes     = getPropertyFromGroup('unspawnNotes', i, 'noteType')
               local getNotePropType  = notePropsJson.notetype
               local getNoteLegalType = getNotePropType[table.find(getNotePropType, getNoteTypes)]

               if charInd == 1 then rgbShaderPlayerNotes(i, getNoteLegalType) end
               if charInd == 2 then rgbShaderOpponentNotes(i, getNoteLegalType) end
          end
     end
end

local function strumOffsets(charInd, ind)
     local checkNoteSkinName = function(element, charNameInd)
          local getNoteSkinName_player   = saveNote_noteCurSkinPlayer:gsub('NOTE_assets%-', ''):lower()
          local getNoteSkinName_opponent = saveNote_noteCurSkinOpponent:gsub('NOTE_assets%-', ''):lower()
          local checkIfNone_player   = getNoteSkinName_player   == '' and 'normal' or getNoteSkinName_player
          local checkIfNone_opponent = getNoteSkinName_opponent == '' and 'normal' or getNoteSkinName_opponent
          local charNames = {checkIfNone_player, checkIfNone_opponent}

          if noteOffsetJson[charNames[charNameInd]] == nil then
               return nil
          end
          if noteOffsetJson[charNames[charNameInd]]['strums'] == nil then
               return nil
          end
          return noteOffsetJson[charNames[charNameInd]]['strums'][element]
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
     local setTexture = function(noteSkinObject, groupObject, ind)
          if noteSkinObject ~= 'NOTE_assets-' then
               setPropertyFromGroup(groupObject, ind, 'texture', 'noteSkins/'..noteSkinObject)
          end
     end

     for i = 0, getProperty('unspawnNotes.length')-1 do
          if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then 
               setTexture(saveNote_noteCurSkinPlayer, 'unspawnNotes', i)
               if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then strumOffsets(1, i) end
          else 
               setTexture(saveNote_noteCurSkinOpponent, 'unspawnNotes', i)
               if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then strumOffsets(2, i) end
          end

          setTexture(saveNote_noteCurSkinPlayer, 'playerStrums', i)
          setTexture(saveNote_noteCurSkinOpponent, 'opponentStrums', i)
     end

     if saveNote_noteCurSkinPlayer ~= 'NOTE_assets-' then 
          initNoteRGB(1, saveNote_noteCheckPlayerIndex)
     end
     if saveNote_noteCurSkinOpponent ~= 'NOTE_assets-' then 
          initNoteRGB(2, saveNote_noteCheckOpponentIndex)
     end
end

function onCreatePost()
     if songName ~= 'NoteSkin Settings' and songName ~= 'NoteSkin Debug' then
          setSave('songLocalName', songName)
          setSave('songLocalDiff', difficulty)
     end
     
     setUpNoteSkins()
     funkinlua.createTimer('deley', 0.1, setUpNoteSkins()) -- override
end

local doubleCliked = 0
local enableTimer  = false
local function loadToMainState(doubleEnabled)
     if songName == 'NoteSkin Settings' then
          return nil;
     end

     if doubleEnabled == true then
          if keyboardJustPressed('TAB') then
               doubleCliked = doubleCliked + 1
               enableTimer  = true
          end
          if enableTimer == true then
               funkinlua.createTimer('timer', 0.3, function() 
                    doubleCliked = 0
                    enableTimer  = false
               end)
               enableTimer = 'maybe'
          end
          if doubleCliked >= 2 then
               loadNewSong('NoteSkin Settings')
          end
     else
          if keyboardJustPressed('TAB') then
               loadNewSong('NoteSkin Settings')
          end
     end
end

function onUpdate(elapsed)
     loadToMainState(getModSetting('enable_double-tapping_safe', 'NoteSkin Selector Remastered'))
end