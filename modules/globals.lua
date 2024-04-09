local globals = {}

function globals.calculatePosition(skinType)
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

function globals.calculatePageLimit(skinType)
     local yindex_limit = 0
     for skinIndex = 1, #skinType do
          local skinIndexNeg = skinIndex - 1
          if skinIndexNeg % 12 == 0 then
               yindex_limit = yindex_limit + 1
          end
     end
     return yindex_limit
end

function globals.getLocalSkins(state)
     local results_note   = {'future', 'chip'}
     local results_splash = {'vanilla', 'sparkles', 'electric', 'diamond'}

     local results_states     = state == 'note' and 'NOTE_assets' or 'noteSplashes'
     local results_statesName = state == 'note' and results_note or results_splash
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

function globals.getSkins(state)
     local results = globals.getLocalSkins(state)
     local pattern = state == 'note' and 'NOTE_assets' or 'noteSplashes'
     local folder  = state == 'note' and 'noteSkins' or 'noteSplashes'
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/'..folder) do
          if v:match('^('..pattern..'%-.+)%.png$') then
               table.insert(results, v:match('^('..pattern..'%-.+)%.png$'))
          end
     end
     return results
end

function globals.getIndexSkins(state, stateSkins)
     local hitboxTag = state == 'note'
     local result = 1
     for index = 1, #noteSkins_getNoteSkins do
          if funkinlua.clickObject('noteSkins_hitbox-'..k) then
               result = index
          end
     end
     return result
end

function globals.getSkinNames(state)
     local results_note   = {'Normal', 'Future', 'Chip'}
     local results_splash = {'Normal', 'Vanilla', 'Sparkles', 'Electric', 'Diamond'}
     local results = state == 'note' and results_note or results_splash

     local pattern = state == 'note' and 'NOTE_assets' or 'noteSplashes'
     local folder  = state == 'note' and 'noteSkins' or 'noteSplashes'
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/'..folder) do
          if v:match('^('..pattern..'%-.+)%.png$') then
               table.insert(results, v:match('^'..pattern..'%-(.+)%.png$'))
          end
     end
     return results
end

return globals