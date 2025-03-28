local string  = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json    = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local global  = require 'mods.NoteSkin Selector Remastered.api.modules.global'

require 'table.new'

local states = {}
states.notes    = {prefix = 'NOTE_assets',  folder = 'noteSkins'}
states.splashes = {prefix = 'noteSplashes', folder = 'noteSplashes'}

--- Gets the total amount of skins it has.
---@param skin string The specified skin to find the total amount it currently has.
---@param withPath? boolean Wheather the result will include a path to the skin or not.
---@return table[table[string]]
function states.getTotalSkins(skin, withPath)
     local totalSkins = {states[skin]['prefix']}
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderPath = 'assets/shared/images/'..totalSkinFolder
     local directorySkinLocalFolder     = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in next, directorySkinLocalFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local includedPath = withPath == true and 'assets/shared/images/'..totalSkinFolder..'/' or ''
               totalSkins[#totalSkins + 1] = includedPath..skins:match('^('..totalSkinPrefix..'%-.+)%.png$')
          end
     end

     local directorySkinFolderGroup = {}
     local directorySkinFolderPath  = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     local directorySkinFolder      = directoryFileList(directorySkinFolderPath)
     for _,skins in next, directorySkinFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local includedPath = withPath == true and totalSkinFolder..'/' or ''
               totalSkins[#totalSkins + 1] = includedPath..skins:match('^('..totalSkinPrefix..'%-.+)%.png$')
          end
          if not skins:match('%.%w+$') then
               table.insert(directorySkinFolderGroup, skins)
          end
     end

     for _,folders in next, directorySkinFolderGroup do
          local directorySkinSubFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder..'/'..folders
          local directorySkinSubFolder     = directoryFileList(directorySkinSubFolderPath)
          for _,skins in next, directorySkinSubFolder do
               if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
                    local includedPath = withPath == true and totalSkinFolder..'/'..skins..'/' or skins..'/'
                    totalSkins[#totalSkins + 1] = includedPath..skins:match('^('..totalSkinPrefix..'%-.+)%.png$')
               end
          end
     end
     return totalSkins
end

--- Gets the total amount of skins it has and returns said names of the skin.
---@param skin string The specified skin to find the total amount it currently has.
---@return table[table[string]]
function states.getTotalSkinNames(skin)
     local totalSkins = {'Funkin'}
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderPath = 'assets/shared/images/'..totalSkinFolder
     local directorySkinLocalFolder     = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in next, directorySkinLocalFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = skins:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          end
     end

     local directorySkinFolderGroup = {}
     local directorySkinFolderPath  = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     local directorySkinFolder      = directoryFileList(directorySkinFolderPath)
     for _,skins in next, directorySkinFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = skins:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          end
          if not skins:match('%.%w+$') then
               table.insert(directorySkinFolderGroup, skins)
          end
     end

     for _,folders in next, directorySkinFolderGroup do
          local directorySkinSubFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder..'/'..folders
          local directorySkinSubFolder     = directoryFileList(directorySkinSubFolderPath)
          for _,skins in next, directorySkinSubFolder do
               if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
                    totalSkins[#totalSkins + 1] = skins:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
               end
          end
     end
     return totalSkins
end

--- Gets the maximum limit skin pages.
---@param skin string The specified skin to find the total amount it currently has.
---@return number
function states.getTotalSkinLimit(skin)
     local totalLimit = 1
     local totalSkins = states.getTotalSkins(skin)
     for page = 1, #totalSkins do
          if page % (16+1) == 0 then
               totalLimit = totalLimit + 1
          end
     end
     return totalLimit
end

---@alias byData string What metadata it should create for.
---| 'skins' # The skin's texture path
---| 'names' # The skin's name
---| 'ids'   # The skin's corresponding ID number
---| 'bools' # THe skin's togglable values

--- Gets multiple metadata properties for the data to be used for interaction.
--- Each data within metadata properties are spliced in every 16-index, inserted to their designated page array.
---@param skin string The specified skin to find the total amount it currently has.
---@param byData byData
---@return table[table[any]]
function states.getTotalSkinObjects(skin, byData)
     local byData = byData == nil and 'skins' or byData:lower()

     local totalSkinGroupIndex = 0
     local totalSkinObjects = table.new(0xff, 0)
     totalSkinObjects[skin] = table.new(0xff, 0)

     local totalSkins     = states.getTotalSkins(skin)
     local totalSkinNames = states.getTotalSkinNames(skin)
     for objects = 1, #totalSkins do
          if (objects-1) % 16 == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinGroupIndex = totalSkinGroupIndex + 1
               totalSkinObjects[skin][totalSkinGroupIndex] = table.new(16, 0)
          end
     
          if objects % 16+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectGroup = totalSkinObjects[skin][totalSkinGroupIndex]
               if byData == 'skins' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = totalSkins[objects]
               elseif byData == 'names' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = totalSkinNames[objects]
               elseif byData == 'ids' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = objects
               elseif byData == 'bools' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = false
               end
          end
     end
     return totalSkinObjects[skin]
end

--- Gets the skin's name each are spliced in every 16-index, inserted to their designated page array.
---@param skin string The specified skin to find the total amount it currently has.
---@return table[table[any]]
function states.getTotalSkinObjectNames(skin)
     local totalSkinObjectNameIndex = 0
     local totalSkinObjectNames = table.new(0xff, 0)
     totalSkinObjectNames[skin] = table.new(0xff, 0)

     local totalSkinNames = states.getTotalSkinNames(skin)
     for objects = 1, #totalSkinNames do
          if (objects-1) % 16 == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinObjectNameIndex = totalSkinObjectNameIndex + 1
               totalSkinObjectNames[skin][totalSkinObjectNameIndex] = table.new(16, 0)
          end
     
          if objects % 16+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectNameGroup = totalSkinObjectNames[skin][totalSkinObjectNameIndex]
               totalSkinObjectNameGroup[#totalSkinObjectNameGroup + 1] = totalSkinNames[objects]
          end
     end
     return totalSkinObjectNames[skin]
end

--- Gets and calculates the positions for the slider functionality
--- If the current state has only one page, it will cause a calculation error, cuz of dividing zero.
--- If the error occured, it must have a piece of code to detect it to prevent visual bugs.
---@param skin The specified skin to contain the positions
---@return table[table[number]]
function states.getPageSkinSliderPositions(skin)
     local sliderTrackData = table.new(3, 0)
     sliderTrackData[skin] = {intervals = table.new(0xff, 0), semiIntervals = table.new(0xff, 0), pages = table.new(0xff, 0)}

     local totalSkinMax = states.getTotalSkinLimit(skin)-1
     local totalSliderHeight = 570
     for pages = 0, totalSkinMax+1 do
          local intervals     = (pages / totalSkinMax) * totalSliderHeight
          local semiIntervals = ( (((pages-1) / totalSkinMax) + (pages / totalSkinMax)) / 2) * totalSliderHeight

          table.insert(sliderTrackData[skin]['intervals'], intervals + 127)
          table.insert(sliderTrackData[skin]['semiIntervals'], semiIntervals + 127)
          table.insert(sliderTrackData[skin]['pages'], pages + 1)
     end

     local overIntervals     = (totalSkinMax + 1 / totalSkinMax) * totalSliderHeight
     local overSemiIntervals = ( (((totalSkinMax-1) / totalSkinMax) + (totalSkinMax / totalSkinMax)) / 2) * totalSliderHeight
     table.insert(sliderTrackData[skin]['intervals'], overIntervals + 127)
     table.insert(sliderTrackData[skin]['semiIntervals'], overSemiIntervals + 127)
     return sliderTrackData[skin]
end

--- Gets the total amount of skin metadata it has.
---@param skin string The specified skin to find the total amount of metadata it currently has.
---@param metadataFolder string The specified metadata folder to get the amount of metadata.
---@return table<string, any>
function states.getMetadataSkins(skin, metadataFolder)
     local totalSkins      = {}
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinLocalFolderGroup = {'funkin.json'}
     local directorySkinLocalFolderPath  = 'assets/shared/images/'..totalSkinFolder
     local directorySkinLocalFolder      = directoryFileList(directorySkinLocalFolderPath)
     for _,skins in next, directorySkinLocalFolder do
          if skins:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local skinName = skins:match('^'..totalSkinPrefix..'%-(.+)%.png$'):gsub('%s', '_'):lower()
               table.insert(directorySkinLocalFolderGroup, skinName..'.json')
          end
     end

     local directoryMetadataFolderGroup = {}
     local directoryMetadataFolderPath  = 'mods/NoteSkin Selector Remastered/json/'..skin..'/'..metadataFolder
     local directoryMetadataFolder      = directoryFileList(directoryMetadataFolderPath)
     for _,skins in next, directoryMetadataFolder do
          if skins:match('.-%.json$') then
               local skinMetadataTemp = {skin = skin, file = skins:match('.-%.json$')}
               local skinMetadata     = ('json/${skin}/${file}'):interpol(skinMetadataTemp)
               totalSkins[#totalSkins + 1] = skinMetadata
          end
          if not skins:match('%.%w+$') then
               table.insert(directoryMetadataFolderGroup, skins)
          end
     end

     for _,folders in next, directoryMetadataFolderGroup do
          local directoryMetadataSubFolderPath = 'mods/NoteSkin Selector Remastered/json/'..skin..'/'..metadataFolder..'/'..folders
          local directoryMetadataSubFolder     = directoryFileList(directoryMetadataSubFolderPath)
          for _,skins in next, directoryMetadataSubFolder do
               if skins:match('.-%.json$') then
                    local skinMetadataTemp = {skin = skin, folder = folders, file = skins:match('.-%.json$')}
                    local skinMetadata     = ('json/${skin}/${folder}/${file}'):interpol(skinMetadataTemp)
                    totalSkins[#totalSkins + 1] = skinMetadata
               end
          end
     end

     table.sort(totalSkins) -- this table sort function is a heterosexual
     for localSkinInd, localSkins in next, directorySkinLocalFolderGroup do
          local skinMetadata = ('json/${skin}/${file}'):interpol({skin = skin, file = localSkins})
          table.remove(totalSkins, table.find(totalSkins, skinMetadata))
          table.insert(totalSkins, localSkinInd, skinMetadata)
     end
     return totalSkins
end

local stateMetadataObjectNames = table.new(0xff, 0)
local stateMetadataObjectDatas = table.new(0xff, 0)
local stateMetadataObjectIndex = table.new(0xff, 0)
function states.getMetadataObjectSkins(skin, metadataFolder)
     local totalSkinObjectMetadataIndex = 0
     local totalSkinObjectMetadatas = table.new(0xff, 0)
     totalSkinObjectMetadatas[skin] = table.new(0xff, 0)

     local totalSkinNames     = states.getTotalSkinNames(skin)
     local totalSkinMetadatas = states.getMetadataSkins(skin, metadataFolder)
     for objects = 1, #totalSkinMetadatas do
          table.insert(stateMetadataObjectNames, totalSkinNames[objects]:gsub('%s', '_'):lower())
          table.insert(stateMetadataObjectDatas, totalSkinMetadatas[objects]:match('.+/(.-)%.json'))
     end
     for objects = 1, #totalSkinMetadatas do
          table.insert(stateMetadataObjectIndex, objects, table.find(stateMetadataObjectNames, stateMetadataObjectDatas[objects]))
     end
     for objects = 1, #totalSkinMetadatas do
          if (objects-1) % 16 == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinObjectMetadataIndex = totalSkinObjectMetadataIndex + 1
               totalSkinObjectMetadatas[skin][totalSkinObjectMetadataIndex] = table.new(16, 0)
          end
          if objects % 16+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectMetadataGroup = totalSkinObjectMetadatas[skin][totalSkinObjectMetadataIndex]
               if stateMetadataObjectIndex[table.find(stateMetadataObjectIndex, objects)] == nil then
                    totalSkinObjectMetadataGroup[#totalSkinObjectMetadataGroup + 1] = false
               else
                    totalSkinObjectMetadataGroup[#totalSkinObjectMetadataGroup + 1] = totalSkinMetadatas[objects]
               end
          end
     end
     return totalSkinObjectMetadatas[skin]
end

function states.getMetadataSkinElements(skin, metadataFolder)
end

return states