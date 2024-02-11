local table  = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/table')
local string = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/string')
local json   = require('mods/NoteSkin Selector Remastered/scripts/modules/libraries/json')

local function getTextFileContent(path)
     local file = io.open(path)
     local content = ''
     for line in file:lines() do  
          content = content .. line .. '\n'
     end
     return content
end

local function calculatePosition(skinType)
     local xpos = {20, 220 - 30, (220 + 170) - 30, (220 + (170 * 2)) - 30}
     local ypos = -155 -- increment in each 4th value

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

local function calculatePageLimit(skinType)
     local yindex_limit = 0
     for skinIndex = 1, #skinType do
          local skinIndexNeg = skinIndex - 1
          if skinIndexNeg % 12 == 0 then
               yindex_limit = yindex_limit + 1
          end
     end
     return yindex_limit
end

local function clickObject(obj)
     return objectsOverlap(obj, 'mouse_hitbox') and mouseClicked('left')
end

local function getSplashSkins()
     local results = {'noteSplashes', 'noteSplashes-vanilla', 'noteSplashes-sparkles', 'noteSplashes-electric', 'noteSplashes-diamond'}
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/noteSplashes') do
          if v:match('^(noteSplashes%-.+)%.png$') then
               table.insert(results, v:match('^(noteSplashes%-.+)%.png$'))
          end
     end
     return results
end

local function getSplashSkinNames()
     local results = {'Normal', 'Vanilla', 'Sparkles', 'Electric', 'Diamond'}
     for _,v in next, directoryFileList('mods/NoteSkin Selector Remastered/images/noteSplashes') do
          if v:match('^noteSplashes%-(.+)%.png$') then
               table.insert(results, v:match('^noteSplashes%-(.+)%.png$'))
          end
     end
     return results
end

local function altValue(main, alt)
     return main ~= nil and main or alt
end

local splashPropertiesPath = 'mods/NoteSkin Selector Remastered/jsons/splash/property_menuSplashes.json'
local splashPropertiesJSON = getTextFileContent(splashPropertiesPath)
local splashProperties = json.decode(splashPropertiesJSON)
local function loadSplashProperties(json, alt, index)
     local getDictElements = function(dict, ele) return dict[ele] end
     local getSplashNames = getSplashSkinNames()[index]:lower()
     local getSplashElemValues = getDictElements(json, getSplashNames)
     return altValue(getSplashElemValues, alt)
end

local function createSplashSkins()
     for index, value in next, getSplashSkins() do
          local splashSkin_getCurPos = calculatePosition(getSplashSkins())[index]
          local splashSkin_hitboxTag = 'splashSkins_hitbox-'..tostring(index)
          makeLuaSprite(splashSkin_hitboxTag, nil, splashSkin_getCurPos[1], splashSkin_getCurPos[2])
          makeGraphic(splashSkin_hitboxTag, 130, 130, '000000')
          setObjectCamera(splashSkin_hitboxTag, 'camOther')
          setProperty(splashSkin_hitboxTag..'.visible', false)
          addLuaSprite(splashSkin_hitboxTag)

          local splash_prefixes = loadSplashProperties(splashProperties.prefixes, 'note splash', index)
          local splash_size     = loadSplashProperties(splashProperties.size, 110, index)

          local splashSkin_displayTag = 'splashSkins_display-'..tostring(index)
          local splashSkin_displayImage = 'noteSplashes/'..value
          makeAnimatedLuaSprite(splashSkin_displayTag, splashSkin_displayImage, splashSkin_getCurPos[1] + 10, splashSkin_getCurPos[2] + 5)
          addAnimationByPrefix(splashSkin_displayTag, 'display', splash_prefixes .. ' green 1', 12, true)
          addAnimationByPrefix(splashSkin_displayTag, 'displayAlt', splash_prefixes .. ' green 2', 12, true)
          setObjectCamera(splashSkin_displayTag, 'camOther')
          setGraphicSize(splashSkin_displayTag, splash_size, splash_size)
          playAnim(splashSkin_displayTag, 'display')
          precacheImage(splashSkin_displayImage)
          addLuaSprite(splashSkin_displayTag)
     end
end

function onCreatePost()
     createSplashSkins()
end

local disable_selection_flash = getModSetting('disable_selection_flash', 'NoteSkin Selector Remastered')
local skinHitboxAnimation = disable_selection_flash == false and 'selecting' or 'selecting-static'

local splashSkins_selectOffset = 7
local function selectionSplashSkins()
     for k = 1, #getSplashSkins() do
          local splashSkins_getPos = calculatePosition(getSplashSkins())[k]
          local splashSkins_tagGetY = 'splashSkins_hitbox-'..tostring(k)..'.y'
          local splashSkins_tagDisplayGetY = 'splashSkins_display-'..tostring(k)..'.y'

          if clickObject('splashSkins_hitbox-'..tostring(k)) then
               playSound('select', 1)
               playAnim('skinHitbox-highlight', skinHitboxAnimation, true)
               setTextString('skin_name', getSplashSkinNames()[k])

               local splashSkinHitbox_highlightX = splashSkins_getPos[1] - 8 + 0.8
               local splashSkinHitbox_highlightY = getProperty(splashSkins_tagGetY) - splashSkins_selectOffset
               setProperty('skinHitbox-highlight.x', splashSkinHitbox_highlightX)
               setProperty('skinHitbox-highlight.y', splashSkinHitbox_highlightY)
               
               splashSkins_selectedPos = k
          end
     end
end

function onUpdatePost(elapsed)
     if getProperty('skinStates') == 'splash' then
          selectionSplashSkins()
     end
end