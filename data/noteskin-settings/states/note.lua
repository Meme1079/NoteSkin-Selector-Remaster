local funkinlua = require 'mods.NoteSkin Selector Remastered.modules.funkinlua'
local globals   = require 'mods.NoteSkin Selector Remastered.modules.globals'
local string    = require 'mods.NoteSkin Selector Remastered.libraries.string'
local json      = require 'mods.NoteSkin Selector Remastered.libraries.json.json'

local setProperties = funkinlua.setProperties
local setSave = funkinlua.setSave
local getSave = funkinlua.getSave
local ternary = funkinlua.ternary

initSaveData('noteselector', 'NoteSkin Selector')
local saveNote_noteStateIndex             = ternary(nil, getSave('noteStateIndex'), 1)
local saveNote_noteStatePage              = ternary(nil, getSave('noteStatePage'), 1)
local saveNote_noteStateSkins             = ternary(nil, getSave('noteStateSkins'), 'normal')
local saveNote_noteCheckPlayerIndex       = ternary(nil, getSave('noteCheckPlayerIndex'), 0)
local saveNote_noteCheckOpponentIndex     = ternary(nil, getSave('noteCheckOpponentIndex'), 0)
local saveNote_noteCheckPlayerSelectPos   = ternary(nil, getSave('noteCheckPlayerSelectPos'), {95, 215})
local saveNote_noteCheckOpponentSelectPos = ternary(nil, getSave('noteCheckOpponentSelectPos'), {95, 215 - 80})

local getNotes = globals.getSkins('note')
local getNoteIndex = saveNote_noteStateIndex
local function getCurrentIndex()
     for k = 1, #getNotes do
          if funkinlua.clickObject('noteHitbox-'..tostring(k)) then
               getNoteIndex = k
          end
     end
     return getNoteIndex
end

local function loadsaveNote(num)
     local calculatePosition = 340 * ((num - 1) * 2)
     for perSkinInd = 1, #getNotes do
          local hitboxTagY  = ('noteHitbox-${ind}.y'):interpol({ind = perSkinInd})
          local displayTagY = ('noteDisplay-${ind}.y'):interpol({ind = perSkinInd})
          setProperty(hitboxTagY,  getProperty(hitboxTagY) - calculatePosition)
          setProperty(displayTagY, getProperty(displayTagY) - calculatePosition)
     end

     local maximumLimit_noteskins = globals.calculatePageLimit(globals.getSkins('note'))
     local skinPageElems = {curPage = num, maxPage = maximumLimit_noteskins}
     setTextString('uiSkinPage', ('Page ${curPage} / ${maxPage}'):interpol(skinPageElems))
     setTextString('uiSkinName', globals.getSkinNames('note')[getCurrentIndex()])

     local hitbox = ('noteHitbox-${curInd}'):interpol({curInd = getCurrentIndex()})
     setProperties('selectDisplay', {x = getProperty(hitbox..'.x') - 7, y = getProperty(hitbox..'.y') - 7})
end

local function loadsaveCheckboxIcon()
     local checkboxPlayerSlctPos, checkboxOpponentSlctPos = saveNote_noteCheckPlayerSelectPos, saveNote_noteCheckOpponentSelectPos
     local checkboxPlayerPos   = {ternary(nil, checkboxPlayerSlctPos[1], 95), ternary(nil, checkboxPlayerSlctPos[2], 215)}
     local checkboxOpponentPos = {ternary(nil, checkboxOpponentSlctPos[1], 95), ternary(nil, checkboxOpponentSlctPos[2], 215 - 80)}
     setProperties('checkbox_playerSelect',   {x = checkboxPlayerPos[1], y = checkboxPlayerPos[2]})
     setProperties('checkbox_opponentSelect', {x = checkboxOpponentPos[1], y = checkboxOpponentPos[2]})

     if saveNote_noteCheckPlayerIndex == 0 then
          removeLuaSprite('checkbox_playerSelect', false)
     else
          addLuaSprite('checkbox_playerSelect', false)
     end
     if saveNote_noteCheckOpponentIndex == 0 then
          removeLuaSprite('checkbox_opponentSelect', false)
     else
          addLuaSprite('checkbox_opponentSelect', false)
     end
end

local function initNoteSkins(tag, image, nameAnim, prefixAnim, xpos)
     makeAnimatedLuaSprite(tag, image, xpos - 15, 175 + -30)
     addAnimationByPrefix(tag, 'leftConfirm', 'left confirm', 24, false)
     addAnimationByPrefix(tag, 'downConfirm', 'down confirm', 24, false)
     addAnimationByPrefix(tag, 'upConfirm', 'up confirm', 24, false)
     addAnimationByPrefix(tag, 'rightConfirm', 'right confirm', 24, false)
     addAnimationByPrefix(tag, 'leftPressed', 'left press', 24, false)
     addAnimationByPrefix(tag, 'downPressed', 'down press', 24, false)
     addAnimationByPrefix(tag, 'upPressed', 'up press', 24, false)
     addAnimationByPrefix(tag, 'rightPressed', 'right press', 24, false)
     addAnimationByPrefix(tag, 'leftColored', 'purple0', 24, false)
     addAnimationByPrefix(tag, 'downColored', 'blue0', 24, false)
     addAnimationByPrefix(tag, 'upColored', 'green0', 24, false)
     addAnimationByPrefix(tag, 'rightColored', 'red0', 24, false)
     addAnimationByPrefix(tag, nameAnim, prefixAnim, 24, false)
     setGraphicSize(tag, 110, 110)
     setObjectCamera(tag, 'camHUD')
     addLuaSprite(tag, false)
end

local function offsetNoteSkins(offsetsTable, image, index)
     local getDirectTag = function(ind)
          local prefixes = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          return ('noteSkins${direct}${ind}'):interpol({direct = prefixes[ind], ind = index}) 
     end
     local getDirectOffsets = function(ind)
          return {getProperty(getDirectTag(ind)..'.offset.x'), getProperty(getDirectTag(ind)..'.offset.y')}
     end

     initNoteSkins(getDirectTag(1), image, 'left', 'arrowLEFT', 790)
     initNoteSkins(getDirectTag(2), image, 'down', 'arrowDOWN', 790 + 115)
     initNoteSkins(getDirectTag(3), image, 'up', 'arrowUP', 790 + 115 * 2)
     initNoteSkins(getDirectTag(4), image, 'right', 'arrowRIGHT', 790 + 115 * 3)

     table.insert(offsetsTable.left,  getDirectOffsets(1))
     table.insert(offsetsTable.down,  getDirectOffsets(2))
     table.insert(offsetsTable.up,    getDirectOffsets(3))
     table.insert(offsetsTable.right, getDirectOffsets(4))

     for q = 1, #offsetsTable.left do
          addOffset(getDirectTag(1), 'left',  offsetsTable.left[q][1],  offsetsTable.left[q][2])
          addOffset(getDirectTag(2), 'down',  offsetsTable.down[q][1],  offsetsTable.down[q][2])
          addOffset(getDirectTag(3), 'up',    offsetsTable.up[q][1],    offsetsTable.up[q][2])
          addOffset(getDirectTag(4), 'right', offsetsTable.right[q][1], offsetsTable.right[q][2])
     end 
end

local function createNoteSkins()
     local offsets = {left = {}, down = {}, up = {}, right = {}}
     for index, value in next, globals.getSkins('note') do
          local getCurrentPos   = globals.calculatePosition(globals.getSkins('note'))[index]
          local getCurrentNotes = 'noteSkins/'..value

          local hitboxTag = 'noteHitbox-'..index
          makeLuaSprite(hitboxTag, nil, getCurrentPos[1], getCurrentPos[2] + -20 - 9.5)
          makeGraphic(hitboxTag, 130, 130, '000000')
          setObjectCamera(hitboxTag, 'camOther')
          setProperty(hitboxTag..'.visible', false)
          addLuaSprite(hitboxTag)

          local displayTag = 'noteDisplay-'..index
          makeAnimatedLuaSprite(displayTag, getCurrentNotes, getCurrentPos[1] + 9.5, getCurrentPos[2] + -20)
          addAnimationByPrefix(displayTag, 'up', 'arrowUP', 24, false)
          setGraphicSize(displayTag, 110, 110)
          setObjectCamera(displayTag, 'camOther')
          precacheImage(getCurrentNotes)
          addLuaSprite(displayTag, false)

          offsetNoteSkins(offsets, getCurrentNotes, index)          
     end
end

local function errorNoteSkinChecking()
     for k,v in pairs(getNotes) do
          if v ~= saveNote_noteStateSkins[k] then
               setProperty('camGame.visible', false)
               setProperty('camHUD.visible', false)
               setProperty('camOther.visible', false)
               restartSong(true)

               setSave('noteStateIndex', 1)
               setSave('noteStatePage', 1)
               setSave('noteCheckPlayerIndex', 0)
               setSave('noteCheckOpponentIndex', 0)
               setSave('noteCheckPlayerSelectPos', {95, 215})
               setSave('noteCheckOpponentSelectPos', {95, 215 - 80})
          end
     end
end

function onCreate()
     makeAnimatedLuaSprite('selectDisplay', 'ui/selection', 12.8, 128)
     addAnimationByPrefix('selectDisplay', 'selecting', 'selected', 3)
     addAnimationByIndices('selectDisplay', 'selecting-static', 'selected', '0', 1)
     playAnim('selectDisplay', 'selecting')
     setObjectCamera('selectDisplay', 'camHUD')
     addLuaSprite('selectDisplay')

     -- Checkboxes & Texts --

     local checkboxConstY = 320
     local checkboxConstX = 775
     makeAnimatedLuaSprite('checkbox_player', 'checkboxanim', checkboxConstX, checkboxConstY)
     setObjectCamera('checkbox_player', 'camHUD')
     setGraphicSize('checkbox_player', 55, 55)
     addAnimationByPrefix('checkbox_player', 'unchecked', 'checkbox0', 24, false)
     addAnimationByPrefix('checkbox_player', 'unchecking', 'checkbox anim reverse', 24, false)
     addAnimationByPrefix('checkbox_player', 'checking', 'checkbox anim0', 24, false)
     addAnimationByPrefix('checkbox_player', 'checked', 'checkbox finish', 24, false)
     addOffset('checkbox_player', 'unchecked', 18, 16.5)
     addOffset('checkbox_player', 'unchecking', 31.8, 31.3)
     addOffset('checkbox_player', 'checking', 37, 29)
     addOffset('checkbox_player', 'checked', 19.5, 22)
     playAnim('checkbox_player', 'unchecked', true)
     addLuaSprite('checkbox_player')

     makeAnimatedLuaSprite('checkbox_opponent', 'checkboxanim', checkboxConstX + 220, checkboxConstY)
     setObjectCamera('checkbox_opponent', 'camHUD')
     setGraphicSize('checkbox_opponent', 55, 55)
     addAnimationByPrefix('checkbox_opponent', 'unchecked', 'checkbox0', 24, false)
     addAnimationByPrefix('checkbox_opponent', 'unchecking', 'checkbox anim reverse', 24, false)
     addAnimationByPrefix('checkbox_opponent', 'checking', 'checkbox anim0', 24, false)
     addAnimationByPrefix('checkbox_opponent', 'checked', 'checkbox finish', 24, false)
     addOffset('checkbox_opponent', 'unchecked', 18, 16.5)
     addOffset('checkbox_opponent', 'unchecking', 31.8, 31.3)
     addOffset('checkbox_opponent', 'checking', 37, 29)
     addOffset('checkbox_opponent', 'checked', 19.5, 22)
     playAnim('checkbox_opponent', 'unchecked', true)
     addLuaSprite('checkbox_opponent')

     makeLuaText('checkbox_playerText', 'Player', 0, checkboxConstX + 80, checkboxConstY + 20)
     setTextColor('checkbox_playerText', '31b0d1')
     setTextSize('checkbox_playerText', 30)
     setTextFont('checkbox_playerText', 'phantummuff.ttf')
     setObjectCamera('checkbox_playerText', 'camHUD')
     setObjectOrder('checkbox_playerText', getObjectOrder('checkbox_player') - 2)
     addLuaText('checkbox_playerText')

     makeLuaText('checkbox_opponentText', 'Opponent', 0, checkboxConstX + 220 + ((80 * 2) / 2), checkboxConstY + 20)
     setTextColor('checkbox_opponentText', 'af66ce')
     setTextSize('checkbox_opponentText', 30)
     setTextFont('checkbox_opponentText', 'phantummuff.ttf')
     setObjectCamera('checkbox_opponentText', 'camHUD')
     setObjectOrder('checkbox_opponentText', getObjectOrder('checkbox_opponent') - 2)
     addLuaText('checkbox_opponentText')

     makeLuaSprite('checkbox_playerSelect', 'ui/icons/playerIcon', 95, 215)
     setGraphicSize('checkbox_playerSelect', 57, 57)
     setObjectCamera('checkbox_playerSelect', 'camOther')
     addLuaSprite('checkbox_playerSelect', true)

     makeLuaSprite('checkbox_opponentSelect', 'ui/icons/opponentIcon', 95, 215 - 80)
     setGraphicSize('checkbox_opponentSelect', 57, 57)
     setObjectCamera('checkbox_opponentSelect', 'camOther')
     addLuaSprite('checkbox_opponentSelect', true)

     -- Others --

     createNoteSkins()
     loadsaveNote(saveNote_noteStatePage)
     loadsaveCheckboxIcon()

     errorNoteSkinChecking()
     setSave('noteStateSkins', getNotes)
end

local increValue_noteskins = saveNote_noteStatePage
local minimumLimit_noteskins = false
local maximumLimit_noteskins = false
local function traverseNoteSkins()
     completeArrowUp = function()
          startTween('uiArrowUp', 'uiArrowUp', {y = 670}, 0.15, {ease = 'circin'})
     end
     completeArrowDown = function()
          startTween('uiArrowDown', 'uiArrowDown', {y = 670}, 0.15, {ease = 'circin'})
     end

     local maximumPageLimit = globals.calculatePageLimit(globals.getSkins('note'))
     if keyboardJustPressed('UP') and maximumLimit_noteskins == false then
          increValue_noteskins = increValue_noteskins - 1
          startTween('uiArrowUp', 'uiArrowUp', {y = 665}, 0.15, {ease = 'circout', onComplete = 'completeArrowUp'})
          playSound('move', 0.5)

          local elements = {curPage = increValue_noteskins, curLimit = maximumPageLimit}
          setTextString('uiSkinPage', ('Page ${curPage} / ${curLimit}'):interpol(elements))
          setSave('noteStatePage', increValue_noteskins)
     end
     if keyboardJustPressed('DOWN') and minimumLimit_noteskins == false then
          increValue_noteskins = increValue_noteskins + 1
          startTween('uiArrowDown', 'uiArrowDown', {y = 675}, 0.15, {ease = 'circout', onComplete = 'completeArrowDown'})
          playSound('move', 0.5)
          
          local elements = {curPage = increValue_noteskins, curLimit = maximumPageLimit}
          setTextString('uiSkinPage', ('Page ${curPage} / ${curLimit}'):interpol(elements))
          setSave('noteStatePage', increValue_noteskins)
     end

     if increValue_noteskins <= 1 then
          maximumLimit_noteskins = true
          setProperty('uiArrowUp.color', 0xbababa)
     else
          maximumLimit_noteskins = false
          setProperty('uiArrowUp.color', 0xffffff)
     end
     if increValue_noteskins >= maximumPageLimit then
          minimumLimit_noteskins = true
          setProperty('uiArrowDown.color', 0xbababa)
     else
          minimumLimit_noteskins = false
          setProperty('uiArrowDown.color', 0xffffff)
     end
end

local function selectNoteSkins()
     local selectDisplayMoveByPage = 340 * 2
     local selectDisplayOffset     = 7
     for k = 1, #getNotes do
          local getCalculatePosition = globals.calculatePosition(getNotes)[k]
          local hitboxTagY  = ('noteHitbox-${ind}.y'):interpol({ind = k})
          local displayTagY = ('noteDisplay-${ind}.y'):interpol({ind = k})

          if funkinlua.clickObject('noteHitbox-'..tostring(k)) then
               setTextString('uiSkinName', globals.getSkinNames('note')[k])
               playAnim('selectDisplay', 'selecting', true)
               playSound('select', 1)

               setProperty('selectDisplay.x', getCalculatePosition[1] - 8 + 0.8)
               setProperty('selectDisplay.y', getProperty(hitboxTagY) - selectDisplayOffset)
               setSave('noteStateIndex', k)
          end

          local noteSkinPrefixes = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          local noteSkinCurIndex = getCurrentIndex()
          for a,b in next, noteSkinPrefixes do
               local tag = ('noteSkins${prefixes}${ind}'):interpol({prefixes = b, ind = k})
               if k ~= noteSkinCurIndex then
                    removeLuaSprite(tag, false)
               else
                    addLuaSprite(tag, false)
               end
          end

          if keyboardJustPressed('UP') and maximumLimit_noteskins == false then
               setProperty(hitboxTagY,  getProperty(hitboxTagY) + selectDisplayMoveByPage)
               setProperty(displayTagY, getProperty(displayTagY) + selectDisplayMoveByPage)
     
               setProperty('selectDisplay.y', getProperty('noteHitbox-'..tostring(noteSkinCurIndex)..'.y') - selectDisplayOffset)
          end
          if keyboardJustPressed('DOWN') and minimumLimit_noteskins == false then
               setProperty(hitboxTagY,  getProperty(hitboxTagY) - selectDisplayMoveByPage)
               setProperty(displayTagY, getProperty(displayTagY) - selectDisplayMoveByPage)
     
               setProperty('selectDisplay.y', getProperty('noteHitbox-'..tostring(noteSkinCurIndex)..'.y') - selectDisplayOffset)
          end
     end

     traverseNoteSkins()
end

local noteOffsetPath  = 'mods/NoteSkin Selector Remastered/jsons/note/offsets.json'
local noteOffsetFetch = funkinlua.getTextFileContent(noteOffsetPath):gsub('//%s*.-(\n)', '%1')
local noteOffsetJson  = json.parse(noteOffsetFetch, true)
local function initNoteAnim(key, ind, dir, animType, offsets)
     local tag    = ('noteSkins_arrow${direct}-${ind}'):interpol({direct = dir:upperAtStart(), ind = ind})
     local prefix = dir:lower()..animType:upperAtStart()
     if key == nil and offsets == nil then
          playAnim(tag, prefix)
          return;
     end

     if keyboardJustPressed(getKeyBinds(key)) then
          addOffset(tag, prefix, offsets[1], offsets[2])
          playAnim(tag, prefix)
     end
     if keyboardReleased(getKeyBinds(key)) then
          playAnim(tag, dir:lower())
     end
end

local changeBackNormal = false
local changeAnimType   = 0
local function setNoteAnim()
     if keyboardJustPressed('LBRACKET') and changeAnimType == 0 then
          playAnim('uiNoteAnimations', 'pressed', true)
          playSound('ding', 0.5)
          changeAnimType = 1
     elseif keyboardJustPressed('LBRACKET') and changeAnimType == 1 then
          playAnim('uiNoteAnimations', 'colored', true)
          playSound('ding', 0.5)
          changeAnimType = 2
     elseif keyboardJustPressed('LBRACKET') and changeAnimType == 2 then
          playAnim('uiNoteAnimations', 'confirm', true)
          playSound('ding', 0.5)
          changeAnimType = 0
     end

     for k = 1, #getNotes do
          if k == getCurrentIndex() then
               local offsets = function(json, dir, def, anim)
                    local a = getNotes[k]:gsub('NOTE_assets%-', ''):lower()
                    local b = a == 'note_assets' and 'normal' or a

                    local x = json[b][anim][dir] ~= nil and json[b][anim][dir][1] or def[1]
                    local y = json[b][anim][dir] ~= nil and json[b][anim][dir][2] or def[2]
                    return {x, y}
               end
               local changeNoteAnims = function(animType, defPos, change)
                    if change == true then
                         initNoteAnim(nil, k, 'left',  animType)
                         initNoteAnim(nil, k, 'down',  animType)
                         initNoteAnim(nil, k, 'up',    animType)
                         initNoteAnim(nil, k, 'right', animType)
                         return;
                    end
                    initNoteAnim(0, k, 'left',  animType, offsets(noteOffsetJson, 'left',  defPos[1], animType))
                    initNoteAnim(1, k, 'down',  animType, offsets(noteOffsetJson, 'down',  defPos[2], animType))
                    initNoteAnim(2, k, 'up',    animType, offsets(noteOffsetJson, 'up',    defPos[3], animType))
                    initNoteAnim(3, k, 'right', animType, offsets(noteOffsetJson, 'right', defPos[4], animType))
               end

               if funkinlua.clickObject('noteHitbox-'..tostring(k)) then -- DO NOT DELETE
                    changeNoteAnims('', nil, true)
               end

               if changeAnimType == 0 then
                    if changeBackNormal == false then
                         changeNoteAnims('', nil, true)
                         changeBackNormal = true
                    end
                    changeNoteAnims('confirm', {{45.5, 48}, {50, 48.5}, {50, 48}, {46, 49.5}})
               elseif changeAnimType == 1 then
                    changeNoteAnims('pressed', {{20, 20}, {20, 20}, {20, 20}, {20, 20}})
               elseif changeAnimType == 2 then
                    changeNoteAnims('colored', nil, true)
                    changeBackNormal = false
               end
          end
     end
end

local isClicked = {false, false}
local function controlCheckbox()
     local char = {'player', 'opponent'}
     local switchStates = function(curInd)
          local tagChar       = 'checkbox_'..char[curInd]
          local tagCharSelect = 'checkbox_'..char[curInd]..'Select'
          if funkinlua.clickObject(tagChar) and isClicked[curInd] == false then
               playSound('scrollMenu', 0.6)
               playAnim(tagChar, 'checking', true)
               addLuaSprite(tagCharSelect)

               isClicked[curInd] = true
          elseif funkinlua.clickObject(tagChar) and isClicked[curInd] == true then
               playSound('cancel', 0.5)
               playAnim(tagChar, 'unchecking', true)
               removeLuaSprite(tagCharSelect, false)

               isClicked[curInd] = false
          end
     end
     local animFinished = function(checkbox_charInd)
          local tagChar = 'checkbox_'..char[checkbox_charInd]
          local checkboxAnimFinish  = getProperty(tagChar..'.animation.finished')
          local checkboxCurAnimName = getProperty(tagChar..'.animation.curAnim.name')

          if checkboxAnimFinish and checkboxCurAnimName == 'unchecking' then
               playAnim(tagChar, 'unchecked', true)
          end
     end

     for i = 1, 2 do
          switchStates(i); animFinished(i)
     end
end

local isDisabled = {true, true}
local checkboxPlayerIndex   = saveNote_noteCheckPlayerIndex
local checkboxOpponentIndex = saveNote_noteCheckOpponentIndex
local function animateCheckbox()
     for k = 1, #getNotes do
          if funkinlua.clickObject('noteHitbox-'..tostring(k)) then    
               if k ~= checkboxPlayerIndex then
                    playAnim('checkbox_player', 'unchecked')
                    isClicked[1] = false
               else
                    playAnim('checkbox_player', 'checked')
                    isClicked[1] = true
               end
               if k ~= checkboxOpponentIndex then
                    playAnim('checkbox_opponent', 'unchecked')
                    isClicked[2] = false
               else
                    playAnim('checkbox_opponent', 'checked')
                    isClicked[2] = true
               end
          end
     end
    
     local setCheckIcons = function(charInd, checkboxInd)
          local chars  = {'player', 'opponent'}
          local constY = {80, 0}

          local hitbox   = ('noteHitbox-${ind}'):interpol({ind = checkboxInd})
          local checkbox = ('checkbox_${char}Select'):interpol({char = chars[charInd]})
          setProperty(checkbox..'.x', getProperty(hitbox..'.x') + 75)
          setProperty(checkbox..'.y', getProperty(hitbox..'.y') + constY[charInd])
     end
     local checkboxPos = function(charInd)
          local chars    = {'player', 'opponent'}
          local checkbox = ('checkbox_${char}Select'):interpol({char = chars[charInd]})
          return {getProperty(checkbox..'.x'), getProperty(checkbox..'.y')}
     end

     if funkinlua.clickObject('checkbox_player') and isClicked[1] == true then
          checkboxPlayerIndex = getCurrentIndex()
          isDisabled[1] = false

          setCheckIcons(1, checkboxPlayerIndex)
          setSave('noteCurSkinPlayer', getNotes[checkboxPlayerIndex])
          setSave('noteCheckPlayerIndex', checkboxPlayerIndex)
          setSave('noteCheckPlayerSelectPos', checkboxPos(1))
     elseif funkinlua.clickObject('checkbox_player') and isClicked[1] == false then
          checkboxPlayerIndex = 0
          setSave('noteCurSkinPlayer', nil)
          setSave('noteCheckPlayerIndex', checkboxPlayerIndex)
     end
     if funkinlua.clickObject('checkbox_opponent') and isClicked[2] == true then
          checkboxOpponentIndex = getCurrentIndex()
          isDisabled[2] = false

          setCheckIcons(2, checkboxOpponentIndex)
          setSave('noteCurSkinOpponent', getNotes[checkboxOpponentIndex])
          setSave('noteCheckOpponentIndex', checkboxOpponentIndex)
          setSave('noteCheckOpponentSelectPos', checkboxPos(2))
     elseif funkinlua.clickObject('checkbox_opponent') and isClicked[2] == false then
          checkboxOpponentIndex = 0
          setSave('noteCurSkinOpponent', nil)
          setSave('noteCheckOpponentIndex', checkboxOpponentIndex)
     end
     
     if getCurrentIndex() == checkboxPlayerIndex and isDisabled[1] == true then
          playAnim('checkbox_player', 'checked', false)
          isClicked[1] = true; isDisabled[1] = false
     end
     if getCurrentIndex() == checkboxOpponentIndex and isDisabled[2] == true then
          playAnim('checkbox_opponent', 'checked', false)
          isClicked[2] = true; isDisabled[2] = false
     end   
     
     if keyboardJustPressed('UP') and maximumLimit_noteskins == false then
          setProperty('checkbox_playerSelect.y', getProperty('checkbox_playerSelect.y') + 340 * 2)
          setProperty('checkbox_opponentSelect.y', getProperty('checkbox_opponentSelect.y') + 340 * 2)

          setSave('noteCheckPlayerSelectPos', checkboxPos(1))
          setSave('noteCheckOpponentSelectPos', checkboxPos(2))
     end
     if keyboardJustPressed('DOWN') and minimumLimit_noteskins == false then
          setProperty('checkbox_playerSelect.y', getProperty('checkbox_playerSelect.y') - 340 * 2)
          setProperty('checkbox_opponentSelect.y', getProperty('checkbox_opponentSelect.y') - 340 * 2)

          setSave('noteCheckPlayerSelectPos', checkboxPos(1))
          setSave('noteCheckOpponentSelectPos', checkboxPos(2))
     end
end

function onUpdate(elapsed)
     controlCheckbox()
     animateCheckbox()

     selectNoteSkins()
     setNoteAnim()
end