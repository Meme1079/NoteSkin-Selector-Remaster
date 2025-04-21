luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

require 'table.new'
require 'table.clear'

local switch         = global.switch
local createTimer    = funkinlua.createTimer
local hoverObject    = funkinlua.hoverObject
local clickObject    = funkinlua.clickObject
local pressedObject  = funkinlua.pressedObject
local releasedObject = funkinlua.releasedObject
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinNoteSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')

---@class SkinNotes
local SkinNotes = {}

--- Initializes the creation of a skin state to display skins.
---@param stateClass string The given tag for the class to inherit.
---@param statePath string The corresponding image path to display its skins.
---@param statePrefix string the corresponding prefix image for the said state. 
---@param stateStart boolean Whether to the given class state will be displayed at the start or not.
---@return table
function SkinNotes:new(stateClass, statePaths, statePrefix, startStart)
     local self = setmetatable({}, {__index = self})
     self.stateClass  = stateClass
     self.statePaths  = statePaths
     self.statePrefix = statePrefix
     self.stateStart  = stateStart

     return self
end

--- Loads multiple-unique data to the class itself, to be used later.
---@return nil
function SkinNotes:load()
     self.totalSkins     = states.getTotalSkins(self.stateClass, self.statePaths)
     self.totalSkinNames = states.getTotalSkinNames(self.stateClass)

     -- Object Properties --

     self.totalSkinLimit         = states.getTotalSkinLimit(self.stateClass)
     self.totalSkinObjects       = states.getTotalSkinObjects(self.stateClass)
     self.totalSkinObjectID      = states.getTotalSkinObjects(self.stateClass, 'ids')
     self.totalSkinObjectNames   = states.getTotalSkinObjects(self.stateClass, 'names')
     self.totalSkinObjectIndexes = states.getTotalSkinObjectIndexes(self.stateClass)

     -- Display Properties --
     
     self.totalSkinObjectHovered  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.totalSkinObjectClicked  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.totalSkinObjectSelected = states.getTotalSkinObjects(self.stateClass, 'bools')

     self.totalMetadataObjectDisplay  = states.getMetadataObjectSkins(self.stateClass, 'display', true)
     self.totalMetadataObjectPreview  = states.getMetadataObjectSkins(self.stateClass, 'preview', true)
     self.totalMetadataObjectSkins    = states.getMetadataObjectSkins(self.stateClass, 'skins', true)

     self.totalMetadataOrderedDisplay = states.getMetadataSkinsOrdered(self.stateClass, 'display', true)
     self.totalMetadataOrderedPreview = states.getMetadataSkinsOrdered(self.stateClass, 'preview', true)
     self.totalMetadataOrderedSkins   = states.getMetadataSkinsOrdered(self.stateClass, 'skins', true)
     
     -- Search Properties --

     self.searchSkinObjectIndex = table.new(16, 0)
     self.searchSkinObjectPage  = table.new(16, 0)

     -- Slider Properties --

     self.sliderPageIndex          = 1
     self.sliderTrackPageIndex     = 1
     self.sliderTrackPressed       = false
     self.sliderTrackToggle        = false
     self.sliderTrackIntervals     = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.sliderTrackSemiIntervals = states.getPageSkinSliderPositions(self.stateClass).semiIntervals

     -- Display Selection Properties --
     
     self.selectSkinPagePositionIndex = 1     -- current page index
     self.selectSkinInitSelectedIndex = 1     -- current pressed selected skin
     self.selectSkinPreSelectedIndex  = 1     -- highlighting the current selected skin
     self.selectSkinCurSelectedIndex  = 1     -- current selected skin index
     self.selectSkinHasBeenClicked    = false -- whether the skin display has been clicked or not

     -- Preview Animation Properties --

     self.previewAnimationObjectHovered = {false, false}
     self.previewAnimationObjectClicked = {false, false}

     self.previewAnimationObjectIndex     = 1
     self.previewAnimationObjectPrevAnims = {'confirm', 'pressed', 'colored'}

     -- Checkbox Skin Properties --

     self.checkboxSkinObjectHovered = {false, false}
     self.checkboxSkinObjectClicked = {false, false}

     self.checkboxSkinObjectIndex  = {player = 0,     opponent = 18}
     self.checkboxSkinObjectToggle = {player = false, opponent = false}
     self.checkboxSkinObjectType   = table.keys(self.checkboxSkinObjectIndex)

     self.metadataErrorExists = false
end

--- Checks if the any of skin states' data misaligned with each other.
--- If found it will reset the skin states' data to its default.
---@return nil
function SkinNotes:preventError()
     if self.totalSkinLimit <= self.sliderPageIndex then
          self.metadataErrorExists = true
     end
     if self.totalSkinLimit <= self.sliderTrackPageIndex then
          self.metadataErrorExists = true
     end
     if self.totalSkinLimit <= self.selectSkinPagePositionIndex then
          self.metadataErrorExists = true
     end

     if #self.totalSkins <= self.selectSkinInitSelectedIndex then
          self.metadataErrorExists = true
     end
     if #self.totalSkins <= self.selectSkinPreSelectedIndex then
          self.metadataErrorExists = true
     end
     if #self.totalSkins <= self.selectSkinCurSelectedIndex then
          self.metadataErrorExists = true
     end

     if self.metadataErrorExists == true then
          self.sliderPageIndex          = 1
          self.sliderTrackPageIndex     = 1

          self.selectSkinPagePositionIndex = 1
          self.selectSkinInitSelectedIndex = 0
          self.selectSkinPreSelectedIndex  = 0
          self.selectSkinCurSelectedIndex  = 0

          self:page_text()
          self:save_selection()
     end
end

--- Creates a 16 chunk display of the selected skins.
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

          local displaySkinMetadataJSON = self.totalMetadataObjectDisplay[index][displays]
          local displaySkinMetadata_frames   = displaySkinMetadataJSON == '@void' and 24           or (displaySkinMetadataJSON.frames   or 24)
          local displaySkinMetadata_prefixes = displaySkinMetadataJSON == '@void' and 'arrowUP'    or (displaySkinMetadataJSON.prefixes or 'arrowUP')
          local displaySkinMetadata_size     = displaySkinMetadataJSON == '@void' and {0.55, 0.55} or (displaySkinMetadataJSON.size     or {0.55, 0.55})
          local displaySkinMetadata_offsets  = displaySkinMetadataJSON == '@void' and {0, 0}       or (displaySkinMetadataJSON.offsets  or {0, 0})

          local displaySkinImageTemplate = {path = self.statePaths, skin = self.totalSkinObjects[index][displays]}
          local displaySkinImage = ('${path}/${skin}'):interpol(displaySkinImageTemplate)

          local displaySkinImagePositionX = displaySkinPositionX + 16.5
          local displaySkinImagePositionY = displaySkinPositionY + 12
          makeAnimatedLuaSprite(displaySkinIconSkin, displaySkinImage, displaySkinImagePositionX, displaySkinImagePositionY)
          scaleObject(displaySkinIconSkin, displaySkinMetadata_size[1], displaySkinMetadata_size[2])
          addAnimationByPrefix(displaySkinIconSkin, 'static', displaySkinMetadata_prefixes, displaySkinMetadata_frames, true)

          local curOffsetX = getProperty(displaySkinIconSkin..'.offset.x')
          local curOffsetY = getProperty(displaySkinIconSkin..'.offset.y')
          addOffset(displaySkinIconSkin, 'static', curOffsetX - displaySkinMetadata_offsets[1], curOffsetY + displaySkinMetadata_offsets[2])
          playAnim(displaySkinIconSkin, 'static')
          setObjectCamera(displaySkinIconSkin, 'camHUD')
          addLuaSprite(displaySkinIconSkin)
     end

     self:page_text()
     self:save_selection()
end

--- Preloads multiple existing chunks by creating and deleting, "improves optimization significantly".
---@return nil
function SkinNotes:preload()
     for pages = self.totalSkinLimit, 1, -1 do
          if pages ~= self.selectSkinPagePositionIndex then
               break
          end
          self:create(pages)
     end
end

--- Precaches the total amount of skin images for optimization purposes.
---@return nil
function SkinNotes:precache()
     for _, skins in pairs(states.getTotalSkins(self.stateClass, true)) do
          precacheImage(skins)
     end
     precacheImage('ui/buttons/display_button')
end

--- Slider functionality for switching to multiple pages.
---@param snapToPage? boolean Whether allow slider snapping to the nearest page.
---@return nil
function SkinNotes:page_slider(snapToPage)
     local snapToPage = snapToPage == nil and true or false

     local function sliderTrackThumbAnimations()
          if self.totalSkinLimit < 2 then
               return
          end

          if mousePressed('left') then
               playAnim('displaySliderIcon', 'pressed')
               setProperty('displaySliderIcon.y', getMouseY('camHUD') - getProperty('displaySliderIcon.height') / 2)
          end
          if mouseReleased('left') then
               playAnim('displaySliderIcon', 'static')
               self.sliderTrackThumbPressed = false 
          end
     end
     if clickObject('displaySliderIcon', 'camHUD') then
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
                    self:create(sliderTrackCurrentPageIndex)
                    self.selectSkinPagePositionIndex = sliderTrackCurrentPageIndex
                    self.sliderPageIndex             = sliderTrackCurrentPageIndex

                    if self.sliderPageIndex == self.totalSkinLimit then
                         setTextColor('genInfoStatePage', 'ff0000')
                    else
                         setTextColor('genInfoStatePage', 'ffffff')
                    end
                    playSound('ding', 0.5)
                    callOnScripts('skinSearchInput_callResetSearch')
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
                    setProperty('displaySliderIcon.y', 643)
                    return
               end
               setProperty('displaySliderIcon.y', self.sliderTrackIntervals[sliderTrackCurrentPageIndex])
          end
     end

     sliderTrackSwitchPage()
     sliderTrackSnapPage()
end

--- Creates a slider marks of each page intervals, for visual aid purposes.
---@return nil
function SkinNotes:page_slider_marks()
     local function sectionSliderMarks(tag, color, width, offsetTrackX, sliderTracks, sliderTrackIndex)
          local sectionSliderMarksTemplate = {tag = tag:upperAtStart(), index = sliderTrackIndex}
          local sectionSliderMarksTag = ('displaySliderMark${tag}${index}'):interpol(sectionSliderMarksTemplate)
          local sectionSliderMarksX   = getProperty('displaySliderTrack.x') - offsetTrackX
          local sectionSliderMarksY   = sliderTracks[sliderTrackIndex]
     
          makeLuaSprite(sectionSliderMarksTag, nil, sectionSliderMarksX, sectionSliderMarksY)
          makeGraphic(sectionSliderMarksTag, width, 3, color)
          setObjectOrder(sectionSliderMarksTag, getObjectOrder('displaySliderIcon') - 0)
          setObjectCamera(sectionSliderMarksTag, 'camHUD')
          setProperty(sectionSliderMarksTag..'.antialiasing', false)
          addLuaSprite(sectionSliderMarksTag)
     end

     for intervalIndex = 1, #self.sliderTrackIntervals do
          sectionSliderMarks('interval', '3b8527', 12 * 2, 12 / 2, self.sliderTrackIntervals, intervalIndex)
     end
     for semiIntervalIndex = 2, #self.sliderTrackSemiIntervals do
          sectionSliderMarks('semiInterval', '847500', 12 * 1.5, 12 / 4, self.sliderTrackSemiIntervals, semiIntervalIndex)
     end
end

--- Changes the page index by using keyboard keys.
---@return nil
function SkinNotes:page_moved()
     if self.sliderTrackThumbPressed == true then return end
     local conditionPressedDown = keyboardJustConditionPressed('E', getVar('skinSearchInputFocus') == false)
     local conditionPressedUp   = keyboardJustConditionPressed('Q', getVar('skinSearchInputFocus') == false)

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local skinObjectsPerClicked = self.totalSkinObjectClicked[self.selectSkinPagePositionIndex]
     local curPage = self.selectSkinPreSelectedIndex - (16 * (self.selectSkinPagePositionIndex - 1))
     if not (skinObjectsPerClicked[curPage] == nil or skinObjectsPerClicked[curPage] == false) then
          if conditionPressedUp and self.selectSkinPagePositionIndex > 1 then
               setTextColor('genInfoStatePage', 'f0b72f')
               playSound('cancel')
          end
          if conditionPressedDown and self.selectSkinPagePositionIndex < self.totalSkinLimit then
               setTextColor('genInfoStatePage', 'f0b72f')
               playSound('cancel')
          end
          return
     end

     if conditionPressedUp and self.selectSkinPagePositionIndex > 1 then
          self.sliderPageIndex             = self.sliderPageIndex - 1
          self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex - 1
          self:create(self.selectSkinPagePositionIndex)

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
          callOnScripts('skinSearchInput_callResetSearch')
     end
     if conditionPressedDown and self.selectSkinPagePositionIndex < self.totalSkinLimit then
          self.sliderPageIndex             = self.sliderPageIndex + 1
          self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex + 1
          self:create(self.selectSkinPagePositionIndex)

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
          callOnScripts('skinSearchInput_callResetSearch')
     end

     if self.selectSkinPagePositionIndex == self.totalSkinLimit then
          setTextColor('genInfoStatePage', 'ff0000')
     else
          setTextColor('genInfoStatePage', 'ffffff')
     end
end

--- Updates the current page text, that is literally it.
---@return nil
function SkinNotes:page_text()
     local currentPage = ('%.3d'):format(self.selectSkinPagePositionIndex)
     local maximumPage = ('%.3d'):format(self.totalSkinLimit)
     setTextString('genInfoStatePage', (' Page ${cur} / ${max}'):interpol({cur = currentPage, max = maximumPage}))
end

--- Collection of similair methods of the selection function.
---@return nil
function SkinNotes:selection()
     self:selection_byclick()
     self:selection_byhover()
     self:selection_bycursor()
end

--- Main click functionality when interacting any skins when selecting one.
--- Allows the selection of skins alongs with its display skin button animations.
---@return nil
function SkinNotes:selection_byclick()
     local skinObjectsPerIDs      = self.totalSkinObjectID[self.selectSkinPagePositionIndex]
     local skinObjectsPerHovered  = self.totalSkinObjectHovered[self.selectSkinPagePositionIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.selectSkinPagePositionIndex]
     local skinObjectsPerSelected = self.totalSkinObjectSelected[self.selectSkinPagePositionIndex]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (self.selectSkinPagePositionIndex - 1))

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = pageSkins}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          local function displaySkinSelect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == pageSkins

               if byClick == true and skinObjectsPerClicked[curPage] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = pageSkins
                    self.selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[curPage] = true
               end

               if byRelease == true and skinObjectsPerClicked[curPage] == true then
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    self.selectSkinInitSelectedIndex = self.selectSkinCurSelectedIndex
                    self.selectSkinCurSelectedIndex  = pageSkins
                    self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex
                    self.selectSkinHasBeenClicked    = false
                    
                    self:preview()
                    self:search_preview()
                    skinObjectsPerSelected[curPage] = true
                    skinObjectsPerClicked[curPage]  = false
               end
          end
          local function displaySkinDeselect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == pageSkins
               if byClick == true and skinObjectsPerClicked[curPage] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = pageSkins
                    self.selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[curPage] = true
               end

               if byRelease == true and skinObjectsPerClicked[curPage] == true then
                    playAnim(displaySkinIconButton, 'static', true)

                    self.selectSkinCurSelectedIndex = 0
                    self.selectSkinPreSelectedIndex = 0
                    self.selectSkinHasBeenClicked   = false

                    self:preview()
                    self:search_preview()
                    skinObjectsPerSelected[curPage] = false
                    skinObjectsPerClicked[curPage]  = false
                    skinObjectsPerHovered[curPage]  = false
               end
          end

          if skinObjectsPerSelected[curPage] == false or pageSkins ~= self.selectSkinCurSelectedIndex then
               displaySkinSelect()
          end
          if skinObjectsPerSelected[curPage] == true then
               --displaySkinDeselect()
          end

          if pageSkins == self.selectSkinInitSelectedIndex then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    playAnim(displaySkinIconButton, 'static', true)
               end

               self.selectSkinInitSelectedIndex = 0
               skinObjectsPerSelected[curPage]  = false
          end
     end
end

--- Main hovering functionality when interacting any skins when selecting any.
--- Allows the display skin button to have a hover animation.
---@return nil
function SkinNotes:selection_byhover()
     local skinObjectsPerIDs      = self.totalSkinObjectID[self.selectSkinPagePositionIndex]
     local skinObjectsPerHovered  = self.totalSkinObjectHovered[self.selectSkinPagePositionIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.selectSkinPagePositionIndex]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (self.selectSkinPagePositionIndex - 1))

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = pageSkins}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               skinObjectsPerHovered[curPage] = true
          end
          if hoverObject(displaySkinIconButton, 'camHUD') == false then
               skinObjectsPerHovered[curPage] = false
          end

          local nonCurrentPreSelectedSkin = self.selectSkinPreSelectedIndex ~= pageSkins
          local nonCurrentCurSelectedSkin = self.selectSkinCurSelectedIndex ~= pageSkins
          if skinObjectsPerHovered[curPage] == true and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'hover', true)
          end
          if skinObjectsPerHovered[curPage] == false and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'static', true)
          end
     end
end

--- Main cursor functionality when interacting any skins when selecting any.
--- Changes the cursor's texture depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotes:selection_bycursor()
     local skinObjectsPerHovered  = self.totalSkinObjectHovered[self.selectSkinPagePositionIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.selectSkinPagePositionIndex]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = self.selectSkinCurSelectedIndex}
     local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
     for skinIndex = 1, math.max(#skinObjectsPerClicked, #skinObjectsPerHovered) do
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               goto skipSelectedSkin -- disabled deselecting
          end

          if skinObjectsPerClicked[skinIndex] == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if skinObjectsPerHovered[skinIndex] == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
          ::skipSelectedSkin::
     end

     if hoverObject('displaySliderIcon', 'camHUD') == true and self.totalSkinLimit == 1 then
          if mouseClicked('left') or mousePressed('left') then 
               playAnim('mouseTexture', 'disabledClick', true)
          else
               playAnim('mouseTexture', 'disabled', true)
          end

          if mouseClicked('left') then 
               playSound('cancel') 
          end
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end
end

--- Creates the selected skin's preview strums.
---@return nil
function SkinNotes:preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local curPage  = self.selectSkinPagePositionIndex
     local curIndex = self.selectSkinCurSelectedIndex
     local function getCurrentPreviewSkin(previewSkinArray)
          if curIndex == 0 then
               return previewSkinArray[1][1]
          end

          for pages = 1, self.totalSkinLimit do
               local presentObjectIndex = table.find(self.totalSkinObjectIndexes[pages], curIndex)
               if presentObjectIndex ~= nil then
                    return previewSkinArray[pages][presentObjectIndex]
               end
          end
     end

     local getCurrentPreviewSkinObjects       = getCurrentPreviewSkin(self.totalSkinObjects)
     local getCurrentPreviewSkinObjectNames   = getCurrentPreviewSkin(self.totalSkinObjectNames)
     local getCurrentPreviewSkinObjectPreview = getCurrentPreviewSkin(self.totalMetadataObjectPreview)
     for strums = 1, 4 do
          local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
          local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)

          local previewMetadataObjectData = function(skinAnim)
               local previewMetadataObjecNames = getCurrentPreviewSkinObjectPreview['names'][skinAnim][strums]
               return getCurrentPreviewSkinObjectPreview['animations'][skinAnim][previewMetadataObjecNames]
          end
          local previewMetadataObjects  = function(element)
               return getCurrentPreviewSkinObjectPreview[element]
          end

          local previewMetadataByObjectConfirm = previewMetadataObjectData('confirm')
          local previewMetadataByObjectPressed = previewMetadataObjectData('pressed')
          local previewMetadataByObjectColored = previewMetadataObjectData('colored')
          local previewMetadataByObjectStrums  = previewMetadataObjectData('strums')

          local previewMetadataByFramesConfirm = previewMetadataObjects('frames').confirm
          local previewMetadataByFramesPressed = previewMetadataObjects('frames').pressed
          local previewMetadataByFramesColored = previewMetadataObjects('frames').colored
          local previewMetadataByFramesStrums  = previewMetadataObjects('frames').strums

          local previewMetadataBySize       = previewMetadataObjects('size')
          local previewMetadataByNameStrums = previewMetadataObjects('names')['strums'][strums]

          local previewSkinImagePath = self.statePaths..'/'..getCurrentPreviewSkinObjects
          local previewSkinPositionX = 790 + (105*(strums-1))
          local previewSkinPositionY = 135
          makeAnimatedLuaSprite(previewSkinGroup, previewSkinImagePath, previewSkinPositionX, previewSkinPositionY)
          scaleObject(previewSkinGroup, previewMetadataBySize[1], previewMetadataBySize[2])

          local addAnimationByPrefixGroup = function(previewMetadataByObjects, previewMetadataByFrames)
               local byName, byPrefix = previewMetadataByObjects.name, previewMetadataByObjects.prefix
               addAnimationByPrefix(previewSkinGroup, byName, byPrefix, previewMetadataByFrames, false)
          end
          addAnimationByPrefixGroup(previewMetadataByObjectConfirm, previewMetadataByFramesConfirm)
          addAnimationByPrefixGroup(previewMetadataByObjectPressed, previewMetadataByFramesPressed)
          addAnimationByPrefixGroup(previewMetadataByObjectColored, previewMetadataByFramesColored)
          addAnimationByPrefixGroup(previewMetadataByObjectStrums, previewMetadataByFramesStrums)

          local curOffsets = function(previewMetadataObject, positionType)
               local curOffsetX = getProperty(previewSkinGroup..'.offset.x')
               local curOffsetY = getProperty(previewSkinGroup..'.offset.y')
               if positionType == 'x' then
                    return curOffsetX - previewMetadataObject.offsets[1]
               end
               if positionType == 'y' then
                    return curOffsetY + previewMetadataObject.offsets[2]
               end
          end
          local addOffsets = function(previewSkinGroup, previewMetadataObject)
               local curOffsetX = curOffsets(previewMetadataObject, 'x')
               local curOffsetY = curOffsets(previewMetadataObject, 'y')
               addOffset(previewSkinGroup, previewMetadataObject.name, curOffsetX, curOffsetY)
          end
          addOffsets(previewSkinGroup, previewMetadataByObjectConfirm)
          addOffsets(previewSkinGroup, previewMetadataByObjectPressed)
          addOffsets(previewSkinGroup, previewMetadataByObjectColored)
          addOffsets(previewSkinGroup, previewMetadataByObjectStrums)

          playAnim(previewSkinGroup, previewMetadataByNameStrums)
          setObjectCamera(previewSkinGroup, 'camHUD')
          addLuaSprite(previewSkinGroup, true)
     end

     setTextString('genInfoSkinName', getCurrentPreviewSkinObjectNames)
     self:preview_animation(true)
end

--- Creates and loads the selected skin's preview animations.
---@param loadAnim? boolean Will only load the current skin's preview animations or not, bug fixing purposes.
---@return nil
function SkinNotes:preview_animation(loadAnim)
     local loadAnim = loadAnim ~= nil and true or false

     local firstJustPressed  = callMethodFromClass('flixel.FlxG', 'keys.firstJustPressed', {''})
     local firstJustReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})

     local firstJustInputPressed  = (firstJustPressed ~= -1 and firstJustPressed ~= nil)
     local firstJustInputReleased = (firstJustReleased ~= -1 and firstJustReleased ~= nil)
     local firstJustInputs        = (firstJustInputPressed or firstJustInputReleased)
     if not firstJustInputs and loadAnim == false then
          return
     end

     local curIndex = self.selectSkinCurSelectedIndex
     local function getCurrentPreviewSkin(previewSkinArray)
          if curIndex == 0 then
               return previewSkinArray[1][1]
          end

          for pages = 1, self.totalSkinLimit do
               local presentObjectIndex = table.find(self.totalSkinObjectIndexes[pages], curIndex)
               if presentObjectIndex ~= nil then
                    return previewSkinArray[pages][presentObjectIndex]
               end
          end
     end

     local conditionPressedLeft  = keyboardJustConditionPressed('Z', not getVar('skinSearchInputFocus'))
     local conditionPressedRight = keyboardJustConditionPressed('X', not getVar('skinSearchInputFocus'))
     local getCurrentPreviewSkinObjectPreview = getCurrentPreviewSkin(self.totalMetadataObjectPreview)
     for strums = 1, 4 do
          local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
          local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)

          local previewMetadataObjectAnims = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
          local previewMetadataObjectData  = function(skinAnim)
               local previewMetadataObjecNames = getCurrentPreviewSkinObjectPreview['names'][skinAnim][strums]
               return getCurrentPreviewSkinObjectPreview['animations'][skinAnim][previewMetadataObjecNames]
          end

          local previewMetadataObjectGroupData = {
               confirm = previewMetadataObjectData('confirm'), 
               pressed = previewMetadataObjectData('pressed'),
               colored = previewMetadataObjectData('colored'), 
               strums  = previewMetadataObjectData('strums')
          }

          if previewMetadataObjectAnims == 'colored' then
               playAnim(previewSkinGroup, previewMetadataObjectGroupData['colored']['name'], true)
               goto skipPreviewMetadataAnim
          end

          --[[ 
               I've spent hours finding a solution to fix a stupid visual bug where switching to the 
               preview colored animations for the strums, by using the buttons below will remain the same 
               previous animations until pressing a button to play an animation and adding "mouseReleased('left')" 
               to this if statement, literally solve this stupid issue

               Welcome to programming where Occam's Razor is somehow the main solution to every problem
                    ~ Meme1079
          ]]
          if (conditionPressedLeft or conditionPressedRight) or mouseReleased('left') then
               playAnim(previewSkinGroup, previewMetadataObjectGroupData['strums']['name'], true)
          end
          if keyboardJustConditionPressed(getKeyBinds(strums), not getVar('skinSearchInputFocus')) then
               playAnim(previewSkinGroup, previewMetadataObjectGroupData[previewMetadataObjectAnims]['name'], true)
          end
          if keyboardJustConditionReleased(getKeyBinds(strums), not getVar('skinSearchInputFocus')) then
               playAnim(previewSkinGroup, previewMetadataObjectGroupData['strums']['name'], true)
          end
          ::skipPreviewMetadataAnim::
     end
end

--- Collection of similair methods of the preview selection function.
---@return nil
function SkinNotes:preview_selection()
     self:preview_selection_moved()
     self:preview_selection_byclick()
     self:preview_selection_byhover()
     self:preview_selection_bycursor()
end

local previewSelectionToggle = false -- * ok who gaf
--- Changes the skin's preview animations by using keyboard keys.
---@return nil
function SkinNotes:preview_selection_moved()
     local conditionPressedLeft  = keyboardJustConditionPressed('Z', not getVar('skinSearchInputFocus'))
     local conditionPressedRight = keyboardJustConditionPressed('X', not getVar('skinSearchInputFocus'))

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
     local previewAnimationInverseMinIndex = self.previewAnimationObjectIndex <= 1
     local previewAnimationInverseMaxIndex = self.previewAnimationObjectIndex >= #self.previewAnimationObjectPrevAnims
     if conditionPressedLeft and previewAnimationMinIndex then
          self.previewAnimationObjectIndex = self.previewAnimationObjectIndex - 1
          previewSelectionToggle  = true

          playSound('ding', 0.5)
     end
     if conditionPressedRight and previewAnimationMaxIndex then
          self.previewAnimationObjectIndex = self.previewAnimationObjectIndex + 1
          previewSelectionToggle  = true

          playSound('ding', 0.5)
     end
     
     if previewSelectionToggle == true then --! DO NOT DELETE
          previewSelectionToggle = false
          return
     end

     if previewAnimationInverseMinIndex then
          playAnim('previewSkinInfoIconLeft', 'none', true)
          playAnim('previewSkinInfoIconRight', 'right', true)
     else
          playAnim('previewSkinInfoIconLeft', 'left', true)
     end

     if previewAnimationInverseMaxIndex then
          playAnim('previewSkinInfoIconLeft', 'left', true)
          playAnim('previewSkinInfoIconRight', 'none', true)
     else
          playAnim('previewSkinInfoIconRight', 'right', true)
     end

     local previewMetadataObjectAnims = self.previewAnimationObjectPrevAnims[self.previewAnimationObjectIndex]
     setTextString('previewSkinButtonSelectionText', previewMetadataObjectAnims:upperAtStart())
end

--- Main click functionality when interacting any preview buttons when selecting one.
--- Allows the skin's preview animations along with the preview buttons displaying its animations.
---@return nil
function SkinNotes:preview_selection_byclick()
     local function previewSelectionButtonClick(index, direct, value)
          local previewSkinButton = 'previewSkinButton'..direct:upperAtStart()

          local byPreviewButtonClick   = clickObject(previewSkinButton, 'camHUD')
          local byPreviewButtonRelease = mouseReleased('left')
          if byPreviewButtonClick == true and self.previewAnimationObjectClicked[index] == false then
               playAnim(previewSkinButton, 'hovered-pressed', true)
               self.previewAnimationObjectClicked[index] = true
          end
          if byPreviewButtonRelease == true and self.previewAnimationObjectClicked[index] == true then
               playAnim(previewSkinButton, 'static', true)
               playSound('ding', 0.5)

               self.previewAnimationObjectIndex          = self.previewAnimationObjectIndex + value
               self.previewAnimationObjectClicked[index] = false
               self:preview_animation(true)
          end
     end

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
     if previewAnimationMinIndex == true then
          previewSelectionButtonClick(1, 'left', -1)
     end
     if previewAnimationMaxIndex == true then
          previewSelectionButtonClick(2, 'right', 1)
     end
end

--- Main hovering functionality when interacting any preview buttons when selecting any.
--- Allows the preview buttons to have a hover animation.
---@return nil
function SkinNotes:preview_selection_byhover()
     local function previewSelectionButtonHover(index, direct, value)
          local previewSkinButton = 'previewSkinButton'..direct:upperAtStart()
          if self.previewAnimationObjectClicked[index] == true then
               return
          end

          if hoverObject(previewSkinButton, 'camHUD') == true then
               self.previewAnimationObjectHovered[index] = true
          end
          if hoverObject(previewSkinButton, 'camHUD') == false then
               self.previewAnimationObjectHovered[index] = false
          end

          if self.previewAnimationObjectHovered[index] == true then
               playAnim(previewSkinButton, 'hovered-static', true)
          end
          if self.previewAnimationObjectHovered[index] == false then
               playAnim(previewSkinButton, 'static', true)
          end
     end

     local previewAnimationMinIndex = self.previewAnimationObjectIndex > 1
     local previewAnimationMaxIndex = self.previewAnimationObjectIndex < #self.previewAnimationObjectPrevAnims
     if previewAnimationMinIndex == true then
          previewSelectionButtonHover(1, 'left')
     else
          playAnim('previewSkinButtonLeft', 'hovered-blocked', true)
          self.previewAnimationObjectHovered[1] = false
     end
     if previewAnimationMaxIndex == true then
          previewSelectionButtonHover(2, 'right')
     else
          playAnim('previewSkinButtonRight', 'hovered-blocked', true)
          self.previewAnimationObjectHovered[2] = false
     end
end

--- Main cursor functionality when interacting any preview buttons when selecting any.
--- Changes the cursor's texture depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotes:preview_selection_bycursor()
     for previewObjects = 1, 2 do
          if self.previewAnimationObjectClicked[previewObjects] == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if self.previewAnimationObjectHovered[previewObjects] == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
     end

     local conditionHoverLeft  = hoverObject('previewSkinButtonLeft', 'camHUD')
     local conditionHoverRight = hoverObject('previewSkinButtonRight', 'camHUD')
     if conditionHoverLeft or conditionHoverRight then
          if mouseClicked('left') or mousePressed('left') then 
               playAnim('mouseTexture', 'disabledClick', true)
          else
               playAnim('mouseTexture', 'disabled', true)
          end

          if mouseClicked('left') then 
               playSound('cancel') 
          end
     end
end

--- Checkbox functionality, selecting certain skins for the player or opponent.
---@return nil
function SkinNotes:checkbox()
     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          local checkboxObjectTypes   = self.checkboxSkinObjectType[checkboxIndex]
          local checkboxObjectTypeTag = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()

          local checkboxSkinIndex      = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]
          local checkboxSkinCurrent    = checkboxSkinIndex == self.selectSkinCurSelectedIndex
          local checkboxSkinNonCurrent = checkboxSkinIndex ~= self.selectSkinCurSelectedIndex

          local selectionSkinButton = 'selectionSkinButton'..checkboxObjectTypeTag
          local selectionSkinButtonAnimFinish = getProperty(selectionSkinButton..'.animation.finished')
          local selectionSkinButtonAnimName   = getProperty(selectionSkinButton..'.animation.curAnim.name')
          if checkboxSkinCurrent == true and selectionSkinButtonAnimFinish == true then
               playAnim(selectionSkinButton, 'check')
               self.checkboxSkinObjectToggle[checkboxObjectTypes:lower()] = true
          end
          if checkboxSkinNonCurrent == true and selectionSkinButtonAnimFinish == true then
               playAnim(selectionSkinButton, 'uncheck')
               self.checkboxSkinObjectToggle[checkboxObjectTypes:lower()] = false
          end
     end
end

--- Syncs the display highlights for visual purposes.
---@return nil
function SkinNotes:checkbox_sync()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local skinObjectsPerIDs = self.totalSkinObjectID[self.selectSkinPagePositionIndex]
     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          local checkboxObjectTypes      = self.checkboxSkinObjectType[checkboxIndex]
          local checkboxObjectTypeTag    = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()
          local checkboxSkinIndex        = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]
          local checkboxSkinIndexPresent = table.find(skinObjectsPerIDs, checkboxSkinIndex)

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = checkboxSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if checkboxSkinIndex == self.selectSkinCurSelectedIndex or checkboxSkinIndex == checkboxSkinIndexPresent or luaSpriteExists(displaySkinIconButton) == true then
               local displaySelectionHighlightX = ('displaySelection${select}.x'):interpol({select = checkboxObjectTypeTag})
               local displaySelectionHighlightY = ('displaySelection${select}.y'):interpol({select = checkboxObjectTypeTag})
               setProperty(displaySelectionHighlightX, getProperty(displaySkinIconButton..'.x'))
               setProperty(displaySelectionHighlightY, getProperty(displaySkinIconButton..'.y'))
          end

          if checkboxSkinIndex == 0 or luaSpriteExists(displaySkinIconButton) == false then
               removeLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
          else
               addLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
          end
     end
end

--- Collection of similair methods of the checkbox selection functions.
---@return nil
function SkinNotes:checkbox_selection()
     self:checkbox_selection_byclick()
     self:checkbox_selection_byhover()
     self:checkbox_selection_bycursor()
end

--- Main click functionality when interacting any checkbox buttons when selecting one.
--- Allows to select the skin to either the player or opponent along side displaying its animations.
---@return nil
function SkinNotes:checkbox_selection_byclick()
     local function checkboxSelectionButtonClick(index, skin)
          local selectionSkinButton = 'selectionSkinButton'..skin:upperAtStart()
          local selectionSkinButtonClick    = clickObject(selectionSkinButton, 'camHUD')
          local selectionSkinButtonReleased = mouseReleased('left')
          if selectionSkinButtonClick == true and self.checkboxSkinObjectClicked[index] == false then
               self.checkboxSkinObjectClicked[index] = true
          end
          if selectionSkinButtonReleased == true and self.checkboxSkinObjectClicked[index] == true then
               playSound('remote_click')

               self.checkboxSkinObjectToggle[skin:lower()] = not self.checkboxSkinObjectToggle[skin:lower()]
               self.checkboxSkinObjectClicked[index]       = false
          end

          if self.checkboxSkinObjectToggle[skin:lower()] == false and self.checkboxSkinObjectClicked[index] == true then
               self.checkboxSkinObjectIndex[skin:lower()] = self.selectSkinCurSelectedIndex
               playAnim(selectionSkinButton, 'checking')
          end
          if self.checkboxSkinObjectToggle[skin:lower()] == true and self.checkboxSkinObjectClicked[index] == true then
               self.checkboxSkinObjectIndex[skin:lower()] = 0
               playAnim(selectionSkinButton, 'unchecking')
          end

          local selectionSkinButtonAnimFinish = getProperty(selectionSkinButton..'.animation.finished')
          local selectionSkinButtonAnimName   = getProperty(selectionSkinButton..'.animation.curAnim.name')
          if selectionSkinButtonAnimName == 'unchecking' and selectionSkinButtonAnimFinish == true then
               playAnim(selectionSkinButton, 'uncheck')
               return
          end
          if selectionSkinButtonAnimName == 'checking' and selectionSkinButtonAnimFinish == true then
               playAnim(selectionSkinButton, 'check')
               return
          end
     end

     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          checkboxSelectionButtonClick(checkboxIndex, tostring(self.checkboxSkinObjectType[checkboxIndex]))
     end
end

--- Main hovering functionality when interacting any checkbox buttons when selecting any.
--- Allows the support of the cursor's sprite changing when hovering any checkbox buttons.
---@return nil
function SkinNotes:checkbox_selection_byhover()
     local function checkboxSelectionButtonHover(index, skin)
          local selectionSkinButton = 'selectionSkinButton'..skin:upperAtStart()
          if self.checkboxSkinObjectClicked[index] == true then
               return
          end

          if hoverObject(selectionSkinButton, 'camHUD') == true then
               self.checkboxSkinObjectHovered[index] = true
          end
          if hoverObject(selectionSkinButton, 'camHUD') == false then
               self.checkboxSkinObjectHovered[index] = false
          end
     end

     for checkboxIndex = 1, #self.checkboxSkinObjectType do
          checkboxSelectionButtonHover(checkboxIndex, tostring(self.checkboxSkinObjectType[checkboxIndex]))
     end
end

--- Main cursor functionality when interacting any checkbox buttons when selecting any.
--- Changes the cursor's texture depending on its interaction (i.e. selecting and hovering).
---@return nil
function SkinNotes:checkbox_selection_bycursor()
     for checkboxObjects = 1, 2 do
          if self.checkboxSkinObjectClicked[checkboxObjects] == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if self.checkboxSkinObjectHovered[checkboxObjects] == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
     end
end

--- Collection of similair methods of the search functions.
---@return nil
function SkinNotes:search()
     self:search_create()
     self:search_skins()
     self:search_selection()
     self:search_checkbox_sync()
end

--- Creates a 16 chunk display of the selected search skins.
---@return nil
function SkinNotes:search_create()
     local justReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     if not (justReleased ~= -1 and justReleased ~= nil and getVar('skinSearchInputFocus') == true) then
          return
     end

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent')
     if skinSearchInput_textContent == '' and getVar('skinSearchInputFocus') == true then
          self:create(self.selectSkinPagePositionIndex)
          self:page_text()
          self:save_selection()
          return
     end

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

     --- Searches the closest skin name it can possibly find
     ---@param list table[string] The given list of skins for the algorithm to do its work.
     ---@param input string The given input to search the closest skins.
     ---@param element string What element it can return either its 'id' or 'skins'.
     ---@param match string The prefix of the skin to match.
     ---@param allowPath? boolean Wheather it will include a path or not.
     ---@return table
     local function filter_search(list, input, element, match, allowPath)
          local search_result = {}
          for i = 1, #list, 1 do
               local startName   = list[i]:match(match..'(.+)')  == nil and 'funkin' or list[i]:match(match..'(.+)')
               local startFolder = list[i]:match('(.+/)'..match) == nil and ''       or list[i]:match('(.+/)'..match)

               local startPos = startName:upper():find(input:upper())
               local wordPos  = startPos == nil and -1 or startPos
               if wordPos > -1 and #search_result < 16 then
                    local p = allowPath == true and startFolder..match:gsub('%%%-', '-')..startName or startName
                    search_result[i] = p:match(match..'funkin') == nil and p or match:gsub('%%%-', '')
               end
          end

          local search_resultFilter = {}
          for ids, skins in pairs(search_result) do
               if skins ~= nil and #search_resultFilter < 16 then
                    if element == 'skins' then
                         search_resultFilter[#search_resultFilter + 1] = skins
                    elseif element == 'ids' then
                         search_resultFilter[#search_resultFilter + 1] = ids
                    end
               end
          end 
          return search_resultFilter
     end

     local function displaySkinPositions()
          local displaySkinIndexes   = {x = 0, y = 0}
          local displaySkinPositions = {}
          for displays = 1, 16 do
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

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent')
     local filterSearchByID   = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'ids', self.statePrefix..'%-', false)
     local filterSearchByName = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'skins', self.statePrefix..'%-', false)
     local filterSearchBySkin = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'skins', self.statePrefix..'%-', true)

     local currenMinPage = (self.selectSkinPagePositionIndex - 1) * 16
     local currenMinPageIndex = currenMinPage == 0 and 1 or currenMinPage
     local currenMaxPageIndex = self.selectSkinPagePositionIndex * 16

     local searchFilterSkinsDefault = table.tally(currenMinPageIndex, currenMaxPageIndex)
     local searchFilterSkinsTyped   = table.singularity(table.merge(filterSearchByID, searchFilterSkinsDefault), false)

     local searchFilterSkinsSubDefault = table.sub(searchFilterSkinsDefault, 1, 16)
     local searchFilterSkinsSubTyped   = table.sub(searchFilterSkinsTyped, 1, 16)
     local searchFilterSkins = #filterSearchByID == 0 and searchFilterSkinsSubDefault or searchFilterSkinsSubTyped
     for ids, displays in pairs(searchFilterSkins) do
          if #filterSearchByID    == 0 then return end -- !DO NOT DELETE
          if #filterSearchByName < ids then return end -- !DO NOT DELETE

          local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = displays}
          local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
          local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)

          local displaySkinPositionX = displaySkinPositions()[ids][1]
          local displaySkinPositionY = displaySkinPositions()[ids][2]
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

          local displaySkinMetadataJSON = self.totalMetadataOrderedDisplay[tonumber(displays)]
          local displaySkinMetadata_frames   = displaySkinMetadataJSON == '@void' and 24           or (displaySkinMetadataJSON.frames   or 24)
          local displaySkinMetadata_prefixes = displaySkinMetadataJSON == '@void' and 'arrowUP'    or (displaySkinMetadataJSON.prefixes or 'arrowUP')
          local displaySkinMetadata_size     = displaySkinMetadataJSON == '@void' and {0.55, 0.55} or (displaySkinMetadataJSON.size     or {0.55, 0.55})
          local displaySkinMetadata_offsets  = displaySkinMetadataJSON == '@void' and {0, 0}       or (displaySkinMetadataJSON.offsets  or {0, 0})

          local displaySkinImageTemplate = {path = self.statePaths, skin = filterSearchBySkin[ids]}
          local displaySkinImage         = ('${path}/${skin}'):interpol(displaySkinImageTemplate)

          local displaySkinImagePositionX = displaySkinPositionX + 16.5
          local displaySkinImagePositionY = displaySkinPositionY + 12
          makeAnimatedLuaSprite(displaySkinIconSkin, displaySkinImage, displaySkinImagePositionX, displaySkinImagePositionY)
          scaleObject(displaySkinIconSkin, displaySkinMetadata_size[1], displaySkinMetadata_size[2])
          addAnimationByPrefix(displaySkinIconSkin, 'static', displaySkinMetadata_prefixes, displaySkinMetadata_frames, true)

          local curOffsetX = getProperty(displaySkinIconSkin..'.offset.x')
          local curOffsetY = getProperty(displaySkinIconSkin..'.offset.y')
          addOffset(displaySkinIconSkin, 'static', curOffsetX - displaySkinMetadata_offsets[1], curOffsetY + displaySkinMetadata_offsets[2])
          playAnim(displaySkinIconSkin, 'static')
          setObjectCamera(displaySkinIconSkin, 'camHUD')
          addLuaSprite(displaySkinIconSkin)

          if ids > #filterSearchBySkin then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
          end

          if #filterSearchBySkin == 0 then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    return
               end
               
               for _ in pairs(searchFilterSkins) do -- lmao
                    local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = displays}
                    local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
                    local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)

                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
               if ids == 16 then 
                    return 
               end
          end
          self:save_selection()
     end
end

--- Calculates and loads the nearest total amount of searched skins.
---@return nil
function SkinNotes:search_skins()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent <= 0 then
          return
     end

     local justReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     if not (justReleased ~= -1 and justReleased ~= nil and getVar('skinSearchInputFocus') == true) then
          return
     end

     --- Searches the closest skin name it can possibly find
     ---@param list table[string] The given list of skins for the algorithm to do its work.
     ---@param input string The given input to search the closest skins.
     ---@param element string What element it can return either its 'id' or 'skins'.
     ---@param match string The prefix of the skin to match.
     ---@param allowPath? boolean Wheather it will include a path or not.
     ---@return table
     local function filter_search(list, input, element, match, allowPath)
          local search_result = {}
          for i = 1, #list, 1 do
               local startName   = list[i]:match(match..'(.+)')   == nil and 'funkin' or list[i]:match(match..'(.+)')
               local startFolder = list[i]:match('(%w+/)'..match) == nil and ''       or list[i]:match('(%w+/)'..match)

               local startPos = startName:upper():find(input:upper())
               local wordPos  = startPos == nil and -1 or startPos
               if wordPos > -1 and #search_result < 16 then
                    local p = allowPath == true and startFolder..match:gsub('%%%-', '-')..startName or startName
                    search_result[i] = p:match(match..'funkin') == nil and p or match:gsub('%%%-', '')
               end
          end

          local search_resultFilter = {}
          for ids, skins in pairs(search_result) do
               if skins ~= nil and #search_resultFilter < 16 then
                    if element == 'skins' then
                         search_resultFilter[#search_resultFilter + 1] = skins
                    elseif element == 'ids' then
                         search_resultFilter[#search_resultFilter + 1] = ids
                    end
               end
          end 
          return search_resultFilter
     end

     local skinSearchInput_textContent   = getVar('skinSearchInput_textContent')
     local skinSearchInput_textContentID = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'ids', self.statePrefix..'%-', false)

     local searchSkinIndex = 0
     for searchPage = 1, #self.totalSkinObjectID do
          local totalSkinObjectIDs     = self.totalSkinObjectID[searchPage]
          local totalSkinObjectPresent = table.singularity(table.merge(totalSkinObjectIDs, skinSearchInput_textContentID), true)

          for pageSkins = 1, #totalSkinObjectPresent do
               if #totalSkinObjectPresent == 0 then 
                    return 
               end

               searchSkinIndex = searchSkinIndex + 1
               self.searchSkinObjectIndex[searchSkinIndex] = totalSkinObjectPresent[pageSkins]
               self.searchSkinObjectPage[searchSkinIndex]  = searchPage
          end
     end
end

--- Creates and loads the selected search skin's preview strums.
---@return nil
function SkinNotes:search_preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     local curIndex = self.selectSkinCurSelectedIndex
     local function previewSearchSkinIndex()
          for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
               local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )

               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
               if releasedObject(displaySkinIconButton, 'camHUD') then
                    return searchSkinIndex
               end
          end
     end

     local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = previewSearchSkinIndex()}
     local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
     if releasedObject(displaySkinIconButton, 'camHUD') then
          local function getCurrentPreviewSkin(previewSkinArray)
               if curIndex == 0 then
                    return previewSkinArray[1][1]
               end

               for pages = 1, self.totalSkinLimit do
                    local presentObjectIndex = table.find(self.totalSkinObjectIndexes[pages], curIndex)
                    if presentObjectIndex ~= nil then
                         return previewSkinArray[pages][presentObjectIndex]
                    end
               end
          end
     
          local getCurrentPreviewSkinObjects       = getCurrentPreviewSkin(self.totalSkinObjects)
          local getCurrentPreviewSkinObjectNames   = getCurrentPreviewSkin(self.totalSkinObjectNames)
          local getCurrentPreviewSkinObjectPreview = getCurrentPreviewSkin(self.totalMetadataObjectPreview)
          for strums = 1, 4 do
               local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
               local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)
     
               local previewMetadataObjectData = function(skinAnim)
                    local previewMetadataObjecNames = getCurrentPreviewSkinObjectPreview['names'][skinAnim][strums]
                    return getCurrentPreviewSkinObjectPreview['animations'][skinAnim][previewMetadataObjecNames]
               end
               local previewMetadataObjectNames = function(skinAnim)
                    return getCurrentPreviewSkinObjectPreview['names'][skinAnim]
               end
     
               local previewMetadataConfirmObject = previewMetadataObjectData('confirm')
               local previewMetadataPressedObject = previewMetadataObjectData('pressed')
               local previewMetadataColoredObject = previewMetadataObjectData('colored')
               local previewMetadataStrumsObject  = previewMetadataObjectData('strums')
     
               local previewSkinImagePath = self.statePaths..'/'..getCurrentPreviewSkinObjects
               local previewSkinPositionX = 790 + (105*(strums-1))
               local previewSkinPositionY = 135
               makeAnimatedLuaSprite(previewSkinGroup, previewSkinImagePath, previewSkinPositionX, previewSkinPositionY)
               scaleObject(previewSkinGroup, 0.65, 0.65)
               addAnimationByPrefix(previewSkinGroup, previewMetadataConfirmObject.name, previewMetadataConfirmObject.prefix, 24, false)
               addAnimationByPrefix(previewSkinGroup, previewMetadataPressedObject.name, previewMetadataPressedObject.prefix, 24, false)
               addAnimationByPrefix(previewSkinGroup, previewMetadataColoredObject.name, previewMetadataColoredObject.prefix, 24, false)
               addAnimationByPrefix(previewSkinGroup, previewMetadataStrumsObject.name,  previewMetadataStrumsObject.prefix, 24, false)
     
               local curOffsets = function(previewMetadataObject, positionType)
                    local curOffsetX = getProperty(previewSkinGroup..'.offset.x')
                    local curOffsetY = getProperty(previewSkinGroup..'.offset.y')
                    if positionType == 'x' then
                         return curOffsetX - previewMetadataObject.offsets[1]
                    end
                    if positionType == 'y' then
                         return curOffsetY + previewMetadataObject.offsets[2]
                    end
               end
               local addOffsets = function(previewSkinGroup, previewMetadataObject)
                    local curOffsetX = curOffsets(previewMetadataObject, 'x')
                    local curOffsetY = curOffsets(previewMetadataObject, 'y')
                    addOffset(previewSkinGroup, previewMetadataObject.name, curOffsetX, curOffsetY)
               end
     
               addOffsets(previewSkinGroup, previewMetadataConfirmObject)
               addOffsets(previewSkinGroup, previewMetadataPressedObject)
               addOffsets(previewSkinGroup, previewMetadataColoredObject)
               addOffsets(previewSkinGroup, previewMetadataStrumsObject)
               playAnim(previewSkinGroup, previewMetadataObjectNames('strums')[strums])
               setObjectCamera(previewSkinGroup, 'camHUD')
               addLuaSprite(previewSkinGroup, true)
          end
     
          setTextString('genInfoSkinName', getCurrentPreviewSkinObjectNames)
     end
     self:preview_animation(true)
end

--- Syncs the display highlights when searching for skins, obviously for visual purposes.
---@return nil
function SkinNotes:search_checkbox_sync()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs = self.totalSkinObjectID[searchSkinPage]
          for checkboxIndex = 1, #self.checkboxSkinObjectType do
               local checkboxObjectTypes      = self.checkboxSkinObjectType[checkboxIndex]
               local checkboxObjectTypeTag    = self.checkboxSkinObjectType[checkboxIndex]:upperAtStart()
               local checkboxSkinIndex        = self.checkboxSkinObjectIndex[checkboxObjectTypes:lower()]
               local checkboxSkinIndexPresent = table.find(skinObjectsPerIDs, checkboxSkinIndex)
     
               local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = checkboxSkinIndex}
               local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
               if checkboxSkinIndex == self.selectSkinCurSelectedIndex or checkboxSkinIndex == checkboxSkinIndexPresent or luaSpriteExists(displaySkinIconButton) == true then
                    local displaySelectionHighlightX = ('displaySelection${select}.x'):interpol({select = checkboxObjectTypeTag})
                    local displaySelectionHighlightY = ('displaySelection${select}.y'):interpol({select = checkboxObjectTypeTag})
                    setProperty(displaySelectionHighlightX, getProperty(displaySkinIconButton..'.x'))
                    setProperty(displaySelectionHighlightY, getProperty(displaySkinIconButton..'.y'))
               end

               if checkboxSkinIndex == 0 or luaSpriteExists(displaySkinIconButton) == false then
                    removeLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               else
                    addLuaSprite('displaySelection'..checkboxObjectTypeTag, false)
               end
          end
     end
end

--- Collection of similair methods of the search selection functions.
---@return nil
function SkinNotes:search_selection()
     self:search_selection_byclick()
     self:search_selection_byhover()
     self:search_selection_cursor()
end

--- Main click functionality when interacting any searched skins when selecting one.
--- Allows the selection of the searched skins alongs with its display skin button animations.
---@return nil
function SkinNotes:search_selection_byclick()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.totalSkinObjectID[searchSkinPage]
          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]
          local skinObjectsPerSelected = self.totalSkinObjectSelected[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          local displaySkinIconSkin     = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplate)
          local function displaySkinSelect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == searchSkinIndex

               if byClick == true and skinObjectsPerClicked[searchSkinPresentIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[searchSkinPresentIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[searchSkinPresentIndex] == true then
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    self.selectSkinInitSelectedIndex = self.selectSkinCurSelectedIndex
                    self.selectSkinCurSelectedIndex  = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex
                    self.selectSkinHasBeenClicked    = false
                    
                    self:search_preview()
                    skinObjectsPerSelected[searchSkinPresentIndex] = true
                    skinObjectsPerClicked[searchSkinPresentIndex]  = false
               end
          end
          local function displaySkinDeselect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == searchSkinIndex
               if byClick == true and skinObjectsPerClicked[searchSkinPresentIndex] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = skinObjectsPerIDs[searchSkinPresentIndex]
                    self.selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[searchSkinPresentIndex] = true
               end

               if byRelease == true and skinObjectsPerClicked[searchSkinPresentIndex] == true then
                    playAnim(displaySkinIconButton, 'static', true)

                    self.selectSkinCurSelectedIndex = 0
                    self.selectSkinPreSelectedIndex = 0
                    self.selectSkinHasBeenClicked   = false

                    self:search_preview()
                    skinObjectsPerSelected[searchSkinPresentIndex] = false
                    skinObjectsPerClicked[searchSkinPresentIndex]  = false
                    skinObjectsPerHovered[searchSkinPresentIndex]  = false
               end
          end

          if skinObjectsPerSelected[searchSkinPresentIndex] == false or searchSkinIndex ~= self.selectSkinCurSelectedIndex then
               displaySkinSelect()
          end
          if skinObjectsPerSelected[searchSkinPresentIndex] == true then
               --displaySkinDeselect()
          end

          if searchSkinIndex == self.selectSkinInitSelectedIndex then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    playAnim(displaySkinIconButton, 'static', true)
               end

               self.selectSkinInitSelectedIndex = 0
               skinObjectsPerSelected[searchSkinPresentIndex]  = false
          end
     end
end

--- Main hovering functionality when interacting any searched skins when selecting any.
--- Allows the display button to have a hover animation.
---@return nil
function SkinNotes:search_selection_byhover()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.totalSkinObjectID[searchSkinPage]
          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]
          local skinObjectsPerSelected = self.totalSkinObjectSelected[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               skinObjectsPerHovered[searchSkinPresentIndex] = true
          end
          if hoverObject(displaySkinIconButton, 'camHUD') == false then
               skinObjectsPerHovered[searchSkinPresentIndex] = false
          end

          local nonCurrentPreSelectedSkin = self.selectSkinPreSelectedIndex ~= searchSkinIndex
          local nonCurrentCurSelectedSkin = self.selectSkinCurSelectedIndex ~= searchSkinIndex
          if skinObjectsPerHovered[searchSkinPresentIndex] == true and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'hover', true)
          end
          if skinObjectsPerHovered[searchSkinPresentIndex] == false and nonCurrentPreSelectedSkin and nonCurrentCurSelectedSkin then
               if luaSpriteExists(displaySkinIconButton) == false then return end
               playAnim(displaySkinIconButton, 'static', true)
          end
     end
end

--- Main cursor functionality when interacting any searched skins when selecting any.
--- Changes the cursor's texture depending on it interaction (i.e. selecting and hovering).
---@return nil
function SkinNotes:search_selection_cursor()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )
          local searchSkinPresentIndex = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton:gsub('%d+', tostring(self.selectSkinCurSelectedIndex)), 'camHUD') == true then
               goto skipSelectedSearchSkin -- disabled deselecting
          end

          if skinObjectsPerClicked[searchSkinPresentIndex] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if skinObjectsPerHovered[searchSkinPresentIndex] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
          ::skipSelectedSearchSkin::
     end
     
     if hoverObject('displaySliderIcon', 'camHUD') == true and self.totalSkinLimit == 1 then
          if mouseClicked('left') or mousePressed('left') then 
               playAnim('mouseTexture', 'disabledClick', true)
          else
               playAnim('mouseTexture', 'disabled', true)
          end

          if mouseClicked('left') then 
               playSound('cancel') 
          end
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end
end

--- Loads the save data from the current class state.
---@return nil
function SkinNotes:save_load()
     self:create(self.selectSkinPagePositionIndex)
     self:checkbox_sync()

     if math.isReal(self.sliderTrackIntervals[self.selectSkinPagePositionIndex]) == true then
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
     end
end

--- Loads and syncs the saved selected skin.
---@return nil
function SkinNotes:save_selection()
     if self.selectSkinPreSelectedIndex == 0 then
          return
     end

     local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = self.selectSkinPreSelectedIndex}
     local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
     if luaSpriteExists(displaySkinIconButton) == true then
          playAnim(displaySkinIconButton, 'selected', true)
     end
end

return SkinNotes