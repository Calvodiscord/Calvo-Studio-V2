--[[
    Script: Calvo Studio (V5 - Corrigido e Aprimorado)
    Autor: Recriado e aprimorado com base na solicitação
    Descrição: GUI com tela de carregamento, menu principal com páginas,
               botões de fechar/minimizar e um painel de opções de modificação (mods) funcional.
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

-- Variáveis de estado para os mods
local isFlying = false
local isNoclipping = false
local isSpeedEnabled = false
local noclipConnection = nil -- Para controlar o loop do noclip

-- Variáveis de configuração dos mods
local originalWalkSpeed = humanoid.WalkSpeed
local flySpeed = 50
local customWalkSpeed = 50

--==================================================================================--
--||                                TELA DE CARREGAMENTO                            ||--
--==================================================================================--

local loadingScreenGui = Instance.new("ScreenGui")
loadingScreenGui.Name = "LoadingScreenGUI"
loadingScreenGui.Parent = playerGui
loadingScreenGui.ResetOnSpawn = false
loadingScreenGui.DisplayOrder = 1000

local loadingBackground = Instance.new("CanvasGroup")
loadingBackground.Name = "Background"
loadingBackground.Parent = loadingScreenGui
loadingBackground.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
loadingBackground.Size = UDim2.new(1, 0, 1, 0)

local loadingTitle = Instance.new("TextLabel", loadingBackground)
loadingTitle.Font = Enum.Font.GothamSemibold
loadingTitle.Text = "Calvo Studio"
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.TextSize = 52
loadingTitle.BackgroundTransparency = 1
loadingTitle.Size = UDim2.new(0.8, 0, 0.2, 0)
loadingTitle.Position = UDim2.new(0.5, 0, 0.35, 0)
loadingTitle.AnchorPoint = Vector2.new(0.5, 0.5)

local progressBarBackground = Instance.new("Frame", loadingBackground)
progressBarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
progressBarBackground.BorderSizePixel = 0
progressBarBackground.Size = UDim2.new(0.5, 0, 0, 20)
progressBarBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
progressBarBackground.AnchorPoint = Vector2.new(0.5, 0.5)
Instance.new("UICorner", progressBarBackground).CornerRadius = UDim.new(1, 0)

local progressBarFill = Instance.new("Frame", progressBarBackground)
progressBarFill.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
progressBarFill.BorderSizePixel = 0
progressBarFill.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", progressBarFill).CornerRadius = UDim.new(1, 0)

local loadingText = Instance.new("TextLabel", loadingBackground)
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

local mainFrame = Instance.new("Frame", mainGui)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0, 320, 0, 420)
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

-- --- NOVO: Botões de Controle da Janela (Fechar e Minimizar) ---
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
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.TextScaled = true
    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
    return button
end

local minimizeButton = createControlButton("_", Color3.fromRGB(255, 189, 89), "MinimizeButton")
local closeButton = createControlButton("X", Color3.fromRGB(255, 89, 89), "CloseButton")


local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.BackgroundTransparency = 1
contentContainer.Size = UDim2.new(1, 0, 1, -40)
contentContainer.Position = UDim2.new(0, 0, 0, 40)
contentContainer.ClipsDescendants = true

local mainPage = Instance.new("Frame", contentContainer)
mainPage.BackgroundTransparency = 1
mainPage.Size = UDim2.new(1, 0, 1, 0)
local mainPageLayout = Instance.new("UIListLayout", mainPage)
mainPageLayout.Padding = UDim.new(0, 15)
mainPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainPageLayout.VerticalAlignment = Enum.VerticalAlignment.Center
mainPageLayout.SortOrder = Enum.SortOrder.LayoutOrder

local modsPage = Instance.new("Frame", contentContainer)
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

local function createButton(parent, text, layoutOrder)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Name = text:gsub("%s", "") .. "Button"
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    button.Size = UDim2.new(0.8, 0, 0, 45)
    button.Font = Enum.Font.GothamSemibold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 16
    button.LayoutOrder = layoutOrder
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 95)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play()
    end)
    
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
        if state then
            button.Text = text .. " [ON]"
            button.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            button.Text = text .. " [OFF]"
            button.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
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
	track.BorderSizePixel = 0
	track.Size = UDim2.new(1, 0, 0, 8)
	track.Position = UDim2.new(0, 0, 0.75, 0)
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", track)
	fill.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local dragger = Instance.new("TextButton", track) -- Usar TextButton para melhor captura de input
	dragger.Size = UDim2.new(1, 0, 3, 0) -- Área de arrastar maior
	dragger.Position = UDim2.new(0.5, 0, 0.5, 0)
	dragger.AnchorPoint = Vector2.new(0.5, 0.5)
	dragger.BackgroundTransparency = 1
	dragger.Text = ""

	local function updateSlider(value)
		local clampedValue = math.clamp(value, min, max)
		local percentage = (clampedValue - min) / (max - min)
		fill.Size = UDim2.new(percentage, 0, 1, 0)
		valueLabel.Text = tostring(math.floor(clampedValue))
		if callback then
			callback(clampedValue)
		end
	end
	updateSlider(initialValue)

	dragger.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local function updateFromInput()
				local mousePos = UserInputService:GetMouseLocation()
				local relativeX = mousePos.X - track.AbsolutePosition.X
				local percentage = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
				local newValue = min + (max - min) * percentage
				updateSlider(newValue)
			end
			
			updateFromInput() -- Atualiza no primeiro clique

			local moveConnection
			moveConnection = UserInputService.InputChanged:Connect(function(inputObj)
				if inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch then
					updateFromInput()
				end
			end)
			
			local releaseConnection
			releaseConnection = UserInputService.InputEnded:Connect(function(inputObj)
				if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
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

local modMenuButton = createButton(mainPage, "Mod Menu", 1)
local discordButton = createButton(mainPage, "Discord", 2)
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordButton.MouseEnter:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 137, 218)}):Play()
end)
discordButton.MouseLeave:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
end)

local flyButton = createModButton(modsPage, "Fly", 1)
createSlider(modsPage, "Fly Speed", 1, 100, flySpeed, 2, function(value)
    flySpeed = value
end)

local noclipButton = createModButton(modsPage, "Atravessar Parede", 3)

local speedButton = createModButton(modsPage, "Speed", 4)
createSlider(modsPage, "Walk Speed", originalWalkSpeed, 100, customWalkSpeed, 5, function(value)
    customWalkSpeed = value
    if isSpeedEnabled then
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
    local tween = TweenService:Create(progressBarFill, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    tween:Play()
    tween.Completed:Wait()
    
    loadingText.Text = "Pronto!"
    task.wait(0.5)
    
    local fadeOutTween = TweenService:Create(loadingBackground, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {GroupTransparency = 1})
    fadeOutTween:Play()
    fadeOutTween.Completed:Wait()

    loadingScreenGui:Destroy()
    mainGui.Enabled = true
    print("Calvo Studio GUI carregado com sucesso!")
end

-- LÓGICA DA JANELA E NAVEGAÇÃO
closeButton.MouseButton1Click:Connect(function()
    mainGui.Enabled = false
end)

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    contentContainer.Visible = not isMinimized
    
    local sizeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local targetSize
    if isMinimized then
		targetSize = UDim2.new(0, mainFrame.Size.X.Offset, 0, titleBar.Size.Y.Offset)
    else
        targetSize = UDim2.new(0, 320, 0, 420)
    end
	TweenService:Create(mainFrame, sizeInfo, {Size = targetSize}):Play()
end)

modMenuButton.MouseButton1Click:Connect(function()
    mainPage.Visible = false
    modsPage.Visible = true
end)

backButton.MouseButton1Click:Connect(function()
    modsPage.Visible = false
    mainPage.Visible = true
end)

discordButton.MouseButton1Click:Connect(function()
    print("Botão do Discord clicado!")
    -- setclipboard("SEU_LINK_AQUI") -- Descomente se tiver permissão
end)

-- LÓGICA DOS MODS (CORRIGIDA)

-- --- Lógica do Fly ---
local flyGyro, flyVelocity
flyButton.Activated:Connect(function()
    isFlying = not isFlying
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    if isFlying then
        flyGyro = Instance.new("BodyGyro")
        flyGyro.P = 50000
        flyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        flyGyro.CFrame = rootPart.CFrame
        flyGyro.Parent = rootPart

        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Velocity = Vector3.new()
        flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyVelocity.Parent = rootPart
        
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    else
        if flyGyro then flyGyro:Destroy() end
        if flyVelocity then flyVelocity:Destroy() end
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

-- --- Lógica do Speed ---
speedButton.Activated:Connect(function()
    isSpeedEnabled = not isSpeedEnabled
    if isSpeedEnabled then
        humanoid.WalkSpeed = customWalkSpeed
    else
        humanoid.WalkSpeed = originalWalkSpeed
    end
end)

-- --- Lógica do Noclip ---
noclipButton.Activated:Connect(function()
    isNoclipping = not isNoclipping
    if isNoclipping then
        -- Conecta a função ao evento Stepped para desativar colisão continuamente
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        -- Desconecta a função e reativa a colisão
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)


-- --- Loop principal para mods que precisam de atualização constante (Fly) ---
RunService.RenderStepped:Connect(function()
    if isFlying and flyVelocity and flyGyro then
        local direction = Vector3.new()
        local camera = workspace.CurrentCamera
		
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = -camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = -camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = camera.CFrame.RightVector end
		
		local verticalDirection = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then verticalDirection = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then verticalDirection = -1 end
		
		local combinedDirection = (direction.Unit * Vector3.new(1, 0, 1)).Unit + Vector3.new(0, verticalDirection, 0)

        flyVelocity.Velocity = combinedDirection * flySpeed
        flyGyro.CFrame = camera.CFrame
    end
end)


-- Inicia todo o processo
StartLoading()
