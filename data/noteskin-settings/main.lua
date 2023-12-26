local table = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/table')

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

function onCreate()
     addLuaScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/skins/noteskin')
     addHScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/other/globalfunk')
     addHScript('mods/NoteSkin Selector Remastered/data/noteskin-settings/other/backdrop')

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

     -- Keybinds --

     makeLuaText('keybind_text1', tostring(getKeyBinds(0)), nil, 833, 300)
     setTextSize('keybind_text1', 35)
     setObjectCamera('keybind_text1', 'camHUD')
     addLuaText('keybind_text1')

     makeLuaText('keybind_text2', tostring(getKeyBinds(1)), nil, 833 + 115, 300)
     setTextSize('keybind_text2', 35)
     setObjectCamera('keybind_text2', 'camHUD')
     addLuaText('keybind_text2')

     makeLuaText('keybind_text3', tostring(getKeyBinds(2)), nil, 833 + 115 * 2, 300)
     setTextSize('keybind_text3', 35)
     setObjectCamera('keybind_text3', 'camHUD')
     addLuaText('keybind_text3')

     makeLuaText('keybind_text4', tostring(getKeyBinds(3)), nil, 833 + 115 * 3, 300)
     setTextSize('keybind_text4', 35)
     setObjectCamera('keybind_text4', 'camHUD')
     addLuaText('keybind_text4')

     -- UI --

     makeLuaText('ui_noteAnim', 'Anims', 0, 815, 610)
     setTextFont('ui_noteAnim', 'phantummuff full.ttf')
     addLuaText('ui_noteAnim')

     makeLuaText('ui_noteStyle', 'Style', 0, 930, 610)
     setTextFont('ui_noteStyle', 'phantummuff full.ttf')
     addLuaText('ui_noteStyle')

     makeLuaText('ui_noteOptions', 'Options', 0, 1030, 610)
     setTextFont('ui_noteOptions', 'phantummuff full.ttf')
     addLuaText('ui_noteOptions')

     makeLuaText('ui_noteLBRACKET', 'LBRKT', 0, 840, 690)
     setTextFont('ui_noteLBRACKET', 'phantummuff full.ttf')
     addLuaText('ui_noteLBRACKET')

     makeLuaText('ui_noteRBRACKET', 'RBRKT', 0, 950, 690)
     setTextFont('ui_noteRBRACKET', 'phantummuff full.ttf')
     addLuaText('ui_noteRBRACKET')

     makeLuaText('ui_noteSHIFTO', 'SHIFT + O', 0, 1060, 690)
     setTextFont('ui_noteSHIFTO', 'phantummuff full.ttf')
     addLuaText('ui_noteSHIFTO')

     makeLuaSprite('ui_notePressed', 'ui/note-pressed', 790, 620)
     setObjectCamera('ui_notePressed', 'camHUD')
     setGraphicSize('ui_notePressed', 100, 100)
     addLuaSprite('ui_notePressed')

     makeLuaSprite('ui_noteConfirm', 'ui/note-confirm', 790, 620)
     setObjectCamera('ui_noteConfirm', 'camHUD')
     setGraphicSize('ui_noteConfirm', 100, 100)
     addLuaSprite('ui_noteConfirm')

     makeLuaSprite('ui_noteNormal', 'ui/note-pressed', 900, 620)
     setObjectCamera('ui_noteNormal', 'camHUD')
     setGraphicSize('ui_noteNormal', 100, 100)
     addLuaSprite('ui_noteNormal')

     --makeLuaSprite('ui_notePixel', 'ui/note-pixel', 900, 620)
     --setObjectCamera('ui_notePixel', 'camHUD')
     --setGraphicSize('ui_notePixel', 100, 100)
     --addLuaSprite('ui_notePixel')

     makeLuaSprite('ui_noteOptions', 'ui/note-options', 1010, 620)
     setObjectCamera('ui_noteOptions', 'camHUD')
     setGraphicSize('ui_noteOptions', 100, 100)
     addLuaSprite('ui_noteOptions')

     -- Player & Opponent --

     makeAnimatedLuaSprite('checkbox_player', 'checkboxanim', 803, 385)
     setObjectCamera('checkbox_player', 'camHUD')
     setGraphicSize('checkbox_player', 75, 75)
     addAnimationByPrefix('checkbox_player', 'unchecked', 'checkbox0', 24, false)
     addAnimationByPrefix('checkbox_player', 'unchecking', 'checkbox anim reverse', 24, false)
     addAnimationByPrefix('checkbox_player', 'checking', 'checkbox anim0', 24, false)
     addAnimationByPrefix('checkbox_player', 'checked', 'checkbox finish', 24, false)
     addOffset('checkbox_player', 'unchecked', 18, 16.5)
     addOffset('checkbox_player', 'unchecking', 37, 37)
     addOffset('checkbox_player', 'checking', 44, 34)
     addOffset('checkbox_player', 'checked', 20, 24)
     playAnim('checkbox_player', 'unchecked')
     addLuaSprite('checkbox_player')

     makeAnimatedLuaSprite('checkbox_opponent', 'checkboxanim', 803, 385 + 100)
     setObjectCamera('checkbox_opponent', 'camHUD')
     setGraphicSize('checkbox_opponent', 75, 75)
     addAnimationByPrefix('checkbox_opponent', 'unchecked', 'checkbox0', 24, false)
     addAnimationByPrefix('checkbox_opponent', 'unchecking', 'checkbox anim reverse', 24, false)
     addAnimationByPrefix('checkbox_opponent', 'checking', 'checkbox anim0', 24, false)
     addAnimationByPrefix('checkbox_opponent', 'checked', 'checkbox finish', 24, false)
     addOffset('checkbox_opponent', 'unchecked', 18, 16.5)
     addOffset('checkbox_opponent', 'unchecking', 37, 37)
     addOffset('checkbox_opponent', 'checking', 44, 34)
     addOffset('checkbox_opponent', 'checked', 20, 24)
     playAnim('checkbox_opponent', 'unchecked')
     addLuaSprite('checkbox_opponent')

     makeLuaText('checkbox_playerText', 'Player', 0, 803 + 100, 400 - 3)
     setTextColor('checkbox_playerText', '31b0d1')
     setTextSize('checkbox_playerText', 40)
     setTextFont('checkbox_playerText', 'phantummuff full.ttf')
     setObjectCamera('checkbox_playerText', 'camHUD')
     addLuaText('checkbox_playerText')

     makeLuaText('checkbox_opponentText', 'Opponent', 0, 803 + 100, 400 + 100 - 3)
     setTextColor('checkbox_opponentText', 'af66ce')
     setTextSize('checkbox_opponentText', 40)
     setTextFont('checkbox_opponentText', 'phantummuff full.ttf')
     setObjectCamera('checkbox_opponentText', 'camHUD')
     addLuaText('checkbox_opponentText')

     makeLuaSprite('checkbox_playerSelect', 'player-selected', 100, 165)
     setGraphicSize('checkbox_playerSelect', 65, 65)
     setObjectCamera('checkbox_playerSelect', 'camOther')
     addLuaSprite('checkbox_playerSelect', true)

     makeLuaSprite('checkbox_opponentSelect', 'opponent-selected', 100, 235)
     setGraphicSize('checkbox_opponentSelect', 65, 65)
     setObjectCamera('checkbox_opponentSelect', 'camOther')
     addLuaSprite('checkbox_opponentSelect', true)

     -- Other --

     makeLuaSprite('windowGameHitbox', nil, 20, 20)
     makeGraphic('windowGameHitbox', screenWidth - 40, screenHeight - 40, '000000')
     setObjectCamera('windowGameHitbox', 'camHUD')
     setProperty('windowGameHitbox.visible', false)
     addLuaSprite('windowGameHitbox')

     -- Music --
     
     precacheMusic('file_select')
     playMusic('file_select', 0.25, true)
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
     if keyboardJustPressed('TAB') then
          loadNewSong(getDataFromSave('noteskin_selector-save', 'curSongName'), getDataFromSave('noteskin_selector-save', 'curDiffID'))
     end

     if keyboardPressed('SHIFT') and keyboardJustPressed('O') then
          runHaxeCode([[
   	          import options.OptionsState;
  	          import backend.MusicBeatState;
  	          game.paused = true; // For lua
 	          game.vocals.volume = 0;
  	          MusicBeatState.switchState(new OptionsState());
  	          if (ClientPrefs.data.pauseMusic != 'None') {
    	               FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), game.modchartSounds('pauseMusic').volume);
    	               FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
      	          FlxG.sound.music.time = game.modchartSounds('pauseMusic').time;
    	          }
    	          OptionsState.onPlayState = true;
	     ]])
     end

     if clickObject('bgButton_splashskin') then
          playSound('ping', 0.3)
          setProperty('bgButton_noteskin-selected.visible', false)
          setProperty('bgButton_splashskin-selected.visible', true)
     end
     if clickObject('bgButton_noteskin') then
          playSound('ping', 0.3)
          setProperty('bgButton_noteskin-selected.visible', true)
          setProperty('bgButton_splashskin-selected.visible', false)
     end

     setProperty('mouse_hitbox.x', getMouseX('camHUD'))
     setProperty('mouse_hitbox.y', getMouseY('camHUD'))
end

function hueToRGB(primary, secondary, tertiary)
     if tertiary < 0 then tertiary = tertiary + 1 end
     if tertiary > 1 then tertiary = tertiary - 1 end
     if tertiary < 1 / 6 then return primary + (secondary - primary) * 6 * tertiary end
     if tertiary < 1 / 2 then return secondary end
     if tertiary < 2 / 3 then return primary + (secondary - primary) * (2 / 3 - tertiary) * 6 end
     return primary;
end

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

function rgbToHex(red, green, blue)
     local red   = red   >= 0 and (red   <= 255 and red   or 255) or 0
     local green = green >= 0 and (green <= 255 and green or 255) or 0
     local blue  = blue  >= 0 and (blue  <= 255 and blue  or 255) or 0
     return string.format("%02x%02x%02x", red, green, blue)
end

local switch = true
local cpm = 0.05 -- color per-millisecond
local hue = 240
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

local allowCountdown = false;
function onStartCountdown()
     if not allowCountdown then -- Block the first countdown
          allowCountdown = true;
          return Function_Stop;
     end
     setProperty('camHUD.visible', true)
     return Function_Continue;
end