--[[
    Script: CALVO MOD V4 (PRISON LIFE) - Edição de Carregamento
    Versão: 4.0
    
]]

--==================================================================================--
--||                                   SERVIÇOS                                   ||--
--==================================================================================--
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

--==================================================================================--
--||                                   CONFIGURAÇÕES                                ||--
--==================================================================================--
local currentLanguage = "pt"
local modStates = {isFlying=false, isNoclipping=false, isSpeedEnabled=false, isEspEnabled=false, isGodModeEnabled=false, isInfiniteAmmoEnabled=false, isTargetLocked=false}
local modSettings = {originalWalkSpeed=16, flySpeed=80, walkSpeed=80}
local uiData = {activeCategoryButton=nil, contentPanels={}, uiUpdaters={}, isMinimized=false, kickTargetName="", selectedPlayer=nil, lockedTarget=nil, savedPosition=nil}

local LANGUAGES = {
    pt = {
        title = "CALVO MOD V4", category_admin = "Admin", category_opcoes = "Opções", category_combate = "Combate",
        category_teleports = "Teleportes", category_esp = "ESP", category_idiomas = "Idiomas", category_weapons = "Armas",
        fly = "Voar", noclip = "Atravessar Parede", speed = "Correr Rápido", walk_speed = "Velocidade de Corrida",
        kick_player = "Kickar Player", kick_target_placeholder = "Nome do Player", server_info = "Info do Servidor",
        server_uptime = "Tempo de Atividade", players = "Jogadores",
        select_player = "Selecione um Player:", tp_to_player = "Ir até Player", kill_player = "Matar Player",
        lock_player = "Travar Player",
        god_mode = "Modo Deus", infinite_ammo = "Munição Infinita",
        get_weapon_m9 = "Pegar M9", get_weapon_remington = "Pegar Remington 870", get_weapon_ak47 = "Pegar AK-47",
        tp_to_criminals = "Ir para Base Criminal", tp_to_prison = "Ir para Prisão",
        save_location = "Salvar Local", teleport_to_location = "Ir para Local Salvo",
        esp_players = "ESP Players", esp_distance = "Distância",
        change_lang_pt = "Português", change_lang_en = "English", status_on = "ON", status_off = "OFF"
    },
    en = {
        title = "CALVO MOD V4", category_admin = "Admin", category_opcoes = "Options", category_combate = "Combat",
        category_teleports = "Teleports", category_esp = "ESP", category_idiomas = "Languages", category_weapons = "Weapons",
        fly = "Fly", noclip = "Noclip", speed = "Speed Hack", walk_speed = "Walk Speed",
        kick_player = "Kick Player", kick_target_placeholder = "Player's Name", server_info = "Server Info",
        server_uptime = "Uptime", players = "Players",
        select_player = "Select a Player:", tp_to_player = "Go to Player", kill_player = "Kill Player",
        lock_player = "Lock Player",
        god_mode = "God Mode", infinite_ammo = "Infinite Ammo",
        get_weapon_m9 = "Get M9", get_weapon_remington = "Get Remington 870", get_weapon_ak47 = "Get AK-47",
        tp_to_criminals = "Go to Criminals' Base", tp_to_prison = "Go to Prison",
        save_location = "Save Location", teleport_to_location = "Teleport to Saved Location",
        esp_players = "ESP Players", esp_distance = "Distance",
        change_lang_pt = "Portuguese", change_lang_en = "English", status_on = "ON", status_off = "OFF"
    }
}

--==================================================================================--
--||                          FUNÇÕES DE AÇÃO (BLINDADAS)                         ||--
--==================================================================================--
local function GetWeapon(weaponName) pcall(function() ReplicatedStorage:WaitForChild("WeaponEvent", 10):FireServer("Create", weaponName) end) end
local function TeleportPlayer(targetCFrame) local char=localPlayer.Character; if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame=targetCFrame*CFrame.new(0,5,0) end end
local function KillPlayer(targetPlayer) if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return end; pcall(function() ReplicatedStorage:WaitForChild("WeaponEvent", 5):FireServer("Damage", targetPlayer.Character.Head, 101) end) end

--==================================================================================--
--||                           FUNÇÃO PRINCIPAL DA UI                             ||--
--==================================================================================--
local function Create(i,p) local inst=Instance.new(i); for prop,v in pairs(p) do pcall(function() inst[prop]=v end) end; return inst end

local function BuildUI()
    if localPlayer.PlayerGui:FindFirstChild("CalvoModV4Gui") then localPlayer.PlayerGui.CalvoModV4Gui:Destroy() end
    local mainGui=Create("ScreenGui", {Name="CalvoModV4Gui", Parent=localPlayer.PlayerGui, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Global})
    local mainContainer=Create("Frame",{Name="Container",Parent=mainGui,Size=UDim2.new(0,560,0,420),Position=UDim2.new(0.5,-280,0.5,-210),BackgroundColor3=Color3.fromRGB(35,35,45),Draggable=true,Active=true,ClipsDescendants=true})
    Create("UICorner",{Parent=mainContainer,CornerRadius=UDim.new(0,8)});Create("UIStroke",{Parent=mainContainer,Color=Color3.fromRGB(80,80,100),Thickness=1.5})
    local topBar=Create("Frame",{Name="TopBar",Parent=mainContainer,Size=UDim2.new(1,0,0,35),BackgroundColor3=Color3.fromRGB(28,28,36)})
    local topBarTitle=Create("TextLabel",{Name="Title",Parent=topBar,Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,15,0,0),Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1})
    local closeButton=Create("TextButton",{Name="Close",Parent=topBar,Size=UDim2.new(0,35,0,35),Position=UDim2.new(1,-35,0,0),Text="X",Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextSize=16,BackgroundColor3=Color3.fromRGB(28,28,36),ZIndex=2})
    local minimizeButton=Create("TextButton",{Name="Minimize",Parent=topBar,Size=UDim2.new(0,35,0,35),Position=UDim2.new(1,-70,0,0),Text="_",Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextSize=16,BackgroundColor3=Color3.fromRGB(28,28,36),ZIndex=2})
    local leftPanel=Create("Frame",{Name="LeftPanel",Parent=mainContainer,Size=UDim2.new(0,150,1,-35),Position=UDim2.new(0,0,0,35),BackgroundColor3=Color3.fromRGB(40,40,52)})
    Create("UIListLayout",{Parent=leftPanel,Padding=UDim.new(0,5),HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10)})
    local rightPanel=Create("Frame",{Name="RightPanel",Parent=mainContainer,Size=UDim2.new(1,-150,1,-35),Position=UDim2.new(0,150,0,35),BackgroundTransparency=1})

    local function updateAllUIText() pcall(function() local lang=LANGUAGES[currentLanguage]; topBarTitle.Text=lang.title; for k,u in pairs(uiData.uiUpdaters) do pcall(u) end end) end
    local function selectCategory(b, p) if uiData.activeCategoryButton then uiData.activeCategoryButton.BackgroundColor3=Color3.fromRGB(55,55,70); uiData.activeCategoryButton:FindFirstChild("UIStroke").Enabled=false end; b.BackgroundColor3=Color3.fromRGB(45,45,60); b:FindFirstChild("UIStroke").Enabled=true; uiData.activeCategoryButton=b; for _,panel in pairs(uiData.contentPanels) do panel.Visible=false end; p.Visible=true end
    
    local function createCategory(key, order)
        local panel=Create("ScrollingFrame",{Name=key.."Panel",Parent=rightPanel,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarImageColor3=Color3.fromRGB(0,170,255),ScrollBarThickness=6})
        Create("UIListLayout",{Parent=panel,Padding=UDim.new(0,10),HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder}); Create("UIPadding",{Parent=panel,PaddingTop=UDim.new(0,15),PaddingLeft=UDim.new(0,20),PaddingRight=UDim.new(0,20)})
        uiData.contentPanels[key]=panel
        local button=Create("TextButton",{Name=key,Parent=leftPanel,Size=UDim2.new(0.85,0,0,35),BackgroundColor3=Color3.fromRGB(55,55,70),Font=Enum.Font.GothamSemibold,TextSize=15,TextColor3=Color3.fromRGB(255,255,255),LayoutOrder=order})
        Create("UICorner",{Parent=button,CornerRadius=UDim.new(0,6)}); Create("UIStroke",{Parent=button,Color=Color3.fromRGB(0,170,255),Thickness=2,Enabled=false})
        button.MouseButton1Click:Connect(function() if not uiData.isMinimized then selectCategory(button, panel) end end)
        uiData.uiUpdaters[key.."_cat"] = function() button.Text = LANGUAGES[currentLanguage][key] end
        return panel, button
    end

    local function createStandardButton(p, k, cb) local b=Create("TextButton",{Name=k,Parent=p,Size=UDim2.new(1,0,0,35),BackgroundColor3=Color3.fromRGB(55,55,70),Font=Enum.Font.GothamSemibold,TextSize=14,TextColor3=Color3.fromRGB(255,255,255)}); Create("UICorner",{Parent=b,CornerRadius=UDim.new(0,6)}); b.MouseButton1Click:Connect(cb); uiData.uiUpdaters[k]=function() b.Text=LANGUAGES[currentLanguage][k] end; return b end
    local function createToggleButton(p,k,s) local b=createStandardButton(p,k,function() modStates[s]=not modStates[s]; uiData.uiUpdaters[k]() end); Create("UIStroke",{Parent=b,Color=Color3.fromRGB(80,80,100)}); local old=uiData.uiUpdaters[k]; uiData.uiUpdaters[k]=function() old(); local l=LANGUAGES[currentLanguage]; local st=modStates[s] and l.status_on or l.status_off; b.Text=l[k].." ["..st.."]"; b:FindFirstChild("UIStroke").Color=modStates[s] and Color3.fromRGB(0,170,255) or Color3.fromRGB(80,80,100) end end
    local function createSlider(p,t,vt,vk,min,max,st) local f=Create("Frame",{Parent=p,Size=UDim2.new(1,0,0,50),BackgroundTransparency=1}); Create("UIListLayout",{Parent=f,FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,5)}); local tf=Create("Frame",{Parent=f,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1}); local tl=Create("TextLabel",{Parent=tf,Size=UDim2.new(0.7,0,1,0),Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(220,220,220),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left}); local vl=Create("TextLabel",{Parent=tf,Size=UDim2.new(0.3,0,1,0),Position=UDim2.new(0.7,0,0,0),Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right}); local s=Create("Slider",{Parent=f,Size=UDim2.new(1,0,0,20),MinValue=min,MaxValue=max,Value=vt[vk]}); s.ValueChanged:Connect(function(v) vt[vk]=math.floor(v/st)*st; uiData.uiUpdaters[t]() end); uiData.uiUpdaters[t]=function() tl.Text=LANGUAGES[currentLanguage][t]; vl.Text=tostring(math.floor(vt[vk])); s.Value=vt[vk] end end

    local adminPanel,adminButton=createCategory("category_admin",1); local opcoesPanel,_=createCategory("category_opcoes",2); local combatPanel,_=createCategory("category_combate",3); local weaponsPanel,_=createCategory("category_weapons",4); local tpPanel,_=createCategory("category_teleports",5); local espPanel,_=createCategory("category_esp",6); local langPanel,_=createCategory("category_idiomas",7)

    pcall(function()
        local kickTitle=Create("TextLabel",{Parent=adminPanel,Size=UDim2.new(1,0,0,25),Font=Enum.Font.GothamBold,TextSize=16,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1});uiData.uiUpdaters.kick_player=function()kickTitle.Text=LANGUAGES[currentLanguage].kick_player end
        local nameBox=Create("TextBox",{Parent=adminPanel,Size=UDim2.new(1,0,0,35),BackgroundColor3=Color3.fromRGB(55,55,70),Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(220,220,220),PlaceholderColor3=Color3.fromRGB(150,150,150)});Create("UICorner",{Parent=nameBox,CornerRadius=UDim.new(0,6)});uiData.uiUpdaters.kick_target_placeholder=function()nameBox.PlaceholderText=LANGUAGES[currentLanguage].kick_target_placeholder end;nameBox.FocusLost:Connect(function()uiData.kickTargetName=nameBox.Text end)
        createStandardButton(adminPanel,"kick_player",function()local p=Players:FindFirstChild(uiData.kickTargetName);if p then p:Kick("Kickado pelo Calvo Mod V4")end end)
        createStandardButton(adminPanel,"server_info",function() local iF=Create("Frame",{Parent=mainGui,Size=UDim2.new(0,300,0,100),Position=UDim2.new(0.5,-150,0.5,-50),BackgroundColor3=Color3.fromRGB(45,45,60)});Create("UICorner",{Parent=iF,CornerRadius=UDim.new(0,8)});Create("UIStroke",{Parent=iF,Color=Color3.fromRGB(90,90,110)});Create("UIListLayout",{Parent=iF,Padding=UDim.new(0,10),HorizontalAlignment=Enum.HorizontalAlignment.Center});Create("UIPadding",{Parent=iF,PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)});local up=math.floor(Workspace.DistributedGameTime or tick()-game.StartTime);local upT=string.format("%s: %d min",LANGUAGES[currentLanguage].server_uptime,math.floor(up/60));local pT=string.format("%s: %d/%d",LANGUAGES[currentLanguage].players,#Players:GetPlayers(),Players.MaxPlayers);Create("TextLabel",{Parent=iF,Size=UDim2.new(1,0,0,25),Font=Enum.Font.GothamBold,TextSize=15,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Text=upT});Create("TextLabel",{Parent=iF,Size=UDim2.new(1,0,0,25),Font=Enum.Font.GothamBold,TextSize=15,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Text=pT});task.delay(5,function()if iF then iF:Destroy()end end)end)
    end)
    pcall(function() createToggleButton(opcoesPanel,"fly","isFlying");createToggleButton(opcoesPanel,"noclip","isNoclipping");createToggleButton(opcoesPanel,"speed","isSpeedEnabled");createSlider(opcoesPanel,"walk_speed",modSettings,"walkSpeed",16,150,1) end)
    pcall(function()
        createToggleButton(combatPanel,"god_mode","isGodModeEnabled");createToggleButton(combatPanel,"infinite_ammo","isInfiniteAmmoEnabled");local t=Create("TextLabel",{Parent=combatPanel,Size=UDim2.new(1,0,0,20),Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextSize=15,BackgroundTransparency=1,Margin=UDim.new(0,10)});uiData.uiUpdaters.select_player=function()t.Text=LANGUAGES[currentLanguage].select_player end;local pLF=Create("ScrollingFrame",{Parent=combatPanel,Size=UDim2.new(1,0,0,120),BackgroundColor3=Color3.fromRGB(40,40,52)});Create("UIListLayout",{Parent=pLF});Create("UICorner",{Parent=pLF,CornerRadius=UDim.new(0,6)});local aF=Create("Frame",{Parent=combatPanel,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1});Create("UIListLayout",{Parent=aF,Padding=UDim.new(0,10)})
        local function rPL() pLF.CanvasSize=UDim2.new();for _,c in pairs(pLF:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end;for _,p in pairs(Players:GetPlayers())do if p~=localPlayer then local b=createStandardButton(pLF,p.Name,function()uiData.selectedPlayer=p;for _,btn in pairs(pLF:GetChildren())do if btn:IsA("TextButton")then btn.BackgroundColor3=Color3.fromRGB(55,55,70)end end;b.BackgroundColor3=Color3.fromRGB(0,170,255)end);b.Text=p.Name end end end
        local function cA(k,cb) createStandardButton(aF,k,function()if uiData.selectedPlayer then cb(uiData.selectedPlayer)end end)end;cA("tp_to_player",function(p)if p.Character and p.Character.PrimaryPart then TeleportPlayer(p.Character.PrimaryPart.CFrame)end end);cA("kill_player",KillPlayer);cA("kick_player",function(p)p:Kick()end);cA("lock_player",function(p)modStates.isTargetLocked=not modStates.isTargetLocked;uiData.lockedTarget=modStates.isTargetLocked and p or nil end);rPL();Players.PlayerAdded:Connect(rPL);Players.PlayerRemoving:Connect(rPL)
    end)
    pcall(function()createStandardButton(weaponsPanel,"get_weapon_m9",function()GetWeapon("M9")end);createStandardButton(weaponsPanel,"get_weapon_remington",function()GetWeapon("Remington 870")end);createStandardButton(weaponsPanel,"get_weapon_ak47",function()GetWeapon("AK-47")end)end)
    pcall(function()createStandardButton(tpPanel,"tp_to_criminals",function()local s=Workspace:WaitForChild("Spawns",5)and Workspace.Spawns:WaitForChild("CriminalsSpawn",5);if s then TeleportPlayer(s.CFrame)end end);createStandardButton(tpPanel,"tp_to_prison",function()local s=Workspace:WaitForChild("Spawns",5)and Workspace.Spawns:WaitForChild("YardSpawn",5);if s then TeleportPlayer(s.CFrame)end end);createStandardButton(tpPanel,"save_location",function()local r=localPlayer.Character and localPlayer.Character.PrimaryPart;if r then uiData.savedPosition=r.CFrame end end);createStandardButton(tpPanel,"teleport_to_location",function()if uiData.savedPosition then TeleportPlayer(uiData.savedPosition)end end)end)
    pcall(function()createToggleButton(espPanel,"esp_players","isEspEnabled")end)
    -- CORREÇÃO APLICADA AQUI: A sintaxe anterior estava errada.
    pcall(function()createStandardButton(langPanel, "change_lang_pt", function() currentLanguage="pt"; updateAllUIText() end);createStandardButton(langPanel, "change_lang_en", function() currentLanguage="en"; updateAllUIText() end)end)

    closeButton.MouseButton1Click:Connect(function()mainGui:Destroy()end);minimizeButton.MouseButton1Click:Connect(function()uiData.isMinimized=not uiData.isMinimized;local s=uiData.isMinimized and UDim2.new(0,560,0,35)or UDim2.new(0,560,0,420);TweenService:Create(mainContainer,TweenInfo.new(0.3),{Size=s}):Play()end)
    
    updateAllUIText()
    selectCategory(adminButton, adminButton.Parent.Parent:FindFirstChild("RightPanel"):FindFirstChild("category_adminPanel"))
end

--==================================================================================--
--||                          LÓGICA CENTRAL (RenderStepped)                      ||--
--==================================================================================--
local function ManageCoreLogic()
    local char=localPlayer.Character; local humanoid=char and char:FindFirstChildOfClass("Humanoid"); if not humanoid or not humanoid.RootPart then return end; local rootPart=humanoid.RootPart; if modStates.isGodModeEnabled then humanoid.Health=humanoid.MaxHealth end; if modStates.isInfiniteAmmoEnabled then local tool=char:FindFirstChildOfClass("Tool"); if tool and (tool:FindFirstChild("Ammo") or tool:FindFirstChild("ammo")) then local ammo=tool.Ammo or tool.ammo; if ammo and ammo.Value<999 then ammo.Value=999 end end end; humanoid.WalkSpeed=modStates.isSpeedEnabled and modSettings.walkSpeed or modSettings.originalWalkSpeed; if modStates.isNoclipping then for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then pcall(function() part.CanCollide=false end) end end; humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,modStates.isFlying); if modStates.isFlying then humanoid:ChangeState(Enum.HumanoidStateType.Flying); local camCF=Workspace.CurrentCamera.CFrame; local flyDir=(camCF.lookVector*(UserInputService:IsKeyDown(Enum.KeyCode.W) and -1 or UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)+camCF.rightVector*(UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0)+Vector3.new(0,(UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.Q) and -1 or 0),0)); rootPart.Velocity=flyDir.Unit*modSettings.flySpeed end; if uiData.lockedTarget and uiData.lockedTarget.Character and uiData.lockedTarget.Character:FindFirstChild("HumanoidRootPart") then uiData.lockedTarget.Character.HumanoidRootPart.Anchored=modStates.isTargetLocked else modStates.isTargetLocked=false; uiData.lockedTarget=nil end; for userId,esp in pairs(espTracker) do local player=Players:GetPlayerByUserId(userId); if not player or not player.Character or not modStates.isEspEnabled then esp.Gui:Destroy(); espTracker[userId]=nil end end; if modStates.isEspEnabled then local localPos=rootPart.Position; for _,player in pairs(Players:GetPlayers()) do if player~=localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then local targetRoot,targetHumanoid=player.Character.HumanoidRootPart,player.Character.Humanoid; local esp=espTracker[player.UserId]; if not esp then esp={}; esp.Gui=Create("BillboardGui",{Parent=targetRoot,Name="PlayerESP",AlwaysOnTop=true,Size=UDim2.new(4,0,4,0),Adornee=targetRoot,ClipsDescendants=false,ZIndex=10}); esp.Box=Create("Frame",{Parent=esp.Gui,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,2,0),BackgroundTransparency=1}); Create("UIStroke",{Parent=esp.Box,Color=Color3.fromHSV(0,0,1),Thickness=1.5}); esp.NameLabel=Create("TextLabel",{Parent=esp.Gui,ZIndex=12,Position=UDim2.new(0.5,-100,0.5,-60),Size=UDim2.new(0,200,0,20),Font=Enum.Font.GothamBold,TextSize=16,TextColor3=Color3.fromHSV(0,0,1),BackgroundTransparency=1,Text=player.Name}); esp.DistLabel=Create("TextLabel",{Parent=esp.Gui,ZIndex=12,Position=UDim2.new(0.5,-100,0.5,45),Size=UDim2.new(0,200,0,20),Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromHSV(0,0,0.8),BackgroundTransparency=1}); esp.HealthBarBG=Create("Frame",{Parent=esp.Gui,ZIndex=11,AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0.5,-45),Size=UDim2.new(1.2,0,0,8),BackgroundColor3=Color3.fromHSV(0,0,0),BackgroundTransparency=0.5,BorderSizePixel=0}); esp.HealthBar=Create("Frame",{Parent=esp.HealthBarBG,ZIndex=12,Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromHSV(0.33,1,1),BorderSizePixel=0}); espTracker[player.UserId]=esp end; esp.Gui.Enabled=true; local dist=(localPos-targetRoot.Position).Magnitude; esp.DistLabel.Text=string.format("%s: %.0fm",LANGUAGES[currentLanguage].esp_distance,dist); local healthPercent=math.clamp(targetHumanoid.Health/targetHumanoid.MaxHealth,0,1); esp.HealthBar.Size=UDim2.new(healthPercent,0,1,0); esp.HealthBar.BackgroundColor3=Color3.fromHSV(0.33*healthPercent,1,1) end end end
end

--==================================================================================--
--||                             INICIALIZAÇÃO E LOOPS                            ||--
--==================================================================================--
local function Initialize()
    pcall(BuildUI)
    RunService.RenderStepped:Connect(ManageCoreLogic)
    local char=localPlayer.Character or localPlayer.CharacterAdded:Wait(); local humanoid=char:WaitForChild("Humanoid"); modSettings.originalWalkSpeed=humanoid.WalkSpeed
    localPlayer.CharacterAdded:Connect(function(newChar) local newHumanoid=newChar:WaitForChild("Humanoid"); modSettings.originalWalkSpeed=newHumanoid.WalkSpeed end)
end

Initialize()
