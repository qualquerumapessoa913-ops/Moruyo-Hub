local VirtualInput = game:GetService("VirtualInputManager")

-- Clique confiável (usando VirtualInputManager)
local function clickMouse()
    pcall(function()
        VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Pega o personagem do jogador
local function getCharacter()
    return game.Players.LocalPlayer.Character
end

-- Pega o Humanoid
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

-- Pega o HumanoidRootPart
local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

return {
    clickMouse = clickMouse,
    getCharacter = getCharacter,
    getHumanoid = getHumanoid,
    getHRP = getHRP
}