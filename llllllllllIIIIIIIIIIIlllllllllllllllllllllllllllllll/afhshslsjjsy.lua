local STARTERGUI = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui, FlyButton, SpinButton, SpeedBox, SpinBox
local FLYING, SPINNING, SPEED, SPIN_SPEED
local CONTROL, lCONTROL
local controlModule, Notify
local currentAO, currentLV, currentMoverAttachment
local NSound

local function checkScriptRunning()
    if game:GetService("ReplicatedStorage"):FindFirstChild("BZn2q91BzN") then
        STARTERGUI:SetCore("SendNotification", {
            Title = "Hasl Fly Script",
            Text = "脚本已在运行中",
            Icon = "rbxassetid://14494607687",
            Duration = 4
        })
        return true
    end
    return false
end

local function initNotification()
    local VdbwjS = Instance.new("StringValue", game:GetService("ReplicatedStorage"))
    VdbwjS.Name = "BZn2q91BzN"

    NSound = Instance.new("Sound")
    NSound.SoundId = "rbxassetid://9086208751"
    NSound.Volume = 1
    NSound.Parent = game:GetService("SoundService")

    Notify = function(Txt, Dur)
        STARTERGUI:SetCore("SendNotification", {
            Title = "Hasl Fly Script",
            Text = Txt,
            Icon = "rbxassetid://14494607687",
            Duration = Dur
        })
        NSound:Play()
    end

    Notify("Hasl Fly Script 已加载", 5)
end

local function initUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false

    FlyButton = Instance.new("TextButton")
    FlyButton.Name = "FlyButton"
    FlyButton.Parent = ScreenGui
    FlyButton.BackgroundColor3 = Color3.new(0.168627, 0.513726, 0.25098)
    FlyButton.BorderColor3 = Color3.new(0,0,0)
    FlyButton.Position = UDim2.new(0.912970064, 0, 0.194202876, 0)
    FlyButton.Size = UDim2.new(0, 50, 0, 50)
    FlyButton.Font = Enum.Font.Code
    FlyButton.Text = "飞行"
    FlyButton.TextColor3 = Color3.new(0,0,0)
    FlyButton.TextSize = 14
    FlyButton.TextStrokeColor3 = Color3.new(1, 1, 1)
    FlyButton.TextWrapped = true
    FlyButton.Transparency = 0.2

    SpinButton = Instance.new("TextButton")
    SpinButton.Name = "SpinButton"
    SpinButton.Parent = ScreenGui
    SpinButton.BackgroundColor3 = Color3.new(0.168627, 0.513726, 0.25098)
    SpinButton.BorderColor3 = Color3.new(0,0,0)
    SpinButton.Position = UDim2.new(0.912970064, 0, 0.394202876, 0)
    SpinButton.Size = UDim2.new(0, 50, 0, 50)
    SpinButton.Font = Enum.Font.Code
    SpinButton.Text = "旋转"
    SpinButton.TextColor3 = Color3.new(0,0,0)
    SpinButton.TextSize = 14
    SpinButton.TextStrokeColor3 = Color3.new(1, 1, 1)
    SpinButton.TextWrapped = true
    SpinButton.Transparency = 0.2

    SpeedBox = Instance.new("TextBox")
    SpeedBox.Name = "SpeedBox"
    SpeedBox.Parent = FlyButton
    SpeedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SpeedBox.Position = UDim2.new(-1.716970064, 0, 0.004202876, 0)
    SpeedBox.Size = UDim2.new(0, 80, 0, 50)
    SpeedBox.Font = Enum.Font.Code
    SpeedBox.PlaceholderText = "速度"
    SpeedBox.Text = "50"
    SpeedBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    SpeedBox.TextScaled = true
    SpeedBox.TextSize = 14.000
    SpeedBox.TextWrapped = true

    SpinBox = Instance.new("TextBox")
    SpinBox.Name = "SpinBox"
    SpinBox.Parent = FlyButton
    SpinBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SpinBox.Position = UDim2.new(-1.716970064, 0, 1.394202876, 0)
    SpinBox.Size = UDim2.new(0, 80, 0, 50)
    SpinBox.Font = Enum.Font.Code
    SpinBox.PlaceholderText = "旋转速度"
    SpinBox.Text = "5"
    SpinBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    SpinBox.TextScaled = true
    SpinBox.TextSize = 14.000
    SpinBox.TextWrapped = true
end
local function initControlModule()
    controlModule = require(LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'):WaitForChild("ControlModule"))
end

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function setupBodyMovers(character)
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    local moverParent = workspace:FindFirstChildOfClass("Terrain") or workspace
    local moverAttachment = Instance.new("Attachment", hrp)
    moverAttachment.Name = "FlyAttachment"
    
    local AO = Instance.new('AlignOrientation')
    AO.Mode = Enum.OrientationAlignmentMode.OneAttachment
    AO.RigidityEnabled = true
    AO.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    AO.CFrame = hrp.CFrame
    AO.Attachment0 = moverAttachment
    AO.Parent = moverParent

    local LV = Instance.new('LinearVelocity')
    LV.VectorVelocity = Vector3.new(0, 0, 0)
    LV.MaxForce = 9e9
    LV.Attachment0 = moverAttachment
    LV.Parent = moverParent
    
    return AO, LV, humanoid, moverAttachment
end

local function updateFlyVector()
    local moveVector = controlModule:GetMoveVector()
    local camera = workspace.CurrentCamera
    
    CONTROL.F = -moveVector.Z
    CONTROL.B = moveVector.Z
    CONTROL.L = -moveVector.X
    CONTROL.R = moveVector.X
    CONTROL.Q = moveVector.Y
    CONTROL.E = -moveVector.Y

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then CONTROL.F = 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then CONTROL.B = 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then CONTROL.L = 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then CONTROL.R = 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then CONTROL.Q = 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then CONTROL.E = 1 end

    local flyVector = (camera.CFrame.LookVector * (CONTROL.F - CONTROL.B) + 
                       camera.CFrame.RightVector * (CONTROL.R - CONTROL.L) + 
                       Vector3.new(0, 1, 0) * (CONTROL.Q - CONTROL.E))
    
    return flyVector.Magnitude > 0 and flyVector.Unit or flyVector
end

local function fly()
    FLYING = true
    SPINNING = false
    local character = getCharacter()
    local targetPart = character.Humanoid.SeatPart or character.HumanoidRootPart
    
    if currentAO then currentAO:Destroy() end
    if currentLV then currentLV:Destroy() end
    if currentMoverAttachment then currentMoverAttachment:Destroy() end
    
    local AO, LV, humanoid, moverAttachment = setupBodyMovers(character)
    currentAO, currentLV, currentMoverAttachment = AO, LV, moverAttachment
    
    SpinButton.Text = "旋转: 关"
    SpinButton.BackgroundColor3 = Color3.new(1, 0, 0)

    local flyLoop
    flyLoop = RunService.Heartbeat:Connect(function()
        if not FLYING then flyLoop:Disconnect() return end
        
        local flyVector = updateFlyVector()
        
        if flyVector.Magnitude > 0 then
            LV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            LV.VectorVelocity = flyVector * SPEED
        else
            LV.VectorVelocity = Vector3.new(0, 0, 0)
        end
        
        if SPINNING then
            local spinCFrame = targetPart.CFrame * CFrame.Angles(0, math.rad(SPIN_SPEED), 0)
            AO.CFrame = spinCFrame
        else
            AO.CFrame = workspace.CurrentCamera.CFrame
        end
        
        if targetPart == character.HumanoidRootPart then
            humanoid.PlatformStand = true
        end
    end)
    
    local characterRemoving
    characterRemoving = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            stopFlying()
            characterRemoving:Disconnect()
        end
    end)
end

local function stopFlying()
    FLYING = false
    SPINNING = false
    CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    
    local character = getCharacter()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    if currentAO then currentAO:Destroy() end
    if currentLV then currentLV:Destroy() end
    if currentMoverAttachment then currentMoverAttachment:Destroy() end
    
    currentAO, currentLV, currentMoverAttachment = nil, nil, nil
    
    SpinButton.Text = "旋转: 关"
    SpinButton.BackgroundColor3 = Color3.new(1, 0, 0)
end

local function main()
    if checkScriptRunning() then return end
    initNotification()
    initUI()
    initControlModule()

    FLYING = false
    SPINNING = false
    SPEED = 50
    SPIN_SPEED = 5
    CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}

    FlyButton.MouseButton1Click:Connect(function()
        if FLYING then
            stopFlying()
            FlyButton.Text = "飞行: 关"
            FlyButton.BackgroundColor3 = Color3.new(1, 0, 0)
            Notify("飞行已关闭", 2)
        else
            SPEED = SPEED <= 0 and (tonumber(SpeedBox.Text) or 50) or SPEED
            fly()
            FlyButton.Text = "飞行: 开"
            FlyButton.BackgroundColor3 = Color3.new(0, 1, 0)
            Notify("飞行已开启", 2)
        end
    end)

    SpinButton.MouseButton1Click:Connect(function()
        if not FLYING then
            Notify("请先开启飞行", 2)
            return
        end
        
        SPINNING = not SPINNING
        if SPINNING then
            SpinButton.Text = "旋转: 开"
            SpinButton.BackgroundColor3 = Color3.new(0, 1, 0)
            Notify("旋转已开启", 2)
        else
            SpinButton.Text = "旋转: 关"
            SpinButton.BackgroundColor3 = Color3.new(1, 0, 0)
            Notify("旋转已关闭", 2)
        end
    end)

    SpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
        local newSpeed = tonumber(SpeedBox.Text)
        if newSpeed and newSpeed > 0 then
            SPEED = newSpeed
            Notify("设置速度: " .. newSpeed, 2)
        end
    end)

    SpinBox:GetPropertyChangedSignal("Text"):Connect(function()
        local newSpin = tonumber(SpinBox.Text)
        if newSpin and newSpin > 0 then
            SPIN_SPEED = newSpin
            Notify("设置旋转速度: " .. newSpin, 2)
        end
    end)

    LocalPlayer.Chatted:Connect(function(msg)
        if msg:sub(1,5) == "!stop" then
            stopFlying()
            game:GetService("ReplicatedStorage"):FindFirstChild("BZn2q91BzN"):Destroy()
            ScreenGui:Destroy()
            Notify("脚本关闭", 2)
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        if FLYING then
            stopFlying()
            fly()
        end
    end)
end

main()
