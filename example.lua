local Owl = loadstring(game:HttpGet("https://raw.githubusercontent.com/vze7/scripts/main/owl.lua?v=28d5596", true))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function notify(title, content, duration)
	Owl:Notify({Title = title, Content = content, Duration = duration or 3})
end

local function humanoid()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

Owl:Load({
	Name = "Owl Complete Demo",
	Accent = Color3.fromRGB(0, 170, 255),
})

local window = Owl:CreateWindow({
	Name = "Owl Complete Demo",
	SubText = "All Library Features",
	ConfigFolder = "OwlDemo",
	KeyToOpenWindow = Enum.KeyCode.RightShift,
	FreeMouse = true,
	PreserveCameraMode = true,
	Watermark = false,
	Home = {Enabled = true, hTitle = "Owl Complete Demo", hSubText = "All Library Features", profileImage = ""},
})

local buttons = window:MakeTab({Name = "Buttons & Actions"})
local inputs = window:MakeTab({Name = "Inputs & Forms"})
local visuals = window:MakeTab({Name = "Visuals & Media"})
local controls = window:MakeTab({Name = "Controls & Settings"})
local advanced = window:MakeTab({Name = "Advanced Features"})

buttons:Section("Basic Buttons")
local status = buttons:Paragraph({Title = "Owl Library", Content = "Complete component demonstration."})

buttons:Button({
	Title = "Simple Button",
	CallBack = function()
		status:Set("Simple Button", "The callback is working.")
		notify("Success", "Simple button was clicked.")
	end,
})

buttons:Button({
	Title = "Button with Description",
	Description = "A normal action with supporting text.",
	CallBack = function()
		notify("Description Button", "Button was activated.")
	end,
})

buttons:Button({
	Title = "Hold Button",
	Description = "Hold for two seconds to activate.",
	Type = "Hold",
	HoldTime = 2,
	CallBack = function()
		notify("Hold Complete", "The hold action completed.")
	end,
})

buttons:Section("Toggle Controls")
buttons:Toggle({
	Title = "Basic Toggle",
	Value = false,
	Flag = "demo_basic_toggle",
	CallBack = function(value)
		status:Set("Basic Toggle", value and "Enabled" or "Disabled")
	end,
})

buttons:Toggle({
	Title = "Pre-enabled Toggle",
	Description = "This toggle starts enabled.",
	Value = true,
	Flag = "demo_enabled_toggle",
	CallBack = function(value)
		print("Pre-enabled Toggle:", value)
	end,
})

buttons:Toggle({
	Title = "Configurable Toggle (Session)",
	Description = "Starts enabled and resets when the script runs again.",
	Value = true,
	Config = true,
	Save = false,
	CallBack = function(value)
		notify("Session Toggle", value and "Enabled" or "Disabled", 2)
	end,
})

buttons:Toggle({
	Title = "Configurable Toggle (Saved)",
	Description = "Starts enabled and saves the selected value automatically.",
	Value = true,
	Config = true,
	Save = true,
	Flag = "demo_configurable_toggle_saved",
	CallBack = function(value)
		notify("Saved Toggle", value and "Enabled" or "Disabled", 2)
	end,
})

inputs:Section("Text Input Fields")
inputs:TextInput({
	Title = "Player Name",
	PlaceHolder = "Enter your name...",
	ClearOnLost = false,
	CallBack = function(text)
		notify("Name Set", text == "" and "No name entered." or "Hello, " .. text .. "!", 2)
	end,
})

inputs:TextInput({
	Title = "Walk Speed",
	PlaceHolder = "Enter a value from 16 to 100",
	NumberOnly = true,
	ClearOnLost = false,
	CallBack = function(text)
		local speed = tonumber(text)
		local characterHumanoid = humanoid()
		if characterHumanoid and speed and speed >= 16 and speed <= 100 then
			characterHumanoid.WalkSpeed = speed
			notify("Speed Changed", "Walk speed: " .. speed, 2)
		else
			notify("Invalid Speed", "Use a number between 16 and 100.")
		end
	end,
})

inputs:Section("Dropdown Menus")
inputs:Dropdown({
	Title = "Game Mode",
	Options = {"Adventure", "Creative", "Survival", "Spectator"},
	PlaceHolder = "Select a mode...",
	Flag = "demo_game_mode",
	CallBack = function(option)
		notify("Game Mode", "Selected: " .. tostring(option), 2)
	end,
})

inputs:Dropdown({
	Title = "Favorite Features",
	Options = {"Building", "Combat", "Exploration", "Trading", "Social"},
	PlaceHolder = "Select favorites...",
	Multi = true,
	Flag = "demo_favorite_features",
	CallBack = function(options)
		print("Favorite features:", options)
	end,
})

inputs:PlayerDropdown({
	Title = "Target Player",
	Description = "Player dropdown example.",
	PlaceHolder = "Select a player...",
	Flag = "demo_target_player",
	CallBack = function(name)
		notify("Target Player", "Selected: " .. tostring(name), 2)
	end,
})

inputs:PlayerMultiDropdown({
	Title = "Player MultiDropdown",
	Description = "Multi-select player dropdown example.",
	PlaceHolder = "Select players...",
	MultipleSelection = true,
	Flag = "demo_player_multi_dropdown",
	CallBack = function(selected)
		print("Selected players:", selected)
	end,
})

inputs:Section("Keybind Controls")
inputs:Keybind({
	Title = "Action Key",
	Description = "Click the key and choose another one.",
	Key = Enum.KeyCode.E,
	Flag = "demo_action_key",
	Save = true,
	CallBack = function()
		notify("Keybind Pressed", "Action key activated.", 2)
	end,
})

inputs:Keybind({
	Title = "Quick Notification",
	Key = Enum.KeyCode.F5,
	Flag = "demo_quick_notification",
	Save = true,
	CallBack = function()
		notify("Quick Notification", "Saved keybind is working.", 2)
	end,
})

visuals:Section("Color Pickers")
visuals:ColorPicker({
	Title = "Interface Accent",
	Color = Color3.fromRGB(0, 170, 255),
	Flag = "demo_interface_accent",
	CallBack = function(color)
		Owl:UpdateTheme({Accent = color, HitBox = color})
		Owl:SaveThemeCfg()
	end,
})

visuals:ColorPicker({
	Title = "Independent Color",
	Description = "A standalone color picker.",
	Linkable = false,
	Color = Color3.fromRGB(120, 220, 150),
	Flag = "demo_independent_color",
	CallBack = function(color)
		print("Independent color:", color)
	end,
})

visuals:Section("Text Elements")
visuals:Label("Left aligned label", "Left")
visuals:Label("Centered label", "Center")
visuals:Label("Right aligned label", "Right")
visuals:Paragraph({
	Title = "Features Overview",
	Content = "Owl provides buttons, toggles, sliders, dropdowns, keybinds, text inputs, color pickers, saved settings, notifications, and modals.",
})

controls:Section("Slider Controls")
controls:Slider({
	Title = "Movement Speed",
	Range = {16, 100},
	Increment = 1,
	StarterValue = 16,
	Flag = "demo_movement_speed",
	CallBack = function(value)
		local characterHumanoid = humanoid()
		if characterHumanoid then characterHumanoid.WalkSpeed = value end
	end,
})

controls:Slider({
	Title = "Field of View",
	Range = {70, 120},
	Increment = 1,
	StarterValue = 70,
	Flag = "demo_fov",
	CallBack = function(value)
		workspace.CurrentCamera.FieldOfView = value
	end,
})

controls:Slider({
	Title = "Brightness",
	Range = {0, 10},
	Increment = 1,
	StarterValue = 2,
	Flag = "demo_brightness",
	CallBack = function(value)
		game:GetService("Lighting").Brightness = value
	end,
})

advanced:Section("Advanced Features")
advanced:Button({
	Title = "Show Modal Dialog",
	Description = "Demonstrates the built-in modal.",
	CallBack = function()
		window:Modal({
			Title = "Confirmation Required",
			Content = "Do you want to continue?",
			CallBack = function()
				notify("Action Confirmed", "The modal callback ran.")
			end,
		})
	end,
})

advanced:Button({
	Title = "Test Notifications",
	Description = "Shows notification timing.",
	CallBack = function()
		notify("Quick Message", "Short notification.", 1)
		task.delay(1.2, function()
			notify("Information", "This is a longer notification message.", 3)
		end)
	end,
})

advanced:Button({
	Title = "Add Dynamic Toggle",
	Description = "Creates a toggle on this tab.",
	CallBack = function()
		advanced:Toggle({
			Title = "Dynamic Toggle " .. math.random(100, 999),
			Value = false,
			CallBack = function(value)
				print("Dynamic toggle:", value)
			end,
		})
		notify("Element Added", "A new toggle was created.")
	end,
})

advanced:Paragraph({
	Title = "Library Information",
	Content = "Owl version: " .. tostring(Owl.Build or "Unknown") .. "\nSettings and keybinds are saved in the OwlDemo folder.",
})

notify("Owl Complete Demo", "All example components loaded. Press RightShift to toggle the UI.", 5)
