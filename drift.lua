local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Настройки дрифта
local DRIFT_FRICTION = 0.05 -- Почти нулевое трение (машина будет скользить как по льду)
local DRIFT_TORQUE = 10     -- Сила заноса (угловая скорость)

local isDrifting = false
local currentVehicle = nil

-- UI Кнопка (справа снизу, чтобы не мешать джойстику)
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "DriftControl"
screenGui.ResetOnSpawn = false

local driftButton = Instance.new("TextButton", screenGui)
driftButton.Size = UDim2.new(0.2, 0, 0.1, 0)
driftButton.Position = UDim2.new(0.75, 0, 0.6, 0) -- Сдвинули вправо!
driftButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
driftButton.Text = "DRIFT (OFF)"
driftButton.TextScaled = true
driftButton.Font = Enum.Font.GothamBold
driftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
driftButton.BorderSizePixel = 0
Instance.new("UICorner", driftButton).CornerRadius = UDim.new(0, 10)

-- Функция поиска машины
local function getVehicle()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        return char.Humanoid.SeatPart.Parent
    end
    return nil
end

-- Включение дрифта
local function startDrift(vehicle)
    if not vehicle then return end
    -- Делаем ВСЕ детали машины скользкими
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Убираем трение
            part.CustomPhysicalProperties = PhysicalProperties.new(0.1, DRIFT_FRICTION, 0.1, 1, 1)
        end
    end
end

-- Выключение дрифта (возвращаем сцепление)
local function stopDrift(vehicle)
    if not vehicle then return end
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = nil -- Сбрасываем на стандартные
        end
    end
end

-- Обработка нажатия (теперь это переключатель Toggle, не надо держать палец)
driftButton.MouseButton1Click:Connect(function()
    local vehicle = getVehicle()
    if not vehicle then
        driftButton.Text = "НЕТ МАШИНЫ"
        task.wait(1)
        driftButton.Text = isDrifting and "DRIFT (ON)" or "DRIFT (OFF)"
        return
    end

    isDrifting = not isDrifting
    currentVehicle = vehicle

    if isDrifting then
        driftButton.Text = "DRIFT (ON)"
        driftButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100) -- Зеленый при включении
        startDrift(currentVehicle)
    else
        driftButton.Text = "DRIFT (OFF)"
        driftButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0) -- Оранжевый при выключении
        stopDrift(currentVehicle)
    end
end)

-- Цикл для постоянного заноса во время движения
RunService.Heartbeat:Connect(function()
    if isDrifting and currentVehicle then
        local chassis = currentVehicle.PrimaryPart or currentVehicle:FindFirstChildWhichIsA("BasePart")
        if chassis then
            -- Добавляем вращение (занос)
            chassis.AssemblyAngularVelocity = Vector3.new(chassis.AssemblyAngularVelocity.X, DRIFT_TORQUE, chassis.AssemblyAngularVelocity.Z)
        end
    end
end)

print("Drift Script V2 loaded!")
