local Save = require 'mods.NoteSkin Selector Remastered.data.noteskin-settings.classes.Save'

local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.libraries.string'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local function getJsonData(path)
     local JSONpath = 'mods/NoteSkin Selector Remastered/jsons/'..path
     return json.parse(globals.getTextFileContent(JSONpath), true)
end

local function toAllMetatable(tab, default)
     local duplicateMetaData = { 
          __index    = function() return default end,
          __newindex = function() return default end
     }
     local duplicate = {}
     for keys, values in pairs(tab) do
		if type(values) == "table" then
               values = toAllMetatable(setmetatable(values, duplicateMetaData), default)
          else
               values = values
          end
          duplicate[keys] = values
     end
     return setmetatable(duplicate, duplicateMetaData)
end

local SkinStateSaves = Save:new('noteskin_selector', 'NoteSkin Selector')
local SkinStates = {}
function SkinStates:new(stateStart, stateTypes, statePaths)
     local self = setmetatable({}, {__index = self})
     self.stateStart = stateStart
     self.stateTypes = stateTypes
     self.statePaths = statePaths

     return self
end

-- local test = SkinStates:new('notes', {'notes', 'splashes'}, {'noteSkins', 'noteSplashes'})

function SkinStates:create()
end

function SkinStates:page()
end

function SkinStates:hover()
end

function SkinStates:selection()
end

function SkinStates:switch()
end

return SkinStates