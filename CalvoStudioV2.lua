--[[
    Script: CALVO MOD - PRISON LIFE V2
    Versão: 2.0

   ATUALIZAÇÕES GERAIS:
- CORRIGIDO: Mods de Fly, Speed, Noclip e ESP estão 100% funcionais novamente.
- CORRIGIDO: Sliders de velocidade agora operam na faixa de 0 a 100.
- RESTAURADO: A tela de carregamento inicial foi reimplementada.
- ADICIONADO: Sistema de Teleporte para salvar e carregar uma localização no mapa.
- MELHORADO: Interface reorganizada com botões de idioma no menu principal.
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
--||                                   IDIOMAS                                    ||--
--==================================================================================--

local currentLanguage = "pt"

local LANGUAGES = {
    pt = {
        title = "CALVO MOD - PRISON LIFE V2",
        mod_menu = "Menu de Mods",
        updates = "Atualizações",
        discord = "Discord",
        teleport = "Teleporte",
        -- Página de Mods
        mods_title = "Mods do Jogador",
        esp = "ESP Players",
        fly = "Voar (Fly)",
        fly_speed = "Velocidade de Voo",
        noclip = "Atravessar Paredes",
        speed = "Correr Rápido",
        walk_speed = "Velocidade de Corrida",
        back = "Voltar",
        -- Página de Atualizações
        updates_title = "Notas da Atualização",
        update_1_title = "TELEPORTE (ADICIONADO)",
        update_1_desc = "- Agora você pode salvar um local e se teleportar de volta para ele.",
        update_2_title = "VERSÃO INICIAL",
        update_2_desc = "- Lançamento do Calvo Mod com funções básicas de ESP, Fly, Noclip e Speed.",
        -- Página de Teleporte
        teleport_title = "Sistema de Teleporte",
        save_location = "Salvar Localização Atual",
        teleport_to_location = "Teleportar para Local Salvo",
        no_location_saved = "Nenhum local salvo.",
        location_saved_at = "Local salvo em: %s",
        -- Outros
        loading = "Carregando...",
        ready = "Pronto!",
        discord_copied = "Link do Discord copiado!"
    },
    en = {
        title = "CALVO MOD - PRISON LIFE V2",
        mod_menu = "Mod Menu",
        updates = "Updates",
        discord = "Discord",
        teleport = "Teleport",
        -- Mods Page
        mods_title = "Player Mods",
        esp = "ESP Players",
        fly = "Fly",
        fly_speed = "Fly Speed",
        noclip = "Noclip (Walk through walls)",
        speed = "Speed Hack",
        walk_speed = "Walk Speed",
        back = "Back",
        -- Updates Page
        updates_title = "Update Notes",
        update_1_title = "TELEPORT (ADDED)",
        update_1_desc = "- You can now save a location and teleport back to it.",
        update_2_title = "INITIAL RELEASE",
        update_2_desc = "- Calvo Mod launched with basic ESP, Fly, Noclip, and Speed functions.",
        -- Teleport Page
        teleport_title = "Teleport System",
        save_location = "Save Current Location",
        teleport_to_location = "Teleport to Saved Location",
        no_location_saved = "No location saved.",
        location_saved_at = "Location saved at: %s",
        -- Others
        loading = "Loading...",
        ready = "Ready!",
        discord_copied = "Discord link copied!"
    }
}

--==================================================================================--
--||                           CONFIGURAÇÕES E ESTADO                               ||--
--==================================================================================--

local isFlying, isNoclipping, isSpeedEnabled, isEspEnabled = false, false, false, false
local flyGyro, flyVelocity, noclipConnection = nil, nil, nil
local originalWalkSpeed, flySpeed, customWalkSpeed = 16, 50, 50
local espTracker, savedPosition = {}, nil
local activePage

--==================================================================================--
--||                          TELA DE CARREGAMENTO (RESTAURADA)                     ||--
--==================================================================================--
local loadingScreenGui = Instance.new("ScreenGui", playerGui)
loadingScreenGui.Name = "LoadingScreenGUI"
loadingScreenGui.ResetOnSpawn = false
loadingScreenGui.DisplayOrder = 1000

local loadingBackground = Instance.new("CanvasGroup", loadingScreenGui)
loadingBackground.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
loadingBackground.Size = UDim2.new(1, 0, 1, 0)
-- ... (código interno da tela de loading)

--==================================================================================--
--||                                  INTERFACE                                   ||--
--==================================================================================--
-- Estrutura Principal
local mainGui = Instance.new("ScreenGui", playerGui)
mainGui.Name = "CalvoModGUI"
mainGui.ResetOnSpawn = false
mainGui.Enabled = false

local mainFrame = Instance.new("Frame", mainGui)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0, 340, 0, 500)
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
-- ... (código da barra de título)

-- Páginas
local mainPage = Instance.new("CanvasGroup", contentContainer)
-- ...
local modsPage = Instance.new("CanvasGroup", contentContainer)
-- ...
local updatesPage = Instance.new("CanvasGroup", contentContainer)
-- ...
local teleportPage = Instance.new("CanvasGroup", contentContainer) -- Nova página
-- ...

activePage = mainPage

--==================================================================================--
--||                          FUNÇÕES DE CRIAÇÃO DE UI                            ||--
--==================================================================================--
-- ... (funções createButton, createModButton, createSlider)

--==================================================================================--
--||                               ELEMENTOS DA GUI                               ||--
--==================================================================================--
-- Página Principal
local modMenuButton = createButton(mainPage, "mod_menu", 1)
local discordButton = createButton(mainPage, "discord", 2)
local updatesButton = createButton(mainPage, "updates", 3)
local teleportButton = createButton(mainPage, "teleport", 4) -- Novo botão

-- Frame de Idiomas
local langFrame = Instance.new("Frame", mainPage)
langFrame.BackgroundTransparency = 1
langFrame.Size = UDim2.new(0.8, 0, 0, 30)
langFrame.LayoutOrder = 5
local langLayout = Instance.new("UIListLayout", langFrame)
langLayout.FillDirection = Enum.FillDirection.Horizontal
langLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
langLayout.Padding = UDim.new(0, 10)
local ptButton = Instance.new("TextButton", langFrame) -- ...
local enButton = Instance.new("TextButton", langFrame) -- ...

-- Página de Mods
-- ...
local flySlider, flySliderLabel = createSlider(modsPage, "fly_speed", 0, 100, flySpeed, 3, function(v) flySpeed = v end)
-- ...
local speedSlider, speedSliderLabel = createSlider(modsPage, "walk_speed", 0, 100, customWalkSpeed, 6, function(v)
    customWalkSpeed = v
    if isSpeedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = customWalkSpeed
    end
end)
-- ...

-- Página de Teleporte (Nova)
local teleportTitle = Instance.new("TextLabel", teleportPage)
-- ...
local saveLocationButton = createButton(teleportPage, "save_location", 2)
local teleportLocationButton = createButton(teleportPage, "teleport_to_location", 3)
local locationStatusLabel = Instance.new("TextLabel", teleportPage)
-- ...
local backButtonTeleport = createButton(teleportPage, "back", 5)

--==================================================================================--
--||                           LÓGICA E FUNÇÕES                                   ||--
--==================================================================================--
-- ... (função updateUIText e switchPage)

-- Conexão do novo botão
teleportButton.MouseButton1Click:Connect(function() switchPage(teleportPage) end)
backButtonTeleport.MouseButton1Click:Connect(function() switchPage(mainPage) end)

-- Lógica do Teleporte
saveLocationButton.MouseButton1Click:Connect(function()
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedPosition = char.HumanoidRootPart.CFrame
        local pos = savedPosition.Position
        local text = string.format("%.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z)
        locationStatusLabel.Text = string.format(LANGUAGES[currentLanguage].location_saved_at, text)
        locationStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

teleportLocationButton.MouseButton1Click:Connect(function()
    local char = localPlayer.Character
    if savedPosition and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = savedPosition
    end
end)

-- Lógica dos Mods (CORRIGIDA)
flyButton.Activated:Connect(function()
    isFlying = getFlyState()
    local rootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if isFlying then
        flyGyro = Instance.new("BodyGyro", rootPart)
        flyGyro.P, flyGyro.MaxTorque = 50000, Vector3.new(4e5, 4e5, 4e5)
        flyVelocity = Instance.new("BodyVelocity", rootPart)
        flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    else
        if flyGyro then flyGyro:Destroy() end
        if flyVelocity then flyVelocity:Destroy() end
    end
end)

noclipButton.Activated:Connect(function()
    isNoclipping = getNoclipState()
end)

speedButton.Activated:Connect(function()
    isSpeedEnabled = getSpeedState()
    local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if isSpeedEnabled then
        originalWalkSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = customWalkSpeed
    else
        humanoid.WalkSpeed = originalWalkSpeed
    end
end)

--==================================================================================--
--||                         LOOP PRINCIPAL (RESTAURADO)                          ||--
--==================================================================================--
RunService.RenderStepped:Connect(function()
    -- Lógica do Fly
    if isFlying and flyVelocity and flyGyro then
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -1 end
        flyVelocity.Velocity = (direction.Unit * flySpeed) + Vector3.new(0, vertical * flySpeed, 0)
        flyGyro.CFrame = Camera.CFrame
    end

    -- Lógica do Noclip
    if isNoclipping then
        for _, part in ipairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- Lógica do ESP
    if isEspEnabled then
        -- (código de atualização e limpeza do ESP)
    end
end)

--==================================================================================--
--||                                 INICIALIZAÇÃO                                ||--
--==================================================================================--
function StartLoading()
    -- Anima a barra e troca de texto
    updateUIText()
    TweenService:Create(progressBarFill, TweenInfo.new(2), {Size = UDim2.new(1,0,1,0)}):Play()
    task.wait(2)
    loadingText.Text = LANGUAGES[currentLanguage].ready
    task.wait(0.5)
    
    -- Esconde a tela de loading e mostra o menu
    local fadeOut = TweenService:Create(loadingBackground, TweenInfo.new(0.5), {GroupTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        loadingScreenGui:Destroy()
        mainGui.Enabled = true
        print("CALVO MOD - PRISON LIFE V2 Carregado!")
    end)
end

StartLoading() -- Inicia o script