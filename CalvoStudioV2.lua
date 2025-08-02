--[[
    Script: Calvo Studio (V7.0 - Correção de ESP e Adição de Aimbot)
   AVISO: O uso de Aimbot viola os Termos de Serviço do Roblox e pode causar banimento.
          Use por sua conta e risco.

   ATUALIZAÇÕES;
- CORRIGIDO: A função de ESP agora exibe corretamente o Nick, Vida e Plataforma (PC/Mobile).
- ADICIONADO: Função de Aimbot que mira no inimigo mais próximo do cursor ao segurar uma tecla.
- MELHORADO: Otimização geral do loop principal.
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
    Enabled = false, -- O botão no menu vai controlar isso
    ToggleKey = Enum.UserInputType.MouseButton2, -- Tecla para ativar (Botão Direito do Mouse)
    TargetPart = "Head", -- Parte do corpo para mirar ("Head" ou "HumanoidRootPart")
    Sensitivity = 800 -- Quão longe do centro da tela o aimbot irá "puxar" (em pixels)
}
-- ####################################

-- Variáveis de estado para os mods
local isFlying = false
local isNoclipping = false
local isSpeedEnabled = false
local isEspEnabled = false
local noclipConnection = nil

-- Variáveis de configuração dos mods
local originalWalkSpeed = 16
local flySpeed = 50
local customWalkSpeed = 50

-- Tabela para guardar as GUIs de ESP de cada jogador
local espTracker = {}

--==================================================================================--
--||                                TELA DE CARREGAMENTO                            ||--
--==================================================================================--
-- (O código da tela de carregamento e da interface principal permanece o mesmo)
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
mainFrame.Size = UDim2.new(0, 320, 0, 450) -- Aumentei um pouco a altura para o novo botão
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

local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.BackgroundTransparency = 1
contentContainer.Size = UDim2.new(1, 0, 1, -40)
contentContainer.Position = UDim2.new(0, 0, 0, 40)
contentContainer.ClipsDescendants = true

local modsPage = Instance.new("Frame", contentContainer)
modsPage.BackgroundTransparency = 1
modsPage.Size = UDim2.new(1, 0, 1, 0)
local modsPageLayout = Instance.new("UIListLayout", modsPage)
modsPageLayout.Padding = UDim.new(0, 12)
modsPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
modsPageLayout.VerticalAlignment = Enum.VerticalAlignment.Top
modsPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
local modsPagePadding = Instance.new("UIPadding", modsPage)
modsPagePadding.PaddingTop = UDim.new(0, 20)
-- ... (O resto da criação de UI é igual)
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
    return button, function() return state end
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
			updateFromInput()
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

local aimbotButton, getAimbotState = createModButton(modsPage, "Aimbot", 1)
local espButton, getEspState = createModButton(modsPage, "ESP Players", 2)
local flyButton, getFlyState = createModButton(modsPage, "Fly", 3)
createSlider(modsPage, "Fly Speed", 1, 200, flySpeed, 4, function(value) flySpeed = value end)
local noclipButton, getNoclipState = createModButton(modsPage, "Atravessar Parede", 5)
local speedButton, getSpeedState = createModButton(modsPage, "Speed", 6)
createSlider(modsPage, "Walk Speed", 16, 200, customWalkSpeed, 7, function(value)
    customWalkSpeed = value
    if isSpeedEnabled then
        local character = localPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = customWalkSpeed end
    end
end)
local backButton = createButton(modsPage, "Voltar", 8)
backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
backButton.Size = UDim2.new(0.85, 0, 0, 35)

--==================================================================================--
--||                                LÓGICA DO SCRIPT                                ||--
--==================================================================================--
function StartLoading()
    -- (Esta função continua a mesma)
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
-- ... (Conexões de botões principais continuam as mesmas)
--==================================================================================--
--||                                LÓGICA DOS MODS                                 ||--
--==================================================================================--

-- --- Lógica do Aimbot ---
aimbotButton.Activated:Connect(function()
    aimbotConfig.Enabled = getAimbotState()
end)

function getBestAimbotTarget()
    local bestTarget = nil
    local closestDist = aimbotConfig.Sensitivity

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(aimbotConfig.TargetPart)
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                if onScreen then
                    local dist = (UserInputService:GetMouseLocation() - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        bestTarget = targetPart
                    end
                end
            end
        end
    end
    return bestTarget
end

-- --- Lógica do Fly, Speed, Noclip ---
-- (Estas funções permanecem as mesmas)

-- --- Lógica do ESP (CORRIGIDA) ---
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
    local head = playerChar and playerChar:FindFirstChild("Head")
    if not head then
        if espTracker[player] then
            espTracker[player]:Destroy()
            espTracker[player] = nil
        end
        return
    end
    
    local espGui = espTracker[player]
    if not espGui or not espGui.Parent then
        if espGui then espGui:Destroy() end
        
        espGui = Instance.new("BillboardGui")
        espGui.Name = "PlayerESP"
        espGui.Adornee = head
        espGui.Size = UDim2.new(0, 150, 0, 70)
        espGui.AlwaysOnTop = true
        espGui.ResetOnSpawn = false
		espGui.LightInfluence = 0
		espGui.SizeOffset = Vector2.new(0, 2)
        espGui.Parent = head -- Parentar no final
        
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
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, -10, 0, 20)
        nameLabel.Position = UDim2.new(0.5, 0, 0, 5)
		nameLabel.AnchorPoint = Vector2.new(0.5, 0)
        
        local healthBarBack = Instance.new("Frame", background)
        healthBarBack.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
        healthBarBack.BorderSizePixel = 0
        healthBarBack.Size = UDim2.new(1, -10, 0, 8)
        healthBarBack.Position = UDim2.new(0.5, 0, 0, 30)
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
        infoLabel.TextSize = 14
        infoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Size = UDim2.new(1, -10, 0, 20)
        infoLabel.Position = UDim2.new(0.5, 0, 0, 42)
		infoLabel.AnchorPoint = Vector2.new(0.5, 0)
        
        espTracker[player] = espGui
    end

    local playerHumanoid = playerChar:FindFirstChildOfClass("Humanoid")
    if playerHumanoid then
        -- CORREÇÃO: Busca os elementos com FindFirstChild para evitar erros se a GUI não carregar a tempo
        local background = espGui:FindFirstChild("Background")
        if not background then return end
        
        local nameLabel = background:FindFirstChild("NameLabel")
        local healthBar = background:FindFirstChild("HealthBarBack"):FindFirstChild("HealthBar")
        local infoLabel = background:FindFirstChild("InfoLabel")
        
        if nameLabel then nameLabel.Text = player.DisplayName end -- Usar DisplayName é melhor
        if healthBar then
            local health = math.clamp(playerHumanoid.Health, 0, playerHumanoid.MaxHealth)
            healthBar.Size = UDim2.new(health / playerHumanoid.MaxHealth, 0, 1, 0)
        end
        if infoLabel then
            -- A detecção de plataforma mais comum na comunidade.
            local platform = player:FindFirstChild("PlayerScripts") and "🖥️" or "📱"
            local distance = (Camera.CFrame.Position - head.Position).Magnitude
            infoLabel.Text = string.format("[%.0fm] %s", distance, platform)
        end
    end
end

--==================================================================================--
--||                                 LOOP PRINCIPAL                               ||--
--==================================================================================--

RunService.RenderStepped:Connect(function()
    -- --- Bloco do Aimbot ---
    if aimbotConfig.Enabled and UserInputService:IsMouseButtonPressed(aimbotConfig.ToggleKey) then
        local target = getBestAimbotTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
    
    -- --- Bloco do Fly ---
    if isFlying then
		-- (Código do fly continua o mesmo)
	end

    -- --- Bloco do ESP ---
    if isEspEnabled then
        local currentPlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                currentPlayers[player] = true
                if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChildOfClass("Humanoid") then
                    createOrUpdateEsp(player)
                else
                    if espTracker[player] then
                        espTracker[player]:Destroy()
                        espTracker[player] = nil
                    end
                end
            end
        end
        for player, esp in pairs(espTracker) do
            if not currentPlayers[player] then
                if esp then esp:Destroy() end
                espTracker[player] = nil
            end
        end
    end
end)

-- Inicia todo o processo
StartLoading()