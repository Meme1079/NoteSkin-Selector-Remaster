local SkinSaves = require 'mods.NoteSkin Selector Remastered.data.noteskin-settings.classes.SkinSaves'

local table     = require 'mods.NoteSkin Selector Remastered.libraries.table'
local string    = require 'mods.NoteSkin Selector Remastered.libraries.string'
local json      = require 'mods.NoteSkin Selector Remastered.libraries.json.main'
local globals   = require 'mods.NoteSkin Selector Remastered.modules.globals'
local states    = require 'mods.NoteSkin Selector Remastered.modules.states'
local funkinlua = require 'mods.NoteSkin Selector Remastered.modules.funkinlua'

local ternary   = globals.ternary
local switch    = globals.switch
local clickObject = funkinlua.clickObject
local createTimer = funkinlua.createTimer

local function getJsonData(path)
     local JSONpath = 'mods/NoteSkin Selector Remastered/jsons/'..path
     return json.parse(globals.getTextFileContent(JSONpath), true)
end

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

local SkinStateJsons = {
     note = {
          offsets    = getJsonData('note/offsets.json'),
          preview    = getJsonData('note/preview.json'),
          properties = getJsonData('note/properties.json')
     },
     splash = {
          display    = getJsonData('splash/display.json'),
          offsets    = getJsonData('splash/offsets.json'),
          preview    = getJsonData('splash/preview.json'),
          properties = getJsonData('splash/properties.json')
     }
}
local SkinStateSaves = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
local SkinStateTypes = {}
local SkinStateFirst = {}
local SkinStates = {}
function SkinStates:new(stateType, statePath, stateFirstSection)
     local self = setmetatable({}, {__index = self})
     self.stateType = stateType
     self.statePath = statePath
     self.stateFirstSection = stateFirstSection

     SkinStateTypes[#SkinStateTypes + 1] = self.stateType
     SkinStateFirst[self.stateType]      = self.stateFirstSection
     return self
end

local previewDirects = {'left', 'down', 'up', 'right'}
local previewColors  = {'purple', 'blue', 'green', 'red'}
function SkinStates:statePreviewGroupVisible(previewIndex, stateSelectIndex, isUpdated)
     for dir = 1,4 do
          local statePreviewElems = {state = self.stateType, direct = previewDirects[dir]:upperAtStart(), index = previewIndex}
          local statePreviewTag   = ('${state}Preview${direct}-${index}'):interpol(statePreviewElems)

          if self.stateFirstSection == true then
               local isCurIndex = stateSelectIndex[self.stateType] == previewIndex
               setProperty(statePreviewTag..'.visible', isCurIndex)
          end
          if self.stateFirstSection == false and isUpdated == false then
               setProperty(statePreviewTag..'.visible', false)
          end
     end
end

local stateMaximumLimit       = {note = false, splash = false}
local stateMinimumLimit       = {note = false, splash = false}
local statePageIndex          = {note = SkinStateSaves:get('notePageIndex', 1),   splash = SkinStateSaves:get('splashPageIndex', 1)}
local stateSelectIndex        = {note = SkinStateSaves:get('noteSelectIndex', 1), splash = SkinStateSaves:get('splashSelectIndex', 1)}
local stateSelectIndexEnabled = {note = true,  splash = true}
function SkinStates:create()
     local jsonDataProperty = SkinStateJsons[self.stateType]['properties']
     local jsonDataPreview  = SkinStateJsons[self.stateType]['preview']
     local jsonDataDisplay  = SkinStateJsons['splash']['display']

     local stateGetSkins = states.getSkins(self.stateType)
     for index, value in next, stateGetSkins do
          local stateCurrentPos = states.calculatePosition(stateGetSkins)[index]
          local statePositionX  = self.stateFirstSection == true and 0 or -(340 * 2)
          local stateImage      = ('${folder}/${file}'):interpol({folder = self.statePath, file = value})

          local stateHitboxTag  = ('${skin}Hitbox-${index}'):interpol({skin = self.stateType, index = index})
          makeLuaSprite(stateHitboxTag, 'user_interface/selection_bg', stateCurrentPos[1] + statePositionX - 12.8, stateCurrentPos[2] + -43.3)
          setObjectCamera(stateHitboxTag, 'camHUD')
          setGraphicSize(stateHitboxTag, 155, 155)
          setProperty(stateHitboxTag..'.antialiasing', false)
          addLuaSprite(stateHitboxTag, false)

          local stateDisplayTag = ('${skin}Display-${index}'):interpol({skin = self.stateType, index = index})
          local function stateDisplayObject(displaySize, displayPrefix, displayFrame, displayAddedOffsets)
               local displayPosX = stateCurrentPos[1] + statePositionX + 9.5
               local displayPosY = stateCurrentPos[2] + -20
               makeAnimatedLuaSprite(stateDisplayTag, stateImage, displayPosX, displayPosY)
               setGraphicSize(stateDisplayTag, displaySize, displaySize)
               addAnimationByPrefix(stateDisplayTag, 'display', displayPrefix, displayFrame, true)

               local displayOffsetX = getProperty(stateDisplayTag..'.offset.x') + displayAddedOffsets[1]
               local displayOffsetY = getProperty(stateDisplayTag..'.offset.y') + displayAddedOffsets[2]
               addOffset(stateDisplayTag, 'display', displayOffsetX, displayOffsetY)
               playAnim(stateDisplayTag, 'display')
               setObjectCamera(stateDisplayTag, 'camHUD')
               precacheImage(stateImage)
               addLuaSprite(stateDisplayTag, true)
          end

          local function statePreviewObjectGroup(previewSize, previewPrefix)
               local jsonPropertyAnimIdle = jsonDataProperty['animations']['idle']
               local jsonPropertyAnimPlay = jsonDataProperty['animations']['played']

               for dir = 1,4 do
                    local statePreviewElems   = {state = self.stateType, direct = previewDirects[dir]:upperAtStart(), index = index}
                    local statePreviewTag     = ('${state}Preview${direct}-${index}'):interpol(statePreviewElems)
                    local statePreviewMarginX = 790 + (115 * (dir - 1))

                    local statePreviewAnimName   = previewDirects[dir]
                    local statePreviewAnimPrefix = jsonPropertyAnimIdle[dir]
                    makeAnimatedLuaSprite(statePreviewTag, stateImage, statePreviewMarginX - 15, 175 + -30)
                    for names, prefixes in pairs(jsonPropertyAnimPlay) do
                         addAnimationByPrefix(statePreviewTag, names, prefixes:gsub('@prefix', previewPrefix), 24, false)
                    end
                    addAnimationByPrefix(statePreviewTag, statePreviewAnimName, statePreviewAnimPrefix, 24, true)
                    playAnim(statePreviewTag, statePreviewAnimName)
                    setGraphicSize(statePreviewTag, previewSize, previewSize)
                    setObjectCamera(statePreviewTag, 'camHUD')
                    addOffset(statePreviewTag, statePreviewAnimName, getProperty(statePreviewTag..'.offset.x'), getProperty(statePreviewTag..'.offset.y'))
                    addLuaSprite(statePreviewTag, false)
               end
          end

          local stateNamePrefix = value:lower():split('-')[2]
          local stateNameFilter = stateNamePrefix == nil and 'funkin' or stateNamePrefix
          switch (self.stateType) {
               note = function()
                    stateDisplayObject(110, 'arrowUP', 24, {0,0})
                    statePreviewObjectGroup(110, '')
               end,
               splash = function()
                    local getSplashDisplayElem = function(element, default, index)
                         if type(jsonDataDisplay[stateNameFilter][element]) == 'table' then
                              return ternary(nil, jsonDataDisplay[stateNameFilter][element][index], default)
                         end
                         return ternary(nil, jsonDataDisplay[stateNameFilter][element], default)
                    end
                    local getSplashPreviewElem = function() -- If only is there a way to make every single table a metatable
                         if jsonDataPreview[stateNameFilter]['properties']         == nil then return 110 end
                         if jsonDataPreview[stateNameFilter]['properties']['size'] == nil then return 110 end
                         return jsonDataPreview[stateNameFilter]['properties']['size']
                    end

                    local splashDisplaySize     = getSplashDisplayElem('size', 110)
                    local splashDisplayPrefixes = getSplashDisplayElem('prefixes', 'note splash')
                    local splashDisplayFrames   = getSplashDisplayElem('frames', 24)

                    local splashDisplayOffsetX  = getSplashDisplayElem('offsets', 0, 1)
                    local splashDisplayOffsetY  = getSplashDisplayElem('offsets', 0, 2)
                    local splashDisplayOffsets  = {splashDisplayOffsetX, splashDisplayOffsetY}
                    stateDisplayObject(splashDisplaySize, splashDisplayPrefixes .. ' green 1', splashDisplayFrames, splashDisplayOffsets)
                    statePreviewObjectGroup(getSplashPreviewElem(), splashDisplayPrefixes)
               end
          }

          local selectHighlightTag = ('selectHighlight${skin}'):interpol({skin = self.stateType:upperAtStart()})
          makeLuaSprite(selectHighlightTag, 'user_interface/selection', 7.2, 121.7)
          setGraphicSize(selectHighlightTag, 155, 155)
          setObjectCamera(selectHighlightTag, 'camHUD')
          setProperty(selectHighlightTag..'.antialiasing', false)
          setProperty(selectHighlightTag..'.visible', self.stateFirstSection)
          addLuaSprite(selectHighlightTag, false)

          self:statePreviewGroupVisible(index, stateSelectIndex, false)
     end
end

function SkinStates:pageFlip(setBySave)
     if SkinStateFirst[self.stateType] == false then return end
     if setBySave == true then
          local selectDisplayMoveByPage = 340 * ((statePageIndex[self.stateType] - 1) * 2)

          local stateGetSkins = states.getSkins(self.stateType)
          local stateMaxSkins = states.calculatePageLimit(stateGetSkins)
          for index, value in next, stateGetSkins do
               local hitboxTag  = ('${skin}Hitbox-${index}.y'):interpol({skin = self.stateType, index = index})
               local displayTag = ('${skin}Display-${index}.y'):interpol({skin = self.stateType, index = index})
               setProperty(hitboxTag,  getProperty(hitboxTag)  - selectDisplayMoveByPage)
               setProperty(displayTag, getProperty(displayTag) - selectDisplayMoveByPage)
          end
     
          local skinPageElems = {curPage = statePageIndex[self.stateType], curLimit = stateMaxSkins}
          setTextString('skinPageCurCount', ('Page ${curPage} / ${curLimit}'):interpol(skinPageElems))
          setTextString('sidebarSkinName', states.getSkinNames(self.stateType)[statePageIndex[self.stateType]])
     
          local hitBoxTagElems = {skin = self.stateType, index = statePageIndex[self.stateType]}
          local hitboxTag      = ('${skin}Hitbox-${index}'):interpol(hitBoxTagElems)
          setProperty('selectHighlight.x'.. getProperty(hitboxTag..'.x') - 7)
          setProperty('selectHighlight.y'.. getProperty(hitboxTag..'.y') - 7)   
          return -- stops the code below from executing
     end

     local selectDisplayMoveByPage = 340 * 2
     local selectDisplayOffset     = 7

     local stateGetSkins = states.getSkins(self.stateType)
     local stateMaxSkins = states.calculatePageLimit(stateGetSkins)
     for index, value in next, stateGetSkins do
          local hitboxTag  = ('${skin}Hitbox-${index}.y'):interpol({skin = self.stateType, index = index})
          local displayTag = ('${skin}Display-${index}.y'):interpol({skin = self.stateType, index = index})

          local getHiboxForSelectDisplayY = ('${skin}Hitbox-${preIndex}.y'):interpol({skin = self.stateType, preIndex = stateSelectIndex[self.stateType]})
          if keyboardJustPressed('UP') and stateMaximumLimit[self.stateType] == false then
               setProperty(hitboxTag,  getProperty(hitboxTag)  + selectDisplayMoveByPage)
               setProperty(displayTag, getProperty(displayTag) + selectDisplayMoveByPage)
     
               setProperty('selectHighlight'..self.stateType:upperAtStart()..'.y', getProperty(getHiboxForSelectDisplayY))
          end
          if keyboardJustPressed('DOWN') and stateMinimumLimit[self.stateType] == false then
               setProperty(hitboxTag,  getProperty(hitboxTag)  - selectDisplayMoveByPage)
               setProperty(displayTag, getProperty(displayTag) - selectDisplayMoveByPage)
     
               setProperty('selectHighlight'..self.stateType:upperAtStart()..'.y', getProperty(getHiboxForSelectDisplayY))
          end
     end

     if keyboardJustPressed('UP') and stateMaximumLimit[self.stateType] == false then
          statePageIndex[self.stateType] = statePageIndex[self.stateType] - 1 
          setTextString('skinPageCurCount', ('Page ${curPage} / ${curLimit}'):interpol({curPage = statePageIndex[self.stateType], curLimit = stateMaxSkins}))
          playSound('move', 0.5)
          
          SkinStateSaves:set(self.stateType..'PageIndex', statePageIndex[self.stateType])
          SkinStateSaves:flush()
     end
     if keyboardJustPressed('DOWN') and stateMinimumLimit[self.stateType] == false then
          statePageIndex[self.stateType] = statePageIndex[self.stateType] + 1
          setTextString('skinPageCurCount', ('Page ${curPage} / ${curLimit}'):interpol({curPage = statePageIndex[self.stateType], curLimit = stateMaxSkins}))
          playSound('move', 0.5)

          SkinStateSaves:set(self.stateType..'PageIndex', statePageIndex[self.stateType])
          SkinStateSaves:flush()
     end

     if statePageIndex[self.stateType] <= 1 then
          stateMaximumLimit[self.stateType] = true
          setProperty('skinPageArrowUp.color', 0xbababa)
     else
          stateMaximumLimit[self.stateType] = false
          setProperty('skinPageArrowUp.color', 0xffffff)
     end
     if statePageIndex[self.stateType] >= stateMaxSkins then
          stateMinimumLimit[self.stateType] = true
          setProperty('skinPageArrowDown.color', 0xbababa)
     else
          stateMinimumLimit[self.stateType] = false
          setProperty('skinPageArrowDown.color', 0xffffff)
     end
end

function SkinStates:stateSwap()
     local function swapPositions(state, xAxis, isVisible)
          local stateGetSkins = states.getSkins(state)
          for index, value in next, stateGetSkins do
               local hitboxTag = ('${skin}Hitbox-${index}'):interpol({skin = state, index = index})
               setProperty(hitboxTag..'.x', getProperty(hitboxTag..'.x') + xAxis)
               setProperty(hitboxTag..'.visible', isVisible)

               local displayTag = ('${skin}Display-${index}'):interpol({skin = state, index = index})
               setProperty(displayTag..'.x', getProperty(displayTag..'.x') + xAxis)
               setProperty(displayTag..'.visible', isVisible)
          end
     end
     local function checkboxStates(state, isVisible)
          local checkboxChars = {'player', 'opponent'}
          for index, chars in next, checkboxChars do
               local checkboxCharElems = {state = state, char = chars}
               local checkboxCharTag   = ('${state}CheckboxChar-${char}'):interpol(checkboxCharElems)

               setProperty(checkboxCharTag..'.visible', isVisible)
          end
     end

     for _, curState in pairs(SkinStateTypes) do
          if not SkinStateFirst[curState] then
               local stateGetSkins = states.getSkins(curState)
               local stateMaxSkins = states.calculatePageLimit(stateGetSkins)
               setTextString('sidebarSkinName', states.getSkinNames(curState)[stateSelectIndex[curState]])
               setTextString('skinPageCurCount', 'Page '.. statePageIndex[curState] .. ' / ' .. stateMaxSkins)
               setProperty('selectHighlight'..curState:upperAtStart()..'.visible', true)

               swapPositions(curState, 340 * 2, true)
               checkboxStates(curState, true)
               SkinStateFirst[curState] = true
               goto continue
          end
          setProperty('selectHighlight'..curState:upperAtStart()..'.visible', false)

          swapPositions(curState, -340 * 2, false)
          checkboxStates(curState, false)
          SkinStateFirst[curState] = false
          ::continue::
     end
end

function SkinStates:highlight()
     local stateGetSkins = states.getSkins(self.stateType)
     for index, value in next, stateGetSkins do
          local hitboxTag  = ('${state}Hitbox-${index}'):interpol({state = self.stateType, index = index})
          local displayTag = ('${state}Display-${index}'):interpol({state = self.stateType, index = index})
          local setSelectDisplayPos = function()
               local getCalculatePosition = states.calculatePosition(stateGetSkins)[index]

               local selectDisplayTag = ('selectHighlight${state}'):interpol({state = self.stateType:upperAtStart()})
               setProperty(selectDisplayTag..'.x', getCalculatePosition[1] - 12.6)
               setProperty(selectDisplayTag..'.y', getProperty(hitboxTag..'.y'))
          end
          
          if clickObject(hitboxTag) then
               setTextString('sidebarSkinName', states.getSkinNames(self.stateType)[index])
               playSound('select', 1)
               setSelectDisplayPos()
               stateSelectIndex[self.stateType] = index

               SkinStateSaves:set(self.stateType..'SelectIndex', index)
               SkinStateSaves:flush()
          end

          if stateSelectIndex[self.stateType] == index and stateSelectIndexEnabled[self.stateType] == true then
               setTextString('sidebarSkinName', states.getSkinNames(self.stateType)[index])
               setSelectDisplayPos()

               stateSelectIndexEnabled[self.stateType] = false
          end
     end
end

function SkinStates:preview()
     local jsonDataPreview = SkinStateJsons[self.stateType]['preview']

     local stateGetSkins = states.getSkins(self.stateType)
     for index, value in next, stateGetSkins do
          local stateHitboxTag = ('${skin}Hitbox-${index}'):interpol({skin = self.stateType, index = index})
          for dir = 1,4 do
               local statePreviewElem = {state = self.stateType, direct = previewDirects[dir]:upperAtStart(), index = stateSelectIndex[self.stateType]}
               local statePreviewTag  = ('${state}Preview${direct}-${index}'):interpol(statePreviewElem)

               local curKeyBinds       = getKeyBinds(dir)
               local curKeyHorizontals = keyboardReleased('LEFT') or keyboardReleased('RIGHT')

               local stateNamePrefix = value:lower():split('-')[2]
               local stateNameFilter = stateNamePrefix == nil and 'funkin' or stateNamePrefix
               local function previewGetOffset(mainAnimPrefix, offsetAnimPrefix, offsetIndex)
                    local jsonPreviewCurrDirect = jsonDataPreview[offsetAnimPrefix][mainAnimPrefix][previewDirects[dir]]
                    local jsonPreviewFunkDirect = jsonDataPreview['funkin'][mainAnimPrefix][previewDirects[dir]]
     
                    local statePositionIndex     = {'x', 'y'}
                    local statePreviewOffsetElem = {skin = statePreviewTag, pos = statePositionIndex[posIndex]}
                    local statePreviewOffsetTag  = ('${skin}.offset.${pos}'):interpol(statePreviewOffsetElem)
                    if jsonPreviewCurrDirect == nil then
                         return getProperty(statePreviewOffsetTag)
                    end

                    local previewCurrDirectIndex = jsonPreviewCurrDirect[offsetIndex]
                    local previewFunkDirectIndex = jsonPreviewFunkDirect[offsetIndex]
                    if previewCurrDirectIndex == nil then
                         return getProperty(statePreviewOffsetTag)
                    end
                    if type(previewCurrDirectIndex) == 'string' and previewCurrDirectIndex:match('@funkin') == '@funkin' then
                         local previewCurrPosCalc = previewCurrDirectIndex:match(':calc{(.-)}') or 0
                         return previewFunkDirectIndex + load('return '..previewCurrPosCalc)()
                    end
                    return previewCurrDirectIndex
               end
               local function previewSetOffset(mainAnimPrefix)
                    if stateSelectIndex[self.stateType] ~= index then 
                         return nil
                    end
                    if jsonDataPreview[stateNameFilter] == nil then
                         return debugPrint('SkinStates Error: Missing or mispelled skin name!', 'ff0000')
                    end
     
                    local stateOffsetPosNameX = previewGetOffset(mainAnimPrefix, stateNameFilter, 1)
                    local stateOffsetPosNameY = previewGetOffset(mainAnimPrefix, stateNameFilter, 2)
                    local stateOffsetAnimName = previewDirects[dir]..mainAnimPrefix:upperAtStart()
                    addOffset(statePreviewTag, stateOffsetAnimName, stateOffsetPosNameX, stateOffsetPosNameY)
               end
               local function playAnimPreview(mainAnimPrefix, limitVisible)
                    if keyboardJustPressed(curKeyBinds) then
                         if limitVisible == true then setProperty(statePreviewTag..'.visible', true) end
                         previewSetOffset(mainAnimPrefix)
                         playAnim(statePreviewTag, previewDirects[dir]..mainAnimPrefix:upperAtStart(), true)
                    end
                    if keyboardReleased(curKeyBinds) or clickObject(stateHitboxTag) or curKeyHorizontals then
                         if limitVisible == true then setProperty(statePreviewTag..'.visible', false) end
                         playAnim(statePreviewTag, previewDirects[dir])
                    end
               end

               switch (self.stateType) {
                    note = function()
                         playAnimPreview('confirm', false)
                    end,
                    splash = function() 
                         playAnimPreview('splash1', true)
                    end
               }
          end
          --self:statePreviewGroupVisible(index, stateSelectIndex, true)
     end
end

local stateCheckboxDisable = {
     note   = {player = true, opponent = true},   
     splash = {player = true, opponent = true}
}
local stateCheckboxClicked = {
     note   = {
          player   = SkinStateSaves:get('noteCheckboxClickedPlayer', false), 
          opponent = SkinStateSaves:get('noteCheckboxClickedOpponent', false)
     }, 
     splash = {
          player   = SkinStateSaves:get('splashCheckboxClickedPlayer', false), 
          opponent = SkinStateSaves:get('splashCheckboxClickedOpponent', false)
     }
}
local stateCheckboxIndex   = {
     note   = {
          player   = SkinStateSaves:get('noteCheckboxIndexPlayer', 0), 
          opponent = SkinStateSaves:get('noteCheckboxIndexOpponent', 0)},
     splash = {
          player   = SkinStateSaves:get('splashCheckboxIndexPlayer', 0), 
          opponent = SkinStateSaves:get('splashCheckboxIndexOpponent', 0)
     }
}
function SkinStates:checkbox(setBySave)
     local checkboxChars = {'player', 'opponent'}
     if setBySave == true then
          for index, chars in next, checkboxChars do
               local checkboxCharElems = {state = self.stateType, char = chars}
               local checkboxCharTag   = ('${state}CheckboxChar-${char}'):interpol(checkboxCharElems)
               local checkboxCharX = 775 + (220 * (index - 1))
               local checkboxCharY = 300

               makeAnimatedLuaSprite(checkboxCharTag, 'checkboxanim', checkboxCharX, checkboxCharY)
               setObjectCamera(checkboxCharTag, 'camHUD')
               setGraphicSize(checkboxCharTag, 55, 55)
               addAnimationByPrefix(checkboxCharTag, 'unchecked', 'checkbox0', 24, false)
               addAnimationByPrefix(checkboxCharTag, 'unchecking', 'checkbox anim reverse', 24, false)
               addAnimationByPrefix(checkboxCharTag, 'checking', 'checkbox anim0', 24, false)
               addAnimationByPrefix(checkboxCharTag, 'checked', 'checkbox finish', 24, false)
               addOffset(checkboxCharTag, 'unchecked', 18, 16.5)
               addOffset(checkboxCharTag, 'unchecking', 31.8, 31.3)
               addOffset(checkboxCharTag, 'checking', 37, 29)
               addOffset(checkboxCharTag, 'checked', 19.5, 22)
               playAnim(checkboxCharTag, 'unchecked', true)
               addLuaSprite(checkboxCharTag)

               if self.stateFirstSection == false then
                    setProperty(checkboxCharTag..'.visible', false)
               end
          end
          return -- stops the code below from executing
     end

     local stateGetSkins = states.getSkins(self.stateType)
     for index, value in next, stateGetSkins do
          local hitboxTag = ('${skin}Hitbox-${index}'):interpol({skin = self.stateType, index = index})

          for _, chars in next, checkboxChars do
               local checkboxCharElems = {state = self.stateType, char = chars}
               local checkboxCharTag   = ('${state}CheckboxChar-${char}'):interpol(checkboxCharElems)

               if clickObject(checkboxCharTag) and stateCheckboxClicked[self.stateType][chars] == false then
                    stateCheckboxIndex[self.stateType][chars]   = stateSelectIndex[self.stateType]
                    stateCheckboxDisable[self.stateType][chars] = false
                    
                    playAnim(checkboxCharTag, 'checking', true)
                    createTimer(self.stateType..'Check', 1e-3, function()
                         stateCheckboxClicked[self.stateType][chars] = true
                    end)
                    SkinStateSaves:set(self.stateType..'CheckboxIndexPlayer', stateCheckboxIndex[self.stateType]['player'])
                    SkinStateSaves:set(self.stateType..'CheckboxIndexOpponent', stateCheckboxIndex[self.stateType]['opponent'])
                    SkinStateSaves:set(self.stateType..'CheckboxClickedPlayer', true)
                    SkinStateSaves:set(self.stateType..'CheckboxClickedOpponent', true)
                    SkinStateSaves:flush()
               end
               if clickObject(checkboxCharTag) and stateCheckboxClicked[self.stateType][chars] == true then
                    stateCheckboxIndex[self.stateType][chars]   = 0
                    
                    playAnim(checkboxCharTag, 'unchecking', true)
                    createTimer(self.stateType..'Uncheck', 1e-3, function()
                         stateCheckboxClicked[self.stateType][chars] = false
                    end)
                    SkinStateSaves:set(self.stateType..'CheckboxIndexPlayer', 0)
                    SkinStateSaves:set(self.stateType..'CheckboxIndexOpponent', 0)
                    SkinStateSaves:set(self.stateType..'CheckboxClickedPlayer', false)
                    SkinStateSaves:set(self.stateType..'CheckboxClickedOpponent', false)
                    SkinStateSaves:flush()
               end
     
               if clickObject(hitboxTag) and stateSelectIndex[self.stateType] ~= stateCheckboxIndex[self.stateType][chars] then
                    playAnim(checkboxCharTag, 'unchecked')
                    stateCheckboxClicked[self.stateType][chars] = false
               end
               if clickObject(hitboxTag) and stateSelectIndex[self.stateType] == stateCheckboxIndex[self.stateType][chars] then
                    playAnim(checkboxCharTag, 'checked')
                    stateCheckboxClicked[self.stateType][chars] = true
               end
               
               if stateSelectIndex[self.stateType] == stateCheckboxIndex[self.stateType][chars] and stateCheckboxDisable[self.stateType][chars] == true then
                    playAnim(checkboxCharTag, 'checked', false)
                    stateCheckboxClicked[self.stateType][chars] = true
                    stateCheckboxDisable[self.stateType][chars] = false
               end

               local checkboxCharTagAnimFinish = getProperty(checkboxCharTag..'.animation.finished')
               local checkboxCharTagAnimName   = getProperty(checkboxCharTag..'.animation.curAnim.name')
               if checkboxCharTagAnimFinish and checkboxCharTagAnimName == 'unchecking' then
                    playAnim(checkboxCharTag, 'unchecked', true)
               end
          end
     end
end

SkinStates.SkinStateTypes = SkinStateTypes
return SkinStates