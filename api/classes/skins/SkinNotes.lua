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

     self.totalSkinLimit       = states.getTotalSkinLimit(self.stateClass)
     self.totalSkinObjects     = states.getTotalSkinObjects(self.stateClass)
     self.totalSkinObjectID    = states.getTotalSkinObjects(self.stateClass, 'ids')
     self.totalSkinObjectNames = states.getTotalSkinObjects(self.stateClass, 'names')
     
     self.totalSkinObjectHovered  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.totalSkinObjectClicked  = states.getTotalSkinObjects(self.stateClass, 'bools')
     self.totalSkinObjectSelected = states.getTotalSkinObjects(self.stateClass, 'bools')

     self.totalMetadataObjectDisplay  = states.getMetadataObjectSkins(self.stateClass, 'display', true)
     self.totalMetadataObjectPreview  = states.getMetadataObjectSkins(self.stateClass, 'preview', true)
     self.totalMetadataObjectSkins    = states.getMetadataObjectSkins(self.stateClass, 'skins', true)

     self.totalMetadataOrderedDisplay = states.getMetadataSkinsOrdered(self.stateClass, 'display', true)
     self.totalMetadataOrderedPreview = states.getMetadataSkinsOrdered(self.stateClass, 'preview', true)
     self.totalMetadataOrderedSkins   = states.getMetadataSkinsOrdered(self.stateClass, 'skins', true)

     self.sliderPageIndex          = 1
     self.sliderTrackPageIndex     = 1
     self.sliderTrackPressed       = false
     self.sliderTrackToggle        = false
     self.sliderTrackIntervals     = states.getPageSkinSliderPositions(self.stateClass).intervals
     self.sliderTrackSemiIntervals = states.getPageSkinSliderPositions(self.stateClass).semiIntervals
     
     self.selectSkinPagePositionIndex = 1     -- lordx
     self.selectSkinInitSelectedIndex = 0     -- d2011x
     self.selectSkinPreSelectedIndex  = 0     -- xeno
     self.selectSkinCurSelectedIndex  = 0     -- s2017x
     self.selectSkinHasBeenClicked    = false -- sunky

     self.searchSkinObjectIndex = table.new(16, 0)
     self.searchSkinObjectPage  = table.new(16, 0)

     self:preload()
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
     self:selection_sync()
end

--- Preloads multiple existing chunks by creating and deleting, improves optimization significantly.
---@return nil
function SkinNotes:preload()
     for pages = self.totalSkinLimit, 1, -1 do
          if pages ~= self.selectSkinPagePositionIndex then
               break
          end
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
                    self.sliderPageIndex = sliderTrackCurrentPageIndex

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

--- Creates the sliders interval marks for visual aid purposes.
---@return nil
function SkinNotes:page_sliderMarks()
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

--- Alternative functionlity of the slider for switching pages.
---@return nil
function SkinNotes:page_moved()
     if self.sliderTrackThumbPressed == true then return end
     local conditionPressedDown = keyboardJustConditionPressed('E', getVar('skinSearchInputFocus') == false)
     local conditionPressedUp   = keyboardJustConditionPressed('Q', getVar('skinSearchInputFocus') == false)

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

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
          callOnScripts('skinSearchInput_callResetSearch')
     end
     if conditionPressedDown and self.sliderPageIndex < self.totalSkinLimit then
          self.sliderPageIndex = self.sliderPageIndex + 1
          self.selectSkinPagePositionIndex = self.selectSkinPagePositionIndex + 1
          self:create(self.sliderPageIndex)

          playSound('ding', 0.5)
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.sliderPageIndex])
          callOnScripts('skinSearchInput_callResetSearch')
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

--- Selection functionality; group similair functions of 'selection'.
---@return nil
function SkinNotes:selection()
     self:selection_byclick()
     self:selection_byhover()
     self:selection_cursor()
end

--- Selects the selected skin, focuses on the click functionality.
---@return nil
function SkinNotes:selection_byclick()
     local skinObjectsPerIDs      = self.totalSkinObjectID[self.sliderPageIndex]
     local skinObjectsPerHovered  = self.totalSkinObjectHovered[self.sliderPageIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.sliderPageIndex]
     local skinObjectsPerSelected = self.totalSkinObjectSelected[self.sliderPageIndex]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (self.sliderPageIndex - 1))

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
                    self.selectSkinPagePositionIndex = self.sliderPageIndex
                    self.selectSkinHasBeenClicked    = false
                    
                    self:preview()
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
                    skinObjectsPerSelected[curPage] = false
                    skinObjectsPerClicked[curPage]  = false
                    skinObjectsPerHovered[curPage]  = false
               end
          end

          if skinObjectsPerSelected[curPage] == false then
               displaySkinSelect()
          end
          if skinObjectsPerSelected[curPage] == true then
               displaySkinDeselect()
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

--- Selects the selected skin, focuses on the hovering functionality.
---@return nil
function SkinNotes:selection_byhover()
     local skinObjectsPerIDs      = self.totalSkinObjectID[self.sliderPageIndex]
     local skinObjectsPerHovered  = self.totalSkinObjectHovered[self.sliderPageIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.sliderPageIndex]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (self.sliderPageIndex - 1))

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

--- Cursor behavior when selecting certain skins.
---@return nil
function SkinNotes:selection_cursor()
     local skinObjectsPerHovered  = self.totalSkinObjectHovered[self.sliderPageIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.sliderPageIndex]

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     for pageSkins = 1, math.max(#skinObjectsPerClicked, #skinObjectsPerHovered) do
          if skinObjectsPerClicked[pageSkins] == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if skinObjectsPerHovered[pageSkins] == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
     end

     if hoverObject('displaySliderIcon', 'camHUD') == true and self.totalSkinLimit == 1 then
          if mouseClicked('left') or mousePressed('left') then 
               playAnim('mouseTexture', 'disabledClick', true)
          else
               playAnim('mouseTexture', 'disabled', true)
          end

          if mouseClicked('left') then playSound('cancel') end
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end
end

--- Syncs the saved selection of the certain skin.
---@return nil
function SkinNotes:selection_sync()
     if self.selectSkinPreSelectedIndex ~= 0 then
          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = self.selectSkinPreSelectedIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)

          if luaSpriteExists(displaySkinIconButton) == true then
               playAnim(displaySkinIconButton, 'selected', true)
          end
     end
end

--- Search functionality; group similair functions of 'search'.
---@return nil
function SkinNotes:search()
     self:search_create()
     self:search_skins()
     self:search_byclick()
     self:search_byhover()
     self:search_cursor()
     self:search_preview()
end

--- Creates a chunk to display the selected skins when searching.
---@return nil
function SkinNotes:search_create()
     local justReleased = callMethodFromClass('flixel.FlxG', 'keys.firstJustReleased', {''})
     if not (justReleased ~= -1 and justReleased ~= nil and getVar('skinSearchInputFocus') == true) then
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
               local startName   = list[i]:match(match..'(.+)')   == nil and 'funkin' or list[i]:match(match..'(.+)')
               local startFolder = list[i]:match('(.+/)'..match) == nil and ''        or list[i]:match('(.+/)'..match)

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

     local currenMinPageIndex = (self.sliderPageIndex - 1) * 16 == 0 and 1 or (self.sliderPageIndex - 1) * 16
     local currenMaxPageIndex =  self.sliderPageIndex      * 16

     local searchFilterSkinsDefault = table.tally(currenMinPageIndex, currenMaxPageIndex)
     local searchFilterSkinsTyped   = table.singularity(table.merge(filterSearchByID, searchFilterSkinsDefault), false)
     local searchFilterSkins        = #filterSearchByID == 0 and table.sub(searchFilterSkinsDefault, 1, 16) or table.sub(searchFilterSkinsTyped, 1, 16)

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

          if ids > #filterSearchBySkin then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    removeLuaSprite(displaySkinIconButton, true)
                    removeLuaSprite(displaySkinIconSkin, true)
               end
          end

          if #filterSearchBySkin == 0 then
               if luaSpriteExists(displaySkinIconButton) == false and luaSpriteExists(displaySkinIconSkin) == false then
                    for _ in pairs(searchFilterSkins) do -- lmao
                         local displaySkinIconTemplates = {state = (self.stateClass):upperAtStart(), ID = displays}
                         local displaySkinIconButton = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplates)
                         local displaySkinIconSkin   = ('displaySkinIconSkin${state}-${ID}'):interpol(displaySkinIconTemplates)
     
                         removeLuaSprite(displaySkinIconButton, true)
                         removeLuaSprite(displaySkinIconSkin, true)
                    end
                    if ids == 16 then return end
               end
          end
          self:selection_sync()
     end
end

--- Calculates the total amount skins present when searching
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

     --[[ local isMovedX = getPropertyFromClass('flixel.FlxG', 'mouse.deltaScreenX')
     local isMovedY = getPropertyFromClass('flixel.FlxG', 'mouse.deltaScreenY')
     if isMovedX == 0 and isMovedY == 0 then
          return
     end ]]

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

     local skinSearchInput_textContent = getVar('skinSearchInput_textContent')
     local filterSearchByID = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'ids', self.statePrefix..'%-', false)

     local searchSkinIndex = 0
     for searchPage = 1, #self.totalSkinObjectID do
          local totalSkinObjectIDs     = self.totalSkinObjectID[searchPage]
          local totalSkinObjectPresent = table.singularity(table.merge(totalSkinObjectIDs, filterSearchByID), true)

          for pageSkins = 1, #totalSkinObjectPresent do
               if #totalSkinObjectPresent == 0 then return end
               searchSkinIndex = searchSkinIndex + 1

               local searchIndex = totalSkinObjectPresent[pageSkins]
               self.searchSkinObjectIndex[searchSkinIndex] = searchIndex
               self.searchSkinObjectPage[searchSkinIndex]  = searchPage
          end
     end
end

--- Selects the selected skin, focuses on the click functionality.
--- Only applies when searching for skins.
---@return nil
function SkinNotes:search_byclick()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )

          local curPage = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

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

               if byClick == true and skinObjectsPerClicked[curPage] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = skinObjectsPerIDs[curPage]
                    self.selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[curPage] = true
               end

               if byRelease == true and skinObjectsPerClicked[curPage] == true then
                    playAnim(displaySkinIconButton, 'selected', true)
     
                    self.selectSkinInitSelectedIndex = self.selectSkinCurSelectedIndex
                    self.selectSkinCurSelectedIndex  = skinObjectsPerIDs[curPage]
                    self.selectSkinPagePositionIndex = self.sliderPageIndex
                    self.selectSkinHasBeenClicked    = false
                    
                    self:search_preview()
                    skinObjectsPerSelected[curPage] = true
                    skinObjectsPerClicked[curPage]  = false
               end
          end
          local function displaySkinDeselect()
               local byClick   = clickObject(displaySkinIconButton, 'camHUD')
               local byRelease = mouseReleased('left') and self.selectSkinPreSelectedIndex == searchSkinIndex
               if byClick == true and skinObjectsPerClicked[curPage] == false then
                    playAnim(displaySkinIconButton, 'pressed', true)

                    self.selectSkinPreSelectedIndex = skinObjectsPerIDs[curPage]
                    self.selectSkinHasBeenClicked   = true

                    skinObjectsPerClicked[curPage] = true
               end

               if byRelease == true and skinObjectsPerClicked[curPage] == true then
                    playAnim(displaySkinIconButton, 'static', true)

                    self.selectSkinCurSelectedIndex = 0
                    self.selectSkinPreSelectedIndex = 0
                    self.selectSkinHasBeenClicked   = false

                    self:search_preview()
                    skinObjectsPerSelected[curPage] = false
                    skinObjectsPerClicked[curPage]  = false
                    skinObjectsPerHovered[curPage]  = false
               end
          end

          if skinObjectsPerSelected[curPage] == false then
               displaySkinSelect()
          end
          if skinObjectsPerSelected[curPage] == true then
               displaySkinDeselect()
          end

          if searchSkinIndex == self.selectSkinInitSelectedIndex then
               if luaSpriteExists(displaySkinIconButton) == true and luaSpriteExists(displaySkinIconSkin) == true then
                    playAnim(displaySkinIconButton, 'static', true)
               end

               self.selectSkinInitSelectedIndex = 0
               skinObjectsPerSelected[curPage]  = false
          end
     end
end

--- Selects the selected skin, focuses on the hovering functionality.
--- Only applies when searching for skins.
---@return nil
function SkinNotes:search_byhover()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )

          local curPage = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerIDs      = self.totalSkinObjectID[searchSkinPage]
          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]
          local skinObjectsPerSelected = self.totalSkinObjectSelected[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if hoverObject(displaySkinIconButton, 'camHUD') == true then
               skinObjectsPerHovered[curPage] = true
          end
          if hoverObject(displaySkinIconButton, 'camHUD') == false then
               skinObjectsPerHovered[curPage] = false
          end

          local nonCurrentPreSelectedSkin = self.selectSkinPreSelectedIndex ~= searchSkinIndex
          local nonCurrentCurSelectedSkin = self.selectSkinCurSelectedIndex ~= searchSkinIndex
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

--- Cursor behavior when selecting certain skins.
--- Only applies when searching for skins.
---@return nil
function SkinNotes:search_cursor()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )

          local curPage = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)

          local skinObjectsPerHovered  = self.totalSkinObjectHovered[searchSkinPage]
          local skinObjectsPerClicked  = self.totalSkinObjectClicked[searchSkinPage]

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if skinObjectsPerClicked[curPage] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'handClick', true)
               return
          end
          if skinObjectsPerHovered[curPage] == true and luaSpriteExists(displaySkinIconButton) == true then
               playAnim('mouseTexture', 'hand', true)
               return
          end
     end
     
     if hoverObject('displaySliderIcon', 'camHUD') == true and self.totalSkinLimit == 1 then
          if mouseClicked('left') or mousePressed('left') then 
               playAnim('mouseTexture', 'disabledClick', true)
          else
               playAnim('mouseTexture', 'disabled', true)
          end

          if mouseClicked('left') then playSound('cancel') end
          return
     end

     if mouseClicked('left') or mousePressed('left') then 
          playAnim('mouseTexture', 'idleClick', true)
     else
          playAnim('mouseTexture', 'idle', true)
     end
end

function SkinNotes:search_preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent == 0 then
          return
     end

     for searchIndex = 1, math.max(#self.searchSkinObjectIndex, #self.searchSkinObjectPage) do
          local searchSkinIndex = tonumber( self.searchSkinObjectIndex[searchIndex] )
          local searchSkinPage  = tonumber( self.searchSkinObjectPage[searchIndex]  )

          local curPage   = self.selectSkinCurSelectedIndex
          local curPageID = table.find(self.totalSkinObjectID[searchSkinPage], searchSkinIndex)
          local getCurrentPreviewSkinNames = function()
               local skinNames   = self.totalSkinObjectNames[searchSkinPage]
               return curPage > 0 and skinNames[curPageID]:gsub('_', ' ') or self.totalSkinObjectNames[1][1]
          end
          local getCurrentPreviewSkinObjects = function()
               local skinObjects = self.totalSkinObjects[searchSkinPage]
               return curPage > 0 and skinObjects[curPageID] or self.totalSkinObjects[1][1]
          end

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = searchSkinIndex}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if releasedObject(displaySkinIconButton, 'camHUD') then
               for strums = 1, 4 do
                    local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
                    local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)
          
                    local previewSkinImagePath = self.statePaths..'/'..getCurrentPreviewSkinObjects()
                    local previewSkinPositionX = 790 + (105*(strums-1))
                    local previewSkinPositionY = 135
                    makeAnimatedLuaSprite(previewSkinGroup, previewSkinImagePath, previewSkinPositionX, previewSkinPositionY)
                    scaleObject(previewSkinGroup, 0.65, 0.65)
                    addAnimationByPrefix(previewSkinGroup, 'left', 'arrowLEFT', 24, true)
                    addAnimationByPrefix(previewSkinGroup, 'down', 'arrowDOWN', 24, true)
                    addAnimationByPrefix(previewSkinGroup, 'up', 'arrowUP', 24, true)
                    addAnimationByPrefix(previewSkinGroup, 'right', 'arrowRIGHT', 24, true)
                    playAnim(previewSkinGroup, ({'left', 'down', 'up', 'right'})[strums])
                    setObjectCamera(previewSkinGroup, 'camHUD')
                    addLuaSprite(previewSkinGroup, true)
               end

               setTextString('genInfoSkinName', getCurrentPreviewSkinNames())
          end
     end
end

function SkinNotes:preview()
     local skinSearchInput_textContent = getVar('skinSearchInput_textContent') or ''
     if #skinSearchInput_textContent > 0 then
          return
     end

     local curPage  = self.selectSkinPagePositionIndex
     local curIndex = tonumber(self.selectSkinCurSelectedIndex - (16 * (curPage - 1)))
     local getCurrentPreviewSkinNames = function()
          local skinNames = self.totalSkinObjectNames[curPage]
          return curIndex > 0 and skinNames[curIndex]:gsub('_', ' ') or self.totalSkinObjectNames[1][1]
     end
     local getCurrentPreviewSkinObjects = function()
          local skinObjects = self.totalSkinObjects[curPage]
          return curIndex > 0 and skinObjects[curIndex] or self.totalSkinObjects[1][1]
     end

     local previewMetadataObjectIndex = curIndex > 0 and curIndex or 1
     local previewMetadataObjects     = self.totalMetadataObjectPreview[curPage][previewMetadataObjectIndex]
     for strums = 1, 4 do
          local previewSkinTemplate = {state = (self.stateClass):upperAtStart(), groupID = strums}
          local previewSkinGroup    = ('previewSkinGroup${state}-${groupID}'):interpol(previewSkinTemplate)

          local previewMetadataObjectData = function(skinAnim)
               local previewMetadataObjecNames = previewMetadataObjects['names'][skinAnim][strums]
               return previewMetadataObjects['animations'][skinAnim][previewMetadataObjecNames]
          end
          local previewMetadataObjectNames = function(skinAnim)
               return previewMetadataObjects['names'][skinAnim]
          end

          local previewMetadataConfirmObject = previewMetadataObjectData('confirm')
          local previewMetadataPressedObject = previewMetadataObjectData('pressed')
          local previewMetadataColoredObject = previewMetadataObjectData('colored')
          local previewMetadataStrumsObject  = previewMetadataObjectData('strums')

          local previewSkinImagePath = self.statePaths..'/'..getCurrentPreviewSkinObjects()
          local previewSkinPositionX = 790 + (105*(strums-1))
          local previewSkinPositionY = 135
          makeAnimatedLuaSprite(previewSkinGroup, previewSkinImagePath, previewSkinPositionX, previewSkinPositionY)
          scaleObject(previewSkinGroup, 0.65, 0.65)
          addAnimationByPrefix(previewSkinGroup, previewMetadataConfirmObject.name, previewMetadataConfirmObject.prefix, 24, true)
          addAnimationByPrefix(previewSkinGroup, previewMetadataPressedObject.name, previewMetadataPressedObject.prefix, 24, true)
          addAnimationByPrefix(previewSkinGroup, previewMetadataColoredObject.name, previewMetadataColoredObject.prefix, 24, true)
          addAnimationByPrefix(previewSkinGroup, previewMetadataStrumsObject.name,  previewMetadataStrumsObject.prefix, 24, true)

          local curOffsets = function(previewMetadataObject, positionType)
               local curOffsetX = getProperty(previewSkinGroup..'.offset.x')
               local curOffsetY = getProperty(previewSkinGroup..'.offset.y')
               if positionType == 'y' then
                    return curOffsetX - previewMetadataObject.offsets[1]
               end
               if positionType == 'x' then
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

     setTextString('genInfoSkinName', getCurrentPreviewSkinNames())
end

function SkinNotes:preview_animation()
end

function SkinNotes:switch()

end


--- Loads the save data from the current class state.
---@return nil
function SkinNotes:save_load()
     self:create(self.selectSkinPagePositionIndex)

     if math.isReal(self.sliderTrackIntervals[self.selectSkinPagePositionIndex]) == true then
          setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
     end
end

return SkinNotes