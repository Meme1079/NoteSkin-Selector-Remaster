import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import objects.Alphabet;

var promptBGWidth  = boxWidth / 1.3;
var promptBGHeight = boxHeight / 1.3;

var promptGraphic = new FlxSprite(40, 40).makeGraphic(promptBGWidth, promptBGHeight, FlxColor.TRANSPARENT);
var promptBG = FlxSpriteUtil.drawRoundRect(promptGraphic, 0, 0, promptBGWidth, boxHeight / 1.5, 35, 35, FlxColor.BLACK);
promptBG.cameras = [game.camOther];
promptBG.alpha = 0;
promptBG.screenCenter();
game.add(promptBG);

var boldTextWidth = boxWidth / 2;
var titlePrompt:Alphabet = new Alphabet(boldTextWidth, 140, "Enter Prompt", true);
titlePrompt.cameras = [game.camOther];
titlePrompt.alpha = 0;
titlePrompt.setScale(0.85, 0.85);
titlePrompt.setAlignmentFromString('center');
game.add(titlePrompt);

var agreePrompt:Alphabet = new Alphabet(boldTextWidth - 180, 330, "Yes", true);
agreePrompt.cameras = [game.camOther];
agreePrompt.alpha = 0;
agreePrompt.setScale(0.65, 0.65);
agreePrompt.setAlignmentFromString('center');
game.add(agreePrompt);

var disagreePrompt:Alphabet = new Alphabet(boldTextWidth + 180, 330, "No", true);
disagreePrompt.cameras = [game.camOther];
disagreePrompt.alpha = 0;
disagreePrompt.setScale(0.65, 0.65);
disagreePrompt.setAlignmentFromString('center');
game.add(disagreePrompt);

FlxTween.tween(promptBG,       { alpha: 0.55 }, 0.35, { ease: FlxEase.quartInOut });
FlxTween.tween(titlePrompt,    { alpha: 1 },    0.35, { ease: FlxEase.quartInOut });
FlxTween.tween(agreePrompt,    { alpha: 1 },    0.35, { ease: FlxEase.quartInOut });
FlxTween.tween(disagreePrompt, { alpha: 1 },    0.35, { ease: FlxEase.quartInOut });

setVar('promptBGElement', promptBG);
setVar('titlePromptElement', titlePrompt);
setVar('agreePrompt', agreePrompt);
setVar('disagreePrompt', disagreePrompt);