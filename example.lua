local Owl = loadstring(game:HttpGet("https://raw.githubusercontent.com/vze7/scripts/refs/heads/main/owl.lua", true))()

Owl:Load({
	Name = "Owl",
	Accent = Color3.fromRGB(190, 70, 255),
})

local window = Owl:CreateWindow({
	Name = "Owl Demo",
	SubText = "Complete Example",
	ConfigFolder = "OwlDemo",
	KeyToOpenWindow = Enum.KeyCode.RightShift,
	FreeMouse = true,
	PreserveCameraMode = true,
	Watermark = false,
	Home = {
		Enabled = true,
		hTitle = "Owl",
		hSubText = "Complete Example",
		profileImage = "",
	},
})

local mainTab = window:MakeTab({Name = "Main"})
local inputTab = window:MakeTab({Name = "Inputs"})

mainTab:Section("Information")

local status = mainTab:Paragraph({
	Title = "Owl Library",
	Content = "Every main component is demonstrated in this file.",
})

mainTab:Button({
	Title = "Notification",
	Description = "Displays a temporary notification.",
	CallBack = function()
		Owl:Notify({Title = "Owl", Content = "Notification working correctly.", Duration = 3})
	end,
})

mainTab:Button({
	Title = "Confirmation modal",
	Description = "Opens a modal without changing the camera mode.",
	CallBack = function()
		window:Modal({
			Title = "Confirm action",
			Content = "Do you want to continue?",
			CallBack = function()
				status:Set("Status", "The modal was confirmed.")
			end,
		})
	end,
})

mainTab:Button({
	Title = "Toast",
	Description = "Displays a compact message at the top.",
	CallBack = function()
		Owl:Toast({Content = "Owl is ready.", Duration = 3})
	end,
})

mainTab:Toggle({
	Title = "Saved toggle",
	Description = "The value is restored on the next execution.",
	Value = false,
	Flag = "demo_toggle",
	CallBack = function(value)
		status:Set("Toggle", value and "Enabled" or "Disabled")
	end,
})

mainTab:Slider({
	Title = "Movement speed",
	Description = "Example numeric control.",
	Range = {0, 100},
	Increment = 1,
	StarterValue = 50,
	Flag = "demo_speed",
	CallBack = function(value)
		print("Speed:", value)
	end,
})

mainTab:Dropdown({
	Title = "Mode",
	Options = {"Default", "Fast", "Safe"},
	Default = "Default",
	Flag = "demo_mode",
	CallBack = function(value)
		print("Mode:", value)
	end,
})

inputTab:Section("Input controls")

inputTab:Keybind({
	Title = "Action key",
	Description = "Click the bind and press another key.",
	Key = Enum.KeyCode.E,
	Flag = "demo_action_key",
	Save = true,
	CallBack = function()
		Owl:Toast({Content = "Action key pressed.", Duration = 2})
	end,
})

inputTab:TextInput({
	Title = "Player message",
	PlaceHolder = "Type something...",
	ClearOnLost = false,
	CallBack = function(value)
		status:Set("Text input", value)
	end,
})

inputTab:ColorPicker({
	Title = "Interface accent",
	Color = Color3.fromRGB(190, 70, 255),
	Flag = "demo_accent",
	CallBack = function(color)
		Owl:UpdateTheme({Accent = color, HitBox = color})
	end,
})

Owl:Notify({
	Title = "Owl",
	Content = "Example loaded. Press RightShift to toggle the UI.",
	Duration = 4,
})
