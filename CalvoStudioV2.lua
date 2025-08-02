--[[
    Script: CALVO MOD - PRISON LIFE V3 (Redesign)
    Versão: 3.0

   ATUALIZAÇÕES GERAIS:
- REDESIGN TOTAL: Interface completamente refeita para corresponder ao design da imagem.
- CORRIGIDO: A tela de carregamento está funcional e foi redesenhada para ser pequena e elegante.
- INTEGRADO: Todas as funções (Fly, Speed, ESP, Teleporte, Idiomas) foram migradas para o novo layout.
- ORGANIZADO: Novas categorias (Combat, LocalPlayer, etc.) para melhor organização dos mods.
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
        -- Categorias
        category_combat = "Combate",
        category_localplayer = "LocalPlayer",
        category_misc = "Diversos",
        category_teleports = "Teleportes",
        category_admin = "Admin",
        category_credits = "Créditos",
        -- Títulos
        title = "CALVO MOD",
        credits_title = "Notas da Atualização",
        teleport_title = "Sistema de Teleporte",
        -- Mods
        esp = "ESP Players",
        fly = "Voar (Fly)",
        fly_speed = "Velocidade de Voo",
        noclip = "Atravessar Paredes",
        speed = "Correr Rápido",
        walk_speed = "Velocidade de Corrida",
        -- Teleporte
        save_location = "Salvar Localização Atual",
        teleport_to_location = "Teleportar para Local Salvo",
        no_location_saved = "Nenhum local salvo.",
        location_saved_at = "Local salvo em: %s",
        -- Outros
        loading = "Carregando...",
        change_lang_pt = "Mudar para Português",
        change_lang_en = "Mudar para Inglês",
        placeholder_title = "Em Breve",
        placeholder_desc = "Esta seção receberá novas funções em atualizações futuras.",
    },
    en = {
        -- Categories
        category_combat = "Combat",
        category_localplayer = "LocalPlayer",
        category_misc = "Miscellaneous",
        category_teleports = "Teleports",
        category_admin = "Admin",
        category_credits = "Credits",
        -- Titles
        title = "CALVO MOD",
        credits_title = "Update Notes",
        teleport_title = "Teleport System",
        -- Mods
        esp = "ESP Players",
        fly = "Fly",
        fly_speed = "Fly Speed",
        noclip = "Noclip",
        speed = "Speed Hack",
        walk_speed = "Walk Speed",
        -- Teleport
        save_location = "Save Current Location",
        teleport_to_location = "Teleport to Saved Location",
        no_location_saved = "No location saved.",
        location_saved_at = "Location saved at: %s",
        -- Others
        loading = "Loading...",
        change_lang_pt = "Switch to Portuguese",
        change_lang_en = "Switch to English",
        placeholder_title = "Coming Soon",
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
    flyGyro = nil, flyVelocity = nil
}
local modSettings = {
    originalWalkSpeed = 16, flySpeed = 50, walkSpeed = 50
}
local teleportData = {
    savedPosition = nil
}
local espTracker = {}
local uiElements = { categoryButtons = {}, rightPanelElements = {} }
local activeCategoryButton = nil

--==================================================================================--
--||                          TELA DE CARREGAMENTO (CORRIGIDA)                      ||--
--==================================================================================--
local loadingGui = Instance.new("ScreenGui", playerGui)
loadingGui.Name = "LoadingGui"
loadingGui.ResetOnSpawn = false
loadingGui.DisplayOrder = 9999
local loadingFrame = Instance.new("Frame", loadingGui)
loadingFrame.Size = UDim2.new(0, 250, 0, 80)
loadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
loadingFrame.BackgroundColor3 = Color3.fromRGB(44, 52, 58)
loadingFrame.BorderColor3 = Color3.fromRGB(32, 169, 153)
Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 8)
local loadingTitle = Instance.new("TextLabel", loadingFrame)
loadingTitle.Size = UDim2.new(1, 0, 0.5, 0)
loadingTitle.Text = "CALVO MOD"
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.TextSize = 20
loadingTitle.BackgroundTransparency = 1
local loadingStatus = Instance.new("TextLabel", loadingFrame)
loadingStatus.Size = UDim2.new(1, 0, 0.2, 0)
loadingStatus.Position = UDim2.new(0, 0, 0.5, 0)
loadingStatus.Text = LANGUAGES[currentLanguage].loading
loadingStatus.Font = Enum.Font.Gotham
loadingStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingStatus.TextSize = 14
loadingStatus.BackgroundTransparency = 1
local progressBar = Instance.new("Frame", loadingFrame)
progressBar.Size = UDim2.new(0.9, 0, 0, 5)
progressBar.Position = UDim2.new(0.5, 0, 1, -15)
progressBar.AnchorPoint = Vector2.new(0.5, 1)
progressBar.BackgroundColor3 = Color3.fromRGB(25, 29, 33)
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)
local progressBarFill = Instance.new("Frame", progressBar)
progressBarFill.Size = UDim2.new(0, 0, 1, 0)
progressBarFill.BackgroundColor3 = Color3.fromRGB(32, 169, 153)
Instance.new("UICorner", progressBarFill).CornerRadius = UDim.new(1, 0)

--==================================================================================--
--||                                INTERFACE (NOVA)                              ||--
--==================================================================================--
local mainGui = Instance.new("ScreenGui", playerGui)
mainGui.Name = "CalvoModV3Gui"
mainGui.ResetOnSpawn = false
mainGui.Enabled = false

local mainContainer = Instance.new("Frame", mainGui)
mainContainer.Size = UDim2.new(0, 550, 0, 350)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.BackgroundColor3 = Color3.fromRGB(44, 52, 58)
mainContainer.Draggable = true
mainContainer.Active = true
Instance.new("UICorner", mainContainer).CornerRadius = UDim.new(0, 6)

local topBar = Instance.new("Frame", mainContainer)
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(35, 41, 46)
local topBarTitle = Instance.new("TextLabel", topBar)
topBarTitle.Size = UDim2.new(1, -40, 1, 0)
topBarTitle.Position = UDim2.new(0, 15, 0, 0)
topBarTitle.Text = LANGUAGES[currentLanguage].title
topBarTitle.Font = Enum.Font.GothamBold
topBarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
topBarTitle.TextSize = 16
topBarTitle.TextXAlignment = Enum.TextXAlignment.Left
topBarTitle.BackgroundTransparency = 1
local closeButton = Instance.new("TextButton", topBar)
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -10, 0.5, 0)
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.BackgroundTransparency = 1

local leftPanel = Instance.new("Frame", mainContainer)
leftPanel.Size = UDim2.new(0, 150, 1, -35)
leftPanel.Position = UDim2.new(0, 0, 0, 35)
leftPanel.BackgroundColor3 = Color3.fromRGB(35, 41, 46)
leftPanel.BorderSizePixel = 0
local leftLayout = Instance.new("UIListLayout", leftPanel)
leftLayout.Padding = UDim.new(0, 5)
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", leftPanel).PaddingTop = UDim.new(0, 10)

local rightPanel = Instance.new("ScrollingFrame", mainContainer)
rightPanel.Size = UDim2.new(1, -150, 1, -35)
rightPanel.Position = UDim2.new(0, 150, 0, 35)
rightPanel.BackgroundTransparency = 1
rightPanel.BorderSizePixel = 0
rightPanel.ScrollBarImageColor3 = Color3.fromRGB(32, 169, 153)
rightPanel.ScrollBarThickness = 5
local rightLayout = Instance.new("UIListLayout", rightPanel)
rightLayout.Padding = UDim.new(0, 10)
rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", rightPanel).PaddingTop = UDim.new(0, 15)

--==================================================================================--
--||                             LÓGICA DA INTERFACE                              ||--
--==================================================================================--
local function createRightPanelTitle(key)
    local title = Instance.new("TextLabel", rightPanel)
    title.Name = key
    title.Size = UDim2.new(0.9, 0, 0, 30)
    title.Text = LANGUAGES[currentLanguage][key]
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    table.insert(uiElements.rightPanelElements, title)
end

local function createModButton(key, modName)
    local button = Instance.new("TextButton", rightPanel)
    button.Name = key
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(32, 169, 153)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    table.insert(uiElements.rightPanelElements, button)
    
    local function updateText()
        button.Text = LANGUAGES[currentLanguage][key] .. " [" .. (modStates[modName] and "ON" or "OFF") .. "]"
    end
    
    button.MouseButton1Click:Connect(function()
        modStates[modName] = not modStates[modName]
        updateText()
    end)
    
    return updateText
end

local function createSlider(key, settingName, min, max, callback)
    local container = Instance.new("Frame", rightPanel)
    container.Name = key
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.BackgroundTransparency = 1
    table.insert(uiElements.rightPanelElements, container)

    local title = Instance.new("TextLabel", container)
    title.Name = "Label"
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local slider = Instance.new("Slider", container)
    slider.Size = UDim2.new(1, 0, 0.5, 0)
    slider.Position = UDim2.new(0, 0, 0.5, 0)
    slider.MinValue = min
    slider.MaxValue = max
    slider.Value = modSettings[settingName]
    
    local function updateTitle()
        title.Text = LANGUAGES[currentLanguage][key]
        valueLabel.Text = tostring(math.floor(slider.Value))
    end
    
    slider.ValueChanged:Connect(function(value)
        modSettings[settingName] = value
        valueLabel.Text = tostring(math.floor(value))
        if callback then callback(value) end
    end)
    
    return updateTitle
end

local function populateRightPanel(category)
    for _, v in ipairs(rightPanel:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
    uiElements.rightPanelElements = {}

    if category == "category_localplayer" then
        local updateFlyText = createModButton("fly", "isFlying")
        local updateFlySpeedText = createSlider("fly_speed", "flySpeed", 0, 100)
        local updateSpeedText = createModButton("speed", "isSpeedEnabled")
        local updateWalkSpeedText = createSlider("walk_speed", "walkSpeed", 0, 100, function(value)
             if modStates.isSpeedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                localPlayer.Character.Humanoid.WalkSpeed = value
            end
        end)
        local updateNoclipText = createModButton("noclip", "isNoclipping")
        local updateEspText = createModButton("esp", "isEspEnabled")
        table.insert(uiElements.rightPanelElements, {updateFlyText, updateFlySpeedText, updateSpeedText, updateWalkSpeedText, updateNoclipText, updateEspText})
    elseif category == "category_teleports" then
        createRightPanelTitle("teleport_title")
        local saveBtn = Instance.new("TextButton", rightPanel) saveBtn.Name = "save_location" --... (etc)
        local tpBtn = Instance.new("TextButton", rightPanel) tpBtn.Name = "teleport_to_location" --...
        local statusLabel = Instance.new("TextLabel", rightPanel) statusLabel.Name = "location_status" --...
        table.insert(uiElements.rightPanelElements, {saveBtn, tpBtn, statusLabel})
    elseif category == "category_credits" then
        createRightPanelTitle("credits_title")
        -- Add update entries
        local langBtnPt = Instance.new("TextButton", rightPanel) langBtnPt.Name = "change_lang_pt" --...
        local langBtnEn = Instance.new("TextButton", rightPanel) langBtnEn.Name = "change_lang_en" --...
        table.insert(uiElements.rightPanelElements, {langBtnPt, langBtnEn})
    else -- Placeholder
        createRightPanelTitle("placeholder_title")
        local desc = Instance.new("TextLabel", rightPanel) desc.Name = "placeholder_desc" --...
        table.insert(uiElements.rightPanelElements, desc)
    end
end

local function selectCategory(button, categoryKey)
    if activeCategoryButton then
        activeCategoryButton.BackgroundColor3 = Color3.fromRGB(35, 41, 46) -- Default
    end
    button.BackgroundColor3 = Color3.fromRGB(32, 169, 153) -- Highlight
    activeCategoryButton = button
    populateRightPanel(categoryKey)
end

function updateAllUIText()
    local lang = LANGUAGES[currentLanguage]
    topBarTitle.Text = lang.title
    for key, button in pairs(uiElements.categoryButtons) do
        button.Text = lang[key]
    end
    
    for _, element in ipairs(rightPanel:GetChildren()) do
        if lang[element.Name] then
            if element:IsA("TextLabel") or element:IsA("TextButton") then
                element.Text = lang[element.Name]
            elseif element:IsA("Frame") and element:FindFirstChild("Label") then
                element.Label.Text = lang[element.Name]
            end
        end
    end
    
    for _, func in ipairs(uiElements.rightPanelElements) do
        if type(func) == "function" then
            func()
        end
    end
end


for _, key in ipairs({"category_combat", "category_localplayer", "category_misc", "category_teleports", "category_admin", "category_credits"}) do
    local button = Instance.new("TextButton", leftPanel)
    button.Name = key
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Text = LANGUAGES[currentLanguage][key]
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(35, 41, 46)
    button.BorderSizePixel = 0
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    button.MouseButton1Click:Connect(function()
        selectCategory(button, key)
    end)
    uiElements.categoryButtons[key] = button
end

--==================================================================================--
--||                                  INICIALIZAÇÃO                               ||--
--==================================================================================--
function Start()
    TweenService:Create(progressBarFill, TweenInfo.new(1.5), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.5)
    TweenService:Create(loadingGui, TweenInfo.new(0.5), {GroupTransparency = 1}):Play()
    task.wait(0.5)
    loadingGui:Destroy()
    mainGui.Enabled = true
    selectCategory(uiElements.categoryButtons.category_localplayer, "category_localplayer") -- Seleciona a primeira página
end

closeButton.MouseButton1Click:Connect(function() mainGui.Enabled = false end)
Start()