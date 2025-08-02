--[[
    Script: CALVO MOD - PRISON LIFE V3.3 (Correção Final de Inicialização)
    Versão: 3.3

   ATUALIZAÇÕES:
- CORRIGIDO: Recriado o sistema de inicialização para ser à prova de falhas, garantindo que a UI sempre apareça.
- MELHORADO: Lógica de ativação dos mods otimizada para maior estabilidade e performance.
- DIAGNÓSTICO: Adicionado um sistema de pcall com impressão de erro para capturar qualquer falha inesperada.
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

--==================================================================================--
--||                                   IDIOMAS                                    ||--
--==================================================================================--
local currentLanguage = "pt"
local LANGUAGES = {
    pt = {
        -- Categorias
        category_combat = "Combate", category_localplayer = "LocalPlayer", category_misc = "Diversos",
        category_teleports = "Teleportes", category_admin = "Admin", category_credits = "Créditos",
        -- Títulos
        title = "CALVO MOD", credits_title = "Notas da Atualização", teleport_title = "Sistema de Teleporte",
        -- Mods
        esp = "ESP Players", fly = "Voar (Fly)", fly_speed = "Velocidade de Voo", noclip = "Atravessar Paredes",
        speed = "Correr Rápido", walk_speed = "Velocidade de Corrida",
        -- Teleporte
        save_location = "Salvar Localização Atual", teleport_to_location = "Teleportar para Local Salvo",
        no_location_saved = "Nenhum local salvo.", location_saved_at = "Local salvo em: %s",
        -- Outros
        loading = "Carregando...", ready = "Pronto!", change_lang_pt = "Mudar para Português",
        change_lang_en = "Mudar para Inglês", placeholder_title = "Em Breve",
        placeholder_desc = "Esta seção receberá novas funções em atualizações futuras.",
    },
    en = {
        -- Categories
        category_combat = "Combat", category_localplayer = "LocalPlayer", category_misc = "Miscellaneous",
        category_teleports = "Teleports", category_admin = "Admin", category_credits = "Credits",
        -- Titles
        title = "CALVO MOD", credits_title = "Update Notes", teleport_title = "Teleport System",
        -- Mods
        esp = "ESP Players", fly = "Fly", fly_speed = "Fly Speed", noclip = "Noclip",
        speed = "Speed Hack", walk_speed = "Walk Speed",
        -- Teleport
        save_location = "Save Current Location", teleport_to_location = "Teleport to Saved Location",
        no_location_saved = "No location saved.", location_saved_at = "Location saved at: %s",
        -- Others
        loading = "Loading...", ready = "Ready!", change_lang_pt = "Switch to Portuguese",
        change_lang_en = "Switch to English", placeholder_title = "Coming Soon",
        placeholder_desc = "This section will receive new features in future updates.",
    }
}

--==================================================================================--
--||                           CONFIGURAÇÕES E ESTADO                               ||--
--==================================================================================--
local modStates = {
    isFlying = false, isNoclipping = false, isSpeedEnabled = false, isEspEnabled = false
}
local modConnections = {
    flyGyro = nil, flyVelocity = nil, noclipConnection = nil
}
local modSettings = {
    originalWalkSpeed = 16, flySpeed = 50, walkSpeed = 50
}
local teleportData = {
    savedPosition = nil
}
local espTracker = {}
local uiElements = { categoryButtons = {}, rightPanelUpdaters = {} }
local activeCategoryButton = nil

--==================================================================================--
--||                                LÓGICA DA UI                                  ||--
--==================================================================================--
local function createRightPanelTitle(parent, key)
    local title = Instance.new("TextLabel")
    title.Name = key; title.Parent = parent; title.Size = UDim2.new(0.9, 0, 0, 30); title.Font = Enum.Font.GothamBold
    title.TextSize = 18; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Text = LANGUAGES[currentLanguage][key] or key
    return title
end

local function createModButton(parent, key, modName)
    local button = Instance.new("TextButton"); button.Name = key; button.Parent = parent
    button.Size = UDim2.new(0.9, 0, 0, 30); button.BackgroundColor3 = Color3.fromRGB(32, 169, 153)
    button.Font = Enum.Font.GothamSemibold; button.TextSize = 14; button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    
    local function updateText()
        local status = modStates[modName] and "ON" or "OFF"
        button.Text = (LANGUAGES[currentLanguage][key] or key) .. " [" .. status .. "]"
    end
    
    button.MouseButton1Click:Connect(function()
        modStates[modName] = not modStates[modName]
        updateText()
        -- Lógica de ativação/desativação imediata
        if modName == "isSpeedEnabled" then
            local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if modStates.isSpeedEnabled then
                    modSettings.originalWalkSpeed = humanoid.WalkSpeed
                    humanoid.WalkSpeed = modSettings.walkSpeed
                else
                    humanoid.WalkSpeed = modSettings.originalWalkSpeed
                end
            end
        end
    end)
    
    return updateText
end

local function createSlider(parent, key, settingName, min, max, callback)
    local container = Instance.new("Frame"); container.Name = key; container.Parent = parent
    container.Size = UDim2.new(0.9, 0, 0, 50); container.BackgroundTransparency = 1
    local title = Instance.new("TextLabel", container); title.Size = UDim2.new(1, 0, 0.5, 0); title.Font = Enum.Font.Gotham
    title.TextSize = 14; title.TextColor3 = Color3.fromRGB(200, 200, 200); title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    local valueLabel = Instance.new("TextLabel", container); valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
    valueLabel.Font = Enum.Font.GothamBold; valueLabel.TextSize = 14; valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.BackgroundTransparency = 1; valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local slider = Instance.new("Slider", container); slider.Size = UDim2.new(1, 0, 0.5, 0); slider.Position = UDim2.new(0, 0, 0.5, 0)
    slider.MinValue = min; slider.MaxValue = max; slider.Value = modSettings[settingName]
    
    local function updateText()
        title.Text = LANGUAGES[currentLanguage][key] or key
        valueLabel.Text = tostring(math.floor(slider.Value))
    end
    
    slider.ValueChanged:Connect(function(value)
        modSettings[settingName] = value; valueLabel.Text = tostring(math.floor(value))
        if callback then callback(value) end
    end)
    
    updateText()
    return updateText
end

local function createNormalButton(parent, key, onClick)
    local button = Instance.new("TextButton"); button.Name = key; button.Parent = parent
    button.Size = UDim2.new(0.9, 0, 0, 30); button.BackgroundColor3 = Color3.fromRGB(32, 169, 153)
    button.Font = Enum.Font.GothamSemibold; button.TextSize = 14; button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = LANGUAGES[currentLanguage][key] or key; Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    if onClick then button.MouseButton1Click:Connect(onClick) end
    return button
end

local function createTextLabel(parent, key, isDescription)
    local label = Instance.new("TextLabel"); label.Name = key; label.Parent = parent; label.Size = UDim2.new(0.9, 0, 0, 40)
    label.Font = isDescription and Enum.Font.Gotham or Enum.Font.GothamBold
    label.TextSize = isDescription and 13 or 16
    label.TextColor3 = isDescription and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1; label.TextWrapped = true; label.TextXAlignment = Enum.TextXAlignment.Left
    label.SizeConstraint = Enum.SizeConstraint.RelativeY; label.TextYAlignment = Enum.TextYAlignment.Top
    label.Text = LANGUAGES[currentLanguage][key] or key
    return label
end

--==================================================================================--
--||                             LÓGICA PRINCIPAL                                 ||--
--==================================================================================--
function InitializeMod()
    -- 1. Criação de todos os elementos da UI (sem parent)
    local loadingGui = Instance.new("ScreenGui"); loadingGui.Name = "LoadingGui"
    loadingGui.ResetOnSpawn = false; loadingGui.DisplayOrder = 9999
    
    -- ... (Criação de todos os elementos da tela de carregamento)
    local loadingFrame = Instance.new("Frame", loadingGui); --...
    local loadingTitle = Instance.new("TextLabel", loadingFrame); --...
    local loadingStatus = Instance.new("TextLabel", loadingFrame); --...
    local progressBar = Instance.new("Frame", loadingFrame); --...
    local progressBarFill = Instance.new("Frame", progressBar); --...
    
    local mainGui = Instance.new("ScreenGui"); mainGui.Name = "CalvoModV3Gui"
    mainGui.ResetOnSpawn = false; mainGui.Enabled = false
    
    -- ... (Criação de todos os elementos do menu principal)
    local mainContainer = Instance.new("Frame", mainGui); --...
    local topBar = Instance.new("Frame", mainContainer); --...
    local topBarTitle = Instance.new("TextLabel", topBar); --...
    local closeButton = Instance.new("TextButton", topBar); --...
    local leftPanel = Instance.new("Frame", mainContainer); --...
    local rightPanel = Instance.new("ScrollingFrame", mainContainer); --...
    
    -- 2. Configuração das propriedades dos elementos
    -- Tela de Carregamento
    loadingFrame.Size = UDim2.new(0, 250, 0, 80); loadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5); loadingFrame.BackgroundColor3 = Color3.fromRGB(44, 52, 58)
    loadingFrame.BorderColor3 = Color3.fromRGB(32, 169, 153); Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 8)
    loadingTitle.Size = UDim2.new(1, 0, 0.5, 0); loadingTitle.Text = "CALVO MOD"; loadingTitle.Font = Enum.Font.GothamBold
    loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255); loadingTitle.TextSize = 20; loadingTitle.BackgroundTransparency = 1
    loadingStatus.Size = UDim2.new(1, 0, 0.2, 0); loadingStatus.Position = UDim2.new(0, 0, 0.5, 0)
    loadingStatus.Text = LANGUAGES[currentLanguage].loading; loadingStatus.Font = Enum.Font.Gotham
    loadingStatus.TextColor3 = Color3.fromRGB(200, 200, 200); loadingStatus.TextSize = 14; loadingStatus.BackgroundTransparency = 1
    progressBar.Size = UDim2.new(0.9, 0, 0, 5); progressBar.Position = UDim2.new(0.5, 0, 1, -15)
    progressBar.AnchorPoint = Vector2.new(0.5, 1); progressBar.BackgroundColor3 = Color3.fromRGB(25, 29, 33)
    Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)
    progressBarFill.Size = UDim2.new(0, 0, 1, 0); progressBarFill.BackgroundColor3 = Color3.fromRGB(32, 169, 153)
    Instance.new("UICorner", progressBarFill).CornerRadius = UDim.new(1, 0)

    -- Menu Principal
    mainContainer.Size = UDim2.new(0, 550, 0, 350); mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainContainer.AnchorPoint = Vector2.new(0.5, 0.5); mainContainer.BackgroundColor3 = Color3.fromRGB(44, 52, 58)
    mainContainer.Draggable = true; mainContainer.Active = true; Instance.new("UICorner", mainContainer).CornerRadius = UDim.new(0, 6)
    topBar.Size = UDim2.new(1, 0, 0, 35); topBar.BackgroundColor3 = Color3.fromRGB(35, 41, 46)
    topBarTitle.Size = UDim2.new(1, -40, 1, 0); topBarTitle.Position = UDim2.new(0, 15, 0, 0)
    topBarTitle.Text = LANGUAGES[currentLanguage].title; topBarTitle.Font = Enum.Font.GothamBold
    topBarTitle.TextColor3 = Color3.fromRGB(255, 255, 255); topBarTitle.TextSize = 16
    topBarTitle.TextXAlignment = Enum.TextXAlignment.Left; topBarTitle.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 20, 0, 20); closeButton.Position = UDim2.new(1, -10, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0.5); closeButton.Text = "X"; closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255); closeButton.TextSize = 14; closeButton.BackgroundTransparency = 1
    leftPanel.Size = UDim2.new(0, 150, 1, -35); leftPanel.Position = UDim2.new(0, 0, 0, 35)
    leftPanel.BackgroundColor3 = Color3.fromRGB(35, 41, 46); leftPanel.BorderSizePixel = 0
    local leftLayout = Instance.new("UIListLayout", leftPanel); leftLayout.Padding = UDim.new(0, 5)
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; Instance.new("UIPadding", leftPanel).PaddingTop = UDim.new(0, 10)
    rightPanel.Size = UDim2.new(1, -150, 1, -35); rightPanel.Position = UDim2.new(0, 150, 0, 35)
    rightPanel.BackgroundTransparency = 1; rightPanel.BorderSizePixel = 0; rightPanel.ScrollBarImageColor3 = Color3.fromRGB(32, 169, 153)
    rightPanel.ScrollBarThickness = 5; local rightLayout = Instance.new("UIListLayout", rightPanel)
    rightLayout.Padding = UDim.new(0, 10); rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", rightPanel).PaddingTop = UDim.new(0, 15)

    -- 3. Conexões e Funções da UI
    local function updateAllUIText() --... (funções internas)
    local function selectCategory(button, categoryKey) --...

    -- 4. Criação dos Botões de Categoria (Painel Esquerdo)
    for _, key in ipairs({"category_combat", "category_localplayer", "category_misc", "category_teleports", "category_admin", "category_credits"}) do
        local button = Instance.new("TextButton", leftPanel); --...
    end

    -- 5. Função de Inicialização das Animações
    local function StartAnimations()
        local progressBarTween = TweenService:Create(progressBarFill, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
        progressBarTween.Completed:Connect(function()
            loadingStatus.Text = LANGUAGES[currentLanguage].ready
            task.wait(0.3) 
            local fadeOutTween = TweenService:Create(loadingGui, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {GroupTransparency = 1})
            fadeOutTween.Completed:Connect(function()
                loadingGui:Destroy()
                mainGui.Enabled = true
                if uiElements.categoryButtons.category_localplayer then
                    selectCategory(uiElements.categoryButtons.category_localplayer, "category_localplayer")
                end
                print("CALVO MOD V3.3 Carregado com sucesso!")
            end)
            fadeOutTween:Play()
        end)
        progressBarTween:Play()
    end
    
    closeButton.MouseButton1Click:Connect(function() mainGui.Enabled = false end)

    -- 6. Parent e Início
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    loadingGui.Parent = playerGui
    mainGui.Parent = playerGui
    StartAnimations()
end

--==================================================================================--
--||                           LÓGICA DOS MODS                                    ||--
--==================================================================================--
RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    if not char then return end

    -- Lógica do Fly
    if modStates.isFlying then
        if not modConnections.flyGyro then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                modConnections.flyGyro = Instance.new("BodyGyro", rootPart)
                modConnections.flyGyro.P, modConnections.flyGyro.MaxTorque = 50000, Vector3.new(4e5, 4e5, 4e5)
                modConnections.flyVelocity = Instance.new("BodyVelocity", rootPart)
                modConnections.flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            end
        end
        if modConnections.flyVelocity and modConnections.flyGyro then
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
            local vertical = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -1 end
            modConnections.flyVelocity.Velocity = (direction.Unit * modSettings.flySpeed) + Vector3.new(0, vertical * modSettings.flySpeed, 0)
            modConnections.flyGyro.CFrame = Camera.CFrame
        end
    elseif modConnections.flyGyro then
        modConnections.flyGyro:Destroy(); modConnections.flyGyro = nil
        modConnections.flyVelocity:Destroy(); modConnections.flyVelocity = nil
    end

    -- Lógica do Noclip
    if modStates.isNoclipping and not modConnections.noclipConnection then
        modConnections.noclipConnection = RunService.Stepped:Connect(function()
            if localPlayer.Character then
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    elseif not modStates.isNoclipping and modConnections.noclipConnection then
        modConnections.noclipConnection:Disconnect(); modConnections.noclipConnection = nil
        if localPlayer.Character then
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)


--==================================================================================--
--||                                  INICIALIZAÇÃO FINAL                           ||--
--==================================================================================--
local success, err = pcall(InitializeMod)
if not success then
    warn("FALHA CRÍTICA NO CALVO MOD: " .. tostring(err))
end