-- Летающий карандаш (без нарушений) — для Executor Delta, работает на телефоне
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Стиль R6 только
if humanoid:GetAttribute("RigType") ~= "R6" then
    warn("Этот скрипт работает только с R6-персонажами.")
    return
end

-- Скрыть оригинальное тело
local function hideCharacter()
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") or child:IsA("MeshPart") then
            child.Transparency = 1
            child.CanCollide = false
        end
    end
end
hideCharacter()

-- Создаем карандаш из 3 частей: тело, грифель, резинка
local pencil = Instance.new("Part")
pencil.Name = "FlyingPencil"
pencil.Shape = Enum.PartType.Cylinder
pencil.Size = Vector3.new(0.4, 3, 0.4)
pencil.Material = Enum.Material.Neon
pencil.Color = Color3.fromRGB(255, 200, 100) -- желтый карандаш
pencil.Anchored = true
pencil.CanCollide = false
pencil.Transparency = 0.1
pencil.Locked = true
pencil.CFrame = character.HumanoidRootPart.CFrame
pencil.Parent = workspace

-- Грифель (черный кончик)
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

-- Резинка (красная верхушка)
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

-- Собираем всё в группу для удобства
local pencilGroup = Instance.new("Folder")
pencilGroup.Name = "FlyingPencilGroup"
pencilGroup.Parent = workspace
pencil.Parent = pencilGroup
tip.Parent = pencilGroup
eraser.Parent = pencilGroup

-- Следим за позицией игрока
local function updatePencilPosition()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = player.Character.HumanoidRootPart
    pencilGroup.CFrame = root.CFrame
end

RunService.Heartbeat:Connect(updatePencilPosition)

-- Управление полетом: вверх/вниз по кнопкам
local upButton = Instance.new("TextButton")
upButton.Text = "↑"
upButton.Size = UDim2.new(0, 80, 0, 60)
upButton.Position = UDim2.new(1, -90, 0, 20)
upButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Font = Enum.Font.SourceSansBold
upButton.BorderSizePixel = 0
upButton.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local downButton = Instance.new("TextButton")
downButton.Text = "↓"
downButton.Size = UDim2.new(0, 80, 0, 60)
downButton.Position = UDim2.new(1, -90, 0, 90)
downButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Font = Enum.Font.SourceSansBold
downButton.BorderSizePixel = 0
downButton.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local flightSpeed = 15 -- скорость полета

upButton.MouseButton1Down:Connect(function()
    local currentCFrame = pencilGroup.CFrame
    pencilGroup.CFrame = currentCFrame + Vector3.new(0, flightSpeed * 0.1, 0)
end)

downButton.MouseButton1Down:Connect(function()
    local currentCFrame = pencilGroup.CFrame
    pencilGroup.CFrame = currentCFrame + Vector3.new(0, -flightSpeed * 0.1, 0)
end)

-- Управление полетом влево/вправо через виртуальный джойстик Roblox
-- Roblox автоматически создает джойстик на телефоне — мы его используем!
local moveSpeed = 10

RunService.Heartbeat:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local root = player.Character.HumanoidRootPart
    local moveVector = Vector3.new(0, 0, 0)

    -- Проверяем ввод джойстика (только на мобильных)
    if UserInputService:IsUserInputActive(Enum.UserInputType.VirtualRightThumb) then
        local thumbInput = UserInputService:GetUserInputState(Enum.UserInputType.VirtualRightThumb)
        local joystickDelta = thumbInput.Position - Vector2.new(0.5, 0.5) -- центр джойстика
        moveVector = Vector3.new(joystickDelta.X * moveSpeed, 0, joystickDelta.Y * moveSpeed)
    end

    -- Смещаем карандаш в сторону движения
    if moveVector.Magnitude > 0 then
        local newCFrame = pencilGroup.CFrame + (pencilGroup.CFrame.LookVector * moveVector.Z) + (pencilGroup.CFrame.RightVector * moveVector.X)
        pencilGroup.CFrame = newCFrame
    end
end)

-- Убираем карандаш при смерти/выходе
player.DescendantAdded:Connect(function(obj)
    if obj:IsA("Humanoid") and obj.Health <= 0 then
        wait(1)
        if pencilGroup and pencilGroup.Parent then
            pencilGroup:Destroy()
        end
    end
end)

player.CharacterAdded:Connect(function(newChar)
    wait(0.5)
    if pencilGroup and pencilGroup.Parent then
        pencilGroup:Destroy()
    end
    -- Пересоздаем
    hideCharacter()
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

-- Убираем UI при выходе
player:GetPropertyChangedSignal("Character"):Connect(function()
    if not player.Character then
        wait(0.5)
        if pencilGroup and pencilGroup.Parent then
            pencilGroup:Destroy()
        end
        if upButton and upButton.Parent then
            upButton:Destroy()
        end
        if downButton and downButton.Parent then
            downButton:Destroy()
        end
    end
end)
