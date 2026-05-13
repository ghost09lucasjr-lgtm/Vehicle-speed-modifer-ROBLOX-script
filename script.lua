
local MEM_FOLDER = "MotoScript"
local MEM_FILE   = MEM_FOLDER .. "/Simple.json"

local function SaveMem(data)
	pcall(function()
		if not isfolder(MEM_FOLDER) then makefolder(MEM_FOLDER) end
		writefile(MEM_FILE, game:GetService("HttpService"):JSONEncode(data))
	end)
end
local function LoadMem()
	local ok, r = pcall(function()
		if isfile(MEM_FILE) then
			return game:GetService("HttpService"):JSONDecode(readfile(MEM_FILE))
		end
	end)
	return (ok and type(r)=="table") and r or {}
end

local MEM = LoadMem()
local function M(k, d) local v=MEM[k]; return v~=nil and v or d end
local function S(k,v)  MEM[k]=v; SaveMem(MEM) end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

local blackGui = Instance.new("ScreenGui")
blackGui.Name = "BlackScreen"
blackGui.ResetOnSpawn = false
blackGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
blackGui.IgnoreGuiInset = true
blackGui.Parent = LocalPlayer.PlayerGui

local blackBg = Instance.new("Frame")
blackBg.Size = UDim2.new(1, 0, 1, 0)
blackBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackBg.BackgroundTransparency = 0
blackBg.BorderSizePixel = 0
blackBg.Parent = blackGui

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(0, 300, 0, 60)
loadingText.Position = UDim2.new(0.5, -150, 0.5, -30)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Greetings fine huzz"
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextScaled = true
loadingText.Font = Enum.Font.GothamBold
loadingText.Parent = blackGui

local dotIndex = 0
local dotPatterns = { "", ".", "..", "..." }
local dotTimer = task.spawn(function()
	while blackGui and blackGui.Parent do
		task.wait(0.3)
		dotIndex = dotIndex % 3 + 1
		loadingText.Text = "Loading" .. dotPatterns[dotIndex]
	end
end)

task.wait(4)
task.cancel(dotTimer)
loadingText:Destroy()

local questionFrame = Instance.new("Frame")
questionFrame.Size = UDim2.new(0, 400, 0, 160)
questionFrame.Position = UDim2.new(0.5, -200, 0.5, -80)
questionFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
questionFrame.BackgroundTransparency = 0
questionFrame.BorderSizePixel = 0
questionFrame.Parent = blackGui

local questionLabel = Instance.new("TextLabel")
questionLabel.Size = UDim2.new(1, -20, 0, 40)
questionLabel.Position = UDim2.new(0, 10, 0, 10)
questionLabel.BackgroundTransparency = 1
questionLabel.Text = "im i lwky fine huzz?"
questionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
questionLabel.TextScaled = true
questionLabel.Font = Enum.Font.GothamBold
questionLabel.Parent = questionFrame

local answerBox = Instance.new("TextBox")
answerBox.Size = UDim2.new(0, 250, 0, 35)
answerBox.Position = UDim2.new(0.5, -125, 0, 55)
answerBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
answerBox.BorderSizePixel = 1
answerBox.BorderColor3 = Color3.fromRGB(100, 100, 110)
answerBox.Text = ""
answerBox.PlaceholderText = "Type your answer..."
answerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
answerBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
answerBox.Font = Enum.Font.Gotham
answerBox.TextSize = 16
answerBox.ClearTextOnFocus = true
answerBox.Parent = questionFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0, 100, 0, 35)
submitBtn.Position = UDim2.new(0.5, -50, 0, 105)
submitBtn.BackgroundColor3 = Color3.fromRGB(60, 210, 90)
submitBtn.BorderSizePixel = 0
submitBtn.Text = "SUBMIT"
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 16
submitBtn.Parent = questionFrame

local userAnswered = false
local correctAnswers = {"yes", "yeah", "duh", "yea"}

submitBtn.MouseButton1Click:Connect(function()
	local answer = answerBox.Text:lower()
	for _, correct in ipairs(correctAnswers) do
		if answer == correct then
			userAnswered = true
			break
		end
	end
	if userAnswered then
		questionLabel.Text = "YEPPY"
		answerBox.Visible = false
		submitBtn.Visible = false
		task.wait(0.4)
		blackGui:Destroy()
		LoadMainScript()
	else
		LocalPlayer:Kick("incorrect Get out :( next time call me Fine huzz and ill let you slide),")
	end
end)

-- ======================== MAIN SCRIPT (Vehicle Modifier) ========================
function LoadMainScript()
	local speedCapEnabled   = M("speedCapEnabled",   false)
	local speedCapValue     = M("speedCapValue",      150)
	local brakeEnabled      = M("brakeEnabled",       false)
	local brakeForceValue   = M("brakeForceValue",    150)
	local showHUD           = M("showHUD", true)
	local accelEnabled      = M("accelEnabled",      true)
	local accelRaw          = M("accelRaw",          25)
	local accelMult         = accelRaw / 1000

	local DEFAULTS = {
		speedCapEnabled  = false,
		speedCapValue    = 150,
		brakeEnabled     = false,
		brakeForceValue  = 150,
		showHUD          = true,
		accelEnabled     = true,
		accelRaw         = 25,
	}

	local function GetSeat()
		local char = LocalPlayer.Character; if not char then return nil end
		local hum = char:FindFirstChildWhichIsA("Humanoid"); if not hum then return nil end
		local s = hum.SeatPart; return (s and s:IsA("VehicleSeat")) and s or nil
	end

	RunService.Heartbeat:Connect(function()
		if UserInputService:GetFocusedTextBox() then return end
		local seat = GetSeat(); if not seat then return end
		local vel = seat.AssemblyLinearVelocity

		if accelEnabled and UserInputService:IsKeyDown(Enum.KeyCode.W) then
			local hv = Vector3.new(vel.X, 0, vel.Z) * (1 + accelMult)
			seat.AssemblyLinearVelocity = Vector3.new(hv.X, vel.Y, hv.Z)
		end

		if accelEnabled and UserInputService:IsKeyDown(Enum.KeyCode.S) then
			local bMult = brakeEnabled and math.max(0, 1 - brakeForceValue/1000) or (1 - 0.15)
			local hv = Vector3.new(vel.X, 0, vel.Z) * bMult
			seat.AssemblyLinearVelocity = Vector3.new(hv.X, vel.Y, hv.Z)
		end

		if speedCapEnabled then
			local vel2 = seat.AssemblyLinearVelocity
			local hv   = Vector3.new(vel2.X, 0, vel2.Z)
			local currentMPH = hv.Magnitude / 1.60934
			
			if speedCapValue >= 0 then
				if currentMPH > speedCapValue then
					local targetStuds = speedCapValue * 1.60934
					local clamped = hv.Unit * targetStuds
					seat.AssemblyLinearVelocity = Vector3.new(clamped.X, vel2.Y, clamped.Z)
				end
			else
				local targetStuds = math.abs(speedCapValue) * 1.60934
				if currentMPH > math.abs(speedCapValue) then
					local clamped = hv.Unit * targetStuds
					seat.AssemblyLinearVelocity = Vector3.new(clamped.X, vel2.Y, clamped.Z)
				end
			end
		end
	end)

	local BG        = Color3.fromRGB(18,  18,  22)
	local SURFACE   = Color3.fromRGB(28,  28,  34)
	local ACCENT    = Color3.fromRGB(255, 200,  50)
	local GREY      = Color3.fromRGB(180, 180, 190)   -- new grey for title
	local GREEN     = Color3.fromRGB(60,  210,  90)
	local RED       = Color3.fromRGB(220,  55,  55)
	local TEXT      = Color3.fromRGB(230, 230, 230)
	local SUBTEXT   = Color3.fromRGB(140, 140, 150)
	local BORDER    = Color3.fromRGB(55,  55,  65)

	local FONT      = Enum.Font.GothamBold
	local FONTMED   = Enum.Font.Gotham

	local Root = Instance.new("ScreenGui")
	Root.Name = "VehicleModifier"
	Root.ResetOnSpawn = false
	Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Root.Parent = LocalPlayer.PlayerGui

	local function Corner(parent, r) end
	local function Stroke(parent, color, thick)
		local s = Instance.new("UIStroke", parent)
		s.Color = color or BORDER; s.Thickness = thick or 1
	end

	-- ======================== SPEED HUD (unchanged) ========================
	local HUD = Instance.new("Frame")
	HUD.Name            = "SpeedHUD"
	HUD.Size            = UDim2.new(0, 160, 0, 90)
	HUD.Position        = UDim2.new(0.5, -80, 1, -110)
	HUD.BackgroundColor3       = BG
	HUD.BackgroundTransparency = 0.5
	HUD.BorderSizePixel = 0
	HUD.Visible         = showHUD
	HUD.ClipsDescendants = true
	HUD.Parent          = Root
	Corner(HUD)
	Stroke(HUD, BORDER, 1.5)

	local HUDSpeed = Instance.new("TextLabel")
	HUDSpeed.Size = UDim2.new(1, -10, 0.62, 0)
	HUDSpeed.Position = UDim2.new(0, 5, 0, 0)
	HUDSpeed.BackgroundTransparency = 1
	HUDSpeed.Text = "0"
	HUDSpeed.TextColor3 = Color3.fromRGB(235, 235, 235)
	HUDSpeed.TextScaled = true
	HUDSpeed.Font = FONT
	HUDSpeed.Parent = HUD

	local HUDUnit = Instance.new("TextLabel")
	HUDUnit.Size = UDim2.new(0.55, 0, 0.3, 0)
	HUDUnit.Position = UDim2.new(0, 5, 0.62, 0)
	HUDUnit.BackgroundTransparency = 1
	HUDUnit.Text = "MPH"
	HUDUnit.TextColor3 = SUBTEXT
	HUDUnit.TextScaled = true
	HUDUnit.Font = FONTMED
	HUDUnit.Parent = HUD

	local HUDTop = Instance.new("TextLabel")
	HUDTop.Size = UDim2.new(0.45, -5, 0.3, 0)
	HUDTop.Position = UDim2.new(0.55, 0, 0.62, 0)
	HUDTop.BackgroundTransparency = 1
	HUDTop.Text = "▲ 0"
	HUDTop.TextColor3 = Color3.fromRGB(90, 160, 255)
	HUDTop.TextScaled = true
	HUDTop.Font = FONTMED
	HUDTop.Parent = HUD

	-- HUD drag
	do
		local dragging, dragStart, startPos = false, nil, nil
		HUD.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true; dragStart = input.Position; startPos = HUD.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = input.Position - dragStart
				HUD.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
			end
		end)
	end

	-- Rotate
	local RotHandle = Instance.new("TextButton")
	RotHandle.Size = UDim2.new(0, 18, 0, 18)
	RotHandle.Position = UDim2.new(1, -20, 0, 2)
	RotHandle.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	RotHandle.BackgroundTransparency = 0.3
	RotHandle.BorderSizePixel = 0
	RotHandle.Text = "↻"
	RotHandle.TextColor3 = Color3.fromRGB(0, 0, 0)
	RotHandle.Font = FONT
	RotHandle.TextSize = 12
	RotHandle.Parent = HUD
	Corner(RotHandle, 9)

	do
		local rotating = false
		RotHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				rotating = true
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then rotating = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not rotating then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local abs = HUD.AbsolutePosition
				local size = HUD.AbsoluteSize
				local centre = Vector2.new(abs.X + size.X/2, abs.Y + size.Y/2)
				local mousePos = Vector2.new(input.Position.X, input.Position.Y)
				local delta = mousePos - centre
				local angle = math.deg(math.atan2(delta.X, -delta.Y))
				HUD.Rotation = angle
			end
		end)
	end

	-- HUD resize
	local ResHandle = Instance.new("TextButton")
	ResHandle.Size = UDim2.new(0, 18, 0, 18)
	ResHandle.Position = UDim2.new(1, -20, 1, -20)
	ResHandle.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	ResHandle.BackgroundTransparency = 0.2
	ResHandle.BorderSizePixel = 0
	ResHandle.Text = "⤡"
	ResHandle.TextColor3 = TEXT
	ResHandle.Font = FONT
	ResHandle.TextSize = 12
	ResHandle.Parent = HUD
	Corner(ResHandle, 4)

	do
		local resizing = false
		local resStart, sizeStart = nil, nil
		ResHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				resStart = Vector2.new(input.Position.X, input.Position.Y)
				sizeStart = Vector2.new(HUD.AbsoluteSize.X, HUD.AbsoluteSize.Y)
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then resizing = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not resizing then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = Vector2.new(input.Position.X, input.Position.Y) - resStart
				local newW = math.max(80, sizeStart.X + d.X)
				local newH = math.max(50, sizeStart.Y + d.Y)
				HUD.Size = UDim2.new(0, newW, 0, newH)
			end
		end)
	end

	-- ======================== MAIN PANEL (less wide, resizable) ========================
	local Panel = Instance.new("Frame")
	Panel.Name            = "MainPanel"
	Panel.Size            = UDim2.new(0, 600, 0, 195)   -- reduced width from 720 to 600
	Panel.Position        = UDim2.new(0.5, -300, 0.5, -97.5)
	Panel.BackgroundColor3      = BG
	Panel.BackgroundTransparency = 0.2   -- lowered (more opaque)
	Panel.BorderSizePixel = 0
	Panel.Parent          = Root
	Corner(Panel)
	Stroke(Panel, BORDER, 1.5)

	-- Drag panel
	do
		local dragging, dragStart, startPos = false, nil, nil
		Panel.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos  = Panel.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = input.Position - dragStart
				Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	-- Resize panel (new)
	local PanelResize = Instance.new("TextButton")
	PanelResize.Size = UDim2.new(0, 18, 0, 18)
	PanelResize.Position = UDim2.new(1, -20, 1, -20)
	PanelResize.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	PanelResize.BackgroundTransparency = 0.2
	PanelResize.BorderSizePixel = 0
	PanelResize.Text = "⤡"
	PanelResize.TextColor3 = TEXT
	PanelResize.Font = FONT
	PanelResize.TextSize = 12
	PanelResize.Parent = Panel
	Corner(PanelResize, 4)

	do
		local resizing = false
		local resStart, sizeStart = nil, nil
		PanelResize.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				resStart = Vector2.new(input.Position.X, input.Position.Y)
				sizeStart = Vector2.new(Panel.AbsoluteSize.X, Panel.AbsoluteSize.Y)
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then resizing = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not resizing then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = Vector2.new(input.Position.X, input.Position.Y) - resStart
				local newW = math.max(400, sizeStart.X + d.X)   -- minimum width 400
				local newH = math.max(150, sizeStart.Y + d.Y)   -- minimum height 150
				Panel.Size = UDim2.new(0, newW, 0, newH)
			end
		end)
	end

	-- Title bar (grey text)
	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 34)
	TitleBar.BackgroundTransparency = 1
	TitleBar.Parent = Panel

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
	TitleLabel.Position = UDim2.new(0, 12, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "Vehicle Modifier"
	TitleLabel.TextColor3 = GREY   -- changed to grey
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextScaled = true
	TitleLabel.Font = FONT
	TitleLabel.Parent = TitleBar

	local HintLabel = Instance.new("TextLabel")
	HintLabel.Size = UDim2.new(0.38, 0, 1, 0)
	HintLabel.Position = UDim2.new(0.62, 0, 0, 0)
	HintLabel.BackgroundTransparency = 1
	HintLabel.Text = "[K] Toggle"
	HintLabel.TextColor3 = SUBTEXT
	HintLabel.TextXAlignment = Enum.TextXAlignment.Right
	HintLabel.TextScaled = false
	HintLabel.TextSize = 12
	HintLabel.Font = FONTMED
	HintLabel.Parent = TitleBar

	local Divider = Instance.new("Frame")
	Divider.Size = UDim2.new(1, -24, 0, 1)
	Divider.Position = UDim2.new(0, 12, 0, 36)
	Divider.BackgroundColor3 = BORDER
	Divider.BorderSizePixel = 0
	Divider.Parent = Panel

	-- Speed Cap
	local SpeedLabel = Instance.new("TextLabel")
	SpeedLabel.Size = UDim2.new(0, 140, 0, 24)
	SpeedLabel.Position = UDim2.new(0, 12, 0, 44)
	SpeedLabel.BackgroundTransparency = 1
	SpeedLabel.Text = "Modify Speed Cap"
	SpeedLabel.TextColor3 = TEXT
	SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
	SpeedLabel.TextScaled = true
	SpeedLabel.Font = FONTMED
	SpeedLabel.Parent = Panel

	local SpeedBox = Instance.new("TextBox")
	SpeedBox.Size = UDim2.new(1, -130, 0, 30)
	SpeedBox.Position = UDim2.new(0, 12, 0, 72)
	SpeedBox.BackgroundColor3 = SURFACE
	SpeedBox.BackgroundTransparency = 0.3
	SpeedBox.BorderSizePixel = 0
	SpeedBox.Text = tostring(speedCapValue)
	SpeedBox.PlaceholderText = "Any number... (MPH)"
	SpeedBox.TextColor3 = TEXT
	SpeedBox.PlaceholderColor3 = SUBTEXT
	SpeedBox.Font = FONT
	SpeedBox.TextSize = 18
	SpeedBox.ClearTextOnFocus = false
	SpeedBox.Parent = Panel
	Corner(SpeedBox)
	Stroke(SpeedBox, BORDER, 1)

	SpeedBox.FocusLost:Connect(function()
		local val = tonumber(SpeedBox.Text)
		if val ~= nil then speedCapValue = val; S("speedCapValue", val)
		else SpeedBox.Text = tostring(speedCapValue) end
	end)

	local SpeedToggle = Instance.new("TextButton")
	SpeedToggle.Size = UDim2.new(0, 80, 0, 30)
	SpeedToggle.Position = UDim2.new(1, -100, 0, 72)
	SpeedToggle.BackgroundColor3 = speedCapEnabled and GREEN or RED
	SpeedToggle.BorderSizePixel = 0
	SpeedToggle.Text = speedCapEnabled and "ON" or "OFF"
	SpeedToggle.TextColor3 = Color3.fromRGB(255,255,255)
	SpeedToggle.Font = FONT
	SpeedToggle.TextSize = 15
	SpeedToggle.Parent = Panel
	Corner(SpeedToggle)

	SpeedToggle.MouseButton1Click:Connect(function()
		speedCapEnabled = not speedCapEnabled
		S("speedCapEnabled", speedCapEnabled)
		SpeedToggle.BackgroundColor3 = speedCapEnabled and GREEN or RED
		SpeedToggle.Text = speedCapEnabled and "ON" or "OFF"
	end)

	-- Bottom row (positions adjusted for 600 width)
	local BottomLabelY = 118
	local BottomBoxY   = 138

	-- Brake Force
	local BrakeLabel = Instance.new("TextLabel")
	BrakeLabel.Size = UDim2.new(0, 90, 0, 22)
	BrakeLabel.Position = UDim2.new(0, 12, 0, BottomLabelY)
	BrakeLabel.BackgroundTransparency = 1
	BrakeLabel.Text = "Brake Force"
	BrakeLabel.TextColor3 = TEXT
	BrakeLabel.TextXAlignment = Enum.TextXAlignment.Left
	BrakeLabel.TextScaled = true
	BrakeLabel.Font = FONTMED
	BrakeLabel.Parent = Panel

	local BrakeBox = Instance.new("TextBox")
	BrakeBox.Size = UDim2.new(0, 60, 0, 28)
	BrakeBox.Position = UDim2.new(0, 12, 0, BottomBoxY)
	BrakeBox.BackgroundColor3 = SURFACE
	BrakeBox.BackgroundTransparency = 0.3
	BrakeBox.BorderSizePixel = 0
	BrakeBox.Text = tostring(brakeForceValue)
	BrakeBox.PlaceholderText = "150"
	BrakeBox.TextColor3 = TEXT
	BrakeBox.PlaceholderColor3 = SUBTEXT
	BrakeBox.Font = FONT
	BrakeBox.TextSize = 16
	BrakeBox.ClearTextOnFocus = false
	BrakeBox.Parent = Panel
	Corner(BrakeBox)
	Stroke(BrakeBox, BORDER, 1)

	BrakeBox.FocusLost:Connect(function()
		local val = tonumber(BrakeBox.Text)
		if val ~= nil then brakeForceValue = val; S("brakeForceValue", val)
		else BrakeBox.Text = tostring(brakeForceValue) end
	end)

	local BrakeToggle = Instance.new("TextButton")
	BrakeToggle.Size = UDim2.new(0, 44, 0, 28)
	BrakeToggle.Position = UDim2.new(0, 82, 0, BottomBoxY)
	BrakeToggle.BackgroundColor3 = brakeEnabled and GREEN or RED
	BrakeToggle.BorderSizePixel = 0
	BrakeToggle.Text = brakeEnabled and "ON" or "OFF"
	BrakeToggle.TextColor3 = Color3.fromRGB(255,255,255)
	BrakeToggle.Font = FONT
	BrakeToggle.TextSize = 13
	BrakeToggle.Parent = Panel
	Corner(BrakeToggle)

	BrakeToggle.MouseButton1Click:Connect(function()
		brakeEnabled = not brakeEnabled
		S("brakeEnabled", brakeEnabled)
		BrakeToggle.BackgroundColor3 = brakeEnabled and GREEN or RED
		BrakeToggle.Text = brakeEnabled and "ON" or "OFF"
	end)

	-- Acceleration
	local AccelLabel = Instance.new("TextLabel")
	AccelLabel.Size = UDim2.new(0, 100, 0, 22)
	AccelLabel.Position = UDim2.new(0, 150, 0, BottomLabelY)   -- shifted left because panel is narrower
	AccelLabel.BackgroundTransparency = 1
	AccelLabel.Text = "Accel Multiplier"
	AccelLabel.TextColor3 = TEXT
	AccelLabel.TextXAlignment = Enum.TextXAlignment.Left
	AccelLabel.TextScaled = true
	AccelLabel.Font = FONTMED
	AccelLabel.Parent = Panel

	local AccelBox = Instance.new("TextBox")
	AccelBox.Size = UDim2.new(0, 60, 0, 28)
	AccelBox.Position = UDim2.new(0, 150, 0, BottomBoxY)
	AccelBox.BackgroundColor3 = SURFACE
	AccelBox.BackgroundTransparency = 0.3
	AccelBox.BorderSizePixel = 0
	AccelBox.Text = tostring(accelRaw)
	AccelBox.PlaceholderText = "1-50"
	AccelBox.TextColor3 = TEXT
	AccelBox.PlaceholderColor3 = SUBTEXT
	AccelBox.Font = FONT
	AccelBox.TextSize = 16
	AccelBox.ClearTextOnFocus = false
	AccelBox.Parent = Panel
	Corner(AccelBox)
	Stroke(AccelBox, BORDER, 1)

	AccelBox.FocusLost:Connect(function()
		local val = tonumber(AccelBox.Text)
		if val and val >= 1 and val <= 50 then
			accelRaw = val
			accelMult = accelRaw / 1000
			S("accelRaw", accelRaw)
			S("accelMult", accelMult)
			AccelBox.Text = tostring(accelRaw)
		else
			AccelBox.Text = tostring(accelRaw)
		end
	end)

	local AccelToggle = Instance.new("TextButton")
	AccelToggle.Size = UDim2.new(0, 44, 0, 28)
	AccelToggle.Position = UDim2.new(0, 220, 0, BottomBoxY)
	AccelToggle.BackgroundColor3 = accelEnabled and GREEN or RED
	AccelToggle.BorderSizePixel = 0
	AccelToggle.Text = accelEnabled and "ON" or "OFF"
	AccelToggle.TextColor3 = Color3.fromRGB(255,255,255)
	AccelToggle.Font = FONT
	AccelToggle.TextSize = 13
	AccelToggle.Parent = Panel
	Corner(AccelToggle)

	AccelToggle.MouseButton1Click:Connect(function()
		accelEnabled = not accelEnabled
		S("accelEnabled", accelEnabled)
		AccelToggle.BackgroundColor3 = accelEnabled and GREEN or RED
		AccelToggle.Text = accelEnabled and "ON" or "OFF"
	end)

	-- HUD Toggle
	local HUDToggle = Instance.new("TextButton")
	HUDToggle.Size = UDim2.new(0, 100, 0, 28)
	HUDToggle.Position = UDim2.new(0, 290, 0, BottomBoxY)
	HUDToggle.BackgroundColor3 = SURFACE
	HUDToggle.BackgroundTransparency = 0.2
	HUDToggle.BorderSizePixel = 0
	HUDToggle.Text = "Speed HUD " .. (showHUD and "ON" or "OFF")
	HUDToggle.TextColor3 = showHUD and GREEN or SUBTEXT
	HUDToggle.Font = FONTMED
	HUDToggle.TextSize = 12
	HUDToggle.Parent = Panel
	Corner(HUDToggle)
	Stroke(HUDToggle, BORDER, 1)

	HUDToggle.MouseButton1Click:Connect(function()
		showHUD = not showHUD
		S("showHUD", showHUD)
		HUDToggle.Text = "Speed HUD " .. (showHUD and "ON" or "OFF")
		HUDToggle.TextColor3 = showHUD and GREEN or SUBTEXT
		HUD.Visible = showHUD
	end)

	-- Teleport Up button (new)
	local TeleportUpBtn = Instance.new("TextButton")
	TeleportUpBtn.Size = UDim2.new(0, 70, 0, 28)
	TeleportUpBtn.Position = UDim2.new(1, -190, 0, BottomBoxY)  -- to the left of Reset button
	TeleportUpBtn.BackgroundColor3 = SURFACE
	TeleportUpBtn.BackgroundTransparency = 0.2
	TeleportUpBtn.BorderSizePixel = 0
	TeleportUpBtn.Text = "UP"
	TeleportUpBtn.TextColor3 = ACCENT
	TeleportUpBtn.Font = FONT
	TeleportUpBtn.TextSize = 14
	TeleportUpBtn.Parent = Panel
	Corner(TeleportUpBtn)
	Stroke(TeleportUpBtn, BORDER, 1)

	TeleportUpBtn.MouseButton1Click:Connect(function()
		local seat = GetSeat()
		if seat then
			seat.CFrame = seat.CFrame + Vector3.new(0, 5, 0)
			-- optional: small visual feedback
			TeleportUpBtn.TextColor3 = Color3.fromRGB(255,255,255)
			task.delay(0.1, function() TeleportUpBtn.TextColor3 = ACCENT end)
		end
	end)

	-- Reset Button
	local ResetBtn = Instance.new("TextButton")
	ResetBtn.Size = UDim2.new(0, 80, 0, 28)
	ResetBtn.Position = UDim2.new(1, -100, 0, BottomBoxY)
	ResetBtn.BackgroundTransparency = 1
	ResetBtn.BorderSizePixel = 0
	ResetBtn.Text = "RESET"
	ResetBtn.TextColor3 = RED
	ResetBtn.Font = FONT
	ResetBtn.TextSize = 14
	ResetBtn.Parent = Panel

	ResetBtn.MouseButton1Click:Connect(function()
		speedCapEnabled = DEFAULTS.speedCapEnabled
		speedCapValue   = DEFAULTS.speedCapValue
		brakeEnabled    = DEFAULTS.brakeEnabled
		brakeForceValue = DEFAULTS.brakeForceValue
		showHUD         = DEFAULTS.showHUD
		accelEnabled    = DEFAULTS.accelEnabled
		accelRaw        = DEFAULTS.accelRaw
		accelMult       = accelRaw / 1000

		SpeedBox.Text = tostring(speedCapValue)
		BrakeBox.Text = tostring(brakeForceValue)
		AccelBox.Text = tostring(accelRaw)

		SpeedToggle.BackgroundColor3 = speedCapEnabled and GREEN or RED
		SpeedToggle.Text = speedCapEnabled and "ON" or "OFF"
		BrakeToggle.BackgroundColor3 = brakeEnabled and GREEN or RED
		BrakeToggle.Text = brakeEnabled and "ON" or "OFF"
		AccelToggle.BackgroundColor3 = accelEnabled and GREEN or RED
		AccelToggle.Text = accelEnabled and "ON" or "OFF"

		HUDToggle.Text = "Speed HUD " .. (showHUD and "ON" or "OFF")
		HUDToggle.TextColor3 = showHUD and GREEN or SUBTEXT
		HUD.Visible = showHUD

		SaveMem(DEFAULTS)
		MEM = {}
		for k,v in pairs(DEFAULTS) do MEM[k]=v end
	end)

	local Credit = Instance.new("TextLabel")
	Credit.Size = UDim2.new(1, 0, 0, 20)
	Credit.Position = UDim2.new(0, 0, 1, -20)
	Credit.BackgroundTransparency = 1
	Credit.Text = "A project by Lucas :P"
	Credit.TextColor3 = SUBTEXT
	Credit.TextScaled = true
	Credit.Font = FONTMED
	Credit.Parent = Panel

	-- HUD update loop
	local topSpd = 0
	RunService.Heartbeat:Connect(function()
		local seat = GetSeat()
		if seat then
			local v   = seat.AssemblyLinearVelocity
			local spdStuds = Vector3.new(v.X,0,v.Z).Magnitude
			local mph = math.floor(spdStuds / 1.60934)
			if mph > topSpd then topSpd = mph end
			HUDSpeed.Text = tostring(mph)
			HUDTop.Text   = "▲ " .. tostring(topSpd)
		else
			HUDSpeed.Text = "0"
			topSpd = 0
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == Enum.KeyCode.K then
			Panel.Visible = not Panel.Visible
		end
	end)

	local function N(text)
		game.StarterGui:SetCore("SendNotification", {Title = "Lucas :P said", Text = text, Duration = 8})
	end

	N("Lucas :P presents this awsome fine Huzz type script")
	N("Click K to toggle the ui, Bla bla bla,you understand, Bye cya :)")
	N("im lwky fine huzz, hit me up if you wanna try yk what im sayinnnn")
	N("i got no friends i need friends, my discord is * karma_ontop. * btw")
end
