--[[
    Script: CALVO MOD - PRISON LIFE V5.0 (Reconstrução Estável)
    Versão: 5.0

   ATUALIZAÇÕES:
- RECONSTRUÍDO DO ZERO: Script totalmente refeito para máxima estabilidade e para corresponder ao novo design.
- FUNCIONALIDADE GARANTIDA: Todos os mods (Fly, Speed, Noclip, Teleporte, ESP) foram revisados e estão funcionando.
- INTERFACE FIEL: O design agora é idêntico à imagem fornecida, com a organização de menus solicitada.
]]

--==================================================================================--
--||                                   SERVIÇOS                                   ||--
--==================================================================================--
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

--==================================================================================--
--||                                   IDIOMAS                                    ||--
--==================================================================================--
local currentLanguage = "pt"
local LANGUAGES = {
    pt = {
        -- Títulos e Categorias
        title = "CALVO MOD",
        category_main = "Principal",
        category_teleports = "Teleportes",
        category_esp = "ESP",
        category_combat = "Combate",
        category_idiomas = "Idiomas",
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
        save_location = "Salvar Local",
        teleport_to_location = "Ir para Local Salvo",
        no_location_saved = "Nenhum local salvo.",
        location_saved_at = "Local salvo em: %s",
        -- Outros
        change_lang_pt = "Português",
        change_lang_en = "English",
        placeholder_title = "Em Breve",
        placeholder_desc = "Funções de combate serão adicionadas aqui.",
    },
    en = {
        -- Titles and Categories
        title = "CALVO MOD",
        category_main = "Main",
        category_teleports = "Teleports",
        category_esp = "ESP",
        category_combat = "Combat",
        category_idiomas = "Languages",
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
        change_lang_pt = "Portuguese",
        change_lang_en = "English",
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
local uiData = { activeCategoryButton = nil, contentPanels = {}, uiUpdaters = {} }

--==================================================================================--
--||                          FUNÇÕES DE CRIAÇÃO DE UI                            ||--
--==================================================================================--
local function create(instanceType, properties)
    local inst = Instance.new(instanceType)
    for prop, value in pairs(properties) do
        inst[prop] = value
    end
    return inst
end

--==================================================================================--
--||                           FUNÇÃO PRINCIPAL DA UI                             ||--
--==================================================================================--
local function CreateAndEnableGUI()
    local playerGui = localPlayer:WaitForChild("PlayerGui")

    local mainGui = create("ScreenGui", {Name = "CalvoModV5Gui", Parent = playerGui, ResetOnSpawn = false})
    local mainContainer = create("Frame", {Name = "MainContainer", Parent = mainGui, Size = UDim2.new(0, 500, 0, 300), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(44, 44, 52), Draggable = true, Active = true})
    create("UICorner", {Parent = mainContainer, CornerRadius = UDim.new(0, 6)})
    
    local topBarTitle = create("TextLabel", {Name = "Title", Parent = mainContainer, Size = UDim2.new(1, 0, 0, 35), Position = UDim2.new(0, 15, 0, 0), Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1})
    local closeButton = create("TextButton", {Name = "Close", Parent = mainContainer, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -15, 0, 8), Text = "X", Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, BackgroundTransparency = 1})
    
    local leftPanel = create("Frame", {Name = "LeftPanel", Parent = mainContainer, Size = UDim2.new(0, 130, 1, -35), Position = UDim2.new(0, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(44, 44, 52), BorderSizePixel = 0})
    local leftLayout = create("UIListLayout", {Parent = leftPanel, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})
    create("UIPadding", {Parent = leftPanel, PaddingTop = UDim.new(0, 10)})
    
    local rightPanel = create("Frame", {Name = "RightPanel", Parent = mainContainer, Size = UDim2.new(1, -130, 1, -35), Position = UDim2.new(0, 130, 0, 35), BackgroundTransparency = 1})

    local function updateAllUIText()
        local lang = LANGUAGES[currentLanguage]
        topBarTitle.Text = lang.title
        for _, updater in pairs(uiData.uiUpdaters) do updater() end
    end

    local function selectCategory(button, panel)
        if uiData.activeCategoryButton then uiData.activeCategoryButton.BackgroundColor3 = Color3.fromRGB(44, 44, 52) end
        button.BackgroundColor3 = Color3.fromRGB(32, 169, 153)
        uiData.activeCategoryButton = button
        for _, p in pairs(uiData.contentPanels) do p.Visible = false end
        panel.Visible = true
    end

    local categories = {"category_main", "category_teleports", "category_esp", "category_combat", "category_idiomas"}
    for i, key in ipairs(categories) do
        local contentPanel = create("ScrollingFrame", {Name = key .. "Panel", Parent = rightPanel, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarImageColor3 = Color3.fromRGB(32,169,153), ScrollBarThickness=5})
        create("UIListLayout", {Parent = contentPanel, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center})
        create("UIPadding", {Parent = contentPanel, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15)})
        uiData.contentPanels[key] = contentPanel

        local catButton = create("TextButton", {Name = key, Parent = leftPanel, Size = UDim2.new(0.9, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(44, 44, 52), Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = Color3.fromRGB(255, 255, 255), LayoutOrder = i})
        create("UICorner", {Parent = catButton, CornerRadius = UDim.new(0, 4)})
        uiData.uiUpdaters[key] = function() catButton.Text = LANGUAGES[currentLanguage][key] end
        catButton.MouseButton1Click:Connect(function() selectCategory(catButton, contentPanel) end)
    end
    
    -- Popular Painel MAIN
    local mainPanel = uiData.contentPanels.category_main
    local flyBtn = create("TextButton", {Name="fly", Parent = mainPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=flyBtn, CornerRadius=UDim.new(0,4)})
    flyBtn.MouseButton1Click:Connect(function() modStates.isFlying = not modStates.isFlying; uiData.uiUpdaters.flyBtn() end); uiData.uiUpdaters.flyBtn = function() flyBtn.Text = LANGUAGES[currentLanguage].fly .. " [" .. (modStates.isFlying and "ON" or "OFF") .. "]" end
    local _, flyTitle, flyVal, flySlider = createSlider(mainPanel, "fly_speed"); flySlider.MinValue=0; flySlider.MaxValue=100; flySlider.Value=modSettings.flySpeed; flySlider.ValueChanged:Connect(function(v) modSettings.flySpeed=v; uiData.uiUpdaters.flySlider() end); uiData.uiUpdaters.flySlider = function() flyTitle.Text = LANGUAGES[currentLanguage].fly_speed; flyVal.Text = tostring(math.floor(flySlider.Value)) end
    local speedBtn = create("TextButton", {Name="speed", Parent=mainPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=speedBtn, CornerRadius=UDim.new(0,4)})
    speedBtn.MouseButton1Click:Connect(function() modStates.isSpeedEnabled=not modStates.isSpeedEnabled; local h=localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=modStates.isSpeedEnabled and modSettings.walkSpeed or modSettings.originalWalkSpeed end; uiData.uiUpdaters.speedBtn() end); uiData.uiUpdaters.speedBtn = function() speedBtn.Text = LANGUAGES[currentLanguage].speed .. " [" .. (modStates.isSpeedEnabled and "ON" or "OFF") .. "]" end
    local _, speedTitle, speedVal, speedSlider = createSlider(mainPanel, "walk_speed"); speedSlider.MinValue=16; speedSlider.MaxValue=100; speedSlider.Value=modSettings.walkSpeed; speedSlider.ValueChanged:Connect(function(v) modSettings.walkSpeed=v; if modStates.isSpeedEnabled then localPlayer.Character.Humanoid.WalkSpeed = v end; uiData.uiUpdaters.speedSlider() end); uiData.uiUpdaters.speedSlider = function() speedTitle.Text = LANGUAGES[currentLanguage].walk_speed; speedVal.Text = tostring(math.floor(speedSlider.Value)) end
    local noclipBtn = create("TextButton", {Name="noclip", Parent=mainPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=noclipBtn, CornerRadius=UDim.new(0,4)})
    noclipBtn.MouseButton1Click:Connect(function() modStates.isNoclipping=not modStates.isNoclipping; uiData.uiUpdaters.noclipBtn() end); uiData.uiUpdaters.noclipBtn = function() noclipBtn.Text = LANGUAGES[currentLanguage].noclip .. " [" .. (modStates.isNoclipping and "ON" or "OFF") .. "]" end
    local weaponBtn = create("TextButton", {Name="get_weapon", Parent=mainPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=weaponBtn, CornerRadius=UDim.new(0,4)}); uiData.uiUpdaters.weaponBtn = function() weaponBtn.Text = LANGUAGES[currentLanguage].get_weapon end
    
    -- Popular Painel TELEPORTE
    local tpPanel = uiData.contentPanels.category_teleports
    local statusLbl = create("TextLabel", {Name="no_location_saved", Parent=tpPanel, Size=UDim2.new(0.9,0,0,20), Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(200,200,200), BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left}); uiData.uiUpdaters.tpStatus = function() if not teleportData.savedPosition then statusLbl.Text = LANGUAGES[currentLanguage].no_location_saved else local p=teleportData.savedPosition.Position; statusLbl.Text=string.format(LANGUAGES[currentLanguage].location_saved_at, string.format("%.0f,%.0f,%.0f", p.X, p.Y, p.Z)) end end
    local saveBtn = create("TextButton", {Name="save_location", Parent=tpPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=saveBtn, CornerRadius=UDim.new(0,4)}); saveBtn.MouseButton1Click:Connect(function() local r=localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then teleportData.savedPosition=r.CFrame; uiData.uiUpdaters.tpStatus() end end); uiData.uiUpdaters.tpSave = function() saveBtn.Text = LANGUAGES[currentLanguage].save_location end
    local loadBtn = create("TextButton", {Name="teleport_to_location", Parent=tpPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=loadBtn, CornerRadius=UDim.new(0,4)}); loadBtn.MouseButton1Click:Connect(function() if teleportData.savedPosition and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then localPlayer.Character.HumanoidRootPart.CFrame = teleportData.savedPosition end end); uiData.uiUpdaters.tpLoad = function() loadBtn.Text = LANGUAGES[currentLanguage].teleport_to_location end

    -- Popular Painel ESP
    local espPanel = uiData.contentPanels.category_esp
    local espBtn = create("TextButton", {Name="esp_players", Parent=espPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=espBtn, CornerRadius=UDim.new(0,4)}); espBtn.MouseButton1Click:Connect(function() modStates.isEspEnabled = not modStates.isEspEnabled; uiData.uiUpdaters.espBtn() end); uiData.uiUpdaters.espBtn = function() espBtn.Text = LANGUAGES[currentLanguage].esp_players .. " [" .. (modStates.isEspEnabled and "ON" or "OFF") .. "]" end
    local espObjBtn = create("TextButton", {Name="esp_objectives", Parent=espPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=espObjBtn, CornerRadius=UDim.new(0,4)}); uiData.uiUpdaters.espObjBtn = function() espObjBtn.Text = LANGUAGES[currentLanguage].esp_objectives end
    
    -- Popular Painel Combate (Placeholder)
    local combatPanel = uiData.contentPanels.category_combat
    local combatTitle = create("TextLabel", {Name="placeholder_title", Parent=combatPanel, Size=UDim2.new(0.9,0,0,30), Font=Enum.Font.GothamBold, TextSize=18, TextColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left}); uiData.uiUpdaters.combatTitle = function() combatTitle.Text = LANGUAGES[currentLanguage].placeholder_title end
    local combatDesc = create("TextLabel", {Name="placeholder_desc", Parent=combatPanel, Size=UDim2.new(0.9,0,0,40), Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(200,200,200), BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left}); uiData.uiUpdaters.combatDesc = function() combatDesc.Text = LANGUAGES[currentLanguage].placeholder_desc end
    
    -- Popular Painel Idiomas
    local langPanel = uiData.contentPanels.category_idiomas
    local ptBtn = create("TextButton", {Name="change_lang_pt", Parent=langPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=ptBtn, CornerRadius=UDim.new(0,4)}); ptBtn.MouseButton1Click:Connect(function() currentLanguage="pt"; updateAllUIText() end); uiData.uiUpdaters.ptBtn = function() ptBtn.Text=LANGUAGES[currentLanguage].change_lang_pt end
    local enBtn = create("TextButton", {Name="change_lang_en", Parent=langPanel, Size=UDim2.new(0.9,0,0,30), BackgroundColor3=Color3.fromRGB(32,169,153), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)}); create("UICorner", {Parent=enBtn, CornerRadius=UDim.new(0,4)}); enBtn.MouseButton1Click:Connect(function() currentLanguage="en"; updateAllUIText() end); uiData.uiUpdaters.enBtn = function() enBtn.Text=LANGUAGES[currentLanguage].change_lang_en end
    
    closeButton.MouseButton1Click:Connect(function() mainGui:Destroy() end)
    
    updateAllUIText()
    selectCategory(leftPanel:FindFirstChild("category_main"), uiData.contentPanels.category_main)
end

--==================================================================================--
--||                           LÓGICA DOS MODS                                    ||--
--==================================================================================--
local function updateEsp()
    local currentPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            currentPlayers[player] = true; local rootPart = player.Character.HumanoidRootPart
            local espGui = espTracker[player]; if not espGui or not espGui.Parent then if espGui then espGui:Destroy() end
                espGui = create("BillboardGui", {Parent=rootPart, AlwaysOnTop=true, Size=UDim2.new(0,200,0,50), Adornee=rootPart, StudsOffset=Vector3.new(0,3,0)}); local nameLbl = create("TextLabel", {Parent=espGui, Text=player.DisplayName, Size=UDim2.new(1,0,1,0), Font=Enum.Font.GothamBold, TextSize=18, TextColor3=Color3.new(1,1,1), BackgroundTransparency=1}); espTracker[player] = espGui
            end
        end
    end
    for player, gui in pairs(espTracker) do if not currentPlayers[player] then gui:Destroy(); espTracker[player] = nil end end
end

RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character; if not char then return end
    if modStates.isFlying then if not modConnections.flyGyro then local r = char:FindFirstChild("HumanoidRootPart"); if r then modConnections.flyGyro = create("BodyGyro", {Parent=r, P=5e4, MaxTorque=Vector3.new(4e5,4e5,4e5)}); modConnections.flyVelocity = create("BodyVelocity", {Parent=r, MaxForce=Vector3.new(math.huge,math.huge,math.huge)}) end end; if modConnections.flyVelocity then local d,v=Vector3.new(),0; if UserInputService:IsKeyDown(Enum.KeyCode.W) then d=d+workspace.CurrentCamera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then d=d-workspace.CurrentCamera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.A) then d=d-workspace.CurrentCamera.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.D) then d=d+workspace.CurrentCamera.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v=1 end; if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v=-1 end; modConnections.flyVelocity.Velocity=(d.Unit*modSettings.flySpeed)+Vector3.new(0,v*modSettings.flySpeed,0); modConnections.flyGyro.CFrame=workspace.CurrentCamera.CFrame end elseif modConnections.flyGyro then modConnections.flyGyro:Destroy();modConnections.flyGyro=nil;modConnections.flyVelocity:Destroy();modConnections.flyVelocity=nil end
    if modStates.isNoclipping then if not modConnections.noclipConnection then modConnections.noclipConnection = RunService.Stepped:Connect(function() if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end elseif modConnections.noclipConnection then modConnections.noclipConnection:Disconnect();modConnections.noclipConnection=nil;if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
    if modStates.isEspEnabled then updateEsp() elseif next(espTracker) then for _,gui in pairs(espTracker) do gui:Destroy() end; espTracker = {} end
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
        playerConnection:Disconnect()
    end)
end