luaDebugMode = true

local string = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json   = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'


local g = states.getTotalSkinObjects('notes')


local skinPosX = 0
local skinPosY = 0
for grid = 1, #g[1] do
     if (grid-1) % 4 == 0 then
          skinPosX = 0
          skinPosY = skinPosY + 1
     else
          skinPosX = skinPosX + 1
     end

     local newSkinPosX = 20+(170*skinPosX)-(25*skinPosX)
     local newSkinPosY = -20+(180*skinPosY)-(30*skinPosY)

     local skinDisplayGridIcon = 'displayGridIcon-'..tostring(grid)
     makeAnimatedLuaSprite(skinDisplayGridIcon, 'ui/buttons/display_button', newSkinPosX, newSkinPosY)
     addAnimationByPrefix(skinDisplayGridIcon, 'static', 'display_button-static')
     addAnimationByPrefix(skinDisplayGridIcon, 'selected', 'display_button-selected')
     addAnimationByPrefix(skinDisplayGridIcon, 'hover', 'display_button-hover')
     playAnim(skinDisplayGridIcon, 'static')
     scaleObject(skinDisplayGridIcon, 0.8, 0.8)
     setProperty(skinDisplayGridIcon..'.camera', instanceArg('camHUD'), false, true)
     setProperty(skinDisplayGridIcon..'.antialiasing', false)
     addLuaSprite(skinDisplayGridIcon)

     local skinGraphicGridIcon = 'graphicGridIcon-'..tostring(grid)
     makeAnimatedLuaSprite(skinGraphicGridIcon, 'noteSkins/'..g[1][grid], newSkinPosX + 16.5, newSkinPosY + 12)
     addAnimationByPrefix(skinGraphicGridIcon, 'static', 'arrowUP')
     playAnim(skinGraphicGridIcon, 'static')
     scaleObject(skinGraphicGridIcon, 0.55, 0.55)
     setProperty(skinGraphicGridIcon..'.camera', instanceArg('camHUD'), false, true)
     addLuaSprite(skinGraphicGridIcon)
end

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
setObjectOrder('displaySliderTrack', getObjectOrder('displaySliderIcon') - 0)
setProperty('displaySliderTrack.camera', instanceArg('camHUD'), false, true)
setProperty('displaySliderTrack.antialiasing', false)
addLuaSprite('displaySliderTrack')

local sliderTrackPosition = states.getPageSkinSliderPositions('notes', 'positions')
local sliderTrackDivider  = states.getPageSkinSliderPositions('notes', 'divider')
local function displaySliderMarks(uniqueTag, color, widthBy, sliderTracks, sliderIndex)
     local hitboxMarkSliderTrackTag = ('displaySliderMark${tag}${index}'):interpol({tag = uniqueTag:upperAtStart(), index = sliderIndex})
     local hitboxMarkSliderTrackX = (600 + (getProperty('displaySliderIcon.width') / 2.7)) - widthBy[2]
     local hitboxMarkSliderTrackY = sliderTracks[sliderIndex][1]

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

local sliderTrackThumbPressed = false
function sliderTrackPageFunctionality()
     if funkinlua.clickObject('displaySliderIcon') then
          sliderTrackThumbPressed = true
     end

     if sliderTrackThumbPressed == true then
          if mousePressed('left') then
               playAnim('displaySliderIcon', 'pressed')
               setProperty('displaySliderIcon.y', getMouseY('camHUD') - getProperty('displaySliderIcon.height') / 2)
          end
          if mouseReleased('left') then
               playAnim('displaySliderIcon', 'static')
               funkinlua.createTimer(nil, 0.1, function() sliderTrackThumbPressed = false end)
          end
     end

     if getProperty('displaySliderIcon.y') <= 127 then
          setProperty('displaySliderIcon.y', 127)
     end
     if getProperty('displaySliderIcon.y') >= 643 then
          setProperty('displaySliderIcon.y', 643)
     end

     for positionIndex = 1, #sliderTrackPosition do
          if sliderTrackThumbPressed == false then 
               break
          end

          local checkThumbByPosition = getProperty('displaySliderIcon.y') <= sliderTrackPosition[positionIndex][1]
          local checkThumbByDivider  = getProperty('displaySliderIcon.y') >= sliderTrackDivider[positionIndex][1]
          if checkThumbByPosition and checkThumbByDivider then
               return sliderTrackPosition[positionIndex][2]
          end
     end
end

function onUpdate(elapsed)
     if keyboardJustPressed('ONE')    then restartSong(true) end
     if keyboardJustPressed('ESCAPE') then exitSong()        end

     if mouseClicked('left')  then playSound('clicks/clickDown', 0.8) end
     if mouseReleased('left') then playSound('clicks/clickUp', 0.8) end

     setProperty('mouseHitBox.x', getMouseX('camHUD') - 3)
     setProperty('mouseHitBox.y', getMouseY('camHUD'))
end

local p = 0
local e = {['0'] = true, ['1'] = true, ['2'] = true, ['3'] = true, ['4'] = true}
function onUpdatePost(elapsed)
     p = sliderTrackPageFunctionality()
     --debugPrint(e[tostring(p)] == nil)
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