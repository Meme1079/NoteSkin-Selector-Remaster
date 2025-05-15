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

local skinStaticDataNotes    = json.parse(getTextFromFile('json/notes/default static data/dsd_skins.json'))
local skinStaticDataSplashes = json.parse(getTextFromFile('json/splashes/default static data/dsd_skins.json'))

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

--- 
---@param skinStaticDataType table
---@param skinMetadataType table
---@param strumData string
---@return
local function skinsMetadataObjectData(skinStaticDataType, skinMetadataType, strumData)
     local skinMetadataObject         = skinMetadataType
     local skinMetadataObjectByAnim   = skinMetadataType.strums
     local skinStaticDataObjectByAnim = skinStaticDataType.strums
     if skinMetadataObject == '@void' or skinMetadataObjectByAnim == nil then
          return skinStaticDataObjectByAnim[strumData]
     end
     if skinMetadataObjectByAnim == nil then
          skinMetadataObjectByAnim['strums'] = skinStaticDataObjectByAnim
          return skinMetadataObjectByAnim
     end
     if skinMetadataObjectByAnim[strumData] == nil then
          skinMetadataObjectByAnim['strums'][strumData] = skinStaticDataObjectByAnim[strumData]
          return skinMetadataObjectByAnim[strumData]
     end
     return skinMetadataObjectByAnim[strumData]
end

---
---@param skinStaticDataType table
---@param skinMetadataType table
---@param element string
---@return any
local function skinsMetadataObjects(skinStaticDataType, skinMetadataType, element)
     local skinsMetadataObject       = skinMetadataType
     local skinsMetadataObjectByElem = skinMetadataType[element]
     if skinsMetadataObject == '@void' or skinsMetadataObjectByElem == nil then
          return skinStaticDataType[element]
     end
     return skinsMetadataObjectByElem
end

local skinMetadataObjectNotes = {
     player = {
          strums    = {
               height  = skinsMetadataObjectData(skinStaticDataNotes, getNoteSkinMetadataPlayer, 'height'),
               offsetX = skinsMetadataObjectData(skinStaticDataNotes, getNoteSkinMetadataPlayer, 'offsetX')
          },
          types     = skinsMetadataObjects(skinStaticDataNotes, getNoteSkinMetadataPlayer, 'types'),
          rgbshader = skinsMetadataObjects(skinStaticDataNotes, getNoteSkinMetadataPlayer, 'rgbshader')
     },
     opponent = {     
          strums    = {
               height  = skinsMetadataObjectData(skinStaticDataNotes, getNoteSkinMetadataOpponent, 'height'),
               offsetX = skinsMetadataObjectData(skinStaticDataNotes, getNoteSkinMetadataOpponent, 'offsetX')
          },
          types     = skinsMetadataObjects(skinStaticDataNotes, getNoteSkinMetadataOpponent, 'types'),
          rgbshader = skinsMetadataObjects(skinStaticDataNotes, getNoteSkinMetadataOpponent, 'rgbshader')
     }
}
local skinMetadataObjectSplashes = {
     types     = skinsMetadataObjects(skinStaticDataSplashes, getSplashesSkinMetadataPlayer, 'types'),
     rgbshader = skinsMetadataObjects(skinStaticDataSplashes, getSplashesSkinMetadataPlayer, 'rgbshader')
}

local skinMetadataObjectNotePlayer   = skinMetadataObjectNotes.player
local skinMetadataObjectNoteOpponent = skinMetadataObjectNotes.opponent
local fliterSkinNotePathPlayer       = filterSkinImagePath( getNoteSkinImagePathPlayer )
local fliterSkinNotePathOpponent     = filterSkinImagePath( getNoteSkinImagePathOpponent )

local skinMetadataObjectSplashPlayer = skinMetadataObjectSplashes
local filterSkinSplashesPathPlayer   = filterSkinImagePath( getSplashesSkinImagePathPlayer )
function onCreatePost()
     for strums = 0,3 do
          setPropertyFromGroup('playerStrums', strums, 'texture', fliterSkinNotePathPlayer)
          setPropertyFromGroup('playerStrums', strums, 'useRGBShader', skinMetadataObjectNotePlayer.rgbshader)

          setPropertyFromGroup('opponentStrums', strums, 'texture', fliterSkinNotePathOpponent)
          setPropertyFromGroup('opponentStrums', strums, 'useRGBShader', skinMetadataObjectNoteOpponent.rgbshader)
     end

     for memberIndex = 0, getProperty('unspawnNotes.length')-1 do
          setPropertyFromGroup('unspawnNotes', memberIndex, 'noteSplashData.texture', filterSkinSplashesPathPlayer)
          setPropertyFromGroup('unspawnNotes', memberIndex, 'noteSplashData.useRGBShader', skinMetadataObjectSplashPlayer.rgbshader)
     end
end

function onSpawnNote(memberIndex, noteData, noteType, isSustainNote, strumTime)
     local songSpeed    = getProperty('songSpeed')
     local songPlayRate = getProperty('playbackRate')
     local noteSustainHeight = ((stepCrochet / 100 * 1.05) * songSpeed) / songPlayRate

     local ultimateSwagWidth = getPropertyFromClass('objects.Note', 'swagWidth')
     local ultimateNoteWidth = getPropertyFromGroup('notes', memberIndex, 'width')
     local ultimateWidth     = (ultimateSwagWidth - ultimateNoteWidth) / 2

     ---
     ---@param skinMetadataObjectType table
     ---@return nil
     local function setPropertySustain(skinMetadataObjectType)
          if isSustainNote == false then
               return
          end
          local sustainNoteOffsetX = ultimateNoteWidth - skinMetadataObjectType.strums.offsetX
          setPropertyFromGroup('notes', memberIndex, 'offsetX', sustainNoteOffsetX)
          
          local isTailName = getProperty('game.notes.members['..memberIndex..'].animation.curAnim.name')
          local isTailNote = stringEndsWith(isTailName, 'end')
          if not isTailNote then
               local sustainNoteHeight = noteSustainHeight / skinMetadataObjectType.strums.height % noteSustainHeight
               if skinMetadataObjectType.strums.height == 0 then --! IF NO VALUE ADDED; DO NOT DELETE 
                    setPropertyFromGroup('notes', memberIndex, 'scale.y', noteSustainHeight)
               else
                    setPropertyFromGroup('notes', memberIndex, 'scale.y', sustainNoteHeight)
               end
          end
     end

     if getPropertyFromGroup('notes', memberIndex, 'mustPress') then
          setPropertyFromGroup('notes', memberIndex, 'texture', fliterSkinNotePathPlayer);
          setPropertyFromGroup('notes', memberIndex, 'rgbShader.enabled', skinMetadataObjectNotePlayer.rgbshader)
          setPropertySustain(skinMetadataObjectNotePlayer)
          updateHitboxFromGroup('notes', memberIndex)
     else
          setPropertyFromGroup('notes', memberIndex, 'texture', fliterSkinNotePathOpponent);
          setPropertyFromGroup('notes', memberIndex, 'rgbShader.enabled', skinMetadataObjectNoteOpponent.rgbshader)
          setPropertySustain(skinMetadataObjectNoteOpponent)
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