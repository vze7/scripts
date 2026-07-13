local OrionLib = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Lilwagz/scripts/main/Orion%20X?cache=" .. tostring(os.time())
))()

local Window = OrionLib:MakeWindow({
	Name = "Orion X - Dynamic List Test",
	HidePremium = true,
	SaveConfig = false,
	IntroEnabled = false,
	FreeMouse = true,
})

local ControlsTab = Window:MakeTab({
	Name = "Dynamic List",
	Icon = "list",
	PremiumOnly = false,
})

local Controls = ControlsTab:AddSection({
	Name = "List controls",
})

local Items = ControlsTab:AddSection({
	Name = "Items",
})

local buttons = {}
local nextId = 1
local counterLabel = Controls:AddLabel("0 visible items")

local function updateCounter()
	counterLabel:Set(string.format("%d visible items", #buttons))
end

local function addItem()
	local id = nextId
	nextId += 1

	local button
	button = Items:AddButton({
		Name = string.format("Dynamic button %02d", id),
		Icon = "mouse-pointer-click",
		Callback = function()
			for index, item in ipairs(buttons) do
				if item == button then
					table.remove(buttons, index)
					break
				end
			end
			button:Destroy()
			updateCounter()
		end,
	})

	table.insert(buttons, button)
	updateCounter()
end

local function removeLast()
	local button = table.remove(buttons)
	if button then
		button:Destroy()
		updateCounter()
	end
end

Controls:AddButton({
	Name = "Add 10 buttons",
	Icon = "plus",
	Callback = function()
		for _ = 1, 10 do
			addItem()
		end
	end,
})

Controls:AddButton({
	Name = "Remove last button",
	Icon = "minus",
	Callback = removeLast,
})

Controls:AddButton({
	Name = "Clear list",
	Icon = "trash-2",
	Callback = function()
		while #buttons > 0 do
			removeLast()
		end
	end,
})

for _ = 1, 40 do
	addItem()
end

local ComponentsTab = Window:MakeTab({
	Name = "Components",
	Icon = "sliders-horizontal",
	PremiumOnly = false,
})

local Feedback = ComponentsTab:AddSection({Name = "Live feedback"})
local feedbackLabel = Feedback:AddParagraph("Last interaction", "Use any control below.")

local function report(name, value)
	local text = tostring(value)
	if typeof(value) == "table" then
		local values = {}
		for key, item in pairs(value) do
			table.insert(values, string.format("%s=%s", tostring(key), tostring(item)))
		end
		table.sort(values)
		text = table.concat(values, ", ")
	end
	feedbackLabel:Set(string.format("%s: %s", name, text))
end

local Sliders = ComponentsTab:AddSection({Name = "Sliders"})
Sliders:AddSlider({
	Name = "Walk speed",
	Min = 0,
	Max = 100,
	Default = 16,
	Increment = 1,
	ValueName = "studs/s",
	Callback = function(value) report("Walk speed", value) end,
})
Sliders:AddSlider({
	Name = "Transparency",
	Min = 0,
	Max = 1,
	Default = 0.25,
	Increment = 0.05,
	ValueName = "",
	Callback = function(value) report("Transparency", value) end,
})
Sliders:AddSlider({
	Name = "Large range",
	Min = -1000,
	Max = 1000,
	Default = 0,
	Increment = 25,
	ValueName = "units",
	Callback = function(value) report("Large range", value) end,
})

local Switches = ComponentsTab:AddSection({Name = "Toggles and keybind"})
Switches:AddToggle({
	Name = "Feature enabled",
	Default = true,
	Callback = function(value) report("Feature enabled", value) end,
})
Switches:AddToggle({
	Name = "Rainbow mode",
	Default = false,
	Color = Color3.fromRGB(255, 80, 180),
	Callback = function(value) report("Rainbow mode", value) end,
})
Switches:AddBind({
	Name = "Test keybind",
	Default = Enum.KeyCode.K,
	Hold = false,
	Callback = function() report("Keybind", "K pressed") end,
})

local Inputs = ComponentsTab:AddSection({Name = "Text and color"})
Inputs:AddTextbox({
	Name = "Persistent text",
	Default = "Orion X",
	TextDisappear = false,
	Callback = function(value) report("Persistent text", value) end,
})
Inputs:AddTextbox({
	Name = "Clears after submit",
	Default = "",
	TextDisappear = true,
	Callback = function(value) report("Submitted text", value) end,
})
Inputs:AddColorpicker({
	Name = "Accent preview",
	Default = Color3.fromRGB(70, 150, 255),
	Mode = 1,
	Callback = function(value) report("Color", tostring(value)) end,
})

local DropdownsTab = Window:MakeTab({
	Name = "Dropdowns",
	Icon = "list-filter",
	PremiumOnly = false,
})

local DropdownTests = DropdownsTab:AddSection({Name = "Dropdown variants"})
DropdownTests:AddDropdown({
	Name = "Single selection",
	Options = {"Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta"},
	Default = "Alpha",
	SearchBar = true,
	MaxElements = 4,
	Callback = function(value) report("Single dropdown", value) end,
})
DropdownTests:AddDropdown({
	Name = "Multiple selection",
	Options = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange", "White", "Black"},
	Default = {"Red", "Blue"},
	MultipleSelection = true,
	SearchBar = true,
	MaxElements = 5,
	Callback = function(value) report("Multi dropdown", value) end,
})
DropdownTests:AddDropdown({
	Name = "Options with images",
	Options = {
		{Name = "Sword", Image = "rbxassetid://9909725942"},
		{Name = "House", Image = "rbxassetid://8989326312"},
		{Name = "Common", Image = "rbxassetid://8989327148"},
	},
	Default = "Sword",
	Callback = function(value) report("Image dropdown", value) end,
})
DropdownTests:AddPlayersDropdown({
	Name = "Players in server",
	Default = "",
	MultipleSelection = true,
	SearchBar = true,
	Callback = function(value) report("Players", value) end,
})

local StressTab = Window:MakeTab({
	Name = "Stress Test",
	Icon = "gauge",
	PremiumOnly = false,
})

local StressControls = StressTab:AddSection({Name = "Mass operations"})
local StressItems = StressTab:AddSection({Name = "Generated controls"})
local stressHandles = {}

local function clearStress()
	for _, handle in ipairs(stressHandles) do
		handle:Destroy()
	end
	table.clear(stressHandles)
end

StressControls:AddButton({
	Name = "Generate 100 buttons",
	Icon = "zap",
	Callback = function()
		clearStress()
		for index = 1, 100 do
			table.insert(stressHandles, StressItems:AddButton({
				Name = string.format("Stress item %03d", index),
				Callback = function() report("Stress click", index) end,
			}))
		end
	end,
})
StressControls:AddButton({
	Name = "Remove alternating items",
	Icon = "list-minus",
	Callback = function()
		for index = #stressHandles, 1, -2 do
			local handle = table.remove(stressHandles, index)
			handle:Destroy()
		end
	end,
})
StressControls:AddButton({
	Name = "Clear stress test",
	Icon = "trash-2",
	Callback = clearStress,
})

local Mixed = StressTab:AddSection({Name = "Mixed heights"})
Mixed:AddParagraph("Short paragraph", "One line of content.")
Mixed:AddParagraph(
	"Wrapped paragraph",
	"This is intentionally long text used to verify that wrapped paragraphs resize the section, scrolling canvas, and all following controls without overlaps."
)
for index = 1, 12 do
	Mixed:AddToggle({
		Name = "Generated toggle " .. index,
		Default = index % 2 == 0,
		Callback = function(value) report("Toggle " .. index, value) end,
	})
end

Window:AddConfigTab()
