local string  = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json    = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local global  = require 'mods.NoteSkin Selector Remastered.api.modules.global'

require 'table.new'

local states = {}
states.notes    = {prefix = 'NOTE_assets',  folder = 'noteSkins'}
states.splashes = {prefix = 'noteSplashes', folder = 'noteSplashes'}

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

     local directorySkinModFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     local directorySkinModFolder     = directoryFileList(directorySkinModFolderPath)
     for _,v in next, directorySkinModFolder do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               local includedPath = withPath == true and totalSkinFolder..'/' or ''
               totalSkins[#totalSkins + 1] = includedPath..v:match('^('..totalSkinPrefix..'%-.+)%.png$')
          end
     end
     return totalSkins
end

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

     local directorySkinModFolderPath = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     local directorySkinModFolder     = directoryFileList(directorySkinModFolderPath)
     for _,v in next, directorySkinModFolder do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = v:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          end
     end
     return totalSkins
end

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
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = totalSkinNames[pages]:lower()
               elseif byData == 'ids' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = pages
               end
          end
     end
     return totalSkinObjects[skin]
end

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

return states