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

local stateSave_checkboxNoteIndexPlayer   = SkinStateSave:get('checkboxSkinObjectIndexPlayer', 'notes', 0)
local stateSave_checkboxNoteIndexOpponent = SkinStateSave:get('checkboxSkinObjectIndexOpponent', 'notes', 0)

local stateSave_checkboxSplashIndexPlayer = SkinStateSave:get('checkboxSkinObjectIndexPlayer', 'splashes', 0)

local getTotalSkinNotes       = states.getTotalSkins('notes', true)
local getTotalSkinSplashes    = states.getTotalSkins('splashes', true)
local getMetadataSkinNotes    = states.getMetadataSkinsOrdered('notes', 'skins', true)
local getMetadataSkinSplashes = states.getMetadataSkinsOrdered('splashes', 'skins', true)

local getNoteSkinImagePathPlayer   = getTotalSkinNotes[stateSave_checkboxNoteIndexPlayer]
local getNoteSkinImagePathOpponent = getTotalSkinNotes[stateSave_checkboxNoteIndexOpponent]
local getNoteSkinMetadataPlayer    = getMetadataSkinNotes[stateSave_checkboxNoteIndexPlayer]
local getNoteSkinMetadataOpponent  = getMetadataSkinNotes[stateSave_checkboxNoteIndexOpponent]

local getSplashesSkinImagePathPlayer = getTotalSkinSplashes[stateSave_checkboxSplashIndexPlayer]
local getSplashesSkinMetadataPlayer  = getMetadataSkinSplashes[stateSave_checkboxSplashIndexPlayer]

local function filterSkinImagePath(str)
     local filterLocalPath = 'assets/shared/images/'
     if str:match(filterLocalPath) then
          return str:gsub(filterLocalPath, '')
     end
     return str
end

function onCreatePost()
     local fliterSkinNotePathPlayer   = filterSkinImagePath( getNoteSkinImagePathPlayer )
     local fliterSkinNotePathOpponent = filterSkinImagePath( getNoteSkinImagePathOpponent )
     for strums = 0,3 do
          setPropertyFromGroup('playerStrums', strums, 'texture', fliterSkinNotePathPlayer)
          setPropertyFromGroup('playerStrums', strums, 'useRGBShader', false)

          setPropertyFromGroup('opponentStrums', strums, 'texture', fliterSkinNotePathOpponent)
          setPropertyFromGroup('opponentStrums', strums, 'useRGBShader', false)
     end

     local filterSkinSplashesPathPlayer = filterSkinImagePath( getSplashesSkinImagePathPlayer )
     for memberIndex = 0, getProperty('unspawnNotes.length')-1 do
          setPropertyFromGroup('unspawnNotes', memberIndex, 'noteSplashData.texture', filterSkinSplashesPathPlayer)
          setPropertyFromGroup('unspawnNotes', memberIndex, 'noteSplashData.useRGBShader', false)
     end
end

function onSpawnNote(memberIndex, noteData, noteType, isSustainNote, strumTime)
     local fliterSkinNotePathPlayer   = filterSkinImagePath( getNoteSkinImagePathPlayer )
     local fliterSkinNotePathOpponent = filterSkinImagePath( getNoteSkinImagePathOpponent )

     local songSpeed    = getProperty('songSpeed')
     local songPlayRate = getProperty('playbackRate')
     local noteSustainHeight = ((stepCrochet / 100 * 1.05) * songSpeed) / songPlayRate

     local ultimateSwagWidth = getPropertyFromClass('objects.Note', 'swagWidth')
     local ultimateNoteWidth = getPropertyFromGroup('notes', memberIndex, 'width')
     local ultimateWidth     = (ultimateSwagWidth - ultimateNoteWidth) / 2
     if getPropertyFromGroup('notes', memberIndex, 'mustPress') then
          setPropertyFromGroup('notes', memberIndex, 'texture', fliterSkinNotePathPlayer);

          if isSustainNote == true then
               setPropertyFromGroup('notes', memberIndex, 'offsetX', ultimateNoteWidth - getNoteSkinMetadataPlayer.strums.offsetX)

               local isTailNote = stringEndsWith(getProperty('game.notes.members['..memberIndex..'].animation.curAnim.name'), 'end')
               if not isTailNote then
                    setPropertyFromGroup('notes', memberIndex, 'scale.y', noteSustainHeight / getNoteSkinMetadataPlayer.strums.height % noteSustainHeight)
               end
          end
          updateHitboxFromGroup('notes', memberIndex)
     else
          setPropertyFromGroup('notes', memberIndex, 'texture', fliterSkinNotePathOpponent);

          if isSustainNote == true then
               setPropertyFromGroup('notes', memberIndex, 'offsetX', ultimateNoteWidth - getNoteSkinMetadataOpponent.strums.offsetX)

               local isTailNote = stringEndsWith(getProperty('game.notes.members['..memberIndex..'].animation.curAnim.name'), 'end')
               if not isTailNote then
                    setPropertyFromGroup('notes', memberIndex, 'scale.y', noteSustainHeight / getNoteSkinMetadataOpponent.strums.height % noteSustainHeight)
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