import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

function setObjectOrder(obj:String, pos:Int) {
     LuaUtils.getTargetInstance().remove(obj);
     LuaUtils.getTargetInstance().insert(pos, obj);
}

function checkerboardColorHex(hexString:String) {
     switch (hexString) {
          case '000000': return 0xFF000000;
          case 'FF0000': return 0xFFFF0000;
          case 'FFFF00': return 0xFFFFFF00;
          case '00FF00': return 0xFF00FF00;
          case '00FFFF': return 0xFF00FFFF;
          case '0000FF': return 0xFF0000FF;
          case 'FF00FF': return 0xFFFF00FF;
          case 'FFFFFF': return 0xFFFFFFFF;
     }
}

var gridOverlayColor = checkerboardColorHex(0xFF00FFFF);
var gridOverlay = FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFF68CBFD, 0x0);
var gridBG:FlxBackdrop = new FlxBackdrop(gridOverlay);
gridBG.velocity.set(20, 20);
gridBG.alpha = 0;
gridBG.cameras = [game.camHUD];
setObjectOrder(gridBG, 1);
add(gridBG, false);
     
FlxTween.tween(gridBG, {alpha: 0.2}, 0.5, {ease: FlxEase.quadOut});