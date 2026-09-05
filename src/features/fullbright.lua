local Lighting = game:GetService("Lighting")

local fullBrightOn = false

local function toggle(state)
    fullBrightOn = state
    if fullBrightOn then
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    end
end

return {
    toggle = toggle,
    isOn = function() return fullBrightOn end
}