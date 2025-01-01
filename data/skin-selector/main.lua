luaDebugMode = true

local string = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json   = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'


local sliderTrackPosition = states.getPageSkinSliderPositions('notes', 'positions')
local sliderTrackDivider  = states.getPageSkinSliderPositions('notes', 'divider')


local g = {}
local d = 0
for i = 1, #states.getTotalSkins('notes') do
     if (i-1) % 16 == 0 then
          d = d + 1
          g[d] = {}
     end

     if i % 16+1 ~= 0 then
          g[d][#g[d] + 1] = states.getTotalSkins('notes')[i]
     end
end

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

local function displaySliderMarks(tag, index, color, yPosition)
     local hitboxMarkSliderTrack = 'displaySliderMarks'..tag..'-'..index
     makeLuaSprite(hitboxMarkSliderTrack, nil, 600 + getProperty('displaySliderIcon.width') / 2.7, yPosition)
     makeGraphic(hitboxMarkSliderTrack, 12, 1, color)
     setObjectOrder(hitboxMarkSliderTrack, getObjectOrder('displaySliderIcon') - 0)
     setProperty(hitboxMarkSliderTrack..'.camera', instanceArg('camHUD'), false, true)
     setProperty(hitboxMarkSliderTrack..'.antialiasing', false)
     addLuaSprite(hitboxMarkSliderTrack)
end

for positionIndex = 1, #sliderTrackPosition do
     displaySliderMarks('Positions', positionIndex, 'ff0000', sliderTrackPosition[positionIndex][1])
end
for dividerIndex = 2, #sliderTrackDivider do
     displaySliderMarks('Divider', dividerIndex, 'ffff00', sliderTrackDivider[dividerIndex][1])
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


function onUpdate(elapsed)
     if keyboardJustPressed('ONE')    then restartSong(true) end
     if keyboardJustPressed('ESCAPE') then exitSong()        end

     if mouseClicked('left')  then playSound('clicks/clickDown', 0.8) end
     if mouseReleased('left') then playSound('clicks/clickUp', 0.8) end

     setProperty('mouseHitBox.x', getMouseX('camHUD') - 3)
     setProperty('mouseHitBox.y', getMouseY('camHUD'))
end

local feoi = false
local je = true


function onUpdatePost()
     if objectsOverlap('displaySliderIcon', 'mouseHitBox') and mouseClicked('left') then
          feoi = true
     end
     if feoi == true and mousePressed('left') then
          local e = getProperty('displaySliderIcon.height') / 2
          setProperty('displaySliderIcon.y', getMouseY('camHUD') - e)
          playAnim('displaySliderIcon', 'pressed')
     end
     if mouseReleased('left') then
          playAnim('displaySliderIcon', 'static')

          funkinlua.createTimer(nil, 0.1, function() feoi = false end)
     end

     if getProperty('displaySliderIcon.y') <= 127 then
          setProperty('displaySliderIcon.y', 127)
     end
     if getProperty('displaySliderIcon.y') >= 643 then
          setProperty('displaySliderIcon.y', 643)
     end

     local function jay()
          for d = 1, #sliderTrackPosition do
               if feoi == false then break end
               if getProperty('displaySliderIcon.y') <= sliderTrackPosition[d][1] and getProperty('displaySliderIcon.y') >= sliderTrackDivider[d][1] then
                    return true
               end
          end
          return false
     end

     for d = 1, #sliderTrackPosition do
          if feoi == false then break end

          if getProperty('displaySliderIcon.y') <= sliderTrackPosition[d][1] and getProperty('displaySliderIcon.y') >= sliderTrackDivider[d][1] then
               if je == true then
                    playSound('keyboard'..tostring(getRandomInt(1,3)))
                    je = false
               end
          end

          if jay() == false then
               je = true
          end
     end
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