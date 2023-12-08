local table  = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/table')
local string = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/string')
local main   = require('mods/NoteSkin Selector Remastered/data/noteskin-settings/main')

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
     addAnimationByPrefix(noteSkinTag, nameAnim, prefixAnim, 24, false)
     setGraphicSize(noteSkinTag, 110, 110)
     setObjectCamera(noteSkinTag, 'camHUD')
     addLuaSprite(noteSkinTag)
end

--- Creates the noteskin for display
---@return nil
local function createNoteSkins()
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
          addLuaSprite(noteSkin_displayTag)

          local noteSkin_arrowImage = 'noteSkins/'..value
          local notenoteSkin_arrowTagPrefix = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          local noteSkin_arrowTag = function(ind) 
               return 'noteSkins'..notenoteSkin_arrowTagPrefix[ind]..tostring(index) 
          end

          initNoteSkins(noteSkin_arrowTag(1), noteSkin_arrowImage, 'left', 'arrowLEFT', 790)
          initNoteSkins(noteSkin_arrowTag(2), noteSkin_arrowImage, 'down', 'arrowDOWN', 790 + 115)
          initNoteSkins(noteSkin_arrowTag(3), noteSkin_arrowImage, 'up', 'arrowUP', 790 + 115 * 2)
          initNoteSkins(noteSkin_arrowTag(4), noteSkin_arrowImage, 'right', 'arrowRIGHT', 790 + 115 * 3)
     end
end

--- Checks if the main value is nil, and returns an alternative value
---@param main any The main value to use
---@param alt any The alternate value if the `main` argument is a `nil`
function altValue(main, alt)
     return main ~= nil and main or alt
end

local savedData_curPage
local savedData_highlightPosX
local savedData_highlightPosY
local savedData_selectedName
local savedData_selectedPos
function onCreate()
     initSaveData('noteskin_selector-save', 'noteskin_selector')
     savedData_curPage       = altValue(getDataFromSave('noteskin_selector-save', 'savedData_curPage'), 1)
     savedData_highlightPosX = altValue(getDataFromSave('noteskin_selector-save', 'savedData_highlightPosX'), 42.8 - 30)
     savedData_highlightPosY = altValue(getDataFromSave('noteskin_selector-save', 'savedData_highlightPosY'), 158)
     savedData_selectedName  = altValue(getDataFromSave('noteskin_selector-save', 'savedData_selectedName'), 'Default')
     savedData_selectedPos   = altValue(getDataFromSave('noteskin_selector-save', 'savedData_selectedPos'), 1)
end

--- Saves the current page were you left last time
---@return nil
local function saveSelectionLocation()
     local perMultiply = 0
     for perPage = 1, savedData_curPage do
          if perPage >= 3 then
               perMultiply = perMultiply + 1
          end
     end

     local noteSkins_decrement = 0
     for perSkinInd = 1, #getNoteSkins() do
          if savedData_curPage == 1 then --! DO NOT DELETE
               break
          end
          if savedData_curPage >= 3 then
               noteSkins_decrement = 340 * perMultiply
          end

          local noteSkins_tagGetY        = 'noteSkins_hitbox-'..tostring(perSkinInd)..'.y'
          local noteSkins_tagDisplayGetY = 'noteSkins_display-'..tostring(perSkinInd)..'.y'
          setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) - 340 * savedData_curPage - noteSkins_decrement)
          setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) - 340 * savedData_curPage - noteSkins_decrement)
     end
end

local increValue_noteskins
local minimumLimit_noteskins = false
local maximumLimit_noteskins = false
function onCreatePost()
     createNoteSkins()
     saveSelectionLocation()

     setProperty('skinHitbox-highlight.x', savedData_highlightPosX)
     setProperty('skinHitbox-highlight.y', savedData_highlightPosY)
     setTextString('skin_page', 'Page '..savedData_curPage..' / '..main.calculatePageLimit(getNoteSkins()))
     setTextString('skin_name', savedData_selectedName)
     increValue_noteskins = altValue(getDataFromSave('noteskin_selector-save', 'savedData_curPage'), 1)
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
          setDataFromSave('noteskin_selector-save', 'savedData_curPage', increValue_noteskins)
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
               setDataFromSave('noteskin_selector-save', 'savedData_highlightPosX', noteskinHitbox_highlightX)
               setDataFromSave('noteskin_selector-save', 'savedData_selectedName', getNoteSkinNames()[k])
               setDataFromSave('noteskin_selector-save', 'savedData_selectedPos', k)
          end

          local savedData_selectedPos = getDataFromSave('noteskin_selector-save', 'savedData_selectedPos') or noteSkins_selectedPos
          local noteSkins_arrows = {'_arrowLeft-', '_arrowDown-', '_arrowUp-', '_arrowRight-'}
          for a,b in next, noteSkins_arrows do
               if k ~= savedData_selectedPos then
                    removeLuaSprite('noteSkins'..b..tostring(k), false)
               else
                    addLuaSprite('noteSkins'..b..tostring(k))
               end
          end
          
          if keyboardJustPressed('UP') and maximumLimit_noteskins == false then
               setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) + noteSkins_bgPos)
               setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) + noteSkins_bgPos)
               setProperty('skinHitbox-highlight.y', getProperty('noteSkins_hitbox-'..tostring(savedData_selectedPos)..'.y') - noteSkins_selectOffset)
          end
          if keyboardJustPressed('DOWN') and minimumLimit_noteskins == false then
               setProperty(noteSkins_tagGetY, getProperty(noteSkins_tagGetY) - noteSkins_bgPos)
               setProperty(noteSkins_tagDisplayGetY, getProperty(noteSkins_tagDisplayGetY) - noteSkins_bgPos)
               setProperty('skinHitbox-highlight.y', getProperty('noteSkins_hitbox-'..tostring(savedData_selectedPos)..'.y') - noteSkins_selectOffset)
          end

          setDataFromSave('noteskin_selector-save', 'savedData_highlightPosY', getProperty('noteSkins_hitbox-'..tostring(savedData_selectedPos)..'.y') - noteSkins_selectOffset)
     end

     traverseNoteSkins()
end

function onUpdate(elapsed)
     selectionNoteSkins()
end