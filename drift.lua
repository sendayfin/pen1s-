local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- НАСТРОЙКИ
-- ==========================================
local normalGravity = 196.2
local lowGravity = 50
local isDrifting = false
local isMenuOpen = true

-- ==========================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (Премиум стиль)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DriftUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Главная панель (Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 120)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Позволяет перетаскивать меню пальцем
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Обводка (Неон)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(138, 43, 226)
stroke.Thickness = 1.5
stroke.Transparency = 0.2

-- Градиентный фон
local grad = Instance.new("UIGradient", mainFrame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 10, 40))
})
grad.Rotation = 45

-- Заголовок (Верхняя полоска)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Drift Engine v2.0"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Кнопка Свернуть/Развернуть (в заголовке)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
minimizeBtn.Position = UDim2.new(1, -25, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = topBar

-- Текст статуса
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 0, 20)
statusText.Position = UDim2.new(0, 10, 0, 40)
statusText.BackgroundTransparency = 1
statusText.Text = "System: Offline"
statusText.TextColor3 = Color3.fromRGB(100, 100, 100)
statusText.TextSize = 12
statusText.Font = Enum.Font.Gotham
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = mainFrame

-- Главная кнопка включения
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 65)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
toggleBtn.Text = "ENABLE DRIFT"
toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Color3.fromRGB(80, 80, 90)
btnStroke.Thickness = 1

-- ==========================================
-- ЛОГИКА UI (Анимации и Перетаскивание)
-- ==========================================
-- Свернуть/Развернуть
local isMinimized = false
local originalSize = mainFrame.Size
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 220, 0, 30)}):Play()
        minimizeBtn.Text = "+"
        toggleBtn.Visible = false
        statusText.Visible = false
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = originalSize}):Play()
        task.wait(0.1)
        minimizeBtn.Text = "—"
        toggleBtn.Visible = true
        statusText.Visible = true
    end
end)

-- Эффекты наведения (Hover) для ПК
toggleBtn.MouseEnter:Connect(function()
    if not isDrifting then
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
    end
end)
toggleBtn.MouseLeave:Connect(function()
    if not isDrifting then
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
    end
end)

-- Звук клика (Создаем аудио-объект)
local clickSound = Instance.new("Sound", screenGui)
clickSound.SoundId = "rbxassetid://6895079853" -- Звук клика (можно поменять)
clickSound.Volume = 0.5

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

toggleBtn.MouseButton1Click:Connect(function()
    local veh = getVehicle()
    if not veh and not isDrifting then
        statusText.Text = "System: Error (Not in vehicle)"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(2)
        statusText.Text = "System: Offline"
        statusText.TextColor3 = Color3.fromRGB(100, 100, 100)
        return
    end

    isDrifting = not isDrifting
    clickSound:Play()

    if isDrifting then
        -- Включение
        Workspace.Gravity = lowGravity
        
        -- Анимация кнопки
        TweenService:Create(toggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundColor3 = Color3.fromRGB(138, 43, 226), -- Фиолетовый неон
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.3), {
            Color = Color3.fromRGB(180, 100, 255),
            Thickness = 2
        }):Play()
        
        toggleBtn.Text = "DRIFT ACTIVE"
        statusText.Text = "System: Online"
        statusText.TextColor3 = Color3.fromRGB(138, 43, 226)
        
        -- Добавляем дым к машине
        if veh then
            for _, p in pairs(veh:GetDescendants()) do
                if p:IsA("BasePart") and (p.Name:lower():find("wheel") or p.Name:lower():find("tire")) then
                    local smoke = Instance.new("Smoke")
                    smoke.Parent = p
                    smoke.Color = Color3.fromRGB(180, 100, 255) -- Фиолетовый дым
                    smoke.Size = 4
                    smoke.Opacity = 0.6
                    smoke.RiseVelocity = 2
                end
            end
        end
        
    else
        -- Выключение
        Workspace.Gravity = normalGravity
        
        -- Анимация кнопки
        TweenService:Create(toggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 45),
            TextColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.3), {
            Color = Color3.fromRGB(80, 80, 90),
            Thickness = 1
        }):Play()
        
        toggleBtn.Text = "ENABLE DRIFT"
        statusText.Text = "System: Offline"
        statusText.TextColor3 = Color3.fromRGB(100, 100, 100)
        
        -- Удаляем дым
        if veh then
            for _, p in pairs(veh:GetDescendants()) do
                if p:IsA("Smoke") then
                    p:Destroy()
                end
            end
        end
    end
end)

-- Очистка при смерти (чтобы гравитация не осталась сломанной)
LocalPlayer.CharacterAdded:Connect(function(char)
    Workspace.Gravity = normalGravity
    if screenGui then screenGui:Destroy() end
end)

print("Drift UI V7 Loaded. System ready.")
