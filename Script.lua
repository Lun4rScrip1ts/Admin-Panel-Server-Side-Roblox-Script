--  Lunar Admin  |  prefix : !
---------------------------------------------------------------- SERVICES
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local TeleportService= game:GetService("TeleportService")
local UserInputService= game:GetService("UserInputService")
local TextChatService= game:GetService("TextChatService")
local StarterGui     = game:GetService("StarterGui")

local client = Players.LocalPlayer
local Mouse = client:GetMouse()
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
	"!rejoin","!cmds","!ping","!stopwatch","!clickTP",
	"!fov [1-120]","!kick [plr]",
	"!ragdoll","!unragdoll",
	"!spin [num]","!unspin",
	"!console","!logs"
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

---------------------------------------------------------------- NOTIFICATION
local notifGui = Instance.new("ScreenGui", client.PlayerGui); notifGui.ResetOnSpawn = false
local function notify(text, col)
	col = col or Color3.fromRGB(57, 57, 57)
	local f = Instance.new("Frame", notifGui)
	f.Size = UDim2.new(0, 250, 0, 45)
	f.Position = UDim2.new(1, 10, 0.9, 0)
	f.BackgroundColor3 = col
	f.BorderSizePixel = 0
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(1, -10, 1, -10)
	l.Position = UDim2.new(0, 5, 0, 5)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.GothamBold
	l.TextSize = 16
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextWrapped = true
	TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(1, -260, 0.9, 0)}):Play()
	task.spawn(function()
		task.wait(4.5)
		TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(1, 10, 0.9, 0)}):Play()
		task.wait(0.5)
		f:Destroy()
	end)
end

---------------------------------------------------------------- SPIN
local spinData = {}
local function spin(p, speed)
	if spinData[p] then return end
	local hrp = getHRP(p)
	if not hrp then return end
	speed = tonumber(speed) or 30
	local av = Instance.new("AngularVelocity", hrp)
	av.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	av.AngularVelocity = Vector3.new(0, math.rad(speed), 0)
	av.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	spinData[p] = av
	notify("Spinning at " .. speed, Color3.fromRGB(0, 170, 255))
end
local function unspin(p)
	local av = spinData[p]
	if av then av:Destroy(); spinData[p] = nil; notify("Spin stopped") end
end

---------------------------------------------------------------- FOV
local function setFOV(num)
	local cam = workspace.CurrentCamera
	local fov = tonumber(num)
	if not fov then notify("Invalid FOV", Color3.fromRGB(255, 0, 0)); return end
	fov = math.clamp(fov, 1, 120)
	cam.FieldOfView = fov
	notify("FOV set to " .. fov, Color3.fromRGB(0, 170, 255))
end

---------------------------------------------------------------- KILL
local function killPlayer(p)
	if not p then return end
	local char = p.Character
	if char then char:BreakJoints() end
end

---------------------------------------------------------------- FLY
local flyData = {}
local function fly(p, spd)
	if flyData[p] or not getHRP(p) then return end
	spd = tonumber(spd) or 50
	local hrp = getHRP(p)
	local cam = workspace.CurrentCamera
	local bg = Instance.new("BodyGyro", hrp)
	bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	local bv = Instance.new("BodyVelocity", hrp)
	bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	flyData[p] = {bg = bg, bv = bv, s = spd}
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
		bv.Velocity = dir.Unit * (dir.Magnitude > 0 and flyData[p].s or 0)
		bg.CFrame = cf
	end
	RunService:BindToRenderStep("FreeFly"..p.Name, 200, step)
end
local function unfly(p)
	local t = flyData[p]
	if t then t.bg:Destroy(); t.bv:Destroy(); flyData[p] = nil; RunService:UnbindFromRenderStep("FreeFly"..p.Name) end
end

---------------------------------------------------------------- SPEED
local function setspeed(p, n)
	local hum = getHum(p) if not hum then return end
	if not hum:FindFirstChild("CustSpeed") then Instance.new("NumberValue", hum).Name = "CustSpeed" end
	hum.CustSpeed.Value = tonumber(n) or 16; hum.WalkSpeed = hum.CustSpeed.Value
end
local function resetspeed(p)
	local hum = getHum(p) if not hum then return end
	if hum:FindFirstChild("CustSpeed") then hum.CustSpeed:Destroy() end
	hum.WalkSpeed = 16
end

---------------------------------------------------------------- NOCLIP
local noclip = {}
local function setnoclip(p, on)
	local char = p.Character if not char then return end
	if noclip[p] then noclip[p]:Disconnect(); noclip[p] = nil end
	if on then
		noclip[p] = RunService.Stepped:Connect(function()
			for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
		end)
	else
		for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end
	end
end

---------------------------------------------------------------- ESP
local espt = {}
local function unesp(p)
	local t = espt[p] if not t then return end
	for _, v in pairs(t) do v:Destroy() end; espt[p] = nil
end
local function esp(p)
	if espt[p] then return end
	local t = {}; espt[p] = t
	local function build(ch)
		if not ch then return end
		local box = Instance.new("BoxHandleAdornment")
		box.Adornee = getHRP(p) or ch:FindFirstChild("Head")
		box.Size, box.Color3, box.AlwaysOnTop = Vector3.new(2, 3, 2), Color3.new(1, 0, 0), true
		box.ZIndex, box.Parent = 5, ch
		table.insert(t, box)
		local bbg = Instance.new("BillboardGui")
		bbg.Size, bbg.AlwaysOnTop, bbg.Adornee = UDim2.new(0, 200, 0, 50), true, box.Adornee
		bbg.StudsOffset = Vector3.new(0, 3, 0)
		local txt = Instance.new("TextLabel", bbg)
		txt.Size, txt.Text, txt.TextScaled = UDim2.new(1, 0, 1, 0), p.Name, true
		txt.BackgroundTransparency, txt.TextColor3 = 1, Color3.new(1, 1, 1)
		bbg.Parent = ch; table.insert(t, bbg)
	end
	build(p.Character)
	local added; added = p.CharacterAdded:Connect(function(ch) build(ch) end); table.insert(t, added)
end
local function espall() for _, v in ipairs(Players:GetPlayers()) do esp(v) end end
local function unespall() for _, v in ipairs(Players:GetPlayers()) do unesp(v) end end

---------------------------------------------------------------- HEAL
local function heal(p)
	local hum = getHum(p) if hum then hum.Health = hum.MaxHealth end
end

---------------------------------------------------------------- TP
local function tp(p1, p2)
	local h1, h2 = getHRP(p1), getHRP(p2)
	if h1 and h2 then h1.CFrame = h2.CFrame + Vector3.new(0, 2, 0) end
end
local function bring(to, tgt) tp(tgt, to) end
local function goto(me, tgt) tp(me, tgt) end
local function tpall()
	for _, v in ipairs(Players:GetPlayers()) do if v ~= client then tp(v, client) end end
end

---------------------------------------------------------------- MISC
local function jumppower(p, pow)
	local hum = getHum(p) if hum then hum.UseJumpPower = true; hum.JumpPower = tonumber(pow) or 50 end
end
local function sit(p)
	local hum = getHum(p) if hum then hum.Sit = true end
end
local function lay(p)
	local hum = getHum(p) if hum then hum.Sit = true; getHRP(p).CFrame = getHRP(p).CFrame * CFrame.Angles(math.pi/2, 0, 0) end
end

---------------------------------------------------------------- FREEZE
local frozen = {}
local function freeze(p)
	local hum = getHum(p) if not hum or frozen[p] then return end
	frozen[p] = {ws = hum.WalkSpeed, jp = hum.JumpPower, jh = hum.JumpHeight}
	hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = 0, 0, 0
end
local function unfreeze(p)
	local t = frozen[p]; local hum = getHum(p)
	if t and hum then hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = t.ws, t.jp, t.jh; frozen[p] = nil end
end

---------------------------------------------------------------- GOD
local gods = {}
local function god(p)
	if gods[p] then return end
	local hum = getHum(p) if not hum then return end
	gods[p] = hum.HealthChanged:Connect(function() if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end end)
end
local function ungod(p)
	local c = gods[p] if c then c:Disconnect(); gods[p] = nil end
end

---------------------------------------------------------------- INVIS
local invis = {}
local function invisP(p)
	if invis[p] or not p.Character then return end
	for _, v in ipairs(p.Character:GetChildren()) do if v:IsA("BasePart") then v.Transparency = 1 end end
	invis[p] = true
end
local function visP(p)
	if not invis[p] or not p.Character then return end
	for _, v in ipairs(p.Character:GetChildren()) do if v:IsA("BasePart") then v.Transparency = 0 end end
	invis[p] = nil
end

---------------------------------------------------------------- FLING
local function fling(p)
	local hrp = getHRP(p) if not hrp then return end
	local v = Instance.new("BodyVelocity", hrp)
	v.MaxForce, v.Velocity = Vector3.new(1e6, 1e6, 1e6), Vector3.new(math.random(-2e4, 2e4), 2e4, math.random(-2e4, 2e4))
	task.wait(0.25); v:Destroy()
end

---------------------------------------------------------------- REJOIN
local function rejoin() TeleportService:Teleport(game.PlaceId, client) end

---------------------------------------------------------------- PING
local function showPing()
	local ping = tonumber(string.format("%.0f", client:GetNetworkPing() * 1000))
	notify("Ping: " .. ping .. " ms", Color3.fromRGB(0, 170, 255))
end

---------------------------------------------------------------- STOPWATCH
local stopGui = nil
local function toggleStopwatch()
	if stopGui then stopGui:Destroy(); stopGui = nil; return end
	stopGui = Instance.new("ScreenGui", client.PlayerGui); stopGui.ResetOnSpawn = false
	local f = Instance.new("Frame", stopGui)
	f.Size = UDim2.new(0, 200, 0, 100)
	f.Position = UDim2.new(1, 10, 0.5, -50)
	f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	f.BorderSizePixel = 0
	f.Active = true
	local drag = Instance.new("LocalScript", f)
	drag.Source = [[
		local f = script.Parent
		local uis = game:GetService("UserInputService")
		local dragging, dragInput, dragStart, startPos
		f.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; dragStart = input.Position; startPos = f.Position
				input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		f.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
		uis.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	]]
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	local x = Instance.new("TextButton", f)
	x.Size = UDim2.new(0, 20, 0, 20)
	x.Position = UDim2.new(1, -22, 0, 2)
	x.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	x.Text = "X"
	x.Font = Enum.Font.GothamBold
	x.TextSize = 14
	x.TextColor3 = Color3.white
	x.AutoButtonColor = false
	Instance.new("UICorner", x).CornerRadius = UDim.new(0, 4)
	x.MouseButton1Click:Connect(function() stopGui:Destroy(); stopGui = nil end)
	local lbl = Instance.new("TextLabel", f)
	lbl.Size = UDim2.new(1, -10, 1, -30)
	lbl.Position = UDim2.new(0, 5, 0, 25)
	lbl.BackgroundTransparency = 1
	lbl.Text = "0.00"
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 28
	lbl.TextColor3 = Color3.new(1, 1, 1)
	local start = os.clock()
	local con = RunService.Heartbeat:Connect(function()
		if not stopGui then con:Disconnect(); return end
		lbl.Text = string.format("%.2f", os.clock() - start)
	end)
	TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(1, -210, 0.5, -50)}):Play()
end

---------------------------------------------------------------- CLICK TP
local clickTP = false
local function toggleClickTP()
	clickTP = not clickTP
	notify("Click TP " .. (clickTP and "ON" or "OFF"))
end
Mouse.Button1Down:Connect(function()
	if not clickTP then return end
	local target = Mouse.Target
	if target and target:IsA("BasePart") then
		local hrp = getHRP(client)
		if hrp then hrp.CFrame = Mouse.Hit * CFrame.new(0, 3, 0) end
	end
end)

---------------------------------------------------------------- CONSOLE
local function openConsole()
	StarterGui:SetCore("DevConsoleVisible", true)
end

---------------------------------------------------------------- CHAT-LOGS PANEL
local logsGui = nil
local function toggleLogs()
	if logsGui then logsGui:Destroy(); logsGui = nil; return end
	logsGui = Instance.new("ScreenGui", client.PlayerGui); logsGui.ResetOnSpawn = false
	local f = Instance.new("Frame", logsGui)
	f.Size = UDim2.new(0, 400, 0, 300)
	f.Position = UDim2.new(0.5, -200, 0.5, -150)
	f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	f.Active = true
	local drag = Instance.new("LocalScript", f)
	drag.Source = [[
		local f = script.Parent
		local uis = game:GetService("UserInputService")
		local dragging, dragInput, dragStart, startPos
		f.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; dragStart = input.Position; startPos = f.Position
				input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		f.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
		uis.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	]]
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	local top = Instance.new("TextLabel", f)
	top.Size = UDim2.new(1, 0, 0, 30)
	top.BackgroundTransparency = 1
	top.Text = "Chat Logs"
	top.Font = Enum.Font.GothamBold
	top.TextSize = 18
	top.TextColor3 = Color3.new(1, 1, 1)
	local close = Instance.new("TextButton", f)
	close.Size = UDim2.new(0, 22, 0, 22)
	close.Position = UDim2.new(1, -25, 0, 3)
	close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	close.Text = "X"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.TextColor3 = Color3.new(1, 1, 1)
	close.AutoButtonColor = false
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
	close.MouseButton1Click:Connect(function() logsGui:Destroy(); logsGui = nil end)
	local search = Instance.new("TextBox", f)
	search.Size = UDim2.new(1, -10, 0, 25)
	search.Position = UDim2.new(0, 5, 0, 32)
	search.PlaceholderText = "Search..."
	search.Font = Enum.Font.Gotham
	search.TextSize = 14
	search.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	search.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", search)
	local list = Instance.new("ScrollingFrame", f)
	list.Position = UDim2.new(0, 5, 0, 62)
	list.Size = UDim2.new(1, -10, 1, -67)
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.ScrollBarThickness = 6
	list.BackgroundTransparency = 1
	local uiGrid = Instance.new("UIGridLayout", list)
	uiGrid.CellSize = UDim2.new(1, 0, 0, 20)
	uiGrid.SortOrder = Enum.SortOrder.LayoutOrder
	local lbls = {}
	local function addLog(sender, msg)
		local str = string.format("[%s]: %s", sender, msg)
		local l = Instance.new("TextLabel")
		l.Size = uiGrid.CellSize
		l.BackgroundTransparency = 1
		l.Text = str
		l.Font = Enum.Font.Gotham
		l.TextSize = 14
		l.TextColor3 = Color3.new(1, 1, 1)
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Parent = list
		table.insert(lbls, l)
		list.CanvasSize = UDim2.new(0, 0, 0, #lbls * uiGrid.CellSize.Y.Offset)
	end
	search:GetPropertyChangedSignal("Text"):Connect(function()
		local filter = search.Text:lower()
		for _, v in ipairs(lbls) do
			v.Visible = filter == "" or v.Text:lower():find(filter)
		end
	end)
	-- catch future messages
	local function hookChannel(chan)
		chan.OnIncomingMessage = function(m)
			addLog(m.TextSource and m.TextSource.Name or "???", m.Text or "")
			return m
		end
	end
	for _, chan in ipairs(TextChatService:WaitForChild("TextChannels"):GetChildren()) do
		hookChannel(chan)
	end
	TextChatService:WaitForChild("TextChannels").ChildAdded:Connect(hookChannel)
	notify("Chat-logs panel opened")
end

---------------------------------------------------------------- RAGDOLL (fixed: keep collisions)
local ragData = {}
local function ragdoll(p)
	if ragData[p] or not p.Character then return end
	local char = p.Character
	ragData[p] = {}
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("Motor6D") then
			local socket = Instance.new("BallSocketConstraint")
			socket.Name = "RagSocket"
			socket.Attachment0 = v.Part0:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", v.Part0)
			socket.Attachment1 = v.Part1:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", v.Part1)
			socket.Parent = v.Part0
			v.Enabled = false
			table.insert(ragData[p], v)
		end
	end
	-- make sure parts stay collidable
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then v.CanCollide = true end
	end
	local hum = getHum(p)
	if hum then hum.PlatformStand = true; hum.AutoRotate = false end
	notify("Ragdolled", Color3.fromRGB(255, 0, 0))
end
local function unragdoll(p)
	if not ragData[p] or not p.Character then return end
	local char = p.Character
	for _, mot in ipairs(ragData[p]) do
		if mot and mot.Parent then
			mot.Enabled = true
			local socket = mot.Part0:FindFirstChild("RagSocket")
			if socket then socket:Destroy() end
		end
	end
	ragData[p] = nil
	local hum = getHum(p)
	if hum then hum.PlatformStand = false; hum.AutoRotate = true end
	notify("Un-ragdolled", Color3.fromRGB(0, 255, 0))
end

---------------------------------------------------------------- COMMAND PROCESSOR
local function processCmd(msg)
	if msg:sub(1, 1) ~= prefix then return end
	local args = msg:sub(2):split(" ")
	local cmd  = table.remove(args, 1):lower()
	notify("!" .. cmd, Color3.fromRGB(60, 60, 60))

	if cmd == "cmds" then
		-- toggle built-in cmd list GUI
		local gui = client.PlayerGui:FindFirstChild("LunarGui")
		if gui then gui.Enabled = not gui.Enabled end
	elseif cmd == "rejoin" then rejoin()
	elseif cmd == "kill" then
		local name = args[1] or ""
		if name:lower() == "all" then for _, p in ipairs(Players:GetPlayers()) do killPlayer(p) end
		else local tgt = getPlr(name); if tgt then killPlayer(tgt) end end
	elseif cmd == "fly" then fly(getPlr(args[1]), args[2])
	elseif cmd == "unfly" then unfly(getPlr(args[1]))
	elseif cmd == "speed" then setspeed(getPlr(args[1]), args[2])
	elseif cmd == "resetspeed" then resetspeed(getPlr(args[1]))
	elseif cmd == "noclip" then setnoclip(getPlr(args[1]), true)
	elseif cmd == "clip" then setnoclip(getPlr(args[1]), false)
	elseif cmd == "esp" then
		local tgt = args[1] or ""
		if tgt:lower() == "all" then espall() else esp(getPlr(tgt)) end
	elseif cmd == "unesp" then
		local tgt = args[1] or ""
		if tgt:lower() == "all" then unespall() else unesp(getPlr(tgt)) end
	elseif cmd == "heal" then heal(getPlr(args[1]))
	elseif cmd == "tp" then tp(getPlr(args[1]), getPlr(args[2]))
	elseif cmd == "bring" then bring(client, getPlr(args[1]))
	elseif cmd == "to" then goto(client, getPlr(args[1]))
	elseif cmd == "tpall" then tpall()
	elseif cmd == "jump" then jumppower(client, args[1])
	elseif cmd == "sit" then sit(client)
	elseif cmd == "lay" then lay(client)
	elseif cmd == "freeze" then freeze(getPlr(args[1]))
	elseif cmd == "unfreeze" then unfreeze(getPlr(args[1]))
	elseif cmd == "god" then god(getPlr(args[1]))
	elseif cmd == "ungod" then ungod(getPlr(args[1]))
	elseif cmd == "invis" then invisP(getPlr(args[1]))
	elseif cmd == "vis" then visP(getPlr(args[1]))
	elseif cmd == "fling" then fling(getPlr(args[1]))
	elseif cmd == "ping" then showPing()
	elseif cmd == "stopwatch" then toggleStopwatch()
	elseif cmd == "clickTP" then toggleClickTP()
	elseif cmd == "ragdoll" then ragdoll(client)
	elseif cmd == "unragdoll" then unragdoll(client)
	elseif cmd == "spin" then spin(client, args[1])
	elseif cmd == "unspin" then unspin(client)
	elseif cmd == "console" then openConsole()
	elseif cmd == "logs" then toggleLogs()
	elseif cmd == "fov" then setFOV(args[1])
	elseif cmd == "kick" then
		local tgt = getPlr(args[1])
		if tgt == client then
			client:Kick("Kicked by Lunar Admin")
		else
			notify("Kick only works on yourself (LocalScript)", Color3.fromRGB(255, 170, 0))
		end
	end
end

-- private cmd box
local cmdBox = Instance.new("ScreenGui", client.PlayerGui); cmdBox.ResetOnSpawn = false
local frame = Instance.new("Frame", cmdBox)
frame.Size = UDim2.new(0, 250, 0, 40)
frame.Position = UDim2.new(1, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
local drag = Instance.new("LocalScript", frame)
drag.Source = [[
	local f = script.Parent
	local uis = game:GetService("UserInputService")
	local dragging, dragInput, dragStart, startPos
	f.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = f.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	f.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
]]
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(1, -10, 1, -10)
box.Position = UDim2.new(0, 5, 0, 5)
box.BackgroundTransparency = 1
box.PlaceholderText = "Type command here..."
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.TextColor3 = Color3.new(1, 1, 1)
box.ClearTextOnFocus = false
box.FocusLost:Connect(function(enter)
	if not enter then return end
	local msg = box.Text
	box.Text = ""
	processCmd(msg)
end)
TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(1, -260, 0.2, 0)}):Play()

-- chat handler
client.Chatted:Connect(processCmd)

-- hot-key for cmd list
UserInputService.InputBegan:Connect(function(i, g)
	if not g and i.KeyCode == Enum.KeyCode.RightShift then
		local gui = client.PlayerGui:FindFirstChild("LunarGui")
		if gui then gui.Enabled = not gui.Enabled end
	end
end)

-- load msg
---------------------------------------------------------------- CMD-LIST GUI (named "LunarGui" so toggle works)
local gui = Instance.new("ScreenGui", client.PlayerGui)
gui.Name = "LunarGui"
gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(1, 40, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Active = true
main.Draggable = true
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
	for _, v in ipairs(lbls) do v:Destroy() end
	lbls = {}
	local y = 0
	for _, cmd in ipairs(cmds) do
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

gui.Enabled = false   -- start hidden

---------------------------------------------------------------- LOAD MSG
task.spawn(function()
	local chan = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
	chan:SendAsync("Admin loaded – !cmds for list – Created By @xLunarxZzRbxx")
end)--  Lunar Admin  |  prefix : !
--  cleaned + spin + unspin + console + logs + ragdoll fix
---------------------------------------------------------------- SERVICES
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local TeleportService= game:GetService("TeleportService")
local UserInputService= game:GetService("UserInputService")
local TextChatService= game:GetService("TextChatService")
local StarterGui     = game:GetService("StarterGui")

local client = Players.LocalPlayer
local Mouse = client:GetMouse()
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
	"!rejoin","!cmds","!ping","!stopwatch","!clickTP",
	"!fov [1-120]","!kick [plr]",
	"!ragdoll","!unragdoll",
	"!spin [num]","!unspin",
	"!console","!logs"
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

---------------------------------------------------------------- NOTIFICATION
local notifGui = Instance.new("ScreenGui", client.PlayerGui); notifGui.ResetOnSpawn = false
local function notify(text, col)
	col = col or Color3.fromRGB(57, 57, 57)
	local f = Instance.new("Frame", notifGui)
	f.Size = UDim2.new(0, 250, 0, 45)
	f.Position = UDim2.new(1, 10, 0.9, 0)
	f.BackgroundColor3 = col
	f.BorderSizePixel = 0
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(1, -10, 1, -10)
	l.Position = UDim2.new(0, 5, 0, 5)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.GothamBold
	l.TextSize = 16
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextWrapped = true
	TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(1, -260, 0.9, 0)}):Play()
	task.spawn(function()
		task.wait(4.5)
		TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(1, 10, 0.9, 0)}):Play()
		task.wait(0.5)
		f:Destroy()
	end)
end

---------------------------------------------------------------- SPIN
local spinData = {}
local function spin(p, speed)
	if spinData[p] then return end
	local hrp = getHRP(p)
	if not hrp then return end
	speed = tonumber(speed) or 30
	local av = Instance.new("AngularVelocity", hrp)
	av.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	av.AngularVelocity = Vector3.new(0, math.rad(speed), 0)
	av.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	spinData[p] = av
	notify("Spinning at " .. speed, Color3.fromRGB(0, 170, 255))
end
local function unspin(p)
	local av = spinData[p]
	if av then av:Destroy(); spinData[p] = nil; notify("Spin stopped") end
end

---------------------------------------------------------------- FOV
local function setFOV(num)
	local cam = workspace.CurrentCamera
	local fov = tonumber(num)
	if not fov then notify("Invalid FOV", Color3.fromRGB(255, 0, 0)); return end
	fov = math.clamp(fov, 1, 120)
	cam.FieldOfView = fov
	notify("FOV set to " .. fov, Color3.fromRGB(0, 170, 255))
end

---------------------------------------------------------------- KILL
local function killPlayer(p)
	if not p then return end
	local char = p.Character
	if char then char:BreakJoints() end
end

---------------------------------------------------------------- FLY
local flyData = {}
local function fly(p, spd)
	if flyData[p] or not getHRP(p) then return end
	spd = tonumber(spd) or 50
	local hrp = getHRP(p)
	local cam = workspace.CurrentCamera
	local bg = Instance.new("BodyGyro", hrp)
	bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	local bv = Instance.new("BodyVelocity", hrp)
	bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	flyData[p] = {bg = bg, bv = bv, s = spd}
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
		bv.Velocity = dir.Unit * (dir.Magnitude > 0 and flyData[p].s or 0)
		bg.CFrame = cf
	end
	RunService:BindToRenderStep("FreeFly"..p.Name, 200, step)
end
local function unfly(p)
	local t = flyData[p]
	if t then t.bg:Destroy(); t.bv:Destroy(); flyData[p] = nil; RunService:UnbindFromRenderStep("FreeFly"..p.Name) end
end

---------------------------------------------------------------- SPEED
local function setspeed(p, n)
	local hum = getHum(p) if not hum then return end
	if not hum:FindFirstChild("CustSpeed") then Instance.new("NumberValue", hum).Name = "CustSpeed" end
	hum.CustSpeed.Value = tonumber(n) or 16; hum.WalkSpeed = hum.CustSpeed.Value
end
local function resetspeed(p)
	local hum = getHum(p) if not hum then return end
	if hum:FindFirstChild("CustSpeed") then hum.CustSpeed:Destroy() end
	hum.WalkSpeed = 16
end

---------------------------------------------------------------- NOCLIP
local noclip = {}
local function setnoclip(p, on)
	local char = p.Character if not char then return end
	if noclip[p] then noclip[p]:Disconnect(); noclip[p] = nil end
	if on then
		noclip[p] = RunService.Stepped:Connect(function()
			for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
		end)
	else
		for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end
	end
end

---------------------------------------------------------------- ESP
local espt = {}
local function unesp(p)
	local t = espt[p] if not t then return end
	for _, v in pairs(t) do v:Destroy() end; espt[p] = nil
end
local function esp(p)
	if espt[p] then return end
	local t = {}; espt[p] = t
	local function build(ch)
		if not ch then return end
		local box = Instance.new("BoxHandleAdornment")
		box.Adornee = getHRP(p) or ch:FindFirstChild("Head")
		box.Size, box.Color3, box.AlwaysOnTop = Vector3.new(2, 3, 2), Color3.new(1, 0, 0), true
		box.ZIndex, box.Parent = 5, ch
		table.insert(t, box)
		local bbg = Instance.new("BillboardGui")
		bbg.Size, bbg.AlwaysOnTop, bbg.Adornee = UDim2.new(0, 200, 0, 50), true, box.Adornee
		bbg.StudsOffset = Vector3.new(0, 3, 0)
		local txt = Instance.new("TextLabel", bbg)
		txt.Size, txt.Text, txt.TextScaled = UDim2.new(1, 0, 1, 0), p.Name, true
		txt.BackgroundTransparency, txt.TextColor3 = 1, Color3.new(1, 1, 1)
		bbg.Parent = ch; table.insert(t, bbg)
	end
	build(p.Character)
	local added; added = p.CharacterAdded:Connect(function(ch) build(ch) end); table.insert(t, added)
end
local function espall() for _, v in ipairs(Players:GetPlayers()) do esp(v) end end
local function unespall() for _, v in ipairs(Players:GetPlayers()) do unesp(v) end end

---------------------------------------------------------------- HEAL
local function heal(p)
	local hum = getHum(p) if hum then hum.Health = hum.MaxHealth end
end

---------------------------------------------------------------- TP
local function tp(p1, p2)
	local h1, h2 = getHRP(p1), getHRP(p2)
	if h1 and h2 then h1.CFrame = h2.CFrame + Vector3.new(0, 2, 0) end
end
local function bring(to, tgt) tp(tgt, to) end
local function goto(me, tgt) tp(me, tgt) end
local function tpall()
	for _, v in ipairs(Players:GetPlayers()) do if v ~= client then tp(v, client) end end
end

---------------------------------------------------------------- MISC
local function jumppower(p, pow)
	local hum = getHum(p) if hum then hum.UseJumpPower = true; hum.JumpPower = tonumber(pow) or 50 end
end
local function sit(p)
	local hum = getHum(p) if hum then hum.Sit = true end
end
local function lay(p)
	local hum = getHum(p) if hum then hum.Sit = true; getHRP(p).CFrame = getHRP(p).CFrame * CFrame.Angles(math.pi/2, 0, 0) end
end

---------------------------------------------------------------- FREEZE
local frozen = {}
local function freeze(p)
	local hum = getHum(p) if not hum or frozen[p] then return end
	frozen[p] = {ws = hum.WalkSpeed, jp = hum.JumpPower, jh = hum.JumpHeight}
	hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = 0, 0, 0
end
local function unfreeze(p)
	local t = frozen[p]; local hum = getHum(p)
	if t and hum then hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = t.ws, t.jp, t.jh; frozen[p] = nil end
end

---------------------------------------------------------------- GOD
local gods = {}
local function god(p)
	if gods[p] then return end
	local hum = getHum(p) if not hum then return end
	gods[p] = hum.HealthChanged:Connect(function() if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end end)
end
local function ungod(p)
	local c = gods[p] if c then c:Disconnect(); gods[p] = nil end
end

---------------------------------------------------------------- INVIS
local invis = {}
local function invisP(p)
	if invis[p] or not p.Character then return end
	for _, v in ipairs(p.Character:GetChildren()) do if v:IsA("BasePart") then v.Transparency = 1 end end
	invis[p] = true
end
local function visP(p)
	if not invis[p] or not p.Character then return end
	for _, v in ipairs(p.Character:GetChildren()) do if v:IsA("BasePart") then v.Transparency = 0 end end
	invis[p] = nil
end

---------------------------------------------------------------- FLING
local function fling(p)
	local hrp = getHRP(p) if not hrp then return end
	local v = Instance.new("BodyVelocity", hrp)
	v.MaxForce, v.Velocity = Vector3.new(1e6, 1e6, 1e6), Vector3.new(math.random(-2e4, 2e4), 2e4, math.random(-2e4, 2e4))
	task.wait(0.25); v:Destroy()
end

---------------------------------------------------------------- REJOIN
local function rejoin() TeleportService:Teleport(game.PlaceId, client) end

---------------------------------------------------------------- PING
local function showPing()
	local ping = tonumber(string.format("%.0f", client:GetNetworkPing() * 1000))
	notify("Ping: " .. ping .. " ms", Color3.fromRGB(0, 170, 255))
end

---------------------------------------------------------------- STOPWATCH
local stopGui = nil
local function toggleStopwatch()
	if stopGui then stopGui:Destroy(); stopGui = nil; return end
	stopGui = Instance.new("ScreenGui", client.PlayerGui); stopGui.ResetOnSpawn = false
	local f = Instance.new("Frame", stopGui)
	f.Size = UDim2.new(0, 200, 0, 100)
	f.Position = UDim2.new(1, 10, 0.5, -50)
	f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	f.BorderSizePixel = 0
	f.Active = true
	local drag = Instance.new("LocalScript", f)
	drag.Source = [[
		local f = script.Parent
		local uis = game:GetService("UserInputService")
		local dragging, dragInput, dragStart, startPos
		f.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; dragStart = input.Position; startPos = f.Position
				input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		f.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
		uis.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	]]
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	local x = Instance.new("TextButton", f)
	x.Size = UDim2.new(0, 20, 0, 20)
	x.Position = UDim2.new(1, -22, 0, 2)
	x.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	x.Text = "X"
	x.Font = Enum.Font.GothamBold
	x.TextSize = 14
	x.TextColor3 = Color3.white
	x.AutoButtonColor = false
	Instance.new("UICorner", x).CornerRadius = UDim.new(0, 4)
	x.MouseButton1Click:Connect(function() stopGui:Destroy(); stopGui = nil end)
	local lbl = Instance.new("TextLabel", f)
	lbl.Size = UDim2.new(1, -10, 1, -30)
	lbl.Position = UDim2.new(0, 5, 0, 25)
	lbl.BackgroundTransparency = 1
	lbl.Text = "0.00"
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 28
	lbl.TextColor3 = Color3.new(1, 1, 1)
	local start = os.clock()
	local con = RunService.Heartbeat:Connect(function()
		if not stopGui then con:Disconnect(); return end
		lbl.Text = string.format("%.2f", os.clock() - start)
	end)
	TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(1, -210, 0.5, -50)}):Play()
end

---------------------------------------------------------------- CLICK TP
local clickTP = false
local function toggleClickTP()
	clickTP = not clickTP
	notify("Click TP " .. (clickTP and "ON" or "OFF"))
end
Mouse.Button1Down:Connect(function()
	if not clickTP then return end
	local target = Mouse.Target
	if target and target:IsA("BasePart") then
		local hrp = getHRP(client)
		if hrp then hrp.CFrame = Mouse.Hit * CFrame.new(0, 3, 0) end
	end
end)

---------------------------------------------------------------- CONSOLE
local function openConsole()
	StarterGui:SetCore("DevConsoleVisible", true)
end

---------------------------------------------------------------- CHAT-LOGS PANEL
local logsGui = nil
local function toggleLogs()
	if logsGui then logsGui:Destroy(); logsGui = nil; return end
	logsGui = Instance.new("ScreenGui", client.PlayerGui); logsGui.ResetOnSpawn = false
	local f = Instance.new("Frame", logsGui)
	f.Size = UDim2.new(0, 400, 0, 300)
	f.Position = UDim2.new(0.5, -200, 0.5, -150)
	f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	f.Active = true
	local drag = Instance.new("LocalScript", f)
	drag.Source = [[
		local f = script.Parent
		local uis = game:GetService("UserInputService")
		local dragging, dragInput, dragStart, startPos
		f.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; dragStart = input.Position; startPos = f.Position
				input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		f.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
		uis.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	]]
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	local top = Instance.new("TextLabel", f)
	top.Size = UDim2.new(1, 0, 0, 30)
	top.BackgroundTransparency = 1
	top.Text = "Chat Logs"
	top.Font = Enum.Font.GothamBold
	top.TextSize = 18
	top.TextColor3 = Color3.new(1, 1, 1)
	local close = Instance.new("TextButton", f)
	close.Size = UDim2.new(0, 22, 0, 22)
	close.Position = UDim2.new(1, -25, 0, 3)
	close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	close.Text = "X"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.TextColor3 = Color3.new(1, 1, 1)
	close.AutoButtonColor = false
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
	close.MouseButton1Click:Connect(function() logsGui:Destroy(); logsGui = nil end)
	local search = Instance.new("TextBox", f)
	search.Size = UDim2.new(1, -10, 0, 25)
	search.Position = UDim2.new(0, 5, 0, 32)
	search.PlaceholderText = "Search..."
	search.Font = Enum.Font.Gotham
	search.TextSize = 14
	search.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	search.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", search)
	local list = Instance.new("ScrollingFrame", f)
	list.Position = UDim2.new(0, 5, 0, 62)
	list.Size = UDim2.new(1, -10, 1, -67)
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.ScrollBarThickness = 6
	list.BackgroundTransparency = 1
	local uiGrid = Instance.new("UIGridLayout", list)
	uiGrid.CellSize = UDim2.new(1, 0, 0, 20)
	uiGrid.SortOrder = Enum.SortOrder.LayoutOrder
	local lbls = {}
	local function addLog(sender, msg)
		local str = string.format("[%s]: %s", sender, msg)
		local l = Instance.new("TextLabel")
		l.Size = uiGrid.CellSize
		l.BackgroundTransparency = 1
		l.Text = str
		l.Font = Enum.Font.Gotham
		l.TextSize = 14
		l.TextColor3 = Color3.new(1, 1, 1)
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Parent = list
		table.insert(lbls, l)
		list.CanvasSize = UDim2.new(0, 0, 0, #lbls * uiGrid.CellSize.Y.Offset)
	end
	search:GetPropertyChangedSignal("Text"):Connect(function()
		local filter = search.Text:lower()
		for _, v in ipairs(lbls) do
			v.Visible = filter == "" or v.Text:lower():find(filter)
		end
	end)
	-- catch future messages
	local function hookChannel(chan)
		chan.OnIncomingMessage = function(m)
			addLog(m.TextSource and m.TextSource.Name or "???", m.Text or "")
			return m
		end
	end
	for _, chan in ipairs(TextChatService:WaitForChild("TextChannels"):GetChildren()) do
		hookChannel(chan)
	end
	TextChatService:WaitForChild("TextChannels").ChildAdded:Connect(hookChannel)
	notify("Chat-logs panel opened")
end

---------------------------------------------------------------- RAGDOLL (fixed: keep collisions)
local ragData = {}
local function ragdoll(p)
	if ragData[p] or not p.Character then return end
	local char = p.Character
	ragData[p] = {}
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("Motor6D") then
			local socket = Instance.new("BallSocketConstraint")
			socket.Name = "RagSocket"
			socket.Attachment0 = v.Part0:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", v.Part0)
			socket.Attachment1 = v.Part1:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", v.Part1)
			socket.Parent = v.Part0
			v.Enabled = false
			table.insert(ragData[p], v)
		end
	end
	-- make sure parts stay collidable
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then v.CanCollide = true end
	end
	local hum = getHum(p)
	if hum then hum.PlatformStand = true; hum.AutoRotate = false end
	notify("Ragdolled", Color3.fromRGB(255, 0, 0))
end
local function unragdoll(p)
	if not ragData[p] or not p.Character then return end
	local char = p.Character
	for _, mot in ipairs(ragData[p]) do
		if mot and mot.Parent then
			mot.Enabled = true
			local socket = mot.Part0:FindFirstChild("RagSocket")
			if socket then socket:Destroy() end
		end
	end
	ragData[p] = nil
	local hum = getHum(p)
	if hum then hum.PlatformStand = false; hum.AutoRotate = true end
	notify("Un-ragdolled", Color3.fromRGB(0, 255, 0))
end

---------------------------------------------------------------- COMMAND PROCESSOR
local function processCmd(msg)
	if msg:sub(1, 1) ~= prefix then return end
	local args = msg:sub(2):split(" ")
	local cmd  = table.remove(args, 1):lower()
	notify("!" .. cmd, Color3.fromRGB(60, 60, 60))

	if cmd == "cmds" then
		-- toggle built-in cmd list GUI
		local gui = client.PlayerGui:FindFirstChild("LunarGui")
		if gui then gui.Enabled = not gui.Enabled end
	elseif cmd == "rejoin" then rejoin()
	elseif cmd == "kill" then
		local name = args[1] or ""
		if name:lower() == "all" then for _, p in ipairs(Players:GetPlayers()) do killPlayer(p) end
		else local tgt = getPlr(name); if tgt then killPlayer(tgt) end end
	elseif cmd == "fly" then fly(getPlr(args[1]), args[2])
	elseif cmd == "unfly" then unfly(getPlr(args[1]))
	elseif cmd == "speed" then setspeed(getPlr(args[1]), args[2])
	elseif cmd == "resetspeed" then resetspeed(getPlr(args[1]))
	elseif cmd == "noclip" then setnoclip(getPlr(args[1]), true)
	elseif cmd == "clip" then setnoclip(getPlr(args[1]), false)
	elseif cmd == "esp" then
		local tgt = args[1] or ""
		if tgt:lower() == "all" then espall() else esp(getPlr(tgt)) end
	elseif cmd == "unesp" then
		local tgt = args[1] or ""
		if tgt:lower() == "all" then unespall() else unesp(getPlr(tgt)) end
	elseif cmd == "heal" then heal(getPlr(args[1]))
	elseif cmd == "tp" then tp(getPlr(args[1]), getPlr(args[2]))
	elseif cmd == "bring" then bring(client, getPlr(args[1]))
	elseif cmd == "to" then goto(client, getPlr(args[1]))
	elseif cmd == "tpall" then tpall()
	elseif cmd == "jump" then jumppower(client, args[1])
	elseif cmd == "sit" then sit(client)
	elseif cmd == "lay" then lay(client)
	elseif cmd == "freeze" then freeze(getPlr(args[1]))
	elseif cmd == "unfreeze" then unfreeze(getPlr(args[1]))
	elseif cmd == "god" then god(getPlr(args[1]))
	elseif cmd == "ungod" then ungod(getPlr(args[1]))
	elseif cmd == "invis" then invisP(getPlr(args[1]))
	elseif cmd == "vis" then visP(getPlr(args[1]))
	elseif cmd == "fling" then fling(getPlr(args[1]))
	elseif cmd == "ping" then showPing()
	elseif cmd == "stopwatch" then toggleStopwatch()
	elseif cmd == "clickTP" then toggleClickTP()
	elseif cmd == "ragdoll" then ragdoll(client)
	elseif cmd == "unragdoll" then unragdoll(client)
	elseif cmd == "spin" then spin(client, args[1])
	elseif cmd == "unspin" then unspin(client)
	elseif cmd == "console" then openConsole()
	elseif cmd == "logs" then toggleLogs()
	elseif cmd == "fov" then setFOV(args[1])
	elseif cmd == "kick" then
		local tgt = getPlr(args[1])
		if tgt == client then
			client:Kick("Kicked by Lunar Admin")
		else
			notify("Kick only works on yourself (LocalScript)", Color3.fromRGB(255, 170, 0))
		end
	end
end

-- private cmd box
local cmdBox = Instance.new("ScreenGui", client.PlayerGui); cmdBox.ResetOnSpawn = false
local frame = Instance.new("Frame", cmdBox)
frame.Size = UDim2.new(0, 250, 0, 40)
frame.Position = UDim2.new(1, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
local drag = Instance.new("LocalScript", frame)
drag.Source = [[
	local f = script.Parent
	local uis = game:GetService("UserInputService")
	local dragging, dragInput, dragStart, startPos
	f.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = f.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	f.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
]]
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(1, -10, 1, -10)
box.Position = UDim2.new(0, 5, 0, 5)
box.BackgroundTransparency = 1
box.PlaceholderText = "Type command here..."
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.TextColor3 = Color3.new(1, 1, 1)
box.ClearTextOnFocus = false
box.FocusLost:Connect(function(enter)
	if not enter then return end
	local msg = box.Text
	box.Text = ""
	processCmd(msg)
end)
TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(1, -260, 0.2, 0)}):Play()

-- chat handler
client.Chatted:Connect(processCmd)

-- hot-key for cmd list
UserInputService.InputBegan:Connect(function(i, g)
	if not g and i.KeyCode == Enum.KeyCode.RightShift then
		local gui = client.PlayerGui:FindFirstChild("LunarGui")
		if gui then gui.Enabled = not gui.Enabled end
	end
end)

-- load msg
---------------------------------------------------------------- CMD-LIST GUI (named "LunarGui" so toggle works)
local gui = Instance.new("ScreenGui", client.PlayerGui)
gui.Name = "LunarGui"
gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(1, 40, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Active = true
main.Draggable = true
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
	for _, v in ipairs(lbls) do v:Destroy() end
	lbls = {}
	local y = 0
	for _, cmd in ipairs(cmds) do
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

gui.Enabled = false   -- start hidden

---------------------------------------------------------------- LOAD MSG
task.spawn(function()
	local chan = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
	chan:SendAsync("Admin loaded – !cmds for list – Created By @xLunarxZzRbxx")
end)
