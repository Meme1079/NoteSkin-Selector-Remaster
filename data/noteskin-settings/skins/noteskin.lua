local table  = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/table')
local string = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/string')
local json   = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/json')

local function getTextFileContent(path)
     local file = io.open(path)
     local content = ''
     for line in file:lines() do  
          content = content .. line .. '\n'
     end
     return content
end

local function calculatePosition(skinType)
     local xpos = {20, 220 - 30, (220 + 170) - 30, (220 + (170 * 2)) - 30}
     local ypos = -155 -- increment in each 4th value

     local xindex = 0
     local result = {}
     for skinIndex = 1, #skinType do
          xindex = xindex + 1
          if xindex > 4 then
               xindex = 1
          end

          local skinIndexNeg = skinIndex - 1
          if skinIndexNeg % 4 == 0  then ypos = ypos + 180 end;
          if skinIndexNeg % 12 == 0 then ypos = ypos + 140 end;
          table.insert(result, {xpos[xindex], ypos});
     end
     
     return result
end

local function calculatePageLimit(skinType)
     local yindex_limit = 0
     for skinIndex = 1, #skinType do
          local skinIndexNeg = skinIndex - 1
          if skinIndexNeg % 12 == 0 then
               yindex_limit = yindex_limit + 1
          end
     end
     return yindex_limit
end

local function clickObject(obj)
     return objectsOverlap(obj, 'mouse_hitbox') and mouseClicked('left')
end

local function getNoteSkins()
     local results = {'NOTE_assets', 'NOTE_assets-future', 'NOTE_assets-chip'}
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/noteSkins') do
          if v:match('^(NOTE_assets%-.+)%.png$') then
               table.insert(results, v:match('^(NOTE_assets%-.+)%.png$'))
          end
     end
     return results
end

local function getNoteSkinNames()
     local results = {'Normal', 'Future', 'Chip'}
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/noteSkins') do
          if v:match('^NOTE_assets%-(.+)%.png$') then
               table.insert(results, v:match('^NOTE_assets%-(.+)%.png$'))
          end
     end
     return results
end

local function altValue(main, alt)
     return main ~= nil and main or alt
end

local function initNoteSkins(noteSkinTag, noteSkinImage, nameAnim, prefixAnim, xpos)
     makeAnimatedLuaSprite(noteSkinTag, noteSkinImage, xpos, 175)
     addAnimationByPrefix(noteSkinTag, 'leftConfirm', 'left confirm', 24, false)
     addAnimationByPrefix(noteSkinTag, 'downConfirm', 'down confirm', 24, false)
     addAnimationByPrefix(noteSkinTag, 'upConfirm', 'up confirm', 24, false)
     addAnimationByPrefix(noteSkinTag, 'rightConfirm', 'right confirm', 24, false)
     addAnimationByPrefix(noteSkinTag, 'leftPressed', 'left press', 24, false)
     addAnimationByPrefix(noteSkinTag, 'downPressed', 'down press', 24, false)
     addAnimationByPrefix(noteSkinTag, 'upPressed', 'up press', 24, false)
     addAnimationByPrefix(noteSkinTag, 'rightPressed', 'right press', 24, false)
     addAnimationByPrefix(noteSkinTag, nameAnim, prefixAnim, 24, false)
     setGraphicSize(noteSkinTag, 110, 110)
     setObjectCamera(noteSkinTag, 'camHUD')
     addLuaSprite(noteSkinTag, false)
end

local function createNoteSkins()
     local offsetsConfrim = {left = {}, down = {}, up = {}, right = {}}
     local offsetsPressed = {left = {}, down = {}, up = {}, right = {}}
     for index, value in next, getNoteSkins() do
          local noteSkin_getCurPos = calculatePosition(getNoteSkins())[index]
          local noteSkin_hitboxTag = 'noteSkins_hitbox-'..tostring(index)
          makeLuaSprite(noteSkin_hitboxTag, nil, noteSkin_getCurPos[1], noteSkin_getCurPos[2])
          makeGraphic(noteSkin_hitboxTag, 130, 130, '000000')
          setObjectCamera(noteSkin_hitboxTag, 'camOther')
          setProperty(noteSkin_hitboxTag..'.visible', false)
          addLuaSprite(noteSkin_hitboxTag)

          local noteSkin_displayTag = 'noteSkins_display-'..tostring(index)
          local noteSkin_displayImage = 'noteSkins/'..value
          makeAnimatedLuaSprite(noteSkin_displayTag, noteSkin_displayImage, noteSkin_getCurPos[1] + 9.5, noteSkin_getCurPos[2] + 9.5)
          addAnimationByPrefix(noteSkin_displayTag, 'up', 'arrowUP', 24, false)
          setGraphicSize(noteSkin_displayTag, 110, 110)
          setObjectCamera(noteSkin_displayTag, 'camOther')
          precacheImage(noteSkin_displayImage)
          addLuaSprite(noteSkin_displayTag)

          local noteSkin_arrowImage = 'noteSkins/'..value
          local noteSkin_arrowTagPrefix = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          local noteSkin_arrowTag = function(ind) 
               return 'noteSkins'..noteSkin_arrowTagPrefix[ind]..tostring(index) 
          end

          initNoteSkins(noteSkin_arrowTag(1), noteSkin_arrowImage, 'left', 'arrowLEFT', 790)
          initNoteSkins(noteSkin_arrowTag(2), noteSkin_arrowImage, 'down', 'arrowDOWN', 790 + 115)
          initNoteSkins(noteSkin_arrowTag(3), noteSkin_arrowImage, 'up', 'arrowUP', 790 + 115 * 2)
          initNoteSkins(noteSkin_arrowTag(4), noteSkin_arrowImage, 'right', 'arrowRIGHT', 790 + 115 * 3)

          table.insert(offsetsConfrim.left,  {getProperty(noteSkin_arrowTag(1)..'.offset.x'), getProperty(noteSkin_arrowTag(1)..'.offset.y')})
          table.insert(offsetsConfrim.down,  {getProperty(noteSkin_arrowTag(2)..'.offset.x'), getProperty(noteSkin_arrowTag(2)..'.offset.y')})
          table.insert(offsetsConfrim.up,    {getProperty(noteSkin_arrowTag(3)..'.offset.x'), getProperty(noteSkin_arrowTag(3)..'.offset.y')})
          table.insert(offsetsConfrim.right, {getProperty(noteSkin_arrowTag(4)..'.offset.x'), getProperty(noteSkin_arrowTag(4)..'.offset.y')})

          for q = 1, #offsetsConfrim.left do
               addOffset(noteSkin_arrowTag(1), 'left',  offsetsConfrim.left[q][1],  offsetsConfrim.left[q][2])
               addOffset(noteSkin_arrowTag(2), 'down',  offsetsConfrim.down[q][1],  offsetsConfrim.down[q][2])
               addOffset(noteSkin_arrowTag(3), 'up',    offsetsConfrim.up[q][1],    offsetsConfrim.up[q][2])
               addOffset(noteSkin_arrowTag(4), 'right', offsetsConfrim.right[q][1], offsetsConfrim.right[q][2])
          end 
     end
end

local noteSave_curPage
local noteSave_highlightPosX, noteSave_highlightPosY
local noteSave_selectedName, noteSave_selectedPos
local noteSave_checkboxPlayer, noteSave_checkboxOpponent
local noteSave_checkboxSelectedPlayer, noteSave_checkboxSelectedOpponent
local noteSave_checkboxVisiblePlayer, noteSave_checkboxVisibleOpponent
function onCreate()
     initSaveData('noteskin_selector-save', 'noteskin_selector')
     noteSave_curPage          = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_curPage'), 1)
     noteSave_highlightPosX    = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_highlightPosX'), 42.8 - 30)
     noteSave_highlightPosY    = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_highlightPosY'), 158)
     noteSave_selectedName     = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_selectedName'), 'Normal')
     noteSave_selectedPos      = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_selectedPos'), 1)
     noteSave_checkboxPlayer   = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_checkboxPlayer'), 1)
     noteSave_checkboxOpponent = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_checkboxOpponent'), 1)
     noteSave_checkboxSelectedPlayer   = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_checkboxSelectedPlayer'), {100, 165})
     noteSave_checkboxSelectedOpponent = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_checkboxSelectedOpponent'), {100, 235})
     noteSave_checkboxVisiblePlayer    = altValue(getDataFromSave('noteskin_selector-save', 'cPlayer'), false)
     noteSave_checkboxVisibleOpponent  = altValue(getDataFromSave('noteskin_selector-save', 'cOpponent'), false)
end

local function saveSelectionLocation()
     local perMultiply = 0
     for perPage = 1, noteSave_curPage do
          if perPage >= 3 then
               perMultiply = perMultiply + 1
          end
     end

     local noteSkins_decrement = 0
     for perSkinInd = 1, #getNoteSkins() do
          if noteSave_curPage == 1 then --! DO NOT DELETE
               break
          end
          if noteSave_curPage >= 3 then
               noteSkins_decrement = 340 * perMultiply
          end

          local noteSkins_tagGetY        = 'noteSkins_hitbox-'..tostring(perSkinInd)..'.y'
          local noteSkins_tagDisplayGetY = 'noteSkins_display-'..tostring(perSkinInd)..'.y'
          setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) - 340 * noteSave_curPage - noteSkins_decrement)
          setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) - 340 * noteSave_curPage - noteSkins_decrement)
     end
end

local increValue_noteskins
local minimumLimit_noteskins = false
local maximumLimit_noteskins = false
function onCreatePost()
     createNoteSkins()
     saveSelectionLocation()

     setProperty('checkbox_playerSelect.x', noteSave_checkboxSelectedPlayer[1])
     setProperty('checkbox_playerSelect.y', noteSave_checkboxSelectedPlayer[2])
     setProperty('checkbox_opponentSelect.x', noteSave_checkboxSelectedOpponent[1])
     setProperty('checkbox_opponentSelect.y', noteSave_checkboxSelectedOpponent[2])

     setProperty('skinHitbox-highlight.x', noteSave_highlightPosX)
     setProperty('skinHitbox-highlight.y', noteSave_highlightPosY)
     setTextString('skin_page', 'Page '..noteSave_curPage..' / '..calculatePageLimit(getNoteSkins()))
     setTextString('skin_name', noteSave_selectedName)
     increValue_noteskins = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_curPage'), 1)
end

local function traverseNoteSkins()
     if keyboardJustPressed('UP') and maximumLimit_noteskins == false then
          increValue_noteskins = increValue_noteskins - 1
          playSound('scrollMenu', 0.3)

          setTextString('skin_page', 'Page '..increValue_noteskins..' / '..calculatePageLimit(getNoteSkins()))
          setDataFromSave('noteskin_selector-save', 'noteSave_curPage', increValue_noteskins)
     end
     if keyboardJustPressed('DOWN') and minimumLimit_noteskins == false then
          increValue_noteskins = increValue_noteskins + 1
          playSound('scrollMenu', 0.3)

          setTextString('skin_page', 'Page '..increValue_noteskins..' / '..calculatePageLimit(getNoteSkins()))
          setDataFromSave('noteskin_selector-save', 'noteSave_curPage', increValue_noteskins)
     end

     if increValue_noteskins <= 1 then
          maximumLimit_noteskins = true
     else
          maximumLimit_noteskins = false
     end
     if increValue_noteskins >= calculatePageLimit(getNoteSkins()) then
          minimumLimit_noteskins = true
     else
          minimumLimit_noteskins = false
     end
end

local noteSkins_getNoteSkins = getNoteSkins()
local noteSkins_selectedPos  = 1
local noteSkins_bgPos        = 340 * 2
local noteSkins_selectOffset = 7
local noteSkins_selectPos = 1
local function selectionNoteSkins()
     for k = 1, #noteSkins_getNoteSkins do
          local noteSkins_getPos = calculatePosition(noteSkins_getNoteSkins)[k]
          local noteSkins_tagGetY = 'noteSkins_hitbox-'..tostring(k)..'.y'
          local noteSkins_tagDisplayGetY = 'noteSkins_display-'..tostring(k)..'.y'

          if clickObject('noteSkins_hitbox-'..tostring(k)) then
               playSound('select', 1)
               playAnim('skinHitbox-highlight', 'selecting', true)
               setTextString('skin_name', getNoteSkinNames()[k])

               local noteskinHitbox_highlightX = noteSkins_getPos[1] - 8 + 0.8
               local noteskinHitbox_highlightY = getProperty(noteSkins_tagGetY) - noteSkins_selectOffset
               setProperty('skinHitbox-highlight.x', noteskinHitbox_highlightX)
               setProperty('skinHitbox-highlight.y', noteskinHitbox_highlightY)
               
               noteSkins_selectedPos = k
               setDataFromSave('noteskin_selector-save', 'noteSave_highlightPosX', noteskinHitbox_highlightX)
               setDataFromSave('noteskin_selector-save', 'noteSave_selectedName', getNoteSkinNames()[k])
               setDataFromSave('noteskin_selector-save', 'noteSave_selectedPos', k)
          end

          local noteSave_selectedPos = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_selectedPos'), noteSkins_selectedPos)
          local noteSkins_arrows = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          for a,b in next, noteSkins_arrows do
               if k ~= noteSave_selectedPos then
                    removeLuaSprite('noteSkins'..b..tostring(k), false)
               else
                    addLuaSprite('noteSkins'..b..tostring(k))
               end
          end
          
          if keyboardJustPressed('UP') and maximumLimit_noteskins == false then
               setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) + noteSkins_bgPos)
               setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) + noteSkins_bgPos)
               setProperty('skinHitbox-highlight.y', getProperty('noteSkins_hitbox-'..tostring(noteSave_selectedPos)..'.y') - noteSkins_selectOffset)
          end
          if keyboardJustPressed('DOWN') and minimumLimit_noteskins == false then
               setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) - noteSkins_bgPos)
               setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) - noteSkins_bgPos)
               setProperty('skinHitbox-highlight.y', getProperty('noteSkins_hitbox-'..tostring(noteSave_selectedPos)..'.y') - noteSkins_selectOffset)
          end

          setDataFromSave('noteskin_selector-save', 'noteSave_highlightPosY', getProperty('noteSkins_hitbox-'..tostring(noteSave_selectedPos)..'.y') - noteSkins_selectOffset)
     end
     
     traverseNoteSkins()
end

local confirmPath = 'mods/NoteSkin Selector Remastered/jsons/offsets_confirm.json'
local pressedPath = 'mods/NoteSkin Selector Remastered/jsons/offsets_pressed.json'

local noteSkins_offsets_confirm = getTextFileContent(confirmPath):gsub('//%s*.-(\n)', '%1')
local noteSkins_offsets_pressed = getTextFileContent(pressedPath):gsub('//%s*.-(\n)', '%1')
local noteSkins_jsonConfirm = json.decode(noteSkins_offsets_confirm)
local noteSkins_jsonPressed = json.decode(noteSkins_offsets_pressed)

local function initNoteAnim(key, ind, dir, offsets, animType)
     if keyboardJustPressed(getKeyBinds(key)) then
          addOffset('noteSkins_arrow'..dir..'-'..ind, dir:lower()..animType, offsets[1], offsets[2])
          playAnim('noteSkins_arrow'..dir..'-'..ind, dir:lower()..animType)
     end
     if keyboardReleased(getKeyBinds(key)) then
          playAnim('noteSkins_arrow'..dir..'-'..ind, dir:lower())
     end
end

local changeAnimType = true
local function setNoteAnim()
     if keyboardJustPressed('LBRACKET') and changeAnimType == true then
          addLuaSprite('ui_notePressed')
          removeLuaSprite('ui_noteConfirm', false)
          changeAnimType = false
     elseif keyboardJustPressed('LBRACKET') and changeAnimType == false then
          addLuaSprite('ui_noteConfirm')
          removeLuaSprite('ui_notePressed', false)
          changeAnimType = true
     end

     for k = 1, #noteSkins_getNoteSkins do
          local noteSave_selectedPos = getDataFromSave('noteskin_selector-save', 'noteSave_selectedPos') or noteSkins_selectedPos
          local noteSkins_arrows = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          if k == noteSave_selectedPos then
               local offsets = function(json, dir, def)
                    local a = noteSkins_getNoteSkins[k]:gsub('NOTE_assets%-', ''):lower()
                    local b = a == 'note_assets' and 'normal' or a

                    local x = json[dir][b] ~= nil and json[dir][b][1] or def[1]
                    local y = json[dir][b] ~= nil and json[dir][b][2] or def[2]
                    return {x, y}
               end

               if changeAnimType == true then
                    initNoteAnim(0, k, 'Left',  offsets(noteSkins_jsonConfirm, 'left',  {45.5, 48}), 'Confirm')
                    initNoteAnim(1, k, 'Down',  offsets(noteSkins_jsonConfirm, 'down',  {50, 48.5}), 'Confirm')
                    initNoteAnim(2, k, 'Up',    offsets(noteSkins_jsonConfirm, 'up',    {50, 48})  , 'Confirm')
                    initNoteAnim(3, k, 'Right', offsets(noteSkins_jsonConfirm, 'right', {46, 49.5}), 'Confirm')
               else
                    initNoteAnim(0, k, 'Left',  offsets(noteSkins_jsonPressed, 'left',  {20, 20}), 'Pressed')
                    initNoteAnim(1, k, 'Down',  offsets(noteSkins_jsonPressed, 'down',  {20, 20}), 'Pressed')
                    initNoteAnim(2, k, 'Up',    offsets(noteSkins_jsonPressed, 'up',    {20, 20}), 'Pressed')
                    initNoteAnim(3, k, 'Right', offsets(noteSkins_jsonPressed, 'right', {20, 20}), 'Pressed')
               end
          end
     end
end

local antiRepeat = false
local function saveDataWhenExit()
     local doubleSaveData = function()
          local noteSaves = {
               'noteSave_highlightPosX', 'noteSave_highlightPosY', 'noteSave_selectedName', 'noteSave_selectedPos',
               'noteSave_curPage', 'noteSave_checkboxPlayer', 'noteSave_checkboxOpponent', 'noteSave_checkboxSelectedPlayer',
               'noteSave_checkboxSelectedOpponent', 'noteSave_checkboxVisiblePlayer', 'noteSave_checkboxVisibleOpponent'
          }

          for k,v in next, noteSaves do
               setDataFromSave('noteskin_selector-save', v, getDataFromSave('noteskin_selector-save', v))
          end
          flushSaveData('noteskin_selector-save')
     end

     if keyboardJustPressed('ESCAPE') then
          doubleSaveData()
     end
     if not objectsOverlap('windowGameHitbox', 'mouse_hitbox') then
          doubleSaveData()
          antiRepeat = true
     end
     if objectsOverlap('windowGameHitbox', 'mouse_hitbox') then
          antiRepeat = false
     end
end

local isClicked = {false, false}
local function checkBoxAnimation()
     local char = {'player', 'opponent'}
     local checkBoxSwitch = function(curInd)
          if clickObject('checkbox_'..char[curInd]) and isClicked[curInd] == false then
               addLuaSprite('checkbox_'..char[curInd]..'Select')
               playAnim('checkbox_'..char[curInd], 'checking', true)
               isClicked[curInd] = true

               setDataFromSave('noteskin_selector-save', 'noteSave_checkboxVisible'..string.capAt(char[curInd], 1,1), true)
          elseif clickObject('checkbox_'..char[curInd]) and isClicked[curInd] == true then
               removeLuaSprite('checkbox_'..char[curInd]..'Select', false)
               playAnim('checkbox_'..char[curInd], 'unchecking', true)
               isClicked[curInd] = false

               setDataFromSave('noteskin_selector-save', 'noteSave_checkboxVisible'..string.capAt(char[curInd], 1,1), false)
          end
     end

     local checkBoxFinished = function(checkbox_charInd)
          local checkboxAnimFinish  = getProperty('checkbox_'..char[checkbox_charInd]..'.animation.finished')
          local checkboxCurAnimName = getProperty('checkbox_'..char[checkbox_charInd]..'.animation.curAnim.name')

          if checkboxAnimFinish and checkboxCurAnimName == 'unchecking' then
               playAnim('checkbox_'..char[checkbox_charInd], 'unchecked', true)
          end
     end

     checkBoxSwitch(1)
     checkBoxFinished(1)

     checkBoxSwitch(2)
     checkBoxFinished(2)
end

local checkbox_selectedPos = 1
local isDisabled = {true, true}
local function checkBoxSave()
     for k = 1, #noteSkins_getNoteSkins do
          if clickObject('noteSkins_hitbox-'..tostring(k)) then    
               if k ~= noteSave_checkboxPlayer then
                    playAnim('checkbox_player', 'unchecked')
                    isClicked[1] = false
               else
                    playAnim('checkbox_player', 'checked')
                    isClicked[1] = true
               end
               if k ~= noteSave_checkboxOpponent then
                    playAnim('checkbox_opponent', 'unchecked')
                    isClicked[2] = false
               else
                    playAnim('checkbox_opponent', 'checked')
                    isClicked[2] = true
               end

               checkbox_selectedPos = k
               setDataFromSave('noteskin_selector-save', 'noteSave_checkboxSelectedPos', k)
          end
     end

     local checkboxChar_setPos = function(charInd, x, y)
          local chars  = {'player', 'opponent'}
          local charsY = {0, 70}
          setProperty('checkbox_'..chars[charInd]..'Select.x', x + 80)
          setProperty('checkbox_'..chars[charInd]..'Select.y', y + charsY[charInd])
     end

     local noteSave_checkboxSelectedPos = altValue(getDataFromSave('noteskin_selector-save', 'noteSave_checkboxSelectedPos'), checkbox_selectedPos)
     local checkboxChar_getPos = calculatePosition(noteSkins_getNoteSkins)[noteSave_checkboxSelectedPos]
     if clickObject('checkbox_player') and isClicked[1] == true then
          noteSave_checkboxPlayer = checkbox_selectedPos
          isDisabled[1] = false

          checkboxChar_setPos(1, checkboxChar_getPos[1], checkboxChar_getPos[2])
          setDataFromSave('noteskin_selector-save', 'noteSave_checkboxSelectedPlayer', {checkboxChar_getPos[1] + 80, checkboxChar_getPos[2]})
          setDataFromSave('noteskin_selector-save', 'noteSave_curNoteSkinPlayer', noteSkins_getNoteSkins[checkbox_selectedPos])
     elseif clickObject('checkbox_player') and isClicked[1] == false then
          noteSave_checkboxPlayer = 0
     end
     if clickObject('checkbox_opponent') and isClicked[2] == true then
          noteSave_checkboxOpponent = checkbox_selectedPos
          isDisabled[2] = false

          checkboxChar_setPos(2, checkboxChar_getPos[1], checkboxChar_getPos[2])
          setDataFromSave('noteskin_selector-save', 'noteSave_checkboxSelectedOpponent', {checkboxChar_getPos[1] + 80, checkboxChar_getPos[2] + 70})
          setDataFromSave('noteskin_selector-save', 'noteSave_curNoteSkinOpponent', noteSkins_getNoteSkins[checkbox_selectedPos])
     elseif clickObject('checkbox_opponent') and isClicked[1] == false then
          noteSave_checkboxOpponent = 0
     end
     
     if noteSave_selectedPos == noteSave_checkboxPlayer and isDisabled[1] == true then
          playAnim('checkbox_player', 'checked', false)
          isClicked[1] = true; isDisabled[1] = false
     end
     if noteSave_selectedPos == noteSave_checkboxOpponent and isDisabled[2] == true then
          playAnim('checkbox_opponent', 'checked', false)
          isClicked[2] = true; isDisabled[2] = false
     end

     local noteSkins_getNoteSkinsWith0 = setmetatable(noteSkins_getNoteSkins, {
          __index = function(self, ind)
               if ind == 0 then return 'none' end
          end
     })
     setDataFromSave('noteskin_selector-save', 'noteSave_checkboxPlayer', noteSave_checkboxPlayer)
     setDataFromSave('noteskin_selector-save', 'noteSave_checkboxOpponent', noteSave_checkboxOpponent)
end

function onUpdate(elapsed)
     selectionNoteSkins()
     setNoteAnim()
     saveDataWhenExit()

     checkBoxAnimation()
     checkBoxSave()
end