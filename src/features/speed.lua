local helpers = require(script.Parent.Parent.utils.helpers)
local logger = require(script.Parent.Parent.core.logger)

local speedOn = false
local speedValue = 50

local function applySpeed(value)
    pcall(function()
        local humanoid = helpers.getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end)
end

local function toggle(state)
    speedOn = state
    if speedOn then
        applySpeed(speedValue)
        logger.info("Speed ON (" .. speedValue .. ")")
    else
        applySpeed(16)
        logger.info("Speed OFF")
    end
end

coroutine.wrap(function()
    while true do
        if speedOn then applySpeed(speedValue) end
        task.wait(0.5)
    end
end)()

return {
    toggle = toggle,
    isOn = function() return speedOn end
}