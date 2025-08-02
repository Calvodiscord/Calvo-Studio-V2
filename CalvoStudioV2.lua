--[[
    Script: Calvo Mod (V7 - Corrigido e Otimizado)
    
]]

--==================================================================================--
--||                                   SERVIÇOS E JOGADOR                           ||--
--==================================================================================--

pcall(function()
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local localPlayer = Players.LocalPlayer
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local camera = workspace.CurrentCamera

    --==================================================================================--
    --||                           CONFIGURAÇÕES E ESTADO                               ||--
    --==================================================================================--

    local isFlying, isNoclipping, isSpeedEnabled, isEspEnabled, isAimbotEnabled = false, false, false, false, false
    local noclipConnection = nil

    local originalWalkSpeed = humanoid.WalkSpeed
    local flySpeed = 50
    local customWalkSpeed = 50
    local aimbotSmoothness = 0.2

    local espElements = {}

    --==================================================================================--
    --||                                   MENU PRINCIPAL                               ||--
    --==================================================================================--

    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CalvoModGUI"
    mainGui.Parent = playerGui
    mainGui.ResetOnSpawn = false
    mainGui.Enabled = true -- CORREÇÃO: Habilitado por padrão para aparecer imediatamente.

    local mainFrame = Instance.new("Frame", mainGui)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 2
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Size = UDim2.new(0, 340, 0, 480)
    mainFrame.Draggable = true
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    titleBar.Size = UDim2.new(1, 0, 0, 40)

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "Calvo Mod"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)

    local controlButtonsFrame = Instance.new("Frame", titleBar)
    controlButtonsFrame.BackgroundTransparency = 1
    controlButtonsFrame.Size = UDim2.new(0, 60, 1, 0)
    controlButtonsFrame.Position = UDim2.new(1, -10, 0.5, 0)
    controlButtonsFrame.AnchorPoint = Vector2.new(1, 0.5)
    local controlLayout = Instance.new("UIListLayout", controlButtonsFrame)
    controlLayout.FillDirection = Enum.FillDirection.Horizontal
    controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlLayout.Padding = UDim.new(0, 8)

    local function createControlButton(color)
        local button = Instance.new("TextButton", controlButtonsFrame)
        button.BackgroundColor3 = color
        button.Size = UDim2.new(0, 15, 0, 15)
        button.Text = ""
        Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
        return button
    end
    local minimizeButton = createControlButton(Color3.fromRGB(255, 189, 89))
    local closeButton = createControlButton(Color3.fromRGB(255, 89, 89))

    local contentContainer = Instance.new("Frame", mainFrame)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, 0, 1, -40)
    contentContainer.Position = UDim2.new(0, 0, 0, 40)
    contentContainer.ClipsDescendants = true

    local mainPage = Instance.new("Frame", contentContainer)
    mainPage.Name = "MainPage"
    mainPage.BackgroundTransparency = 1
    mainPage.Size = UDim2.new(1, 0, 1, 0)
    local mainPageLayout = Instance.new("UIListLayout", mainPage)
    mainPageLayout.Padding = UDim.new(0, 15)
    mainPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    mainPageLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local modsPage = Instance.new("Frame", contentContainer)
    modsPage.Name = "ModsPage"
    modsPage.BackgroundTransparency = 1
    modsPage.Size = UDim2.new(1, 0, 1, 0)
    modsPage.Visible = false
    local modsPageLayout = Instance.new("UIListLayout", modsPage)
    modsPageLayout.Padding = UDim.new(0, 15)
    modsPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    modsPageLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    Instance.new("UIPadding", modsPage).PaddingTop = UDim.new(0, 20)

    --==================================================================================--
    --||                                   GUI DO ESP                                 ||--
    --==================================================================================--
    local espGui = Instance.new("ScreenGui")
    espGui.Name = "ESPGUI"
    espGui.Parent = playerGui
    espGui.ResetOnSpawn = false
    espGui.Enabled = false
    espGui.DisplayOrder = 1

    --==================================================================================--
    --||                          FUNÇÕES DE CRIAÇÃO DE UI                            ||--
    --==================================================================================--

    local function createButton(parent, text, layoutOrder)
        local button = Instance.new("TextButton", parent)
        button.Name = text:gsub("%s", "") .. "Button"
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        button.Size = UDim2.new(0.8, 0, 0, 45)
        button.Font = Enum.Font.GothamSemibold
        button.Text = text
        button.TextColor3 = Color3.fromRGB(230, 230, 230)
        button.TextSize = 16
        button.LayoutOrder = layoutOrder
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
        return button
    end

    local function createModButton(parent, text, layoutOrder)
        local button = createButton(parent, text .. " [OFF]", layoutOrder)
        button.Size = UDim2.new(0.85, 0, 0, 35)
        button.TextColor3 = Color3.fromRGB(255, 100, 100)
        button.Font = Enum.Font.Gotham
        local state = false
        button.Activated:Connect(function()
            state = not state
            button.Text = text .. (state and " [ON]" or " [OFF]")
            button.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        end)
        return button
    end

    local function createSlider(parent, text, min, max, initialValue, layoutOrder, callback)
        local container = Instance.new("Frame", parent)
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(0.85, 0, 0, 40)
        container.LayoutOrder = layoutOrder
        container.ClipsDescendants = true
        local title = Instance.new("TextLabel", container)
        title.Font = Enum.Font.Gotham
        title.Text = text
        title.TextColor3 = Color3.fromRGB(200, 200, 200)
        title.TextSize = 14
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(0.5, 0, 0.5, 0)
        title.TextXAlignment = Enum.TextXAlignment.Left
        local valueLabel = Instance.new("TextLabel", container)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.TextSize = 14
        valueLabel.BackgroundTransparency = 1
        valueLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
        valueLabel.Position = UDim2.new(1, 0, 0, 0)
        valueLabel.AnchorPoint = Vector2.new(1, 0)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        local track = Instance.new("Frame", container)
        track.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        track.Size = UDim2.new(1, 0, 0, 8)
        track.Position = UDim2.new(0, 0, 0.75, 0)
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local dragger = Instance.new("TextButton", track)
        dragger.Size = UDim2.new(1, 0, 3, 0)
        dragger.Position = UDim2.new(0.5, 0, 0.5, 0)
        dragger.AnchorPoint = Vector2.new(0.5, 0.5)
        dragger.BackgroundTransparency = 1
        dragger.Text = ""
        local function updateSlider(value)
            local clampedValue = math.clamp(value, min, max)
            local percentage = (clampedValue - min) / (max - min)
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(clampedValue))
            if callback then callback(clampedValue) end
        end
        updateSlider(initialValue)
        dragger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local moveConnection, releaseConnection
                moveConnection = UserInputService.InputChanged:Connect(function(inputObj)
                    if inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch then
                        local mousePos = UserInputService:GetMouseLocation()
                        local relativeX = mousePos.X - track.AbsolutePosition.X
                        local percentage = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
                        updateSlider(min + (max - min) * percentage)
                    end
                end)
                releaseConnection = UserInputService.InputEnded:Connect(function(inputObj)
                    if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
                        moveConnection:Disconnect()
                        releaseConnection:Disconnect()
                    end
                end)
            end
        end)
    end

    --==================================================================================--
    --||                               ELEMENTOS DA GUI                               ||--
    --==================================================================================--

    local modsButton = createButton(mainPage, "Mods", 1)
    local discordButton = createButton(mainPage, "Discord", 2)
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)

    local aimbotButton = createModButton(modsPage, "Aimbot", 1)
    local espButton = createModButton(modsPage, "ESP", 2)
    local flyButton = createModButton(modsPage, "Fly", 3)
    createSlider(modsPage, "Fly Speed", 1, 100, flySpeed, 4, function(value) flySpeed = value end)
    local noclipButton = createModButton(modsPage, "Atravessar Parede", 5)
    local speedButton = createModButton(modsPage, "Speed", 6)
    createSlider(modsPage, "Walk Speed", originalWalkSpeed, 100, customWalkSpeed, 7, function(value)
        customWalkSpeed = value
        if isSpeedEnabled then humanoid.WalkSpeed = customWalkSpeed end
    end)
    local backButton = createButton(modsPage, "Voltar", 99)
    backButton.Size = UDim2.new(0.85, 0, 0, 35)

    --==================================================================================--
    --||                                LÓGICA DO SCRIPT                                ||--
    --==================================================================================--

    closeButton.MouseButton1Click:Connect(function() mainGui:Destroy(); espGui:Destroy() end)
    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        contentContainer.Visible = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 340, 0, 40) or UDim2.new(0, 340, 0, 480)
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    end)

    modsButton.MouseButton1Click:Connect(function() mainPage.Visible = false; modsPage.Visible = true end)
    backButton.MouseButton1Click:Connect(function() modsPage.Visible = false; mainPage.Visible = true end)

    aimbotButton.Activated:Connect(function() isAimbotEnabled = not isAimbotEnabled end)
    function getClosestPlayerToMouse()
        local closestPlayer, shortestDist = nil, math.huge
        local mousePos = UserInputService:GetMouseLocation()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character.Humanoid.Health > 0 then
                local headPos, onScreen = camera:WorldToScreenPoint(player.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
        return closestPlayer
    end

    espButton.Activated:Connect(function()
        isEspEnabled = not isEspEnabled
        espGui.Enabled = isEspEnabled
        if not isEspEnabled then
            for _, elements in pairs(espElements) do elements.box:Destroy() end
            espElements = {}
        end
    end)
    function getPlatformEmoji(player)
        if player == localPlayer then return UserInputService.TouchEnabled and "📱" or "💻" end
        return "💻"
    end
    function createEspElements(player)
        local box = Instance.new("Frame", espGui)
        box.BackgroundTransparency = 1
        box.Size = UDim2.new(0, 100, 0, 120)
        Instance.new("UIStroke", box).Color = Color3.fromRGB(255, 255, 255)
        local nameLabel = Instance.new("TextLabel", box)
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, -20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        local healthBar = Instance.new("Frame", box)
        healthBar.Position = UDim2.new(-1, -5, 0, 0)
        healthBar.Size = UDim2.new(0, 5, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        local healthFill = Instance.new("Frame", healthBar)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthFill.Position = UDim2.new(0, 0, 1, 0)
        healthFill.AnchorPoint = Vector2.new(0, 1)
        return {box = box, name = nameLabel, health = healthFill}
    end
    function updateEsp()
        local currentPlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                currentPlayers[player] = true
                local head = player.Character:FindFirstChild("Head")
                if not head then continue end
                local headPos, onScreen = camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    if not espElements[player] then espElements[player] = createEspElements(player) end
                    local elements = espElements[player]
                    local scale = 1 / (headPos.Z / 100)
                    local boxSize = Vector2.new(60 * scale, 120 * scale)
                    elements.box.Visible = true
                    elements.box.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)
                    elements.box.Position = UDim2.fromOffset(headPos.X - boxSize.X / 2, headPos.Y - boxSize.Y / 2)
                    elements.name.Text = player.Name .. " " .. getPlatformEmoji(player)
                    local healthPercent = player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth
                    elements.health.Size = UDim2.new(1, 0, healthPercent, 0)
                    elements.health.BackgroundColor3 = Color3.fromHSV(0.33 * healthPercent, 1, 1)
                elseif espElements[player] then
                    espElements[player].box.Visible = false
                end
            end
        end
        for player, elements in pairs(espElements) do
            if not currentPlayers[player] then
                elements.box:Destroy()
                espElements[player] = nil
            end
        end
    end

    local flyGyro, flyVelocity
    flyButton.Activated:Connect(function()
        isFlying = not isFlying
        if not isFlying then
            if flyGyro then flyGyro:Destroy() end
            if flyVelocity then flyVelocity:Destroy() end
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        else
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then isFlying = false; return end
            flyGyro = Instance.new("BodyGyro", root); flyGyro.P, flyGyro.MaxTorque = 5e4, Vector3.new(4e5, 4e5, 4e5)
            flyVelocity = Instance.new("BodyVelocity", root); flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)

    noclipButton.Activated:Connect(function()
        isNoclipping = not isNoclipping
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        if isNoclipping then
            noclipConnection = RunService.Stepped:Connect(function()
                for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
            end)
        else
            for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
        end
    end)

    speedButton.Activated:Connect(function()
        isSpeedEnabled = not isSpeedEnabled
        humanoid.WalkSpeed = isSpeedEnabled and customWalkSpeed or originalWalkSpeed
    end)

    RunService.RenderStepped:Connect(function()
        if isAimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestPlayerToMouse()
            if target and target.Character and target.Character.Head then
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), aimbotSmoothness)
            end
        end
        if isEspEnabled then updateEsp() end
        if isFlying and flyVelocity and flyGyro then
            local direction, vDirection = Vector3.new(), 0
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = -camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = -camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vDirection = 1 end
