luaDebugMode = true

local SkinSaves = require 'mods.NoteSkin Selector Remastered.api.classes.skins.static.SkinSaves'
local SkinNotes = require 'mods.NoteSkin Selector Remastered.api.classes.skins.SkinNotes'
local Cursor    = require 'mods.NoteSkin Selector Remastered.api.classes.Cursor'

local string    = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local json      = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'
local states    = require 'mods.NoteSkin Selector Remastered.api.modules.states'
local global    = require 'mods.NoteSkin Selector Remastered.api.modules.global'

local switch         = global.switch
local createTimer    = funkinlua.createTimer
local clickObject    = funkinlua.clickObject
local pressedObject  = funkinlua.pressedObject
local releasedObject = funkinlua.releasedObject
local keyboardJustConditionPressed  = funkinlua.keyboardJustConditionPressed
local keyboardJustConditionPress    = funkinlua.keyboardJustConditionPress
local keyboardJustConditionReleased = funkinlua.keyboardJustConditionReleased

local SkinSplashSave = SkinSaves:new('noteskin_selector', 'NoteSkin Selector')
local SkinCursor     = Cursor:new()
SkinCursor:load('default')

---@class SkinSplashes
local SkinSplashes = SkinNotes:new()

--- Initializes the creation of a skin state to display skins.
---@param stateClass
---@param stateStart string The given starting skin state to display first when created.
---@param stateType table[string] The given skin states within a group to display later.
---@param statePath table[string] The given corresponding image paths to each skin states.
---@return table
function SkinSplashes:new(stateClass, startStart, stateTypes, statePaths)
     local self = setmetatable({}, {__index = self})
     self.stateClass = stateClass
     self.stateType  = stateTypes
     self.statePath  = statePaths
     self.stateStart = stateStart

     return self
end

--- Loads table data for the methods to use later.
--- Loads a bunch of data to the class
---@return nil
function SkinSplashes:load()
     self.metadata_display = json.parse(getTextFromFile('json/'..self.currentState..'/metadata_display.json'))
     self.metadata_preview = json.parse(getTextFromFile('json/'..self.currentState..'/metadata_preview.json'))
    
     self.totalSkinLimit              = states.getTotalSkinLimit(self.currentState)
     self.totalSkinObjects            = states.getTotalSkinObjects(self.currentState)
     self.totalSkinObjectID           = states.getTotalSkinObjects(self.currentState, 'ids')
     self.totalSkinObjectNames        = states.getTotalSkinObjects(self.currentState, 'names')
     
     self.totalSkinObjectHovered      = states.getTotalSkinObjects(self.currentState, 'bools')
     self.totalSkinObjectClicked      = states.getTotalSkinObjects(self.currentState, 'bools')
     self.totalSkinObjectSelected     = states.getTotalSkinObjects(self.currentState, 'bools')

     self.sliderPageIndex             = 1
     self.sliderTrackIntervals        = states.getPageSkinSliderPositions(self.currentState).intervals
     self.sliderTrackSemiIntervals    = states.getPageSkinSliderPositions(self.currentState).semiIntervals

     self.selectSkinPagePositionIndex = 1     -- lordx
     self.selectSkinInitSelectedIndex = 0     -- d2011x
     self.selectSkinPreSelectedIndex  = 0     -- xeno
     self.selectSkinCurSelectedIndex  = 0     -- s2017x
     self.selectSkinHasBeenClicked    = false -- sunky
end

--- Creates a chunk from the current skin state selected to display skins.
---@param index? integer The chunk position index to display.
---@return nil
function SkinSplashes:create(index)

end

--- Creates and loads chunks from the current skin state, improves optimization significantly
---@param index? integer The chunk position index to display.
---@return nil
function SkinSplashes:create_preload()

end

local sliderTrackThumbPressed = false
local sliderTrackToggle       = false
local sliderTrackCurrentPage  = 0
--- Main functionlity of the slider for switching pages.
---@param snapToPage? boolean Whether to enable snap to page when scrolling through pages.
---@return nil
function SkinSplashes:page_slider(snapToPage)

end

--- Alternative functionlity of the slider for switching pages.
---@return nil
function SkinSplashes:page_moved()

end

--- Setups the current page text, that's it.
---@return nil
function SkinSplashes:page_setup()

end

--- Searches and finds the given skin.
---@return nil
function SkinSplashes:found()

end

--- Selects the certain skin by a click or a search
---@return nil
function SkinSplashes:selection()

end

--- Syncs the saved selection of the certain skin
---@param bySearch boolean Whether to use by the search functionality or not.
---@return nil
function SkinSplashes:selection_sync(bySearch)

end

function SkinSplashes:preview()

end

function SkinSplashes:switch()

end


--- Precaches the images to each skin states for optimizations.
---@return nil
function SkinSplashes:precache()

end

return SkinSplashes