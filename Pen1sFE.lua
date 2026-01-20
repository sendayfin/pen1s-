local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Проверка R6
if humanoid:GetAttribute("RigType") ~= "R6" then
    warn("Только R6 персонажи поддерживаются!")
    return
end

-- Скрываем оригинальное тело
local function hideCharacter()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
end
hideCharacter()

-- Создаём карандаш (одна часть — просто цилиндр)
local pencil = Instance.new("Part")
pencil.Name = "FlyingPencil"
pencil.Shape = Enum.PartType.Cylinder
pencil.Size = Vector3.new(0.4, 3, 0.4)
pencil.Material = Enum.Material.Neon
pencil.Color = Color3.fromRGB(255, 200, 100) -- жёлтый
pencil.Anchored = true
pencil.CanCollide = false
pencil.Transparency = 0.1
pencil.Locked = true
pencil.Parent = workspace

-- Создаём грифель (чёрный кончик)
local tip = Instance.new("Part")
tip.Name = "PencilTip"
tip.Shape = Enum.PartType.Cylinder
tip.Size = Vector3.new(0.2, 0.5, 0.2)
tip.Material = Enum.Material.Neon
tip.Color = Color3.fromRGB(20, 20, 20)
tip.Anchored = true
tip.CanCollide = false
tip.CFrame = pencil.CFrame * CFrame.new(0, -1.3, 0)
tip.Parent = workspace

-- Создаём резинку (красная верхушка)
local eraser = Instance.new("Part")
eraser.Name = "PencilEraser"
eraser.Shape = Enum.PartType.Cylinder
eraser.Size = Vector3.new(0.5, 0.3, 0.5)
eraser.Material = Enum.Material.Neon
eraser.Color = Color3.fromRGB(255, 80, 80)
eraser.Anchored = true
eraser.CanCollide = false
eraser.CFrame = pencil.CFrame * CFrame.new(0, 1.3, 0)
eraser.Parent = workspace

-- Группируем
local pencilGroup = Instance.new("Folder")
pencilGroup.Name = "FlyingPencilGroup"
pencilGroup.Parent = workspace
pencil.Parent = pencilGroup
tip.Parent = pencilGroup
eraser.Parent = pencilGroup

-- Привязываем карандаш к позиции игрока
local function updatePencil()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = player.Character.HumanoidRootPart
    pencilGroup.CFrame = root.CFrame
end

RunService.Heartbeat:Connect(updatePencil)

-- Кнопки управления
local function createButton(text, y, color, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 80, 0, 60)
    btn.Position = UDim2.new(1, -90, 0, y)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.BorderSizePixel = 0
    btn.Parent = player:WaitForChild("PlayerGui")
    btn.MouseButton1Down:Connect(callback)
    return btn
end

local upBtn = createButton("↑", 20, Color3.fromRGB(50, 150, 255), function()
    local cf = pencilGroup.CFrame
    pencilGroup.CFrame = cf + Vector3.new(0, 0.5, 0)
end)

local downBtn = createButton("↓", 90, Color3.fromRGB(255, 100, 100), function()
    local cf = pencilGroup.CFrame
    pencilGroup.CFrame = cf + Vector3.new(0, -0.5, 0)
end)

-- Управление джойстиком (телефон)
local moveSpeed = 8
RunService.Heartbeat:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local root = player.Character.HumanoidRootPart
    local joystick = UserInputService:GetUserInputState(Enum.UserInputType.VirtualRightThumb)
    local delta = joystick.Position - Vector2.new(0.5, 0.5)

    if delta.Magnitude > 0.1 then
        local moveX = delta.X * moveSpeed * 0.05
        local moveZ = delta.Y * moveSpeed * 0.05
        local look = pencilGroup.CFrame.LookVector
        local right = pencilGroup.CFrame.RightVector

        pencilGroup.CFrame = pencilGroup.CFrame + (look * moveZ) + (right * moveX)
    end
end)

-- Пересоздаём при смерти/спауне
player.CharacterAdded:Connect(function(newChar)
    wait(0.1)
    hideCharacter()
    pencilGroup:ClearAllChildren()
    pencil:Destroy()
    tip:Destroy()
    eraser:Destroy()

    pencil = Instance.new("Part")
    pencil.Name = "FlyingPencil"
    pencil.Shape = Enum.PartType.Cylinder
    pencil.Size = Vector3.new(0.4, 3, 0.4)
    pencil.Material = Enum.Material.Neon
    pencil.Color = Color3.fromRGB(255, 200, 100)
    pencil.Anchored = true
    pencil.CanCollide = false
    pencil.Transparency = 0.1
    pencil.Locked = true
    pencil.Parent = workspace

    tip = Instance.new("Part")
    tip.Name = "PencilTip"
    tip.Shape = Enum.PartType.Cylinder
    tip.Size = Vector3.new(0.2, 0.5, 0.2)
    tip.Material = Enum.Material.Neon
    tip.Color = Color3.fromRGB(20, 20, 20)
    tip.Anchored = true
    tip.CanCollide = false
    tip.CFrame = pencil.CFrame * CFrame.new(0, -1.3, 0)
    tip.Parent = workspace

    eraser = Instance.new("Part")
    eraser.Name = "PencilEraser"
    eraser.Shape = Enum.PartType.Cylinder
    eraser.Size = Vector3.new(0.5, 0.3, 0.5)
    eraser.Material = Enum.Material.Neon
    eraser.Color = Color3.fromRGB(255, 80, 80)
    eraser.Anchored = true
    eraser.CanCollide = false
    eraser.CFrame = pencil.CFrame * CFrame.new(0, 1.3, 0)
    eraser.Parent = workspace

    pencilGroup = Instance.new("Folder")
    pencilGroup.Name = "FlyingPencilGroup"
    pencilGroup.Parent = workspace
    pencil.Parent = pencilGroup
    tip.Parent = pencilGroup
    eraser.Parent = pencilGroup
end)

-- Убираем кнопки при выходе
player:GetPropertyChangedSignal("Character"):Connect(function()
    if not player.Character then
        wait(0.5)
        if upBtn.Parent then upBtn:Destroy() end
        if downBtn.Parent then downBtn:Destroy() end
    end
end)
