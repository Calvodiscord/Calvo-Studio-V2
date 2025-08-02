--[[
    Script: Calvo Studio (V8)
    Autor: Recriado e aprimorado com base na solicitação
    Descrição: GUI instantânea sem tela de carregamento para garantir funcionalidade.
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
--||                                   MENU PRINCIPAL                               ||--
--==================================================================================--

-- A GUI principal agora é ativada imediatamente.
local mainGui = Instance.new("ScreenGui", playerGui)
mainGui.Name = "CalvoStudioGUI"
mainGui.ResetOnSpawn = false
mainGui.Enabled = true -- ATIVADO DIRETAMENTE

local mainFrame = Instance.new("Frame", mainGui)
mainFrame.Name = "MainFrame"; mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45); mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 25); mainFrame.BorderSizePixel = 2; mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); mainFrame.AnchorPoint = Vector2.new(0.5, 0.5); mainFrame.Size = UDim2.new(0, 400, 0, 420); mainFrame.Draggable = true; mainFrame.Active = true; mainFrame.ClipsDescendants = true; Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Name = "TitleBar"; titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55); titleBar.Size = UDim2.new(1, 0, 0, 40); titleBar.BorderSizePixel = 0
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Font = Enum.Font.GothamBold; titleLabel.Text = "Calvo Studio"; titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.TextSize = 18; titleLabel.BackgroundTransparency = 1; titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0); titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)

local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.Name = "ContentContainer"; contentContainer.BackgroundTransparency = 1; contentContainer.Size = UDim2.new(1, 0, 1, -40); contentContainer.Position = UDim2.new(0, 0, 0, 40); contentContainer.ClipsDescendants = true

-- Páginas
local mainPage = Instance.new("Frame", contentContainer)
mainPage.Name = "MainPage"; mainPage.BackgroundTransparency = 1; mainPage.Size = UDim2.new(1, 0, 1, 0)
local localModsPage = Instance.new("Frame", contentContainer)
localModsPage.Name = "LocalModsPage"; localModsPage.BackgroundTransparency = 1; localModsPage.Size = UDim2.new(1, 0, 1, 0); localModsPage.Visible = false
local playerModsPage = Instance.new("Frame", contentContainer)
playerModsPage.Name = "PlayerModsPage"; playerModsPage.BackgroundTransparency = 1; playerModsPage.Size = UDim2.new(1, 0, 1, 0); playerModsPage.Visible = false

-- Layouts
Instance.new("UIListLayout", mainPage).Padding = UDim.new(0, 15); mainPage.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; mainPage.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIListLayout", localModsPage).Padding = UDim.new(0, 10); localModsPage.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; localModsPage.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top; localModsPage.UIListLayout.Padding = UDim.new(0, 20); localModsPage.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", playerModsPage).PaddingTop = UDim.new(0, 10)

-- Funções de UI reutilizáveis
local function createButton(parent, text, size, layoutOrder)
    local btn = Instance.new("TextButton", parent)
    btn.Name = text:gsub(" ", "") .. "Button"; btn.BackgroundColor3 = Color3.fromRGB(60, 60, 75); btn.Size = size; btn.Font = Enum.Font.GothamSemibold; btn.Text = text; btn.TextColor3 = Color3.fromRGB(230, 230, 230); btn.TextSize = 16; btn.LayoutOrder = layoutOrder; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 95)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play() end)
    return btn
end

local function createModButton(parent, text, layoutOrder)
    local btn = createButton(parent, text .. " [OFF]", UDim2.new(0.85, 0, 0, 35), layoutOrder)
    btn.TextColor3 = Color3.fromRGB(255, 100, 100); btn.Font = Enum.Font.Gotham
    local state = false
    btn.Activated:Connect(function()
        state = not state
        if state then btn.Text = text .. " [ON]"; btn.TextColor3 = Color3.fromRGB(100, 255, 100) else btn.Text = text .. " [OFF]"; btn.TextColor3 = Color3.fromRGB(255, 100, 100) end
    end)
    return btn
end

local function createSlider(parent, text, minVal, maxVal, startVal, layoutOrder)
    local container = Instance.new("Frame", parent)
    container.BackgroundTransparency = 1; container.Size = UDim2.new(0.85, 0, 0, 40); container.LayoutOrder = layoutOrder
    local label = Instance.new("TextLabel", container)
    label.Font = Enum.Font.Gotham; label.Text = text .. ": " .. startVal; label.TextColor3 = Color3.fromRGB(220, 220, 220); label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Size = UDim2.new(1, 0, 0, 15)
    local sliderBg = Instance.new("Frame", container)
    sliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30); sliderBg.BorderSizePixel = 0; sliderBg.Size = UDim2.new(1, 0, 0, 8); sliderBg.Position = UDim2.new(0, 0, 0, 20); Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.BackgroundColor3 = Color3.fromRGB(114, 137, 218); sliderFill.BorderSizePixel = 0; Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    local handle = Instance.new("TextButton", sliderBg)
    handle.Size = UDim2.new(0, 16, 0, 16); handle.AnchorPoint = Vector2.new(0.5, 0.5); handle.Position = UDim2.new((startVal - minVal) / (maxVal - minVal), 0, 0.5, 0); handle.Draggable = true; handle.BackgroundColor3 = Color3.fromRGB(240, 240, 240); handle.Text = ""; Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)
    local onValueChanged = Instance.new("BindableEvent")
    local function updateSlider(pos)
        local relPos = math.clamp(pos, 0, sliderBg.AbsoluteSize.X)
        handle.Position = UDim2.new(0, relPos, 0.5, 0)
        local percent = relPos / sliderBg.AbsoluteSize.X
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        local value = math.floor(minVal + (maxVal - minVal) * percent + 0.5)
        label.Text = text .. ": " .. value; onValueChanged:Fire(value)
    end
    handle.DragBegan:Connect(function() handle.BackgroundColor3 = Color3.fromRGB(200, 200, 200) end)
    handle.DragEnded:Connect(function() handle.BackgroundColor3 = Color3.fromRGB(240, 240, 240) end)
    handle.MouseDrag:Connect(function(_, _, _, _, rel) updateSlider(handle.AbsolutePosition.X - sliderBg.AbsolutePosition.X + rel.X) end)
    updateSlider(handle.Position.X.Offset)
    return onValueChanged.Event
end

-- Conteúdo das páginas (o restante do menu)
createButton(mainPage, "Mods Locais", UDim2.new(0.8, 0, 0, 45), 1).MouseButton1Click:Connect(function() mainPage.Visible = false; localModsPage.Visible = true end)
createButton(mainPage, "Player Mods", UDim2.new(0.8, 0, 0, 45), 2).MouseButton1Click:Connect(function() mainPage.Visible = false; playerModsPage.Visible = true; end)
local discordButton = createButton(mainPage, "Discord", UDim2.new(0.8, 0, 0, 45), 3)
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
Instance.new("UIPadding", localModsPage).PaddingTop = UDim.new(0, 20)
local flyButton = createModButton(localModsPage, "Fly", 1)
createSlider(localModsPage, "Velocidade do Voo", 10, 200, flySpeed, 2):Connect(function(value) flySpeed = value end)
local noclipButton = createModButton(localModsPage, "Atravessar Parede", 3)
local speedButton = createModButton(localModsPage, "Speed", 4)
createSlider(localModsPage, "Velocidade da Corrida", 16, 200, customWalkSpeed, 5):Connect(function(value) customWalkSpeed = value end)
createButton(localModsPage, "Voltar", UDim2.new(0.85, 0, 0, 35), 6).MouseButton1Click:Connect(function() localModsPage.Visible = false; mainPage.Visible = true end)
local playerListFrame = Instance.new("ScrollingFrame", playerModsPage)
playerListFrame.Size = UDim2.new(1, -20, 1, -120); playerListFrame.Position = UDim2.new(0.5, 0, 0, 0); playerListFrame.AnchorPoint = Vector2.new(0.5, 0); playerListFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55); playerListFrame.BorderColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 8); Instance.new("UIListLayout", playerListFrame).Padding = UDim.new(0, 5)
local playerTemplate = Instance.new("Frame", nil)
playerTemplate.Size = UDim2.new(1, -10, 0, 30); playerTemplate.BackgroundColor3 = Color3.fromRGB(60, 60, 75); playerTemplate.ClipsDescendants = true; Instance.new("UICorner", playerTemplate).CornerRadius = UDim.new(0, 6)
local playerCheck = Instance.new("TextButton", playerTemplate)
playerCheck.Size = UDim2.new(0, 20, 0, 20); playerCheck.Position = UDim2.new(0, 5, 0.5, 0); playerCheck.AnchorPoint = Vector2.new(0, 0.5); playerCheck.BackgroundColor3 = Color3.fromRGB(45, 45, 55); playerCheck.Text = ""; Instance.new("UICorner", playerCheck).CornerRadius = UDim.new(0, 4)
local playerName = Instance.new("TextLabel", playerTemplate)
playerName.Size = UDim2.new(1, -35, 1, 0); playerName.Position = UDim2.new(0, 30, 0, 0); playerName.Font = Enum.Font.Gotham; playerName.TextColor3 = Color3.fromRGB(230, 230, 230); playerName.TextSize = 14; playerName.TextXAlignment = Enum.TextXAlignment.Left
local buttonContainer = Instance.new("Frame", playerModsPage)
buttonContainer.Size = UDim2.new(1, -20, 0, 100); buttonContainer.Position = UDim2.new(0.5, 0, 1, -100); buttonContainer.AnchorPoint = Vector2.new(0.5, 0); buttonContainer.BackgroundTransparency = 1; Instance.new("UIGridLayout", buttonContainer).CellSize = UDim2.new(0.5, -5, 0, 40); buttonContainer.UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local killButton = createButton(buttonContainer, "Matar Selecionados", UDim2.new(), 1)
local kickButton = createButton(buttonContainer, "Kicka do Servidor", UDim2.new(), 2)
createButton(buttonContainer, "Atualizar Lista", UDim2.new(), 3)
createButton(buttonContainer, "Voltar", UDim2.new(), 4).MouseButton1Click:Connect(function() playerModsPage.Visible = false; mainPage.Visible = true end)
local function populatePlayerList()
    playerListFrame:ClearAllChildren(); Instance.new("UIListLayout", playerListFrame).Padding = UDim.new(0, 5)
    for _, p in pairs(Players:GetPlayers()) do if p ~= localPlayer then local c = playerTemplate:Clone(); c.PlayerObject = p; c.Name = p.Name; c.Parent = playerListFrame; local ch = c:FindFirstChild("TextButton"); local nl = c:FindFirstChild("TextLabel"); ch.Text = ""; ch.selected = false; ch.MouseButton1Click:Connect(function() ch.selected = not ch.selected; ch.Text = ch.selected and "X" or "" end); nl.Text = p.Name end end
end
function getSelectedPlayers() local s = {}; for _, i in pairs(playerListFrame:GetChildren()) do if i:IsA("Frame") and i:FindFirstChild("TextButton").selected then table.insert(s, i.PlayerObject) end end; return s end
killButton.MouseButton1Click:Connect(function() for _, p in pairs(getSelectedPlayers()) do if p.Character and p.Character:FindFirstChild("Humanoid") then p.Character.Humanoid.Health = 0 end end end)
kickButton.MouseButton1Click:Connect(function() for _, p in pairs(getSelectedPlayers()) do p:Kick("Kicked by Calvo Studio.") end end)
playerModsPage.VisibleChanged:Connect(function(v) if v then populatePlayerList() end end); Players.PlayerAdded:Connect(populatePlayerList); Players.PlayerRemoving:Connect(populatePlayerList)
local flyGyro, flyVelocity; flyButton.Activated:Connect(function() isFlying = not isFlying; local rp = character and character:FindFirstChild("HumanoidRootPart"); if not humanoid or not rp then return end if isFlying then flyGyro = Instance.new("BodyGyro", rp); flyGyro.P = 5e4; flyGyro.MaxTorque = Vector3.new(4e5, 4e5, 4e5); flyGyro.CFrame = rp.CFrame; flyVelocity = Instance.new("BodyVelocity", rp); flyVelocity.Velocity = Vector3.new(0,0,0); flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge); humanoid.PlatformStand = true else if flyGyro then flyGyro:Destroy() end; if flyVelocity then flyVelocity:Destroy() end; humanoid.PlatformStand = false end end)
RunService.RenderStepped:Connect(function() if isFlying and flyVelocity then local d, ccf = Vector3.new(0,0,0), workspace.CurrentCamera.CFrame; if UserInputService:IsKeyDown(Enum.KeyCode.W) then d = d + ccf.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then d = d - ccf.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.A) then d = d - ccf.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.D) then d = d + ccf.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0,1,0) end; if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d = d - Vector3.new(0,1,0) end; flyVelocity.Velocity = d.Magnitude > 0 and d.Unit * flySpeed or Vector3.new(0,0,0); if flyGyro then flyGyro.CFrame = ccf end end end)
noclipButton.Activated:Connect(function() isNoclipping = not isNoclipping; for _, p in pairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = not isNoclipping end end end)
speedButton.Activated:Connect(function() humanoid.WalkSpeed = humanoid.WalkSpeed == originalWalkSpeed and customWalkSpeed or originalWalkSpeed end)

print("Calvo Studio GUI carregado com sucesso!")
