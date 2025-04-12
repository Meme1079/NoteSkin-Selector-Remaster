luaDebugMode = true

local SkinNotes = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinNotes'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local ease      = require 'mods.NoteSkin Selector Remastered.api.libraries.ease.ease'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'

-- Background --

makeLuaSprite('selectorBackground', 'menuDesat', 0, 0)
setObjectCamera('selectorBackground', 'camHUD')
setObjectOrder('selectorBackground', 0)
setProperty('selectorBackground.color', 0x5220bd)
addLuaSprite('selectorBackground')

-- Display Sliders --

makeAnimatedLuaSprite('displaySliderIcon', 'ui/buttons/slider_button', 600, 127) -- min: 127; max: 643
addAnimationByPrefix('displaySliderIcon', 'static', 'slider_button-static')
addAnimationByPrefix('displaySliderIcon', 'pressed', 'slider_button-pressed')
addAnimationByPrefix('displaySliderIcon', 'unscrollable', 'slider_button-unscrollable')
playAnim('displaySliderIcon', 'static')
scaleObject('displaySliderIcon', 0.6, 0.6)
setObjectCamera('displaySliderIcon', 'camHUD')
setProperty('displaySliderIcon.antialiasing', false)
precacheImage('ui/buttons/slider_button')
addLuaSprite('displaySliderIcon')

makeLuaSprite('displaySliderTrack', nil, 600 + getProperty('displaySliderIcon.width') / 2.7, 127 + 3)
makeGraphic('displaySliderTrack', 12, 570, '1d1e1f')
setObjectOrder('displaySliderTrack', getObjectOrder('displaySliderIcon'))
setObjectCamera('displaySliderTrack', 'camHUD')
setProperty('displaySliderTrack.antialiasing', false)
addLuaSprite('displaySliderTrack', true)

-- Selection Buttons --

makeAnimatedLuaSprite('selectionSkinButton_player', 'ui/buttons/checkbox_buttons', 775 + 12, 315)
addAnimationByPrefix('selectionSkinButton_player', 'default', 'default')
addAnimationByPrefix('selectionSkinButton_player', 'hover', 'hover0')
addAnimationByPrefix('selectionSkinButton_player', 'selected', 'selected')
addAnimationByPrefix('selectionSkinButton_player', 'hover-alt', 'hover-alt')
playAnim('selectionSkinButton_player', 'default')
scaleObject('selectionSkinButton_player', 0.4, 0.4)
setObjectCamera('selectionSkinButton_player', 'camHUD')
setProperty('selectionSkinButton_player.antialiasing', false)
addLuaSprite('selectionSkinButton_player')

makeAnimatedLuaSprite('selectionSkinButton_opponent', 'ui/buttons/checkbox_buttons', 775 + 12 + (80*2.9), 315)
addAnimationByPrefix('selectionSkinButton_opponent', 'default', 'default')
addAnimationByPrefix('selectionSkinButton_opponent', 'hover', 'hover0')
addAnimationByPrefix('selectionSkinButton_opponent', 'selected', 'selected')
addAnimationByPrefix('selectionSkinButton_opponent', 'hover-alt', 'hover-alt')
playAnim('selectionSkinButton_opponent', 'default')
scaleObject('selectionSkinButton_opponent', 0.4, 0.4)
setObjectCamera('selectionSkinButton_opponent', 'camHUD')
setProperty('selectionSkinButton_opponent.antialiasing', false)
addLuaSprite('selectionSkinButton_opponent')

makeLuaText('selectionSkinText_player', 'Player', 0, 775 + 75, 315 + 7)
setTextFont('selectionSkinText_player', 'sonic.ttf')
setTextSize('selectionSkinText_player', 30)
setTextColor('selectionSkinText_player', '31b0d1')
setObjectCamera('selectionSkinText_player', 'camHUD')
setProperty('selectionSkinText_player.antialiasing', false)
addLuaText('selectionSkinText_player')

makeLuaText('selectionSkinText_opponent', 'Opponent', 0, 775 + 75 + (80*2.9), 315 + 7)
setTextFont('selectionSkinText_opponent', 'sonic.ttf')
setTextSize('selectionSkinText_opponent', 30)
setTextColor('selectionSkinText_opponent', 'af66ce')
setObjectCamera('selectionSkinText_opponent', 'camHUD')
setProperty('selectionSkinText_opponent.antialiasing', false)
addLuaText('selectionSkinText_opponent')

-- Selection Animation Buttons --

makeLuaText('pa', 'Preview Animations', 0, 775+12, 470)
setTextFont('pa', 'FridayNight.ttf')
setTextSize('pa', 18)
setTextBorder('pa', 3, '000000')
setObjectCamera('pa', 'camHUD')
setProperty('pa.antialiasing', false)
addLuaText('pa')

makeAnimatedLuaSprite('da1', 'ui/buttons/preview anim/previewAnimIcon_button', 775+12, 500)
addAnimationByPrefix('da1', 'static', 'skinanim-static', 24, false)
addAnimationByPrefix('da1', 'pressed', 'skinanim-pressed', 24, false)
addAnimationByPrefix('da1', 'hovered-static', 'skinanim-hovered-static', 24, false)
addAnimationByPrefix('da1', 'hovered-pressed', 'skinanim-hovered-pressed', 24, false)
playAnim('da1', 'static', true)
scaleObject('da1', 0.5, 0.5)
setObjectCamera('da1', 'camHUD')
setProperty('da1.antialiasing', false)
addLuaSprite('da1')

makeAnimatedLuaSprite('geu1', 'ui/buttons/preview anim/previewAnimInfoDirection_button', 775+12+(60/4.4), 500+(60/4.8))
addAnimationByPrefix('geu1', 'none', 'icons-none', 24, false)
addAnimationByPrefix('geu1', 'left', 'icons-left', 24, false)
addAnimationByPrefix('geu1', 'right', 'icons-right', 24, false)
playAnim('geu1', 'none', true)
scaleObject('geu1', 0.5, 0.5)
setObjectCamera('geu1', 'camHUD')
setProperty('geu1.antialiasing', false)
addLuaSprite('geu1')

makeAnimatedLuaSprite('da2', 'ui/buttons/preview anim/previewAnimIcon_button', 775+(12*7), 500)
addAnimationByPrefix('da2', 'static', 'skinanim-static', 24, false)
addAnimationByPrefix('da2', 'pressed', 'skinanim-pressed', 24, false)
addAnimationByPrefix('da2', 'hovered-static', 'skinanim-hovered-static', 24, false)
addAnimationByPrefix('da2', 'hovered-pressed', 'skinanim-hovered-pressed', 24, false)
playAnim('da2', 'static', true)
scaleObject('da2', 0.5, 0.5)
setObjectCamera('da2', 'camHUD')
setProperty('da2.antialiasing', false)
addLuaSprite('da2')

makeAnimatedLuaSprite('geu2', 'ui/buttons/preview anim/previewAnimInfoDirection_button', 775+(12*7)+(60/4.4), 500+(60/4.8))
addAnimationByPrefix('geu2', 'none', 'icons-none', 24, false)
addAnimationByPrefix('geu2', 'left', 'icons-left', 24, false)
addAnimationByPrefix('geu2', 'right', 'icons-right', 24, false)
playAnim('geu2', 'right', true)
scaleObject('geu2', 0.5, 0.5)
setObjectCamera('geu2', 'camHUD')
setProperty('geu2.antialiasing', false)
addLuaSprite('geu2')

makeAnimatedLuaSprite('sha', 'ui/buttons/preview anim/previewAnimSelection_button', 775+(12*16), 500)
addAnimationByPrefix('sha', 'static', 'selection-static', 24, false)
addAnimationByPrefix('sha', 'pressed', 'selection-pressed', 24, false)
addAnimationByPrefix('sha', 'hovered-static', 'selection-hovered-static', 24, false)
addAnimationByPrefix('sha', 'hovered-pressed', 'selection-hovered-pressed', 24, false)
playAnim('sha', 'static', true)
scaleObject('sha', 0.5, 0.5)
setObjectCamera('sha', 'camHUD')
setProperty('sha.antialiasing', false)
addLuaSprite('sha')

makeLuaText('qew', 'Confirm', 0, 775+(12*17.3), 515)
setTextFont('qew', 'sonic.ttf')
setTextSize('qew', 25)
setObjectCamera('qew', 'camHUD')
setProperty('qew.antialiasing', false)
addLuaText('qew')

-- General Infos --

makeLuaText('genInfoStateName', ' Notes', 0, 7, 13)
setTextFont('genInfoStateName', 'sonic.ttf')
setTextSize('genInfoStateName', 35)
setTextBorder('genInfoStateName', 3, '000000')
setObjectCamera('genInfoStateName', 'camHUD')
setProperty('genInfoStateName.antialiasing', false)
addLuaText('genInfoStateName')

makeLuaText('genInfoStatePage', ' Page 001 / 100', 0, 7^2.767, 17)
setTextFont('genInfoStatePage', 'sonic.ttf')
setTextSize('genInfoStatePage', 30)
setTextBorder('genInfoStatePage', 3, '000000')
setProperty('genInfoStatePage.camera', instanceArg('camHUD'), false, true)
setObjectCamera('genInfoStatePage', 'camHUD')
setProperty('genInfoStatePage.antialiasing', false)
addLuaText('genInfoStatePage')

makeLuaText('genInfoSkinName', 'Funkin', 500, 748, 70)
setTextFont('genInfoSkinName', 'sonic.ttf')
setTextSize('genInfoSkinName', 50)
setTextBorder('genInfoSkinName', 4, '000000')
setTextAlignment('genInfoSkinName', 'center')
setObjectCamera('genInfoSkinName', 'camHUD')
setProperty('genInfoSkinName.antialiasing', false)
addLuaText('genInfoSkinName')

makeLuaText('genInfoVersion', 'Ver 2.0.0', 0, 1195, 5)
setTextFont('genInfoVersion', 'sonic.ttf')
setTextSize('genInfoVersion', 20)
setTextColor('genInfoVersion', 'fccf03')
setObjectCamera('genInfoVersion', 'camHUD')
setProperty('genInfoVersion.antialiasing', false)
addLuaText('genInfoVersion')

for keyID = 1, 4 do
     local previewSkinPositionX = 830 + (105*(keyID-1))
     local previewSkinPositionY = 250

     if keyID == 2 then
          previewSkinPositionX = 830 + (105*(keyID-1)) - 4
     elseif keyID == 3 then
          previewSkinPositionX = 830 + (105*(keyID-1)) - 3
     end

     local genInfoKeybinds = 'genInfoKeybinds-'..keyID
     makeLuaText(genInfoKeybinds, tostring(getKeyBinds(keyID)), nil, previewSkinPositionX, previewSkinPositionY)
     setTextFont(genInfoKeybinds, 'FridayNight.ttf')
     setTextSize(genInfoKeybinds, 35)
     setTextBorder(genInfoKeybinds, 4, '000000')
     setObjectCamera(genInfoKeybinds, 'camHUD')
     addLuaText(genInfoKeybinds)
end

-- Mouse Texture --

makeAnimatedLuaSprite('mouseTexture', 'ui/cursor', getMouseX('camOther'), getMouseY('camOther'))
scaleObject('mouseTexture', 0.4, 0.4)
addAnimationByPrefix('mouseTexture', 'idle', 'idle', false)
addAnimationByPrefix('mouseTexture', 'idleClick', 'idleClick', false)
addAnimationByPrefix('mouseTexture', 'hand', 'hand', false)
addAnimationByPrefix('mouseTexture', 'handClick', 'handClick', false)
addAnimationByPrefix('mouseTexture', 'disabled', 'disabled', false)
addAnimationByPrefix('mouseTexture', 'disabledClick', 'disabledClick', false)
playAnim('mouseTexture', 'idle')
setObjectCamera('mouseTexture', 'camOther')
addLuaSprite('mouseTexture', true)
setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)

-- HScript Stuff --

addHScript('hscripts/skin-selector/selectorGridBG')     -- Checkerboard & Infinitely BG Stuff
addHScript('hscripts/skin-selector/ui/skinSearchInput') -- Search Input Functionality

-- General Stuff --

local hueChangeSwitch = true
local hueChangeCPM    = 0.09
local hueChangeStaticValue = 0   -- start: 0   | end: 30
local hueChangeTweenValue  = 240 -- start: 240 | end: 270
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
          hueChangeStaticValue = hueChangeStaticValue + hueChangeCPM
          hueChangeTweenValue  = ease.inOutExpo(hueChangeStaticValue/30, 0, 30-0, 1)+240

          if math.round(hueChangeStaticValue, 0) >= 30 then 
               hueChangeSwitch = false 
          end
     end
     if hueChangeSwitch == false then
          hueChangeStaticValue = hueChangeStaticValue - hueChangeCPM
          hueChangeTweenValue  = math.abs(ease.inOutExpo(hueChangeStaticValue/30, 30, 0-30, 1)-30)+240

          if math.round(hueChangeStaticValue, 0) <= 0 then 
               hueChangeSwitch = true 
          end
     end

     if not getModSetting('remove_color_changing_bg', modFolder) then
          local rgb = hslToRGB(hueChangeTweenValue, 54, 43)
          local hex = rgbToHex(unpack(rgb))
          setProperty('selectorBackground.color', tonumber('0x'..hex))
     end
end

-- 'splashes', 'noteSplashes', 'noteSplashes', true
-- 'notes', 'noteSkins', 'NOTE_assets', true
local Notes = SkinNotes:new('notes', 'noteSkins', 'NOTE_assets', true)
Notes:load()
Notes:save_load()
Notes:precache()
Notes:preload()
--Notes:preventError()
Notes:preview()
Notes:page_sliderMarks()

function onUpdate(elapsed)
     Notes:page_slider()
     Notes:page_moved()
     Notes:selection()
     Notes:search()
     Notes:preview_moved()
     Notes:preview_animation()
     

     hueChangeBG()
end