luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinSaves'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch = global.switch

local SkinStateSaves = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
local SkinStates = {}

--- Initializes the creation of a skin state to display skins
---@param stateStart string The given starting skin state to display first when created.
---@param stateTypes table[string] The given skin states within a group to display later.
---@param statePaths table[string] The given corresponding image paths to each skin states.
---@return table
function SkinStates:new(stateStart, stateTypes, statePaths)
     local self = setmetatable({}, {__index = self})
     self.stateStart = stateStart
     self.stateTypes = stateTypes
     self.statePaths = statePaths
     self.currentState = stateTypes[table.find(stateTypes, stateStart)]

     return self
end

local totalSkinObjects  = {}
local totalSkinObjectID = {}
local totalSkinLimit    = 0

local totalSkinOneTime  = true
--- Loads a bunch of tables to each variables; improves optimization by about 10 milliseconds.
--- Can only be loaded once.
---@return nil
function SkinStates:loadTotalSkinData()
     if totalSkinOneTime == true then
          totalSkinObjects  = states.getTotalSkinObjects(self.currentState)
          totalSkinObjectID = states.getTotalSkinObjects(self.currentState, 'ids')
          totalSkinLimit    = states.getTotalSkinLimit(self.currentState)

          totalSkinOneTime = false
     end
end

--- Creates a chunk from the current skin state selected to display skins.
---@param index? integer The chunk position index to display.
---@return nil
function SkinStates:create(index)
     local index = index == nil and 1 or index
     self:loadTotalSkinData()
       
     local function displaySkinPositions()
          local displaySkinIndexes   = {x = 0, y = 0}
          local displaySkinPositions = {}
          for displays = 1, #totalSkinObjects[index] do
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

     for pages = 1, totalSkinLimit do
          for displays = 1, #totalSkinObjects[pages] do
               if pages == index then
                    goto continue_removeNonCurrentPages
               end

               local displaySkinIconTemplates = {state = (self.currentState):upperAtStart(), ID = totalSkinObjectID[pages][displays]}
               local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
               local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
               ::continue_removeNonCurrentPages::
          end
     end

     local call_displaySkinPositions = displaySkinPositions()
     for displays = 1, #totalSkinObjects[index] do
          local displaySkinPositionX = call_displaySkinPositions[displays][1]
          local displaySkinPositionY = call_displaySkinPositions[displays][2]

          local displaySkinIconTemplates = {state = (self.currentState):upperAtStart(), ID = totalSkinObjectID[index][displays]}
          local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
          local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)

          switch (self.currentState) {
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

                    makeAnimatedLuaSprite(displaySkinIconSkin, 'noteSkins/'..totalSkinObjects[index][displays], displaySkinPositionX + 16.5, displaySkinPositionY + 12)
                    addAnimationByPrefix(displaySkinIconSkin, 'static', 'arrowUP')
                    playAnim(displaySkinIconSkin, 'static')
                    scaleObject(displaySkinIconSkin, 0.55, 0.55)
                    setProperty(displaySkinIconSkin..'.camera', instanceArg('camHUD'), false, true)
                    addLuaSprite(displaySkinIconSkin)
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

--- Precaches the images to each skin states for optimizations.
---@return nil
function SkinStates:precache()
     for types = 1, #self.stateTypes do
          local skinSprites = states.getTotalSkins(self.stateTypes[types], true)
          for skins = 1, #skinSprites do
               precacheImage(skinSprites[skins])
          end
     end
end

return SkinStates