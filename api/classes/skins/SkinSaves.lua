local SkinSaves = {}

function SkinSaves:new(saveName, saveFolder)
     local self = setmetatable({}, {__index = self})
     self.saveName   = saveName
     self.saveFolder = savePath

     initSaveData(self.saveName, self.saveFolder)
     return self
end

function SkinSaves:set(tag, value)
     setDataFromSave(self.saveName, tag, value)
end

function SkinSaves:get(tag, altValue)
     return getDataFromSave(self.saveName, tag) or altValue
end

function SkinSaves:flush()
     flushSaveData(self.saveName)
end

function SkinSaves:erase(tag, value)
     eraseSaveData(self.saveName)
end

return SkinSaves