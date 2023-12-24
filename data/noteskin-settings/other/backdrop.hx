import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

function setObjectOrder(obj:String, pos:Int) {
     LuaUtils.getTargetInstance().remove(obj);
     LuaUtils.getTargetInstance().insert(pos, obj);
}

function onCreatePost() {
     var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFF00FFFF, 0x0));
     grid.velocity.set(20, 20);
     grid.alpha = 0;
     grid.cameras = [game.camHUD];
     setObjectOrder(grid, 1);
     FlxTween.tween(grid, {alpha: 0.15}, 0.5, {ease: FlxEase.quadOut});
     add(grid, false);
}
