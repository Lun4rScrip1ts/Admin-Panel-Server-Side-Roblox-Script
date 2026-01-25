-- Join my Discord :3 https://discord.gg/5GeQAXYYcW
-- Created by @xLunarxZzRbxx

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local TeleportService  = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TextChatService  = game:GetService("TextChatService")
local StarterGui       = game:GetService("StarterGui")
local SoundService     = game:GetService("SoundService")
local Debris           = game:GetService("Debris")

local client = Players.LocalPlayer
local Mouse  = client:GetMouse()

local prefix = "!"

-- =============================================================
-- THEMES
-- =============================================================
local themes = {
    Default = {
        main = Color3.fromRGB(22, 22, 28),
        grad1 = Color3.fromRGB(35, 35, 45),
        grad2 = Color3.fromRGB(22, 22, 28),
        accent = Color3.fromRGB(0, 170, 255),
        text = Color3.new(1,1,1),
        btn = Color3.fromRGB(45, 45, 60),
        list = Color3.fromRGB(38, 38, 48)
    },
    Pink = {
        main = Color3.fromRGB(255, 182, 193),
        grad1 = Color3.fromRGB(255, 192, 203),
        grad2 = Color3.fromRGB(255, 105, 180),
        accent = Color3.fromRGB(255, 79, 163),
        text = Color3.new(0.15,0.15,0.15),
        btn = Color3.fromRGB(255, 105, 180),
        list = Color3.fromRGB(250, 160, 180)
    },
    Blue = {
        main = Color3.fromRGB(25, 35, 60),
        grad1 = Color3.fromRGB(40, 70, 120),
        grad2 = Color3.fromRGB(20, 40, 80),
        accent = Color3.fromRGB(80, 220, 255),
        text = Color3.new(1,1,1),
        btn = Color3.fromRGB(50, 90, 150),
        list = Color3.fromRGB(35, 55, 100)
    },
    Red = {
        main = Color3.fromRGB(40, 15, 15),
        grad1 = Color3.fromRGB(80, 20, 20),
        grad2 = Color3.fromRGB(50, 10, 10),
        accent = Color3.fromRGB(255, 80, 80),
        text = Color3.new(1,1,1),
        btn = Color3.fromRGB(180, 40, 40),
        list = Color3.fromRGB(70, 20, 20)
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
-- SUBTLE FALLING EFFECT
-- =============================================================
local function startFalling(panel)
    local symbols = {"★", "✦"}
    local function spawn()
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.ZIndex = 999
        lbl.TextTransparency = 0.7
        lbl.Parent = panel
        lbl.Text = symbols[math.random(1, #symbols)]
        lbl.TextSize = math.random(12,16)
        lbl.TextColor3 = currentTheme.accent
        lbl.Position = UDim2.new(math.random(), 0, -0.25, 0)
        local dur = math.random(9, 14)
        local rot = math.random(-30,30)
        TweenService:Create(lbl, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
            Position = UDim2.new(lbl.Position.X.Scale, 0, 1.4, 0),
            Rotation = rot,
            TextTransparency = 1
        }):Play()
        task.delay(dur + 1.5, function()
            if lbl and lbl.Parent then lbl:Destroy() end
        end)
    end
    local conn = RunService.Heartbeat:Connect(function()
        if not panel or not panel.Parent then
            conn:Disconnect()
            return
        end
        if math.random(1, 200) == 1 then spawn() end
    end)
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
    f.Size = UDim2.new(0, 320, 0, 65)
    f.Position = UDim2.new(1, -340, 1, -100)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    f.BorderSizePixel = 0
    f.Parent = notifGui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", f)
    stroke.Color = col
    stroke.Thickness = 1.5
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -20, 1, -20)
    lbl.Position = UDim2.new(0, 10, 0, 10)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 17
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextWrapped = true
    TweenService:Create(f, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -340, 1, -85)
    }):Play()
    task.delay(5, function()
        TweenService:Create(f, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, 50, 1, -85)
        }):Play()
        task.delay(0.7, function() f:Destroy() end)
    end)
end

-- =============================================================
-- INTRO ANIMATION (plays first, then enables UI)
-- =============================================================
local function createIntro()
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "LunarIntro"
    introGui.IgnoreGuiInset = true
    introGui.ResetOnSpawn = false
    introGui.Parent = client.PlayerGui

    local bg = Instance.new("Frame", introGui)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.new(0,0,0)
    bg.BackgroundTransparency = 1

    local ring = Instance.new("ImageLabel", bg)
    ring.AnchorPoint = Vector2.new(0.5,0.5)
    ring.Position = UDim2.new(0.5,0,0.5,0)
    ring.Size = UDim2.new(0,520,0,520)
    ring.BackgroundTransparency = 1
    ring.ImageTransparency = 1
    ring.Image = "rbxassetid://18398420960" -- CHANGE TO YOUR IMAGE ID IF NEEDED
    ring.ScaleType = Enum.ScaleType.Fit

    local glow = Instance.new("ImageLabel", ring)
    glow.AnchorPoint = Vector2.new(0.5,0.5)
    glow.Position = UDim2.new(0.5,0,0.5,0)
    glow.Size = UDim2.new(1.5,0,1.5,0)
    glow.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    glow.Image = "rbxassetid://4996891970"
    glow.ImageColor3 = Color3.fromRGB(0,170,255)

    local text = Instance.new("TextLabel", bg)
    text.AnchorPoint = Vector2.new(0.5,0.5)
    text.Position = UDim2.new(0.5,0,0.78,0)
    text.Size = UDim2.new(0.9,0,0.14,0)
    text.BackgroundTransparency = 1
    text.Text = "LUNAR STUDIOS"
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 72
    text.TextColor3 = Color3.new(1,1,1)
    text.TextTransparency = 1
    text.TextStrokeTransparency = 0.7
    text.TextStrokeColor3 = Color3.fromRGB(0,170,255)

    TweenService:Create(bg, TweenInfo.new(1.4), {BackgroundTransparency = 0.08}):Play()

    task.delay(0.6, function()
        TweenService:Create(ring, TweenInfo.new(2.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
        TweenService:Create(glow, TweenInfo.new(2.3, Enum.EasingStyle.Sine), {ImageTransparency = 0.3}):Play()
        TweenService:Create(text, TweenInfo.new(1.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    end)

    task.delay(5.5, function()
        TweenService:Create(ring, TweenInfo.new(1.5), {ImageTransparency = 1}):Play()
        TweenService:Create(glow, TweenInfo.new(1.5), {ImageTransparency = 1}):Play()
        TweenService:Create(text, TweenInfo.new(1.5), {TextTransparency = 1}):Play()
        TweenService:Create(bg, TweenInfo.new(1.8), {BackgroundTransparency = 1}):Play()
        task.delay(2, function()
            introGui:Destroy()
            -- Enable main UI after intro
            local g = client.PlayerGui:FindFirstChild("LunarGui")
            if g then
                g.Enabled = true
                playOpen()
                startFalling(g.Main)
                notify("Lunar Admin loaded • RightShift to toggle", Color3.fromRGB(120,220,255))
            else
                notify("GUI failed to load - re-execute script", Color3.fromRGB(255,100,100))
            end
        end)
    end)
end

-- =============================================================
-- WORKING CHAT LOGS (!logs)
-- =============================================================
local logsGui, logsScroll, logEntries = nil, nil, {}

local function addLog(sender, message)
    if #logEntries > 70 then
        if logEntries[1] then logEntries[1]:Destroy() end
        table.remove(logEntries, 1)
    end
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, -16, 0, 28)
    entry.BackgroundTransparency = 1
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.RichText = true
    entry.Text = " <font color='rgb(160,180,255)'>" .. sender .. "</font>: " .. message
    entry.TextColor3 = Color3.new(0.95,0.95,1)
    entry.TextSize = 15
    entry.Font = Enum.Font.Gotham
    entry.TextWrapped = true
    entry.Parent = logsScroll
    table.insert(logEntries, entry)
    logsScroll.CanvasSize = UDim2.new(0,0,0, #logEntries * 32)
    logsScroll.CanvasPosition = Vector2.new(0, #logEntries * 32)
end

local function toggleLogs()
    if logsGui then
        logsGui:Destroy()
        logsGui = nil
        return
    end

    logsGui = Instance.new("ScreenGui")
    logsGui.Name = "LunarLogs"
    logsGui.ResetOnSpawn = false
    logsGui.Parent = client.PlayerGui

    local frame = Instance.new("Frame", logsGui)
    frame.Size = UDim2.new(0, 450, 0, 330)
    frame.Position = UDim2.new(0.5, -225, 0.5, -165)
    frame.BackgroundColor3 = Color3.fromRGB(18,18,24)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,42)
    title.BackgroundTransparency = 1
    title.Text = "Chat Logs"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.new(1,1,1)

    logsScroll = Instance.new("ScrollingFrame", frame)
    logsScroll.Size = UDim2.new(1,-16,1,-54)
    logsScroll.Position = UDim2.new(0,8,0,46)
    logsScroll.BackgroundTransparency = 1
    logsScroll.ScrollBarThickness = 5
    logsScroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,120)

    local layout = Instance.new("UIListLayout", logsScroll)
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    notify("Chat logs opened", Color3.fromRGB(180,180,255))
end

TextChatService.MessageReceived:Connect(function(msg)
    if msg.TextSource then
        addLog(msg.TextSource.Name, msg.Text)
    end
end)

-- =============================================================
-- UTILITIES
-- =============================================================
local function getPlr(str)
    if not str or str:lower() == "me" then return client end
    str = str:lower()
    for _, p in Players:GetPlayers() do
        if p.Name:lower():sub(1,#str) == str or (p.DisplayName or ""):lower():sub(1,#str) == str then
            return p
        end
    end
    return nil
end

local function getHRP(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function getHum(p) return p.Character and p.Character:FindFirstChildOfClass("Humanoid") end

local function checkSelf(p, cmd)
    if p ~= client then
        notify("Command '" .. cmd .. "' only works on self (client-side limit)", Color3.fromRGB(255, 100, 100))
        return false
    end
    return true
end

-- =============================================================
-- DATA STORAGE
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
local loopJumpData = {}

-- =============================================================
-- COMMANDS IMPLEMENTATION
-- =============================================================

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

    for _, item in data do
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

local stopGui
local function stopwatch()
    if stopGui then stopGui:Destroy() stopGui = nil return end
    stopGui = Instance.new("ScreenGui")
    stopGui.ResetOnSpawn = false
    stopGui.Parent = client.PlayerGui
    local f = Instance.new("Frame", stopGui)
    f.Size = UDim2.new(0, 200, 0, 100)
    f.Position = UDim2.new(0.5, -100, 0.5, -50)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    f.Active = true
    f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "0.00"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 40
    lbl.TextColor3 = Color3.new(1,1,1)
    local start = tick()
    local conn = RunService.Heartbeat:Connect(function()
        if not stopGui or not lbl.Parent then return end
        lbl.Text = string.format("%.2f", tick() - start)
    end)
    notify("Stopwatch started (toggle again to stop)", Color3.fromRGB(200, 200, 255))
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
    for _, v in joints do v.Enabled = true end
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

local fallConn
local function disableFallDamage()
    if fallConn then return end
    fallConn = client.CharacterAdded:Connect(function(char)
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
        for _, scaleName in {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"} do
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
        for _, scaleName in {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"} do
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

-- =============================================================
-- COMMAND PROCESSOR
-- =============================================================
local function processCmd(msg)
    if not msg or msg:sub(1,1) ~= prefix then return end
    local args = msg:sub(2):split(" ")
    local cmd = args[1]:lower()
    table.remove(args, 1)
    notify(prefix .. cmd, Color3.fromRGB(180, 180, 255))
    local target = getPlr(args[1] or "me")

    if cmd == "fly" then fly(target, args[2])
    elseif cmd == "unfly" then unfly(target)
    elseif cmd == "speed" then setspeed(target, args[2])
    elseif cmd == "resetspeed" then resetspeed(target)
    elseif cmd == "noclip" then noclip(target)
    elseif cmd == "unnoclip" then unnoclip(target)
    elseif cmd == "esp" then
        if args[1] == "all" then for _, p in Players:GetPlayers() do esp(p) end
        else esp(target) end
    elseif cmd == "unesp" then
        if args[1] == "all" then for _, p in Players:GetPlayers() do unesp(p) end
        else unesp(target) end
    elseif cmd == "heal" then heal(target)
    elseif cmd == "kill" then
        if args[1] == "all" then for _, p in Players:GetPlayers() do kill(p) end
        elseif args[1] == "me" then kill(client)
        else kill(target) end
    elseif cmd == "tp" then tp(client, getPlr(args[2] or "me"))
    elseif cmd == "bring" then bring(target)
    elseif cmd == "to" then gotoMe(target)
    elseif cmd == "jump" then jump(client, args[1])
    elseif cmd == "sit" then sit(client)
    elseif cmd == "lay" then lay(client)
    elseif cmd == "freeze" then freeze(target)
    elseif cmd == "unfreeze" then unfreeze(target)
    elseif cmd == "god" then god(target)
    elseif cmd == "ungod" then ungod(target)
    elseif cmd == "invis" then invisP(target)
    elseif cmd == "vis" then visP(target)
    elseif cmd == "fling" then fling(target)
    elseif cmd == "rejoin" then rejoin()
    elseif cmd == "ping" then ping()
    elseif cmd == "stopwatch" then stopwatch()
    elseif cmd == "clicktp" then clickTP()
    elseif cmd == "fov" then setFov(args[1])
    elseif cmd == "kick" then kick(target)
    elseif cmd == "ragdoll" then ragdoll(client)
    elseif cmd == "unragdoll" then unragdoll(client)
    elseif cmd == "spin" then spin(client, args[1])
    elseif cmd == "unspin" then unspin(client)
    elseif cmd == "console" then console()
    elseif cmd == "logs" then toggleLogs()
    elseif cmd == "disablefalldamage" then disableFallDamage()
    elseif cmd == "enable" then
        local what = args[1] or ""
        if what == "inventory" or what == "playerlist" then
            enableCore(what)
        end
    elseif cmd == "dance" then dance(target)
    elseif cmd == "trip" then trip(target)
    elseif cmd == "explode" then explode(target)
    elseif cmd == "giant" then giant(target)
    elseif cmd == "tiny" then tiny(target)
    elseif cmd == "rainbow" then rainbow(target)
    elseif cmd == "unrainbow" then unrainbow(target)
    elseif cmd == "fire" then fire(target)
    elseif cmd == "unfire" then unfire(target)
    end
end

-- =============================================================
-- COMMAND INPUT (floating box)
-- =============================================================
local cmdBoxGui = Instance.new("ScreenGui")
cmdBoxGui.ResetOnSpawn = false
cmdBoxGui.Parent = client.PlayerGui

local cmdFrame = Instance.new("Frame", cmdBoxGui)
cmdFrame.Size = UDim2.new(0, 280, 0, 45)
cmdFrame.Position = UDim2.new(1, -300, 0.2, 0)
cmdFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
cmdFrame.Active = true
cmdFrame.Draggable = true
Instance.new("UICorner", cmdFrame).CornerRadius = UDim.new(0, 10)

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
                startFalling(g.Main)
            else
                playClose()
            end
        end
    end
end)

-- =============================================================
-- MAIN PANEL GUI
-- =============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "LunarGui"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = client.PlayerGui

local main = Instance.new("Frame", gui)
main.Name = "Main"
main.Size = UDim2.new(0, 380, 0, 580)
main.Position = UDim2.new(1, -400, 0.5, -290)
main.BackgroundColor3 = currentTheme.main
main.BackgroundTransparency = 0.05
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new(currentTheme.grad1, currentTheme.grad2)
grad.Rotation = 90

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "Lunar Hub"
title.Font = Enum.Font.GothamBlack
title.TextSize = 28
title.TextColor3 = currentTheme.text

-- Tabs
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, -20, 0, 45)
tabBar.Position = UDim2.new(0, 10, 0, 65)
tabBar.BackgroundTransparency = 1

local cmdTab = Instance.new("TextButton", tabBar)
cmdTab.Size = UDim2.new(0.5, -5, 1, 0)
cmdTab.BackgroundColor3 = currentTheme.btn
cmdTab.Text = "Commands"
cmdTab.Font = Enum.Font.GothamBold
cmdTab.TextSize = 17
cmdTab.TextColor3 = currentTheme.text
Instance.new("UICorner", cmdTab).CornerRadius = UDim.new(0, 10)

local settingsTab = Instance.new("TextButton", tabBar)
settingsTab.Size = UDim2.new(0.5, -5, 1, 0)
settingsTab.Position = UDim2.new(0.5, 5, 0, 0)
settingsTab.BackgroundColor3 = currentTheme.btn
settingsTab.Text = "Settings"
settingsTab.Font = Enum.Font.GothamBold
settingsTab.TextSize = 17
settingsTab.TextColor3 = currentTheme.text
Instance.new("UICorner", settingsTab).CornerRadius = UDim.new(0, 10)

-- Commands tab content
local cmdFrame = Instance.new("Frame", main)
cmdFrame.Size = UDim2.new(1, -20, 1, -120)
cmdFrame.Position = UDim2.new(0, 10, 0, 120)
cmdFrame.BackgroundTransparency = 1

local search = Instance.new("TextBox", cmdFrame)
search.Size = UDim2.new(1, 0, 0, 38)
search.BackgroundColor3 = currentTheme.list
search.PlaceholderText = "Search commands..."
search.Font = Enum.Font.Gotham
search.TextSize = 16
search.TextColor3 = currentTheme.text
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 10)

local scroll = Instance.new("ScrollingFrame", cmdFrame)
scroll.Size = UDim2.new(1, 0, 1, -48)
scroll.Position = UDim2.new(0, 0, 0, 48)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = currentTheme.accent

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
    "-- FUN EXTRAS --",
    "!dance [plr]","!trip [plr]","!explode [plr]","!giant [plr]","!tiny [plr]",
    "!rainbow [plr]","!unrainbow [plr]",
    "!fire [plr]","!unfire [plr]"
}

for i, cmdStr in ipairs(cmds) do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 44)
    lbl.BackgroundColor3 = currentTheme.list
    lbl.BackgroundTransparency = 0.3
    lbl.Text = " " .. cmdStr
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextColor3 = currentTheme.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 10)
    lbl.Parent = scroll
    lbl.LayoutOrder = i
end
scroll.CanvasSize = UDim2.new(0,0,0, #cmds * 52)

search:GetPropertyChangedSignal("Text"):Connect(function()
    local filter = search.Text:lower()
    for _, child in scroll:GetChildren() do
        if child:IsA("TextLabel") then
            child.Visible = filter == "" or child.Text:lower():find(filter, 1, true)
        end
    end
end)

-- Settings tab
local settingsFrame = Instance.new("Frame", main)
settingsFrame.Size = UDim2.new(1, -20, 1, -120)
settingsFrame.Position = UDim2.new(0, 10, 0, 120)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Visible = false

local prefixTitle = Instance.new("TextLabel", settingsFrame)
prefixTitle.Size = UDim2.new(1, 0, 0, 40)
prefixTitle.BackgroundTransparency = 1
prefixTitle.Text = "Prefix:"
prefixTitle.Font = Enum.Font.GothamBold
prefixTitle.TextSize = 18
prefixTitle.TextColor3 = currentTheme.text

local prefixInput = Instance.new("TextBox", settingsFrame)
prefixInput.Size = UDim2.new(0.7, 0, 0, 40)
prefixInput.Position = UDim2.new(0.15, 0, 0, 50)
prefixInput.BackgroundColor3 = currentTheme.btn
prefixInput.Text = prefix
prefixInput.Font = Enum.Font.Gotham
prefixInput.TextSize = 16
prefixInput.TextColor3 = currentTheme.text
Instance.new("UICorner", prefixInput).CornerRadius = UDim.new(0, 10)

prefixInput.FocusLost:Connect(function(enter)
    if enter then
        prefix = prefixInput.Text ~= "" and prefixInput.Text or "!"
        notify("Prefix changed to: " .. prefix, currentTheme.accent)
    end
end)

local themeTitle = Instance.new("TextLabel", settingsFrame)
themeTitle.Size = UDim2.new(1, 0, 0, 40)
themeTitle.Position = UDim2.new(0, 0, 0, 110)
themeTitle.BackgroundTransparency = 1
themeTitle.Text = "Theme:"
themeTitle.Font = Enum.Font.GothamBold
themeTitle.TextSize = 18
themeTitle.TextColor3 = currentTheme.text

local themeContainer = Instance.new("Frame", settingsFrame)
themeContainer.Size = UDim2.new(1, 0, 0, 80)
themeContainer.Position = UDim2.new(0, 0, 0, 150)
themeContainer.BackgroundTransparency = 1

local themeLayout = Instance.new("UIListLayout", themeContainer)
themeLayout.FillDirection = Enum.FillDirection.Horizontal
themeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
themeLayout.Padding = UDim.new(0, 12)

for name, th in pairs(themes) do
    local btn = Instance.new("TextButton", themeContainer)
    btn.Size = UDim2.new(0, 100, 0, 50)
    btn.BackgroundColor3 = th.accent
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = th.text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(function()
        currentTheme = th
        main.BackgroundColor3 = th.main
        grad.Color = ColorSequence.new(th.grad1, th.grad2)
        title.TextColor3 = th.text
        cmdTab.BackgroundColor3 = th.btn
        cmdTab.TextColor3 = th.text
        settingsTab.BackgroundColor3 = th.btn
        settingsTab.TextColor3 = th.text
        search.BackgroundColor3 = th.list
        search.TextColor3 = th.text
        prefixInput.BackgroundColor3 = th.btn
        prefixInput.TextColor3 = th.text
        notify("Theme changed to " .. name, th.accent)
    end)
end

-- Discord Join Button
local discordBtn = Instance.new("TextButton", settingsFrame)
discordBtn.Size = UDim2.new(0.8, 0, 0, 50)
discordBtn.Position = UDim2.new(0.1, 0, 0.78, 0)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Join my Discord"
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 20
discordBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 10)

discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/5GeQAXYYcW")
        notify("Discord link copied to clipboard!", Color3.fromRGB(88,101,242))
    else
        notify("Clipboard not supported in this executor", Color3.fromRGB(255,100,100))
    end
end)

-- Tab switching
cmdTab.MouseButton1Click:Connect(function()
    cmdFrame.Visible = true
    settingsFrame.Visible = false
end)

settingsTab.MouseButton1Click:Connect(function()
    cmdFrame.Visible = false
    settingsFrame.Visible = true
end)

-- =============================================================
-- STARTUP
-- =============================================================
createIntro()

task.spawn(function()
    task.wait(0.8)
    local wm = Instance.new("ScreenGui")
    wm.ResetOnSpawn = false
    wm.Parent = client.PlayerGui
    local label = Instance.new("TextLabel", wm)
    label.Size = UDim2.new(0, 320, 0, 40)
    label.Position = UDim2.new(0.5, -160, 0.94, -20)
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
--!nocheck
-- Lunar Rainbow Spinning Crosshair (Text ALWAYS under crosshair, DOES NOT rotate)
-- LocalScript - StarterPlayer → StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Force hide default mouse
task.wait(0.1)
UserInputService.MouseIconEnabled = false
if mouse then mouse.Icon = "" end
print("🌙 Lunar Crosshair: Mouse hidden | Text fixed under crosshair (no rotation)")

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "LunarCrosshair"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 999999
gui.Parent = player:WaitForChild("PlayerGui")

-- ================= SETTINGS =================
local settings = {
    VertLength = 16,
    HorzLength = 16,
    Width = 3,
    RotationSpeed = 120,
    RainbowSpeed = 1.5,
    YOffset = 0,
    TextGap = 8,
    Text = "Lunar",
    Symbol = "",
    SpinEnabled = true,
    VFXEnabled = false
}

-- ================= CROSSHAIR =================
local center = Instance.new("Frame")
center.BackgroundTransparency = 1
center.Size = UDim2.fromOffset(1,1)
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.ZIndex = 999
center.Parent = gui

local function makeLine()
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.ZIndex = 999
    return f
end

local vertical = makeLine(); vertical.Parent = center
local horizontal = makeLine(); horizontal.Parent = center

local crosshairSymbol = Instance.new("TextLabel")
crosshairSymbol.BackgroundTransparency = 1
crosshairSymbol.Size = UDim2.fromScale(1,1)
crosshairSymbol.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairSymbol.Position = UDim2.fromScale(0.5, 0.5)
crosshairSymbol.TextScaled = false
crosshairSymbol.Font = Enum.Font.GothamBold
crosshairSymbol.TextStrokeTransparency = 0.5
crosshairSymbol.TextStrokeColor3 = Color3.new(0,0,0)
crosshairSymbol.ZIndex = 999
crosshairSymbol.Parent = center
crosshairSymbol.Visible = false

-- ================= TEXT (always upright, under crosshair) =================
local text = Instance.new("TextLabel")
text.Text = settings.Text
text.Font = Enum.Font.GothamBold
text.TextSize = 18
text.BackgroundTransparency = 1
text.AnchorPoint = Vector2.new(0.5, 0) -- top-center
text.ZIndex = 999
text.TextStrokeTransparency = 0.5
text.TextStrokeColor3 = Color3.new(0,0,0)
text.TextXAlignment = Enum.TextXAlignment.Center
text.Parent = gui  -- stays in gui → does NOT rotate

-- ================= SETTINGS PANEL =================
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(240, 540)
panel.Position = UDim2.fromOffset(30, 200)
panel.BackgroundColor3 = Color3.fromRGB(20,20,25)
panel.BorderSizePixel = 0
panel.Visible = true
panel.ZIndex = 500
panel.Parent = gui

local corner = Instance.new("UICorner", panel)
corner.CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Text = "Lunar Crosshair (Right Shift: Toggle)"
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.new(1,1,1)
title.ZIndex = 501
title.Parent = panel

-- Dragging
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ================= INPUT MAKER =================
local function makeInput(name, yOffset, key, minVal, maxVal)
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Position = UDim2.fromOffset(10, yOffset)
    label.Size = UDim2.fromOffset(130, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.new(0.9,0.9,0.9)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 501
    label.Parent = panel

    local box = Instance.new("TextBox")
    box.Text = tostring(settings[key])
    box.Position = UDim2.fromOffset(150, yOffset)
    box.Size = UDim2.fromOffset(75, 20)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.BackgroundColor3 = Color3.fromRGB(35,35,40)
    box.TextColor3 = Color3.new(1,1,1)
    box.BorderSizePixel = 0
    box.ZIndex = 501
    box.Parent = panel
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    box:GetPropertyChangedSignal("Text"):Connect(function()
        local num = tonumber(box.Text)
        if num and num >= minVal and num <= maxVal then
            settings[key] = num
        end
    end)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            settings[key] = math.clamp(num, minVal, maxVal)
            box.Text = tostring(settings[key])
        else
            box.Text = tostring(settings[key])
        end
    end)
end

local function makeTextInput(name, yOffset, key)
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Position = UDim2.fromOffset(10, yOffset)
    label.Size = UDim2.fromOffset(80, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.new(0.9,0.9,0.9)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 501
    label.Parent = panel

    local box = Instance.new("TextBox")
    box.Text = settings[key]
    box.Position = UDim2.fromOffset(95, yOffset)
    box.Size = UDim2.fromOffset(140, 20)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.GothamBold
    box.TextSize = 13
    box.BackgroundColor3 = Color3.fromRGB(35,35,40)
    box.TextColor3 = Color3.new(1,1,1)
    box.BorderSizePixel = 0
    box.ZIndex = 501
    box.Parent = panel
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    box:GetPropertyChangedSignal("Text"):Connect(function()
        settings[key] = box.Text
    end)

    return box
end

local function makeToggle(name, yOffset, key)
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Position = UDim2.fromOffset(10, yOffset)
    label.Size = UDim2.fromOffset(130, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.new(0.9,0.9,0.9)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 501
    label.Parent = panel

    local button = Instance.new("TextButton")
    button.Text = settings[key] and "On" or "Off"
    button.Position = UDim2.fromOffset(150, yOffset)
    button.Size = UDim2.fromOffset(75, 20)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.BackgroundColor3 = Color3.fromRGB(35,35,40)
    button.TextColor3 = Color3.new(1,1,1)
    button.BorderSizePixel = 0
    button.ZIndex = 501
    button.Parent = panel
    Instance.new("UICorner", button).CornerRadius = UDim.new(0,6)

    button.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        button.Text = settings[key] and "On" or "Off"
    end)
end

-- Create inputs
makeInput("Vert Length", 40, "VertLength", 1, 10000)
makeInput("Horz Length", 70, "HorzLength", 1, 10000)
makeInput("Width", 100, "Width", 1, 10000)
makeInput("Rotation", 130, "RotationSpeed", 0, 10000)
makeInput("Rainbow", 160, "RainbowSpeed", 0, 10000)
makeInput("Y Offset", 190, "YOffset", -50, 50)
makeInput("Text Gap", 220, "TextGap", 0, 10000)

makeTextInput("Text", 255, "Text")
local symbolBox = makeTextInput("Symbol", 290, "Symbol")

-- Symbol selection list
local listLabel = Instance.new("TextLabel")
listLabel.Text = "Select Symbol:"
listLabel.Position = UDim2.fromOffset(10, 320)
listLabel.Size = UDim2.fromOffset(220, 20)
listLabel.BackgroundTransparency = 1
listLabel.Font = Enum.Font.Gotham
listLabel.TextSize = 12
listLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.ZIndex = 501
listLabel.Parent = panel

local symbolList = Instance.new("ScrollingFrame")
symbolList.Position = UDim2.fromOffset(10, 340)
symbolList.Size = UDim2.fromOffset(220, 100)
symbolList.BackgroundTransparency = 1
symbolList.CanvasSize = UDim2.new(0, 0, 0, 0)
symbolList.ScrollBarThickness = 4
symbolList.ZIndex = 501
symbolList.Parent = panel

local grid = Instance.new("UIGridLayout", symbolList)
grid.CellSize = UDim2.fromOffset(30, 30)
grid.CellPadding = UDim2.fromOffset(5, 5)
grid.SortOrder = Enum.SortOrder.LayoutOrder

local symbols = {"卐","+","-","×","÷","*","•","○","□","△","▽","♡","♥","★","☆","!","@","#","$","%","^","&","(",")","[","]","{","}","<",">","/","\\","|","~"}
for _, sym in ipairs(symbols) do
    local btn = Instance.new("TextButton")
    btn.Text = sym
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BorderSizePixel = 0
    btn.ZIndex = 501
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.Parent = symbolList
    btn.MouseButton1Click:Connect(function()
        settings.Symbol = sym
        symbolBox.Text = sym
    end)
end
symbolList.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y)

-- Toggles
makeToggle("Spin", 450, "SpinEnabled")
makeToggle("VFX", 480, "VFXEnabled")

-- ================= DISCORD BUTTON =================
local discordButton = Instance.new("TextButton")
discordButton.Text = "Join Discord!"
discordButton.Position = UDim2.fromOffset(10, 510)
discordButton.Size = UDim2.fromOffset(220, 30)
discordButton.Font = Enum.Font.GothamBold
discordButton.TextSize = 16
discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordButton.TextColor3 = Color3.new(1,1,1)
discordButton.BorderSizePixel = 0
discordButton.ZIndex = 501
discordButton.Parent = panel
Instance.new("UICorner", discordButton).CornerRadius = UDim.new(0,8)

local discordLink = "https://discord.gg/5GeQAXYYcW"
discordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(discordLink)
    elseif toClipboard then
        toClipboard(discordLink)
    else
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Discord Link",
                Text = discordLink .. "\n(Copied manually or use setclipboard)",
                Duration = 8
            })
        end)
        return
    end

    local feedback = Instance.new("TextLabel")
    feedback.Text = "Copied to clipboard!"
    feedback.Size = UDim2.fromOffset(200, 30)
    feedback.Position = UDim2.fromOffset(20, 545)
    feedback.BackgroundTransparency = 0.3
    feedback.BackgroundColor3 = Color3.fromRGB(0,170,0)
    feedback.TextColor3 = Color3.new(1,1,1)
    feedback.Font = Enum.Font.Gotham
    feedback.TextSize = 14
    feedback.ZIndex = 502
    feedback.Parent = panel
    Instance.new("UICorner", feedback).CornerRadius = UDim.new(0,6)

    task.delay(2.5, function()
        feedback:Destroy()
    end)
end)

-- ================= TOGGLE PANEL =================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        panel.Visible = not panel.Visible
    end
end)

-- ================= PARTICLE SPAWN =================
local function spawnParticle(color)
    local p = Instance.new("Frame")
    p.Size = UDim2.fromOffset(settings.Width * 2, settings.Width * 2)
    p.BackgroundColor3 = color
    p.BackgroundTransparency = 0
    p.AnchorPoint = Vector2.new(0.5, 0.5)
    p.Position = UDim2.fromOffset(0, 0)
    p.BorderSizePixel = 0
    p.ZIndex = 998
    p.Parent = center

    local corner = Instance.new("UICorner", p)
    corner.CornerRadius = UDim.new(1, 0)

    local direction = math.random() * math.pi * 2
    local distance = 50 + math.random() * 100
    local life = 0.3 + math.random() * 0.4

    local goal = {
        Position = UDim2.fromOffset(math.cos(direction) * distance, math.sin(direction) * distance),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(settings.Width * 3, settings.Width * 3)
    }

    local tweenInfo = TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(p, tweenInfo, goal)
    tween:Play()
    tween.Completed:Connect(function()
        p:Destroy()
    end)
end

-- ================= MAIN LOOP =================
local hue = 0
local rotation = 0

RunService.RenderStepped:Connect(function(dt)
    local mousePos = UserInputService:GetMouseLocation()
    local baseY = mousePos.Y + settings.YOffset

    center.Position = UDim2.fromOffset(mousePos.X, baseY)

    local crossBottomY

    if settings.Symbol ~= "" then
        vertical.Visible = false
        horizontal.Visible = false
        crosshairSymbol.Visible = true

        crosshairSymbol.Text = settings.Symbol
        crosshairSymbol.TextColor3 = Color3.fromHSV(hue, 1, 1)
        crosshairSymbol.TextSize = settings.VertLength

        crossBottomY = baseY + (settings.VertLength / 2)
    else
        vertical.Visible = true
        horizontal.Visible = true
        crosshairSymbol.Visible = false

        vertical.Size = UDim2.fromOffset(settings.Width, settings.VertLength)
        horizontal.Size = UDim2.fromOffset(settings.HorzLength, settings.Width)

        crossBottomY = baseY + (settings.VertLength / 2)
    end

    -- Text always positioned under crosshair center — never rotates
    text.Position = UDim2.fromOffset(mousePos.X, crossBottomY + settings.TextGap)
    text.Text = settings.Text
    text.TextColor3 = Color3.fromHSV(hue, 1, 1)

    vertical.AnchorPoint = Vector2.new(0.5, 0.5)
    horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
    vertical.Position = UDim2.fromScale(0.5, 0.5)
    horizontal.Position = UDim2.fromScale(0.5, 0.5)

    if settings.SpinEnabled then
        rotation = rotation + settings.RotationSpeed * dt
        center.Rotation = rotation % 360
    else
        center.Rotation = 0
    end

    hue = (hue + settings.RainbowSpeed * dt) % 1
    local color = Color3.fromHSV(hue, 1, 1)

    vertical.BackgroundColor3 = color
    horizontal.BackgroundColor3 = color
    title.TextColor3 = color
    panel.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 0.18)

    if settings.VFXEnabled and math.random() < 0.3 then
        spawnParticle(color)
    end
end)
local TextChatService = game:GetService "TextChatService"
local TextChannel = TextChatService:WaitForChild "TextChannels" : WaitForChild "RBXGeneral" :: TextChannel
--parenthesis are optional in calls with one literal argument
TextChannel:SendAsync "🌙Created by Lunar Studios🌙"
