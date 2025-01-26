luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinSaves'
local Cursor    = require 'mods.NoteSkin Selector Remastered.api.classes.Cursor'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch         = global.switch
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

local metadata_preview = {}
local metadata_skins   = {}

local totalSkinLimit              = {}
local totalSkinObjects            = {}
local totalSkinObjectID           = {}
local totalSkinObjectNames        = {}

local totalSkinObjectHovered      = {}
local totalSkinObjectClicked      = {}
local totalSkinObjectSelected     = {}

local sliderTrackIntervals        = {}
local sliderTrackSemiIntervals    = {}

local selectSkinPagePositionIndex = {} -- lordx
local selectSkinInitSelectedIndex = {} -- d2011x
local selectSkinPreSelectedIndex  = {} -- xeno
local selectSkinCurSelectedIndex  = {} -- s2017x
local selectSkinHasBeenClicked    = {} -- sunky
--- Loads table data for the methods to use later.
---@return nil
function SkinStates:load()
     local skinCurrentState = self.currentState
     local function setToCurrentState(supvalue)
          
          local metaCurrentState = {}
          function metaCurrentState:__index(index)
               local newindex = #self == 1 and 1 or index
               return self[skinCurrentState][newindex]
          end
          function metaCurrentState:__newindex(value, index)
               local newindex = #self == 1 and 1 or index
               self[skinCurrentState][newindex] = value
          end
          return #self == 1 and setmetatable(supvalue, metaCurrentState) or setmetatable({supvalue}, metaCurrentState)[1]
     end

     metadata_preview = json.parse(getTextFromFile('json/'..self.currentState..'/preview_metadata.json'))
     metadata_skins   = json.parse(getTextFromFile('json/'..self.currentState..'/preview_metadata.json'))
    
     totalSkinLimit              = setToCurrentState(states.getTotalSkinLimit(self.currentState))
     totalSkinObjects            = setToCurrentState(states.getTotalSkinObjects(self.currentState))
     totalSkinObjectID           = setToCurrentState(states.getTotalSkinObjects(self.currentState, 'ids'))
     totalSkinObjectNames        = setToCurrentState(states.getTotalSkinObjects(self.currentState, 'names'))
     
     totalSkinObjectHovered      = setToCurrentState(states.getTotalSkinObjects(self.currentState, 'bools'))
     totalSkinObjectClicked      = setToCurrentState(states.getTotalSkinObjects(self.currentState, 'bools'))
     totalSkinObjectSelected     = setToCurrentState(states.getTotalSkinObjects(self.currentState, 'bools'))

     sliderTrackIntervals        = setToCurrentState(states.getPageSkinSliderPositions(self.currentState).intervals)
     sliderTrackSemiIntervals    = setToCurrentState(states.getPageSkinSliderPositions(self.currentState).semiIntervals)

     selectSkinPagePositionIndex = setToCurrentState(0)
     selectSkinInitSelectedIndex = setToCurrentState(0)
     selectSkinPreSelectedIndex  = setToCurrentState(0)
     selectSkinCurSelectedIndex  = setToCurrentState(0)
     selectSkinHasBeenClicked    = setToCurrentState(false)
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
          makeAnimatedLuaSprite(displaySkinIconButton, 'ui/buttons/display_button', displaySkinPositionX, displaySkinPositionY)
          addAnimationByPrefix(displaySkinIconButton, 'static', 'static')
          addAnimationByPrefix(displaySkinIconButton, 'selected', 'selected')
          addAnimationByPrefix(displaySkinIconButton, 'hover', 'hovered-static')
          addAnimationByPrefix(displaySkinIconButton, 'pressed', 'hovered-pressed')
          playAnim(displaySkinIconButton, 'static', true)
          scaleObject(displaySkinIconButton, 0.8, 0.8)
          setObjectCamera(displaySkinIconButton, 'camHUD')
          setProperty(displaySkinIconButton..'.antialiasing', false)
          addLuaSprite(displaySkinIconButton)

          local skinObjectMetadata
          local skinObjectMetadata_prefix
          local skinObjectMetadata_sizeX,   skinObjectMetadata_sizeY
          local skinObjectMetadata_offsetX, skinObjectMetadata_offsetY

          local metadataExists = true
          local skinObjectMetadata_load = function()
               local skinObjectNames = totalSkinObjectNames[index][displays]:gsub('%s+', '_')
               if metadata_preview == nil                             then metadataExists = false; return end
               if metadata_preview[skinObjectNames] == nil            then metadataExists = false; return end
               if metadata_preview[skinObjectNames]['display'] == nil then metadataExists = false; return end

               if metadataExists == false then return end
               skinObjectMetadata = metadata_preview[skinObjectNames]['display']

               skinObjectMetadata_prefix = skinObjectMetadata.prefixes
               skinObjectMetadata_sizeX  = skinObjectMetadata.size[1]
               skinObjectMetadata_sizeY  = skinObjectMetadata.size[2]

               skinObjectMetadata_offsetX = skinObjectMetadata.offsets[1]
               skinObjectMetadata_offsetY = skinObjectMetadata.offsets[2]
          end
          switch (self.currentState) {
               notes = function() 
                    skinObjectMetadata_prefix = 'arrowUP'
                    skinObjectMetadata_sizeX  = 0.55
                    skinObjectMetadata_sizeY  = 0.55
               end,
               splashes = function() 
                    skinObjectMetadata_prefix = 'note splash green 1'
                    skinObjectMetadata_sizeX  = 0.45
                    skinObjectMetadata_sizeY  = 0.45
               end
          }
          skinObjectMetadata_offsetX = 0
          skinObjectMetadata_offsetY = 0

          switch (self.currentState) {
               notes = function()
                    skinObjectMetadata_load()

                    local skinIconImagePath = 'noteSkins/'..totalSkinObjects[index][displays]
                    local skinIconPositionX = displaySkinPositionX + 16.5
                    local skinIconPositionY = displaySkinPositionY + 12
                    makeAnimatedLuaSprite(displaySkinIconSkin, skinIconImagePath, skinIconPositionX, skinIconPositionY)
                    scaleObject(displaySkinIconSkin, skinObjectMetadata_sizeX, skinObjectMetadata_sizeY)
                    addAnimationByPrefix(displaySkinIconSkin, 'static', skinObjectMetadata_prefix, 24, true)

                    local curOffsetX = getProperty(displaySkinIconSkin..'.offset.x')
                    local curOffsetY = getProperty(displaySkinIconSkin..'.offset.y')
                    addOffset(displaySkinIconSkin, 'static', curOffsetX + skinObjectMetadata_offsetX, curOffsetY + skinObjectMetadata_offsetY)
                    playAnim(displaySkinIconSkin, 'static')
                    setObjectCamera(displaySkinIconSkin, 'camHUD')
                    addLuaSprite(displaySkinIconSkin)
               end,
               splashes = function()
                    skinObjectMetadata_load()

                    local skinIconImagePath = 'noteSplashes/'..totalSkinObjects[index][displays]
                    local skinIconPositionX = displaySkinPositionX + 16.5
                    local skinIconPositionY = displaySkinPositionY + 12
                    makeAnimatedLuaSprite(displaySkinIconSkin, skinIconImagePath, skinIconPositionX, skinIconPositionY)
                    scaleObject(displaySkinIconSkin, skinObjectMetadata_sizeX, skinObjectMetadata_sizeY)
                    addAnimationByPrefix(displaySkinIconSkin, 'static', skinObjectMetadata_prefix, 15, true)

                    local curOffsetX = getProperty(displaySkinIconSkin..'.offset.x')
                    local curOffsetY = getProperty(displaySkinIconSkin..'.offset.y')
                    addOffset(displaySkinIconSkin, 'static', curOffsetX + skinObjectMetadata_offsetX, curOffsetY + skinObjectMetadata_offsetY)
                    playAnim(displaySkinIconSkin, 'static')
                    setObjectCamera(displaySkinIconSkin, 'camHUD')
                    addLuaSprite(displaySkinIconSkin)
               end
          }
     end
end

--- Creates and loads chunks from the current skin state, improves optimization significantly
---@param index? integer The chunk position index to display.
---@return nil
function SkinStates:create_preload()
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
     if sliderTrackThumbPressed == true then
          return
     end

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
               self:preview()

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

--- Selects the certain skin by a click or a search
---@return nil
function SkinStates:selection()
     local skinObjectsPerIDs      = totalSkinObjectID[pageCurrentIndex]
     local skinObjectsPerHovered  = totalSkinObjectHovered[pageCurrentIndex]
     local skinObjectsPerClicked  = totalSkinObjectClicked[pageCurrentIndex]
     local skinObjectsPerSelected = totalSkinObjectSelected[pageCurrentIndex]
     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (pageCurrentIndex - 1))

          local displaySkinIconTemplate = {state = (self.currentState):upperAtStart(), ID = pageSkins}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if skinObjectsPerSelected[curPage] == false then
               if clickObject(displaySkinIconButton) == true and skinObjectsPerClicked[curPage] == false then
                    SkinCursor:reload('grabbing')
                    playAnim(displaySkinIconButton, 'pressed', true)

                    selectSkinPreSelectedIndex = pageSkins
                    selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[curPage] = true
               end

               local released = (mouseReleased('left') and selectSkinPreSelectedIndex == pageSkins)
               if released == true and skinObjectsPerClicked[curPage] == true then
                    SkinCursor:reload('default')
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    selectSkinInitSelectedIndex = selectSkinCurSelectedIndex
                    selectSkinCurSelectedIndex  = pageSkins
                    selectSkinPagePositionIndex = pageCurrentIndex
                    selectSkinHasBeenClicked    = false
                    
                    skinObjectsPerSelected[curPage] = true
                    skinObjectsPerClicked[curPage]  = false

                    self:preview()
               end
          end
          if skinObjectsPerSelected[curPage] == true then
               if clickObject(displaySkinIconButton) == true and skinObjectsPerClicked[curPage] == false then
                    SkinCursor:reload('grabbing')
                    playAnim(displaySkinIconButton, 'pressed', true)

                    selectSkinPreSelectedIndex = pageSkins
                    selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[curPage] = true
               end

               local released = (mouseReleased('left') and selectSkinPreSelectedIndex == pageSkins)
               if released == true and skinObjectsPerClicked[curPage] == true then
                    SkinCursor:reload('default')
                    playAnim(displaySkinIconButton, 'static', true)
     
                    selectSkinCurSelectedIndex = 0
                    selectSkinPreSelectedIndex = 0
                    selectSkinHasBeenClicked   = false
     
                    skinObjectsPerSelected[curPage] = false
                    skinObjectsPerClicked[curPage]  = false
                    skinObjectsPerHovered[curPage]  = false

                    self:preview()
               end
          end
          
          if selectSkinPreSelectedIndex ~= pageSkins then
               if objectsOverlap(displaySkinIconButton, 'mouseHitBox') == true and skinObjectsPerHovered[curPage] == false then
                    if selectSkinHasBeenClicked == false then 
                         SkinCursor:reload('pointer')
                    end
                    playAnim(displaySkinIconButton, 'hover', true)
                    skinObjectsPerHovered[curPage] = true
               end
               if objectsOverlap(displaySkinIconButton, 'mouseHitBox') == false and skinObjectsPerHovered[curPage] == true then
                    if selectSkinHasBeenClicked == false then 
                         SkinCursor:reload('default')
                    end
                    playAnim(displaySkinIconButton, 'static', true)
                    skinObjectsPerHovered[curPage] = false
               end
          end

          if pageSkins == selectSkinInitSelectedIndex then
               skinObjectsPerSelected[curPage] = false
          end
     end
end

--- Syncs the saved selection of the certain skin
---@param bySearch boolean Whether to use by the search functionality or not.
---@return nil
function SkinStates:selection_sync(bySearch)
     local bySearch = bySearch == nil and false or true

     local skinObjectsPerIDs      = totalSkinObjectID[pageCurrentIndex]
     local skinObjectsPerHovered  = totalSkinObjectHovered[pageCurrentIndex]
     local skinObjectsPerClicked  = totalSkinObjectClicked[pageCurrentIndex]
     local skinObjectsPerSelected = totalSkinObjectSelected[pageCurrentIndex]
     if bySearch == true and (searchBarInput_onFocus() and keyboardJustPressed('ENTER')) then
          local searchBarInputContent       = getVar('searchBarInputContent')
          local searchBarInputContentFilter = searchBarInputContent ~= nil and searchBarInputContent:gsub('%-(.-)', '%1'):lower() or ''
          for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
               local curPage = pageSkins - (16 * (pageCurrentIndex - 1))
               if totalSkinObjectNames[pageCurrentIndex][curPage] == searchBarInputContent then
                    selectSkinInitSelectedIndex = selectSkinCurSelectedIndex
                    selectSkinPreSelectedIndex  = pageSkins
                    selectSkinCurSelectedIndex  = pageSkins
                    selectSkinPagePositionIndex = pageCurrentIndex
     
                    local displaySkinIconTemplate = {state = (self.currentState):upperAtStart(), ID = pageSkins}
                    local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
                    playAnim(displaySkinIconButton, 'selected', true)

                    skinObjectsPerSelected[curPage] = true
                    skinObjectsPerClicked[curPage]  = false
               end
          end
     end

     if selectSkinPreSelectedIndex ~= 0 and selectSkinPagePositionIndex == pageCurrentIndex then
          local displaySkinIconTemplate = {state = (self.currentState):upperAtStart(), ID = selectSkinPreSelectedIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          playAnim(displaySkinIconButton, 'selected', true)
     end 
end

function SkinStates:preview()
     local p = {'left', 'down', 'up', 'right'}
     local w = ''
     for funky = 1, 4 do
          local tag = 'fart'..funky

          if selectSkinCurSelectedIndex ~= 0 then
               local curPage = selectSkinCurSelectedIndex - (16 * (pageCurrentIndex - 1))
               w = 'noteSkins/'..totalSkinObjects[selectSkinPagePositionIndex][curPage]
          else
               w = 'noteSkins/NOTE_assets'
          end
          
          makeAnimatedLuaSprite(tag, w, 790+(105*(funky-1)), 135)

          addAnimationByPrefix(tag, 'left_confirm', 'left confirm', 24, false)
          addAnimationByPrefix(tag, 'down_confirm', 'down confirm', 24, false)
          addAnimationByPrefix(tag, 'up_confirm', 'up confirm', 24, false)
          addAnimationByPrefix(tag, 'right_confirm', 'right confirm', 24, false)

          addAnimationByPrefix(tag, 'left_pressed', 'left press', 24, false)
          addAnimationByPrefix(tag, 'down_pressed', 'down press', 24, false)
          addAnimationByPrefix(tag, 'up_pressed', 'up press', 24, false)
          addAnimationByPrefix(tag, 'right_pressed', 'right press', 24, false)

          addAnimationByPrefix(tag, 'left_colored', 'purple0', 24, false)
          addAnimationByPrefix(tag, 'down_colored', 'blue0', 24, false)
          addAnimationByPrefix(tag, 'up_colored', 'green0', 24, false)
          addAnimationByPrefix(tag, 'right_colored', 'red0', 24, false)

          addAnimationByPrefix(tag, 'left', 'arrowLEFT', 24, false)
          addAnimationByPrefix(tag, 'down', 'arrowDOWN', 24, false)
          addAnimationByPrefix(tag, 'up', 'arrowUP', 24, false)
          addAnimationByPrefix(tag, 'right', 'arrowRIGHT', 24, false)

          playAnim(tag, p[funky])
          scaleObject(tag, 0.65, 0.65)
          setObjectCamera(tag, 'camHUD')
          addLuaSprite(tag, true)
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