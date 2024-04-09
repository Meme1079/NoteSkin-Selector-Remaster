function onCreate()
     makeLuaSprite('a', nil, 0, 0)
     makeGraphic('a', 2500, 1500, 'ababab')
     setObjectCamera('a', 'camHUD')
     addLuaSprite('a', true)

     makeLuaSprite('c', nil, 54 - 3, 640 - 101 - 3)
     makeGraphic('c', 380 + 6, 24 + 6, '000000')
     setObjectCamera('c', 'camHUD')
     addLuaSprite('c', true)

     makeLuaSprite('b', nil, 54, 640 - 101)
     makeGraphic('b', 380, 24, 'ffffff')
     setObjectCamera('b', 'camHUD')
     addLuaSprite('b', true)

     
end

function onCreatePost()
     callMethod('uiGroup.remove', {instanceArg('iconP1')})
     callMethod('uiGroup.remove', {instanceArg('iconP2')})
     callMethod('uiGroup.remove', {instanceArg('healthBar')})
     callMethod('uiGroup.remove', {instanceArg('scoreTxt')})
     callMethod('uiGroup.remove', {instanceArg('botplayTxt')})

     setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);
end

function onUpdate(elapsed)
     if keyboardJustPressed('ONE')    then restartSong(true) end
     if keyboardJustPressed('ESCAPE') then exitSong()        end

end

local allowCountdown = false;
function onStartCountdown()
     if not allowCountdown then -- Block the first countdown
          allowCountdown = true;
          return Function_Stop;
     end
     setProperty('camHUD.visible', true)
     return Function_Continue;
end
