local SkinSaves = require 'mods.NoteSkin Selector Remastered.data.noteskin-settings.classes.SkinSaves'

local table     = require 'mods.NoteSkin Selector Remastered.libraries.table'
local string    = require 'mods.NoteSkin Selector Remastered.libraries.string'
local json      = require 'mods.NoteSkin Selector Remastered.libraries.json.main'
local globals   = require 'mods.NoteSkin Selector Remastered.modules.globals'
local states    = require 'mods.NoteSkin Selector Remastered.modules.states'
local funkinlua = require 'mods.NoteSkin Selector Remastered.modules.funkinlua'

local SkinStateSaves = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')


function onUpdatePost()

end

function onUpdate(elapsed)
     if getModSetting('enable_double-tapping_safe', 'NoteSkin Selector Remastered') then
          if funkinlua.keyboardJustDoublePressed('TAB') then
               loadNewSong('NoteSkin Settings')
          end
     else
          if keyboardJustPressed('TAB') then
               loadNewSong('NoteSkin Settings')
          end
     end
end