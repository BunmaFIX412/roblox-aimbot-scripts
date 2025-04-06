local Local FOV_RADIUS = 120 -- ขนาดเริ่มต้นของวง FOV
local AIM_SPEED = 0.2  -- ความเร็วเริ่มต้นของการล็อค
local RANDOMNESS = 0.5
local MAX_DISTANCE = 200
local AIMBOT_ENABLED = false
local FOV_ENABLED = true

local camera = workspace.CurrentCamera
local localPlayer = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")

-- 🔴 สร้างวง FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 0, 0) -- สีแดง
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Radius = FOV_RADIUS
fovCircle.Visible = FOV_ENABLED

local function updateFOV()
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Visible = FOV_ENABLED
end

-- ฟังก์ชันเช็คการมีสิ่งกีดขวาง (Raycasting)
local function isObstructed(target)
    local targetPos = target.Position
    local direction = (targetPos - camera.CFrame.Position).unit
    local ray = Ray.new(camera.CFrame.Position, direction * MAX_DISTANCE)
    local hitPart, hitPosition = workspace:FindPartOnRay(ray, localPlayer.Character, false, true)

    return hitPart and hitPart.Parent ~= target.Parent
end

-- ฟังก์ชันค้นหาศัตรูที่ใกล้ที่สุดที่ยังไม่ถูกบัง
local function getClosestTarget()
    if not AIMBOT_ENABLED then return nil end

    local closestTarget = nil
    local shortestDistance = FOV_RADIUS

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not game.Players:GetPlayerFromCharacter(obj) then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local head = obj:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and head then
                local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude

                    -- เช็คว่าศัตรูอยู่ในระยะที่กำหนด และไม่มีสิ่งกีดขวางระหว่างกล้องและศัตรู
                    if distance < shortestDistance and not isObstructed(head) then
                        closestTarget = head
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    return closestTarget
end

local function aimAt(target)
    if AIMBOT_ENABLED and target then
        local targetPos = target.Position
        local currentLook = camera.CFrame.LookVector
        local direction = (targetPos - camera.CFrame.Position).unit

        camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + currentLook:Lerp(direction, AIM_SPEED))
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    local target = getClosestTarget()
    aimAt(target)
    updateFOV()
end)

-- ✅ สร้าง GUI สำหรับการปรับความเร็วในการล็อค (Aimbot Speed) และขนาดวง FOV
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotGUI" -- ตั้งชื่อให้ ScreenGui เพื่อใช้อ้างอิง
    screenGui.Parent = localPlayer.PlayerGui
    screenGui.Enabled = false -- ปิด GUI ตอนเริ่มต้น

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 300)
    frame.Position = UDim2.new(0.5, -150, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui

    -- ป้ายแสดงผลของ Aimbot Speed
    local labelSpeed = Instance.new("TextLabel")
    labelSpeed.Text = "Aimbot Speed: " .. AIM_SPEED
    labelSpeed.Size = UDim2.new(0, 280, 0, 50)
    labelSpeed.Position = UDim2.new(0, 10, 0, 10)
    labelSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelSpeed.TextSize = 18
    labelSpeed.BackgroundTransparency = 1
    labelSpeed.Parent = frame

    -- กล่องสำหรับใส่ความเร็วของ Aimbot
    local textBoxSpeed = Instance.new("TextBox")
    textBoxSpeed.Size = UDim2.new(0, 280, 0, 50)
    textBoxSpeed.Position = UDim2.new(0, 10, 0, 70)
    textBoxSpeed.PlaceholderText = "Enter Aimbot Speed (Min: 0.1, Max: 1.0)"
    textBoxSpeed.Text = tostring(AIM_SPEED)
    textBoxSpeed.TextSize = 18
    textBoxSpeed.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textBoxSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBoxSpeed.Parent = frame

    -- ปุ่มเปลี่ยนความเร็ว Aimbot
    local buttonSpeed = Instance.new("TextButton")
    buttonSpeed.Size = UDim2.new(0, 280, 0, 50)
    buttonSpeed.Position = UDim2.new(0, 10, 0, 130)
    buttonSpeed.Text = "Set Speed"
    buttonSpeed.TextSize = 18
    buttonSpeed.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    buttonSpeed.TextColor3 = Color3.fromRGB(0, 0, 0)
    buttonSpeed.Parent = frame

    -- ป้ายแสดงผลของ FOV Size
    local labelFOV = Instance.new("TextLabel")
    labelFOV.Text = "FOV Size: " .. FOV_RADIUS
    labelFOV.Size = UDim2.new(0, 280, 0, 50)
    labelFOV.Position = UDim2.new(0, 10, 0, 190)
    labelFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelFOV.TextSize = 18
    labelFOV.BackgroundTransparency = 1
    labelFOV.Parent = frame

    -- กล่องสำหรับใส่ขนาดวง FOV
    local textBoxFOV = Instance.new("TextBox")
    textBoxFOV.Size = UDim2.new(0, 280, 0, 50)
    textBoxFOV.Position = UDim2.new(0, 10, 0, 250)
    textBoxFOV.PlaceholderText = "Enter FOV Size (Min: 50, Max: 300)"
    textBoxFOV.Text = tostring(FOV_RADIUS)
    textBoxFOV.TextSize = 18
    textBoxFOV.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textBoxFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBoxFOV.Parent = frame

    -- ปุ่มเปลี่ยนขนาด FOV
    local buttonFOV = Instance.new("TextButton")
    buttonFOV.Size = UDim2.new(0, 280, 0, 50)
    buttonFOV.Position = UDim2.new(0, 10, 0, 310)
    buttonFOV.Text = "Set FOV"
    buttonFOV.TextSize = 18
    buttonFOV.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    buttonFOV.TextColor3 = Color3.fromRGB(0, 0, 0)
    buttonFOV.Parent = frame

    -- ฟังก์ชันเมื่อกดปุ่ม Set Speed
    buttonSpeed.MouseButton1Click:Connect(function()
        local newSpeed = tonumber(textBoxSpeed.Text)
        if newSpeed and newSpeed >= 0.1 and newSpeed <= 1.0 then
            AIM_SPEED = newSpeed
            labelSpeed.Text = "Aimbot Speed: " .. AIM_SPEED
        else
            textBoxSpeed.Text = "Invalid input!"
        end
    end)

    -- ฟังก์ชันเมื่อกดปุ่ม Set FOV
    buttonFOV.MouseButton1Click:Connect(function()
        local newFOV = tonumber(textBoxFOV.Text)
        if newFOV and newFOV >= 50 and newFOV <= 300 then
            FOV_RADIUS = newFOV
            fovCircle.Radius = FOV_RADIUS
            labelFOV.Text = "FOV Size: " .. FOV_RADIUS
        else
            textBoxFOV.Text = "Invalid input!"
        end
    end)
end

-- ✅ สร้าง GUI และจัดการการเปิด/ปิดด้วยปุ่ม K
local aimbotGui = nil -- ตัวแปรเก็บ GUI ที่สร้าง

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F then
            FOV_ENABLED = not FOV_ENABLED
        elseif input.KeyCode == Enum.KeyCode.X then
            AIMBOT_ENABLED = not AIMBOT_ENABLED
        elseif input.KeyCode == Enum.KeyCode.K then
            if not aimbotGui then
                createGui()
                aimbotGui = localPlayer.PlayerGui:FindFirstChild("AimbotGUI")
            elseif aimbotGui then
                aimbotGui.Enabled = not aimbotGui.Enabled
            end
        end
    end
end)

-- ฟังก์ชันตรวจสอบเมื่อผู้เล่นตาย
local function onCharacterAdded(character)
    -- ลบ GUI เก่า (ถ้ามี)
    if aimbotGui then
        aimbotGui:Destroy()
        aimbotGui = nil
    end
    -- สร้าง GUI ใหม่เมื่อตัวละครเกิด
    -- createGui() -- ย้ายการสร้าง GUI ไปที่การกดปุ่ม K แทน
end

-- ตรวจสอบเมื่อผู้เล่นเกิดใหม่
localPlayer.CharacterAdded:Connect(onCharacterAdded)

-- หากตัวละครผู้เล่นมีอยู่แล้ว จะยังไม่สร้าง GUI ทันที
-- if localPlayer.Character then
--     onCharacterAdded(localPlayer.Character)
-- end
