local string  = require 'mods.NoteSkin Selector Remastered.libraries.string'
local globals = require 'mods.NoteSkin Selector Remastered.modules.globals'

function onCreatePost()
     local camUI = {'iconP1', 'iconP2', 'healthBar', 'scoreTxt', 'botplayTxt'}
     for i = 1, #camUI do
          callMethod('uiGroup.remove', {instanceArg(camUI[i])})
     end

     if not getModSetting('remove_checker_bg', modFolder) then
          local path = 'mods/NoteSkin Selector Remastered/data/noteskin-settings/hscripts/backdrop.hx'
          runHaxeCode(globals.getTextFileContent(path))
     end
     playMusic(getModSetting('song_select', modFolder):lower(), 0.35, true)
end

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
          setProperty('bgCover.color', tonumber('0x'..hex))
     end
end

function onUpdate(elapsed)
     if mouseClicked('left') then
          playSound('clicks/clickDown', 1, 'corn1')
     end
     if mouseReleased('left') then
          playSound('clicks/clickUp', 1, 'corn2')
     end

     if keyboardJustPressed('ONE')    then restartSong(true) end
     if keyboardJustPressed('ESCAPE') then exitSong()        end
     setProperty('mouseHitBox.x', getMouseX('camHUD') - 3)
     setProperty('mouseHitBox.y', getMouseY('camHUD'))

     hueChangeBG()
end

local allowCountdown = false;
function onStartCountdown()
     if not allowCountdown then -- Block the first countdown
          for k,v in pairs(getRunningScripts()) do
               if v:match(modFolder..'/scripts/skins') or not v:match(modFolder) then
                    removeLuaScript(v)
               end
          end
          allowCountdown = true;
          return Function_Stop;
     end
     setProperty('camHUD.visible', true)
     return Function_Continue;
end