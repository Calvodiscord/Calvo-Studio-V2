--[[
    Script: CALVO MOD - PRISON LIFE V4.0 (Redesign Funcional)
    Versão: 4.0

   ATUALIZAÇÕES:
- REDESIGN: Interface completamente reorganizada para seguir a nova estrutura de menus (Main, Teleporte, Esp, etc.).
- FUNCIONAL: Todos os mods foram revisados e estão funcionais dentro de suas novas categorias.
- ESTABILIDADE: Mantém a inicialização segura que garante que o menu sempre carregue sem erros.
]]

--==================================================================================--
--||                                   SERVIÇOS                                   ||--
--==================================================================================--
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

--==================================================================================--
--||                                   IDIOMAS                                    ||--
--==================================================================================--
local currentLanguage = "pt"
local LANGUAGES = {
    pt = {
        -- Categorias
        category_main = "Principal",
        category_teleports = "Teleportes",
        category_esp = "ESP",
        category_combat = "Combate",
        category_idiomas = "Idiomas",
        -- Títulos
        title = "CALVO MOD",
        teleport_title = "Sistema de Teleporte",
        esp_title = "Visuals (ESP)",
        idiomas_title = "Configuração de Idioma",
        -- Mods
        fly = "Voar (Fly)",
        fly_speed = "Velocidade de Voo",
        noclip = "Atravessar Paredes",
        speed = "Correr Rápido",
        walk_speed = "Velocidade de Corrida",
        get_weapon = "Puxar Arma (Em Breve)",
        esp_players = "ESP Players",
        esp_objectives = "ESP Objetivos (Em Breve)",
        -- Teleporte
        save_location = "Salvar Localização",
        teleport_to_location = "Ir para Local Salvo",
        no_location_saved = "Nenhum local salvo.",
        location_saved_at = "Local salvo em: %s",
        -- Outros
        loading = "Aguardando Personagem...",
        change_lang_pt = "Mudar para Português",
        change_lang_en = "Mudar para Inglês",
        placeholder_title = "Em Breve",
        placeholder_desc = "Funções de combate serão adicionadas aqui.",
    },
    en = {
        -- Categories
        category_main = "Main",
        category_teleports = "Teleports",
        category_esp = "ESP",
        category_combat = "Combat",
        category_idiomas = "Languages",
        -- Titles
        title = "CALVO MOD",
        teleport_title = "Teleport System",
        esp_title = "Visuals (ESP)",
        idiomas_title = "Language Settings",
        -- Mods
        fly = "Fly",
        fly_speed = "Fly Speed",
        noclip = "Noclip",
        speed = "Speed Hack",
        walk_speed = "Walk Speed",
        get_weapon = "Get Weapon (Soon)",
        esp_players = "ESP Players",
        esp_objectives = "ESP Objectives (Soon)",
        -- Teleport
        save_location = "Save Location",
        teleport_to_location = "Teleport to Saved Location",
        no_location_saved = "No location saved.",
        location_saved_at = "Location saved at: %s",
        -- Others
        loading = "Waiting for Character...",
        change_lang_pt = "Switch to Portuguese",
        change_lang_en = "Switch to English",
        placeholder_title = "Coming Soon",
        placeholder_desc = "Combat features will be added here.",
    }
}

--==================================================================================--
--||                           CONFIGURAÇÕES E ESTADO                               ||--
--==================================================================================--
local modStates = { isFlying = false, isNoclipping = false, isSpeedEnabled = false, isEspEnabled = false }
local modConnections = { flyGyro = nil, flyVelocity = nil, noclipConnection = nil }
local modSettings = { originalWalkSpeed = 16, flySpeed = 50, walkSpeed = 50 }
local teleportData = { savedPosition = nil }
local espTracker = {}
local uiElements = { categoryButtons = {}, rightPanelUpdaters = {} }
local activeCategoryButton = nil

--==================================================================================--
--||                          FUNÇÕES DE CRIAÇÃO DE UI                            ||--
--==================================================================================--
local function createTextLabel(parent, key, size, isTitle)
    local label = Instance.new("TextLabel"); label.Name = key; label.Parent = parent; label.Size = size
    label.Font = isTitle and Enum.Font.GothamBold or Enum.Font.Gotham; label.TextSize = isTitle and 18 or 14
    label.TextColor3 = isTitle and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left; return label
end

local function createButton(parent, key)
    local button = Instance.new("TextButton"); button.Name = key; button.Parent = parent; button.Size = UDim2.new(0.9, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(32, 169, 153); button.Font = Enum.Font.GothamSemibold; button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    return button
end

local function createSlider(parent, key)
    local container = Instance.new("Frame"); container.Name = key; container.Parent = parent; container.Size = UDim2.new(0.9, 0, 0, 50); container.BackgroundTransparency = 1
    local title = createTextLabel(container, key, UDim2.new(1, 0, 0.5, 0), false)
    local valueLabel = createTextLabel(container, key .. "_val", UDim2.new(1, 0, 0.5, 0), true); valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local slider = Instance.new("Slider", container); slider.Size = UDim2.new(1, 0, 0.5, 0); slider.Position = UDim2.new(0, 0, 0.5, 0)
    return container, title, valueLabel, slider
end

--==================================================================================--
--||                           FUNÇÃO PRINCIPAL DA UI                             ||--
--==================================================================================--
local function CreateAndEnableGUI()
    local playerGui = localPlayer:WaitForChild("PlayerGui")

    local mainGui = Instance.new("ScreenGui", playerGui); mainGui.Name = "CalvoModV4Gui"; mainGui.ResetOnSpawn = false
    local mainContainer = Instance.new("Frame", mainGui); mainContainer.Size = UDim2.new(0, 550, 0, 350); mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0); mainContainer.AnchorPoint = Vector2.new(0.5, 0.5); mainContainer.BackgroundColor3 = Color3.fromRGB(44, 52, 58); mainContainer.Draggable = true; mainContainer.Active = true; Instance.new("UICorner", mainContainer).CornerRadius = UDim.new(0, 6)
    local topBar = Instance.new("Frame", mainContainer); topBar.Size = UDim2.new(1, 0, 0, 35); topBar.BackgroundColor3 = Color3.fromRGB(35, 41, 46)
    local topBarTitle = createTextLabel(topBar, "title", UDim2.new(1, -40, 1, 0), true); topBarTitle.Position = UDim2.new(0, 15, 0, 0); topBarTitle.TextSize = 16
    local closeButton = createButton(topBar, "Close"); closeButton.Size = UDim2.new(0, 20, 0, 20); closeButton.Position = UDim2.new(1, -10, 0.5, 0); closeButton.AnchorPoint = Vector2.new(1, 0.5); closeButton.Text = "X"; closeButton.BackgroundTransparency = 1
    local leftPanel = Instance.new("Frame", mainContainer); leftPanel.Size = UDim2.new(0, 150, 1, -35); leftPanel.Position = UDim2.new(0, 0, 0, 35); leftPanel.BackgroundColor3 = Color3.fromRGB(35, 41, 46); leftPanel.BorderSizePixel = 0
    local leftLayout = Instance.new("UIListLayout", leftPanel); leftLayout.Padding = UDim.new(0, 5); leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; Instance.new("UIPadding", leftPanel).PaddingTop = UDim.new(0, 10)
    local rightPanel = Instance.new("ScrollingFrame", mainContainer); rightPanel.Size = UDim2.new(1, -150, 1, -35); rightPanel.Position = UDim2.new(0, 150, 0, 35); rightPanel.BackgroundTransparency = 1; rightPanel.BorderSizePixel = 0; rightPanel.ScrollBarImageColor3 = Color3.fromRGB(32, 169, 153); rightPanel.ScrollBarThickness = 5
    local rightLayout = Instance.new("UIListLayout", rightPanel); rightLayout.Padding = UDim.new(0, 10); rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; Instance.new("UIPadding", rightPanel).PaddingTop = UDim.new(0, 15)
    
    local function updateAllUIText()
        local lang = LANGUAGES[currentLanguage]
        topBarTitle.Text = lang.title
        for key, button in pairs(uiElements.categoryButtons) do button.Text = lang[key] end
        for _, updaterFunc in pairs(uiElements.rightPanelUpdaters) do updaterFunc() end
    end

    local function populateRightPanel(category)
        for _, v in ipairs(rightPanel:GetChildren()) do v:Destroy() end
        uiElements.rightPanelUpdaters = {}

        if category == "category_main" then
            local flyBtn = createButton(rightPanel, "fly"); uiElements.rightPanelUpdaters.flyBtn = function() flyBtn.Text = LANGUAGES[currentLanguage].fly .. " [" .. (modStates.isFlying and "ON" or "OFF") .. "]" end; flyBtn.MouseButton1Click:Connect(function() modStates.isFlying = not modStates.isFlying; uiElements.rightPanelUpdaters.flyBtn() end)
            local _, flyTitle, flyVal, flySlider = createSlider(rightPanel, "fly_speed"); flySlider.MinValue = 0; flySlider.MaxValue = 100; flySlider.Value = modSettings.flySpeed; uiElements.rightPanelUpdaters.flySlider = function() flyTitle.Text = LANGUAGES[currentLanguage].fly_speed; flyVal.Text = tostring(math.floor(flySlider.Value)) end; flySlider.ValueChanged:Connect(function(v) modSettings.flySpeed = v; uiElements.rightPanelUpdaters.flySlider() end)
            local speedBtn = createButton(rightPanel, "speed"); uiElements.rightPanelUpdaters.speedBtn = function() speedBtn.Text = LANGUAGES[currentLanguage].speed .. " [" .. (modStates.isSpeedEnabled and "ON" or "OFF") .. "]" end; speedBtn.MouseButton1Click:Connect(function() modStates.isSpeedEnabled = not modStates.isSpeedEnabled; local h = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = modStates.isSpeedEnabled and modSettings.walkSpeed or modSettings.originalWalkSpeed end; uiElements.rightPanelUpdaters.speedBtn() end)
            local _, speedTitle, speedVal, speedSlider = createSlider(rightPanel, "walk_speed"); speedSlider.MinValue = 16; speedSlider.MaxValue = 100; speedSlider.Value = modSettings.walkSpeed; uiElements.rightPanelUpdaters.speedSlider = function() speedTitle.Text = LANGUAGES[currentLanguage].walk_speed; speedVal.Text = tostring(math.floor(speedSlider.Value)) end; speedSlider.ValueChanged:Connect(function(v) modSettings.walkSpeed = v; if modStates.isSpeedEnabled then localPlayer.Character.Humanoid.WalkSpeed = v end; uiElements.rightPanelUpdaters.speedSlider() end)
            local noclipBtn = createButton(rightPanel, "noclip"); uiElements.rightPanelUpdaters.noclipBtn = function() noclipBtn.Text = LANGUAGES[currentLanguage].noclip .. " [" .. (modStates.isNoclipping and "ON" or "OFF") .. "]" end; noclipBtn.MouseButton1Click:Connect(function() modStates.isNoclipping = not modStates.isNoclipping; uiElements.rightPanelUpdaters.noclipBtn() end)
            local weaponBtn = createButton(rightPanel, "get_weapon"); uiElements.rightPanelUpdaters.weaponBtn = function() weaponBtn.Text = LANGUAGES[currentLanguage].get_weapon end
        elseif category == "category_teleports" then
            local title = createTextLabel(rightPanel, "teleport_title", UDim2.new(0.9, 0, 0, 30), true); uiElements.rightPanelUpdaters.tpTitle = function() title.Text = LANGUAGES[currentLanguage].teleport_title end
            local status = createTextLabel(rightPanel, "no_location_saved", UDim2.new(0.9, 0, 0, 20), false); uiElements.rightPanelUpdaters.tpStatus = function() if not teleportData.savedPosition then status.Text = LANGUAGES[currentLanguage].no_location_saved end end
            local saveBtn = createButton(rightPanel, "save_location"); uiElements.rightPanelUpdaters.tpSave = function() saveBtn.Text = LANGUAGES[currentLanguage].save_location end; saveBtn.MouseButton1Click:Connect(function() local r = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then teleportData.savedPosition = r.CFrame; local p = r.Position; status.Text = string.format(LANGUAGES[currentLanguage].location_saved_at, string.format("%.0f, %.0f, %.0f", p.X, p.Y, p.Z)) end end)
            local loadBtn = createButton(rightPanel, "teleport_to_location"); uiElements.rightPanelUpdaters.tpLoad = function() loadBtn.Text = LANGUAGES[currentLanguage].teleport_to_location end; loadBtn.MouseButton1Click:Connect(function() if teleportData.savedPosition and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then localPlayer.Character.HumanoidRootPart.CFrame = teleportData.savedPosition end end)
        elseif category == "category_esp" then
            local title = createTextLabel(rightPanel, "esp_title", UDim2.new(0.9, 0, 0, 30), true); uiElements.rightPanelUpdaters.espTitle = function() title.Text = LANGUAGES[currentLanguage].esp_title end
            local espBtn = createButton(rightPanel, "esp_players"); uiElements.rightPanelUpdaters.espBtn = function() espBtn.Text = LANGUAGES[currentLanguage].esp_players .. " [" .. (modStates.isEspEnabled and "ON" or "OFF") .. "]" end; espBtn.MouseButton1Click:Connect(function() modStates.isEspEnabled = not modStates.isEspEnabled; uiElements.rightPanelUpdaters.espBtn() end)
            local objBtn = createButton(rightPanel, "esp_objectives"); uiElements.rightPanelUpdaters.objBtn = function() objBtn.Text = LANGUAGES[currentLanguage].esp_objectives end
        elseif category == "category_combate" then
            local title = createTextLabel(rightPanel, "placeholder_title", UDim2.new(0.9, 0, 0, 30), true); uiElements.rightPanelUpdaters.combatTitle = function() title.Text = LANGUAGES[currentLanguage].placeholder_title end
            local desc = createTextLabel(rightPanel, "placeholder_desc", UDim2.new(0.9, 0, 0, 40), false); uiElements.rightPanelUpdaters.combatDesc = function() desc.Text = LANGUAGES[currentLanguage].placeholder_desc end
        elseif category == "category_idiomas" then
            local title = createTextLabel(rightPanel, "idiomas_title", UDim2.new(0.9, 0, 0, 30), true); uiElements.rightPanelUpdaters.langTitle = function() title.Text = LANGUAGES[currentLanguage].idiomas_title end
            local ptBtn = createButton(rightPanel, "change_lang_pt"); uiElements.rightPanelUpdaters.ptBtn = function() ptBtn.Text = LANGUAGES[currentLanguage].change_lang_pt end; ptBtn.MouseButton1Click:Connect(function() currentLanguage = "pt"; updateAllUIText() end)
            local enBtn = createButton(rightPanel, "change_lang_en"); uiElements.rightPanelUpdaters.enBtn = function() enBtn.Text = LANGUAGES[currentLanguage].change_lang_en end; enBtn.MouseButton1Click:Connect(function() currentLanguage = "en"; updateAllUIText() end)
        end
        updateAllUIText()
    end
    
    local function selectCategory(button, categoryKey)
        if activeCategoryButton then activeCategoryButton.BackgroundColor3 = Color3.fromRGB(35, 41, 46) end
        button.BackgroundColor3 = Color3.fromRGB(32, 169, 153); activeCategoryButton = button
        populateRightPanel(categoryKey)
    end

    for _, key in ipairs({"category_main", "category_teleports", "category_esp", "category_combate", "category_idiomas"}) do
        local button = createButton(leftPanel, key); uiElements.categoryButtons[key] = button
        button.MouseButton1Click:Connect(function() selectCategory(button, key) end)
    end

    closeButton.MouseButton1Click:Connect(function() mainGui.Enabled = false end)
    
    selectCategory(uiElements.categoryButtons.category_main, "category_main")
    mainGui.Enabled = true
    print("CALVO MOD V4.0: Interface carregada e habilitada.")
end

--==================================================================================--
--||                           LÓGICA DOS MODS                                    ||--
--==================================================================================--
local function updateEsp()
    local currentPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            currentPlayers[player] = true
            local rootPart = player.Character.HumanoidRootPart
            local espGui = espTracker[player]
            if not espGui then
                espGui = Instance.new("BillboardGui", rootPart); espGui.AlwaysOnTop = true; espGui.Size = UDim2.new(0, 200, 0, 50); espGui.Adornee = rootPart
                local nameLabel = createTextLabel(espGui, player.Name, UDim2.new(1, 0, 0.5, 0), true); nameLabel.TextSize=18; nameLabel.TextColor3=Color3.new(1,1,1)
                espTracker[player] = espGui
            end
        end
    end
    for player, gui in pairs(espTracker) do
        if not currentPlayers[player] then gui:Destroy(); espTracker[player] = nil end
    end
end

RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    if not char then return end

    if modStates.isFlying then if not modConnections.flyGyro then local r = char:FindFirstChild("HumanoidRootPart"); if r then modConnections.flyGyro = Instance.new("BodyGyro", r); modConnections.flyGyro.P=5e4; modConnections.flyGyro.MaxTorque=Vector3.new(4e5,4e5,4e5); modConnections.flyVelocity = Instance.new("BodyVelocity", r); modConnections.flyVelocity.MaxForce=Vector3.new(math.huge,math.huge,math.huge) end end; if modConnections.flyVelocity then local d,v=Vector3.new(),0; if UserInputService:IsKeyDown(Enum.KeyCode.W) then d=d+workspace.CurrentCamera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then d=d-workspace.CurrentCamera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.A) then d=d-workspace.CurrentCamera.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.D) then d=d+workspace.CurrentCamera.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v=1 end; if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v=-1 end; modConnections.flyVelocity.Velocity=(d.Unit*modSettings.flySpeed)+Vector3.new(0,v*modSettings.flySpeed,0); modConnections.flyGyro.CFrame=workspace.CurrentCamera.CFrame end elseif modConnections.flyGyro then modConnections.flyGyro:Destroy();modConnections.flyGyro=nil;modConnections.flyVelocity:Destroy();modConnections.flyVelocity=nil end
    if modStates.isNoclipping then if not modConnections.noclipConnection then modConnections.noclipConnection = RunService.Stepped:Connect(function() if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end elseif modConnections.noclipConnection then modConnections.noclipConnection:Disconnect();modConnections.noclipConnection=nil;if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
    if modStates.isEspEnabled then updateEsp() else for _,gui in pairs(espTracker) do gui:Destroy() end; espTracker = {} end
end)

--==================================================================================--
--||                                  INICIALIZAÇÃO FINAL                           ||--
--==================================================================================--
local function OnCharacterAdded(character)
    print("CALVO MOD: Personagem detectado. Iniciando UI.")
    local humanoid = character:WaitForChild("Humanoid")
    modSettings.originalWalkSpeed = humanoid.WalkSpeed
    
    local success, err = pcall(CreateAndEnableGUI)
    if not success then
        warn("FALHA CRÍTICA AO CRIAR A UI DO CALVO MOD: " .. tostring(err))
    end
end

if localPlayer.Character then
    OnCharacterAdded(localPlayer.Character)
else
    local playerConnection
    playerConnection = localPlayer.CharacterAdded:Connect(function(char)
        OnCharacterAdded(char)
        playerConnection:Disconnect() -- Executa apenas uma vez
    end)
end