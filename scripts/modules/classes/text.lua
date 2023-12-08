local text = {}

function text:new(tag, content, pos, width)
     local constructor = setmetatable({}, {__index = self})
     constructor.tag     = tag
     constructor.content = content
     constructor.width   = width
     constructor.pos     = pos

     makeLuaText(constructor.tag, constructor.content, constructor.width, constructor.pos[1], constructor.pos[2])
     return constructor
end

function text:set(property, value)
     if property == 'string'        then setTextString(self.tag, value)
     elseif property == 'size'      then setTextSize(self.tag, value)
     elseif property == 'width'     then setTextWidth(self.tag, value)
     elseif property == 'border'    then setTextBorder(self.tag, value[1], value[2])
     elseif property == 'color'     then setTextColor(self.tag, value)
     elseif property == 'alignment' then setTextAlignment(self.tag, value)
     elseif property == 'font'      then setTextFont(self.tag, value)
     elseif property == 'italic'    then setTextItalic(self.tag, value)
     end
     
     setProperty(self.tag..'.'..property, value)
end

function text:camera(cam)
     local cam = cam or 'camGame'
     setObjectCamera(self.tag, cam)
end

function text:order(order)
     setObjectOrder(self.tag, order)
end

function text:add()
     addLuaText(self.tag)
end

return text