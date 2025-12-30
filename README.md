-- Created By @xLunarxZzRbxx --
-- Prefix: ! --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local prefix = "!"

-- Commands list
local commands = {
    "!fly [player] [speed]",
    "!unfly [player]",
    "!speed [player] [speed]",
    "!resetSpeed [player]",
    "!noclip [player]",
    "!clip [player]",
    "!esp [player/all]",
    "!unesp [player/all]",
    "!heal [player]",
    "!kill [player/all/me]",
    "!tp [player1] [player2]",
    "!bring [player]",
    "!goto [player]"
}

-- Table for ESP and Fly
local ESPs = {}
local flyStates = {}
local noclipStates = {}

-- Utility functions
local function getPlayer(name)
    if not name then return nil end
    name = name:lower()
    if name == "me" then return player end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
            return p
        end
    end
    return nil
end

-- Kill function (fixed)
local function killPlayer(plr)
    if not plr then return end
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Dead)
        hum.Health = 0
    end
end

-- Fly system
local function flyTarget(target, speed)
    speed = speed or 50
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = target.Character.HumanoidRootPart
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyGyro.MaxTorque = Vector3.new(400000,400000,400000)
    bodyGyro.P = 100000
    bodyVelocity.MaxForce = Vector3.new(400000,400000,400000)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyGyro.Parent = hrp
    bodyVelocity.Parent = hrp
    flyStates[target] = {gyro=bodyGyro, velocity=bodyVelocity, speed=speed}
    RunService:BindToRenderStep("Fly"..target.Name, 201, function()
        if flyStates[target] then
            local cam = workspace.CurrentCamera
            local dir = cam.CFrame.LookVector
            bodyVelocity.Velocity = dir * flyStates[target].speed
            bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
        else
            RunService:UnbindFromRenderStep("Fly"..target.Name)
        end
    end)
end

local function unflyTarget(target)
    if flyStates[target] then
        flyStates[target].gyro:Destroy()
        flyStates[target].velocity:Destroy()
        flyStates[target] = nil
        RunService:UnbindFromRenderStep("Fly"..target.Name)
    end
end

-- Speed
local function setSpeed(target, speed)
    if target.Character and target.Character:FindFirstChild("Humanoid") then
        target.Character.Humanoid.WalkSpeed = speed
    end
end

-- Noclip
local function noclipTarget(target)
    if target.Character then
        noclipStates[target] = true
        for _, part in pairs(target.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

local function clipTarget(target)
    if target.Character then
        noclipStates[target] = false
        for _, part in pairs(target.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ESP
local function addESP(target)
    if ESPs[target] then return end
    if not target.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = target.Character
    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.OutlineColor = Color3.fromRGB(255,255,255)
    highlight.Parent = workspace
    ESPs[target] = highlight
end

local function removeESP(target)
    if ESPs[target] then
        ESPs[target]:Destroy()
        ESPs[target] = nil
    end
end

-- Command executor (fixed kill)
local function runCommand(cmd)
    local args = cmd:split(" ")
    local command = args[1]:lower()
    
    if command == "fly" then
        local plr = getPlayer(args[2])
        local speed = tonumber(args[3]) or 50
        if plr then flyTarget(plr, speed) end
    elseif command == "unfly" then
        local plr = getPlayer(args[2])
        if plr then unflyTarget(plr) end
    elseif command == "speed" then
        local plr = getPlayer(args[2])
        local speed = tonumber(args[3])
        if plr and speed then setSpeed(plr, speed) end
    elseif command == "resetspeed" then
        local plr = getPlayer(args[2])
        if plr then setSpeed(plr,16) end
    elseif command == "noclip" then
        local plr = getPlayer(args[2])
        if plr then noclipTarget(plr) end
    elseif command == "clip" then
        local plr = getPlayer(args[2])
        if plr then clipTarget(plr) end
    elseif command == "esp" then
        if args[2] == "all" then
            for _, p in pairs(Players:GetPlayers()) do addESP(p) end
        else
            local plr = getPlayer(args[2])
            if plr then addESP(plr) end
        end
    elseif command == "unesp" then
        if args[2] == "all" then
            for _, p in pairs(Players:GetPlayers()) do removeESP(p) end
        else
            local plr = getPlayer(args[2])
            if plr then removeESP(plr) end
        end
    elseif command == "heal" then
        local plr = getPlayer(args[2])
        if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.Health = plr.Character.Humanoid.MaxHealth
        end
    elseif command == "kill" then
        if args[2] then
            local targetName = args[2]:lower()
            if targetName == "all" then
                for _, p in pairs(Players:GetPlayers()) do
                    killPlayer(p)
                end
            else
                local plr = getPlayer(args[2])
                if plr then killPlayer(plr) end
            end
        else
            killPlayer(player)
        end
    elseif command == "tp" then
        local plr1 = getPlayer(args[2])
        local plr2 = getPlayer(args[3])
        if plr1 and plr2 and plr1.Character and plr2.Character then
            plr1.Character:MoveTo(plr2.Character.HumanoidRootPart.Position)
        end
    elseif command == "bring" then
        local plr = getPlayer(args[2])
        if plr and plr.Character and player.Character then
            plr.Character:MoveTo(player.Character.HumanoidRootPart.Position + Vector3.new(0,5,0))
        end
    elseif command == "goto" then
        local plr = getPlayer(args[2])
        if plr and plr.Character and player.Character then
            player.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
        end
    end
end

-- Chat listener
player.Chatted:Connect(function(msg)
    if msg:sub(1,1) == prefix then
        local command = msg:sub(2)
        if command:lower() == "cmds" then
            if ScreenGui then
                ScreenGui.Enabled = true
            else
                createPanel()
            end
        else
            runCommand(command)
        end
    end
end)

-- === PANEL CREATION ===
local ScreenGui, MainFrame, CloseButton, TitleLabel, CmdsFrame

local function createPanel()
    if ScreenGui then ScreenGui:Destroy() end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdminPanelGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    -- Title
    TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1,-30,0,40)
    TitleLabel.Position = UDim2.new(0,10,0,5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Admin Commands"
    TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = MainFrame

    -- Close button
    CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0,25,0,25)
    CloseButton.Position = UDim2.new(1,-30,0,10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
    CloseButton.Parent = MainFrame
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    -- Commands list
    CmdsFrame = Instance.new("ScrollingFrame")
    CmdsFrame.Size = UDim2.new(1,-20,1,-60)
    CmdsFrame.Position = UDim2.new(0,10,0,45)
    CmdsFrame.BackgroundTransparency = 1
    CmdsFrame.BorderSizePixel = 0
    CmdsFrame.CanvasSize = UDim2.new(0,0,#commands*30)
    CmdsFrame.ScrollBarThickness = 6
    CmdsFrame.Parent = MainFrame

    for i, cmd in pairs(commands) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,-10,0,25)
        lbl.Position = UDim2.new(0,5,0,(i-1)*30)
        lbl.BackgroundTransparency = 0.3
        lbl.BackgroundColor3 = Color3.fromRGB(40,40,40)
        lbl.Text = cmd
        lbl.TextColor3 = Color3.fromRGB(255,255,255)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = CmdsFrame
    end
end

-- Create panel initially
createPanel()
