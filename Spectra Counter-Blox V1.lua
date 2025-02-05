-- Services
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Variables
local AimbotEnabled = false
local ESPEnabled = false
local AimbotStrength = 10
local TargetPart = "Head"  -- Target part for Aimbot
local ESPObjects = {}  -- To store ESP squares for players

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- Spectra Toggle Button
local SpectraButton = Instance.new("TextButton")
SpectraButton.Size = UDim2.new(0, 100, 0, 40)
SpectraButton.Position = UDim2.new(0, 10, 0.5, -20)
SpectraButton.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
SpectraButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpectraButton.Text = "Spectra"
SpectraButton.Font = Enum.Font.SourceSansBold
SpectraButton.TextSize = 18
SpectraButton.Parent = ScreenGui

-- Main UI
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 60)
MainFrame.BorderSizePixel = 2
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
Title.Text = "Spectra Cheat Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Function to Add Buttons
function createButton(text, pos, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.Position = UDim2.new(0, 5, 0, pos)
    Button.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = text
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 16
    Button.Parent = MainFrame
    Button.MouseButton1Click:Connect(callback)
end

-- Create Slider for Aimbot Strength
function createSlider(minValue, maxValue, defaultValue, text, position, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0, 300, 0, 50)
    SliderFrame.Position = UDim2.new(0, 5, 0, position)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
    SliderFrame.Parent = MainFrame

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Text = text
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.TextSize = 16
    SliderLabel.Parent = SliderFrame

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, 0, 0, 10)
    Slider.Position = UDim2.new(0, 0, 0, 20)
    Slider.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
    Slider.Text = ""
    Slider.Parent = SliderFrame

    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 50, 0, 10)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Handle.Parent = Slider

    Handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local newPos = math.clamp(input.Position.X - Slider.AbsolutePosition.X, 0, Slider.AbsoluteSize.X)
            Handle.Position = UDim2.new(0, newPos, 0, 0)
            local percentage = newPos / Slider.AbsoluteSize.X
            local value = minValue + (percentage * (maxValue - minValue))
            callback(value)
        end
    end)

    callback(defaultValue) -- Set initial value
end

-- Toggle Cheat
createButton("Toggle Cheat", 50, function()
    AimbotEnabled = not AimbotEnabled
end)

-- ESP Toggle
createButton("Toggle ESP", 90, function()
    ESPEnabled = not ESPEnabled
end)

-- Spectra Button Toggles UI
SpectraButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Aimbot Strength Slider
createSlider(0, 100, 10, "Aimbot Strength", 250, function(value)
    AimbotStrength = value
end)

-- Optimized ESP Function
RunService.RenderStepped:Connect(function()
    -- Only update ESP when it's enabled
    if ESPEnabled then
        -- Loop through all players in the game
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Check if player is not a teammate
                if player.Team ~= LocalPlayer.Team then
                    local RootPart = player.Character.HumanoidRootPart
                    local vector, onScreen = Camera:WorldToViewportPoint(RootPart.Position)
                    
                    -- Draw the ESP box only if the player is on-screen
                    if onScreen then
                        -- Create the ESP box if it doesn't exist
                        if not ESPObjects[player] then
                            local ESPBox = Drawing.new("Square")
                            ESPBox.Size = Vector2.new(50, 50)  -- Set size of the box
                            ESPBox.Position = Vector2.new(vector.X - 25, vector.Y - 25)  -- Adjust position to center the box
                            ESPBox.Color = Color3.fromRGB(255, 0, 0) -- Red outline
                            ESPBox.Thickness = 3
                            ESPBox.Visible = true
                            ESPBox.Filled = false
                            ESPObjects[player] = ESPBox
                        else
                            -- Update the position of the ESP box if it already exists
                            local ESPBox = ESPObjects[player]
                            ESPBox.Position = Vector2.new(vector.X - 25, vector.Y - 25)
                            ESPBox.Visible = true
                        end
                    else
                        -- Hide the ESP box when player is off-screen
                        if ESPObjects[player] then
                            ESPObjects[player].Visible = false
                        end
                    end
                end
            else
                -- Remove ESP box if the player is dead or disconnected
                if ESPObjects[player] then
                    ESPObjects[player]:Remove()
                    ESPObjects[player] = nil
                end
            end
        end
    end
end)

-- Aimbot Function
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mouseLocation = UserInputService:GetMouseLocation()

        -- Find closest player to aim at
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Team Check: If Teamcheck is enabled, don't aim at teammates
                if player.Team ~= LocalPlayer.Team then
                    local RootPart = player.Character.HumanoidRootPart
                    local screenPos, onScreen = Camera:WorldToViewportPoint(RootPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                        if distance < shortestDistance then
                            closestPlayer = RootPart
                            shortestDistance = distance
                        end
                    end
                end
            end
        end

        -- Aim at closest player
        if closestPlayer then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestPlayer.Position), AimbotStrength / 100)
        end
    end
end)
