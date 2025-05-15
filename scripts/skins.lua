luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local ease      = require 'mods.NoteSkin Selector Remastered.api.libraries.ease.ease'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local SkinStateSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector', true)

local bf_a  = SkinStateSave:get('checkboxSkinObjectIndexPlayer', 'notes', 0)
local dad_a = SkinStateSave:get('checkboxSkinObjectIndexOpponent', 'notes', 0)

local bf  = states.getTotalSkins('notes', true)[bf_a]
local dad = states.getTotalSkins('notes', true)[dad_a]

local d_bf  = states.getMetadataSkinsOrdered('notes', 'skins', true)[bf_a]
local d_dad = states.getMetadataSkinsOrdered('notes', 'skins', true)[dad_a]
function onCreatePost()
     for strums = 0, 3 do
          setPropertyFromGroup('playerStrums', strums, 'texture', bf:gsub('assets/shared/images/', ''))
          setPropertyFromGroup('playerStrums', strums, 'useRGBShader', false)
     end
     for strums = 0, 3 do
          setPropertyFromGroup('opponentStrums', strums, 'texture', dad:gsub('assets/shared/images/', ''))
          setPropertyFromGroup('opponentStrums', strums, 'useRGBShader', false)
     end
end

function onSpawnNote(memberIndex, noteData, noteType, isSustainNote, strumTime)
     local songSpeed    = getProperty('songSpeed')
     local songPlayRate = getProperty('playbackRate')
     local calculateNoteSustian = ((stepCrochet / 100 * 1.05) * songSpeed) / songPlayRate

     local ultimateSwagWidth = getPropertyFromClass('objects.Note', 'swagWidth')
     local ultimateNoteWidth = getPropertyFromGroup('notes', memberIndex, 'width')
     local ultimateWidth = (ultimateSwagWidth - ultimateNoteWidth) / 2
     
     local offsetsAddedX = d_dad['strums']['offsets'][1]
     local scaleDividedY = d_dad['strums']['height']


     if getPropertyFromGroup('notes', memberIndex, 'mustPress') then
          setPropertyFromGroup('notes', memberIndex, 'texture', bf:gsub('assets/shared/images/', ''));
          updateHitboxFromGroup('notes', memberIndex)
     else
          setPropertyFromGroup('notes', memberIndex, 'texture', dad:gsub('assets/shared/images/', ''));
          
          if isSustainNote == true then
               setPropertyFromGroup('notes', memberIndex, 'offsetX', ultimateNoteWidth + offsetsAddedX)

               if not stringEndsWith(getProperty('game.notes.members['..memberIndex..'].animation.curAnim.name'), 'end') then
                    setPropertyFromGroup('notes', memberIndex, 'scale.y', calculateNoteSustian / scaleDividedY % calculateNoteSustian)
               end
          end
          updateHitboxFromGroup('notes', memberIndex)
     end
end

function onUpdatePost(elapsed)
     if keyboardJustPressed('TAB') then
          SkinStateSave:set('dataSongName', '', songName)
          SkinStateSave:set('dataDiffID',   '', tostring(difficulty))
          SkinStateSave:set('dataDiffList', '', getPropertyFromClass('backend.Difficulty', 'list'))

          loadNewSong('Skin Selector', -1, {'Easy', 'Normal', 'Hard'})
     end
end