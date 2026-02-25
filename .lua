-- Join my Discord :3 https://discord.gg/5GeQAXYYcW   
-- Created by @LunarRbxZ
-- Fixed and Enhanced Admin Script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local client = Players.LocalPlayer
local Mouse = client:GetMouse()
local prefix = "!"

local waypoints = {}
local tracerLines = {}

-- Wait for character to load
local char = client.Character or client.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart", 10)
local hum = char:WaitForChild("Humanoid", 10)

if not hrp or not hum then
    StarterGui:SetCore("SendNotification", {Title = "Lunar Error", Text = "Character not loaded. Re-execute after spawn.", Duration = 10})
    return
end

client.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart", 10)
    hum = char:WaitForChild("Humanoid", 10)
    
    if flyData[client] and flyData[client].enabled then
        task.wait(0.5)
        startFly(client, flyData[client].speed)
    end
end)

-- =============================================================
-- GLOBAL CONFIGURATION
-- =============================================================
local globalConfig = {
    textColor = Color3.new(1, 1, 1),
    uiTransparency = 0.1,
    strokeTransparency = 0.5
}

-- Store main UI references for transparency control
local lunarGui = nil
local mainFrame = nil

-- =============================================================
-- GLASS EFFECT UTILITY
-- =============================================================
local function applyGlassEffect(frame, transparency, strokeTransparency)
    transparency = transparency or globalConfig.uiTransparency
    strokeTransparency = strokeTransparency or globalConfig.strokeTransparency
    frame.BackgroundTransparency = transparency
    
    local stroke = frame:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = strokeTransparency
    stroke.Parent = frame
    
    local corner = frame:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local gradient = frame:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 240))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    gradient.Rotation = 45
    gradient.Parent = frame
end

-- =============================================================
-- THEMES
-- =============================================================
local themes = {
    Default = {
        main = Color3.fromRGB(25, 25, 35),
        grad1 = Color3.fromRGB(40, 40, 55),
        grad2 = Color3.fromRGB(25, 25, 35),
        accent = Color3.fromRGB(0, 180, 255),
        text = Color3.new(1,1,1),
        btn = Color3.fromRGB(55, 55, 75),
        list = Color3.fromRGB(45, 45, 60),
        glass = Color3.fromRGB(35, 35, 50)
    },
    Pink = {
        main = Color3.fromRGB(255, 192, 203),
        grad1 = Color3.fromRGB(255, 182, 193),
        grad2 = Color3.fromRGB(255, 105, 180),
        accent = Color3.fromRGB(255, 20, 147),
        text = Color3.new(0.1,0.1,0.1),
        btn = Color3.fromRGB(255, 105, 180),
        list = Color3.fromRGB(255, 160, 180),
        glass = Color3.fromRGB(255, 200, 210)
    },
    Blue = {
        main = Color3.fromRGB(30, 40, 70),
        grad1 = Color3.fromRGB(50, 80, 140),
        grad2 = Color3.fromRGB(25, 45, 90),
        accent = Color3.fromRGB(100, 230, 255),
        text = Color3.new(1,1,1),
        btn = Color3.fromRGB(60, 100, 170),
        list = Color3.fromRGB(45, 65, 110),
        glass = Color3.fromRGB(40, 55, 100)
    },
    Red = {
        main = Color3.fromRGB(50, 20, 20),
        grad1 = Color3.fromRGB(90, 25, 25),
        grad2 = Color3.fromRGB(60, 15, 15),
        accent = Color3.fromRGB(255, 100, 100),
        text = Color3.new(1,1,1),
        btn = Color3.fromRGB(190, 50, 50),
        list = Color3.fromRGB(80, 25, 25),
        glass = Color3.fromRGB(70, 25, 25)
    },
    Dark = {
        main = Color3.fromRGB(15, 15, 20),
        grad1 = Color3.fromRGB(30, 30, 40),
        grad2 = Color3.fromRGB(15, 15, 20),
        accent = Color3.fromRGB(0, 200, 255),
        text = Color3.new(1,1,1),
        btn = Color3.fromRGB(40, 40, 55),
        list = Color3.fromRGB(35, 35, 45),
        glass = Color3.fromRGB(25, 25, 35)
    }
}
local currentTheme = themes.Default

-- =============================================================
-- SOUND EFFECTS
-- =============================================================
local function playOpen()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://124233495227925"
    s.Volume = 0.45
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 3)
end

local function playClose()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://9119707219"
    s.Volume = 0.4
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 3)
end

-- =============================================================
-- NOTIFICATIONS - STACKING SYSTEM
-- =============================================================
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "LunarNotifs"
notifGui.ResetOnSpawn = false
notifGui.DisplayOrder = 999999
notifGui.Parent = client.PlayerGui

local activeNotifications = {}
local notifHeight = 80
local notifSpacing = 10

local function notify(text, col)
    col = col or Color3.fromRGB(100, 200, 255)
    
    -- Create notification frame
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 320, 0, 70)
    f.Position = UDim2.new(1, 50, 1, -100) -- Start off-screen
    f.BackgroundColor3 = currentTheme.glass
    f.BorderSizePixel = 0
    f.Parent = notifGui
    
    -- Apply glass effect
    applyGlassEffect(f, globalConfig.uiTransparency, 0.4)
    
    -- SOLID TEXT - NO TRANSPARENCY
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -20, 1, -20)
    lbl.Position = UDim2.new(0, 10, 0, 10)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.TextColor3 = globalConfig.textColor
    lbl.TextTransparency = 0 -- SOLID
    lbl.TextStrokeTransparency = 0.5 -- Outline for readability
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.TextWrapped = true
    
    -- Add to active notifications
    table.insert(activeNotifications, 1, f) -- Add to front
    
    -- Reposition all notifications
    for i, notif in ipairs(activeNotifications) do
        local targetY = -90 - ((i-1) * (notifHeight + notifSpacing))
        TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -340, 1, targetY)
        }):Play()
    end
    
    -- Remove old notifications if too many
    if #activeNotifications > 5 then
        local old = table.remove(activeNotifications)
        TweenService:Create(old, TweenInfo.new(0.3), {Position = UDim2.new(1, 50, 1, old.Position.Y.Offset)}):Play()
        task.delay(0.4, function() old:Destroy() end)
    end
    
    -- Auto remove after delay
    task.delay(5, function()
        -- Find and remove from table
        for i, notif in ipairs(activeNotifications) do
            if notif == f then
                table.remove(activeNotifications, i)
                break
            end
        end
        
        -- Slide out
        TweenService:Create(f, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, 50, 1, f.Position.Y.Offset)
        }):Play()
        
        -- Reposition remaining
        task.delay(0.1, function()
            for i, notif in ipairs(activeNotifications) do
                local targetY = -90 - ((i-1) * (notifHeight + notifSpacing))
                TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                    Position = UDim2.new(1, -340, 1, targetY)
                }):Play()
            end
        end)
        
        task.delay(0.6, function() f:Destroy() end)
    end)
end

-- =============================================================
-- FIXED FLY SYSTEM
-- =============================================================
local flyData = {}

local function startFly(plr, spd)
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    spd = tonumber(spd) or 50
    
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp
    
    flyData[plr] = {
        enabled = true,
        speed = spd,
        bodyGyro = bg,
        bodyVelocity = bv,
        connection = nil
    }
    
    flyData[plr].connection = RunService.RenderStepped:Connect(function()
        if not flyData[plr] or not flyData[plr].enabled then return end
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local currentHrp = plr.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        
        flyData[plr].bodyGyro.CFrame = cam.CFrame
        
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        if moveDir.Magnitude > 0 then
            flyData[plr].bodyVelocity.Velocity = moveDir.Unit * flyData[plr].speed
        else
            flyData[plr].bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    notify("✅ Flying at speed " .. spd .. " - Use WASD, Space, Shift", currentTheme.accent)
end

local function fly(plr, spd)
    if plr ~= client then
        notify("❌ Fly only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if flyData[plr] and flyData[plr].enabled then
        notify("⚠️ Already flying! Use !unfly to stop", Color3.fromRGB(255, 200, 100))
        return
    end
    
    startFly(plr, spd)
end

local function unfly(plr)
    if plr ~= client then
        notify("❌ Unfly only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if not flyData[plr] or not flyData[plr].enabled then
        notify("⚠️ Not currently flying", Color3.fromRGB(255, 100, 100))
        return
    end
    
    flyData[plr].enabled = false
    
    if flyData[plr].connection then
        flyData[plr].connection:Disconnect()
    end
    if flyData[plr].bodyGyro then
        flyData[plr].bodyGyro:Destroy()
    end
    if flyData[plr].bodyVelocity then
        flyData[plr].bodyVelocity:Destroy()
    end
    
    flyData[plr] = nil
    notify("✅ Fly stopped", Color3.fromRGB(255, 160, 60))
end

-- =============================================================
-- SPEED PANEL SYSTEM
-- =============================================================
local speedPanelData = {
    panel = nil,
    enabled = false,
    bypassEnabled = false,
    speedValue = 100,
    connection = nil
}

local function createSpeedPanel()
    if speedPanelData.panel then
        speedPanelData.panel:Destroy()
        speedPanelData.panel = nil
        if speedPanelData.connection then
            speedPanelData.connection:Disconnect()
            speedPanelData.connection = nil
        end
        return
    end
    
    local panel = Instance.new("ScreenGui")
    panel.Name = "SpeedPanel"
    panel.ResetOnSpawn = false
    panel.DisplayOrder = 999999
    panel.Parent = client.PlayerGui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 350, 0, 280)
    main.Position = UDim2.new(0.5, -175, 0.5, -140)
    main.BackgroundColor3 = currentTheme.glass
    main.Active = true
    main.Draggable = true
    main.Parent = panel
    applyGlassEffect(main, globalConfig.uiTransparency, 0.4)
    
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "SPEED CONTROL"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 26
    title.TextColor3 = currentTheme.accent
    title.TextTransparency = 0 -- SOLID
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.new(0,0,0)
    
    local speedDisplay = Instance.new("TextLabel", main)
    speedDisplay.Size = UDim2.new(1, 0, 0, 40)
    speedDisplay.Position = UDim2.new(0, 0, 0, 50)
    speedDisplay.BackgroundTransparency = 1
    speedDisplay.Text = "Speed: " .. speedPanelData.speedValue
    speedDisplay.Font = Enum.Font.GothamBold
    speedDisplay.TextSize = 24
    speedDisplay.TextColor3 = globalConfig.textColor
    speedDisplay.TextTransparency = 0 -- SOLID
    speedDisplay.TextStrokeTransparency = 0.5
    speedDisplay.TextStrokeColor3 = Color3.new(0,0,0)
    
    local sliderFrame = Instance.new("Frame", main)
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 12)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 95)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    applyGlassEffect(sliderFrame, 0.3, 0.7)
    
    local sliderFill = Instance.new("Frame", sliderFrame)
    sliderFill.Size = UDim2.new(speedPanelData.speedValue / 10000, 0, 1, 0)
    sliderFill.BackgroundColor3 = currentTheme.accent
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 6)
    
    local sliderKnob = Instance.new("TextButton", sliderFrame)
    sliderKnob.Size = UDim2.new(0, 24, 0, 24)
    sliderKnob.Position = UDim2.new(speedPanelData.speedValue / 10000, -12, 0.5, -12)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.Text = ""
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
    
    local toggle1Btn = Instance.new("TextButton", main)
    toggle1Btn.Size = UDim2.new(0.9, 0, 0, 45)
    toggle1Btn.Position = UDim2.new(0.05, 0, 0, 120)
    toggle1Btn.BackgroundColor3 = speedPanelData.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    toggle1Btn.Text = "Walkspeed: " .. (speedPanelData.enabled and "ON" or "OFF")
    toggle1Btn.Font = Enum.Font.GothamBold
    toggle1Btn.TextSize = 18
    toggle1Btn.TextColor3 = Color3.new(0,0,0)
    toggle1Btn.TextTransparency = 0 -- SOLID
    applyGlassEffect(toggle1Btn, 0.2, 0.5)
    
    local toggle2Btn = Instance.new("TextButton", main)
    toggle2Btn.Size = UDim2.new(0.9, 0, 0, 45)
    toggle2Btn.Position = UDim2.new(0.05, 0, 0, 175)
    toggle2Btn.BackgroundColor3 = speedPanelData.bypassEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    toggle2Btn.Text = "Bypass Scripts: " .. (speedPanelData.bypassEnabled and "ON" or "OFF")
    toggle2Btn.Font = Enum.Font.GothamBold
    toggle2Btn.TextSize = 18
    toggle2Btn.TextColor3 = Color3.new(0,0,0)
    toggle2Btn.TextTransparency = 0 -- SOLID
    applyGlassEffect(toggle2Btn, 0.2, 0.5)
    
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(closeBtn, 0.2, 0.4)
    
    local dragging = false
    
    local function updateSpeed(val)
        speedPanelData.speedValue = math.clamp(math.floor(val), 1, 10000)
        speedDisplay.Text = "Speed: " .. speedPanelData.speedValue
        sliderFill.Size = UDim2.new(speedPanelData.speedValue / 10000, 0, 1, 0)
        sliderKnob.Position = UDim2.new(speedPanelData.speedValue / 10000, -12, 0.5, -12)
        
        if speedPanelData.enabled and hum then
            hum.WalkSpeed = speedPanelData.speedValue
        end
    end
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            updateSpeed(pos * 10000)
        end
    end)
    
    toggle1Btn.MouseButton1Click:Connect(function()
        speedPanelData.enabled = not speedPanelData.enabled
        toggle1Btn.Text = "Walkspeed: " .. (speedPanelData.enabled and "ON" or "OFF")
        toggle1Btn.BackgroundColor3 = speedPanelData.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if speedPanelData.enabled and hum then
            hum.WalkSpeed = speedPanelData.speedValue
        elseif hum then
            hum.WalkSpeed = 16
        end
    end)
    
    toggle2Btn.MouseButton1Click:Connect(function()
        speedPanelData.bypassEnabled = not speedPanelData.bypassEnabled
        toggle2Btn.Text = "Bypass Scripts: " .. (speedPanelData.bypassEnabled and "ON" or "OFF")
        toggle2Btn.BackgroundColor3 = speedPanelData.bypassEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if speedPanelData.bypassEnabled then
            speedPanelData.connection = RunService.Heartbeat:Connect(function()
                if hum and speedPanelData.enabled then
                    hum.WalkSpeed = speedPanelData.speedValue
                end
            end)
        else
            if speedPanelData.connection then
                speedPanelData.connection:Disconnect()
                speedPanelData.connection = nil
            end
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        panel:Destroy()
        speedPanelData.panel = nil
    end)
    
    speedPanelData.panel = panel
    notify("✅ Speed panel opened", currentTheme.accent)
end

-- =============================================================
-- VIEW SYSTEM
-- =============================================================
-- IMPROVED SPECTATE: Full free-look like you're playing as them (mouse look, zoom, etc.)
-- No locked angle, no floor glitch on exit

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Keep your existing notify(), themes, etc.
-- local notify = ...
-- local currentTheme, globalConfig, applyGlassEffect, client = ...

local viewData = {
    enabled = false,
    target = nil,
    originalCameraSubject = nil,
    originalCameraType = nil,
    originalWalkSpeed = 16,
    originalJumpPower = 50,
    originalPlatformStand = false,
    viewGui = nil,
}

local function freezeLocalCharacter(freeze)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if freeze then
        viewData.originalWalkSpeed     = hum.WalkSpeed
        viewData.originalJumpPower     = hum.JumpPower
        viewData.originalPlatformStand = hum.PlatformStand
        
        hum.WalkSpeed     = 0
        hum.JumpPower     = 0
        hum.PlatformStand = true  -- Prevents falling/sliding while frozen
    else
        hum.WalkSpeed     = viewData.originalWalkSpeed
        hum.JumpPower     = viewData.originalJumpPower
        hum.PlatformStand = viewData.originalPlatformStand
        
        -- Tiny delay + force clean state to fix floor glue / falling glitch
        task.delay(0.03, function()
            if hum and hum.Parent then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                -- Optional extra: hum:ChangeState(Enum.HumanoidStateType.GettingUp) if ragdolled
            end
        end)
    end
end

local function view(targetPlayer)
    if viewData.enabled then
        notify("⚠️ Already viewing someone! Use !unview first", Color3.fromRGB(255, 100, 100))
        return
    end
    
    if not targetPlayer or not targetPlayer.Character then
        notify("❌ Player not found or has no character", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then
        notify("❌ Target is dead or has no Humanoid", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Store originals
    viewData.enabled          = true
    viewData.target           = targetPlayer
    viewData.originalCameraSubject = Camera.CameraSubject
    viewData.originalCameraType    = Camera.CameraType
    
    -- Freeze your own character
    freezeLocalCharacter(true)
    
    -- TRANSFER CAMERA CONTROL → feels like you're them
    Camera.CameraSubject = targetHum
    Camera.CameraType    = Enum.CameraType.Custom   -- This allows full mouse look / zoom
    
    -- Optional: start in third person if you want consistent view
    -- targetHum.CameraOffset = Vector3.new(0, 2, 0)  -- tweak if needed
    
    -- Top label
    local viewGui = Instance.new("ScreenGui")
    viewGui.Name = "SpectateGui"
    viewGui.ResetOnSpawn = false
    viewGui.DisplayOrder = 999999
    viewGui.Parent = client.PlayerGui  -- or LocalPlayer.PlayerGui
    
    local label = Instance.new("TextLabel")
    label.Size           = UDim2.new(0, 360, 0, 40)
    label.Position       = UDim2.new(0.5, -180, 0, 10)
    label.BackgroundTransparency = globalConfig.uiTransparency or 0.45
    label.BackgroundColor3 = currentTheme.glass or Color3.fromRGB(20, 20, 40)
    label.Text           = "👁️  Spectating: " .. targetPlayer.Name .. "  (@" .. targetPlayer.DisplayName .. ")  — Use mouse to look around"
    label.Font           = Enum.Font.GothamBold
    label.TextSize       = 18
    label.TextColor3     = globalConfig.textColor or Color3.fromRGB(230, 230, 255)
    label.TextStrokeTransparency = 0.7
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.BorderSizePixel = 0
    label.Parent = viewGui
    
    if applyGlassEffect then
        applyGlassEffect(label, globalConfig.uiTransparency or 0.45, 0.35)
    end
    
    viewData.viewGui = viewGui
    
    notify("👁️ Now viewing " .. targetPlayer.Name .. " — full free look like you're them", Color3.fromRGB(100, 255, 100))
end

local function unview()
    if not viewData.enabled then
        notify("⚠️ Not viewing anyone", Color3.fromRGB(255, 100, 100))
        return
    end
    
    viewData.enabled = false
    
    -- Restore camera **before** unfreezing (prevents glitches)
    Camera.CameraSubject = viewData.originalCameraSubject or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
    Camera.CameraType    = viewData.originalCameraType or Enum.CameraType.Custom
    
    -- Unfreeze
    freezeLocalCharacter(false)
    
    -- Clean up GUI
    if viewData.viewGui then
        viewData.viewGui:Destroy()
        viewData.viewGui = nil
    end
    
    viewData.target = nil
    viewData.originalCameraSubject = nil
    viewData.originalCameraType = nil
    
    notify("✅ Stopped spectating — back to normal", Color3.fromRGB(255, 160, 60))
end

-- Auto-stop if target disappears/dies/leaves
Players.PlayerRemoving:Connect(function(plr)
    if viewData.target == plr and viewData.enabled then
        unview()
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if viewData.enabled then
        unview()
    end
end)

print("Spectate system ready: full free camera control like playing as them + glitch fix")

-- =============================================================
-- JOIN LOGS PANEL
-- =============================================================
local joinLogsData = {
    panel = nil,
    entries = {},
    connections = {}
}

local function createJoinLogsPanel()
    if joinLogsData.panel then
        joinLogsData.panel:Destroy()
        joinLogsData.panel = nil
        for _, conn in ipairs(joinLogsData.connections) do
            conn:Disconnect()
        end
        joinLogsData.connections = {}
        return
    end
    
    local panel = Instance.new("ScreenGui")
    panel.Name = "JoinLogsPanel"
    panel.ResetOnSpawn = false
    panel.DisplayOrder = 999999
    panel.Parent = client.PlayerGui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500, 0, 400)
    main.Position = UDim2.new(0.5, -250, 0.5, -200)
    main.BackgroundColor3 = currentTheme.glass
    main.Active = true
    main.Draggable = true
    main.Parent = panel
    applyGlassEffect(main, globalConfig.uiTransparency, 0.4)
    
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, -50, 0, 45)
    title.Position = UDim2.new(0, 15, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "JOIN/LEAVE LOGS"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextColor3 = currentTheme.accent
    title.TextTransparency = 0 -- SOLID
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.new(0,0,0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(closeBtn, 0.2, 0.4)
    
    local headers = Instance.new("Frame", main)
    headers.Size = UDim2.new(1, -20, 0, 30)
    headers.Position = UDim2.new(0, 10, 0, 55)
    headers.BackgroundColor3 = currentTheme.btn
    applyGlassEffect(headers, 0.3, 0.6)
    
    local timeHeader = Instance.new("TextLabel", headers)
    timeHeader.Size = UDim2.new(0.2, 0, 1, 0)
    timeHeader.BackgroundTransparency = 1
    timeHeader.Text = "Time"
    timeHeader.Font = Enum.Font.GothamBold
    timeHeader.TextSize = 14
    timeHeader.TextColor3 = globalConfig.textColor
    timeHeader.TextTransparency = 0 -- SOLID
    timeHeader.TextStrokeTransparency = 0.5
    timeHeader.TextStrokeColor3 = Color3.new(0,0,0)
    
    local userHeader = Instance.new("TextLabel", headers)
    userHeader.Size = UDim2.new(0.4, 0, 1, 0)
    userHeader.Position = UDim2.new(0.2, 0, 0, 0)
    userHeader.BackgroundTransparency = 1
    userHeader.Text = "Username"
    userHeader.Font = Enum.Font.GothamBold
    userHeader.TextSize = 14
    userHeader.TextColor3 = globalConfig.textColor
    userHeader.TextTransparency = 0 -- SOLID
    userHeader.TextStrokeTransparency = 0.5
    userHeader.TextStrokeColor3 = Color3.new(0,0,0)
    
    local distHeader = Instance.new("TextLabel", headers)
    distHeader.Size = UDim2.new(0.2, 0, 1, 0)
    distHeader.Position = UDim2.new(0.6, 0, 0, 0)
    distHeader.BackgroundTransparency = 1
    distHeader.Text = "Distance"
    distHeader.Font = Enum.Font.GothamBold
    distHeader.TextSize = 14
    distHeader.TextColor3 = globalConfig.textColor
    distHeader.TextTransparency = 0 -- SOLID
    distHeader.TextStrokeTransparency = 0.5
    distHeader.TextStrokeColor3 = Color3.new(0,0,0)
    
    local actionHeader = Instance.new("TextLabel", headers)
    actionHeader.Size = UDim2.new(0.2, 0, 1, 0)
    actionHeader.Position = UDim2.new(0.8, 0, 0, 0)
    actionHeader.BackgroundTransparency = 1
    actionHeader.Text = "Action"
    actionHeader.Font = Enum.Font.GothamBold
    actionHeader.TextSize = 14
    actionHeader.TextColor3 = globalConfig.textColor
    actionHeader.TextTransparency = 0 -- SOLID
    actionHeader.TextStrokeTransparency = 0.5
    actionHeader.TextStrokeColor3 = Color3.new(0,0,0)
    
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -100)
    scroll.Position = UDim2.new(0, 10, 0, 90)
    scroll.BackgroundTransparency = 0.4
    scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    scroll.ScrollBarThickness = 8
    scroll.ScrollBarImageColor3 = currentTheme.accent
    applyGlassEffect(scroll, 0.5, 0.7)
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function addLogEntry(plr, action)
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, -10, 0, 35)
        entry.BackgroundColor3 = action == "JOINED" and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        entry.BackgroundTransparency = 0.8
        entry.BorderSizePixel = 0
        
        local timeLabel = Instance.new("TextLabel", entry)
        timeLabel.Size = UDim2.new(0.2, 0, 1, 0)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Text = os.date("%H:%M:%S")
        timeLabel.Font = Enum.Font.Gotham
        timeLabel.TextSize = 12
        timeLabel.TextColor3 = globalConfig.textColor
        timeLabel.TextTransparency = 0 -- SOLID
        timeLabel.TextStrokeTransparency = 0.5
        timeLabel.TextStrokeColor3 = Color3.new(0,0,0)
        
        local userLabel = Instance.new("TextLabel", entry)
        userLabel.Size = UDim2.new(0.4, 0, 1, 0)
        userLabel.Position = UDim2.new(0.2, 0, 0, 0)
        userLabel.BackgroundTransparency = 1
        userLabel.Text = plr.Name
        userLabel.Font = Enum.Font.GothamBold
        userLabel.TextSize = 14
        userLabel.TextColor3 = globalConfig.textColor
        userLabel.TextTransparency = 0 -- SOLID
        userLabel.TextStrokeTransparency = 0.5
        userLabel.TextStrokeColor3 = Color3.new(0,0,0)
        
        local dist = "N/A"
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and hrp then
            dist = math.floor((plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) .. " studs"
        end
        
        local distLabel = Instance.new("TextLabel", entry)
        distLabel.Size = UDim2.new(0.2, 0, 1, 0)
        distLabel.Position = UDim2.new(0.6, 0, 0, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = dist
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 12
        distLabel.TextColor3 = globalConfig.textColor
        distLabel.TextTransparency = 0 -- SOLID
        distLabel.TextStrokeTransparency = 0.5
        distLabel.TextStrokeColor3 = Color3.new(0,0,0)
        
        local actionLabel = Instance.new("TextLabel", entry)
        actionLabel.Size = UDim2.new(0.2, 0, 1, 0)
        actionLabel.Position = UDim2.new(0.8, 0, 0, 0)
        actionLabel.BackgroundTransparency = 1
        actionLabel.Text = action
        actionLabel.Font = Enum.Font.GothamBold
        actionLabel.TextSize = 14
        actionLabel.TextColor3 = action == "JOINED" and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        actionLabel.TextTransparency = 0 -- SOLID
        actionLabel.TextStrokeTransparency = 0.5
        actionLabel.TextStrokeColor3 = Color3.new(0,0,0)
        
        entry.Parent = scroll
        table.insert(joinLogsData.entries, entry)
        
        if #joinLogsData.entries > 50 then
            joinLogsData.entries[1]:Destroy()
            table.remove(joinLogsData.entries, 1)
        end
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, #joinLogsData.entries * 40)
        scroll.CanvasPosition = Vector2.new(0, #joinLogsData.entries * 40)
    end
    
    local joinConn = Players.PlayerAdded:Connect(function(plr)
        addLogEntry(plr, "JOINED")
    end)
    
    local leaveConn = Players.PlayerRemoving:Connect(function(plr)
        addLogEntry(plr, "LEFT")
    end)
    
    table.insert(joinLogsData.connections, joinConn)
    table.insert(joinLogsData.connections, leaveConn)
    
    closeBtn.MouseButton1Click:Connect(function()
        panel:Destroy()
        joinLogsData.panel = nil
        for _, conn in ipairs(joinLogsData.connections) do
            conn:Disconnect()
        end
        joinLogsData.connections = {}
    end)
    
    joinLogsData.panel = panel
    notify("✅ Join logs panel opened", Color3.fromRGB(100, 255, 100))
end

-- =============================================================
-- ENHANCED ESP 
-- =============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local client = Players.LocalPlayer

---------------------------------------------------------------------
-- DATA
---------------------------------------------------------------------
local espData = {
    enabled = false,
    playerESP = {},
    connections = {},
    distanceConn = nil
}

---------------------------------------------------------------------
-- SAFE HRP GETTER (prevents breaking when you die)
---------------------------------------------------------------------
local function getMyHRP()
    local char = client.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

---------------------------------------------------------------------
-- CLEAR PLAYER ESP
---------------------------------------------------------------------
local function clearPlayerESP(plr)
    local data = espData.playerESP[plr]
    if not data then return end

    for _,conn in ipairs(data.connections) do
        conn:Disconnect()
    end

    for _,obj in ipairs(data.objects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end

    espData.playerESP[plr] = nil
end

---------------------------------------------------------------------
-- ATTACH ESP TO CHARACTER
---------------------------------------------------------------------
local function attachESP(plr, char)

    if not espData.enabled then return end
    if plr == client then return end

    local data = espData.playerESP[plr]
    if not data then return end

    -- clear old objects (important for respawn)
    for _,obj in ipairs(data.objects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    data.objects = {}
    data.distLabel = nil

    local head = char:WaitForChild("Head",10)
    local hrp = char:WaitForChild("HumanoidRootPart",10)
    if not head or not hrp then return end

    ----------------------------------------------------
    -- HIGHLIGHT
    ----------------------------------------------------
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    if plr.Team then
        highlight.FillColor = plr.Team.TeamColor.Color
    else
        highlight.FillColor = Color3.new(1,0,0)
    end

    highlight.Parent = workspace
    table.insert(data.objects, highlight)

    ----------------------------------------------------
    -- BILLBOARD
    ----------------------------------------------------
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,200,0,60)
    billboard.StudsOffset = Vector3.new(0,2.5,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = client.PlayerGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = highlight.FillColor
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.BackgroundTransparency = 1
    distLabel.Position = UDim2.new(0,0,0.55,0)
    distLabel.Size = UDim2.new(1,0,0.45,0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 13
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distLabel.TextColor3 = Color3.new(1,1,1)
    distLabel.Text = "0 studs"
    distLabel.Parent = billboard

    table.insert(data.objects, billboard)
    data.distLabel = distLabel
end

---------------------------------------------------------------------
-- CREATE PLAYER ESP
---------------------------------------------------------------------
local function createPlayerESP(plr)
    if plr == client then return end
    if espData.playerESP[plr] then return end

    local data = {
        connections = {},
        objects = {},
        distLabel = nil
    }

    espData.playerESP[plr] = data

    if plr.Character then
        attachESP(plr, plr.Character)
    end

    -- Reattach every respawn
    local respawnConn = plr.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        attachESP(plr, char)
    end)

    table.insert(data.connections, respawnConn)
end

---------------------------------------------------------------------
-- ENABLE ALL
---------------------------------------------------------------------
function enableESPAll()

    if espData.enabled then return end
    espData.enabled = true

    -- Distance updater (never errors)
    espData.distanceConn = RunService.RenderStepped:Connect(function()

        local myHRP = getMyHRP()
        if not myHRP then return end

        for plr,data in pairs(espData.playerESP) do
            if data.distLabel and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = plr.Character.HumanoidRootPart
                local dist = (targetHRP.Position - myHRP.Position).Magnitude
                data.distLabel.Text = math.floor(dist).." studs"
            end
        end

    end)

    -- Apply to current players
    for _,plr in ipairs(Players:GetPlayers()) do
        createPlayerESP(plr)
    end

    -- Auto apply to new players
    table.insert(espData.connections,
        Players.PlayerAdded:Connect(function(plr)
            if espData.enabled then
                createPlayerESP(plr)
            end
        end)
    )

    -- Remove when they leave
    table.insert(espData.connections,
        Players.PlayerRemoving:Connect(clearPlayerESP)
    )
end

---------------------------------------------------------------------
-- DISABLE ALL
---------------------------------------------------------------------
function disableESPAll()

    if not espData.enabled then return end
    espData.enabled = false

    if espData.distanceConn then
        espData.distanceConn:Disconnect()
        espData.distanceConn = nil
    end

    for _,conn in ipairs(espData.connections) do
        conn:Disconnect()
    end
    espData.connections = {}

    for plr,_ in pairs(espData.playerESP) do
        clearPlayerESP(plr)
    end
end
-- =============================================================
-- SPIN SYSTEM
-- =============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local spinData = {}

function spin(plr, speed)

	speed = tonumber(speed) or 20
	speed = math.clamp(speed, 1, 10000)

	local char = plr.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	-- Stop old spin
	if spinData[plr] then
		unspin(plr)
	end

	hum.AutoRotate = false

	-- Attachment (YOU ALREADY HAD THIS)
	local attachment = Instance.new("Attachment")
	attachment.Name = "SpinAttachment"
	attachment.Parent = hrp

	-- REAL SPIN MOTOR (replaces AlignOrientation only)
	local angular = Instance.new("AngularVelocity")
	angular.Name = "SpinVelocity"
	angular.Attachment0 = attachment
	angular.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	angular.MaxTorque = math.huge

	-- the actual speed you type
	angular.AngularVelocity = Vector3.new(0, speed, 0)

	angular.Parent = hrp

	spinData[plr] = {
		attachment = attachment,
		angular = angular,
		connection = nil
	}

	-- keep server ownership so Roblox doesn't override it
	spinData[plr].connection = RunService.Stepped:Connect(function()
		if hrp and hrp.Parent then
			pcall(function()
				hrp:SetNetworkOwner(nil)
			end)
		end
	end)
end


function unspin(plr)

	local data = spinData[plr]
	if not data then return end

	if data.connection then
		data.connection:Disconnect()
	end

	if data.angular then
		data.angular:Destroy()
	end

	if data.attachment then
		data.attachment:Destroy()
	end

	local char = plr.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.AutoRotate = true
		end
	end

	spinData[plr] = nil
end


Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		unspin(plr)
	end)
end)

-- =============================================================
-- LEAVE COMMAND
-- =============================================================
local function leaveGame()
    game:Shutdown()
    notify("👋 Leaving game...", Color3.fromRGB(255, 100, 100))
end

-- =============================================================
-- DESTROY SCRIPT COMMAND
-- =============================================================
local function destroyScript()
    for _, gui in ipairs(client.PlayerGui:GetChildren()) do
        if gui.Name == "LunarGui" or gui.Name == "LunarNotifs" or 
           gui.Name == "AimbotPanel" or gui.Name == "logsPanel" or 
           gui.Name == "stopwatchPanel" or gui.Name == "SpeedPanel" or
           gui.Name == "JoinLogsPanel" or gui.Name == "ViewGui" or
           gui.Name == "CmdBarGui" then
            gui:Destroy()
        end
    end
    
    for _, data in pairs(spinData) do
        if data.connection then
            data.connection:Disconnect()
        end
    end
    
    if speedPanelData.connection then
        speedPanelData.connection:Disconnect()
    end
    
    if viewData.freezeConn then
        viewData.freezeConn:Disconnect()
    end
    
    disableESPAll()
    disableFreecam()
    
    notify("💥 Script destroyed", Color3.fromRGB(255, 80, 80))
end

-- =============================================================
-- COMMAND BAR - COMPLETELY FIXED
-- =============================================================
local cmdBarData = {
    gui = nil,
    visible = false,
    inputBox = nil
}

-- Global command processor reference for cmdbar
local commandProcessor = nil

local function toggleCmdBar()
    if cmdBarData.gui then
        cmdBarData.gui.Enabled = not cmdBarData.gui.Enabled
        cmdBarData.visible = cmdBarData.gui.Enabled
        if cmdBarData.visible and cmdBarData.inputBox then
            cmdBarData.inputBox:CaptureFocus()
        end
        return
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "CmdBarGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.Parent = client.PlayerGui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 600, 0, 50)
    main.Position = UDim2.new(0.5, -300, 0.1, 0)
    main.BackgroundColor3 = currentTheme.glass
    main.BorderSizePixel = 0
    main.Parent = gui
    applyGlassEffect(main, globalConfig.uiTransparency, 0.4)
    
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, -20, 1, -10)
    input.Position = UDim2.new(0, 10, 0, 5)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "Type command and press ENTER..."
    input.Font = Enum.Font.GothamBold
    input.TextSize = 20
    input.TextColor3 = globalConfig.textColor
    input.TextTransparency = 0 -- SOLID
    input.TextStrokeTransparency = 0.5
    input.TextStrokeColor3 = Color3.new(0,0,0)
    input.ClearTextOnFocus = false
    input.Parent = main
    
    cmdBarData.inputBox = input
    
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(1, 0, 0, 200)
    dropdown.Position = UDim2.new(0, 0, 1, 5)
    dropdown.BackgroundColor3 = currentTheme.list
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ClipsDescendants = true
    dropdown.Parent = main
    applyGlassEffect(dropdown, globalConfig.uiTransparency + 0.1, 0.5)
    
    local dropdownScroll = Instance.new("ScrollingFrame", dropdown)
    dropdownScroll.Size = UDim2.new(1, -10, 1, -10)
    dropdownScroll.Position = UDim2.new(0, 5, 0, 5)
    dropdownScroll.BackgroundTransparency = 1
    dropdownScroll.ScrollBarThickness = 6
    dropdownScroll.ScrollBarImageColor3 = currentTheme.accent
    
    local dropdownList = Instance.new("UIListLayout", dropdownScroll)
    dropdownList.Padding = UDim.new(0, 2)
    
    local allCommands = {
        "!aimbot", "!bring", "!clicktp", "!cmdbar", "!console", "!dance", "!destroyscript", 
        "!disablefalldamage", "!enable inventory", "!enable playerlist", "!esp all", "!unesp all", 
        "!explode", "!fire", "!unfire", "!firstp", "!fling", "!fly", "!unfly", "!freecam", 
        "!unfreecam", "!freeze", "!unfreeze", "!giant", "!tiny", "!god", "!ungod", "!heal", 
        "!invis", "!vis", "!joinlogs", "!jump", "!kill", "!lay", "!leave", "!logs", "!noclip", 
        "!unnoclip", "!ping", "!ragdoll", "!unragdoll", "!rainbow", "!unrainbow", "!rejoin", 
        "!removewaypoint", "!resetspeed", "!sit", "!speed", "!spin", "!unspin", "!stopwatch", 
        "!thirdp", "!to", "!tp", "!trip", "!tracers", "!untracers", "!view", "!unview", 
        "!waypoint", "!fov", "!kick", "!unlockmouse"
    }
    
    local function updateDropdown(text)
        for _, child in ipairs(dropdownScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        if text == "" or text == "!" then
            dropdown.Visible = false
            return
        end
        
        local matches = {}
        for _, cmd in ipairs(allCommands) do
            if cmd:lower():find(text:lower(), 1, true) then
                table.insert(matches, cmd)
            end
        end
        
        if #matches > 0 then
            dropdown.Visible = true
            for _, match in ipairs(matches) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = currentTheme.btn
                btn.BackgroundTransparency = 0.5
                btn.Text = match
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 16
                btn.TextColor3 = globalConfig.textColor
                btn.TextTransparency = 0 -- SOLID
                btn.TextStrokeTransparency = 0.5
                btn.TextStrokeColor3 = Color3.new(0,0,0)
                btn.Parent = dropdownScroll
                
                btn.MouseButton1Click:Connect(function()
                    input.Text = match .. " "
                    input.CursorPosition = #input.Text + 1
                    dropdown.Visible = false
                    input:CaptureFocus()
                end)
                
                btn.MouseEnter:Connect(function()
                    btn.BackgroundColor3 = currentTheme.accent
                end)
                
                btn.MouseLeave:Connect(function()
                    btn.BackgroundColor3 = currentTheme.btn
                end)
            end
            dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #matches * 32)
        else
            dropdown.Visible = false
        end
    end
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        updateDropdown(input.Text)
    end)
    
    -- FIXED: Command execution on Enter
    local function executeCommand()
        local cmdText = input.Text
        if cmdText and cmdText ~= "" then
            notify("▶️ Executing: " .. cmdText, Color3.fromRGB(200, 200, 255))
            processCmd(cmdText)
            input.Text = ""
            dropdown.Visible = false
        end
    end
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            executeCommand()
        end
    end)
    
    -- Backup: Also check for Return key
    UserInputService.InputBegan:Connect(function(key, gameProcessed)
        if not gameProcessed and key.KeyCode == Enum.KeyCode.Return and cmdBarData.visible and input:IsFocused() then
            executeCommand()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = UserInputService:GetMouseLocation()
            local absPos = main.AbsolutePosition
            local absSize = main.AbsoluteSize
            
            if pos.X < absPos.X or pos.X > absPos.X + absSize.X or
               pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y + 200 then
                dropdown.Visible = false
            end
        end
    end)
    
    cmdBarData.gui = gui
    cmdBarData.visible = true
    input:CaptureFocus()
    
    notify("✅ Command bar opened - Type and press ENTER", currentTheme.accent)
end

-- =============================================================
-- AIMBOT SYSTEM
-- =============================================================
local aimbotData = {
    enabled = false,
    fovEnabled = false,
    fovSize = 150,
    smoothness = 0.5,
    smoothnessEnabled = true,
    teamCheck = false,
    wallCheck = false,
    target = nil,
    rightClickHeld = false,
    panel = nil,
    fovCircle = nil,
    connection = nil,
    inputBeganConn = nil,
    inputEndedConn = nil,
    renderConn = nil
}

local function createAimbotPanel()
    -- Clean up existing
    if aimbotData.panel then
        aimbotData.panel:Destroy()
        aimbotData.panel = nil
    end
    if aimbotData.fovCircle then
        aimbotData.fovCircle:Destroy()
        aimbotData.fovCircle = nil
    end
    if aimbotData.connection then
        aimbotData.connection:Disconnect()
        aimbotData.connection = nil
    end
    if aimbotData.inputBeganConn then
        aimbotData.inputBeganConn:Disconnect()
        aimbotData.inputBeganConn = nil
    end
    if aimbotData.inputEndedConn then
        aimbotData.inputEndedConn:Disconnect()
        aimbotData.inputEndedConn = nil
    end
    if aimbotData.renderConn then
        aimbotData.renderConn:Disconnect()
        aimbotData.renderConn = nil
    end
    
    aimbotData.enabled = false
    aimbotData.fovEnabled = false
    
    local panel = Instance.new("ScreenGui")
    panel.Name = "AimbotPanel"
    panel.ResetOnSpawn = false
    panel.DisplayOrder = 999999
    panel.Parent = client.PlayerGui
    
    -- FOV Circle - Centered on cursor
    local fovCircle = Instance.new("Frame")
    fovCircle.Name = "FOVCircle"
    fovCircle.Size = UDim2.new(0, aimbotData.fovSize * 2, 0, aimbotData.fovSize * 2)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 0
    fovCircle.Visible = false
    fovCircle.Parent = panel
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = fovCircle
    
    local circleStroke = Instance.new("UIStroke")
    circleStroke.Color = currentTheme.accent
    circleStroke.Thickness = 2
    circleStroke.Parent = fovCircle
    
    aimbotData.fovCircle = fovCircle
    
    -- Update FOV circle position to center on mouse
    aimbotData.renderConn = RunService.RenderStepped:Connect(function()
        if aimbotData.fovCircle and aimbotData.fovEnabled then
            local mousePos = UserInputService:GetMouseLocation()
            local size = aimbotData.fovSize * 2
            -- Center the circle on the mouse cursor
            aimbotData.fovCircle.Position = UDim2.new(0, mousePos.X - aimbotData.fovSize, 0, mousePos.Y - aimbotData.fovSize)
            aimbotData.fovCircle.Size = UDim2.new(0, size, 0, size)
        end
    end)
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 340, 0, 520)
    main.Position = UDim2.new(0, 430, 0.5, -260)
    main.BackgroundColor3 = currentTheme.glass
    main.Active = true
    main.Draggable = true
    main.Parent = panel
    applyGlassEffect(main, globalConfig.uiTransparency, 0.4)
    
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "AIMBOT CONTROL"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 26
    title.TextColor3 = currentTheme.accent
    title.TextTransparency = 0 -- SOLID
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.new(0,0,0)
    
    local toggleBtn = Instance.new("TextButton", main)
    toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
    toggleBtn.Position = UDim2.new(0.05, 0, 0, 55)
    toggleBtn.BackgroundColor3 = currentTheme.btn
    toggleBtn.Text = "Toggle Aimbot: OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 18
    toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    toggleBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(toggleBtn, 0.2, 0.5)
    
    local fovBtn = Instance.new("TextButton", main)
    fovBtn.Size = UDim2.new(0.9, 0, 0, 45)
    fovBtn.Position = UDim2.new(0.05, 0, 0, 105)
    fovBtn.BackgroundColor3 = currentTheme.btn
    fovBtn.Text = "Toggle FOV Circle: OFF"
    fovBtn.Font = Enum.Font.GothamBold
    fovBtn.TextSize = 18
    fovBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    fovBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(fovBtn, 0.2, 0.5)
    
    local fovLabel = Instance.new("TextLabel", main)
    fovLabel.Size = UDim2.new(0.9, 0, 0, 30)
    fovLabel.Position = UDim2.new(0.05, 0, 0, 155)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV Size: 150"
    fovLabel.Font = Enum.Font.GothamBold
    fovLabel.TextSize = 16
    fovLabel.TextColor3 = globalConfig.textColor
    fovLabel.TextTransparency = 0 -- SOLID
    fovLabel.TextStrokeTransparency = 0.5
    fovLabel.TextStrokeColor3 = Color3.new(0,0,0)
    
    local fovSlider = Instance.new("Frame", main)
    fovSlider.Size = UDim2.new(0.9, 0, 0, 12)
    fovSlider.Position = UDim2.new(0.05, 0, 0, 185)
    fovSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    applyGlassEffect(fovSlider, 0.3, 0.7)
    
    local fovFill = Instance.new("Frame", fovSlider)
    fovFill.Size = UDim2.new(0.33, 0, 1, 0)
    fovFill.BackgroundColor3 = currentTheme.accent
    fovFill.BorderSizePixel = 0
    Instance.new("UICorner", fovFill).CornerRadius = UDim.new(0, 6)
    
    local fovDrag = Instance.new("TextButton", fovSlider)
    fovDrag.Size = UDim2.new(0, 20, 0, 20)
    fovDrag.Position = UDim2.new(0.33, -10, 0.5, -10)
    fovDrag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fovDrag.Text = ""
    Instance.new("UICorner", fovDrag).CornerRadius = UDim.new(1, 0)
    
    local smoothToggleBtn = Instance.new("TextButton", main)
    smoothToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
    smoothToggleBtn.Position = UDim2.new(0.05, 0, 0, 205)
    smoothToggleBtn.BackgroundColor3 = currentTheme.btn
    smoothToggleBtn.Text = "Smoothness: ON"
    smoothToggleBtn.Font = Enum.Font.GothamBold
    smoothToggleBtn.TextSize = 18
    smoothToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    smoothToggleBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(smoothToggleBtn, 0.2, 0.5)
    
    local smoothLabel = Instance.new("TextLabel", main)
    smoothLabel.Size = UDim2.new(0.9, 0, 0, 30)
    smoothLabel.Position = UDim2.new(0.05, 0, 0, 255)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.Text = "Smoothness Amount: 0.5"
    smoothLabel.Font = Enum.Font.GothamBold
    smoothLabel.TextSize = 16
    smoothLabel.TextColor3 = globalConfig.textColor
    smoothLabel.TextTransparency = 0 -- SOLID
    smoothLabel.TextStrokeTransparency = 0.5
    smoothLabel.TextStrokeColor3 = Color3.new(0,0,0)
    
    local smoothSlider = Instance.new("Frame", main)
    smoothSlider.Size = UDim2.new(0.9, 0, 0, 12)
    smoothSlider.Position = UDim2.new(0.05, 0, 0, 285)
    smoothSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    applyGlassEffect(smoothSlider, 0.3, 0.7)
    
    local smoothFill = Instance.new("Frame", smoothSlider)
    smoothFill.Size = UDim2.new(0.44, 0, 1, 0)
    smoothFill.BackgroundColor3 = currentTheme.accent
    smoothFill.BorderSizePixel = 0
    Instance.new("UICorner", smoothFill).CornerRadius = UDim.new(0, 6)
    
    local smoothDrag = Instance.new("TextButton", smoothSlider)
    smoothDrag.Size = UDim2.new(0, 20, 0, 20)
    smoothDrag.Position = UDim2.new(0.44, -10, 0.5, -10)
    smoothDrag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    smoothDrag.Text = ""
    Instance.new("UICorner", smoothDrag).CornerRadius = UDim.new(1, 0)
    
    local teamBtn = Instance.new("TextButton", main)
    teamBtn.Size = UDim2.new(0.9, 0, 0, 45)
    teamBtn.Position = UDim2.new(0.05, 0, 0, 305)
    teamBtn.BackgroundColor3 = currentTheme.btn
    teamBtn.Text = "Team Check: OFF"
    teamBtn.Font = Enum.Font.GothamBold
    teamBtn.TextSize = 18
    teamBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    teamBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(teamBtn, 0.2, 0.5)
    
    local wallBtn = Instance.new("TextButton", main)
    wallBtn.Size = UDim2.new(0.9, 0, 0, 45)
    wallBtn.Position = UDim2.new(0.05, 0, 0, 355)
    wallBtn.BackgroundColor3 = currentTheme.btn
    wallBtn.Text = "Wall Check: OFF"
    wallBtn.Font = Enum.Font.GothamBold
    wallBtn.TextSize = 18
    wallBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    wallBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(wallBtn, 0.2, 0.5)
    
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(closeBtn, 0.2, 0.4)
    
    local statusLabel = Instance.new("TextLabel", main)
    statusLabel.Size = UDim2.new(0.9, 0, 0, 60)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 410)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Hold Right Click to Lock"
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 18
    statusLabel.TextColor3 = currentTheme.accent
    statusLabel.TextTransparency = 0 -- SOLID
    statusLabel.TextStrokeTransparency = 0.5
    statusLabel.TextStrokeColor3 = Color3.new(0,0,0)
    statusLabel.TextWrapped = true
    
    local function updateAimbot()
        if aimbotData.enabled then
            toggleBtn.Text = "Toggle Aimbot: ON"
            toggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            toggleBtn.Text = "Toggle Aimbot: OFF"
            toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    local function updateFOV()
        if aimbotData.fovEnabled then
            fovBtn.Text = "Toggle FOV Circle: ON"
            fovBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
            if aimbotData.fovCircle then
                aimbotData.fovCircle.Visible = true
            end
        else
            fovBtn.Text = "Toggle FOV Circle: OFF"
            fovBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            if aimbotData.fovCircle then
                aimbotData.fovCircle.Visible = false
            end
        end
    end
    
    local function updateSmoothnessToggle()
        if aimbotData.smoothnessEnabled then
            smoothToggleBtn.Text = "Smoothness: ON"
            smoothToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            smoothToggleBtn.Text = "Smoothness: OFF"
            smoothToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    local function updateTeamCheck()
        if aimbotData.teamCheck then
            teamBtn.Text = "Team Check: ON"
            teamBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            teamBtn.Text = "Team Check: OFF"
            teamBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    local function updateWallCheck()
        if aimbotData.wallCheck then
            wallBtn.Text = "Wall Check: ON"
            wallBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            wallBtn.Text = "Wall Check: OFF"
            wallBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    toggleBtn.MouseButton1Click:Connect(function()
        aimbotData.enabled = not aimbotData.enabled
        updateAimbot()
    end)
    
    fovBtn.MouseButton1Click:Connect(function()
        aimbotData.fovEnabled = not aimbotData.fovEnabled
        updateFOV()
    end)
    
    smoothToggleBtn.MouseButton1Click:Connect(function()
        aimbotData.smoothnessEnabled = not aimbotData.smoothnessEnabled
        updateSmoothnessToggle()
    end)
    
    teamBtn.MouseButton1Click:Connect(function()
        aimbotData.teamCheck = not aimbotData.teamCheck
        updateTeamCheck()
    end)
    
    wallBtn.MouseButton1Click:Connect(function()
        aimbotData.wallCheck = not aimbotData.wallCheck
        updateWallCheck()
    end)
    
    local function setupSlider(slider, fill, drag, label, dataKey, min, max, isInt, prefixText)
        local dragging = false
        
        drag.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                drag.Position = UDim2.new(pos, -10, 0.5, -10)
                
                local value = min + (pos * (max - min))
                if isInt then
                    value = math.floor(value)
                else
                    value = math.round(value * 10) / 10
                end
                
                aimbotData[dataKey] = value
                label.Text = prefixText .. ": " .. value
                
                if dataKey == "fovSize" and aimbotData.fovCircle then
                    local size = value * 2
                    aimbotData.fovCircle.Size = UDim2.new(0, size, 0, size)
                end
            end
        end)
    end
    
    setupSlider(fovSlider, fovFill, fovDrag, fovLabel, "fovSize", 50, 400, true, "FOV Size")
    setupSlider(smoothSlider, smoothFill, smoothDrag, smoothLabel, "smoothness", 0.1, 1, false, "Smoothness Amount")
    
    closeBtn.MouseButton1Click:Connect(function()
        aimbotData.enabled = false
        aimbotData.fovEnabled = false
        aimbotData.rightClickHeld = false
        
        if aimbotData.connection then
            aimbotData.connection:Disconnect()
            aimbotData.connection = nil
        end
        if aimbotData.inputBeganConn then
            aimbotData.inputBeganConn:Disconnect()
            aimbotData.inputBeganConn = nil
        end
        if aimbotData.inputEndedConn then
            aimbotData.inputEndedConn:Disconnect()
            aimbotData.inputEndedConn = nil
        end
        if aimbotData.renderConn then
            aimbotData.renderConn:Disconnect()
            aimbotData.renderConn = nil
        end
        
        panel:Destroy()
        aimbotData.panel = nil
        aimbotData.fovCircle = nil
        
        notify("✅ Aimbot panel closed", Color3.fromRGB(255, 160, 60))
    end)
    
    aimbotData.panel = panel
    
    -- FIXED: Better target validation with team check
    local function isValidTarget(plr)
        if not plr or plr == client then return false end
        if not plr.Character then return false end
        if not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
        if not plr.Character:FindFirstChild("Humanoid") then return false end
        if plr.Character.Humanoid.Health <= 0 then return false end
        
        -- FIXED: Team Check - Skip teammates
        if aimbotData.teamCheck then
            if client.Team and plr.Team and client.Team == plr.Team then
                return false
            end
        end
        
        if aimbotData.wallCheck then
            local targetPos = plr.Character.HumanoidRootPart.Position
            local cameraPos = workspace.CurrentCamera.CFrame.Position
            local direction = (targetPos - cameraPos).Unit
            local distance = (targetPos - cameraPos).Magnitude
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {client.Character, plr.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            
            local result = Workspace:Raycast(cameraPos, direction * distance, raycastParams)
            if result then
                return false
            end
        end
        
        return true
    end
    
    local function getClosestPlayer()
        local closest = nil
        local closestDist = aimbotData.fovEnabled and aimbotData.fovSize or math.huge
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if isValidTarget(plr) then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = plr
                    end
                end
            end
        end
        
        return closest
    end
    
    -- FIXED: Aimbot loop that works even after death
    aimbotData.connection = RunService.RenderStepped:Connect(function()
        if aimbotData.enabled and aimbotData.rightClickHeld then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local pos = workspace.CurrentCamera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local targetPos = Vector2.new(pos.X, pos.Y)
                
                local moveVec
                if aimbotData.smoothnessEnabled then
                    moveVec = mousePos:Lerp(targetPos, 1 - aimbotData.smoothness)
                else
                    moveVec = targetPos
                end
                
                if mousemoverel then
                    mousemoverel(moveVec.X - mousePos.X, moveVec.Y - mousePos.Y)
                end
            end
        end
    end)
    
    aimbotData.inputBeganConn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            aimbotData.rightClickHeld = true
        end
    end)
    
    aimbotData.inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            aimbotData.rightClickHeld = false
        end
    end)
end

-- =============================================================
-- UNLOCK MOUSE SYSTEM
-- =============================================================
local mouseUnlockData = {
    enabled = false,
    connection = nil
}

local function toggleMouseUnlock()
    mouseUnlockData.enabled = not mouseUnlockData.enabled
    
    if mouseUnlockData.enabled then
        notify("🔓 Mouse unlock enabled! Press F to toggle lock/unlock", Color3.fromRGB(100, 255, 100))
        
        mouseUnlockData.connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
                local currentState = UserInputService.MouseBehavior
                if currentState == Enum.MouseBehavior.LockCenter then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                    UserInputService.MouseIconEnabled = true
                    notify("🔓 Mouse UNLOCKED - Move freely", Color3.fromRGB(100, 255, 100))
                else
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                    UserInputService.MouseIconEnabled = false
                    notify("🔒 Mouse LOCKED - FPS mode", Color3.fromRGB(255, 100, 100))
                end
            end
        end)
    else
        if mouseUnlockData.connection then
            mouseUnlockData.connection:Disconnect()
            mouseUnlockData.connection = nil
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        notify("❌ Mouse unlock disabled", Color3.fromRGB(255, 100, 100))
    end
end

-- =============================================================
-- PANEL MANAGEMENT
-- =============================================================
local subPanels = {
    logs = nil,
    stopwatch = nil
}

local function createSubPanel(name, size, titleText)
    local existing = client.PlayerGui:FindFirstChild(name .. "Panel")
    if existing then
        existing:Destroy()
        if subPanels[name] then
            subPanels[name] = nil
        end
        return nil
    end
    
    local panel = Instance.new("ScreenGui")
    panel.Name = name .. "Panel"
    panel.ResetOnSpawn = false
    panel.DisplayOrder = 999999
    panel.Parent = client.PlayerGui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = size
    main.Position = UDim2.new(0, 430, 0.5, -size.Y.Offset/2)
    main.BackgroundColor3 = currentTheme.glass
    main.Active = true
    main.Draggable = true
    main.Parent = panel
    applyGlassEffect(main, globalConfig.uiTransparency, 0.4)
    
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, -50, 0, 45)
    title.Position = UDim2.new(0, 15, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextColor3 = currentTheme.accent
    title.TextTransparency = 0 -- SOLID
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.new(0,0,0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(closeBtn, 0.2, 0.4)
    
    closeBtn.MouseButton1Click:Connect(function()
        panel:Destroy()
        subPanels[name] = nil
    end)
    
    subPanels[name] = panel
    return main
end

-- =============================================================
-- LOGS PANEL
-- =============================================================
local logsScroll, logEntries = nil, {}

local function addLog(sender, message)
    if not logsScroll or not logsScroll.Parent then return end
    if #logEntries > 70 then
        if logEntries[1] then logEntries[1]:Destroy() end
        table.remove(logEntries, 1)
    end
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, -16, 0, 32)
    entry.BackgroundTransparency = 0.8
    entry.BackgroundColor3 = currentTheme.btn
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.RichText = true
    entry.Text = " <font color='rgb(140,180,255)'><b>" .. sender .. "</b></font>: " .. message
    entry.TextColor3 = globalConfig.textColor
    entry.TextSize = 15
    entry.Font = Enum.Font.Gotham
    entry.TextWrapped = true
    entry.TextTransparency = 0 -- SOLID
    entry.TextStrokeTransparency = 0.5
    entry.TextStrokeColor3 = Color3.new(0,0,0)
    entry.Parent = logsScroll
    applyGlassEffect(entry, 0.6, 0.8)
    table.insert(logEntries, entry)
    logsScroll.CanvasSize = UDim2.new(0,0,0, #logEntries * 36)
    logsScroll.CanvasPosition = Vector2.new(0, #logEntries * 36)
end

local function toggleLogs()
    if subPanels.logs then
        subPanels.logs:Destroy()
        subPanels.logs = nil
        logsScroll = nil
        return
    end
    
    local main = createSubPanel("logs", UDim2.new(0, 420, 0, 380), "CHAT LOGS")
    if not main then return end
    
    logsScroll = Instance.new("ScrollingFrame", main)
    logsScroll.Size = UDim2.new(1, -20, 1, -65)
    logsScroll.Position = UDim2.new(0, 10, 0, 55)
    logsScroll.BackgroundTransparency = 0.4
    logsScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    logsScroll.ScrollBarThickness = 8
    logsScroll.ScrollBarImageColor3 = currentTheme.accent
    applyGlassEffect(logsScroll, 0.5, 0.7)
    
    local layout = Instance.new("UIListLayout", logsScroll)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local clearBtn = Instance.new("TextButton", main)
    clearBtn.Size = UDim2.new(0, 90, 0, 35)
    clearBtn.Position = UDim2.new(1, -140, 0, 5)
    clearBtn.BackgroundColor3 = currentTheme.btn
    clearBtn.Text = "Clear"
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 16
    clearBtn.TextColor3 = globalConfig.textColor
    clearBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(clearBtn, 0.25, 0.5)
    
    clearBtn.MouseButton1Click:Connect(function()
        for _, entry in ipairs(logEntries) do
            if entry then entry:Destroy() end
        end
        logEntries = {}
        logsScroll.CanvasSize = UDim2.new(0,0,0,0)
    end)
    
    notify("✅ Logs panel opened", Color3.fromRGB(180,180,255))
end

TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then
        addLog(msg.TextSource.Name, msg.Text)
    end
end)

-- =============================================================
-- STOPWATCH PANEL
-- =============================================================
local stopwatchData = {
    running = false,
    startTime = 0,
    conn = nil,
    label = nil
}

local function toggleStopwatch()
    if subPanels.stopwatch then
        subPanels.stopwatch:Destroy()
        subPanels.stopwatch = nil
        if stopwatchData.conn then
            stopwatchData.conn:Disconnect()
            stopwatchData.conn = nil
        end
        stopwatchData.running = false
        return
    end
    
    local main = createSubPanel("stopwatch", UDim2.new(0, 380, 0, 220), "STOPWATCH")
    if not main then return end
    
    local timeLabel = Instance.new("TextLabel", main)
    timeLabel.Size = UDim2.new(1, -20, 0, 90)
    timeLabel.Position = UDim2.new(0, 10, 0, 55)
    timeLabel.BackgroundTransparency = 0.3
    timeLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    timeLabel.Text = "00:00.00"
    timeLabel.Font = Enum.Font.GothamBlack
    timeLabel.TextSize = 56
    timeLabel.TextColor3 = currentTheme.accent
    timeLabel.TextTransparency = 0 -- SOLID
    timeLabel.TextStrokeTransparency = 0.5
    timeLabel.TextStrokeColor3 = Color3.new(0,0,0)
    applyGlassEffect(timeLabel, 0.4, 0.6)
    
    local btnFrame = Instance.new("Frame", main)
    btnFrame.Size = UDim2.new(1, -20, 0, 55)
    btnFrame.Position = UDim2.new(0, 10, 0, 155)
    btnFrame.BackgroundTransparency = 1
    
    local startBtn = Instance.new("TextButton", btnFrame)
    startBtn.Size = UDim2.new(0.48, 0, 1, 0)
    startBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    startBtn.Text = "START"
    startBtn.Font = Enum.Font.GothamBlack
    startBtn.TextSize = 22
    startBtn.TextColor3 = Color3.new(0,0,0)
    startBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(startBtn, 0.15, 0.4)
    
    local resetBtn = Instance.new("TextButton", btnFrame)
    resetBtn.Size = UDim2.new(0.48, 0, 1, 0)
    resetBtn.Position = UDim2.new(0.52, 0, 0, 0)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    resetBtn.Text = "RESET"
    resetBtn.Font = Enum.Font.GothamBlack
    resetBtn.TextSize = 22
    resetBtn.TextColor3 = Color3.new(0,0,0)
    resetBtn.TextTransparency = 0 -- SOLID
    applyGlassEffect(resetBtn, 0.15, 0.4)
    
    local function formatTime(t)
        local mins = math.floor(t / 60)
        local secs = math.floor(t % 60)
        local ms = math.floor((t % 1) * 100)
        return string.format("%02d:%02d.%02d", mins, secs, ms)
    end
    
    startBtn.MouseButton1Click:Connect(function()
        if stopwatchData.running then
            stopwatchData.running = false
            if stopwatchData.conn then
                stopwatchData.conn:Disconnect()
                stopwatchData.conn = nil
            end
            startBtn.Text = "RESUME"
            startBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        else
            stopwatchData.running = true
            local current = tick()
            stopwatchData.startTime = current - (stopwatchData.startTime or 0)
            stopwatchData.conn = RunService.Heartbeat:Connect(function()
                if stopwatchData.running then
                    local elapsed = tick() - stopwatchData.startTime
                    timeLabel.Text = formatTime(elapsed)
                end
            end)
            startBtn.Text = "PAUSE"
            startBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
        end
    end)
    
    resetBtn.MouseButton1Click:Connect(function()
        stopwatchData.running = false
        if stopwatchData.conn then
            stopwatchData.conn:Disconnect()
            stopwatchData.conn = nil
        end
        stopwatchData.startTime = 0
        timeLabel.Text = "00:00.00"
        startBtn.Text = "START"
        startBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    end)
    
    stopwatchData.label = timeLabel
    notify("✅ Stopwatch panel opened", Color3.fromRGB(200, 200, 255))
end

-- =============================================================
-- REMOVE WAYPOINT
-- =============================================================
local function removeWaypoint()
    if #waypoints == 0 then
        notify("⚠️ No waypoints to remove", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local last = waypoints[#waypoints]
    if last then
        if last.conn then last.conn:Disconnect() end
        if last.part then last.part:Destroy() end
        table.remove(waypoints, #waypoints)
        notify("✅ Removed waypoint #" .. (#waypoints + 1), Color3.fromRGB(255, 160, 60))
    end
end

-- =============================================================
-- UTILITIES
-- =============================================================
local function getPlr(str)
    if not str or str:lower() == "me" then return client end
    str = str:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1,#str) == str or (p.DisplayName or ""):lower():sub(1,#str) == str then
            return p
        end
    end
    return nil
end

local function getHRP(p)
    local c = p.Character
    if c then
        local part = c:FindFirstChild("HumanoidRootPart")
        if part then
            return part
        end
    end
    return nil
end

local function getHum(p)
    local c = p.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            return hum
        end
    end
    return nil
end

-- =============================================================
-- ALL COMMANDS
-- =============================================================
local noclipConn
local frozen = {}
local gods = {}
local invis = {}
local rainbowData = {}
local ragdolls = {}
------------------------------------------------
-- advanced speed
------------------------------------------------
local function setspeed(plr, num)
    if plr ~= client then
        notify("❌ Speed only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if hum then
        hum.WalkSpeed = tonumber(num) or 16
        notify("✅ WalkSpeed set to " .. hum.WalkSpeed, currentTheme.accent)
    end
end
------------------------------------------------
-- advanced resetspeed
------------------------------------------------
local function resetspeed(plr)
    if plr ~= client then
        notify("❌ Resetspeed only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if hum then
        hum.WalkSpeed = 16
        notify("✅ WalkSpeed reset to 16", Color3.fromRGB(180, 180, 255))
    end
end
------------------------------------------------
-- advanced noclip
------------------------------------------------
local function noclip(plr)
    if plr ~= client then
        notify("❌ Noclip only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if noclipConn then 
        notify("⚠️ Noclip already enabled", Color3.fromRGB(255, 200, 100))
        return 
    end
    noclipConn = RunService.Stepped:Connect(function()
        if client.Character then
            for _, part in client.Character:GetDescendants() do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end)
    notify("✅ Noclip enabled", Color3.fromRGB(100, 255, 120))
end
------------------------------------------------
-- advanced unnoclip
------------------------------------------------
local function unnoclip(plr)
    if plr ~= client then
        notify("❌ Unnoclip only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    if client.Character then
        for _, part in client.Character:GetDescendants() do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
    notify("✅ Noclip disabled", Color3.fromRGB(255, 120, 100))
end
------------------------------------------------
-- advanced heal
------------------------------------------------
local function heal(plr)
    local hum = getHum(plr)
    if hum then
        hum.Health = hum.MaxHealth
        notify("✅ Healed " .. plr.Name, Color3.fromRGB(100, 255, 100))
    else
        notify("❌ Cannot heal - no humanoid found", Color3.fromRGB(255, 100, 100))
    end
end
------------------------------------------------
-- advanced kill
------------------------------------------------
local function kill(plr)
    local char = plr and plr.Character
    if not char then 
        notify("❌ Cannot kill - no character", Color3.fromRGB(255, 100, 100))
        return 
    end
    pcall(function()
        local hum = getHum(plr)
        if hum then hum.Health = 0 end
        char:BreakJoints()
    end)
    notify("💀 Killed " .. plr.Name, Color3.fromRGB(255, 80, 80))
end
------------------------------------------------
-- advanced tp
------------------------------------------------
local function tp(p1, p2)
    if p1 ~= client then
        notify("❌ Teleport only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if not p2 then
        notify("❌ No target player specified", Color3.fromRGB(255, 100, 100))
        return
    end
    local h1, h2 = getHRP(p1), getHRP(p2)
    if h1 and h2 then
        h1.CFrame = h2.CFrame * CFrame.new(0, 3, 0)
        notify("✅ Teleported to " .. p2.Name, currentTheme.accent)
    else
        notify("❌ Teleport failed - missing character parts", Color3.fromRGB(255, 100, 100))
    end
end
------------------------------------------------
-- advanced bring
------------------------------------------------
local function bring(plr)
    notify("⚠️ Bring not possible client-side", Color3.fromRGB(255, 200, 100))
end
------------------------------------------------
-- advanced to
------------------------------------------------
local function gotoMe(target)
    if not target then
        notify("❌ No target specified", Color3.fromRGB(255, 100, 100))
        return
    end
    tp(client, target)
end
------------------------------------------------
-- advanced Jumppower
------------------------------------------------
local function jump(plr, pow)
    if plr ~= client then
        notify("❌ Jump only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if hum then
        hum.JumpPower = tonumber(pow) or 50
        notify("✅ Jump power set to " .. hum.JumpPower, Color3.fromRGB(200, 200, 100))
    end
end
------------------------------------------------
-- advanced sit
------------------------------------------------
local function sit(plr)
    if plr ~= client then
        notify("❌ Sit only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if hum then 
        hum.Sit = true 
        notify("✅ Sitting", Color3.fromRGB(200, 150, 255))
    end
end
------------------------------------------------
-- advanced Lay
------------------------------------------------
local function lay(plr)
    if plr ~= client then
        notify("❌ Lay only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if hum then
        hum.Sit = true
        task.wait(0.1)
        local hrp = getHRP(plr)
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0) end
        notify("✅ Laying down", Color3.fromRGB(200, 150, 255))
    end
end
------------------------------------------------
-- advanced Freeze
------------------------------------------------
local function freeze(plr)
    if plr ~= client then
        notify("❌ Freeze only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if not hum or frozen[plr] then 
        notify("⚠️ Already frozen", Color3.fromRGB(255, 200, 100))
        return 
    end
    frozen[plr] = {ws = hum.WalkSpeed, jp = hum.JumpPower}
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    notify("❄️ Frozen", Color3.fromRGB(100, 100, 255))
end
------------------------------------------------
-- advanced Unfreeze
------------------------------------------------
local function unfreeze(plr)
    if plr ~= client then
        notify("❌ Unfreeze only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local data = frozen[plr]
    local hum = getHum(plr)
    if data and hum then
        hum.WalkSpeed = data.ws
        hum.JumpPower = data.jp
        frozen[plr] = nil
        notify("✅ Unfrozen", Color3.fromRGB(200, 100, 200))
    else
        notify("⚠️ Not frozen", Color3.fromRGB(255, 200, 100))
    end
end
------------------------------------------------
-- advanced God
------------------------------------------------
local function god(plr)
    if plr ~= client then
        notify("❌ God mode only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if gods[plr] then 
        notify("⚠️ Already in god mode", Color3.fromRGB(255, 200, 100))
        return 
    end
    local hum = getHum(plr)
    if hum then
        gods[plr] = hum.HealthChanged:Connect(function()
            hum.Health = hum.MaxHealth
        end)
        notify("👑 God mode enabled", Color3.fromRGB(255, 215, 0))
    end
end
------------------------------------------------
-- advanced Ungod
------------------------------------------------
local function ungod(plr)
    if plr ~= client then
        notify("❌ Ungod only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if gods[plr] then
        gods[plr]:Disconnect()
        gods[plr] = nil
        notify("✅ God mode disabled", Color3.fromRGB(255, 140, 0))
    else
        notify("⚠️ Not in god mode", Color3.fromRGB(255, 200, 100))
    end
end
------------------------------------------------
-- advanced Invisible
------------------------------------------------
local function invisP(plr)
    if plr ~= client then
        notify("❌ Invisibility only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if invis[plr] then 
        notify("⚠️ Already invisible", Color3.fromRGB(255, 200, 100))
        return 
    end
    local char = plr.Character
    if char then
        for _, part in char:GetDescendants() do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            end
        end
    end
    invis[plr] = true
    notify("👻 Invisible", Color3.fromRGB(180, 100, 255))
end
------------------------------------------------
-- advanced Visible
------------------------------------------------
local function visP(plr)
    if plr ~= client then
        notify("❌ Visibility only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if not invis[plr] then 
        notify("⚠️ Already visible", Color3.fromRGB(255, 200, 100))
        return 
    end
    local char = plr.Character
    if char then
        for _, part in char:GetDescendants() do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
    invis[plr] = nil
    notify("✅ Visible", Color3.fromRGB(100, 180, 255))
end
------------------------------------------------
-- advanced Fling
------------------------------------------------
local function fling(plr)
    if plr ~= client then
        notify("❌ Fling only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hrp = getHRP(plr)
    if hrp then
        local v = Instance.new("BodyVelocity")
        v.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        v.Velocity = Vector3.new(math.random(-200,200)*100, 200*100, math.random(-200,200)*100)
        v.Parent = hrp
        task.delay(0.3, function() if v then v:Destroy() end end)
        notify("💨 Flung!", Color3.fromRGB(255, 100, 180))
    end
end
------------------------------------------------
-- advanced Rejoin
------------------------------------------------
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function rejoin()
    -- Optional: show a little notification (if you have a notify function already)
    notify("🔄 Rejoining same server...", Color3.fromRGB(100, 200, 255))
    
    -- This rejoins **exactly** the current server (using current JobId)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end
------------------------------------------------
-- advanced Ping
------------------------------------------------
local function ping()
    local ping = math.round(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    local color = ping < 100 and Color3.fromRGB(100, 255, 100) or (ping < 200 and Color3.fromRGB(255, 255, 100) or Color3.fromRGB(255, 100, 100))
    notify("📶 Ping: " .. ping .. "ms", color)
end
------------------------------------------------
-- advanced ClickTP
------------------------------------------------
local clickTPconn
local function clickTP()
    if clickTPconn then
        clickTPconn:Disconnect()
        clickTPconn = nil
        notify("✅ Click TP disabled", Color3.fromRGB(255, 120, 100))
    else
        clickTPconn = Mouse.Button1Down:Connect(function()
            if Mouse.Target then
                local hrp = getHRP(client)
                if hrp then
                    hrp.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
                end
            end
        end)
        notify("✅ Click TP enabled - click anywhere to teleport", Color3.fromRGB(100, 255, 120))
    end
end
------------------------------------------------
-- advanced FOV
------------------------------------------------
local function setFov(val)
    local num = tonumber(val)
    if num and num >= 1 and num <= 120 then
        workspace.CurrentCamera.FieldOfView = num
        notify("✅ FOV set to " .. num, currentTheme.accent)
    else
        notify("❌ Invalid FOV (1-120)", Color3.fromRGB(255, 100, 100))
    end
end
------------------------------------------------
-- advanced kick
------------------------------------------------
local function kick(plr)
    if plr == client then
        client:Kick("Kicked via Lunar Admin")
    else
        notify("⚠️ Kick only works on yourself (client-side)", Color3.fromRGB(255, 170, 0))
    end
end
------------------------------------------------
-- advanced ragdoll
------------------------------------------------
local function ragdoll(plr)
    if plr ~= client then
        notify("❌ Ragdoll only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local char = plr.Character
    if not char then 
        notify("❌ No character to ragdoll", Color3.fromRGB(255, 100, 100))
        return 
    end
    local hum = getHum(plr)
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    hum.PlatformStand = true
    local joints = {}
    for _, v in char:GetDescendants() do
        if v:IsA("Motor6D") then
            v.Enabled = false
            table.insert(joints, v)
        end
    end
    ragdolls[plr] = joints
    notify("🦴 Ragdolled", Color3.fromRGB(200, 100, 100))
end
------------------------------------------------
-- advanced unragdoll
------------------------------------------------
local function unragdoll(plr)
    if plr ~= client then
        notify("❌ Unragdoll only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local joints = ragdolls[plr]
    if not joints then 
        notify("⚠️ Not ragdolled", Color3.fromRGB(255, 200, 100))
        return 
    end
    for _, v in ipairs(joints) do v.Enabled = true end
    local hum = getHum(plr)
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum.PlatformStand = false
    end
    ragdolls[plr] = nil
    notify("✅ Unragdolled", Color3.fromRGB(100, 200, 100))
end
------------------------------------------------
-- advanced console
------------------------------------------------
local function console()
    StarterGui:SetCore("DevConsoleVisible", true)
    notify("✅ Console opened", Color3.fromRGB(180, 180, 255))
end
------------------------------------------------
-- advanced disable fall damage
------------------------------------------------
local function disableFallDamage()
    local conn = client.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end)
    notify("✅ Fall damage disabled", Color3.fromRGB(100, 255, 180))
end
------------------------------------------------
-- advanced enable inventory
------------------------------------------------
local function enableCore(name)
    local enum
    if name == "inventory" then enum = Enum.CoreGuiType.Backpack
    elseif name == "playerlist" then enum = Enum.CoreGuiType.PlayerList
    else 
        notify("❌ Unknown core GUI: " .. tostring(name), Color3.fromRGB(255, 100, 100))
        return 
    end
    local current = StarterGui:GetCoreGuiEnabled(enum)
    StarterGui:SetCoreGuiEnabled(enum, not current)
    notify("✅ " .. name:gsub("^%l", string.upper) .. (not current and " enabled" or " disabled"), Color3.fromRGB(180, 180, 255))
end
------------------------------------------------
-- advanced Dance
------------------------------------------------
local function dance(plr)
    if plr ~= client then
        notify("❌ Dance only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507771019"
        local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
        local track = animator:LoadAnimation(anim)
        track:Play()
        notify("💃 Dancing!", Color3.fromRGB(255, 100, 255))
    end
end
------------------------------------------------
-- advanced trip
------------------------------------------------
local function trip(plr)
    if plr ~= client then
        notify("❌ Trip only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if hum then
        hum.Sit = true
        hum.Jump = true
        notify("🤕 Tripped!", Color3.fromRGB(255, 180, 100))
    end
end

------------------------------------
-- advanced explode 
------------------------------------

local function explode(plr)
    local char = plr.Character
    if not char then
        notify("❌ No character found", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not root or humanoid.Health <= 0 then
        notify("❌ Cannot explode - invalid or already dead", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Step 1: Create a big visible explosion for everyone
    local explosion = Instance.new("Explosion")
    explosion.Position = root.Position
    explosion.BlastRadius = 12           -- decent size
    explosion.BlastPressure = 500000     -- strong visual push
    explosion.DestroyJointRadiusPercent = 0  -- don't auto-break joints (we do it manually)
    explosion.Parent = workspace
    
    -- Step 2: Force death + ragdoll (kills you and makes physics take over)
    humanoid.Health = 0
    humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    
    -- Step 3: Detach limbs visibly (breaks Motor6D joints → parts fly apart)
    -- This is what makes limbs scatter like an explosion
    for _, motor in ipairs(char:GetDescendants()) do
        if motor:IsA("Motor6D") and motor.Part1 and motor.Part0 then
            -- Create a BallSocketConstraint or just break the joint
            -- Option A: Simple break (most games let this replicate)
            motor.Enabled = false
            
            -- Option B: Replace with BallSocket + NoCollision for flying parts (more dramatic)
            local socket = Instance.new("BallSocketConstraint")
            socket.Attachment0 = Instance.new("Attachment", motor.Part0)
            socket.Attachment1 = Instance.new("Attachment", motor.Part1)
            socket.LimitsEnabled = false
            socket.Parent = motor.Part0
            
            -- Optional: Give random velocity to make limbs fly farther
            if motor.Part1:IsA("BasePart") then
                motor.Part1.Velocity = Vector3.new(
                    math.random(-80,80),
                    math.random(60,140),
                    math.random(-80,80)
                )
                motor.Part1.RotVelocity = Vector3.new(
                    math.random(-10,10),
                    math.random(-10,10),
                    math.random(-10,10)
                )
            end
        end
    end
    
    -- Step 4: Extra ragdoll physics boost (makes body flop/scatter more)
    if root then
        root.Velocity = Vector3.new(0, 80, 0)  -- upward kick
        root.AssemblyLinearVelocity = Vector3.new(
            math.random(-60,60),
            math.random(40,100),
            math.random(-60,60)
        )
    end
    
    -- Optional: Hide head or make dramatic (some games detect head removal)
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0.3  -- slight fade or leave visible
        head.Velocity = Vector3.new(math.random(-50,50), 100, math.random(-50,50))
    end
    
    notify("💥 Exploded! Limbs detached & scattered", Color3.fromRGB(255, 60, 60))
end
------------------------------------------------
-- advanced tiny mode
------------------------------------------------
local function tiny(plr)
    if plr ~= client then
        notify("❌ Tiny only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    local hum = getHum(plr)
    if hum then
        for _, scaleName in ipairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do
            local scale = hum:FindFirstChild(scaleName)
            if scale then scale.Value = 0.3 end
        end
        notify("🐜 Tiny mode!", Color3.fromRGB(100, 200, 255))
    end
end
------------------------------------------------
-- advanced rainbow
------------------------------------------------
local function rainbow(plr)
    if plr ~= client then
        notify("❌ Rainbow only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if rainbowData[plr] then 
        notify("⚠️ Already rainbow", Color3.fromRGB(255, 200, 100))
        return 
    end
    local char = plr.Character
    if not char then 
        notify("❌ No character for rainbow", Color3.fromRGB(255, 100, 100))
        return 
    end
	local conn = RunService.Heartbeat:Connect(function()
        local hue = tick() % 5 / 5
        local c = Color3.fromHSV(hue, 1, 1)
        for _, part in char:GetDescendants() do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Color = c
            end
        end
    end)
    rainbowData[plr] = conn
    notify("🌈 Rainbow ON", Color3.fromRGB(255, 100, 255))
end
------------------------------------------------
-- advanced unrainbow
------------------------------------------------
local function unrainbow(plr)
    if plr ~= client then
        notify("❌ Unrainbow only works on yourself", Color3.fromRGB(255, 100, 100))
        return
    end
    if rainbowData[plr] then
        rainbowData[plr]:Disconnect()
        rainbowData[plr] = nil
        notify("✅ Rainbow OFF", Color3.fromRGB(200, 100, 200))
    else
        notify("⚠️ Not in rainbow mode", Color3.fromRGB(255, 200, 100))
    end
end
------------------------------------------------
-- advanced fire
------------------------------------------------
local function fire(plr)
    local hrp = getHRP(plr)
    if hrp and not hrp:FindFirstChild("Fire") then
        local f = Instance.new("Fire", hrp)
        f.Size = 10
        f.Heat = 25
        notify("🔥 On fire!", Color3.fromRGB(255, 100, 0))
    else
        notify("⚠️ Already on fire or no character", Color3.fromRGB(255, 200, 100))
    end
end
------------------------------------------------
-- advanced unfire
------------------------------------------------
local function unfire(plr)
    local hrp = getHRP(plr)
    if hrp then
        local f = hrp:FindFirstChild("Fire")
        if f then 
            f:Destroy() 
            notify("✅ Fire off", Color3.fromRGB(200, 100, 0))
        else
            notify("⚠️ Not on fire", Color3.fromRGB(255, 200, 100))
        end
    end
end
------------------------------------------------
-- advanced first person/thrid person
------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local client = Players.LocalPlayer  -- assuming 'client' is LocalPlayer in your script

local function thirdp()
    -- Step 1: Switch to Classic mode (allows zooming)
    client.CameraMode = Enum.CameraMode.Classic
    
    -- Step 2: Temporarily force a zoom-out to exit first person reliably
    -- (Roblox camera won't exit FP just by setting Classic if already zoomed in)
    local originalMinZoom = client.CameraMinZoomDistance
    client.CameraMinZoomDistance = 10  -- or higher, forces zoom out
    client.CameraMaxZoomDistance = 400
    
    -- Wait one frame so the camera module processes the change and zooms out
    RunService.RenderStepped:Wait()  -- or task.wait(0.03) if you prefer
    
    -- Step 3: Restore normal min zoom (so player can zoom in again if they want)
    client.CameraMinZoomDistance = originalMinZoom  -- or set to 0.5 if you want tight zoom allowed
    
    -- Step 4: Fix "invisible to self" glitch
    -- Roblox sets LocalTransparencyModifier = 1 on parts in FP; doesn't always reset
    local character = client.Character
    if character then
        for _, obj in ipairs(character:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                obj.LocalTransparencyModifier = 0
            end
        end
        
        -- Optional: If head/face is still hidden, force it visible too
        local head = character:FindFirstChild("Head")
        if head then
            head.LocalTransparencyModifier = 0
        end
    end
    
    -- Optional: Re-focus camera on your humanoid to snap back cleanly
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        workspace.CurrentCamera.CameraSubject = humanoid
    end
    
    notify("✅ Third person enabled (forced zoom out + visibility fix)", currentTheme.accent)
end

local function firstp()
    client.CameraMode = Enum.CameraMode.LockFirstPerson
    notify("✅ First person enabled", currentTheme.accent)
end
------------------------------------------------
-- advanced Waypoint
------------------------------------------------
local function waypoint()
    local num = #waypoints + 1
    local wp = Instance.new("Part")
    wp.Size = Vector3.new(1,1,1)
    wp.Transparency = 1
    wp.Anchored = true
    wp.CanCollide = false
    wp.Position = hrp.Position + Vector3.new(0, 5, 0)
    wp.Parent = workspace
    local bb = Instance.new("BillboardGui")
    bb.Adornee = wp
    bb.Size = UDim2.new(0, 100, 0, 100)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = wp
    local symbol = Instance.new("TextLabel", bb)
    symbol.Size = UDim2.new(1,0,0.5,0)
    symbol.BackgroundTransparency = 1
    symbol.Text = "★"
    symbol.Font = Enum.Font.GothamBlack
    symbol.TextSize = 40
    symbol.TextColor3 = Color3.new(1,1,1)
    symbol.TextStrokeTransparency = 0
    symbol.TextStrokeColor3 = Color3.new(0,0,0)
    local distLabel = Instance.new("TextLabel", bb)
    distLabel.Size = UDim2.new(1,0,0.5,0)
    distLabel.Position = UDim2.new(0,0,0.5,0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0 studs"
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 18
    distLabel.TextColor3 = Color3.new(1,1,1)
    distLabel.TextStrokeTransparency = 0.5
    local conn = RunService.Heartbeat:Connect(function()
        if not wp.Parent then conn:Disconnect() return end
        local dist = (hrp.Position - wp.Position).Magnitude
        distLabel.Text = math.floor(dist) .. " studs"
    end)
    table.insert(waypoints, {part = wp, conn = conn})
    notify("📍 Waypoint #" .. num .. " added", currentTheme.accent)
end

------------------------------------------------
-- advanced tracers
------------------------------------------------
local Players = game:GetService("Players")

local tracerSystem = {
    enabled = false,
    players = {},
    connections = {}
}

----------------------------------------------------
-- GET YOUR HRP
----------------------------------------------------
local function getMyHRP()
    if client.Character then
        return client.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

----------------------------------------------------
-- TEAM COLOR LOGIC
----------------------------------------------------
local function getTracerColor(plr)
    if not client.Team or not plr.Team then
        return Color3.new(1,1,1) -- white if no team
    end

    if plr.Team == client.Team then
        return Color3.fromRGB(0,255,0) -- friendly
    else
        return Color3.fromRGB(255,0,0) -- enemy
    end
end

----------------------------------------------------
-- CLEAR ONE PLAYER TRACER
----------------------------------------------------
local function clearPlayer(plr)
    local data = tracerSystem.players[plr]
    if not data then return end

    if data.beam then data.beam:Destroy() end
    if data.att0 then data.att0:Destroy() end
    if data.att1 then data.att1:Destroy() end

    for _,conn in ipairs(data.connections) do
        conn:Disconnect()
    end

    tracerSystem.players[plr] = nil
end

----------------------------------------------------
-- ATTACH TRACER
----------------------------------------------------
local function attachTracer(plr, char)

    if not tracerSystem.enabled then return end
    if plr == client then return end

    local myHRP = getMyHRP()
    if not myHRP then return end

    local enemyHRP = char:WaitForChild("HumanoidRootPart",10)
    if not enemyHRP then return end

    clearPlayer(plr)

    local data = { connections = {} }
    tracerSystem.players[plr] = data

    local beam = Instance.new("Beam")
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.Transparency = NumberSequence.new(0.3)
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(getTracerColor(plr))

    local att0 = Instance.new("Attachment")
    att0.Parent = myHRP

    local att1 = Instance.new("Attachment")
    att1.Parent = enemyHRP

    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Parent = workspace

    data.beam = beam
    data.att0 = att0
    data.att1 = att1

    -- Update color if THEY change team
    table.insert(data.connections,
        plr:GetPropertyChangedSignal("Team"):Connect(function()
            if beam then
                beam.Color = ColorSequence.new(getTracerColor(plr))
            end
        end)
    )

    -- Update color if YOU change team
    table.insert(data.connections,
        client:GetPropertyChangedSignal("Team"):Connect(function()
            if beam then
                beam.Color = ColorSequence.new(getTracerColor(plr))
            end
        end)
    )

    -- Reattach if THEY respawn
    table.insert(data.connections,
        plr.CharacterAdded:Connect(function(newChar)
            task.wait(0.2)
            attachTracer(plr, newChar)
        end)
    )
end

----------------------------------------------------
-- CREATE FOR PLAYER
----------------------------------------------------
local function createForPlayer(plr)
    if plr == client then return end
    if tracerSystem.players[plr] then return end

    if plr.Character then
        attachTracer(plr, plr.Character)
    end
end

----------------------------------------------------
-- ENABLE
----------------------------------------------------
function enableTracers()

    if tracerSystem.enabled then return end
    tracerSystem.enabled = true

    -- existing players
    for _,plr in ipairs(Players:GetPlayers()) do
        createForPlayer(plr)
    end

    -- new players
    table.insert(tracerSystem.connections,
        Players.PlayerAdded:Connect(function(plr)
            if tracerSystem.enabled then
                createForPlayer(plr)
            end
        end)
    )

    -- cleanup on leave
    table.insert(tracerSystem.connections,
        Players.PlayerRemoving:Connect(function(plr)
            clearPlayer(plr)
        end)
    )

    -- YOU respawn → rebuild all
    table.insert(tracerSystem.connections,
        client.CharacterAdded:Connect(function()
            task.wait(0.3)

            for plr,_ in pairs(tracerSystem.players) do
                clearPlayer(plr)
            end

            for _,plr in ipairs(Players:GetPlayers()) do
                createForPlayer(plr)
            end
        end)
    )

    notify("✅ Tracers enabled", currentTheme.accent)
end

----------------------------------------------------
-- DISABLE
----------------------------------------------------
function disableTracers()

    if not tracerSystem.enabled then return end
    tracerSystem.enabled = false

    for _,conn in ipairs(tracerSystem.connections) do
        conn:Disconnect()
    end
    tracerSystem.connections = {}

    for plr,_ in pairs(tracerSystem.players) do
        clearPlayer(plr)
    end

    tracerSystem.players = {}

    notify("❌ Tracers disabled", currentTheme.accent)
end
----------------------------------------------------
-- advanced Disable tracers
------------------------------------------------
local function disableTracers()
    tracersEnabled = false
    clearTracers()
    notify("❌ Tracers disabled", currentTheme.accent)
end

-- =============================================================
-- COMMAND PROCESSOR - DEFINED BEFORE USE
-- =============================================================
function processCmd(msg)
    if not msg or msg:sub(1,1) ~= prefix then return end
    local args = {}
    for word in msg:sub(2):gmatch("%S+") do
        table.insert(args, word)
    end
    local cmd = table.remove(args, 1):lower()
    
    notify(prefix .. cmd, Color3.fromRGB(180, 180, 255))
    local target = getPlr(args[1] or "me")
    
    if cmd == "aimbot" then 
        createAimbotPanel()
    elseif cmd == "bring" then 
        bring(target)
    elseif cmd == "clicktp" then 
        clickTP()
    elseif cmd == "cmdbar" then
        toggleCmdBar()
    elseif cmd == "console" then 
        console()
    elseif cmd == "dance" then 
        dance(target)
    elseif cmd == "destroyscript" then
        destroyScript()
    elseif cmd == "disablefalldamage" then 
        disableFallDamage()
    elseif cmd == "enable" then
        local what = args[1] or ""
        if what == "inventory" or what == "playerlist" then
            enableCore(what)
        end
    elseif cmd == "esp" then
        if args[1] == "all" then 
            enableESPAll()
        else 
            notify("⚠️ Use !esp all for enhanced ESP", Color3.fromRGB(255, 200, 100))
        end
    elseif cmd == "unesp" then
        if args[1] == "all" then 
            disableESPAll()
        else 
            notify("⚠️ Use !unesp all to disable", Color3.fromRGB(255, 200, 100))
        end
    elseif cmd == "explode" then 
        explode(target)
    elseif cmd == "fire" then 
        fire(target)
    elseif cmd == "unfire" then 
        unfire(target)
    elseif cmd == "firstp" then 
        firstp()
    elseif cmd == "fling" then 
        fling(target)
    elseif cmd == "fly" then 
        fly(target, args[2])
    elseif cmd == "unfly" then 
        unfly(target)
    elseif cmd == "freecam" then 
        enableFreecam()
    elseif cmd == "unfreecam" then 
        disableFreecam()
    elseif cmd == "freeze" then 
        freeze(target)
    elseif cmd == "unfreeze" then 
        unfreeze(target)
    elseif cmd == "giant" then 
        giant(target)
    elseif cmd == "tiny" then 
        tiny(target)
    elseif cmd == "god" then 
        god(target)
    elseif cmd == "ungod" then 
        ungod(target)
    elseif cmd == "heal" then 
        heal(target)
    elseif cmd == "invis" then 
        invisP(target)
    elseif cmd == "vis" then 
        visP(target)
    elseif cmd == "joinlogs" then
        createJoinLogsPanel()
    elseif cmd == "jump" then 
        jump(client, args[1])
    elseif cmd == "kill" then
        if args[1] == "all" then 
            for _, p in ipairs(Players:GetPlayers()) do kill(p) end
        elseif args[1] == "me" then 
            kill(client)
        else 
            kill(target) 
        end
    elseif cmd == "lay" then 
        lay(client)
    elseif cmd == "leave" then
        leaveGame()
    elseif cmd == "logs" then 
        toggleLogs()
    elseif cmd == "noclip" then 
        noclip(target)
    elseif cmd == "unnoclip" then 
        unnoclip(target)
    elseif cmd == "ping" then 
        ping()
    elseif cmd == "ragdoll" then 
        ragdoll(client)
    elseif cmd == "unragdoll" then 
        unragdoll(client)
    elseif cmd == "rainbow" then 
        rainbow(target)
    elseif cmd == "unrainbow" then 
        unrainbow(target)
    elseif cmd == "rejoin" then 
        rejoin()
    elseif cmd == "removewaypoint" then 
        removeWaypoint()
    elseif cmd == "resetspeed" then 
        resetspeed(target)
    elseif cmd == "sit" then 
        sit(client)
    elseif cmd == "speed" then 
        if args[1] == "me" then
            createSpeedPanel()
        else
            setspeed(target, args[2])
        end
    elseif cmd == "spin" then 
        spin(client, args[1])
    elseif cmd == "unspin" then 
        unspin(client)
    elseif cmd == "stopwatch" then 
        toggleStopwatch()
    elseif cmd == "thirdp" then 
        thirdp()
    elseif cmd == "to" then 
        gotoMe(target)
    elseif cmd == "tp" then 
        tp(client, getPlr(args[2] or "me"))
    elseif cmd == "trip" then 
        trip(target)
    elseif cmd == "tracers" then 
        enableTracers()
    elseif cmd == "untracers" then 
        disableTracers()
    elseif cmd == "view" then 
        view(target)
    elseif cmd == "unview" then 
        unview()
    elseif cmd == "waypoint" then 
        waypoint()
    elseif cmd == "fov" then 
        setFov(args[1])
    elseif cmd == "kick" then 
        kick(target)
    elseif cmd == "unlockmouse" then
        toggleMouseUnlock()
    else
        notify("❌ Unknown command: " .. cmd, Color3.fromRGB(255, 100, 100))
    end
end

-- =============================================================
-- MAIN GUI - SOLID TEXT
-- =============================================================
lunarGui = Instance.new("ScreenGui")
lunarGui.Name = "LunarGui"
lunarGui.ResetOnSpawn = false
lunarGui.Enabled = false
lunarGui.DisplayOrder = 999999
lunarGui.Parent = client.PlayerGui

mainFrame = Instance.new("Frame", lunarGui)
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(1, -420, 0.5, -300)
mainFrame.BackgroundColor3 = currentTheme.glass
mainFrame.Active = true
mainFrame.Draggable = true
applyGlassEffect(mainFrame, globalConfig.uiTransparency, globalConfig.strokeTransparency)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "Lunar Hub"
title.Font = Enum.Font.GothamBlack
title.TextSize = 32
title.TextColor3 = currentTheme.accent
title.TextTransparency = 0 -- SOLID
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.new(0,0,0)

-- Tabs
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, -20, 0, 50)
tabBar.Position = UDim2.new(0, 10, 0, 70)
tabBar.BackgroundTransparency = 1

local cmdTab = Instance.new("TextButton", tabBar)
cmdTab.Size = UDim2.new(0.5, -5, 1, 0)
cmdTab.BackgroundColor3 = currentTheme.accent
cmdTab.Text = "Commands"
cmdTab.Font = Enum.Font.GothamBold
cmdTab.TextSize = 18
cmdTab.TextColor3 = Color3.new(0,0,0)
cmdTab.TextTransparency = 0 -- SOLID
cmdTab.TextStrokeTransparency = 0.5
cmdTab.TextStrokeColor3 = Color3.new(1,1,1)
applyGlassEffect(cmdTab, 0.2, 0.4)

local settingsTab = Instance.new("TextButton", tabBar)
settingsTab.Size = UDim2.new(0.5, -5, 1, 0)
settingsTab.Position = UDim2.new(0.5, 5, 0, 0)
settingsTab.BackgroundColor3 = currentTheme.btn
settingsTab.Text = "Settings"
settingsTab.Font = Enum.Font.GothamBold
settingsTab.TextSize = 18
settingsTab.TextColor3 = globalConfig.textColor
settingsTab.TextTransparency = 0 -- SOLID
settingsTab.TextStrokeTransparency = 0.5
settingsTab.TextStrokeColor3 = Color3.new(0,0,0)
applyGlassEffect(settingsTab, 0.2, 0.5)

-- Commands tab
local cmdFrame = Instance.new("Frame", mainFrame)
cmdFrame.Size = UDim2.new(1, -20, 1, -130)
cmdFrame.Position = UDim2.new(0, 10, 0, 130)
cmdFrame.BackgroundTransparency = 1

local search = Instance.new("TextBox", cmdFrame)
search.Size = UDim2.new(1, 0, 0, 40)
search.BackgroundColor3 = currentTheme.list
search.PlaceholderText = "Search commands..."
search.Font = Enum.Font.Gotham
search.TextSize = 16
search.TextColor3 = globalConfig.textColor
search.TextTransparency = 0 -- SOLID
search.TextStrokeTransparency = 0.5
search.TextStrokeColor3 = Color3.new(0,0,0)
applyGlassEffect(search, 0.3, 0.6)

local scroll = Instance.new("ScrollingFrame", cmdFrame)
scroll.Size = UDim2.new(1, 0, 1, -50)
scroll.Position = UDim2.new(0, 0, 0, 50)
scroll.BackgroundTransparency = 0.3
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = currentTheme.accent
applyGlassEffect(scroll, 0.4, 0.7)

local uiList = Instance.new("UIListLayout", scroll)
uiList.Padding = UDim.new(0, 8)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

-- Command descriptions for hover tooltips
local commandDescriptions = {
    ["!aimbot"] = "Opens aimbot control panel with FOV and smoothness settings",
    ["!bring [plr]"] = "Attempt to bring player to you (client-side limited)",
    ["!clicktp"] = "Toggle click teleport - click anywhere to teleport",
    ["!cmdbar"] = "Toggle command bar with autocomplete",
    ["!console"] = "Opens Roblox developer console",
    ["!dance [plr]"] = "Makes player dance",
    ["!destroyscript"] = "Removes all UI and stops all scripts",
    ["!disablefalldamage"] = "Disables fall damage on respawn",
    ["!enable inventory"] = "Toggle backpack visibility",
    ["!enable playerlist"] = "Toggle player list visibility",
    ["!esp all"] = "Enable ESP on all players with team colors and names",
    ["!unesp all"] = "Disable ESP on all players",
    ["!explode [plr]"] = "Creates explosion at player position",
    ["!fire [plr]"] = "Sets player on fire",
    ["!unfire [plr]"] = "Extinguishes player",
    ["!firstp"] = "Enable first person mode",
    ["!fling [plr]"] = "Flings player randomly",
    ["!fly [plr] [speed]"] = "Enables flying with optional speed",
    ["!unfly [plr]"] = "Disables flying",
    ["!freecam"] = "Enables free camera mouse control",
    ["!unfreecam"] = "Disables free camera",
    ["!freeze [plr]"] = "Freezes player in place",
    ["!unfreeze [plr]"] = "Unfreezes player",
    ["!giant [plr]"] = "Makes player giant sized",
    ["!tiny [plr]"] = "Makes player tiny",
    ["!god [plr]"] = "Enables god mode (no damage)",
    ["!ungod [plr]"] = "Disables god mode",
    ["!heal [plr]"] = "Restores player health to max",
    ["!invis [plr]"] = "Makes player invisible",
    ["!vis [plr]"] = "Makes player visible",
    ["!joinlogs"] = "Opens panel showing player joins/leaves",
    ["!jump [power]"] = "Sets jump power",
    ["!kill [plr/all/me]"] = "Kills specified player(s)",
    ["!lay"] = "Makes character lay down",
    ["!leave"] = "Force leaves the game",
    ["!logs"] = "Opens chat logs panel",
    ["!noclip [plr]"] = "Enables walking through walls",
    ["!unnoclip [plr]"] = "Disables noclip",
    ["!ping"] = "Shows current ping",
    ["!ragdoll"] = "Makes character ragdoll",
    ["!unragdoll"] = "Stops ragdoll",
    ["!rainbow [plr]"] = "Makes player cycle through colors",
    ["!unrainbow [plr]"] = "Stops rainbow effect",
    ["!rejoin"] = "Rejoins current server",
    ["!removewaypoint"] = "Removes last placed waypoint",
    ["!resetspeed [plr]"] = "Resets walkspeed to default",
    ["!sit"] = "Makes character sit",
    ["!speed [plr] [num]"] = "Opens speed panel or sets walkspeed",
    ["!spin [speed]"] = "Spins character in place",
    ["!unspin"] = "Stops spinning",
    ["!stopwatch"] = "Opens stopwatch panel",
    ["!thirdp"] = "Enable third person mode",
    ["!to [plr]"] = "Teleport to player",
    ["!tp [p1] [p2]"] = "Teleport p1 to p2",
    ["!trip [plr]"] = "Makes player trip",
    ["!tracers"] = "Shows lines to all players",
    ["!untracers"] = "Hides tracers",
    ["!unlockmouse"] = "Toggle F key to unlock/lock mouse in FPS games",
    ["!view [plr]"] = "Spectate player (free look enabled)",
    ["!unview"] = "Stop spectating",
    ["!waypoint"] = "Creates waypoint at current position",
    ["!fov [1-120]"] = "Sets camera field of view",
    ["!kick [plr]"] = "Kicks player from game"
}

-- Alphabetical command list
local cmds = {
    "!aimbot", "!bring [plr]", "!clicktp", "!cmdbar", "!console", "!dance [plr]",
    "!destroyscript", "!disablefalldamage", "!enable inventory", "!enable playerlist",
    "!esp all", "!unesp all", "!explode [plr]", "!fire [plr]", "!unfire [plr]",
    "!firstp", "!fling [plr]", "!fly [plr] [speed]", "!unfly [plr]", "!freecam",
    "!unfreecam", "!freeze [plr]", "!unfreeze [plr]", "!giant [plr]", "!tiny [plr]",
    "!god [plr]", "!ungod [plr]", "!heal [plr]", "!invis [plr]", "!vis [plr]",
    "!joinlogs", "!jump [power]", "!kill [plr/all/me]", "!lay", "!leave", "!logs",
    "!noclip [plr]", "!unnoclip [plr]", "!ping", "!ragdoll", "!unragdoll",
    "!rainbow [plr]", "!unrainbow [plr]", "!rejoin", "!removewaypoint",
    "!resetspeed [plr]", "!sit", "!speed [plr] [num]", "!spin [speed]", "!unspin",
    "!stopwatch", "!thirdp", "!to [plr]", "!tp [p1] [p2]", "!trip [plr]",
    "!tracers", "!untracers", "!unlockmouse", "!view [plr]", "!unview", "!waypoint",
    "!fov [1-120]", "!kick [plr]"
}

for i, cmdStr in ipairs(cmds) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 44)
    btn.BackgroundColor3 = currentTheme.list
    btn.BackgroundTransparency = 0.2
    btn.Text = " " .. cmdStr
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.TextColor3 = globalConfig.textColor
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextTransparency = 0 -- SOLID
    btn.TextStrokeTransparency = 0.5
    btn.TextStrokeColor3 = Color3.new(0,0,0)
    applyGlassEffect(btn, 0.4, 0.7)
    btn.Parent = scroll
    btn.LayoutOrder = i
    
    local desc = commandDescriptions[cmdStr]
    if desc then
        btn.MouseEnter:Connect(function()
            btn.Text = " " .. cmdStr .. " - " .. desc
            btn.TextColor3 = currentTheme.accent
        end)
        btn.MouseLeave:Connect(function()
            btn.Text = " " .. cmdStr
            btn.TextColor3 = globalConfig.textColor
        end)
    end
    
    btn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(cmdStr)
            notify("✅ Copied: " .. cmdStr, Color3.fromRGB(100, 255, 100))
        end
    end)
end

scroll.CanvasSize = UDim2.new(0,0,0, #cmds * 52)
search:GetPropertyChangedSignal("Text"):Connect(function()
    local filter = search.Text:lower()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child.Visible = filter == "" or child.Text:lower():find(filter, 1, true)
        end
    end
end)

-- Settings tab
local settingsFrame = Instance.new("Frame", mainFrame)
settingsFrame.Size = UDim2.new(1, -20, 1, -130)
settingsFrame.Position = UDim2.new(0, 10, 0, 130)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Visible = false

local settingsScroll = Instance.new("ScrollingFrame", settingsFrame)
settingsScroll.Size = UDim2.new(1, 0, 1, 0)
settingsScroll.BackgroundTransparency = 0.3
settingsScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
settingsScroll.ScrollBarThickness = 8
settingsScroll.ScrollBarImageColor3 = currentTheme.accent
applyGlassEffect(settingsScroll, 0.4, 0.7)

local settingsList = Instance.new("UIListLayout", settingsScroll)
settingsList.Padding = UDim.new(0, 15)
settingsList.SortOrder = Enum.SortOrder.LayoutOrder

-- Prefix Section
local prefixSection = Instance.new("Frame", settingsScroll)
prefixSection.Size = UDim2.new(1, -20, 0, 100)
prefixSection.BackgroundColor3 = currentTheme.btn
prefixSection.BackgroundTransparency = 0.3
applyGlassEffect(prefixSection, 0.3, 0.6)

local prefixTitle = Instance.new("TextLabel", prefixSection)
prefixTitle.Size = UDim2.new(1, 0, 0, 30)
prefixTitle.Position = UDim2.new(0, 0, 0, 5)
prefixTitle.BackgroundTransparency = 1
prefixTitle.Text = "COMMAND PREFIX"
prefixTitle.Font = Enum.Font.GothamBlack
prefixTitle.TextSize = 18
prefixTitle.TextColor3 = currentTheme.accent
prefixTitle.TextTransparency = 0 -- SOLID
prefixTitle.TextStrokeTransparency = 0.5
prefixTitle.TextStrokeColor3 = Color3.new(0,0,0)

local prefixInput = Instance.new("TextBox", prefixSection)
prefixInput.Size = UDim2.new(0.8, 0, 0, 40)
prefixInput.Position = UDim2.new(0.1, 0, 0, 45)
prefixInput.BackgroundColor3 = currentTheme.list
prefixInput.Text = prefix
prefixInput.Font = Enum.Font.GothamBold
prefixInput.TextSize = 20
prefixInput.TextColor3 = globalConfig.textColor
prefixInput.TextTransparency = 0 -- SOLID
prefixInput.TextStrokeTransparency = 0.5
prefixInput.TextStrokeColor3 = Color3.new(0,0,0)
applyGlassEffect(prefixInput, 0.25, 0.5)

prefixInput.FocusLost:Connect(function(enter)
    if enter then
        prefix = prefixInput.Text ~= "" and prefixInput.Text or "!"
        notify("✅ Prefix changed to: " .. prefix, currentTheme.accent)
    end
end)

-- Text Color Section
local colorSection = Instance.new("Frame", settingsScroll)
colorSection.Size = UDim2.new(1, -20, 0, 150)
colorSection.BackgroundColor3 = currentTheme.btn
colorSection.BackgroundTransparency = 0.3
applyGlassEffect(colorSection, 0.3, 0.6)

local colorTitle = Instance.new("TextLabel", colorSection)
colorTitle.Size = UDim2.new(1, 0, 0, 30)
colorTitle.Position = UDim2.new(0, 0, 0, 5)
colorTitle.BackgroundTransparency = 1
colorTitle.Text = "TEXT COLOR"
colorTitle.Font = Enum.Font.GothamBlack
colorTitle.TextSize = 18
colorTitle.TextColor3 = currentTheme.accent
colorTitle.TextTransparency = 0 -- SOLID
colorTitle.TextStrokeTransparency = 0.5
colorTitle.TextStrokeColor3 = Color3.new(0,0,0)

local colorDisplay = Instance.new("TextLabel", colorSection)
colorDisplay.Size = UDim2.new(0.8, 0, 0, 30)
colorDisplay.Position = UDim2.new(0.1, 0, 0, 40)
colorDisplay.BackgroundColor3 = globalConfig.textColor
colorDisplay.Text = "Preview Text"
colorDisplay.Font = Enum.Font.GothamBold
colorDisplay.TextSize = 16
colorDisplay.TextColor3 = Color3.new(0,0,0)
colorDisplay.TextTransparency = 0 -- SOLID
colorDisplay.TextStrokeTransparency = 0.5
colorDisplay.TextStrokeColor3 = Color3.new(1,1,1)
applyGlassEffect(colorDisplay, 0, 0.4)

-- RGB Sliders
local rSlider = Instance.new("Frame", colorSection)
rSlider.Size = UDim2.new(0.8, 0, 0, 8)
rSlider.Position = UDim2.new(0.1, 0, 0, 80)
rSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
applyGlassEffect(rSlider, 0.3, 0.7)

local rFill = Instance.new("Frame", rSlider)
rFill.Size = UDim2.new(globalConfig.textColor.R, 0, 1, 0)
rFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
rFill.BorderSizePixel = 0
Instance.new("UICorner", rFill).CornerRadius = UDim.new(0, 4)

local gSlider = Instance.new("Frame", colorSection)
gSlider.Size = UDim2.new(0.8, 0, 0, 8)
gSlider.Position = UDim2.new(0.1, 0, 0, 95)
gSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
applyGlassEffect(gSlider, 0.3, 0.7)

local gFill = Instance.new("Frame", gSlider)
gFill.Size = UDim2.new(globalConfig.textColor.G, 0, 1, 0)
gFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
gFill.BorderSizePixel = 0
Instance.new("UICorner", gFill).CornerRadius = UDim.new(0, 4)

local bSlider = Instance.new("Frame", colorSection)
bSlider.Size = UDim2.new(0.8, 0, 0, 8)
bSlider.Position = UDim2.new(0.1, 0, 0, 110)
bSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
applyGlassEffect(bSlider, 0.3, 0.7)

local bFill = Instance.new("Frame", bSlider)
bFill.Size = UDim2.new(globalConfig.textColor.B, 0, 1, 0)
bFill.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
bFill.BorderSizePixel = 0
Instance.new("UICorner", bFill).CornerRadius = UDim.new(0, 4)

local function setupColorSlider(slider, fill, colorComponent)
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            
            local newColor = Color3.new(
                colorComponent == "R" and pos or globalConfig.textColor.R,
                colorComponent == "G" and pos or globalConfig.textColor.G,
                colorComponent == "B" and pos or globalConfig.textColor.B
            )
            globalConfig.textColor = newColor
            colorDisplay.BackgroundColor3 = newColor
            
            -- Update all text elements in LunarGui
            if lunarGui then
                for _, obj in ipairs(lunarGui:GetDescendants()) do
                    if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.TextColor3 ~= currentTheme.accent then
                        obj.TextColor3 = newColor
                    end
                end
            end
        end
    end)
end

setupColorSlider(rSlider, rFill, "R")
setupColorSlider(gSlider, gFill, "G")
setupColorSlider(bSlider, bFill, "B")

-- Transparency Section - FIXED
local transSection = Instance.new("Frame", settingsScroll)
transSection.Size = UDim2.new(1, -20, 0, 100)
transSection.BackgroundColor3 = currentTheme.btn
transSection.BackgroundTransparency = 0.3
applyGlassEffect(transSection, 0.3, 0.6)

local transTitle = Instance.new("TextLabel", transSection)
transTitle.Size = UDim2.new(1, 0, 0, 30)
transTitle.Position = UDim2.new(0, 0, 0, 5)
transTitle.BackgroundTransparency = 1
transTitle.Text = "UI TRANSPARENCY"
transTitle.Font = Enum.Font.GothamBlack
transTitle.TextSize = 18
transTitle.TextColor3 = currentTheme.accent
transTitle.TextTransparency = 0 -- SOLID
transTitle.TextStrokeTransparency = 0.5
transTitle.TextStrokeColor3 = Color3.new(0,0,0)

local transLabel = Instance.new("TextLabel", transSection)
transLabel.Size = UDim2.new(1, 0, 0, 25)
transLabel.Position = UDim2.new(0, 0, 0, 35)
transLabel.BackgroundTransparency = 1
transLabel.Text = "Transparency: " .. math.round(globalConfig.uiTransparency * 100) .. "%"
transLabel.Font = Enum.Font.GothamBold
transLabel.TextSize = 16
transLabel.TextColor3 = globalConfig.textColor
transLabel.TextTransparency = 0 -- SOLID
transLabel.TextStrokeTransparency = 0.5
transLabel.TextStrokeColor3 = Color3.new(0,0,0)

local transSlider = Instance.new("Frame", transSection)
transSlider.Size = UDim2.new(0.8, 0, 0, 12)
transSlider.Position = UDim2.new(0.1, 0, 0, 65)
transSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
applyGlassEffect(transSlider, 0.3, 0.7)

local transFill = Instance.new("Frame", transSlider)
transFill.Size = UDim2.new(globalConfig.uiTransparency, 0, 1, 0)
transFill.BackgroundColor3 = currentTheme.accent
transFill.BorderSizePixel = 0
Instance.new("UICorner", transFill).CornerRadius = UDim.new(0, 6)

local transDrag = Instance.new("TextButton", transSlider)
transDrag.Size = UDim2.new(0, 20, 0, 20)
transDrag.Position = UDim2.new(globalConfig.uiTransparency, -10, 0.5, -10)
transDrag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
transDrag.Text = ""
Instance.new("UICorner", transDrag).CornerRadius = UDim.new(1, 0)

local draggingTrans = false
transDrag.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingTrans = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingTrans = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingTrans and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - transSlider.AbsolutePosition.X) / transSlider.AbsoluteSize.X, 0, 1)
        transFill.Size = UDim2.new(pos, 0, 1, 0)
        transDrag.Position = UDim2.new(pos, -10, 0.5, -10)
        globalConfig.uiTransparency = pos
        transLabel.Text = "Transparency: " .. math.round(pos * 100) .. "%"
        
        -- Update main frame transparency
        if mainFrame then
            mainFrame.BackgroundTransparency = pos
        end
    end
end)

-- Theme Section
local themeSection = Instance.new("Frame", settingsScroll)
themeSection.Size = UDim2.new(1, -20, 0, 200)
themeSection.BackgroundColor3 = currentTheme.btn
themeSection.BackgroundTransparency = 0.3
applyGlassEffect(themeSection, 0.3, 0.6)

local themeTitle = Instance.new("TextLabel", themeSection)
themeTitle.Size = UDim2.new(1, 0, 0, 30)
themeTitle.Position = UDim2.new(0, 0, 0, 5)
themeTitle.BackgroundTransparency = 1
themeTitle.Text = "THEME SELECTOR"
themeTitle.Font = Enum.Font.GothamBlack
themeTitle.TextSize = 18
themeTitle.TextColor3 = currentTheme.accent
themeTitle.TextTransparency = 0 -- SOLID
themeTitle.TextStrokeTransparency = 0.5
themeTitle.TextStrokeColor3 = Color3.new(0,0,0)

local themeContainer = Instance.new("Frame", themeSection)
themeContainer.Size = UDim2.new(1, -20, 0, 140)
themeContainer.Position = UDim2.new(0, 10, 0, 45)
themeContainer.BackgroundTransparency = 1

local themeGrid = Instance.new("UIGridLayout", themeContainer)
themeGrid.CellSize = UDim2.new(0.48, 0, 0, 50)
themeGrid.CellPadding = UDim2.new(0, 10, 0, 10)

for name, th in pairs(themes) do
    local btn = Instance.new("TextButton", themeContainer)
    btn.BackgroundColor3 = th.accent
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = th.text
    btn.TextTransparency = 0 -- SOLID
    btn.TextStrokeTransparency = 0.5
    btn.TextStrokeColor3 = Color3.new(0,0,0)
    applyGlassEffect(btn, 0.15, 0.4)
    
    btn.MouseButton1Click:Connect(function()
        currentTheme = th
        mainFrame.BackgroundColor3 = th.glass
        title.TextColor3 = th.accent
        cmdTab.BackgroundColor3 = th.accent
        settingsTab.BackgroundColor3 = th.btn
        search.BackgroundColor3 = th.list
        prefixInput.BackgroundColor3 = th.list
        
        -- Update all UI elements with new theme
        for _, obj in ipairs(lunarGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.TextColor3 == currentTheme.accent then
                obj.TextColor3 = th.accent
            end
        end
        
        notify("✅ Theme changed to " .. name, th.accent)
    end)
end

-- Discord Section
local discordSection = Instance.new("Frame", settingsScroll)
discordSection.Size = UDim2.new(1, -20, 0, 100)
discordSection.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordSection.BackgroundTransparency = 0.2
applyGlassEffect(discordSection, 0.3, 0.6)

local discordTitle = Instance.new("TextLabel", discordSection)
discordTitle.Size = UDim2.new(1, 0, 0, 30)
discordTitle.Position = UDim2.new(0, 0, 0, 5)
discordTitle.BackgroundTransparency = 1
discordTitle.Text = "COMMUNITY"
discordTitle.Font = Enum.Font.GothamBlack
discordTitle.TextSize = 18
discordTitle.TextColor3 = Color3.new(1,1,1)
discordTitle.TextTransparency = 0 -- SOLID
discordTitle.TextStrokeTransparency = 0.5
discordTitle.TextStrokeColor3 = Color3.new(0,0,0)

local discordBtn = Instance.new("TextButton", discordSection)
discordBtn.Size = UDim2.new(0.9, 0, 0, 45)
discordBtn.Position = UDim2.new(0.05, 0, 0, 45)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Join Discord Server"
discordBtn.Font = Enum.Font.GothamBlack
discordBtn.TextSize = 18
discordBtn.TextColor3 = Color3.new(1,1,1)
discordBtn.TextTransparency = 0 -- SOLID
discordBtn.TextStrokeTransparency = 0.5
discordBtn.TextStrokeColor3 = Color3.new(0,0,0)
applyGlassEffect(discordBtn, 0.15, 0.4)

discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/5GeQAXYYcW")
        notify("✅ Discord link copied to clipboard!", Color3.fromRGB(88,101,242))
    else
        notify("❌ Clipboard not supported in this executor", Color3.fromRGB(255,100,100))
    end
end)

settingsScroll.CanvasSize = UDim2.new(0,0,0, 700)

-- Tab switching
cmdTab.MouseButton1Click:Connect(function()
    cmdFrame.Visible = true
    settingsFrame.Visible = false
    cmdTab.BackgroundColor3 = currentTheme.accent
    cmdTab.TextColor3 = Color3.new(0,0,0)
    settingsTab.BackgroundColor3 = currentTheme.btn
    settingsTab.TextColor3 = globalConfig.textColor
end)

settingsTab.MouseButton1Click:Connect(function()
    cmdFrame.Visible = false
    settingsFrame.Visible = true
    settingsTab.BackgroundColor3 = currentTheme.accent
    settingsTab.TextColor3 = Color3.new(0,0,0)
    cmdTab.BackgroundColor3 = currentTheme.btn
    cmdTab.TextColor3 = globalConfig.textColor
end)

-- =============================================================
-- STARTUP
-- =============================================================
lunarGui.Enabled = true
playOpen()
notify("✅ Lunar Admin loaded • RightShift to toggle", Color3.fromRGB(120,220,255))

task.spawn(function()
    task.wait(0.8)
    local wm = Instance.new("ScreenGui")
    wm.ResetOnSpawn = false
    wm.DisplayOrder = 999999
    wm.Parent = client.PlayerGui
    local label = Instance.new("TextLabel", wm)
    label.Size = UDim2.new(0, 320, 0, 40)
    label.Position = UDim2.new(0.5, -160, 0.94, 0)
    label.BackgroundTransparency = 1
    label.Text = "Created By @LunarRbxZ"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 24
    label.TextColor3 = globalConfig.textColor
    label.TextTransparency = 0 -- SOLID
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0,0,0)
    TweenService:Create(label, TweenInfo.new(1.8, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(5.5)
    TweenService:Create(label, TweenInfo.new(1.6), {TextTransparency = 1}):Play()
    task.delay(2, function() wm:Destroy() end)
end)

-- Keybind handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if lunarGui then
            lunarGui.Enabled = not lunarGui.Enabled
            if lunarGui.Enabled then
                playOpen()
            else
                playClose()
            end
        end
    end
end)

-- Chat handler
client.Chatted:Connect(processCmd)
