import backend.InputFormatter;
import backend.Difficulty;
import backend.Highscore;
import backend.Song;
import states.LoadingState;

createGlobalCallback('getKeyBinds', function(noteType:Int = 1) {
     var binds = ClientPrefs.keyBinds;
     var input = InputFormatter.getKeyName;
     switch (noteType) {
          case 1:  return input(binds.get('note_left')[0]);
          case 2:  return input(binds.get('note_down')[0]);
          case 3:  return input(binds.get('note_up')[0]);
          case 4:  return input(binds.get('note_right')[0]);
          default: return 'invalid, stupid';
     }
});

// By, Rodney
createGlobalCallback('loadNewSong', function(name:String = null, difficultyNum:Int = -1, difficultyArray:Array<String> = null) {
     if (difficultyArray != null) Difficulty.list = difficultyArray;
     if (name == null || name.length < 1) name = PlayState.SONG.song;
     if (difficultyNum == -1) difficultyNum = PlayState.storyDifficulty;

     var bigAssShit = Highscore.formatSong(name, difficultyNum);
     PlayState.SONG = Song.loadFromJson(bigAssShit, name);
     PlayState.storyDifficulty = difficultyNum;
     game.persistentUpdate = false;
     LoadingState.loadAndSwitchState(new PlayState());

     FlxG.sound.music.pause();
     FlxG.sound.music.volume = 0;
     if (game.vocals != null) {
         game.vocals.pause();
         game.vocals.volume = 0;
     }
     FlxG.camera.followLerp = 0;
});