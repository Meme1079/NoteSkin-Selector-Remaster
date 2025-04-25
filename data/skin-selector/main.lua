luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinNoteSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
function onCreatePost()
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
     if keyboardJustPressed('TAB') and songName == 'Skin Selector' then
          local dataSongName = SkinNoteSave:get('dataSongName', '')
          local dataDiffID   = SkinNoteSave:get('dataDiffID',   '')
          local dataDiffList = SkinNoteSave:get('dataDiffList', '')
          loadNewSong(dataSongName, tonumber(dataDiffID), dataDiffList)
     end
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
                    removeLuaScript(v, true)
               end
          end
          allowCountdown = true;
          return Function_Stop;
     end
     setProperty('camHUD.visible', true)
     return Function_Continue;
end