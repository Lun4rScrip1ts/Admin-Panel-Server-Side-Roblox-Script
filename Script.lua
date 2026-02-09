-- Join my Discord :3 https://discord.gg/5GeQAXYYcW  
-- Created by @LunarRbxZ
-- Working on !Aimbot and other problems

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
end)

-- =============================================================
-- GLASS EFFECT UTILITY
-- =============================================================
local function applyGlassEffect(frame, transparency, strokeTransparency)
    transparency = transparency or 0.15
    strokeTransparency = strokeTransparency or 0.6
    frame.BackgroundTransparency = transparency
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = strokeTransparency
    stroke.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local gradient = Instance.new("UIGradient")
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
    s.SoundId = "rbxassetid://1847661826"
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
-- NOTIFICATIONS
-- =============================================================
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "LunarNotifs"
notifGui.ResetOnSpawn = false
notifGui.Parent = client.PlayerGui

local function notify(text, col)
    col = col or Color3.fromRGB(100, 200, 255)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 320, 0, 70)
    f.Position = UDim2.new(1, -340, 1, -100)
    f.BackgroundColor3 = currentTheme.glass
    f.BorderSizePixel = 0
    f.Parent = notifGui
    applyGlassEffect(f, 0.08, 0.4)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -20, 1, -20)
    lbl.Position = UDim2.new(0, 10, 0, 10)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextStrokeTransparency = 0.9
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.TextWrapped = true
    
    TweenService:Create(f, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -340, 1, -90)
    }):Play()
    task.delay(5, function()
        TweenService:Create(f, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, 50, 1, -90)
        }):Play()
        task.delay(0.7, function() f:Destroy() end)
    end)
end

-- =============================================================
-- VIEW SYSTEM
-- =============================================================
local viewData = {
    enabled = false,
    target = nil,
    originalCFrame = nil,
    originalCameraType = nil,
    freezeConn = nil
}

local function view(plr)
    if viewData.enabled then
        notify("Already viewing someone! Use !unview first", Color3.fromRGB(255, 100, 100))
        return
    end
    
    if not plr or not plr.Character then
        notify("Player not found", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then
        notify("Target has no HumanoidRootPart", Color3.fromRGB(255, 100, 100))
        return
    end
    
    viewData.enabled = true
    viewData.target = plr
    viewData.originalCFrame = workspace.CurrentCamera.CFrame
    viewData.originalCameraType = workspace.CurrentCamera.CameraType
    
    if hum then
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    end
    if hrp then
        hrp.Anchored = true
    end
    
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    
    viewData.freezeConn = RunService.RenderStepped:Connect(function()
        if not viewData.enabled or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        workspace.CurrentCamera.CFrame = CFrame.new(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 10), plr.Character.HumanoidRootPart.Position)
    end)
    
    notify("Now viewing " .. plr.Name, Color3.fromRGB(100, 255, 100))
end

local function unview()
    if not viewData.enabled then
        notify("Not viewing anyone", Color3.fromRGB(255, 100, 100))
        return
    end
    
    viewData.enabled = false
    
    if viewData.freezeConn then
        viewData.freezeConn:Disconnect()
        viewData.freezeConn = nil
    end
    
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    if hrp then
        hrp.Anchored = false
    end
    
    workspace.CurrentCamera.CameraType = viewData.originalCameraType or Enum.CameraType.Custom
    if viewData.originalCFrame then
        workspace.CurrentCamera.CFrame = viewData.originalCFrame
    end
    
    viewData.target = nil
    viewData.originalCFrame = nil
    viewData.originalCameraType = nil
    
    notify("View stopped", Color3.fromRGB(255, 160, 60))
end

-- =============================================================
-- FIXED AIMBOT SYSTEM WITH ALL FEATURES
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
    inputEndedConn = nil
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
    
    aimbotData.enabled = false
    aimbotData.fovEnabled = false
    
    local panel = Instance.new("ScreenGui")
    panel.Name = "AimbotPanel"
    panel.ResetOnSpawn = false
    panel.Parent = client.PlayerGui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 340, 0, 520)
    main.Position = UDim2.new(0, 430, 0.5, -260)
    main.BackgroundColor3 = currentTheme.glass
    main.Active = true
    main.Draggable = true
    main.Parent = panel
    applyGlassEffect(main, 0.08, 0.4)
    
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "AIMBOT CONTROL"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 26
    title.TextColor3 = currentTheme.accent
    title.TextStrokeTransparency = 0.8
    
    -- Toggle Aimbot Button
    local toggleBtn = Instance.new("TextButton", main)
    toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
    toggleBtn.Position = UDim2.new(0.05, 0, 0, 55)
    toggleBtn.BackgroundColor3 = currentTheme.btn
    toggleBtn.Text = "Toggle Aimbot: OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 18
    toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    applyGlassEffect(toggleBtn, 0.2, 0.5)
    
    -- Toggle FOV Button
    local fovBtn = Instance.new("TextButton", main)
    fovBtn.Size = UDim2.new(0.9, 0, 0, 45)
    fovBtn.Position = UDim2.new(0.05, 0, 0, 105)
    fovBtn.BackgroundColor3 = currentTheme.btn
    fovBtn.Text = "Toggle FOV Circle: OFF"
    fovBtn.Font = Enum.Font.GothamBold
    fovBtn.TextSize = 18
    fovBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    applyGlassEffect(fovBtn, 0.2, 0.5)
    
    -- FOV Size Slider
    local fovLabel = Instance.new("TextLabel", main)
    fovLabel.Size = UDim2.new(0.9, 0, 0, 30)
    fovLabel.Position = UDim2.new(0.05, 0, 0, 155)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV Size: 150"
    fovLabel.Font = Enum.Font.GothamBold
    fovLabel.TextSize = 16
    fovLabel.TextColor3 = currentTheme.text
    
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
    
    -- Smoothness Toggle
    local smoothToggleBtn = Instance.new("TextButton", main)
    smoothToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
    smoothToggleBtn.Position = UDim2.new(0.05, 0, 0, 205)
    smoothToggleBtn.BackgroundColor3 = currentTheme.btn
    smoothToggleBtn.Text = "Smoothness: ON"
    smoothToggleBtn.Font = Enum.Font.GothamBold
    smoothToggleBtn.TextSize = 18
    smoothToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    applyGlassEffect(smoothToggleBtn, 0.2, 0.5)
    
    -- Smoothness Slider
    local smoothLabel = Instance.new("TextLabel", main)
    smoothLabel.Size = UDim2.new(0.9, 0, 0, 30)
    smoothLabel.Position = UDim2.new(0.05, 0, 0, 255)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.Text = "Smoothness Amount: 0.5"
    smoothLabel.Font = Enum.Font.GothamBold
    smoothLabel.TextSize = 16
    smoothLabel.TextColor3 = currentTheme.text
    
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
    
    -- Team Check Toggle
    local teamBtn = Instance.new("TextButton", main)
    teamBtn.Size = UDim2.new(0.9, 0, 0, 45)
    teamBtn.Position = UDim2.new(0.05, 0, 0, 305)
    teamBtn.BackgroundColor3 = currentTheme.btn
    teamBtn.Text = "Team Check: OFF"
    teamBtn.Font = Enum.Font.GothamBold
    teamBtn.TextSize = 18
    teamBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    applyGlassEffect(teamBtn, 0.2, 0.5)
    
    -- Wall Check Toggle
    local wallBtn = Instance.new("TextButton", main)
    wallBtn.Size = UDim2.new(0.9, 0, 0, 45)
    wallBtn.Position = UDim2.new(0.05, 0, 0, 355)
    wallBtn.BackgroundColor3 = currentTheme.btn
    wallBtn.Text = "Wall Check: OFF"
    wallBtn.Font = Enum.Font.GothamBold
    wallBtn.TextSize = 18
    wallBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    applyGlassEffect(wallBtn, 0.2, 0.5)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = Color3.new(1,1,1)
    applyGlassEffect(closeBtn, 0.2, 0.4)
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel", main)
    statusLabel.Size = UDim2.new(0.9, 0, 0, 60)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 410)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Hold Right Click to Lock"
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 18
    statusLabel.TextColor3 = currentTheme.accent
    statusLabel.TextWrapped = true
    
    -- Update Functions
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
            if not aimbotData.fovCircle then
                aimbotData.fovCircle = Instance.new("Frame")
                aimbotData.fovCircle.Name = "FOVCircle"
                aimbotData.fovCircle.Size = UDim2.new(0, aimbotData.fovSize * 2, 0, aimbotData.fovSize * 2)
                aimbotData.fovCircle.BackgroundTransparency = 1
                aimbotData.fovCircle.BorderSizePixel = 0
                aimbotData.fovCircle.Parent = panel
                
                local circle = Instance.new("UICorner")
                circle.CornerRadius = UDim.new(1, 0)
                circle.Parent = aimbotData.fovCircle
                
                local stroke = Instance.new("UIStroke")
                stroke.Color = currentTheme.accent
                stroke.Thickness = 3
                stroke.Parent = aimbotData.fovCircle
                
                -- Centered on cursor
                RunService.RenderStepped:Connect(function()
                    if aimbotData.fovCircle and aimbotData.fovCircle.Parent then
                        local mousePos = UserInputService:GetMouseLocation()
                        local size = aimbotData.fovSize * 2
                        aimbotData.fovCircle.Position = UDim2.new(0, mousePos.X - aimbotData.fovSize, 0, mousePos.Y - aimbotData.fovSize)
                        aimbotData.fovCircle.Size = UDim2.new(0, size, 0, size)
                    end
                end)
            else
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
    
    -- Button Connections
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
    
    -- Slider functionality
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
    
    -- Close Button - Proper Cleanup
    closeBtn.MouseButton1Click:Connect(function()
        -- Disable aimbot first
        aimbotData.enabled = false
        aimbotData.fovEnabled = false
        aimbotData.rightClickHeld = false
        
        -- Disconnect all connections
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
        
        -- Destroy UI
        panel:Destroy()
        aimbotData.panel = nil
        aimbotData.fovCircle = nil
        
        notify("Aimbot panel closed", Color3.fromRGB(255, 160, 60))
    end)
    
    aimbotData.panel = panel
    
    -- Aimbot Logic with Team Check and Wall Check
    local function isValidTarget(plr)
        if not plr or plr == client then return false end
        if not plr.Character then return false end
        if not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
        if not plr.Character:FindFirstChild("Humanoid") then return false end
        if plr.Character.Humanoid.Health <= 0 then return false end
        
        -- Team Check
        if aimbotData.teamCheck then
            if client.Team and plr.Team and client.Team == plr.Team then
                return false
            end
        end
        
        -- Wall Check
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
                return false -- Wall in the way
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
    
    -- Aimbot Loop
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
                
                mousemoverel(moveVec.X - mousePos.X, moveVec.Y - mousePos.Y)
            end
        end
    end)
    
    -- Input Connections - Store them
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
    panel.Parent = client.PlayerGui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = size
    main.Position = UDim2.new(0, 430, 0.5, -size.Y.Offset/2)
    main.BackgroundColor3 = currentTheme.glass
    main.Active = true
    main.Draggable = true
    main.Parent = panel
    applyGlassEffect(main, 0.08, 0.4)
    
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, -50, 0, 45)
    title.Position = UDim2.new(0, 15, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextColor3 = currentTheme.accent
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = Color3.new(1,1,1)
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
    entry.TextColor3 = Color3.new(0.95,0.95,1)
    entry.TextSize = 15
    entry.Font = Enum.Font.Gotham
    entry.TextWrapped = true
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
    clearBtn.TextColor3 = currentTheme.text
    applyGlassEffect(clearBtn, 0.25, 0.5)
    
    clearBtn.MouseButton1Click:Connect(function()
        for _, entry in ipairs(logEntries) do
            if entry then entry:Destroy() end
        end
        logEntries = {}
        logsScroll.CanvasSize = UDim2.new(0,0,0,0)
    end)
    
    notify("Logs panel opened", Color3.fromRGB(180,180,255))
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
    applyGlassEffect(startBtn, 0.15, 0.4)
    
    local resetBtn = Instance.new("TextButton", btnFrame)
    resetBtn.Size = UDim2.new(0.48, 0, 1, 0)
    resetBtn.Position = UDim2.new(0.52, 0, 0, 0)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    resetBtn.Text = "RESET"
    resetBtn.Font = Enum.Font.GothamBlack
    resetBtn.TextSize = 22
    resetBtn.TextColor3 = Color3.new(0,0,0)
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
    notify("Stopwatch panel opened", Color3.fromRGB(200, 200, 255))
end

-- =============================================================
-- REMOVE WAYPOINT
-- =============================================================
local function removeWaypoint()
    if #waypoints == 0 then
        notify("No waypoints to remove", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local last = waypoints[#waypoints]
    if last then
        if last.conn then last.conn:Disconnect() end
        if last.part then last.part:Destroy() end
        table.remove(waypoints, #waypoints)
        notify("Removed waypoint #" .. (#waypoints + 1), Color3.fromRGB(255, 160, 60))
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

local function checkSelf(p, cmd)
    if p ~= client then
        notify("Command '" .. cmd .. "' only works on self (client-side limit)", Color3.fromRGB(255, 100, 100))
        return false
    end
    return true
end

-- =============================================================
-- ALL COMMANDS
-- =============================================================
local flyData = {}
local noclipConn
local espTable = {}
local frozen = {}
local gods = {}
local invis = {}
local rainbowData = {}
local ragdolls = {}
local spinData = {}

local function fly(plr, spd)
    if not checkSelf(plr, "fly") then return end
    if flyData[plr] then return end
    spd = tonumber(spd) or 50
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local align = Instance.new("AlignOrientation")
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.MaxTorque = 100000
    align.Responsiveness = 200
    align.Attachment0 = Instance.new("Attachment", hrp)
    align.Parent = hrp
    local linVel = Instance.new("LinearVelocity")
    linVel.MaxForce = 100000
    linVel.VectorVelocity = Vector3.new()
    linVel.Attachment0 = align.Attachment0
    linVel.Parent = hrp
    flyData[plr] = {align = align, linVel = linVel, speed = spd}
    local conn = RunService.RenderStepped:Connect(function()
        if not flyData[plr] then return end
        align.CFrame = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
        linVel.VectorVelocity = moveDir.Unit * spd
    end)
    flyData[plr].conn = conn
    notify("Flying at speed " .. spd, currentTheme.accent)
end

local function unfly(plr)
    if not checkSelf(plr, "unfly") then return end
    local data = flyData[plr]
    if not data then return end
    if data.conn then data.conn:Disconnect() end
    if data.align then data.align:Destroy() end
    if data.linVel then data.linVel:Destroy() end
    flyData[plr] = nil
    notify("Fly stopped", Color3.fromRGB(255, 160, 60))
end

local function setspeed(plr, num)
    if not checkSelf(plr, "speed") then return end
    local hum = getHum(plr)
    if hum then
        hum.WalkSpeed = tonumber(num) or 16
        notify("WalkSpeed set to " .. hum.WalkSpeed, currentTheme.accent)
    end
end

local function resetspeed(plr)
    if not checkSelf(plr, "resetspeed") then return end
    local hum = getHum(plr)
    if hum then
        hum.WalkSpeed = 16
        notify("WalkSpeed reset to 16", Color3.fromRGB(180, 180, 255))
    end
end

local function noclip(plr)
    if not checkSelf(plr, "noclip") then return end
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if client.Character then
            for _, part in client.Character:GetDescendants() do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end)
    notify("Noclip enabled", Color3.fromRGB(100, 255, 120))
end

local function unnoclip(plr)
    if not checkSelf(plr, "unnoclip") then return end
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
    notify("Noclip disabled", Color3.fromRGB(255, 120, 100))
end

local function esp(plr)
    if espTable[plr] then return end
    local highlights = {}
    espTable[plr] = highlights
    local function addHighlight(char)
        if not char then return end
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillColor = Color3.new(1,0,0)
        hl.FillTransparency = 0.7
        hl.OutlineColor = Color3.new(1,1,1)
        hl.OutlineTransparency = 0
        hl.Parent = client.PlayerGui
        table.insert(highlights, hl)
    end
    if plr.Character then addHighlight(plr.Character) end
    table.insert(highlights, plr.CharacterAdded:Connect(addHighlight))
    notify("ESP enabled on " .. plr.Name, currentTheme.accent)
end

local function unesp(plr)
    local data = espTable[plr]
    if not data then return end
    for _, item in ipairs(data) do
        if typeof(item) == "Instance" then item:Destroy()
        elseif typeof(item) == "RBXScriptConnection" then item:Disconnect() end
    end
    espTable[plr] = nil
    notify("ESP disabled on " .. plr.Name, Color3.fromRGB(255, 100, 100))
end

local function heal(plr)
    local hum = getHum(plr)
    if hum then
        hum.Health = hum.MaxHealth
        notify("Healed " .. plr.Name, Color3.fromRGB(100, 255, 100))
    end
end

local function kill(plr)
    local char = plr and plr.Character
    if not char then return end
    pcall(function()
        local hum = getHum(plr)
        if hum then hum.Health = 0 end
        char:BreakJoints()
    end)
    notify("Killed " .. plr.Name, Color3.fromRGB(255, 80, 80))
end

local function tp(p1, p2)
    if not checkSelf(p1, "tp") then return end
    local h1, h2 = getHRP(p1), getHRP(p2)
    if h1 and h2 then
        h1.CFrame = h2.CFrame * CFrame.new(0, 3, 0)
        notify("Teleported to " .. p2.Name, currentTheme.accent)
    end
end

local function bring(plr)
    notify("Bring not possible client-side", Color3.fromRGB(255, 100, 100))
end

local function gotoMe(target)
    tp(client, target)
end

local function jump(plr, pow)
    if not checkSelf(plr, "jump") then return end
    local hum = getHum(plr)
    if hum then
        hum.JumpPower = tonumber(pow) or 50
        notify("Jump power set to " .. hum.JumpPower, Color3.fromRGB(200, 200, 100))
    end
end

local function sit(plr)
    if not checkSelf(plr, "sit") then return end
    local hum = getHum(plr)
    if hum then hum.Sit = true end
    notify("Sitting", Color3.fromRGB(200, 150, 255))
end

local function lay(plr)
    if not checkSelf(plr, "lay") then return end
    local hum = getHum(plr)
    if hum then
        hum.Sit = true
        task.wait(0.1)
        local hrp = getHRP(plr)
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0) end
    end
    notify("Laying", Color3.fromRGB(200, 150, 255))
end

local function freeze(plr)
    if not checkSelf(plr, "freeze") then return end
    local hum = getHum(plr)
    if not hum or frozen[plr] then return end
    frozen[plr] = {ws = hum.WalkSpeed, jp = hum.JumpPower}
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    notify("Frozen", Color3.fromRGB(100, 100, 255))
end

local function unfreeze(plr)
    if not checkSelf(plr, "unfreeze") then return end
    local data = frozen[plr]
    local hum = getHum(plr)
    if data and hum then
        hum.WalkSpeed = data.ws
        hum.JumpPower = data.jp
        frozen[plr] = nil
        notify("Unfrozen", Color3.fromRGB(200, 100, 200))
    end
end

local function god(plr)
    if not checkSelf(plr, "god") then return end
    if gods[plr] then return end
    local hum = getHum(plr)
    if hum then
        gods[plr] = hum.HealthChanged:Connect(function()
            hum.Health = hum.MaxHealth
        end)
        notify("God mode enabled", Color3.fromRGB(255, 215, 0))
    end
end

local function ungod(plr)
    if not checkSelf(plr, "ungod") then return end
    if gods[plr] then
        gods[plr]:Disconnect()
        gods[plr] = nil
        notify("God mode disabled", Color3.fromRGB(255, 140, 0))
    end
end

local function invisP(plr)
    if not checkSelf(plr, "invis") then return end
    if invis[plr] then return end
    local char = plr.Character
    if char then
        for _, part in char:GetDescendants() do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            end
        end
    end
    invis[plr] = true
    notify("Invisible", Color3.fromRGB(180, 100, 255))
end

local function visP(plr)
    if not checkSelf(plr, "vis") then return end
    if not invis[plr] then return end
    local char = plr.Character
    if char then
        for _, part in char:GetDescendants() do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
    invis[plr] = nil
    notify("Visible", Color3.fromRGB(100, 180, 255))
end

local function fling(plr)
    if not checkSelf(plr, "fling") then return end
    local hrp = getHRP(plr)
    if hrp then
        local v = Instance.new("BodyVelocity")
        v.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        v.Velocity = Vector3.new(math.random(-200,200)*100, 200*100, math.random(-200,200)*100)
        v.Parent = hrp
        task.delay(0.3, function() if v then v:Destroy() end end)
        notify("Flung!", Color3.fromRGB(255, 100, 180))
    end
end

local function rejoin()
    TeleportService:Teleport(game.PlaceId, client)
end

local function ping()
    local ping = math.round(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    notify("Ping: " .. ping .. "ms", Color3.fromRGB(200, 200, 255))
end

local clickTPconn
local function clickTP()
    if clickTPconn then
        clickTPconn:Disconnect()
        clickTPconn = nil
        notify("Click TP disabled", Color3.fromRGB(255, 120, 100))
    else
        clickTPconn = Mouse.Button1Down:Connect(function()
            if Mouse.Target then
                local hrp = getHRP(client)
                if hrp then
                    hrp.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
                end
            end
        end)
        notify("Click TP enabled - click anywhere", Color3.fromRGB(100, 255, 120))
    end
end

local function setFov(val)
    local num = tonumber(val)
    if num and num >= 1 and num <= 120 then
        workspace.CurrentCamera.FieldOfView = num
        notify("FOV set to " .. num, currentTheme.accent)
    else
        notify("Invalid FOV (1-120)", Color3.fromRGB(255, 100, 100))
    end
end

local function kick(plr)
    if plr == client then
        client:Kick("Kicked via Lunar Admin")
    else
        notify("Kick only works on self (client-side)", Color3.fromRGB(255, 170, 0))
    end
end

local function ragdoll(plr)
    if not checkSelf(plr, "ragdoll") then return end
    local char = plr.Character
    if not char then return end
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
    notify("Ragdolled", Color3.fromRGB(200, 100, 100))
end

local function unragdoll(plr)
    if not checkSelf(plr, "unragdoll") then return end
    local joints = ragdolls[plr]
    if not joints then return end
    for _, v in ipairs(joints) do v.Enabled = true end
    local hum = getHum(plr)
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum.PlatformStand = false
    end
    ragdolls[plr] = nil
    notify("Unragdolled", Color3.fromRGB(100, 200, 100))
end

local function spin(plr, num)
    if not checkSelf(plr, "spin") then return end
    local hrp = getHRP(plr)
    if not hrp or spinData[plr] then return end
    local speed = tonumber(num) or 500
    local a = Instance.new("AngularVelocity")
    a.MaxTorque = Vector3.new(0, math.huge, 0)
    a.AngularVelocity = Vector3.new(0, speed, 0)
    a.Attachment0 = Instance.new("Attachment", hrp)
    a.Parent = hrp
    spinData[plr] = a
    notify("Spinning at " .. speed .. " deg/s", currentTheme.accent)
end

local function unspin(plr)
    if not checkSelf(plr, "unspin") then return end
    if spinData[plr] then
        spinData[plr]:Destroy()
        spinData[plr] = nil
        notify("Spin stopped", Color3.fromRGB(200, 200, 200))
    end
end

local function console()
    StarterGui:SetCore("DevConsoleVisible", true)
    notify("Console opened", Color3.fromRGB(180, 180, 255))
end

local function disableFallDamage()
    local conn = client.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end)
    notify("Fall damage disabled", Color3.fromRGB(100, 255, 180))
end

local function enableCore(name)
    local enum
    if name == "inventory" then enum = Enum.CoreGuiType.Backpack
    elseif name == "playerlist" then enum = Enum.CoreGuiType.PlayerList
    else return end
    local current = StarterGui:GetCoreGuiEnabled(enum)
    StarterGui:SetCoreGuiEnabled(enum, not current)
    notify(name:gsub("^%l", string.upper) .. (not current and " enabled" or " disabled"), Color3.fromRGB(180, 180, 255))
end

local function dance(plr)
    if not checkSelf(plr, "dance") then return end
    local hum = getHum(plr)
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507771019"
        local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
        local track = animator:LoadAnimation(anim)
        track:Play()
        notify("Dancing!", Color3.fromRGB(255, 100, 255))
    end
end

local function trip(plr)
    if not checkSelf(plr, "trip") then return end
    local hum = getHum(plr)
    if hum then
        hum.Sit = true
        hum.Jump = true
        notify("Tripped!", Color3.fromRGB(255, 180, 100))
    end
end

local function explode(plr)
    local hrp = getHRP(plr)
    if hrp then
        local ex = Instance.new("Explosion")
        ex.Position = hrp.Position
        ex.BlastPressure = 0
        ex.Parent = workspace
        notify("Exploded!", Color3.fromRGB(255, 80, 80))
    end
end

local function giant(plr)
    if not checkSelf(plr, "giant") then return end
    local hum = getHum(plr)
    if hum then
        for _, scaleName in ipairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do
            local scale = hum:FindFirstChild(scaleName)
            if scale then scale.Value = 3 end
        end
        notify("Giant mode!", Color3.fromRGB(100, 255, 100))
    end
end

local function tiny(plr)
    if not checkSelf(plr, "tiny") then return end
    local hum = getHum(plr)
    if hum then
        for _, scaleName in ipairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do
            local scale = hum:FindFirstChild(scaleName)
            if scale then scale.Value = 0.3 end
        end
        notify("Tiny mode!", Color3.fromRGB(100, 200, 255))
    end
end

local function rainbow(plr)
    if not checkSelf(plr, "rainbow") then return end
    if rainbowData[plr] then return end
    local char = plr.Character
    if not char then return end
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
    notify("Rainbow ON", Color3.fromRGB(255, 100, 255))
end

local function unrainbow(plr)
    if not checkSelf(plr, "unrainbow") then return end
    if rainbowData[plr] then
        rainbowData[plr]:Disconnect()
        rainbowData[plr] = nil
        notify("Rainbow OFF", Color3.fromRGB(200, 100, 200))
    end
end

local function fire(plr)
    local hrp = getHRP(plr)
    if hrp and not hrp:FindFirstChild("Fire") then
        local f = Instance.new("Fire", hrp)
        f.Size = 10
        f.Heat = 25
        notify("On fire!", Color3.fromRGB(255, 100, 0))
    end
end

local function unfire(plr)
    local hrp = getHRP(plr)
    if hrp then
        local f = hrp:FindFirstChild("Fire")
        if f then f:Destroy() end
        notify("Fire off", Color3.fromRGB(200, 100, 0))
    end
end

local freecamEnabled = false
local freecamConn, mouseConn, inputBeganConn, inputEndedConn
local function freecam()
    if freecamEnabled then return end
    freecamEnabled = true
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hrp.Anchored = true
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    local speed = 60
    local sensitivity = 0.25
    local moveDir = Vector3.new()
    local keys = {}
    inputBeganConn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keys[input.KeyCode] = true
        end
    end)
    inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keys[input.KeyCode] = false
        end
    end)
    mouseConn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Delta
            local cam = workspace.CurrentCamera
            local yaw = CFrame.Angles(0, -math.rad(delta.X * sensitivity), 0)
            local pitch = CFrame.Angles(-math.rad(delta.Y * sensitivity), 0, 0)
            hrp.CFrame = hrp.CFrame * yaw
            cam.CFrame = cam.CFrame * pitch
        end
    end)
    freecamConn = RunService.RenderStepped:Connect(function(dt)
        moveDir = Vector3.new(
            (keys[Enum.KeyCode.D] and 1 or 0) - (keys[Enum.KeyCode.A] and 1 or 0),
            (keys[Enum.KeyCode.E] and 1 or 0) - (keys[Enum.KeyCode.Q] and 1 or 0),
            (keys[Enum.KeyCode.S] and 1 or 0) - (keys[Enum.KeyCode.W] and 1 or 0)
        )
        if moveDir.Magnitude > 0 then
            local cam = workspace.CurrentCamera
            local dir = (cam.CFrame.LookVector * -moveDir.Z) + (cam.CFrame.RightVector * moveDir.X) + (cam.CFrame.UpVector * moveDir.Y)
            cam.CFrame += dir.Unit * speed * dt
        end
    end)
    notify("Freecam enabled", currentTheme.accent)
end

local function unfreecam()
    if not freecamEnabled then return end
    freecamEnabled = false
    hum.WalkSpeed = 16
    hum.JumpPower = 50
    hrp.Anchored = false
    if freecamConn then freecamConn:Disconnect() end
    if mouseConn then mouseConn:Disconnect() end
    if inputBeganConn then inputBeganConn:Disconnect() end
    if inputEndedConn then inputEndedConn:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    notify("Freecam disabled", currentTheme.accent)
end

local function thirdp()
    client.CameraMode = Enum.CameraMode.Classic
    client.CameraMaxZoomDistance = 400
    client.CameraMinZoomDistance = 0.5
    notify("Third person enabled", currentTheme.accent)
end

local function firstp()
    client.CameraMode = Enum.CameraMode.LockFirstPerson
    notify("First person enabled", currentTheme.accent)
end

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
    notify("Waypoint #" .. num .. " added", currentTheme.accent)
end

local function enableTracers()
    for _, line in ipairs(tracerLines) do 
        if line then line:Destroy() end 
    end
    tracerLines = {}
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= client and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local line = Instance.new("Beam")
            line.Color = ColorSequence.new(Color3.new(1,0,0))
            line.Width0 = 0.2
            line.Width1 = 0.2
            line.Transparency = NumberSequence.new(0.3)
            line.Attachment0 = Instance.new("Attachment", hrp)
            line.Attachment1 = Instance.new("Attachment", p.Character.HumanoidRootPart)
            line.Parent = workspace
            table.insert(tracerLines, line)
        end
    end
    notify("Tracers enabled", currentTheme.accent)
end

local function disableTracers()
    for _, line in ipairs(tracerLines) do 
        if line then line:Destroy() end 
    end
    tracerLines = {}
    notify("Tracers disabled", currentTheme.accent)
end

-- =============================================================
-- COMMAND PROCESSOR
-- =============================================================
local function processCmd(msg)
    if not msg or msg:sub(1,1) ~= prefix then return end
    local args = {}
    for word in msg:sub(2):gmatch("%S+") do
        table.insert(args, word)
    end
    local cmd = table.remove(args, 1):lower()
    
    notify(prefix .. cmd, Color3.fromRGB(180, 180, 255))
    local target = getPlr(args[1] or "me")
    
    if cmd == "fly" then 
        fly(target, args[2])
    elseif cmd == "unfly" then 
        unfly(target)
    elseif cmd == "speed" then 
        setspeed(target, args[2])
    elseif cmd == "resetspeed" then 
        resetspeed(target)
    elseif cmd == "noclip" then 
        noclip(target)
    elseif cmd == "unnoclip" then 
        unnoclip(target)
    elseif cmd == "esp" then
        if args[1] == "all" then 
            for _, p in ipairs(Players:GetPlayers()) do esp(p) end
        else 
            esp(target) 
        end
    elseif cmd == "unesp" then
        if args[1] == "all" then 
            for _, p in ipairs(Players:GetPlayers()) do unesp(p) end
        else 
            unesp(target) 
        end
    elseif cmd == "heal" then 
        heal(target)
    elseif cmd == "kill" then
        if args[1] == "all" then 
            for _, p in ipairs(Players:GetPlayers()) do kill(p) end
        elseif args[1] == "me" then 
            kill(client)
        else 
            kill(target) 
        end
    elseif cmd == "tp" then 
        tp(client, getPlr(args[2] or "me"))
    elseif cmd == "bring" then 
        bring(target)
    elseif cmd == "to" then 
        gotoMe(target)
    elseif cmd == "jump" then 
        jump(client, args[1])
    elseif cmd == "sit" then 
        sit(client)
    elseif cmd == "lay" then 
        lay(client)
    elseif cmd == "freeze" then 
        freeze(target)
    elseif cmd == "unfreeze" then 
        unfreeze(target)
    elseif cmd == "god" then 
        god(target)
    elseif cmd == "ungod" then 
        ungod(target)
    elseif cmd == "invis" then 
        invisP(target)
    elseif cmd == "vis" then 
        visP(target)
    elseif cmd == "fling" then 
        fling(target)
    elseif cmd == "rejoin" then 
        rejoin()
    elseif cmd == "ping" then 
        ping()
    elseif cmd == "stopwatch" then 
        toggleStopwatch()
    elseif cmd == "clicktp" then 
        clickTP()
    elseif cmd == "fov" then 
        setFov(args[1])
    elseif cmd == "kick" then 
        kick(target)
    elseif cmd == "ragdoll" then 
        ragdoll(client)
    elseif cmd == "unragdoll" then 
        unragdoll(client)
    elseif cmd == "spin" then 
        spin(client, args[1])
    elseif cmd == "unspin" then 
        unspin(client)
    elseif cmd == "console" then 
        console()
    elseif cmd == "logs" then 
        toggleLogs()
    elseif cmd == "disablefalldamage" then 
        disableFallDamage()
    elseif cmd == "enable" then
        local what = args[1] or ""
        if what == "inventory" or what == "playerlist" then
            enableCore(what)
        end
    elseif cmd == "dance" then 
        dance(target)
    elseif cmd == "trip" then 
        trip(target)
    elseif cmd == "explode" then 
        explode(target)
    elseif cmd == "giant" then 
        giant(target)
    elseif cmd == "tiny" then 
        tiny(target)
    elseif cmd == "rainbow" then 
        rainbow(target)
    elseif cmd == "unrainbow" then 
        unrainbow(target)
    elseif cmd == "fire" then 
        fire(target)
    elseif cmd == "unfire" then 
        unfire(target)
    elseif cmd == "freecam" then 
        freecam()
    elseif cmd == "unfreecam" then 
        unfreecam()
    elseif cmd == "thirdp" then 
        thirdp()
    elseif cmd == "firstp" then 
        firstp()
    elseif cmd == "waypoint" then 
        waypoint()
    elseif cmd == "removewaypoint" then 
        removeWaypoint()
    elseif cmd == "tracers" then 
        enableTracers()
    elseif cmd == "untracers" then 
        disableTracers()
    elseif cmd == "view" then 
        view(target)
    elseif cmd == "unview" then 
        unview()
    elseif cmd == "aimbot" then 
        createAimbotPanel()
    end
end

-- =============================================================
-- COMMAND INPUT
-- =============================================================
local cmdBoxGui = Instance.new("ScreenGui")
cmdBoxGui.ResetOnSpawn = false
cmdBoxGui.Parent = client.PlayerGui
local cmdFrame = Instance.new("Frame", cmdBoxGui)
cmdFrame.Size = UDim2.new(0, 280, 0, 45)
cmdFrame.Position = UDim2.new(1, -300, 0.2, 0)
cmdFrame.BackgroundColor3 = currentTheme.glass
cmdFrame.Active = true
cmdFrame.Draggable = true
applyGlassEffect(cmdFrame, 0.2, 0.5)

local cmdInput = Instance.new("TextBox", cmdFrame)
cmdInput.Size = UDim2.new(1, -20, 1, -10)
cmdInput.Position = UDim2.new(0, 10, 0, 5)
cmdInput.BackgroundTransparency = 1
cmdInput.PlaceholderText = "Type command here..."
cmdInput.Font = Enum.Font.Gotham
cmdInput.TextSize = 16
cmdInput.TextColor3 = Color3.new(1,1,1)
cmdInput.ClearTextOnFocus = false
cmdInput.FocusLost:Connect(function(enter)
    if enter then
        processCmd(cmdInput.Text)
        cmdInput.Text = ""
    end
end)

-- =============================================================
-- CHAT & KEYBIND HANDLERS
-- =============================================================
client.Chatted:Connect(processCmd)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        local g = client.PlayerGui:FindFirstChild("LunarGui")
        if g then
            g.Enabled = not g.Enabled
            if g.Enabled then
                playOpen()
            else
                playClose()
            end
        end
    end
end)

-- =============================================================
-- MAIN GUI
-- =============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "LunarGui"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = client.PlayerGui

local main = Instance.new("Frame", gui)
main.Name = "Main"
main.Size = UDim2.new(0, 400, 0, 600)
main.Position = UDim2.new(1, -420, 0.5, -300)
main.BackgroundColor3 = currentTheme.glass
main.Active = true
main.Draggable = true
applyGlassEffect(main, 0.1, 0.5)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "Lunar Hub"
title.Font = Enum.Font.GothamBlack
title.TextSize = 32
title.TextColor3 = currentTheme.accent

-- Tabs
local tabBar = Instance.new("Frame", main)
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
applyGlassEffect(cmdTab, 0.2, 0.4)

local settingsTab = Instance.new("TextButton", tabBar)
settingsTab.Size = UDim2.new(0.5, -5, 1, 0)
settingsTab.Position = UDim2.new(0.5, 5, 0, 0)
settingsTab.BackgroundColor3 = currentTheme.btn
settingsTab.Text = "Settings"
settingsTab.Font = Enum.Font.GothamBold
settingsTab.TextSize = 18
settingsTab.TextColor3 = currentTheme.text
applyGlassEffect(settingsTab, 0.2, 0.5)

-- Commands tab
local cmdFrame = Instance.new("Frame", main)
cmdFrame.Size = UDim2.new(1, -20, 1, -130)
cmdFrame.Position = UDim2.new(0, 10, 0, 130)
cmdFrame.BackgroundTransparency = 1

local search = Instance.new("TextBox", cmdFrame)
search.Size = UDim2.new(1, 0, 0, 40)
search.BackgroundColor3 = currentTheme.list
search.PlaceholderText = "Search commands..."
search.Font = Enum.Font.Gotham
search.TextSize = 16
search.TextColor3 = currentTheme.text
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

local cmds = {
    "!fly [plr] [speed]","!unfly [plr]",
    "!speed [plr] [num]","!resetspeed [plr]",
    "!noclip [plr]","!unnoclip [plr]",
    "!esp [plr/all]","!unesp [plr/all]",
    "!heal [plr]","!kill [plr/all/me]",
    "!tp [p1] [p2]","!bring [plr]","!to [plr]",
    "!jump [pow]","!sit","!lay",
    "!freeze [plr]","!unfreeze [plr]",
    "!god [plr]","!ungod [plr]",
    "!invis [plr]","!vis [plr]",
    "!fling [plr]",
    "!rejoin","!ping","!stopwatch","!clicktp",
    "!fov [1-120]","!kick [plr]",
    "!ragdoll","!unragdoll",
    "!spin [num]","!unspin",
    "!console","!logs",
    "!disablefalldamage","!enable inventory","!enable playerlist",
    "-- NEW COMMANDS --",
    "!view [plr]","!unview",
    "!removewaypoint","!aimbot",
    "-- FUN EXTRAS --",
    "!dance [plr]","!trip [plr]","!explode [plr]","!giant [plr]","!tiny [plr]",
    "!rainbow [plr]","!unrainbow [plr]",
    "!fire [plr]","!unfire [plr]",
    "!freecam","!unfreecam",
    "!thirdp","!firstp",
    "!waypoint","!tracers","!untracers"
}

for i, cmdStr in ipairs(cmds) do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 44)
    lbl.BackgroundColor3 = currentTheme.list
    lbl.BackgroundTransparency = 0.2
    lbl.Text = " " .. cmdStr
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextColor3 = currentTheme.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    applyGlassEffect(lbl, 0.4, 0.7)
    lbl.Parent = scroll
    lbl.LayoutOrder = i
end

scroll.CanvasSize = UDim2.new(0,0,0, #cmds * 52)
search:GetPropertyChangedSignal("Text"):Connect(function()
    local filter = search.Text:lower()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child.Visible = filter == "" or child.Text:lower():find(filter, 1, true)
        end
    end
end)

-- Settings tab
local settingsFrame = Instance.new("Frame", main)
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

local prefixInput = Instance.new("TextBox", prefixSection)
prefixInput.Size = UDim2.new(0.8, 0, 0, 40)
prefixInput.Position = UDim2.new(0.1, 0, 0, 45)
prefixInput.BackgroundColor3 = currentTheme.list
prefixInput.Text = prefix
prefixInput.Font = Enum.Font.GothamBold
prefixInput.TextSize = 20
prefixInput.TextColor3 = currentTheme.text
applyGlassEffect(prefixInput, 0.25, 0.5)

prefixInput.FocusLost:Connect(function(enter)
    if enter then
        prefix = prefixInput.Text ~= "" and prefixInput.Text or "!"
        notify("Prefix changed to: " .. prefix, currentTheme.accent)
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
    applyGlassEffect(btn, 0.15, 0.4)
    
    btn.MouseButton1Click:Connect(function()
        currentTheme = th
        main.BackgroundColor3 = th.glass
        title.TextColor3 = th.accent
        cmdTab.BackgroundColor3 = th.accent
        settingsTab.BackgroundColor3 = th.btn
        search.BackgroundColor3 = th.list
        prefixInput.BackgroundColor3 = th.list
        
        notify("Theme changed to " .. name, th.accent)
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

local discordBtn = Instance.new("TextButton", discordSection)
discordBtn.Size = UDim2.new(0.9, 0, 0, 45)
discordBtn.Position = UDim2.new(0.05, 0, 0, 45)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Join Discord Server"
discordBtn.Font = Enum.Font.GothamBlack
discordBtn.TextSize = 18
discordBtn.TextColor3 = Color3.new(1,1,1)
applyGlassEffect(discordBtn, 0.15, 0.4)

discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/5GeQAXYYcW ")
        notify("Discord link copied to clipboard!", Color3.fromRGB(88,101,242))
    else
        notify("Clipboard not supported in this executor", Color3.fromRGB(255,100,100))
    end
end)

settingsScroll.CanvasSize = UDim2.new(0,0,0, 500)

-- Tab switching
cmdTab.MouseButton1Click:Connect(function()
    cmdFrame.Visible = true
    settingsFrame.Visible = false
    cmdTab.BackgroundColor3 = currentTheme.accent
    cmdTab.TextColor3 = Color3.new(0,0,0)
    settingsTab.BackgroundColor3 = currentTheme.btn
    settingsTab.TextColor3 = currentTheme.text
end)

settingsTab.MouseButton1Click:Connect(function()
    cmdFrame.Visible = false
    settingsFrame.Visible = true
    settingsTab.BackgroundColor3 = currentTheme.accent
    settingsTab.TextColor3 = Color3.new(0,0,0)
    cmdTab.BackgroundColor3 = currentTheme.btn
    cmdTab.TextColor3 = currentTheme.text
end)

-- =============================================================
-- STARTUP
-- =============================================================
gui.Enabled = true
playOpen()
notify("Lunar Admin loaded • RightShift to toggle", Color3.fromRGB(120,220,255))

task.spawn(function()
    task.wait(0.8)
    local wm = Instance.new("ScreenGui")
    wm.ResetOnSpawn = false
    wm.Parent = client.PlayerGui
    local label = Instance.new("TextLabel", wm)
    label.Size = UDim2.new(0, 320, 0, 40)
    label.Position = UDim2.new(0.5, -160, 0.94, 0)
    label.BackgroundTransparency = 1
    label.Text = "Created By @LunarRbxZ"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 24
    label.TextColor3 = Color3.new(1,1,1)
    label.TextTransparency = 1
    TweenService:Create(label, TweenInfo.new(1.8, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(5.5)
    TweenService:Create(label, TweenInfo.new(1.6), {TextTransparency = 1}):Play()
    task.delay(2, function() wm:Destroy() end)
end)
