--[[
    Script: Calvo Studio (V2)
    Autor: Recriado com base na solicitação
    Descrição: GUI com tela de carregamento, menu principal e um painel de opções de modificação (mods).
]]

--==================================================================================--
--||                                   SERVIÇOS E JOGADOR                           ||--
--==================================================================================--

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

--==================================================================================--
--||                                TELA DE CARREGAMENTO                            ||--
--==================================================================================--

-- Gui principal da tela de carregamento
local loadingScreenGui = Instance.new("ScreenGui")
loadingScreenGui.Name = "LoadingScreenGUI"
loadingScreenGui.Parent = playerGui
loadingScreenGui.ResetOnSpawn = false
loadingScreenGui.DisplayOrder = 1000 -- Garante que fique por cima de tudo

-- Fundo preto
local loadingBackground = Instance.new("Frame")
loadingBackground.Name = "Background"
loadingBackground.Parent = loadingScreenGui
loadingBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
loadingBackground.BorderSizePixel = 0
loadingBackground.Size = UDim2.new(1, 0, 1, 0)

-- Título
local loadingTitle = Instance.new("TextLabel")
loadingTitle.Name = "Title"
loadingTitle.Parent = loadingBackground
loadingTitle.Font = Enum.Font.SourceSansBold
loadingTitle.Text = "Calvo Studio"
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.TextSize = 48
loadingTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Size = UDim2.new(0.8, 0, 0.2, 0)
loadingTitle.Position = UDim2.new(0.1, 0, 0.3, 0)
loadingTitle.TextYAlignment = Enum.TextYAlignment.Bottom

-- Barra de progresso (fundo)
local progressBarBackground = Instance.new("Frame")
progressBarBackground.Name = "ProgressBarBackground"
progressBarBackground.Parent = loadingBackground
progressBarBackground.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
progressBarBackground.BorderColor3 = Color3.fromRGB(85, 85, 125)
progressBarBackground.BorderSizePixel = 2
progressBarBackground.Size = UDim2.new(0.6, 0, 0, 30)
progressBarBackground.Position = UDim2.new(0.5, -progressBarBackground.AbsoluteSize.X / 2, 0.5, -15)

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(0, 8)
progressBarCorner.Parent = progressBarBackground

-- Barra de progresso (a que se move)
local progressBarFill = Instance.new("Frame")
progressBarFill.Name = "ProgressBarFill"
progressBarFill.Parent = progressBarBackground
progressBarFill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
progressBarFill.BorderSizePixel = 0
progressBarFill.Size = UDim2.new(0, 0, 1, 0) -- Começa com tamanho 0

local progressBarFillCorner = Instance.new("UICorner")
progressBarFillCorner.CornerRadius = UDim.new(0, 8)
progressBarFillCorner.Parent = progressBarFill

-- Texto de carregamento
local loadingText = Instance.new("TextLabel")
loadingText.Name = "LoadingText"
loadingText.Parent = loadingBackground
loadingText.Font = Enum.Font.SourceSans
loadingText.Text = "Carregando..."
loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingText.TextSize = 18
loadingText.BackgroundTransparency = 1
loadingText.Size = UDim2.new(0.6, 0, 0, 20)
loadingText.Position = UDim2.new(0.5, -loadingText.AbsoluteSize.X / 2, 0.5, 25)

--==================================================================================--
--||                                   MENU PRINCIPAL                               ||--
--==================================================================================--

-- Variáveis de estado para as funções
local isFlying = false
local isNoclipping = false
local originalWalkSpeed = 16

-- Gui principal do menu
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "CalvoStudioGUI"
mainGui.Parent = playerGui
mainGui.ResetOnSpawn = false
mainGui.Enabled = false -- Começa desativado

-- Frame principal (a janela)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = mainGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderColor3 = Color3.fromRGB(85, 85, 125)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.ClipsDescendants = true
local mainFrameCorner = Instance.new("UICorner", mainFrame)
mainFrameCorner.CornerRadius = UDim.new(0, 8)

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Calvo Studio"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
local titleCorner = Instance.new("UICorner", titleLabel)
titleCorner.CornerRadius = UDim.new(0, 8)

-- Container para os botões principais
local mainButtonsContainer = Instance.new("Frame")
mainButtonsContainer.Name = "MainButtonsContainer"
mainButtonsContainer.Parent = mainFrame
mainButtonsContainer.BackgroundTransparency = 1
mainButtonsContainer.Size = UDim2.new(1, -20, 0, 80)
mainButtonsContainer.Position = UDim2.new(0.5, -mainButtonsContainer.AbsoluteSize.X / 2, 0, 60)
local mainButtonsLayout = Instance.new("UIListLayout", mainButtonsContainer)
mainButtonsLayout.Padding = UDim.new(0, 10)
mainButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Botão "Mod Menu"
local modMenuButton = Instance.new("TextButton")
modMenuButton.Name = "ModMenuButton"
modMenuButton.Parent = mainButtonsContainer
modMenuButton.BackgroundColor3 = Color3.fromRGB(85, 85, 125)
modMenuButton.Size = UDim2.new(1, 0, 0, 35)
modMenuButton.Font = Enum.Font.SourceSans
modMenuButton.Text = "Mod Menu"
modMenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modMenuButton.TextSize = 18
local modMenuButtonCorner = Instance.new("UICorner", modMenuButton)
modMenuButtonCorner.CornerRadius = UDim.new(0, 6)

-- Botão "Discord"
local discordButton = Instance.new("TextButton")
discordButton.Name = "DiscordButton"
discordButton.Parent = mainButtonsContainer
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordButton.Size = UDim2.new(1, 0, 0, 35)
discordButton.Font = Enum.Font.SourceSans
discordButton.Text = "Discord"
discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
discordButton.TextSize = 18
local discordButtonCorner = Instance.new("UICorner", discordButton)
discordButtonCorner.CornerRadius = UDim.new(0, 6)

-- Frame para as opções de mod (inicialmente invisível)
local optionsFrame = Instance.new("Frame")
optionsFrame.Name = "OptionsFrame"
optionsFrame.Parent = mainFrame
optionsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
optionsFrame.BorderColor3 = Color3.fromRGB(85, 85, 125)
optionsFrame.BorderSizePixel = 1
optionsFrame.Position = UDim2.new(0.5, -135, 0, 150)
optionsFrame.Size = UDim2.new(0, 270, 0, 140)
optionsFrame.Visible = false
local optionsFrameCorner = Instance.new("UICorner", optionsFrame)
optionsFrameCorner.CornerRadius = UDim.new(0, 8)
local optionsLayout = Instance.new("UIListLayout", optionsFrame)
optionsLayout.Padding = UDim.new(0, 10)
optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
optionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Botão de Fly
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"; flyButton.Parent = optionsFrame
flyButton.BackgroundColor3 = Color3.fromRGB(65, 65, 85); flyButton.Size = UDim2.new(0.9, 0, 0, 30)
flyButton.Font = Enum.Font.SourceSans; flyButton.Text = "Fly [OFF]"; flyButton.TextColor3 = Color3.fromRGB(220, 80, 80)
flyButton.TextSize = 16; local flyCorner = Instance.new("UICorner", flyButton); flyCorner.CornerRadius = UDim.new(0, 6)

-- Botão de Atravessar Parede (Noclip)
local noclipButton = Instance.new("TextButton")
noclipButton.Name = "NoclipButton"; noclipButton.Parent = optionsFrame
noclipButton.BackgroundColor3 = Color3.fromRGB(65, 65, 85); noclipButton.Size = UDim2.new(0.9, 0, 0, 30)
noclipButton.Font = Enum.Font.SourceSans; noclipButton.Text = "Atravessar Parede [OFF]"; noclipButton.TextColor3 = Color3.fromRGB(220, 80, 80)
noclipButton.TextSize = 16; local noclipCorner = Instance.new("UICorner", noclipButton); noclipCorner.CornerRadius = UDim.new(0, 6)

-- Botão de Speed
local speedButton = Instance.new("TextButton")
speedButton.Name = "SpeedButton"; speedButton.Parent = optionsFrame
speedButton.BackgroundColor3 = Color3.fromRGB(65, 65, 85); speedButton.Size = UDim2.new(0.9, 0, 0, 30)
speedButton.Font = Enum.Font.SourceSans; speedButton.Text = "Speed [OFF]"; speedButton.TextColor3 = Color3.fromRGB(220, 80, 80)
speedButton.TextSize = 16; local speedCorner = Instance.new("UICorner", speedButton); speedCorner.CornerRadius = UDim.new(0, 6)

--==================================================================================--
--||                                LÓGICA DO SCRIPT                                ||--
--==================================================================================--

-- LÓGICA DE TRANSIÇÃO (LOADING -> MENU)
function StartLoading()
    local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear) -- 3 segundos de carregamento
    local tween = TweenService:Create(progressBarFill, tweenInfo, { Size = UDim2.new(1, 0, 1, 0) })
    
    tween:Play()
    tween.Completed:Wait() -- Espera a animação da barra terminar
    
    task.wait(0.5) -- Pequena pausa para efeito
    
    -- Anima a saída da tela de carregamento
    local fadeOutInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
    local fadeOutTween = TweenService:Create(loadingBackground, fadeOutInfo, {BackgroundTransparency = 1})
    fadeOutTween:Play()
    fadeOutTween.Completed:Wait()

    loadingScreenGui:Destroy() -- Remove a tela de carregamento
    mainGui.Enabled = true -- Ativa o menu principal
    print("Calvo Studio GUI carregado com sucesso!")
end

-- LÓGICA DOS BOTÕES DO MENU

-- Botão "Mod Menu"
modMenuButton.MouseButton1Click:Connect(function()
    optionsFrame.Visible = not optionsFrame.Visible
end)

-- Botão "Discord"
discordButton.MouseButton1Click:Connect(function()
    -- Roblox não permite abrir links. Ação recomendada é copiar um link.
    print("Botão do Discord clicado! Lógica para copiar link para a área de transferência seria adicionada aqui.")
end)

-- Botão Fly
flyButton.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
    local rootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    if isFlying then
        flyButton.Text = "Fly [ON]"; flyButton.TextColor3 = Color3.fromRGB(80, 220, 80)
        local bodyGyro = Instance.new("BodyGyro", rootPart)
        bodyGyro.P = 50000; bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        local bodyVelocity = Instance.new("BodyVelocity", rootPart)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0); bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    else
        flyButton.Text = "Fly [OFF]"; flyButton.TextColor3 = Color3.fromRGB(220, 80, 80)
        if rootPart:FindFirstChild("BodyGyro") then rootPart.BodyGyro:Destroy() end
        if rootPart:FindFirstChild("BodyVelocity") then rootPart.BodyVelocity:Destroy() end
    end
end)

-- Botão Noclip
noclipButton.MouseButton1Click:Connect(function()
    isNoclipping = not isNoclipping
    if isNoclipping then
        noclipButton.Text = "Atravessar Parede [ON]"; noclipButton.TextColor3 = Color3.fromRGB(80, 220, 80)
    else
        noclipButton.Text = "Atravessar Parede [OFF]"; noclipButton.TextColor3 = Color3.fromRGB(220, 80, 80)
    end
    for _, part in pairs(localPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not isNoclipping
        end
    end
end)

-- Botão Speed
speedButton.MouseButton1Click:Connect(function()
    local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if humanoid.WalkSpeed == originalWalkSpeed then
        humanoid.WalkSpeed = 75
        speedButton.Text = "Speed [ON]"; speedButton.TextColor3 = Color3.fromRGB(80, 220, 80)
    else
        humanoid.WalkSpeed = originalWalkSpeed
        speedButton.Text = "Speed [OFF]"; speedButton.TextColor3 = Color3.fromRGB(220, 80, 80)
    end
end)

-- Inicia todo o processo
StartLoading()
