-- ============================================================
-- MORUYO HUB v10.2 – VERSÃO DE EMERGÊNCIA (FUNCIONAL)
-- ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- 1. FUNÇÕES AUXILIARES
-- ============================================================
local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

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

-- ============================================================
-- 2. VARIÁVEIS DE ESTADO
-- ============================================================
local speedOn = false
local noClipOn = false
local infiniteJumpOn = false
local flyOn = false
local aimbotOn = false
local espOn = false
local espHighlights = {}

-- ============================================================
-- 3. FUNÇÕES DAS FEATURES
-- ============================================================

-- SPEED
function toggleSpeed()
    speedOn = not speedOn
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = speedOn and 50 or 16
    end
    print("[Moruyo] Speed:", speedOn and "ON" or "OFF")
end

-- NO CLIP
function toggleNoClip()
    noClipOn = not noClipOn
    local hrp = getHRP()
    if hrp then
        hrp.CanCollide = not noClipOn
    end
    print("[Moruyo] No Clip:", noClipOn and "ON" or "OFF")
end

-- INFINITE JUMP
function toggleInfiniteJump()
    infiniteJumpOn = not infiniteJumpOn
    print("[Moruyo] Infinite Jump:", infiniteJumpOn and "ON" or "OFF")
end

-- FLY
local flyVelocity = Vector3.new(0,0,0)
function toggleFly()
    flyOn = not flyOn
    local hum = getHumanoid()
    if hum then
        hum.PlatformStand = flyOn
    end
    if not flyOn then
        flyVelocity = Vector3.new(0,0,0)
    end
    print("[Moruyo] Fly:", flyOn and "ON" or "OFF")
end

-- AIMBOT
function toggleAimbot()
    aimbotOn = not aimbotOn
    print("[Moruyo] Aimbot:", aimbotOn and "ON" or "OFF")
end

-- ESP
function addESP(player)
    if not player.Character then return end
    if espHighlights[player] then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    local color = Color3.fromRGB(255,0,0)
    if player.Team then
        if player.Team.Name == "Guards" or player.Team.Name == "Police" then
            color = Color3.fromRGB(0,150,255)
        elseif player.Team.Name == "Prisoners" or player.Team.Name == "Inmates" then
            color = Color3.fromRGB(255,50,50)
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(255,255,255)
    highlight.OutlineTransparency = 0.1
    highlight.Parent = player.Character
    espHighlights[player] = highlight
end

function removeESP(player)
    local highlight = espHighlights[player]
    if highlight then
        highlight:Destroy()
        espHighlights[player] = nil
    end
end

function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if espOn then
                addESP(player)
            else
                removeESP(player)
            end
        end
    end
end

function toggleESP()
    espOn = not espOn
    updateESP()
    print("[Moruyo] ESP:", espOn and "ON" or "OFF")
end

-- ============================================================
-- 4. LOOPS
-- ============================================================

-- Loop do Aimbot
coroutine.wrap(function()
    while true do
        if aimbotOn then
            local target = getClosestEnemy()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                end
            end
        end
        task.wait()
    end
end)()

-- Loop do No Clip (forçado)
coroutine.wrap(function()
    while true do
        if noClipOn then
            local hrp = getHRP()
            if hrp then
                hrp.CanCollide = false
            end
        end
        task.wait(0.1)
    end
end)()

-- Loop do Fly
coroutine.wrap(function()
    while true do
        if flyOn then
            local hrp = getHRP()
            local hum = getHumanoid()
            if hrp and hum then
                hrp.Velocity = flyVelocity
            end
        end
        task.wait()
    end
end)()

-- Loop do ESP (atualização a cada 0.5s)
coroutine.wrap(function()
    while true do
        if espOn then
            updateESP()
        end
        task.wait(0.5)
    end
end)()

-- ============================================================
-- 5. EVENTOS DO TECLADO
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and infiniteJumpOn then
        local hum = getHumanoid()
        if hum then
            hum.Jump = true
        end
    end
end)

-- Controles do Fly (WASD + Espaço + Shift)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not flyOn then return end
    local key = input.KeyCode.Name
    local speed = 50
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
        flyVelocity = Vector3.new(0,0,0)
    end
end)

-- ============================================================
-- 6. GUI (SIMPLES E FUNCIONAL)
-- ============================================================
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MoruyoHub"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.Position = UDim2.new(0,0,0,5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ MORUYO HUB v10.2"
    Title.TextColor3 = Color3.fromRGB(255,255,255)
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
    Scroll.Size = UDim2.new(1,-10,1,-50)
    Scroll.Position = UDim2.new(0,5,0,45)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.Parent = MainFrame
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ScrollBarThickness = 4

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.Padding = UDim.new(0,6)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Parent = Scroll

    -- Função para criar botão
    function createButton(parent, label, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.9,0,0,34)
        frame.BackgroundColor3 = Color3.fromRGB(30,40,55)
        frame.BackgroundTransparency = 0.2
        frame.Parent = parent
        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0,6)
        fCorner.Parent = frame

        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.55,0,1,0)
        labelText.Position = UDim2.new(0,8,0,0)
        labelText.BackgroundTransparency = 1
        labelText.Font = Enum.Font.Gotham
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(220,230,255)
        labelText.TextSize = 13
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25,0,0.7,0)
        btn.Position = UDim2.new(0.7,0,0.15,0)
        btn.BackgroundColor3 = Color3.fromRGB(60,70,90)
        btn.BackgroundTransparency = 0.1
        btn.Font = Enum.Font.GothamBold
        btn.Text = "OFF"
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextSize = 13
        btn.Parent = frame
        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0,6)
        bCorner.Parent = btn

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0,200,80) or Color3.fromRGB(60,70,90)
            btn.Text = state and "ON" or "OFF"
            callback()
        end)

        return frame
    end

    -- Botões
    createButton(Scroll, "💨 Speed", toggleSpeed)
    createButton(Scroll, "🚀 No Clip", toggleNoClip)
    createButton(Scroll, "🦘 Infinite Jump", toggleInfiniteJump)
    createButton(Scroll, "🕊️ Fly", toggleFly)
    createButton(Scroll, "🎯 Aimbot", toggleAimbot)
    createButton(Scroll, "👁️ ESP", toggleESP)

    return MainFrame
end

-- ============================================================
-- 7. INICIALIZAÇÃO
-- ============================================================
print("[Moruyo] Inicializando versão de emergência...")
createGUI()
print("[Moruyo] Hub carregado! Teste as funções.")