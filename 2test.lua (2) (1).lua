local oldDestroy
oldDestroy = hookfunction(game.Destroy, function(obj, ...)
    if obj:IsA("Tool") then
        return
    end
    return oldDestroy(obj, ...)
end)

local oldIndex
oldIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if self:IsA("Tool") then
        if key == "Parent" and value == nil then
            return
        end
        if key == "Enabled" and value == false then
            return
        end
    end
    return oldIndex(self, key, value)
end)

local oldUnequip
oldUnequip = hookfunction(game.Players.LocalPlayer.Character.Humanoid.UnequipTools, function(...)
    return
end)

local a = Instance.new("ScreenGui")
local b = Instance.new("Frame")
local f = Instance.new("TextLabel")
local g = Instance.new("TextBox")
local e = Instance.new("TextButton")
local closeButton = Instance.new("TextButton")
local i = Instance.new("UICorner")
local j = Instance.new("UIStroke")
local l = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

a.Parent = game.CoreGui
a.Name = "MainMenuGui"
a.ResetOnSpawn = false

i.CornerRadius = UDim.new(0, 12)
j.Color = Color3.fromRGB(0, 0, 0)
j.Thickness = 2

b.Parent = a
b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
b.Position = UDim2.new(0.5, -150, 0.5, -120)
b.Size = UDim2.new(0, 300, 0, 200)
b.Visible = true
b.BorderSizePixel = 0
i:Clone().Parent = b

closeButton.Parent = b
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
i:Clone().Parent = closeButton
j:Clone().Parent = closeButton

e.Parent = b
e.Position = UDim2.new(0.5, -50, 0, 20)
e.Size = UDim2.new(0, 100, 0, 30)
e.Text = "On"
e.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
e.TextColor3 = Color3.fromRGB(255, 255, 255)
e.Font = Enum.Font.SourceSansBold
e.TextSize = 16
i:Clone().Parent = e
j:Clone().Parent = e

f.Parent = b
f.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
f.Position = UDim2.new(0.1, 0, 0.4, 0)
f.Size = UDim2.new(0.8, 0, 0, 20)
f.Text = "Speed:"
f.TextColor3 = Color3.fromRGB(255, 255, 255)
f.Font = Enum.Font.SourceSans
f.TextSize = 16

g.Parent = b
g.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
g.Position = UDim2.new(0.1, 0, 0.5, 0)
g.Size = UDim2.new(0.8, 0, 0, 30)
g.Text = "16"
g.ClearTextOnFocus = true
g.PlaceholderText = "Enter Speed"
g.TextColor3 = Color3.fromRGB(255, 255, 255)
g.Font = Enum.Font.SourceSans
g.TextSize = 18
i:Clone().Parent = g
j:Clone().Parent = g

local isFrozen = false
local defaultSpeed = 16
local speed = defaultSpeed
local moveConnection

local function toggleFreeze()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoidRootPart and humanoid then
        if not isFrozen then
            humanoidRootPart.Anchored = true
            moveConnection = l.RenderStepped:Connect(function()
                if isFrozen then
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame + (humanoid.MoveDirection * speed / 60)
                end
            end)
            isFrozen = true
            e.Text = "Off"
        else
            humanoidRootPart.Anchored = false
            humanoid.WalkSpeed = defaultSpeed
            isFrozen = false
            e.Text = "On"
            if moveConnection then moveConnection:Disconnect() end
        end
    end
end

local function updateSpeed()
    local newSpeed = tonumber(g.Text)
    if newSpeed and newSpeed > 0 then
        speed = newSpeed
        f.Text = "Speed: " .. tostring(speed)
    else
        g.Text = tostring(speed)
    end
end

g.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        updateSpeed()
    end
end)

local dragging, dragStart, startPos
local dragConnection, changeConnection

local function updateDrag(input)
    local delta = input.Position - dragStart
    b.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

b.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = b.Position

        changeConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if changeConnection then changeConnection:Disconnect() end
            end
        end)
    end
end)

b.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    b.Visible = false
end)

e.MouseButton1Click:Connect(function()
    toggleFreeze()
end)
