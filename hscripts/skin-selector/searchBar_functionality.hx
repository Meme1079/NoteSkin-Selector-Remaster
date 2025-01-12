import flixel.FlxG;
import flixel.util.FlxTimer;
import backend.ui.PsychUIInputText;
import backend.ClientPrefs;
import backend.Paths;

function onCreate() {
     var searchBarInput:PsychUIInputText = new PsychUIInputText(34, 54+12, 385, '', 31);
     searchBarInput.textObj.font  = Paths.mods('NoteSkin Selector Remastered/fonts/sonic.ttf');
     searchBarInput.textObj.color = FlxColor.WHITE;
     searchBarInput.textObj.antialiasing = false;
     searchBarInput.bg.visible           = false;
     searchBarInput.behindText.visible   = false;
     searchBarInput.caret.alpha  = 0;
     searchBarInput.cameras      = [game.camHUD];
     searchBarInput.onChange     = function(preText:String, curText:String) {          
          FlxG.sound.play(Paths.sound( 'keyclicks/keyClick' + Std.string(FlxG.random.int(1,8)) ));
          
          if (curText.length > 0) {
               game.getLuaObject('searchBarInputPlaceHolder').text = '';          
          } else {
               game.getLuaObject('searchBarInputPlaceHolder').text = 'Search Skins...';
          }
     
          ClientPrefs.toggleVolumeKeys(false); game.allowDebugKeys = false;
          new FlxTimer().start(0.1, () -> {
               ClientPrefs.toggleVolumeKeys(true); game.allowDebugKeys = true;
          });
     }
     searchBarInput.onPressEnter = function() { 
          setVar('searchBarInputContent', searchBarInput.text); 
     }
     add(searchBarInput);

     game.getLuaObject('searchBarInputCaret').x = searchBarInput.caret.x + 1;
     game.getLuaObject('searchBarInputCaret').y = searchBarInput.caret.y;
     setVar('searchBarInput', searchBarInput);

     createGlobalCallback('searchBarInput_onFocus', function() {
          return PsychUIInputText.focusOn != null && PsychUIInputText.focusOn == searchBarInput;
     });
}

function onUpdate(elapsed:Float) {
     game.getLuaObject('searchBarInputCaret').x       = getVar('searchBarInput').caret.x + 1;
     game.getLuaObject('searchBarInputCaret').visible = getVar('searchBarInput').caret.visible;
}