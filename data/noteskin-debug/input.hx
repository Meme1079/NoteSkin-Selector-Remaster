import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxInputText;
import backend.Paths;

var fileInputInfo:FlxText;
var fileInputStatus:FlxText;
var fileInputPromptGraphic:FlxSprite;
var fileInputPrompt:FlxSprite;
var fileInputInfoIcon:FlxSprite;

var fileInputDeleteText:FlxText;
var fileInputDeleteTextControl:FlxText;
var fileInputSaveText:FlxText;
var fileInputSaveTextControl:FlxText;
var fileInputEraseText:FlxText;
var fileInputEraseTextControl:FlxText;

var fileInputTextOutline:FlxSprite;
var fileInputTextBG:FlxSprite;
var fileInputText:FlxInputText;
var fileInputTextFocused:Bool;

var fileInputStatusStun  = true;
var fileInputStatusDelay = (status:String, color:Int, sound:String, Delay:Float, extra:Any) -> {
     if (fileInputStatusStun == true) {
          FlxG.sound.play(Paths.sound(sound), 0.8);
          fileInputStatus.text  = status;
          fileInputStatus.color = color;
          fileInputStatus.visible = true;
          if (extra != null) extra();
     
          fileInputStatusStun = false;
          new FlxTimer().start(Delay, () -> { fileInputStatusStun = true; });
     }
}

function onCreate() {
     fileInputPromptGraphic = new FlxSprite(28, 450).makeGraphic(530, 200, FlxColor.TRANSPARENT);
     fileInputPrompt = FlxSpriteUtil.drawRoundRect(fileInputPromptGraphic, 0, 0, 530, 200, 15, 15, FlxColor.BLACK);
     fileInputPrompt.cameras = [game.camHUD];
     fileInputPrompt.alpha = 0.5;
     game.add(fileInputPrompt);

     fileInputInfo = new FlxText(51, 470, 0, 'Noteskin File Name:', 16);
     fileInputInfo.setFormat(null, 16, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
     fileInputInfo.cameras = [game.camHUD];
     fileInputInfo.borderSize = 2;
     add(fileInputInfo);

     fileInputStatus = new FlxText(51 * 5.5, 470, 0, '', 16);
     fileInputStatus.setFormat(null, 16, FlxColor.RED, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
     fileInputStatus.cameras = [game.camHUD];
     fileInputStatus.borderSize = 2;
     fileInputStatus.visible = false;
     add(fileInputStatus);

     /* Text Help */

     function createTextHelp(tag:Array<String>, content:Array<String>, y:Float) {
          tag[0] = new FlxText(51, y, 0, content[0], 16);
          tag[0].setFormat(null, 16, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
          tag[0].cameras = [game.camHUD];
          tag[0].borderSize = 2;
          add(tag[0]);
     
          tag[1] = new FlxText(51 + 250, y, 0, content[1], 16);
          tag[1].setFormat(null, 16, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
          tag[1].cameras = [game.camHUD];
          tag[1].borderSize = 2;
          add(tag[1]);
     }

     final fileInputVars:Array<String>    = ['fileInputDeleteText', 'fileInputSaveText', 'fileInputEraseText'];
     final fileInputSetting:Array<String> = ['Delete All Text:', 'Save Data Positions:', 'Erase All Data Files:'];
     final fileInputControl:Array<String> = ['[CTRL + BACKSPACE]', '[SHIFT + M]', '[SHIFT + B]'];
     final fileInputY:Array<Float> = [540, 550 + 30, 550 + 55];
     for (i in 0...fileInputVars.length + 1) {
          var tags:Array<String>    = [fileInputVars[i], fileInputVars[i] + 'Control'];
          var content:Array<String> = [fileInputSetting[i], fileInputControl[i]];
          createTextHelp(tags, content, fileInputY[i]);
     }
     
     /* Noteskin File Input */

     final fileInputTextProps:Map<Int> = ["x" => 54, "y" => 640 - 141, "width" => 470, "height" => 24];
     fileInputTextOutline = new FlxSprite(fileInputTextProps['x'] - 3, fileInputTextProps['y'] - 3);
     fileInputTextOutline.makeGraphic(fileInputTextProps['width'] + 6, fileInputTextProps['height'] + 6, FlxColor.BLACK);
     fileInputTextOutline.cameras = [game.camHUD];
     add(fileInputTextOutline);

     fileInputTextBG = new FlxSprite(fileInputTextProps['x'], fileInputTextProps['y']);
     fileInputTextBG.makeGraphic(fileInputTextProps['width'], fileInputTextProps['height'], FlxColor.WHITE);
     fileInputTextBG.cameras = [game.camHUD];
     add(fileInputTextBG);

     fileInputText = new FlxInputText(60, 640 - 140, 450, 'NOTE_assets-', 16);
     fileInputText.cameras    = [game.camHUD];
     fileInputText.maxLength  = ('NOTE_assets-').length + 30;
     fileInputText.caretWidth = 5;
     fileInputText.backgroundColor  = FlxColor.TRANSPARENT;
     fileInputText.fieldBorderColor = FlxColor.TRANSPARENT;
     fileInputText.focusGained = function() { fileInputTextFocused = true;  }
     fileInputText.focusLost   = function() { fileInputTextFocused = false; }
     fileInputText.callback    = function(text:String, action:String) {
          if (action == 'enter') {
               if (getNotes.contains(text)) { // better code lol
                    FlxG.sound.play(Paths.sound('ding'));
                    game.setOnScripts('fileInputTextData', text);
                    game.getLuaObject('nails').visible = false;
                    fileInputStatus.visible = false;
               } else {
                    fileInputStatusDelay('ERROR: Invalid File Name', FlxColor.RED, 'denied', 2.0, () -> {
                         game.setOnScripts('fileInputTextData', null);
                    });
               }
          } else {
               game.getLuaObject('nails').visible = false;
               fileInputStatus.visible = false;
          }

          if (fileInputText.caretIndex <= 12) {
               fileInputText.text = 'NOTE_assets-';
               fileInputText.caretIndex = 12;
          }
     }
     add(fileInputText);
}

function onUpdate(elapsed:Float) {     
     if (fileInputTextFocused && FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.BACKSPACE) {
          fileInputText.text = 'NOTE_assets-';
          fileInputText.caretIndex = 13;
     }

     if (!fileInputTextFocused && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.M) {
          fileInputStatusDelay('SAVED: Data Offset Saved', FlxColor.LIME, 'saved', 2.0, null);
     }
     if (!fileInputTextFocused && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.B) {
          fileInputStatusDelay('ERASED: Data All Cleared', 0xffba0000, 'erased', 1.0, null);
          game.getLuaObject('nails').visible = false;
     }
     game.setOnScripts('fileInputTextFocused', fileInputTextFocused);
}