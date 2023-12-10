local table = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/table')

--- Calculates the positions of a row skins
---@param skinType table Either it will be `note` or `splash` tables to get the positions
---@return table Returns the given `x` and `y` positions
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

--- Calculates the page limit from the row skins
---@param skinType table Either it will be `note` or `splash` tables to get the page limit
---@return number Returns the given page limit from the specified skins
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

function onCreate()
     makeLuaSprite('bg_cover', 'menuDesat', 0, 0)
     setObjectCamera('bg_cover', 'camHUD')
     setProperty('bg_cover.color', 0x5332a8)
     addLuaSprite('bg_cover')

     makeLuaSprite('bg_side', 'sidebar', 100, 0)
     setObjectCamera('bg_side', 'camHUD')
     setProperty('bg_side.color', 0x000000)
     setProperty('bg_side.alpha', 0.5)
     addLuaSprite('bg_side')

     makeLuaSprite('bg_head', nil, 0, 0)
     makeGraphic('bg_head', 1300, 100, 'ffffff')
     setObjectCamera('bg_head', 'camHUD')
     addLuaSprite('bg_head')

     -- Button Displays --

     makeLuaText('skin_note', 'Note', 0, 272.5, 20)
     setTextFont('skin_note', 'mania.ttf')
     setTextAlignment('skin_note', 'center')
     setTextSize('skin_note', 50)
     setObjectCamera('skin_note', 'camHUD')
     setProperty('skin_note.antialiasing', true)
     addLuaText('skin_note')

     makeLuaText('skin_splash', 'Splash', 0, 817.5, 20)
     setTextFont('skin_splash', 'mania.ttf')
     setTextAlignment('skin_splash', 'center')
     setTextSize('skin_splash', 50)
     setObjectCamera('skin_splash', 'camHUD')
     setProperty('skin_splash.antialiasing', true)
     addLuaText('skin_splash')

     makeLuaSprite('bgButton_noteskin-selected', 'buttons/selectbut', getProperty('skin_note.x') - 85, getProperty('skin_note.y'))
     setGraphicSize('bgButton_noteskin-selected', 300, 70)
     setObjectCamera('bgButton_noteskin-selected', 'camHUD')
     setProperty('bgButton_noteskin-selected.color', 0xff0000)
     addLuaSprite('bgButton_noteskin-selected')

     makeLuaSprite('bgButton_splashskin-selected', 'buttons/selectbut', getProperty('skin_splash.x') - 65, getProperty('skin_splash.y'))
     setGraphicSize('bgButton_splashskin-selected', 300, 70)
     setObjectCamera('bgButton_splashskin-selected', 'camHUD')
     setProperty('bgButton_splashskin-selected.color', 0xff0000)
     setProperty('bgButton_splashskin-selected.visible', false)
     addLuaSprite('bgButton_splashskin-selected')

     makeLuaSprite('bgButton_noteskin', 'buttons/blackbut', getProperty('skin_note.x') - 100, getProperty('skin_note.y') - 10)  
     setGraphicSize('bgButton_noteskin', 300, 70)
     setObjectCamera('bgButton_noteskin', 'camHUD')
     addLuaSprite('bgButton_noteskin')

     makeLuaSprite('bgButton_splashskin', 'buttons/blackbut', getProperty('skin_splash.x') - 80, getProperty('skin_splash.y') - 10)
     setGraphicSize('bgButton_splashskin', 300, 70)
     setObjectCamera('bgButton_splashskin', 'camHUD')
     addLuaSprite('bgButton_splashskin')

     -- Infos --

     makeLuaText('skin_page', 'Page 1 / NaN', 0, 265, 675)
     setObjectCamera('skin_page', 'camHUD')
     setTextFont('skin_page', 'mania.ttf')
     setTextSize('skin_page', 30)
     setProperty('skin_page.antialiasing', true)
     addLuaText('skin_page')

     makeLuaText('skin_name', 'Default', 350, 845, 115)
     setObjectCamera('skin_name', 'camHUD')
     setTextFont('skin_name', 'mania.ttf')
     setTextSize('skin_name', 50)
     setTextAlignment('skin_name', 'center')
     setProperty('skin_name.antialiasing', true)
     addLuaText('skin_name')

     makeAnimatedLuaSprite('skinHitbox-highlight', 'selection', 42.8 - 30, 158)
     addAnimationByPrefix('skinHitbox-highlight', 'selecting', 'selected', 3)
     playAnim('skinHitbox-highlight', 'selecting')
     setObjectCamera('skinHitbox-highlight', 'camHUD')
     addLuaSprite('skinHitbox-highlight')

     -- Other --

     makeLuaSprite('windowGameHitbox', nil, 15, 15)
     makeGraphic('windowGameHitbox', screenWidth - 30, screenHeight - 30, '000000')
     setObjectCamera('windowGameHitbox', 'camHUD')
     setProperty('windowGameHitbox.visible', false)
     addLuaSprite('windowGameHitbox')

     -- Music --
     
     precacheMusic('file_select')
     playMusic('file_select', 0.45, true)

     -- Scripts --

     addLuaScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/skins/noteskin')
     addHScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/other/globalfunk')
     addHScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/other/backdrop')
end

function onCreatePost()
     setProperty('iconP1.visible', false)
     setProperty('iconP2.visible', false)
     setProperty('healthBar.visible', false)
     setProperty('healthBarBG.visible', false)
     setProperty('scoreTxt.visible', false)

     -- Mouse --

     makeLuaSprite('mouse_hitbox', nil, getMouseX('camHUD'), getMouseY('camHUD'))
     makeGraphic('mouse_hitbox', 10, 10, 'e44932')
     setObjectCamera('mouse_hitbox', 'camHUD')
     setObjectOrder('mouse_hitbox', math.huge)
     setProperty('mouse_hitbox.visible', false)
     addLuaSprite('mouse_hitbox')

     setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);
end

--- Clicks on the specified object and returns `true`, if clicked.
---@param obj string The specified object to click
---@return boolean
local function clickObject(obj)
     return objectsOverlap(obj, 'mouse_hitbox') and mouseClicked('left')
end

function onUpdate(elapsed)
     if keyboardJustPressed('ONE') then
          restartSong(true)
     end
     if keyboardJustPressed('ESCAPE') then
          exitSong()
     end
     if not objectsOverlap('windowGameHitbox', 'mouse_hitbox') then
          flushSaveData('noteskin_selector-save')
     end

     if clickObject('bgButton_splashskin') then
          playSound('ping', 0.1)
          setProperty('bgButton_noteskin-selected.visible', false)
          setProperty('bgButton_splashskin-selected.visible', true)
     end
     if clickObject('bgButton_noteskin') then
          playSound('ping', 0.1)
          setProperty('bgButton_noteskin-selected.visible', true)
          setProperty('bgButton_splashskin-selected.visible', false)
     end

     setProperty('mouse_hitbox.x', getMouseX('camHUD'))
     setProperty('mouse_hitbox.y', getMouseY('camHUD'))
end

--- Converts a HUE value into a RGB value _(I stole this)_
---@param primary number The first color
---@param secondary number The second color
---@param tertiary number The third color
---@return number Returns a RGB value
function hueToRGB(primary, secondary, tertiary)
     if tertiary < 0 then tertiary = tertiary + 1 end
     if tertiary > 1 then tertiary = tertiary - 1 end
     if tertiary < 1 / 6 then return primary + (secondary - primary) * 6 * tertiary end
     if tertiary < 1 / 2 then return secondary end
     if tertiary < 2 / 3 then return primary + (secondary - primary) * (2 / 3 - tertiary) * 6 end
     return primary;
end

--- Converts HSL color value into a RGB value _(I stole this)_
---@param hue number The color
---@param sat number The saturation
---@param light number The lightness
---@return table Returns a RGB value in a table form
function hslToRGB(hue, sat, light)
     local hue, sat, light = hue / 360, sat / 100, light / 100
     local red, green, blue = light, light, light; -- achromatic
     if sat ~= 0 then
          local q = light < 0.5 and light * (1 + sat) or light + sat - light * sat;
          local p = 2 * light - q;
          red, green, blue = hueToRGB(p, q, hue + 1 / 3), hueToRGB(p, q, hue), hueToRGB(p, q, hue - 1 / 3);
     end
     return {math.floor(red * 255), math.floor(green * 255), math.floor(blue * 255)}
end

--- Converts RGB color value into a Hex value _(I modified this)_
---@param red number The red value
---@param green number The green value
---@param blue number The blue value
---@return string Returns a Hex value
function rgbToHex(red, green, blue)
     local red   = red   >= 0 and (red   <= 255 and red   or 255) or 0
     local green = green >= 0 and (green <= 255 and green or 255) or 0
     local blue  = blue  >= 0 and (blue  <= 255 and blue  or 255) or 0
     return string.format("%02x%02x%02x", red, green, blue)
end

local switch = true
local cpm = 0.05 -- color per-millisecond
local hue = 230
function onUpdatePost(elapsed)
     if switch == false then
          if hue <= 270 then hue = hue + cpm end
          if hue >= 270 then switch = true end
     else
          if hue >= 240 then hue = hue - cpm end
          if hue <= 240 then switch = false end
     end

     setProperty('bg_cover.color', tonumber('0x'..rgbToHex(unpack(hslToRGB(hue, 54, 43)))))
end

--- Creates a timer in milliseconds _(Better)_
---@param tag string The specified tag to use
---@param timer number How much time will the `callback` be called
---@param callback function The code to execute
---@return nil
function createTimer(tag, timer, callback)
     timers = {}
     table.insert(timers, {tag, callback})
     runTimer(tag, timer)
end

function onTimerCompleted(tag, loops, loopsLeft)
     for _,v in pairs(timers) do
          if v[1] == tag then v[2]() end
     end
end

local allowCountdown = false;
function onStartCountdown()
     if not allowCountdown then -- Block the first countdown
          allowCountdown = true;
          return Function_Stop;
     end
     setProperty('camHUD.visible', true)
     return Function_Continue;
end

return {
     ['clickObject'] = clickObject,
     ['calculatePosition'] = calculatePosition, 
     ['calculatePageLimit'] = calculatePageLimit,
}