-- Drift Mode For Brookhaven by (FELIX SCRIPT)
Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false
local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 135, 0, 50)
button.Position = UDim2.new(1, -185, 0.5, -25) -- Кнопка справа по центру
button.Text = "Drift Mode by KAKA: OFF"
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.BorderSizePixel = 0
button.AutoButtonColor = true

local normalGravity = 196.2
local lowGravity = 50
local enabled = false

button.MouseButton1Click:Connect(function()
    enabled = not enabled
    Workspace.Gravity = enabled and lowGravity or normalGravity
    button.Text = enabled and "drift mode by KAKA: ON" or "Drift mode by KAKA: OFF"
end)
