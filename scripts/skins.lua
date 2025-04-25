luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'

local SkinNoteSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')


function onUpdatePost(elapsed)
     if keyboardJustPressed('TAB') then
          SkinNoteSave:set('dataSongName', '', songName)
          SkinNoteSave:set('dataDiffID',   '', tostring(difficulty))
          SkinNoteSave:set('dataDiffList', '', getPropertyFromClass('backend.Difficulty', 'list'))

          loadNewSong('Skin Selector', -1, {'Easy', 'Normal', 'Hard'})
     end
end