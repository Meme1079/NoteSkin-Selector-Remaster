luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

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

     self.totalSkins     = states.getTotalSkins(self.stateClass, self.statePaths)
     self.totalSkinNames = states.getTotalSkinNames(self.stateClass)

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
function SkinNotes:preload()
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
                    self.sliderPageIndex = sliderTrackCurrentPageIndex
                    self:create(self.sliderPageIndex)

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
     local conditionPressedDown = keyboardJustConditionPressed('E', getVar('skinSearchInputFocus') == false)
     local conditionPressedUp   = keyboardJustConditionPressed('Q', getVar('skinSearchInputFocus') == false)

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

--- Searches the closest skin name it can find
---@return nil
function SkinNotes:search()
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

     local function filter_search(list, input, element, filter)
          local search_result = {}
          for i = 1, #list, 1 do
               local startPos = list[i]:gsub(filter or '', ''):upper():find(input:upper())
               local wordPos  = startPos == nil and -1 or startPos
               if wordPos > -1 and #search_result < 16 then
                    search_result[i] = list[i]:gsub(filter or '', '')
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
     local filterSearchByID     = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'ids', '')
     local filterSearchBySkin   = filter_search(self.totalSkins, skinSearchInput_textContent or '', 'skins', 'NOTE_assets')

     local currenMinPageIndex = (self.sliderPageIndex - 1) * 16 == 0 and 1 or (self.sliderPageIndex - 1) * 16
     local currenMaxPageIndex =  self.sliderPageIndex      * 16

     local searchFilterSkinsDefault = table.tally(currenMinPageIndex, currenMaxPageIndex)
     local searchFilterSkinsTyped   = table.singularity(table.merge(filterSearchByID, searchFilterSkinsDefault))
     local searchFilterSkins        = #filterSearchByID == 0 and table.sub(searchFilterSkinsDefault, 1, 16) or table.sub(searchFilterSkinsTyped, 1, 16)
     for ids, displays in pairs(searchFilterSkins) do
          if #filterSearchByID    == 0 then return end -- !DO NOT DELETE
          if #filterSearchBySkin < ids then return end -- !DO NOT DELETE

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

          local displaySkinImageTemplate = {path = self.statePaths, skin = 'NOTE_assets'..filterSearchBySkin[ids]}
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
     end
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

     for i = 1, math.max(#skinObjectsPerClicked, #skinObjectsPerHovered) do
          if skinObjectsPerClicked[i] == true then
               playAnim('mouseTexture', 'handClick', true)
               break
          end
          if skinObjectsPerHovered[i] == true then
               playAnim('mouseTexture', 'hand', true)
               break
          end
          if mouseClicked('left') or mousePressed('left') then 
               playAnim('mouseTexture', 'idleClick', true)
          else
               playAnim('mouseTexture', 'idle', true)
          end
     end
end

--- Syncs the saved selection of the certain skin
---@return nil
function SkinNotes:selection_sync()
     local skinObjectsPerIDs      = self.totalSkinObjectID[self.sliderPageIndex]
     local skinObjectsPerHovered  = self.totalSkinObjectHovered[self.sliderPageIndex]
     local skinObjectsPerClicked  = self.totalSkinObjectClicked[self.sliderPageIndex]
     local skinObjectsPerSelected = self.totalSkinObjectSelected[self.sliderPageIndex]
     local skinObjectsPerName     = self.totalSkinObjectNames[self.sliderPageIndex]

     local skinSearchInput_textContent       = getVar('skinSearchInput_textContent')
     local skinSearchInput_textContentFilter = skinSearchInput_textContent ~= nil and skinSearchInput_textContent:lower() or ''
     for pageSkins = skinObjectsPerIDs[1], skinObjectsPerIDs[#skinObjectsPerIDs] do
          local curPage = pageSkins - (16 * (self.sliderPageIndex - 1))

          local displaySkinIconTemplate = {state = (self.stateClass):upperAtStart(), ID = pageSkins}
          local displaySkinIconButton   = ('displaySkinIconButton${state}-${ID}'):interpol(displaySkinIconTemplate)
          if skinObjectsPerName[curPage] == skinSearchInput_textContentFilter and pageSkins ~= self.selectSkinCurSelectedIndex then
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

--- Loads the save data from the current class state.
---@return nil
function SkinNotes:save_load()
     self:create(self.selectSkinPagePositionIndex)
     setProperty('displaySliderIcon.y', self.sliderTrackIntervals[self.selectSkinPagePositionIndex])
end

return SkinNotes