local string  = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'
local json    = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'
local global  = require 'mods.NoteSkin Selector Remastered.api.modules.global'

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

     local totalSkinObjects    = {}
     local totalSkinGroupIndex = 0
     local totalSkins = states.getTotalSkins(skin)

     totalSkinObjects[skin] = {}
     for pages = 1, #totalSkins do
          if (pages-1) % (16+1) == 0 then
               totalSkinGroupIndex = totalSkinGroupIndex + 1
               totalSkinObjects[skin][totalSkinGroupIndex] = {}
          end
     
          if pages % (16) ~= 0 then
               local totalSkinObjectGroup = totalSkinObjects[skin][totalSkinGroupIndex]
               if byData == 'skins' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = totalSkins[pages]
               elseif byData == 'ids' then
                    totalSkinObjectGroup[#totalSkinObjectGroup + 1] = pages
               end
          end
     end
     return totalSkinObjects[skin]
end

function states.getPageSkinSliderPositions(skin)
     local sliderTrackData = {}
     sliderTrackData[skin] = {intervals = {}, semiIntervals = {}, pages = {}}

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