luaDebugMode = true

local SkinStates = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinStates'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'

local test = SkinStates:new('notes', {'notes', 'splashes'}, {'noteSkins', 'noteSplashes'})
test:precache()
test:create(1)

makeAnimatedLuaSprite('displaySliderIcon', 'ui/buttons/slider_button', 600, 127) -- min: 127; max: 643
addAnimationByPrefix('displaySliderIcon', 'static', 'slider_button-static')
addAnimationByPrefix('displaySliderIcon', 'pressed', 'slider_button-pressed')
addAnimationByPrefix('displaySliderIcon', 'unscrollable', 'slider_button-unscrollable')
playAnim('displaySliderIcon', 'static')
scaleObject('displaySliderIcon', 0.6, 0.6)
setProperty('displaySliderIcon.camera', instanceArg('camHUD'), false, true)
setProperty('displaySliderIcon.antialiasing', false)
addLuaSprite('displaySliderIcon')

makeLuaSprite('displaySliderTrack', nil, 600 + getProperty('displaySliderIcon.width') / 2.7, 127 + 3)
makeGraphic('displaySliderTrack', 12, 570, '1d1e1f')
setObjectOrder('displaySliderTrack', getObjectOrder('displaySliderIcon'))
setProperty('displaySliderTrack.camera', instanceArg('camHUD'), false, true)
setProperty('displaySliderTrack.antialiasing', false)
addLuaSprite('displaySliderTrack', true)

function onCreatePost()
     makeLuaSprite('mouseHitBox', nil, getMouseX('camHUD') - 3, getMouseY('camHUD'))
     makeGraphic('mouseHitBox', 10, 10, 'ff0000')
     setProperty('mouseHitBox.camera', instanceArg('camHUD'), false, true)
     setObjectOrder('mouseHitBox', 90E34) -- fuck you
     setProperty('mouseHitBox.visible', false)
     addLuaSprite('mouseHitBox', true)

     local camUI = {'iconP1', 'iconP2', 'healthBar', 'scoreTxt', 'botplayTxt'}
     for i = 1, #camUI do
          callMethod('uiGroup.remove', {instanceArg(camUI[i])})
     end

     if not getModSetting('remove_checker_bg', modFolder) then
          runHaxeCode('hscripts/skin-selector/background.hx')
     end
     playMusic(getModSetting('song_select', modFolder):lower(), 0.35, true)
end

function onUpdate(elapsed)
     if keyboardJustPressed('ONE')    then restartSong(true) end
     if keyboardJustPressed('ESCAPE') then exitSong()        end

     if mouseClicked('left')  then playSound('clicks/clickDown', 0.8) end
     if mouseReleased('left') then playSound('clicks/clickUp', 0.8) end

     setProperty('mouseHitBox.x', getMouseX('camHUD') - 3)
     setProperty('mouseHitBox.y', getMouseY('camHUD'))
end

local d = 1
function onUpdatePost(elapsed)
     if keyboardJustPressed('Q') then
          d = d + 1
          test:create(d)
     end
     if keyboardJustPressed('E') then
          d = d - 1
          test:create(d)
     end 
     --sliderTrackPageFunctionality()
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