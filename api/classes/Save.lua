local Save = {}

function Save:new(saveName, saveFolder)
     local self = setmetatable({}, {__index = self})
     self.saveName   = saveName
     self.saveFolder = savePath

     initSaveData(self.saveName, self.saveFolder)
     return self
end

function Save:set(tag, value)
     setDataFromSave(self.saveName, tag, value)
end

function Save:get(tag, altValue)
     return getDataFromSave(self.saveName, tag) or altValue
end

function Save:flush()
     flushSaveData(self.saveName)
end

function Save:erase(tag, value)
     eraseSaveData(self.saveName)
end

return Save