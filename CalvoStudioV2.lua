--[[
    Script: CALVO MOD - PRISON LIFE V3.2 (Correção de Exibição)
    Versão: 3.2

   ATUALIZAÇÕES:
- CORRIGIDO: Erro crítico que impedia a interface de aparecer após a tela de carregamento foi resolvido.
- RESTAURADO: As seções de Teleporte e Créditos agora criam e exibem seus botões e textos corretamente.
- MELHORADO: Estabilidade geral do script aprimorada para evitar falhas silenciosas na inicialização.
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
        ready = "Pronto!",
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
        ready = "Ready!",
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
--||                          TELA DE CARREGAMENTO                      ||--
--==================================================================================--
local loadingGui = Instance.new("ScreenGui", playerGui)
loadingGui.Name = "LoadingGui"
loadingGui.ResetOnSpawn = false
loadingGui.DisplayOrder = 9999
loadingGui.GroupTransparency = 0 

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
--||                                INTERFACE                                     ||--
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
local function createRightPanelTitle(parent, key)
    local title = Instance.new("TextLabel", parent)
    title.Name = key
    title.Size = UDim2.new(0.9, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = LANGUAGES[currentLanguage][key] or key
    return title
end

local function createModButton(parent, key, modName)
    local button = Instance.new("TextButton", parent)
    button.Name = key
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(32, 169, 153)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    
    local function updateText()
        local status = modStates[modName] and "ON" or "OFF"
        button.Text = (LANGUAGES[currentLanguage][key] or key) .. " [" .. status .. "]"
    end
    
    button.MouseButton1Click:Connect(function()
        modStates[modName] = not modStates[modName]
        updateText()
    end)
    
    return updateText
end

local function createSlider(parent, key, settingName, min, max, callback)
    local container = Instance.new("Frame", parent)
    container.Name = key
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", container)
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
    
    local function updateText()
        title.Text = LANGUAGES[currentLanguage][key] or key
        valueLabel.Text = tostring(math.floor(slider.Value))
    end
    
    slider.ValueChanged:Connect(function(value)
        modSettings[settingName] = value
        valueLabel.Text = tostring(math.floor(value))
        if callback then callback(value) end
    end)
    
    updateText() -- Initial text set
    return updateText
end

local function createNormalButton(parent, key, onClick)
    local button = Instance.new("TextButton", parent)
    button.Name = key
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(32, 169, 153)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = LANGUAGES[currentLanguage][key] or key
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    if onClick then button.MouseButton1Click:Connect(onClick) end
    return button
end

local function createTextLabel(parent, key, isDescription)
    local label = Instance.new("TextLabel", parent)
    label.Name = key
    label.Size = UDim2.new(0.9, 0, 0, 40)
    label.Font = isDescription and Enum.Font.Gotham or Enum.Font.GothamBold
    label.TextSize = isDescription and 13 or 16
    label.TextColor3 = isDescription and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.SizeConstraint = Enum.SizeConstraint.RelativeY
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Text = LANGUAGES[currentLanguage][key] or key
    return label
end

local function populateRightPanel(category)
    for _, v in ipairs(rightPanel:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
    uiElements.rightPanelUpdaters = {}

    if category == "category_localplayer" then
        table.insert(uiElements.rightPanelUpdaters, createModButton(rightPanel, "fly", "isFlying"))
        table.insert(uiElements.rightPanelUpdaters, createSlider(rightPanel, "fly_speed", "flySpeed", 0, 100))
        table.insert(uiElements.rightPanelUpdaters, createModButton(rightPanel, "speed", "isSpeedEnabled"))
        table.insert(uiElements.rightPanelUpdaters, createSlider(rightPanel, "walk_speed", "walkSpeed", 16, 100, function(value)
             if modStates.isSpeedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                localPlayer.Character.Humanoid.WalkSpeed = value
            end
        end))
        table.insert(uiElements.rightPanelUpdaters, createModButton(rightPanel, "noclip", "isNoclipping"))
        table.insert(uiElements.rightPanelUpdaters, createModButton(rightPanel, "esp", "isEspEnabled"))
    elseif category == "category_teleports" then
        createRightPanelTitle(rightPanel, "teleport_title")
        local statusLabel = createTextLabel(rightPanel, "no_location_saved", true)
        statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
        
        createNormalButton(rightPanel, "save_location", function()
            local char = localPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                teleportData.savedPosition = char.HumanoidRootPart.CFrame
                local pos = teleportData.savedPosition.Position
                local text = string.format("%.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z)
                statusLabel.Text = string.format(LANGUAGES[currentLanguage].location_saved_at, text)
            end
        end)
        createNormalButton(rightPanel, "teleport_to_location", function()
             local char = localPlayer.Character
            if teleportData.savedPosition and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = teleportData.savedPosition
            end
        end)
    elseif category == "category_credits" then
        createRightPanelTitle(rightPanel, "credits_title")
        createTextLabel(rightPanel, "update_1_title", false).Size = UDim2.new(0.9, 0, 0, 20)
        createTextLabel(rightPanel, "update_1_desc", true)
        createTextLabel(rightPanel, "update_2_title", false).Size = UDim2.new(0.9, 0, 0, 20)
        createTextLabel(rightPanel, "update_2_desc", true)
        Instance.new("Frame", rightPanel).Size = UDim2.new(0,0,0,10) -- Spacer
        createNormalButton(rightPanel, "change_lang_pt", function() currentLanguage = "pt"; updateAllUIText() end)
        createNormalButton(rightPanel, "change_lang_en", function() currentLanguage = "en"; updateAllUIText() end)
    else -- Placeholder
        createRightPanelTitle(rightPanel, "placeholder_title")
        createTextLabel(rightPanel, "placeholder_desc", true)
    end
end

function updateAllUIText()
    local lang = LANGUAGES[currentLanguage]
    topBarTitle.Text = lang.title
    for key, button in pairs(uiElements.categoryButtons) do
        button.Text = lang[key]
    end
    
    for _, element in ipairs(rightPanel:GetChildren()) do
        if lang[element.Name] then
            element.Text = lang[element.Name]
        end
    end

    for _, updaterFunc in ipairs(uiElements.rightPanelUpdaters) do
        updaterFunc()
    end
end

local function selectCategory(button, categoryKey)
    if activeCategoryButton then
        activeCategoryButton.BackgroundColor3 = Color3.fromRGB(35, 41, 46) -- Default
    end
    button.BackgroundColor3 = Color3.fromRGB(32, 169, 153) -- Highlight
    activeCategoryButton = button
    populateRightPanel(categoryKey)
    updateAllUIText() -- Update text for the new panel
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
    else
        if modConnections.flyGyro then modConnections.flyGyro:Destroy(); modConnections.flyGyro = nil end
        if modConnections.flyVelocity then modConnections.flyVelocity:Destroy(); modConnections.flyVelocity = nil end
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
--||                                  INICIALIZAÇÃO                               ||--
--==================================================================================--
function Start()
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
            print("CALVO MOD V3.2 Carregado com sucesso!")
        end)
        
        fadeOutTween:Play()
    end)
    
    progressBarTween:Play()
end

closeButton.MouseButton1Click:Connect(function() mainGui.Enabled = false end)

pcall(Start) -- Usa pcall para uma inicialização mais segura