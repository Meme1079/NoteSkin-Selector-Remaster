local funkinlua = require 'mods.NoteSkin Selector Remastered.modules.funkinlua'
local globals   = require 'mods.NoteSkin Selector Remastered.modules.globals'
local string    = require 'mods.NoteSkin Selector Remastered.libraries.string'
local json      = require 'mods.NoteSkin Selector Remastered.libraries.json.json'

local setSave = funkinlua.setSave
local getSave = funkinlua.getSave
initSaveData('noteselector', 'NoteSkin Selector')

function onCreate()
     makeLuaSprite('bgCover', 'menuDesat', 0, 0)
     setObjectCamera('bgCover', 'camHUD')
     setProperty('bgCover.color', 0x5332a8)
     addLuaSprite('bgCover')

     makeLuaSprite('bgSideCover', 'ui/sidebar', 80, 0)
     setObjectCamera('bgSideCover', 'camHUD')
     setProperty('bgSideCover.color', 0x000000)
     setProperty('bgSideCover.alpha', 0.5)
     addLuaSprite('bgSideCover')

     -- Buttons --

     makeLuaText('buttonNoteText', 'Note', 0, 105, 18)
     setObjectCamera('buttonNoteText', 'camHUD')
     setTextFont('buttonNoteText', 'sonic.ttf')
     setTextAlignment('buttonNoteText', 'center')
     setTextSize('buttonNoteText', 50)
     setProperty('buttonNoteText.antialiasing', false)
     addLuaText('buttonNoteText')

     makeLuaSprite('buttonNoteBackBG', 'ui/button', 30, 25)
     setObjectCamera('buttonNoteBackBG', 'camHUD')
     scaleObject('buttonNoteBackBG', 0.75, 0.85)
     setProperty('buttonNoteBackBG.color', 0xff0000)
     addLuaSprite('buttonNoteBackBG')

     makeLuaSprite('buttonNoteFrontBG', 'ui/button', 30 - 10, 25 - 10)
     setObjectCamera('buttonNoteFrontBG', 'camHUD')
     scaleObject('buttonNoteFrontBG', 0.75, 0.85)
     setProperty('buttonNoteFrontBG.color', 0x0000000)
     addLuaSprite('buttonNoteFrontBG')

     makeLuaText('buttonSplashText', 'Splash', 0, (118 * 4) - 30 + 20, 18)
     setObjectCamera('buttonSplashText', 'camHUD')
     setTextFont('buttonSplashText', 'sonic.ttf')
     setTextAlignment('buttonSplashText', 'center')
     setTextSize('buttonSplashText', 50)
     setProperty('buttonSplashText.antialiasing', false)
     addLuaText('buttonSplashText')

     makeLuaSprite('buttonSplashBackBG', 'ui/button', (50 * 8) - 20 + 20, 25)
     setObjectCamera('buttonSplashBackBG', 'camHUD')
     scaleObject('buttonSplashBackBG', 0.75, 0.85)
     setProperty('buttonSplashBackBG.color', 0xff00000)
     setProperty('buttonSplashBackBG.visible', false)
     addLuaSprite('buttonSplashBackBG')

     makeLuaSprite('buttonSplashFrontBG', 'ui/button', ((50 * 8) - 20) - 10 + 20, 25 - 10)
     setObjectCamera('buttonSplashFrontBG', 'camHUD')
     scaleObject('buttonSplashFrontBG', 0.75, 0.85)
     setProperty('buttonSplashFrontBG.color', 0x000000)
     addLuaSprite('buttonSplashFrontBG')

     -- Keybinds --

     local keybindTextX = {833 - 15, 833 + 115 - 15, (833 + 115 * 2) - 15, (833 + 115 * 3) - 15}
     for keyPos = 1, #keybindTextX do
          local keybindTag    = 'keybind_text'..keyPos
          local keybindString = tostring(getKeyBinds(keyPos - 1))
          makeLuaText(keybindTag, keybindString, nil, keybindTextX[keyPos], 270)
          setTextSize(keybindTag, 35)
          setObjectCamera(keybindTag, 'camHUD')
          addLuaText(keybindTag)
     end

     -- Info UIs --

     local maximumLimit_noteskins = globals.calculatePageLimit(globals.getSkins('note'))
     makeLuaText('uiSkinPage', 'Page 1 / '..maximumLimit_noteskins, 1000, -165, 675)
     setObjectCamera('uiSkinPage', 'camHUD')
     setTextFont('uiSkinPage', 'sonic.ttf')
     setTextAlignment('uiSkinPage', 'center')
     setTextSize('uiSkinPage', 30)
     setProperty('uiSkinPage.antialiasing', false)
     addLuaText('uiSkinPage')

     makeLuaText('uiSkinName', 'Normal', 500, 756, 70) -- y: 70
     setObjectCamera('uiSkinName', 'camHUD')
     setTextFont('uiSkinName', 'sonic.ttf')
     setTextAlignment('uiSkinName', 'center')
     setTextSize('uiSkinName', 60)
     setTextBorder('uiSkinName', 5, '000000', 'OUTLINE_FAST')
     setProperty('uiSkinName.antialiasing', false)
     addLuaText('uiSkinName')

     makeLuaText('uiCurVersion', 'Ver 1.0.0', 0, 1188, 5)
     setTextFont('uiCurVersion', 'sonic.ttf')
     setTextColor('uiCurVersion', 'fccf03')
     setTextSize('uiCurVersion', 20)
     setObjectCamera('uiCurVersion', 'camHUD')
     setProperty('uiCurVersion.antialiasing', false)
     addLuaText('uiCurVersion')

     makeLuaSprite('uiArrowUp', 'ui/button_arrows', 455, 670)
     setObjectCamera('uiArrowUp', 'camHUD')
     scaleObject('uiArrowUp', 0.18, 0.18)
     addLuaSprite('uiArrowUp')

     makeLuaSprite('uiArrowDown', 'ui/button_arrows', 180, 670)
     setObjectCamera('uiArrowDown', 'camHUD')
     scaleObject('uiArrowDown', 0.18, 0.18)
     setProperty('uiArrowDown.flipY', true)
     addLuaSprite('uiArrowDown')

     -- Note UIs --

     makeLuaSprite('uiNoteOptions', 'ui/changers/note-options', 1170, 630)
     setObjectCamera('uiNoteOptions', 'camHUD')
     setGraphicSize('uiNoteOptions', 80, 80)
     addLuaSprite('uiNoteOptions')

     makeAnimatedLuaSprite('uiNoteAnimations', 'ui/changers/note-animations', 770, 620)
     addAnimationByPrefix('uiNoteAnimations', 'confirm', 'note-confirm0', 24, false)
     addAnimationByPrefix('uiNoteAnimations', 'pressed', 'note-pressed0', 24, false)
     addAnimationByPrefix('uiNoteAnimations', 'colored', 'note-colored0', 24, false)
     setObjectCamera('uiNoteAnimations', 'camHUD')
     setGraphicSize('uiNoteAnimations', 100, 100)
     playAnim('uiNoteAnimations', 'confirm', true)
     addLuaSprite('uiNoteAnimations')

     makeAnimatedLuaSprite('uiNoteStyles', 'ui/changers/note-style', 770 + 110, 620)
     addAnimationByPrefix('uiNoteStyles', 'pixel', 'note-pixel0', 24, false)
     addAnimationByPrefix('uiNoteStyles', 'normal', 'note-normal0', 24, false)
     setObjectCamera('uiNoteStyles', 'camHUD')
     setGraphicSize('uiNoteStyles', 100, 100)
     playAnim('uiNoteStyles', 'normal', true)
     addLuaSprite('uiNoteStyles')

     makeLuaText('uiTextSettings', 'Settings', 0, 1170 + 3, 608)
     setTextFont('uiTextSettings', 'phantummuff.ttf')
     addLuaText('uiTextSettings')

     makeLuaText('uiTextNoteAnimations', 'Anims', 0, 770 + 25, 608)
     setTextFont('uiTextNoteAnimations', 'phantummuff.ttf')
     addLuaText('uiTextNoteAnimations')

     makeLuaText('uiTextNoteStyles', 'Styles', 0, 770 + 110 + 25, 608)
     setTextFont('uiTextNoteStyles', 'phantummuff.ttf')
     addLuaText('uiTextNoteStyles')

     makeLuaText('uiTextNoteAnimationsControl', 'LBRCKT', 0, 770 + 50, 610 + 80)
     setTextFont('uiTextNoteAnimationsControl', 'phantummuff.ttf')
     setTextSize('uiTextNoteAnimationsControl', 14)
     addLuaText('uiTextNoteAnimationsControl')

     makeLuaText('uiTextNoteStylesControl', 'RBRCKT', 0, 770 + 110 + 50, 610 + 80)
     setTextFont('uiTextNoteStylesControl', 'phantummuff.ttf')
     setTextSize('uiTextNoteStylesControl', 14)
     addLuaText('uiTextNoteStylesControl')
end

function onCreatePost()
     addLuaScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/states/note')
     if not getModSetting('remove_checker_bg', 'NoteSkin Selector Remastered') then
          runHaxeCode(funkinlua.getTextFileContent('mods/NoteSkin Selector Remastered/hscripts/backdrop.hx'))
     end
     
     -- Whatever the hell this is --

     callMethod('uiGroup.remove', {instanceArg('iconP1')})
     callMethod('uiGroup.remove', {instanceArg('iconP2')})
     callMethod('uiGroup.remove', {instanceArg('healthBar')})
     callMethod('uiGroup.remove', {instanceArg('scoreTxt')})
     callMethod('uiGroup.remove', {instanceArg('botplayTxt')})

     -- Mouse --

     makeLuaSprite('mouseHitBox', nil, getMouseX('camHUD') - 3, getMouseY('camHUD'))
     makeGraphic('mouseHitBox', 10, 10, 'ff0000')
     setObjectCamera('mouseHitBox', 'camHUD')
     setObjectOrder('mouseHitBox', 90E34) -- fuck you
     setProperty('mouseHitBox.visible', false)
     addLuaSprite('mouseHitBox', true)

     setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);

     -- Music --

     local music = getModSetting('song_select', 'NoteSkin Selector Remastered'):lower()
     playMusic(music, 0.35, true)
end

local buttonState = 'splash'
local function changeStates()
     if funkinlua.clickObject('buttonNoteBackBG') and buttonState == 'note' then
          playSound('ping', 0.1)

          setProperty('buttonNoteBackBG.visible', true)
          setProperty('buttonSplashBackBG.visible', false)
          buttonState = 'splash'
     end
     if funkinlua.clickObject('buttonSplashBackBG') and buttonState == 'splash' then
          playSound('ping', 0.1)

          setProperty('buttonNoteBackBG.visible', false)
          setProperty('buttonSplashBackBG.visible', true)
          buttonState = 'note'
     end
end

local changeSize = false
local function changeToOptionState()
     local changeOptionSize = function()
          local curNoteOptionsScale = 0.526315789473684
          if objectsOverlap('uiNoteOptions', 'mouseHitBox') and changeSize == false then
               startTween('uiNoteOptionsIn', 'uiNoteOptions', {['scale.x'] = 0.48, ['scale.y'] = 0.48}, 0.15, {ease = 'circout'})
               return;
          end
          startTween('uiNoteOptionsIn', 'uiNoteOptions', {['scale.x'] = curNoteOptionsScale, ['scale.y'] = curNoteOptionsScale}, 0.15, {ease = 'circout'})
     
          changeSize = true
          funkinlua.createTimer('resetChange', 0.01, function() 
               changeSize = false 
          end)
     end
     
     local optionsStatePath = 'mods/NoteSkin Selector Remastered/hscripts/options.hx'
     local optionsState = funkinlua.getTextFileContent(optionsStatePath)
     if funkinlua.clickObject('uiNoteOptions') then
          playSound('select', 1)
          funkinlua.createTimer('toOptionsState', 0.1, function() 
               runHaxeCode(optionsState)
          end)
     end
     changeOptionSize()
end

function onUpdate(elapsed)
     setProperty('mouseHitBox.x', getMouseX('camHUD') - 3)
     setProperty('mouseHitBox.y', getMouseY('camHUD'))

     if keyboardJustPressed('ONE')    then restartSong(true) end
     if keyboardJustPressed('ESCAPE') then exitSong()        end
     changeStates()
     changeToOptionState()
end

local function hueToRGB(primary, secondary, tertiary)
     if tertiary < 0 then tertiary = tertiary + 1 end
     if tertiary > 1 then tertiary = tertiary - 1 end
     if tertiary < 1 / 6 then return primary + (secondary - primary) * 6 * tertiary end
     if tertiary < 1 / 2 then return secondary end
     if tertiary < 2 / 3 then return primary + (secondary - primary) * (2 / 3 - tertiary) * 6 end
     return primary;
end

local function hslToRGB(hue, sat, light)
     local hue, sat, light = hue / 360, sat / 100, light / 100
     local red, green, blue = light, light, light; -- achromatic
     if sat ~= 0 then
          local q = light < 0.5 and light * (1 + sat) or light + sat - light * sat;
          local p = 2 * light - q;
          red, green, blue = hueToRGB(p, q, hue + 1 / 3), hueToRGB(p, q, hue), hueToRGB(p, q, hue - 1 / 3);
     end
     return {math.floor(red * 255), math.floor(green * 255), math.floor(blue * 255)}
end

local function rgbToHex(red, green, blue)
     local red   = red   >= 0 and (red   <= 255 and red   or 255) or 0
     local green = green >= 0 and (green <= 255 and green or 255) or 0
     local blue  = blue  >= 0 and (blue  <= 255 and blue  or 255) or 0
     return string.format("%02x%02x%02x", red, green, blue)
end

local switch = true
local cpm    = 0.05 -- color per-millisecond
local hue    = 240
local function colorSwapTween()
     if switch == false then
          if hue <= 270 then hue = hue + cpm end
          if hue >= 270 then switch = true end
     else
          if hue >= 240 then hue = hue - cpm end
          if hue <= 240 then switch = false end
     end
     setProperty('bgCover.color', tonumber('0x'..rgbToHex(unpack(hslToRGB(hue, 54, 43)))))
end

function onUpdatePost(elapsed)
     if not getModSetting('remove_color_changing_bg', 'NoteSkin Selector Remastered') then
          colorSwapTween()
     end
     if keyboardJustPressed('TAB') and songName == 'NoteSkin Settings' then
          loadNewSong(getSave('songLocalName'), getSave('songLocalDiff'))
     end

     if keyboardJustPressed('SHIFT') then
          loadNewSong('NoteSkin Debug')
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