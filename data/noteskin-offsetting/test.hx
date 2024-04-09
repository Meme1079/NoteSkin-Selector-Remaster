import flixel.addons.ui.FlxInputText;

var imageInputText = new FlxInputText(60, 640 - 100, 360, 'NOTE_assets-', 16);
imageInputText.cameras = [game.camHUD];
imageInputText.maxLength = ('NOTE_assets-').length + 30;
imageInputText.caretWidth = 5;
imageInputText.backgroundColor = 0x00000000;
imageInputText.fieldBorderColor = 0x00000000;
imageInputText.callback = function(text:String, action:String) {
     switch (action) {
          case 'enter':
               setVar('test', text);
          case 'backspace':
               imageInputText.text = 'NOTE_assets-';
               imageInputText.caretIndex = 13;
     }
     if (13 >= text.length && imageInputText.caretIndex <= 13) {
          imageInputText.text = 'NOTE_assets-';
          imageInputText.caretIndex = 13;
     }
}
add(imageInputText);