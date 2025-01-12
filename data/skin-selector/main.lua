luaDebugMode = true

local SkinStates = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinStates'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'

local Skins = SkinStates:new('notes', {'notes', 'splashes'}, {'noteSkins', 'noteSplashes'})
Skins:precache()
Skins:create_pre(1)
Skins:create(1)

makeAnimatedLuaSprite('displaySliderIcon', 'ui/buttons/slider_button', 600, 127) -- min: 127; max: 643
addAnimationByPrefix('displaySliderIcon', 'static', 'slider_button-static')
addAnimationByPrefix('displaySliderIcon', 'pressed', 'slider_button-pressed')
addAnimationByPrefix('displaySliderIcon', 'unscrollable', 'slider_button-unscrollable')
playAnim('displaySliderIcon', 'static')
scaleObject('displaySliderIcon', 0.6, 0.6)
setProperty('displaySliderIcon.camera', instanceArg('camHUD'), false, true)
setProperty('displaySliderIcon.antialiasing', false)
precacheImage('ui/buttons/slider_button')
addLuaSprite('displaySliderIcon')

makeLuaSprite('displaySliderTrack', nil, 600 + getProperty('displaySliderIcon.width') / 2.7, 127 + 3)
makeGraphic('displaySliderTrack', 12, 570, '1d1e1f')
setObjectOrder('displaySliderTrack', getObjectOrder('displaySliderIcon'))
setProperty('displaySliderTrack.camera', instanceArg('camHUD'), false, true)
setProperty('displaySliderTrack.antialiasing', false)
addLuaSprite('displaySliderTrack', true)


local p = 55
makeLuaSprite('windowTest1', 'ui/buttons/button_test5', 20, p)
scaleObject('windowTest1', 0.8, 0.8)
setProperty('windowTest1.camera', instanceArg('camHUD'), false, true)
setProperty('windowTest1.antialiasing', false)
addLuaSprite('windowTest1', true)

makeLuaText('testy', 'Search Skins...', 0, 35, p + 12)
setTextFont('testy', 'sonic.ttf')
setTextSize('testy', 31)
setTextColor('testy', 'b3b3b5')
setTextBorder('testy', -1)
setProperty('testy.camera', instanceArg('camHUD'), false, true)
setProperty('testy.antialiasing', false)
addLuaText('testy')

makeLuaSprite('corn', nil, 0, 0)
makeGraphic('corn', 3, 25, 'ffffff')
setObjectCamera('corn', 'camHUD')
addLuaSprite('corn', true)

runHaxeCode([[
import flixel.FlxG;
import backend.ui.PsychUIInputText;
import backend.ClientPrefs;
import backend.Paths;

var test = new PsychUIInputText(34, 54+12, 385, '', 31);
test.textObj.font = Paths.mods('NoteSkin Selector Remastered/fonts/sonic.ttf');
test.textObj.color = FlxColor.WHITE;
test.textObj.antialiasing = false;
test.bg.visible = false;
test.behindText.visible = false;
test.caret.alpha = 0;
test.cameras = [game.camHUD];
add(test);

game.getLuaObject('corn').x = test.caret.x + 1;
game.getLuaObject('corn').y = test.caret.y;
test.onChange = function(preText:String, curText:String) {
     game.getLuaObject('corn').x = test.caret.x + 1;

     if (curText.length > 0) {
          game.getLuaObject('testy').text = '';          
     } else {
          game.getLuaObject('testy').text = 'Search Skins...';
     }

     ClientPrefs.toggleVolumeKeys(false);
     new FlxTimer().start(0.1, () -> { ClientPrefs.toggleVolumeKeys(true); });
}
test.onPressEnter = function(e) {
     setVar('gems', test.text);
}

setVar('test', test);
]])

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

     playMusic(getModSetting('song_select', modFolder):lower(), 0.35, true)
end

function onUpdate(elapsed)
     if keyboardJustPressed('ONE') then restartSong(true) end
     if keyboardJustPressed('ESCAPE')      then exitSong()        end

     if mouseClicked('left')  then playSound('clicks/clickDown', 0.8) end
     if mouseReleased('left') then playSound('clicks/clickUp', 0.8) end

     setProperty('mouseHitBox.x', getMouseX('camHUD') - 3)
     setProperty('mouseHitBox.y', getMouseY('camHUD'))

     if keyboardJustPressed('ENTER') then
          local er = states.getTotalSkinObjects('notes', 'names')[1]
          --local pe = table.find(states.getTotalSkinObjects('notes')[1], getVar('gems'):)
          -- json.stringify(er, nil, 5)
          debugPrint( table.find(er, getVar('gems'):gsub('%-(.-)', '%1')) )
     end

     runHaxeCode([[
          game.getLuaObject('corn').visible = getVar('test').caret.visible;
     ]])
end



--local d = 1
function onUpdatePost(elapsed)
     --[[ if keyboardJustPressed('Q') then
          d = d + 1
          Skins:create(d)
     end
     if keyboardJustPressed('E') then
          d = d - 1
          Skins:create(d)
     end  ]]

     Skins:page_slider()
     --sliderTrackPageFunctionality()
end

local sliderTrackPosition = states.getPageSkinSliderPositions('notes').intervals
local sliderTrackDivider  = states.getPageSkinSliderPositions('notes').semiIntervals
local function displaySliderMarks(uniqueTag, color, widthBy, sliderTracks, sliderIndex)
     local hitboxMarkSliderTrackTag = ('displaySliderMark${tag}${index}'):interpol({tag = uniqueTag:upperAtStart(), index = sliderIndex})
     local hitboxMarkSliderTrackX = (600 + (getProperty('displaySliderIcon.width') / 2.7)) - widthBy[2]
     local hitboxMarkSliderTrackY = sliderTracks[sliderIndex]

     makeLuaSprite(hitboxMarkSliderTrackTag, nil, hitboxMarkSliderTrackX, hitboxMarkSliderTrackY)
     makeGraphic(hitboxMarkSliderTrackTag, widthBy[1], 3, color)
     setObjectOrder(hitboxMarkSliderTrackTag, getObjectOrder('displaySliderIcon') - 0)
     setProperty(hitboxMarkSliderTrackTag..'.camera', instanceArg('camHUD'), false, true)
     setProperty(hitboxMarkSliderTrackTag..'.antialiasing', false)
     addLuaSprite(hitboxMarkSliderTrackTag)
end
for positionIndex = 1, #sliderTrackPosition do
     displaySliderMarks('positions', '3b8527', {12 * 2, 12 / 2}, sliderTrackPosition, positionIndex)
end
for dividerIndex = 2, #sliderTrackDivider do
     displaySliderMarks('divider', '847500', {12 * 1.5, 12 / 4}, sliderTrackDivider, dividerIndex)
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