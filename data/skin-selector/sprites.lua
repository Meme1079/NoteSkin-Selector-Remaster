local Cursor = require 'mods.NoteSkin Selector Remastered.api.classes.Cursor'


local SkinCursor = Cursor:new()
SkinCursor:load('default')

function setObjectCamera(object, camera)
     setProperty(object..'.camera', instanceArg(camera), false, true)
end


makeLuaSprite('selectorBackground', 'menuDesat', 0, 0)
setObjectCamera('selectorBackground', 'camHUD')
setObjectOrder('selectorBackground', 0)
setProperty('selectorBackground.color', 0x5220bd)
addLuaSprite('selectorBackground')

createInstance('selectorSideCover', 'flixel.addons.display.FlxBackdrop', {nil, 0x10, 0})
loadGraphic('selectorSideCover', 'ui/sidecover')
setObjectCamera('selectorSideCover', 'camHUD')
setProperty('selectorSideCover.x', 80)
setProperty('selectorSideCover.alpha', 0.5)
setProperty('selectorSideCover.color', 0x000000)
setProperty('selectorSideCover.velocity.y', 1000 / 20)
addInstance('selectorSideCover', false)

--[[ makeLuaText('skinPageCurCount', 'Page 1 / 100', 1000, -400, 675)
setObjectCamera('skinPageCurCount', 'camHUD')
setTextFont('skinPageCurCount', 'sonic.ttf')
setTextAlignment('skinPageCurCount', 'center')
setTextSize('skinPageCurCount', 30)
setProperty('skinPageCurCount.antialiasing', false)
addLuaText('skinPageCurCount')

local a = 300
local b = 430 * 1.13

makeLuaSprite('oidouwe', 'ui/buttons', a + 10, 678 - 2)
setObjectCamera('oidouwe', 'camHUD')
scaleObject('oidouwe', 0.4, 0.4)
setProperty('oidouwe.color', 0x282028)
setProperty('oidouwe.antialiasing', false)
addLuaSprite('oidouwe')

makeLuaSprite('oidouwe1', 'ui/buttons', b + 10, 678 - 2)
setObjectCamera('oidouwe1', 'camHUD')
scaleObject('oidouwe1', 0.4, 0.4)
setProperty('oidouwe1.color', 0x282028)
setProperty('oidouwe1.antialiasing', false)
addLuaSprite('oidouwe1')

makeLuaText('ioew', 'UP', 0, a + 50, 678 - 6)
setObjectCamera('ioew', 'camHUD')
setTextFont('ioew', 'sonic.ttf')
setTextSize('ioew', 38)
addLuaText('ioew')

makeLuaText('ioew1', 'DOWN', 0, b + 50, 678 - 6)
setObjectCamera('ioew1', 'camHUD')
setTextFont('ioew1', 'sonic.ttf')
setTextSize('ioew1', 38)
addLuaText('ioew1')

makeLuaSprite('ouew', 'ui/iconButton', a - 17, 678 - 19)
setObjectCamera('ouew', 'camHUD')
scaleObject('ouew', 0.4, 0.4)
setProperty('ouew.antialiasing', false)
addLuaSprite('ouew')

makeLuaSprite('ouew2', 'ui/iconButton', b - 17, 678 - 19)
setObjectCamera('ouew2', 'camHUD')
scaleObject('ouew2', 0.4, 0.4)
setProperty('ouew2.antialiasing', false)
addLuaSprite('ouew2')

makeLuaSprite('skinPageArrowDown', 'ui/buttons_arrow', a, 678)
setObjectCamera('skinPageArrowDown', 'camHUD')
scaleObject('skinPageArrowDown', 0.13, 0.13)
setProperty('skinPageArrowDown.flipY', true)
addLuaSprite('skinPageArrowDown')

makeLuaSprite('skinPageArrowUp', 'ui/buttons_arrow', b, 675)
setObjectCamera('skinPageArrowUp', 'camHUD')
scaleObject('skinPageArrowUp', 0.13, 0.13)
addLuaSprite('skinPageArrowUp') ]]


local hueChangeSwitch = true
local hueChangeCPM    = 0.09
local hueChangeValue  = 240
local function hueChangeBG()
     local hueToRGB = function(primary, secondary, tertiary)
          if tertiary < 0 then tertiary = tertiary + 1 end
          if tertiary > 1 then tertiary = tertiary - 1 end
          if tertiary < 1 / 6 then return primary + (secondary - primary) * 6 * tertiary end
          if tertiary < 1 / 2 then return secondary end
          if tertiary < 2 / 3 then return primary + (secondary - primary) * (2 / 3 - tertiary) * 6 end
          return primary;
     end
     local hslToRGB = function(hue, sat, light)
          local hue, sat, light = hue / 360, sat / 100, light / 100
          local red, green, blue = light, light, light; -- achromatic
          if sat ~= 0 then
               local q = light < 0.5 and light * (1 + sat) or light + sat - light * sat;
               local p = 2 * light - q;
               red, green, blue = hueToRGB(p, q, hue + 1 / 3), hueToRGB(p, q, hue), hueToRGB(p, q, hue - 1 / 3);
          end
          return {math.floor(red * 255), math.floor(green * 255), math.floor(blue * 255)}
     end
     local rgbToHex = function(red, green, blue)
          local red   = red   >= 0 and (red   <= 255 and red   or 255) or 0
          local green = green >= 0 and (green <= 255 and green or 255) or 0
          local blue  = blue  >= 0 and (blue  <= 255 and blue  or 255) or 0
          return string.format("%02x%02x%02x", red, green, blue)
     end

     if hueChangeSwitch == true then
          if hueChangeValue >= 240 then hueChangeValue  = hueChangeValue - hueChangeCPM end
          if hueChangeValue <= 240 then hueChangeSwitch = false end
     else
          if hueChangeValue <= 270 then hueChangeValue  = hueChangeValue + hueChangeCPM end
          if hueChangeValue >= 270 then hueChangeSwitch = true  end
     end

     if not getModSetting('remove_color_changing_bg', modFolder) then
          local rgb = hslToRGB(hueChangeValue, 54, 43)
          local hex = rgbToHex(unpack(rgb))
          setProperty('selectorBackground.color', tonumber('0x'..hex))
     end
end

function onUpdate(elapsed)
     hueChangeBG()
end