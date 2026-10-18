local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- НАСТРОЙКИ
-- ==========================================
local normalGravity = 196.2
local lowGravity = 50
local isDrifting = false
local isMinimized = false

-- Звук клика
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://6895079853"
clickSound.Volume = 0.5
clickSound.Parent = playerGui

-- ==========================================
-- ГЛАВНЫЙ ИНТЕРФЕЙС
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PremiumUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 260)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(138, 43, 226)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.2

-- ==========================================
-- ШАПКА
-- ==========================================
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 16)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0.5, 0)
topBarFix.Position = UDim2.new(0, 0, 0.5, 0)
topBarFix.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

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
-- ВКЛАДКИ
-- ==========================================
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(0, 100, 1, -50)
tabHolder.Position = UDim2.new(0, 10, 0, 50)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = mainFrame

local function createTabBtn(text, order)
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
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(40, 40, 50)
    s.Thickness = 1
    return btn, s
end

local tabDrift, strokeDrift = createTabBtn("Drift", 0)
local tabEnv, strokeEnv = createTabBtn("Sky", 1)

-- ==========================================
-- КОНТЕНТ
-- ==========================================
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -130, 1, -60)
contentHolder.Position = UDim2.new(0, 120, 0, 50)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = mainFrame

-- 1. ДРИФТ
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

-- 2. НЕБО
local envPage = Instance.new("Frame")
envPage.Size = UDim2.new(1, 0, 1, 0)
envPage.BackgroundTransparency = 1
envPage.Visible = false
envPage.Parent = contentHolder

local function createEnvBtn(text, order)
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
    s.Color = Color3.fromRGB(50, 50, 60)
    s.Thickness = 1
    return btn
end

local btnDay = createEnvBtn("Day", 0)
local btnNight = createEnvBtn("Night", 1)
local btnSunset = createEnvBtn("Sunset", 2)
local btnSkeleton = createEnvBtn("Skeleton", 3)
local btnReset = createEnvBtn("Reset", 4)

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

-- ==========================================
-- СВЕРНУТЬ / РАЗВЕРНУТЬ (ИСПРАВЛЕНО)
-- ==========================================
minimizeBtn.MouseButton1Click:Connect(function()
    clickSound:Play()
    isMinimized = not isMinimized
    if isMinimized then
        -- Прячем всё, кроме шапки
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 45)}):Play()
        tabHolder.Visible = false
        contentHolder.Visible = false
        minimizeBtn.Text = "+"
    else
        -- Показываем обратно
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 260)}):Play()
        task.wait(0.15)
        tabHolder.Visible = true
        contentHolder.Visible = true
        minimizeBtn.Text = "—"
    end
end)

-- ==========================================
-- ДРИФТ
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
        TweenService:Create(toggleDriftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(138, 43, 226), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
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
        TweenService:Create(toggleDriftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 38), TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
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
-- СКАЙБОКСЫ (ИСПРАВЛЕНО)
-- ==========================================
local function clearSkybox()
    -- Удаляем ВСЕ скайбоксы
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then
            v:Destroy()
        end
    end
    -- Убираем цветовые фильтры
    local cc = Lighting:FindFirstChild("ColorEffect")
    if cc then cc:Destroy() end
end

local function applySkybox(ids)
    clearSkybox()
    local newSky = Instance.new("Sky")
    newSky.Name = "CustomSky"
    newSky.SkyboxBk = "rbxassetid://" .. ids.Bk
    newSky.SkyboxDn = "rbxassetid://" .. ids.Dn
    newSky.SkyboxFt = "rbxassetid://" .. ids.Ft
    newSky.SkyboxLf = "rbxassetid://" .. ids.Lf
    newSky.SkyboxRt = "rbxassetid://" .. ids.Rt
    newSky.SkyboxUp = "rbxassetid://" .. ids.Up
    newSky.CelestialBodiesShown = false 
    newSky.Parent = Lighting
end

btnDay.MouseButton1Click:Connect(function()
    clickSound:Play()
    clearSkybox()
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
end)

btnNight.MouseButton1Click:Connect(function()
    clickSound:Play()
    applySkybox({
        Bk = "1873090842", Dn = "1873090842", Ft = "1873090842",
        Lf = "1873090842", Rt = "1873090842", Up = "1873090842"
    })
    Lighting.ClockTime = 0
    Lighting.Brightness = 0.5
end)

btnSunset.MouseButton1Click:Connect(function()
    clickSound:Play()
    -- Горный закат
    applySkybox({
        Bk = "600830446", Dn = "600831635", Ft = "600832720",
        Lf = "600886090", Rt = "600833862", Up = "600835177"
    })
    Lighting.ClockTime = 17.5
    Lighting.Brightness = 1.5
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Name = "ColorEffect"
    cc.TintColor = Color3.fromRGB(255, 180, 200)
    cc.Saturation = 0.3
end)

btnSkeleton.MouseButton1Click:Connect(function()
    clickSound:Play()
    applySkybox({
        Bk = "110544794736899", Dn = "110544794736899", Ft = "110544794736899",
        Lf = "110544794736899", Rt = "110544794736899", Up = "110544794736899"
    })
    Lighting.ClockTime = 0
    Lighting.Brightness = 0.2
end)

btnReset.MouseButton1Click:Connect(function()
    clickSound:Play()
    clearSkybox()
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
end)

-- Защита при смерти
LocalPlayer.CharacterAdded:Connect(function()
    Workspace.Gravity = normalGravity
    screenGui:Destroy()
end)

print("Premium Drift UI V10 Loaded.")
