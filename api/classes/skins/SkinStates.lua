luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinSaves'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch = global.switch
local clickObject = funkinlua.clickObject
local createTimer = funkinlua.createTimer
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinStateSaves = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

---@class SkinStates
local SkinStates = {}

--- Initializes the creation of a skin state to display skins.
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

local totalSkinObjects     = {}
local totalSkinObjectID    = {}
local totalSkinObjectNames = {}
local totalSkinLimit = 0

local totalSkinOneTime = true
--- Loads multiple tables to each corresponding variables, can only be loaded once executed.
---@return nil
function SkinStates:load_totalSkinData()
     if totalSkinOneTime == true then
          totalSkinObjects     = states.getTotalSkinObjects(self.currentState)
          totalSkinObjectID    = states.getTotalSkinObjects(self.currentState, 'ids')
          totalSkinObjectNames = states.getTotalSkinObjects(self.currentState, 'names')
          totalSkinLimit       = states.getTotalSkinLimit(self.currentState)

          totalSkinOneTime = false
     end
end

local sliderTrackIntervals     = {}
local sliderTrackSemiIntervals = {}

local sliderTrackOneTime = true
--- Loads multiple tables to each corresponding variables, can only be loaded once executed.
---@return nil
function SkinStates:load_pageSkinSliderData()
     if sliderTrackOneTime == true then
          sliderTrackIntervals     = states.getPageSkinSliderPositions(self.currentState).intervals
          sliderTrackSemiIntervals = states.getPageSkinSliderPositions(self.currentState).semiIntervals

          sliderTrackOneTime = false
     end
end

--- Creates a chunk from the current skin state selected to display skins.
---@param index? integer The chunk position index to display.
---@return nil
function SkinStates:create(index)
     local index = index == nil and 1 or index
     self:load_totalSkinData()

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

--- Creates and loads chunks from the current skin state, improves optimization significantly
---@param index? integer The chunk position index to display.
---@return nil
function SkinStates:create_pre(index)
     local index = index == nil and 1 or index
     for pages = 1, totalSkinLimit do
          self:create(pages)
     end
     self:create(index)
end

local pageCurrentIndex = 1
local sliderTrackThumbPressed = false
local sliderTrackToggle       = false
local sliderTrackCurrentPage  = 0
--- Main functionlity of the slider for switching pages.
---@param snapToPage? boolean Whether to enable snap to page when scrolling through pages.
---@return nil
function SkinStates:page_slider(snapToPage)
     local snapToPage = snapToPage == nil and true or false
     self:load_pageSkinSliderData()

     if clickObject('displaySliderIcon') then
          sliderTrackThumbPressed = true
     end

     if sliderTrackThumbPressed == true and totalSkinLimit >= 2 then
          if mousePressed('left') then
               playAnim('displaySliderIcon', 'pressed')

               local displaySliderIconHeight = getProperty('displaySliderIcon.height')
               setProperty('displaySliderIcon.y', getMouseY('camHUD') - displaySliderIconHeight / 2)
          end
          if mouseReleased('left') then
               playAnim('displaySliderIcon', 'static')
               sliderTrackThumbPressed = false 
          end
     end
     if totalSkinLimit < 2 then
          playAnim('displaySliderIcon', 'unscrollable')
     end

     if getProperty('displaySliderIcon.y') <= 127 then
          setProperty('displaySliderIcon.y', 127)
     end
     if getProperty('displaySliderIcon.y') >= 643 then
          setProperty('displaySliderIcon.y', 643)
     end

     local function sliderTrackCheckIntervals()
          local displaySliderIconPositionY = getProperty('displaySliderIcon.y')
          for positionIndex = 2, #sliderTrackIntervals do
               local sliderTrackBehindIntervals     = sliderTrackIntervals[positionIndex-1]
               local sliderTrackBehindSemiIntervals = sliderTrackSemiIntervals[positionIndex-1]
               if sliderTrackBehindIntervals > displaySliderIconPositionY and displaySliderIconPositionY <= sliderTrackBehindSemiIntervals then
                    return positionIndex-2
               end
          end
          return false
     end

     local sliderTrackCurrentPageIndex = sliderTrackCheckIntervals()
     local function sliderTrackSwitchPages()
          local checkThumbPressed  = sliderTrackCurrentPageIndex ~= false and sliderTrackToggle == false
          local checkThumbReleased = sliderTrackCurrentPageIndex == false and sliderTrackToggle == true  -- semi-useful
          if checkThumbPressed and sliderTrackCurrentPageIndex ~= sliderTrackCurrentPage then
               if sliderTrackThumbPressed == true then 
                    self:create(sliderTrackCurrentPageIndex)
                    playSound('ding', 0.5)
                    pageCurrentIndex = sliderTrackCurrentPageIndex

                    local genInfoStatePageTemplate = {cur = ('%.3d'):format(sliderTrackCurrentPageIndex), max = ('%.3d'):format(totalSkinLimit) }
                    setTextString('genInfoStatePage', (' Page ${cur} / ${max}'):interpol(genInfoStatePageTemplate))
               end
               
               sliderTrackCurrentPage = sliderTrackCurrentPageIndex
               sliderTrackToggle = true
          end
          if checkThumbReleased or sliderTrackCurrentPageIndex == sliderTrackCurrentPage then
               sliderTrackToggle = false
          end
     end
     local function sliderTrackSnapToPage()
          if snapToPage == false then return end -- gosh this weird code looks weird
          if totalSkinLimit < 2  then return end -- fixes a weird bug

          if sliderTrackThumbPressed == false and mouseReleased('left') then
               if sliderTrackCurrentPageIndex == totalSkinLimit then
                    setProperty('displaySliderIcon.y', 643)
                    return
               end
               setProperty('displaySliderIcon.y', sliderTrackIntervals[sliderTrackCurrentPageIndex])
          end
     end

     sliderTrackSwitchPages()
     sliderTrackSnapToPage()
end

--- Alternative functionlity of the slider for switching pages.
---@return nil
function SkinStates:page_moved()
     local changeGenInfoPage = function()
          local genInfoStatePageTemplate = {cur = ('%.3d'):format(pageCurrentIndex), max = ('%.3d'):format(totalSkinLimit) }
          setTextString('genInfoStatePage', (' Page ${cur} / ${max}'):interpol(genInfoStatePageTemplate))
     end

     if keyboardJustConditionPressed('Q', searchBarInput_onFocus() == false) and pageCurrentIndex > 1 then
          pageCurrentIndex = pageCurrentIndex - 1
          changeGenInfoPage()

          self:create(pageCurrentIndex)
          setProperty('displaySliderIcon.y', sliderTrackIntervals[pageCurrentIndex])
          playSound('ding', 0.5)
     end
     if keyboardJustConditionPressed('E', searchBarInput_onFocus() == false) and pageCurrentIndex < totalSkinLimit then
          pageCurrentIndex = pageCurrentIndex + 1
          changeGenInfoPage()

          self:create(pageCurrentIndex)
          setProperty('displaySliderIcon.y', sliderTrackIntervals[pageCurrentIndex])
          playSound('ding', 0.5)
     end

     if pageCurrentIndex == totalSkinLimit then
          setTextColor('genInfoStatePage', 'ff0000')
     else
          setTextColor('genInfoStatePage', 'ffffff')
     end
end

--- Setups the current page text, that's it.
---@return nil
function SkinStates:page_setup()
     local genInfoStatePageTemplate = {cur = ('%.3d'):format(pageCurrentIndex), max = ('%.3d'):format(totalSkinLimit) }
     setTextString('genInfoStatePage', (' Page ${cur} / ${max}'):interpol(genInfoStatePageTemplate))
end

--- Searches and finds the given skin.
---@return nil
function SkinStates:found()
     if not (searchBarInput_onFocus() and keyboardJustPressed('ENTER')) then
          return nil
     end

     for skins = 1, totalSkinLimit do
          local searchBarInputContent = getVar('searchBarInputContent'):gsub('%-(.-)', '%1'):lower()
          if table.find(totalSkinObjectNames[skins], searchBarInputContent) ~= nil then
               pageCurrentIndex = skins
               self:create(pageCurrentIndex)
               self:page_setup()

               setProperty('displaySliderIcon.y', sliderTrackIntervals[skins])
               playSound('ding', 0.5)
               break
          end

          if skins == totalSkinLimit then
               setProperty(getVar('searchBarInput')..'.caretIndex', 0)
               callMethod(getVar('searchBarInput')..'.set_text', {''})

               setProperty('searchBarInputPlaceHolder.text', 'Invalid Skin!')
               setProperty('searchBarInputPlaceHolder.color', 0xB50000)
               playSound('cancel')
          end
     end
end


local p = {
     true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
     true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
     true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true
}
function SkinStates:hover()
     --[[ local q = totalSkinObjectID[pageCurrentIndex]
     if keyboardJustConditionPress('O', searchBarInput_onFocus() == false) then
          debugPrint({q-16, q})
     end ]]
     local q = totalSkinObjectID[pageCurrentIndex]

     for i = q[1], q[#q] do
          if objectsOverlap('displaySkinIconButtonNotes-'..i, 'mouseHitBox') == true and p[i] == true then
               playAnim('displaySkinIconButtonNotes-'..i, 'hover', true)
               p[i] = false
          end
          if objectsOverlap('displaySkinIconButtonNotes-'..i, 'mouseHitBox') == false and p[i] == false then
               playAnim('displaySkinIconButtonNotes-'..i, 'static', true)
               p[i] = true
          end
     end
end

function SkinStates:selection()
end

function SkinStates:switch()
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