local funkinlua = require 'mods.NoteSkin Selector Remastered.modules.funkinlua'
local globals   = require 'mods.NoteSkin Selector Remastered.modules.globals'
local states    = require 'mods.NoteSkin Selector Remastered.modules.states'
local string    = require 'mods.NoteSkin Selector Remastered.libraries.string'
local table     = require 'mods.NoteSkin Selector Remastered.libraries.table'
local json      = require 'mods.NoteSkin Selector Remastered.libraries.json.json'

local noteAnimDirects    = {'left', 'down', 'up', 'right'}
local noteCalculateEachX = function(x, y)
     return (x + ((x * y) / 2)) - x / 2 
end

makeLuaSprite('bgCover', nil, 0, 0)
makeGraphic('bgCover', 2500, 1500, 'ababab')
setObjectCamera('bgCover', 'camHUD')
addLuaSprite('bgCover', false)

makeAnimatedLuaSprite('nails', 'ui/nails', 560, 445)
addAnimationByPrefix('nails', 'flash', 'nails-flash', 16, true)
addAnimationByPrefix('nails', 'static', 'nails-static', 16, false)
setObjectCamera('nails', 'camHUD')
scaleObject('nails', 0.5, 0.5)
setProperty('nails.visible', false)
setProperty('nails.antialiasing', false)
addLuaSprite('nails')

makeLuaText('fileControlInfo', 'Controls:', 0, 2^9.5, 470)
setTextSize('fileControlInfo', 16)
setTextFont('fileControlInfo', 'nokia.ttf')
setObjectCamera('fileControlInfo', 'camHUD')
addLuaText('fileControlInfo')

local function createTextControl(tag, content, x, y)
     makeLuaText(tag, content[1], 0, x[1], y)
     setTextSize(tag, 16)
     setTextFont(tag, 'nokia.ttf')
     setObjectCamera(tag, 'camHUD')
     addLuaText(tag)

     local tagContent = tag..'Content'
     makeLuaText(tagContent, content[2], 0, x[1] + (x[2] or 100), y)
     setTextSize(tagContent, 16)
     setTextFont(tagContent, 'nokia.ttf')
     setTextColor(tagContent, 'ababab')
     setObjectCamera(tagContent, 'camHUD')
     addLuaText(tagContent)
end

createTextControl('fileControlLeft', {'LEFT:', 'A'}, {2^9.5}, 510)
createTextControl('fileControlDOWN', {'DOWN:', 'S'}, {2^9.5}, 510 + 25)
createTextControl('fileControlUP', {'UP:', 'W'}, {2^9.5}, 510 + 25 * 2)
createTextControl('fileControlRIGHT', {'RIGHT:', 'D'}, {2^9.5}, 510 + 25 * 3)

createTextControl('fileControlGoLeft', {'Go Left:', 'K'}, {2^9.8, 110}, 510)
createTextControl('fileControlGoRight', {'Go Right:', 'L'}, {2^9.8, 110}, 510 + 25)

createTextControl('fileControlChangeIdle', {'To Idle:', 'I'}, {2^10.05, 150}, 510)
createTextControl('fileControlChangeConfirm', {'To Confirm:', 'O'}, {2^10.05, 150}, 510 + 25)
createTextControl('fileControlChangePressed', {'To Pressed:', 'P'}, {2^10.05, 150}, 510 + 25 * 2)

-- Selected BG --

local selectedX = 168 * 2
local selectedY = (230 - 9.5) - 30
makeLuaSprite('selectedBG', nil, selectedX - 9.5, selectedY)
makeGraphic('selectedBG', 130, 130, '000000')
setObjectCamera('selectedBG', 'camHUD')
setProperty('selectedBG.alpha', 0.5)
addLuaSprite('selectedBG', false)

makeLuaText('selectedConfirmInfo', 'Confirm Pos:', 0, selectedX - 180, selectedY + 140)
setTextSize('selectedConfirmInfo', 16)
setTextFont('selectedConfirmInfo', 'nokia.ttf')
setObjectCamera('selectedConfirmInfo', 'camHUD')
addLuaText('selectedConfirmInfo')

makeLuaText('selectedPressedInfo', 'Pressed Pos:', 0, selectedX - 180, selectedY + 170)
setTextSize('selectedPressedInfo', 16)
setTextFont('selectedPressedInfo', 'nokia.ttf')
setObjectCamera('selectedPressedInfo', 'camHUD')
addLuaText('selectedPressedInfo')

-- Positions & Note Displays --

local function initSelectedPos(state, ind, name, text, x, y)
     local stateType = state == 'confirm' and 'Confirm' or state == 'pressed' and 'Pressed'

     local selectedPosTag = ('selected${state}Pos-${direct}'):interpol({state = stateType, direct = name})
     local selectedPosX   = noteCalculateEachX(x, ind)
     makeLuaText(selectedPosTag, ('[${x}, ${y}]'):interpol({x = text[1], y = text[2]}), 150, selectedPosX - 20.5, y)
     setTextSize(selectedPosTag, 16)
     setTextFont(selectedPosTag, 'nokia.ttf')
     setObjectCamera(selectedPosTag, 'camOther')
     addLuaText(selectedPosTag)
end

local function getOffsetSelectedNotes(direct)
     local tag = ('selectedNote-${direct}.offset'):interpol({direct = direct})
     return {getProperty(tag..'.x'), getProperty(tag..'.y')}
end

local function initSelectedNotes(ind, direct, image, x, y)
     local selectedNotesTag = ('selectedNote-${direct}'):interpol({direct = direct})
     local selectedNotesX   = noteCalculateEachX(x, ind)
     makeAnimatedLuaSprite(selectedNotesTag, 'noteSkins/'..image, selectedNotesX, y + 10)
     addAnimationByPrefix(selectedNotesTag, direct..'Confirm', direct..' confirm', 24, false)
     addAnimationByPrefix(selectedNotesTag, direct..'Pressed', direct..' press', 24, false)
     addAnimationByPrefix(selectedNotesTag, direct, 'arrow'..direct:upper(), 24, true)
     setGraphicSize(selectedNotesTag, 110, 110)
     setObjectCamera(selectedNotesTag, 'camOther')
     addOffset(selectedNotesTag, direct, unpack(getOffsetSelectedNotes(direct)))
     precacheImage('noteSkins/'..image)
     addLuaSprite(selectedNotesTag, false)
end

local function createSelectedNotes(images)
     for i = 1, 4 do
          initSelectedNotes(i, noteAnimDirects[i], images, selectedX, selectedY)
          initSelectedPos('confirm', i, noteAnimDirects[i], getOffsetSelectedNotes(noteAnimDirects[i]), selectedX, selectedY + 140)
          initSelectedPos('pressed', i, noteAnimDirects[i], getOffsetSelectedNotes(noteAnimDirects[i]), selectedX, selectedY + 170)
     end
end

local changeSelectTexture = 'NOTE_assets'
local changeSelectReset = true
local function changeSelectedNotes()
     if fileInputTextData ~= nil and changeSelectReset == true then
          createSelectedNotes(fileInputTextData)
          changeSelectTexture = fileInputTextData

          changeSelectReset = false
          setOnScripts('fileInputTextData', nil); changeSelectReset = true
     end
end

createSelectedNotes('NOTE_assets')

function onCreatePost()
     callMethod('uiGroup.remove', {instanceArg('iconP1')})
     callMethod('uiGroup.remove', {instanceArg('iconP2')})
     callMethod('uiGroup.remove', {instanceArg('healthBar')})
     callMethod('uiGroup.remove', {instanceArg('scoreTxt')})
     callMethod('uiGroup.remove', {instanceArg('botplayTxt')})

     setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
     setOnScripts('getNotes', states.getSkins('note'))
end

function math.round(num, dp) -- i stole this
     local mult = 10^(dp or 0);
     return math.floor(num * mult + 0.5)/mult;
end

local offsetsConfirm  = {
     left  = getOffsetSelectedNotes('left'),
     down  = getOffsetSelectedNotes('down'),
     up    = getOffsetSelectedNotes('up'),
     right = getOffsetSelectedNotes('right')
}
local offsetsPressed  = {
     left  = getOffsetSelectedNotes('left'),
     down  = getOffsetSelectedNotes('down'),
     up    = getOffsetSelectedNotes('up'),
     right = getOffsetSelectedNotes('right')
}
local offsetsAnimType = true
local function offsetNoteAnims(direct)
     local selectedNoteTag = 'selectedNote-'..direct
     if keyboardJustPressed('I') and fileInputTextFocused == false then
          playAnim(selectedNoteTag, direct, true)
     end
     if keyboardJustPressed('O') and fileInputTextFocused == false then
          playAnim(selectedNoteTag, direct)
          playAnim(selectedNoteTag, direct..'Confirm', true)
          offsetsAnimType = true
     end
     if keyboardJustPressed('P') and fileInputTextFocused == false then
          playAnim(selectedNoteTag, direct)
          playAnim(selectedNoteTag, direct..'Pressed', true)
          offsetsAnimType = false
     end

     local moveOffsetAnims = function(state, pos, iter)
          local stateType  = state == 'confirm' and 'Confirm' or state == 'pressed' and 'Pressed'
          local offsetType = state == 'confirm' and offsetsConfirm[direct] or state == 'pressed' and offsetsPressed[direct]
          local posType = pos == 1 and 'x' or pos == 2 and 'y'

          local infoTag   = ('selected${state}Pos-${direct}'):interpol({state = stateType, direct = direct})
          local offsetTag = ('${tag}.offset.${pos}'):interpol({tag = selectedNoteTag, pos = posType})
          local offsetPosTagX = getProperty(('${tag}.offset.x'):interpol({tag = selectedNoteTag}))
          local offsetPosTagY = getProperty(('${tag}.offset.y'):interpol({tag = selectedNoteTag}))
          local offsetPosTagElems = {x = math.round(offsetPosTagX, 2), y = math.round(offsetPosTagY, 2)}
          
          offsetType[pos] = offsetType[pos] + iter
          addOffset(selectedNoteTag, direct..stateType, offsetType[1], offsetType[2])
          setProperty(offsetTag, getProperty(offsetTag) + iter)
          setTextString(infoTag, ('[${x}, ${y}]'):interpol(offsetPosTagElems))
     end
     local moveControlAnims = function(state)
          if keyboardPressed('A') then moveOffsetAnims(state, 1, 0.1)  end
          if keyboardPressed('D') then moveOffsetAnims(state, 1, -0.1) end
          if keyboardPressed('S') then moveOffsetAnims(state, 2, -0.1) end
          if keyboardPressed('W') then moveOffsetAnims(state, 2, 0.1)  end
     end

     if getProperty('selectedNote-'..direct..'.animation.curAnim.name') ~= direct then
          if fileInputTextFocused == true then
               return
          end

          if offsetsAnimType == true then
               moveControlAnims('confirm')
          else
               moveControlAnims('pressed')
          end
     end
end

local noteAnimsIndex = 1
local function selectNoteAnims()
     if fileInputTextFocused == false and keyboardJustPressed('L') then
          noteAnimsIndex = noteAnimsIndex + 1
          playSound('select', 0.3)
     end
     if fileInputTextFocused == false and keyboardJustPressed('K') then
          noteAnimsIndex = noteAnimsIndex - 1
          playSound('select', 0.3)
     end
     if noteAnimsIndex >= 5 then
          noteAnimsIndex = 1
     end
     if noteAnimsIndex <= 0 then
          noteAnimsIndex = 4
     end

     local x = noteCalculateEachX(168 * 2, noteAnimsIndex)
     setProperty('selectedBG.x', x - 9.5)
     offsetNoteAnims(noteAnimDirects[noteAnimsIndex])
end

local noteOffsetsJson = {name = {confirm = {}, pressed = {}}}
local noteStrConfirmOffsets = ''
local noteStrPressedOffsets = ''

local saveNoteDebugDelay = false
local function saveNoteDebugPositions() -- what the fuck
     local spaceBy10 = ('\n'):pad(10, ' ', 'r')

     local condition = not fileInputTextFocused and (keyboardPressed('SHIFT') and keyboardJustPressed('M'))
     if not saveNoteDebugDelay and condition then
          local noteStrOffsets = json.stringify(noteOffsetsJson, nil, 5)
          local noteStrOffsets_filterName    = noteStrOffsets:gsub('name', changeSelectTexture:gsub('NOTE_assets%-', ''):lower() or 'normal')
          local noteStrOffsets_filterConfirm = noteStrOffsets_filterName:gsub('(.+"confirm": ){}(.+)', '%1{@1}%2')
          local noteStrOffsets_filterPressed = noteStrOffsets_filterConfirm:gsub('(.+"pressed": ){}(.+)', '%1{@2}%2')

          noteStrConfirmOffsets = ''
          noteStrPressedOffsets = ''
          for directInd = 1,4 do
               local selectedConfirmPos = getTextString('selectedConfirmPos-'..noteAnimDirects[directInd])
               local selectedPressedPos = getTextString('selectedPressedPos-'..noteAnimDirects[directInd])

               local selectedConfirmElems = {directs = noteAnimDirects[directInd], contentConfirm = selectedConfirmPos, space = spaceBy10}
               local selectedPressedElems = {directs = noteAnimDirects[directInd], contentPressed = selectedPressedPos, space = spaceBy10}
               local selectedConfirmString = ('     \"${directs}\": ${contentConfirm},${space}'):interpol(selectedConfirmElems)
               local selectedPressedString = ('     \"${directs}\": ${contentPressed},${space}'):interpol(selectedPressedElems)
               noteStrConfirmOffsets = noteStrConfirmOffsets .. selectedConfirmString
               noteStrPressedOffsets = noteStrPressedOffsets .. selectedPressedString
          end

          local noteStrOffsets_filterConfirmElems = {filtered = noteStrConfirmOffsets:sub(1, #noteStrConfirmOffsets - #(','..spaceBy10)), space = spaceBy10}
          local noteStrOffsets_filterPressedElems = {filtered = noteStrPressedOffsets:sub(1, #noteStrPressedOffsets - #(','..spaceBy10)), space = spaceBy10}
          local noteStrOffsets_filterConfirmString = ('${space}${filtered}${space}'):interpol(noteStrOffsets_filterConfirmElems)
          local noteStrOffsets_filterPressedString = ('${space}${filtered}${space}'):interpol(noteStrOffsets_filterPressedElems)
          local noteStrOffsets_filterContent = noteStrOffsets_filterPressed:gsub('@1', noteStrOffsets_filterConfirmString):gsub('@2', noteStrOffsets_filterPressedString)

          local noteStrOffsets_filterSpacedPattern = '("pressed":%s*{.-}),%s*("confirm":%s*{.-})'
          local noteStrOffsets_filterSpacedResult  = '%2,'..spaceBy10..'%1'
          local noteStrOffsets_filterSpaced = noteStrOffsets_filterContent:gsub(noteStrOffsets_filterSpacedPattern, noteStrOffsets_filterSpacedResult)

          local path = 'NoteSkin Selector Remastered/jsons/debug/'..changeSelectTexture..'.json'
          saveFile(path, noteStrOffsets_filterSpaced)

          if getRandomBool(30) then
               setProperty('nails.visible', true)
               playAnim('nails', 'flash')

               funkinlua.createTimer('nailsTimer', 2.0, function() playAnim('nails', 'static', true)  end)
          else
               setProperty('nails.visible', false)
          end

          saveNoteDebugDelay = true
          funkinlua.createTimer('saveNoteDebugDelay', 2.0, function() saveNoteDebugDelay = false end)
     end
end

local eraseNoteDebugDelay = false
local function erasedNoteDebugPositions()
     local condition = not fileInputTextFocused and (keyboardPressed('SHIFT') and keyboardJustPressed('B'))
     if not eraseNoteDebugDelay and condition then
          for k,v in pairs(directoryFileList('mods/NoteSkin Selector Remastered/jsons/debug')) do
               if v:match('%.json') then
                    deleteFile('NoteSkin Selector Remastered/jsons/debug/'..v)
               end
          end

          eraseNoteDebugDelay = true
          funkinlua.createTimer('eraseNoteDebugDelay', 1.0, function() eraseNoteDebugDelay = false end)
     end
end

function onUpdate(elapsed)
     if fileInputTextFocused == false and keyboardJustPressed('ONE')    then restartSong(true) end
     if fileInputTextFocused == false and keyboardJustPressed('ESCAPE') then exitSong()        end
     if getModSetting('enable_double-tapping_safe', 'NoteSkin Selector Remastered') then
          if funkinlua.keyboardJustDoublePressed('TAB') then
               loadNewSong('NoteSkin Settings')
          end
     else
          if keyboardJustPressed('TAB') then
               loadNewSong('NoteSkin Settings')
          end
     end
     
     selectNoteAnims()
     changeSelectedNotes()

     saveNoteDebugPositions()
     erasedNoteDebugPositions()
end

local allowCountdown = false;
function onStartCountdown()
     if not allowCountdown then -- Block the first countdown
          local localModFolder = 'NoteSkin Selector Remastered'
          for k,v in pairs(getRunningScripts()) do
               if v:match(localModFolder..'/scripts/skins') or not v:match(localModFolder) then
                    removeLuaScript(v)
               end
          end
          allowCountdown = true;
          return Function_Stop;
     end
     setProperty('camHUD.visible', true)
     return Function_Continue;
end