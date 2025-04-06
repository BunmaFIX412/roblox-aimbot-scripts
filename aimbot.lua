local FOV_RADIUS = 120
local AIM_SPEED = 0.2
local MAX_DISTANCE = 500
local AIMBOT_VISIBLE = true -- ตัวแปรใหม่ควบคุมการมองเห็น/การทำงานของ Aimbot (เริ่มต้นให้เปิด)
local FOV_ENABLED = true
local ESP_ENABLED = false

local camera = workspace.CurrentCamera
local localPlayer = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Radius = FOV_RADIUS
fovCircle.Visible = FOV_ENABLED

local espObjects = {}

local function updateFOV()
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Visible = FOV_ENABLED
    fovCircle.Radius = FOV_RADIUS
end

local function isInPOV(target)
    local screenPoint, onScreen = camera:WorldToViewportPoint(target.Position)
    if not onScreen then return false end
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
    return distance <= FOV_RADIUS
end

local function isObstructed(target)
    local rayOrigin = camera.CFrame.Position
    local rayDirection = (target.Position - rayOrigin).unit * MAX_DISTANCE
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {localPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if raycastResult then
        if raycastResult.Instance and raycastResult.Instance:IsA("BasePart") then
            if raycastResult.Instance.CanCollide then
                return true
            end
        end
    end
    return false
end

local function getClosestTarget()
    if not AIMBOT_VISIBLE then return nil end -- ตรวจสอบแค่ AIMBOT_VISIBLE

    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = player.Character.Head
                if isInPOV(head) and not isObstructed(head) then
                    local distance = (head.Position - camera.CFrame.Position).Magnitude
                    if distance < shortestDistance then
                        closestTarget = head
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    if closestTarget then
        print("Target found: " .. closestTarget.Parent.Name)
    else
        print("No target found.")
    end

    return closestTarget
end

local function aimAt(target)
    if AIMBOT_VISIBLE and target then -- ตรวจสอบแค่ AIMBOT_VISIBLE
        local direction = (target.Position - camera.CFrame.Position).unit
        local newCFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Position), AIM_SPEED)
        camera.CFrame = newCFrame
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    local target = getClosestTarget()
    if target then
        aimAt(target)
    end
    updateFOV()
end)

-- GUI System
local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
screenGui.Name = "AimbotGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Aimbot Settings"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Center

local toggleFOV = Instance.new("TextButton", frame)
toggleFOV.Size = UDim2.new(0, 280, 0, 40)
toggleFOV.Position = UDim2.new(0, 10, 0, 90)
toggleFOV.Text = "FOV: ON (F)"
toggleFOV.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleFOV.MouseButton1Click:Connect(function()
    FOV_ENABLED = not FOV_ENABLED
    fovCircle.Visible = FOV_ENABLED
    toggleFOV.Text = "FOV: " .. (FOV_ENABLED and "ON (F)" or "OFF (F)")
    toggleFOV.BackgroundColor3 = FOV_ENABLED and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
end)
local toggleAimbot = Instance.new("TextButton", frame)
toggleAimbot.Size = UDim2.new(0, 280, 0, 40)
toggleAimbot.Position = UDim2.new(0, 10, 0, 40)
toggleAimbot.Text = "Aimbot: OFF (X)"
toggleAimbot.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleAimbot.MouseButton1Click:Connect(function()
    AIMBOT_VISIBLE = not AIMBOT_VISIBLE
    toggleAimbot.Text = "Aimbot: " .. (AIMBOT_VISIBLE and "ON (X)" or "OFF (X)")
    toggleAimbot.BackgroundColor3 = AIMBOT_VISIBLE and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
end)

local fovLabel = Instance.new("TextLabel", frame)
fovLabel.Size = UDim2.new(0, 280, 0, 20)
fovLabel.Position = UDim2.new(0, 10, 0, 140)
fovLabel.Text = "FOV Radius:"
fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovLabel.BackgroundTransparency = 1
fovLabel.Font = Enum.Font.SourceSans

local fovInput = Instance.new("TextBox", frame)
fovInput.Size = UDim2.new(0, 135, 0, 30)
fovInput.Position = UDim2.new(0, 145, 0, 160)
fovInput.PlaceholderText = tostring(FOV_RADIUS)
fovInput.Text = ""
fovInput.Font = Enum.Font.SourceSans
fovInput.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
fovInput.TextColor3 = Color3.fromRGB(255, 255, 255)
fovInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newFOV = tonumber(fovInput.Text)
        if newFOV and newFOV > 0 then
            FOV_RADIUS = newFOV
            fovInput.PlaceholderText = tostring(FOV_RADIUS)
            updateFOV()
        else
            fovInput.Text = ""
            fovInput.PlaceholderText = tostring(FOV_RADIUS)
        end
        fovInput.Text = ""
    end
end)
fovInput.Changed:Connect(function()
    if not tonumber(fovInput.Text) and fovInput.Text ~= "" then
        fovInput.Text = ""
    end
end)

local aimSpeedLabel = Instance.new("TextLabel", frame)
aimSpeedLabel.Size = UDim2.new(0, 280, 0, 20)
aimSpeedLabel.Position = UDim2.new(0, 10, 0, 200)
aimSpeedLabel.Text = "Aimbot Speed:"
aimSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
aimSpeedLabel.BackgroundTransparency = 1
aimSpeedLabel.Font = Enum.Font.SourceSans

local aimSpeedInput = Instance.new("TextBox", frame)
aimSpeedInput.Size = UDim2.new(0, 135, 0, 30)
aimSpeedInput.Position = UDim2.new(0, 145, 0, 220)
aimSpeedInput.PlaceholderText = string.format("%.2f", AIM_SPEED)
aimSpeedInput.Text = ""
aimSpeedInput.Font = Enum.Font.SourceSans
aimSpeedInput.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
aimSpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
aimSpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newSpeed = tonumber(aimSpeedInput.Text)
        if newSpeed and newSpeed > 0 then
            AIM_SPEED = math.clamp(newSpeed, 0, 1)
            aimSpeedInput.PlaceholderText = string.format("%.2f", AIM_SPEED)
        else
            aimSpeedInput.Text = ""
            aimSpeedInput.PlaceholderText = string.format("%.2f", AIM_SPEED)
        end
        aimSpeedInput.Text = ""
    end
end)
aimSpeedInput.Changed:Connect(function()
    if not tonumber(aimSpeedInput.Text) and aimSpeedInput.Text ~= "" then
        aimSpeedInput.Text = ""
    end
end)

-- ESP System
local function createESP(player)
    if player == Players.LocalPlayer then return end
    if not player.Character then return end
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 5, 0)
    billboard.Adornee = rootPart
    billboard.AlwaysOnTop = true
    billboard.Parent = rootPart

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0

    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 0, 0)

    return billboard
end

local function setupESPForPlayer(player)
    if player == Players.LocalPlayer then return end

    local function onCharacterAdded(character)
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        if ESP_ENABLED and not espObjects[player] and hrp then
            task.wait(0.3)
            espObjects[player] = createESP(player)
        end
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)
end

local function toggleESP()
    ESP_ENABLED = not ESP_ENABLED

    for _, player in ipairs(Players:GetPlayers()) do
        if ESP_ENABLED then
            setupESPForPlayer(player)
        else
            if espObjects[player] then
                espObjects[player]:Destroy()
                espObjects[player] = nil
            end
        end
    end
end

-- ปุ่มคีย์ลัด
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        -- เปิด/ปิด Aimbot ด้วยปุ่ม X (ควบคุม AIMBOT_VISIBLE โดยตรง)
        AIMBOT_VISIBLE = not AIMBOT_VISIBLE
        toggleAimbot.Text = "Aimbot: " .. (AIMBOT_VISIBLE and "ON (X)" or "OFF (X)")
        toggleAimbot.BackgroundColor3 = AIMBOT_VISIBLE and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    end

    if input.KeyCode == Enum.KeyCode.B then
        -- เปิด/ปิด ESP ด้วยปุ่ม B
        toggleESP()
    end
    if input.KeyCode == Enum.KeyCode.F then
        -- เปิด/ปิด FOV ด้วยปุ่ม F
        FOV_ENABLED = not FOV_ENABLED
        fovCircle.Visible = FOV_ENABLED
        toggleFOV.Text = "FOV: " .. (FOV_ENABLED and "ON (F)" or "OFF (F)")
        toggleFOV.BackgroundColor3 = FOV_ENABLED and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    end
    if input.KeyCode == Enum.KeyCode.K then
        -- เปิด/ปิด GUI ด้วยปุ่ม K
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- ตั้งค่า ESP สำหรับผู้เล่นที่มีอยู่แล้วในเกม
for _, player in ipairs(Players:GetPlayers()) do
    setupESPForPlayer(player)
end

-- **เพิ่มส่วนนี้เข้าไปเพื่อจัดการผู้เล่นใหม่**
game.Players.PlayerAdded:Connect(function(player)
    setupESPForPlayer(player)
end)
initial script
