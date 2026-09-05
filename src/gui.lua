local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Cria um botão com toggle
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

-- Cria a GUI principal
local function createGUI(gameModule)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MoruyoHub"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
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

    -- Arrastar a GUI pelo título
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

    -- ScrollingFrame para os botões
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

    -- Botões universais (sempre aparecem)
    if gameModule.speed then
        createButton(Scroll, "💨 Speed", gameModule.speed.toggle)
    end
    if gameModule.noclip then
        createButton(Scroll, "🚀 No Clip", gameModule.noclip.toggle)
    end
    if gameModule.infinitejump then
        createButton(Scroll, "🦘 Infinite Jump", gameModule.infinitejump.toggle)
    end
    if gameModule.fly then
        createButton(Scroll, "🕊️ Fly", gameModule.fly.toggle)
    end
    if gameModule.fullbright then
        createButton(Scroll, "☀️ Full Bright", gameModule.fullbright.toggle)
    end

    -- Botões específicos do jogo (se existirem)
    if gameModule.toggleAimbot then
        createButton(Scroll, "🎯 Aimbot", gameModule.toggleAimbot)
    end
    if gameModule.toggleSilentAim then
        createButton(Scroll, "🔇 Silent Aim", gameModule.toggleSilentAim)
    end
    if gameModule.toggleTrigger then
        createButton(Scroll, "🔫 Trigger", gameModule.toggleTrigger)
    end
    if gameModule.toggleESP then
        createButton(Scroll, "👁️ ESP", gameModule.toggleESP)
    end

    return MainFrame
end

return {
    createGUI = createGUI
}