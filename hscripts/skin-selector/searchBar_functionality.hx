import flixel.FlxG;
import flixel.util.FlxTimer;
import backend.ui.PsychUIInputText;
import backend.ClientPrefs;
import backend.Paths;

var searchBarInput:PsychUIInputText = new PsychUIInputText(34, 54+12, 385, '', 31);
function onCreate() {
     searchBarInput.textObj.font  = Paths.mods('NoteSkin Selector Remastered/fonts/sonic.ttf');
     searchBarInput.textObj.color = FlxColor.WHITE;
     searchBarInput.textObj.antialiasing = false;
     searchBarInput.bg.visible           = false;
     searchBarInput.behindText.visible   = false;
     searchBarInput.caret.alpha     = 0;
     searchBarInput.selection.color = 0xFF1565DE;
     searchBarInput.cameras         = [game.camHUD];
     searchBarInput.maxLength       = 50;
     searchBarInput.onChange        = function(preText:String, curText:String) {
          FlxG.sound.play(Paths.sound( 'keyclicks/keyClick' + Std.string(FlxG.random.int(1,8)) ));

          if (curText.length > 0) {
               game.getLuaObject('searchBarInputPlaceHolder').text  = '';
          } else {
               game.getLuaObject('searchBarInputPlaceHolder').text  = 'Search Skins...';
               game.getLuaObject('searchBarInputPlaceHolder').color = 0xFFB3B3B5;
          }

          if (curText.length >= 50) {
               FlxG.sound.play(Paths.sound('cancel'), 0.5);
               searchBarInput.textObj.color = FlxColor.RED;
          } else {
               searchBarInput.textObj.color = FlxColor.WHITE;
          }
     }
     searchBarInput.onPressEnter = function() { 
          searchBarInput.textObj.color = 0xFFF0B72F;
          setVar('searchBarInputContent', searchBarInput.text);
          
          new FlxTimer().start(0.1, () -> { PsychUIInputText.focusOn = null; });
          new FlxTimer().start(0.3, () -> { setVar('searchBarInputContent', ''); }); // forcefully resets, due to a bug
     }
     add(searchBarInput);
     game.getLuaObject('searchBarInputCaret').x = searchBarInput.caret.x + 1;
     game.getLuaObject('searchBarInputCaret').y = searchBarInput.caret.y;
     setVar('searchBarInput', searchBarInput);
}

var searchBarInputFocusToggle = false;
function onUpdate(elapsed:Float) {
     setVar('searchBarFocus', PsychUIInputText.focusOn != null && PsychUIInputText.focusOn == getVar('searchBarInput'));

     var visibility = PsychUIInputText.focusOn == null ? false : getVar('searchBarInput').caret.visible;
     game.getLuaObject('searchBarInputCaret').visible = visibility;
     game.getLuaObject('searchBarInputCaret').x       = getVar('searchBarInput').caret.x + 1;
     if (getVar('searchBarFocus') == true && searchBarInputFocusToggle == false) {
          ClientPrefs.toggleVolumeKeys(false);
          game.allowDebugKeys = false;

          searchBarInputFocusToggle = true;
     }
     if (getVar('searchBarFocus') == false && searchBarInputFocusToggle == true){
          ClientPrefs.toggleVolumeKeys(true);
          game.allowDebugKeys = true;

          searchBarInputFocusToggle = false;
     }
}