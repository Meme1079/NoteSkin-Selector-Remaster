local SkinSaves = {}

--- Creates a save for this mod, that's it.
---@param saveName string The global save name to utilize with.
---@param savePrefix string The prefix to concatenate with the tag.
---@param saveFolder? string The specified folder to save to.
---@return nil
function SkinSaves:new(saveName, savePrefix, saveFolder)
     local self = setmetatable({}, {__index = self})
     self.saveName   = saveName
     self.savePrefix = savePrefix
     self.saveFolder = savePath

     initSaveData(self.saveName, self.saveFolder)
     return self
end

--- Sets the data field with a new value from the save game data or be created with inherited field value. 
--- If the said data field currently doesn't exist yet.

---@param tag string The specified data field to set a new value to.
---@param value any The new value to set it to.
---@return nil
function SkinSaves:set(tag, value)
     setDataFromSave(self.saveName, self.savePrefix..'_'..tag, value)
end

--- Gets the data field current value from the save game data.
---@param prefix string The prefix to concatenate with the tag.
---@param tag string The specified data field to get its current value from.
---@param default any The field data's default value, if the inherited value doesn't exist.
---@return any
function SkinSaves:get(tag, default)
     return getDataFromSave(self.saveName, self.savePrefix..'_'..tag, default)
end

--- Saves the applied changes from the save game data, updates its content with new values.
---@return nil
function SkinSaves:flush()
     flushSaveData(self.saveName)
end

--- Erases the specified save game data, removes the sub-folder within the application data folder.
---@return nil
function SkinSaves:erase()
     eraseSaveData(self.saveName)
end

return SkinSaves