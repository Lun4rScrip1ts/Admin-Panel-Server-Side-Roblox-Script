-- Created By @xLunarxZzRbxx
-- Prefix: !
---------------- SERVICES ----------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local prefix = "!"

---------------- COMMAND DATA ----------------
local commands = {
	"!fly [player] [speed]",
	"!unfly [player]",
	"!speed [player] [speed]",
	"!resetspeed [player]",
	"!noclip [player]",
	"!clip [player]",
	"!esp [player/all]",
	"!unesp [player/all]",
	"!heal [player]",
	"!kill [player/all/me]",
	"!tp [p1] [p2]",
	"!bring [player]",
	"!goto [player]",
	"!jump [power]",
	"!sit",
	"!freeze [player]",
	"!unfreeze [player]",
	"!rejoin",
	"!cmds"
}

---------------- UTIL ----------------
local function getPlayer(name)
	if not name then return player end
	name = name:lower()
	if name == "me" then return player end
	for _,p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
			return p
		end
	end
	return player
end

---------------- INTRO + WATERMARK ----------------
local introGui = Instance.new("ScreenGui", player.PlayerGui)
introGui.ResetOnSpawn = false

local introFrame = Instance.new("Frame", introGui)
introFrame.Size = UDim2.fromScale(0.3, 0.15)
introFrame.Position = UDim2.fromScale(0.5, 0.5)
introFrame.AnchorPoint = Vector2.new(0.5,0.5)
introFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
introFrame.BackgroundTransparency = 1
Instance.new("UICorner", introFrame).CornerRadius = UDim.new(0,16)

local introText = Instance.new("TextLabel", introFrame)
introText.Size = UDim2.fromScale(1,1)
introText.BackgroundTransparency = 1
introText.Text = "Admin Panel Loading..."
introText.Font = Enum.Font.GothamBold
introText.TextScaled = true
introText.TextColor3 = Color3.new(1,1,1)
introText.TextTransparency = 1

TweenService:Create(introFrame, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
TweenService:Create(introText, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
task.wait(2)

TweenService:Create(introFrame, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
TweenService:Create(introText, TweenInfo.new(0.6), {TextTransparency = 1}):Play()

-- Watermark
local watermark = Instance.new("TextLabel", introGui)
watermark.Size = UDim2.new(0,240,0,22)
watermark.Position = UDim2.new(0.5,0,0.88,0)
watermark.AnchorPoint = Vector2.new(0.5,0)
watermark.BackgroundTransparency = 1
watermark.Text = "Created By @xLunarxZzRbxx"
watermark.Font = Enum.Font.Gotham
watermark.TextSize = 14
watermark.TextColor3 = Color3.new(1,1,1)
watermark.TextTransparency = 1

TweenService:Create(watermark, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
task.wait(2.5)
TweenService:Create(watermark, TweenInfo.new(0.8), {TextTransparency = 1}):Play()

task.wait(1)
introGui:Destroy()

---------------- GUI ----------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0,320,0,420)
panel.Position = UDim2.new(1,40,0.5,-210)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel)

TweenService:Create(panel, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {
	Position = UDim2.new(1,-340,0.5,-210)
}):Play()

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Admin Panel"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)

-- Search box
local search = Instance.new("TextBox", panel)
search.Size = UDim2.new(1,-20,0,30)
search.Position = UDim2.new(0,10,0,45)
search.PlaceholderText = "Search commands..."
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.BackgroundColor3 = Color3.fromRGB(35,35,35)
search.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", search)

-- Command list
local list = Instance.new("ScrollingFrame", panel)
list.Position = UDim2.new(0,10,0,85)
list.Size = UDim2.new(1,-20,1,-145)
list.CanvasSize = UDim2.new(0,0,0,#commands*30)
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1

local labels = {}

local function refreshList(filter)
	for _,l in pairs(labels) do l:Destroy() end
	labels = {}
	local y = 0
	for _,cmd in ipairs(commands) do
		if not filter or cmd:lower():find(filter:lower()) then
			local lbl = Instance.new("TextLabel", list)
			lbl.Size = UDim2.new(1,-10,0,26)
			lbl.Position = UDim2.new(0,5,0,y)
			lbl.BackgroundColor3 = Color3.fromRGB(40,40,40)
			lbl.BackgroundTransparency = 0.2
			lbl.Text = cmd
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.new(1,1,1)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UICorner", lbl)
			table.insert(labels, lbl)
			y += 30
		end
	end
	list.CanvasSize = UDim2.new(0,0,0,y)
end

refreshList()

search:GetPropertyChangedSignal("Text"):Connect(function()
	refreshList(search.Text)
end)

-- Discord button
local discord = Instance.new("TextButton", panel)
discord.Size = UDim2.new(1,-20,0,35)
discord.Position = UDim2.new(0,10,1,-45)
discord.Text = "Discord"
discord.Font = Enum.Font.GothamBold
discord.TextSize = 16
discord.BackgroundColor3 = Color3.fromRGB(50,50,50)
discord.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", discord)

discord.MouseButton1Click:Connect(function()
	setclipboard("https://discord.gg/5GeQAXYYcW")
	discord.Text = "Copied!"
	task.wait(1.5)
	discord.Text = "Discord"
end)

---------------- COMMAND LOGIC ----------------
local flyData = {}
local noclip = {}

local function kill(plr)
	if plr.Character then
		plr.Character:BreakJoints()
	end
end

local function fly(plr, speed)
	if flyData[plr] or not plr.Character then return end
	speed = speed or 50
	local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
	local gyro = Instance.new("BodyGyro", hrp)
	local vel = Instance.new("BodyVelocity", hrp)
	gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
	vel.MaxForce = Vector3.new(9e9,9e9,9e9)
	flyData[plr] = {gyro=gyro, vel=vel, speed=speed}
	RunService:BindToRenderStep("Fly"..plr.Name, 200, function()
		if not flyData[plr] then return end
		vel.Velocity = workspace.CurrentCamera.CFrame.LookVector * speed
		gyro.CFrame = workspace.CurrentCamera.CFrame
	end)
end

local function unfly(plr)
	if flyData[plr] then
		flyData[plr].gyro:Destroy()
		flyData[plr].vel:Destroy()
		flyData[plr] = nil
		RunService:UnbindFromRenderStep("Fly"..plr.Name)
	end
end

---------------- CHAT ----------------
player.Chatted:Connect(function(msg)
	if msg:sub(1,1) ~= prefix then return end
	local args = msg:sub(2):split(" ")
	local cmd = args[1]:lower()

	if cmd == "cmds" then
		gui.Enabled = not gui.Enabled
	elseif cmd == "rejoin" then
		TeleportService:Teleport(game.PlaceId, player)
	elseif cmd == "kill" then
		if args[2] == "all" then
			for _,p in ipairs(Players:GetPlayers()) do kill(p) end
		else
			kill(getPlayer(args[2]))
		end
	elseif cmd == "fly" then
		fly(getPlayer(args[2]), tonumber(args[3]))
	elseif cmd == "unfly" then
		unfly(getPlayer(args[2]))
	elseif cmd == "noclip" then
		for _,p in ipairs(getPlayer(args[2]).Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	elseif cmd == "clip" then
		for _,p in ipairs(getPlayer(args[2]).Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
end)

UserInputService.InputBegan:Connect(function(i,g)
	if not g and i.KeyCode == Enum.KeyCode.RightShift then
		gui.Enabled = not gui.Enabled
	end
end)

local TextChatService = game:GetService "TextChatService"
local TextChannel = TextChatService:WaitForChild "TextChannels" : WaitForChild "RBXGeneral" :: TextChannel
--parenthesis are optional in calls with one literal argument
TextChannel:SendAsync "Created By @xLunarxZzRbxx~"
