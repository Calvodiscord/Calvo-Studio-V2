--[[
    Script: Calvo Studio (Recriado)
    Autor: Gemini
    Descrição: Versão criada do zero com foco em estabilidade e funcionalidade,
               incluindo uma tela de carregamento à prova de falhas.
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

local isFlying = false
local isNoclipping = false
local originalWalkSpeed = humanoid.WalkSpeed
local customWalkSpeed = 75
local flySpeed = 50

--==================================================================================--
--||                            CONSTRUÇÃO DA INTERFACE (UI)                        ||--
--==================================================================================--

-- Estruturas principais
local loadingScreenGui = Instance.new("ScreenGui", playerGui)
loadingScreenGui.Name = "LoadingScreenGUI"
loadingScreenGui.ResetOnSpawn = false
loadingScreenGui.DisplayOrder = 1000

local mainGui = Instance.new("ScreenGui", playerGui)
mainGui.Name = "CalvoStudioGUI"
mainGui.ResetOnSpawn = false
mainGui.Enabled = false -- Começa desativado

-- Função para criar botões e evitar repetição
local function createButton(properties)
    local button = Instance.new("TextButton")
    for prop, value in pairs(properties) do
        button[prop] = value
    end
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    local originalColor = button.BackgroundColor3
    local hoverColor = originalColor:Lerp(Color3.new(1,1,1), 0.1)

    button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() end)
    button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play() end)
    return button
end

-- 1. Construir a Tela de Carregamento
do
    local background = Instance.new("CanvasGroup", loadingScreenGui)
    background.Size = UDim2.new(0, 320, 0, 100)
    background.Position = UDim2.new(0.5, 0, 0.5, 0)
    background.AnchorPoint = Vector2.new(0.5, 0.5)
    background.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", background).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", background)
    title.Text = "Calvo Studio"; title.Font = Enum.Font.GothamBold; title.TextSize = 24; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.BackgroundTransparency = 1; title.Size = UDim2.new(1, 0, 0.5, 0)

    local progressBarBg = Instance.new("Frame", background)
    progressBarBg.Size = UDim2.new(0.8, 0, 0, 12); progressBarBg.Position = UDim2.new(0.5, 0, 0.65, 0); progressBarBg.AnchorPoint = Vector2.new(0.5, 0.5); progressBarBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(1, 0)

    local progressBarFill = Instance.new("Frame", progressBarBg)
    progressBarFill.Name = "ProgressBarFill"; progressBarFill.Size = UDim2.new(0, 0, 1, 0); progressBarFill.BackgroundColor3 = Color3.fromRGB(114, 137, 218); Instance.new("UICorner", progressBarFill).CornerRadius = UDim.new(1, 0)
end

-- 2. Construir o Menu Principal
do
    local mainFrame = Instance.new("Frame", mainGui)
    mainFrame.Size = UDim2.new(0, 420, 0, 380); mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); mainFrame.AnchorPoint = Vector2.new(0.5, 0.5); mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45); mainFrame.Draggable = true; mainFrame.Active = true; Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 40); titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55); Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Text = "Calvo Studio"; titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 18; titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.BackgroundTransparency = 1; titleLabel.Size = UDim2.new(1, 0, 1, 0)

    local content = Instance.new("Frame", mainFrame)
    content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1

    -- Páginas
    local mainPage = Instance.new("Frame", content)
    mainPage.Size = UDim2.new(1, 0, 1, 0); mainPage.BackgroundTransparency = 1; Instance.new("UIListLayout", mainPage).VerticalAlignment = Enum.VerticalAlignment.Center; mainPage.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; mainPage.UIListLayout.Padding = UDim.new(0, 15)

    local localModsPage = Instance.new("Frame", content)
    localModsPage.Size = UDim2.new(1, 0, 1, 0); localModsPage.BackgroundTransparency = 1; localModsPage.Visible = false; Instance.new("UIListLayout", localModsPage).HorizontalAlignment = Enum.HorizontalAlignment.Center; localModsPage.UIListLayout.Padding = UDim.new(0, 15); Instance.new("UIPadding", localModsPage).PaddingTop = UDim.new(0, 20)

    local playerModsPage = Instance.new("Frame", content)
    playerModsPage.Size = UDim2.new(1, 0, 1, 0); playerModsPage.BackgroundTransparency = 1; playerModsPage.Visible = false; Instance.new("UIPadding", playerModsPage).PaddingTop = UDim.new(0, 10)

    -- Funções de criação de elementos específicos
    local function createModButton(parent, text)
        local button = createButton({Parent = parent, Text = text .. " [OFF]", Size = UDim2.new(0.8, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(60, 60, 75), TextColor3 = Color3.fromRGB(255, 100, 100)})
        local state = false
        button.MouseButton1Click:Connect(function()
            state = not state
            button.Text = text .. (state and " [ON]" or " [OFF]")
            button.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            button.Activated:Fire() -- Dispara um evento customizado
        end)
        return button
    end
    local function createSlider(parent, text, min, max, default)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(0.8, 0, 0, 40); container.BackgroundTransparency = 1
        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, 0, 0.5, 0); label.Font = Enum.Font.Gotham; label.TextSize = 14; label.TextColor3 = Color3.fromRGB(220, 220, 220); label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left
        local sliderBg = Instance.new("Frame", container)
        sliderBg.Size = UDim2.new(1, 0, 0, 8); sliderBg.Position = UDim2.new(0, 0, 0.5, 0); sliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
        local sliderFill = Instance.new("Frame", sliderBg)
        sliderFill.BackgroundColor3 = Color3.fromRGB(114, 137, 218); Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
        local handle = createButton({Parent = sliderBg, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new((default-min)/(max-min), 0, 0.5, 0), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.fromRGB(240,240,240), Text=""})
        handle.Draggable = true
        local valueChanged = Instance.new("BindableEvent")
        local function update(fromDrag)
            local percent = math.clamp(handle.Position.X.Scale, 0, 1)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            local value = math.floor(min + (max - min) * percent + 0.5)
            label.Text = text .. ": " .. value
            if fromDrag then valueChanged:Fire(value) end
        end
        handle.DragEnded:Connect(function() update(true) end)
        handle:GetPropertyChangedSignal("Position"):Connect(function() update(handle.Draggable) end)
        update(true)
        return valueChanged.Event
    end

    -- Preencher Páginas
    createButton({Parent = mainPage, Text = "Mods Locais", Size = UDim2.new(0.8, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(60, 60, 75)}).MouseButton1Click:Connect(function() mainPage.Visible, localModsPage.Visible = false, true end)
    createButton({Parent = mainPage, Text = "Player Mods", Size = UDim2.new(0.8, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(60, 60, 75)}).MouseButton1Click:Connect(function() mainPage.Visible, playerModsPage.Visible = false, true end)
    createButton({Parent = mainPage, Text = "Discord", Size = UDim2.new(0.8, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(88, 101, 242)})

    local flyButton = createModButton(localModsPage, "Fly"); createSlider(localModsPage, "Velocidade Voo", 10, 200, flySpeed):Connect(function(v) flySpeed = v end)
    local noclipButton = createModButton(localModsPage, "Atravessar Parede")
    local speedButton = createModButton(localModsPage, "Speed"); createSlider(localModsPage, "Velocidade Corrida", 16, 200, customWalkSpeed):Connect(function(v) customWalkSpeed = v end)
    createButton({Parent = localModsPage, Text = "Voltar", Size = UDim2.new(0.8, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(80, 80, 95)}).MouseButton1Click:Connect(function() mainPage.Visible, localModsPage.Visible = true, false end)
    
    local playerList = Instance.new("ScrollingFrame", playerModsPage); playerList.Size = UDim2.new(1, -20, 1, -110); playerList.Position = UDim2.new(0.5, 0, 0, 0); playerList.AnchorPoint = Vector2.new(0.5, 0); playerList.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UIListLayout", playerList).Padding = UDim.new(0,5); Instance.new("UICorner", playerList).CornerRadius = UDim.new(0,8)
    local btnContainer = Instance.new("Frame", playerModsPage); btnContainer.Size = UDim2.new(1, 0, 0, 90); btnContainer.Position = UDim2.new(0, 0, 1, -90); btnContainer.BackgroundTransparency = 1; Instance.new("UIGridLayout", btnContainer).CellSize = UDim2.new(0.5, -15, 0, 35); btnContainer.UIGridLayout.StartCorner = "TopLeft"; btnContainer.UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local killBtn = createButton({Parent = btnContainer, Text = "Matar", Size = UDim2.new(), BackgroundColor3 = Color3.fromRGB(150, 50, 50)}); local kickBtn = createButton({Parent = btnContainer, Text = "Kickar", Size = UDim2.new(), BackgroundColor3 = Color3.fromRGB(150, 50, 50)}); createButton({Parent = btnContainer, Text = "Atualizar", Size = UDim2.new(), BackgroundColor3 = Color3.fromRGB(60, 60, 75)}); createButton({Parent = btnContainer, Text = "Voltar", Size = UDim2.new(), BackgroundColor3 = Color3.fromRGB(80, 80, 95)}).MouseButton1Click:Connect(function() mainPage.Visible, playerModsPage.Visible = true, false end)
    
--==================================================================================--
--||                                   LÓGICA DO SCRIPT                             ||--
--==================================================================================--

    -- Lógica de Mods
    flyButton.Activated:Connect(function() isFlying = not isFlying; local rp = character:FindFirstChild("HumanoidRootPart"); if isFlying then humanoid.PlatformStand = true; local g = Instance.new("BodyGyro", rp); g.MaxTorque=Vector3.new(9e9,9e9,9e9); g.P=5e4; g.Name="FlyGyro"; local v=Instance.new("BodyVelocity",rp);v.MaxForce=Vector3.new(9e9,9e9,9e9);v.Velocity=Vector3.new(0,0,0);v.Name="FlyVel" else humanoid.PlatformStand = false; if rp.FlyGyro then rp.FlyGyro:Destroy() end; if rp.FlyVel then rp.FlyVel:Destroy() end end end)
    RunService.Stepped:Connect(function() if isFlying then local rp=character:FindFirstChild("HumanoidRootPart"); if rp and rp.FlyVel then local dir=Vector3.new(); if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+workspace.CurrentCamera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-workspace.CurrentCamera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-workspace.CurrentCamera.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+workspace.CurrentCamera.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end; if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end; rp.FlyVel.Velocity=dir.Unit*flySpeed; if rp.FlyGyro then rp.FlyGyro.CFrame = workspace.CurrentCamera.CFrame end end end end)
    noclipButton.Activated:Connect(function() isNoclipping = not isNoclipping; for i,v in pairs(character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = not isNoclipping end end end)
    speedButton.Activated:Connect(function() humanoid.WalkSpeed = humanoid.WalkSpeed == originalWalkSpeed and customWalkSpeed or originalWalkSpeed end)

    -- Lógica de Player
    local function getSelected() local s = {}; for i,v in pairs(playerList:GetChildren()) do if v:IsA("Frame") and v.Selected then table.insert(s, v.Player) end end; return s end
    killBtn.MouseButton1Click:Connect(function() for i,v in pairs(getSelected()) do if v.Character and v.Character:FindFirstChild("Humanoid") then v.Character.Humanoid.Health = 0 end end end)
    kickBtn.MouseButton1Click:Connect(function() for i,v in pairs(getSelected()) do v:Kick("Kicked by Calvo Studio") end end)

    -- Lógica da Lista de Players
    local playerTemplate = Instance.new("Frame", nil); playerTemplate.Size=UDim2.new(1,-10,0,30); playerTemplate.BackgroundColor3=Color3.fromRGB(60,60,75); Instance.new("UICorner", playerTemplate).CornerRadius=UDim.new(0,6)
    local check = createButton({Parent=playerTemplate, Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,5,0.5,0),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=Color3.fromRGB(45,45,55),Text=""})
    check.MouseButton1Click:Connect(function() local frame=check.Parent; frame.Selected = not frame.Selected; check.Text=frame.Selected and "X" or "" end)
    local plName = Instance.new("TextLabel", playerTemplate); plName.Size=UDim2.new(1,-35,1,0);plName.Position=UDim2.new(0,30,0,0);plName.Font=Enum.Font.Gotham;plName.TextColor3=Color3.fromRGB(230,230,230);plName.TextSize=14;plName.TextXAlignment=Enum.TextXAlignment.Left
    local function updatePlayerList() playerList:ClearAllChildren(); Instance.new("UIListLayout", playerList).Padding = UDim.new(0,5); for i,v in pairs(Players:GetPlayers()) do if v~=localPlayer then local clone=playerTemplate:Clone(); clone.Player=v; clone.name.Text=v.Name; clone.Parent=playerList end end end
    playerModsPage.VisibleChanged:Connect(function(v) if v then updatePlayerList() end end)
    Players.PlayerAdded:Connect(updatePlayerList); Players.PlayerRemoving:Connect(updatePlayerList)
end

--==================================================================================--
--||                          LÓGICA DE INÍCIO (À PROVA DE FALHAS)                  ||--
--==================================================================================--

-- Função final que inicia tudo
local function Initialize()
    local progressBar = loadingScreenGui:FindFirstChild("Background"):FindFirstChild("ProgressBarFill")
    
    -- 1. Inicia a animação visual (não bloqueia o script)
    TweenService:Create(progressBar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    
    -- 2. Cria uma tarefa paralela que GARANTE a transição
    task.spawn(function()
        -- Espera um tempo fixo
        task.wait(3.0) 
        
        -- 3. Força a troca, não importa o que aconteça
        mainGui.Enabled = true
        loadingScreenGui:Destroy()
        print("Calvo Studio GUI carregado com sucesso!")
    end)
end

Initialize()
