--  Lunar Admin  |  prefix : !
---------------------------------------------------------------- SERVICES
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local TeleportService= game:GetService("TeleportService")
local UserInputService= game:GetService("UserInputService")
local TextChatService= game:GetService("TextChatService")

local client = Players.LocalPlayer
local prefix = "!"

---------------------------------------------------------------- COMMAND LIST
local cmds = {
	"!fly [plr] [speed]","!unfly [plr]",
	"!speed [plr] [num]","!resetspeed [plr]",
	"!noclip [plr]","!clip [plr]",
	"!esp [plr/all]","!unesp [plr/all]",
	"!heal [plr]","!kill [plr/all/me]",
	"!tp [p1] [p2]","!bring [plr]","!to [plr]",
	"!jump [pow]","!sit","!lay",
	"!freeze [plr]","!unfreeze [plr]",
	"!god [plr]","!ungod [plr]",
	"!invis [plr]","!vis [plr]",
	"!fling [plr]","!tpall",
	"!rejoin","!cmds"
}

---------------------------------------------------------------- UTIL
local function getPlr(str)
	if not str or str:lower()=="me" then return client end
	for _,p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():sub(1,#str)==str:lower() or p.DisplayName:lower():sub(1,#str)==str:lower() then
			return p
		end
	end
	return nil
end
local function getHRP(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function getHum(p) return p.Character and p.Character:FindFirstChildOfClass("Humanoid") end

---------------------------------------------------------------- KILL (joint-break only)
local function killPlayer(p) if not p then return end local char = p.Character if char then char:BreakJoints() end end

---------------------------------------------------------------- FREE-MOVE FLY
local flyData = {}
local function fly(p, spd)
	if flyData[p] or not getHRP(p) then return end
	spd = tonumber(spd) or 50
	local hrp = getHRP(p)
	local cam = workspace.CurrentCamera

	local bg = Instance.new("BodyGyro", hrp)
	bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
	local bv = Instance.new("BodyVelocity", hrp)
	bv.MaxForce = Vector3.new(1e6,1e6,1e6)
	flyData[p] = {bg=bg,bv=bv,s=spd}

	local function step()
		if not flyData[p] then return end
		local cf = cam.CFrame
		local dir = Vector3.new()
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
		bv.Velocity = dir.Unit * flyData[p].s
		bg.CFrame = cf
	end
	RunService:BindToRenderStep("FreeFly"..p.Name, 200, step)
end
local function unfly(p)
	local t = flyData[p]
	if t then t.bg:Destroy(); t.bv:Destroy(); flyData[p]=nil; RunService:UnbindFromRenderStep("FreeFly"..p.Name) end
end

---------------------------------------------------------------- SPEED
local function setspeed(p, n)
	local hum = getHum(p) if not hum then return end
	if not hum:FindFirstChild("CustSpeed") then Instance.new("NumberValue",hum).Name="CustSpeed" end
	hum.CustSpeed.Value = tonumber(n) or 16; hum.WalkSpeed = hum.CustSpeed.Value
end
local function resetspeed(p)
	local hum = getHum(p) if not hum then return end
	if hum:FindFirstChild("CustSpeed") then hum.CustSpeed:Destroy() end
	hum.WalkSpeed = 16
end

---------------------------------------------------------------- NOCLIP / CLIP
local noclip = {}
local function setnoclip(p, on)
	local char = p.Character if not char then return end
	if noclip[p] then noclip[p]:Disconnect(); noclip[p]=nil end
	if on then
		noclip[p] = RunService.Stepped:Connect(function()
			for _,v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
		end)
	else
		for _,v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end
	end
end

---------------------------------------------------------------- ESP
local espt = {}
local function unesp(p)
	local t = espt[p] if not t then return end
	for _,v in pairs(t) do v:Destroy() end; espt[p]=nil
end
local function esp(p)
	if espt[p] then return end
	local t = {}; espt[p]=t
	local function build(ch)
		if not ch then return end
		local box = Instance.new("BoxHandleAdornment")
		box.Adornee = getHRP(p) or ch:FindFirstChild("Head")
		box.Size,box.Color3,box.AlwaysOnTop = Vector3.new(2,3,2),Color3.new(1,0,0),true
		box.ZIndex,box.Parent = 5,ch
		table.insert(t,box)
		local bbg = Instance.new("BillboardGui")
		bbg.Size,bbg.AlwaysOnTop,bbg.Adornee = UDim2.new(0,200,0,50),true,box.Adornee
		bbg.StudsOffset = Vector3.new(0,3,0)
		local txt = Instance.new("TextLabel",bbg)
		txt.Size,txt.Text,txt.TextScaled = UDim2.new(1,0,1,0),p.Name,true
		txt.BackgroundTransparency,txt.TextColor3 = 1,Color3.new(1,1,1)
		bbg.Parent = ch; table.insert(t,bbg)
	end
	build(p.Character)
	local added; added = p.CharacterAdded:Connect(function(ch) build(ch) end); table.insert(t,added)
end
local function espall() for _,v in ipairs(Players:GetPlayers()) do esp(v) end end
local function unespall() for _,v in ipairs(Players:GetPlayers()) do unesp(v) end end

---------------------------------------------------------------- HEAL
local function heal(p)
	local hum = getHum(p) if hum then hum.Health = hum.MaxHealth end
end

---------------------------------------------------------------- TP
local function tp(p1, p2)
	local h1,h2 = getHRP(p1), getHRP(p2)
	if h1 and h2 then h1.CFrame = h2.CFrame + Vector3.new(0,2,0) end
end
local function bring(to, tgt) tp(tgt, to) end
local function goto(me, tgt) tp(me, tgt) end
local function tpall()
	for _,v in ipairs(Players:GetPlayers()) do if v~=client then tp(v, client) end end
end

---------------------------------------------------------------- MISC
local function jumppower(p, pow)
	local hum = getHum(p) if hum then hum.UseJumpPower=true; hum.JumpPower=tonumber(pow) or 50 end
end
local function sit(p)
	local hum = getHum(p) if hum then hum.Sit=true end
end
local function lay(p)
	local hum = getHum(p) if hum then hum.Sit=true; getHRP(p).CFrame = getHRP(p).CFrame*CFrame.Angles(math.pi/2,0,0) end
end

---------------------------------------------------------------- FREEZE
local frozen = {}
local function freeze(p)
	local hum = getHum(p) if not hum or frozen[p] then return end
	frozen[p] = {ws = hum.WalkSpeed, jp = hum.JumpPower, jh = hum.JumpHeight}
	hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = 0,0,0
end
local function unfreeze(p)
	local t = frozen[p]; local hum = getHum(p)
	if t and hum then hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = t.ws, t.jp, t.jh; frozen[p]=nil end
end

---------------------------------------------------------------- GOD
local gods = {}
local function god(p)
	if gods[p] then return end
	local hum = getHum(p) if not hum then return end
	gods[p] = hum.HealthChanged:Connect(function() if hum.Health<hum.MaxHealth then hum.Health=hum.MaxHealth end end)
end
local function ungod(p)
	local c = gods[p] if c then c:Disconnect(); gods[p]=nil end
end

---------------------------------------------------------------- INVIS
local invis = {}
local function invisP(p)
	if invis[p] or not p.Character then return end
	for _,v in ipairs(p.Character:GetChildren()) do if v:IsA("BasePart") then v.Transparency = 1 end end
	invis[p] = true
end
local function visP(p)
	if not invis[p] or not p.Character then return end
	for _,v in ipairs(p.Character:GetChildren()) do if v:IsA("BasePart") then v.Transparency = 0 end end
	invis[p] = nil
end

---------------------------------------------------------------- FLING
local function fling(p)
	local hrp = getHRP(p) if not hrp then return end
	local v = Instance.new("BodyVelocity", hrp)
	v.MaxForce, v.Velocity = Vector3.new(1e6,1e6,1e6), Vector3.new(math.random(-2e4,2e4), 2e4, math.random(-2e4,2e4))
	task.wait(0.25); v:Destroy()
end

---------------------------------------------------------------- REJOIN
local function rejoin() TeleportService:Teleport(game.PlaceId, client) end

---------------------------------------------------------------- GUI
local gui = Instance.new("ScreenGui", client.PlayerGui); gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(1, 40, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Active = true; main.Draggable = true
Instance.new("UICorner", main)
TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -340, 0.5, -210)}):Play()

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Lunar Admin"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)

local search = Instance.new("TextBox", main)
search.Size = UDim2.new(1, -20, 0, 30)
search.Position = UDim2.new(0, 10, 0, 45)
search.PlaceholderText = "Search commands..."
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
search.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", search)

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0, 10, 0, 85)
list.Size = UDim2.new(1, -20, 1, -145)
list.CanvasSize = UDim2.new(0, 0, 0, #cmds * 30)
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1

local lbls = {}
local function refresh(filter)
	for _,v in ipairs(lbls) do v:Destroy() end; lbls = {}
	local y = 0
	for _,cmd in ipairs(cmds) do
		if not filter or cmd:lower():find(filter:lower()) then
			local l = Instance.new("TextLabel", list)
			l.Size = UDim2.new(1, -10, 0, 26)
			l.Position = UDim2.new(0, 5, 0, y)
			l.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			l.BackgroundTransparency = 0.2
			l.Text = cmd
			l.Font = Enum.Font.Gotham
			l.TextSize = 14
			l.TextColor3 = Color3.new(1, 1, 1)
			l.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UICorner", l)
			table.insert(lbls, l)
			y += 30
		end
	end
	list.CanvasSize = UDim2.new(0, 0, 0, y)
end
refresh()
search:GetPropertyChangedSignal("Text"):Connect(function() refresh(search.Text) end)

local discord = Instance.new("TextButton", main)
discord.Size = UDim2.new(1, -20, 0, 35)
discord.Position = UDim2.new(0, 10, 1, -45)
discord.Text = "Discord"
discord.Font = Enum.Font.GothamBold
discord.TextSize = 16
discord.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
discord.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", discord)
discord.MouseButton1Click:Connect(function()
	setclipboard("https://discord.gg/5GeQAXYYcW")
	discord.Text = "Copied!"
	task.wait(1.5)
	discord.Text = "Discord"
end)

---------------------------------------------------------------- CHAT HANDLER
client.Chatted:Connect(function(msg)
	if msg:sub(1,1)~=prefix then return end
	local args = msg:sub(2):split(" ")
	local cmd  = table.remove(args,1):lower()

	if cmd=="cmds" then gui.Enabled = not gui.Enabled
	elseif cmd=="rejoin" then rejoin()
		elseif cmd=="kill" then
		local name = args[1] or ""
		if name:lower()=="all" then
			for _,p in ipairs(Players:GetPlayers()) do killPlayer(p) end
		else
			local tgt = getPlr(name)
			if tgt then killPlayer(tgt) end
		end
	elseif cmd=="fly" then fly(getPlr(args[1]), args[2])
	elseif cmd=="unfly" then unfly(getPlr(args[1]))
	elseif cmd=="speed" then setspeed(getPlr(args[1]), args[2])
	elseif cmd=="resetspeed" then resetspeed(getPlr(args[1]))
	elseif cmd=="noclip" then setnoclip(getPlr(args[1]), true)
	elseif cmd=="clip" then setnoclip(getPlr(args[1]), false)
	elseif cmd=="esp" then
		local tgt = args[1] or ""
		if tgt:lower()=="all" then espall() else esp(getPlr(tgt)) end
	elseif cmd=="unesp" then
		local tgt = args[1] or ""
		if tgt:lower()=="all" then unespall() else unesp(getPlr(tgt)) end
	elseif cmd=="heal" then heal(getPlr(args[1]))
	elseif cmd=="tp" then tp(getPlr(args[1]), getPlr(args[2]))
	elseif cmd=="bring" then bring(client, getPlr(args[1]))
	elseif cmd=="to" then goto(client, getPlr(args[1]))
	elseif cmd=="tpall" then tpall()
	elseif cmd=="jump" then jumppower(client, args[1])
	elseif cmd=="sit" then sit(client)
	elseif cmd=="lay" then lay(client)
	elseif cmd=="freeze" then freeze(getPlr(args[1]))
	elseif cmd=="unfreeze" then unfreeze(getPlr(args[1]))
	elseif cmd=="god" then god(getPlr(args[1]))
	elseif cmd=="ungod" then ungod(getPlr(args[1]))
	elseif cmd=="invis" then invisP(getPlr(args[1]))
	elseif cmd=="vis" then visP(getPlr(args[1]))
	elseif cmd=="fling" then fling(getPlr(args[1]))
	end
end)

---------------------------------------------------------------- HOTKEY
UserInputService.InputBegan:Connect(function(i,g)
	if not g and i.KeyCode==Enum.KeyCode.RightShift then gui.Enabled = not gui.Enabled end
end)

---------------------------------------------------------------- LOAD MSG
task.spawn(function()
	local chan = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
	chan:SendAsync("xLunarxZzRbxx Admin loaded – !cmds for list")
end)
