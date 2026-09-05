local helpers = require(script.Parent.Parent.utils.helpers)
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local flyOn = false
local flySpeed = 50
local flyVelocity = Vector3.new(0, 0, 0)

local function toggle(state)
    flyOn = state
    if not flyOn then
        local humanoid = helpers.getHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
        flyVelocity = Vector3.new(0, 0, 0)
    end
end

coroutine.wrap(function()
    while true do
        if flyOn then
            local hrp = helpers.getHRP()
            local humanoid = helpers.getHumanoid()
            if hrp and humanoid then
                humanoid.PlatformStand = true
                hrp.Velocity = flyVelocity
            end
        end
        task.wait()
    end
end)()

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not flyOn then return end
    local key = input.KeyCode.Name
    local speed = flySpeed
    if key == "W" then flyVelocity = Camera.CFrame.LookVector * speed
    elseif key == "S" then flyVelocity = -Camera.CFrame.LookVector * speed
    elseif key == "A" then flyVelocity = -Camera.CFrame.RightVector * speed
    elseif key == "D" then flyVelocity = Camera.CFrame.RightVector * speed
    elseif key == "Space" then flyVelocity = Vector3.new(0, speed, 0)
    elseif key == "LeftShift" then flyVelocity = Vector3.new(0, -speed, 0)
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if not flyOn then return end
    local key = input.KeyCode.Name
    if key == "W" or key == "S" or key == "A" or key == "D" or key == "Space" or key == "LeftShift" then
        flyVelocity = Vector3.new(0, 0, 0)
    end
end)

return {
    toggle = toggle,
    isOn = function() return flyOn end,
    setSpeed = function(speed) flySpeed = speed end
}