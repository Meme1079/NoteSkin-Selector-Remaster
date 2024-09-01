local funkinlua = require 'mods.NoteSkin Selector Remastered.modules.funkinlua'
local states = {}

function states.calculatePosition(skinType)
     local xpos = {20, 220 - 30, (220 + 170) - 30, (220 + (170 * 2)) - 30}
     local ypos = -155 -- increments, in each 4th value

     local xindex = 0
     local result = {}
     for skinIndex = 1, #skinType do
          xindex = xindex + 1
          if xindex > 4 then
               xindex = 1
          end

          local skinIndexNeg = skinIndex - 1
          if skinIndexNeg % 4  == 0 then ypos = ypos + 180 end;
          if skinIndexNeg % 12 == 0 then ypos = ypos + 140 end;
          table.insert(result, {xpos[xindex], ypos});
     end
     return result
end

function states.calculatePageLimit(skinType)
     local yindex_limit = 0
     for skinIndex = 1, #skinType do
          local skinIndexNeg = skinIndex - 1
          if skinIndexNeg % 12 == 0 then
               yindex_limit = yindex_limit + 1
          end
     end
     return yindex_limit
end

function states.getLocalSkins(state)
     local results_note   = {'future', 'chip'}
     local results_splash = {'vanilla', 'sparkles', 'electric', 'diamond'}

     local results_states     = state == 'note' and 'NOTE_assets' or state == 'splash' and 'noteSplashes'
     local results_statesName = state == 'note' and results_note  or state == 'splash' and results_splash
     local results = {}
     for i = 0, #results_statesName do
          if i == 0 then 
               table.insert(results, results_states)
          else
               table.insert(results, results_states..'-'..results_statesName[i])
          end
     end
     return results
end

function states.getSkins(state)
     local results = states.getLocalSkins(state)
     local pattern = state == 'note' and 'NOTE_assets' or state == 'splash' and 'noteSplashes'
     local folder  = state == 'note' and 'noteSkins'   or state == 'splash' and 'noteSplashes'
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/'..folder) do
          if v:match('^('..pattern..'%-.+)%.png$') then
               table.insert(results, v:match('^('..pattern..'%-.+)%.png$'))
          end
     end
     return results
end

function states.getSkinNames(state)
     local results_note   = {'Funkin', 'Future', 'Chip'}
     local results_splash = {'Funkin', 'Vanilla', 'Sparkles', 'Electric', 'Diamond'}
     local results = state == 'note' and results_note or state == 'splash' and results_splash

     local pattern = state == 'note' and 'NOTE_assets' or state == 'splash' and 'noteSplashes'
     local folder  = state == 'note' and 'noteSkins'   or state == 'splash' and 'noteSplashes'
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/'..folder) do
          if v:match('^('..pattern..'%-.+)%.png$') then
               table.insert(results, v:match('^'..pattern..'%-(.+)%.png$'))
          end
     end
     return results
end

function states.getIndexSkins(state, stateSkins)
     local hitboxTag = state == 'note' and 'note' or state == 'splash' and 'splash'
     local result = 1
     for index = 1, #noteSkins_getNoteSkins do
          if funkinlua.clickObject('noteSkins_hitbox-'..k) then
               result = index
          end
     end
     return result
end

return states