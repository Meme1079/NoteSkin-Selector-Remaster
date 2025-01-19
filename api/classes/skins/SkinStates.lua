luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinSaves'
local Cursor    = require 'mods.NoteSkin Selector Remastered.api.classes.Cursor'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

require 'table.new'

local switch = global.switch
local createTimer    = funkinlua.createTimer
local clickObject    = funkinlua.clickObject
local pressedObject  = funkinlua.pressedObject
local releasedObject = funkinlua.releasedObject
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinStateSaves = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
local SkinCursor     = Cursor:new()
SkinCursor:load('default')

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

local totalSkinLimit = 0
local totalSkinObjects         = table.new(0xff, 0)
local totalSkinObjectID        = table.new(0xff, 0)
local totalSkinObjectNames     = table.new(0xff, 0)

local totalSkinObjectHovered   = table.new(0xff, 0)
local totalSkinObjectClicked   = table.new(0xff, 0)
local totalSkinObjectSelected  = table.new(0xff, 0)

local sliderTrackIntervals     = table.new(0xff, 0)
local sliderTrackSemiIntervals = table.new(0xff, 0)
--- Loads table data for the methods to use later.
---@return nil
function SkinStates:load()
     totalSkinObjects         = states.getTotalSkinObjects(self.currentState)
     totalSkinObjectID        = states.getTotalSkinObjects(self.currentState, 'ids')
     totalSkinObjectNames     = states.getTotalSkinObjects(self.currentState, 'names')
     totalSkinLimit           = states.getTotalSkinLimit(self.currentState)

     totalSkinObjectHovered   = states.getTotalSkinObjects(self.currentState, 'bools')
     totalSkinObjectClicked   = states.getTotalSkinObjects(self.currentState, 'bools')
     totalSkinObjectSelected  = states.getTotalSkinObjects(self.currentState, 'bools')

     sliderTrackIntervals     = states.getPageSkinSliderPositions(self.currentState).intervals
     sliderTrackSemiIntervals = states.getPageSkinSliderPositions(self.currentState).semiIntervals
end

--- Creates a chunk from the current skin state selected to display skins.
---@param index? integer The chunk position index to display.
---@return nil
function SkinStates:create(index)
     local index = index == nil and 1 or index

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
                    addAnimationByPrefix(displaySkinIconButton, 'static', 'static')
                    addAnimationByPrefix(displaySkinIconButton, 'selected', 'selected')
                    addAnimationByPrefix(displaySkinIconButton, 'hover', 'hovered-static')
                    addAnimationByPrefix(displaySkinIconButton, 'pressed', 'hovered-pressed')
                    playAnim(displaySkinIconButton, 'static', false)
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
function SkinStates:create_pre()
     for pages = totalSkinLimit, 1, -1 do
          self:create(pages)
     end
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
                    pageCurrentIndex = sliderTrackCurrentPageIndex
                    self:create(sliderTrackCurrentPageIndex)
                    self:selection_sync()
                    playSound('ding', 0.5)
                    
                    local genInfoStatePageTemplate = { cur = ('%.3d'):format(sliderTrackCurrentPageIndex), max = ('%.3d'):format(totalSkinLimit) }
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
          self:selection_sync()
          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', sliderTrackIntervals[pageCurrentIndex])
     end
     if keyboardJustConditionPressed('E', searchBarInput_onFocus() == false) and pageCurrentIndex < totalSkinLimit then
          pageCurrentIndex = pageCurrentIndex + 1
          changeGenInfoPage()

          self:create(pageCurrentIndex)
          self:selection_sync()
          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', sliderTrackIntervals[pageCurrentIndex])
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
               self:selection_sync(true)

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

local s2017x = 0
local d2011x = 0
local lordx  = 0

local xeno   = 0
local sunky  = false
function SkinStates:selection()
     local skinObjectsPerIDs      = totalSkinObjectID[pageCurrentIndex]
     local skinObjectsPerHovered  = totalSkinObjectHovered[pageCurrentIndex]
     local skinObjectsPerClicked  = totalSkinObjectClicked[pageCurrentIndex]
     local skinObjectsPerSelected = totalSkinObjectSelected[pageCurrentIndex]
     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (pageCurrentIndex - 1))

          local displaySkinIconTemplate = {state = (self.currentState):upperAtStart(), ID = pageSkins}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)

          local function a_1()
               SkinCursor:reload('grabbing')
               playAnim(displaySkinIconButton, 'pressed', true)
               skinObjectsPerClicked[curPage] = true
     
               xeno = pageSkins
               sunky = true
          end
          local function b_1()
               SkinCursor:reload('default')
               playAnim(displaySkinIconButton, 'selected', true)

               d2011x = s2017x
               s2017x = pageSkins
               lordx  = pageCurrentIndex
               sunky = false
               
               skinObjectsPerSelected[curPage] = true
               skinObjectsPerClicked[curPage]  = false
          end

          local function a_2()
               SkinCursor:reload('grabbing')
               playAnim(displaySkinIconButton, 'pressed', true)
               skinObjectsPerClicked[curPage] = true

               xeno = pageSkins
               sunky = true
          end
          local function b_2()
               SkinCursor:reload('default')
               playAnim(displaySkinIconButton, 'static', true)

               s2017x = 0
               xeno = 0
               sunky = false

               skinObjectsPerSelected[curPage] = false
               skinObjectsPerClicked[curPage]  = false
               skinObjectsPerHovered[curPage]  = false
          end

          if skinObjectsPerSelected[curPage] == false then
               if clickObject(displaySkinIconButton) == true and skinObjectsPerClicked[curPage] == false then
                    a_1()
               end
               if (mouseReleased('left') and xeno == pageSkins) and skinObjectsPerClicked[curPage] == true then
                    b_1()
               end
          end
          if skinObjectsPerSelected[curPage] == true then
               if clickObject(displaySkinIconButton) == true and skinObjectsPerClicked[curPage] == false then
                    a_1()
               end
               if (mouseReleased('left') and xeno == pageSkins) and skinObjectsPerClicked[curPage] == true then
                    b_2()
               end
          end

          local function c()
               if sunky == false then 
                    SkinCursor:reload('pointer')
               end

               playAnim(displaySkinIconButton, 'hover', true)
               skinObjectsPerHovered[curPage] = true
          end
          local function d()
               if sunky == false then 
                    SkinCursor:reload('default')
               end

               playAnim(displaySkinIconButton, 'static', true)
               skinObjectsPerHovered[curPage] = false
          end
          
          if xeno ~= pageSkins then
               if objectsOverlap(displaySkinIconButton, 'mouseHitBox') == true and skinObjectsPerHovered[curPage] == false then
                    c()
               end
               if objectsOverlap(displaySkinIconButton, 'mouseHitBox') == false and skinObjectsPerHovered[curPage] == true then
                    d()
               end
          end

          if pageSkins == d2011x then
               skinObjectsPerSelected[curPage] = false
          end
     end
end

function SkinStates:selection_sync(e)
     local e = e == nil and false or true

     local skinObjectsPerIDs      = totalSkinObjectID[pageCurrentIndex]
     local skinObjectsPerHovered  = totalSkinObjectHovered[pageCurrentIndex]
     local skinObjectsPerClicked  = totalSkinObjectClicked[pageCurrentIndex]
     local skinObjectsPerSelected = totalSkinObjectSelected[pageCurrentIndex]

     if e == true then
          local searchBarInputContent       = getVar('searchBarInputContent')
          local searchBarInputContentFilter = searchBarInputContent ~= nil and searchBarInputContent:gsub('%-(.-)', '%1'):lower() or ''

          for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
               local curPage = pageSkins - (16 * (pageCurrentIndex - 1))
               if totalSkinObjectNames[pageCurrentIndex][curPage] == searchBarInputContent then
                    xeno = pageSkins
                    d2011x = s2017x
                    s2017x = pageSkins
                    lordx  = pageCurrentIndex
                    sunky = false

                    local displaySkinIconTemplate = {state = (self.currentState):upperAtStart(), ID = pageSkins}
                    local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
                    playAnim(displaySkinIconButton, 'selected', true)

                    skinObjectsPerSelected[curPage] = true
                    skinObjectsPerClicked[curPage]  = false
               end
          end
     end

     if xeno ~= 0 and lordx == pageCurrentIndex then
          local displaySkinIconTemplate = {state = (self.currentState):upperAtStart(), ID = xeno}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)

          playAnim(displaySkinIconButton, 'selected', true)
     end     
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