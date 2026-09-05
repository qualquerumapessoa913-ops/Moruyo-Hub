local helpers = require(script.Parent.Parent.utils.helpers)
local logger = require(script.Parent.Parent.core.logger)
local RunService = game:GetService("RunService")

local noClipOn = false

local function toggle(state)
    noClipOn = state
    local hrp = helpers.getHRP()
    if hrp then
        hrp.CanCollide = not noClipOn
    end
    logger.info("No Clip: " .. (noClipOn and "ON" or "OFF"))
end

RunService.RenderStepped:Connect(function()
    if noClipOn then
        local hrp = helpers.getHRP()
        if hrp then
            hrp.CanCollide = false
        end
    end
end)

return {
    toggle = toggle,
    isOn = function() return noClipOn end
}