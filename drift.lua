local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local isDrifting = false
local activeVehicle = nil

-- Создаем UI (перенесли выше и правее, чтобы не мешать)
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "DriftControl"
screenGui.ResetOnSpawn = false

local driftButton = Instance.new("TextButton", screenGui)
driftButton.Size = UDim2.new(0.25, 0, 0.1, 0)
driftButton.Position = UDim2.new(0.7, 0, 0.2, 0) -- Безопасное место
driftButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
driftButton.Text = "DRIFT (OFF)"
driftButton.TextScaled = true
driftButton.Font = Enum.Font.GothamBold
driftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
driftButton.BorderSizePixel = 0
Instance.new("UICorner", driftButton).CornerRadius = UDim.new(0, 10)

-- Поиск машины
local function getVehicle()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        return char.Humanoid.SeatPart.Parent
    end
    return nil
end

driftButton.MouseButton1Click:Connect(function()
    local veh = getVehicle()
    if not veh then
        driftButton.Text = "СЯДЬ В МАШИНУ"
        task.wait(1)
        driftButton.Text = isDrifting and "DRIFT (ON)" or "DRIFT (OFF)"
        return
    end

    isDrifting = not isDrifting

    if isDrifting then
        driftButton.Text = "DRIFT (ON)"
        driftButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        activeVehicle = veh
        
        -- Ищем главную часть машины (шасси)
        local chassis = veh.PrimaryPart or veh:FindFirstChild("Chassis")
        if not chassis then
            local biggest = 0
            for _, p in pairs(veh:GetChildren()) do
                if p:IsA("BasePart") and p.Size.Magnitude > biggest then
                    chassis = p
                    biggest = p.Size.Magnitude
                end
            end
        end
        
        if chassis then
            -- Применяем физическую силу (занос)
            local bAV = Instance.new("BodyAngularVelocity")
            bAV.AngularVelocity = Vector3.new(0, 25, 0) -- Закручиваем машину
            bAV.MaxTorque = Vector3.new(0, math.huge, 0) -- Огромная сила
            bAV.Parent = chassis
            
            -- Добавляем дым из-под колес для эффекта
            for _, p in pairs(veh:GetDescendants()) do
                if p:IsA("BasePart") and (p.Name:lower():find("wheel") or p.Name:lower():find("tire")) then
                    local smoke = Instance.new("Smoke")
                    smoke.Parent = p
                    smoke.Color = Color3.fromRGB(200, 200, 200)
                    smoke.Size = 4
                    smoke.RiseVelocity = 3
                    smoke.Opacity = 0.5
                end
            end
        end
    else
        driftButton.Text = "DRIFT (OFF)"
        driftButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        
        -- Удаляем все силы и дым
        if activeVehicle then
            for _, child in pairs(activeVehicle:GetDescendants()) do
                if child:IsA("BodyAngularVelocity") or child:IsA("Smoke") then
                    child:Destroy()
                end
            end
        end
        activeVehicle = nil
    end
end)

print("Drift Script V3 (Real Physics) loaded!")
