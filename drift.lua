-- Drift Script for Brookhaven (Prototype)
-- Работает на мобильных устройствах (Delta)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Настройки дрифта (можно менять)
local DRIFT_FRICTION = 0.3 -- Чем меньше, тем сильнее скольжение
local DRIFT_TORQUE = 5000   -- Сила заноса (угловая скорость)

local isDrifting = false
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создаем UI кнопку для мобильных устройств
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "DriftControl"
screenGui.ResetOnSpawn = false

local driftButton = Instance.new("TextButton", screenGui)
driftButton.Size = UDim2.new(0.2, 0, 0.1, 0)
driftButton.Position = UDim2.new(0.1, 0, 0.7, 0)
driftButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
driftButton.Text = "DRIFT"
driftButton.TextScaled = true
driftButton.Font = Enum.Font.GothamBold
driftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
driftButton.BorderSizePixel = 0

local corner = Instance.new("UICorner", driftButton)
corner.CornerRadius = UDim.new(0, 10)

-- Визуальный эффект дыма
local smokeAttachment
local smokeEmitter

-- Функция для применения физики дрифта к машине
local function applyDriftPhysics(vehicle)
    if not vehicle then return end
    
    -- Ищем колеса (обычно они называются Wheel или имеют HingeConstraint)
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("wheel") then
            -- 1. Уменьшаем трение, чтобы машина скользила
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, DRIFT_FRICTION, 0.5, 1, 1)
        end
    end
    
    -- 2. Добавляем угловую скорость для заноса
    local chassis = vehicle.PrimaryPart or vehicle:FindFirstChild("Chassis")
    if chassis then
        local currentVel = chassis.AssemblyAngularVelocity
        chassis.AssemblyAngularVelocity = Vector3.new(currentVel.X, DRIFT_TORQUE, currentVel.Z)
    end
end

-- Функция для сброса физики в стандартное состояние
local function resetPhysics(vehicle)
    if not vehicle then return end
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("wheel") then
            part.CustomPhysicalProperties = nil -- Возвращаем стандартные свойства
        end
    end
    local chassis = vehicle.PrimaryPart or vehicle:FindFirstChild("Chassis")
    if chassis then
        chassis.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

-- Обработчик нажатия кнопки
driftButton.MouseButton1Down:Connect(function()
    isDrifting = true
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Ищем машину, в которой сидит игрок
    local vehicle = character:FindFirstChild("Humanoid") and character.Humanoid.SeatPart and character.Humanoid.SeatPart.Parent
    if vehicle then
        applyDriftPhysics(vehicle)
    end
end)

driftButton.MouseButton1Up:Connect(function()
    isDrifting = false
    local character = LocalPlayer.Character
    if not character then return end
    
    local vehicle = character:FindFirstChild("Humanoid") and character.Humanoid.SeatPart and character.Humanoid.SeatPart.Parent
    if vehicle then
        resetPhysics(vehicle)
    end
end)

-- Цикл для обновления физики (для мобильных устройств, где кнопка может "залипать")
RunService.Heartbeat:Connect(function()
    if isDrifting then
        local character = LocalPlayer.Character
        if not character then return end
        
        local vehicle = character:FindFirstChild("Humanoid") and character.Humanoid.SeatPart and character.Humanoid.SeatPart.Parent
        if vehicle then
            applyDriftPhysics(vehicle)
        end
    end
end)

print("Drift Script loaded! Press and hold DRIFT button to slide.")