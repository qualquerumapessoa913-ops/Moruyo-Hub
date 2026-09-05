local helpers = require(script.Parent.Parent.utils.helpers)
local UserInputService = game:GetService("UserInputService")

local infiniteJumpOn = false

local function toggle(state)
    infiniteJumpOn = state
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and infiniteJumpOn then
        local humanoid = helpers.getHumanoid()
        if humanoid then
            humanoid.Jump = true
        end
    end
end)

return {
    toggle = toggle,
    isOn = function() return infiniteJumpOn end
}