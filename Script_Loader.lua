local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Scripts = {
	{Name = "Evade Exploit", URL = "https://raw.githubusercontent.com/ghost09lucasjr-lgtm/universal-script-centre/refs/heads/main/Evade%20Exploit"},
	{Name = "No More Time", URL = "https://raw.githubusercontent.com/ghost09lucasjr-lgtm/universal-script-centre/refs/heads/main/No%20more%20time."},
	{Name = "Modded Pshade", URL = "https://raw.githubusercontent.com/ghost09lucasjr-lgtm/universal-script-centre/refs/heads/main/Modded%20Pshade"},
	{Name = "First Person Model", URL = "https://raw.githubusercontent.com/ghost09lucasjr-lgtm/universal-script-centre/refs/heads/main/first%20person%20model"},
	{Name = "ThirdPerson Force", URL = "https://raw.githubusercontent.com/ghost09lucasjr-lgtm/universal-script-centre/refs/heads/main/ThirdPerson%20Force"},
	{Name = "Vehicle Modifier", URL = "https://raw.githubusercontent.com/ghost09lucasjr-lgtm/universal-script-centre/refs/heads/main/Vehiclemodifier.lua"},
	{Name = "Zoom Script", URL = "https://raw.githubusercontent.com/ghost09lucasjr-lgtm/universal-script-centre/refs/heads/main/Zoom%20script."},
}

local LoadedScripts = {}
local SelectedScript = nil

local GUI = Instance.new("ScreenGui")
GUI.Name = "ScriptLoader"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 550)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 150, 255)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Script Loader"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 24
TitleLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
TitleLabel.Parent = MainFrame

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 45)
Divider.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local ScriptList = Instance.new("Frame")
ScriptList.Name = "ScriptList"
ScriptList.Size = UDim2.new(1, -20, 0, 360)
ScriptList.Position = UDim2.new(0, 10, 0, 55)
ScriptList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ScriptList.BorderSizePixel = 0
ScriptList.Parent = MainFrame

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = ScriptList

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScriptList

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 8)
UIPadding.PaddingRight = UDim.new(0, 8)
UIPadding.PaddingTop = UDim.new(0, 8)
UIPadding.PaddingBottom = UDim.new(0, 8)
UIPadding.Parent = ScriptList

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
ScrollingFrame.Parent = ScriptList

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding = UDim.new(0, 6)
ScrollLayout.Parent = ScrollingFrame

local ScrollPadding = Instance.new("UIPadding")
ScrollPadding.PaddingLeft = UDim.new(0, 6)
ScrollPadding.PaddingRight = UDim.new(0, 6)
ScrollPadding.PaddingTop = UDim.new(0, 6)
ScrollPadding.PaddingBottom = UDim.new(0, 6)
ScrollPadding.Parent = ScrollingFrame

for _, script in ipairs(Scripts) do
	local Button = Instance.new("TextButton")
	Button.Name = script.Name
	Button.Size = UDim2.new(1, 0, 0, 40)
	Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	Button.TextColor3 = Color3.fromRGB(200, 200, 220)
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 14
	Button.Text = script.Name
	Button.AutoButtonColor = false
	Button.Parent = ScrollingFrame

	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 6)
	BtnCorner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		if SelectedScript then
			SelectedScript.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		end
		SelectedScript = Button
		Button.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
	end)

	Button.MouseEnter:Connect(function()
		if SelectedScript ~= Button then
			Button.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
		end
	end)

	Button.MouseLeave:Connect(function()
		if SelectedScript ~= Button then
			Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		end
	end)
end

ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y)
ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y)
end)

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, -20, 0, 100)
ButtonContainer.Position = UDim2.new(0, 10, 1, -110)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.BorderSizePixel = 0
ButtonContainer.Parent = MainFrame

local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(0, 180, 0, 40)
ExecuteButton.Position = UDim2.new(0, 0, 0, 0)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
ExecuteButton.TextColor3 = Color3.new(1, 1, 1)
ExecuteButton.Font = Enum.Font.GothamBold
ExecuteButton.TextSize = 14
ExecuteButton.Text = "Execute"
ExecuteButton.AutoButtonColor = false
ExecuteButton.Parent = ButtonContainer

local ExecCorner = Instance.new("UICorner")
ExecCorner.CornerRadius = UDim.new(0, 8)
ExecCorner.Parent = ExecuteButton

ExecuteButton.MouseEnter:Connect(function()
	ExecuteButton.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
end)

ExecuteButton.MouseLeave:Connect(function()
	ExecuteButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
end)

ExecuteButton.MouseButton1Click:Connect(function()
	if not SelectedScript then
		game.StarterGui:SetCore("SendNotification", {
			Title = "Script Loader",
			Text = "Please select a script first",
			Duration = 2
		})
		return
	end

	local scriptName = SelectedScript.Name
	local script = nil
	for _, s in ipairs(Scripts) do
		if s.Name == scriptName then
			script = s
			break
		end
	end

	if script then
		ExecuteButton.Text = "Loading..."
		ExecuteButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)

		local success, err = pcall(function()
			loadstring(game:HttpGet(script.URL))()
		end)

		if success then
			table.insert(LoadedScripts, scriptName)
			ExecuteButton.Text = "✓ Executed"
			ExecuteButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
			game.StarterGui:SetCore("SendNotification", {
				Title = "Script Loader",
				Text = scriptName .. " executed successfully!",
				Duration = 3
			})
			task.wait(1.5)
			ExecuteButton.Text = "Execute"
		else
			ExecuteButton.Text = "✗ Error"
			ExecuteButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
			game.StarterGui:SetCore("SendNotification", {
				Title = "Script Loader",
				Text = "Error executing " .. scriptName,
				Duration = 3
			})
			task.wait(1.5)
			ExecuteButton.Text = "Execute"
		end
	end
end)

local UnloadButton = Instance.new("TextButton")
UnloadButton.Name = "UnloadButton"
UnloadButton.Size = UDim2.new(0, 180, 0, 40)
UnloadButton.Position = UDim2.new(1, -180, 0, 0)
UnloadButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
UnloadButton.TextColor3 = Color3.new(1, 1, 1)
UnloadButton.Font = Enum.Font.GothamBold
UnloadButton.TextSize = 14
UnloadButton.Text = "Unload All"
UnloadButton.AutoButtonColor = false
UnloadButton.Parent = ButtonContainer

local UnloadCorner = Instance.new("UICorner")
UnloadCorner.CornerRadius = UDim.new(0, 8)
UnloadCorner.Parent = UnloadButton

UnloadButton.MouseEnter:Connect(function()
	UnloadButton.BackgroundColor3 = Color3.fromRGB(240, 100, 100)
end)

UnloadButton.MouseLeave:Connect(function()
	UnloadButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
end)

UnloadButton.MouseButton1Click:Connect(function()
	UnloadButton.Text = "Unloading..."
	UnloadButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)

	for _, child in ipairs(game.CoreGui:GetChildren()) do
		if child.Name:find("Rayfield") or child.Name:find("ESP") or child.Name:find("Zoom") or child.Name:find("NMT") or child.Name:find("VehicleModifier") then
			pcall(function() child:Destroy() end)
		end
	end

	for _, child in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
		if child.Name:find("Rayfield") or child.Name:find("ESP") or child.Name:find("Zoom") or child.Name:find("NMT") or child.Name:find("VehicleModifier") or child.Name:find("CameraUnlocker") or child.Name:find("ExtendedFOV") then
			pcall(function() child:Destroy() end)
		end
	end

	LoadedScripts = {}
	SelectedScript = nil

	UnloadButton.Text = "✓ Unloaded"
	UnloadButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
	game.StarterGui:SetCore("SendNotification", {
		Title = "Script Loader",
		Text = "All scripts unloaded!",
		Duration = 2
	})
	task.wait(1.5)
	UnloadButton.Text = "Unload All"
	UnloadButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 1, -30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Loaded: 0"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Delete then
		GUI.Enabled = not GUI.Enabled
	end
end)

game.StarterGui:SetCore("SendNotification", {
	Title = "Script Loader",
	Text = "Press DELETE to toggle UI. Select a script and click Execute.",
	Duration = 5
})

print("✅ Script Loader ready. Press DELETE to toggle UI.")
