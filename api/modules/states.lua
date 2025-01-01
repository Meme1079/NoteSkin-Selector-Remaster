local string  = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string'

local states = {}
states.notes    = {prefix = 'NOTE_assets',  folder = 'noteSkins'}
states.splashes = {prefix = 'noteSplashes', folder = 'noteSplashes'}

function states.getTotalSkins(skin)
     local totalSkins = {states[skin]['prefix']}
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinFolder = 'assets/shared/images/'..totalSkinFolder
     for _,v in next, directoryFileList(directorySkinFolder) do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = v:match('^('..totalSkinPrefix..'%-.+)%.png$')
          end
     end
     local directorySkinModFolder = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     for _,v in next, directoryFileList(directorySkinModFolder) do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = v:match('^('..totalSkinPrefix..'%-.+)%.png$')
          end
     end
     return totalSkins
end

function states.getTotalSkinNames(skin)
     local totalSkins = {'Funkin'}
     local totalSkinPrefix = states[skin]['prefix']
     local totalSkinFolder = states[skin]['folder']

     local directorySkinFolder = 'assets/shared/images/'..totalSkinFolder
     for _,v in next, directoryFileList(directorySkinFolder) do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = v:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          end
     end
     local directorySkinModFolder = 'mods/NoteSkin Selector Remastered/images/'..totalSkinFolder
     for _,v in next, directoryFileList(directorySkinModFolder) do
          if v:match('^('..totalSkinPrefix..'%-.+)%.png$') then
               totalSkins[#totalSkins + 1] = v:match('^'..totalSkinPrefix..'%-(.+)%.png$'):upperAtStart()
          end
     end
     return totalSkins
end

function states.getTotalSkinLimit(skin)
     local totalLimit = 0
     for page = 1, #states.getTotalSkins(skin) do
          if page % 16 == 0 then
               totalLimit = totalLimit + 1
          end
     end
     return totalLimit
end

function states.getPageSkinSliderPositions(skin, data)
     local sliderTrackPosition = {}
     local sliderTrackDivider  = {}

     local totalSkinMax = states.getTotalSkinLimit(skin)
     local totalSliderHeight = 570
     for pages = 0, totalSkinMax do
          local position = (pages / totalSkinMax) * totalSliderHeight
          local divider  = ( ( ((pages-1) / totalSkinMax) + (pages / totalSkinMax ) ) / 2) * totalSliderHeight

          sliderTrackPosition[#sliderTrackPosition + 1] = {position + 130, pages}
          sliderTrackDivider[#sliderTrackDivider + 1]   = {divider  + 130, pages}
     end

     if data == 'positions' then
          return sliderTrackPosition
     end
     if data == 'divider' then
          return sliderTrackDivider
     end
     return {sliderTrackPosition, sliderTrackDivider}
end

return states