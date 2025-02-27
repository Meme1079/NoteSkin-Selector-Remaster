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

-- Selection Buttons --

--[[ makeAnimatedLuaSprite('selectionSkinButton_player', 'ui/buttons/checkbox_buttons', 775 + 12, 315)
addAnimationByPrefix('selectionSkinButton_player', 'default', 'default')
addAnimationByPrefix('selectionSkinButton_player', 'hover', 'hover0')
addAnimationByPrefix('selectionSkinButton_player', 'selected', 'selected')
addAnimationByPrefix('selectionSkinButton_player', 'hover-alt', 'hover-alt')
playAnim('selectionSkinButton_player', 'default')
scaleObject('selectionSkinButton_player', 0.5, 0.5)
setObjectCamera('selectionSkinButton_player', 'camHUD')
setProperty('selectionSkinButton_player.antialiasing', false)
addLuaSprite('selectionSkinButton_player')

makeAnimatedLuaSprite('selectionSkinButton_opponent', 'ui/buttons/checkbox_buttons', 775 + 220 + 12, 315)
scaleObject('selectionSkinButton_opponent', 0.5, 0.5)
addAnimationByPrefix('selectionSkinButton_opponent', 'checking', 'checking', 24, false)
addAnimationByPrefix('selectionSkinButton_opponent', 'unchecking', 'unchecking', 24, false)
playAnim('selectionSkinButton_opponent', 'checking')
setObjectCamera('selectionSkinButton_opponent', 'camHUD')
setProperty('selectionSkinButton_opponent.antialiasing', false)
addLuaSprite('selectionSkinButton_opponent') ]]

--[[ makeLuaText('selectionSkinText_player', 'Player', 0, 775 + 80, 315 + 11)
setTextFont('selectionSkinText_player', 'sonic.ttf')
setTextSize('selectionSkinText_player', 30)
setTextColor('selectionSkinText_player', '31b0d1')
setObjectCamera('selectionSkinText_player', 'camHUD')
setProperty('selectionSkinText_player.antialiasing', false)
addLuaText('selectionSkinText_player')

makeLuaText('selectionSkinText_opponent', 'Opponent', 0, 775 + 220 + ((80 * 2) / 2), 315 + 11)
setTextFont('selectionSkinText_opponent', 'sonic.ttf')
setTextSize('selectionSkinText_opponent', 30)
setTextColor('selectionSkinText_opponent', 'af66ce')
setObjectCamera('selectionSkinText_opponent', 'camHUD')
setProperty('selectionSkinText_opponent.antialiasing', false)
addLuaText('selectionSkinText_opponent') ]]

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
     local previewSkinPositionX = 830 + (105*(keyID-1)) - 8
     local previewSkinPositionY = 250

     local genInfoKeybinds = 'genInfoKeybinds-'..keyID
     makeLuaText(genInfoKeybinds, tostring(getKeyBinds(keyID)), nil, previewSkinPositionX, previewSkinPositionY)
     setTextFont(genInfoKeybinds, 'vipnagorgialla.otf')
     setTextSize(genInfoKeybinds, 40)
     setTextBorder(genInfoKeybinds, 3, '000000')
     setObjectCamera(genInfoKeybinds, 'camHUD')
     addLuaText(genInfoKeybinds)
end

-- Search Input --

addHScript('hscripts/skin-selector/ui/skinSearchInput')

-- Mouse Texture --

makeAnimatedLuaSprite('mouseTexture', 'ui/cursor', getMouseX('camOther'), getMouseY('camOther'))
addAnimationByPrefix('mouseTexture', 'default', 'default')
addAnimationByPrefix('mouseTexture', 'grabbed', 'grabbed')
addAnimationByPrefix('mouseTexture', 'pointer', 'pointer')
playAnim('mouseTexture', 'default')
setObjectCamera('mouseTexture', 'camOther')
addLuaSprite('mouseTexture', true)
setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)

-- Skins --

local Notes = SkinNotes:new('notes', 'noteSkins', true)
Notes:load()
Notes:precache()
Notes:preload()
Notes:preview()
Notes:save_load()

function onCreatePost()
     playMusic(getModSetting('song_select', modFolder):lower(), 0.5, true)

     
     --[[ local width,height = 800, 450
     callMethodFromClass('flixel.FlxG', 'resizeWindow', {width,height})
     callMethodFromClass('flixel.FlxG', 'resizeGame', {width,height}) ]]
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
for positionIndex = 1, #sliderTrackPosition-2 do
     displaySliderMarks('positions', '3b8527', {12 * 2, 12 / 2}, sliderTrackPosition, positionIndex)
end
for dividerIndex = 2, #sliderTrackDivider-2 do
     displaySliderMarks('divider', '847500', {12 * 1.5, 12 / 4}, sliderTrackDivider, dividerIndex)
end

local allowCountdown = false;
function onStartCountdown()
     local camUI = {'iconP1', 'iconP2', 'healthBar', 'scoreTxt', 'botplayTxt'}
     for i = 1, #camUI do
          callMethod('uiGroup.remove', {instanceArg(camUI[i])})
     end

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