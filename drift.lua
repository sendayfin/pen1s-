local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local isDrifting = false
local activeVehicle = nil
local driftForce = nil
local yawForce = nil

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "DriftControl"
screenGui.ResetOnSpawn = false

local driftButton = Instance.new("TextButton", screenGui)
driftButton.Size = UDim2.new(0.25, 0, 0.1, 0)
driftButton.Position = UDim2.new(0.7, 0, 0.2, 0)
driftButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
driftButton.Text = "DRIFT (OFF)"
driftButton.TextScaled = true
driftButton.Font = Enum.Font.GothamBold
driftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
driftButton.BorderSizePixel = 0
Instance.new("UICorner", driftButton).CornerRadius = UDim.new(0, 10)

local function getVehicleAndSeat()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local seat = char.Humanoid.SeatPart
        if seat:IsA("VehicleSeat") then
            return seat.Parent, seat
        end
    end
    return nil, nil
end

driftButton.MouseButton1Click:Connect(function()
    local veh = getVehicleAndSeat()
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
        
        -- Добавляем дым на колеса
        for _, p in pairs(veh:GetDescendants()) do
            if p:IsA("BasePart") and (p.Name:lower():find("wheel") or p.Name:lower():find("tire") or p.Name:lower():find("rim")) then
                local smoke = Instance.new("Smoke")
                smoke.Parent = p
                smoke.Color = Color3.fromRGB(200, 200, 200)
                smoke.Size = 3
                smoke.Opacity = 0.5
            end
        end
    else
        driftButton.Text = "DRIFT (OFF)"
        driftButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        if activeVehicle then
            for _, child in pairs(activeVehicle:GetDescendants()) do
                if child:IsA("Smoke") or child.Name == "DriftVectorForce" or child.Name == "DriftYawForce" then 
                    child:Destroy() 
                end
            end
        end
        activeVehicle = nil
        driftForce = nil
        yawForce = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if isDrifting and activeVehicle then
        local veh, seat = getVehicleAndSeat()
        if veh and seat then
            local chassis = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
            if chassis then
                local speed = chassis.AssemblyLinearVelocity.Magnitude
                local steer = seat.Steer 
                local throttle = seat.Throttle 
                
                -- Если едем и крутим руль
                if speed > 10 and throttle > 0 and math.abs(steer) > 0.1 then
                    -- Создаем силы, если их нет
                    if not driftForce or not driftForce.Parent then
                        local attach = Instance.new("Attachment", chassis)
                        
                        driftForce = Instance.new("VectorForce", chassis)
                        driftForce.Name = "DriftVectorForce"
                        driftForce.Attachment0 = attach
                        driftForce.RelativeTo = Enum.ActuatorRelativeTo.World

                        yawForce = Instance.new("BodyAngularVelocity", chassis)
                        yawForce.Name = "DriftYawForce"
                        yawForce.MaxTorque = Vector3.new(0, 100000, 0) -- Ограничиваем силу, чтобы не вертело как юлу
                    end
                    
                    -- 1. Выталкиваем жопу машины вбок (чтобы скользила)
                    -- Если руль вправо (steer > 0), толкаем влево (отрицательное значение RightVector)
                    local sideForceValue = -steer * math.min(speed * 2000, 40000)
                    driftForce.Force = chassis.CFrame.RightVector * sideForceValue
                    
                    -- 2. Немного доворачиваем кузов (задаем угловую скорость)
                    -- Ограничиваем до 2.5 радиан в секунду, чтобы не крутило
                    local yawSpeed = steer * math.min(speed * 0.05, 2.5) 
                    yawForce.AngularVelocity = Vector3.new(0, yawSpeed, 0)
                    
                else
                    -- Если едем прямо или отпустили газ - убираем занос
                    if driftForce then driftForce.Force = Vector3.new(0,0,0) end
                    if yawForce then yawForce.AngularVelocity = Vector3.new(0,0,0) end
                end
            end
        end
    end
end)

print("Drift Script V6 (Realistic Slide) loaded!")
