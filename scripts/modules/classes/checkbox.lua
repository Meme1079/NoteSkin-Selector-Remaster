local checkbox = {}

-- 785, 350
-- buttonBoxType1
function checkbox:new(tag, pos)
     local constructor = setmetatable({}, {__index = self})
     makeAnimatedLuaSprite(self.tag, 'checkboxanim', pos[1], pos[2])
     setGraphicSize(self.tag, 80, 80)
     addAnimationByPrefix(self.tag, 'unchecked', 'checkbox0', 24, false)
     addAnimationByPrefix(self.tag, 'unchecking', 'checkbox anim reverse', 24, false)
     addAnimationByPrefix(self.tag, 'checking', 'checkbox anim0', 24, false)
     addAnimationByPrefix(self.tag, 'checked', 'checkbox finish', 24, false)
     addOffset(self.tag, 'unchecked', 0, 0)
     addOffset(self.tag, 'unchecking', 20, 21.5)
     addOffset(self.tag, 'checking', 27.4, 18.5)
     playAnim(self.tag, 'unchecked')
     setObjectCamera(self.tag, 'camOther')
     addLuaSprite(self.tag, true)

     return constructor
end

function checkbox:()
     -- code
end

return checkbox

--[[

makeAnimatedLuaSprite('buttonBoxType1', 'checkboxanim', 785, 350)
setGraphicSize('buttonBoxType1', 80, 80)
addAnimationByPrefix('buttonBoxType1', 'unchecked', 'checkbox0', 24, false)
addAnimationByPrefix('buttonBoxType1', 'unchecking', 'checkbox anim reverse', 24, false)
addAnimationByPrefix('buttonBoxType1', 'checking', 'checkbox anim0', 24, false)
addAnimationByPrefix('buttonBoxType1', 'checked', 'checkbox finish', 24, false)
addOffset('buttonBoxType1', 'unchecked', 0, 0)
addOffset('buttonBoxType1', 'unchecking', 20, 21.5)
addOffset('buttonBoxType1', 'checking', 27.4, 18.5)
playAnim('buttonBoxType1', 'unchecked')
setObjectCamera('buttonBoxType1', 'camOther')
addLuaSprite('buttonBoxType1', true)
]]