local string = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.string' 

local Cursor = {}
function Cursor:new(size, xOffset, yOffset)
     local self = setmetatable({}, {__index = self})
     self.size    = size    or 1
     self.xOffset = xOffset or 0
     self.yOffset = yOffset or 0

     return self
end

function Cursor:load(image)
     local codeContents = 'FlxG.mouse.load(new FlxSprite().loadGraphic(Paths.image(\"ui/cursors/cursor-${image}\")).pixels, ${size}, ${xOffset}, ${yOffset});'
     local codeElements = {image = image, size = self.size, xOffset = self.xOffset, yOffset = self.yOffset}
     setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
     runHaxeCode(codeContents:interpol(codeElements))
end

function Cursor:reload(image)
     self.size    = size    or 1
     self.xOffset = xOffset or 0
     self.yOffset = yOffset or 0

     self:load(image)
end

function Cursor:unload(visibility)
     setPropertyFromClass('flixel.FlxG', 'mouse.visible', visibility)
     runHaxeCode('FlxG.mouse.unload();')
end

function Cursor:visible(visibility)
     setPropertyFromClass('flixel.FlxG', 'mouse.visible', visibility)
end

return Cursor