local sprite = {}

function sprite:new(tag, path, pos)
     local constructor = setmetatable({}, {__index = self})
     constructor.tag  = tag
     constructor.path = path
     constructor.pos  = pos

     makeLuaSprite(constructor.tag, constructor.path, constructor.pos[1], constructor.pos[2])
     return constructor
end

function sprite:graphic(size, color)
     local front = front or false
     makeGraphic(self.tag, size[1], size[2], color)
end

function sprite:camera(cam)
     local cam = cam or 'camGame'
     setObjectCamera(self.tag, cam)
end

function sprite:order(order)
     setObjectOrder(self.tag, order)
end

function sprite:set(property, value)
     setProperty(self.tag..'.'..property, value)
end

function sprite:add(front)
     local front = front or false
     addLuaSprite(self.tag, front)
end

return sprite