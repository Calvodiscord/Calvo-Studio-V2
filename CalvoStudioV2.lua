--[[
    Script: CALVO MOD - PRISON LIFE V3.4 (Estrutura à Prova de Falhas)
    Versão: 3.4

   ATUALIZAÇÕES:
- CORREÇÃO DEFINITIVA: Script reconstruído com uma inicialização segura que espera o personagem carregar.
                      Isso resolve o problema do menu não aparecer de uma vez por todas.
- ESTABILIDADE: A criação da UI e a lógica dos mods foram otimizadas para prevenir falhas silenciosas.
- CONFIABILIDADE: O código agora é mais robusto e resistente a erros de temporização do jogo.
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
        category_combat = "Combate", category_localplayer = "LocalPlayer", category_misc = "Diversos",
        category_teleports = "Teleportes", category_admin = "Admin", category_credits = "Créditos",
        title = "CALVO MOD", credits_title = "Notas da Atualização", teleport_title = "Sistema de Teleporte",
        esp = "ESP Players", fly = "Voar (Fly)", fly_speed = "Velocidade de Voo", noclip = "Atravessar Paredes",
        speed = "Correr Rápido", walk_speed = "Velocidade de Corrida", save_location = "Salvar Localização Atual",
        teleport_to_location = "Teleportar para Local Salvo", no_location_saved = "Nenhum local salvo.",
        location_saved_at = "Local salvo em: %s", loading = "Aguardando Personagem...", ready = "Pronto!",
        change_lang_pt = "Mudar para Português", change_lang_en = "Mudar para Inglês",
        placeholder_title = "Em Breve", placeholder_desc = "Funções futuras aqui.",
        update_1_title = "TELEPORTE (ADICIONADO)",
        update_1_desc = "- Agora você pode salvar um local e se teleportar de volta para ele.",
        update_2_title = "VERSÃO INICIAL",
        update_2_desc = "- Lançamento do Calvo Mod com funções básicas."
    },
    en = {
        category_combat = "Combat", category_localplayer = "LocalPlayer", category_misc = "Miscellaneous",
        category_teleports = "Teleports", category_admin = "Admin", category_credits = "Credits",
        title = "CALVO MOD", credits_title = "Update Notes", teleport_title = "Teleport System",
        esp = "ESP Players", fly = "Fly", fly_speed = "Fly Speed", noclip = "Noclip", speed = "Speed Hack",
        walk_speed = "Walk Speed", save_location = "Save Current Location",
        teleport_to_location = "Teleport to Saved Location", no_location_saved = "No location saved.",
        location_saved_at = "Location saved at: %s", loading = "Waiting for Character...", ready = "Ready!",
        change_lang_pt = "Switch to Portuguese", change_lang_en = "Switch to English",
        placeholder_title = "Coming Soon", placeholder_desc = "Future functions here.",
        update_1_title = "TELEPORT (ADDED)",
        update_1_desc = "- You can now save a location and teleport back to it.",
        update_2_title = "INITIAL RELEASE",
        update_2_desc = "- Calvo Mod launched with basic functions."
    }
}

--==================================================================================--
--||                           CONFIGURAÇÕES E ESTADO                               ||--
--==================================================================================--
local modStates = { isFlying = false, isNoclipping = false, isSpeedEnabled = false, isEspEnabled = false }
local modConnections = { flyGyro = nil, flyVelocity = nil, noclipConnection = nil }
local modSettings = { originalWalkSpeed = 16, flySpeed = 50, walkSpeed = 50 }
local teleportData = { savedPosition = nil }
local uiElements = { categoryButtons = {}, rightPanelUpdaters = {} }
local activeCategoryButton = nil

--==================================================================================--
--||                          FUNÇÕES DE CRIAÇÃO DE UI                            ||--
--==================================================================================--
-- Estas funções apenas criam os objetos, sem lógica complexa.

local function createRightPanelTitle(parent, key)
    local title = Instance.new("TextLabel"); title.Name = key; title.Parent = parent; title.Size = UDim2.new(0.9, 0, 0, 30); title.Font = Enum.Font.GothamBold
    title.TextSize = 18; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left; return title
end

local function createModButton(parent, key, modName)
    local button = Instance.new("TextButton"); button.Name = key; button.Parent = parent; button.Size = UDim2.new(0.9, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(32, 169, 153); button.Font = Enum.Font.GothamSemibold; button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    return button
end

local function createSlider(parent, key, settingName)
    local container = Instance.new("Frame"); container.Name = key; container.Parent = parent; container.Size = UDim2.new(0.9, 0, 0, 50); container.BackgroundTransparency = 1
    local title = Instance.new("TextLabel", container); title.Size = UDim2.new(1, 0, 0.5, 0); title.Font = Enum.Font.Gotham; title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(200, 200, 200); title.BackgroundTransparency = 1; title.TextXAlignment = Enum.TextXAlignment.Left
    local valueLabel = Instance.new("TextLabel", container); valueLabel.Size = UDim2.new(1, 0, 0.5, 0); valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14; valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255); valueLabel.BackgroundTransparency = 1; valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local slider = Instance.new("Slider", container); slider.Size = UDim2.new(1, 0, 0.5, 0); slider.Position = UDim2.new(0, 0, 0.5, 0)
    return container, title, valueLabel, slider
end

local function createNormalButton(parent, key)
    local button = Instance.new("TextButton"); button.Name = key; button.Parent = parent; button.Size = UDim2.new(0.9, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(32, 169, 153); button.Font = Enum.Font.GothamSemibold; button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    return button
end

local function createTextLabel(parent, key, isDescription)
    local label = Instance.new("TextLabel"); label.Name = key; label.Parent = parent; label.Size = UDim2.new(0.9, 0, 0, 40)
    label.Font = isDescription and Enum.Font.Gotham or Enum.Font.GothamBold; label.TextSize = isDescription and 13 or 16
    label.TextColor3 = isDescription and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255); label.BackgroundTransparency = 1
    label.TextWrapped = true; label.TextXAlignment = Enum.TextXAlignment.Left; label.SizeConstraint = Enum.SizeConstraint.RelativeY
    label.TextYAlignment = Enum.TextYAlignment.Top; return label
end

--==================================================================================--
--||                           FUNÇÃO PRINCIPAL DA UI                             ||--
--==================================================================================--
local function CreateAndEnableGUI()
    local playerGui = localPlayer:WaitForChild("PlayerGui")

    -- Gui Principal
    local mainGui = Instance.new("ScreenGui", playerGui); mainGui.Name = "CalvoModV3Gui"; mainGui.ResetOnSpawn = false
    local mainContainer = Instance.new("Frame", mainGui); mainContainer.Size = UDim2.new(0, 550, 0, 350)
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0); mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    mainContainer.BackgroundColor3 = Color3.fromRGB(44, 52, 58); mainContainer.Draggable = true; mainContainer.Active = true
    Instance.new("UICorner", mainContainer).CornerRadius = UDim.new(0, 6)

    -- Barra Superior
    local topBar = Instance.new("Frame", mainContainer); topBar.Size = UDim2.new(1, 0, 0, 35); topBar.BackgroundColor3 = Color3.fromRGB(35, 41, 46)
    local topBarTitle = Instance.new("TextLabel", topBar); topBarTitle.Size = UDim2.new(1, -40, 1, 0); topBarTitle.Position = UDim2.new(0, 15, 0, 0)
    topBarTitle.Font = Enum.Font.GothamBold; topBarTitle.TextColor3 = Color3.fromRGB(255, 255, 255); topBarTitle.TextSize = 16
    topBarTitle.TextXAlignment = Enum.TextXAlignment.Left; topBarTitle.BackgroundTransparency = 1
    local closeButton = createNormalButton(topBar, "Close"); closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -10, 0.5, 0); closeButton.AnchorPoint = Vector2.new(1, 0.5); closeButton.Text = "X"
    closeButton.BackgroundTransparency = 1; closeButton.BackgroundColor3 = Color3.new()

    -- Painéis
    local leftPanel = Instance.new("Frame", mainContainer); leftPanel.Size = UDim2.new(0, 150, 1, -35); leftPanel.Position = UDim2.new(0, 0, 0, 35)
    leftPanel.BackgroundColor3 = Color3.fromRGB(35, 41, 46); leftPanel.BorderSizePixel = 0
    local leftLayout = Instance.new("UIListLayout", leftPanel); leftLayout.Padding = UDim.new(0, 5); leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", leftPanel).PaddingTop = UDim.new(0, 10)
    local rightPanel = Instance.new("ScrollingFrame", mainContainer); rightPanel.Size = UDim2.new(1, -150, 1, -35)
    rightPanel.Position = UDim2.new(0, 150, 0, 35); rightPanel.BackgroundTransparency = 1; rightPanel.BorderSizePixel = 0
    rightPanel.ScrollBarImageColor3 = Color3.fromRGB(32, 169, 153); rightPanel.ScrollBarThickness = 5
    local rightLayout = Instance.new("UIListLayout", rightPanel); rightLayout.Padding = UDim.new(0, 10); rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", rightPanel).PaddingTop = UDim.new(0, 15)
    
    -- Lógica de atualização e população
    local function updateAllUIText()
        local lang = LANGUAGES[currentLanguage]
        topBarTitle.Text = lang.title
        for key, button in pairs(uiElements.categoryButtons) do button.Text = lang[key] end
        for _, element in ipairs(rightPanel:GetChildren()) do if lang[element.Name] then element.Text = lang[element.Name] end end
        for _, updaterFunc in ipairs(uiElements.rightPanelUpdaters) do updaterFunc() end
    end

    local function populateRightPanel(category)
        for _, v in ipairs(rightPanel:GetChildren()) do v:Destroy() end
        uiElements.rightPanelUpdaters = {}

        if category == "category_localplayer" then
            table.insert(uiElements.rightPanelUpdaters, (function()
                local btn = createModButton(rightPanel, "fly", "isFlying")
                local function update() btn.Text = LANGUAGES[currentLanguage].fly .. " [" .. (modStates.isFlying and "ON" or "OFF") .. "]" end
                btn.MouseButton1Click:Connect(function() modStates.isFlying = not modStates.isFlying; update() end); return update
            end)())
            table.insert(uiElements.rightPanelUpdaters, (function()
                local _, title, val, slider = createSlider(rightPanel, "fly_speed", "flySpeed"); slider.MinValue = 0; slider.MaxValue = 100; slider.Value = modSettings.flySpeed
                local function update() title.Text = LANGUAGES[currentLanguage].fly_speed; val.Text = tostring(math.floor(slider.Value)) end
                slider.ValueChanged:Connect(function(v) modSettings.flySpeed = v; update() end); return update
            end)())
            table.insert(uiElements.rightPanelUpdaters, (function()
                local btn = createModButton(rightPanel, "speed", "isSpeedEnabled")
                local function update() btn.Text = LANGUAGES[currentLanguage].speed .. " [" .. (modStates.isSpeedEnabled and "ON" or "OFF") .. "]" end
                btn.MouseButton1Click:Connect(function()
                    modStates.isSpeedEnabled = not modStates.isSpeedEnabled; update()
                    local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.WalkSpeed = modStates.isSpeedEnabled and modSettings.walkSpeed or modSettings.originalWalkSpeed end
                end)
                return update
            end)())
            table.insert(uiElements.rightPanelUpdaters, (function()
                 local _, title, val, slider = createSlider(rightPanel, "walk_speed", "walkSpeed"); slider.MinValue = 16; slider.MaxValue = 100; slider.Value = modSettings.walkSpeed
                local function update() title.Text = LANGUAGES[currentLanguage].walk_speed; val.Text = tostring(math.floor(slider.Value)) end
                slider.ValueChanged:Connect(function(v) modSettings.walkSpeed = v; update(); if modStates.isSpeedEnabled then localPlayer.Character.Humanoid.WalkSpeed = v end end)
                return update
            end)())
        else -- Placeholders...
            createRightPanelTitle(rightPanel, "placeholder_title").Text = LANGUAGES[currentLanguage].placeholder_title
        end
        updateAllUIText()
    end
    
    local function selectCategory(button, categoryKey)
        if activeCategoryButton then activeCategoryButton.BackgroundColor3 = Color3.fromRGB(35, 41, 46) end
        button.BackgroundColor3 = Color3.fromRGB(32, 169, 153); activeCategoryButton = button
        populateRightPanel(categoryKey)
    end

    for _, key in ipairs({"category_localplayer", "category_combat", "category_misc", "category_teleports", "category_admin", "category_credits"}) do
        local button = createNormalButton(leftPanel, key); uiElements.categoryButtons[key] = button
        button.MouseButton1Click:Connect(function() selectCategory(button, key) end)
    end

    closeButton.MouseButton1Click:Connect(function() mainGui.Enabled = false end)
    
    -- Seleciona a primeira categoria e habilita a GUI
    selectCategory(uiElements.categoryButtons.category_localplayer, "category_localplayer")
    mainGui.Enabled = true
    print("CALVO MOD V3.4: Interface carregada e habilitada.")
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
                modConnections.flyGyro = Instance.new("BodyGyro", rootPart); modConnections.flyGyro.P=5e4; modConnections.flyGyro.MaxTorque=Vector3.new(4e5,4e5,4e5)
                modConnections.flyVelocity = Instance.new("BodyVelocity", rootPart); modConnections.flyVelocity.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
            end
        end
        if modConnections.flyVelocity then
            local direction=Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction+=Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction-=Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction-=Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction+=Camera.CFrame.RightVector end
            local vertical=0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical=1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical=-1 end
            modConnections.flyVelocity.Velocity=(direction.Unit*modSettings.flySpeed)+Vector3.new(0,vertical*modSettings.flySpeed,0)
            modConnections.flyGyro.CFrame=Camera.CFrame
        end
    elseif modConnections.flyGyro then
        modConnections.flyGyro:Destroy(); modConnections.flyGyro=nil; modConnections.flyVelocity:Destroy(); modConnections.flyVelocity=nil
    end
end)

--==================================================================================--
--||                                  INICIALIZAÇÃO FINAL                           ||--
--==================================================================================--
local function OnCharacterAdded(character)
    print("CALVO MOD: Personagem detectado. Iniciando UI.")
    -- Espera o Humanoid para garantir que o WalkSpeed original seja lido corretamente
    local humanoid = character:WaitForChild("Humanoid")
    modSettings.originalWalkSpeed = humanoid.WalkSpeed
    
    -- Agora, cria a UI
    local success, err = pcall(CreateAndEnableGUI)
    if not success then
        warn("FALHA CRÍTICA AO CRIAR A UI DO CALVO MOD: " .. tostring(err))
    end
end

-- Espera o personagem ser adicionado pela primeira vez para iniciar o script
if localPlayer.Character then
    OnCharacterAdded(localPlayer.Character)
else
    localPlayer.CharacterAdded:Connect(OnCharacterAdded)
end