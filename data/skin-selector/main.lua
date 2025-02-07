luaDebugMode = true

local SkinNotes = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinNotes'

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

-- Search Input --

--[[ makeAnimatedLuaSprite('skinSearchInput_background', 'ui/buttons/search_input', 20, 55)
addAnimationByPrefix('skinSearchInput_background', 'default', 'default')
addAnimationByPrefix('skinSearchInput_background', 'hover', 'hovered')
addAnimationByPrefix('skinSearchInput_background', 'selectAll', 'selectAll')
playAnim('skinSearchInput_background', 'default')
scaleObject('skinSearchInput_background', 0.8, 0.8)
setObjectCamera('skinSearchInput_background', 'camHUD')
setProperty('skinSearchInput_background.antialiasing', false)
addLuaSprite('skinSearchInput_background') ]]

addHScript('hscripts/skin-selector/ui/skinSearchInput')

-- Mouse Hitbox --

makeLuaSprite('mouseHitBox', nil, getMouseX('camHUD') - 3, getMouseY('camHUD'))
makeGraphic('mouseHitBox', 10, 10, 'ff0000')
setObjectCamera('mouseHitBox', 'camHUD')
setObjectOrder('mouseHitBox', 90E34) -- fuck you
setProperty('mouseHitBox.visible', false)
addLuaSprite('mouseHitBox', true)

makeAnimatedLuaSprite('mouseTexture', 'ui/cursor', getMouseX('camOther'), getMouseY('camOther'))
addAnimationByPrefix('mouseTexture', 'default', 'default')
addAnimationByPrefix('mouseTexture', 'grabbed', 'grabbed')
addAnimationByPrefix('mouseTexture', 'pointer', 'pointer')
playAnim('mouseTexture', 'default')
setObjectCamera('mouseTexture', 'camHUD')
addLuaSprite('mouseTexture', true)
setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)

-- Skins --

local Notes = SkinNotes:new('notes', 'noteSkins', true)
Notes:load()
Notes:precache()
Notes:create_preload()
Notes:create(1)
Notes:preview()
Notes:save_load()

function onCreatePost()
     local camUI = {'iconP1', 'iconP2', 'healthBar', 'scoreTxt', 'botplayTxt'}
     for i = 1, #camUI do
          callMethod('uiGroup.remove', {instanceArg(camUI[i])})
     end
     playMusic(getModSetting('song_select', modFolder):lower(), 0.5, true)
end

function onUpdate(elapsed)
     if keyboardJustConditionPressed('ONE',    not getVar('skinSearchInputFocus')) then restartSong(true) end
     if keyboardJustConditionPressed('ESCAPE', not getVar('skinSearchInputFocus')) then exitSong()        end
     if mouseClicked('left')  then playSound('clicks/clickDown', 0.5) end
     if mouseReleased('left') then playSound('clicks/clickUp', 0.5)   end

     setProperty('mouseHitBox.x', getMouseX('camHUD') - 3)
     setProperty('mouseHitBox.y', getMouseY('camHUD'))

     setProperty('mouseTexture.x', getMouseX('camHUD'))
     setProperty('mouseTexture.y', getMouseY('camHUD'))
end

function onUpdatePost(elapsed)
     Notes:page_slider()
     Notes:page_moved()
     Notes:selection_byclick()
     Notes:selection_byhover()
     Notes:found()
     

     Notes:yeat()
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