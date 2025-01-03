luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinSaves'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch = global.switch

--[[ local function getJsonData(path)
     local JSONpath = 'mods/NoteSkin Selector Remastered/jsons/'..path
     return json.parse(globals.getTextFileContent(JSONpath), true)
end ]]

local function toAllMetatable(tab, default)
     local duplicateMetaData = { 
          __index    = function() return default end,
          __newindex = function() return default end
     }
     local duplicate = {}
     for keys, values in pairs(tab) do
		if type(values) == "table" then
               values = toAllMetatable(setmetatable(values, duplicateMetaData), default)
          else
               values = values
          end
          duplicate[keys] = values
     end
     return setmetatable(duplicate, duplicateMetaData)
end

local SkinStateSaves = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
local SkinStates = {}
function SkinStates:new(stateStart, stateTypes, statePaths)
     local self = setmetatable({}, {__index = self})
     self.stateStart = stateStart
     self.stateTypes = stateTypes
     self.statePaths = statePaths

     return self
end

-- local test = SkinStates:new('notes', {'notes', 'splashes'}, {'noteSkins', 'noteSplashes'})
-- test:create(0)
function SkinStates:create(index)
     local index = index == nil and 1 or index
     local currentState = self.stateTypes[table.find(self.stateTypes, self.stateStart)]

     local totalSkinObjects  = states.getTotalSkinObjects(currentState, index)
     local totalSkinObjectID = states.getTotalSkinObjects(currentState, index, 'ids')
     local displaySkinPositions = function()
          local displaySkinIndexes   = {x = 0, y = 0}
          local displaySkinPositions = {}
          for displays = 1, #totalSkinObjects do
               if (displays-1) % 4 == 0 then
                    displaySkinIndexes.x = 0
                    displaySkinIndexes.y = displaySkinIndexes.y + 1
               else
                    displaySkinIndexes.x = displaySkinIndexes.x + 1
               end

               local displaySkinPositionX = 20  + (170 * displaySkinIndexes.x) - (25 * displaySkinIndexes.x)
               local displaySkinPositionY = -20 + (180 * displaySkinIndexes.y) - (30 * displaySkinIndexes.y)
               displaySkinPositions[#displaySkinPositions + 1] = {displaySkinPositionX, displaySkinPositionY}
          end
          return displaySkinPositions
     end

     local totalSkinLimit = states.getTotalSkinLimit(currentState)
     for pages = 1, totalSkinLimit do
          local totalSkinObjects = states.getTotalSkinObjects(currentState, pages)
          local totalSkinObjectID = states.getTotalSkinObjects(currentState, pages, 'ids')
          for displays = 1, #totalSkinObjects do
               if pages == index then
                    goto continue_removeNonCurrentPages
               end

               local displaySkinIconTemplates = {state = currentState:upperAtStart(), ID = totalSkinObjectID[displays]}
               local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
               local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)
               removeLuaSprite(displaySkinIconButton, true)
               removeLuaSprite(displaySkinIconSkin, true)
               ::continue_removeNonCurrentPages::
          end
     end
     
     local call_displaySkinPositions = displaySkinPositions()
     for displays = 1, #totalSkinObjects do
          local displaySkinPositionX = call_displaySkinPositions[displays][1]
          local displaySkinPositionY = call_displaySkinPositions[displays][2]

          local displaySkinIconTemplates = {state = currentState:upperAtStart(), ID = totalSkinObjectID[displays]}
          local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
          local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)
          switch (currentState) {
               notes = function()
                    makeAnimatedLuaSprite(displaySkinIconButton, 'ui/buttons/display_button', displaySkinPositionX, displaySkinPositionY)
                    addAnimationByPrefix(displaySkinIconButton, 'static', 'display_button-static')
                    addAnimationByPrefix(displaySkinIconButton, 'selected', 'display_button-selected')
                    addAnimationByPrefix(displaySkinIconButton, 'hover', 'display_button-hover')
                    playAnim(displaySkinIconButton, 'static')
                    scaleObject(displaySkinIconButton, 0.8, 0.8)
                    setProperty(displaySkinIconButton..'.camera', instanceArg('camHUD'), false, true)
                    setProperty(displaySkinIconButton..'.antialiasing', false)
                    addLuaSprite(displaySkinIconButton)

                    makeAnimatedLuaSprite(displaySkinIconSkin, 'noteSkins/'..totalSkinObjects[displays], displaySkinPositionX + 16.5, displaySkinPositionY + 12)
                    addAnimationByPrefix(displaySkinIconSkin, 'static', 'arrowUP')
                    playAnim(displaySkinIconSkin, 'static')
                    scaleObject(displaySkinIconSkin, 0.55, 0.55)
                    setProperty(displaySkinIconSkin..'.camera', instanceArg('camHUD'), false, true)
                    addLuaSprite(displaySkinIconSkin)
               end,
               splashes = function()
                    
               end
          }
     end
end

function SkinStates:switch()

end

function SkinStates:page()
end

function SkinStates:hover()
end

function SkinStates:selection()
end

function SkinStates:precache()
     for types = 1, #self.stateTypes do
          local skinSprites = states.getTotalSkins(self.stateTypes[types], true)
          for skins = 1, #skinSprites do
               precacheImage(skinSprites[skins])
          end
     end
end

return SkinStates