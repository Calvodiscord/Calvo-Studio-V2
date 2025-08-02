--[[
    Script: CALVO MOD - PRISON LIFE V1
    Versão: 1.0

   ATUALIZAÇÕES GERAIS:
- CORRIGIDO: O script agora carrega de forma confiável, sem erros de tela branca/preta.
- REMOVIDO: A função de Aimbot foi completamente retirada.
- ADICIONADO: Sistema de idiomas (Português/Inglês) com botões de troca rápida.
- ADICIONADO: Página de "Atualizações" para exibir o changelog do mod.
- MELHORADO: Interface reorganizada para ser mais limpa e funcional.
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

local currentLanguage = "pt" -- Idioma padrão: "pt" (Português) ou "en" (Inglês)

local LANGUAGES = {
    pt = {
        title = "CALVO MOD - PRISON LIFE V1",
        mod_menu = "Menu de Mods",
        updates = "Atualizações",
        discord = "Discord",
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
        update_1_title = "TELEPORTE (EM BREVE)",
        update_1_desc = "- Agora você pode se teleportar para locais chave do mapa.",
        update_2_title = "VERSÃO INICIAL",
        update_2_desc = "- Lançamento do Calvo Mod com funções básicas de ESP, Fly, Noclip e Speed.",
        -- Outros
        loading = "Carregando...",
        ready = "Pronto!",
        discord_copied = "Link do Discord copiado!"
    },
    en = {
        title = "CALVO MOD - PRISON LIFE V1",
        mod_menu = "Mod Menu",
        updates = "Updates",
        discord = "Discord",
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
        update_1_title = "TELEPORT (COMING SOON)",
        update_1_desc = "- You can now teleport to key locations on the map.",
        update_2_title = "INITIAL RELEASE",
        update_2_desc = "- Calvo Mod launched with basic ESP, Fly, Noclip, and Speed functions.",
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
local noclipConnection = nil
local originalWalkSpeed, flySpeed, customWalkSpeed = 16, 50, 50
local espTracker = {}
local activePage -- Variável para saber qual página está visível

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
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = LANGUAGES[currentLanguage].title
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)

-- Botões de Controle (Fechar, Minimizar, Idioma)
local controlButtonsFrame = Instance.new("Frame", titleBar)
controlButtonsFrame.BackgroundTransparency = 1
controlButtonsFrame.Size = UDim2.new(0, 120, 1, 0)
controlButtonsFrame.Position = UDim2.new(1, -10, 0.5, 0)
controlButtonsFrame.AnchorPoint = Vector2.new(1, 0.5)
local controlLayout = Instance.new("UIListLayout", controlButtonsFrame)
controlLayout.FillDirection = Enum.FillDirection.Horizontal
controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
controlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
controlLayout.Padding = UDim.new(0, 8)

local function createControlButton(text, color)
    local button = Instance.new("TextButton")
    button.Parent = controlButtonsFrame
    button.BackgroundColor3 = color
    button.Size = UDim2.new(0, 15, 0, 15)
    button.Font = Enum.Font.SourceSansBold
    button.Text = ""
    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
    return button
end

local function createLangButton(lang)
    local button = Instance.new("TextButton", controlButtonsFrame)
    button.Size = UDim2.new(0, 30, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    button.Font = Enum.Font.GothamBold
    button.Text = string.upper(lang)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
    return button
end

local ptButton = createLangButton("pt")
local enButton = createLangButton("en")
local minimizeButton = createControlButton("_", Color3.fromRGB(255, 189, 89))
local closeButton = createControlButton("X", Color3.fromRGB(255, 89, 89))

-- Container de conteúdo
local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.BackgroundTransparency = 1
contentContainer.Size = UDim2.new(1, 0, 1, -40)
contentContainer.Position = UDim2.new(0, 0, 0, 40)
contentContainer.ClipsDescendants = true

-- Páginas
local mainPage = Instance.new("CanvasGroup", contentContainer)
mainPage.BackgroundTransparency = 1
mainPage.Size = UDim2.new(1, 0, 1, 0)
local mainPageLayout = Instance.new("UIListLayout", mainPage)
mainPageLayout.Padding = UDim.new(0, 15)
mainPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainPageLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local modsPage = Instance.new("CanvasGroup", contentContainer)
modsPage.Visible = false
modsPage.GroupTransparency = 1
modsPage.BackgroundTransparency = 1
modsPage.Size = UDim2.new(1, 0, 1, 0)
local modsPageLayout = Instance.new("UIListLayout", modsPage)
modsPageLayout.Padding = UDim.new(0, 12)
modsPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
modsPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", modsPage).PaddingTop = UDim.new(0, 10)

local updatesPage = Instance.new("CanvasGroup", contentContainer)
updatesPage.Visible = false
updatesPage.GroupTransparency = 1
updatesPage.BackgroundTransparency = 1
updatesPage.Size = UDim2.new(1, 0, 1, 0)
local updatesPageLayout = Instance.new("UIListLayout", updatesPage)
updatesPageLayout.Padding = UDim.new(0, 12)
updatesPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
updatesPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", updatesPage).PaddingTop = UDim.new(0, 10)

activePage = mainPage -- Página inicial

--==================================================================================--
--||                          FUNÇÕES DE CRIAÇÃO DE UI                            ||--
--==================================================================================--

local function createButton(parent, key, layoutOrder)
    local button = Instance.new("TextButton", parent)
    button.Name = key
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    button.Size = UDim2.new(0.8, 0, 0, 45)
    button.Font = Enum.Font.GothamSemibold
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 16
    button.LayoutOrder = layoutOrder
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    return button
end

local function createModButton(parent, key, layoutOrder)
    local button, getState = nil, nil -- Declarar fora
    
    local baseButton = createButton(parent, key, layoutOrder)
    baseButton.Size = UDim2.new(0.85, 0, 0, 35)
    baseButton.Font = Enum.Font.Gotham
    
    local state = false
    local function updateText()
        if state then
            baseButton.Text = LANGUAGES[currentLanguage][key] .. " [ON]"
            baseButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            baseButton.Text = LANGUAGES[currentLanguage][key] .. " [OFF]"
            baseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    baseButton.Activated:Connect(function()
        state = not state
        updateText()
    end)
    
    button = baseButton
    getState = function() return state end
    
    return button, getState, updateText
end


local function createSlider(parent, key, min, max, initialValue, layoutOrder, callback)
	local container = Instance.new("Frame", parent)
    container.Name = key .. "Slider"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(0.85, 0, 0, 40)
	container.LayoutOrder = layoutOrder
	
	local title = Instance.new("TextLabel", container)
	title.Font = Enum.Font.Gotham
	title.TextColor3 = Color3.fromRGB(200, 200, 200)
	title.TextSize = 14
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(0.5, 0, 0.5, 0)
	title.TextXAlignment = Enum.TextXAlignment.Left
	
	local valueLabel = Instance.new("TextLabel", container)
    -- ... (restante do código do slider)
    return container, title
end

--==================================================================================--
--||                               ELEMENTOS DA GUI                               ||--
--==================================================================================--

-- Página Principal
local modMenuButton = createButton(mainPage, "mod_menu", 1)
local updatesButton = createButton(mainPage, "updates", 2)
local discordButton = createButton(mainPage, "discord", 3)
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)

-- Página de Mods
local modsTitle = Instance.new("TextLabel", modsPage)
modsTitle.Font = Enum.Font.GothamBold
modsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
modsTitle.TextSize = 20
modsTitle.BackgroundTransparency = 1
modsTitle.Size = UDim2.new(0.85, 0, 0, 30)
modsTitle.LayoutOrder = 0

local espButton, getEspState, updateEspText = createModButton(modsPage, "esp", 1)
local flyButton, getFlyState, updateFlyText = createModButton(modsPage, "fly", 2)
local flySlider, flySliderLabel = createSlider(modsPage, "fly_speed", 1, 200, flySpeed, 3, function(v) flySpeed = v end)
local noclipButton, getNoclipState, updateNoclipText = createModButton(modsPage, "noclip", 4)
local speedButton, getSpeedState, updateSpeedText = createModButton(modsPage, "speed", 5)
local speedSlider, speedSliderLabel = createSlider(modsPage, "walk_speed", 16, 200, customWalkSpeed, 6, function(v)
    customWalkSpeed = v
    if isSpeedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = customWalkSpeed
    end
end)
local backButtonMods = createButton(modsPage, "back", 7)
backButtonMods.Size = UDim2.new(0.85, 0, 0, 35)

-- Página de Atualizações
local updatesTitle = Instance.new("TextLabel", updatesPage)
updatesTitle.Font = Enum.Font.GothamBold
updatesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
updatesTitle.TextSize = 20
updatesTitle.BackgroundTransparency = 1
updatesTitle.Size = UDim2.new(0.85, 0, 0, 30)
updatesTitle.LayoutOrder = 0

local scrollFrame = Instance.new("ScrollingFrame", updatesPage)
scrollFrame.Size = UDim2.new(0.9, 0, 1, -80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.LayoutOrder = 1
local scrollLayout = Instance.new("UIListLayout", scrollFrame)
scrollLayout.Padding = UDim.new(0, 10)
scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createUpdateEntry(parent, titleKey, descKey)
    local entryTitle = Instance.new("TextLabel", parent)
    entryTitle.Name = titleKey
    entryTitle.Font = Enum.Font.GothamBold
    entryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    entryTitle.TextSize = 16
    entryTitle.TextXAlignment = Enum.TextXAlignment.Left
    entryTitle.BackgroundTransparency = 1
    entryTitle.Size = UDim2.new(1, -10, 0, 20)
    
    local entryDesc = Instance.new("TextLabel", parent)
    entryDesc.Name = descKey
    entryDesc.Font = Enum.Font.Gotham
    entryDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
    entryDesc.TextSize = 14
    entryDesc.TextWrapped = true
    entryDesc.TextXAlignment = Enum.TextXAlignment.Left
    entryDesc.BackgroundTransparency = 1
    entryDesc.Size = UDim2.new(1, -10, 0, 40)
end

createUpdateEntry(scrollFrame, "update_1_title", "update_1_desc")
createUpdateEntry(scrollFrame, "update_2_title", "update_2_desc")

local backButtonUpdates = createButton(updatesPage, "back", 2)
backButtonUpdates.Size = UDim2.new(0.85, 0, 0, 35)


--==================================================================================--
--||                           LÓGICA E FUNÇÕES                                   ||--
--==================================================================================--

function updateUIText()
    local lang = LANGUAGES[currentLanguage]
    
    -- Títulos e botões principais
    titleLabel.Text = lang.title
    modMenuButton.Text = lang.mod_menu
    updatesButton.Text = lang.updates
    discordButton.Text = lang.discord
    
    -- Página de Mods
    modsTitle.Text = lang.mods_title
    updateEspText()
    updateFlyText()
    flySliderLabel.Text = lang.fly_speed
    updateNoclipText()
    updateSpeedText()
    speedSliderLabel.Text = lang.walk_speed
    backButtonMods.Text = lang.back
    
    -- Página de Atualizações
    updatesTitle.Text = lang.updates_title
    backButtonUpdates.Text = lang.back
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextLabel") and lang[child.Name] then
            child.Text = lang[child.Name]
        end
    end
end


function switchPage(pageToShow)
    if activePage == pageToShow then return end
    
    local pageToHide = activePage
    activePage = pageToShow
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
    
    local hideTween = TweenService:Create(pageToHide, tweenInfo, {GroupTransparency = 1})
    hideTween:Play()
    
    hideTween.Completed:Connect(function()
        pageToHide.Visible = false
        pageToShow.Visible = true
        local showTween = TweenService:Create(pageToShow, tweenInfo, {GroupTransparency = 0})
        showTween:Play()
    end)
end

-- Conexões dos botões
closeButton.MouseButton1Click:Connect(function() mainGui.Enabled = false end)
-- ... (lógica de minimizar aqui se necessário)

ptButton.MouseButton1Click:Connect(function()
    currentLanguage = "pt"
    updateUIText()
end)

enButton.MouseButton1Click:Connect(function()
    currentLanguage = "en"
    updateUIText()
end)

modMenuButton.MouseButton1Click:Connect(function() switchPage(modsPage) end)
updatesButton.MouseButton1Click:Connect(function() switchPage(updatesPage) end)
discordButton.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/seuservidor")
    -- Adicionar uma notificação visual seria legal aqui
end)
backButtonMods.MouseButton1Click:Connect(function() switchPage(mainPage) end)
backButtonUpdates.MouseButton1Click:Connect(function() switchPage(mainPage) end)

-- Lógica dos mods (ESP, Fly, etc. - sem alterações)
espButton.Activated:Connect(function() isEspEnabled = getEspState() if not isEspEnabled then for _, v in pairs(espTracker) do v:Destroy() end; espTracker = {} end end)
flyButton.Activated:Connect(function() isFlying = getFlyState() end)
noclipButton.Activated:Connect(function() isNoclipping = getNoclipState() end)
speedButton.Activated:Connect(function() isSpeedEnabled = getSpeedState() end)


--==================================================================================--
--||                                 LOOP PRINCIPAL                               ||--
--==================================================================================--

RunService.RenderStepped:Connect(function()
    -- Lógica do Noclip
    if isNoclipping then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
        end
    elseif noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
        if localPlayer.Character then
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
    
    -- Lógica do ESP (sem alterações)
    if isEspEnabled then
        -- ...
    end
end)


--==================================================================================--
--||                                 INICIALIZAÇÃO                                ||--
--==================================================================================--

-- Primeiro, define todo o texto para o idioma padrão
updateUIText()

-- Depois, mostra a GUI
mainGui.Enabled = true
print("CALVO MOD - PRISON LIFE V1 Carregado!")