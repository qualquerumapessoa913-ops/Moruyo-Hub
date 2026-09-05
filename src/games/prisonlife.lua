-- ============================================================
-- GAMES/PRISONLIFE.LUA – MÓDULO COMPLETO
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local helpers = require(script.Parent.Parent.utils.helpers)
local logger = require(script.Parent.Parent.core.logger)

-- ============================================================
-- ESTADOS
-- ============================================================
local aimbotOn = false
local aimbotMode = "Always"
local silentAimOn = false
local triggerOn = false
local espOn = false
local rightMousePressed = false
local espHighlights = {}

-- ============================================================
-- DETECTAR INIMIGO MAIS PRÓXIMO (POR TIME)
-- ============================================================
local function getClosestEnemy()
    local hrp = helpers.getHRP()
    if not hrp then return nil end
    local myTeam = LocalPlayer.Team
    if not myTeam then return nil end
    local closest = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team and player.Team ~= myTeam then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local dist = (head.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- ============================================================
-- AIMBOT (COM SMOOTH)
-- ============================================================
local function smoothAimbot(targetPos)
    local currentPos = Camera.CFrame.Position
    local goal = CFrame.new(currentPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(goal, 0.12)
end

local function toggleAimbot(state)
    aimbotOn = state
    logger.info("Aimbot: " .. (aimbotOn and "ON" or "OFF"))
end

local function setAimbotMode(mode)
    aimbotMode = mode
    logger.info("Modo Aimbot: " .. aimbotMode)
end

-- ============================================================
-- SILENT AIM
-- ============================================================
local function doSilentAim()
    local target = getClosestEnemy()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            helpers.clickMouse()
        end
    end
end

local function toggleSilentAim(state)
    silentAimOn = state
    logger.info("Silent Aim: " .. (silentAimOn and "ON" or "OFF"))
end

-- ============================================================
-- TRIGGERBOT (TELEGUIADO)
-- ============================================================
local function triggerShoot()
    local target = getClosestEnemy()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                helpers.clickMouse()
            else
                local currentCF = Camera.CFrame
                Camera.CFrame = CFrame.new(currentCF.Position, head.Position)
                task.wait(0.05)
                helpers.clickMouse()
                Camera.CFrame = currentCF
            end
        end
    end
end

local function toggleTrigger(state)
    triggerOn = state
    logger.info("Trigger: " .. (triggerOn and "ON" or "OFF"))
end

-- ============================================================
-- ESP
-- ============================================================
local function addESP(player)
    if not player.Character or espHighlights[player] then return end
    local hrp = helpers.getHRP()
    if not hrp then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    local dist = (head.Position - hrp.Position).Magnitude
    if dist > 150 then return end

    local color = Color3.fromRGB(255, 255, 0)
    if player.Team then
        if player.Team.Name == "Guards" or player.Team.Name == "Police" then
            color = Color3.fromRGB(0, 150, 255)
        elseif player.Team.Name == "Prisoners" or player.Team.Name == "Inmates" then
            color = Color3.fromRGB(255, 50, 50)
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.1
    highlight.Parent = player.Character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.fromScale(1, 1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = player.Name .. "\n(" .. (player.Team and player.Team.Name or "Sem time") .. ")"
    nameLabel.TextColor3 = color
    nameLabel.TextSize = 14
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Parent = billboard

    espHighlights[player] = {highlight = highlight, billboard = billboard}
end

local function removeESP(player)
    local data = espHighlights[player]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        espHighlights[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if espOn then addESP(player) else removeESP(player) end
        end
    end
end

local function toggleESP(state)
    espOn = state
    updateESP()
    logger.info("ESP: " .. (espOn and "ON" or "OFF"))
end

-- Atualização automática do ESP a cada 1s
local lastESPUpdate = 0
RunService.Heartbeat:Connect(function(deltaTime)
    lastESPUpdate = lastESPUpdate + deltaTime
    if lastESPUpdate >= 1 then
        lastESPUpdate = 0
        if espOn then updateESP() end
    end
end)

-- Detecta novos jogadores
local function setupPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        if espOn then addESP(player) end
    end)
    if player.Character and espOn then addESP(player) end
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

-- ============================================================
-- LOOPS PRINCIPAIS
-- ============================================================

-- Aimbot (smooth)
coroutine.wrap(function()
    while true do
        if aimbotOn then
            local shouldAim = (aimbotMode == "Always") or (aimbotMode == "MouseButton" and rightMousePressed)
            if shouldAim then
                local target = getClosestEnemy()
                if target and target.Character then
                    local head = target.Character:FindFirstChild("Head")
                    if head then
                        smoothAimbot(head.Position)
                    end
                end
            end
        end
        task.wait()
    end
end)()

-- TriggerBot (teleguiado)
coroutine.wrap(function()
    while true do
        if triggerOn then
            triggerShoot()
        end
        task.wait(0.2)
    end
end)()

-- Silent Aim (dispara com clique esquerdo)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and silentAimOn then
        doSilentAim()
    end
end)

-- Botão direito (para modo MouseButton)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMousePressed = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMousePressed = false
    end
end)

-- ============================================================
-- EXPORTAÇÃO
-- ============================================================
return {
    toggleAimbot = toggleAimbot,
    toggleSilentAim = toggleSilentAim,
    toggleTrigger = toggleTrigger,
    toggleESP = toggleESP,
    setAimbotMode = setAimbotMode,
    getClosestEnemy = getClosestEnemy,
    name = "Prison Life"
}