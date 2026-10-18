local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local isDrifting = false
local activeVehicle = nil
local currentForce = nil
local currentAttachment = nil

-- Создаем UI
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
            -- Создаем физическую силу для сноса вбок
            local attachment = Instance.new("Attachment")
            attachment.Parent = chassis
            
            local vForce = Instance.new("VectorForce")
            vForce.Attachment0 = attachment
            vForce.RelativeTo = Enum.ActuatorRelativeTo.World
            -- Толкаем машину вбок (вправо), чтобы начался занос
            vForce.Force = chassis.CFrame.RightVector * 30000 
            vForce.Parent = chassis
            
            currentForce = vForce
            currentAttachment = attachment
            
            -- Визуальный эффект (дым)
            for _, p in pairs(veh:GetDescendants()) do
                if p:IsA("BasePart") and (p.Name:lower():find("wheel") or p.Name:lower():find("tire") or p.Name:lower():find("rim")) then
                    local smoke = Instance.new("Smoke")
                    smoke.Parent = p
                    smoke.Color = Color3.fromRGB(200, 200, 200)
                    smoke.Size = 3
                    smoke.RiseVelocity = 2
                    smoke.Opacity = 0.6
                end
            end
        end
    else
        driftButton.Text = "DRIFT (OFF)"
        driftButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        
        -- Удаляем физическую силу и дым
        if activeVehicle then
            for _, child in pairs(activeVehicle:GetDescendants()) do
                if child:IsA("Smoke") then
                    child:Destroy()
                end
            end
        end
        if currentForce then currentForce:Destroy() end
        if currentAttachment then currentAttachment:Destroy() end
        
        activeVehicle = nil
        currentForce = nil
        currentAttachment = nil
    end
end)

-- Динамическое обновление силы, чтобы машина скользила, а не просто телепортировалась
RunService.Heartbeat:Connect(function()
    if isDrifting and currentForce and activeVehicle then
        local chassis = currentForce.Parent
        if chassis then
            -- Если машина едет быстро, толкаем ее вбок сильнее
            local speed = chassis.AssemblyLinearVelocity.Magnitude
            if speed > 5 then
                currentForce.Force = chassis.CFrame.RightVector * (speed * 1000)
            else
                currentForce.Force = Vector3.new(0,0,0) -- Если стоим, не толкаем
            end
        end
    end
end)

print("Drift Script V4 (Slide Physics) loaded!")
