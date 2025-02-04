luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
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

local SkinNoteSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
local SkinCursor   = Cursor:new()
SkinCursor:load('default')

---@class SkinNotes
local SkinNotes = {}

--- Initializes the creation of a skin state to display skins.
---@param stateClass string The given tag for the class to inherit.
---@param statePath string The given corresponding image path to display its skins.
---@param stateStart boolean Whether to the given class state will be displayed at the start or not.
---@return table
function SkinNotes:new(stateClass, statePaths, startStart)
     local self = setmetatable({}, {__index = self})
     self.stateClass = stateClass
     self.statePaths = statePaths
     self.stateStart = stateStart

     return self
end

--- Loads multiple-unique data to the class itself, to be used later.
---@return nil
function SkinNotes:load()
     self.metadata_display = json.parse(getTextFromFile('json/'..self.stateClass..'/metadata_display.json'))
     self.metadata_preview = json.parse(getTextFromFile('json/'..self.stateClass..'/metadata_preview.json'))
    
     self.totalSkinLimit       = states.getTotalSkinLimit(self.stateClass)
     self.totalSkinObjects     = states.getTotalSkinObjects(self.stateClass)
     self.totalSkinObjectID    = states.getTotalSkinObjects(self.stateClass, 'ids')
     self.totalSkinObjectNames = states.getTotalSkinObjects(self.stateClass, 'names')
     
     self.totalSkinObjectHovered  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.totalSkinObjectClicked  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.totalSkinObjectSelected = states.getTotalSkinObjects(self.stateClass, 'bools')

     self.sliderPageIndex          = 1
     self.sliderTrackPageIndex     = 1
     self.sliderTrackPressed       = false
     self.sliderTrackToggle        = false
     self.sliderTrackIntervals     = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.sliderTrackSemiIntervals = states.getPageSkinSliderPositions(self.stateClass).semiIntervals
     
     self.selectSkinPrePagePositionIndex = 1
     self.selectSkinPagePositionIndex = 1     -- lordx
     self.selectSkinInitSelectedIndex = 0     -- d2011x
     self.selectSkinPreSelectedIndex  = 0     -- xeno
     self.selectSkinCurSelectedIndex  = 0     -- s2017x
     self.selectSkinHasBeenClicked    = false -- sunky
end

--- Creates a chunk to display the selected skins
---@param index? integer The specified page index for the given chunk to display.
---@return nil
function SkinNotes:create(index)
     local index = index == nil and 1 or index

     for pages = 1, self.totalSkinLimit do
          for displays = 1, #self.totalSkinObjects[pages] do
               if pages == index then
                    goto continue_removeNonCurrentPages
               end

               local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = self.totalSkinObjectID[pages][displays]}
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
          for displays = 1, #self.totalSkinObjects[index] do
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

     for displays = 1, #self.totalSkinObjects[index] do
          local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = self.totalSkinObjectID[index][displays]}
          local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
          local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)

          local displaySkinPositionX = displaySkinPositions()[displays][1]
          local displaySkinPositionY = displaySkinPositions()[displays][2]
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

          local displaySkinImageTemplate = {path = self.statePaths, skin = self.totalSkinObjects[index][displays]}
          local displaySkinImage = ('${path}/${skin}'):interpol(displaySkinImageTemplate)

          local displaySkinImagePositionX = displaySkinPositionX + 16.5
          local displaySkinImagePositionY = displaySkinPositionY + 12
          makeAnimatedLuaSprite(displaySkinIconSkin, displaySkinImage, displaySkinImagePositionX, displaySkinImagePositionY)
          scaleObject(displaySkinIconSkin, 0.55, 0.55)
          addAnimationByPrefix(displaySkinIconSkin, 'static', 'arrowUP', 24, true)

          local curOffsetX = getProperty(displaySkinIconSkin..'.offset.x')
          local curOffsetY = getProperty(displaySkinIconSkin..'.offset.y')
          --addOffset(displaySkinIconSkin, 'static', curOffsetX - getSkinMetadata.offsets[1], curOffsetY + getSkinMetadata.offsets[2])
          playAnim(displaySkinIconSkin, 'static')
          setObjectCamera(displaySkinIconSkin, 'camHUD')
          addLuaSprite(displaySkinIconSkin)
     end

     self:page_text()
     self:selection_sync()
end

--- Preloads multiple existing chunks by creating and deleting, improves optimization significantly.
---@return nil
function SkinNotes:create_preload()
     for pages = self.totalSkinLimit, 1, -1 do
          self:create(pages)
     end
end

--- Precaches images from this class for optimization purposes.
---@return nil
function SkinNotes:precache()
     for _, skins in pairs(states.getTotalSkins(self.stateClass, true)) do
          precacheImage(skins)
     end
     precacheImage('ui/buttons/display_button')
end

--- Main functionlity of the slider for switching pages.
---@param snapToPage? boolean Whether to enable snap to page when scrolling through pages.
---@return nil
function SkinNotes:page_slider(snapToPage)
     local snapToPage = snapToPage == nil and true or false

     local function sliderTrackThumbAnimations()
          if mousePressed('left') then
               playAnim('displaySliderIcon', 'pressed')
               setProperty('displaySliderIcon.y', getMouseY('camHUD') - getProperty('displaySliderIcon.height') / 2)
          end
          if mouseReleased('left') then
               playAnim('displaySliderIcon', 'static')
               self.sliderTrackThumbPressed = false 
          end
     end
     if clickObject('displaySliderIcon') then
          self.sliderTrackThumbPressed = true
     end
     if self.sliderTrackThumbPressed == true then
          sliderTrackThumbAnimations()
     end
     if self.totalSkinLimit < 2 then
          playAnim('displaySliderIcon', 'unscrollable')
     end
     
     if getProperty('displaySliderIcon.y') <= 127 then
          setProperty('displaySliderIcon.y', 127)
     end
     if getProperty('displaySliderIcon.y') >= 643 then
          setProperty('displaySliderIcon.y', 643)
     end

     local function sliderTrackCurrentPageIndex()
          local displaySliderIconPositionY = getProperty('displaySliderIcon.y')
          for positionIndex = 2, #self.sliderTrackIntervals do
               local sliderTrackBehindIntervals     = self.sliderTrackIntervals[positionIndex-1]
               local sliderTrackBehindSemiIntervals = self.sliderTrackSemiIntervals[positionIndex-1]

               local checkSliderTrackIntervalsByPosition     = sliderTrackBehindIntervals > displaySliderIconPositionY
               local checkSliderTrackSemiIntervalsByPosition = displaySliderIconPositionY <= sliderTrackBehindSemiIntervals
               if checkSliderTrackIntervalsByPosition and checkSliderTrackSemiIntervalsByPosition then 
                    return positionIndex-2 
               end
          end
          return false
     end

     local sliderTrackCurrentPageIndex = sliderTrackCurrentPageIndex()
     local function sliderTrackSwitchPage()
          local sliderTrackThumbPressed  = sliderTrackCurrentPageIndex ~= false and self.sliderTrackToggle == false
          local sliderTrackThumbReleased = sliderTrackCurrentPageIndex == false and self.sliderTrackToggle == true

          if sliderTrackThumbPressed and sliderTrackCurrentPageIndex ~= self.sliderPageIndex then
               if self.sliderTrackThumbPressed == true then 
                    self.sliderPageIndex = sliderTrackCurrentPageIndex
                    self:create(self.sliderPageIndex)

                    if self.sliderPageIndex == self.totalSkinLimit then
                         setTextColor('genInfoStatePage', 'ff0000')
                    else
                         setTextColor('genInfoStatePage', 'ffffff')
                    end
                    playSound('ding', 0.5)
               end
               
               self.sliderTrackPageIndex = sliderTrackCurrentPageIndex
               self.sliderTrackToggle    = true
          end
          if sliderTrackThumbReleased or sliderTrackCurrentPageIndex == self.sliderTrackPageIndex then
               self.sliderTrackToggle = false
          end
     end
     local function sliderTrackSnapPage()
          if snapToPage == false     then return end
          if self.totalSkinLimit < 2 then return end -- fixes a weird bug

          if self.sliderTrackThumbPressed == false and mouseReleased('left') then
               if sliderTrackCurrentPageIndex == self.totalSkinLimit then
                    setProperty('displaySliderIcon.y', 643); return
               end
               setProperty('displaySliderIcon.y', self.sliderTrackIntervals[sliderTrackCurrentPageIndex])
          end
     end

     sliderTrackSwitchPage()
     sliderTrackSnapPage()
end

--- Alternative functionlity of the slider for switching pages.
---@return nil
function SkinNotes:page_moved()
     if self.sliderTrackThumbPressed == true then return end
     local conditionPressedDown = keyboardJustConditionPressed('E', getVar('searchBarFocus') == false)
     local conditionPressedUp   = keyboardJustConditionPressed('Q', getVar('searchBarFocus') == false)

     local skinObjectsPerClicked = self.totalSkinObjectClicked[self.sliderPageIndex]
     local curPage = self.selectSkinPreSelectedIndex - (16 * (self.sliderPageIndex - 1))
     if not (skinObjectsPerClicked[curPage] == nil or skinObjectsPerClicked[curPage] == false) then
          if conditionPressedUp and self.sliderPageIndex > 1 then
               setTextColor('genInfoStatePage', 'f0b72f')
               playSound('cancel')
          end
          if conditionPressedDown and self.sliderPageIndex < self.totalSkinLimit then
               setTextColor('genInfoStatePage', 'f0b72f')
               playSound('cancel')
          end
          return
     end

     if conditionPressedUp and self.sliderPageIndex > 1 then
          self.sliderPageIndex = self.sliderPageIndex - 1
          self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex - 1
          self:create(self.sliderPageIndex)

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.sliderPageIndex])
     end
     if conditionPressedDown and self.sliderPageIndex < self.totalSkinLimit then
          self.sliderPageIndex = self.sliderPageIndex + 1
          self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex + 1
          self:create(self.sliderPageIndex)

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.sliderPageIndex])
     end

     if self.sliderPageIndex == self.totalSkinLimit then
          setTextColor('genInfoStatePage', 'ff0000')
     else
          setTextColor('genInfoStatePage', 'ffffff')
     end
end

--- Setups the current page text, that's it.
---@return nil
function SkinNotes:page_text()
     local currentPage = ('%.3d'):format(self.sliderPageIndex)
     local maximumPage = ('%.3d'):format(self.totalSkinLimit)
     setTextString('genInfoStatePage', (' Page ${cur} / ${max}'):interpol({cur = currentPage, max = maximumPage}))
end

--- Searches and finds the given skin.
---@return nil
function SkinNotes:found()
     if not (getVar('searchBarFocus') and keyboardJustPressed('ENTER')) then
          return nil
     end

     for skins = 1, self.totalSkinLimit do
          local searchBarInputContent       = getVar('searchBarInputContent')
          local searchBarInputContentFilter = searchBarInputContent ~= nil and searchBarInputContent:lower() or ''
          if table.find(self.totalSkinObjectNames[skins], searchBarInputContentFilter) ~= nil then
               self.sliderPageIndex = skins
               self:create(self.sliderPageIndex)
               self:preview()

               setProperty('displaySliderIcon.y', self.sliderTrackIntervals[skins])
               playSound('ding', 0.5)
               break
          end

          if skins == self.totalSkinLimit then
               setProperty(getVar('searchBarInput')..'.caretIndex', 1)
               callMethod(getVar('searchBarInput')..'.set_text', {''})

               setProperty('searchBarInputPlaceHolder.text', 'Invalid Skin!')
               setProperty('searchBarInputPlaceHolder.color', 0xB50000)
               playSound('cancel')
          end
     end
end

--- Selects the certain skin by a click or a search
---@return nil
function SkinNotes:selection()
     local skinObjectsPerIDs      = self.totalSkinObjectID[self.sliderPageIndex]
     local skinObjectsPerHovered  = self.totalSkinObjectHovered[self.sliderPageIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.sliderPageIndex]
     local skinObjectsPerSelected = self.totalSkinObjectSelected[self.sliderPageIndex]
     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (self.sliderPageIndex - 1))

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = pageSkins}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if skinObjectsPerSelected[curPage] == false then
               if clickObject(displaySkinIconButton) == true and skinObjectsPerClicked[curPage] == false then
                    SkinCursor:reload('grabbing')
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPrePagePositionIndex = self.sliderPageIndex
                    self.selectSkinPreSelectedIndex = pageSkins
                    self.selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[curPage] = true
               end

               local released = (mouseReleased('left') and self.selectSkinPreSelectedIndex == pageSkins)
               if released == true and skinObjectsPerClicked[curPage] == true then
                    SkinCursor:reload('default')
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    self.selectSkinInitSelectedIndex = self.selectSkinCurSelectedIndex
                    self.selectSkinCurSelectedIndex  = pageSkins
                    self.selectSkinPagePositionIndex = self.sliderPageIndex
                    self.selectSkinHasBeenClicked    = false
                    
                    self:preview()
                    skinObjectsPerSelected[curPage] = true
                    skinObjectsPerClicked[curPage]  = false
               end
          end
          if skinObjectsPerSelected[curPage] == true then
               if clickObject(displaySkinIconButton) == true and skinObjectsPerClicked[curPage] == false then
                    SkinCursor:reload('grabbing')
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPrePagePositionIndex = self.sliderPageIndex
                    self.selectSkinPreSelectedIndex = pageSkins
                    self.selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[curPage] = true
               end

               local released = (mouseReleased('left') and self.selectSkinPreSelectedIndex == pageSkins)
               if released == true and skinObjectsPerClicked[curPage] == true then
                    SkinCursor:reload('default')
                    playAnim(displaySkinIconButton, 'static', true)
     
                    self.selectSkinPrePagePositionIndex = 0
                    self.selectSkinCurSelectedIndex = 0
                    self.selectSkinPreSelectedIndex = 0
                    self.selectSkinHasBeenClicked   = false

                    self:preview()
                    skinObjectsPerSelected[curPage] = false
                    skinObjectsPerClicked[curPage]  = false
                    skinObjectsPerHovered[curPage]  = false
               end
          end
          
          if self.selectSkinPreSelectedIndex ~= pageSkins then
               if objectsOverlap(displaySkinIconButton, 'mouseHitBox') == true and skinObjectsPerHovered[curPage] == false then
                    if self.selectSkinHasBeenClicked == false then 
                         SkinCursor:reload('pointer')
                    end
                    playAnim(displaySkinIconButton, 'hover', true)
                    skinObjectsPerHovered[curPage] = true
               end
               if objectsOverlap(displaySkinIconButton, 'mouseHitBox') == false and skinObjectsPerHovered[curPage] == true then
                    if self.selectSkinHasBeenClicked == false then 
                         SkinCursor:reload('default')
                    end
                    playAnim(displaySkinIconButton, 'static', true)
                    skinObjectsPerHovered[curPage] = false
               end
          end

          if pageSkins == self.selectSkinInitSelectedIndex then
               playAnim(displaySkinIconButton, 'static', true)

               self.selectSkinInitSelectedIndex = 0
               skinObjectsPerSelected[curPage]  = false
          end
     end
end

--- Syncs the saved selection of the certain skin
---@return nil
function SkinNotes:selection_sync()
     local skinObjectsPerIDs      = self.totalSkinObjectID[self.sliderPageIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.sliderPageIndex]
     local skinObjectsPerSelected = self.totalSkinObjectSelected[self.sliderPageIndex]
     local skinObjectsPerName     = self.totalSkinObjectNames[self.sliderPageIndex]

     local searchBarInputContent       = getVar('searchBarInputContent')
     local searchBarInputContentFilter = searchBarInputContent ~= nil and searchBarInputContent:lower() or ''
     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (self.sliderPageIndex - 1))

          if skinObjectsPerName[curPage] == searchBarInputContentFilter and pageSkins ~= self.selectSkinCurSelectedIndex then
               self.selectSkinInitSelectedIndex = self.selectSkinCurSelectedIndex
               self.selectSkinPreSelectedIndex  = pageSkins
               self.selectSkinCurSelectedIndex  = pageSkins
               self.selectSkinPagePositionIndex = self.sliderPageIndex
               self.selectSkinHasBeenClicked    = false

               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = pageSkins}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
               playAnim(displaySkinIconButton, 'selected', true)

               skinObjectsPerSelected[curPage] = true
               skinObjectsPerClicked[curPage]  = false
               break
          end
     end

     if self.selectSkinPreSelectedIndex ~= 0 and self.selectSkinPagePositionIndex == self.sliderPageIndex then
          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = self.selectSkinPreSelectedIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if luaSpriteExists(displaySkinIconButton) == true then
               playAnim(displaySkinIconButton, 'selected', true)
          end
     end
end

function SkinNotes:preview()
     local curPage = self.selectSkinCurSelectedIndex - (16 * (self.sliderPageIndex - 1))
     local getCurrentPreviewSkinNames = function()
          local skinNames   = self.totalSkinObjectNames[self.sliderPageIndex]
          return curPage > 0 and skinNames[curPage]:gsub('%s+', '_'):lower() or self.totalSkinObjectNames[1][1]
     end
     local getCurrentPreviewSkinObjects = function()
          local skinObjects = self.totalSkinObjects[self.sliderPageIndex]
          return curPage > 0 and skinObjects[curPage] or self.totalSkinObjects[1][1]
     end

     local curSkinName = getCurrentPreviewSkinNames()
     for strums = 1, 4 do
          local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
          local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)

          local previewSkinImagePath = self.statePaths..'/'..getCurrentPreviewSkinObjects()
          local previewSkinPositionX = 790 + (105*(strums-1))
          local previewSkinPositionY = 135
          makeAnimatedLuaSprite(previewSkinGroup, previewSkinImagePath, previewSkinPositionX, previewSkinPositionY)
          scaleObject(previewSkinGroup, 0.65, 0.65)
          addAnimationByPrefix(previewSkinGroup, 'left', 'arrowLEFT', 24, false)
          addAnimationByPrefix(previewSkinGroup, 'down', 'arrowDOWN', 24, false)
          addAnimationByPrefix(previewSkinGroup, 'up', 'arrowUP', 24, false)
          addAnimationByPrefix(previewSkinGroup, 'right', 'arrowRIGHT', 24, false)
          playAnim(previewSkinGroup, ({'left', 'down', 'up', 'right'})[strums])
          setObjectCamera(previewSkinGroup, 'camHUD')
          addLuaSprite(previewSkinGroup, true)
     end
end 

function SkinNotes:switch()

end

function SkinNotes:yeat()
     --[[ debugPrint({

          totalSkinObjectClicked = self.totalSkinObjectClicked[self.sliderPageIndex],
          selectSkinCurSelectedIndex = self.selectSkinCurSelectedIndex
     }) ]]

     --[[ debugPrint({
          totalSkinObjectHovered = self.totalSkinObjectClicked[self.sliderPageIndex]
     }) ]]
end

--- Loads the save data from the current class state.
---@return nil
function SkinNotes:save_load()
     self:create(self.selectSkinPagePositionIndex)
     setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
end

return SkinNotes