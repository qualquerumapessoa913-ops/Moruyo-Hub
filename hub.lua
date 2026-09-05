-- ============================================================
-- MORUYO HUB v9.0 – SCRIPT ÚNICO (PARA EXECUTOR)
-- ============================================================

-- ============================================================
-- 1. HELPERS
-- ============================================================
local VirtualInput = game:GetService("VirtualInputManager")

local function clickMouse()
    pcall(function()
        VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

local function getCharacter()
    return game.Players.LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- 2. LOGGER
-- ============================================================
local function info(msg)
    print("[MoruyoHub] " .. msg)
end

local function warn(msg)
    warn("[MoruyoHub] " .. msg)
end

-- ============================================================
-- 3. GAME DETECTOR
-- ============================================================
local Games = {
    [840821278] = "PrisonLife",
}

local function getCurrentGame()
    return Games[game.PlaceId] or "Unknown"
end

local function isSupported()
    return Games[game.PlaceId] ~= nil
end

-- ============================================================
-- 4. FEATURES UNIVERSAIS
-- ============================================================

-- SPEED
local speedOn = false
local speedValue = 50

local function applySpeed(value)
    pcall(function()
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end)
end

local function toggleSpeed(state)
    speedOn = state
    if speedOn then
        applySpeed(speedValue)
        info("Speed ON (" .. speedValue .. ")")
    else
        applySpeed(16)
        info("Speed OFF")
    end
end

coroutine.wrap(function()
    while true do
        if speedOn then applySpeed(speedValue) end
        task.wait(0.5)
    end
end)()

-- NOCLIP
local noClipOn = false
local RunService = game:GetService("RunService")

local function toggleNoClip(state)
    noClipOn = state
    local hrp = getHRP()
    if hrp then
        hrp.CanCollide = not noClipOn
    end
    info("No Clip: " .. (noClipOn and "ON" or "OFF"))
end

RunService.RenderStepped:Connect(function()
    if noClipOn then
        local hrp = getHRP()
        if hrp then
            hrp.CanCollide = false
        end
    end
end)

-- INFINITE JUMP
local infiniteJumpOn = false
local UserInputService = game:GetService("UserInputService")

local function toggleInfiniteJump(state)
    infiniteJumpOn = state
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and infiniteJumpOn then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.Jump = true
        end
    end
end)

-- FLY
local flyOn = false
local flySpeed = 50
local flyVelocity = Vector3.new(0, 0, 0)
local Camera = workspace.CurrentCamera

local function toggleFly(state)
    flyOn = state
    if not flyOn then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
        flyVelocity = Vector3.new(0, 0, 0)
    end
end

coroutine.wrap(function()
    while true do
        if flyOn then
            local hrp = getHRP()
            local humanoid = getHumanoid()
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

-- FULL BRIGHT
local Lighting = game:GetService("Lighting")
local fullBrightOn = false

local function toggleFullBright(state)
    fullBrightOn = state
    if fullBrightOn then
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    end
end

-- ============================================================
-- 5. PRISON LIFE MODULE
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local aimbotOn = false
local aimbotMode = "Always"
local silentAimOn = false
local triggerOn = false
local espOn = false
local rightMousePressed = false
local espHighlights = {}
local lastESPUpdate = 0

local function getClosestEnemy()
    local hrp = getHRP()
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

local function smoothAimbot(targetPos)
    local currentPos = Camera.CFrame.Position
    local goal = CFrame.new(currentPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(goal, 0.12)
end

local function toggleAimbot(state)
    aimbotOn = state
    info("Aimbot: " .. (aimbotOn and "ON" or "OFF"))
end

local function setAimbotMode(mode)
    aimbotMode = mode
    info("Modo Aimbot: " .. aimbotMode)
end

local function doSilentAim()
    local target = getClosestEnemy()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            clickMouse()
        end
    end
end

local function toggleSilentAim(state)
    silentAimOn = state
    info("Silent Aim: " .. (silentAimOn and "ON" or "OFF"))
end

local function triggerShoot()
    local target = getClosestEnemy()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                clickMouse()
            else
                local currentCF = Camera.CFrame
                Camera.CFrame = CFrame.new(currentCF.Position, head.Position)
                task.wait(0.05)
                clickMouse()
                Camera.CFrame = currentCF
            end
        end
    end
end

local function toggleTrigger(state)
    triggerOn = state
    info("Trigger: " .. (triggerOn and "ON" or "OFF"))
end

local function addESP(player)
    if not player.Character or espHighlights[player] then return end
    local hrp = getHRP()
    if not hrp then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    if (head.Position - hrp.Position).Magnitude > 150 then return end

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
    info("ESP: " .. (espOn and "ON" or "OFF"))
end

RunService.Heartbeat:Connect(function(deltaTime)
    lastESPUpdate = lastESPUpdate + deltaTime
    if lastESPUpdate >= 1 then
        lastESPUpdate = 0
        if espOn then updateESP() end
    end
end)

local function setupPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        if espOn then addESP(player) end
    end)
    if player.Character and espOn then addESP(player) end
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

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

coroutine.wrap(function()
    while true do
        if triggerOn then
            triggerShoot()
        end
        task.wait(0.2)
    end
end)()

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and silentAimOn then
        doSilentAim()
    end
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
-- 6. GUI (INTERFACE)
-- ============================================================
local function createButton(parent, label, toggleFunc)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
    frame.BackgroundTransparency = 0.2
    frame.Parent = parent
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 6)
    fCorner.Parent = frame

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.Position = UDim2.new(0, 8, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(220, 230, 255)
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 0.7, 0)
    btn.Position = UDim2.new(0.7, 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    btn.BackgroundTransparency = 0.1
    btn.Font = Enum.Font.GothamBold
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Parent = frame
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(60, 70, 90)
        btn.Text = state and "ON" or "OFF"
        toggleFunc(state)
    end)

    return frame
end

local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MoruyoHub"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ MORUYO HUB v9.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = MainFrame

    -- Arrastar
    local dragging = false
    local dragStart = nil
    local framePos = nil
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            framePos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -10, 1, -50)
    Scroll.Position = UDim2.new(0, 5, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.Parent = MainFrame
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ScrollBarThickness = 4

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.Padding = UDim.new(0, 4)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Parent = Scroll

    -- Botões universais
    createButton(Scroll, "💨 Speed", toggleSpeed)
    createButton(Scroll, "🚀 No Clip", toggleNoClip)
    createButton(Scroll, "🦘 Infinite Jump", toggleInfiniteJump)
    createButton(Scroll, "🕊️ Fly", toggleFly)
    createButton(Scroll, "☀️ Full Bright", toggleFullBright)

    -- Botões do Prison Life
    createButton(Scroll, "🎯 Aimbot", toggleAimbot)
    createButton(Scroll, "🔇 Silent Aim", toggleSilentAim)
    createButton(Scroll, "🔫 Trigger", toggleTrigger)
    createButton(Scroll, "👁️ ESP", toggleESP)

    return MainFrame
end

-- ============================================================
-- 7. INICIALIZAÇÃO
-- ============================================================
if not isSupported() then
    warn("Jogo não suportado: " .. getCurrentGame())
    return
end

info("Carregando Moruyo Hub para: " .. getCurrentGame())
createGUI()
info("Moruyo Hub carregado com sucesso!")