-- ============================================================
-- MORUYO HUB v10.0 – UPGRADE 1000%
-- Estilo Hawk Hub | Prison Life Edition
-- ============================================================

-- ============================================================
-- 1. SERVIÇOS E VARIÁVEIS GLOBAIS
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualInput = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Personagem e referências (atualizadas automaticamente)
local Character, Humanoid, hrp

local function updateCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:FindFirstChild("Humanoid")
    hrp = Character:FindFirstChild("HumanoidRootPart")
end
updateCharacter()
LocalPlayer.CharacterAdded:Connect(updateCharacter)

-- ============================================================
-- 2. FUNÇÕES AUXILIARES (SEGURAS)
-- ============================================================
local function safeFindChild(parent, name)
    if not parent then return nil end
    return parent:FindFirstChild(name)
end

local function getClosestEnemy()
    if not hrp then return nil end
    local myTeam = LocalPlayer.Team
    if not myTeam then return nil end
    local closest = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team and player.Team ~= myTeam then
            local head = safeFindChild(player.Character, "Head")
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

local function clickMouse()
    pcall(function()
        VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    pcall(function()
        mouse1click()
    end)
end

local function log(msg)
    print("[MoruyoHub] " .. msg)
end

-- ============================================================
-- 3. SPEED (COM SLIDER VISUAL NA GUI)
-- ============================================================
local speedOn = false
local speedValue = 50

local function applySpeed(value)
    pcall(function()
        if Humanoid then Humanoid.WalkSpeed = value end
    end)
end

local function toggleSpeed(state)
    speedOn = state
    if speedOn then applySpeed(speedValue) else applySpeed(16) end
    log("Speed " .. (speedOn and "ON (" .. speedValue .. ")" or "OFF"))
end

local function setSpeed(value)
    speedValue = value
    if speedOn then applySpeed(speedValue) end
end

-- Loop de manutenção
coroutine.wrap(function()
    while true do
        if speedOn then applySpeed(speedValue) end
        task.wait(0.5)
    end
end)()

-- ============================================================
-- 4. NO CLIP (FORÇA BRUTA)
-- ============================================================
local noClipOn = false

local function toggleNoClip(state)
    noClipOn = state
    if hrp then hrp.CanCollide = not noClipOn end
    log("No Clip " .. (noClipOn and "ON" or "OFF"))
end

RunService.RenderStepped:Connect(function()
    if noClipOn and hrp then
        hrp.CanCollide = false
    end
end)

-- ============================================================
-- 5. INFINITE JUMP
-- ============================================================
local infiniteJumpOn = false

local function toggleInfiniteJump(state)
    infiniteJumpOn = state
    log("Infinite Jump " .. (infiniteJumpOn and "ON" or "OFF"))
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and infiniteJumpOn and Humanoid then
        Humanoid.Jump = true
    end
end)

-- ============================================================
-- 6. FLY (CONTROLE SUAVE)
-- ============================================================
local flyOn = false
local flySpeed = 50
local flyVelocity = Vector3.new(0, 0, 0)

local function toggleFly(state)
    flyOn = state
    if not flyOn and Humanoid then
        Humanoid.PlatformStand = false
        flyVelocity = Vector3.new(0, 0, 0)
    end
    log("Fly " .. (flyOn and "ON" or "OFF"))
end

local function setFlySpeed(value)
    flySpeed = value
end

coroutine.wrap(function()
    while true do
        if flyOn and hrp and Humanoid then
            Humanoid.PlatformStand = true
            hrp.Velocity = flyVelocity
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

-- ============================================================
-- 7. FULL BRIGHT
-- ============================================================
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
    log("Full Bright " .. (fullBrightOn and "ON" or "OFF"))
end

-- ============================================================
-- 8. AIMBOT (COM SMOOTH E MODOS)
-- ============================================================
local aimbotOn = false
local aimbotMode = "Always" -- "Always" ou "MouseButton"
local rightMousePressed = false

local function smoothAimbot(targetPos)
    if not targetPos then return end
    local currentPos = Camera.CFrame.Position
    local goal = CFrame.new(currentPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(goal, 0.15)
end

local function toggleAimbot(state)
    aimbotOn = state
    log("Aimbot " .. (aimbotOn and "ON (" .. aimbotMode .. ")" or "OFF"))
end

local function setAimbotMode(mode)
    aimbotMode = mode
    log("Aimbot Mode: " .. aimbotMode)
end

coroutine.wrap(function()
    while true do
        if aimbotOn then
            local shouldAim = (aimbotMode == "Always") or (aimbotMode == "MouseButton" and rightMousePressed)
            if shouldAim then
                local target = getClosestEnemy()
                if target and target.Character then
                    local head = safeFindChild(target.Character, "Head")
                    if head then
                        smoothAimbot(head.Position)
                    end
                end
            end
        end
        task.wait()
    end
end)()

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
-- 9. SILENT AIM
-- ============================================================
local silentAimOn = false

local function doSilentAim()
    local target = getClosestEnemy()
    if target and target.Character then
        local head = safeFindChild(target.Character, "Head")
        if head then
            clickMouse()
        end
    end
end

local function toggleSilentAim(state)
    silentAimOn = state
    log("Silent Aim " .. (silentAimOn and "ON" or "OFF"))
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and silentAimOn then
        doSilentAim()
    end
end)

-- ============================================================
-- 10. TRIGGER (TELEGUIADO)
-- ============================================================
local triggerOn = false

local function triggerShoot()
    local target = getClosestEnemy()
    if target and target.Character then
        local head = safeFindChild(target.Character, "Head")
        if head then
            clickMouse()
        end
    end
end

local function toggleTrigger(state)
    triggerOn = state
    log("Trigger " .. (triggerOn and "ON" or "OFF"))
end

coroutine.wrap(function()
    while true do
        if triggerOn then
            triggerShoot()
        end
        task.wait(0.2)
    end
end)()

-- ============================================================
-- 11. ESP (COM HIGHLIGHT E BILLBOARD)
-- ============================================================
local espOn = false
local espHighlights = {}
local lastESPUpdate = 0

local function addESP(player)
    if not player.Character then return end
    if espHighlights[player] then return end
    local head = safeFindChild(player.Character, "Head")
    if not head then return end
    if not hrp then return end
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
    billboard.Size = UDim2.new(0, 200, 0, 40)
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
    log("ESP " .. (espOn and "ON" or "OFF"))
end

RunService.Heartbeat:Connect(function(deltaTime)
    lastESPUpdate = lastESPUpdate + deltaTime
    if lastESPUpdate >= 1 then
        lastESPUpdate = 0
        if espOn then updateESP() end
    end
end)

-- Detectar novos jogadores
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
-- 12. GUI ESTILO HAWK HUB (COM SEÇÕES E ELEMENTOS)
-- ============================================================
local function createSection(parent, title, yPos, height)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, height or 80)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.2
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    return frame
end

local function createSwitch(parent, label, toggleFunc, xPos, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.45, 0, 0, 32)
    frame.Position = UDim2.new(xPos or 0.05, 0, yPos or 0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.Position = UDim2.new(0.1, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.TextSize = 13
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 0.6, 0)
    btn.Position = UDim2.new(0.7, 0, 0.2, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.BackgroundTransparency = 0.2
    btn.Font = Enum.Font.GothamBold
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(60, 60, 70)
        btn.Text = state and "ON" or "OFF"
        toggleFunc(state)
    end)

    return {frame = frame, btn = btn}
end

local function createModeSelector(parent, label, options, current, callback, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 30)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.2
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.Position = UDim2.new(0, 10, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.Gotham
    labelText.Text = label .. ": " .. current
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 0.7, 0)
    btn.Position = UDim2.new(0.7, 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    btn.BackgroundTransparency = 0.1
    btn.Font = Enum.Font.Gotham
    btn.Text = current
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Parent = frame
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local idx = 1
    for i, opt in ipairs(options) do
        if opt == current then idx = i end
    end

    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        local newMode = options[idx]
        btn.Text = newMode
        labelText.Text = label .. ": " .. newMode
        callback(newMode)
    end)

    return frame
end

local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MoruyoHub"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 360, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    -- Título (estilo Hawk)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Position = UDim2.new(0, 0, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ MORUYO HUB | PRISON LIFE"
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
    Scroll.Size = UDim2.new(1, -10, 1, -55)
    Scroll.Position = UDim2.new(0, 5, 0, 50)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.Parent = MainFrame
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ScrollBarThickness = 4

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.Padding = UDim.new(0, 8)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Parent = Scroll

    -- ============================================================
    -- SEÇÃO COMBATE
    -- ============================================================
    local combatSection = createSection(Scroll, "⚔️ COMBATE", 0, 130)
    createSwitch(combatSection, "Aimbot", toggleAimbot, 0.05, 0.25)
    createModeSelector(combatSection, "Modo Aimbot", {"Always", "MouseButton"}, aimbotMode, setAimbotMode, 0.65)
    createSwitch(combatSection, "Silent Aim", toggleSilentAim, 0.05, 0.85)
    createSwitch(combatSection, "Trigger", toggleTrigger, 0.55, 0.85)

    -- ============================================================
    -- SEÇÃO VISUAIS
    -- ============================================================
    local visSection = createSection(Scroll, "👁️ VISUAIS", 0, 80)
    createSwitch(visSection, "ESP", toggleESP, 0.05, 0.25)
    createSwitch(visSection, "Full Bright", toggleFullBright, 0.55, 0.25)

    -- ============================================================
    -- SEÇÃO MOVIMENTO
    -- ============================================================
    local moveSection = createSection(Scroll, "🏃 MOVIMENTO", 0, 160)
    createSwitch(moveSection, "Speed", toggleSpeed, 0.05, 0.2)
    createSwitch(moveSection, "No Clip", toggleNoClip, 0.55, 0.2)
    createSwitch(moveSection, "Infinite Jump", toggleInfiniteJump, 0.05, 0.6)
    createSwitch(moveSection, "Fly", toggleFly, 0.55, 0.6)

    -- ============================================================
    -- SEÇÃO CRÉDITOS
    -- ============================================================
    local credSection = createSection(Scroll, "📋 CRÉDITOS", 0, 50)
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Size = UDim2.new(1, 0, 0, 30)
    creditLabel.Position = UDim2.new(0, 10, 0, 10)
    creditLabel.BackgroundTransparency = 1
    creditLabel.Font = Enum.Font.Gotham
    creditLabel.Text = "Moruyo Hub v10.0 | Desenvolvido para Hawk Hub"
    creditLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    creditLabel.TextSize = 12
    creditLabel.TextXAlignment = Enum.TextXAlignment.Left
    creditLabel.Parent = credSection

    return MainFrame
end

-- ============================================================
-- 13. INICIALIZAÇÃO
-- ============================================================
log("Inicializando Moruyo Hub v10.0...")
createGUI()
log("GUI carregada com sucesso!")
log("Pressione F9 para abrir/fechar o console de logs.")
log("Use as teclas de atalho nos botões ou clique neles para ativar/desativar.")