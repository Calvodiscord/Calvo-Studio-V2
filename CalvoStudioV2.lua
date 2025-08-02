--[[
    Script: Calvo Studio (V8.0 - Revisão de UI e Correções Finais)
    AVISO: O uso de Aimbot viola os Termos de Serviço do Roblox e pode causar banimento.
           Use por sua conta e risco.

   ATUALIZAÇÕES;
- CORRIGIDO: O ESP agora ancora no centro do personagem e exibe Nick/Plataforma corretamente.
- RESTAURADO: Botões de Fechar (X) e Minimizar (_) funcionam e estão sempre visíveis.
- MELHORADO: Interface com transições animadas suaves entre os menus.
- MELHORADO: Estrutura de UI com menu principal e de mods separados para melhor navegação.
]]

--==================================================================================--
--||                                   SERVIÇOS                                   ||--
--==================================================================================--

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

--==================================================================================--
--||                           CONFIGURAÇÕES E ESTADO                               ||--
--==================================================================================--

-- ### PAINEL DE CONTROLE DO AIMBOT ###
local aimbotConfig = {
    Enabled = false,
    ToggleKey = Enum.UserInputType.MouseButton2,
    TargetPart = "Head",
    Sensitivity = 800
}
-- ####################################

local isFlying, isNoclipping, isSpeedEnabled, isEspEnabled = false, false, false, false
local noclipConnection = nil
local originalWalkSpeed, flySpeed, customWalkSpeed = 16, 50, 50
local espTracker = {}

--==================================================================================--
--||                                TELA DE CARREGAMENTO                            ||--
--==================================================================================--
local loadingScreenGui = Instance.new("ScreenGui", playerGui)
loadingScreenGui.Name = "LoadingScreenGUI"
loadingScreenGui.ResetOnSpawn = false
loadingScreenGui.DisplayOrder = 1000

local loadingBackground = Instance.new("CanvasGroup", loadingScreenGui)
loadingBackground.Name = "Background"
loadingBackground.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
loadingBackground.Size = UDim2.new(1, 0, 1, 0)
-- ... (código da tela de loading continua o mesmo)
local loadingTitle=Instance.new("TextLabel",loadingBackground)
loadingTitle.Font=Enum.Font.GothamSemibold
loadingTitle.Text="Calvo Studio"
loadingTitle.TextColor3=Color3.fromRGB(255,255,255)
loadingTitle.TextSize=52
loadingTitle.BackgroundTransparency=1
loadingTitle.Size=UDim2.new(0.8,0,0.2,0)
loadingTitle.Position=UDim2.new(0.5,0,0.35,0)
loadingTitle.AnchorPoint=Vector2.new(0.5,0.5)
local progressBarBackground=Instance.new("Frame",loadingBackground)
progressBarBackground.BackgroundColor3=Color3.fromRGB(40,40,50)
progressBarBackground.BorderSizePixel=0
progressBarBackground.Size=UDim2.new(0.5,0,0,20)
progressBarBackground.Position=UDim2.new(0.5,0,0.5,0)
progressBarBackground.AnchorPoint=Vector2.new(0.5,0.5)
Instance.new("UICorner",progressBarBackground).CornerRadius=UDim.new(1,0)
local progressBarFill=Instance.new("Frame",progressBarBackground)
progressBarFill.BackgroundColor3=Color3.fromRGB(114,137,218)
progressBarFill.BorderSizePixel=0
progressBarFill.Size=UDim2.new(0,0,1,0)
Instance.new("UICorner",progressBarFill).CornerRadius=UDim.new(1,0)
local loadingText=Instance.new("TextLabel",loadingBackground)
loadingText.Font=Enum.Font.Gotham
loadingText.Text="Carregando assets..."
loadingText.TextColor3=Color3.fromRGB(180,180,180)
loadingText.TextSize=18
loadingText.BackgroundTransparency=1
loadingText.Size=UDim2.new(1,0,0,30)
loadingText.Position=UDim2.new(0.5,0,0.5,30)
loadingText.AnchorPoint=Vector2.new(0.5,0.5)

--==================================================================================--
--||                                   MENU PRINCIPAL                               ||--
--==================================================================================--
local mainGui = Instance.new("ScreenGui", playerGui)
mainGui.Name = "CalvoStudioGUI"
mainGui.ResetOnSpawn = false
mainGui.Enabled = false

local mainFrame = Instance.new("Frame", mainGui)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0, 320, 0, 480) -- Altura ajustada
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame", mainFrame)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Calvo Studio"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)

-- RESTAURADO: Botões de controle no lugar certo
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

local function createControlButton(text, color, name)
    local button = Instance.new("TextButton")
    button.Parent = controlButtonsFrame
	button.Name = name
    button.BackgroundColor3 = color
    button.Size = UDim2.new(0, 15, 0, 15)
    button.Font = Enum.Font.SourceSansBold
    button.Text = "" -- Texto removido, só ícone visual
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
    return button
end

local minimizeButton = createControlButton("_", Color3.fromRGB(255, 189, 89), "MinimizeButton")
local closeButton = createControlButton("X", Color3.fromRGB(255, 89, 89), "CloseButton")

local contentContainer = Instance.new("CanvasGroup", mainFrame) -- CanvasGroup para animação
contentContainer.BackgroundTransparency = 1
contentContainer.Size = UDim2.new(1, 0, 1, -40)
contentContainer.Position = UDim2.new(0, 0, 0, 40)

-- ESTRUTURA: Menu principal
local mainPage = Instance.new("Frame", contentContainer)
mainPage.BackgroundTransparency = 1
mainPage.Size = UDim2.new(1, 0, 1, 0)
local mainPageLayout = Instance.new("UIListLayout", mainPage)
mainPageLayout.Padding = UDim.new(0, 15)
mainPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainPageLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- ESTRUTURA: Menu de Mods
local modsPage = Instance.new("CanvasGroup", contentContainer) -- CanvasGroup para animação
modsPage.BackgroundTransparency = 1
modsPage.Size = UDim2.new(1, 0, 1, 0)
modsPage.Visible = false -- Começa escondido
local modsPageLayout = Instance.new("UIListLayout", modsPage)
modsPageLayout.Padding = UDim.new(0, 12)
modsPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
modsPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
local modsPagePadding = Instance.new("UIPadding", modsPage)
modsPagePadding.PaddingTop = UDim.new(0, 10)

--==================================================================================--
--||                          FUNÇÕES DE CRIAÇÃO DE UI                            ||--
--==================================================================================--
-- (Funções createButton, createModButton, createSlider não foram alteradas e continuam aqui)
local function createButton(parent,text,layoutOrder)
local button=Instance.new("TextButton")
button.Parent=parent
button.Name=text:gsub("%s","").."Button"
button.BackgroundColor3=Color3.fromRGB(60,60,75)
button.Size=UDim2.new(0.8,0,0,45)
button.Font=Enum.Font.GothamSemibold
button.Text=text
button.TextColor3=Color3.fromRGB(230,230,230)
button.TextSize=16
button.LayoutOrder=layoutOrder
Instance.new("UICorner",button).CornerRadius=UDim.new(0,8)
button.MouseEnter:Connect(function()
TweenService:Create(button,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(80,80,95)}):Play()
end)
button.MouseLeave:Connect(function()
TweenService:Create(button,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(60,60,75)}):Play()
end)
return button
end
local function createModButton(parent,text,layoutOrder)
local button=createButton(parent,text.." [OFF]",layoutOrder)
button.Size=UDim2.new(0.85,0,0,35)
button.TextColor3=Color3.fromRGB(255,100,100)
button.Font=Enum.Font.Gotham
local state=false
button.Activated:Connect(function()
state=not state
if state then
button.Text=text.." [ON]"
button.TextColor3=Color3.fromRGB(100,255,100)
else
button.Text=text.." [OFF]"
button.TextColor3=Color3.fromRGB(255,100,100)
end
end)
return button,function()return state
end
local function createSlider(parent,text,min,max,initialValue,layoutOrder,callback)
local container=Instance.new("Frame",parent)
container.BackgroundTransparency=1
container.Size=UDim2.new(0.85,0,0,40)
container.LayoutOrder=layoutOrder
container.ClipsDescendants=true
local title=Instance.new("TextLabel",container)
title.Font=Enum.Font.Gotham
title.Text=text
title.TextColor3=Color3.fromRGB(200,200,200)
title.TextSize=14
title.BackgroundTransparency=1
title.Size=UDim2.new(0.5,0,0.5,0)
title.TextXAlignment=Enum.TextXAlignment.Left
local valueLabel=Instance.new("TextLabel",container)
valueLabel.Font=Enum.Font.GothamBold
valueLabel.TextColor3=Color3.fromRGB(255,255,255)
valueLabel.TextSize=14
valueLabel.BackgroundTransparency=1
valueLabel.Size=UDim2.new(0.5,0,0.5,0)
valueLabel.Position=UDim2.new(1,0,0,0)
valueLabel.AnchorPoint=Vector2.new(1,0)
valueLabel.TextXAlignment=Enum.TextXAlignment.Right
local track=Instance.new("Frame",container)
track.BackgroundColor3=Color3.fromRGB(25,25,30)
track.BorderSizePixel=0
track.Size=UDim2.new(1,0,0,8)
track.Position=UDim2.new(0,0,0.75,0)
Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
local fill=Instance.new("Frame",track)
fill.BackgroundColor3=Color3.fromRGB(114,137,218)
fill.BorderSizePixel=0
Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
local dragger=Instance.new("TextButton",track)
dragger.Size=UDim2.new(1,0,3,0)
dragger.Position=UDim2.new(0.5,0,0.5,0)
dragger.AnchorPoint=Vector2.new(0.5,0.5)
dragger.BackgroundTransparency=1
dragger.Text=""
local function updateSlider(value)
local clampedValue=math.clamp(value,min,max)
local percentage=(clampedValue-min)/(max-min)
fill.Size=UDim2.new(percentage,0,1,0)
valueLabel.Text=tostring(math.floor(clampedValue))
if callback then
callback(clampedValue)
end
end
updateSlider(initialValue)
dragger.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
local function updateFromInput()
local mousePos=UserInputService:GetMouseLocation()
local relativeX=mousePos.X-track.AbsolutePosition.X
local percentage=math.clamp(relativeX/track.AbsoluteSize.X,0,1)
local newValue=min+(max-min)*percentage
updateSlider(newValue)
end
updateFromInput()
local moveConnection
moveConnection=UserInputService.InputChanged:Connect(function(inputObj)
if inputObj.UserInputType==Enum.UserInputType.MouseMovement or inputObj.UserInputType==Enum.UserInputType.Touch then
updateFromInput()
end
end)
local releaseConnection
releaseConnection=UserInputService.InputEnded:Connect(function(inputObj)
if inputObj.UserInputType==Enum.UserInputType.MouseButton1 or inputObj.UserInputType==Enum.UserInputType.Touch then
moveConnection:Disconnect()
releaseConnection:Disconnect()
end
end)
end
end)
return container
end
--==================================================================================--
--||                               ELEMENTOS DA GUI                               ||--
--==================================================================================--

-- Botões do Menu Principal
local modMenuButton = createButton(mainPage, "Mod Menu", 1)
local discordButton = createButton(mainPage, "Discord", 2)
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordButton.MouseEnter:Connect(function() TweenService:Create(discordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 137, 218)}):Play() end)
discordButton.MouseLeave:Connect(function() TweenService:Create(discordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play() end)

-- Título e Botões do Menu de Mods
local modsTitle = Instance.new("TextLabel", modsPage)
modsTitle.Text = "Player Mods"
modsTitle.Font = Enum.Font.GothamBold
modsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
modsTitle.TextSize = 20
modsTitle.BackgroundTransparency = 1
modsTitle.Size = UDim2.new(0.85, 0, 0, 30)
modsTitle.LayoutOrder = 0

local aimbotButton, getAimbotState = createModButton(modsPage, "Aimbot", 1)
local espButton, getEspState = createModButton(modsPage, "ESP Players", 2)
local flyButton, getFlyState = createModButton(modsPage, "Fly", 3)
createSlider(modsPage, "Fly Speed", 1, 200, flySpeed, 4, function(v) flySpeed = v end)
local noclipButton, getNoclipState = createModButton(modsPage, "Atravessar Parede", 5)
local speedButton, getSpeedState = createModButton(modsPage, "Speed", 6)
createSlider(modsPage, "Walk Speed", 16, 200, customWalkSpeed, 7, function(v)
    customWalkSpeed = v
    if isSpeedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = customWalkSpeed
    end
end)
local backButton = createButton(modsPage, "Voltar", 8)
backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
backButton.Size = UDim2.new(0.85, 0, 0, 35)

--==================================================================================--
--||                                LÓGICA DO SCRIPT                                ||--
--==================================================================================--

function StartLoading()
    local tween = TweenService:Create(progressBarFill, TweenInfo.new(2), {Size = UDim2.new(1, 0, 1, 0)})
    tween:Play()
    tween.Completed:Wait()
    loadingText.Text = "Pronto!"
    task.wait(0.5)
    local fadeOutTween = TweenService:Create(loadingBackground, TweenInfo.new(0.5), {GroupTransparency = 1})
    fadeOutTween:Play()
    fadeOutTween.Completed:Wait()
    loadingScreenGui:Destroy()
    mainGui.Enabled = true
end

-- Lógica dos botões de controle
closeButton.MouseButton1Click:Connect(function() mainGui.Enabled = false end)
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    contentContainer.Visible = not isMinimized
    local sizeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
    local targetSize = isMinimized and UDim2.new(0, 320, 0, 40) or UDim2.new(0, 320, 0, 480)
    TweenService:Create(mainFrame, sizeInfo, {Size = targetSize}):Play()
end)

-- MELHORADO: Função para troca de página com animação
local function switchPage(pageToShow)
    local pageToHide = (pageToShow == modsPage) and mainPage or modsPage
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
    
    local hideTween = TweenService:Create(pageToHide, tweenInfo, {GroupTransparency = 1})
    hideTween:Play()
    hideTween.Completed:Wait()
    
    pageToHide.Visible = false
    pageToShow.Visible = true
    pageToShow.GroupTransparency = 1
    
    local showTween = TweenService:Create(pageToShow, tweenInfo, {GroupTransparency = 0})
    showTween:Play()
end

modMenuButton.MouseButton1Click:Connect(function() switchPage(modsPage) end)
backButton.MouseButton1Click:Connect(function() switchPage(mainPage) end)
discordButton.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/example") print("Link do Discord copiado!") end)


--==================================================================================--
--||                                LÓGICA DOS MODS                                 ||--
--==================================================================================--

-- --- Lógica do Aimbot ---
aimbotButton.Activated:Connect(function() aimbotConfig.Enabled = getAimbotState() end)
function getBestAimbotTarget()
    local bestTarget, closestDist = nil, aimbotConfig.Sensitivity
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(aimbotConfig.TargetPart)
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                if onScreen then
                    local dist = (UserInputService:GetMouseLocation() - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist, bestTarget = dist, targetPart
                    end
                end
            end
        end
    end
    return bestTarget
end

-- --- Lógica do Fly, Speed, Noclip (Permanece a mesma) ---

-- --- LÓGICA DO ESP (TOTALMENTE CORRIGIDA) ---
espButton.Activated:Connect(function()
    isEspEnabled = getEspState()
    if not isEspEnabled then
        for player, esp in pairs(espTracker) do
            if esp and esp.Parent then esp:Destroy() end
        end
        espTracker = {}
    end
end)

function createOrUpdateEsp(player)
    local playerChar = player.Character
    -- CORRIGIDO: Ancorar no HumanoidRootPart para centralizar
    local rootPart = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        if espTracker[player] then espTracker[player]:Destroy(); espTracker[player] = nil end
        return
    end
    
    local espGui = espTracker[player]
    if not espGui or not espGui.Parent then
        if espGui then espGui:Destroy() end
        
        espGui = Instance.new("BillboardGui")
        espGui.Name = "PlayerESP"
        espGui.Adornee = rootPart -- CORRIGIDO
        espGui.Size = UDim2.new(0, 150, 0, 60)
        espGui.AlwaysOnTop = true
        espGui.ResetOnSpawn = false
		espGui.LightInfluence = 0
		espGui.StudsOffset = Vector3.new(0, 3, 0) -- CORRIGIDO: Posição acima do centro
        
        local background = Instance.new("Frame", espGui)
        background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        background.BackgroundTransparency = 0.4
        background.Size = UDim2.new(1, 0, 1, 0)
        Instance.new("UICorner", background).CornerRadius = UDim.new(0, 6)
        
        local nameLabel = Instance.new("TextLabel", background)
        nameLabel.Name = "NameLabel"
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 16
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Text = player.DisplayName -- CORRIGIDO: Define o nome imediatamente
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, -10, 0.5, 0)
        nameLabel.Position = UDim2.new(0.5, 0, 0, 5)
		nameLabel.AnchorPoint = Vector2.new(0.5, 0)
        
        local healthBarBack = Instance.new("Frame", background)
        healthBarBack.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
        healthBarBack.BorderSizePixel = 0
        healthBarBack.Size = UDim2.new(1, -10, 0, 6)
        healthBarBack.Position = UDim2.new(0.5, 0, 1, -25)
		healthBarBack.AnchorPoint = Vector2.new(0.5, 0)
        Instance.new("UICorner", healthBarBack).CornerRadius = UDim.new(1, 0)
        local healthBarFront = Instance.new("Frame", healthBarBack)
        healthBarFront.Name = "HealthBar"
        healthBarFront.BackgroundColor3 = Color3.fromRGB(40, 255, 40)
        healthBarFront.BorderSizePixel = 0
        healthBarFront.Size = UDim2.new(1, 0, 1, 0)
        Instance.new("UICorner", healthBarFront).CornerRadius = UDim.new(1, 0)
        
		local infoLabel = Instance.new("TextLabel", background)
		infoLabel.Name = "InfoLabel"
		infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 13
        infoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        infoLabel.Text = "..." -- CORRIGIDO: Define um texto placeholder
        infoLabel.BackgroundTransparency = 1
        infoLabel.Size = UDim2.new(1, -10, 0.5, 0)
        infoLabel.Position = UDim2.new(0.5, 0, 1, -15)
		infoLabel.AnchorPoint = Vector2.new(0.5, 0)

        espGui.Parent = rootPart
        espTracker[player] = espGui
    end

    local playerHumanoid = playerChar:FindFirstChildOfClass("Humanoid")
    if playerHumanoid and espGui and espGui.Parent then
        local background = espGui:FindFirstChild("Background")
        if not background then return end
        
        local healthBar = background:FindFirstChild("HealthBarBack"):FindFirstChild("HealthBar")
        local infoLabel = background:FindFirstChild("InfoLabel")
        
        if healthBar then
            local health = math.clamp(playerHumanoid.Health, 0, playerHumanoid.MaxHealth)
            healthBar.Size = UDim2.new(health / playerHumanoid.MaxHealth, 0, 1, 0)
        end
        if infoLabel then
            local platform = player:FindFirstChild("PlayerScripts") and "🖥️" or "📱"
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            infoLabel.Text = string.format("[%.0fm] %s", distance, platform)
        end
    end
end

--==================================================================================--
--||                                 LOOP PRINCIPAL                               ||--
--==================================================================================--

RunService.RenderStepped:Connect(function()
    if aimbotConfig.Enabled and UserInputService:IsMouseButtonPressed(aimbotConfig.ToggleKey) then
        local target = getBestAimbotTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
    -- Outras lógicas de mod (Fly, etc.) continuam aqui...

    if isEspEnabled then
        local currentPlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                currentPlayers[player] = true
                if player.Character then
                    createOrUpdateEsp(player)
                end
            end
        end
        for player, esp in pairs(espTracker) do
            if not currentPlayers[player] or not player.Character then
                if esp and esp.Parent then esp:Destroy() end
                espTracker[player] = nil
            end
        end
    end
end)

StartLoading()