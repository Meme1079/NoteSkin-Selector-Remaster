local table  = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/table')
local string = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/string')
local json   = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/json')
local main   = require('mods/NoteSkin Selector Remastered/data/noteskin-settings/main')

--- Gets the text file content's from another file
---@param path string The path duh; Starts outside the `mods` folder
---@return string The file content's
local function getTextFileContent(path)
     local file = io.open(path)
     local content = ''
     for line in file:lines() do  
          content = content .. line .. '\n'
     end
     return content
end

--- Gets the noteskins assets
---@return table The noteskins that were collected
local function getNoteSkins()
     local results = {'NOTE_assets', 'NOTE_assets-future', 'NOTE_assets-chip'}
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/noteSkins') do
          if v:match('^(NOTE_assets%-.+)%.png$') then
               table.insert(results, v:match('^(NOTE_assets%-.+)%.png$'))
          end
     end
     return results
end

--- Gets the noteskins' name from the suffix of file name
---@return table The noteskins' name that were collected
local function getNoteSkinNames()
     local results = {'Default', 'Future', 'Chip'}
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/noteSkins') do
          if v:match('^NOTE_assets%-(.+)%.png$') then
               table.insert(results, v:match('^NOTE_assets%-(.+)%.png$'))
          end
     end
     return results
end

--- Initiates the creation of the noteskins for display
---@param noteSkinTag string The specified noteskin tag
---@param noteSkinImage string The specified image to display
---@param nameAnim string The given name of the animation
---@param prefixAnim string The given prefix animation to use
---@param xpos number The x position to set in
---@return nil
local function initNoteSkins(noteSkinTag, noteSkinImage, nameAnim, prefixAnim, xpos)
     makeAnimatedLuaSprite(noteSkinTag, noteSkinImage, xpos, 175)
     addAnimationByPrefix(noteSkinTag, 'leftConfirm', 'left confirm', 24, false)
     addAnimationByPrefix(noteSkinTag, 'downConfirm', 'down confirm', 24, false)
     addAnimationByPrefix(noteSkinTag, 'upConfirm', 'up confirm', 24, false)
     addAnimationByPrefix(noteSkinTag, 'rightConfirm', 'right confirm', 24, false)
     addAnimationByPrefix(noteSkinTag, nameAnim, prefixAnim, 24, false)
     setGraphicSize(noteSkinTag, 110, 110)
     setObjectCamera(noteSkinTag, 'camHUD')
     addLuaSprite(noteSkinTag, false)
end

--- Creates the noteskin for display
---@return nil
local function createNoteSkins()
     local offsets = {left = {}, down = {}, up = {}, right = {}}
     for index, value in next, getNoteSkins() do
          local noteSkin_getCurPos = main.calculatePosition(getNoteSkins())[index]
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
          addLuaSprite(noteSkin_displayTag, false)

          local noteSkin_arrowImage = 'noteSkins/'..value
          local noteSkin_arrowTagPrefix = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          local noteSkin_arrowTag = function(ind) 
               return 'noteSkins'..noteSkin_arrowTagPrefix[ind]..tostring(index) 
          end

          initNoteSkins(noteSkin_arrowTag(1), noteSkin_arrowImage, 'left', 'arrowLEFT', 790)
          initNoteSkins(noteSkin_arrowTag(2), noteSkin_arrowImage, 'down', 'arrowDOWN', 790 + 115)
          initNoteSkins(noteSkin_arrowTag(3), noteSkin_arrowImage, 'up', 'arrowUP', 790 + 115 * 2)
          initNoteSkins(noteSkin_arrowTag(4), noteSkin_arrowImage, 'right', 'arrowRIGHT', 790 + 115 * 3)

          table.insert(offsets.left, {getProperty(noteSkin_arrowTag(1)..'.offset.x'), getProperty(noteSkin_arrowTag(1)..'.offset.y')})
          table.insert(offsets.down, {getProperty(noteSkin_arrowTag(2)..'.offset.x'), getProperty(noteSkin_arrowTag(2)..'.offset.y')})
          table.insert(offsets.up, {getProperty(noteSkin_arrowTag(3)..'.offset.x'), getProperty(noteSkin_arrowTag(3)..'.offset.y')})
          table.insert(offsets.right, {getProperty(noteSkin_arrowTag(4)..'.offset.x'), getProperty(noteSkin_arrowTag(4)..'.offset.y')})

          for q = 1, #offsets.left do
               addOffset(noteSkin_arrowTag(1), 'left',  offsets.left[q][1],  offsets.left[q][2])
               addOffset(noteSkin_arrowTag(2), 'down',  offsets.down[q][1],  offsets.down[q][2])
               addOffset(noteSkin_arrowTag(3), 'up',    offsets.up[q][1],    offsets.up[q][2])
               addOffset(noteSkin_arrowTag(4), 'right', offsets.right[q][1], offsets.right[q][2])
          end 
     end
end

--- Checks if the main value is nil, and returns an alternative value
---@param main any The main value to use
---@param alt any The alternate value if the `main` argument is a `nil`
function altValue(main, alt)
     return main ~= nil and main or alt
end

local noteSkin_savedData_curPage
local noteSkin_savedData_highlightPosX
local noteSkin_savedData_highlightPosY
local noteSkin_savedData_selectedName
local noteSkin_savedData_selectedPos
function onCreate()
     initSaveData('noteskin_selector-save', 'noteskin_selector')
     noteSkin_savedData_curPage       = altValue(getDataFromSave('noteskin_selector-save', 'noteSkin_savedData_curPage'), 1)
     noteSkin_savedData_highlightPosX = altValue(getDataFromSave('noteskin_selector-save', 'noteSkin_savedData_highlightPosX'), 42.8 - 30)
     noteSkin_savedData_highlightPosY = altValue(getDataFromSave('noteskin_selector-save', 'noteSkin_savedData_highlightPosY'), 158)
     noteSkin_savedData_selectedName  = altValue(getDataFromSave('noteskin_selector-save', 'noteSkin_savedData_selectedName'), 'Default')
     noteSkin_savedData_selectedPos   = altValue(getDataFromSave('noteskin_selector-save', 'noteSkin_savedData_selectedPos'), 1)
end

--- Saves the current page were you left last time
---@return nil
local function saveSelectionLocation()
     local perMultiply = 0
     for perPage = 1, noteSkin_savedData_curPage do
          if perPage >= 3 then
               perMultiply = perMultiply + 1
          end
     end

     local noteSkins_decrement = 0
     for perSkinInd = 1, #getNoteSkins() do
          if noteSkin_savedData_curPage == 1 then --! DO NOT DELETE
               break
          end
          if noteSkin_savedData_curPage >= 3 then
               noteSkins_decrement = 340 * perMultiply
          end

          local noteSkins_tagGetY        = 'noteSkins_hitbox-'..tostring(perSkinInd)..'.y'
          local noteSkins_tagDisplayGetY = 'noteSkins_display-'..tostring(perSkinInd)..'.y'
          setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) - 340 * noteSkin_savedData_curPage - noteSkins_decrement)
          setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) - 340 * noteSkin_savedData_curPage - noteSkins_decrement)
     end
end

local increValue_noteskins
local minimumLimit_noteskins = false
local maximumLimit_noteskins = false
function onCreatePost()
     createNoteSkins()
     saveSelectionLocation()
     
     setProperty('skinHitbox-highlight.x', noteSkin_savedData_highlightPosX)
     setProperty('skinHitbox-highlight.y', noteSkin_savedData_highlightPosY)
     setTextString('skin_page', 'Page '..noteSkin_savedData_curPage..' / '..main.calculatePageLimit(getNoteSkins()))
     setTextString('skin_name', noteSkin_savedData_selectedName)
     increValue_noteskins = altValue(getDataFromSave('noteskin_selector-save', 'noteSkin_savedData_curPage'), 1)
end

local function traverseNoteSkins()
     if keyboardJustPressed('UP') and maximumLimit_noteskins == false then
          increValue_noteskins = increValue_noteskins - 1
          playSound('scrollMenu', 0.3)

          setTextString('skin_page', 'Page '..increValue_noteskins..' / '..main.calculatePageLimit(getNoteSkins()))
     end
     if keyboardJustPressed('DOWN') and minimumLimit_noteskins == false then
          increValue_noteskins = increValue_noteskins + 1
          playSound('scrollMenu', 0.3)

          setTextString('skin_page', 'Page '..increValue_noteskins..' / '..main.calculatePageLimit(getNoteSkins()))
     end

     if increValue_noteskins <= 1 then
          maximumLimit_noteskins = true
     else
          maximumLimit_noteskins = false
     end
     if increValue_noteskins >= main.calculatePageLimit(getNoteSkins()) then
          minimumLimit_noteskins = true
     else
          minimumLimit_noteskins = false
     end

     if keyboardJustPressed('ONE') or keyboardJustPressed('ESCAPE') then
          setDataFromSave('noteskin_selector-save', 'noteSkin_savedData_curPage', increValue_noteskins)
     end
end

local noteSkins_getNoteSkins = getNoteSkins()
local noteSkins_selectedPos  = 1
local noteSkins_bgPos        = 340 * 2
local noteSkins_selectOffset = 7
local function selectionNoteSkins()
     for k = 1, #noteSkins_getNoteSkins do
          local noteSkins_getPos = main.calculatePosition(noteSkins_getNoteSkins)[k]
          local noteSkins_tagGetY = 'noteSkins_hitbox-'..tostring(k)..'.y'
          local noteSkins_tagDisplayGetY = 'noteSkins_display-'..tostring(k)..'.y'

          if main.clickObject('noteSkins_hitbox-'..tostring(k)) then
               playSound('select', 1)
               playAnim('skinHitbox-highlight', 'selecting', true)
               setTextString('skin_name', getNoteSkinNames()[k])

               local noteskinHitbox_highlightX = noteSkins_getPos[1] - 8 + 0.8
               local noteskinHitbox_highlightY = getProperty(noteSkins_tagGetY) - noteSkins_selectOffset
               setProperty('skinHitbox-highlight.x', noteskinHitbox_highlightX)
               setProperty('skinHitbox-highlight.y', noteskinHitbox_highlightY)
               
               noteSkins_selectedPos = k
               setDataFromSave('noteskin_selector-save', 'noteSkin_savedData_highlightPosX', noteskinHitbox_highlightX)
               setDataFromSave('noteskin_selector-save', 'noteSkin_savedData_selectedName', getNoteSkinNames()[k])
               setDataFromSave('noteskin_selector-save', 'noteSkin_savedData_selectedPos', k)
          end

          local noteSkin_savedData_selectedPos = getDataFromSave('noteskin_selector-save', 'noteSkin_savedData_selectedPos') or noteSkins_selectedPos
          local noteSkins_arrows = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          for a,b in next, noteSkins_arrows do
               if k ~= noteSkin_savedData_selectedPos then
                    removeLuaSprite('noteSkins'..b..tostring(k), false)
               else
                    addLuaSprite('noteSkins'..b..tostring(k))
               end
          end
          
          if keyboardJustPressed('UP') and maximumLimit_noteskins == false then
               setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) + noteSkins_bgPos)
               setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) + noteSkins_bgPos)
               setProperty('skinHitbox-highlight.y', getProperty('noteSkins_hitbox-'..tostring(noteSkin_savedData_selectedPos)..'.y') - noteSkins_selectOffset)
          end
          if keyboardJustPressed('DOWN') and minimumLimit_noteskins == false then
               setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) - noteSkins_bgPos)
               setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) - noteSkins_bgPos)
               setProperty('skinHitbox-highlight.y', getProperty('noteSkins_hitbox-'..tostring(noteSkin_savedData_selectedPos)..'.y') - noteSkins_selectOffset)
          end

          setDataFromSave('noteskin_selector-save', 'noteSkin_savedData_highlightPosY', getProperty('noteSkins_hitbox-'..tostring(noteSkin_savedData_selectedPos)..'.y') - noteSkins_selectOffset)
     end

     traverseNoteSkins()
end

local gayPath = 'mods/NoteSkin Selector Remastered/jsons/offsets_confirm.jsonc'
local noteSkins_offsets_confirm = getTextFileContent(gayPath):gsub('//%s*.-(\n)', '%1')
local g = json.decode(noteSkins_offsets_confirm)

--- Initiates the note skin animations when pressing
---@param key integer The note direction in each strum of the note
---@param ind integer The given index of the note skin arrows
---@param dir string The given direction to use
---@param offsets table The animation offsets
---@return nil
local function initNoteAnim(key, ind, dir, offsets)
     if keyboardJustPressed(getKeyBinds(key)) then
          addOffset('noteSkins_arrow'..dir..'-'..ind, dir:lower()..'Confirm', offsets[1], offsets[2])
          playAnim('noteSkins_arrow'..dir..'-'..ind, dir:lower()..'Confirm')
     end
     if keyboardReleased(getKeyBinds(key)) then
          playAnim('noteSkins_arrow'..dir..'-'..ind, dir:lower())
     end
end

--- Sets the note skin animations
---@return nil
local function setNoteAnim()
     for k = 1, #noteSkins_getNoteSkins do
          local noteSkin_savedData_selectedPos = getDataFromSave('noteskin_selector-save', 'noteSkin_savedData_selectedPos') or noteSkins_selectedPos
          local noteSkins_arrows = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          if k == noteSkin_savedData_selectedPos then
               local offsets = function(dir, def)
                    local x = g[dir][k] ~= nil and g[dir][k][1] or def[1]
                    local y = g[dir][k] ~= nil and g[dir][k][2] or def[2]
                    return {x, y}
               end

               initNoteAnim(0, k, 'Left',  offsets('left',  {45.5, 48}))
               initNoteAnim(1, k, 'Down',  offsets('down',  {50, 48.5}))
               initNoteAnim(2, k, 'Up',    offsets('up',    {50, 46.5}))
               initNoteAnim(3, k, 'Right', offsets('right', {46, 49.5}))
          end
     end
end

function onUpdate(elapsed)
     selectionNoteSkins()
     setNoteAnim()
end