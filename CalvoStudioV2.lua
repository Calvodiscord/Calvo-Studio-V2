--[[
    Script: Calvo Studio (V4)
    Autor: Recriado e aprimorado com base na solicitação (com sliders de velocidade)
    Descrição: GUI com tela de carregamento, menu principal com páginas,
               botão de minimizar e um painel de opções de modificação (mods) com
               controles de velocidade.
]]

--==================================================================================--
--||                                   SERVIÇOS E JOGADOR                           ||--
--==================================================================================--

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

--==================================================================================--
--||                           CONFIGURAÇÕES E ESTADO                               ||--
--==================================================================================--

local isFlying = false
local isNoclipping = false
local isSpeedEnabled = false
local originalWalkSpeed = humanoid.WalkSpeed
local flySpeed = 50 -- Valor inicial do fly speed
local customWalkSpeed = 50 -- Valor inicial do walk speed customizado

--==================================================================================--
--||                                TELA DE CARREGAMENTO                            ||--
--==================================================================================--

-- Gui principal da tela de carregamento
local loadingScreenGui = Instance.new("ScreenGui")
loadingScreenGui.Name = "LoadingScreenGUI"
loadingScreenGui.Parent = playerGui
loadingScreenGui.ResetOnSpawn = false
loadingScreenGui.DisplayOrder = 1000 -- Garante que fique por cima de tudo

local loadingBackground = Instance.new("CanvasGroup")
loadingBackground.Name = "Background"
loadingBackground.Parent = loadingScreenGui
loadingBackground.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
loadingBackground.BorderSizePixel = 0
loadingBackground.Size = UDim2.new(1, 0, 1, 0)

-- Título
local loadingTitle = Instance.new("TextLabel")
loadingTitle.Name = "Title"
loadingTitle.Parent = loadingBackground
loadingTitle.Font = Enum.Font.GothamSemibold
loadingTitle.Text = "Calvo Studio"
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.TextSize = 52
loadingTitle.BackgroundTransparency = 1
loadingTitle.Size = UDim2.new(1, 0, 0.2, 0)
loadingTitle.Position = UDim2.new(0.5, 0, 0.35, 0)
loadingTitle.AnchorPoint = Vector2.new(0.5, 0.5)

-- Barra de progresso (fundo)
local progressBarBackground = Instance.new("Frame")
progressBarBackground.Name = "ProgressBarBackground"
progressBarBackground.Parent = loadingBackground
progressBarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
progressBarBackground.BorderSizePixel = 0
progressBarBackground.Size = UDim2.new(0.5, 0, 0, 20)
progressBarBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
progressBarBackground.AnchorPoint = Vector2.new(0.5, 0.5)
local progressBarCorner = Instance.new("UICorner", progressBarBackground)
progressBarCorner.CornerRadius = UDim.new(1, 0)

-- Barra de progresso (preenchimento)
local progressBarFill = Instance.new("Frame")
progressBarFill.Name = "ProgressBarFill"
progressBarFill.Parent = progressBarBackground
progressBarFill.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
progressBarFill.BorderSizePixel = 0
progressBarFill.Size = UDim2.new(0, 0, 1, 0)
local progressBarFillCorner = Instance.new("UICorner", progressBarFill)
progressBarFillCorner.CornerRadius = UDim.new(1, 0)

-- Texto de status
local loadingText = Instance.new("TextLabel")
loadingText.Name = "LoadingText"
loadingText.Parent = loadingBackground
loadingText.Font = Enum.Font.Gotham
loadingText.Text = "Carregando assets..."
loadingText.TextColor3 = Color3.fromRGB(180, 180, 180)
loadingText.TextSize = 18
loadingText.BackgroundTransparency = 1
loadingText.Size = UDim2.new(1, 0, 0, 30)
loadingText.Position = UDim2.new(0.5, 0, 0.5, 30)
loadingText.AnchorPoint = Vector2.new(0.5, 0.5)

--==================================================================================--
--||                                   MENU PRINCIPAL                               ||--
--==================================================================================--

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "CalvoStudioGUI"
mainGui.Parent = playerGui
mainGui.ResetOnSpawn = false
mainGui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = mainGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0, 320, 0, 450) -- Aumentado o tamanho para os sliders
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.ClipsDescendants = true
local mainFrameCorner = Instance.new("UICorner", mainFrame)
mainFrameCorner.CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Calvo Studio"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Parent = titleBar
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 89, 89)
minimizeButton.Size = UDim2.new(0, 15, 0, 15)
minimizeButton.Position = UDim2.new(0, 25, 0.5, 0)
minimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Text = ""
local minBtnCorner = Instance.new("UICorner", minimizeButton)
minBtnCorner.CornerRadius = UDim.new(1, 0)

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Parent = mainFrame
contentContainer.BackgroundTransparency = 1
contentContainer.Size = UDim2.new(1, 0, 1, -40)
contentContainer.Position = UDim2.new(0, 0, 0, 40)
contentContainer.ClipsDescendants = true

local mainPage = Instance.new("Frame")
mainPage.Name = "MainPage"
mainPage.Parent = contentContainer
mainPage.BackgroundTransparency = 1
mainPage.Size = UDim2.new(1, 0, 1, 0)
local mainPageLayout = Instance.new("UIListLayout", mainPage)
mainPageLayout.Padding = UDim.new(0, 15)
mainPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainPageLayout.VerticalAlignment = Enum.VerticalAlignment.Center
mainPageLayout.SortOrder = Enum.SortOrder.LayoutOrder

local modsPage = Instance.new("Frame")
modsPage.Name = "ModsPage"
modsPage.Parent = contentContainer
modsPage.BackgroundTransparency = 1
modsPage.Size = UDim2.new(1, 0, 1, 0)
modsPage.Visible = false
local modsPageLayout = Instance.new("UIListLayout", modsPage)
modsPageLayout.Padding = UDim.new(0, 12)
modsPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
modsPageLayout.VerticalAlignment = Enum.VerticalAlignment.Top
modsPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
local modsPagePadding = Instance.new("UIPadding", modsPage)
modsPagePadding.PaddingTop = UDim.new(0, 20)

--==================================================================================--
--||                          FUNÇÕES DE CRIAÇÃO DE UI                            ||--
--==================================================================================--

-- Função para criar botões estilizados
local function createButton(parent, text, layoutOrder)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Name = text:gsub(" ", "") .. "Button"
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    button.Size = UDim2.new(0.8, 0, 0, 45)
    button.Font = Enum.Font.GothamSemibold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 16
    button.LayoutOrder = layoutOrder
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 8)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 95)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play()
    end)
    
    return button
end

-- Função para criar botões de mods (com estado ON/OFF)
local function createModButton(parent, text, layoutOrder)
    local button = createButton(parent, text .. " [OFF]", layoutOrder)
    button.Size = UDim2.new(0.85, 0, 0, 35)
    button.TextColor3 = Color3.fromRGB(255, 100, 100)
    button.Font = Enum.Font.Gotham
    
    local state = false
    button.Activated:Connect(function()
        state = not state
        if state then
            button.Text = text .. " [ON]"
            button.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            button.Text = text .. " [OFF]"
            button.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    return button, function() return state end -- Retorna o botão e uma função para pegar o estado
end

-- --- NOVO: Função para criar sliders de velocidade ---
local function createSlider(parent, text, min, max, initialValue, layoutOrder, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0.85, 0, 0, 40)
    container.LayoutOrder = layoutOrder

    local title = Instance.new("TextLabel")
    title.Parent = container
    title.Font = Enum.Font.Gotham
    title.Text = text
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.TextSize = 14
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(0.5, 0, 1, 0)
	title.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = container
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, 0, 0, 0)
    valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame")
    track.Parent = container
    track.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    track.BorderSizePixel = 0
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0.5, 0, 1, 0)
    track.AnchorPoint = Vector2.new(0.5, 1)
    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Parent = track
    fill.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    fill.BorderSizePixel = 0
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(1, 0)

    local handle = Instance.new("Frame")
    handle.Parent = track
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(0, 0, 0.5, 0)
    local handleCorner = Instance.new("UICorner", handle)
    handleCorner.CornerRadius = UDim.new(1, 0)

    local function updateSlider(value)
        local percentage = (value - min) / (max - min)
        percentage = math.clamp(percentage, 0, 1)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        handle.Position = UDim2.new(percentage, 0, 0.5, 0)
        valueLabel.Text = tostring(math.floor(value))
        if callback then
            callback(value)
        end
    end

    updateSlider(initialValue)

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UserInputService.InputChanged:Connect(function(inputChanged)
                if inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = mousePos.X - track.AbsolutePosition.X
                    local percentage = math.clamp(relativePos / track.AbsoluteSize.X, 0, 1)
                    local newValue = min + (max - min) * percentage
                    updateSlider(newValue)
                end
            end)

            local endedConnection
            endedConnection = UserInputService.InputEnded:Connect(function(inputEnded)
                if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                    endedConnection:Disconnect()
                end
            end)
        end
    end)
    
    return container, updateSlider
end

--==================================================================================--
--||                               ELEMENTOS DA GUI                               ||--
--==================================================================================--

-- Botões da página principal
local modMenuButton = createButton(mainPage, "Mod Menu", 1)
local discordButton = createButton(mainPage, "Discord", 2)
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordButton.MouseEnter:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 137, 218)}):Play()
end)
discordButton.MouseLeave:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
end)

-- Botões e sliders da página de mods
local flyButton, getFlyState = createModButton(modsPage, "Fly", 1)
local flySlider = createSlider(modsPage, "Fly Speed", 1, 100, flySpeed, 2, function(value)
    flySpeed = value
end)

local noclipButton, getNoclipState = createModButton(modsPage, "Atravessar Parede", 3)

local speedButton, getSpeedState = createModButton(modsPage, "Speed", 4)
local speedSlider = createSlider(modsPage, "Walk Speed", originalWalkSpeed, 100, customWalkSpeed, 5, function(value)
    customWalkSpeed = value
    if getSpeedState() then -- Atualiza em tempo real se o mod estiver ativo
        humanoid.WalkSpeed = customWalkSpeed
    end
end)

local backButton = createButton(modsPage, "Voltar", 6)
backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
backButton.Size = UDim2.new(0.85, 0, 0, 35)

--==================================================================================--
--||                                LÓGICA DO SCRIPT                                ||--
--==================================================================================--

function StartLoading()
    local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = TweenService:Create(progressBarFill, tweenInfo, { Size = UDim2.new(1, 0, 1, 0) })
    
    tween:Play()
    tween.Completed:Wait()
    
    loadingText.Text = "Pronto!"
    task.wait(0.5)
    
    local fadeOutInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
    local fadeOutTween = TweenService:Create(loadingBackground, fadeOutInfo, {GroupTransparency = 1})
    fadeOutTween:Play()
    
    fadeOutTween.Completed:Wait()

    loadingScreenGui:Destroy()
    mainGui.Enabled = true
    print("Calvo Studio GUI carregado com sucesso!")
end

-- LÓGICA DOS BOTÕES DO MENU
modMenuButton.MouseButton1Click:Connect(function()
    mainPage.Visible = false
    modsPage.Visible = true
end)

backButton.MouseButton1Click:Connect(function()
    modsPage.Visible = false
    mainPage.Visible = true
end)

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    contentContainer.Visible = not isMinimized
    
    local sizeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if isMinimized then
        TweenService:Create(mainFrame, sizeInfo, {Size = UDim2.new(0, 150, 0, 40)}):Play()
        minimizeButton.BackgroundColor3 = Color3.fromRGB(89, 255, 89)
    else
        TweenService:Create(mainFrame, sizeInfo, {Size = UDim2.new(0, 320, 0, 450)}):Play() -- Tamanho restaurado
        minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 89, 89)
    end
end)

discordButton.MouseButton1Click:Connect(function()
    print("Link do Discord: (Um link seria copiado aqui)")
    -- setclipboard("SEU_LINK_AQUI")
end)

-- LÓGICA DOS MODS

-- Botão Fly
local flyGyro, flyVelocity
flyButton.Activated:Connect(function()
    isFlying = getFlyState()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    if isFlying then
        flyGyro = Instance.new("BodyGyro")
        flyGyro.P = 50000
        flyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        flyGyro.CFrame = rootPart.CFrame
        flyGyro.Parent = rootPart

        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyVelocity.Parent = rootPart
        
        humanoid.PlatformStand = true
    else
        if flyGyro then flyGyro:Destroy() end
        if flyVelocity then flyVelocity:Destroy() end
        humanoid.PlatformStand = false
    end
end)

RunService.RenderStepped:Connect(function()
    if isFlying and flyVelocity then
        local direction = Vector3.new(0,0,0)
        local cameraCFrame = workspace.CurrentCamera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cameraCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cameraCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cameraCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cameraCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0,1,0) end

        if direction.Magnitude > 0 then
            flyVelocity.Velocity = direction.Unit * flySpeed -- Usa a variável do slider
        else
            flyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        if flyGyro then flyGyro.CFrame = cameraCFrame end
    end
end)

-- Botão Noclip
noclipButton.Activated:Connect(function()
    isNoclipping = getNoclipState()
    pcall(function()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not isNoclipping
            end
        end
    end)
end)

-- Botão Speed
speedButton.Activated:Connect(function()
    isSpeedEnabled = getSpeedState()
    if isSpeedEnabled then
        humanoid.WalkSpeed = customWalkSpeed -- Usa a velocidade do slider
    else
        humanoid.WalkSpeed = originalWalkSpeed -- Restaura para a original
    end
end)

-- Inicia todo o processo
StartLoading()
