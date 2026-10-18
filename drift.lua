local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- ПЕРЕМЕННЫЕ
-- ==========================================
local normalGravity = 196.2
local lowGravity = 50
local isDrifting = false
local currentTab = "drift"

-- Звук клика
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://6895079853"
clickSound.Volume = 0.5
clickSound.Parent = playerGui

-- ==========================================
-- ГЛАВНЫЙ ИНТЕРФЕЙС (ScreenGui)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PremiumUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

-- ==========================================
-- ОСНОВНАЯ ПАНЕЛЬ
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 260) -- Увеличили под две колонки
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Перетаскивание
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

-- Неоновая обводка
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(138, 43, 226)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.2

-- Градиент фона
local bgGradient = Instance.new("UIGradient", mainFrame)
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})
bgGradient.Rotation = 45

-- ==========================================
-- ЗАГОЛОВОК (Top Bar)
-- ==========================================
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 16)

-- Прячем нижние углы у шапки (эффект скругления только сверху)
local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0.5, 0)
topBarFix.Position = UDim2.new(0, 0, 0.5, 0)
topBarFix.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

-- Название и Автор
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 18)
title.Position = UDim2.new(0, 16, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Drift Engine v2.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local author = Instance.new("TextLabel")
author.Size = UDim2.new(1, -80, 0, 14)
author.Position = UDim2.new(0, 16, 0, 24)
author.BackgroundTransparency = 1
author.Text = "By: tgk @sendayfin"
author.TextColor3 = Color3.fromRGB(138, 43, 226)
author.TextSize = 11
author.Font = Enum.Font.Gotham
author.TextXAlignment = Enum.TextXAlignment.Left
author.Parent = topBar

-- Кнопка Свернуть
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -34, 0, 10)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundTransparency = 0.9
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = topBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- ВКЛАДКИ (Навигация)
-- ==========================================
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(0, 100, 1, -50)
tabHolder.Position = UDim2.new(0, 10, 0, 50)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = mainFrame

-- Стилизация кнопок вкладок
local function createTabBtn(name, text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, order * 45)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(130, 130, 140)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = tabHolder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(40, 40, 50)
    btnStroke.Thickness = 1
    
    return btn, btnStroke
end

local tabDrift, strokeDrift = createTabBtn("drift", "Drift Engine", 0)
local tabEnv, strokeEnv = createTabBtn("env", "Environment", 1)

-- ==========================================
-- КОНТЕНТ ВКЛАДОК
-- ==========================================
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -130, 1, -60)
contentHolder.Position = UDim2.new(0, 120, 0, 50)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = mainFrame

-- 1. Вкладка Дрифт
local driftPage = Instance.new("Frame")
driftPage.Size = UDim2.new(1, 0, 1, 0)
driftPage.BackgroundTransparency = 1
driftPage.Visible = true
driftPage.Parent = contentHolder

local toggleDriftBtn = Instance.new("TextButton")
toggleDriftBtn.Size = UDim2.new(1, 0, 0, 50)
toggleDriftBtn.Position = UDim2.new(0, 0, 0, 0)
toggleDriftBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
toggleDriftBtn.Text = "ENABLE DRIFT"
toggleDriftBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
toggleDriftBtn.TextSize = 16
toggleDriftBtn.Font = Enum.Font.GothamBold
toggleDriftBtn.BorderSizePixel = 0
toggleDriftBtn.Parent = driftPage
Instance.new("UICorner", toggleDriftBtn).CornerRadius = UDim.new(0, 10)

local driftStroke = Instance.new("UIStroke", toggleDriftBtn)
driftStroke.Color = Color3.fromRGB(60, 60, 70)
driftStroke.Thickness = 1.5

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Offline"
statusLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = driftPage

-- 2. Вкладка Окружение (Скайбоксы)
local envPage = Instance.new("Frame")
envPage.Size = UDim2.new(1, 0, 1, 0)
envPage.BackgroundTransparency = 1
envPage.Visible = false
envPage.Parent = contentHolder

local function createEnvBtn(text, order, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, 0, 0, 35)
    btn.Position = UDim2.new(0, order % 2 == 0 and 0 or 0.52, 0, math.floor(order/2) * 45)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = envPage
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local s = Instance.new("UIStroke", btn)
    s.Color = color or Color3.fromRGB(50, 50, 60)
    s.Thickness = 1
    return btn
end

local btnDay = createEnvBtn("Day", 0, Color3.fromRGB(255, 200, 0))
local btnNight = createEnvBtn("Night", 1, Color3.fromRGB(50, 50, 150))
local btnPink = createEnvBtn("Pink Sky", 2, Color3.fromRGB(255, 100, 200))
local btnReset = createEnvBtn("Reset", 3, Color3.fromRGB(200, 100, 100))

-- ==========================================
-- ЛОГИКА ВКЛАДОК
-- ==========================================
local function switchTab(tab)
    clickSound:Play()
    if tab == "drift" then
        driftPage.Visible = true
        envPage.Visible = false
        TweenService:Create(tabDrift, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 30, 60), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(strokeDrift, TweenInfo.new(0.2), {Color = Color3.fromRGB(138, 43, 226), Thickness = 2}):Play()
        TweenService:Create(tabEnv, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 32), TextColor3 = Color3.fromRGB(130, 130, 140)}):Play()
        TweenService:Create(strokeEnv, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 50), Thickness = 1}):Play()
    else
        driftPage.Visible = false
        envPage.Visible = true
        TweenService:Create(tabEnv, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 30, 60), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(strokeEnv, TweenInfo.new(0.2), {Color = Color3.fromRGB(138, 43, 226), Thickness = 2}):Play()
        TweenService:Create(tabDrift, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 32), TextColor3 = Color3.fromRGB(130, 130, 140)}):Play()
        TweenService:Create(strokeDrift, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 50), Thickness = 1}):Play()
    end
end

tabDrift.MouseButton1Click:Connect(function() switchTab("drift") end)
tabEnv.MouseButton1Click:Connect(function() switchTab("env") end)

-- Свернуть / Развернуть
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    clickSound:Play()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 45)}):Play()
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 260)}):Play()
    end
end)

-- ==========================================
-- ЛОГИКА ДРИФТА
-- ==========================================
local function getVehicle()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        return char.Humanoid.SeatPart.Parent
    end
    return nil
end

toggleDriftBtn.MouseButton1Click:Connect(function()
    local veh = getVehicle()
    if not veh and not isDrifting then
        statusLabel.Text = "Error: Get in a vehicle"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        task.wait(2)
        statusLabel.Text = "Status: Offline"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
        return
    end

    isDrifting = not isDrifting
    clickSound:Play()

    if isDrifting then
        Workspace.Gravity = lowGravity
        TweenService:Create(toggleDriftBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(138, 43, 226),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(driftStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(180, 100, 255), Thickness = 2}):Play()
        
        toggleDriftBtn.Text = "DRIFT ACTIVE"
        statusLabel.Text = "Status: Online"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        if veh then
            for _, p in pairs(veh:GetDescendants()) do
                if p:IsA("BasePart") and (p.Name:lower():find("wheel") or p.Name:lower():find("tire")) then
                    local smoke = Instance.new("Smoke")
                    smoke.Parent = p
                    smoke.Color = Color3.fromRGB(180, 100, 255)
                    smoke.Size = 4
                    smoke.Opacity = 0.6
                end
            end
        end
    else
        Workspace.Gravity = normalGravity
        TweenService:Create(toggleDriftBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
            TextColor3 = Color3.fromRGB(220, 220, 220)
        }):Play()
        TweenService:Create(driftStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 60, 70), Thickness = 1.5}):Play()
        
        toggleDriftBtn.Text = "ENABLE DRIFT"
        statusLabel.Text = "Status: Offline"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
        
        if veh then
            for _, p in pairs(veh:GetDescendants()) do
                if p:IsA("Smoke") then p:Destroy() end
            end
        end
    end
end)

-- ==========================================
-- ЛОГИКА ОКРУЖЕНИЯ (Скайбоксы)
-- ==========================================
local function setSkybox(skyId)
    clickSound:Play()
    local sky = Lighting:FindFirstChild("CustomSky")
    if sky then sky:Destroy() end
    
    if skyId then
        local newSky = Instance.new("Sky")
        newSky.Name = "CustomSky"
        newSky.SkyboxBk = skyId
        newSky.SkyboxDn = skyId
        newSky.SkyboxFt = skyId
        newSky.SkyboxLf = skyId
        newSky.SkyboxRt = skyId
        newSky.SkyboxUp = skyId
        newSky.Parent = Lighting
    end
end

btnDay.MouseButton1Click:Connect(function()
    Lighting.ClockTime = 14 -- 2 часа дня
    Lighting.Brightness = 2
    setSkybox(nil) -- Сброс на дефолт
end)

btnNight.MouseButton1Click:Connect(function()
    Lighting.ClockTime = 0 -- Полночь
    Lighting.Brightness = 0.5
    setSkybox("rbxassetid://1873090842") -- Звездное небо
end)

btnPink.MouseButton1Click:Connect(function()
    Lighting.ClockTime = 17.5 -- Закат
    Lighting.Brightness = 1.5
    setSkybox("rbxassetid://1873090842") -- Пока используем это, в идеале нужен розовый скайбокс
    -- Можно добавить ColorCorrection для розового эффекта
    local cc = Lighting:FindFirstChild("PinkEffect") or Instance.new("ColorCorrectionEffect", Lighting)
    cc.Name = "PinkEffect"
    cc.TintColor = Color3.fromRGB(255, 150, 200)
    cc.Saturation = 0.5
end)

btnReset.MouseButton1Click:Connect(function()
    clickSound:Play()
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    setSkybox(nil)
    local cc = Lighting:FindFirstChild("PinkEffect")
    if cc then cc:Destroy() end
end)

-- Защита при смерти
LocalPlayer.CharacterAdded:Connect(function()
    Workspace.Gravity = normalGravity
    screenGui:Destroy()
end)

print("Premium Drift UI V8 Loaded.")
