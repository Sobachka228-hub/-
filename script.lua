-- Универсальный Admin Hub для любой игры Roblox
-- Функции: Fly, God Mode, Speed, Noclip, ESP
-- Работает в Blox Fruits, Brookhaven, Adopt Me, Brainrot, Coco и любых других

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "AdminHub"
gui.ResetOnSpawn = false
player:WaitForChild("PlayerGui"):InsertOnIdentity(gui)

-- Основное окно
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 350)
frame.Position = UDim2.new(0.5, -140, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
frame.Parent = gui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.Text = "➤ Admin Hub | Universal"
title.TextColor3 = Color3.fromRGB(255, 180, 80)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

-- Переменные состояний
local flyEnabled = false
local godEnabled = false
local noclipEnabled = false
local speedValue = 16
local speedMultiplier = 1
local espEnabled = false

local bodyVelocity = nil
local noclipConnection = nil

-- Функция полёта
local function setFly(state)
    flyEnabled = state
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChild("Humanoid")
    
    if flyEnabled then
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        end
        bodyVelocity.Parent = hrp
        if humanoid then humanoid.PlatformStand = true end
        
        local moveDirection = Vector3.new(0,0,0)
        local userInput = game:GetService("UserInputService")
        local runService = game:GetService("RunService")
        
        local connection
        connection = runService.RenderStepped:Connect(function()
            if not flyEnabled or not hrp or hrp.Parent == nil then
                if connection then connection:Disconnect() end
                return
            end
            
            local camera = workspace.CurrentCamera
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local up = Vector3.new(0,1,0)
            
            local move = Vector3.new(0,0,0)
            if userInput:IsKeyDown(Enum.KeyCode.W) then move = move + forward end
            if userInput:IsKeyDown(Enum.KeyCode.S) then move = move - forward end
            if userInput:IsKeyDown(Enum.KeyCode.D) then move = move + right end
            if userInput:IsKeyDown(Enum.KeyCode.A) then move = move - right end
            if userInput:IsKeyDown(Enum.KeyCode.Space) then move = move + up end
            if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - up end
            
            if move.Magnitude > 0 then
                move = move.Unit * 85
            end
            bodyVelocity.Velocity = move
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        bodyVelocity = nil
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- God Mode (бесконечное здоровье)
local function setGodMode(state)
    godEnabled = state
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if godEnabled and humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = humanoid.MaxHealth
        humanoid.BreakJointsOnDeath = false
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health <= 0 and godEnabled then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    elseif not godEnabled and humanoid then
        humanoid.MaxHealth = 100
    end
end

-- Noclip
local function setNoclip(state)
    noclipEnabled = state
    if noclipConnection then noclipConnection:Disconnect() end
    if noclipEnabled then
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- ESP (подсветка)
local function setESP(state)
    espEnabled = state
    if espEnabled then
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local highlight = Instance.new("Highlight")
                highlight.Parent = plr.Character
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.Name = "ESP_Highlight"
            end
        end
        
        game.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(char)
                if espEnabled then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = char
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.Name = "ESP_Highlight"
                end
            end)
        end)
    else
        for _, plr in ipairs(game.Players:GetPlayers()) do
            local char = plr.Character
            if char then
                local highlight = char:FindFirstChild("ESP_Highlight")
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- Скорость
local function setSpeed(mult)
    speedMultiplier = mult
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16 * speedMultiplier
    end
    speedSlider.Text = speedMultiplier .. "x"
end

-- GUI элементы
local function makeButton(name, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 30)
    btn.Position = UDim2.new(0.1, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local flyBtn = makeButton("🕊️ ВКЛ/ВЫКЛ Полет", 50, function()
    setFly(not flyEnabled)
    flyBtn.Text = (flyEnabled and "✅ " or "🕊️ ") .. (flyEnabled and "Полёт: ВКЛ" or "Полёт: ВЫКЛ")
end)
flyBtn.Text = "🕊️ Полёт: ВЫКЛ"

local godBtn = makeButton("🛡️ ВКЛ/ВЫКЛ God Mode", 90, function()
    setGodMode(not godEnabled)
    godBtn.Text = (godEnabled and "✅ " or "🛡️ ") .. (godEnabled and "God Mode: ВКЛ" or "God Mode: ВЫКЛ")
end)
godBtn.Text = "🛡️ God Mode: ВЫКЛ"

local noclipBtn = makeButton("🧱 ВКЛ/ВЫКЛ Noclip", 130, function()
    setNoclip(not noclipEnabled)
    noclipBtn.Text = (noclipEnabled and "✅ " or "🧱 ") .. (noclipEnabled and "Noclip: ВКЛ" or "Noclip: ВЫКЛ")
end)
noclipBtn.Text = "🧱 Noclip: ВЫКЛ"

local espBtn = makeButton("👁️ ВКЛ/ВЫКЛ ESP", 170, function()
    setESP(not espEnabled)
    espBtn.Text = (espEnabled and "✅ " or "👁️ ") .. (espEnabled and "ESP: ВКЛ" or "ESP: ВЫКЛ")
end)
espBtn.Text = "👁️ ESP: ВЫКЛ"

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.8, 0, 0, 20)
speedLabel.Position = UDim2.new(0.1, 0, 0, 210)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: x1"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.Parent = frame

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(0.6, 0, 0, 25)
speedSlider.Position = UDim2.new(0.2, 0, 0, 235)
speedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
speedSlider.Text = "x1"
speedSlider.Font = Enum.Font.GothamBold
speedSlider.TextSize = 14
speedSlider.Parent = frame

speedSlider.MouseButton1Click:Connect(function()
    local mult = speedMultiplier + 1
    if mult > 30 then mult = 1 end
    setSpeed(mult)
    speedLabel.Text = "Скорость: x" .. mult
end)

-- Закрывающая кнопка
local closeBtn = makeButton("❌ Закрыть", 300, function()
    gui:Destroy()
end)

print("Admin Hub загружен | Настройки: Fly, God Mode, Noclip, ESP, Speed")
