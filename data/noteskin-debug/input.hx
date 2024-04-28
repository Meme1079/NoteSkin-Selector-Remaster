import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxInputText;
import backend.Paths;

var fileInputInfo:FlxText;
var fileInputError:FlxText;
var fileInputShortCut:FlxText;

var fileInputTextOutline:FlxSprite;
var fileInputTextBG:FlxSprite;
var fileInputText:FlxInputText;
var fileInputTextFocused:Bool;
function onCreate() {
     fileInputInfo = new FlxText(51, 510, 0, 'Noteskin File Name:', 16);
     fileInputInfo.setFormat(null, 16, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
     fileInputInfo.cameras = [game.camHUD];
     fileInputInfo.borderSize = 2;
     add(fileInputInfo);

     fileInputError = new FlxText(51 * 5.5, 510, 0, 'ERROR: Invalid File Name', 16);
     fileInputError.setFormat(null, 16, FlxColor.RED, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
     fileInputError.cameras = [game.camHUD];
     fileInputError.borderSize = 2;
     fileInputError.visible = false;
     add(fileInputError);
     
     fileInputShortCut = new FlxText(51, 590, 0, 'Delete All Text (CONTROL + DELETE)', 16);
     fileInputShortCut.setFormat(null, 16, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
     fileInputShortCut.cameras = [game.camHUD];
     fileInputShortCut.borderSize = 2;
     add(fileInputShortCut);

     /* Noteskin File Input */

     final fileInputTextProps:Map<Int> = ["x" => 54, "y" => 640 - 101, "width" => 470, "height" => 24];
     fileInputTextOutline = new FlxSprite(fileInputTextProps['x'] - 3, fileInputTextProps['y'] - 3);
     fileInputTextOutline.makeGraphic(fileInputTextProps['width'] + 6, fileInputTextProps['height'] + 6, FlxColor.BLACK);
     fileInputTextOutline.cameras = [game.camHUD];
     add(fileInputTextOutline);

     fileInputTextBG = new FlxSprite(fileInputTextProps['x'], fileInputTextProps['y']);
     fileInputTextBG.makeGraphic(fileInputTextProps['width'], fileInputTextProps['height'], FlxColor.WHITE);
     fileInputTextBG.cameras = [game.camHUD];
     add(fileInputTextBG);

     fileInputText = new FlxInputText(60, 640 - 100, 450, 'NOTE_assets-', 16);
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
                    fileInputError.visible = false;
               } else {
                    FlxG.sound.play(Paths.sound('denied'), 0.8);
                    game.setOnScripts('fileInputTextData', null);
                    fileInputError.visible = true;
               }
          } else {
               fileInputError.visible = false;
               game.getLuaObject('controlSaveMessageJson').visible = false;
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
     game.setOnScripts('fileInputTextFocused', fileInputTextFocused);
}