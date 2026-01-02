--  Lunar Admin  |  prefix : !
---------------------------------------------------------------- SERVICES
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local TeleportService= game:GetService("TeleportService")
local UserInputService= game:GetService("UserInputService")
local TextChatService= game:GetService("TextChatService")
local StarterGui     = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting       = game:GetService("Lighting")

local client = Players.LocalPlayer
local Mouse = client:GetMouse()
local prefix = "!"

-- global notify (everyone sees it)
local function globalNotify(text, col)
	col = col or Color3.fromRGB(57, 57, 57)
	for _,p in ipairs(Players:GetPlayers()) do
		local sg = p:FindFirstChild("PlayerGui")
		if sg then
			local f = Instance.new("Frame")
			f.Size = UDim2.new(0, 300, 0, 60)
			f.Position = UDim2.new(0.5, 0, 0.1, 0)
			f.AnchorPoint = Vector2.new(0.5, 0)
			f.BackgroundColor3 = col
			f.BorderSizePixel = 0
			f.Parent = sg
			Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(1, -10, 1, -10)
			l.Position = UDim2.new(0, 5, 0, 5)
			l.BackgroundTransparency = 1
			l.Text = text
			l.Font = Enum.Font.GothamBold
			l.TextSize = 18
			l.TextColor3 = Color3.new(1, 1, 1)
			l.TextWrapped = true
			l.Parent = f
			TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(0.5, 0, 0.05, 0)}):Play()
			task.spawn(function()
				task.wait(3)
				TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(0.5, 0, -0.1, 0)}):Play()
				task.wait(0.5)
				f:Destroy()
			end)
		end
	end
end

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
	"!console","!logs",
	"!disableFalldamage","!enable inventory","!enable playerlist",
	"-- FUN EXTRAS --",
	"!dance [plr]","!trip [plr]","!explode [plr]","!giant [plr]","!tiny [plr]",
	"!rainbow [plr]","!fire [plr]","!unfire [plr]","!smoke [plr]","!unsmoke [plr]",
	"!sparkles [plr]","!unsparkles [plr]","!rickroll [plr]","!loopjump [plr]","!unloopjump [plr]"
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

---------------------------------------------------------------- NOTIFICATION (local only)
local notifGui = Instance.new("ScreenGui", client.PlayerGui); notifGui.ResetOnSpawn = false
local function notify(text, col)
	col = col or Color3.fromRGB(57, 57, 57)
	local f = Instance.new("Frame", notifGui)
	f.Size = UDim2.new(0, 260, 0, 48)
	f.Position = UDim2.new(1, 10, 0.9, 0)
	f.BackgroundColor3 = col
	f.BorderSizePixel = 0
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(1, -10, 1, -10)
	l.Position = UDim2.new(0, 5, 0, 5)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.GothamBold
	l.TextSize = 16
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextWrapped = true
	TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(1, -270, 0.9, 0)}):Play()
	task.spawn(function()
		task.wait(4.5)
		TweenService:Create(f, TweenInfo.new(0.5), {Position = UDim2.new(1, 10, 0.9, 0)}):Play()
		task.wait(0.5)
		f:Destroy()
	end)
end

---------------------------------------------------------------- SPIN  (0-1000, stays until !unspin)
local spinData = {}
local function spin(p, speed)
	if spinData[p] then return end
	local hrp = getHRP(p)
	if not hrp then return end
	speed = math.clamp(tonumber(speed) or 30, 0, 1000)
	local att = hrp:FindFirstChild("SpinAtt") or Instance.new("Attachment", hrp)
	att.Name = "SpinAtt"
	local av = Instance.new("AngularVelocity")
	av.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	av.AngularVelocity = Vector3.new(0, math.rad(speed), 0)
	av.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	av.Attachment0 = att
	av.Parent = hrp
	spinData[p] = av
	notify("Spinning at " .. speed, Color3.fromRGB(0, 170, 255))
	globalNotify(p.Name .. " is spinning at " .. speed .. " rpm!", Color3.fromRGB(0, 170, 255))
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

---------------------------------------------------------------- KILL  (working)
local function killPlayer(p)
	if not p then return end
	local hum = getHum(p)
	if hum then hum.Health = 0 end
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
local function goto(me, tgt)
	local hMe = getHRP(me)
	local hTgt = getHRP(tgt)
	if not hMe or not hTgt then return end
	hMe.CFrame = hTgt.CFrame + Vector3.new(0, 3, 0)
	freeze(me)
	task.wait(1)
	unfreeze(me)
end
local function tpall()
	for _, v in ipairs(Players:GetPlayers()) do if v ~= client then tp(v, client) end end
end

---------------------------------------------------------------- MISC
local savedJump = 50
local function jumppower(p, pow)
	local hum = getHum(p) if not hum then return end
	pow = tonumber(pow)
	if pow then savedJump = pow end
	hum.UseJumpPower = true
	hum.JumpPower = savedJump
	notify("Jump-power set to "..savedJump)
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
	if not p then return end
	local hum = getHum(p)
	if not hum or frozen[p] then return end
	frozen[p] = {ws = hum.WalkSpeed, jp = hum.JumpPower, jh = hum.JumpHeight}
	hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = 0, 0, 0
end
local function unfreeze(p)
	local t = frozen[p]
	local hum = getHum(p)
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

---------------------------------------------------------------- CHAT-LOGS PANEL  (glass UI)
local logsGui = nil
local function toggleLogs()
	if logsGui then logsGui:Destroy(); logsGui = nil; return end

	logsGui = Instance.new("ScreenGui", client.PlayerGui); logsGui.ResetOnSpawn = false
	logsGui.Name = "LogsGui"
	local f = Instance.new("Frame", logsGui)
	f.Size = UDim2.new(0, 420, 0, 320)
	f.Position = UDim2.new(1, 40, 0.5, 220)
	f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	f.BackgroundTransparency = 0.2
	f.BorderSizePixel = 0
	f.Active = true
	f.Draggable = true
	-- glass gradient
	local grad = Instance.new("UIGradient", f)
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
	})
	grad.Rotation = 90
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
	TweenService:Create(f, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -430, 0.5, 220)}):Play()

	local top = Instance.new("TextLabel", f)
	top.Size = UDim2.new(1, 0, 0, 35)
	top.BackgroundTransparency = 1
	top.Text = "Chat Logs"
	top.Font = Enum.Font.GothamBold
	top.TextSize = 20
	top.TextColor3 = Color3.new(1, 1, 1)

	local close = Instance.new("TextButton", f)
	close.Size = UDim2.new(0, 24, 0, 24)
	close.Position = UDim2.new(1, -27, 0, 3)
	close.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
	close.AutoButtonColor = false
	close.Text = "X"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 16
	close.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
	close.MouseEnter:Connect(function() close.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end)
	close.MouseLeave:Connect(function() close.BackgroundColor3 = Color3.fromRGB(220, 20, 60) end)
	close.MouseButton1Click:Connect(function() logsGui:Destroy(); logsGui = nil end)

	local search = Instance.new("TextBox", f)
	search.Size = UDim2.new(1, -10, 0, 28)
	search.Position = UDim2.new(0, 5, 0, 38)
	search.PlaceholderText = "Search logs..."
	search.Font = Enum.Font.Gotham
	search.TextSize = 15
	search.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	search.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", search).CornerRadius = UDim.new(0, 6)

	local list = Instance.new("ScrollingFrame", f)
	list.Position = UDim2.new(0, 5, 0, 70)
	list.Size = UDim2.new(1, -10, 1, -75)
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.ScrollBarThickness = 6
	list.BackgroundTransparency = 1
	list.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
	local uiGrid = Instance.new("UIGridLayout", list)
	uiGrid.CellSize = UDim2.new(1, 0, 0, 22)
	uiGrid.SortOrder = Enum.SortOrder.LayoutOrder

	local lbls = {}
	-- chat capture (once)
	if not _G.logsHooked then
		_G.logsHooked = true
		TextChatService.MessageReceived:Connect(function(msg)
			local src = msg.TextSource
			local sender = src and (src.DisplayName or src.Name) or "???"
			local plain = (msg.Text or ""):gsub("<[^>]+>", ""):gsub("&nbsp;", " ")
			for _, screen in ipairs(Players:GetPlayers()) do
				local sg = screen:FindFirstChild("PlayerGui")
				if sg then
					for _, logs in ipairs(sg:GetChildren()) do
						if logs.Name == "LogsGui" then
							local list = logs:FindFirstChild("Frame", true):FindFirstChild("ScrollingFrame")
							if list then
								local uiGrid = list:FindFirstChildOfClass("UIGridLayout")
								local l = Instance.new("TextLabel")
								l.Size = uiGrid.CellSize
								l.BackgroundTransparency = 1
								l.Text = string.format("[%s]: %s", sender, plain)
								l.Font = Enum.Font.Gotham
								l.TextSize = 14
								l.TextColor3 = Color3.new(.95, .95, .95)
								l.TextXAlignment = Enum.TextXAlignment.Left
								l.RichText = true
								l.Parent = list
								list.CanvasSize = UDim2.new(0, 0, 0, #list:GetChildren() * uiGrid.CellSize.Y.Offset)
							end
						end
					end
				end
			end
		end)
	end
	notify("Chat-logs panel opened")
end

---------------------------------------------------------------- FALL-DAMAGE TOGGLE
local fallConn = nil
local function disableFalldamage()
	if fallConn then return end
	fallConn = client.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
	end)
	if client.Character then client.Character:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Landed, false) end
	notify("Fall-damage disabled", Color3.fromRGB(0, 170, 255))
	globalNotify(client.Name .. " disabled fall-damage!", Color3.fromRGB(0, 170, 255))
end

---------------------------------------------------------------- ENABLE TOGGLES
local function enableInventory(on)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, on)
	notify("Inventory " .. (on and "enabled" or "disabled"))
end
local function enablePlayerlist(on)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, on)
	notify("Player-list " .. (on and "enabled" or "disabled"))
end

---------------------------------------------------------------- FUN EXTRAS
-- dance
local function dance(p)
	local hum = getHum(p)
	if not hum then return end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://33796059"
	local track = hum:LoadAnimation(anim)
	track:Play()
	globalNotify(p.Name .. " is dancing!", Color3.fromRGB(255, 0, 255))
end

-- trip
local function trip(p)
	local hum = getHum(p)
	if not hum then return end
	hum.Sit = true
	hum.Jump = true
	globalNotify(p.Name .. " tripped!", Color3.fromRGB(255, 170, 0))
end

-- explode
local function explode(p)
	local char = p.Character
	if not char then return end
	local ex = Instance.new("Explosion", char)
	ex.Position = getHRP(p).Position
	ex.BlastPressure = 0
	ex.BlastRadius = 10
	ex.DestroyJointRadiusPercent = 0
	globalNotify(p.Name .. " exploded!", Color3.fromRGB(255, 0, 0))
end

-- giant
local function giant(p)
	local hum = getHum(p)
	if not hum then return end
	hum.BodyDepthScale.Value = 3
	hum.BodyHeightScale.Value = 3
	hum.BodyWidthScale.Value = 3
	hum.HeadScale.Value = 3
	globalNotify(p.Name .. " became a giant!", Color3.fromRGB(0, 255, 0))
end

-- tiny
local function tiny(p)
	local hum = getHum(p)
	if not hum then return end
	hum.BodyDepthScale.Value = 0.3
	hum.BodyHeightScale.Value = 0.3
	hum.BodyWidthScale.Value = 0.3
	hum.HeadScale.Value = 0.3
	globalNotify(p.Name .. " became tiny!", Color3.fromRGB(0, 255, 255))
end

-- rainbow
local function rainbow(p)
	local char = p.Character
	if not char then return end
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			local cs = Instance.new("ColorSequenceValue")
			cs.Value = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 170, 255)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
			})
			local g = Instance.new("UIGradient", v)
			g.Color = cs.Value
			g.Offset = Vector2.new(0, 0)
			local con = RunService.Heartbeat:Connect(function()
				g.Offset = Vector2.new(g.Offset.X + 0.01, 0)
			end)
			table.insert(espt, con)
		end
	end
	globalNotify(p.Name .. " is rainbow!", Color3.fromRGB(255, 0, 255))
end

-- fire
local function fire(p)
	if p.Character:FindFirstChild("Fire") then return end
	local f = Instance.new("Fire", getHRP(p))
	f.Size = 10
	f.Heat = 25
	globalNotify(p.Name .. " is on fire!", Color3.fromRGB(255, 100, 0))
end
local function unfire(p)
	local f = p.Character:FindFirstChild("Fire")
	if f then f:Destroy() end
end

-- smoke
local function smoke(p)
	if p.Character:FindFirstChild("Smoke") then return end
	local s = Instance.new("Smoke", getHRP(p))
	s.Size = 10
	s.RiseVelocity = 5
	globalNotify(p.Name .. " is smoking!", Color3.fromRGB(150, 150, 150))
end
local function unsmoke(p)
	local s = p.Character:FindFirstChild("Smoke")
	if s then s:Destroy() end
end

-- sparkles
local function sparkles(p)
	if p.Character:FindFirstChild("Sparkles") then return end
	local s = Instance.new("Sparkles", getHRP(p))
	s.SparkleColor = Color3.fromRGB(255, 255, 0)
	globalNotify(p.Name .. " is sparkling!", Color3.fromRGB(255, 255, 0))
end
local function unsparkles(p)
	local s = p.Character:FindFirstChild("Sparkles")
	if s then s:Destroy() end
end

-- rickroll
local function rickroll(p)
	local sg = p:FindFirstChild("PlayerGui")
	if not sg then return end
	local screen = Instance.new("ScreenGui", sg)
	screen.Name = "Rickroll"
	screen.ResetOnSpawn = false
	local img = Instance.new("ImageLabel", screen)
	img.Size = UDim2.new(1, 0, 1, 0)
	img.Image = "rbxassetid://6087489939" -- never-gonna-give-you-up
	img.BackgroundTransparency = 1
	img.ScaleType = Enum.ScaleType.Crop
	local sound = Instance.new("Sound", screen)
	sound.SoundId = "rbxassetid://1833023465"
	sound.Volume = 1
	sound:Play()
	globalNotify(p.Name .. " got rickrolled!", Color3.fromRGB(255, 0, 255))
	task.wait(10)
	screen:Destroy()
end

-- loopjump
local loopJumpData = {}
local function loopjump(p)
	if loopJumpData[p] then return end
	local con = RunService.Heartbeat:Connect(function()
		local hum = getHum(p)
		if hum then hum.Jump = true end
	end)
	loopJumpData[p] = con
	globalNotify(p.Name .. " is loop-jumping!", Color3.fromRGB(0, 255, 0))
end
local function unloopjump(p)
	local con = loopJumpData[p]
	if con then con:Disconnect(); loopJumpData[p] = nil end
end

---------------------------------------------------------------- COMMAND PROCESSOR
local function processCmd(msg)
	if msg:sub(1, 1) ~= prefix then return end
	local args = msg:sub(2):split(" ")
	local cmd  = table.remove(args, 1):lower()
	notify("!" .. cmd, Color3.fromRGB(60, 60, 60))

	if cmd == "cmds" then
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
	elseif cmd == "disablefalldamage" then disableFalldamage()
	elseif cmd == "enable" then
		local what = (args[1] or ""):lower()
		if what == "inventory" then
			local on = not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, on)
			notify("Inventory " .. (on and "enabled" or "disabled"))
		elseif what == "playerlist" then
			local on = not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, on)
			notify("Player-list " .. (on and "enabled" or "disabled"))
		end
	-- FUN EXTRAS
	elseif cmd == "dance" then dance(getPlr(args[1] or "me"))
	elseif cmd == "trip" then trip(getPlr(args[1] or "me"))
	elseif cmd == "explode" then explode(getPlr(args[1] or "me"))
	elseif cmd == "giant" then giant(getPlr(args[1] or "me"))
	elseif cmd == "tiny" then tiny(getPlr(args[1] or "me"))
	elseif cmd == "rainbow" then rainbow(getPlr(args[1] or "me"))
	elseif cmd == "fire" then fire(getPlr(args[1] or "me"))
	elseif cmd == "unfire" then unfire(getPlr(args[1] or "me"))
	elseif cmd == "smoke" then smoke(getPlr(args[1] or "me"))
	elseif cmd == "unsmoke" then unsmoke(getPlr(args[1] or "me"))
	elseif cmd == "sparkles" then sparkles(getPlr(args[1] or "me"))
	elseif cmd == "unsparkles" then unsparkles(getPlr(args[1] or "me"))
	elseif cmd == "rickroll" then rickroll(getPlr(args[1] or "me"))
	elseif cmd == "loopjump" then loopjump(getPlr(args[1] or "me"))
	elseif cmd == "unloopjump" then unloopjump(getPlr(args[1] or "me"))
	end
end

-- private cmd box
local cmdBox = Instance.new("ScreenGui", client.PlayerGui); cmdBox.ResetOnSpawn = false
local frame = Instance.new("Frame", cmdBox)
frame.Size = UDim2.new(0, 250, 0, 40)
frame.Position = UDim2.new(1, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
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

---------------------------------------------------------------- GLASS CMD-LIST GUI  (everyone sees it)
local gui = Instance.new("ScreenGui", client.PlayerGui)
gui.Name = "LunarGui"
gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 460)
main.Position = UDim2.new(1, 40, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BackgroundTransparency = 0.1
main.Active = true
main.Draggable = true
-- glass gradient
local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
grad.Rotation = 90
-- shadow
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.new(1, 12, 1, 12)
shadow.Position = UDim2.new(0, -6, 0, -6)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.7
shadow.BackgroundTransparency = 1
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(16, 16, 240, 240)
shadow.ZIndex = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -380, 0.5, -230)}):Play()

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "Lunar Admin"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)

local search = Instance.new("TextBox", main)
search.Size = UDim2.new(1, -20, 0, 32)
search.Position = UDim2.new(0, 10, 0, 50)
search.PlaceholderText = "Search commands..."
search.Font = Enum.Font.Gotham
search.TextSize = 15
search.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
search.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 6)

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0, 10, 0, 92)
list.Size = UDim2.new(1, -20, 1, -152)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1
list.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
local uiGrid = Instance.new("UIGridLayout", list)
uiGrid.CellSize = UDim2.new(1, 0, 0, 28)
uiGrid.SortOrder = Enum.SortOrder.LayoutOrder

local lbls = {}
local function refresh(filter)
	for _, v in ipairs(lbls) do v:Destroy() end
	lbls = {}
	local y = 0
	for _, cmd in ipairs(cmds) do
		if not filter or cmd:lower():find(filter:lower()) then
			local l = Instance.new("TextLabel", list)
			l.Size = uiGrid.CellSize
			l.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			l.BackgroundTransparency = 0.2
			l.Text = cmd
			l.Font = Enum.Font.Gotham
			l.TextSize = 14
			l.TextColor3 = Color3.new(.95, .95, .95)
			l.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UICorner", l)
			table.insert(lbls, l)
			y += 28
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

---------------------------------------------------------------- WATERMARK (fades in after everything loads)
task.spawn(function()
	task.wait(1.2)
	local gui = Instance.new("ScreenGui", client.PlayerGui)
	gui.ResetOnSpawn = false
	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(0,260,0,22)
	label.Position = UDim2.new(0.5,0,0.88,0)
	label.AnchorPoint = Vector2.new(0.5,0)
	label.BackgroundTransparency = 1
	label.Text = "Created By @xLunarxZzRbxx"
	label.Font = Enum.Font.Gotham
	label.TextSize = 50
	label.TextColor3 = Color3.new(1,1,1)
	label.TextTransparency = 1
	TweenService:Create(label, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
	task.wait(2.5)
	TweenService:Create(label, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
	task.wait(1)
	gui:Destroy()
end)
