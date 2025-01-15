luaDebugMode = true

local SkinStates = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinStates'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'

local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

-- Display Sliders --

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

-- General Infos --

makeLuaText('genInfoStateName', ' Notes', 0, 7, 13)
setTextFont('genInfoStateName', 'sonic.ttf')
setTextSize('genInfoStateName', 35)
setTextBorder('genInfoStateName', 3, '000000')
setProperty('genInfoStateName.camera', instanceArg('camHUD'), false, true)
setProperty('genInfoStateName.antialiasing', false)
addLuaText('genInfoStateName')

makeLuaText('genInfoStatePage', ' Page 001 / 100', 0, 7^2.767, 17)
setTextFont('genInfoStatePage', 'sonic.ttf')
setTextSize('genInfoStatePage', 30)
setTextBorder('genInfoStatePage', 3, '000000')
setProperty('genInfoStatePage.camera', instanceArg('camHUD'), false, true)
setProperty('genInfoStatePage.antialiasing', false)
addLuaText('genInfoStatePage')

-- Search Bar --

makeLuaSprite('searchBarBackground', 'ui/buttons/search_inputs', 20, 55)
scaleObject('searchBarBackground', 0.8, 0.8)
setProperty('searchBarBackground.camera', instanceArg('camHUD'), false, true)
setProperty('searchBarBackground.antialiasing', false)
precacheImage('ui/buttons/search_inputs')
addLuaSprite('searchBarBackground', true)

makeLuaText('searchBarInputPlaceHolder', 'Search Skins...', 0, 35, 55 + 12)
setTextFont('searchBarInputPlaceHolder', 'sonic.ttf')
setTextSize('searchBarInputPlaceHolder', 31)
setTextColor('searchBarInputPlaceHolder', 'b3b3b5')
setTextBorder('searchBarInputPlaceHolder', -1)
setProperty('searchBarInputPlaceHolder.camera', instanceArg('camHUD'), false, true)
setProperty('searchBarInputPlaceHolder.antialiasing', false)
addLuaText('searchBarInputPlaceHolder')

makeLuaSprite('searchBarInputCaret', nil, 0, 0)
makeGraphic('searchBarInputCaret', 3, 25, 'ffffff')
setObjectCamera('searchBarInputCaret', 'camHUD')
addLuaSprite('searchBarInputCaret', true)

addHScript('hscripts/skin-selector/searchBar_functionality')

-- Mouse Hitbox --

makeLuaSprite('mouseHitBox', nil, getMouseX('camHUD') - 3, getMouseY('camHUD'))
makeGraphic('mouseHitBox', 10, 10, 'ff0000')
setProperty('mouseHitBox.camera', instanceArg('camHUD'), false, true)
setObjectOrder('mouseHitBox', 90E34) -- fuck you
setProperty('mouseHitBox.visible', false)
addLuaSprite('mouseHitBox', true)

-- Skins --

local Skins = SkinStates:new('notes', {'notes', 'splashes'}, {'noteSkins', 'noteSplashes'})
Skins:precache()
Skins:create_pre(1)
Skins:create(1)
Skins:page_setup()

function onCreatePost()
     local camUI = {'iconP1', 'iconP2', 'healthBar', 'scoreTxt', 'botplayTxt'}
     for i = 1, #camUI do
          callMethod('uiGroup.remove', {instanceArg(camUI[i])})
     end
     playMusic(getModSetting('song_select', modFolder):lower(), 0.15, true)
end

function onUpdate(elapsed)
     if keyboardJustConditionPressed('ONE',    not searchBarInput_onFocus()) then restartSong(true) end
     if keyboardJustConditionPressed('ESCAPE', not searchBarInput_onFocus()) then exitSong()        end
     if mouseClicked('left')  then playSound('clicks/clickDown', 0.5) end
     if mouseReleased('left') then playSound('clicks/clickUp', 0.5)   end

     setProperty('mouseHitBox.x', getMouseX('camHUD') - 3)
     setProperty('mouseHitBox.y', getMouseY('camHUD'))
end

function onUpdatePost(elapsed)
     Skins:page_slider()
     Skins:page_moved()
     Skins:found()
     Skins:hover()
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