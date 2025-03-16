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

     local directorySkinFolderPath = 'assets/shared/images/'..totalSkinFolder
     local directorySkinFolder     = directoryFileList(directorySkinFolderPath)
     for _,v in next, directorySkinFolder do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local includedPath = withPath == true and 'assets/shared/images/'..totalSkinFolder..'/' or ''
               totalSkins[#totalSkins + 1] = includedPath..v:match('^('..totalSkinPrefix..'%-.+)%.png$')
          end
     end

     local directorySkinModSubFolder  = {}
     local directorySkinModFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     local directorySkinModFolder     = directoryFileList(directorySkinModFolderPath)
     for _,v in next, directorySkinModFolder do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local includedPath = withPath == true and totalSkinFolder..'/' or ''
               totalSkins[#totalSkins + 1] = includedPath..v:match('^('..totalSkinPrefix..'%-.+)%.png$')
          end

          if not v:match('%.%w+$') then
               table.insert(directorySkinModSubFolder, v)
          end
     end

     for _,v in next, directorySkinModSubFolder do
          local directorySubSkinModFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder..'/'..v
          local directorySubSkinModFolder     = directoryFileList(directorySubSkinModFolderPath)

          for _,q in next, directorySubSkinModFolder do
               if q:match('^('..totalSkinPrefix..'%-.+)%.png$') then
                    local includedPath = withPath == true and totalSkinFolder..'/'..v..'/' or v..'/'
                    totalSkins[#totalSkins + 1] = includedPath..q:match('^('..totalSkinPrefix..'%-.+)%.png$')
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

     local directorySkinFolderPath = 'assets/shared/images/'..totalSkinFolder
     local directorySkinFolder     = directoryFileList(directorySkinFolderPath)
     for _,v in next, directorySkinFolder do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = v:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          end
     end

     local directorySkinModSubFolder  = {}
     local directorySkinModFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     local directorySkinModFolder     = directoryFileList(directorySkinModFolderPath)
     for _,v in next, directorySkinModFolder do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = v:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          end

          if not v:match('%.%w+$') then
               table.insert(directorySkinModSubFolder, v)
          end
     end

     for _,v in next, directorySkinModSubFolder do
          local directorySubSkinModFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder..'/'..v
          local directorySubSkinModFolder     = directoryFileList(directorySubSkinModFolderPath)

          for _,q in next, directorySubSkinModFolder do
               if q:match('^('..totalSkinPrefix..'%-.+)%.png$') then
                    totalSkins[#totalSkins + 1] = q:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
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
---@param skin string The specified skin to find the total amount it currently has.
---@param byData byData
---@return table[table[any]]
function states.getTotalSkinObjects(skin, byData)
     local byData = byData == nil and 'skins' or byData:lower()

     local totalSkinGroupIndex = 0
     local totalSkinObjects = table.new(0xff, 0)
     totalSkinObjects[skin] = table.new(0xff, 0)

     local totalSkinNames = states.getTotalSkinNames(skin)
     local totalSkins     = states.getTotalSkins(skin)
     for pages = 1, #totalSkins do
          if (pages-1) % 16 == 0 then --! DO NOT REMOVE PARENTHESIS
               totalSkinGroupIndex = totalSkinGroupIndex + 1
               totalSkinObjects[skin][totalSkinGroupIndex] = table.new(16, 0)
          end
     
          if pages % 16+1 ~= 0 then   --! DO NOT ADD PARENTHESIS
               local totalSkinObjectGroup = totalSkinObjects[skin][totalSkinGroupIndex]
               if byData == 'skins' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = totalSkins[pages]
               elseif byData == 'names' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = totalSkinNames[pages]
               elseif byData == 'ids' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = pages
               elseif byData == 'bools' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = false
               end
          end
     end
     return totalSkinObjects[skin]
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

---
---@param metadataFolder string
---@return table<string, any>
function states.getMetadataSkins(metadataFolder)
     local woef = table.new(0, 0xff)

     --for k,v in pairs() do
     --end
end

function states.getMetadataSkinElements()
end

return states