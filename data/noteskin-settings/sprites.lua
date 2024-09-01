local SkinStates = require 'mods.NoteSkin Selector Remastered.data.noteskin-settings.classes.SkinStates'

local string  = require 'mods.NoteSkin Selector Remastered.libraries.string'
local globals = require 'mods.NoteSkin Selector Remastered.modules.globals'
local states  = require 'mods.NoteSkin Selector Remastered.modules.states'

local switch  = globals.switch

makeLuaSprite('bgCover', 'menuDesat', 0, 0)
setObjectCamera('bgCover', 'camHUD')
setObjectOrder('bgCover', 0)
setProperty('bgCover.color', 0x5220bd)
addLuaSprite('bgCover')

makeLuaSprite('bgSideCover', 'user_interface/sidebar', 80, 0)
setObjectCamera('bgSideCover', 'camHUD')
setProperty('bgSideCover.color', 0x000000)
setProperty('bgSideCover.alpha', 0.5)
addLuaSprite('bgSideCover')

-- Header Skin Select --

makeLuaText('skinSelectText', 'Notes', 230, 7, 18)
setObjectCamera('skinSelectText', 'camHUD')
setTextFont('skinSelectText', 'sonic.ttf')
setTextAlignment('skinSelectText', 'center')
setTextSize('skinSelectText', 50)
setProperty('skinSelectText.antialiasing', false)
addLuaText('skinSelectText')

makeLuaSprite('skinSelectBG', 'user_interface/buttons_sideWidth', -15 * 7, 15)
setObjectCamera('skinSelectBG', 'camHUD')
scaleObject('skinSelectBG', 0.85, 0.85)
setProperty('skinSelectBG.color', 0x0000000)
addLuaSprite('skinSelectBG')

makeLuaSprite('skinSelectCarpet', 'user_interface/buttons_sideWidth', (-15 * 7) - 50, 15 + 13)
setObjectCamera('skinSelectCarpet', 'camHUD')
setObjectOrder('skinSelectCarpet', getObjectOrder('skinSelectBG'))
scaleObject('skinSelectCarpet', 0.85, 0.85)
setProperty('skinSelectCarpet.color', 0xff00000)
addLuaSprite('skinSelectCarpet')

makeLuaSprite('skinSelectArrowLeft', 'user_interface/buttons_arrow', 240, 25)
setObjectCamera('skinSelectArrowLeft', 'camHUD')
scaleObject('skinSelectArrowLeft', 0.18, 0.18)
setProperty('skinSelectArrowLeft.angle', -90)
addLuaSprite('skinSelectArrowLeft')

makeLuaSprite('skinSelectArrowRight', 'user_interface/buttons_arrow', 240 + 40, 25)
setObjectCamera('skinSelectArrowRight', 'camHUD')
scaleObject('skinSelectArrowRight', 0.18, 0.18)
setProperty('skinSelectArrowRight.angle', 90)
addLuaSprite('skinSelectArrowRight')

-- Page Info --

makeLuaText('skinPageCurCount', 'Page Error', 1000, -163, 675)
setObjectCamera('skinPageCurCount', 'camHUD')
setTextFont('skinPageCurCount', 'sonic.ttf')
setTextAlignment('skinPageCurCount', 'center')
setTextSize('skinPageCurCount', 30)
setProperty('skinPageCurCount.antialiasing', false)
addLuaText('skinPageCurCount')

makeLuaSprite('skinPageArrowUp', 'user_interface/buttons_arrow', 455, 670)
setObjectCamera('skinPageArrowUp', 'camHUD')
scaleObject('skinPageArrowUp', 0.18, 0.18)
addLuaSprite('skinPageArrowUp')

makeLuaSprite('skinPageArrowDown', 'user_interface/buttons_arrow', 180, 670)
setObjectCamera('skinPageArrowDown', 'camHUD')
scaleObject('skinPageArrowDown', 0.18, 0.18)
setProperty('skinPageArrowDown.flipY', true)
addLuaSprite('skinPageArrowDown')

-- Sidebar Info --

makeLuaText('sidebarVersion', 'Ver 2.0.0', 0, 1195, 5)
setTextFont('sidebarVersion', 'sonic.ttf')
setTextColor('sidebarVersion', 'fccf03')
setTextSize('sidebarVersion', 20)
setObjectCamera('sidebarVersion', 'camHUD')
setProperty('sidebarVersion.antialiasing', false)
addLuaText('sidebarVersion')

makeLuaText('sidebarSkinName', 'Funkin', 500, 753, 70) -- y: 70
setObjectCamera('sidebarSkinName', 'camHUD')
setTextFont('sidebarSkinName', 'sonic.ttf')
setTextAlignment('sidebarSkinName', 'center')
setTextSize('sidebarSkinName', 60)
setTextBorder('sidebarSkinName', 5, '000000', 'OUTLINE_FAST')
setProperty('sidebarSkinName.antialiasing', false)
addLuaText('sidebarSkinName')

makeLuaText('checkboxStatePlayerText', 'Player', 0, 775 + 80, 320)
setTextColor('checkboxStatePlayerText', '31b0d1')
setTextSize('checkboxStatePlayerText', 30)
setTextFont('checkboxStatePlayerText', 'phantummuff.ttf')
setObjectCamera('checkboxStatePlayerText', 'camHUD')
addLuaText('checkboxStatePlayerText')

makeLuaText('checkboxStateOpponentText', 'Opponent', 0, 775 + 220 + ((80 * 2) / 2), 320)
setTextColor('checkboxStateOpponentText', 'af66ce')
setTextSize('checkboxStateOpponentText', 30)
setTextFont('checkboxStateOpponentText', 'phantummuff.ttf')
setObjectCamera('checkboxStateOpponentText', 'camHUD')
addLuaText('checkboxStateOpponentText')

-- Note Options & Shits --

--[[ makeAnimatedLuaSprite('changersNoteAnimations', 'user_interface/changers/note_animations', 770, 620)
addAnimationByPrefix('changersNoteAnimations', 'confirm', 'note-confirm0', 24, false)
addAnimationByPrefix('changersNoteAnimations', 'pressed', 'note-pressed0', 24, false)
addAnimationByPrefix('changersNoteAnimations', 'colored', 'note-colored0', 24, false)
setObjectCamera('changersNoteAnimations', 'camHUD')
setGraphicSize('changersNoteAnimations', 100, 100)
playAnim('changersNoteAnimations', 'confirm', true)
addLuaSprite('changersNoteAnimations')

makeLuaText('changersHeaderNoteAnimations', 'Anims', 0, 770 + 25, 608)
setTextFont('changersHeaderNoteAnimations', 'phantummuff.ttf')
addLuaText('changersHeaderNoteAnimations')

makeLuaText('changersControlsNoteAnimations', 'LBRCKT', 0, 770 + 50, 610 + 80)
setTextFont('changersControlsNoteAnimations', 'phantummuff.ttf')
setTextSize('changersControlsNoteAnimations', 14)
addLuaText('changersControlsNoteAnimations')

makeAnimatedLuaSprite('changersNoteStyles', 'user_interface/changers/note_style', 770 + 110, 620)
addAnimationByPrefix('changersNoteStyles', 'pixel', 'note-pixel0', 24, false)
addAnimationByPrefix('changersNoteStyles', 'normal', 'note-normal0', 24, false)
setObjectCamera('changersNoteStyles', 'camHUD')
setGraphicSize('changersNoteStyles', 100, 100)
playAnim('changersNoteStyles', 'normal', true)
addLuaSprite('changersNoteStyles')

makeLuaText('changersHeaderNoteStyles', 'Styles', 0, 770 + 110 + 25, 608)
setTextFont('changersHeaderNoteStyles', 'phantummuff.ttf')
addLuaText('changersHeaderNoteStyles')

makeLuaText('changersControlsNoteStyles', 'RBRCKT', 0, 770 + 110 + 50, 610 + 80)
setTextFont('changersControlsNoteStyles', 'phantummuff.ttf')
setTextSize('changersControlsNoteStyles', 14)
addLuaText('changersControlsNoteStyles')

makeLuaSprite('changersOptions', 'user_interface/changers/note_options', 1170, 630)
setObjectCamera('changersOptions', 'camHUD')
setGraphicSize('changersOptions', 80, 80)
addLuaSprite('changersOptions')

makeLuaText('changersHeaderOptions', 'Settings', 0, 1170 + 3, 608)
setTextFont('changersHeaderOptions', 'phantummuff.ttf')
addLuaText('changersHeaderOptions') ]]

-- Mouse --

makeLuaSprite('mouseHitBox', nil, getMouseX('camHUD') - 3, getMouseY('camHUD'))
makeGraphic('mouseHitBox', 10, 10, 'ff0000')
setObjectCamera('mouseHitBox', 'camHUD')
setObjectOrder('mouseHitBox', 90E34) -- fuck you
setProperty('mouseHitBox.visible', false)
addLuaSprite('mouseHitBox', true)

setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);

-- Skins --

local Notes = SkinStates:new('note', 'noteSkins', true)
Notes:create()
Notes:checkbox(true)
Notes:pageFlip(true)

local Splashes = SkinStates:new('splash', 'noteSplashes', false)
Splashes:create()
Splashes:checkbox(true)
Splashes:pageFlip(true)

local skinStateTitle = SkinStates.SkinStateTypes
local skinStateIndex = 1
local function stateSelection()
     local function stateArrowAnims(direct, skinArrowTag)
          local prefixShrink = {['scale.x'] = 0.15, ['scale.y'] = 0.15}
          local prefixGrown  = {['scale.x'] = 0.18, ['scale.y'] = 0.18}
          local prefixTag    = skinArrowTag..direct:upperAtStart()
          if keyboardPressed(direct:upper()) then
               startTween(direct, prefixTag, prefixShrink, 0.1, {ease = 'quadout'})
          elseif keyboardReleased(direct:upper()) then
               startTween(direct, prefixTag, prefixGrown,  0.1, {ease = 'quadin'})
          end
     end

     if keyboardReleased('LEFT') then
          if skinStateIndex < 2 then skinStateIndex = 3 end
          skinStateIndex = skinStateIndex - 1
     end
     if keyboardReleased('RIGHT') then
          if skinStateIndex > 1 then skinStateIndex = 0 end
          skinStateIndex = skinStateIndex + 1
     end
     if keyboardReleased('LEFT') or keyboardReleased('RIGHT') then
          setTextString('skinSelectText', skinStateTitle[skinStateIndex]:upperAtStart())
          playSound('ping', 0.5)
     end

     local directs = {'left', 'right', 'up', 'down'}
     for dir = 1, #directs do
          local prefixTag = dir <= #directs / 2 and 'skinSelectArrow' or 'skinPageArrow'
          stateArrowAnims(directs[dir], prefixTag)
     end
end

function onUpdate(elapsed)
     switch (skinStateIndex) { -- lmao
          [1] = function()
               Notes:highlight()
               Notes:preview()
               Notes:pageFlip()
               Notes:checkbox()
               
               if keyboardReleased('LEFT') or keyboardReleased('RIGHT') then 
                    Notes:stateSwap() 
               end
          end,
          [2] = function()
               Splashes:highlight()
               Splashes:preview()
               Splashes:pageFlip()
               Splashes:checkbox()
               
               if keyboardReleased('LEFT') or keyboardReleased('RIGHT') then 
                    Splashes:stateSwap() 
               end
          end
     }
     stateSelection()
end