--[[
    Script: CALVO MOD V1
    Descrição: Interface de usuário completa para Roblox, recriada em Lua.
    Funcionalidades:
    - Tela de carregamento com barra de progresso.
    - Menu principal com transição para o painel de mods.
    - Painel de mods com abas, inspirado na imagem.
    - Funcionalidade de minimizar para uma bola arrastável.
    - Design moderno e animações fluidas com TweenService.
]]

-- Proteção para garantir que o script rode em um ambiente de executor
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- // SERVIÇOS E VARIÁVEIS GLOBAIS //
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURAÇÕES DA UI //
local Theme = {
    AccentColor = Color3.fromHex("4F46E5"),
    AccentHover = Color3.fromHex("6366F1"),
    BackgroundColor = Color3.fromHex("111827"),
    SecondaryColor = Color3.fromHex("1F2937"),
    TertiaryColor = Color3.fromHex("374151"),
    TextColor = Color3.fromHex("FFFFFF"),
    MutedTextColor = Color3.fromHex("9CA3AF"),
    HeaderColor = Color3.fromHex("000000"),
    BorderColor = Color3.fromHex("4B5563"),
    SuccessColor = Color3.fromHex("22C55E"),
    ErrorColor = Color3.fromHex("EF4444")
}

-- Asset IDs dos Ícones (Você pode encontrar outros na Toolbox do Roblox Studio)
local IconIDs = {
    Minimize = "rbxassetid://9995999587",
    Close = "rbxassetid://13511784923",
    Back = "rbxassetid://12190913161",
    Bolt = "rbxassetid://6032099961",
    Main = "rbxassetid://5101472398",
    Visual = "rbxassetid://6032093933",
    Shop = "rbxassetid://10722193266",
    Random = "rbxassetid://9882212793",
    Credit = "rbxassetid://4915354534"
}

-- // CRIAÇÃO DA UI //
-- Remove UI antiga para evitar duplicação
pcall(function() LocalPlayer.PlayerGui.CalvoModScreenGui:Destroy() end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CalvoModScreenGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Container principal que será animado e arrastado
local MenuContainer = Instance.new("Frame")
MenuContainer.Name = "MenuContainer"
MenuContainer.Size = UDim2.new(0, 360, 0, 250)
MenuContainer.Position = UDim2.fromScale(0.5, 0.5)
MenuContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MenuContainer.BackgroundColor3 = Theme.BackgroundColor
MenuContainer.BackgroundTransparency = 0.1
MenuContainer.BorderSizePixel = 1
MenuContainer.BorderColor3 = Theme.BorderColor
MenuContainer.ClipsDescendants = true
MenuContainer.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MenuContainer

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.BorderColor
UIStroke.Thickness = 1
UIStroke.Parent = MenuContainer

-- Efeito de Backdrop (desfoque)
if syn and syn.blur then -- Apenas para executores que suportam
    local blur = Instance.new("Frame")
    blur.Name = "BlurBackdrop"
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.Parent = MenuContainer
    syn.blur(blur, 10)
end

-- // TELA DE CARREGAMENTO //
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.BackgroundColor3 = Theme.BackgroundColor
LoadingScreen.BackgroundTransparency = 1 -- Invisível, os filhos são visíveis
LoadingScreen.Parent = MenuContainer

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Name = "LoadingTitle"
LoadingTitle.Size = UDim2.new(1, -20, 0, 40)
LoadingTitle.Position = UDim2.new(0.5, 0, 0.3, 0)
LoadingTitle.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Font = Enum.Font.Poppins
LoadingTitle.Text = "CALVO MOD <font color='#4F46E5'>V1</font>"
LoadingTitle.TextColor3 = Theme.TextColor
LoadingTitle.TextSize = 32
LoadingTitle.RichText = true
LoadingTitle.Parent = LoadingScreen

local LoadingSubtitle = Instance.new("TextLabel")
LoadingSubtitle.Name = "LoadingSubtitle"
LoadingSubtitle.Size = UDim2.new(1, -20, 0, 20)
LoadingSubtitle.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingSubtitle.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingSubtitle.BackgroundTransparency = 1
LoadingSubtitle.Font = Enum.Font.Poppins
LoadingSubtitle.Text = "Carregando recursos..."
LoadingSubtitle.TextColor3 = Theme.MutedTextColor
LoadingSubtitle.TextSize = 14
LoadingSubtitle.Parent = LoadingScreen

local ProgressBarBG = Instance.new("Frame")
ProgressBarBG.Name = "ProgressBarBG"
ProgressBarBG.Size = UDim2.new(0.8, 0, 0, 10)
ProgressBarBG.Position = UDim2.new(0.5, 0, 0.7, 0)
ProgressBarBG.AnchorPoint = Vector2.new(0.5, 0.5)
ProgressBarBG.BackgroundColor3 = Theme.TertiaryColor
ProgressBarBG.Parent = LoadingScreen
Instance.new("UICorner", ProgressBarBG)

local ProgressBar = Instance.new("Frame")
ProgressBar.Name = "ProgressBar"
ProgressBar.Size = UDim2.new(0, 0, 1, 0) -- Começa com 0 de largura
ProgressBar.BackgroundColor3 = Theme.AccentColor
ProgressBar.Parent = ProgressBarBG
Instance.new("UICorner", ProgressBar)

-- // MENU PRINCIPAL //
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(1, 0, 1, 0)
MainMenu.BackgroundTransparency = 1
MainMenu.Visible = false
MainMenu.Parent = MenuContainer

-- Cabeçalho
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Theme.HeaderColor
Header.BackgroundTransparency = 0.7
Header.Parent = MainMenu

local BackBtn = Instance.new("ImageButton")
BackBtn.Name = "BackBtn"
BackBtn.Size = UDim2.new(0, 24, 0, 24)
BackBtn.Position = UDim2.new(0, 15, 0.5, 0)
BackBtn.AnchorPoint = Vector2.new(0, 0.5)
BackBtn.BackgroundTransparency = 1
BackBtn.Image = IconIDs.Back
BackBtn.Visible = false
BackBtn.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0.5, 0, 0.5, 0)
Title.AnchorPoint = Vector2.new(0.5, 0.5)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Poppins
Title.Text = "CALVO MOD <font color='#4F46E5'>V1</font>"
Title.TextColor3 = Theme.TextColor
Title.TextSize = 20
Title.RichText = true
Title.Parent = Header

local MinimizeBtn = Instance.new("ImageButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -55, 0.5, 0)
MinimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Image = IconIDs.Minimize
MinimizeBtn.Parent = Header

local CloseBtn = Instance.new("ImageButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -20, 0.5, 0)
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = IconIDs.Close
CloseBtn.Parent = Header

-- Corpo da Home
local HomeBody = Instance.new("Frame")
HomeBody.Name = "HomeBody"
HomeBody.Size = UDim2.new(1, 0, 1, -50)
HomeBody.Position = UDim2.new(0, 0, 0, 50)
HomeBody.BackgroundTransparency = 1
HomeBody.Parent = MainMenu

local HomeButtonsLayout = Instance.new("UIListLayout")
HomeButtonsLayout.Padding = UDim.new(0, 15)
HomeButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
HomeButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HomeButtonsLayout.Parent = HomeBody

local OpenModMenuBtn = Instance.new("TextButton")
OpenModMenuBtn.Name = "OpenModMenuBtn"
OpenModMenuBtn.Size = UDim2.new(0.8, 0, 0, 50)
OpenModMenuBtn.BackgroundColor3 = Theme.AccentColor
OpenModMenuBtn.Font = Enum.Font.Poppins
OpenModMenuBtn.Text = "Mod Menu"
OpenModMenuBtn.TextColor3 = Theme.TextColor
OpenModMenuBtn.TextSize = 18
Instance.new("UICorner", OpenModMenuBtn).CornerRadius = UDim.new(0, 8)
OpenModMenuBtn.Parent = HomeBody

local IdiomasBtn = Instance.new("TextButton")
IdiomasBtn.Name = "IdiomasBtn"
IdiomasBtn.Size = UDim2.new(0.8, 0, 0, 50)
IdiomasBtn.BackgroundColor3 = Theme.TertiaryColor
IdiomasBtn.Font = Enum.Font.Poppins
IdiomasBtn.Text = "Idiomas"
IdiomasBtn.TextColor3 = Theme.TextColor
IdiomasBtn.TextSize = 18
Instance.new("UICorner", IdiomasBtn).CornerRadius = UDim.new(0, 8)
IdiomasBtn.Parent = HomeBody

-- Corpo do Mod Menu
local ModMenuBody = Instance.new("Frame")
ModMenuBody.Name = "ModMenuBody"
ModMenuBody.Size = UDim2.new(1, 0, 1, -50)
ModMenuBody.Position = UDim2.new(0, 0, 0, 50)
ModMenuBody.BackgroundTransparency = 1
ModMenuBody.Visible = false
ModMenuBody.Parent = MainMenu

local NavFrame = Instance.new("Frame")
NavFrame.Name = "NavFrame"
NavFrame.Size = UDim2.new(0.35, 0, 1, 0)
NavFrame.BackgroundColor3 = Theme.HeaderColor
NavFrame.BackgroundTransparency = 0.5
NavFrame.Parent = ModMenuBody

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 5)
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Parent = NavFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(0.65, 0, 1, 0)
ContentFrame.Position = UDim2.new(0.35, 0, 0, 0)
ContentFrame.BackgroundColor3 = Theme.SecondaryColor
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Será ajustado
ContentFrame.ScrollBarImageColor3 = Theme.AccentColor
ContentFrame.ScrollBarThickness = 5
ContentFrame.Parent = ModMenuBody

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = ContentFrame

-- Ícone da Bola (Minimizado)
local BallIcon = Instance.new("ImageLabel")
BallIcon.Name = "BallIcon"
BallIcon.Size = UDim2.new(1, 0, 1, 0)
BallIcon.BackgroundTransparency = 1
BallIcon.Image = IconIDs.Bolt
BallIcon.ImageColor3 = Theme.TextColor
BallIcon.Visible = false
BallIcon.Parent = MenuContainer

-- // FUNÇÕES DA UI //
local isMinimized = false

local function CreateTween(instance, propertyTable, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    return TweenService:Create(instance, tweenInfo, propertyTable)
end

local function AnimateOut(instance, duration, callback)
    local transparencyTween = CreateTween(instance, {BackgroundTransparency = 1}, duration)
    if instance:IsA("TextLabel") or instance:IsA("TextButton") then
        transparencyTween = CreateTween(instance, {TextTransparency = 1}, duration)
    elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
        transparencyTween = CreateTween(instance, {ImageTransparency = 1}, duration)
    end
    
    transparencyTween.Completed:Connect(function()
        instance.Visible = false
        if callback then callback() end
    end)
    transparencyTween:Play()
end

local function AnimateIn(instance, duration)
    instance.Visible = true
    if instance:IsA("TextLabel") or instance:IsA("TextButton") then
        CreateTween(instance, {TextTransparency = 0}, duration):Play()
    elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
        CreateTween(instance, {ImageTransparency = 0}, duration):Play()
    else
        CreateTween(instance, {BackgroundTransparency = 0.1}, duration):Play()
    end
end

-- Simulação de Carregamento
coroutine.wrap(function()
    for i = 1, 100, math.random(5, 15) do
        local progress = math.min(i / 100, 1)
        CreateTween(ProgressBar, {Size = UDim2.new(progress, 0, 1, 0)}, 0.2):Play()
        task.wait(0.1)
    end
    CreateTween(ProgressBar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2):Play()
    task.wait(0.5)
    
    AnimateOut(LoadingScreen, 0.3, function()
        MainMenu.Visible = true
        AnimateIn(MainMenu, 0.3)
    end)
end)()

-- Função para criar abas e conteúdo
local Categories = {}
local function CreateCategory(name, iconId, layoutOrder)
    local navButton = Instance.new("TextButton")
    navButton.Name = name .. "Btn"
    navButton.Size = UDim2.new(0.9, 0, 0, 40)
    navButton.BackgroundColor3 = Theme.TertiaryColor
    navButton.BackgroundTransparency = 1
    navButton.Font = Enum.Font.Poppins
    navButton.Text = "  " .. name
    navButton.TextColor3 = Theme.MutedTextColor
    navButton.TextSize = 16
    navButton.TextXAlignment = Enum.TextXAlignment.Left
    navButton.LayoutOrder = layoutOrder
    Instance.new("UICorner", navButton).CornerRadius = UDim.new(0, 6)
    navButton.Parent = NavFrame

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 10, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Theme.MutedTextColor
    icon.Parent = navButton

    local contentPanel = Instance.new("Frame")
    contentPanel.Name = name .. "Content"
    contentPanel.Size = UDim2.new(0.9, 0, 0, 0) -- Altura automática
    contentPanel.AutomaticSize = Enum.AutomaticSize.Y
    contentPanel.BackgroundTransparency = 1
    contentPanel.Visible = false
    contentPanel.Parent = ContentFrame
    
    local panelLayout = Instance.new("UIListLayout")
    panelLayout.Padding = UDim.new(0, 10)
    panelLayout.Parent = contentPanel

    Categories[name] = {
        Button = navButton,
        Icon = icon,
        Panel = contentPanel
    }
    return contentPanel
end

-- Função para trocar de categoria
local activeCategory = nil
local function SwitchCategory(name)
    if activeCategory then
        Categories[activeCategory].Button.BackgroundColor3 = Theme.TertiaryColor
        Categories[activeCategory].Button.BackgroundTransparency = 1
        Categories[activeCategory].Button.TextColor3 = Theme.MutedTextColor
        Categories[activeCategory].Icon.ImageColor3 = Theme.MutedTextColor
        Categories[activeCategory].Panel.Visible = false
    end
    
    Categories[name].Button.BackgroundColor3 = Theme.AccentColor
    Categories[name].Button.BackgroundTransparency = 0
    Categories[name].Button.TextColor3 = Theme.TextColor
    Categories[name].Icon.ImageColor3 = Theme.TextColor
    Categories[name].Panel.Visible = true
    activeCategory = name
    
    -- Atualiza o tamanho do Canvas do ScrollingFrame
    task.wait()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
end

-- Função para criar um Toggle Switch
local function CreateToggle(parent, title, description, enabled)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Theme.TertiaryColor
    frame.BackgroundTransparency = 0.5
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    frame.Parent = parent

    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(0.7, 0, 1, 0)
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0.5, 0)
    titleLabel.Position = UDim2.new(0, 10, 0.25, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.Poppins
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.TextColor
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = textFrame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -10, 0.5, 0)
    descLabel.Position = UDim2.new(0, 10, 0.7, 0)
    descLabel.AnchorPoint = Vector2.new(0, 0.5)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Poppins
    descLabel.Text = description
    descLabel.TextColor3 = Theme.MutedTextColor
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = textFrame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.Position = UDim2.new(1, -30, 0.5, 0)
    switch.AnchorPoint = Vector2.new(0.5, 0.5)
    switch.BackgroundColor3 = enabled and Theme.AccentColor or Theme.BorderColor
    switch.Text = ""
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    switch.Parent = frame
    
    local nub = Instance.new("Frame")
    nub.Size = UDim2.new(0, 14, 0, 14)
    nub.Position = enabled and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    nub.AnchorPoint = Vector2.new(enabled and 1 or 0, 0.5)
    nub.BackgroundColor3 = Theme.TextColor
    Instance.new("UICorner", nub).CornerRadius = UDim.new(1, 0)
    nub.Parent = switch
    
    local state = enabled
    switch.MouseButton1Click:Connect(function()
        state = not state
        local nubPos = state and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local bgColor = state and Theme.AccentColor or Theme.BorderColor
        CreateTween(nub, {Position = nubPos}, 0.2):Play()
        CreateTween(switch, {BackgroundColor3 = bgColor}, 0.2):Play()
        
        -- AQUI VOCÊ COLOCA A FUNÇÃO DO SEU MOD
        -- Exemplo: getgenv().AntiTrap = state
        print(title .. " foi " .. (state and "ativado" or "desativado"))
    end)
end

-- Função para criar um Botão de Ação
local function CreateButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Theme.AccentColor
    button.Font = Enum.Font.Poppins
    button.Text = text
    button.TextColor3 = Theme.TextColor
    button.TextSize = 14
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    button.Parent = parent
    
    button.MouseButton1Click:Connect(function()
        -- AQUI VOCÊ COLOCA A FUNÇÃO DO SEU MOD
        if callback then callback() end
        print(text .. " foi pressionado")
    end)
end

-- Criar as categorias e seu conteúdo
local mainContent = CreateCategory("Main", IconIDs.Main, 1)
CreateToggle(mainContent, "Anti Trap", "Remove a trap hitbox", true)
CreateButton(mainContent, "Boost Speed", function() print("Velocidade aumentada!") end)
CreateButton(mainContent, "AntiSteal (OP)", function() print("AntiSteal ativado!") end)

local visualContent = CreateCategory("Visual", IconIDs.Visual, 2)
CreateToggle(visualContent, "ESP Player", "Mostra jogadores através das paredes", false)

local shopContent = CreateCategory("Shop", IconIDs.Shop, 3)
CreateToggle(shopContent, "Auto Buy Items", "Compra itens automaticamente", false)

local randomContent = CreateCategory("Random Features", IconIDs.Random, 4)
local creditContent = CreateCategory("Credit", IconIDs.Credit, 5)
Instance.new("TextLabel", creditContent).Text = "Feito por [Seu Nome]" -- Adicione seu crédito aqui

-- // CONEXÕES DE EVENTOS //
CloseBtn.MouseButton1Click:Connect(function()
    AnimateOut(MenuContainer, 0.3, function() ScreenGui:Destroy() end)
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainMenu.Visible = false
        BallIcon.Visible = true
        CreateTween(MenuContainer, {Size = UDim2.new(0, 64, 0, 64)}, 0.4):Play()
    else
        BallIcon.Visible = false
        MainMenu.Visible = true
        local targetSize = ModMenuBody.Visible and UDim2.new(0, 500, 0, 350) or UDim2.new(0, 360, 0, 250)
        CreateTween(MenuContainer, {Size = targetSize}, 0.4):Play()
    end
end)

OpenModMenuBtn.MouseButton1Click:Connect(function()
    HomeBody.Visible = false
    ModMenuBody.Visible = true
    BackBtn.Visible = true
    Title.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centraliza o título
    CreateTween(MenuContainer, {Size = UDim2.new(0, 500, 0, 350)}, 0.3):Play()
    SwitchCategory("Main") -- Abre a primeira categoria por padrão
end)

BackBtn.MouseButton1Click:Connect(function()
    ModMenuBody.Visible = false
    HomeBody.Visible = true
    BackBtn.Visible = false
    Title.Position = UDim2.new(0.5, 0, 0.5, 0)
    CreateTween(MenuContainer, {Size = UDim2.new(0, 360, 0, 250)}, 0.3):Play()
end)

-- Conectar botões de navegação
for name, data in pairs(Categories) do
    data.Button.MouseButton1Click:C
CloseBtn.MouseButton1Click:Connect(function()
    AnimateOut(MenuContainer, 0.3, function() ScreenGui:Destroy() end)
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainMenu.Visible = false
        BallIcon.Visible = true
        CreateTween(MenuContainer, {Size = UDim2.new(0, 64, 0, 64)}, 0.4):Play()
    else
        BallIcon.Visible = false
        MainMenu.Visible = true
        local targetSize = ModMenuBody.Visible and UDim2.new(0, 500, 0, 350) or UDim2.new(0, 360, 0, 250)
        CreateTween(MenuContainer, {Size = targetSize}, 0.4):Play()
    end
end)

OpenModMenuBtn.MouseButton1Click:Connect(function()
    HomeBody.Visible = false
    ModMenuBody.Visible = true
    BackBtn.Visible = true
    Title.Position = UDim2.new(0, 30, 0.5, 0) -- Move o título para a esquerda quando o menu de mods é aberto
    CreateTween(MenuContainer, {Size = UDim2.new(0, 500, 0, 350)}, 0.3):Play()
    SwitchCategory("Main") -- Abre a primeira categoria por padrão
end)

BackBtn.MouseButton1Click:Connect(function()
    ModMenuBody.Visible = false
    HomeBody.Visible = true
    BackBtn.Visible = false
    Title.Position = UDim2.new(0.5, 0, 0.5, 0)
    CreateTween(MenuContainer, {Size = UDim2.new(0, 360, 0, 250)}, 0.3):Play()
end)

-- Conectar botões de navegação
for name, data in pairs(Categories) do
    data.Button.MouseButton1Click:Connect(function()
        SwitchCategory(name)
    end)
end

-- // FUNCIONALIDADE DE ARRASTAR O MENU //
local dragging = false
local dragStartPos
local menuStartPos

local function startDrag(input)
    if not isMinimized then
        dragging = true
        dragStartPos = UserInputService:GetMouseLocation()
        menuStartPos = MenuContainer.Position
    end
end

local function moveDrag(input)
    if dragging then
        local delta = UserInputService:GetMouseLocation() - dragStartPos
        local newX = menuStartPos.X.Offset + delta.X
        local newY = menuStartPos.Y.Offset + delta.Y
        MenuContainer.Position = UDim2.new(0, newX, 0, newY)
    end
end

local function endDrag()
    dragging = false
end

Header.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
        startDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        moveDrag(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        endDrag()
    end
end)

BallIcon.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent and isMinimized then
        dragging = true
        dragStartPos = UserInputService:GetMouseLocation()
        menuStartPos = MenuContainer.Position
    end
end)

-- Posiciona o menu no centro da tela e depois move para a posição inicial
MenuContainer.Position = UDim2.fromScale(0.5, 0.5)
CreateTween(MenuContainer, {Size = UDim2.new(0, 360, 0, 250), BackgroundTransparency = 0}, 0.5):Play()
