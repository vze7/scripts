local tweenservice = game:GetService("TweenService")
local https = game:GetService("HttpService")
local runservice = game:GetService("RunService")
local userinput = game:GetService("UserInputService")
local textservice = game:GetService("TextService")
local player = game:GetService("Players")
local coregui = (gethui and gethui()) or game:GetService("CoreGui")

local Library = game:GetObjects("rbxassetid://123800669522471")[1]
local Loader = game:GetObjects("rbxassetid://110221114597158")[1]

local resizing = false
local screenSize = workspace.CurrentCamera.ViewportSize
local isMobile = userinput.TouchEnabled or (screenSize.X < 1024 and screenSize.Y < 768)
local dragOffset = 255
local dragOffsetMobile = 150
local layoutCamera = workspace.CurrentCamera

local function selectedChipAtPosition(scroller, input)
	if not scroller.Visible or not input or not input.Position then
		return nil
	end
	local point = input.Position

	local padding = isMobile and 2 or 1
	for _, chip in ipairs(scroller:GetChildren()) do
		if chip:IsA("Frame") and chip.Visible then
			local removeButton = chip:FindFirstChild("X")
			if removeButton and removeButton.Visible then
				local position = chip.AbsolutePosition
				local size = chip.AbsoluteSize
				if
					point.X >= position.X - padding
					and point.X <= position.X + size.X + padding
					and point.Y >= position.Y - padding
					and point.Y <= position.Y + size.Y + padding
				then
					return chip.Name
				end
			end
		end
	end
	return nil
end

local function isFiniteNumber(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function normalizeSliderOptions(options)
	local range = options.Range
	local minimum = type(range) == "table" and tonumber(range[1]) or nil
	local maximum = type(range) == "table" and tonumber(range[2]) or nil
	if not isFiniteNumber(minimum) or not isFiniteNumber(maximum) or maximum <= minimum then
		minimum, maximum = 0, 100
	end

	local increment = tonumber(options.Increment)
	if not isFiniteNumber(increment) or increment <= 0 then
		increment = 1
	end

	local value = tonumber(options.StarterValue)
	if not isFiniteNumber(value) then
		value = math.clamp(16, minimum, maximum)
	end

	options.Range = { minimum, maximum }
	options.Increment = increment
	options.StarterValue = math.clamp(value, minimum, maximum)
	return options
end

Library.Enabled = false
Loader.Enabled = false

local loaded = false
local normalizeConfigName
local ensureConfigFolder
local resolveConfigPath
local saveDebounce
local pendingSaveName
local configLoadGeneration = 0
local configLoadTasks = {}

local syde = {

	theme = {
		["Accent"] = Color3.fromRGB(255, 151, 227),
		["HitBox"] = Color3.fromRGB(255, 151, 227),
		["DropShadow"] = ColorSequence.new(Color3.fromRGB(0, 0, 0)),
	},
	Connections = {},
	Comms = Instance.new("BindableEvent"),
	ParentOverride = nil,
	Build = "Sv0",
	ApiVersion = 2,
	plugins = {},
	ConfigEnabled = true,
	ConfigFolder = "FireHub",
	ConfigFolderExplicit = false,
	ConfigFile = "Config",
	ConfigFileExplicit = false,
	Folder = "FireHub",
	SaveCfg = true,
	Flags = {},
	SettingsFlags = {},
	LoadedConfig = nil,
	IsLoadingConfig = false,
	UMouseMode = "PreserveCamera",
	maxds = 500,
	minds = 10,
	FreeMouse = true,
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150),
			Accent = Color3.fromRGB(255, 151, 227),
			HitBox = Color3.fromRGB(255, 151, 227),
		},
	},
	SelectedTheme = "Default",
	_currentWindow = nil,
	RainbowMode = false,
}

function syde:DeepMerge(target, source)
	for k, v in pairs(source) do
		if type(v) == "table" and type(target[k]) == "table" then
			self:DeepMerge(target[k], v)
		else
			target[k] = v
		end
	end
end

function syde:UpdateTheme(Config)
	if type(Config) ~= "table" then
		warn("[UpdateTheme] Invalid configuration table")
		return
	end

	local updatedKeys = {}

	for key, value in pairs(Config) do
		if self.theme[key] ~= nil then
			if typeof(self.theme[key]) == typeof(value) then
				if type(value) == "table" then
					self:DeepMerge(self.theme[key], value)
				else
					self.theme[key] = value
				end
				table.insert(updatedKeys, key)
			else
				warn(
					("[UpdateTheme] Type mismatch for key '%s' (expected %s, got %s)"):format(
						key,
						typeof(self.theme[key]),
						typeof(value)
					)
				)
			end
		else
			warn("[UpdateTheme] Key '" .. key .. "' does not exist in theme")
		end
	end

	if #updatedKeys > 0 then
		for _, key in ipairs(updatedKeys) do
			self.Comms:Fire(key, self.theme[key])
		end
	end
end

function syde:IsBindableInput(input)
	local t = input.UserInputType
	if t == Enum.UserInputType.Keyboard then
		return true
	end
	if string.find(tostring(t), "Gamepad", 1, true) then
		return input.KeyCode ~= Enum.KeyCode.Unknown
	end
	if string.find(tostring(t), "MouseButton", 1, true) then
		return true
	end
	return false
end

local function getBindableKey(input)
	if not input or not syde:IsBindableInput(input) then
		return nil
	end
	if input.KeyCode ~= Enum.KeyCode.Unknown then
		return input.KeyCode
	end
	if string.find(tostring(input.UserInputType), "MouseButton", 1, true) then
		return input.UserInputType
	end
	return nil
end

local function encodeToggleKeybind(key)
	if typeof(key) ~= "EnumItem" then
		return nil
	end
	if key.EnumType == Enum.KeyCode then
		return key.Name
	end
	if key.EnumType == Enum.UserInputType then
		return "UserInputType:" .. key.Name
	end
	return nil
end

local function decodeToggleKeybind(value)
	if type(value) ~= "string" then
		return nil
	end
	local inputTypeName = value:match("^UserInputType:(.+)$")
	if inputTypeName then
		return Enum.UserInputType[inputTypeName]
	end

	return Enum.KeyCode[value] or Enum.UserInputType[value]
end

local function matchesToggleKeybind(key, input)
	if typeof(key) ~= "EnumItem" or not input then
		return false
	end
	if key.EnumType == Enum.KeyCode then
		return input.KeyCode == key
	end
	if key.EnumType == Enum.UserInputType then
		return input.UserInputType == key
	end
	return false
end

function syde:DecimalPlaces(num)
	local str = string.format("%.10f", tonumber(num) or 0)
	str = str:gsub("0+$", "")
	str = str:gsub("%.$", "")
	local dot = string.find(str, ".", 1, true)
	if not dot then
		return 0
	end
	return #str - dot
end

function syde:RoundTo(num, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(num * mult + 0.5) / mult
end

function syde:SetSliderGradient(fill, accent)
	if typeof(fill) ~= "Instance" or not fill:IsA("GuiObject") then
		return false
	end
	accent = accent or (self.theme and self.theme.Accent) or Color3.fromRGB(0, 170, 255)
	local gradient = fill:FindFirstChild("SydeSliderGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Name = "SydeSliderGradient"
		gradient.Rotation = 0
		gradient.Parent = fill
	end
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, accent:Lerp(Color3.new(1, 1, 1), 0.1)),
		ColorSequenceKeypoint.new(1, accent),
	})
	return true
end

function syde:SetClipboard(text)
	local fn = setclipboard or toclipboard or set_clipboard or writeclipboard or (syn and syn.write_clipboard)
	if fn then
		return (pcall(fn, text))
	end
	return false
end

function syde:OnClick(object, callback)
	if not object then
		return
	end
	local target = object:FindFirstChild("interact") or object:FindFirstChild("Interact") or object
	if target:IsA("GuiButton") then
		target.MouseButton1Click:Connect(callback)
	else
		target.Active = true
		target.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				callback()
			end
		end)
	end
end

function syde:FlashCopy(icon)
	if not icon then
		return
	end
	tweenservice
		:Create(icon, TweenInfo.new(0.12, Enum.EasingStyle.Quint), { ImageColor3 = Color3.fromRGB(120, 220, 120) })
		:Play()
	task.delay(0.4, function()
		tweenservice
			:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { ImageColor3 = Color3.fromRGB(255, 255, 255) })
			:Play()
	end)
end

function syde:Report(context, err)
	local message = tostring(err or "unknown error")
	local low = string.lower(message)

	local fix
	if
		string.find(low, "httpget", 1, true)
		or string.find(low, "getobjects", 1, true)
		or string.find(low, "failed to load library", 1, true)
		or string.find(low, "rbxassetid", 1, true)
	then
		fix =
			"The UI asset/source failed to download. Re-run it; if it keeps happening your executor is blocking HttpGet/asset loading, or GitHub is serving an old/partial copy (wait ~30s)."
	elseif
		string.find(low, "not a valid member", 1, true)
		or string.find(low, "attempt to index nil", 1, true)
		or string.find(low, "index a nil", 1, true)
	then
		fix =
			"A UI element is missing - your Source and the UI asset id are out of sync. Re-copy the newest Source and re-grab the UI asset."
	elseif string.find(low, "attempt to call a nil value", 1, true) then
		fix =
			"A required function is missing - usually an executor that lacks a global like gethui/getgenv/setclipboard. Try an updated/different executor."
	elseif string.find(low, "callback", 1, true) then
		fix =
			"This came from a callback (your own function), not Syde itself. Check the function attached to that element."
	else
		fix = "Unexpected error - send the screenshot above so it can be looked into."
	end

	warn(table.concat({
		"",
		"----------screenshot this and send it to king jericoo------",
		"[ Syde ] " .. tostring(context or "Errorr"),
		"Problem: " .. message,
		"Fix: " .. fix,
		"------------------------------------------------------------",
		"",
	}, "\n"))
end

function syde:Guard(context, fn)
	return function(...)
		local res = table.pack(pcall(fn, ...))
		if not res[1] then
			syde:Report(context, res[2])
			return nil
		end
		return table.unpack(res, 2, res.n)
	end
end

function syde:AttachSliderInput(Slider, Options)
	local valueLabel = Slider:FindFirstChild("v")
	if not valueLabel or valueLabel:FindFirstChild("ValueInput") then
		return
	end

	local function maxString()
		local dp = syde:DecimalPlaces(Options.Increment)
		return string.format("%." .. dp .. "f", tonumber(Options.Range[2]) or 0)
	end

	local function renderValue(valueText)
		valueLabel.Text =
			string.format("<font size='14'>%s</font><font color='#434343'>/%s</font>", valueText, maxString())
	end

	local function renderCurrent()
		local dp = syde:DecimalPlaces(Options.Increment)
		renderValue(string.format("%." .. dp .. "f", tonumber(Options.StarterValue) or 0))
	end

	local editing = false

	local editBox = Instance.new("TextBox")
	editBox.Name = "ValueInput"
	editBox.BackgroundTransparency = 1
	editBox.Text = ""
	editBox.PlaceholderText = ""
	editBox.TextEditable = true
	editBox.ClearTextOnFocus = false
	editBox.RichText = false
	editBox.MultiLine = false
	editBox.Active = true
	editBox.Selectable = true
	editBox.TextTransparency = 1
	editBox.TextSize = 14
	editBox.Size = UDim2.fromScale(1, 1)
	editBox.Position = UDim2.fromScale(0, 0)
	editBox.ZIndex = valueLabel.ZIndex + 5
	editBox.Parent = valueLabel

	editBox.Focused:Connect(function()
		editing = true
		editBox.Text = ""
		renderValue("")
	end)

	editBox:GetPropertyChangedSignal("Text"):Connect(function()
		if not editing then
			return
		end
		renderValue(editBox.Text)
	end)

	editBox.FocusLost:Connect(function()
		editing = false
		local raw = editBox.Text
		editBox.Text = ""

		local typed = tonumber(raw)
		local low = math.min(Options.Range[1], Options.Range[2])
		local high = math.max(Options.Range[1], Options.Range[2])

		if raw ~= "" and typed and typed >= low and typed <= high and Options.Set then
			local inc = Options.Increment or 1
			if inc > 0 then
				typed = math.floor((typed - low) / inc + 0.5) * inc + low
				typed = syde:RoundTo(typed, syde:DecimalPlaces(inc))
				typed = math.clamp(typed, low, high)
			end
			Options:Set(typed)
		else
			renderCurrent()
		end
	end)

	return editBox
end

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
while not camera do
	RunService.RenderStepped:Wait()
	camera = workspace.CurrentCamera
end

do
	local function IsNotNaN(x)
		return x == x
	end
	local continue = IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x)
	while not continue do
		RunService.RenderStepped:wait()
		continue = IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x)
	end
end

local binds = {}
local root = Instance.new("Folder")
root.Name = "neon"
root.Parent = workspace

local cameraChangedConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = workspace.CurrentCamera
	for frame, binding in pairs(binds) do
		if frame.Parent and binding.update then
			binding.update(true)
		end
	end
end)

local GenUid
do
	local id = 0
	function GenUid()
		id = id + 1
		return "neon::" .. tostring(id)
	end
end

local DrawQuad
do
	local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
	local sz = 0.2

	function DrawTriangle(v1, v2, v3, p0, p1)
		local s1 = (v1 - v2).magnitude
		local s2 = (v2 - v3).magnitude
		local s3 = (v3 - v1).magnitude
		local smax = max(s1, s2, s3)
		local A, B, C
		if s1 == smax then
			A, B, C = v1, v2, v3
		elseif s2 == smax then
			A, B, C = v2, v3, v1
		elseif s3 == smax then
			A, B, C = v3, v1, v2
		end

		local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude
		local perp = sqrt((C - A).magnitude ^ 2 - para * para)
		local dif_para = (A - B).magnitude - para

		local st = CFrame.new(B, A)
		local za = CFrame.Angles(pi / 2, 0, 0)

		local cf0 = st

		local Top_Look = (cf0 * za).lookVector
		local Mid_Point = A + CFrame.new(A, B).lookVector * para
		local Needed_Look = CFrame.new(Mid_Point, C).lookVector
		local dot = Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z

		local ac = CFrame.Angles(0, 0, acos(dot))

		cf0 = cf0 * ac
		if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
			cf0 = cf0 * CFrame.Angles(0, 0, -2 * acos(dot))
		end
		cf0 = cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2))

		local cf1 = st * ac * CFrame.Angles(0, pi, 0)
		if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
			cf1 = cf1 * CFrame.Angles(0, 0, 2 * acos(dot))
		end
		cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2)

		if not p0 then
			p0 = Instance.new("Part")
			p0.FormFactor = "Custom"
			p0.TopSurface = 0
			p0.BottomSurface = 0
			p0.Anchored = true
			p0.CanCollide = false
			p0.Material = "Glass"
			p0.Size = Vector3.new(sz, sz, sz)
			local mesh = Instance.new("SpecialMesh", p0)
			mesh.MeshType = 2
			mesh.Name = "WedgeMesh"
		end
		p0.WedgeMesh.Scale = Vector3.new(0, perp / sz, para / sz)
		p0.CFrame = cf0

		if not p1 then
			p1 = p0:clone()
		end
		p1.WedgeMesh.Scale = Vector3.new(0, perp / sz, dif_para / sz)
		p1.CFrame = cf1

		return p0, p1
	end

	function DrawQuad(v1, v2, v3, v4, parts)
		parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
		parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
	end
end

function syde:BindFrame(frame, properties)
	if self._destroyed then
		return nil
	end
	if typeof(frame) ~= "Instance" or not frame:IsA("GuiObject") then
		warn("[BindFrame] Expected a live GuiObject")
		return nil
	end
	properties = type(properties) == "table" and properties or {}
	if binds[frame] then
		return binds[frame].parts
	end

	local uid = GenUid()
	local parts = {}
	local f = Instance.new("Folder", root)
	f.Name = frame.Name

	local parents = {}
	do
		local function add(child)
			if child:IsA("GuiObject") then
				parents[#parents + 1] = child
				add(child.Parent)
			end
		end
		add(frame)
	end

	local function UpdateOrientation(fetchProps)
		if not camera or not camera.Parent then
			return false
		end
		local zIndex = 1 - 0.05 * frame.ZIndex

		local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		do
			local rot = 0
			for _, v in ipairs(parents) do
				rot = rot + v.Rotation
			end
			if rot ~= 0 and rot % 180 ~= 0 then
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				local vec = tl
				tl = Vector2.new(c * (tl.x - mid.x) - s * (tl.y - mid.y), s * (tl.x - mid.x) + c * (tl.y - mid.y)) + mid
				tr = Vector2.new(c * (tr.x - mid.x) - s * (tr.y - mid.y), s * (tr.x - mid.x) + c * (tr.y - mid.y)) + mid
				bl = Vector2.new(c * (bl.x - mid.x) - s * (bl.y - mid.y), s * (bl.x - mid.x) + c * (bl.y - mid.y)) + mid
				br = Vector2.new(c * (br.x - mid.x) - s * (br.y - mid.y), s * (br.x - mid.x) + c * (br.y - mid.y)) + mid
			end
		end
		DrawQuad(
			camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
			camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
			camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
			camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
			parts
		)
		if fetchProps then
			for _, pt in pairs(parts) do
				pt.Parent = f
			end
			for propName, propValue in pairs(properties) do
				for _, pt in pairs(parts) do
					pt[propName] = propValue
				end
			end
		end
	end

	UpdateOrientation(true)
	RunService:BindToRenderStep(uid, 2000, UpdateOrientation)
	local _, disconnectDestroying = self:AddConnection(frame.Destroying, function()
		self:UnbindFrame(frame)
	end)

	binds[frame] = {
		uid = uid,
		parts = parts,
		folder = f,
		update = UpdateOrientation,
		disconnectDestroying = disconnectDestroying,
	}
	return binds[frame].parts
end

function syde:Modify(frame, properties)
	local parts = syde:GetBoundParts(frame)
	if parts then
		for propName, propValue in pairs(properties) do
			for _, pt in pairs(parts) do
				pt[propName] = propValue
			end
		end
	else
		warn(("No part bindings exist for %s"):format(frame:GetFullName()))
	end
end

function syde:UnbindFrame(frame)
	local cb = binds[frame]
	if cb then
		if cb.disconnectDestroying then
			cb.disconnectDestroying()
			cb.disconnectDestroying = nil
		end
		RunService:UnbindFromRenderStep(cb.uid)
		for _, v in pairs(cb.parts) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		if cb.folder and cb.folder.Parent then
			cb.folder:Destroy()
		end
		binds[frame] = nil
	else
		warn(("No part bindings exist for %s"):format(frame:GetFullName()))
	end
end

function syde:HasBinding(frame)
	return binds[frame] ~= nil
end

function syde:GetBoundParts(frame)
	return binds[frame] and binds[frame].parts
end

function syde:GetDark(Color, val, mode)
	if typeof(Color) ~= "Color3" or type(val) ~= "number" then
		warn("[getdark] Invalid input: Expected (Color3, number)")
		return Color
	end

	local H, S, V = Color:ToHSV()

	val = math.clamp(val, 0.1, 10)

	if mode == "subtract" then
		V = math.clamp(V - (val / 10), 0, 1)
	else
		V = math.clamp(V / val, 0, 1)
	end

	return Color3.fromHSV(H, S, V)
end

function syde:GetLighter(color: Color3, strength: number)
	strength = math.clamp(strength or 0.2, 0, 1)

	return Color3.new(
		color.R + (1 - color.R) * strength,
		color.G + (1 - color.G) * strength,
		color.B + (1 - color.B) * strength
	)
end

function syde:ColorPack(color)
	assert(typeof(color) == "Color3", "PackColor expects a Color3 value.")

	return {
		R = math.round(color.R * 255),
		G = math.round(color.G * 255),
		B = math.round(color.B * 255),
	}
end

function syde:ColorUnpack(color)
	assert(
		type(color) == "table" or type(color) == "string",
		"Invalid color format. Expected table (RGB) or string (HEX)."
	)

	if type(color) == "table" then
		assert(color.R and color.G and color.B, "RGB table must contain 'R', 'G', and 'B' keys.")
		return Color3.fromRGB(math.clamp(color.R, 0, 255), math.clamp(color.G, 0, 255), math.clamp(color.B, 0, 255))
	elseif type(color) == "string" then
		local hex = color:match("^#?(%x%x%x%x%x%x)$")
		assert(hex, "Invalid HEX color format. Expected '#RRGGBB' or 'RRGGBB'.")
		local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
		return Color3.fromRGB(r, g, b)
	end
end

function syde:HidePH(instance, placeholder, recursive)
	if typeof(instance) ~= "Instance" or type(placeholder) ~= "string" then
		warn("[removeplaceholder] Invalid input: Expected (Instance, string)")
		return
	end

	local target = instance:FindFirstChild(placeholder)

	if not target then
		warn(("[removeplaceholder] Placeholder '%s' not found in instance '%s'"):format(placeholder, instance.Name))
		return
	end

	if target:IsA("GuiObject") then
		target.Visible = false
	else
		warn(("[removeplaceholder] '%s' is not a GuiObject and cannot be hidden"):format(placeholder))
		return
	end

	if recursive then
		for _, child in ipairs(target:GetDescendants()) do
			if child:IsA("GuiObject") then
				child.Visible = false
			end
		end
	end
end

local connectionCleanupTask
local function scheduleConnectionCleanup()
	if connectionCleanupTask or #syde.Connections == 0 then
		return
	end
	connectionCleanupTask = task.delay(10, function()
		connectionCleanupTask = nil
		for i = #syde.Connections, 1, -1 do
			local connectionData = syde.Connections[i]
			local connection = connectionData and (connectionData.Connection or connectionData)
			if not connection or not connection.Connected then
				table.remove(syde.Connections, i)
			end
		end
		scheduleConnectionCleanup()
	end)
end

function syde:AddConnection(Type, Callback)
	if syde._destroyed then
		error("[AddConnection] Cannot connect after Syde has been destroyed")
	end
	if typeof(Type) ~= "RBXScriptSignal" then
		error("[AddConnection] Invalid Type: Expected RBXScriptSignal, got " .. typeof(Type))
	end
	if typeof(Callback) ~= "function" then
		error("[AddConnection] Invalid Callback: Expected function, got " .. typeof(Callback))
	end

	local Connection = Type:Connect(Callback)
	local ConnectionData = { Connection = Connection }

	syde.Connections = syde.Connections or {}
	table.insert(syde.Connections, ConnectionData)
	scheduleConnectionCleanup()

	local function Disconnect()
		if Connection.Connected then
			Connection:Disconnect()
		end

		for i = #syde.Connections, 1, -1 do
			if syde.Connections[i] == ConnectionData then
				table.remove(syde.Connections, i)
				break
			end
		end
	end

	return Connection, Disconnect
end

local Bento = {}
Bento.__index = Bento

function Bento.new(container, config)
	local self = setmetatable({}, Bento)

	self.Container = container
	self.Items = {}

	self.Rows = {}

	self.Gap = config.Gap or 8
	self.RightPadding = config.RightPadding or 16
	self.TweenTime = config.TweenTime or 0.3

	self.OriginalContainerSize = container.Size

	self.Original = {}
	self.ActiveTweens = {}

	return self
end

function Bento:NewRow()
	local row = {}
	table.insert(self.Rows, row)
	return row
end

function Bento:AddItem(frame, options, row)
	frame.AnchorPoint = Vector2.new(0, 0)

	local item = {
		Frame = frame,
		Bottom = options and options.Bottom,
		Row = row,
	}

	self.Original[frame] = {
		Position = frame.Position,
		Size = frame.Size,
	}

	table.insert(self.Items, item)

	if row then
		table.insert(row, item)
	end
end

function Bento:Tween(frame, goal)
	if self.ActiveTweens[frame] then
		self.ActiveTweens[frame]:Cancel()
	end

	local tween =
		tweenservice:Create(frame, TweenInfo.new(self.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)

	self.ActiveTweens[frame] = tween
	tween:Play()

	tween.Completed:Connect(function()
		if self.ActiveTweens[frame] == tween then
			self.ActiveTweens[frame] = nil
		end
	end)
end

function Bento:Update()
	local containerWidth = self.Container.AbsoluteSize.X

	local normalItems = {}
	local bottomItems = {}

	for _, item in ipairs(self.Items) do
		if item.Bottom then
			table.insert(bottomItems, item)
		else
			table.insert(normalItems, item)
		end
	end

	local sortedRows = {}

	if #self.Rows > 0 then
		for _, row in ipairs(self.Rows) do
			table.insert(sortedRows, {
				Items = row,
			})
		end
	else
		local rows = {}

		for _, item in ipairs(normalItems) do
			local original = self.Original[item.Frame]
			local y = original.Position.Y.Offset

			rows[y] = rows[y] or {}
			table.insert(rows[y], item)
		end

		for y, row in pairs(rows) do
			table.insert(sortedRows, {
				Y = y,
				Items = row,
			})
		end

		table.sort(sortedRows, function(a, b)
			return a.Y < b.Y
		end)
	end

	local widestRow = 0

	for _, row in ipairs(sortedRows) do
		local width = 0

		for _, item in ipairs(row.Items) do
			width += self.Original[item.Frame].Size.X.Offset
		end

		width += (#row.Items - 1) * self.Gap

		if width > widestRow then
			widestRow = width
		end
	end

	local stacked = widestRow > containerWidth

	if stacked then
		local y = 0

		local function stackItem(item)
			local frame = item.Frame
			local original = self.Original[frame]

			self:Tween(frame, {
				Position = UDim2.fromOffset(0, y),
				Size = UDim2.fromOffset(containerWidth - self.RightPadding, original.Size.Y.Offset),
			})

			y += original.Size.Y.Offset + self.Gap
		end

		for _, row in ipairs(sortedRows) do
			for _, item in ipairs(row.Items) do
				if not item.Bottom then
					stackItem(item)
				end
			end
		end

		for _, item in ipairs(bottomItems) do
			stackItem(item)
		end

		self.Container.Size =
			UDim2.new(self.OriginalContainerSize.X.Scale, self.OriginalContainerSize.X.Offset, 0, y - self.Gap)

		return
	end

	if #self.Rows > 0 then
		local y = 0
		for _, row in ipairs(sortedRows) do
			table.sort(row.Items, function(left, right)
				return self.Original[left.Frame].Position.X.Offset < self.Original[right.Frame].Position.X.Offset
			end)
			local rowHeight = 0
			for index, item in ipairs(row.Items) do
				local frame = item.Frame
				local original = self.Original[frame]
				local x = original.Position.X.Offset
				local nextItem = row.Items[index + 1]
				local width = nextItem and (self.Original[nextItem.Frame].Position.X.Offset - x - self.Gap)
					or (containerWidth - x - self.RightPadding)
				local height = math.max(original.Size.Y.Offset, frame.AbsoluteSize.Y)
				rowHeight = math.max(rowHeight, height)
				self:Tween(frame, {
					Position = UDim2.fromOffset(x, y),
					Size = UDim2.fromOffset(math.max(0, width), height),
				})
			end
			y += rowHeight + self.Gap
		end
		self.Container.Size = UDim2.new(
			self.OriginalContainerSize.X.Scale,
			self.OriginalContainerSize.X.Offset,
			0,
			math.max(0, y - self.Gap)
		)
		return
	end

	for _, row in ipairs(sortedRows) do
		table.sort(row.Items, function(a, b)
			local ax = self.Original[a.Frame].Position.X.Offset
			local bx = self.Original[b.Frame].Position.X.Offset

			return ax < bx
		end)

		for i, item in ipairs(row.Items) do
			local frame = item.Frame
			local original = self.Original[frame]

			local currentX = original.Position.X.Offset
			local height = original.Size.Y.Offset

			local nextItem = row.Items[i + 1]

			local width

			if nextItem then
				local nextX = self.Original[nextItem.Frame].Position.X.Offset

				width = nextX - currentX - self.Gap
			else
				width = containerWidth - currentX - self.RightPadding
			end

			self:Tween(frame, {
				Position = original.Position,
				Size = UDim2.fromOffset(width, height),
			})
		end
	end

	for _, item in ipairs(bottomItems) do
		local frame = item.Frame
		local original = self.Original[frame]

		local width = containerWidth - original.Position.X.Offset - self.RightPadding

		self:Tween(frame, {
			Position = original.Position,
			Size = UDim2.fromOffset(width, original.Size.Y.Offset),
		})
	end

	self.Container.Size = self.OriginalContainerSize
end

function Bento:Bind()
	local busy = false
	local pendingAfterResize = false

	self.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if resizing then
			if pendingAfterResize then
				return
			end
			pendingAfterResize = true
			task.spawn(function()
				repeat
					task.wait(0.1)
				until not resizing or not self.Container.Parent
				pendingAfterResize = false
				if self.Container.Parent then
					self:Update()
				end
			end)
			return
		end

		if busy then
			return
		end
		busy = true

		task.defer(function()
			self:Update()

			busy = false
		end)
	end)
end

function syde:MakeResizable(Dragger, Object, MinSize, Callback, LockAspectRatio)
	if self._destroyed then
		return false
	end
	assert(typeof(Dragger) == "Instance" and Dragger:IsA("GuiObject"), "[MakeResizable] Dragger must be a GuiObject")
	assert(typeof(Object) == "Instance" and Object:IsA("GuiObject"), "[MakeResizable] Object must be a GuiObject")
	assert(typeof(MinSize) == "Vector2", "[MakeResizable] MinSize must be a Vector2")
	assert(Callback == nil or typeof(Callback) == "function", "[MakeResizable] Callback must be a function or nil")

	local userInput = game:GetService("UserInputService")

	local startPosition, startSize = nil, nil
	local isResizing = false
	local activeTouch
	local pendingSize
	local renderConnection
	local resizeDisconnects = {}
	local lastAppliedSize
	local previewGeneration = 0
	local preview = Instance.new("Frame")
	preview.Name = "ResizePreview"
	preview.BackgroundTransparency = 1
	preview.BorderSizePixel = 0
	preview.Active = false
	preview.Visible = false
	preview.ZIndex = Object.ZIndex + 5
	preview.Parent = Object.Parent
	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 18)
	previewCorner.Parent = preview
	local previewStroke = Instance.new("UIStroke")
	previewStroke.Color = Color3.fromRGB(145, 145, 150)
	previewStroke.Thickness = 2
	previewStroke.Transparency = 1
	previewStroke.Parent = preview
	local function applyPendingSize()
		if not pendingSize or pendingSize == lastAppliedSize then
			return
		end
		preview.Size = pendingSize
		lastAppliedSize = pendingSize
	end

	local function getInputPos(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			return Vector2.new(input.Position.X, input.Position.Y)
		else
			return userInput:GetMouseLocation()
		end
	end

	local function onInputBegan(input)
		if
			not isResizing
			and (
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			isResizing = true
			resizing = true
			startPosition = getInputPos(input)
			startSize = Object.AbsoluteSize
			activeTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
			previewGeneration += 1
			preview.AnchorPoint = Object.AnchorPoint
			preview.Position = Object.Position
			preview.Size = Object.Size
			preview.Visible = true
			previewStroke.Transparency = 1
			tweenservice
				:Create(
					previewStroke,
					TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Transparency = 0.2 }
				)
				:Play()
			local arrow = Dragger:FindFirstChild("ResizeArrow")
			if arrow then
				arrow.TextTransparency = 0.1
			end
			renderConnection = runservice.RenderStepped:Connect(applyPendingSize)
		end
	end

	local function onInputChanged(input)
		if
			isResizing
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			if activeTouch and input ~= activeTouch then
				return
			end
			if not activeTouch and input.UserInputType == Enum.UserInputType.Touch then
				return
			end
			local mouse = getInputPos(input)
			if startPosition and mouse then
				local delta = mouse - startPosition

				local viewport = workspace.CurrentCamera.ViewportSize
				local maxWidth = math.max(1, viewport.X - 24)
				local maxHeight = math.max(1, viewport.Y - 24)
				local newWidth = math.clamp(startSize.X + delta.X, math.min(MinSize.X, maxWidth), maxWidth)
				local newHeight = math.clamp(startSize.Y + delta.Y, math.min(MinSize.Y, maxHeight), maxHeight)

				if LockAspectRatio then
					local aspectRatio = startSize.X / startSize.Y
					newHeight = math.clamp(newWidth / aspectRatio, math.min(MinSize.Y, maxHeight), maxHeight)
				end

				pendingSize = UDim2.fromOffset(math.floor(newWidth), math.floor(newHeight))
			end
		end
		return true
	end

	local function finishResize(commit)
		if not isResizing then
			return
		end

		local sizeToApply = pendingSize
		local shouldNotify = commit and sizeToApply ~= nil and Object.Parent and Object.Size ~= sizeToApply
		if shouldNotify then
			Object.Size = sizeToApply
		end
		if renderConnection then
			renderConnection:Disconnect()
			renderConnection = nil
		end
		isResizing = false
		resizing = false
		activeTouch = nil
		startPosition, startSize, pendingSize, lastAppliedSize = nil, nil, nil, nil

		local generation = previewGeneration
		if preview.Parent then
			tweenservice
				:Create(
					previewStroke,
					TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Transparency = 1 }
				)
				:Play()
			task.delay(0.12, function()
				if preview.Parent and previewGeneration == generation and not isResizing then
					preview.Visible = false
				end
			end)
		end
		local arrow = Dragger:FindFirstChild("ResizeArrow")
		if arrow then
			arrow.TextTransparency = 0.45
		end

		if shouldNotify and Callback then
			local ok, err = pcall(Callback, Vector2.new(sizeToApply.X.Offset, sizeToApply.Y.Offset))
			if not ok then
				syde:Report("Resize callback", err)
			end
		end
		if commit and Object.Parent then
			task.defer(function()
				local pages = Library and Library.main and Library.main:FindFirstChild("pages")
				if not pages then
					return
				end
				for _, page in ipairs(pages:GetChildren()) do
					if page:IsA("ScrollingFrame") and page.Visible then
						syde:updateLayout(page, 7)
					end
				end
			end)
		end
	end

	local function onInputEnded(input)
		if
			isResizing
			and (
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			if activeTouch and input ~= activeTouch then
				return
			end
			if not activeTouch and input.UserInputType == Enum.UserInputType.Touch then
				return
			end
			finishResize(true)
		end
	end

	local function trackResizeConnection(signal, callback)
		local _, disconnect = self:AddConnection(signal, callback)
		resizeDisconnects[#resizeDisconnects + 1] = disconnect
	end

	local function cleanupResize()
		finishResize(false)
		for index = #resizeDisconnects, 1, -1 do
			resizeDisconnects[index]()
			resizeDisconnects[index] = nil
		end
		if preview.Parent then
			preview:Destroy()
		end
	end

	trackResizeConnection(Dragger.InputBegan, onInputBegan)
	trackResizeConnection(userInput.InputChanged, onInputChanged)
	trackResizeConnection(userInput.InputEnded, onInputEnded)
	trackResizeConnection(userInput.WindowFocusReleased, function()
		finishResize(true)
	end)
	trackResizeConnection(Dragger.Destroying, cleanupResize)
	return true
end

local loadTweens = {}

function syde:registerLoadTween(object, properties, initialState, tweenInfo)
	assert(typeof(object) == "Instance", "[registerLoadTween] Object must be an Instance")
	assert(typeof(properties) == "table", "[registerLoadTween] Properties must be a table")
	assert(typeof(initialState) == "table", "[registerLoadTween] Initial state must be a table")
	assert(typeof(tweenInfo) == "TweenInfo", "[registerLoadTween] TweenInfo must be of type TweenInfo")

	loadTweens[object] = {
		tween = tweenservice:Create(object, tweenInfo, properties),
		properties = properties,
		initialState = initialState,
		tweenInfo = tweenInfo,
	}
end

function syde:resetToInitialState(animated, resetTweenInfo)
	for object, tweenData in pairs(loadTweens) do
		if object and object.Parent then
			tweenData.tween:Cancel()

			if animated then
				local resetTween =
					tweenservice:Create(object, resetTweenInfo or TweenInfo.new(0.3), tweenData.initialState)
				resetTween:Play()
				resetTween.Completed:Wait()
			else
				for property, value in pairs(tweenData.initialState) do
					object[property] = value
				end
			end
		end
	end
end

function syde:replayLoadTweens(targetObject)
	syde:resetToInitialState(false)

	for object, tweenData in pairs(loadTweens) do
		if object and object.Parent then
			if not targetObject or object == targetObject then
				tweenData.tween:Cancel()
				tweenData.tween:Play()
			end
		end
	end
end

function syde:removeLoadTween(object)
	if loadTweens[object] then
		loadTweens[object].tween:Cancel()
		loadTweens[object] = nil
	end
end

local RunService = game:GetService("RunService")
local activeWiggles = setmetatable({}, { __mode = "k" })
local nextWiggleId = 0

function syde:WiggleText(label)
	if self._destroyed or typeof(label) ~= "Instance" or not label:IsA("TextLabel") then
		return false
	end
	if not label.Text or label.Text == "" then
		return false
	end

	self:StopWiggle(label)

	local container = Instance.new("Folder")
	container.Name = "WiggleContainer"
	container.Parent = label

	local originalTextTransparency = label.TextTransparency
	label.TextTransparency = 1

	local baseText = label.Text:gsub("<.->", "")
	local fontFace = label.FontFace
	local baseSize = label.TextSize
	local textColor = label.TextColor3

	local chars = {}
	local xOffset = 0

	for firstByte, lastByte in utf8.graphemes(baseText) do
		local char = baseText:sub(firstByte, lastByte)
		local charLabel = Instance.new("TextLabel")
		charLabel.BackgroundTransparency = 1
		charLabel.Text = char
		charLabel.TextColor3 = textColor
		charLabel.TextSize = baseSize
		charLabel.FontFace = fontFace
		charLabel.TextXAlignment = Enum.TextXAlignment.Left
		charLabel.TextYAlignment = Enum.TextYAlignment.Center
		charLabel.AnchorPoint = Vector2.new(0, 0.5)
		charLabel.Position = UDim2.new(0, xOffset, 0.5, 0)
		charLabel.Parent = container
		charLabel.ZIndex = 99

		xOffset += charLabel.TextBounds.X
		table.insert(chars, charLabel)
	end

	local t = 0
	nextWiggleId += 1
	local id = "SydeWiggle_" .. tostring(nextWiggleId)
	local state = {
		id = id,
		container = container,
		originalTextTransparency = originalTextTransparency,
	}
	activeWiggles[label] = state
	local _, disconnectDestroying = self:AddConnection(label.Destroying, function()
		self:StopWiggle(label)
	end)
	state.disconnectDestroying = disconnectDestroying

	RunService:BindToRenderStep(id, Enum.RenderPriority.First.Value, function(dt)
		if activeWiggles[label] ~= state then
			RunService:UnbindFromRenderStep(id)
			return
		end
		if not container.Parent then
			self:StopWiggle(label)
			return
		end
		t += dt * 6
		for i, charLabel in ipairs(chars) do
			local offset = math.sin(t + i * 0.3) * 3
			charLabel.Position = UDim2.new(0, charLabel.Position.X.Offset, 0.5, offset)
		end
	end)
	return true
end

function syde:StopWiggle(label)
	if typeof(label) ~= "Instance" or not label:IsA("TextLabel") then
		return false
	end
	local state = activeWiggles[label]
	if not state then
		return false
	end
	activeWiggles[label] = nil
	RunService:UnbindFromRenderStep(state.id)
	if state.disconnectDestroying then
		state.disconnectDestroying()
		state.disconnectDestroying = nil
	end
	if label.Parent then
		label.TextTransparency = state.originalTextTransparency
	end
	if state.container and state.container.Parent then
		state.container:Destroy()
	end
	return true
end

local activeLayouts = setmetatable({}, { __mode = "k" })
function syde:updateLayout(container, spacing)
	if resizing or activeLayouts[container] or not container.Parent then
		return
	end
	activeLayouts[container] = true
	spacing = spacing or 8
	local yOffset = 8

	for _, v in ipairs(container:GetChildren()) do
		if v:IsA("UIListLayout") then
			v:Destroy()
		end
	end

	for _, child in ipairs(container:GetChildren()) do
		if
			(child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("TextLabel") or child:IsA("TextButton"))
			and child.Visible
		then
			if child.Size.X.Offset ~= -16 or child.Size.X.Scale ~= 1 then
				child.Size = UDim2.new(1, -16, child.Size.Y.Scale, child.Size.Y.Offset)
			end
			child.Position = UDim2.fromOffset(8, yOffset)
			yOffset += child.AbsoluteSize.Y + spacing
		end
	end

	container.CanvasSize = UDim2.new(0, 0, 0, yOffset + 14)
	activeLayouts[container] = nil
end

local dragSpeed = 0.6
local LockToScreen = false

function syde:AddDrag(Object, Main, ConstrainToParent)
	assert(typeof(Object) == "Instance" and Object:IsA("GuiObject"), "[AddDrag] Object must be a GuiObject")
	assert(typeof(Main) == "Instance" and Main:IsA("GuiObject"), "[AddDrag] Main must be a GuiObject")

	local userInput = game:GetService("UserInputService")
	local tweenService = game:GetService("TweenService")

	local dragging, dragInput, startMousePos, startFramePos = false, nil, nil, nil

	local function getConstrainedPosition(newPos)
		if not LockToScreen then
			return newPos
		end

		local screenSize = workspace.CurrentCamera.ViewportSize
		local frameSize = Main.AbsoluteSize
		local anchorPoint = Main.AnchorPoint

		local absX = newPos.X.Offset
		local absY = newPos.Y.Offset

		local minX = 0 + (frameSize.X * anchorPoint.X)
		local maxX = screenSize.X - (frameSize.X * (1 - anchorPoint.X))

		local minY = 0 + (frameSize.Y * anchorPoint.Y)
		local maxY = screenSize.Y - (frameSize.Y * (1 - anchorPoint.Y))

		local clampedX = math.clamp(absX, minX, maxX)
		local clampedY = math.clamp(absY, minY, maxY)

		return UDim2.new(0, clampedX, 0, clampedY)
	end

	local function getInputPos(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			return Vector2.new(input.Position.X, input.Position.Y)
		else
			return userInput:GetMouseLocation()
		end
	end

	syde:AddConnection(Object.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			startMousePos = getInputPos(input)

			local screenSize = workspace.CurrentCamera.ViewportSize
			local absX = screenSize.X * Main.Position.X.Scale + Main.Position.X.Offset
			local absY = screenSize.Y * Main.Position.Y.Scale + Main.Position.Y.Offset

			Main.Position = UDim2.new(0, absX, 0, absY)
			startFramePos = Main.Position
		end
	end)

	syde:AddConnection(userInput.InputChanged, function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local currentMousePos = getInputPos(input)
			if currentMousePos and startMousePos then
				local delta = currentMousePos - startMousePos

				local newPos = UDim2.new(
					startFramePos.X.Scale,
					startFramePos.X.Offset + delta.X,
					startFramePos.Y.Scale,
					startFramePos.Y.Offset + delta.Y
				)

				Main:TweenPosition(
					getConstrainedPosition(newPos),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quint,
					dragSpeed,
					true
				)
			end
		end
	end)

	syde:AddConnection(userInput.InputEnded, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = false
		end
	end)
end

function syde:HidePlaceHolder(instance, placeholder, recursive)
	if typeof(instance) ~= "Instance" or type(placeholder) ~= "string" then
		warn("[removeplaceholder] Invalid input: Expected (Instance, string)")
		return
	end

	local target = instance:FindFirstChild(placeholder)

	if not target then
		warn(("[removeplaceholder] Placeholder '%s' not found in instance '%s'"):format(placeholder, instance.Name))
		return
	end

	if target:IsA("GuiObject") then
		target.Visible = false
	else
		warn(("[removeplaceholder] '%s' is not a GuiObject and cannot be hidden"):format(placeholder))
		return
	end

	if recursive then
		for _, child in ipairs(target:GetDescendants()) do
			if child:IsA("GuiObject") then
				child.Visible = false
			end
		end
	end
end

local rs
local ss
local mh = true

do
	function syde:Load(Config)
		task.wait(0.4)
		local LOADER = Loader
		LOADER.Enabled = true
		LOADER.Parent = coregui

		Config.Name = Config.Name or "Syde™"
		Config.Logo = Config.Logo or "rbxassetid://14554547135"
		Config.ConfigFolder = Config.ConfigFolder or "syde"
		Config.Status = Config.Status or false
		Config.Accent = Config.Accent or syde.theme.Accent
		Config.HitBox = Config.HitBox or syde.theme.HitBox

		LOADER.loader.profile.Title.TextTransparency = 1
		LOADER.loader.profile.ImageTransparency = 1
		LOADER.loader.profile.Title.Text = Config.Name

		local LoaderConfig = {
			Name = Config.Name,
			Logo = "rbxassetid://" .. Config.Logo,
			ConfigFolder = Config.ConfigFolder,
			Status = Config.Status,
			Accent = Config.Accent or syde.theme.Accent,
			Hitbox = Config.HitBox or syde.theme.HitBox,
			Socials = {},
		}

		if LoaderConfig.Status == false then
			LOADER.loader.profile.Title.Text = LoaderConfig.Name
		end

		local statusColors = {
			Stable = { Color = Color3.fromRGB(25, 229, 22), Text = '<font color="#24bf48">Stable</font>' },
			Unstable = { Color = Color3.fromRGB(227, 229, 81), Text = '<font color="#e3e551">Unstable</font>' },
			Detected = { Color = Color3.fromRGB(229, 44, 47), Text = '<font color="#e52c2f">Detected</font>' },
			Patched = { Color = Color3.fromRGB(229, 229, 229), Text = '<font color="#e52c2f">Patched</font>' },
		}

		local statusData = statusColors[LoaderConfig.Status]
		if statusData then
			LOADER.loader.profile.status.BackgroundColor3 = statusData.Color
		end

		LOADER.loader.profile.Image = LoaderConfig.Logo
		LOADER.loader.ImageLabel.Image = LoaderConfig.Logo

		local ti = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)

		task.spawn(function()
			while LOADER and LOADER.Parent do
				task.wait()

				local loaderFrame = LOADER:FindFirstChild("loader")
				if not loaderFrame then
					break
				end

				local dots = loaderFrame:FindFirstChild("dots")
				if not dots then
					break
				end

				local function resetDots()
					for _, v in ipairs(dots:GetChildren()) do
						if v:IsA("Frame") then
							tweenservice:Create(v, ti, { BackgroundTransparency = 0.6 }):Play()
						end
					end
				end

				if dots:FindFirstChild("dot1") then
					tweenservice:Create(dots.dot1, ti, { BackgroundTransparency = 0 }):Play()
				end
				task.wait(0.5)
				resetDots()

				if dots:FindFirstChild("dot3") then
					tweenservice:Create(dots.dot3, ti, { BackgroundTransparency = 0 }):Play()
				end
				task.wait(0.5)
				resetDots()

				if dots:FindFirstChild("dot2") then
					tweenservice:Create(dots.dot2, ti, { BackgroundTransparency = 0 }):Play()
				end
				task.wait(0.5)
				resetDots()
			end
		end)

		local TweenWorkPos = 315
		local TweenWorkAppear = 287
		local TweenWorkDisappear = 270

		local Styles = {
			GitHub = {
				BackGroundColor = Color3.fromRGB(39, 39, 39),

				StrokeColor = Color3.fromRGB(39, 39, 39),
				Icon = "rbxassetid://112129825794851",
			},
			Discord = {
				BackGroundColor = Color3.fromRGB(88, 141, 255),

				StrokeColor = Color3.fromRGB(88, 141, 255),
				Icon = "rbxassetid://113723018301753",
			},
			Site = {
				BackGroundColor = Color3.fromRGB(242, 83, 112),

				StrokeColor = Color3.fromRGB(242, 83, 112),
				Icon = "rbxassetid://127485237503891",
			},
		}

		local logo = LOADER.loader.profile

		local loadedsocial = false

		local Socials = Config.Socials or {}
		local maxSocials = 3
		local count = 0

		local SocialTemplate = LOADER.loader.profile.socials.s1

		for platform, value in pairs(Socials) do
			if count >= maxSocials then
				break
			end
			if not Styles[platform] then
				continue
			end
			if not SocialTemplate then
				break
			end

			count += 1

			local clone = SocialTemplate:Clone()
			clone.Visible = true
			clone.Name = platform .. "_Social"
			clone.Parent = SocialTemplate.Parent

			clone.BackgroundColor3 = Styles[platform].BackGroundColor
			clone.ImageLabel.Image = Styles[platform].Icon

			if clone.Frame:FindFirstChild("UIStroke") then
				clone.Frame.UIStroke.Color = Styles[platform].StrokeColor
			end

			if clone:FindFirstChild("Title") then
				clone.Title.Text = value
			end

			clone.interact.MouseButton1Click:Connect(function()
				if value ~= "" then
					tweenservice
						:Create(
							clone.Frame.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart),
							{ Color = Color3.fromRGB(74, 255, 33) }
						)
						:Play()
					tweenservice
						:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { Transparency = 0 })
						:Play()
					task.wait(0.5)
					tweenservice
						:Create(
							clone.Frame.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart),
							{ Color = Styles[platform].BackGroundColor }
						)
						:Play()
					tweenservice
						:Create(
							clone.Frame.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart),
							{ Transparency = 0.5 }
						)
						:Play()
				else
					tweenservice
						:Create(
							clone.Frame.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart),
							{ Color = Color3.fromRGB(255, 41, 45) }
						)
						:Play()
					tweenservice
						:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { Transparency = 0 })
						:Play()
					task.wait(0.5)
					tweenservice
						:Create(
							clone.Frame.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart),
							{ Color = Styles[platform].BackGroundColor }
						)
						:Play()
					tweenservice
						:Create(
							clone.Frame.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart),
							{ Transparency = 0.5 }
						)
						:Play()
				end

				setclipboard(value)
			end)

			clone.MouseEnter:Connect(function()
				tweenservice
					:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { Transparency = 0.5 })
					:Play()
			end)
			clone.MouseLeave:Connect(function()
				tweenservice
					:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { Transparency = 0 })
					:Play()
			end)

			loadedsocial = true
		end

		tweenservice:Create(logo, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()

		tweenservice:Create(logo.Title, TweenInfo.new(2, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
		task.wait(0.4)

		local function TweenWorkLabel(Finish, icon, Text)
			LOADER.loader.work.Position = UDim2.new(0.5, 0, 1, -40)
			LOADER.loader.work.Text = Text
			LOADER.loader.work.ImageLabel.Image = icon
			tweenservice
				:Create(LOADER.loader.work, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { TextTransparency = 0 })
				:Play()
			tweenservice
				:Create(
					LOADER.loader.work.ImageLabel,
					TweenInfo.new(0.2, Enum.EasingStyle.Quint),
					{ ImageTransparency = 0 }
				)
				:Play()
			tweenservice
				:Create(
					LOADER.loader.work,
					TweenInfo.new(0.2, Enum.EasingStyle.Quint),
					{ Position = UDim2.new(0.5, 0, 1, -73) }
				)
				:Play()
			task.wait(Finish or 0.15)
			tweenservice
				:Create(LOADER.loader.work, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { TextTransparency = 1 })
				:Play()
			tweenservice
				:Create(
					LOADER.loader.work.ImageLabel,
					TweenInfo.new(0.2, Enum.EasingStyle.Quint),
					{ ImageTransparency = 1 }
				)
				:Play()
			tweenservice
				:Create(
					LOADER.loader.work,
					TweenInfo.new(0.2, Enum.EasingStyle.Quint),
					{ Position = UDim2.new(0.5, 0, 1, -100) }
				)
				:Play()
			task.wait(0.1)
		end

		local function load()
			TweenWorkLabel(0.18, "rbxassetid://136002400178503", "")

			if Config.ConfigurationSaving and Config.ConfigurationSaving.Enabled then
				local folderName = Config.ConfigurationSaving.FolderName or "SydeSec"
				local fileName = Config.ConfigurationSaving.FileName or "default_config"

				syde.ConfigEnabled = true
				syde.ConfigFolder = folderName
				syde.ConfigFolderExplicit = true
				syde.ConfigFile = normalizeConfigName and normalizeConfigName(fileName) or fileName
				syde.ConfigFileExplicit = true

				if not ensureConfigFolder(folderName) then
					warn("[SYDE] Could not access configuration folder:", folderName)
				end

				local autoloadPath = string.format("%s/_autoload.txt", folderName)
				local autoload = false
				local autoloadProfile
				if isfile then
					local ok, content = pcall(readfile, autoloadPath)
					if ok and content then
						local savedProfile = tostring(content):match("^%s*(.-)%s*$")
						if savedProfile == "1" then
							autoload = true
						elseif savedProfile:sub(1, 2) == "2:" then
							autoloadProfile = normalizeConfigName(savedProfile:sub(3))
							syde.ConfigFile = autoloadProfile
							syde.ConfigFileExplicit = true
							autoload = true
						end
					end
				end

				if autoload then
					local legacyName = not autoloadProfile and tostring(game and game.GameId or "default") or nil
					local configPath, configExists = resolveConfigPath(folderName, syde.ConfigFile, legacyName)
					if configExists then
						local ok, content = pcall(readfile, configPath)
						if ok and content then
							local decodeOk, decoded = pcall(function()
								return https:JSONDecode(content)
							end)
							if decodeOk and type(decoded) == "table" then
								syde.LoadedConfig = decoded
							end
						end
					end
				end
			end

			TweenWorkLabel(0.18, "rbxassetid://105810189969774", "")

			local UI_TAG = "sydeUILoader"
			local MARKER_NAME = "SYDEUIDetector"
			local INTERNAL_UUID = ("SYDE-" .. tostring(game.JobId):gsub("-", "") .. tostring(tick())):gsub("%.", "")
			local PROTECTION_EVENT = Instance.new("BindableEvent")
			local HttpService = game:GetService("HttpService")

			local function deepCleanup()
				for _, v in ipairs(coregui:GetChildren()) do
					if v:IsA("ScreenGui") and v:FindFirstChild(MARKER_NAME) then
						pcall(function()
							v:Destroy()
						end)
					end
				end
			end
			deepCleanup()

			local successLibrary, Library = pcall(function()
				return Library
			end)

			if not successLibrary or not Library then
				syde:Report("Loading UI library", "Library/GetObjects returned nil - the UI asset failed to load")
				return
			end

			Library.Name = UI_TAG
			Library.ResetOnSpawn = false

			local marker = Instance.new("StringValue")
			marker.Name = MARKER_NAME
			marker.Value = INTERNAL_UUID
			marker.Parent = Library

			pcall(function()
				Library.Parent = coregui
			end)

			task.spawn(function()
				while Library and Library.Parent do
					task.wait(1)
					if Library.Parent ~= coregui then
						warn("Syde 〡 UI moved. Restoring...")
						pcall(function()
							Library.Parent = coregui
						end)
					end
				end
			end)

			TweenWorkLabel(0.18, "rbxassetid://108012241529487", "")

			if Config.AutoJoinDiscord and Config.AutoJoinDiscord.Enabled then
				local discordConfig = Config.AutoJoinDiscord
				local rootFolder = Config.ConfigurationSaving and Config.ConfigurationSaving.FolderName or "SydeSec"
				local discordFolder = rootFolder .. "/DiscordInvites"
				local inviteCode = discordConfig.Invite
				local inviteFilePath = discordFolder .. "/" .. inviteCode .. ".txt"

				if isfolder and not isfolder(discordFolder) then
					local folderSuccess, folderErr = pcall(function()
						makefolder(discordFolder)
					end)
					if folderSuccess then
					else
						warn("[SYDE] Failed to create DiscordInvites folder:", folderErr)
					end
				end

				local shouldPrompt = true
				if isfile and discordConfig.RememberJoins and isfile(inviteFilePath) then
					shouldPrompt = false
				end

				if shouldPrompt then
					if request then
						local reqSuccess, reqErr = pcall(function()
							request({
								Url = "http://127.0.0.1:6463/rpc?v=1",
								Method = "POST",
								Headers = {
									["Content-Type"] = "application/json",
									["Origin"] = "https://discord.com",
								},
								Body = https:JSONEncode({
									cmd = "INVITE_BROWSER",
									nonce = https:GenerateGUID(false),
									args = {
										code = inviteCode,
									},
								}),
							})
						end)

						if reqSuccess then
						else
							warn("[SYDE] Failed to send Discord invite:", reqErr)
						end
					else
						warn("[SYDE] Request function not available — cannot send Discord invite.")
					end

					if discordConfig.RememberJoins then
						local writeSuccess, writeErr = pcall(function()
							writefile(
								inviteFilePath,
								"Joined Discord via invite '" .. inviteCode .. "' at " .. os.date()
							)
						end)

						if writeSuccess then
						else
							warn("[SYDE] Failed to write join log for invite:", writeErr)
						end
					end
				end
			end

			TweenWorkLabel(0.18, "rbxassetid://136405833725573", "")
			task.wait(0.4)
			loaded = true
		end

		task.wait(0.08)
		load()

		task.wait(0.15)

		syde.theme.Accent = Config.Accent
		syde.theme.HitBox = Config.HitBox
		LOADER:Destroy()
	end
end

local HttpService = https
local THEME_FOLDER = "BlizTOrionTheme"
local FILE_PATH = THEME_FOLDER .. "/" .. tostring(game and game.GameId or "0") .. ".txt"

if makefolder and isfolder and not isfolder(THEME_FOLDER) then
	pcall(makefolder, THEME_FOLDER)
end

local LoadedThemeFile = false
local ThemeColorsToSave = {}

local function Round(Number, Factor)
	local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then
		Result = Result + Factor
	end
	return Result
end

local function PackColor(Color)
	if typeof(Color) ~= "Color3" then
		return nil
	end
	return { R = Color.R * 255, G = Color.G * 255, B = Color.B * 255 }
end

local function UnpackColor(Color)
	if not Color or not Color.R then
		return Color3.fromRGB(255, 255, 255)
	end
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

function syde:SaveThemeCfg()
	if not LoadedThemeFile then
		return
	end

	local Data = {}
	local themeData = (self.Themes and self.SelectedTheme and self.Themes[self.SelectedTheme]) or self.theme

	if themeData then
		for typeName, value in pairs(themeData) do
			if typeof(value) == "Color3" then
				ThemeColorsToSave[typeName] = PackColor(value)
			end
		end
	end

	if self.theme then
		if self.theme.Accent then
			ThemeColorsToSave["Accent"] = PackColor(self.theme.Accent)
		end
		if self.theme.HitBox then
			ThemeColorsToSave["HitBox"] = PackColor(self.theme.HitBox)
		end
	end
	if self.HeaderTitleColor then
		ThemeColorsToSave["HeaderTitleColor"] = PackColor(self.HeaderTitleColor)
	end
	if self.HeaderSubtitleColor then
		ThemeColorsToSave["HeaderSubtitleColor"] = PackColor(self.HeaderSubtitleColor)
	end

	ensureConfigFolder(THEME_FOLDER)
	if writefile then
		pcall(function()
			writefile(FILE_PATH, HttpService:JSONEncode(ThemeColorsToSave))
		end)
	end
end

local function LoadThemeCfg(Config)
	Config = Config or FILE_PATH
	if isfile and isfile(Config) then
		local ok, dataOrErr = pcall(function()
			return HttpService:JSONDecode(readfile(Config))
		end)

		if ok and type(dataOrErr) == "table" then
			local Data = dataOrErr
			syde.Themes = syde.Themes or {}
			syde.Themes.Custom = syde.Themes.Custom or {}

			for TypeName, Value in pairs(Data) do
				local c = UnpackColor(Value)
				if TypeName == "HeaderTitleColor" or TypeName == "HeaderSubtitleColor" then
					syde[TypeName] = c
				else
					syde.Themes.Custom[TypeName] = c
				end
				if TypeName == "Accent" or TypeName == "HitBox" then
					if syde.theme then
						syde.theme[TypeName] = c
					end
				end
			end

			syde.SelectedTheme = "Custom"
			LoadedThemeFile = true

			task.wait(0.02)
			syde:SetTheme()
		else
			LoadedThemeFile = true
		end
	else
		LoadedThemeFile = true
	end
end

function syde:SetTheme()
	local themeData = (self.Themes and self.SelectedTheme and self.Themes[self.SelectedTheme]) or self.theme
	if not themeData then
		return
	end

	local accent = themeData.Accent or themeData.Main or (self.theme and self.theme.Accent)
	local hitbox = themeData.HitBox or themeData.Accent or themeData.Main or (self.theme and self.theme.HitBox)

	if accent and self.theme then
		self.theme.Accent = accent
		self.Comms:Fire("Accent", accent)
	end
	if hitbox and self.theme then
		self.theme.HitBox = hitbox
		self.Comms:Fire("HitBox", hitbox)
	end

	self:SaveThemeCfg()
end

function syde:GenTheme(mainColor)
	local r, g, b = mainColor.R * 255, mainColor.G * 255, mainColor.B * 255
	local lum = 0.299 * r + 0.587 * g + 0.114 * b
	local dark = lum < 128
	local t = { Main = mainColor }

	if dark then
		t.Second =
			Color3.fromRGB(math.clamp(r * 1.12, 0, 255), math.clamp(g * 1.12, 0, 255), math.clamp(b * 1.12, 0, 255))
		t.Stroke =
			Color3.fromRGB(math.clamp(r * 1.45, 0, 255), math.clamp(g * 1.45, 0, 255), math.clamp(b * 1.45, 0, 255))
		t.Divider =
			Color3.fromRGB(math.clamp(r * 1.28, 0, 255), math.clamp(g * 1.28, 0, 255), math.clamp(b * 1.28, 0, 255))
		t.Text = Color3.fromRGB(240, 240, 242)
		t.TextDark = Color3.fromRGB(155, 155, 160)
		t.Accent =
			Color3.fromRGB(math.clamp(r * 1.85, 0, 255), math.clamp(g * 1.85, 0, 255), math.clamp(b * 1.85, 0, 255))
		t.HitBox = t.Accent
	else
		t.Second =
			Color3.fromRGB(math.clamp(r * 0.94, 0, 255), math.clamp(g * 0.94, 0, 255), math.clamp(b * 0.94, 0, 255))
		t.Stroke =
			Color3.fromRGB(math.clamp(r * 0.75, 0, 255), math.clamp(g * 0.75, 0, 255), math.clamp(b * 0.75, 0, 255))
		t.Divider =
			Color3.fromRGB(math.clamp(r * 0.85, 0, 255), math.clamp(g * 0.85, 0, 255), math.clamp(b * 0.85, 0, 255))
		t.Text = Color3.fromRGB(35, 35, 38)
		t.TextDark = Color3.fromRGB(110, 110, 115)
		t.Accent =
			Color3.fromRGB(math.clamp(r * 0.72, 0, 255), math.clamp(g * 0.72, 0, 255), math.clamp(b * 0.72, 0, 255))
		t.HitBox = t.Accent
	end

	return t
end

normalizeConfigName = function(name)
	name = tostring(name or "default")
	name = name:gsub("[^%w_%-]", "_"):gsub("_+", "_"):sub(1, 64)
	return name ~= "" and name or "default"
end

ensureConfigFolder = function(folder)
	if type(folder) ~= "string" or folder == "" then
		return false
	end
	if isfolder then
		local checkOk, exists = pcall(isfolder, folder)
		if checkOk and exists == true then
			return true
		end
	end
	if not makefolder then
		return false
	end
	local makeOk = pcall(makefolder, folder)
	if isfolder then
		local checkOk, exists = pcall(isfolder, folder)
		if checkOk then
			return exists == true
		end
	end
	return makeOk
end

resolveConfigPath = function(folder, name, fallbackName)
	local primaryPath = string.format("%s/%s.txt", folder, normalizeConfigName(name))
	local function fileExists(path)
		if not isfile then
			return false
		end
		local checkOk, exists = pcall(isfile, path)
		return checkOk and exists == true
	end
	if fileExists(primaryPath) then
		return primaryPath, true
	end
	if fallbackName and tostring(fallbackName) ~= normalizeConfigName(name) then
		local fallbackPath = string.format("%s/%s.txt", folder, normalizeConfigName(fallbackName))
		if fileExists(fallbackPath) then
			return fallbackPath, true
		end
	end
	return primaryPath, false
end

local function SaveCfg(Name, preserveName)
	if syde.IsLoadingConfig then
		return false
	end
	local gameId = tostring(game and game.GameId or "default")
	if not preserveName and (Name == nil or tostring(Name) == gameId) then
		Name = syde.ConfigFile or gameId
	end
	Name = normalizeConfigName(Name or gameId)
	local folder = syde.Folder or syde.ConfigFolder or "FireHub"
	if type(folder) ~= "string" or folder == "" then
		folder = "FireHub"
	end
	ensureConfigFolder(folder)

	local Data = {}

	for key, value in pairs(syde.LoadedConfig or {}) do
		if type(key) == "string" and key:sub(-8) == "_Keybind" then
			Data[key] = value
		end
	end
	for i, v in pairs(syde.Flags) do
		if v and v.Save ~= false then
			if v.Type == "MultiColorpicker" then
				if v.Pickers and #v.Pickers > 0 then
					local colorList = {}
					local rainbowList = {}
					local hasRainbow = false
					for index, picker in ipairs(v.Pickers) do
						colorList[index] = PackColor(picker.Value)
						rainbowList[index] = picker.Control and picker.Control.Rainbow == true or false
						hasRainbow = hasRainbow or rainbowList[index]
					end
					Data[i] = colorList
					if hasRainbow then
						Data[i .. "_Rainbow"] = rainbowList
					end
				end
			elseif v.Type == "Colorpicker" or v.Type == "ColorPicker" then
				if v.SetRainbow then
					Data[i .. "_Rainbow"] = v.Rainbow == true
				end
				if v.Pickers and v.Pickers[1] then
					Data[i] = PackColor(v.Pickers[1].Value)
				elseif v.Value and typeof(v.Value) == "Color3" then
					Data[i] = PackColor(v.Value)
				elseif v.Color and typeof(v.Color) == "Color3" then
					Data[i] = PackColor(v.Color)
				end
			elseif v.Type == "Bind" or v.Type == "Keybind" then
				if typeof(v.Value) == "EnumItem" then
					Data[i] = v.Value.Name
				elseif typeof(v.Key) == "EnumItem" then
					Data[i] = v.Key.Name
				elseif typeof(v.Value) == "string" and v.Value ~= "" and v.Value ~= "NONE" then
					Data[i] = v.Value
				elseif typeof(v.Key) == "string" and v.Key ~= "" and v.Key ~= "NONE" then
					Data[i] = v.Key
				end
			elseif v.Type == "Pbind" or (v.ValueX ~= nil and v.ValueY ~= nil and v.ValueZ ~= nil) then
				Data[i] = { _type = "Pbind", X = tostring(v.ValueX), Y = tostring(v.ValueY), Z = tostring(v.ValueZ) }
			else
				if v.Value ~= nil then
					if typeof(v.Value) == "EnumItem" then
						Data[i] = v.Value.Name
					else
						Data[i] = v.Value
					end
				elseif v.V ~= nil then
					Data[i] = v.V
				elseif v.StarterValue ~= nil then
					Data[i] = v.StarterValue
				elseif v._textBox and v._textBox.Text then
					Data[i] = v._textBox.Text
				end
				if v.Type == "Toggle" and v.Config then
					Data[i .. "_Keybind"] = encodeToggleKeybind(v.Keybind)
				end
			end
		end
	end

	if not writefile then
		return false
	end
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, Data)
	if not ok then
		return false
	end
	local writeOk, writeResult = pcall(writefile, folder .. "/" .. Name .. ".txt", encoded)
	if not writeOk or writeResult == false then
		return false
	end
	syde.LoadedConfig = Data
	return true
end

local function LoadCfg(Config)
	if syde._destroyed then
		return false
	end
	local ok, Data = pcall(function()
		return HttpService:JSONDecode(Config)
	end)
	if not ok or type(Data) ~= "table" then
		return false
	end
	if saveDebounce then
		pcall(task.cancel, saveDebounce)
		saveDebounce = nil
	end
	pendingSaveName = nil
	for _, thread in ipairs(configLoadTasks) do
		pcall(task.cancel, thread)
	end
	table.clear(configLoadTasks)
	configLoadGeneration += 1
	local loadGeneration = configLoadGeneration
	syde.IsLoadingConfig = true

	syde.LoadedConfig = Data

	local flagsProcessed = 0
	local totalFlags = 0
	for _, _ in pairs(Data) do
		totalFlags += 1
	end
	if totalFlags == 0 then
		pcall(function()
			syde:SetTheme()
		end)
		syde.IsLoadingConfig = false
		return true
	end

	local finalizeScheduled = false
	local function finishLoadEntry()
		flagsProcessed += 1
		if flagsProcessed < totalFlags or finalizeScheduled then
			return
		end
		finalizeScheduled = true
		task.delay(0.05, function()
			if configLoadGeneration ~= loadGeneration then
				return
			end
			pcall(function()
				syde:SetTheme()
			end)
			syde.IsLoadingConfig = false
			table.clear(configLoadTasks)
		end)
	end

	for a, b in pairs(Data) do
		if syde.Flags[a] then
			local thread = task.spawn(function()
				if configLoadGeneration ~= loadGeneration then
					return
				end
				local flag = syde.Flags[a]
				if flag then
					pcall(function()
						if flag.Type == "MultiColorpicker" then
							if type(b) == "table" and b.R == nil then
								for index, colorData in ipairs(b) do
									flag:Set(index, UnpackColor(colorData))
								end
							else
								flag:Set(1, UnpackColor(b))
							end
						elseif flag.Type == "Colorpicker" or flag.Type == "ColorPicker" then
							flag:Set(UnpackColor(b))
						elseif flag.Type == "Bind" or flag.Type == "Keybind" then
							local success, keyEnum = pcall(function()
								return Enum.KeyCode[b] or Enum.UserInputType[b]
							end)
							if success and keyEnum then
								flag:Set(keyEnum)
							else
								flag:Set(b)
							end
						elseif flag.Type == "Pbind" or (type(b) == "table" and b._type == "Pbind") then
							if flag.Set then
								flag:Set(b.X, b.Y, b.Z)
							end
						else
							flag:Set(b)
						end
					end)
				end
				if configLoadGeneration == loadGeneration then
					finishLoadEntry()
				end
			end)
			table.insert(configLoadTasks, thread)
		elseif type(a) == "string" and a:sub(-8) == "_Rainbow" then
			pcall(function()
				local picker = syde.Flags[a:sub(1, -9)]
				if picker and picker.SetRainbow then
					if picker.Type == "MultiColorpicker" and type(b) == "table" then
						for index, enabled in ipairs(b) do
							picker:SetRainbow(index, enabled == true, true)
						end
					else
						picker:SetRainbow(b == true, true)
					end
				end
			end)
			finishLoadEntry()
		elseif type(a) == "string" and a:sub(-8) == "_Keybind" then
			pcall(function()
				local toggle = syde.Flags[a:sub(1, -9)]
				if toggle and toggle.Type == "Toggle" and toggle.SetKeybind and type(b) == "string" then
					local key = decodeToggleKeybind(b)
					if key then
						toggle:SetKeybind(key, true)
					end
				end
			end)
			finishLoadEntry()
		else
			finishLoadEntry()
		end
	end
	return true
end

function SaveConfig(Name)
	if syde._destroyed or syde.IsLoadingConfig then
		return false
	end
	if saveDebounce then
		task.cancel(saveDebounce)
	end
	pendingSaveName = Name or syde.ConfigFile or (game and game.GameId) or "default"
	local saveName = pendingSaveName
	saveDebounce = task.delay(0.05, function()
		saveDebounce = nil
		pendingSaveName = nil
		SaveCfg(saveName)
	end)
end

function syde:FlushConfig()
	if syde.IsLoadingConfig then
		return false
	end
	if saveDebounce then
		task.cancel(saveDebounce)
		saveDebounce = nil
	end
	local saveName = pendingSaveName or syde.ConfigFile or (game and game.GameId) or "default"
	pendingSaveName = nil
	return SaveCfg(saveName)
end

function LoadConfig(Configuration)
	return LoadCfg(Configuration) == true
end

function syde:AutoSave()
	return SaveCfg()
end

function syde:LoadSaveConfig(targetFile)
	local folder = syde.Folder or syde.ConfigFolder or "FireHub"
	local fileName = normalizeConfigName(targetFile or syde.ConfigFile or (game and game.GameId) or "default")
	local legacyName = targetFile == nil and tostring(game and game.GameId or "default") or nil
	local filePath, fileExists = resolveConfigPath(folder, fileName, legacyName)

	if not fileExists then
		if syde.Toast then
			syde:Toast({ Content = "No save file found at " .. filePath, Duration = 3 })
		end
		return false
	end

	local ok, content = pcall(readfile, filePath)
	if ok and content then
		local loaded = LoadCfg(content)
		if loaded then
			syde.ConfigFile = fileName
			syde.ConfigFileExplicit = true
			if syde:GetAutoLoad() then
				syde:SetAutoLoad(true)
			end
		end
		if loaded and syde.Toast then
			syde:Toast({ Content = "Loaded config " .. fileName, Duration = 3 })
		end
		return loaded == true
	end
	return false
end

function syde:ListConfigs()
	local list = {}
	local folder = syde.Folder or syde.ConfigFolder or "FireHub"
	if not listfiles or not isfolder then
		return list
	end
	local folderOk, folderExists = pcall(isfolder, folder)
	if not folderOk or not folderExists then
		return list
	end

	local ok, files = pcall(listfiles, folder)
	if not ok or type(files) ~= "table" then
		return list
	end

	for _, full in ipairs(files) do
		local name = tostring(full):match("([^/\\]+)%.txt$")
		if name and name ~= "SettingsConfig" and name ~= "_autoload" then
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

function syde:SaveConfigAs(name)
	if type(name) ~= "string" or name == "" then
		return false
	end
	local saved = SaveCfg(name, true)
	if not saved then
		return false
	end
	syde.ConfigFile = normalizeConfigName(name)
	syde.ConfigFileExplicit = true
	if syde:GetAutoLoad() then
		syde:SetAutoLoad(true)
	end
	if syde.Toast then
		syde:Toast({ Content = "Saved config as " .. normalizeConfigName(name), Duration = 3 })
	end
	return true
end

function syde:DeleteConfig(name)
	if type(name) ~= "string" or name == "" then
		return false
	end
	local folder = syde.Folder or syde.ConfigFolder or "FireHub"
	local filePath = string.format("%s/%s.txt", folder, normalizeConfigName(name))
	if isfile and isfile(filePath) and delfile then
		return pcall(delfile, filePath)
	end
	return false
end

function syde:GetAutoLoad()
	local folder = syde.Folder or syde.ConfigFolder or "FireHub"
	local autoloadPath = string.format("%s/_autoload.txt", folder)
	if not isfile then
		return false
	end
	local existsOk, exists = pcall(isfile, autoloadPath)
	if existsOk and exists then
		local ok, content = pcall(readfile, autoloadPath)
		if ok and content then
			local savedProfile = tostring(content):match("^%s*(.-)%s*$")
			return savedProfile == "1" or savedProfile:match("^2:.+") ~= nil
		end
	end
	return false
end

function syde:SetAutoLoad(enabled)
	local folder = syde.Folder or syde.ConfigFolder or "FireHub"
	local autoloadPath = string.format("%s/_autoload.txt", folder)
	if not ensureConfigFolder(folder) or not writefile then
		return false
	end
	local value = enabled and ("2:" .. normalizeConfigName(syde.ConfigFile)) or "0"
	local writeOk, writeResult = pcall(writefile, autoloadPath, value)
	return writeOk and writeResult ~= false
end

syde.PackColor = PackColor
syde.UnpackColor = UnpackColor
syde.SaveCfg = SaveCfg
syde.LoadCfg = LoadCfg
syde.SaveThemeCfg = syde.SaveThemeCfg
syde.LoadThemeCfg = LoadThemeCfg

local ui = Library
local window = ui.main
local top = window.top
local tabs = window.tabs.tab
local pages = window.pages

local Connected = false
local settingsOpen = false
local pluginsOpen = false
local uiclosed = false
function syde:IsWindowOpen()
	return not uiclosed
end
local userinfodisabled = false
local intro = false
local bluron = false
local glow = false

local uitoggle = Enum.KeyCode.RightShift
local sydeBlurEffect
local sydeBlurLayer
local function updateBlurVisibility()
	local visible = bluron and not uiclosed
	if sydeBlurEffect then
		sydeBlurEffect.Enabled = visible
	end
	if sydeBlurLayer then
		sydeBlurLayer.Enabled = visible
	end
end
local function setBackgroundBlur(enabled)
	bluron = enabled == true
	if not bluron then
		if sydeBlurEffect then
			sydeBlurEffect:Destroy()
		end
		sydeBlurEffect = nil
		if sydeBlurLayer then
			sydeBlurLayer:Destroy()
		end
		sydeBlurLayer = nil
		return
	end
	if not sydeBlurEffect then
		sydeBlurEffect = Instance.new("BlurEffect")
		sydeBlurEffect.Name = "SydeBackgroundBlur"
		sydeBlurEffect.Size = 7
		sydeBlurEffect.Parent = game:GetService("Lighting")
	end
	if not sydeBlurLayer then
		local oldLayer = coregui:FindFirstChild("SydeBlurLayer")
		if oldLayer then
			oldLayer:Destroy()
		end
		if ui.DisplayOrder < 1000 then
			ui.DisplayOrder = 1000
		end
		sydeBlurLayer = Instance.new("ScreenGui")
		sydeBlurLayer.Name = "SydeBlurLayer"
		sydeBlurLayer.DisplayOrder = ui.DisplayOrder - 1
		sydeBlurLayer.IgnoreGuiInset = true
		sydeBlurLayer.ResetOnSpawn = false
		local shade = Instance.new("Frame")
		shade.Name = "Shade"
		shade.Size = UDim2.fromScale(1, 1)
		shade.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
		shade.BackgroundTransparency = 0.82
		shade.BorderSizePixel = 0
		shade.Active = false
		shade.Parent = sydeBlurLayer
		sydeBlurLayer.Parent = coregui
	end
	updateBlurVisibility()
end

local function setWindowGlow(enabled)
	glow = enabled == true
	local visible = (glow or syde.RainbowMode == true) and not uiclosed
	for _, effect in ipairs(window.clipframe:GetChildren()) do
		if effect:IsA("ImageLabel") then
			effect.Visible = visible
			effect.ImageTransparency = visible and 0.93 or 1
		end
	end
	window.shadow.glow.Visible = visible
	window.shadow.glow1.Visible = visible
	window.shadow.glow.ImageTransparency = visible and 0.94 or 1
	window.shadow.glow1.ImageTransparency = visible and 0.94 or 1
end

local rainbowConnection
local rainbowDescendantConnection
local rainbowStrokes = {}
local rainbowSettingControl
local rainbowIconSync
local rainbowOutline
local rainbowOutlineGradient
local rainbowShadowGradient = window.shadow.ImageLabel:FindFirstChildOfClass("UIGradient")
local rainbowShadowOriginal = rainbowShadowGradient and rainbowShadowGradient.Color
local rainbowBaseAccent
local rainbowBaseHitBox
local rainbowBaseTitle

function syde:SetRainbowMode(enabled)
	enabled = enabled == true
	if self.RainbowMode == enabled then
		return
	end
	self.RainbowMode = enabled
	if rainbowConnection then
		rainbowConnection:Disconnect()
		rainbowConnection = nil
	end
	if rainbowDescendantConnection then
		rainbowDescendantConnection:Disconnect()
		rainbowDescendantConnection = nil
	end
	if enabled then
		rainbowBaseAccent = self.theme.Accent
		rainbowBaseHitBox = self.theme.HitBox
		rainbowBaseTitle = top.title.TextColor3
		if not rainbowOutline then
			rainbowOutline = Instance.new("UIStroke")
			rainbowOutline.Name = "RainbowOutline"
			rainbowOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			rainbowOutline.Thickness = 1.5
			rainbowOutline.Transparency = 0.15
			rainbowOutline.Parent = window
			rainbowOutlineGradient = Instance.new("UIGradient")
			rainbowOutlineGradient.Parent = rainbowOutline
		end
		rainbowOutline.Enabled = true
		local function trackStroke(descendant)
			if descendant:IsA("UIStroke") and descendant ~= rainbowOutline and rainbowStrokes[descendant] == nil then
				rainbowStrokes[descendant] = descendant.Color
			end
		end
		for _, descendant in ipairs(ui:GetDescendants()) do
			trackStroke(descendant)
		end
		rainbowDescendantConnection = ui.DescendantAdded:Connect(trackStroke)
		local elapsed = 0
		local themeElapsed = 0
		rainbowConnection = runservice.Heartbeat:Connect(function(deltaTime)
			if self._destroyed or not window.Parent then
				rainbowConnection:Disconnect()
				rainbowConnection = nil
				return
			end
			if uiclosed then
				return
			end
			elapsed += deltaTime
			themeElapsed += deltaTime
			if elapsed < 0.08 then
				return
			end
			elapsed = 0
			local hue = (os.clock() * 0.12) % 1
			local color = Color3.fromHSV(hue, 0.78, 1)
			self.theme.Accent = color
			self.theme.HitBox = color
			if themeElapsed >= 0.2 then
				themeElapsed = 0
				self.Comms:Fire("Accent", color)
				self.Comms:Fire("HitBox", color)
			end
			top.title.TextColor3 = color
			for stroke in pairs(rainbowStrokes) do
				if stroke.Parent then
					stroke.Color = color
				else
					rainbowStrokes[stroke] = nil
				end
			end
			local colors = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 0.8, 1)),
				ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue + 0.33) % 1, 0.8, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.66) % 1, 0.8, 1)),
			})
			rainbowOutlineGradient.Color = colors
			if rainbowShadowGradient then
				rainbowShadowGradient.Color = colors
			end
		end)
	else
		if rainbowOutline then
			rainbowOutline.Enabled = false
		end
		for stroke, originalColor in pairs(rainbowStrokes) do
			if stroke.Parent then
				stroke.Color = originalColor
			end
			rainbowStrokes[stroke] = nil
		end
		if rainbowShadowGradient and rainbowShadowOriginal then
			rainbowShadowGradient.Color = rainbowShadowOriginal
		end
		self:UpdateTheme({
			Accent = rainbowBaseAccent or self.theme.Accent,
			HitBox = rainbowBaseHitBox or self.theme.HitBox,
		})
		top.title.TextColor3 = rainbowBaseTitle or self.theme.Text
	end
	setWindowGlow(glow)
	if rainbowIconSync then
		rainbowIconSync()
	end
	if rainbowSettingControl and rainbowSettingControl.Value ~= enabled then
		rainbowSettingControl:Set(enabled, true)
	end
end

local performanceOverlay = {
	enabled = false,
	connection = nil,
	frame = nil,
	label = nil,
	align = nil,
	frameCount = 0,
	elapsed = 0,
}

local function getNetworkPingMs()
	local localPlayer = player.LocalPlayer
	if not localPlayer then
		return nil
	end
	local ok, seconds = pcall(function()
		return localPlayer:GetNetworkPing()
	end)
	if not ok or type(seconds) ~= "number" or seconds < 0 then
		return nil
	end
	return math.floor(seconds * 1000 + 0.5)
end

local function createPerformanceOverlay()
	if performanceOverlay.frame and performanceOverlay.frame.Parent then
		return
	end
	local header = window and window:FindFirstChild("top")
	local controls = header and header:FindFirstChild("functions")
	if not header or not controls then
		return
	end

	local frame = Instance.new("Frame")
	frame.Name = "PerformanceStatus"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromOffset(100, 20)
	frame.Visible = false
	frame.ZIndex = header.ZIndex + 1
	frame.Active = false
	frame.Parent = header

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.Size = UDim2.fromScale(1, 1)
	label.Text = "-- FPS  ·  -- ms"
	label.TextColor3 = Color3.fromRGB(170, 170, 178)
	label.TextSize = 9
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.ZIndex = frame.ZIndex
	label.Active = false
	label.Parent = frame

	local function align()
		if not frame.Parent or not controls.Parent then
			return
		end
		local searchButton = controls:FindFirstChild("search")
		local firstControl = searchButton or controls
		local controlsLeft = firstControl.AbsolutePosition.X - header.AbsolutePosition.X
		local title = header:FindFirstChild("title")
		local titleRight = title and (title.AbsolutePosition.X - header.AbsolutePosition.X + title.AbsoluteSize.X)
			or 110
		local subtitle = title and title:FindFirstChild("sub")
		if subtitle then
			titleRight =
				math.max(titleRight, subtitle.AbsolutePosition.X - header.AbsolutePosition.X + subtitle.AbsoluteSize.X)
		end
		local width = math.min(100, controlsLeft - titleRight - 16)
		frame.Visible = performanceOverlay.enabled and not uiclosed and width >= 84
		frame.Position = UDim2.fromOffset(controlsLeft - width - 8, math.max(0, (header.AbsoluteSize.Y - 20) / 2))
		frame.Size = UDim2.fromOffset(math.max(0, width), 20)
	end

	syde:AddConnection(header:GetPropertyChangedSignal("AbsoluteSize"), align)
	syde:AddConnection(controls:GetPropertyChangedSignal("AbsolutePosition"), align)
	local searchButton = controls:FindFirstChild("search")
	if searchButton then
		syde:AddConnection(searchButton:GetPropertyChangedSignal("AbsolutePosition"), align)
	end
	local title = header:FindFirstChild("title")
	if title then
		syde:AddConnection(title:GetPropertyChangedSignal("AbsoluteSize"), align)
	end
	performanceOverlay.frame = frame
	performanceOverlay.label = label
	performanceOverlay.align = align
	task.defer(align)
end

function syde:SetPerformanceOverlay(enabled)
	if enabled == nil then
		enabled = true
	end
	performanceOverlay.enabled = enabled == true
	createPerformanceOverlay()
	if not performanceOverlay.frame then
		return false
	end
	performanceOverlay.align()
	if performanceOverlay.connection then
		performanceOverlay.connection:Disconnect()
		performanceOverlay.connection = nil
	end
	if not performanceOverlay.enabled then
		return true
	end

	performanceOverlay.frameCount = 0
	performanceOverlay.elapsed = 0
	performanceOverlay.connection = runservice.RenderStepped:Connect(function(deltaTime)
		performanceOverlay.frameCount += 1
		performanceOverlay.elapsed += deltaTime
		if performanceOverlay.elapsed < 0.25 then
			return
		end

		local fps = math.floor(performanceOverlay.frameCount / performanceOverlay.elapsed + 0.5)
		syde._currentFPS = fps
		local miniInfo = ui.minihome and ui.minihome:FindFirstChild("info")
		if miniInfo and miniInfo:FindFirstChild("fps") then
			miniInfo.fps.Text = fps .. " FPS"
		end
		local ping = getNetworkPingMs()
		if performanceOverlay.label and performanceOverlay.label.Parent then
			performanceOverlay.label.Text = string.format("%d FPS  ·  %s ms", fps, ping and tostring(ping) or "--")
		end
		performanceOverlay.frameCount = 0
		performanceOverlay.elapsed = 0
	end)
	return true
end

function syde:SetCornerImage(assetId)
	local id = tostring(assetId or ""):match("^%s*(.-)%s*$")
	id = id:gsub("^rbxassetid://", "")
	if id ~= "" and not id:match("^%d+$") then
		return false
	end
	local image = window:FindFirstChild("CornerDecal")
	if not image then
		image = Instance.new("ImageLabel")
		image.Name = "CornerDecal"
		image.BackgroundTransparency = 1
		image.BorderSizePixel = 0
		image.AnchorPoint = Vector2.new(1, 1)
		image.Position = UDim2.new(1, -34, 1, -8)
		image.Size = UDim2.fromOffset(22, 22)
		image.ScaleType = Enum.ScaleType.Fit
		image.ZIndex = window.resize.ZIndex + 1
		image.Parent = window
	end
	image.Image = id ~= "" and ("rbxassetid://" .. id) or ""
	image.Visible = id ~= ""
	self.CornerImageId = id
	if self.Flags.CornerImageId then
		self.Flags.CornerImageId.Value = id
	end
	return true
end

function syde:SetWatermarkEnabled(enabled)
	self.WatermarkEnabled = enabled == true
	local watermark = ui and ui:FindFirstChild("minihome")
	if watermark then
		watermark.Visible = self.WatermarkEnabled
	end
	return watermark ~= nil
end

function applyLayout(isMobile)
	local viewportCamera = layoutCamera
	if not viewportCamera then
		return
	end
	local viewport = viewportCamera.ViewportSize
	local width = math.min(isMobile and 543 or 715, math.max(1, viewport.X - 24))
	local height = math.min(isMobile and 321 or 575, math.max(1, viewport.Y - 24))
	tweenservice
		:Create(Library.main, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.fromOffset(width, height) })
		:Play()
	local shadow = window:FindFirstChild("Shadow")
	if shadow then
		shadow.Visible = not isMobile
	end
end

local function updateLayout()
	if uiclosed then
		return
	end
	if not layoutCamera then
		return
	end
	screenSize = layoutCamera.ViewportSize
	isMobile = userinput.TouchEnabled or (screenSize.X < 1024 and screenSize.Y < 768)
	applyLayout(isMobile)
end

local notifications = {}
local notificationSpacing = 10

local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

function updatePositions()
	local screenHeight = workspace.CurrentCamera.ViewportSize.Y - 200
	local currentY = screenHeight

	for i = #notifications, 1, -1 do
		local notif = notifications[i]
		local targetPosition = UDim2.new(0, 250, 0, currentY - notif.Size.Y.Offset + 60)
		tweenservice:Create(notif, tweenInfo, { Position = targetPosition }):Play()
		currentY = currentY - (notif.Size.Y.Offset + notificationSpacing)
	end
end

for _, temp in ipairs(Library.Notification:GetChildren()) do
	if temp:IsA("Frame") then
		temp.Visible = false
	end
end

function syde:Notify(Notification)
	if syde.SuppressNotify then
		return
	end
	task.spawn(function()
		local NotifData = {
			Title = Notification.Title,
			Content = Notification.Content,
			Duration = Notification.Duration or 5,
			Icon = Notification.Icon or "",
			Varient = Notification.Varient or "Default",
			Animation = Notification.Animation,
			ConfirmCallback = Notification.ConfirmCallback,
		}

		local Notification = Library.Notification.Default:Clone()
		Notification.Visible = true
		Notification.Parent = Library.Notification
		Notification.Title.Text = NotifData.Title
		Notification.Content.Text = NotifData.Content
		Notification.Content.Size = UDim2.new(0, 200, 0, Notification.Content.TextBounds.Y)
		Notification.icon.Image = "rbxassetid://" .. NotifData.Icon
		Notification.icon.Visible = true

		local function CloseNotif()
			if Notification and Notification.Parent then
				table.remove(notifications, table.find(notifications, Notification))
				tweenservice
					:Create(Notification.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Scale = 0.9 })
					:Play()
				tweenservice
					:Create(
						Notification.close,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.95 }
					)
					:Play()
				tweenservice
					:Create(
						Notification,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.75 }
					)
					:Play()

				tweenservice
					:Create(
						Notification.Content,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0.78 }
					)
					:Play()

				task.wait(0.15)

				tweenservice
					:Create(Notification, TweenInfo.new(0.95, Enum.EasingStyle.Exponential), {
						Position = UDim2.new(
							0,
							Notification.Position.X.Offset + 400,
							0,
							Notification.Position.Y.Offset
						),
					})
					:Play()
				task.wait(0.4)
				Notification:Destroy()
				updatePositions()
			end
		end

		if NotifData.Animation == "Wiggle" then
			syde:WiggleText(Notification.Title)
		end

		if NotifData.Varient == "Options" then
			Notification.Block.Visible = true
			Notification.Size = UDim2.new(1, 0, 0, Notification.Content.TextBounds.Y + 80)
			Notification.Block.Cancel.MouseButton1Click:Connect(function()
				CloseNotif()
			end)
			Notification.Block.Confirm.MouseButton1Click:Connect(function()
				if NotifData.ConfirmCallback then
					NotifData.ConfirmCallback()
					CloseNotif()
				end
			end)
		else
			Notification.Size = UDim2.new(1, 0, 0, Notification.Content.TextBounds.Y + 45)
		end

		table.insert(notifications, Notification)
		updatePositions()

		Notification.close.ImageTransparency = 0.95
		Notification.BackgroundTransparency = 0.75

		Notification.Content.TextTransparency = 0.78

		Notification.Position = UDim2.new(0, 600, 0, 637)

		task.wait(0.45)

		if NotifData.Icon ~= "" then
			tweenservice
				:Create(
					Notification.Title,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint),
					{ Position = UDim2.new(0, 40, 0, 10) }
				)
				:Play()
			task.wait(0.035)
			tweenservice
				:Create(
					Notification.Content,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint),
					{ Position = UDim2.new(0, 40, 0, 30) }
				)
				:Play()

			tweenservice
				:Create(Notification.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0 })
				:Play()
		end

		tweenservice
			:Create(Notification.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Scale = 1 })
			:Play()
		tweenservice
			:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0.75 })
			:Play()
		tweenservice
			:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
			:Play()

		tweenservice
			:Create(Notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
			:Play()

		Notification.close.MouseEnter:Connect(function()
			tweenservice
				:Create(
					Notification.close,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
					{ ImageTransparency = 0.25 }
				)
				:Play()
		end)

		Notification.close.MouseLeave:Connect(function()
			tweenservice
				:Create(
					Notification.close,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
					{ ImageTransparency = 0.75 }
				)
				:Play()
		end)

		Notification.close.MouseButton1Click:Connect(function()
			CloseNotif()
		end)

		task.delay(NotifData.Duration, function()
			CloseNotif()
		end)
	end)
end

local activeModals = 0

function syde:Modal(Modal)
	Modal = Modal or {}
	task.spawn(function()
		local ModalData = {
			Title = Modal.Title or Modal.Name or "Confirm",
			Content = Modal.Content or Modal.Text or "Are you sure?",
			ConfirmCallBack = Modal.ConfirmCallBack or Modal.ConfimCallBack or Modal.Callback or Modal.CallBack,
		}

		local modalTemplate = (ui and ui.main and (ui.main:FindFirstChild("modal") or ui.main:FindFirstChild("Modal")))

		local ModalInstance
		if modalTemplate then
			ModalInstance = modalTemplate:Clone()
		else
			ModalInstance = Instance.new("Frame")
			ModalInstance.Name = "Modal"
			ModalInstance.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = ModalInstance
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(60, 60, 60)
			stroke.Parent = ModalInstance

			local t = Instance.new("TextLabel")
			t.Name = "Title"
			t.BackgroundTransparency = 1
			t.Size = UDim2.new(1, -20, 0, 30)
			t.Position = UDim2.new(0, 10, 0, 10)
			t.Font = Enum.Font.GothamBold
			t.TextColor3 = Color3.fromRGB(255, 255, 255)
			t.TextSize = 15
			t.TextXAlignment = Enum.TextXAlignment.Left
			t.Parent = ModalInstance

			local c = Instance.new("TextLabel")
			c.Name = "Content"
			c.BackgroundTransparency = 1
			c.Size = UDim2.new(1, -20, 0, 50)
			c.Position = UDim2.new(0, 10, 0, 42)
			c.Font = Enum.Font.Gotham
			c.TextColor3 = Color3.fromRGB(200, 200, 200)
			c.TextSize = 13
			c.TextWrapped = true
			c.TextXAlignment = Enum.TextXAlignment.Left
			c.Parent = ModalInstance

			local btnHolder = Instance.new("Frame")
			btnHolder.Name = "Buttons"
			btnHolder.BackgroundTransparency = 1
			btnHolder.Size = UDim2.new(1, -20, 0, 32)
			btnHolder.Position = UDim2.new(0, 10, 1, -42)
			btnHolder.Parent = ModalInstance

			local confirm = Instance.new("TextButton")
			confirm.Name = "Confirm"
			confirm.BackgroundColor3 = syde.theme.Accent or Color3.fromRGB(255, 151, 227)
			confirm.Size = UDim2.new(0.48, 0, 1, 0)
			confirm.Position = UDim2.new(0.52, 0, 0, 0)
			confirm.Text = "Confirm"
			confirm.TextColor3 = Color3.fromRGB(20, 20, 20)
			confirm.Font = Enum.Font.GothamBold
			confirm.TextSize = 13
			local c_corner = Instance.new("UICorner")
			c_corner.CornerRadius = UDim.new(0, 6)
			c_corner.Parent = confirm
			local c_lbl = Instance.new("TextLabel")
			c_lbl.Name = "TextLabel"
			c_lbl.Text = "Confirm"
			c_lbl.Size = UDim2.new(1, 0, 1, 0)
			c_lbl.BackgroundTransparency = 1
			c_lbl.TextColor3 = Color3.fromRGB(20, 20, 20)
			c_lbl.Font = Enum.Font.GothamBold
			c_lbl.TextSize = 13
			c_lbl.Parent = confirm
			confirm.Parent = btnHolder

			local cancel = Instance.new("TextButton")
			cancel.Name = "Cancel"
			cancel.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
			cancel.Size = UDim2.new(0.48, 0, 1, 0)
			cancel.Position = UDim2.new(0, 0, 0, 0)
			cancel.Text = "Cancel"
			cancel.TextColor3 = Color3.fromRGB(220, 220, 220)
			cancel.Font = Enum.Font.Gotham
			cancel.TextSize = 13
			local can_corner = Instance.new("UICorner")
			can_corner.CornerRadius = UDim.new(0, 6)
			can_corner.Parent = cancel
			local can_lbl = Instance.new("TextLabel")
			can_lbl.Name = "TextLabel"
			can_lbl.Text = "Cancel"
			can_lbl.Size = UDim2.new(1, 0, 1, 0)
			can_lbl.BackgroundTransparency = 1
			can_lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
			can_lbl.Font = Enum.Font.Gotham
			can_lbl.TextSize = 13
			can_lbl.Parent = cancel
			cancel.Parent = btnHolder
		end

		ModalInstance.AnchorPoint = Vector2.new(0.5, 0.5)
		ModalInstance.Position = UDim2.new(0.5, 0, 0.5, 0)
		ModalInstance.Size = UDim2.new(0, 360, 0, 150)
		ModalInstance.ZIndex = 200
		ModalInstance.Visible = true
		ModalInstance.Parent = ui.main

		if ModalInstance:FindFirstChild("Title") then
			ModalInstance.Title.Text = ModalData.Title
			ModalInstance.Title.ZIndex = 202
		end
		if ModalInstance:FindFirstChild("Content") then
			ModalInstance.Content.Text = ModalData.Content
			ModalInstance.Content.ZIndex = 202
		end

		for _, desc in ipairs(ModalInstance:GetDescendants()) do
			if desc:IsA("GuiObject") then
				desc.ZIndex = math.max(desc.ZIndex, 201)
			end
		end

		local dim = ui.main:FindFirstChild("dim") or ui.main:FindFirstChild("Dim")
		if dim then
			dim.ZIndex = 190
			dim.Visible = true
			tweenservice
				:Create(dim, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { BackgroundTransparency = 0.3 })
				:Play()
		end

		local function closeModal()
			activeModals = math.max(0, activeModals - 1)
			pcall(function()
				tweenservice
					:Create(ModalInstance, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
						Size = UDim2.new(0, 320, 0, 120),
						BackgroundTransparency = 1,
					})
					:Play()
			end)
			task.wait(0.2)
			ModalInstance:Destroy()
			if activeModals == 0 and dim then
				tweenservice
					:Create(dim, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 })
					:Play()
				task.delay(0.2, function()
					if activeModals == 0 then
						dim.Visible = false
					end
				end)
			end
		end

		activeModals += 1
		tweenservice
			:Create(ModalInstance, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 360, 0, 150),
				BackgroundTransparency = 0,
			})
			:Play()

		local confirmBtn = ModalInstance:FindFirstChild("Buttons") and ModalInstance.Buttons:FindFirstChild("Confirm")
		local cancelBtn = ModalInstance:FindFirstChild("Buttons") and ModalInstance.Buttons:FindFirstChild("Cancel")

		if confirmBtn then
			confirmBtn.MouseButton1Click:Connect(function()
				if typeof(ModalData.ConfirmCallBack) == "function" then
					pcall(ModalData.ConfirmCallBack)
				end
				closeModal()
			end)
		end

		if cancelBtn then
			cancelBtn.MouseButton1Click:Connect(function()
				closeModal()
			end)
		end
	end)
end

local toasts = {}
local toastSpacing = 8

local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local function updateToastPositions()
	local startY = 10
	local currentY = startY

	for i = 1, #toasts do
		local toast = toasts[i]
		if toast and toast.Parent then
			local target = UDim2.new(0.5, 0, 0, currentY)

			tweenservice
				:Create(toast, tweenInfo, {
					Position = target,
				})
				:Play()

			currentY += toast.Size.Y.Offset + toastSpacing
		end
	end
end

function syde:Toast(Toasty)
	task.spawn(function()
		local Data = {
			Content = Toasty.Content or "",
			Duration = Toasty.Duration or 5,
			Icon = Toasty.Icon or "",
		}

		local Toast = ui.toastholder.toast:Clone()
		Toast.Visible = true
		Toast.Parent = ui.toastholder
		Toast.AnchorPoint = Vector2.new(0.5, 0)

		Toast.Content.Text = Data.Content

		Toast.Size = UDim2.new(1, Toast.Content.TextBounds.X - 140, 0, 40)

		if Data.Icon ~= "" then
			Toast.icon.ImageLabel.Image = "rbxassetid://" .. Data.Icon
			Toast.icon.ImageLabel.ImageTransparency = 0
		end

		Toast.Position = UDim2.new(0.5, 0, 0, -Toast.Size.Y.Offset - 20)

		table.insert(toasts, 1, Toast)
		updateToastPositions()

		task.delay(Data.Duration, function()
			if not Toast or not Toast.Parent then
				return
			end

			table.remove(toasts, table.find(toasts, Toast))

			tweenservice
				:Create(Toast, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
					Position = Toast.Position - UDim2.fromOffset(0, 30),
					BackgroundTransparency = 1,
				})
				:Play()

			for _, v in ipairs(Toast:GetDescendants()) do
				if v:IsA("TextLabel") then
					tweenservice
						:Create(v, TweenInfo.new(0.3), {
							TextTransparency = 1,
						})
						:Play()
				elseif v:IsA("ImageLabel") then
					tweenservice
						:Create(v, TweenInfo.new(0.3), {
							ImageTransparency = 1,
						})
						:Play()
				elseif v:IsA("Frame") then
					tweenservice
						:Create(v, TweenInfo.new(0.3), {
							BackgroundTransparency = 1,
						})
						:Play()
				end
			end

			task.wait(0.35)
			Toast:Destroy()
			updateToastPositions()
		end)
	end)
end

function syde:MakeNotification(NotificationConfig)
	NotificationConfig = NotificationConfig or {}
	local icon = NotificationConfig.Image or NotificationConfig.Icon or ""
	if type(icon) == "string" then
		icon = icon:gsub("rbxassetid://", "")
	end
	return syde:Notify({
		Title = NotificationConfig.Name or NotificationConfig.Title or "Note!",
		Content = NotificationConfig.Content or "Message",
		Duration = NotificationConfig.Time or NotificationConfig.Duration or 5,
		Icon = icon,
	})
end

local freeMouseBtn = nil
local previousMouseBehavior = nil
local previousMouseIconEnabled = nil
local function getFreeMouseBtn()
	if freeMouseBtn and freeMouseBtn.Parent then
		return freeMouseBtn
	end
	pcall(function()
		local targetParent = (ui and ui:IsA("ScreenGui") and ui)
			or (Library and Library:IsA("ScreenGui") and Library)
			or coregui
		freeMouseBtn = Instance.new("TextButton")
		freeMouseBtn.Name = "FreeMouseModal"
		freeMouseBtn.Size = UDim2.new(0, 0, 0, 0)
		freeMouseBtn.Position = UDim2.new(0, 0, 0, 0)
		freeMouseBtn.BackgroundTransparency = 1
		freeMouseBtn.Text = ""
		freeMouseBtn.Modal = true
		freeMouseBtn.Visible = false
		freeMouseBtn.Parent = targetParent
	end)
	return freeMouseBtn
end

function syde:UnlockMouse(Value)
	Value = Value == true or syde.ForceFreeMouse == true
	local btn = getFreeMouseBtn()
	if btn then
		btn.Modal = Value and syde.AllowCameraDrag ~= true or false
		btn.Visible = Value and true or false
	end

	local uis = game:GetService("UserInputService")
	if Value then
		if previousMouseBehavior == nil then
			previousMouseBehavior = uis.MouseBehavior
			previousMouseIconEnabled = uis.MouseIconEnabled
		end
		uis.MouseBehavior = Enum.MouseBehavior.Default
		uis.MouseIconEnabled = true
	elseif previousMouseBehavior ~= nil then
		uis.MouseBehavior = previousMouseBehavior
		uis.MouseIconEnabled = previousMouseIconEnabled
		previousMouseBehavior = nil
		previousMouseIconEnabled = nil
	end
end

local function normalizeWindowRichText(value)
	return tostring(value or ""):gsub("<font%s+color='([^']+)'>", '<font color="%1">')
end

local function showWindowIntro(config)
	local existing = ui:FindFirstChild("SydeIntroOverlay")
	if existing then
		existing:Destroy()
	end

	local overlay = Instance.new("Frame")
	overlay.Name = "SydeIntroOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	overlay.BorderSizePixel = 0
	overlay.Active = true
	overlay.ZIndex = 1000
	overlay.Parent = ui

	local iconId = config.IntroIcon or config.Icon
	local icon
	if type(iconId) == "string" and iconId ~= "" then
		icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.42)
		icon.Size = UDim2.fromOffset(48, 48)
		icon.BackgroundTransparency = 1
		icon.Image = iconId:match("^%d+$") and ("rbxassetid://" .. iconId) or iconId
		icon.ImageTransparency = 1
		icon.ZIndex = 1001
		icon.Parent = overlay
	end

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.52)
	title.Size = UDim2.new(1, -32, 0, 60)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = isMobile and 20 or 24
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextWrapped = true
	title.RichText = true
	title.Text = normalizeWindowRichText(config.IntroTitle or config.IntroText or config.Name)
	title.TextTransparency = 1
	title.ZIndex = 1001
	title.Parent = overlay

	local subtitle
	if type(config.IntroSubtitle) == "string" and config.IntroSubtitle ~= "" then
		subtitle = Instance.new("TextLabel")
		subtitle.Name = "Subtitle"
		subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
		subtitle.Position = UDim2.fromScale(0.5, 0.59)
		subtitle.Size = UDim2.new(1, -32, 0, 34)
		subtitle.BackgroundTransparency = 1
		subtitle.Font = Enum.Font.Gotham
		subtitle.TextSize = isMobile and 12 or 14
		subtitle.TextColor3 = Color3.fromRGB(180, 180, 185)
		subtitle.TextWrapped = true
		subtitle.RichText = true
		subtitle.Text = normalizeWindowRichText(config.IntroSubtitle)
		subtitle.TextTransparency = 1
		subtitle.ZIndex = 1001
		subtitle.Parent = overlay
	end

	local bar = Instance.new("Frame")
	bar.Name = "Progress"
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(0.5, 0.66)
	bar.Size = UDim2.fromOffset(190, 3)
	bar.BackgroundColor3 = Color3.fromRGB(52, 52, 56)
	bar.BorderSizePixel = 0
	bar.ZIndex = 1001
	bar.Parent = overlay

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = syde.theme.Accent
	fill.BorderSizePixel = 0
	fill.ZIndex = 1002
	fill.Parent = bar

	return function()
		task.spawn(function()
			local enterInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			tweenservice:Create(title, enterInfo, { TextTransparency = 0 }):Play()
			if subtitle then
				tweenservice:Create(subtitle, enterInfo, { TextTransparency = 0.2 }):Play()
			end
			if icon then
				tweenservice:Create(icon, enterInfo, { ImageTransparency = 0 }):Play()
			end
			local progress = tweenservice:Create(
				fill,
				TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = UDim2.fromScale(1, 1) }
			)
			progress:Play()
			progress.Completed:Wait()
			if not overlay.Parent then
				return
			end
			local exitInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			tweenservice:Create(overlay, exitInfo, { BackgroundTransparency = 1 }):Play()
			tweenservice:Create(title, exitInfo, { TextTransparency = 1 }):Play()
			if subtitle then
				tweenservice:Create(subtitle, exitInfo, { TextTransparency = 1 }):Play()
			end
			if icon then
				tweenservice:Create(icon, exitInfo, { ImageTransparency = 1 }):Play()
			end
			tweenservice:Create(bar, exitInfo, { BackgroundTransparency = 1 }):Play()
			tweenservice:Create(fill, exitInfo, { BackgroundTransparency = 1 }):Play()
			task.wait(0.2)
			if overlay.Parent then
				overlay:Destroy()
			end
		end)
	end
end

function syde:MakeWindow(WindowConfig)
	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or WindowConfig.Title or "Fire Hub"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder
		or (syde.ConfigFolderExplicit and syde.ConfigFolder)
		or WindowConfig.Name:gsub("<.->", "")
	WindowConfig.SaveConfig = true
	syde.CornerImageDefault = WindowConfig.CornerImageId or ""

	local cfgFolder = WindowConfig.ConfigFolder
	syde.ConfigFolder = cfgFolder
	syde.Folder = cfgFolder
	syde.SaveCfg = true
	syde.ConfigEnabled = true
	if WindowConfig.ConfigFile ~= nil then
		syde.ConfigFile = normalizeConfigName(WindowConfig.ConfigFile)
		syde.ConfigFileExplicit = true
	elseif not syde.ConfigFileExplicit then
		syde.ConfigFile = tostring(game and game.GameId or "default")
	end

	ensureConfigFolder(cfgFolder)
	ensureConfigFolder(THEME_FOLDER)

	LoadThemeCfg(FILE_PATH)

	local legacyConfigName = syde.ConfigFileExplicit and tostring(game and game.GameId or "default") or nil
	local configFilePath, configFileExists =
		resolveConfigPath(cfgFolder, syde.ConfigFile or game and game.GameId or "default", legacyConfigName)
	if configFileExists then
		local ok, rawData = pcall(readfile, configFilePath)
		if ok and rawData and rawData ~= "" then
			local decodeOk, decoded = pcall(function()
				return HttpService:JSONDecode(rawData)
			end)
			if decodeOk and type(decoded) == "table" then
				if decoded.Blur == nil and type(decoded.BLUR) == "boolean" then
					decoded.Blur = decoded.BLUR
				end
				syde.LoadedConfig = decoded
				if decoded["ToggleUI"] then
					local success, keyEnum = pcall(function()
						return Enum.KeyCode[decoded["ToggleUI"]] or Enum.UserInputType[decoded["ToggleUI"]]
					end)
					if success and keyEnum then
						uitoggle = keyEnum
					end
				end
			end
		end
	end

	local libConfig = {
		Title = WindowConfig.Name or WindowConfig.Title or "Syde",
		SubText = WindowConfig.TagText or WindowConfig.Subtitle or WindowConfig.SubText or "Hub",
		MultiTitle = WindowConfig.MultiTitle,
		Home = WindowConfig.Home or {
			Enabled = WindowConfig.HomeEnabled ~= false,
			profileImage = WindowConfig.ProfileImage,
			hTitle = WindowConfig.HomeTitle,
			hSubText = WindowConfig.HomeSubText,
		},
	}

	if WindowConfig.FreeMouse ~= false then
		syde.FreeMouse = true
		task.spawn(function()
			task.wait(0.05)
			syde:UnlockMouse(true)
		end)
	end

	local startIntro
	if WindowConfig.IntroEnabled == true then
		startIntro = showWindowIntro(WindowConfig)
	end
	local windowObj = syde:Init(libConfig)
	setWindowGlow(syde.LoadedConfig and syde.LoadedConfig.Glow == true)
	setBackgroundBlur(syde.LoadedConfig and syde.LoadedConfig.Blur == true)
	if syde.LoadedConfig and syde.LoadedConfig.InterfaceRGB == true then
		syde:SetRainbowMode(true)
	end
	if windowObj and startIntro then
		startIntro()
	elseif startIntro then
		local overlay = ui:FindFirstChild("SydeIntroOverlay")
		if overlay then
			overlay:Destroy()
		end
	end
	local watermarkEnabled = WindowConfig.Watermark ~= false
	if syde.LoadedConfig and type(syde.LoadedConfig.WTRMK) == "boolean" then
		watermarkEnabled = syde.LoadedConfig.WTRMK
	end
	syde:SetWatermarkEnabled(watermarkEnabled)
	syde:SetPerformanceOverlay(WindowConfig.PerformanceOverlay ~= false)

	if
		not (syde.LoadedConfig and syde.LoadedConfig.ToggleUI)
		and (WindowConfig.KeyToOpenWindow or WindowConfig.Openkey)
	then
		local key = WindowConfig.KeyToOpenWindow or WindowConfig.Openkey
		if type(key) == "string" and Enum.KeyCode[key] then
			uitoggle = Enum.KeyCode[key]
		elseif typeof(key) == "EnumItem" then
			uitoggle = key
		end
	end

	return windowObj
end

function syde:CreateWindow(WindowConfig)
	return self:MakeWindow(WindowConfig)
end

local function cancelRejoin(self, expectedState)
	local state = self._rejoinState
	if expectedState and state ~= expectedState then
		return false
	end
	if state then
		state.active = false
		if state.connection and state.connection.Connected then
			state.connection:Disconnect()
		end
		state.connection = nil
		for thread in pairs(state.tasks) do
			pcall(task.cancel, thread)
		end
		table.clear(state.tasks)
		self._rejoinState = nil
	end
	self._rejoining = false
	return true
end

function syde:Rejoin()
	if self._destroyed or self._rejoining then
		return false
	end
	local localPlayer = player.LocalPlayer
	if not localPlayer then
		return false
	end

	self._rejoining = true
	local teleports = game:GetService("TeleportService")
	local state = { active = true, tasks = {} }
	self._rejoinState = state
	local fallbackStarted = false
	local fallbackAttempt = 0
	local retryScheduled = false
	local function isActive()
		return state.active and self._rejoinState == state and self._rejoining and not self._destroyed
	end
	local function schedule(delaySeconds, callback)
		local thread
		thread = task.delay(delaySeconds, function()
			state.tasks[thread] = nil
			if isActive() then
				callback()
			end
		end)
		state.tasks[thread] = true
	end
	local function finish()
		cancelRejoin(self, state)
	end
	local function tryFallback()
		if not isActive() or retryScheduled then
			return
		end
		if fallbackAttempt >= 3 then
			finish()
			return
		end
		fallbackStarted = true
		retryScheduled = true
		schedule(fallbackAttempt == 0 and 0 or 1, function()
			retryScheduled = false
			fallbackAttempt += 1
			local thisAttempt = fallbackAttempt
			local ok, err = pcall(function()
				teleports:Teleport(game.PlaceId, localPlayer)
			end)
			if not ok then
				warn("[Syde Rejoin] Fallback " .. thisAttempt .. " failed: " .. tostring(err))
				tryFallback()
			else
				schedule(10, function()
					if fallbackAttempt == thisAttempt then
						finish()
					end
				end)
			end
		end)
	end

	state.connection = teleports.TeleportInitFailed:Connect(function(failedPlayer)
		if isActive() and failedPlayer == localPlayer then
			tryFallback()
		end
	end)
	if game.JobId == "" then
		tryFallback()
		return true
	end

	local ok, err = pcall(function()
		teleports:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
	end)
	if not ok then
		warn("[Syde Rejoin] Same-server teleport failed: " .. tostring(err))
		tryFallback()
	else
		schedule(10, function()
			if not fallbackStarted then
				finish()
			end
		end)
	end
	return true
end

function syde:Destroy()
	if self._destroyed then
		return false
	end

	if saveDebounce and not self.IsLoadingConfig then
		self:FlushConfig()
	end
	self._destroyed = true
	if cameraChangedConnection and cameraChangedConnection.Connected then
		cameraChangedConnection:Disconnect()
	end
	cancelRejoin(self)
	configLoadGeneration += 1
	syde.IsLoadingConfig = false
	for _, thread in ipairs(configLoadTasks) do
		pcall(task.cancel, thread)
	end
	table.clear(configLoadTasks)
	if connectionCleanupTask then
		task.cancel(connectionCleanupTask)
		connectionCleanupTask = nil
	end
	if rainbowConnection then
		rainbowConnection:Disconnect()
		rainbowConnection = nil
	end
	if rainbowDescendantConnection then
		rainbowDescendantConnection:Disconnect()
		rainbowDescendantConnection = nil
	end
	setBackgroundBlur(false)
	if rs and rs.Connected then
		rs:Disconnect()
	end
	if ss and ss.Connected then
		ss:Disconnect()
	end
	if performanceOverlay.connection then
		performanceOverlay.connection:Disconnect()
		performanceOverlay.connection = nil
	end
	local wiggleLabels = {}
	for label in pairs(activeWiggles) do
		wiggleLabels[#wiggleLabels + 1] = label
	end
	for _, label in ipairs(wiggleLabels) do
		self:StopWiggle(label)
	end
	for index = #syde.Connections, 1, -1 do
		local connectionData = syde.Connections[index]
		local connection = connectionData and (connectionData.Connection or connectionData)
		if connection and connection.Connected then
			connection:Disconnect()
		end
		table.remove(syde.Connections, index)
	end
	local boundFrames = {}
	for frame in pairs(binds) do
		boundFrames[#boundFrames + 1] = frame
	end
	for _, frame in ipairs(boundFrames) do
		self:UnbindFrame(frame)
	end
	if root and root.Parent then
		root:Destroy()
	end
	performanceOverlay.frame = nil
	performanceOverlay.label = nil
	performanceOverlay.enabled = false
	syde._currentWindow = nil
	syde:UnlockMouse(false)
	pcall(function()
		if Library and Library.Parent then
			Library:Destroy()
		end
	end)
	return true
end

function syde:DestroyLib()
	syde:Destroy()
end

function SetUserInfo()
	local LocalPlayer = player.LocalPlayer

	local PLACEHOLDER_IMAGE = "rbxassetid://0"
	local THUMBNAIL_TYPE = Enum.ThumbnailType.HeadShot
	local THUMBNAIL_SIZE = Enum.ThumbnailSize.Size420x420

	local imageLabel = window:WaitForChild("user"):WaitForChild("headshot")
	imageLabel.Image = PLACEHOLDER_IMAGE

	local success, thumbnail = pcall(function()
		return player:GetUserThumbnailAsync(LocalPlayer.UserId, THUMBNAIL_TYPE, THUMBNAIL_SIZE)
	end)

	if success and thumbnail then
		imageLabel.Image = thumbnail
		window.user.headshot.id.username.Text = LocalPlayer.Name
		window.user.headshot.id.displayname.Text = "@" .. LocalPlayer.DisplayName
	else
		imageLabel.Image = PLACEHOLDER_IMAGE
	end
end

local searchopen = false

function opensearch()
	searchopen = true
	window.dim.Visible = true
	window.search.Visible = true
	window.search.Container.Visible = true
	window.search.Visible = true

	if window.search.Frame.TextBox.Text ~= "" then
		tweenservice
			:Create(
				window.search,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ Size = UDim2.new(0, 350, 0, 230) }
			)
			:Play()
	else
		tweenservice
			:Create(
				window.search,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ Size = UDim2.new(0, 350, 0, 60) }
			)
			:Play()
	end

	tweenservice
		:Create(window.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.45 })
		:Play()
	tweenservice
		:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
		:Play()
	tweenservice
		:Create(
			window.search.Frame.ImageLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
			{ ImageTransparency = 0 }
		)
		:Play()

	tweenservice
		:Create(window.search.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
		:Play()
	tweenservice
		:Create(
			window.search.close.ImageLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
			{ ImageTransparency = 0 }
		)
		:Play()

	tweenservice
		:Create(window.search.Frame.TextBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		:Play()
end

function closesearch()
	searchopen = false
	window.search.Container.Visible = false
	tweenservice
		:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 350, 0, 60) })
		:Play()
	tweenservice
		:Create(window.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
		:Play()
	tweenservice
		:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
		:Play()
	tweenservice
		:Create(
			window.search.Frame.ImageLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
			{ ImageTransparency = 1 }
		)
		:Play()

	tweenservice
		:Create(window.search.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
		:Play()
	tweenservice
		:Create(
			window.search.close.ImageLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
			{ ImageTransparency = 1 }
		)
		:Play()

	tweenservice
		:Create(window.search.Frame.TextBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	task.wait(0.5)
	window.dim.Visible = false
	window.search.Visible = false
end

local sizeBeforeMinimize = nil

function openui()
	pages.Visible = true
	window.tabs.Visible = true
	window.user.Visible = true
	window.Visible = true
	uiclosed = false
	updateBlurVisibility()
	if performanceOverlay.align then
		performanceOverlay.align()
	end
	setWindowGlow(glow)

	if syde.FreeMouse ~= false then
		syde:UnlockMouse(true)
	end

	local fastTween = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	tweenservice:Create(window, fastTween, { BackgroundTransparency = 0 }):Play()
	tweenservice:Create(window, fastTween, { Size = sizeBeforeMinimize or UDim2.fromOffset(700, 560) }):Play()

	tweenservice:Create(window.top.separator, fastTween, { BackgroundTransparency = 0 }):Play()
	tweenservice:Create(window.top.title, fastTween, { TextTransparency = 0 }):Play()
	tweenservice:Create(window.top.title.sub, fastTween, { TextTransparency = 0 }):Play()
	tweenservice:Create(window.top.functions, fastTween, { BackgroundTransparency = 0 }):Play()

	if window.wallpaper.ison.Value then
		tweenservice:Create(window.wallpaper, fastTween, { ImageTransparency = 0.84 }):Play()
	end

	for i, v in pairs(window.top.functions:GetChildren()) do
		if v:IsA("Frame") then
			tweenservice:Create(v, fastTween, { BackgroundTransparency = 0.8 }):Play()
			v.Visible = true
			for i, v2 in pairs(v:GetChildren()) do
				if v2:IsA("ImageLabel") then
					tweenservice:Create(v2, fastTween, { ImageTransparency = 0 }):Play()
					v2.Visible = true
				end
			end
			if v:FindFirstChild("rainbow") then
				v.rainbow.ImageTransparency = syde.RainbowMode and 0 or 1
			end
		end
	end

	tweenservice:Create(window.shadow.ImageLabel, fastTween, { ImageTransparency = 0.5 }):Play()
	window.resize.ImageTransparency = 1

	setWindowGlow(glow)
	if rainbowIconSync then
		rainbowIconSync()
	end
end

local lastHideToastAt = 0
function closeui()
	sizeBeforeMinimize = window.Size
	uiclosed = true
	pages.Visible = false
	window.tabs.Visible = false
	window.user.Visible = false
	window.Visible = false
	updateBlurVisibility()
	if performanceOverlay.frame then
		performanceOverlay.frame.Visible = false
	end
	window.shadow.glow.Visible = false
	window.shadow.glow1.Visible = false
	for _, effect in ipairs(window.clipframe:GetChildren()) do
		if effect:IsA("ImageLabel") then
			effect.Visible = false
		end
	end

	settingsOpen = false
	searchopen = false
	window.settings.Visible = false
	window.settings.pages.Visible = false
	window.settings.tabs.Visible = false
	window.search.Container.Visible = false
	window.search.Visible = false
	window.dim.Visible = false

	if syde.FreeMouse ~= false then
		syde:UnlockMouse(false)
	end

	if tick() - lastHideToastAt >= 2 then
		lastHideToastAt = tick()
		syde:Toast({
			Content = "UI Hidden, Use " .. uitoggle.Name .. " To Open Back.",
			Duration = 2,
		})
	end
end

local bounce = false

function ToggleUI()
	if bounce then
		return
	end
	bounce = true

	if uiclosed then
		openui()
	else
		closeui()
	end

	task.delay(0.08, function()
		bounce = false
	end)
end

window.top.functions.close.interact.MouseButton1Click:Connect(function()
	syde:Modal({
		Title = "Please Confirm Below.",
		Content = "Are You Sure You Want To Close This UI?",
		ConfimCallBack = function()
			mh = false

			task.wait(1)
			syde:Destroy()
		end,
	})
end)

syde:HidePH(tabs, "btn")
syde:HidePH(pages, "page")

function syde:Init(library)
	if syde._currentWindow and (not library or library == true or type(library) ~= "table" or not library.Title) then
		pcall(function()
			local folder = syde.Folder or syde.ConfigFolder or "FireHub"
			local filePath = folder .. "/" .. tostring(game and game.GameId or "0") .. ".txt"
			if isfile and isfile(filePath) then
				local content = readfile(filePath)
				if content and content ~= "" then
					LoadCfg(content)
					if syde.MakeNotification then
						syde:MakeNotification({
							Name = "Configuration",
							Content = "Auto-loaded configuration for the game " .. tostring(game.GameId) .. ".",
							Time = 5,
						})
					elseif syde.Notify then
						syde:Notify({
							Title = "Configuration",
							Content = "Auto-loaded configuration for the game " .. tostring(game.GameId) .. ".",
							Duration = 5,
						})
					end
				end
			end
		end)
		return syde._currentWindow
	end

	library = library or {}
	ui.Enabled = true
	if loaded == false then
		local UI_TAG = "sydeUILoader"
		local MARKER_NAME = "SYDEUIDetector"
		local INTERNAL_UUID = ("SYDE-" .. tostring(game.JobId):gsub("-", "") .. tostring(tick())):gsub("%.", "")
		local PROTECTION_EVENT = Instance.new("BindableEvent")
		local HttpService = game:GetService("HttpService")

		local function deepCleanup()
			for _, v in ipairs(coregui:GetChildren()) do
				if v:IsA("ScreenGui") and v:FindFirstChild(MARKER_NAME) then
					pcall(function()
						v:Destroy()
					end)
				end
			end
		end
		deepCleanup()

		local successLibrary, Library = pcall(function()
			return Library
		end)

		if not successLibrary or not Library then
			syde:Report("Loading UI library", "Library/GetObjects returned nil - the UI asset failed to load")
			return
		end

		Library.Name = UI_TAG
		Library.ResetOnSpawn = false

		local marker = Instance.new("StringValue")
		marker.Name = MARKER_NAME
		marker.Value = INTERNAL_UUID
		marker.Parent = Library

		pcall(function()
			Library.Parent = coregui
		end)

		task.spawn(function()
			while Library and Library.Parent do
				task.wait(1)
				if Library.Parent ~= coregui then
					warn("[SYDE] UI moved. Restoring...")
					pcall(function()
						Library.Parent = coregui
					end)
				end
			end
		end)
	end
	task.wait(0.1)

	local Data = {
		Title = library.Title or "Syde",
		SubText = library.SubText or "Google",
		MultiTitle = library.MultiTitle,
		Home = library.Home or {},
	}

	Data.Home.Enabled = (Data.Home.Enabled == true)
	Data.Home.hTitle = Data.Home.hTitle or Data.Title
	Data.Home.hSubText = Data.Home.hSubText or Data.SubText
	Data.Home.profileImage = Data.Home.profileImage or Data.profileImage or ""

	local Minihome = ui.minihome

	local MinihomeData = {
		QuickActions = library.QuickActions or false,
	}

	local lastTime = tick()
	local frames = 0

	if mh then
		rs = RunService.RenderStepped:Connect(function()
			local info = Minihome and Minihome:FindFirstChild("info")
			if not info or not Minihome.Parent then
				if rs then
					rs:Disconnect()
				end
				return
			end

			frames += 1
			local now = tick()

			if now - lastTime >= 1 then
				local fps = math.floor(frames / (now - lastTime))
				lastTime = now
				frames = 0

				if not performanceOverlay.enabled then
					info.fps.Text = fps .. " FPS"
				end
			end

			local hour = tonumber(os.date("%I"))
			info.time.Text = hour .. os.date(":%M")
		end)

		if MinihomeData.QuickActions == false then
			ui.minihome.quick.Visible = false
			ui.minihome:TweenSize(UDim2.new(0, 150, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.8, true)
		end
	end

	if not uiclosed then
		local reopenButton = ui.minihome.open.quickfunc.interact
		reopenButton.AnchorPoint = Vector2.new(0.5, 0.5)
		reopenButton.Position = UDim2.fromScale(0.5, 0.5)
		reopenButton.Size = UDim2.fromOffset(44, 44)
		reopenButton.Activated:Connect(function()
			ToggleUI()
		end)
	end

	top.title.RichText = true
	top.title.sub.RichText = true
	local function setHeaderTitle(value)
		local richTitle = normalizeWindowRichText(value)
		top.title.Text = richTitle
		task.defer(function()
			if top.title.Parent and top.title.Text == richTitle then
				top.title.Size = UDim2.new(0, top.title.TextBounds.X + 3, 0, 20)
			end
		end)
	end
	setHeaderTitle(Data.Title)
	top.title.sub.Text = normalizeWindowRichText(Data.SubText)
	top.title.TextColor3 = syde.HeaderTitleColor or syde.theme.Text or Color3.fromRGB(240, 240, 240)
	top.title.sub.TextColor3 = syde.HeaderSubtitleColor or syde.theme.TextDark or Color3.fromRGB(150, 150, 150)

	syde:AddDrag(top, window, true)
	if Minihome then
		syde:AddDrag(Minihome, Minihome)
	end
	window.resize.ImageTransparency = 1
	window.resize.Size = UDim2.fromOffset(38, 38)
	local resizeArrow = window.resize:FindFirstChild("ResizeArrow") or Instance.new("TextLabel")
	resizeArrow.Name = "ResizeArrow"
	resizeArrow.BackgroundTransparency = 1
	resizeArrow.Size = UDim2.fromScale(1, 1)
	resizeArrow.Font = Enum.Font.GothamSemibold
	resizeArrow.Text = "↘"
	resizeArrow.TextSize = 21
	resizeArrow.TextColor3 = Color3.fromRGB(210, 210, 214)
	resizeArrow.TextTransparency = 0.45
	resizeArrow.ZIndex = window.resize.ZIndex + 1
	resizeArrow.Parent = window.resize
	syde:MakeResizable(window.resize, window, Vector2.new(454, 228))

	top.title.TextTransparency = 1
	tweenservice:Create(top.title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
	top.title.sub.TextTransparency = 1
	tweenservice
		:Create(top.title.sub, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()

	task.spawn(function()
		task.wait(0.5)
		local titleTween =
			tweenservice:Create(top.title, TweenInfo.new(1.65, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		titleTween:Play()

		task.wait(0.1)
		local subTitleTween = tweenservice:Create(
			top.title.sub,
			TweenInfo.new(1.65, Enum.EasingStyle.Exponential),
			{ TextTransparency = 0 }
		)
		subTitleTween:Play()

		task.wait()
		local textSize = top.title.TextBounds.X + 3

		tweenservice
			:Create(top.title, TweenInfo.new(1.55, Enum.EasingStyle.Quint), {
				Size = UDim2.new(0, textSize, 0, 20),
			})
			:Play()
	end)

	local titleVariants = { Data.Title }
	if type(Data.MultiTitle) == "table" then
		for _, title in ipairs(Data.MultiTitle) do
			if type(title) == "string" and title ~= "" then
				table.insert(titleVariants, title)
			end
		end
	end
	syde._titleRotationToken = (syde._titleRotationToken or 0) + 1
	local titleRotationToken = syde._titleRotationToken
	if #titleVariants > 1 then
		task.spawn(function()
			local titleIndex = 1
			while ui.Parent and top.title.Parent and syde._titleRotationToken == titleRotationToken do
				task.wait(4)
				if not ui.Parent or not top.title.Parent or syde._titleRotationToken ~= titleRotationToken then
					break
				end
				titleIndex = titleIndex % #titleVariants + 1
				if not uiclosed then
					local fadeOut = tweenservice:Create(
						top.title,
						TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ TextTransparency = 1 }
					)
					fadeOut:Play()
					fadeOut.Completed:Wait()
					if not top.title.Parent or syde._titleRotationToken ~= titleRotationToken then
						break
					end
				end
				setHeaderTitle(titleVariants[titleIndex])
				if not uiclosed then
					tweenservice
						:Create(
							top.title,
							TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{ TextTransparency = 0 }
						)
						:Play()
				end
			end
		end)
	end

	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")

	for _, v in ipairs(top.functions:GetChildren()) do
		if not v:IsA("Frame") then
			continue
		end
		if not v:FindFirstChild("ImageLabel") then
			continue
		end

		local image = v.ImageLabel
		local rainbowState = v.Name == "plugins"
				and {
					hue = math.random(),
					connection = nil,
					hovered = false,
				}
			or nil
		local gradient = rainbowState and v.rainbow:FindFirstChildOfClass("UIGradient")
		local function stopRainbowAnimation()
			if rainbowState and rainbowState.connection then
				rainbowState.connection:Disconnect()
				rainbowState.connection = nil
			end
		end
		local function startRainbowAnimation()
			if not (rainbowState and gradient and not rainbowState.connection) then
				return
			end
			rainbowState.connection = RunService.RenderStepped:Connect(function(dt)
				if syde._destroyed or uiclosed or not v.Parent or not gradient.Parent then
					stopRainbowAnimation()
					return
				end
				rainbowState.hue = (rainbowState.hue + dt * 0.35) % 1
				gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(rainbowState.hue, 0.8, 1)),
					ColorSequenceKeypoint.new(0.5, Color3.fromHSV((rainbowState.hue + 0.33) % 1, 0.8, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV((rainbowState.hue + 0.66) % 1, 0.8, 1)),
				})
			end)
		end
		if rainbowState then
			v.Destroying:Connect(function()
				stopRainbowAnimation()
			end)
			rainbowIconSync = function()
				v.rainbow.ImageTransparency = (syde.RainbowMode or rainbowState.hovered) and 0 or 1
				if syde.RainbowMode or rainbowState.hovered then
					startRainbowAnimation()
				else
					stopRainbowAnimation()
				end
			end
			local button = v:FindFirstChild("interact")
			if button then
				button.Activated:Connect(function()
					local enabled = not syde.RainbowMode
					if rainbowSettingControl then
						rainbowSettingControl:Set(enabled)
					else
						syde:SetRainbowMode(enabled)
						SaveCfg(game and game.GameId)
					end
				end)
			end
		end

		v.MouseEnter:Connect(function()
			if not uiclosed then
				if v.Name ~= "plugins" then
					TweenService
						:Create(image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0.7 })
						:Play()
				end
			end

			if rainbowState then
				rainbowState.hovered = true
				rainbowIconSync()
			end
		end)

		v.MouseLeave:Connect(function()
			if not uiclosed then
				if v.Name ~= "plugins" then
					TweenService
						:Create(image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0 })
						:Play()
				end
			end

			if rainbowState then
				rainbowState.hovered = false
				rainbowIconSync()
			end
		end)
	end

	window.search.close.interact.MouseButton1Click:Connect(function()
		closesearch()
	end)

	local debounce = false
	local DEBOUNCE_TIME = 0.1

	top.functions.search.interact.MouseButton1Click:Connect(function()
		if debounce then
			return
		end
		debounce = true

		if not searchopen then
			opensearch()
		else
			closesearch()
		end

		task.delay(DEBOUNCE_TIME, function()
			debounce = false
		end)
	end)

	syde:AddConnection(syde.Comms.Event, function(p, value)
		if p == "Accent" then
			for i, glow in pairs(window.clipframe:GetChildren()) do
				if glow:IsA("ImageLabel") then
					tweenservice
						:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageColor3 = value })
						:Play()
				end
			end
			tweenservice
				:Create(window.shadow.glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageColor3 = value })
				:Play()
			tweenservice
				:Create(window.shadow.glow1, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageColor3 = value })
				:Play()
		end
	end)

	SetUserInfo()
	tweenservice
		:Create(
			window.user.headshot.id.username,
			TweenInfo.new(0.5, Enum.EasingStyle.Quart),
			{ Size = UDim2.new(0, window.user.headshot.id.username.TextBounds.X + 10, 0, 10) }
		)
		:Play()

	if userinfodisabled == false then
		tweenservice
			:Create(
				window.tabs,
				TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
				{ Size = UDim2.new(0, 200, 1, -115) }
			)
			:Play()
	else
		tweenservice
			:Create(window.tabs, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 200, 1, -75) })
			:Play()
	end

	window.user.MouseEnter:Connect(function()
		tweenservice:Create(window.user.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Quart), { Thickness = 1 }):Play()
	end)
	window.user.MouseLeave:Connect(function()
		tweenservice:Create(window.user.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Quart), { Thickness = 0 }):Play()
	end)

	if Data.Home.Enabled then
		local homeHeader = window.pages.home.general.presence.Profile.ImageLabel.Text.Header
		local homeSubtitle = window.pages.home.general.presence.Profile.ImageLabel.Text.Sub
		homeHeader.RichText = true
		homeSubtitle.RichText = true
		homeHeader.Text = normalizeWindowRichText(Data.Home.hTitle)
		homeSubtitle.Text = normalizeWindowRichText(Data.Home.hSubText)
		homeHeader.TextColor3 = Color3.fromRGB(245, 245, 248)
		homeSubtitle.TextColor3 = Color3.fromRGB(170, 170, 180)
		homeHeader.TextTruncate = Enum.TextTruncate.AtEnd

		local homeImage = tostring(Data.Home.profileImage or "")
		local usedAvatar = homeImage == ""
		if usedAvatar and player.LocalPlayer then
			homeImage = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player.LocalPlayer.UserId)
		elseif homeImage ~= "" and not homeImage:find("://", 1, true) then
			homeImage = "rbxassetid://" .. homeImage
		end
		window.pages.home.general.presence.Profile.ImageLabel.Image = homeImage
		window.pages.home.general.presence.wallpaper.Image = homeImage
		if usedAvatar then
			window.pages.home.general.presence.wallpaper.ImageTransparency = 0.92
		end

		local placeId = game.PlaceId

		local placeLabel = window.pages.home.general.presence.PlaceID
		placeLabel.Text = "Experiência  ·  " .. placeId
		placeLabel.TextColor3 = Color3.fromRGB(155, 155, 168)
		placeLabel.TextSize = 11

		local layout = Bento.new(window.pages.home.general.Quick, {
			Gap = 6,
			RightPadding = 20,
			TweenTime = 0.35,
		})

		local summaryRow = layout:NewRow()
		local latencyRow = layout:NewRow()
		local actionsRow = layout:NewRow()

		layout:AddItem(window.pages.home.general.Quick.QuickPlay, nil, summaryRow)
		layout:AddItem(window.pages.home.general.Quick.Player, nil, summaryRow)
		layout:AddItem(window.pages.home.general.Quick.Latency, nil, latencyRow)
		layout:AddItem(window.pages.home.general.Quick.QuickSettings, { Bottom = true }, actionsRow)
		local homeScroller = window.pages.home.general
		if homeScroller:IsA("ScrollingFrame") then
			homeScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
		end

		layout:Bind()
		layout:Update()

		local graph = window.pages.home.general.Quick.Latency.Frame:WaitForChild("graph")

		local pointTemplate = graph:WaitForChild("point")
		local lineTemplate = graph:WaitForChild("line")

		pointTemplate.Visible = false
		lineTemplate.Visible = false

		local UPDATE_INTERVAL = 0.3
		local MAX_POINTS = 15
		local MAX_PING = 300

		local SMOOTH_SPEED = 0.25

		local history = {}
		local smoothHistory = {}

		local points = {}
		local lines = {}
		local gridLines = {}
		local gridLabels = {}
		local gridBuilt = false

		while ui and ui.Parent and graph.Parent and (graph.AbsoluteSize.X <= 0 or graph.AbsoluteSize.Y <= 0) do
			task.wait()
		end
		if not (ui and ui.Parent and graph.Parent) then
			return
		end

		local function getPing()
			return getNetworkPingMs()
		end

		local function createGrid()
			local w = graph.AbsoluteSize.X
			local h = graph.AbsoluteSize.Y
			local steps = 4

			if not gridBuilt then
				for i = 0, steps do
					local gridLine = Instance.new("Frame")
					gridLine.Name = "LatencyGridLine" .. tostring(i)
					gridLine.BackgroundTransparency = 0.85
					gridLine.BorderSizePixel = 0
					gridLine.Parent = graph
					gridLines[i + 1] = gridLine

					local label = Instance.new("TextLabel")
					label.Name = "LatencyGridLabel" .. tostring(i)
					label.BackgroundTransparency = 1
					label.TextSize = 6
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextColor3 = Color3.fromRGB(255, 255, 255)
					label.TextTransparency = 0
					label.Parent = graph
					gridLabels[i + 1] = label
				end
				gridBuilt = true
			end

			for i = 0, steps do
				local percent = i / steps
				local y = h - (percent * h)
				local gridLine = gridLines[i + 1]
				local label = gridLabels[i + 1]
				if gridLine and gridLine.Parent then
					gridLine.Size = UDim2.fromOffset(w, 1)
					gridLine.Position = UDim2.fromOffset(34, y)
				end
				if label and label.Parent then
					label.Size = UDim2.fromOffset(40, 14)
					label.Position = UDim2.fromOffset(2, y - 7)
					label.Text = tostring(math.floor(percent * MAX_PING)) .. " ms"
				end
			end
		end

		local function draw()
			if not (graph.Parent and graph.AbsoluteSize.X > 0 and graph.AbsoluteSize.Y > 0) then
				return
			end
			createGrid()

			local w = graph.AbsoluteSize.X
			local h = graph.AbsoluteSize.Y

			local step = w / (MAX_POINTS - 1)

			local lastX, lastY
			local pointCount = #smoothHistory
			local lineCount = math.max(0, pointCount - 1)

			for i, value in ipairs(smoothHistory) do
				local percent = math.clamp(value / MAX_PING, 0, 1)

				local x = (i - 1) * step
				local y = h - (percent * h)

				local point = points[i]
				if not point then
					point = pointTemplate:Clone()
					point.Name = "LatencyPoint" .. tostring(i)
					point.Parent = graph
					points[i] = point
				end
				point.Visible = pointTemplate.Visible
				point.Position = UDim2.fromOffset(x, y)
				point.AnchorPoint = Vector2.new(0.5, 0.5)

				if lastX then
					local dx = x - lastX
					local dy = y - lastY

					local length = math.sqrt(dx * dx + dy * dy)

					local angle = math.deg(math.atan2(dy, dx))

					local midX = (lastX + x) / 2
					local midY = (lastY + y) / 2

					local lineIndex = i - 1
					local line = lines[lineIndex]
					if not line then
						line = lineTemplate:Clone()
						line.Name = "LatencyLine" .. tostring(lineIndex)
						line.Parent = graph
						lines[lineIndex] = line
					end
					line.Visible = true
					line.AnchorPoint = Vector2.new(0.5, 0.5)

					line.Position = UDim2.fromOffset(midX, midY)

					line.Size = UDim2.fromOffset(length, 1)

					line.Rotation = angle
				end

				lastX = x
				lastY = y
			end

			for i = pointCount + 1, #points do
				if points[i] then
					points[i].Visible = false
				end
			end
			for i = lineCount + 1, #lines do
				if lines[i] then
					lines[i].Visible = false
				end
			end
		end

		task.spawn(function()
			while ui and ui.Parent and graph.Parent do
				local ping = getPing()
				if type(ping) == "number" and ping >= 0 and ping < math.huge then
					table.insert(history, ping)
					if #history > MAX_POINTS then
						table.remove(history, 1)
					end

					for i, value in ipairs(history) do
						local current = smoothHistory[i] or value
						smoothHistory[i] = current + (value - current) * SMOOTH_SPEED
					end

					draw()
				end
				task.wait(UPDATE_INTERVAL)
			end
		end)

		local bh = window.pages.home.general.Quick.QuickSettings.QuickButtons.holder

		for i, v in ipairs(window.pages.home.general.Quick.QuickSettings.QuickButtons.holder:GetChildren()) do
			if v:IsA("Frame") then
				v.MouseEnter:Connect(function()
					tweenservice
						:Create(v.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { Transparency = 0 })
						:Play()
				end)

				v.MouseLeave:Connect(function()
					tweenservice
						:Create(v.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { Transparency = 1 })
						:Play()
				end)
			end
		end

		bh.Leave.interact.MouseButton1Click:Connect(function()
			game:GetService("Players").LocalPlayer:Kick("Left the experience")
		end)

		bh.Rejoin.interact.MouseButton1Click:Connect(function()
			syde:Rejoin()
		end)

		local HttpService = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")
		local Players = game:GetService("Players")

		local player = Players.LocalPlayer

		local placeId = game.PlaceId

		local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request

		local function httpGet(url)
			if httpRequest then
				local response = httpRequest({ Url = url, Method = "GET" })
				return response and response.Body
			end
			return game:HttpGet(url)
		end

		local function ServerHop()
			local cursor = ""

			local servers = {}

			repeat
				local url = "https://games.roblox.com/v1/games/"
					.. placeId
					.. "/servers/Public?sortOrder=Asc&limit=100&cursor="
					.. cursor

				local ok, response = pcall(function()
					return HttpService:JSONDecode(httpGet(url))
				end)

				if not ok or type(response) ~= "table" or not response.data then
					break
				end

				for _, server in pairs(response.data) do
					if server.playing < server.maxPlayers and server.id ~= game.JobId then
						table.insert(servers, server.id)
					end
				end

				cursor = response.nextPageCursor

			until cursor == nil or #servers > 0

			if #servers > 0 then
				TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player)
			end
		end

		bh.Fast.interact.MouseButton1Click:Connect(function()
			ServerHop()
		end)

		local Players = game:GetService("Players")

		local label = window.pages.home.general.Quick.Player.Frame.TextLabel
		label.TextScaled = false
		label.TextSize = 24
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.Size = UDim2.new(1, -12, 1, 0)
		label.Position = UDim2.fromOffset(6, 0)

		local function update()
			local current = #Players:GetPlayers()

			local max = Players.MaxPlayers

			label.Text = current .. " / " .. max
		end

		update()

		syde:AddConnection(Players.PlayerAdded, update)
		syde:AddConnection(Players.PlayerRemoving, function()
			task.defer(update)
		end)

		local QuickPlay = window.pages.home.general.Quick.QuickPlay

		local HttpService = game:GetService("HttpService")
		local MarketplaceService = game:GetService("MarketplaceService")
		local TeleportService = game:GetService("TeleportService")

		local FILE = syde.ConfigFolder .. "/last_game.json"

		local function SaveLastGame(placeId)
			if not syde.ConfigEnabled then
				return
			end

			local data = {
				PlaceId = placeId,
				Time = os.time(),
			}

			pcall(function()
				writefile(FILE, HttpService:JSONEncode(data))
			end)
		end

		local function LoadLastGame()
			if not syde.ConfigEnabled then
				return nil
			end
			if not isfile(FILE) then
				return nil
			end

			local success, result = pcall(function()
				return HttpService:JSONDecode(readfile(FILE))
			end)

			if success then
				return result
			end
		end

		local lastGame = LoadLastGame()

		local placeId = game.PlaceId

		if lastGame and lastGame.PlaceId then
			placeId = lastGame.PlaceId
		end

		local success, info = pcall(function()
			return MarketplaceService:GetProductInfoAsync(placeId, Enum.InfoType.Asset)
		end)

		if success and info then
			QuickPlay.gtitle.Text = info.Name

			local id = placeId
			local thumbnailUrl = "https://www.roblox.com/asset-thumbnail/image?assetId="
				.. id
				.. "&width=768&height=432&format=png"
			QuickPlay.thumb.Image = thumbnailUrl
		else
			warn("Failed to get game info for", placeId)
		end

		task.delay(120, function()
			if syde and syde.ConfigEnabled then
				SaveLastGame(game.PlaceId)
			end
		end)

		QuickPlay.Resume.interact.MouseButton1Click:Connect(function()
			local lastGame = LoadLastGame()

			if lastGame and lastGame.PlaceId then
				TeleportService:Teleport(placeId)
			end
		end)
	else
		window.pages.home.Visible = false
		window.tabs.Home.homeicon.interact.Interactable = false
	end

	function opensettings()
		window.settings.Visible = true
		window.dim.Visible = true
		window.settings.tabs.ScrollingFrame.CanvasPosition = Vector2.zero

		tweenservice
			:Create(window.settings, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 390, 0, 430) })
			:Play()
		tweenservice
			:Create(window.dim, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.58 })
			:Play()
		tweenservice
			:Create(
				window.settings.UICorner,
				TweenInfo.new(0.5, Enum.EasingStyle.Quart),
				{ CornerRadius = UDim.new(0, 20) }
			)
			:Play()

		tweenservice
			:Create(window.settings, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
			:Play()
		window.settings.pages.Visible = true
		window.settings.tabs.Visible = true

		tweenservice
			:Create(
				window.settings.top.title,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 }
			)
			:Play()
		tweenservice
			:Create(
				window.settings.top.separator,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0 }
			)
			:Play()
		tweenservice
			:Create(
				window.settings.top.functions.close,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0 }
			)
			:Play()
		tweenservice
			:Create(
				window.settings.top.functions.close.ImageLabel,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ ImageTransparency = 0 }
			)
			:Play()
	end

	function closesettings()
		tweenservice
			:Create(window.settings, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 390, 0, 150) })
			:Play()
		tweenservice
			:Create(window.dim, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
			:Play()
		tweenservice
			:Create(
				window.settings.UICorner,
				TweenInfo.new(0.35, Enum.EasingStyle.Quart),
				{ CornerRadius = UDim.new(0, 90) }
			)
			:Play()

		tweenservice
			:Create(window.settings, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
			:Play()
		window.settings.pages.Visible = false
		window.settings.tabs.Visible = false

		tweenservice
			:Create(
				window.settings.top.title,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential),
				{ TextTransparency = 1 }
			)
			:Play()
		tweenservice
			:Create(
				window.settings.top.separator,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 1 }
			)
			:Play()
		tweenservice
			:Create(
				window.settings.top.functions.close,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 1 }
			)
			:Play()
		tweenservice
			:Create(
				window.settings.top.functions.close.ImageLabel,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential),
				{ ImageTransparency = 1 }
			)
			:Play()
		task.wait(0.6)
		if settingsOpen then
			return
		end
		window.settings.Visible = false
		window.dim.Visible = false
		if performanceOverlay.align then
			performanceOverlay.align()
		end
	end

	if not settingsOpen then
		closesettings()
	end

	window.top.functions.settings.interact.MouseButton1Click:Connect(function()
		if not settingsOpen then
			settingsOpen = true
			opensettings()
		end
	end)

	window.settings.top.functions.close.interact.MouseButton1Click:Connect(function()
		if settingsOpen then
			settingsOpen = false
			closesettings()
		end
	end)

	window.top.functions.mini.interact.MouseButton1Click:Connect(function()
		if not uiclosed then
			ToggleUI()
		end
	end)

	do
		local settings = {}

		local tbdata = {
			first = false,
			selected = false,
		}

		function settings:inittab(tab)
			local telement = {}
			local tdata = {
				Title = tab.Title,
			}

			local tabsContainer = window.settings.tabs.ScrollingFrame
			local pagesContainer = window.settings.pages

			local Tab = tabsContainer.tb:Clone()
			Tab.Visible = true
			Tab.Parent = tabsContainer
			Tab.Name = tdata.Title
			Tab.title.Text = tdata.Title

			local Page = pagesContainer.page:Clone()
			Page.Visible = false
			Page.Parent = pagesContainer
			Page.Name = tdata.Title

			for _, v in ipairs(Page:GetChildren()) do
				if v:IsA("Frame") then
					v:Destroy()
				end
			end

			local bgTween = TweenInfo.new(0.4, Enum.EasingStyle.Exponential)
			local textTween = TweenInfo.new(0.25, Enum.EasingStyle.Exponential)

			local function ApplyTabStyle(tabButton, selected)
				tweenservice
					:Create(tabButton, bgTween, {
						BackgroundColor3 = selected and Color3.fromRGB(31, 31, 31) or Color3.fromRGB(16, 16, 16),
					})
					:Play()

				tweenservice
					:Create(tabButton.title, textTween, {
						TextTransparency = selected and 0 or 0.6,
					})
					:Play()
			end

			if not tbdata.selectedTab then
				tbdata.selectedTab = Tab
				Page.Visible = true
				ApplyTabStyle(Tab, true)
			else
				ApplyTabStyle(Tab, false)
			end

			Tab.interact.MouseButton1Click:Connect(function()
				if tbdata.selectedTab == Tab then
					return
				end

				for _, p in ipairs(pagesContainer:GetChildren()) do
					if p:IsA("ScrollingFrame") then
						p.Visible = false
					end
				end

				for _, t in ipairs(tabsContainer:GetChildren()) do
					if t:IsA("Frame") then
						ApplyTabStyle(t, t == Tab)
					end
				end

				Page.Visible = true
				tbdata.selectedTab = Tab
			end)

			function telement:Button(Button)
				local data = {
					Title = Button.Title or "Temp Button",
					CallBack = Button.CallBack,
					Desc = Button.Description or "",
					Type = Button.Type or "Default",
					HoldTime = Button.HoldTime or 3,
				}

				local button = window.settings.pages.page.Button:Clone()
				button.Visible = true
				button.Parent = Page
				button.title.Text = data.Title
				button.Name = data.Title
				button.title.Size = UDim2.new(0, button.title.TextBounds.X + 15, 0, 35)

				local c

				c = data.CallBack

				local fOTween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)
				local fITween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)

				if data.Type == "Default" then
					button.interact.MouseButton1Down:Connect(function()
						tweenservice:Create(button.UIStroke, fOTween, { Transparency = 1 }):Play()
						tweenservice:Create(button.ImageLabel, fOTween, { ImageTransparency = 1 }):Play()
						tweenservice
							:Create(
								button.ImageLabel,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ ImageTransparency = 1 }
							)
							:Play()
					end)

					button.interact.MouseButton1Up:Connect(function()
						tweenservice:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
						tweenservice
							:Create(
								button.ImageLabel,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ ImageTransparency = 0.95 }
							)
							:Play()
					end)

					button.interact.MouseButton1Click:Connect(function()
						if data.CallBack then
							local success, errorMsg = pcall(c)
							if not success then
								syde:Report("Button '" .. button.Name .. "' callback", errorMsg)
							end
						else
							warn(`[ CallBack Missing: {button.Name} ] No Function Assigned`)
						end
					end)

					button.interact.MouseLeave:Connect(function()
						tweenservice:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
						tweenservice
							:Create(
								button.ImageLabel,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ ImageTransparency = 0.95 }
							)
							:Play()
					end)
				elseif data.Type == "Hold" then
					local HoldTime = data.HoldTime
					local Holding = false
					local TimeLeft = HoldTime
					local Complete = false

					button.ImageLabel.Image = "rbxassetid://127075195365098"
					button.ImageLabel.Rotation = 0
					button.ImageLabel.Size = UDim2.new(0, 16, 0, 16)
					button.ImageLabel.Position = UDim2.new(1, -41, 0.5, 0)

					local function CancelOperation()
						Holding = false
						TimeLeft = HoldTime
						button.title.timer.Text = tostring(HoldTime)
						tweenservice:Create(button.ImageLabel, TweenInfo.new(0.15), { ImageTransparency = 0.95 }):Play()
						tweenservice:Create(button.title.timer, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
						tweenservice
							:Create(button.UIStroke.UIGradient, TweenInfo.new(0.15), { Offset = Vector2.new(-1, 0) })
							:Play()
						Complete = false
					end

					button.interact.MouseButton1Down:Connect(function()
						Holding = true
						TimeLeft = HoldTime
						button.title.timer.Text = tostring(TimeLeft)
						tweenservice
							:Create(
								button.ImageLabel,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ ImageTransparency = 1 }
							)
							:Play()
						tweenservice
							:Create(
								button.title.timer,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ TextTransparency = 0 }
							)
							:Play()
						tweenservice
							:Create(
								button.UIStroke.UIGradient,
								TweenInfo.new(HoldTime, Enum.EasingStyle.Linear),
								{ Offset = Vector2.new(0.7, 0) }
							)
							:Play()
						tweenservice
							:Create(
								button.UIStroke,
								TweenInfo.new(1, Enum.EasingStyle.Exponential),
								{ Transparency = 0 }
							)
							:Play()

						while Holding and TimeLeft > 0 do
							TimeLeft = math.max(0, TimeLeft - runservice.Heartbeat:Wait())
							button.title.timer.Text = string.format("%.1f", TimeLeft)
						end

						if TimeLeft <= 0 then
							Complete = true

							if data.CallBack then
								local success, errorMsg = pcall(data.CallBack)
								if not success then
									syde:Report("Element callback", errorMsg)
								end
							else
								warn("[CALLBACK MISSING]: No Function Assigned To", data.Title)
							end

							tweenservice
								:Create(
									button,
									TweenInfo.new(0.34, Enum.EasingStyle.Exponential),
									{ BackgroundColor3 = Color3.fromRGB(24, 24, 24) }
								)
								:Play()
							tweenservice
								:Create(
									button.UIStroke.UIGradient,
									TweenInfo.new(0.1, Enum.EasingStyle.Linear),
									{ Offset = Vector2.new(-1, 0) }
								)
								:Play()
							task.wait(0.34)
							tweenservice
								:Create(
									button,
									TweenInfo.new(0.34, Enum.EasingStyle.Exponential),
									{ BackgroundColor3 = Color3.fromRGB(17, 17, 17) }
								)
								:Play()
						end
					end)

					button.interact.MouseButton1Up:Connect(function()
						CancelOperation()
					end)

					button.interact.MouseLeave:Connect(function()
						if Holding then
							CancelOperation()
						end
					end)
				end

				local descLabel = button:FindFirstChild("desc")

				if descLabel then
					if data.Desc and data.Desc ~= "" then
						descLabel.Text = data.Desc
						descLabel.Visible = true
						descLabel.TextWrapped = true

						local function updateSize()
							local textSize = textservice:GetTextSize(
								descLabel.Text,
								descLabel.TextSize,
								descLabel.Font,
								Vector2.new(descLabel.AbsoluteSize.X, math.huge)
							)

							local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
							local newButtonSize = UDim2.new(
								button.Size.X.Scale,
								button.Size.X.Offset,
								0,
								button.title.Size.Y.Offset + textSize.Y + 10
							)
							tweenservice
								:Create(
									button.UICorner,
									TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
									{ CornerRadius = UDim.new(0, 20) }
								)
								:Play()
							local descTween = tweenservice:Create(
								descLabel,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ Size = newDescSize }
							)
							descTween:Play()

							local buttonTween = tweenservice:Create(
								button,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ Size = newButtonSize }
							)
							buttonTween:Play()
						end

						updateSize()

						descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
					else
						descLabel.Visible = false
					end
				end
			end

			function telement:Toggle(Toggle)
				local data = {
					Title = Toggle.Title or "Temp Toggle",
					Desc = Toggle.Description or "",
					V = Toggle.Value or false,
					Config = Toggle.Config or false,
					CallBack = Toggle.CallBack,
					SFlag = Toggle.SFlag,
					SettingsConfig = true,
				}

				local toggle = window.settings.pages.page.Toggle:Clone()
				toggle.Visible = true
				toggle.Parent = Page
				toggle.title.Text = data.Title
				toggle.Name = data.Title

				local toggleConfiguration = ui.Render.ToggleConfiguration:Clone()
				toggleConfiguration.Parent = ui.Render
				toggleConfiguration.Visible = false

				toggleConfiguration.Container.KeyBind.Bind.v.Text = "None"
				tweenservice
					:Create(
						toggleConfiguration.Container.KeyBind.Bind,
						TweenInfo.new(0.5, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20, 0, 25) }
					)
					:Play()

				toggleConfiguration.BackgroundTransparency = 1
				toggleConfiguration.Container.KeyBind.Title.TextTransparency = 1
				toggleConfiguration.Container.KeyBind.Bind.BackgroundTransparency = 1
				toggleConfiguration.Container.KeyBind.Bind.v.TextTransparency = 1
				toggleConfiguration.Container.Clear.Title.TextTransparency = 1
				toggleConfiguration.Container.Clear.clear.ImageLabel.ImageTransparency = 1
				toggleConfiguration.Size = UDim2.new(0, 75, 0, 53)

				if not data.Config then
					toggle.configure:Destroy()
				end

				local toggleTween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)
				local fadeTween = TweenInfo.new(0.57, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

				local function UpdateToggleUI(state)
					local targetColor = state and syde.theme.HitBox or Color3.fromRGB(28, 28, 28)
					local strokeTransparency = state and 1 or 0
					local checkTransparency = state and 0 or 1
					local gradientTransparency = state and 0 or 1
					local glowTransparency = state and 0.7 or 1
					local textTransparency = state and 0 or 0.5

					tweenservice:Create(toggle.tog, toggleTween, { BackgroundColor3 = targetColor }):Play()

					tweenservice:Create(toggle.tog.check, toggleTween, { ImageTransparency = checkTransparency }):Play()
					tweenservice
						:Create(toggle.tog.gradfr, fadeTween, { BackgroundTransparency = gradientTransparency })
						:Play()
					tweenservice:Create(toggle.tog.glow, toggleTween, { ImageTransparency = glowTransparency }):Play()
					tweenservice:Create(toggle.tog.glow, toggleTween, { ImageColor3 = targetColor }):Play()
					tweenservice:Create(toggle.title, toggleTween, { TextTransparency = textTransparency }):Play()
				end

				UpdateToggleUI(data.V)

				toggle.interact.MouseButton1Click:Connect(function()
					data:Set(not data.V)
				end)

				local descLabel = toggle:FindFirstChild("desc")

				if descLabel then
					if data.Desc and data.Desc ~= "" then
						descLabel.Text = data.Desc
						descLabel.Visible = true
						descLabel.TextWrapped = true

						local function updateSize()
							local textSize = textservice:GetTextSize(
								descLabel.Text,
								descLabel.TextSize,
								descLabel.Font,
								Vector2.new(descLabel.AbsoluteSize.X, math.huge)
							)

							local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
							local newButtonSize = UDim2.new(
								toggle.Size.X.Scale,
								toggle.Size.X.Offset,
								0,
								toggle.title.Size.Y.Offset + textSize.Y + 10
							)
							tweenservice
								:Create(
									toggle.UICorner,
									TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
									{ CornerRadius = UDim.new(0, 20) }
								)
								:Play()
							local descTween = tweenservice:Create(
								descLabel,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ Size = newDescSize }
							)
							descTween:Play()

							local ToggleTween = tweenservice:Create(
								toggle,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ Size = newButtonSize }
							)
							ToggleTween:Play()
						end

						updateSize()

						descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
					else
						descLabel.Visible = false
					end
				end

				if data.Config then
					local State = false
					local captureConnection

					local enterTween = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)

					toggle.configure.MouseEnter:Connect(function()
						tweenservice
							:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
							:Play()
					end)

					toggle.configure.MouseLeave:Connect(function()
						tweenservice
							:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(104, 104, 104) })
							:Play()
					end)

					local function ToggleConfigOpen()
						toggleConfiguration.Visible = true
						State = true

						tweenservice:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 0 }):Play()
						tweenservice
							:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 0 })
							:Play()
						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind,
								enterTween,
								{ BackgroundTransparency = 0 }
							)
							:Play()
						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind.UIStroke,
								enterTween,
								{ Transparency = 0 }
							)
							:Play()
						tweenservice
							:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 0 })
							:Play()
						tweenservice
							:Create(
								toggleConfiguration.Container.Clear.clear.ImageLabel,
								enterTween,
								{ ImageTransparency = 0 }
							)
							:Play()
						tweenservice
							:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 0 })
							:Play()
						tweenservice
							:Create(
								toggleConfiguration,
								TweenInfo.new(0.7, Enum.EasingStyle.Quint),
								{ Size = UDim2.new(0, 174, 0, 88) }
							)
							:Play()
					end

					local function ToggleConfigClose()
						State = false
						if captureConnection then
							captureConnection:Disconnect()
							captureConnection = nil
							toggleConfiguration.Container.KeyBind.Bind.v.Text = data.Keybind and data.Keybind.Name
								or "None"
						end

						tweenservice:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 1 }):Play()
						tweenservice
							:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 1 })
							:Play()
						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind,
								enterTween,
								{ BackgroundTransparency = 1 }
							)
							:Play()
						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind.UIStroke,
								enterTween,
								{ Transparency = 1 }
							)
							:Play()
						tweenservice
							:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 1 })
							:Play()
						tweenservice
							:Create(
								toggleConfiguration.Container.Clear.clear.ImageLabel,
								enterTween,
								{ ImageTransparency = 1 }
							)
							:Play()
						tweenservice
							:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 1 })
							:Play()
						tweenservice
							:Create(
								toggleConfiguration,
								TweenInfo.new(0.7, Enum.EasingStyle.Quint),
								{ Size = UDim2.new(0, 75, 0, 53) }
							)
							:Play()

						task.wait(0.5)

						toggleConfiguration.Visible = false
					end

					local TogService
					local heldKeys = {}
					local debounce1 = false

					local function ToggleConfig()
						if debounce1 then
							return
						end
						debounce1 = true

						if not toggleConfiguration.Visible then
							TogService = runservice.RenderStepped:Connect(function()
								toggleConfiguration:TweenPosition(
									UDim2.new(
										0,
										toggle.configure.AbsolutePosition.X - 190,
										0,
										toggle.configure.AbsolutePosition.Y + toggle.configure.AbsoluteSize.Y + 65
									),
									Enum.EasingDirection.Out,
									Enum.EasingStyle.Quad,
									0.1,
									true
								)
								if not toggleConfiguration.Visible then
									TogService:Disconnect()
								end
							end)
							ToggleConfigOpen()
						else
							if TogService then
								TogService:Disconnect()
							end
							ToggleConfigClose()
						end

						task.delay(0.4, function()
							debounce1 = false
						end)
					end

					toggle.configure.MouseButton1Click:Connect(function()
						ToggleConfig()
					end)

					local function ResizeBindFrame()
						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind,
								TweenInfo.new(0.5, Enum.EasingStyle.Quint),
								{
									Size = UDim2.new(
										0,
										toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,
										0,
										25
									),
								}
							)
							:Play()
					end

					local function setKeybind(key, skipSave)
						if not key then
							toggleConfiguration.Container.KeyBind.Bind.v.Text = "None"
							ResizeBindFrame()
							data.Keybind = nil
						else
							data.Keybind = key
							data.KeybindReady = false

							tweenservice
								:Create(
									toggleConfiguration.Container.KeyBind.Bind.v,
									TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
									{ TextTransparency = 1 }
								)
								:Play()
							toggleConfiguration.Container.KeyBind.Bind.v.Text = key.Name
							tweenservice
								:Create(
									toggleConfiguration.Container.KeyBind.Bind.v,
									TweenInfo.new(1, Enum.EasingStyle.Exponential),
									{ TextTransparency = 0 }
								)
								:Play()
							ResizeBindFrame()

							task.delay(0.5, function()
								data.KeybindReady = true
							end)
						end
						if not skipSave and data.Flag and data.Save ~= false then
							if type(syde.AutoSave) == "function" then
								local saved = syde:AutoSave()
								if not saved then
									warn("[Syde Config] Could not save keybind for " .. tostring(data.Flag))
								end
							else
								SaveConfig(game and game.GameId)
							end
						end
					end
					data.SetKeybind = function(_, key, skipSave)
						return setKeybind(key, skipSave)
					end

					toggleConfiguration.Container.KeyBind.Interact.MouseButton1Click:Connect(function()
						if captureConnection then
							captureConnection:Disconnect()
						end
						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind.v,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
								{ TextTransparency = 1 }
							)
							:Play()
						task.wait(0.2)
						toggleConfiguration.Container.KeyBind.Bind.v.Text = "..."
						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind.v,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
								{ TextTransparency = 0 }
							)
							:Play()
						ResizeBindFrame()

						captureConnection = syde:AddConnection(userinput.InputBegan, function(input, processed)
							local key = getBindableKey(input)
							if not userinput:GetFocusedTextBox() and key then
								setKeybind(key)
								captureConnection:Disconnect()
								captureConnection = nil
							end
						end)
					end)

					syde:AddConnection(userinput.InputBegan, function(input, processed)
						if
							not userinput:GetFocusedTextBox()
							and data.Keybind
							and data.KeybindReady
							and matchesToggleKeybind(data.Keybind, input)
						then
							data:Set(not data.V)
						end
					end)

					local debounce2 = false

					toggleConfiguration.Container.Clear.Interact.MouseButton1Click:Connect(function()
						if debounce2 then
							return
						end
						debounce2 = true

						setKeybind(nil)

						local function blink()
							tweenservice
								:Create(
									toggleConfiguration.Container.Clear.clear.ImageLabel,
									TweenInfo.new(0.25, Enum.EasingStyle.Quint),
									{ Rotation = 13 }
								)
								:Play()
							task.wait(0.2)
							tweenservice
								:Create(
									toggleConfiguration.Container.Clear.clear.ImageLabel,
									TweenInfo.new(0.25, Enum.EasingStyle.Quint),
									{ Rotation = -13 }
								)
								:Play()
							task.wait(0.2)
							tweenservice
								:Create(
									toggleConfiguration.Container.Clear.clear.ImageLabel,
									TweenInfo.new(0.25, Enum.EasingStyle.Quint),
									{ Rotation = 0 }
								)
								:Play()
						end

						blink()

						task.delay(2, function()
							debounce2 = false
						end)
					end)

					toggleConfiguration.Container.Clear.MouseEnter:Connect(function()
						tweenservice
							:Create(
								toggleConfiguration.Container.Clear.clear,
								TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 0.9 }
							)
							:Play()
					end)

					toggleConfiguration.Container.Clear.MouseLeave:Connect(function()
						tweenservice
							:Create(
								toggleConfiguration.Container.Clear.clear,
								TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 1 }
							)
							:Play()
					end)
				end

				syde:AddConnection(syde.Comms.Event, function(p, color)
					if p == "HitBox" then
						if data.V then
							task.wait(0.5)
							toggle.tog.BackgroundColor3 = color
							toggle.tog.glow.ImageColor3 = color
						end
					end
				end)

				function data:Set(NewValue, skipSave)
					if type(NewValue) ~= "boolean" then
						return false
					end
					data.V = NewValue
					data.Value = NewValue
					UpdateToggleUI(NewValue)

					local success, errorMsg = pcall(function()
						if data.CallBack then
							data.CallBack(NewValue)
						end
					end)

					if not success then
						syde:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
					end

					if not skipSave and data.Save and data.Flag then
						SaveConfig(game and game.GameId)
					end
					return true
				end

				data.Type = "Toggle"
				data.Save = Toggle.Save ~= false
				data.Value = data.V
				local flagKey = Toggle.Flag or Toggle.SFlag or Toggle.Title
				data.Flag = flagKey
				if flagKey then
					syde.Flags[flagKey] = data
					local savedKeybind = syde.LoadedConfig and syde.LoadedConfig[flagKey .. "_Keybind"]
					local key = decodeToggleKeybind(savedKeybind)
					if data.Config and key and data.SetKeybind then
						data:SetKeybind(key, true)
					end
				end
				if data.SFlag then
					syde.SettingsFlags[data.SFlag] = data
				end

				return data
			end

			function telement:Keybind(Keybind)
				local flagKey = Keybind.Flag or Keybind.SFlag or Keybind.Title or "Keybind"
				local initialKey = Keybind.Key or Keybind.Default
				if syde.LoadedConfig and syde.LoadedConfig[flagKey] ~= nil then
					local saved = syde.LoadedConfig[flagKey]
					local success, keyEnum = pcall(function()
						return Enum.KeyCode[saved] or Enum.UserInputType[saved]
					end)
					if success and keyEnum then
						initialKey = keyEnum
					end
				end

				local data = {
					Title = Keybind.Title or "Keybind",
					Key = initialKey,
					Value = initialKey and (typeof(initialKey) == "EnumItem" and initialKey.Name or tostring(
						initialKey
					)) or "NONE",
					Desc = Keybind.Description or "",
					CallBack = Keybind.CallBack,
					WaitingForKey = false,
					Hold = false,
					Holding = false,
					Type = "Bind",
					Save = Keybind.Save ~= false,
					Flag = flagKey,
					SFlag = Keybind.SFlag,
				}

				local KeyBind = window.settings.pages.page.KeyBind:Clone()
				KeyBind.Visible = true
				KeyBind.Parent = Page
				KeyBind.title.Text = data.Title
				KeyBind.Name = data.Title

				KeyBind.Bind.v.Text = data.Key
						and (typeof(data.Key) == "EnumItem" and data.Key.Name or tostring(data.Key))
					or "NONE"
				tweenservice
					:Create(
						KeyBind.Bind,
						TweenInfo.new(0.55, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset) }
					)
					:Play()

				local holdConnection
				local holdLoop
				local keybindInputDisconnect
				local function stopHold()
					local wasActive = data.Hold or holdLoop ~= nil
					data.Hold = false
					if holdConnection then
						holdConnection:Disconnect()
						holdConnection = nil
					end
					if holdLoop then
						holdLoop:Disconnect()
						holdLoop = nil
					end
					if data.Holding and wasActive then
						local ok, failure = pcall(data.CallBack, false)
						if not ok then
							pcall(syde.Report, syde, "Keybind '" .. KeyBind.Name .. "' release callback", failure)
						end
					end
				end
				KeyBind.Destroying:Connect(function()
					data.WaitingForKey = false
					stopHold()
					if keybindInputDisconnect then
						keybindInputDisconnect()
						keybindInputDisconnect = nil
					end
					if flagKey and syde.Flags[flagKey] == data then
						syde.Flags[flagKey] = nil
					end
					if Keybind.SFlag and syde.SettingsFlags[Keybind.SFlag] == data then
						syde.SettingsFlags[Keybind.SFlag] = nil
					end
				end)

				KeyBind.interact.MouseButton1Click:Connect(function()
					KeyBind.Bind.v.Text = "..."
					tweenservice
						:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Thickness = 1 })
						:Play()
					data.WaitingForKey = true
				end)

				KeyBind.Bind.v:GetPropertyChangedSignal("TextBounds"):Connect(function()
					tweenservice
						:Create(
							KeyBind.Bind,
							TweenInfo.new(0.55, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset) }
						)
						:Play()
				end)

				local function SetKeybind(keyCode)
					if data.Hold then
						stopHold()
					end
					if keyCode and keyCode ~= Enum.KeyCode.Unknown then
						if typeof(keyCode) == "string" then
							keyCode = Enum.KeyCode[keyCode] or Enum.UserInputType[keyCode] or keyCode
						end
						data.Key = keyCode
						data.Value = typeof(keyCode) == "EnumItem" and keyCode.Name or tostring(keyCode)
						KeyBind.Bind.v.Text = data.Value
						tweenservice
							:Create(
								KeyBind.Bind.UIStroke,
								TweenInfo.new(0.25, Enum.EasingStyle.Quart),
								{ Thickness = 0 }
							)
							:Play()
						if typeof(Keybind.OnKeyChanged) == "function" then
							pcall(Keybind.OnKeyChanged, keyCode)
						end
					else
						data.Key = nil
						data.Value = "NONE"
						KeyBind.Bind.v.Text = "NONE"
					end
				end

				function data:Set(keyCode)
					SetKeybind(keyCode)
					SaveCfg(game and game.GameId)
				end

				local _, disconnectInput = syde:AddConnection(userinput.InputBegan, function(input, processed)
					if data.WaitingForKey then
						if syde:IsBindableInput(input) then
							data.WaitingForKey = false
							if input.UserInputType == Enum.UserInputType.Keyboard then
								SetKeybind(input.KeyCode)
							else
								SetKeybind(input.UserInputType)
							end
							SaveCfg(game and game.GameId)
						end
						return
					end

					if userinput:GetFocusedTextBox() then
						return
					end
					if input.KeyCode == Enum.KeyCode.Unknown then
						return
					end

					local isMatch = false
					if typeof(data.Key) == "EnumItem" then
						if data.Key.EnumType == Enum.KeyCode and input.KeyCode == data.Key then
							isMatch = true
						elseif data.Key.EnumType == Enum.UserInputType and input.UserInputType == data.Key then
							isMatch = true
						end
					end

					if isMatch then
						if data.Hold then
							return
						end
						data.Hold = true
						holdConnection = input.Changed:Connect(function(prop)
							if prop == "UserInputState" then
								local state = input.UserInputState
								if state == Enum.UserInputState.End then
									data.Hold = false
									if holdConnection then
										holdConnection:Disconnect()
										holdConnection = nil
									end
								end
							end
						end)

						local success, result = pcall(data.CallBack)
						if not data.Holding then
							if not success then
								syde:Report("Keybind '" .. KeyBind.Name .. "' callback", result)
							end
						else
							if data.Hold then
								holdLoop = runservice.RenderStepped:Connect(function()
									if not data.Hold or not KeyBind.Parent or syde._destroyed then
										stopHold()
										return
									end
									local callbackOk, callbackFailure = pcall(data.CallBack, false)
									if not callbackOk then
										pcall(
											syde.Report,
											syde,
											"Keybind '" .. KeyBind.Name .. "' hold callback",
											callbackFailure
										)
										stopHold()
									end
								end)
							end
						end
					end
				end)

				keybindInputDisconnect = disconnectInput
				data._frame = KeyBind
				data.toggle = function(self)
					KeyBind.Visible = not KeyBind.Visible
				end
				data.remove = function(self)
					KeyBind:Destroy()
				end

				if flagKey then
					syde.Flags[flagKey] = data
				end
				if Keybind.SFlag then
					syde.SettingsFlags[Keybind.SFlag] = data
				end

				return data
			end

			function telement:ColorPicker(ColorPicker)
				local data = {
					Title = ColorPicker.Title,
					Color = ColorPicker.Color,
					Color2 = ColorPicker.Color2,
					Linkable = ColorPicker.Linkable,
					Type = ColorPicker.Type or "ColorPicker",
					GradientPath = ColorPicker.GradientPath,
					CallBack = ColorPicker.CallBack,
					SFlag = ColorPicker.SFlag,
					RainbowUpdating = false,
					RainbowUpdateState = type(ColorPicker._RainbowUpdateState) == "table"
							and ColorPicker._RainbowUpdateState
						or { Updating = false },
				}

				if ColorPicker.Linkable == nil then
					ColorPicker.Linkable = true
				end
				data.Linkable = ColorPicker.Linkable

				local colorpicker = window.settings.pages.page.ColorPicker:Clone()
				colorpicker.Visible = true
				colorpicker.Parent = Page
				colorpicker.title.Text = data.Title
				colorpicker.Name = data.Title

				local isLinkable = Instance.new("BoolValue")
				isLinkable.Name = "isLinkable"
				isLinkable.Value = data.Linkable
				isLinkable.Parent = colorpicker

				local HueSat = Instance.new("Color3Value")
				HueSat.Name = "HueSat"
				HueSat.Value = data.Color
				HueSat.Parent = colorpicker

				local Open = false
				local DeBounce = false
				local State = false

				do
					local HueValues = colorpicker.HueValues

					local list = HueValues:FindFirstChildOfClass("UIListLayout")
					if list then
						list:Destroy()
					end

					local ITEMS = {
						HueValues.HEX,
						HueValues.RGB,
						HueValues.Link,
					}

					local GAP = 8
					local ITEM_HEIGHT = 30
					local ITEM_WIDTH = 120
					local HORIZONTAL_THRESHOLD = 260

					local function updateHueValuesLayout()
						if not HueValues.Visible then
							return
						end

						local width = HueValues.AbsoluteSize.X
						local horizontal = width >= HORIZONTAL_THRESHOLD

						local x, y = 0, 0
						local totalHeight = 0

						for _, item in ipairs(ITEMS) do
							item.AnchorPoint = Vector2.new(1, 0)

							if horizontal then
								item.Size = UDim2.new(0, ITEM_WIDTH, 0, ITEM_HEIGHT)
								item.Position = UDim2.new(1, -x, 0, 0)
								x += ITEM_WIDTH + GAP
								totalHeight = ITEM_HEIGHT
							else
								item.Size = UDim2.new(1, -4, 0, ITEM_HEIGHT)
								item.Position = UDim2.new(1, 0, 0, -y)
								y += ITEM_HEIGHT + GAP
								totalHeight = y
							end
						end

						HueValues.Size = UDim2.new(1, -40, 0, totalHeight)
						HueValues.Position = UDim2.new(0.5, 0, 1, -50)

						if Open then
							tweenservice
								:Create(
									colorpicker,
									TweenInfo.new(0.35, Enum.EasingStyle.Quart),
									{ Size = UDim2.new(1, -35, 0, 295 + totalHeight) }
								)
								:Play()
						end
					end

					HueValues:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateHueValuesLayout)
					colorpicker:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateHueValuesLayout)

					colorpicker:SetAttribute("UpdateHueLayout", true)
					colorpicker:GetAttributeChangedSignal("UpdateHueLayout"):Connect(updateHueValuesLayout)

					task.defer(updateHueValuesLayout)
				end

				colorpicker.color.Values.Hue.BackgroundTransparency = 1
				colorpicker.color.Values.Hue.Pin.BackgroundTransparency = 1
				colorpicker.color.Values.Hue.Pin.UIStroke.Transparency = 1
				colorpicker.color.Values.Rainbow.ImageTransparency = 1

				if data.Type == "Gradient" then
					colorpicker.color.Values.Grad.BackgroundTransparency = 1
					colorpicker.color.Values.Grad.Pin1.BackgroundTransparency = 1
					colorpicker.color.Values.Grad.Pin1.UIStroke.Transparency = 1
					colorpicker.color.Values.Grad.Pin2.BackgroundTransparency = 1
					colorpicker.color.Values.Grad.Pin2.UIStroke.Transparency = 1
				end

				colorpicker.color.SVPicker.Pin.BackgroundTransparency = 1
				colorpicker.color.SVPicker.Pin.UIStroke.Transparency = 1
				colorpicker.color.SVPicker.Brightness.BackgroundTransparency = 1
				colorpicker.color.SVPicker.Saturation.BackgroundTransparency = 1

				colorpicker.HueValues.HEX.BackgroundTransparency = 1
				colorpicker.HueValues.HEX.UIStroke.Transparency = 1
				colorpicker.HueValues.HEX.V.HEXBox.TextTransparency = 1
				colorpicker.HueValues.HEX.Copy.ImageTransparency = 1

				colorpicker.HueValues.RGB.BackgroundTransparency = 1
				colorpicker.HueValues.RGB.UIStroke.Transparency = 1
				colorpicker.HueValues.RGB.V.RGBBox.TextTransparency = 1
				colorpicker.HueValues.RGB.Copy.ImageTransparency = 1

				colorpicker.HueValues.Link.BackgroundTransparency = 1
				colorpicker.HueValues.Link.UIStroke.Transparency = 1
				colorpicker.HueValues.Link.Frame.BackgroundTransparency = 1
				colorpicker.HueValues.Link.Frame.ImageLabel.ImageTransparency = 1

				colorpicker.QuickClose.Interactable = false
				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = data.Color }
					)
					:Play()

				local recentContainer = colorpicker.color.Values.Recent
				local spacing = 5
				local frameSize = 12

				local function updateRecentLayout()
					local children = {}
					for _, child in pairs(recentContainer:GetChildren()) do
						if child:IsA("Frame") then
							table.insert(children, child)
						end
					end

					table.sort(children, function(a, b)
						return a.LayoutOrder > b.LayoutOrder
					end)

					local totalWidth = #children * frameSize + math.max(#children - 1, 0) * spacing
					local startX = recentContainer.AbsoluteSize.X - totalWidth

					for _, frame in ipairs(children) do
						tweenservice
							:Create(
								frame,
								TweenInfo.new(0.5, Enum.EasingStyle.Quart),
								{ Position = UDim2.new(0, startX, 0.8, -frame.Size.Y.Offset / 2) }
							)
							:Play()
						startX += frameSize + spacing
					end
				end

				recentContainer.ChildAdded:Connect(function(child)
					if child:IsA("Frame") then
						child.LayoutOrder = os.time()
						updateRecentLayout()
					end
				end)
				recentContainer.ChildRemoved:Connect(updateRecentLayout)
				updateRecentLayout()

				local HSV

				if data.Color then
					HSV = { data.Color:ToHSV() }
				else
					HSV = { 0, 0, 0 }
				end
				local Selected = data.Color
				local HueValue = HSV[1]

				local function TableToColor(Table)
					if type(Table) ~= "table" then
						return Table
					end
					return Color3.fromHSV(Table[1], Table[2], Table[3])
				end

				local function FormatColor(Color, format, precision)
					format = format or "RGB"
					precision = precision or 2

					local formattedColor = ""

					if format == "RGB" then
						return math.round(Color.R * 255)
							.. ","
							.. math.round(Color.G * 255)
							.. ","
							.. math.round(Color.B * 255)
					elseif format == "Hex" then
						formattedColor = string.format(
							"#%02X%02X%02X",
							math.round(Color.R * 255),
							math.round(Color.G * 255),
							math.round(Color.B * 255)
						)

						return formattedColor
					end
				end

				local SVPicker = colorpicker.color.SVPicker
				local HUESlider = colorpicker.color.Values.Hue

				SVPicker.Pin.BackgroundColor3 = data.Color
				HUESlider.Pin.BackgroundColor3 = data.Color

				local Keys
				local ExternalGradient
				local ActivePin = 1
				local GradientFrame = colorpicker.color.Values:FindFirstChild("Grad")
				local HueFrame = colorpicker.color.Values.Hue
				local DraggingPin = nil

				local function updatestuff()
					data.Color = TableToColor(HSV)
					colorpicker.color.BackgroundColor3 = data.Color
					colorpicker.color.glow.ImageColor3 = data.Color

					local newColor = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
					local newColor2 = Color3.fromHSV(HSV[1], 1, 1)

					if data.Type == "Gradient" and Keys and Keys[ActivePin] then
						Keys[ActivePin] = ColorSequenceKeypoint.new(Keys[ActivePin].Time, newColor)

						Keys[1] = ColorSequenceKeypoint.new(0, Keys[2].Value)
						Keys[4] = ColorSequenceKeypoint.new(1, Keys[3].Value)

						data.Color = Keys[2].Value
						data.Color2 = Keys[3].Value

						local seq = ColorSequence.new(Keys)
						if ExternalGradient then
							ExternalGradient.Color = seq
						end
						GradientFrame.Gradient.Color = seq

						GradientFrame.Pin1.BackgroundColor3 = data.Color
						GradientFrame.Pin2.BackgroundColor3 = data.Color2
					end

					HueSat.Value = data.Color

					tweenservice
						:Create(
							HUESlider.Pin,
							TweenInfo.new(0.1, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = newColor2 }
						)
						:Play()
					tweenservice
						:Create(
							SVPicker.Pin,
							TweenInfo.new(0.1, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = newColor }
						)
						:Play()

					tweenservice
						:Create(SVPicker.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0),
						})
						:Play()

					tweenservice
						:Create(HUESlider.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Position = UDim2.new(1 - HSV[1], 0, 0.5, 0),
						})
						:Play()

					local formattedHex = FormatColor(data.Color, "Hex")
					colorpicker.HueValues.HEX.V.HEXBox.PlaceholderText = formattedHex

					local formattedRGB = FormatColor(data.Color, "RGB", 2)
					colorpicker.HueValues.RGB.V.RGBBox.PlaceholderText = formattedRGB

					if data.CallBack then
						data.CallBack(data.Color)
					end
				end
				updatestuff()

				local newColor = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

				local oldCallback = data.CallBack
				data.CallBack = function(col)
					if data.Type ~= "Gradient" then
						if oldCallback then
							oldCallback(col)
						end
						return
					end

					table.sort(Keys, function(a, b)
						return a.Time < b.Time
					end)

					Keys[1] = ColorSequenceKeypoint.new(0, Keys[2].Value)
					Keys[4] = ColorSequenceKeypoint.new(1, Keys[3].Value)

					data.Color = Keys[2].Value
					data.Color2 = Keys[3].Value

					local seq = ColorSequence.new(Keys)
					ExternalGradient.Color = seq
					GradientFrame.Gradient.Color = seq

					if oldCallback then
						oldCallback(seq, data.Color, data.Color2)
					end
				end

				if data.Type == "Gradient" then
					HueFrame.Visible = true
					GradientFrame.Visible = true

					ExternalGradient = data.GradientPath

					local startCol = data.Color or ExternalGradient.Color.Keypoints[1].Value
					local endCol = data.Color2
						or ExternalGradient.Color.Keypoints[#ExternalGradient.Color.Keypoints].Value

					Keys = {
						ColorSequenceKeypoint.new(0, startCol),
						ColorSequenceKeypoint.new(0.2, startCol),
						ColorSequenceKeypoint.new(0.8, endCol),
						ColorSequenceKeypoint.new(1, endCol),
					}

					ActivePin = 2

					GradientFrame.Pin1.BackgroundColor3 = startCol
					GradientFrame.Pin2.BackgroundColor3 = endCol
				end

				local oldCallback = data.CallBack
				data.CallBack = function(col)
					if data.Type ~= "Gradient" then
						if oldCallback then
							oldCallback(col)
						end
						return
					end

					table.sort(Keys, function(a, b)
						return a.Time < b.Time
					end)
					Keys[1] = ColorSequenceKeypoint.new(0, Keys[1].Value)
					Keys[#Keys] = ColorSequenceKeypoint.new(1, Keys[#Keys].Value)

					local seq = ColorSequence.new(Keys)
					ExternalGradient.Color = seq
					GradientFrame.Gradient.Color = seq

					if oldCallback then
						oldCallback(seq)
					end
				end

				if data.Type == "Gradient" then
					local g = GradientFrame
					local UIS = game:GetService("UserInputService")
					local RS = game:GetService("RunService")
					local mouse = game.Players.LocalPlayer:GetMouse()
					local disconnectGradientInputEnded
					local disconnectGradientFocusReleased
					local disconnectGradientHeartbeat

					local function stopGradientDrag()
						DraggingPin = nil
						if disconnectGradientInputEnded then
							disconnectGradientInputEnded()
							disconnectGradientInputEnded = nil
						end
						if disconnectGradientFocusReleased then
							disconnectGradientFocusReleased()
							disconnectGradientFocusReleased = nil
						end
						if disconnectGradientHeartbeat then
							disconnectGradientHeartbeat()
							disconnectGradientHeartbeat = nil
						end
					end

					local function startGradientDrag()
						if disconnectGradientHeartbeat then
							return
						end
						local _, disconnectHeartbeat = syde:AddConnection(RS.Heartbeat, function()
							if not DraggingPin then
								return
							end
							local width = g.AbsoluteSize.X
							if not g.Parent or width <= 0 then
								stopGradientDrag()
								return
							end

							local relX = math.clamp((mouse.X - g.AbsolutePosition.X) / width, 0, 1)
							if DraggingPin == 2 then
								relX = math.clamp(relX, 0, Keys[3].Time - 0.01)
							elseif DraggingPin == 3 then
								relX = math.clamp(relX, Keys[2].Time + 0.01, 1)
							end

							Keys[DraggingPin] = ColorSequenceKeypoint.new(relX, Keys[DraggingPin].Value)
							updateUI()
						end)
						disconnectGradientHeartbeat = disconnectHeartbeat

						local _, disconnectInputEnded = syde:AddConnection(UIS.InputEnded, function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								stopGradientDrag()
							end
						end)
						disconnectGradientInputEnded = disconnectInputEnded

						local _, disconnectFocusReleased = syde:AddConnection(UIS.WindowFocusReleased, stopGradientDrag)
						disconnectGradientFocusReleased = disconnectFocusReleased
					end

					g.Destroying:Connect(stopGradientDrag)

					local function updateUI()
						g.Pin1.Position = UDim2.new(Keys[2].Time, 0, 0.5, 0)
						g.Pin1.BackgroundColor3 = Keys[2].Value

						g.Pin2.Position = UDim2.new(Keys[3].Time, 0, 0.5, 0)
						g.Pin2.BackgroundColor3 = Keys[3].Value

						local seq = ColorSequence.new(Keys)
						ExternalGradient.Color = seq
						g.Gradient.Color = seq
					end

					g.Pin1.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							DraggingPin = 2
							startGradientDrag()
							ActivePin = 2
							local h, s, v = Keys[2].Value:ToHSV()
							HSV[1], HSV[2], HSV[3] = h, s, v
							updatestuff()
						end
					end)

					g.Pin2.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							DraggingPin = 3
							startGradientDrag()
							ActivePin = 3
							local h, s, v = Keys[3].Value:ToHSV()
							HSV[1], HSV[2], HSV[3] = h, s, v
							updatestuff()
						end
					end)

					updateUI()
				end
				local function OpenPicker()
					Open = true
					DeBounce = true
					colorpicker.color.Values.Visible = true
					colorpicker.color.SVPicker.Visible = true

					colorpicker.HueValues.Visible = true
					colorpicker.color.Values.Recent.Visible = true

					colorpicker.interact.Interactable = false
					colorpicker.QuickClose.Interactable = true

					colorpicker.HueValues.Visible = true

					local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")
					if displayGrad then
						displayGrad.Enabled = false
					end

					colorpicker:SetAttribute("UpdateHueLayout", not colorpicker:GetAttribute("UpdateHueLayout"))

					tweenservice
						:Create(
							colorpicker.UICorner,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ CornerRadius = UDim.new(0, 20) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(0.95, Enum.EasingStyle.Quart),
							{ Size = UDim2.new(0, 1, 0, 1) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = Color3.fromRGB(35, 35, 35) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.QuickClose,
							TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()

					task.wait(0.12)
					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(0.9, Enum.EasingStyle.Quart),
							{ Size = UDim2.new(1, -40, 0, 160) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(0.9, Enum.EasingStyle.Quart),
							{ Position = UDim2.new(0.5, 0, 0, 40) }
						)
						:Play()

					tweenservice
						:Create(
							colorpicker,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = Color3.fromRGB(17, 17, 17) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker,
							TweenInfo.new(0.8, Enum.EasingStyle.Quart),
							{ Size = UDim2.new(1, -35, 0, 300) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.UICorner,
							TweenInfo.new(0.8, Enum.EasingStyle.Quart),
							{ CornerRadius = UDim.new(0, 10) }
						)
						:Play()

					tweenservice
						:Create(
							colorpicker.color.Values.Rainbow,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 0 }
						)
						:Play()

					task.wait(0.6)

					tweenservice
						:Create(
							colorpicker.color.SVPicker.Brightness,
							TweenInfo.new(2, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.SVPicker.Saturation,
							TweenInfo.new(2, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.SVPicker.Pin,
							TweenInfo.new(2, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.SVPicker.Pin.UIStroke,
							TweenInfo.new(2, Enum.EasingStyle.Exponential),
							{ Transparency = 0 }
						)
						:Play()

					task.wait(0.5)
					tweenservice
						:Create(
							colorpicker.color.Values.Hue,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Hue.Pin,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Hue.Pin.UIStroke,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ Transparency = 0 }
						)
						:Play()

					if data.Type == "Gradient" then
						tweenservice
							:Create(
								colorpicker.color.Values.Grad,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 0 }
							)
							:Play()
						tweenservice
							:Create(
								colorpicker.color.Values.Grad.Pin1,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 0 }
							)
							:Play()
						tweenservice
							:Create(
								colorpicker.color.Values.Grad.Pin1.UIStroke,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ Transparency = 0 }
							)
							:Play()
						tweenservice
							:Create(
								colorpicker.color.Values.Grad.Pin2,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 0 }
							)
							:Play()
						tweenservice
							:Create(
								colorpicker.color.Values.Grad.Pin2.UIStroke,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ Transparency = 0 }
							)
							:Play()
					end

					tweenservice
						:Create(
							colorpicker.HueValues.HEX,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0.9 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.HEX.UIStroke,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ Transparency = 0.4 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.HEX.V.HEXBox,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ TextTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.HEX.Copy,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 0 }
						)
						:Play()

					task.wait(0.09)
					tweenservice
						:Create(
							colorpicker.HueValues.RGB,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0.9 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.RGB.UIStroke,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ Transparency = 0.4 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.RGB.V.RGBBox,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ TextTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.RGB.Copy,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 0 }
						)
						:Play()
					task.wait(0.09)
					tweenservice
						:Create(
							colorpicker.HueValues.Link,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0.9 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.Link.UIStroke,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ Transparency = 0.4 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.Link.Frame,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.Link.Frame.ImageLabel,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 0 }
						)
						:Play()

					for _, v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
						if v:IsA("Frame") then
							task.wait(0.1)
							tweenservice
								:Create(
									v,
									TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
									{ BackgroundTransparency = 0 }
								)
								:Play()
						end
					end

					task.wait(0.7)
					DeBounce = false
				end

				colorpicker.interact.MouseButton1Click:Connect(function()
					if DeBounce then
						return
					end
					if not Open then
						Open = true
						OpenPicker()
					end
				end)

				colorpicker.QuickClose.hitbox.MouseEnter:Connect(function()
					tweenservice
						:Create(
							colorpicker.QuickClose,
							TweenInfo.new(0.8, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0, 70, 0, 3) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.QuickClose,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = Color3.fromRGB(255, 255, 255) }
						)
						:Play()
				end)

				colorpicker.QuickClose.hitbox.MouseLeave:Connect(function()
					tweenservice
						:Create(
							colorpicker.QuickClose,
							TweenInfo.new(0.8, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0, 60, 0, 3) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.QuickClose,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
						)
						:Play()
				end)

				local function ClosePicker()
					Open = false
					DeBounce = true
					tweenservice
						:Create(
							colorpicker.UICorner,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ CornerRadius = UDim.new(1, 0) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker,
							TweenInfo.new(0.55, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(1, -35, 0, 40) }
						)
						:Play()

					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(0.7, Enum.EasingStyle.Quart),
							{ Position = UDim2.new(1, -30, 0, 10) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(0.55, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0, 20, 0, 20) }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = data.Color }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.QuickClose,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()

					colorpicker.interact.Interactable = true
					colorpicker.QuickClose.Interactable = false

					tweenservice
						:Create(
							colorpicker.color.SVPicker.Brightness,
							TweenInfo.new(2, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.SVPicker.Saturation,
							TweenInfo.new(2, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.SVPicker.Pin,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.SVPicker.Pin.UIStroke,
							TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
							{ Transparency = 1 }
						)
						:Play()

					tweenservice
						:Create(
							colorpicker.color.Values.Hue,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Hue.Pin,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Hue.Pin.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ Transparency = 1 }
						)
						:Play()

					tweenservice
						:Create(
							colorpicker.color.Values.Rainbow,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 1 }
						)
						:Play()

					if data.Type == "Gradient" then
						tweenservice
							:Create(
								colorpicker.color.Values.Grad,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 1 }
							)
							:Play()
						tweenservice
							:Create(
								colorpicker.color.Values.Grad.Pin1,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 1 }
							)
							:Play()
						tweenservice
							:Create(
								colorpicker.color.Values.Grad.Pin1.UIStroke,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ Transparency = 1 }
							)
							:Play()
						tweenservice
							:Create(
								colorpicker.color.Values.Grad.Pin2,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 1 }
							)
							:Play()
						tweenservice
							:Create(
								colorpicker.color.Values.Grad.Pin2.UIStroke,
								TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
								{ Transparency = 1 }
							)
							:Play()
					end

					local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

					if data.Type == "Gradient" and displayGrad then
						displayGrad.Enabled = true
						displayGrad.Color = ColorSequence.new(Keys)

						tweenservice
							:Create(
								colorpicker.color,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = Color3.new(1, 1, 1) }
							)
							:Play()
					else
						if displayGrad then
							displayGrad.Enabled = false
						end
						tweenservice
							:Create(
								colorpicker.color,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = data.Color }
							)
							:Play()
					end

					tweenservice
						:Create(
							colorpicker.HueValues.RGB,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.RGB.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ Transparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.RGB.V.RGBBox,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ TextTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.RGB.Copy,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 1 }
						)
						:Play()

					tweenservice
						:Create(
							colorpicker.HueValues.HEX,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.HEX.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ Transparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.HEX.V.HEXBox,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ TextTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.HEX.Copy,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 1 }
						)
						:Play()

					tweenservice
						:Create(
							colorpicker.HueValues.Link,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.Link.UIStroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ Transparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.Link.Frame,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.HueValues.Link.Frame.ImageLabel,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 1 }
						)
						:Play()
					for _, v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
						if v:IsA("Frame") then
							tweenservice
								:Create(
									v,
									TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
									{ BackgroundTransparency = 1 }
								)
								:Play()
						end
					end
					colorpicker.HueValues.Visible = false
					task.wait(1)
					colorpicker.color.SVPicker.Visible = false
					colorpicker.color.Values.Recent.Visible = false
					task.wait(0.7)
					DeBounce = false
				end

				colorpicker.QuickClose.hitbox.MouseButton1Click:Connect(function()
					if DeBounce then
						return
					end
					if Open then
						Open = false
						ClosePicker()
					end
				end)

				for _, v in ipairs(colorpicker.HueValues:GetChildren()) do
					if v:IsA("Frame") then
						for _, v2 in ipairs(v:GetChildren()) do
							if v2:IsA("ImageLabel") then
								v2.MouseEnter:Connect(function()
									tweenservice
										:Create(
											v2,
											TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
											{ ImageColor3 = Color3.fromRGB(255, 255, 255) }
										)
										:Play()
								end)
								v2.MouseLeave:Connect(function()
									tweenservice
										:Create(
											v2,
											TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
											{ ImageColor3 = Color3.fromRGB(66, 66, 66) }
										)
										:Play()
								end)
							end
						end
					end
				end

				syde:OnClick(colorpicker.HueValues.HEX.Copy, function()
					if syde:SetClipboard(FormatColor(data.Color, "Hex")) then
						syde:FlashCopy(colorpicker.HueValues.HEX.Copy)
					end
				end)
				syde:OnClick(colorpicker.HueValues.RGB.Copy, function()
					if syde:SetClipboard(FormatColor(data.Color, "RGB", 2)) then
						syde:FlashCopy(colorpicker.HueValues.RGB.Copy)
					end
				end)

				local function AddRecentColor(newColor)
					local recentFrame = colorpicker.colorPlaceHolder:Clone()
					recentFrame.Visible = true
					recentFrame.Parent = colorpicker.color.Values.Recent
					recentFrame.BackgroundColor3 = newColor

					recentFrame.interact.MouseButton1Click:Connect(function()
						local h, s, v = newColor:ToHSV()
						if s > 0.02 then
							HSV[1] = h
						end
						HSV[2] = s
						HSV[3] = v
						updatestuff()
					end)

					recentFrame.interact.MouseEnter:Connect(function()
						tweenservice
							:Create(
								recentFrame,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint),
								{ Size = UDim2.new(0, 20, 0, 20) }
							)
							:Play()
					end)

					recentFrame.interact.MouseLeave:Connect(function()
						tweenservice
							:Create(
								recentFrame,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint),
								{ Size = UDim2.new(0, 12, 0, 12) }
							)
							:Play()
					end)

					local maxRecentColors = 10
					local recentContainer = colorpicker.color.Values.Recent

					local children = recentContainer:GetChildren()
					if #children > maxRecentColors then
						for _, child in ipairs(children) do
							if child:IsA("Frame") then
								child:Destroy()
								break
							end
						end
					end
				end

				local SV, HUE = nil, nil
				local function stopColorDrag(recordRecent)
					local wasDragging = SV ~= nil or HUE ~= nil
					if SV then
						SV:Disconnect()
						SV = nil
					end
					if HUE then
						HUE:Disconnect()
						HUE = nil
					end
					if recordRecent and wasDragging then
						AddRecentColor(data.Color)
					end
				end
				local _, disconnectColorDragInput = syde:AddConnection(userinput.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						stopColorDrag(true)
					end
				end)
				local _, disconnectColorFocus = syde:AddConnection(userinput.WindowFocusReleased, function()
					stopColorDrag(true)
				end)
				colorpicker.Destroying:Connect(function()
					stopColorDrag(false)
					disconnectColorDragInput()
					disconnectColorFocus()
				end)

				syde:AddConnection(SVPicker.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						stopColorDrag(false)
						SV = runservice.RenderStepped:Connect(function()
							local pickerSize = SVPicker.AbsoluteSize
							if pickerSize.X <= 0 or pickerSize.Y <= 0 then
								return
							end
							local mouse = game.Players.LocalPlayer:GetMouse()
							local ColorX = math.clamp(mouse.X - SVPicker.AbsolutePosition.X, 0, pickerSize.X)
								/ pickerSize.X
							local ColorY = math.clamp(mouse.Y - SVPicker.AbsolutePosition.Y, 0, pickerSize.Y)
								/ pickerSize.Y

							HSV[2] = ColorX
							HSV[3] = 1 - ColorY

							updatestuff()
						end)
					end
				end)

				syde:AddConnection(SVPicker.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and SV then
						stopColorDrag(true)
					end
				end)

				syde:AddConnection(HUESlider.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						stopColorDrag(false)
						HUE = runservice.RenderStepped:Connect(function()
							local sliderWidth = HUESlider.AbsoluteSize.X
							if sliderWidth <= 0 then
								return
							end
							local mouse = game.Players.LocalPlayer:GetMouse()
							local ColorX = math.clamp(mouse.X - HUESlider.AbsolutePosition.X, 0, sliderWidth)
								/ sliderWidth

							HSV[1] = 1 - ColorX

							updatestuff()
						end)
					end
				end)

				syde:AddConnection(HUESlider.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and HUE then
						stopColorDrag(true)
					end
				end)

				colorpicker.HueValues.HEX.V.HEXBox.FocusLost:Connect(function(Enter)
					if not Enter then
						return
					end

					local hexInput = colorpicker.HueValues.HEX.V.HEXBox.Text

					local success, result = pcall(function()
						return Color3.fromHex(hexInput)
					end)

					if success then
						local Hue, Saturation, Value = result:ToHSV()
						colorpicker.HueValues.HEX.V.HEXBox.Text = ""
						if Saturation > 0.02 then
							HSV[1] = Hue
						end
						HSV[2] = Saturation
						HSV[3] = Value
						updatestuff()
					else
						warn("Failed to convert hex to color:", result)
					end
				end)

				colorpicker.HueValues.RGB.V.RGBBox.FocusLost:Connect(function(Enter)
					if not Enter then
						return
					end

					local rgbInput = colorpicker.HueValues.RGB.V.RGBBox.Text

					local r, g, b = rgbInput:match("^(%d+),%s*(%d+),%s*(%d+)$")

					if r and g and b then
						r, g, b = tonumber(r), tonumber(g), tonumber(b)

						if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
							local color = Color3.fromRGB(r, g, b)

							local Hue, Saturation, Value = color:ToHSV()
							if Saturation > 0.02 then
								HSV[1] = Hue
							end
							HSV[2] = Saturation
							HSV[3] = Value

							colorpicker.HueValues.RGB.V.RGBBox.Text = ""
							updatestuff()
						else
							warn("RGB values must be between 0 and 255.")
						end
					else
						warn("Invalid RGB format. Please use the format 'R,G,B' (e.g., 16,16,16).")
					end
				end)

				local UserInputService = game:GetService("UserInputService")
				local TweenService = game:GetService("TweenService")
				local RunService = game:GetService("RunService")

				local linkDragging = false
				local originalPosition = UDim2.new(0.5, 0, 0, 0)
				local draggedColorPicker = nil
				local followMouseConnection
				local linkableColorPickers = {}
				local lastHoveredPicker = nil

				local function isMouseOver(guiObject)
					local mouse = game.Players.LocalPlayer:GetMouse()
					local pos = guiObject.AbsolutePosition
					local size = guiObject.AbsoluteSize
					return mouse.X >= pos.X
						and mouse.X <= pos.X + size.X
						and mouse.Y >= pos.Y
						and mouse.Y <= pos.Y + size.Y
				end

				colorpicker.HueValues.Link.Frame.interact.MouseButton1Down:Connect(function()
					linkDragging = true
					draggedColorPicker = colorpicker

					TweenService:Create(
						colorpicker.HueValues.Link.Frame,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(0, 40, 1, 0) }
					):Play()

					if followMouseConnection then
						followMouseConnection:Disconnect()
					end
					table.clear(linkableColorPickers)
					lastHoveredPicker = nil
					for _, otherPicker in pairs(Page:GetChildren()) do
						local linkable = otherPicker:IsA("Frame") and otherPicker:FindFirstChild("isLinkable")
						if linkable and linkable.Value and otherPicker ~= draggedColorPicker then
							table.insert(linkableColorPickers, otherPicker)
						end
					end
					followMouseConnection = RunService.RenderStepped:Connect(function()
						if not linkDragging then
							if followMouseConnection then
								followMouseConnection:Disconnect()
								followMouseConnection = nil
							end
							return
						end
						local mouse = game.Players.LocalPlayer:GetMouse()
						colorpicker.HueValues.Link.Frame.Position = UDim2.new(
							0,
							mouse.X - colorpicker.AbsolutePosition.X - 50,
							0,
							mouse.Y - colorpicker.AbsolutePosition.Y - 260
						)

						local hoveredPicker
						for _, otherPicker in ipairs(linkableColorPickers) do
							if otherPicker.Parent and isMouseOver(otherPicker) then
								hoveredPicker = otherPicker
								break
							end
						end
						if hoveredPicker ~= lastHoveredPicker then
							local previousStroke = lastHoveredPicker and lastHoveredPicker:FindFirstChild("UIStroke")
							local hoveredStroke = hoveredPicker and hoveredPicker:FindFirstChild("UIStroke")
							if previousStroke then
								previousStroke.Transparency = 1
							end
							if hoveredStroke then
								hoveredStroke.Transparency = 0
							end
							lastHoveredPicker = hoveredPicker
						end
					end)
				end)

				local _, disconnectLinkInput = syde:AddConnection(UserInputService.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and linkDragging then
						linkDragging = false
						if followMouseConnection then
							followMouseConnection:Disconnect()
							followMouseConnection = nil
						end
						if lastHoveredPicker then
							local stroke = lastHoveredPicker:FindFirstChild("UIStroke")
							if stroke then
								stroke.Transparency = 1
							end
							lastHoveredPicker = nil
						end
						table.clear(linkableColorPickers)
						local foundTarget = false

						for _, otherPicker in pairs(Page:GetChildren()) do
							if
								otherPicker:IsA("Frame")
								and otherPicker:FindFirstChild("isLinkable")
								and otherPicker.isLinkable.Value
							then
								if isMouseOver(otherPicker) and otherPicker ~= draggedColorPicker then
									otherPicker.HueSat.Value = draggedColorPicker.HueSat.Value
									updatestuff()
									foundTarget = true
									TweenService:Create(
										colorpicker.HueValues.Link.Frame,
										TweenInfo.new(0.3, Enum.EasingStyle.Quint),
										{ Position = originalPosition }
									):Play()

									TweenService:Create(
										otherPicker.UIStroke,
										TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
										{ Transparency = 1 }
									):Play()

									TweenService:Create(
										colorpicker.HueValues.Link.Frame,
										TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
										{ Size = UDim2.new(1, 0, 1, 0) }
									):Play()
									break
								end
							end
						end

						if not foundTarget then
							TweenService:Create(
								colorpicker.HueValues.Link.Frame,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
								{ Size = UDim2.new(1, 0, 1, 0) }
							):Play()
							TweenService:Create(
								colorpicker.HueValues.Link.Frame,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint),
								{ Position = originalPosition }
							):Play()
						end
					end
				end)
				colorpicker.Destroying:Connect(function()
					stopColorDrag(false)
					if disconnectColorFocus then
						disconnectColorFocus()
					end
					if colorDragInputConnection and colorDragInputConnection.Connected then
						colorDragInputConnection:Disconnect()
					end
					linkDragging = false
					if followMouseConnection then
						followMouseConnection:Disconnect()
						followMouseConnection = nil
					end
					if lastHoveredPicker then
						local stroke = lastHoveredPicker:FindFirstChild("UIStroke")
						if stroke then
							stroke.Transparency = 1
						end
						lastHoveredPicker = nil
					end
					table.clear(linkableColorPickers)
					if disconnectLinkInput then
						disconnectLinkInput()
					end
				end)

				local function updateColorPicker()
					local Hue, Saturation, Value = HueSat.Value:ToHSV()

					if Saturation > 0.02 then
						HSV[1] = Hue
					end
					HSV[2] = Saturation
					HSV[3] = Value

					updatestuff()
				end

				HueSat.Changed:Connect(updateColorPicker)

				local isRainbowEnabled = false
				local rainbowGeneration = 0
				local rainbowUpdateDepth = 0
				local function updateRainbowColor()
					rainbowUpdateDepth += 1
					data.RainbowUpdating = true
					data.RainbowUpdateState.Updating = true
					local ok, failure = pcall(updatestuff)
					rainbowUpdateDepth -= 1
					data.RainbowUpdating = rainbowUpdateDepth > 0
					data.RainbowUpdateState.Updating = data.RainbowUpdating
					return ok, failure
				end

				local function SetRainbowEffect(enabled, skipSave)
					enabled = enabled == true
					if isRainbowEnabled == enabled then
						return
					end
					isRainbowEnabled = enabled
					rainbowGeneration += 1
					local generation = rainbowGeneration
					data.Rainbow = enabled
					if isRainbowEnabled then
						tweenservice
							:Create(
								colorpicker.color.Values.Rainbow,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
								{ ImageColor3 = Color3.fromRGB(255, 255, 255) }
							)
							:Play()
						task.spawn(function()
							local lastUpdate = os.clock()
							while isRainbowEnabled and rainbowGeneration == generation and colorpicker.Parent do
								local now = os.clock()
								HueValue = (HueValue + math.min(now - lastUpdate, 0.2) * 0.12) % 1
								lastUpdate = now
								HSV[1] = HueValue
								local ok, failure = updateRainbowColor()
								if not ok then
									warn("[Syde RGB] " .. tostring(failure))
									break
								end
								task.wait(0.08)
							end
						end)
					else
						tweenservice
							:Create(
								colorpicker.color.Values.Rainbow,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
								{ ImageColor3 = Color3.fromRGB(62, 62, 62) }
							)
							:Play()
						syde:SaveThemeCfg()
					end
					if not skipSave then
						syde.LoadedConfig = syde.LoadedConfig or {}
						if data.Flag then
							syde.LoadedConfig[data.Flag .. "_Rainbow"] = enabled
						end
						SaveCfg(game and game.GameId)
					end
				end

				function data:SetRainbow(enabled, skipSave)
					SetRainbowEffect(enabled, skipSave)
				end
				colorpicker.color.Values.Rainbow.MouseButton1Click:Connect(function()
					data:SetRainbow(not data.Rainbow)
				end)
				colorpicker.Destroying:Connect(function()
					isRainbowEnabled = false
					rainbowGeneration += 1
				end)

				function data:Set(RGBColor)
					if typeof(RGBColor) == "table" then
						RGBColor = UnpackColor(RGBColor)
					end

					data.Color = RGBColor
					data.Value = RGBColor

					local h, s, v = RGBColor:ToHSV()
					HSV[1], HSV[2], HSV[3] = h, s, v
					updatestuff()
				end

				data.Type = "Colorpicker"
				data.Save = ColorPicker.Save ~= false
				data.Value = data.Color
				local flagKey = ColorPicker.Flag or ColorPicker.SFlag or ColorPicker.Title
				data.Flag = flagKey
				if flagKey then
					syde.Flags[flagKey] = data
					if syde.LoadedConfig and syde.LoadedConfig[flagKey .. "_Rainbow"] == true then
						data:SetRainbow(true, true)
					end
				end
				if data.SFlag then
					syde.SettingsFlags[data.SFlag] = data
				end

				return data
			end

			function telement:Dropdown(Dropdown)
				local data = {
					Title = Dropdown.Title or "Temp Dropdown",
					Options = Dropdown.Options or {},
					StarterOption = Dropdown.StarterOption,
					PlaceHolder = Dropdown.PlaceHolder or "Select Option...",
					Multi = Dropdown.Multi or false,
					CallBack = Dropdown.CallBack,
				}

				local dropdown = window.settings.pages.page.Dropdown:Clone()
				dropdown.Visible = true
				dropdown.Parent = Page
				dropdown.title.Text = data.Title
				dropdown.Name = data.Title
				dropdown.dropholder.drop.Container.Option.Visible = false
				dropdown.dropholder.drop.Container.Visible = false
				tweenservice
					:Create(
						dropdown.dropholder.drop.Container,
						TweenInfo.new(1, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(0.33, -20, 0.576, -75) }
					)
					:Play()
				dropdown.dropholder.drop.selected.Text = data.PlaceHolder

				local DropOpen = false
				local DeBounce = false
				local OptionButton = dropdown.dropholder.drop.Container.Option
				local SelectedOptions = {}
				local SelectedOrder = {}

				local function UpdateCustomLayout()
					local yOffset = 0
					for _, option in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
						if option:IsA("Frame") and option.Visible then
							tweenservice
								:Create(
									option,
									TweenInfo.new(0.5, Enum.EasingStyle.Quint),
									{ Position = UDim2.new(0, 0, 0, yOffset) }
								)
								:Play()
							yOffset = yOffset + option.Size.Y.Offset + 7
						end
					end
				end

				local function OpenDrop()
					DropOpen = true
					dropdown.dropholder.drop.Container.Visible = true
					dropdown.dropholder.drop.search.Visible = true

					tweenservice
						:Create(
							dropdown,
							TweenInfo.new(1.34, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(1, -35, 0, 300) }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.UICorner,
							TweenInfo.new(0.5, Enum.EasingStyle.Quint),
							{ CornerRadius = UDim.new(0, 20) }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.Container,
							TweenInfo.new(1, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(1, -20, 1, -75) }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.v0,
							TweenInfo.new(1.34, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.down,
							TweenInfo.new(0.35, Enum.EasingStyle.Quint),
							{ Rotation = 180 }
						)
						:Play()

					tweenservice
						:Create(
							dropdown.dropholder.drop.search,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0.65 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.search.UIStroke,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ Transparency = 0.4 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.search.TextBox,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ TextTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.search.ImageLabel,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 0.9 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.search.icon,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 0.85 }
						)
						:Play()
				end

				local function CloseDrop()
					DropOpen = false
					tweenservice
						:Create(dropdown, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 95) })
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.UICorner,
							TweenInfo.new(1, Enum.EasingStyle.Quint),
							{ CornerRadius = UDim.new(1, 0) }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.Container,
							TweenInfo.new(1, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0.33, -20, 0.576, -75) }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.v0,
							TweenInfo.new(1.34, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.down,
							TweenInfo.new(0.35, Enum.EasingStyle.Quint),
							{ Rotation = 0 }
						)
						:Play()

					tweenservice
						:Create(
							dropdown.dropholder.drop.search,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.search.UIStroke,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ Transparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.search.TextBox,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ TextTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.search.ImageLabel,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							dropdown.dropholder.drop.search.icon,
							TweenInfo.new(1, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 1 }
						)
						:Play()

					task.wait(0.6)
					dropdown.dropholder.drop.Container.Visible = false
					dropdown.dropholder.drop.search.Visible = false
				end

				local removeChipCallbacks = {}
				local headerHitbox = Instance.new("TextButton")
				headerHitbox.Name = "HeaderHitbox"
				headerHitbox.Text = ""
				headerHitbox.BackgroundTransparency = 1
				headerHitbox.AutoButtonColor = false
				headerHitbox.Size = UDim2.new(1, 0, 0, 42)
				headerHitbox.ZIndex = dropdown.dropholder.drop.down.ZIndex + 2
				headerHitbox.Parent = dropdown.dropholder.drop
				headerHitbox.Activated:Connect(function(input)
					local chip = selectedChipAtPosition(dropdown.dropholder.drop.selectContainer.ScrollingFrame, input)
					if chip and removeChipCallbacks[chip] then
						removeChipCallbacks[chip]()
						return
					end
					if DeBounce then
						return
					end
					DeBounce = true

					if DropOpen then
						CloseDrop()
					else
						OpenDrop()
					end

					task.delay(1.2, function()
						DeBounce = false
					end)
				end)

				local function AddToSelected(option)
					if not SelectedOptions[option] then
						SelectedOptions[option] = true

						local originalIndex
						for i, opt in ipairs(data.Options) do
							if opt == option then
								originalIndex = i
								break
							end
						end

						local insertIndex = 1
						for i, selected in ipairs(SelectedOrder) do
							local selectedIndex = table.find(data.Options, selected)
							if selectedIndex and selectedIndex < originalIndex then
								insertIndex = i + 1
							else
								break
							end
						end
						table.insert(SelectedOrder, insertIndex, option)
					end
				end

				local function RemoveFromSelected(option)
					if SelectedOptions[option] then
						SelectedOptions[option] = nil
						for i = #SelectedOrder, 1, -1 do
							if SelectedOrder[i] == option then
								table.remove(SelectedOrder, i)
								break
							end
						end
					end

					local selectedContainer = dropdown.dropholder.drop.selectContainer.ScrollingFrame
					for _, child in ipairs(selectedContainer:GetChildren()) do
						if child:IsA("Frame") and child.Name == option then
							child:Destroy()
							break
						end
					end
				end

				local function UpdateSelectedText()
					local selectedContainer = dropdown.dropholder.drop.selectContainer.ScrollingFrame
					local placeholderText = dropdown.dropholder.drop.selected
					data.Value = data.Multi and table.clone(SelectedOrder) or SelectedOrder[1] or data.StarterOption
					selectedContainer.Visible = data.Multi
					dropdown.dropholder.drop.selected.Visible = false

					if data.Multi then
						if #SelectedOrder == 0 then
							placeholderText.Visible = true
							selectedContainer.Visible = false
							return
						end

						for _, option in ipairs(SelectedOrder) do
							if not selectedContainer:FindFirstChild(option) then
								local optionGroup = selectedContainer.result:Clone()
								optionGroup.Visible = true
								optionGroup.Name = option
								optionGroup.TextLabel.Text = option
								local removeButton = optionGroup:FindFirstChild("X")
								if removeButton and removeButton:IsA("GuiButton") then
									removeButton.ZIndex = headerHitbox.ZIndex + 1
									removeButton.Active = true
								end

								removeChipCallbacks[option] = function()
									if not SelectedOptions[option] then
										return
									end
									RemoveFromSelected(option)
									UpdateSelectedText()

									for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
										if opt:IsA("Frame") and opt.Name == option then
											tweenservice
												:Create(
													opt,
													TweenInfo.new(1, Enum.EasingStyle.Exponential),
													{ BackgroundTransparency = 0 }
												)
												:Play()
											tweenservice
												:Create(
													opt,
													TweenInfo.new(1, Enum.EasingStyle.Exponential),
													{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
												)
												:Play()
											tweenservice
												:Create(
													opt.Title,
													TweenInfo.new(1, Enum.EasingStyle.Exponential),
													{ TextTransparency = 0 }
												)
												:Play()
											tweenservice
												:Create(
													opt.UIStroke,
													TweenInfo.new(1, Enum.EasingStyle.Exponential),
													{ Transparency = 0.5 }
												)
												:Play()
											tweenservice
												:Create(
													opt.ImageLabel,
													TweenInfo.new(1, Enum.EasingStyle.Exponential),
													{ ImageTransparency = 0.9 }
												)
												:Play()
										end
									end

									if data.CallBack then
										data.CallBack(SelectedOrder)
									end
								end
								optionGroup.X.Activated:Connect(removeChipCallbacks[option])

								optionGroup.Parent = selectedContainer

								task.defer(function()
									local padding = 40
									local textWidth = optionGroup.TextLabel.TextBounds.X
									local totalWidth = textWidth + padding

									optionGroup.TextLabel.Size = UDim2.new(0, textWidth, 1, 0)

									tweenservice
										:Create(
											optionGroup,
											TweenInfo.new(0.67, Enum.EasingStyle.Exponential),
											{ Size = UDim2.new(0, totalWidth, 0, 20) }
										)
										:Play()
								end)
							end
						end
					else
						dropdown.dropholder.drop.selected.Visible = true
						if #SelectedOrder > 0 then
							dropdown.dropholder.drop.selected.Text = SelectedOrder[1]
						else
							dropdown.dropholder.drop.selected.Text = data.PlaceHolder
						end
					end
				end

				dropdown.dropholder.drop.search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
					local searchText = dropdown.dropholder.drop.search.TextBox.Text:lower()

					for _, option in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
						if option:IsA("Frame") and option:FindFirstChild("Title") then
							local optionText = option.Title.Text:lower()
							local isTemplate = option.Name == "Option"
							local shouldShow = not isTemplate
								and (
									searchText == ""
									or optionText:find(searchText, 1, true)
									or SelectedOptions[option.Title.Text]
								)

							if shouldShow then
								option.Visible = true
								if SelectedOptions[option.Title.Text] then
									tweenservice
										:Create(
											option,
											TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
											{ BackgroundTransparency = 0 }
										)
										:Play()
									tweenservice
										:Create(
											option,
											TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
											{ BackgroundColor3 = Color3.fromRGB(39, 39, 39) }
										)
										:Play()
									tweenservice
										:Create(
											option.Title,
											TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
											{ TextTransparency = 0 }
										)
										:Play()
									tweenservice
										:Create(
											option.UIStroke,
											TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
											{ Transparency = 1 }
										)
										:Play()
									tweenservice
										:Create(
											option.ImageLabel,
											TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
											{ ImageTransparency = 0 }
										)
										:Play()
								else
									tweenservice
										:Create(
											option,
											TweenInfo.new(1, Enum.EasingStyle.Exponential),
											{ BackgroundTransparency = 0 }
										)
										:Play()
									tweenservice
										:Create(
											option,
											TweenInfo.new(1, Enum.EasingStyle.Exponential),
											{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
										)
										:Play()
									tweenservice
										:Create(
											option.Title,
											TweenInfo.new(1, Enum.EasingStyle.Exponential),
											{ TextTransparency = 0 }
										)
										:Play()
									tweenservice
										:Create(
											option.UIStroke,
											TweenInfo.new(1, Enum.EasingStyle.Exponential),
											{ Transparency = 0.5 }
										)
										:Play()
									tweenservice
										:Create(
											option.ImageLabel,
											TweenInfo.new(1, Enum.EasingStyle.Exponential),
											{ ImageTransparency = 0.9 }
										)
										:Play()
								end
							else
								tweenservice
									:Create(
										option,
										TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
										{ BackgroundTransparency = 1 }
									)
									:Play()
								tweenservice
									:Create(
										option,
										TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
										{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
									)
									:Play()
								tweenservice
									:Create(
										option.Title,
										TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
										{ TextTransparency = 1 }
									)
									:Play()
								tweenservice
									:Create(
										option.UIStroke,
										TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
										{ Transparency = 1 }
									)
									:Play()
								tweenservice
									:Create(
										option.ImageLabel,
										TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
										{ ImageTransparency = 1 }
									)
									:Play()
								option.Visible = false
							end
						end
					end

					UpdateCustomLayout()
				end)

				local function SetDropdownOptions()
					local starterSet = false
					for _, OptionText in ipairs(data.Options) do
						local option = OptionButton:Clone()
						option.Title.Text = OptionText
						option.Parent = dropdown.dropholder.drop.Container
						option.Visible = true
						option.Name = OptionText
						option.Interact.Size = UDim2.fromScale(1, 1)
						option.Interact.Position = UDim2.fromOffset(0, 0)
						option.Interact.ZIndex = option.ZIndex + 2

						local isStarter = data.StarterOption == OptionText
						if data.Multi and type(data.StarterOption) == "table" then
							isStarter = table.find(data.StarterOption, OptionText) ~= nil
						end
						if isStarter and (data.Multi or not starterSet) then
							starterSet = true
							dropdown.dropholder.drop.selected.Text = OptionText
							if data.Multi then
								AddToSelected(OptionText)
							else
								SelectedOptions = { [OptionText] = true }
								SelectedOrder = { OptionText }
							end

							tweenservice
								:Create(option, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(39, 39, 39) })
								:Play()
							tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0 }):Play()
						end

						option.Interact.Activated:Connect(function()
							if data.Multi then
								if SelectedOptions[OptionText] then
									RemoveFromSelected(OptionText)
									tweenservice
										:Create(
											option,
											TweenInfo.new(0.3),
											{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
										)
										:Play()
									tweenservice
										:Create(option.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0.9 })
										:Play()
								else
									AddToSelected(OptionText)
									tweenservice
										:Create(
											option,
											TweenInfo.new(0.3),
											{ BackgroundColor3 = Color3.fromRGB(39, 39, 39) }
										)
										:Play()
									tweenservice
										:Create(option.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0 })
										:Play()
								end
								data.Value = table.clone(SelectedOrder)

								if data.CallBack then
									data.CallBack(SelectedOrder)
								end
							else
								dropdown.dropholder.drop.selected.Text = OptionText

								SelectedOptions = { [OptionText] = true }
								SelectedOrder = { OptionText }
								data.Value = OptionText

								for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
									if opt:IsA("Frame") then
										tweenservice
											:Create(
												opt,
												TweenInfo.new(0.3),
												{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
											)
											:Play()
										tweenservice
											:Create(opt.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0.9 })
											:Play()
									end
								end

								tweenservice
									:Create(
										option,
										TweenInfo.new(0.3),
										{ BackgroundColor3 = Color3.fromRGB(39, 39, 39) }
									)
									:Play()
								tweenservice
									:Create(option.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0 })
									:Play()

								if data.CallBack then
									data.CallBack(OptionText)
								end

								CloseDrop()
							end

							UpdateSelectedText()
						end)
					end

					if not starterSet then
						dropdown.dropholder.drop.selected.Text = data.PlaceHolder
					end

					UpdateSelectedText()
					UpdateCustomLayout()
				end

				SetDropdownOptions()

				function data:GetSelected()
					return data.Multi and table.clone(SelectedOrder) or SelectedOrder[1]
				end

				function data:SetOptions(newOptions, starter)
					data.Options = newOptions or {}
					data.StarterOption = starter
					for _, child in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
						if child:IsA("Frame") and child.Name ~= "Option" then
							child:Destroy()
						end
					end
					SelectedOptions = {}
					SelectedOrder = {}
					dropdown.dropholder.drop.selected.Text = data.PlaceHolder
					SetDropdownOptions()
				end

				return data
			end

			function telement:Slider(Slider)
				local data = {
					Title = Slider.Title,
					Desc = Slider.Description,
					Sliders = Slider.Sliders,
				}

				local slider = window.settings.pages.page.Slider:Clone()
				slider.Visible = true
				slider.Parent = Page
				slider.title.Text = data.Title
				slider.Name = data.Title
				slider.slideholder.slider.Visible = false

				for _, Options in ipairs(data.Sliders) do
					local Slider = window.settings.pages.page.Slider.slideholder.slider:Clone()

					Options = {
						Title = Options.Title or "Slider",
						Increment = Options.Increment or 1,
						Range = Options.Range or { 0, 100 },
						StarterValue = Options.StarterValue or 16,
						CallBack = Options.CallBack,
						SFlag = Options.SFlag,
						ShowTicks = Options.ShowTicks == true,
						SettingsConfig = true,
					}
					Options = normalizeSliderOptions(Options)

					Slider.Name = Options.Title
					Slider.Title.Text = Options.Title
					Slider.slide.Ticks.Visible = Options.ShowTicks
					Options.Value = Options.StarterValue
					local slideSize = Slider.slide.Size
					Slider.slide.Size =
						UDim2.new(slideSize.X.Scale, slideSize.X.Offset, slideSize.Y.Scale, slideSize.Y.Offset + 4)
					Slider.slide.Interact.Size = UDim2.new(1, 0, 1, 16)
					Slider.slide.Interact.Position = UDim2.new(0, 0, 0, -8)
					Slider.Size = UDim2.new(
						Slider.Size.X.Scale,
						Slider.Size.X.Offset,
						Slider.Size.Y.Scale,
						Slider.Size.Y.Offset + 6
					)
					local dragging = false
					local activeTouch = nil
					local sliderConnections = {}
					local function trackSliderConnection(signal, callback)
						local _, disconnect = syde:AddConnection(signal, callback)
						table.insert(sliderConnections, disconnect)
					end
					local function cleanupSlider()
						dragging = false
						activeTouch = nil
						for index = #sliderConnections, 1, -1 do
							sliderConnections[index]()
							sliderConnections[index] = nil
						end
						syde:removeLoadTween(Slider.slide.slideframe)
					end
					Slider.Destroying:Connect(cleanupSlider)
					Slider.Visible = true
					Slider.Parent = slider.slideholder

					local SliderPosition
					if Options.StarterValue <= Options.Range[1] then
						SliderPosition = 0
					elseif Options.StarterValue >= Options.Range[2] then
						SliderPosition = 1
					else
						local range = Options.Range[2] - Options.Range[1]
						SliderPosition = (Options.StarterValue - Options.Range[1]) / range
					end

					Slider.slide.slideframe:TweenSize(
						UDim2.new(SliderPosition, 0, 1, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quint,
						0.5,
						true
					)

					syde:registerLoadTween(
						Slider.slide.slideframe,
						{ Size = UDim2.new(SliderPosition, 0, 1, 0) },
						{ Size = UDim2.new(0, 100, 1, 0) },
						TweenInfo.new(0.85, Enum.EasingStyle.Quint)
					)

					syde:replayLoadTweens(Slider.slide.slideframe)

					local decimalPlaces = syde:DecimalPlaces(Options.Increment)
					Slider.v.Text = string.format(
						"<font size='14'>%."
							.. decimalPlaces
							.. "f</font><font color='#434343'>/%."
							.. decimalPlaces
							.. "f</font>",
						Options.StarterValue,
						Options.Range[2]
					)

					local function BuildTicks(slide, options)
						local ticksFrame = slide:FindFirstChild("Ticks")
						if not ticksFrame then
							warn("❌ Missing Slider.slide.Ticks")
							return
						end

						local template = ticksFrame:FindFirstChild("tick")
						if not template then
							warn("❌ Missing Tick template inside Ticks")
							return
						end

						local min, max = options.Range[1], options.Range[2]
						local increment = options.Increment
						local range = max - min

						if range <= 0 or increment <= 0 then
							warn("❌ Invalid range/increment", range, increment)
							return
						end

						local tickCount = math.floor(range / increment) + 1
						if tickCount < 2 then
							return
						end

						task.wait()

						local width = ticksFrame.AbsoluteSize.X
						local height = ticksFrame.AbsoluteSize.Y

						local spacing = width / (tickCount - 1)

						local existingTicks = {}
						for _, child in ipairs(ticksFrame:GetChildren()) do
							if child:IsA("Frame") and child ~= template then
								table.insert(existingTicks, child)
							end
						end

						for i = 0, tickCount - 1 do
							local tick = existingTicks[i + 1] or template:Clone()
							tick.Visible = true
							tick.AnchorPoint = Vector2.new(0.5, 0.5)
							tick.BorderSizePixel = 0

							tick.Parent = ticksFrame

							local finalPos = UDim2.fromOffset(i * spacing, height / 1.5)
							tweenservice
								:Create(tick, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
									Position = finalPos,
									BackgroundTransparency = 0.85,
								})
								:Play()
						end

						for i = tickCount + 1, #existingTicks do
							existingTicks[i]:Destroy()
						end
					end

					if Options.ShowTicks and Options.Increment > 4 then
						if not Slider.slide.Ticks:FindFirstChild("_ResizeConnection") then
							local pendingTickRefresh = false
							local conn = Slider.slide.Ticks:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
								if resizing then
									if pendingTickRefresh then
										return
									end
									pendingTickRefresh = true
									task.spawn(function()
										repeat
											task.wait(0.1)
										until not resizing or not Slider.slide.Ticks.Parent
										pendingTickRefresh = false
										if Slider.slide.Ticks.Parent then
											BuildTicks(Slider.slide, Options)
										end
									end)
									return
								end
								BuildTicks(Slider.slide, Options)
							end)

							local marker = Instance.new("BoolValue")
							marker.Name = "_ResizeConnection"
							marker.Parent = Slider.slide.Ticks
							marker:GetPropertyChangedSignal("Parent"):Connect(function()
								if not marker.Parent then
									conn:Disconnect()
								end
							end)
						end
					end

					local function UpdateSlider(x)
						if dragging then
							local sliderStart = Slider.slide.AbsolutePosition.X
							local sliderWidth = Slider.slide.AbsoluteSize.X
							local range = Options.Range[2] - Options.Range[1]
							local increment = tonumber(Options.Increment)
							if
								sliderWidth <= 0
								or range ~= range
								or range <= 0
								or range == math.huge
								or not increment
								or increment ~= increment
								or increment <= 0
								or increment == math.huge
							then
								return
							end
							local sliderPosition = (x - sliderStart) / sliderWidth
							sliderPosition = math.clamp(sliderPosition, 0, 1)

							local newValue = Options.Range[1] + sliderPosition * range
							newValue = math.floor((newValue - Options.Range[1]) / increment + 0.5) * increment
								+ Options.Range[1]
							newValue = syde:RoundTo(newValue, syde:DecimalPlaces(Options.Increment))

							local snapPosition = (newValue - Options.Range[1]) / range
							Slider.slide.slideframe:TweenSize(
								UDim2.new(snapPosition, 0, 1, 0),
								Enum.EasingDirection.Out,
								Enum.EasingStyle.Quint,
								0.55,
								true
							)

							local decimalPlaces = syde:DecimalPlaces(Options.Increment)
							Slider.v.Text = string.format(
								"<font size='14'>%."
									.. decimalPlaces
									.. "f</font><font color='#434343'>/%."
									.. decimalPlaces
									.. "f</font>",
								newValue,
								Options.Range[2]
							)

							tweenservice
								:Create(
									Slider.Title,
									TweenInfo.new(0.55, Enum.EasingStyle.Exponential),
									{ TextTransparency = 0 }
								)
								:Play()

							if type(Options.CallBack) == "function" then
								local success, errorMsg = pcall(function()
									Options.CallBack(newValue)
								end)
								if not success then
									syde:Report("Slider '" .. Slider.Name .. "' callback", errorMsg)
								end
							end

							Options.StarterValue = newValue
							Options.Value = newValue
						end
					end

					Slider.slide.Interact.MouseButton1Down:Connect(function()
						dragging = true
					end)
					Slider.slide.Interact.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Touch and not activeTouch then
							activeTouch = input
							dragging = true
							UpdateSlider(input.Position.X)
						end
					end)

					Slider.slide.Interact.MouseButton1Up:Connect(function()
						dragging = false
					end)

					trackSliderConnection(userinput.InputEnded, function(input, processed)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input == activeTouch then
							dragging = false
							activeTouch = nil
							tweenservice
								:Create(
									Slider.Title,
									TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
									{ TextTransparency = 0.6 }
								)
								:Play()
						end
					end)

					trackSliderConnection(userinput.InputChanged, function(input)
						if
							dragging
							and (
								(activeTouch and input == activeTouch)
								or (not activeTouch and input.UserInputType == Enum.UserInputType.MouseMovement)
							)
						then
							UpdateSlider(input.Position.X)
						end
					end)

					syde:SetSliderGradient(Slider.slide.slideframe, syde.theme.HitBox)
					Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = syde.theme.HitBox
					Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = syde.theme.HitBox
					Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = syde.theme.HitBox
					slider.slideholder.Size =
						UDim2.new(1, -30, 0, slider.slideholder.UIListLayout.AbsoluteContentSize.Y)
					local ss = slider.slideholder.UIListLayout.AbsoluteContentSize.Y
					slider.Size = UDim2.new(1, -35, 0, ss + 20)

					trackSliderConnection(syde.Comms.Event, function(p, color)
						if p == "HitBox" then
							syde:SetSliderGradient(Slider.slide.slideframe, color)
							Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = color
							Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = color
							Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = color
						end
					end)

					function Options:Set(NewVal, skipSave)
						local range = Options.Range[2] - Options.Range[1]
						NewVal = tonumber(NewVal)
						if not isFiniteNumber(NewVal) then
							NewVal = Options.StarterValue
						end
						NewVal = math.clamp(NewVal, Options.Range[1], Options.Range[2])

						NewVal = math.floor((NewVal - Options.Range[1]) / Options.Increment + 0.5) * Options.Increment
							+ Options.Range[1]
						NewVal = syde:RoundTo(NewVal, syde:DecimalPlaces(Options.Increment))
						NewVal = math.clamp(NewVal, Options.Range[1], Options.Range[2])

						local sliderPosition = (NewVal - Options.Range[1]) / range

						Slider.slide.slideframe:TweenSize(
							UDim2.new(sliderPosition, 0, 1, 0),
							Enum.EasingDirection.Out,
							Enum.EasingStyle.Quint,
							0.55,
							true
						)

						syde:registerLoadTween(
							Slider.slide.slideframe,
							{ Size = UDim2.new(sliderPosition, 0, 1, 0) },
							{ Size = UDim2.new(0, 100, 1, 0) },
							TweenInfo.new(0.85, Enum.EasingStyle.Quint)
						)

						local decimalPlaces = syde:DecimalPlaces(Options.Increment)

						Slider.v.Text = string.format(
							"<font size='14'>%."
								.. decimalPlaces
								.. "f</font><font color='#434343'>/%."
								.. decimalPlaces
								.. "f</font>",
							NewVal,
							Options.Range[2]
						)

						tweenservice
							:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {
								TextTransparency = 0,
							})
							:Play()

						Options.StarterValue = NewVal
						Options.Value = NewVal

						if type(Options.CallBack) == "function" then
							local success, result = pcall(function()
								Options.CallBack(NewVal)
							end)
							if not success then
								syde:Report("Slider '" .. Slider.Name .. "' callback", result)
							end
						end
					end

					syde:AttachSliderInput(Slider, Options)

					if Options.SFlag then
						if Options.SFlag then
							syde.SettingsFlags[Options.SFlag] = Options
						end
					end
				end

				local descLabel = slider.slideholder:FindFirstChild("Desc")

				if descLabel then
					if data.Desc and data.Desc ~= "" then
						descLabel.Text = data.Desc
						descLabel.Visible = true
						descLabel.TextWrapped = true

						local function updateSize()
							local textSize = textservice:GetTextSize(
								descLabel.Text,
								descLabel.TextSize,
								descLabel.Font,
								Vector2.new(descLabel.AbsoluteSize.X, math.huge)
							)

							local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
							local newButtonSize = UDim2.new(
								slider.Size.X.Scale,
								slider.Size.X.Offset,
								0,
								slider.slideholder.AbsoluteSize.Y + slider.title.Size.Y.Offset + textSize.Y + 15
							)

							local descTween = tweenservice:Create(
								descLabel,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ Size = newDescSize }
							)
							descTween:Play()

							local ToggleTween = tweenservice:Create(
								slider,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{ Size = newButtonSize }
							)
							ToggleTween:Play()
						end

						updateSize()

						descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
					else
						descLabel.Visible = false
					end
				end
			end

			function telement:Paragraph(Paragraph)
				local ParaData = {
					Title = Paragraph.Title,
					Content = Paragraph.Content,
				}

				local Para = window.settings.pages.page.Paragraph:Clone()
				Para.Visible = true
				Para.Parent = Page
				Para.Frame.title.Text = ParaData.Title
				Para.Content.Text = ParaData.Content

				Para.Content.Size = UDim2.new(1, -20, 0, Para.Content.TextBounds.Y)

				local function updateSize()
					local textSize = textservice:GetTextSize(
						Para.Content.Text,
						Para.Content.TextSize,
						Para.Content.Font,
						Vector2.new(Para.Content.AbsoluteSize.X, math.huge)
					)

					local newDescSize = UDim2.new(1, -20, 0, textSize.Y)
					local newButtonSize = UDim2.new(Para.Size.X.Scale, Para.Size.X.Offset, 0, textSize.Y + 120)

					local descTween = tweenservice:Create(
						Para.Content,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = newDescSize }
					)
					descTween:Play()

					local buttonTween = tweenservice:Create(
						Para,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = newButtonSize }
					)
					buttonTween:Play()
				end

				updateSize()

				Para.Content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)

				local ParagraphSettings = {}

				function ParagraphSettings:Set(text, title)
					Para.Frame.title.Text = title
					Para.Content.Text = text
				end

				ParagraphSettings.Instance = Para

				return ParagraphSettings
			end

			function telement:TextInput(TextInput)
				local data = {
					Title = TextInput.Title or "Text Input",
					PlaceHolder = TextInput.PlaceHolder or "Enter text...",
					NumbersOnly = TextInput.NumberOnly or false,
					ClearOnLost = TextInput.ClearOnLost == nil and true or TextInput.ClearOnLost,

					CallBack = TextInput.CallBack,
				}

				local textinput = window.settings.pages.page.Input:Clone()
				textinput.Visible = true
				textinput.Parent = Page
				textinput.Name = data.Title
				textinput.title.Text = data.Title
				textinput.TextFrame.TextBox.PlaceholderText = data.PlaceHolder

				local textBox = textinput.TextFrame.TextBox
				textBox.Text = tostring(TextInput.Default or "")
				local defaultHeight = 32

				local ignoreNextClear = false

				textinput.TextFrame.Enter.MouseEnter:Connect(function()
					tweenservice
						:Create(
							textinput.TextFrame.Enter,
							TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
							{ TextColor3 = Color3.fromRGB(255, 255, 255) }
						)
						:Play()
				end)

				textinput.TextFrame.Enter.MouseLeave:Connect(function()
					tweenservice
						:Create(
							textinput.TextFrame.Enter,
							TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
							{ TextColor3 = Color3.fromRGB(40, 40, 40) }
						)
						:Play()
				end)

				textBox:GetPropertyChangedSignal("Text"):Connect(function()
					if data.NumbersOnly then
						textBox.Text = textBox.Text:gsub("%D", "")
					end

					textBox.Size = UDim2.new(1, -60, 0, defaultHeight + 40)

					local textSize = game:GetService("TextService"):GetTextSize(
						textBox.Text,
						textBox.TextSize,
						textBox.Font,
						Vector2.new(textBox.AbsoluteSize.X, math.huge)
					)

					if textBox.Text == "" then
						textBox.Size = UDim2.new(1, -60, 0, math.max(defaultHeight))
					else
						local newHeight = math.min(textSize.Y + 18, 120 + 50)
						textBox.Size = UDim2.new(1, -60, 0, newHeight)
					end
				end)

				textinput.TextFrame:GetPropertyChangedSignal("Size"):Connect(function()
					local newHeight = textinput.TextFrame.Size.Y.Offset
					local extraHeight = 32

					tweenservice
						:Create(
							textinput,
							TweenInfo.new(0.7, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(1, -35, 0, newHeight + extraHeight + 35) }
						)
						:Play()
				end)

				textBox:GetPropertyChangedSignal("Size"):Connect(function()
					local newHeight = textBox.Size.Y.Offset
					local totalHeight = math.max(newHeight, defaultHeight)

					tweenservice
						:Create(
							textinput.TextFrame,
							TweenInfo.new(0.7, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(1, -60, 0, totalHeight + 0) }
						)
						:Play()
				end)

				local function ProcessInput(text)
					local success, errorMsg = pcall(function()
						data.CallBack(text)
					end)
					if not success then
						syde:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
					end
				end

				textBox.FocusLost:Connect(function(enterPressed)
					if not enterPressed then
						return
					end

					local success, errorMsg = pcall(function()
						data.CallBack(textBox.Text)
					end)
					if not success then
						syde:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
					end

					if data.ClearOnLost then
						task.defer(function()
							textBox.Text = ""
							textBox.Size = UDim2.new(1, -60, 0, math.max(defaultHeight))
						end)
					else
						textBox.ClearTextOnFocus = false
					end
				end)

				textinput.TextFrame.Enter.MouseButton1Click:Connect(function()
					local success, errorMsg = pcall(function()
						data.CallBack(textBox.Text)
					end)
					if not success then
						syde:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
					end

					if data.ClearOnLost then
						task.defer(function()
							textBox.Text = ""
							textBox.Size = UDim2.new(1, -60, 0, math.max(defaultHeight))
						end)
					else
						textBox.ClearTextOnFocus = false
					end
				end)
			end

			for _bn, _bf in pairs(telement) do
				if type(_bf) == "function" then
					telement[_bn] = syde:Guard("Building a '" .. tostring(_bn) .. "' element", _bf)
				end
			end

			return telement
		end

		local visualSettings = settings:inittab({ Title = "Visual" })
		local privacySettings = settings:inittab({ Title = "Privacidade" })
		local infoSettings = settings:inittab({ Title = "Sobre" })
		local profileSettings = settings:inittab({ Title = "Perfis" })

		rainbowSettingControl = visualSettings:Toggle({
			Title = "Interface RGB",
			Description = "Ativa as cores animadas no hub. O botão de brilho no cabeçalho também controla esta opção.",
			Value = syde.LoadedConfig and syde.LoadedConfig.InterfaceRGB == true,
			Flag = "InterfaceRGB",
			Save = true,
			CallBack = function(enabled)
				syde:SetRainbowMode(enabled)
			end,
		})

		visualSettings:Keybind({
			Title = "Abrir/fechar hub",
			Key = uitoggle,
			Flag = "ToggleUI",
			SFlag = "ToggleUI",
			Save = true,
			OnKeyChanged = function(newKey)
				uitoggle = newKey
				SaveCfg(game and game.GameId)
			end,
			CallBack = function()
				ToggleUI()
			end,
		})

		local accentRainbowState = { Updating = false }
		visualSettings:ColorPicker({
			Title = "Main Color",
			RD = false,
			Linkable = true,
			Color = syde.theme.Accent,
			Flag = "Accent",
			SFlag = "AC",
			Save = true,
			_RainbowUpdateState = accentRainbowState,
			CallBack = function(v)
				if syde.RainbowMode and not accentRainbowState.Updating then
					syde:SetRainbowMode(false)
				end
				syde:UpdateTheme({
					["Accent"] = v,
				})
				if not accentRainbowState.Updating then
					syde:SaveThemeCfg()
					SaveCfg(game and game.GameId)
				end
			end,
		})

		local hitboxRainbowState = { Updating = false }
		visualSettings:ColorPicker({
			Title = "Cor dos controles",
			RD = false,
			Linkable = true,
			Color = syde.theme.HitBox,
			Flag = "HitBox",
			SFlag = "HB",
			Save = true,
			_RainbowUpdateState = hitboxRainbowState,
			CallBack = function(c)
				if syde.RainbowMode and not hitboxRainbowState.Updating then
					syde:SetRainbowMode(false)
				end
				syde:UpdateTheme({
					["HitBox"] = c,
				})
				if not hitboxRainbowState.Updating then
					syde:SaveThemeCfg()
					SaveCfg(game and game.GameId)
				end
			end,
		})

		local seq = syde.theme.DropShadow
		local k = seq.Keypoints

		local rotateGradient = false
		local rotating = false

		local function startGradientRotation()
			if rotating then
				return
			end
			rotating = true

			task.spawn(function()
				local grad = window.shadow.ImageLabel.UIGradient
				local rotation = 0
				while rotateGradient and grad and grad.Enabled do
					rotation = (rotation + 1) % 360
					grad.Rotation = rotation
					task.wait()
				end
				rotating = false
			end)
		end

		visualSettings:Toggle({
			Title = "Gradiente animado",
			Description = "Movimento suave na borda do hub.",
			Value = syde.LoadedConfig and syde.LoadedConfig["RotateGradient"] or false,
			Flag = "RotateGradient",
			SFlag = "RG",
			Save = true,
			CallBack = function(v)
				rotateGradient = v
				local grad = window.shadow.ImageLabel.UIGradient

				if rotateGradient and grad and grad.Enabled then
					startGradientRotation()
				end
				SaveCfg(game and game.GameId)
			end,
		})

		visualSettings:Toggle({
			Title = "Brilho",
			Description = "Brilho suave nas bordas do hub.",
			Value = syde.LoadedConfig and syde.LoadedConfig["Glow"] or false,
			Flag = "Glow",
			Save = true,
			CallBack = function(v)
				setWindowGlow(v)
			end,
		})

		visualSettings:Toggle({
			Title = "Desfoque 3D",
			Description = "Desfoca levemente o mundo 3D atrás do hub.",
			Value = syde.LoadedConfig and syde.LoadedConfig.Blur == true,
			Flag = "Blur",
			Save = true,
			CallBack = function(v)
				setBackgroundBlur(v)
			end,
		})

		visualSettings:Slider({
			Title = "Ajustes finos",
			Sliders = {
				{
					Title = "Intensidade da sombra",
					Range = { 0, 1 },
					Increment = 0.1,
					StarterValue = window.shadow.ImageLabel.ImageTransparency,
					CallBack = function(v)
						tweenservice
							:Create(
								window.shadow.ImageLabel,
								TweenInfo.new(0.65, Enum.EasingStyle.Exponential),
								{ ImageTransparency = v }
							)
							:Play()
					end,
					SFlag = "GDensity",
					SettingConfig = true,
				},
				{
					Title = "Suavidade ao arrastar",
					Range = { 0, 1 },
					Increment = 0.1,
					StarterValue = dragSpeed,
					CallBack = function(v)
						dragSpeed = v
					end,
					SFlag = "DSmoothness",
					SettingConfig = true,
				},
			},
		})

		visualSettings:Toggle({
			Title = "Papel de parede",
			Description = "Mostra a imagem personalizada atrás dos controles.",
			Value = LockToScreen,
			CallBack = function(v)
				if v then
					window.wallpaper.Visible = true
					window.pages.clipframe.v0.Visible = false
					window.pages.clipframe.v1.Visible = false

					window.pages.v0.Visible = false
					window.pages.v1.Visible = false
					window.wallpaper.ison.Value = true
				else
					window.wallpaper.Visible = false

					window.wallpaper.ison.Value = false

					if bluron then
						window.pages.clipframe.v0.Visible = false
						window.pages.clipframe.v1.Visible = false
						window.pages.v0.Visible = false
						window.pages.v1.Visible = false
					else
						window.pages.clipframe.v0.Visible = true
						window.pages.clipframe.v1.Visible = true

						window.pages.v0.Visible = true
						window.pages.v1.Visible = true
					end
				end
			end,
			SFlag = "WALLP",
		})

		visualSettings:TextInput({
			Title = "ID da imagem",
			NumberOnly = true,
			PlaceHolder = "Input your wallpaper ID here.",
			CallBack = function(v)
				if v then
					window.wallpaper.Image = "rbxassetid://" .. v
					syde:Toast({
						Content = "Wallpaper applied.",
					})
				end
			end,
		})

		local titleRainbowState = { Updating = false }
		visualSettings:ColorPicker({
			Title = "Cor do título",
			Color = syde.HeaderTitleColor or top.title.TextColor3,
			Flag = "HeaderTitleColor",
			SFlag = "HTC",
			Save = true,
			_RainbowUpdateState = titleRainbowState,
			CallBack = function(color)
				if syde.RainbowMode and not titleRainbowState.Updating then
					syde:SetRainbowMode(false)
				end
				syde.HeaderTitleColor = color
				top.title.TextColor3 = color
				if not titleRainbowState.Updating then
					syde:SaveThemeCfg()
				end
			end,
		})

		local subtitleRainbowState = { Updating = false }
		visualSettings:ColorPicker({
			Title = "Subtitle Color",
			Color = syde.HeaderSubtitleColor or top.title.sub.TextColor3,
			Flag = "HeaderSubtitleColor",
			SFlag = "HSC",
			Save = true,
			_RainbowUpdateState = subtitleRainbowState,
			CallBack = function(color)
				syde.HeaderSubtitleColor = color
				top.title.sub.TextColor3 = color
				if not subtitleRainbowState.Updating then
					syde:SaveThemeCfg()
				end
			end,
		})
		local cornerImageId = syde.LoadedConfig and syde.LoadedConfig.CornerImageId or syde.CornerImageDefault or ""
		syde.Flags.CornerImageId = {
			Type = "Input",
			Value = tostring(cornerImageId),
			Save = true,
			Set = function(self, value)
				if syde:SetCornerImage(value) then
					self.Value = syde.CornerImageId
				end
			end,
		}
		syde:SetCornerImage(cornerImageId)
		visualSettings:TextInput({
			Title = "Corner Icon",
			PlaceHolder = "Decal ID beside resize arrow",
			Default = cornerImageId,
			NumberOnly = true,
			ClearOnLost = false,
			CallBack = function(value)
				if syde:SetCornerImage(value) then
					SaveCfg(game and game.GameId)
				end
			end,
		})

		visualSettings:Toggle({
			Title = "Lock to Screen",
			Description = "Prevents the hub from being dragged off-screen.",
			Value = LockToScreen,
			CallBack = function(v)
				LockToScreen = v
			end,
			SFlag = "LS",
		})

		local watermarkValue = syde.WatermarkEnabled ~= false
		if syde.LoadedConfig and type(syde.LoadedConfig.WTRMK) == "boolean" then
			watermarkValue = syde.LoadedConfig.WTRMK
		end
		visualSettings:Toggle({
			Title = "Marca d'água",
			Description = "Shows the floating button to reopen the hub.",
			Value = watermarkValue,
			CallBack = function(v)
				syde:SetWatermarkEnabled(v)
			end,
			SFlag = "WTRMK",
		})

		local HttpService = game:GetService("HttpService")

		local isDev = false
		local baseUrl = isDev and "http://localhost:3000" or "https://syde-auth.vercel.app"
		local loginUrl = baseUrl .. "/api/login"
		local VERIFY_ENDPOINT = baseUrl .. "/api/verify?id="

		local currentDiscordId = nil
		local lastCheck = 0
		local debounceTime = 1.5

		local function openURL(url)
			local success = false
			pcall(function()
				if syn and syn.openurl then
					syn.openurl(url)
					success = true
				elseif getgenv().is_sirhurt_closure then
					game:GetService("GuiService"):OpenBrowserWindow(url)
					success = true
				elseif KRNL_LOADED then
					setclipboard(url)
					success = true
				end
			end)

			if not success and setclipboard then
				setclipboard(url)
				syde:Notify({
					Title = "Link Copied",
					Content = "OAuth link copied to clipboard. Paste in your browser.",
					Duration = 5,
				})
			end
		end

		privacySettings:Button({
			Title = "Connect Discord",
			Description = "Authenticate your Discord account.",
			CallBack = function()
				openURL(loginUrl)
			end,
		})

		local function verifyDiscord(id)
			if HttpService.HttpEnabled then
				local ok, res = pcall(function()
					return HttpService:GetAsync(VERIFY_ENDPOINT .. id, true)
				end)
				if ok and res then
					local decodedOk, decoded = pcall(function()
						return HttpService:JSONDecode(res)
					end)
					if decodedOk and type(decoded) == "table" and decoded.verified then
						return true, decoded.discordUsername or nil
					end
				end
				return false, nil
			end

			local success, result = pcall(function()
				if syn and syn.request then
					local r = syn.request({ Url = VERIFY_ENDPOINT .. id, Method = "GET" })
					local decoded = HttpService:JSONDecode(r.Body)
					if decoded.verified then
						return decoded.discordUsername or nil
					end
				elseif request then
					local r = request({ Url = VERIFY_ENDPOINT .. id, Method = "GET" })
					local decoded = HttpService:JSONDecode(r.Body)
					if decoded.verified then
						return decoded.discordUsername or nil
					end
				end
				return nil
			end)

			if success and result then
				return true, result
			end

			return false, nil
		end

		privacySettings:TextInput({
			Title = "Discord ID",
			PlaceHolder = "Paste your Discord ID after verifying",
			ClearOnLost = false,
			CallBack = function(v)
				currentDiscordId = v

				if not currentDiscordId or currentDiscordId == "" then
					window.user.headshot.Status.BackgroundColor3 = Color3.fromRGB(255, 101, 104)
					return
				end

				if tick() - lastCheck < debounceTime then
					return
				end
				lastCheck = tick()

				window.user.headshot.Status.BackgroundColor3 = Color3.fromRGB(255, 238, 49)

				task.spawn(function()
					local verified, discordUsername = verifyDiscord(currentDiscordId)
					if verified then
						window.user.headshot.Status.BackgroundColor3 = Color3.fromRGB(59, 255, 29)
						if discordUsername then
							window.user.headshot.id.username.Text = discordUsername
						end
						syde:Notify({
							Title = "Success",
							Content = "Discord verified successfully",
							Duration = 4,
						})
					else
						window.user.headshot.Status.BackgroundColor3 = Color3.fromRGB(255, 101, 104)
						syde:Notify({
							Title = "Verification Failed",
							Content = "Discord ID is not verified",
							Duration = 4,
						})
					end
				end)
			end,
		})

		function syde:SaveSettingsConfig()
			local saved = SaveCfg()
			syde:SaveThemeCfg()
			syde:Toast({
				Content = saved and "Saved settings config" or "Could not save settings config",
				Duration = 3,
			})
			return saved
		end

		function syde:LoadSettingsConfig()
			LoadThemeCfg(FILE_PATH)
			local folder = syde.Folder or syde.ConfigFolder or "FireHub"
			local legacyName = syde.ConfigFileExplicit and tostring(game and game.GameId or "default") or nil
			local filePath, fileExists =
				resolveConfigPath(folder, syde.ConfigFile or game and game.GameId or "default", legacyName)
			local loaded = false
			if fileExists then
				local readOk, content = pcall(readfile, filePath)
				if readOk and content then
					loaded = LoadCfg(content) == true
				end
			end
			syde:Toast({
				Content = loaded and "Loaded settings config" or "Could not load settings config",
				Duration = 3,
			})
			return loaded
		end

		local currentConfigName = syde.ConfigFile or "Config"
		local selectedConfig
		local autoloadEnabled = syde:GetAutoLoad() and true or false
		local configDropdownData
		local autoLoadToggle
		local revertingAutoLoadToggle = false

		local function refreshConfigList()
			if configDropdownData and configDropdownData.SetOptions then
				configDropdownData:SetOptions(syde:ListConfigs() or {}, currentConfigName)
			end
		end

		local function resolveConfigName()
			if selectedConfig and selectedConfig ~= "" then
				return selectedConfig
			end
			if currentConfigName and currentConfigName ~= "" then
				return currentConfigName
			end
			return syde.ConfigFile
		end

		profileSettings:Paragraph({
			Title = "Profiles",
			Content = "Save and load UI settings profiles. The active profile is used for autosave and optional autoload.",
		})

		configDropdownData = profileSettings:Dropdown({
			Title = "Saved profiles",
			Options = syde:ListConfigs(),
			StarterOption = currentConfigName,
			PlaceHolder = "Select a profile...",
			CallBack = function(value)
				if type(value) == "string" and value ~= "" then
					selectedConfig = value
				end
			end,
		})

		profileSettings:TextInput({
			Title = "Profile name",
			PlaceHolder = "Enter a profile name...",
			Default = currentConfigName,
			ClearOnLost = false,
			CallBack = function(value)
				local trimmed = tostring(value or ""):match("^%s*(.-)%s*$")
				if trimmed and trimmed ~= "" then
					currentConfigName = trimmed
					selectedConfig = trimmed
				end
			end,
		})

		profileSettings:Button({
			Title = "Save profile",
			Description = "Save current controls to the selected profile.",
			CallBack = function()
				local name = resolveConfigName()
				if not name or name == "" then
					return
				end
				if syde:SaveConfigAs(name) then
					currentConfigName = syde.ConfigFile
					selectedConfig = syde.ConfigFile
					refreshConfigList()
				end
			end,
		})

		profileSettings:Button({
			Title = "Load profile",
			Description = "Load controls from the selected profile.",
			CallBack = function()
				local name = resolveConfigName()
				if not name or name == "" then
					return
				end
				if syde:LoadSaveConfig(name) then
					currentConfigName = syde.ConfigFile
					selectedConfig = syde.ConfigFile
					refreshConfigList()
				end
			end,
		})

		profileSettings:Button({
			Title = "Refresh profiles",
			CallBack = refreshConfigList,
		})

		autoLoadToggle = d:Toggle({
			Title = "Autoload active profile",
			Description = "Load this profile automatically on the next launch.",
			Value = autoloadEnabled,
			Flag = "SydeAutoLoadProfile",
			Save = false,
			CallBack = function(enabled)
				if revertingAutoLoadToggle then
					return
				end
				local saved = syde:SetAutoLoad(enabled)
				if saved then
					autoloadEnabled = enabled
				else
					revertingAutoLoadToggle = true
					if autoLoadToggle and autoLoadToggle.Set then
						autoLoadToggle:Set(autoloadEnabled)
					end
					revertingAutoLoadToggle = false
					syde:Toast({ Content = "Could not update autoload setting", Duration = 3 })
				end
			end,
		})

		visualSettings:Paragraph({
			Title = "Auto-Save System",
			Content = "All toggles, sliders, dropdowns, binds and positions are saved automatically.",
		})

		privacySettings:Toggle({
			Title = "Anonymous",
			Description = "Hides your info in User Info.",
			Value = syde.LoadedConfig and syde.LoadedConfig["ANON"] or false,
			Flag = "ANON",
			SFlag = "ANON",
			Save = true,
			CallBack = function(v)
				if v then
					window.user.headshot.id.username.Text = "?"
					window.user.headshot.id.displayname.Text = "@?"
					window.user.headshot.Image = "rbxassetid://139956761561818"
				else
					SetUserInfo()
				end
				SaveCfg(game and game.GameId)
			end,
		})

		infoSettings:Paragraph({
			Title = "Status",
			Content = "Your Up To Date!",
		})

		local uptimeParagraph = c:Paragraph({
			Title = "Session UpTime",
			Content = "Calculating...",
		})

		local function formatTime(seconds)
			local days = math.floor(seconds / 86400)
			seconds = seconds % 86400
			local hours = math.floor(seconds / 3600)
			seconds = seconds % 3600
			local minutes = math.floor(seconds / 60)
			seconds = math.floor(seconds % 60)

			return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
		end

		local startTime = tick()

		ss = syde:AddConnection(runservice.Heartbeat, function()
			local uptime = tick() - startTime
			local formatted = formatTime(uptime)
			uptimeParagraph:Set("Session Uptime: " .. formatted, "Session UpTime")
		end)
	end

	local cameraViewportDisconnect
	local function attachCurrentCamera()
		if cameraViewportDisconnect then
			cameraViewportDisconnect()
			cameraViewportDisconnect = nil
		end
		layoutCamera = workspace.CurrentCamera
		if layoutCamera then
			local _, disconnectViewport =
				syde:AddConnection(layoutCamera:GetPropertyChangedSignal("ViewportSize"), updateLayout)
			cameraViewportDisconnect = disconnectViewport
		end
		updateLayout()
	end

	syde:AddConnection(workspace:GetPropertyChangedSignal("CurrentCamera"), attachCurrentCamera)
	syde:AddConnection(userinput:GetPropertyChangedSignal("TouchEnabled"), updateLayout)
	attachCurrentCamera()

	local tbdata = {
		first = false,
		selected = false,
	}

	function tbdata:Modal(ModalConfig)
		return syde:Modal(ModalConfig)
	end

	function tbdata:Dialog(ModalConfig)
		return syde:Modal(ModalConfig)
	end

	function tbdata:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		local tabTitle = TabConfig.Name or TabConfig.Title or "Tab"
		local tabObj = self:InitTab({
			Title = tabTitle,
			Locked = TabConfig.Locked,
			Key = TabConfig.Key,
		})
		return tabObj
	end

	function tbdata:ChangeIcon(IconId)
		local iconStr = tostring(IconId or "")
		if iconStr ~= "" and not iconStr:find("rbxassetid://") and tonumber(iconStr) then
			iconStr = "rbxassetid://" .. iconStr
		end
		pcall(function()
			if top and top:FindFirstChild("icon") and top.icon:IsA("ImageLabel") then
				top.icon.Image = iconStr
			elseif window:FindFirstChild("icon") and window.icon:IsA("ImageLabel") then
				window.icon.Image = iconStr
			end
		end)
	end

	function tbdata:SetName(NameConfig)
		pcall(function()
			syde._titleRotationToken = (syde._titleRotationToken or 0) + 1
			local titleText = "Syde"
			local titleColor = nil
			if type(NameConfig) == "table" then
				titleText = tostring(NameConfig[1] or "")
				if NameConfig[2] then
					if typeof(NameConfig[2]) == "Color3" then
						titleColor = NameConfig[2]
					elseif type(NameConfig[2]) == "string" then
						titleColor = Color3.fromHex(NameConfig[2])
					end
				end
			else
				titleText = tostring(NameConfig or "")
			end
			if top and top:FindFirstChild("title") then
				setHeaderTitle(titleText)
				if titleColor then
					top.title.TextColor3 = titleColor
				end
			end
		end)
	end

	function tbdata:InitTab(tab)
		if Data.Home.Enabled then
			if not tbdata.__homeBootstrapped then
				tbdata.__homeBootstrapped = true
				tbdata.first = "Home"
				tbdata.homeActive = true

				for _, temp in ipairs(pages:GetChildren()) do
					if temp:IsA("ScrollingFrame") then
						temp.Visible = false
					end
				end

				if window and window.pages and window.pages.home then
					window.pages.home.Visible = true
				end
			end
		end

		local isFirstTab = not tbdata.first

		local tdata = {
			Title = tab.Title,
			Locked = tab.Locked or false,
			Key = tab.Key,
		}

		local LockedFrames = {}

		local Tab = tabs.btn:Clone()
		Tab.Visible = true
		Tab.Parent = tabs
		Tab.title.Text = tdata.Title
		Tab.Name = tdata.Title
		local tabDivider = Instance.new("Frame")
		tabDivider.Name = "SubtleDivider"
		tabDivider.BackgroundColor3 = Color3.fromRGB(105, 105, 110)
		tabDivider.BackgroundTransparency = 0.86
		tabDivider.BorderSizePixel = 0
		tabDivider.Position = UDim2.new(0, 10, 1, 3)
		tabDivider.Size = UDim2.new(0, 145, 0, 1)
		tabDivider.Parent = Tab

		Tab.title.TextTransparency = 1
		Tab.indicator.BackgroundTransparency = 1

		local Page = pages.page:Clone()
		Page.Visible = false
		Page.Parent = pages
		Page.Name = tdata.Title

		local defaultParent = Page

		local function setInternalParent(newParent)
			defaultParent = newParent
		end

		for _, temp in ipairs(Page:GetChildren()) do
			if temp:IsA("Frame") then
				temp:Destroy()
			end
		end

		Page.ChildAdded:Connect(function(child)
			child:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				syde:updateLayout(Page, 7)
			end)
			child:GetPropertyChangedSignal("Visible"):Connect(function()
				syde:updateLayout(Page, 7)
			end)
			syde:updateLayout(Page, 7)
		end)

		Page.ChildRemoved:Connect(function()
			syde:updateLayout(Page, 7)
		end)

		Page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			syde:updateLayout(Page, 7)
		end)

		syde:updateLayout(Page, 7)

		local function ChangeName(Name)
			local fadeOut = tweenservice:Create(
				pages.clipframe.title,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextTransparency = 1, Position = UDim2.new(0, 5, 0.5, -12) }
			)
			fadeOut:Play()
			task.delay(0.1, function()
				pages.clipframe.title.Text = Name
				pages.clipframe.title.Position = UDim2.new(0, 5, 0.5, 12)
				tweenservice
					:Create(
						pages.clipframe.title,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ TextTransparency = 0, Position = UDim2.new(0, 5, 0.5, 0) }
					)
					:Play()
			end)
		end

		if isFirstTab then
			ChangeName(tdata.Title)
			Page.Visible = true
			tbdata.first = tdata.Title
		end

		local tabInitTween = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		if tbdata.first then
			tweenservice:Create(Tab.title, tabInitTween, { TextTransparency = 0.52 }):Play()
			tweenservice:Create(Tab, tabInitTween, { BackgroundTransparency = 0.45 }):Play()
			tweenservice:Create(Tab.indicator, tabInitTween, { BackgroundTransparency = 1 }):Play()
			tweenservice:Create(Tab.indicator.glow, tabInitTween, { ImageTransparency = 1 }):Play()
			tweenservice:Create(Tab, tabInitTween, { Size = UDim2.new(0, Tab.title.TextBounds.X + 30, 0, 35) }):Play()
		else
			tbdata.first = tdata.Title
			tweenservice:Create(Tab.title, tabInitTween, { TextTransparency = 0 }):Play()
			tweenservice:Create(Tab, tabInitTween, { BackgroundTransparency = 0 }):Play()
			tweenservice:Create(Tab.indicator, tabInitTween, { BackgroundTransparency = 0 }):Play()
			tweenservice:Create(Tab.indicator, tabInitTween, { BackgroundColor3 = syde.theme.Accent }):Play()
			tweenservice:Create(Tab.indicator.glow, tabInitTween, { ImageColor3 = syde.theme.Accent }):Play()
			tweenservice:Create(Tab, tabInitTween, { Size = UDim2.new(0, Tab.title.TextBounds.X + 80, 0, 35) }):Play()
		end

		local positionTweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local colorTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local HomeButton = (window and window.tabs and window.tabs.Home) and window.tabs.Home or nil
		local HomePage = (window and window.pages and window.pages.home) and window.pages.home or nil

		local function ApplyHomeButtonStyle(isActive)
			if not HomeButton or not HomeButton.homeicon:FindFirstChild("ImageLabel") then
				return
			end

			if isActive then
				tweenservice
					:Create(
						HomeButton.homeicon,
						TweenInfo.new(1, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.45 }
					)
					:Play()
				tweenservice
					:Create(
						HomeButton.homeicon.ImageLabel,
						TweenInfo.new(1, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }
					)
					:Play()
			else
				tweenservice
					:Create(
						HomeButton.homeicon,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.85 }
					)
					:Play()
				tweenservice
					:Create(
						HomeButton.homeicon.ImageLabel,
						TweenInfo.new(1, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.67 }
					)
					:Play()
			end
		end

		local isInit = true

		local function ApplyTabStyle(tabButton, isSelected)
			local targetTextTransparency = isSelected and 0 or 0.6
			local targetBackgroundTransparency = isSelected and 0 or 0.45
			local targetTransparency = isSelected and 0 or 1
			local targetColor = isSelected and syde.theme.Accent or Color3.fromRGB(29, 29, 29)
			local targetSize = isSelected and UDim2.new(0, tabButton.title.TextBounds.X + 80, 0, 35)
				or UDim2.new(0, tabButton.title.TextBounds.X + 50, 0, 35)

			if isInit then
				task.spawn(function()
					for _, v in ipairs(tabs:GetChildren()) do
						if v:IsA("Frame") then
							tweenservice
								:Create(
									v,
									TweenInfo.new(0.75, Enum.EasingStyle.Quart),
									{ Size = UDim2.new(0, v.title.TextBounds.X + 100, 0, 30) }
								)
								:Play()
							task.wait(0.15)
							tweenservice
								:Create(tabButton, TweenInfo.new(0.75, Enum.EasingStyle.Quart), { Size = targetSize })
								:Play()
							isInit = false
						end
					end
				end)
			end

			tweenservice:Create(tabButton, positionTweenInfo, { Size = targetSize }):Play()
			tweenservice
				:Create(tabButton, colorTweenInfo, { BackgroundTransparency = targetBackgroundTransparency })
				:Play()
			tweenservice:Create(tabButton.title, colorTweenInfo, { TextTransparency = targetTextTransparency }):Play()
			tweenservice:Create(tabButton.indicator.glow, colorTweenInfo, { ImageColor3 = targetColor }):Play()
			tweenservice
				:Create(tabButton.indicator.glow, colorTweenInfo, { ImageTransparency = isSelected and 0.78 or 1 })
				:Play()

			tweenservice:Create(tabButton.indicator, colorTweenInfo, { BackgroundColor3 = targetColor }):Play()
			tweenservice
				:Create(tabButton.indicator, colorTweenInfo, { BackgroundTransparency = isSelected and 0 or 1 })
				:Play()
		end
		ApplyTabStyle(Tab, isFirstTab)

		if Data.Home.Enabled then
			ApplyTabStyle(Tab, false)
		else
			ApplyTabStyle(Tab, isFirstTab)
		end

		local function ShowHome()
			tbdata.homeActive = true
			tbdata.first = "Home"

			for _, otherPage in ipairs(pages:GetChildren()) do
				if otherPage:IsA("ScrollingFrame") then
					otherPage.Visible = false
				end
			end

			for _, otherTab in ipairs(tabs:GetChildren()) do
				if otherTab:IsA("Frame") then
					ApplyTabStyle(otherTab, false)
					otherTab.interact.Active = true
				end
			end

			if HomePage then
				HomePage.Visible = true
				pcall(function()
					tweenservice
						:Create(HomePage, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 })
						:Play()
				end)
			end

			ApplyHomeButtonStyle(true)
			window.pages.clipframe.Visible = false
		end

		local function HideHomeForTab()
			tbdata.homeActive = false

			if HomePage and HomePage.Visible then
				HomePage.Visible = false

				pcall(function()
					HomePage.BackgroundTransparency = 1
				end)
			end

			ApplyHomeButtonStyle(false)
			window.pages.clipframe.Visible = true
		end

		if tbdata.first == "Home" then
			ShowHome()
		end

		if HomeButton and HomeButton.homeicon:FindFirstChild("interact") and not tbdata.__homeHooked then
			tbdata.__homeHooked = true
			HomeButton.homeicon.interact.MouseButton1Click:Connect(function()
				if tbdata.homeActive then
					return
				end

				local lockedFolder = pages:FindFirstChild("lockedpages")
				if lockedFolder then
					for _, lockedPage in ipairs(lockedFolder:GetChildren()) do
						if lockedPage:IsA("TextButton") then
							lockedPage.Visible = false
						end
					end
				end

				ShowHome()
			end)
		end

		Tab.interact.MouseButton1Click:Connect(function()
			if tbdata.first == tdata.Title then
				return
			end

			if Data.Home.Enabled then
				if tbdata.homeActive then
					HideHomeForTab()
				end
			end

			local previous = tbdata.first
			tbdata.first = tdata.Title

			local prevPage = pages:FindFirstChild(previous)
			local newPage = pages:FindFirstChild(tdata.Title)

			if prevPage and newPage then
				ChangeName(tdata.Title)
			else
				pages.clipframe.title.Text = tdata.Title
			end

			for _, otherPage in ipairs(pages:GetChildren()) do
				if otherPage:IsA("ScrollingFrame") then
					otherPage.Visible = false
				end
			end

			Page.Visible = true
			tbdata.first = tdata.Title

			syde:replayLoadTweens()

			for _, otherTab in ipairs(tabs:GetChildren()) do
				if otherTab:IsA("Frame") then
					ApplyTabStyle(otherTab, otherTab == Tab)
					otherTab.interact.Active = true
				end
			end
		end)

		syde:AddConnection(syde.Comms.Event, function(p, color)
			if p == "Accent" then
				if tbdata.first ~= tdata.Title then
					return
				end

				tweenservice
					:Create(Tab.indicator, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						BackgroundColor3 = color,
					})
					:Play()

				tweenservice
					:Create(Tab.indicator.glow, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						ImageColor3 = color,
					})
					:Play()
			end
		end)

		local function SwitchToTab(tabName)
			local selectedTab
			local targetPage

			for _, tab in ipairs(tabs:GetChildren()) do
				if tab:IsA("Frame") and tab.Name == tabName then
					selectedTab = tab
					break
				end
			end

			targetPage = pages:FindFirstChild(tabName)
			if not (selectedTab and targetPage) then
				warn("[Syde] SwitchToTab failed:", tabName)
				return
			end

			if tbdata.first == tabName then
				return
			end

			if Data.Home.Enabled and tbdata.homeActive then
				HideHomeForTab()
			end

			ChangeName(tabName)

			for _, page in ipairs(pages:GetChildren()) do
				if page:IsA("ScrollingFrame") then
					page.Visible = false
				end
			end

			targetPage.Visible = true
			tbdata.first = tabName

			for _, tab in ipairs(tabs:GetChildren()) do
				if tab:IsA("Frame") then
					ApplyTabStyle(tab, tab == selectedTab)
					tab.interact.Active = true
				end
			end

			syde:replayLoadTweens()

			return targetPage
		end

		local Pages = ui.main.pages
		local Results = window.search.Container
		local Template = Results.option

		local activeResults = {}
		local searchDebounce = 0

		local function getFunctionType(frame)
			local attr = frame:GetAttribute("FunctionType")
			if typeof(attr) == "string" then
				return attr
			end
			return "Function"
		end

		local function clearResults()
			for _, v in ipairs(Results:GetChildren()) do
				if v:IsA("Frame") and v ~= Template then
					v:Destroy()
				end
			end
			table.clear(activeResults)
		end

		local function createResult(page, func)
			local key = func:GetFullName()
			if activeResults[key] then
				return
			end
			activeResults[key] = true

			local result = Template:Clone()
			result.Visible = true
			result.Parent = Results

			result.info.title.Text = func.Name
			result.info.badge["function"].Text = getFunctionType(func)
			result.info.badge.Size = UDim2.new(0, result.info.badge["function"].TextBounds.X + 20, 0, 20)
			result.interact.MouseButton1Click:Connect(function()
				closesearch()

				local openedPage = ui.main.pages:FindFirstChild(page.Name)
				if not openedPage or not openedPage:IsA("ScrollingFrame") then
					return
				end

				SwitchToTab(page.Name)

				task.wait(0.05)

				local y = func.AbsolutePosition.Y - openedPage.AbsolutePosition.Y + openedPage.CanvasPosition.Y

				tweenservice
					:Create(
						openedPage,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ CanvasPosition = Vector2.new(0, math.max(0, y - 20)) }
					)
					:Play()

				local original = func.BackgroundColor3
				tweenservice
					:Create(func, TweenInfo.new(0.2), {
						BackgroundColor3 = syde:GetLighter(original, 0.03),
					})
					:Play()

				task.delay(0.35, function()
					tweenservice
						:Create(func, TweenInfo.new(0.35), {
							BackgroundColor3 = original,
						})
						:Play()
				end)
			end)

			result.MouseEnter:Connect(function()
				tweenservice
					:Create(result.ImageLabel, TweenInfo.new(0.2), {
						ImageColor3 = Color3.fromRGB(255, 255, 255),
					})
					:Play()
			end)

			result.MouseLeave:Connect(function()
				tweenservice
					:Create(result.ImageLabel, TweenInfo.new(0.2), {
						ImageColor3 = Color3.fromRGB(130, 130, 130),
					})
					:Play()
			end)

			tweenservice
				:Create(
					result.info.badge,
					TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
					{ BackgroundTransparency = 0 }
				)
				:Play()
			tweenservice
				:Create(result.info.title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
				:Play()
			tweenservice
				:Create(
					result.info.badge["function"],
					TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
					{ TextTransparency = 0 }
				)
				:Play()
		end

		local function searchFunctions(query)
			searchDebounce += 1
			local thisSearch = searchDebounce

			task.delay(0.05, function()
				if thisSearch ~= searchDebounce then
					return
				end

				clearResults()
				query = query:lower()
				if query == "" then
					return
				end

				for _, page in ipairs(Pages:GetChildren()) do
					if page:IsA("ScrollingFrame") then
						for _, child in ipairs(page:GetDescendants()) do
							if child:IsA("Frame") and child:GetAttribute("Searchable") then
								local name = child.Name:lower()
								local ftype = getFunctionType(child):lower()

								if name:find(query) or ftype:find(query) then
									createResult(page, child)
								end
							end
						end
					end
				end
			end)
		end

		local SearchBox = window.search.Frame.TextBox
		SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			searchFunctions(SearchBox.Text)

			tweenservice
				:Create(window.search, TweenInfo.new(0.7, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 350, 0, 230) })
				:Play()
			tweenservice
				:Create(
					window.search.UICorner,
					TweenInfo.new(0.7, Enum.EasingStyle.Quart),
					{ CornerRadius = UDim.new(0, 25) }
				)
				:Play()
			if SearchBox.Text == "" then
				tweenservice
					:Create(
						window.search,
						TweenInfo.new(0.7, Enum.EasingStyle.Quart),
						{ Size = UDim2.new(0, 350, 0, 60) }
					)
					:Play()
				tweenservice
					:Create(
						window.search.UICorner,
						TweenInfo.new(0.7, Enum.EasingStyle.Quart),
						{ CornerRadius = UDim.new(1, 0) }
					)
					:Play()
			end
		end)

		syde:AddConnection(syde.Comms.Event, function(p, value)
			if p == "DropShadow" then
				local imageLabel = window.shadow.ImageLabel
				local gradient = imageLabel:FindFirstChildOfClass("UIGradient")

				if not gradient then
					gradient = Instance.new("UIGradient")
					gradient.Parent = imageLabel
				end

				gradient.Color = value
			end
		end)

		local initelement = {}

		function initelement:Button(Button)
			local data = {
				Title = Button.Title or "Temp Button",
				CallBack = Button.CallBack,
				Desc = Button.Description or "",
				Type = Button.Type or "Default",
				HoldTime = Button.HoldTime or 3,
			}

			local button = pages.page.Button:Clone()
			button.Visible = true
			button.Parent = Page
			button.title.Text = data.Title
			button.Name = data.Title
			button.title.Size = UDim2.new(0, button.title.TextBounds.X + 15, 0, 35)
			button:SetAttribute("Searchable", true)

			local c

			c = data.CallBack

			local fOTween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)
			local fITween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)

			if data.Type == "Default" then
				button.interact.MouseButton1Down:Connect(function()
					tweenservice:Create(button.UIStroke, fOTween, { Transparency = 1 }):Play()
					tweenservice:Create(button.ImageLabel, fOTween, { ImageTransparency = 1 }):Play()
					tweenservice
						:Create(
							button.ImageLabel,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 1 }
						)
						:Play()
				end)

				button.interact.MouseButton1Up:Connect(function()
					tweenservice:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
					tweenservice
						:Create(
							button.ImageLabel,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 0.95 }
						)
						:Play()
				end)

				button.interact.MouseButton1Click:Connect(function()
					if data.CallBack then
						local success, errorMsg = pcall(c)
						if not success then
							syde:Report("Button '" .. button.Name .. "' callback", errorMsg)
						end
					else
						warn(`[ CallBack Missing: {button.Name} ] No Function Assigned`)
					end
				end)

				button.interact.MouseLeave:Connect(function()
					tweenservice:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
					tweenservice
						:Create(
							button.ImageLabel,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 0.95 }
						)
						:Play()
				end)
			elseif data.Type == "Hold" then
				local HoldTime = data.HoldTime
				local Holding = false
				local TimeLeft = HoldTime
				local Complete = false
				local holdSession = 0

				button.ImageLabel.Image = "rbxassetid://127075195365098"
				button.ImageLabel.Rotation = 0
				button.ImageLabel.Size = UDim2.new(0, 16, 0, 16)
				button.ImageLabel.Position = UDim2.new(1, -41, 0.5, 0)

				local function CancelOperation()
					Holding = false
					holdSession += 1
					TimeLeft = HoldTime
					button.title.timer.Text = tostring(HoldTime)
					tweenservice:Create(button.ImageLabel, TweenInfo.new(0.15), { ImageTransparency = 0.95 }):Play()
					tweenservice:Create(button.title.timer, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
					tweenservice
						:Create(button.UIStroke.UIGradient, TweenInfo.new(0.15), { Offset = Vector2.new(-1, 0) })
						:Play()
					Complete = false
				end

				button.interact.MouseButton1Down:Connect(function()
					if Holding or Complete then
						return
					end
					holdSession += 1
					local thisSession = holdSession
					Holding = true
					TimeLeft = HoldTime
					button.title.timer.Text = tostring(TimeLeft)
					tweenservice
						:Create(
							button.ImageLabel,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ ImageTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							button.title.timer,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ TextTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							button.UIStroke.UIGradient,
							TweenInfo.new(HoldTime, Enum.EasingStyle.Linear),
							{ Offset = Vector2.new(0.7, 0) }
						)
						:Play()
					tweenservice
						:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0 })
						:Play()

					while Holding and holdSession == thisSession and TimeLeft > 0 do
						TimeLeft = math.max(0, TimeLeft - runservice.Heartbeat:Wait())
						button.title.timer.Text = string.format("%.1f", TimeLeft)
					end

					if Holding and holdSession == thisSession and TimeLeft <= 0 then
						Holding = false
						Complete = true

						if data.CallBack then
							local success, errorMsg = pcall(data.CallBack)
							if not success then
								syde:Report("Element callback", errorMsg)
							end
						else
							warn("[CALLBACK MISSING]: No Function Assigned To", data.Title)
						end

						tweenservice
							:Create(
								button,
								TweenInfo.new(0.34, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = Color3.fromRGB(24, 24, 24) }
							)
							:Play()
						tweenservice
							:Create(
								button.UIStroke.UIGradient,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear),
								{ Offset = Vector2.new(-1, 0) }
							)
							:Play()
						task.wait(0.34)
						tweenservice
							:Create(
								button,
								TweenInfo.new(0.34, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = Color3.fromRGB(17, 17, 17) }
							)
							:Play()
					end
				end)

				button.interact.MouseButton1Up:Connect(function()
					CancelOperation()
				end)

				button.interact.MouseLeave:Connect(function()
					if Holding then
						CancelOperation()
					end
				end)
			end

			local descLabel = button:FindFirstChild("desc")

			if descLabel then
				if data.Desc and data.Desc ~= "" then
					descLabel.Text = data.Desc
					descLabel.Visible = true
					descLabel.TextWrapped = true

					local function updateSize()
						local textSize = textservice:GetTextSize(
							descLabel.Text,
							descLabel.TextSize,
							descLabel.Font,
							Vector2.new(descLabel.AbsoluteSize.X, math.huge)
						)

						local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
						local newButtonSize = UDim2.new(
							button.Size.X.Scale,
							button.Size.X.Offset,
							0,
							button.title.Size.Y.Offset + textSize.Y + 10
						)

						local descTween = tweenservice:Create(
							descLabel,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Size = newDescSize }
						)
						descTween:Play()

						local buttonTween = tweenservice:Create(
							button,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Size = newButtonSize }
						)
						buttonTween:Play()
					end

					updateSize()

					descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
				else
					descLabel.Visible = false
				end
			end

			data._frame = button
			data.toggle = function(self)
				if self._frame and self._frame.Parent then
					self._frame.Visible = not self._frame.Visible
				end
			end
			data.remove = function(self)
				if self._frame and self._frame.Parent then
					self._frame:Destroy()
				end
			end
			return data
		end

		function initelement:Toggle(Toggle)
			local toggleConnections = {}
			local captureConnection
			local captureDisconnect
			local TogService
			local function connectTracked(signal, callback)
				local connection, unregister = syde:AddConnection(signal, callback)
				local connected = true
				local disconnect
				disconnect = function()
					if not connected then
						return
					end
					connected = false
					unregister()
					for index = #toggleConnections, 1, -1 do
						if toggleConnections[index] == disconnect then
							table.remove(toggleConnections, index)
							break
						end
					end
				end
				table.insert(toggleConnections, disconnect)
				return connection, disconnect
			end

			local data = {
				Title = Toggle.Title or Toggle.Name or "Temp Toggle",
				Desc = Toggle.Description or Toggle.Desc or "",
				V = Toggle.Value ~= nil and Toggle.Value or (Toggle.Default ~= nil and Toggle.Default or false),
				Config = Toggle.Config or false,
				CallBack = Toggle.Callback or Toggle.CallBack,
				Flag = Toggle.Flag,
				Type = "Toggle",
				Save = Toggle.Save ~= false,
			}

			local toggle = pages.page.Toggle:Clone()
			toggle.Visible = true
			toggle.Parent = Page
			toggle.title.Text = data.Title
			toggle.Name = data.Title
			toggle:SetAttribute("Searchable", true)

			local toggleConfiguration = ui.Render.ToggleConfiguration:Clone()
			toggleConfiguration.Parent = ui.Render
			toggleConfiguration.Visible = false

			toggleConfiguration.Container.KeyBind.Bind.v.Text = "None"
			tweenservice
				:Create(
					toggleConfiguration.Container.KeyBind.Bind,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint),
					{ Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20, 0, 25) }
				)
				:Play()

			toggleConfiguration.BackgroundTransparency = 1
			toggleConfiguration.Container.KeyBind.Title.TextTransparency = 1
			toggleConfiguration.Container.KeyBind.Bind.BackgroundTransparency = 1
			toggleConfiguration.Container.KeyBind.Bind.v.TextTransparency = 1
			toggleConfiguration.Container.Clear.Title.TextTransparency = 1
			toggleConfiguration.Container.Clear.clear.ImageLabel.ImageTransparency = 1
			toggleConfiguration.Size = UDim2.new(0, 75, 0, 53)

			if not data.Config then
				toggle.configure:Destroy()
			end

			local toggleTween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)
			local fadeTween = TweenInfo.new(0.57, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

			local function UpdateToggleUI(state)
				local targetColor = state and syde.theme.HitBox or Color3.fromRGB(28, 28, 28)
				local strokeTransparency = state and 1 or 0
				local checkTransparency = state and 0 or 1
				local gradientTransparency = state and 0 or 1
				local glowTransparency = state and 0.7 or 1
				local textTransparency = state and 0 or 0.5

				tweenservice:Create(toggle.tog, toggleTween, { BackgroundColor3 = targetColor }):Play()

				tweenservice:Create(toggle.tog.check, toggleTween, { ImageTransparency = checkTransparency }):Play()
				tweenservice
					:Create(toggle.tog.gradfr, fadeTween, { BackgroundTransparency = gradientTransparency })
					:Play()
				tweenservice:Create(toggle.tog.glow, toggleTween, { ImageTransparency = glowTransparency }):Play()
				tweenservice:Create(toggle.tog.glow, toggleTween, { ImageColor3 = targetColor }):Play()
				tweenservice:Create(toggle.title, toggleTween, { TextTransparency = textTransparency }):Play()
			end

			UpdateToggleUI(data.V)

			toggle.interact.MouseButton1Click:Connect(function()
				data:Set(not data.V)
			end)

			local descLabel = toggle:FindFirstChild("desc")

			if descLabel then
				if data.Desc and data.Desc ~= "" then
					descLabel.Text = data.Desc
					descLabel.Visible = true
					descLabel.TextWrapped = true

					local function updateSize()
						local textSize = textservice:GetTextSize(
							descLabel.Text,
							descLabel.TextSize,
							descLabel.Font,
							Vector2.new(descLabel.AbsoluteSize.X, math.huge)
						)

						local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
						local newButtonSize = UDim2.new(
							toggle.Size.X.Scale,
							toggle.Size.X.Offset,
							0,
							toggle.title.Size.Y.Offset + textSize.Y + 10
						)

						local descTween = tweenservice:Create(
							descLabel,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Size = newDescSize }
						)
						descTween:Play()

						local ToggleTween = tweenservice:Create(
							toggle,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Size = newButtonSize }
						)
						ToggleTween:Play()
					end

					updateSize()

					descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
				else
					descLabel.Visible = false
				end
			end

			if data.Config then
				local State = false

				local enterTween = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)

				toggle.configure.MouseEnter:Connect(function()
					tweenservice
						:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
				end)

				toggle.configure.MouseLeave:Connect(function()
					tweenservice
						:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(104, 104, 104) })
						:Play()
				end)

				local function ToggleConfigOpen()
					toggleConfiguration.Visible = true
					State = true

					tweenservice:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 0 }):Play()
					tweenservice
						:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 0 })
						:Play()
					tweenservice
						:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 0 })
						:Play()
					tweenservice
						:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 0 })
						:Play()
					tweenservice
						:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 0 })
						:Play()
					tweenservice
						:Create(
							toggleConfiguration.Container.Clear.clear.ImageLabel,
							enterTween,
							{ ImageTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 0 })
						:Play()
					tweenservice
						:Create(
							toggleConfiguration,
							TweenInfo.new(0.7, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0, 174, 0, 88) }
						)
						:Play()
				end

				local function ToggleConfigClose()
					State = false
					if captureConnection then
						if captureDisconnect then
							captureDisconnect()
						else
							captureConnection:Disconnect()
						end
						captureConnection = nil
						captureDisconnect = nil
						toggleConfiguration.Container.KeyBind.Bind.v.Text = data.Keybind and data.Keybind.Name or "None"
					end

					tweenservice:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 1 }):Play()
					tweenservice
						:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 1 })
						:Play()
					tweenservice
						:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 1 })
						:Play()
					tweenservice
						:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 1 })
						:Play()
					tweenservice
						:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 1 })
						:Play()
					tweenservice
						:Create(
							toggleConfiguration.Container.Clear.clear.ImageLabel,
							enterTween,
							{ ImageTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 1 })
						:Play()
					tweenservice
						:Create(
							toggleConfiguration,
							TweenInfo.new(0.7, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0, 75, 0, 53) }
						)
						:Play()

					task.wait(0.5)

					if not State then
						toggleConfiguration.Visible = false
					end
				end

				local debounce1 = false

				local function ToggleConfig()
					if debounce1 then
						return
					end
					debounce1 = true

					if not toggleConfiguration.Visible then
						TogService = runservice.RenderStepped:Connect(function()
							toggleConfiguration:TweenPosition(
								UDim2.new(
									0,
									toggle.configure.AbsolutePosition.X - 190,
									0,
									toggle.configure.AbsolutePosition.Y + toggle.configure.AbsoluteSize.Y + 65
								),
								Enum.EasingDirection.Out,
								Enum.EasingStyle.Quad,
								0.1,
								true
							)
							if not toggleConfiguration.Visible then
								TogService:Disconnect()
							end
						end)
						ToggleConfigOpen()
					else
						if TogService then
							TogService:Disconnect()
						end
						ToggleConfigClose()
					end

					task.delay(0.4, function()
						debounce1 = false
					end)
				end

				toggle.configure.MouseButton1Click:Connect(function()
					ToggleConfig()
				end)

				connectTracked(userinput.InputBegan, function(input)
					if
						not State
						or (
							input.UserInputType ~= Enum.UserInputType.MouseButton1
							and input.UserInputType ~= Enum.UserInputType.Touch
						)
					then
						return
					end
					local position = Vector2.new(input.Position.X, input.Position.Y)
					local function inside(gui)
						local origin, size = gui.AbsolutePosition, gui.AbsoluteSize
						return position.X >= origin.X
							and position.X <= origin.X + size.X
							and position.Y >= origin.Y
							and position.Y <= origin.Y + size.Y
					end
					if inside(toggleConfiguration) or inside(toggle.configure) then
						return
					end
					if TogService then
						TogService:Disconnect()
						TogService = nil
					end
					task.spawn(ToggleConfigClose)
				end)

				local function ResizeBindFrame()
					tweenservice
						:Create(
							toggleConfiguration.Container.KeyBind.Bind,
							TweenInfo.new(0.5, Enum.EasingStyle.Quint),
							{
								Size = UDim2.new(
									0,
									toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,
									0,
									25
								),
							}
						)
						:Play()
				end

				local function setKeybind(key, skipSave)
					if not key then
						toggleConfiguration.Container.KeyBind.Bind.v.Text = "None"
						ResizeBindFrame()
						data.Keybind = nil
					else
						data.Keybind = key
						data.KeybindReady = false

						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind.v,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
								{ TextTransparency = 1 }
							)
							:Play()
						toggleConfiguration.Container.KeyBind.Bind.v.Text = key.Name
						tweenservice
							:Create(
								toggleConfiguration.Container.KeyBind.Bind.v,
								TweenInfo.new(1, Enum.EasingStyle.Exponential),
								{ TextTransparency = 0 }
							)
							:Play()
						ResizeBindFrame()

						task.delay(0.5, function()
							data.KeybindReady = true
						end)
					end
					if not skipSave and data.Flag and data.Save ~= false then
						if type(syde.AutoSave) == "function" then
							local saved = syde:AutoSave()
							if not saved then
								warn("[Syde Config] Could not save keybind for " .. tostring(data.Flag))
							end
						else
							SaveConfig(game and game.GameId)
						end
					end
				end
				data.SetKeybind = function(_, key, skipSave)
					setKeybind(key, skipSave)
				end

				toggleConfiguration.Container.KeyBind.Interact.MouseButton1Click:Connect(function()
					if captureDisconnect then
						captureDisconnect()
					end
					tweenservice
						:Create(
							toggleConfiguration.Container.KeyBind.Bind.v,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
							{ TextTransparency = 1 }
						)
						:Play()
					toggleConfiguration.Container.KeyBind.Bind.v.Text = "..."
					tweenservice
						:Create(
							toggleConfiguration.Container.KeyBind.Bind.v,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
							{ TextTransparency = 0 }
						)
						:Play()
					ResizeBindFrame()

					captureConnection, captureDisconnect = connectTracked(userinput.InputBegan, function(input)
						local key = getBindableKey(input)
						if not userinput:GetFocusedTextBox() and key then
							setKeybind(key)
							if captureDisconnect then
								captureDisconnect()
							end
							captureConnection = nil
							captureDisconnect = nil
						end
					end)
				end)

				connectTracked(userinput.InputBegan, function(input)
					if
						not userinput:GetFocusedTextBox()
						and data.Keybind
						and data.KeybindReady
						and matchesToggleKeybind(data.Keybind, input)
					then
						data:Set(not data.V)
					end
				end)

				local debounce2 = false

				toggleConfiguration.Container.Clear.Interact.MouseButton1Click:Connect(function()
					if debounce2 then
						return
					end
					debounce2 = true

					setKeybind(nil)

					local function blink()
						tweenservice
							:Create(
								toggleConfiguration.Container.Clear.clear.ImageLabel,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint),
								{ Rotation = 13 }
							)
							:Play()
						task.wait(0.2)
						tweenservice
							:Create(
								toggleConfiguration.Container.Clear.clear.ImageLabel,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint),
								{ Rotation = -13 }
							)
							:Play()
						task.wait(0.2)
						tweenservice
							:Create(
								toggleConfiguration.Container.Clear.clear.ImageLabel,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint),
								{ Rotation = 0 }
							)
							:Play()
					end

					blink()

					task.delay(2, function()
						debounce2 = false
					end)
				end)

				toggleConfiguration.Container.Clear.MouseEnter:Connect(function()
					tweenservice
						:Create(
							toggleConfiguration.Container.Clear.clear,
							TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0.9 }
						)
						:Play()
				end)

				toggleConfiguration.Container.Clear.MouseLeave:Connect(function()
					tweenservice
						:Create(
							toggleConfiguration.Container.Clear.clear,
							TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
				end)
			end

			connectTracked(syde.Comms.Event, function(p, color)
				if p == "HitBox" then
					if data.V then
						toggle.tog.BackgroundColor3 = color
						toggle.tog.glow.ImageColor3 = color
					end
				end
			end)

			function data:Set(NewValue, skipSave)
				if type(NewValue) ~= "boolean" then
					return false
				end
				data.V = NewValue
				data.Value = NewValue
				UpdateToggleUI(NewValue)

				if data.CallBack then
					local success, errorMsg = pcall(function()
						data.CallBack(data.V)
					end)
					if not success then
						syde:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
					end

					if not skipSave and data.Save and data.Flag then
						SaveConfig(game and game.GameId)
					end
					return true
				end
				if not skipSave and data.Save ~= false and data.Flag then
					SaveConfig(game and game.GameId)
				end
				return true
			end

			data.Value = data.V
			data._frame = toggle
			data.toggle = function(self)
				if self._frame and self._frame.Parent then
					self._frame.Visible = not self._frame.Visible
				end
			end
			data.remove = function(self)
				if TogService then
					TogService:Disconnect()
					TogService = nil
				end
				if captureConnection then
					if captureDisconnect then
						captureDisconnect()
					else
						captureConnection:Disconnect()
					end
					captureConnection = nil
					captureDisconnect = nil
				end
				for index = #toggleConnections, 1, -1 do
					local disconnect = toggleConnections[index]
					toggleConnections[index] = nil
					if disconnect then
						pcall(disconnect)
					end
				end
				if toggleConfiguration.Parent then
					toggleConfiguration:Destroy()
				end
				if data.Flag and syde.Flags[data.Flag] == data then
					syde.Flags[data.Flag] = nil
				end
				if self._frame and self._frame.Parent then
					self._frame:Destroy()
				end
			end

			if syde.ConfigEnabled and data.Flag then
				syde.Flags[data.Flag] = data
				if syde.LoadedConfig and syde.LoadedConfig[data.Flag] ~= nil then
					data:Set(syde.LoadedConfig[data.Flag], true)
				end
				local savedKeybind = syde.LoadedConfig and syde.LoadedConfig[data.Flag .. "_Keybind"]
				if data.Config and type(savedKeybind) == "string" and data.SetKeybind then
					local key = decodeToggleKeybind(savedKeybind)
					if key then
						data:SetKeybind(key, true)
					end
				end
			end

			return data
		end

		function initelement:Slider(Slider)
			local data = {
				Title = Slider.Title or Slider.Name or "Slider",
				Desc = Slider.Description or Slider.Desc or "",
				Sliders = Slider.Sliders,
			}

			if not data.Sliders then
				data.Sliders = {
					{
						Title = Slider.ValueName or Slider.Name or Slider.Title or "Value",
						Range = Slider.Range or { Slider.Min or 0, Slider.Max or 100 },
						Increment = Slider.Increment or 1,
						StarterValue = Slider.Default ~= nil and Slider.Default or (Slider.StarterValue or 0),
						CallBack = Slider.Callback or Slider.CallBack,
						Flag = Slider.Flag,
						ShowTicks = Slider.ShowTicks == true,
					},
				}
			end

			local slider = pages.page.Slider:Clone()
			slider.Visible = true
			slider.Parent = Page
			slider.title.Text = data.Title
			slider.Name = data.Title
			slider.slideholder.slider.Visible = false
			slider:SetAttribute("Searchable", true)

			local primaryOptions = nil

			for _, Options in ipairs(data.Sliders) do
				local Slider = pages.page.Slider.slideholder.slider:Clone()

				Options = {
					Title = Options.Title or "Slider",
					Increment = Options.Increment or 1,
					Range = Options.Range or { 0, 100 },
					StarterValue = Options.StarterValue or 16,
					CallBack = Options.CallBack,
					Flag = Options.Flag,
					ShowTicks = Options.ShowTicks == true,
				}
				Options = normalizeSliderOptions(Options)

				Slider.Name = Options.Title
				Slider.Title.Text = Options.Title
				Slider.slide.Ticks.Visible = Options.ShowTicks
				Options.Value = Options.StarterValue
				local slideSize = Slider.slide.Size
				Slider.slide.Size =
					UDim2.new(slideSize.X.Scale, slideSize.X.Offset, slideSize.Y.Scale, slideSize.Y.Offset + 4)
				Slider.slide.Interact.Size = UDim2.new(1, 0, 1, 16)
				Slider.slide.Interact.Position = UDim2.new(0, 0, 0, -8)
				Slider.Size =
					UDim2.new(Slider.Size.X.Scale, Slider.Size.X.Offset, Slider.Size.Y.Scale, Slider.Size.Y.Offset + 6)
				local dragging = false
				local activeTouch = nil
				local sliderConnections = {}
				local function trackSliderConnection(signal, callback)
					local _, disconnect = syde:AddConnection(signal, callback)
					table.insert(sliderConnections, disconnect)
				end
				local function cleanupSlider()
					dragging = false
					activeTouch = nil
					for index = #sliderConnections, 1, -1 do
						sliderConnections[index]()
						sliderConnections[index] = nil
					end
					syde:removeLoadTween(Slider.slide.slideframe)
				end
				Slider.Destroying:Connect(cleanupSlider)
				Slider.Visible = true
				Slider.Parent = slider.slideholder

				local SliderPosition
				if Options.StarterValue <= Options.Range[1] then
					SliderPosition = 0
				elseif Options.StarterValue >= Options.Range[2] then
					SliderPosition = 1
				else
					local range = Options.Range[2] - Options.Range[1]
					SliderPosition = (Options.StarterValue - Options.Range[1]) / range
				end

				Slider.slide.slideframe:TweenSize(
					UDim2.new(SliderPosition, 0, 1, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quint,
					0.5,
					true
				)

				syde:registerLoadTween(
					Slider.slide.slideframe,
					{ Size = UDim2.new(SliderPosition, 0, 1, 0) },
					{ Size = UDim2.new(0, 100, 1, 0) },
					TweenInfo.new(0.85, Enum.EasingStyle.Quint)
				)

				syde:replayLoadTweens(Slider.slide.slideframe)

				local decimalPlaces = syde:DecimalPlaces(Options.Increment)
				Slider.v.Text = string.format(
					"<font size='14'>%."
						.. decimalPlaces
						.. "f</font><font color='#434343'>/%."
						.. decimalPlaces
						.. "f</font>",
					Options.StarterValue,
					Options.Range[2]
				)

				local function BuildTicks(slide, options)
					local ticksFrame = slide:FindFirstChild("Ticks")
					if not ticksFrame then
						warn("❌ Missing Slider.slide.Ticks")
						return
					end

					local template = ticksFrame:FindFirstChild("tick")
					if not template then
						warn("❌ Missing Tick template inside Ticks")
						return
					end

					local min, max = options.Range[1], options.Range[2]
					local increment = options.Increment
					local range = max - min

					if range <= 0 or increment <= 0 then
						warn("❌ Invalid range/increment", range, increment)
						return
					end

					local tickCount = math.floor(range / increment) + 1
					if tickCount < 2 then
						return
					end

					task.wait()

					local width = ticksFrame.AbsoluteSize.X
					local height = ticksFrame.AbsoluteSize.Y

					local spacing = width / (tickCount - 1)

					local existingTicks = {}
					for _, child in ipairs(ticksFrame:GetChildren()) do
						if child:IsA("Frame") and child ~= template then
							table.insert(existingTicks, child)
						end
					end

					for i = 0, tickCount - 1 do
						local tick = existingTicks[i + 1] or template:Clone()
						tick.Visible = true
						tick.AnchorPoint = Vector2.new(0.5, 0.5)
						tick.BorderSizePixel = 0

						tick.Parent = ticksFrame

						local finalPos = UDim2.fromOffset(i * spacing, height / 1.5)
						tweenservice
							:Create(tick, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								Position = finalPos,
								BackgroundTransparency = 0.85,
							})
							:Play()
					end

					for i = tickCount + 1, #existingTicks do
						existingTicks[i]:Destroy()
					end
				end

				if Options.ShowTicks and Options.Increment > 4 then
					if not Slider.slide.Ticks:FindFirstChild("_ResizeConnection") then
						local pendingTickRefresh = false
						local conn = Slider.slide.Ticks:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
							if resizing then
								if pendingTickRefresh then
									return
								end
								pendingTickRefresh = true
								task.spawn(function()
									repeat
										task.wait(0.1)
									until not resizing or not Slider.slide.Ticks.Parent
									pendingTickRefresh = false
									if Slider.slide.Ticks.Parent then
										BuildTicks(Slider.slide, Options)
									end
								end)
								return
							end
							BuildTicks(Slider.slide, Options)
						end)

						local marker = Instance.new("BoolValue")
						marker.Name = "_ResizeConnection"
						marker.Parent = Slider.slide.Ticks
						marker:GetPropertyChangedSignal("Parent"):Connect(function()
							if not marker.Parent then
								conn:Disconnect()
							end
						end)
					end
				end

				local function UpdateSlider(x)
					if dragging then
						local sliderStart = Slider.slide.AbsolutePosition.X
						local sliderWidth = Slider.slide.AbsoluteSize.X
						local range = Options.Range[2] - Options.Range[1]
						local increment = tonumber(Options.Increment)
						if
							sliderWidth <= 0
							or range ~= range
							or range <= 0
							or range == math.huge
							or not increment
							or increment ~= increment
							or increment <= 0
							or increment == math.huge
						then
							return
						end
						local sliderPosition = (x - sliderStart) / sliderWidth
						sliderPosition = math.clamp(sliderPosition, 0, 1)

						local newValue = Options.Range[1] + sliderPosition * range
						newValue = math.floor((newValue - Options.Range[1]) / increment + 0.5) * increment
							+ Options.Range[1]
						newValue = syde:RoundTo(newValue, syde:DecimalPlaces(Options.Increment))

						if newValue ~= Options.Value then
							Options:Set(newValue)
						end
					end
				end
				UpdateSlider()

				Slider.slide.Interact.MouseButton1Down:Connect(function()
					dragging = true
				end)
				Slider.slide.Interact.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch and not activeTouch then
						activeTouch = input
						dragging = true
						UpdateSlider(input.Position.X)
					end
				end)

				Slider.slide.Interact.MouseButton1Up:Connect(function()
					dragging = false
				end)

				trackSliderConnection(userinput.InputEnded, function(input, processed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input == activeTouch then
						dragging = false
						activeTouch = nil
						tweenservice
							:Create(
								Slider.Title,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
								{ TextTransparency = 0.6 }
							)
							:Play()
					end
				end)

				trackSliderConnection(userinput.InputChanged, function(input)
					if
						dragging
						and (
							(activeTouch and input == activeTouch)
							or (not activeTouch and input.UserInputType == Enum.UserInputType.MouseMovement)
						)
					then
						UpdateSlider(input.Position.X)
					end
				end)

				syde:SetSliderGradient(Slider.slide.slideframe, syde.theme.HitBox)
				Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = syde.theme.HitBox
				Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = syde.theme.HitBox
				Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = syde.theme.HitBox
				slider.slideholder.Size = UDim2.new(1, -30, 0, slider.slideholder.UIListLayout.AbsoluteContentSize.Y)
				local ss = slider.slideholder.UIListLayout.AbsoluteContentSize.Y
				slider.Size = UDim2.new(1, -35, 0, ss + 20)

				trackSliderConnection(syde.Comms.Event, function(p, color)
					if p == "HitBox" then
						syde:SetSliderGradient(Slider.slide.slideframe, color)
						Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = color
						Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = color
						Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = color
					end
				end)

				function Options:Set(NewVal, skipSave)
					local range = Options.Range[2] - Options.Range[1]
					NewVal = tonumber(NewVal)
					if not isFiniteNumber(NewVal) then
						NewVal = Options.StarterValue
					end
					NewVal = math.clamp(NewVal, Options.Range[1], Options.Range[2])
					NewVal = math.floor((NewVal - Options.Range[1]) / Options.Increment + 0.5) * Options.Increment
						+ Options.Range[1]
					NewVal = math.clamp(
						syde:RoundTo(NewVal, syde:DecimalPlaces(Options.Increment)),
						Options.Range[1],
						Options.Range[2]
					)
					local sliderPosition = (NewVal - Options.Range[1]) / range

					Slider.slide.slideframe:TweenSize(
						UDim2.new(sliderPosition, 0, 1, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quint,
						0.55,
						true
					)

					syde:registerLoadTween(
						Slider.slide.slideframe,
						{ Size = UDim2.new(sliderPosition, 0, 1, 0) },
						{ Size = UDim2.new(0, 100, 1, 0) },
						TweenInfo.new(0.85, Enum.EasingStyle.Quint)
					)

					local decimalPlaces = syde:DecimalPlaces(Options.Increment)
					Slider.v.Text = string.format(
						"<font size='14'>%."
							.. decimalPlaces
							.. "f</font><font color='#434343'>/%."
							.. decimalPlaces
							.. "f</font>",
						NewVal,
						Options.Range[2]
					)

					tweenservice
						:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {
							TextTransparency = 0,
						})
						:Play()

					Options.StarterValue = NewVal
					Options.Value = NewVal

					if type(Options.CallBack) == "function" then
						local success, result = pcall(function()
							Options.CallBack(NewVal)
						end)
						if not success then
							syde:Report("Slider '" .. slider.Name .. "' callback", result)
						end
					end
				end

				syde:AttachSliderInput(Slider, Options)

				Options._frame = slider
				Options.toggle = function(self)
					slider.Visible = not slider.Visible
				end
				Options.remove = function(self)
					slider:Destroy()
				end
				if not primaryOptions then
					primaryOptions = Options
				end

				if syde.ConfigEnabled and Options.Flag then
					syde.Flags[Options.Flag] = Options
					if syde.LoadedConfig and syde.LoadedConfig[Options.Flag] ~= nil then
						Options:Set(syde.LoadedConfig[Options.Flag], true)
					end
				end
			end

			local descLabel = slider.slideholder:FindFirstChild("Desc")

			if descLabel then
				if data.Desc and data.Desc ~= "" then
					descLabel.Text = data.Desc
					descLabel.Visible = true
					descLabel.TextWrapped = true

					local function updateSize()
						local textSize = textservice:GetTextSize(
							descLabel.Text,
							descLabel.TextSize,
							descLabel.Font,
							Vector2.new(descLabel.AbsoluteSize.X, math.huge)
						)

						local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
						local newButtonSize = UDim2.new(
							slider.Size.X.Scale,
							slider.Size.X.Offset,
							0,
							slider.slideholder.AbsoluteSize.Y + slider.title.Size.Y.Offset + textSize.Y + 15
						)

						local descTween = tweenservice:Create(
							descLabel,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Size = newDescSize }
						)
						descTween:Play()

						local ToggleTween = tweenservice:Create(
							slider,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Size = newButtonSize }
						)
						ToggleTween:Play()
					end

					updateSize()

					descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
				else
					descLabel.Visible = false
				end
			end

			if Slider.Block and Slider.varFunc then
				local lastBlocked = nil
				task.spawn(function()
					while slider and slider.Parent do
						local ok, blocked = pcall(function()
							local t = Slider.varFunc(Slider.Block[1])
							if type(t) ~= "table" then
								return true
							end
							return not t[Slider.Block[2]]
						end)
						if ok and blocked ~= lastBlocked then
							lastBlocked = blocked
							slider.slideholder.Interactable = not blocked
							tweenservice
								:Create(slider, TweenInfo.new(0.3), {
									BackgroundTransparency = blocked and 0.8 or 0,
								})
								:Play()
						end
						task.wait(0.2)
					end
				end)
			end

			data._frame = slider
			data.toggle = function(self)
				slider.Visible = not slider.Visible
			end
			data.remove = function(self)
				slider:Destroy()
			end

			if primaryOptions then
				primaryOptions._frame = slider
				primaryOptions.toggle = data.toggle
				primaryOptions.remove = data.remove
				return primaryOptions
			end

			return data
		end

		function initelement:Keybind(Keybind)
			local data = {
				Title = Keybind.Title or Keybind.Name or "Keybind",
				Key = Keybind.Key or Keybind.Default,
				Desc = Keybind.Description or Keybind.Desc or "",
				CallBack = Keybind.Callback or Keybind.CallBack or function() end,
				WaitingForKey = false,
				Hold = false,
				Holding = false,
			}

			local KeyBind = pages.page.KeyBind:Clone()
			KeyBind.Visible = true
			KeyBind.Parent = Page
			KeyBind.title.Text = data.Title
			KeyBind.Name = data.Title
			KeyBind:SetAttribute("Searchable", true)

			local keyText = "NONE"
			if typeof(data.Key) == "EnumItem" then
				keyText = data.Key.Name
			end
			KeyBind.Bind.v.Text = keyText
			tweenservice
				:Create(
					KeyBind.Bind,
					TweenInfo.new(0.55, Enum.EasingStyle.Quint),
					{ Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset) }
				)
				:Play()

			local holdConnection
			local holdLoop
			local keybindInputDisconnect
			local function stopHold()
				local wasActive = data.Hold or holdLoop ~= nil
				data.Hold = false
				if holdConnection then
					holdConnection:Disconnect()
					holdConnection = nil
				end
				if holdLoop then
					holdLoop:Disconnect()
					holdLoop = nil
				end
				if data.Holding and wasActive then
					local ok, failure = pcall(data.CallBack, false)
					if not ok then
						pcall(syde.Report, syde, "Keybind '" .. KeyBind.Name .. "' release callback", failure)
					end
				end
			end
			KeyBind.Destroying:Connect(function()
				data.WaitingForKey = false
				stopHold()
				if keybindInputDisconnect then
					keybindInputDisconnect()
					keybindInputDisconnect = nil
				end
			end)

			KeyBind.interact.MouseButton1Click:Connect(function()
				KeyBind.Bind.v.Text = "..."
				tweenservice
					:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Thickness = 1 })
					:Play()
				data.WaitingForKey = true
			end)

			KeyBind.Bind.v:GetPropertyChangedSignal("TextBounds"):Connect(function()
				tweenservice
					:Create(
						KeyBind.Bind,
						TweenInfo.new(0.55, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset) }
					)
					:Play()
			end)

			local function SetKeybind(keyCode)
				if typeof(keyCode) == "EnumItem" and keyCode ~= Enum.KeyCode.Unknown then
					data.Key = keyCode
					tweenservice
						:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Thickness = 0 })
						:Play()
					KeyBind.Bind.v.Text = keyCode.Name
				else
					data.Key = nil
					KeyBind.Bind.v.Text = "NONE"
				end
				if type(Keybind.OnKeyChanged) == "function" then
					pcall(Keybind.OnKeyChanged, data.Key)
				end
			end

			local _, disconnectInput = syde:AddConnection(userinput.InputBegan, function(input, processed)
				if data.WaitingForKey then
					if syde:IsBindableInput(input) then
						data.WaitingForKey = false
						if input.UserInputType == Enum.UserInputType.Keyboard then
							SetKeybind(input.KeyCode)
						else
							SetKeybind(input.UserInputType)
						end
					end
					return
				end

				if userinput:GetFocusedTextBox() then
					return
				end

				local isMatchingKey = false
				if typeof(data.Key) == "EnumItem" then
					if data.Key.EnumType == Enum.KeyCode and input.KeyCode == data.Key then
						isMatchingKey = true
					elseif data.Key.EnumType == Enum.UserInputType and input.UserInputType == data.Key then
						isMatchingKey = true
					end
				end

				if isMatchingKey then
					if data.Hold then
						return
					end
					data.Hold = true

					holdConnection = input.Changed:Connect(function(prop)
						if prop == "UserInputState" then
							if input.UserInputState == Enum.UserInputState.End then
								data.Hold = false
								if holdConnection then
									holdConnection:Disconnect()
									holdConnection = nil
								end
							end
						end
					end)

					local success, result = pcall(data.CallBack)
					if not data.Holding then
						if not success then
							syde:Report("Keybind '" .. KeyBind.Name .. "' callback", result)
						end
					else
						if data.Hold then
							holdLoop = runservice.RenderStepped:Connect(function()
								if not data.Hold or not KeyBind.Parent or syde._destroyed then
									stopHold()
									return
								end
								local callbackOk, callbackFailure = pcall(data.CallBack, false)
								if not callbackOk then
									pcall(
										syde.Report,
										syde,
										"Keybind '" .. KeyBind.Name .. "' hold callback",
										callbackFailure
									)
									stopHold()
								end
							end)
						end
					end
				end
			end)

			keybindInputDisconnect = disconnectInput
			data._frame = KeyBind
			data.toggle = function(self)
				KeyBind.Visible = not KeyBind.Visible
			end
			data.remove = function(self)
				KeyBind:Destroy()
			end
			data.Set = function(self, newKey)
				SetKeybind(newKey)
			end

			return data
		end

		function initelement:TextInput(TextInput)
			local data = {
				Title = TextInput.Title or TextInput.Name or "Text Input",
				PlaceHolder = TextInput.PlaceHolder
					or TextInput.BackGrountText
					or TextInput.Placeholder
					or "Enter text...",
				NumbersOnly = TextInput.NumberOnly or false,
				ClearOnLost = TextInput.ClearOnLost == nil and (TextInput.TextDisappear ~= false)
					or TextInput.ClearOnLost,
				CallBack = TextInput.Callback or TextInput.CallBack,
				Default = TextInput.Default,
			}

			local textinput = pages.page.Input:Clone()
			textinput.Visible = true
			textinput.Parent = Page
			textinput.Name = data.Title
			textinput.title.Text = data.Title
			textinput.TextFrame.TextBox.PlaceholderText = data.PlaceHolder
			textinput:SetAttribute("Searchable", true)

			local textBox = textinput.TextFrame.TextBox
			local defaultHeight = 32

			local ignoreNextClear = false

			textinput.TextFrame.Enter.MouseEnter:Connect(function()
				tweenservice
					:Create(
						textinput.TextFrame.Enter,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
						{ TextColor3 = Color3.fromRGB(255, 255, 255) }
					)
					:Play()
			end)

			textinput.TextFrame.Enter.MouseLeave:Connect(function()
				tweenservice
					:Create(
						textinput.TextFrame.Enter,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
						{ TextColor3 = Color3.fromRGB(40, 40, 40) }
					)
					:Play()
			end)

			textBox:GetPropertyChangedSignal("Text"):Connect(function()
				if data.NumbersOnly then
					textBox.Text = textBox.Text:gsub("%D", "")
				end

				textBox.Size = UDim2.new(1, -60, 0, defaultHeight + 40)

				local textSize = game:GetService("TextService"):GetTextSize(
					textBox.Text,
					textBox.TextSize,
					textBox.Font,
					Vector2.new(textBox.AbsoluteSize.X, math.huge)
				)

				if textBox.Text == "" then
					textBox.Size = UDim2.new(1, -60, 0, math.max(defaultHeight))
				else
					local newHeight = math.min(textSize.Y + 18, 120 + 50)
					textBox.Size = UDim2.new(1, -60, 0, newHeight)
				end
			end)

			textinput.TextFrame:GetPropertyChangedSignal("Size"):Connect(function()
				local newHeight = textinput.TextFrame.Size.Y.Offset
				local extraHeight = 32

				tweenservice
					:Create(
						textinput,
						TweenInfo.new(0.7, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(1, -35, 0, newHeight + extraHeight + 35) }
					)
					:Play()
			end)

			textBox:GetPropertyChangedSignal("Size"):Connect(function()
				local newHeight = textBox.Size.Y.Offset
				local totalHeight = math.max(newHeight, defaultHeight)

				tweenservice
					:Create(
						textinput.TextFrame,
						TweenInfo.new(0.7, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(1, -60, 0, totalHeight + 0) }
					)
					:Play()
			end)

			local function ProcessInput(text)
				local success, errorMsg = pcall(function()
					data.CallBack(text)
				end)
				if not success then
					syde:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
				end
			end

			textBox.FocusLost:Connect(function(enterPressed)
				if not enterPressed then
					return
				end

				local success, errorMsg = pcall(function()
					data.CallBack(textBox.Text)
				end)
				if not success then
					syde:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
				end

				if data.ClearOnLost then
					task.defer(function()
						textBox.Text = ""
						textBox.Size = UDim2.new(1, -60, 0, math.max(defaultHeight))
					end)
				else
					textBox.ClearTextOnFocus = false
				end
			end)

			textinput.TextFrame.Enter.MouseButton1Click:Connect(function()
				local success, errorMsg = pcall(function()
					data.CallBack(textBox.Text)
				end)
				if not success then
					syde:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
				end

				if data.ClearOnLost then
					task.defer(function()
						textBox.Text = ""
						textBox.Size = UDim2.new(1, -60, 0, math.max(defaultHeight))
					end)
				else
					textBox.ClearTextOnFocus = false
				end
			end)

			if data.Default ~= nil and tostring(data.Default) ~= "" then
				textBox.Text = tostring(data.Default)
			end

			data._frame = textinput
			data._textBox = textBox
			data.toggle = function(self)
				textinput.Visible = not textinput.Visible
			end
			data.remove = function(self)
				textinput:Destroy()
			end
			data.Set = function(self, val)
				textBox.Text = tostring(val or "")
				if data.CallBack then
					data.CallBack(textBox.Text)
				end
			end

			return data
		end

		function initelement:EnchancedView(View)
			local Viewdata = {
				Title = View.Title or "3D View",
				Object = View.Object,
				UserRotate = View.UserRotate or false,
				AutoRotate = View.AutoRotate ~= false,
			}

			local EnchancedView = pages.page["3DView"]:Clone()
			EnchancedView.Visible = true
			EnchancedView.Parent = Page
			EnchancedView.Title.Text = Viewdata.Title
			EnchancedView:SetAttribute("Searchable", true)

			local Viewport = EnchancedView.ViewFrame.ViewportFrame
			local Camera = Instance.new("Camera")
			Camera.Parent = Viewport
			Viewport.CurrentCamera = Camera

			local ObjectClone = Viewdata.Object:Clone()
			ObjectClone.Parent = Viewport

			if ObjectClone:IsA("Model") then
				ObjectClone:PivotTo(CFrame.new(0, 0, 0))
			else
				ObjectClone.CFrame = CFrame.new(0, 0, 0)
			end

			if ObjectClone:IsA("BasePart") then
				ObjectClone.Anchored = true
			elseif ObjectClone:IsA("Model") then
				for _, part in ipairs(ObjectClone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = true
					end
				end
			end

			if Viewdata.UserRotate == false then
				tweenservice
					:Create(EnchancedView.ViewFrame.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
						ImageTransparency = 1,
					})
					:Play()
			end

			local primaryPart
			local size
			local center

			if ObjectClone:IsA("BasePart") then
				size = ObjectClone.Size
				ObjectClone.CFrame = CFrame.new(0, 0, 0)
			elseif ObjectClone:IsA("Model") then
				local cf, boundsSize = ObjectClone:GetBoundingBox()
				size = boundsSize

				ObjectClone:PivotTo(CFrame.new(0, 0, 0))

				task.defer(function()
					ObjectClone:PivotTo(CFrame.new(0, 0, 0))
				end)
			end

			local maxDimension = math.max(size.X, size.Y, size.Z)
			local distance = maxDimension * 2
			Camera.CFrame = CFrame.new(Vector3.new(0, 0, distance), Vector3.new(0, 0, 0))

			local icon = EnchancedView.ViewFrame.ImageLabel

			local targetRotationX, targetRotationY = 0, 0
			local currentRotationX, currentRotationY = 0, 0

			local dragging = false
			local dragStartPos
			local lastPos

			task.spawn(function()
				while EnchancedView.Parent do
					currentRotationX += (targetRotationX - currentRotationX) * 0.15
					currentRotationY += (targetRotationY - currentRotationY) * 0.15

					local rotationCFrame = CFrame.Angles(currentRotationX, currentRotationY, 0)
					if ObjectClone:IsA("Model") then
						ObjectClone:PivotTo(rotationCFrame)
					else
						ObjectClone.CFrame = rotationCFrame
					end
					task.wait(0.016)
				end
			end)

			if Viewdata.AutoRotate then
				task.spawn(function()
					while EnchancedView.Parent do
						if not Viewdata.UserRotate or not dragging then
							targetRotationY = targetRotationY + math.rad(0.5)
						end
						task.wait(0.01)
					end
				end)
			end

			if Viewdata.UserRotate == true then
				Viewport.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						lastPos = input.Position
						dragStartPos = input.Position

						tweenservice
							:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
								ImageColor3 = Color3.fromRGB(255, 255, 255),
							})
							:Play()
					end
				end)

				Viewport.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						tweenservice
							:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
								ImageColor3 = Color3.fromRGB(30, 30, 30),
							})
							:Play()
					end
				end)

				Viewport.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						local delta = input.Position - lastPos

						targetRotationY = targetRotationY + delta.X * 0.005
						targetRotationX = math.clamp(targetRotationX - delta.Y * 0.005, -math.pi / 2, math.pi / 2)

						lastPos = input.Position
					end
				end)
			end

			local ZoomFrame = EnchancedView.ViewFrame.Zoom
			local ClipFrame = ZoomFrame.clipframe
			local ScrollFrame = ClipFrame.scroll
			local ZoomAmountLabel = ZoomFrame.Frame.ZoomAmount

			local minZoomDistance = maxDimension * 0.5
			local maxZoomDistance = maxDimension * 10

			local elasticity = 0.4
			local maxOverdrag = 50
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

			local function getScrollLimits()
				local minY = 0
				local diff = ScrollFrame.AbsoluteSize.Y - ClipFrame.AbsoluteSize.Y
				local maxY = diff > 0 and -diff or 0
				return minY, maxY
			end

			local function yToZoom(y)
				local minY, maxY = getScrollLimits()
				if minY == maxY then
					return minZoomDistance
				end
				local t = (y - minY) / (maxY - minY)
				return minZoomDistance + (maxZoomDistance - minZoomDistance) * t
			end

			local function updateZoom(distance)
				distance = math.clamp(distance, minZoomDistance, maxZoomDistance)
				Camera.CFrame = CFrame.new(Vector3.new(0, 0, distance), Vector3.new(0, 0, 0))
				if ZoomAmountLabel then
					tweenservice
						:Create(
							ZoomAmountLabel,
							TweenInfo.new(0.8, Enum.EasingStyle.Elastic),
							{ Position = UDim2.new(1, 0, 0.5, -20) }
						)
						:Play()
					task.wait(0.045)
					ZoomAmountLabel.Text = "x" .. string.format("%.2f", distance)
					ZoomAmountLabel.Position = UDim2.new(1, 0, 0.5, 20)
					tweenservice
						:Create(
							ZoomAmountLabel,
							TweenInfo.new(0.8, Enum.EasingStyle.Elastic),
							{ Position = UDim2.new(1, 0, 0.5, 0) }
						)
						:Play()
				end
			end

			local function visualYFromVirtualY(vy)
				local minY, maxY = getScrollLimits()
				if vy > minY then
					local over = vy - minY
					return math.min(minY + over * elasticity, minY + maxOverdrag)
				elseif vy < maxY then
					local over = vy - maxY
					return math.max(maxY + over * elasticity, maxY - maxOverdrag)
				else
					return vy
				end
			end

			local dragging = false
			local lastPos
			local virtualY = 0

			virtualY = ScrollFrame.Position.Y.Offset

			local initialZoom = 20
			updateZoom(initialZoom)

			local minY, maxY = getScrollLimits()
			local t = (initialZoom - minZoomDistance) / (maxZoomDistance - minZoomDistance)
			local startY = minY + (maxY - minY) * t
			virtualY = startY
			ScrollFrame.Position = UDim2.new(ScrollFrame.Position.X.Scale, ScrollFrame.Position.X.Offset, 0, startY)

			if ZoomAmountLabel then
				ZoomAmountLabel.Text = string.format("%.2f", distance)
			end

			ZoomFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					lastPos = input.Position
				end
			end)

			ZoomFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false

					local minY, maxY = getScrollLimits()
					virtualY = math.clamp(virtualY, maxY, minY)

					game:GetService("TweenService")
						:Create(ScrollFrame, tweenInfo, {
							Position = UDim2.new(
								ScrollFrame.Position.X.Scale,
								ScrollFrame.Position.X.Offset,
								0,
								virtualY
							),
						})
						:Play()

					local distance = yToZoom(virtualY)
					updateZoom(distance)
				end
			end)

			ZoomFrame.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local deltaY = input.Position.Y - lastPos.Y
					lastPos = input.Position

					virtualY = virtualY + deltaY

					local visualY = visualYFromVirtualY(virtualY)
					ScrollFrame.Position =
						UDim2.new(ScrollFrame.Position.X.Scale, ScrollFrame.Position.X.Offset, 0, visualY)

					local minY, maxY = getScrollLimits()
					local clampedY = math.clamp(virtualY, maxY, minY)
					local distance = yToZoom(clampedY)
					updateZoom(distance)
				end
			end)
		end

		function initelement:Paragraph(Paragraph)
			local ParaData = {
				Title = Paragraph.Title or Paragraph.Name or "Paragraph",
				Content = Paragraph.Content or Paragraph.Text or "",
			}

			local Para = pages.page.Paragraph:Clone()
			Para.Visible = true
			Para.Parent = Page
			Para.Frame.title.Text = ParaData.Title
			Para.Content.Text = ParaData.Content
			Para:SetAttribute("Searchable", true)

			Para.Content.Size = UDim2.new(1, -20, 0, Para.Content.TextBounds.Y)

			local function updateSize()
				local textSize = textservice:GetTextSize(
					Para.Content.Text,
					Para.Content.TextSize,
					Para.Content.Font,
					Vector2.new(Para.Content.AbsoluteSize.X, math.huge)
				)

				local newDescSize = UDim2.new(1, -20, 0, textSize.Y)
				local newButtonSize = UDim2.new(Para.Size.X.Scale, Para.Size.X.Offset, 0, textSize.Y + 120)

				local descTween = tweenservice:Create(
					Para.Content,
					TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Size = newDescSize }
				)
				descTween:Play()

				local buttonTween = tweenservice:Create(
					Para,
					TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Size = newButtonSize }
				)
				buttonTween:Play()
			end

			updateSize()

			Para.Content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)

			ParaData._frame = Para
			ParaData.toggle = function(self)
				Para.Visible = not Para.Visible
			end
			ParaData.remove = function(self)
				Para:Destroy()
			end
			ParaData.Set = function(self, newTitle, newContent)
				if newTitle then
					Para.Frame.title.Text = tostring(newTitle)
				end
				if newContent then
					Para.Content.Text = tostring(newContent)
					updateSize()
				end
			end
			return ParaData
		end

		function initelement:Label(Text, Alignment)
			local Label = pages.page.Label:Clone()
			Label.Visible = true
			Label.Parent = Page
			Label.text.Text = tostring(Text or "")
			Label:SetAttribute("Searchable", true)

			if Alignment == "Center" then
				Label.text.TextXAlignment = Enum.TextXAlignment.Center
			elseif Alignment == "Right" then
				Label.text.TextXAlignment = Enum.TextXAlignment.Right
			end

			local labelData = {
				_frame = Label,
				Set = function(self, newText)
					Label.text.Text = tostring(newText or "")
				end,
				toggle = function(self)
					Label.Visible = not Label.Visible
				end,
				remove = function(self)
					Label:Destroy()
				end,
			}
			return labelData
		end

		function initelement:Section(Title, Icon)
			local SectionData = {
				Title = Title or "",
			}

			local Section = pages.page.Section:Clone()
			Section.Visible = true
			Section.Title.Text = SectionData.Title
			Section.Parent = Page
			Section.Title.Position = UDim2.new(0, 0, 0, 0)

			if Icon then
				Section.icon.Image = "rbxassetid://" .. Icon
				Section.Title.Position = UDim2.new(0, 25, 0, 0)
			else
				Section.icon.Visible = false
			end

			SectionData._frame = Section
			SectionData.toggle = function(self)
				Section.Visible = not Section.Visible
			end
			SectionData.remove = function(self)
				Section:Destroy()
			end
			SectionData.Set = function(self, newTitle)
				Section.Title.Text = tostring(newTitle or "")
			end
			return SectionData
		end

		function initelement:Dropdown(Dropdown)
			local data = {
				Title = Dropdown.Title or Dropdown.Name or "Temp Dropdown",
				Options = Dropdown.Options or {},
				StarterOption = Dropdown.Default ~= nil and Dropdown.Default or Dropdown.StarterOption,
				PlaceHolder = Dropdown.PlaceHolder or Dropdown.Placeholder or "Select Option...",
				Multi = Dropdown.Multi or false,
				PlayerSelection = Dropdown.PlayerSelection == true,
				CallBack = Dropdown.Callback or Dropdown.CallBack,
				Flag = Dropdown.Flag,
				Save = Dropdown.Save ~= false,
			}

			local dropdown = pages.page.Dropdown:Clone()
			dropdown.Visible = true
			dropdown.Parent = Page
			dropdown.title.Text = data.Title
			dropdown.Name = data.Title
			dropdown.dropholder.drop.Container.Option.Visible = false
			dropdown.dropholder.drop.Container.Visible = false
			tweenservice
				:Create(
					dropdown.dropholder.drop.Container,
					TweenInfo.new(1, Enum.EasingStyle.Quint),
					{ Size = UDim2.new(0.33, -20, 0.576, -75) }
				)
				:Play()
			dropdown.dropholder.drop.selected.Text = data.PlaceHolder
			dropdown:SetAttribute("Searchable", true)

			local DropOpen = false
			local OptionButton = dropdown.dropholder.drop.Container.Option
			local SelectedOptions = {}
			local SelectedOrder = {}
			local OptionLabels = {}
			local OptionDataByName = {}
			local playerPreview
			if data.PlayerSelection and data.Multi then
				playerPreview = Instance.new("Frame")
				playerPreview.Name = "PlayerSelectionPreview"
				playerPreview.BackgroundTransparency = 1
				playerPreview.ClipsDescendants = true
				playerPreview.Position = UDim2.fromOffset(8, 2)
				playerPreview.Size = UDim2.new(1, -52, 0, 28)
				playerPreview.ZIndex = dropdown.dropholder.drop.selected.ZIndex + 1
				playerPreview.Visible = false
				playerPreview.Parent = dropdown.dropholder.drop
			end

			local function normalizeOption(option)
				if type(option) == "table" then
					local name = option.Name or option.Value or option.Label or option.DisplayName
					return tostring(name or "Option"), option
				end
				local name = tostring(option)
				return name, { Name = name }
			end

			local function optionIndex(name)
				for index, entry in ipairs(data.Options) do
					local entryName = normalizeOption(entry)
					if entryName == name then
						return index
					end
				end
				return math.huge
			end

			local function UpdateCustomLayout()
				local yOffset = 0
				for _, option in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
					if option:IsA("Frame") and option.Visible then
						option.Position = UDim2.new(0, 0, 0, yOffset)
						yOffset = yOffset + option.Size.Y.Offset + 7
					end
				end
				if dropdown.dropholder.drop.Container:IsA("ScrollingFrame") then
					dropdown.dropholder.drop.Container.CanvasSize = UDim2.fromOffset(0, yOffset)
				end
			end

			local function OpenDrop()
				DropOpen = true
				dropdown.dropholder.drop.Container.Visible = true
				dropdown.dropholder.drop.search.Visible = true

				tweenservice
					:Create(dropdown, TweenInfo.new(0.22, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 300) })
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.Container,
						TweenInfo.new(0.22, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(1, -20, 1, -75) }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.v0,
						TweenInfo.new(0.22, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.down,
						TweenInfo.new(0.22, Enum.EasingStyle.Quint),
						{ Rotation = 180 }
					)
					:Play()

				tweenservice
					:Create(
						dropdown.dropholder.drop.search,
						TweenInfo.new(0.22, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.65 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.search.UIStroke,
						TweenInfo.new(0.22, Enum.EasingStyle.Exponential),
						{ Transparency = 0.4 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.search.TextBox,
						TweenInfo.new(0.22, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.search.ImageLabel,
						TweenInfo.new(0.22, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.9 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.search.icon,
						TweenInfo.new(0.22, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.85 }
					)
					:Play()
			end

			local function CloseDrop()
				DropOpen = false
				tweenservice
					:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 95) })
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.Container,
						TweenInfo.new(0.2, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(0.33, -20, 0.576, -75) }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.v0,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Rotation = 0 })
					:Play()

				tweenservice
					:Create(
						dropdown.dropholder.drop.search,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.search.UIStroke,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.search.TextBox,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ TextTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.search.ImageLabel,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						dropdown.dropholder.drop.search.icon,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 1 }
					)
					:Play()

				task.delay(0.2, function()
					if not DropOpen and dropdown.Parent then
						dropdown.dropholder.drop.Container.Visible = false
						dropdown.dropholder.drop.search.Visible = false
					end
				end)
			end

			local removeChipCallbacks = {}
			local playerPreviewRemoveButtons = {}
			local headerHitbox = Instance.new("TextButton")
			headerHitbox.Name = "HeaderHitbox"
			headerHitbox.Text = ""
			headerHitbox.BackgroundTransparency = 1
			headerHitbox.AutoButtonColor = false
			headerHitbox.Size = UDim2.new(1, 0, 0, 42)
			headerHitbox.ZIndex = dropdown.dropholder.drop.down.ZIndex + 2
			headerHitbox.Parent = dropdown.dropholder.drop
			if playerPreview then
				playerPreview.ZIndex = headerHitbox.ZIndex + 1
			end
			headerHitbox.Activated:Connect(function(input)
				if playerPreview and input then
					local pointer = input.Position
					for card, removeSelected in pairs(playerPreviewRemoveButtons) do
						if card.Parent == playerPreview then
							local origin, size = card.AbsolutePosition, card.AbsoluteSize
							if
								pointer.X >= origin.X
								and pointer.X <= origin.X + size.X
								and pointer.Y >= origin.Y
								and pointer.Y <= origin.Y + size.Y
							then
								removeSelected()
								return
							end
						end
					end
				end
				local chip = selectedChipAtPosition(dropdown.dropholder.drop.selectContainer.ScrollingFrame, input)
				if chip and removeChipCallbacks[chip] then
					removeChipCallbacks[chip]()
					return
				end
				if DropOpen then
					CloseDrop()
				else
					OpenDrop()
				end
			end)

			local function AddToSelected(option)
				if not SelectedOptions[option] then
					SelectedOptions[option] = true

					local originalIndex = optionIndex(option)

					local insertIndex = 1
					for i, selected in ipairs(SelectedOrder) do
						local selectedIndex = optionIndex(selected)
						if selectedIndex and selectedIndex < originalIndex then
							insertIndex = i + 1
						else
							break
						end
					end
					table.insert(SelectedOrder, insertIndex, option)
				end
			end

			local function RemoveFromSelected(option)
				if SelectedOptions[option] then
					SelectedOptions[option] = nil
					for i = #SelectedOrder, 1, -1 do
						if SelectedOrder[i] == option then
							table.remove(SelectedOrder, i)
							break
						end
					end
				end

				local selectedContainer = dropdown.dropholder.drop.selectContainer.ScrollingFrame
				for _, child in ipairs(selectedContainer:GetChildren()) do
					if child:IsA("Frame") and child.Name == option then
						child:Destroy()
						break
					end
				end
				removeChipCallbacks[option] = nil
			end

			local function UpdateSelectedText()
				local selectedContainer = dropdown.dropholder.drop.selectContainer.ScrollingFrame
				local placeholderText = dropdown.dropholder.drop.selected
				for _, optionFrame in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
					if optionFrame:IsA("Frame") and optionFrame ~= OptionButton then
						local checkmark = optionFrame:FindFirstChild("ImageLabel")
						if checkmark then
							checkmark.Visible = not data.Multi or SelectedOptions[optionFrame.Name] == true
						end
					end
				end
				selectedContainer.Visible = data.Multi
				dropdown.dropholder.drop.selected.Visible = false
				if playerPreview then
					selectedContainer.Visible = false
					playerPreview.Visible = #SelectedOrder > 0
					placeholderText.Visible = #SelectedOrder == 0
					table.clear(playerPreviewRemoveButtons)
					for _, child in ipairs(playerPreview:GetChildren()) do
						child:Destroy()
					end
					local name = SelectedOrder[1]
					if name then
						local playerData = OptionDataByName[name]
						local hasMore = #SelectedOrder > 1
						local card = Instance.new("TextButton")
						card.Name = name
						card.Text = ""
						card.AutoButtonColor = false
						card.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
						card.BorderSizePixel = 0
						card.ClipsDescendants = true
						card.Size = UDim2.new(1, hasMore and -42 or 0, 0, 28)
						card.ZIndex = headerHitbox.ZIndex + 1
						card.Parent = playerPreview
						local cardCorner = Instance.new("UICorner")
						cardCorner.CornerRadius = UDim.new(0, 8)
						cardCorner.Parent = card
						local avatar = Instance.new("ImageLabel")
						avatar.Name = "Avatar"
						avatar.BackgroundTransparency = 1
						avatar.Image = playerData and playerData.Image or ""
						avatar.Size = UDim2.fromOffset(20, 20)
						avatar.Position = UDim2.fromOffset(5, 4)
						avatar.ZIndex = card.ZIndex + 1
						avatar.Parent = card
						local avatarCorner = Instance.new("UICorner")
						avatarCorner.CornerRadius = UDim.new(1, 0)
						avatarCorner.Parent = avatar
						local nameLabel = Instance.new("TextLabel")
						nameLabel.Name = "PlayerName"
						nameLabel.BackgroundTransparency = 1
						nameLabel.Text = tostring(playerData and playerData.DisplayName or name)
						nameLabel.TextColor3 = Color3.fromRGB(240, 240, 242)
						nameLabel.Font = Enum.Font.GothamMedium
						nameLabel.TextSize = 11
						nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
						nameLabel.TextXAlignment = Enum.TextXAlignment.Left
						nameLabel.Size = UDim2.new(1, -57, 0, 13)
						nameLabel.Position = UDim2.fromOffset(32, 1)
						nameLabel.ZIndex = card.ZIndex + 1
						nameLabel.Parent = card
						local username = Instance.new("TextLabel")
						username.Name = "Username"
						username.BackgroundTransparency = 1
						username.Text = "@" .. tostring(playerData and playerData.Username or name)
						username.TextColor3 = Color3.fromRGB(155, 155, 162)
						username.Font = Enum.Font.Gotham
						username.TextSize = 9
						username.TextTruncate = Enum.TextTruncate.AtEnd
						username.TextXAlignment = Enum.TextXAlignment.Left
						username.Size = UDim2.new(1, -57, 0, 12)
						username.Position = UDim2.fromOffset(32, 14)
						username.ZIndex = card.ZIndex + 1
						username.Parent = card
						local removeHint = Instance.new("TextLabel")
						removeHint.Name = "RemoveHint"
						removeHint.BackgroundTransparency = 1
						removeHint.Text = "×"
						removeHint.TextColor3 = Color3.fromRGB(185, 185, 190)
						removeHint.TextSize = 16
						removeHint.Size = UDim2.fromOffset(20, 28)
						removeHint.Position = UDim2.new(1, -22, 0, 0)
						removeHint.ZIndex = card.ZIndex + 1
						removeHint.Parent = card
						local function removeSelected()
							if not SelectedOptions[name] then
								return
							end
							RemoveFromSelected(name)
							UpdateSelectedText()
							data.Value = table.clone(SelectedOrder)
							if data.CallBack then
								data.CallBack(SelectedOrder)
							end
						end
						playerPreviewRemoveButtons[card] = removeSelected
						card.Activated:Connect(removeSelected)
						if hasMore then
							local more = Instance.new("TextLabel")
							more.Name = "MorePlayers"
							more.BackgroundColor3 = Color3.fromRGB(43, 43, 47)
							more.BorderSizePixel = 0
							more.Text = "+" .. tostring(#SelectedOrder - 1)
							more.TextColor3 = Color3.fromRGB(215, 215, 220)
							more.Font = Enum.Font.GothamMedium
							more.TextSize = 11
							more.Size = UDim2.fromOffset(38, 28)
							more.Position = UDim2.new(1, -38, 0, 0)
							more.ZIndex = playerPreview.ZIndex + 1
							more.Parent = playerPreview
							local moreCorner = Instance.new("UICorner")
							moreCorner.CornerRadius = UDim.new(0, 8)
							moreCorner.Parent = more
						end
					end
					return
				end

				if data.Multi then
					if #SelectedOrder == 0 then
						placeholderText.Visible = true
						selectedContainer.Visible = false
						return
					end

					for _, option in ipairs(SelectedOrder) do
						if not selectedContainer:FindFirstChild(option) then
							local optionGroup = selectedContainer.result:Clone()
							optionGroup.Visible = true
							optionGroup.Name = option
							optionGroup.TextLabel.Text = OptionLabels[option] or option
							local removeButton = optionGroup:FindFirstChild("X")
							if removeButton and removeButton:IsA("GuiButton") then
								removeButton.ZIndex = headerHitbox.ZIndex + 1
								removeButton.Active = true
							end

							removeChipCallbacks[option] = function()
								if not SelectedOptions[option] then
									return
								end
								RemoveFromSelected(option)
								UpdateSelectedText()

								for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
									if opt:IsA("Frame") and opt.Name == option then
										tweenservice
											:Create(
												opt,
												TweenInfo.new(1, Enum.EasingStyle.Exponential),
												{ BackgroundTransparency = 0 }
											)
											:Play()
										tweenservice
											:Create(
												opt,
												TweenInfo.new(1, Enum.EasingStyle.Exponential),
												{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
											)
											:Play()
										tweenservice
											:Create(
												opt.Title,
												TweenInfo.new(1, Enum.EasingStyle.Exponential),
												{ TextTransparency = 0 }
											)
											:Play()
										tweenservice
											:Create(
												opt.UIStroke,
												TweenInfo.new(1, Enum.EasingStyle.Exponential),
												{ Transparency = 0.5 }
											)
											:Play()
										tweenservice
											:Create(
												opt.ImageLabel,
												TweenInfo.new(1, Enum.EasingStyle.Exponential),
												{ ImageTransparency = 0.9 }
											)
											:Play()
									end
								end

								data.Value = table.clone(SelectedOrder)
								if data.CallBack then
									data.CallBack(SelectedOrder)
								end
							end
							optionGroup.X.Activated:Connect(removeChipCallbacks[option])

							optionGroup.Parent = selectedContainer

							task.defer(function()
								local padding = 40
								local textWidth = optionGroup.TextLabel.TextBounds.X
								local totalWidth = textWidth + padding

								optionGroup.TextLabel.Size = UDim2.new(0, textWidth, 1, 0)

								tweenservice
									:Create(
										optionGroup,
										TweenInfo.new(0.67, Enum.EasingStyle.Exponential),
										{ Size = UDim2.new(0, totalWidth, 0, 20) }
									)
									:Play()
							end)
						end
					end
				else
					dropdown.dropholder.drop.selected.Visible = true
					if #SelectedOrder > 0 then
						dropdown.dropholder.drop.selected.Text = SelectedOrder[1]
					else
						dropdown.dropholder.drop.selected.Text = data.PlaceHolder
					end
				end
			end
			if playerPreview then
				playerPreview:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSelectedText)
			end

			dropdown.dropholder.drop.search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				local searchText = dropdown.dropholder.drop.search.TextBox.Text:lower()

				for _, option in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
					if option:IsA("Frame") and option:FindFirstChild("Title") then
						local optionText = option.Title.Text:lower()
						local subtitle = option:FindFirstChild("OptionSubtitle")
						if subtitle and subtitle:IsA("TextLabel") then
							optionText ..= " " .. subtitle.Text:lower()
						end
						local isTemplate = option.Name == "Option"
						local selected = SelectedOptions[option.Name] == true
						local shouldShow = not isTemplate
							and (searchText == "" or optionText:find(searchText, 1, true) or selected)
						option.Visible = shouldShow

						if shouldShow then
							option.BackgroundTransparency = 0
							option.BackgroundColor3 = selected and Color3.fromRGB(39, 39, 39)
								or Color3.fromRGB(33, 33, 33)
							option.Title.TextTransparency = 0
							local stroke = option:FindFirstChildOfClass("UIStroke")
							if stroke then
								stroke.Transparency = selected and 1 or 0.5
							end
							local checkmark = option:FindFirstChild("ImageLabel")
							if checkmark then
								checkmark.ImageTransparency = selected and 0 or 0.9
							end
						end
					end
				end

				UpdateCustomLayout()
			end)

			local function ClearDropdownOptions()
				for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
					if opt:IsA("Frame") and opt ~= OptionButton then
						opt:Destroy()
					end
				end
			end

			local function SetDropdownOptions()
				ClearDropdownOptions()
				table.clear(OptionLabels)
				table.clear(OptionDataByName)
				local starterSet = false
				for _, optionEntry in ipairs(data.Options) do
					local OptionText, optionData = normalizeOption(optionEntry)
					local displayText = tostring(optionData.Label or optionData.DisplayName or OptionText)
					local isPlayerOption = optionData.Player == true or optionData.UserId ~= nil
					local username = tostring(optionData.Username or OptionText)
					if optionData.Offline then
						displayText ..= " × Left"
					end
					OptionLabels[OptionText] = displayText
					OptionDataByName[OptionText] = optionData

					local option = OptionButton:Clone()
					option.Title.Text = displayText
					option.Parent = dropdown.dropholder.drop.Container
					option.Visible = true
					option.Name = OptionText
					option.Size = UDim2.new(1, -6, 0, isPlayerOption and 44 or 36)
					option.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
					option.BackgroundTransparency = 0
					option.BorderSizePixel = 0
					option.Interact.BackgroundTransparency = 1
					option.Title.TextTransparency = 0
					option.Title.TextColor3 = Color3.fromRGB(231, 231, 236)
					option.Title.TextSize = 11
					option.Title.TextXAlignment = Enum.TextXAlignment.Left
					option.Title.Position = UDim2.fromOffset(10, 0)
					option.Title.Size = UDim2.new(1, -18, 1, 0)
					local optionCorner = option:FindFirstChildOfClass("UICorner")
					if optionCorner then
						optionCorner.CornerRadius = UDim.new(0, 8)
					end
					local optionStroke = option:FindFirstChildOfClass("UIStroke")
					if optionStroke then
						optionStroke.Transparency = 0.82
					end
					option.Interact.Size = UDim2.fromScale(1, 1)
					option.Interact.Position = UDim2.fromOffset(0, 0)
					option.Interact.ZIndex = option.ZIndex + 2

					local image =
						tostring(optionData.Image or optionData.Icon or optionData.ImageId or optionData.Decal or "")
					if image ~= "" then
						if not image:find("://", 1, true) then
							image = "rbxassetid://" .. image
						end
						local thumbnail = Instance.new("ImageLabel")
						thumbnail.Name = "OptionImage"
						thumbnail.BackgroundTransparency = 1
						thumbnail.Image = image
						thumbnail.Size = UDim2.fromOffset(isPlayerOption and 30 or 22, isPlayerOption and 30 or 22)
						thumbnail.Position = UDim2.new(0, 8, 0.5, isPlayerOption and -15 or -11)
						thumbnail.ZIndex = option.ZIndex + 2
						thumbnail.Parent = option
						local corner = Instance.new("UICorner")
						corner.CornerRadius = UDim.new(1, 0)
						corner.Parent = thumbnail
						option.Title.Position = UDim2.new(0, isPlayerOption and 44 or 38, 0, isPlayerOption and 3 or 0)
						option.Title.Size = isPlayerOption and UDim2.new(1, -52, 0, 18) or UDim2.new(1, -46, 1, 0)
					end
					if isPlayerOption then
						option.Size = UDim2.new(option.Size.X.Scale, option.Size.X.Offset, 0, 42)
						option.BackgroundTransparency = 0
						option.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
						option.Interact.BackgroundTransparency = 1
						option.Title.TextTransparency = 0
						option.Title.TextColor3 = Color3.fromRGB(235, 235, 238)
						option.Title.ZIndex = option.Interact.ZIndex + 1
						option.Title.Position = UDim2.new(0, image ~= "" and 44 or 10, 0, 3)
						option.Title.Size = UDim2.new(1, image ~= "" and -52 or -18, 0, 18)
						local subtitle = Instance.new("TextLabel")
						subtitle.Name = "OptionSubtitle"
						subtitle.BackgroundTransparency = 1
						subtitle.Font = Enum.Font.Gotham
						subtitle.Text = (optionData.Offline and "× Left · @" or "@") .. username
						subtitle.TextColor3 = optionData.Offline and Color3.fromRGB(235, 115, 115)
							or Color3.fromRGB(170, 170, 176)
						subtitle.TextSize = 10
						subtitle.TextXAlignment = Enum.TextXAlignment.Left
						subtitle.Position = UDim2.new(0, 44, 0, 21)
						subtitle.Size = UDim2.new(1, -52, 0, 15)
						subtitle.ZIndex = option.Title.ZIndex
						subtitle.Parent = option
					end

					if OptionText == data.StarterOption and not starterSet and #SelectedOrder == 0 then
						starterSet = true
						dropdown.dropholder.drop.selected.Text = displayText
						SelectedOptions = { [OptionText] = true }
						SelectedOrder = { OptionText }

						tweenservice
							:Create(option, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(39, 39, 39) })
							:Play()
						tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0 }):Play()
					end

					option.Interact.Activated:Connect(function()
						if data.Multi then
							if SelectedOptions[OptionText] then
								RemoveFromSelected(OptionText)
								tweenservice
									:Create(
										option,
										TweenInfo.new(0.3),
										{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
									)
									:Play()
								tweenservice
									:Create(option.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0.9 })
									:Play()
							else
								AddToSelected(OptionText)
								tweenservice
									:Create(
										option,
										TweenInfo.new(0.3),
										{ BackgroundColor3 = Color3.fromRGB(39, 39, 39) }
									)
									:Play()
								tweenservice
									:Create(option.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0 })
									:Play()
							end

							data.Value = table.clone(SelectedOrder)
							if data.CallBack then
								data.CallBack(SelectedOrder)
							end
						else
							dropdown.dropholder.drop.selected.Text = displayText

							SelectedOptions = { [OptionText] = true }
							SelectedOrder = { OptionText }

							for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
								if opt:IsA("Frame") then
									tweenservice
										:Create(
											opt,
											TweenInfo.new(0.3),
											{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
										)
										:Play()
									tweenservice
										:Create(opt.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0.9 })
										:Play()
								end
							end

							tweenservice
								:Create(option, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(39, 39, 39) })
								:Play()
							tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), { ImageTransparency = 0 }):Play()

							data.Value = OptionText
							if data.CallBack then
								data.CallBack(OptionText)
							end

							CloseDrop()
						end

						UpdateSelectedText()
					end)
				end

				if not starterSet and #SelectedOrder == 0 then
					dropdown.dropholder.drop.selected.Text = data.PlaceHolder
				end

				UpdateSelectedText()
				UpdateCustomLayout()
			end

			if data.Multi and type(data.StarterOption) == "table" then
				for _, value in ipairs(data.StarterOption) do
					AddToSelected(tostring(value))
				end
			end
			SetDropdownOptions()
			data.Value = data.Multi and table.clone(SelectedOrder) or SelectedOrder[1] or data.StarterOption

			function data:Refresh(newOptions, clearCurrent)
				data.Options = newOptions or {}
				table.clear(OptionLabels)
				table.clear(OptionDataByName)
				if clearCurrent then
					SelectedOptions = {}
					SelectedOrder = {}
					data.StarterOption = nil
					dropdown.dropholder.drop.selected.Text = data.PlaceHolder
					local selectedContainer = dropdown.dropholder.drop.selectContainer.ScrollingFrame
					for _, child in ipairs(selectedContainer:GetChildren()) do
						if child:IsA("Frame") and child.Name ~= "result" then
							child:Destroy()
						end
					end
				end
				SetDropdownOptions()
				if clearCurrent and data.Save and data.Flag then
					SaveConfig(game and game.GameId)
				end
				return data
			end

			function data:SetOptions(newOptions, starter)
				data.StarterOption = starter
				data:Refresh(newOptions, false)
				if starter ~= nil then
					data:Set(starter)
				end
				return data
			end

			function data:GetSelected()
				return data.Multi and table.clone(SelectedOrder) or SelectedOrder[1]
			end

			function data:Set(value, state)
				if data.Multi then
					if type(value) == "table" then
						SelectedOptions = {}
						SelectedOrder = {}
						for _, selected in ipairs(value) do
							AddToSelected(tostring(selected))
						end
					elseif state == nil or state == true then
						AddToSelected(tostring(value))
					else
						RemoveFromSelected(tostring(value))
					end
					UpdateSelectedText()
					data.Value = table.clone(SelectedOrder)
					if data.CallBack then
						data.CallBack(SelectedOrder)
					end
				else
					value = tostring(value)
					SelectedOptions = { [value] = true }
					SelectedOrder = { value }
					dropdown.dropholder.drop.selected.Text = OptionLabels[value] or value
					for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
						if opt:IsA("Frame") and opt:FindFirstChild("Title") then
							local isMatch = (opt.Name == value)
							opt.BackgroundColor3 = isMatch and Color3.fromRGB(39, 39, 39) or Color3.fromRGB(33, 33, 33)
							if opt:FindFirstChild("ImageLabel") then
								opt.ImageLabel.ImageTransparency = isMatch and 0 or 0.9
							end
						end
					end
					if data.CallBack then
						data.CallBack(value)
					end
					data.Value = value
				end
			end

			data._frame = dropdown
			data.toggle = function(self)
				dropdown.Visible = not dropdown.Visible
			end
			data.remove = function(self)
				dropdown:Destroy()
			end
			data.tg = nil
			data.Value = data.Multi and table.clone(SelectedOrder) or SelectedOrder[1] or data.StarterOption

			return data
		end

		function initelement:ColorPicker(ColorPicker)
			local data = {
				Title = ColorPicker.Title,
				Color = ColorPicker.Color,
				Color2 = ColorPicker.Color2,
				Linkable = ColorPicker.Linkable,
				Type = ColorPicker.Type or "ColorPicker",
				GradientPath = ColorPicker.GradientPath,
				CallBack = ColorPicker.CallBack,
				Flag = ColorPicker.Flag,
				RainbowUpdating = false,
				RainbowUpdateState = type(ColorPicker._RainbowUpdateState) == "table"
						and ColorPicker._RainbowUpdateState
					or { Updating = false },
			}

			if ColorPicker.Linkable == nil then
				ColorPicker.Linkable = true
			end
			data.Linkable = ColorPicker.Linkable

			local colorpicker = pages.page.ColorPicker:Clone()
			colorpicker.Visible = true
			colorpicker.Parent = Page
			colorpicker.title.Text = data.Title
			colorpicker.Name = data.Title
			colorpicker:SetAttribute("Searchable", true)

			local isLinkable = Instance.new("BoolValue")
			isLinkable.Name = "isLinkable"
			isLinkable.Value = data.Linkable
			isLinkable.Parent = colorpicker

			local HueSat = Instance.new("Color3Value")
			HueSat.Name = "HueSat"
			HueSat.Value = data.Color
			HueSat.Parent = colorpicker

			local Open = false
			local DeBounce = false
			local State = false

			do
				local HueValues = colorpicker.HueValues

				local list = HueValues:FindFirstChildOfClass("UIListLayout")
				if list then
					list:Destroy()
				end

				local ITEMS = {
					HueValues.HEX,
					HueValues.RGB,
					HueValues.Link,
				}

				local GAP = 8
				local ITEM_HEIGHT = 30
				local ITEM_WIDTH = 120
				local HORIZONTAL_THRESHOLD = 260

				local function updateHueValuesLayout()
					if not HueValues.Visible then
						return
					end

					local width = HueValues.AbsoluteSize.X
					local horizontal = width >= HORIZONTAL_THRESHOLD

					local x, y = 0, 0
					local totalHeight = 0

					for _, item in ipairs(ITEMS) do
						item.AnchorPoint = Vector2.new(1, 0)

						if horizontal then
							item.Size = UDim2.new(0, ITEM_WIDTH, 0, ITEM_HEIGHT)
							item.Position = UDim2.new(1, -x, 0, 0)
							x += ITEM_WIDTH + GAP
							totalHeight = ITEM_HEIGHT
						else
							item.Size = UDim2.new(1, -4, 0, ITEM_HEIGHT)
							item.Position = UDim2.new(1, 0, 0, -y)
							y += ITEM_HEIGHT + GAP
							totalHeight = y
						end
					end

					HueValues.Size = UDim2.new(1, -40, 0, totalHeight)
					HueValues.Position = UDim2.new(0.5, 0, 1, -50)

					if Open then
						if data.Type == "Gradient" then
							tweenservice
								:Create(
									colorpicker,
									TweenInfo.new(0.35, Enum.EasingStyle.Quart),
									{ Size = UDim2.new(1, -35, 0, 305 + totalHeight) }
								)
								:Play()
						else
							tweenservice
								:Create(
									colorpicker,
									TweenInfo.new(0.35, Enum.EasingStyle.Quart),
									{ Size = UDim2.new(1, -35, 0, 290 + totalHeight) }
								)
								:Play()
						end
					end
				end

				HueValues:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateHueValuesLayout)
				colorpicker:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateHueValuesLayout)

				colorpicker:SetAttribute("UpdateHueLayout", true)
				colorpicker:GetAttributeChangedSignal("UpdateHueLayout"):Connect(updateHueValuesLayout)

				task.defer(updateHueValuesLayout)
			end

			colorpicker.color.Values.Hue.BackgroundTransparency = 1
			colorpicker.color.Values.Hue.Pin.BackgroundTransparency = 1
			colorpicker.color.Values.Hue.Pin.UIStroke.Transparency = 1
			colorpicker.color.Values.Rainbow.ImageTransparency = 1

			if data.Type == "Gradient" then
				colorpicker.color.Values.Grad.BackgroundTransparency = 1
				colorpicker.color.Values.Grad.Pin1.BackgroundTransparency = 1
				colorpicker.color.Values.Grad.Pin1.UIStroke.Transparency = 1
				colorpicker.color.Values.Grad.Pin2.BackgroundTransparency = 1
				colorpicker.color.Values.Grad.Pin2.UIStroke.Transparency = 1
			end

			colorpicker.color.SVPicker.Pin.BackgroundTransparency = 1
			colorpicker.color.SVPicker.Pin.UIStroke.Transparency = 1
			colorpicker.color.SVPicker.Brightness.BackgroundTransparency = 1
			colorpicker.color.SVPicker.Saturation.BackgroundTransparency = 1

			colorpicker.HueValues.HEX.BackgroundTransparency = 1
			colorpicker.HueValues.HEX.UIStroke.Transparency = 1
			colorpicker.HueValues.HEX.V.HEXBox.TextTransparency = 1
			colorpicker.HueValues.HEX.Copy.ImageTransparency = 1

			colorpicker.HueValues.RGB.BackgroundTransparency = 1
			colorpicker.HueValues.RGB.UIStroke.Transparency = 1
			colorpicker.HueValues.RGB.V.RGBBox.TextTransparency = 1
			colorpicker.HueValues.RGB.Copy.ImageTransparency = 1

			colorpicker.HueValues.Link.BackgroundTransparency = 1
			colorpicker.HueValues.Link.UIStroke.Transparency = 1
			colorpicker.HueValues.Link.Frame.BackgroundTransparency = 1
			colorpicker.HueValues.Link.Frame.ImageLabel.ImageTransparency = 1

			colorpicker.QuickClose.Interactable = false

			local recentContainer = colorpicker.color.Values.Recent
			local spacing = 5
			local frameSize = 12

			local function updateRecentLayout()
				local children = {}
				for _, child in pairs(recentContainer:GetChildren()) do
					if child:IsA("Frame") then
						table.insert(children, child)
					end
				end

				table.sort(children, function(a, b)
					return a.LayoutOrder > b.LayoutOrder
				end)

				local totalWidth = #children * frameSize + math.max(#children - 1, 0) * spacing
				local startX = recentContainer.AbsoluteSize.X - totalWidth

				for _, frame in ipairs(children) do
					tweenservice
						:Create(
							frame,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart),
							{ Position = UDim2.new(0, startX, 0.8, -frame.Size.Y.Offset / 2) }
						)
						:Play()
					startX += frameSize + spacing
				end
			end

			recentContainer.ChildAdded:Connect(function(child)
				if child:IsA("Frame") then
					child.LayoutOrder = os.time()
					updateRecentLayout()
				end
			end)
			recentContainer.ChildRemoved:Connect(updateRecentLayout)
			updateRecentLayout()

			local HSV

			if data.Color then
				HSV = { data.Color:ToHSV() }
			else
				HSV = { 0, 0, 0 }
			end
			local Selected = data.Color
			local HueValue = HSV[1]

			local function TableToColor(Table)
				if type(Table) ~= "table" then
					return Table
				end
				return Color3.fromHSV(Table[1], Table[2], Table[3])
			end

			local function FormatColor(Color, format, precision)
				format = format or "RGB"
				precision = precision or 2

				local formattedColor = ""

				if format == "RGB" then
					return math.round(Color.R * 255)
						.. ","
						.. math.round(Color.G * 255)
						.. ","
						.. math.round(Color.B * 255)
				elseif format == "Hex" then
					formattedColor = string.format(
						"#%02X%02X%02X",
						math.round(Color.R * 255),
						math.round(Color.G * 255),
						math.round(Color.B * 255)
					)

					return formattedColor
				end
			end

			local SVPicker = colorpicker.color.SVPicker
			local HUESlider = colorpicker.color.Values.Hue

			SVPicker.Pin.BackgroundColor3 = data.Color
			HUESlider.Pin.BackgroundColor3 = data.Color

			local Keys
			local ExternalGradient
			local ActivePin = 1
			local GradientFrame = colorpicker.color.Values:FindFirstChild("Grad")
			local HueFrame = colorpicker.color.Values.Hue
			local DraggingPin = nil

			local function updatestuff()
				data.Color = TableToColor(HSV)
				colorpicker.color.glow.ImageColor3 = data.Color
				colorpicker.color.BackgroundColor3 = data.Color

				local newColor = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
				local newColor2 = Color3.fromHSV(HSV[1], 1, 1)

				if data.Type == "Gradient" and Keys and Keys[ActivePin] then
					Keys[ActivePin] = ColorSequenceKeypoint.new(Keys[ActivePin].Time, newColor)

					Keys[1] = ColorSequenceKeypoint.new(0, Keys[2].Value)
					Keys[4] = ColorSequenceKeypoint.new(1, Keys[3].Value)

					data.Color = Keys[2].Value
					data.Color2 = Keys[3].Value

					local seq = ColorSequence.new(Keys)
					if ExternalGradient then
						ExternalGradient.Color = seq
					end
					GradientFrame.Gradient.Color = seq

					GradientFrame.Pin1.BackgroundColor3 = data.Color
					GradientFrame.Pin2.BackgroundColor3 = data.Color2
				end

				HueSat.Value = data.Color

				HUESlider.Pin.BackgroundColor3 = newColor2
				SVPicker.Pin.BackgroundColor3 = newColor
				SVPicker.Pin.Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0)
				HUESlider.Pin.Position = UDim2.new(1 - HSV[1], 0, 0.5, 0)

				local formattedHex = FormatColor(data.Color, "Hex")
				colorpicker.HueValues.HEX.V.HEXBox.PlaceholderText = formattedHex

				local formattedRGB = FormatColor(data.Color, "RGB", 2)
				colorpicker.HueValues.RGB.V.RGBBox.PlaceholderText = formattedRGB
				data.Value = data.Color

				if data.CallBack then
					data.CallBack(data.Color)
				end

				data.Color = data.Color
			end
			updatestuff()

			local newColor = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

			local oldCallback = data.CallBack
			data.CallBack = function(col)
				if data.Type ~= "Gradient" then
					if oldCallback then
						oldCallback(col)
					end
					return
				end

				table.sort(Keys, function(a, b)
					return a.Time < b.Time
				end)

				Keys[1] = ColorSequenceKeypoint.new(0, Keys[2].Value)
				Keys[4] = ColorSequenceKeypoint.new(1, Keys[3].Value)

				data.Color = Keys[2].Value
				data.Color2 = Keys[3].Value

				local seq = ColorSequence.new(Keys)
				ExternalGradient.Color = seq
				GradientFrame.Gradient.Color = seq

				if oldCallback then
					oldCallback(seq, data.Color, data.Color2)
				end
			end

			if data.Type == "Gradient" then
				HueFrame.Visible = true
				GradientFrame.Visible = true

				ExternalGradient = data.GradientPath

				local startCol = data.Color or ExternalGradient.Color.Keypoints[1].Value
				local endCol = data.Color2 or ExternalGradient.Color.Keypoints[#ExternalGradient.Color.Keypoints].Value

				Keys = {
					ColorSequenceKeypoint.new(0, startCol),
					ColorSequenceKeypoint.new(0.2, startCol),
					ColorSequenceKeypoint.new(0.8, endCol),
					ColorSequenceKeypoint.new(1, endCol),
				}

				ActivePin = 2

				GradientFrame.Pin1.BackgroundColor3 = startCol
				GradientFrame.Pin2.BackgroundColor3 = endCol
			end

			local oldCallback = data.CallBack
			data.CallBack = function(col)
				if data.Type ~= "Gradient" then
					if oldCallback then
						oldCallback(col)
					end
					return
				end

				table.sort(Keys, function(a, b)
					return a.Time < b.Time
				end)
				Keys[1] = ColorSequenceKeypoint.new(0, Keys[1].Value)
				Keys[#Keys] = ColorSequenceKeypoint.new(1, Keys[#Keys].Value)

				local seq = ColorSequence.new(Keys)
				ExternalGradient.Color = seq
				GradientFrame.Gradient.Color = seq

				if oldCallback then
					oldCallback(seq)
				end
			end

			if data.Type == "Gradient" then
				local g = GradientFrame
				local UIS = game:GetService("UserInputService")
				local RS = game:GetService("RunService")
				local mouse = game.Players.LocalPlayer:GetMouse()
				local disconnectGradientInputEnded
				local disconnectGradientFocusReleased
				local disconnectGradientHeartbeat

				local function stopGradientDrag()
					DraggingPin = nil
					if disconnectGradientInputEnded then
						disconnectGradientInputEnded()
						disconnectGradientInputEnded = nil
					end
					if disconnectGradientFocusReleased then
						disconnectGradientFocusReleased()
						disconnectGradientFocusReleased = nil
					end
					if disconnectGradientHeartbeat then
						disconnectGradientHeartbeat()
						disconnectGradientHeartbeat = nil
					end
				end

				local function startGradientDrag()
					if disconnectGradientHeartbeat then
						return
					end
					local _, disconnectHeartbeat = syde:AddConnection(RS.Heartbeat, function()
						if not DraggingPin then
							return
						end
						local width = g.AbsoluteSize.X
						if not g.Parent or width <= 0 then
							stopGradientDrag()
							return
						end

						local relX = math.clamp((mouse.X - g.AbsolutePosition.X) / width, 0, 1)
						if DraggingPin == 2 then
							relX = math.clamp(relX, 0, Keys[3].Time - 0.01)
						elseif DraggingPin == 3 then
							relX = math.clamp(relX, Keys[2].Time + 0.01, 1)
						end

						Keys[DraggingPin] = ColorSequenceKeypoint.new(relX, Keys[DraggingPin].Value)
						updateUI()
					end)
					disconnectGradientHeartbeat = disconnectHeartbeat

					local _, disconnectInputEnded = syde:AddConnection(UIS.InputEnded, function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							stopGradientDrag()
						end
					end)
					disconnectGradientInputEnded = disconnectInputEnded

					local _, disconnectFocusReleased = syde:AddConnection(UIS.WindowFocusReleased, stopGradientDrag)
					disconnectGradientFocusReleased = disconnectFocusReleased
				end

				g.Destroying:Connect(stopGradientDrag)

				local function updateUI()
					g.Pin1.Position = UDim2.new(Keys[2].Time, 0, 0.5, 0)
					g.Pin1.BackgroundColor3 = Keys[2].Value

					g.Pin2.Position = UDim2.new(Keys[3].Time, 0, 0.5, 0)
					g.Pin2.BackgroundColor3 = Keys[3].Value

					local seq = ColorSequence.new(Keys)
					ExternalGradient.Color = seq
					g.Gradient.Color = seq
				end

				g.Pin1.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						DraggingPin = 2
						startGradientDrag()
						ActivePin = 2
						local h, s, v = Keys[2].Value:ToHSV()
						HSV[1], HSV[2], HSV[3] = h, s, v
						updatestuff()
					end
				end)

				g.Pin2.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						DraggingPin = 3
						startGradientDrag()
						ActivePin = 3
						local h, s, v = Keys[3].Value:ToHSV()
						HSV[1], HSV[2], HSV[3] = h, s, v
						updatestuff()
					end
				end)

				updateUI()
			end

			local function OpenPicker()
				Open = true
				DeBounce = true
				colorpicker.color.Values.Visible = true
				colorpicker.color.SVPicker.Visible = true

				colorpicker.HueValues.Visible = true
				colorpicker.color.Values.Recent.Visible = true

				colorpicker.interact.Interactable = false
				colorpicker.QuickClose.Interactable = true

				colorpicker.HueValues.Visible = true

				local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")
				if displayGrad then
					displayGrad.Enabled = false
				end

				colorpicker:SetAttribute("UpdateHueLayout", not colorpicker:GetAttribute("UpdateHueLayout"))

				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.95, Enum.EasingStyle.Quart),
						{ Size = UDim2.new(0, 1, 0, 1) }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(35, 35, 35) }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(1, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = data.Color }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.QuickClose,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.glow,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 1 }
					)
					:Play()
				task.wait(0.12)
				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.9, Enum.EasingStyle.Quart),
						{ Size = UDim2.new(1, -40, 0, 160) }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.9, Enum.EasingStyle.Quart),
						{ Position = UDim2.new(0.5, 0, 0, 40) }
					)
					:Play()

				tweenservice
					:Create(
						colorpicker,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(17, 17, 17) }
					)
					:Play()

				tweenservice
					:Create(
						colorpicker.color.UICorner,
						TweenInfo.new(0.8, Enum.EasingStyle.Quart),
						{ CornerRadius = UDim.new(0, 10) }
					)
					:Play()

				tweenservice
					:Create(
						colorpicker.color.Values.Rainbow,
						TweenInfo.new(1, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }
					)
					:Play()

				task.wait(0.6)

				tweenservice
					:Create(
						colorpicker.color.SVPicker.Brightness,
						TweenInfo.new(2, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.SVPicker.Saturation,
						TweenInfo.new(2, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.SVPicker.Pin,
						TweenInfo.new(2, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.SVPicker.Pin.UIStroke,
						TweenInfo.new(2, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }
					)
					:Play()

				task.wait(0.5)
				tweenservice
					:Create(
						colorpicker.color.Values.Hue,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.Values.Hue.Pin,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.Values.Hue.Pin.UIStroke,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }
					)
					:Play()

				if data.Type == "Gradient" then
					tweenservice
						:Create(
							colorpicker.color.Values.Grad,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Grad.Pin1,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Grad.Pin1.UIStroke,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ Transparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Grad.Pin2,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 0 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Grad.Pin2.UIStroke,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ Transparency = 0 }
						)
						:Play()
				end

				tweenservice
					:Create(
						colorpicker.HueValues.HEX,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.9 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.HEX.UIStroke,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ Transparency = 0.4 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.HEX.V.HEXBox,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.HEX.Copy,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }
					)
					:Play()

				task.wait(0.09)
				tweenservice
					:Create(
						colorpicker.HueValues.RGB,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.9 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.RGB.UIStroke,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ Transparency = 0.4 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.RGB.V.RGBBox,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.RGB.Copy,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }
					)
					:Play()
				task.wait(0.09)
				tweenservice
					:Create(
						colorpicker.HueValues.Link,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.9 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.Link.UIStroke,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ Transparency = 0.4 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.Link.Frame,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.Link.Frame.ImageLabel,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }
					)
					:Play()

				for _, v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
					if v:IsA("Frame") then
						task.wait(0.1)
						tweenservice
							:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
							:Play()
					end
				end

				task.wait(0.7)
				DeBounce = false
			end

			colorpicker.interact.MouseButton1Click:Connect(function()
				if DeBounce then
					return
				end
				if not Open then
					Open = true
					OpenPicker()
				end
			end)

			colorpicker.QuickClose.hitbox.MouseEnter:Connect(function()
				tweenservice
					:Create(
						colorpicker.QuickClose,
						TweenInfo.new(0.8, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(0, 70, 0, 3) }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.QuickClose,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(255, 255, 255) }
					)
					:Play()
			end)

			colorpicker.QuickClose.hitbox.MouseLeave:Connect(function()
				tweenservice
					:Create(
						colorpicker.QuickClose,
						TweenInfo.new(0.8, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(0, 60, 0, 3) }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.QuickClose,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(33, 33, 33) }
					)
					:Play()
			end)

			local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

			if data.Type == "Gradient" and displayGrad then
				displayGrad.Enabled = true
				displayGrad.Color = ColorSequence.new(Keys)

				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.new(1, 1, 1) }
					)
					:Play()
			else
				if displayGrad then
					displayGrad.Enabled = false
				end
				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = data.Color }
					)
					:Play()
			end

			local function ClosePicker()
				Open = false
				DeBounce = true
				tweenservice
					:Create(
						colorpicker,
						TweenInfo.new(0.55, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(1, -35, 0, 40) }
					)
					:Play()

				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.7, Enum.EasingStyle.Quart),
						{ Position = UDim2.new(1, -30, 0, 10) }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.55, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(0, 20, 0, 20) }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = data.Color }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.QuickClose,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.glow,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.7 }
					)
					:Play()
				colorpicker.interact.Interactable = true
				colorpicker.QuickClose.Interactable = false

				tweenservice
					:Create(
						colorpicker.color.SVPicker.Brightness,
						TweenInfo.new(2, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.SVPicker.Saturation,
						TweenInfo.new(2, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.SVPicker.Pin,
						TweenInfo.new(1, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.SVPicker.Pin.UIStroke,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }
					)
					:Play()

				tweenservice
					:Create(
						colorpicker.color.Values.Hue,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.Values.Hue.Pin,
						TweenInfo.new(1, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.color.Values.Hue.Pin.UIStroke,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }
					)
					:Play()

				tweenservice
					:Create(
						colorpicker.color.Values.Rainbow,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 1 }
					)
					:Play()

				local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

				if data.Type == "Gradient" and displayGrad then
					displayGrad.Enabled = true
					displayGrad.Color = ColorSequence.new(Keys)

					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = Color3.new(1, 1, 1) }
						)
						:Play()
				else
					if displayGrad then
						displayGrad.Enabled = false
					end
					tweenservice
						:Create(
							colorpicker.color,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ BackgroundColor3 = data.Color }
						)
						:Play()
				end

				if data.Type == "Gradient" then
					tweenservice
						:Create(
							colorpicker.color.Values.Grad,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Grad.Pin1,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Grad.Pin1.UIStroke,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ Transparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Grad.Pin2,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ BackgroundTransparency = 1 }
						)
						:Play()
					tweenservice
						:Create(
							colorpicker.color.Values.Grad.Pin2.UIStroke,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
							{ Transparency = 1 }
						)
						:Play()
				end

				tweenservice
					:Create(
						colorpicker.HueValues.RGB,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.RGB.UIStroke,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.RGB.V.RGBBox,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ TextTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.RGB.Copy,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 1 }
					)
					:Play()

				tweenservice
					:Create(
						colorpicker.HueValues.HEX,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.HEX.UIStroke,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.HEX.V.HEXBox,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ TextTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.HEX.Copy,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 1 }
					)
					:Play()

				tweenservice
					:Create(
						colorpicker.HueValues.Link,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.Link.UIStroke,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.Link.Frame,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }
					)
					:Play()
				tweenservice
					:Create(
						colorpicker.HueValues.Link.Frame.ImageLabel,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 1 }
					)
					:Play()
				colorpicker.HueValues.Visible = false
				for _, v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
					if v:IsA("Frame") then
						tweenservice
							:Create(v, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
							:Play()
					end
				end
				task.wait(1)
				colorpicker.color.SVPicker.Visible = false
				colorpicker.color.Values.Recent.Visible = false
				task.wait(0.7)
				DeBounce = false
			end

			colorpicker.QuickClose.hitbox.MouseButton1Click:Connect(function()
				if DeBounce then
					return
				end
				if Open then
					Open = false
					ClosePicker()
				end
			end)

			for _, v in ipairs(colorpicker.HueValues:GetChildren()) do
				if v:IsA("Frame") then
					for _, v2 in ipairs(v:GetChildren()) do
						if v2:IsA("ImageLabel") then
							v2.MouseEnter:Connect(function()
								tweenservice
									:Create(
										v2,
										TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
										{ ImageColor3 = Color3.fromRGB(255, 255, 255) }
									)
									:Play()
							end)
							v2.MouseLeave:Connect(function()
								tweenservice
									:Create(
										v2,
										TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
										{ ImageColor3 = Color3.fromRGB(66, 66, 66) }
									)
									:Play()
							end)
						end
					end
				end
			end

			syde:OnClick(colorpicker.HueValues.HEX.Copy, function()
				if syde:SetClipboard(FormatColor(data.Color, "Hex")) then
					syde:FlashCopy(colorpicker.HueValues.HEX.Copy)
				end
			end)
			syde:OnClick(colorpicker.HueValues.RGB.Copy, function()
				if syde:SetClipboard(FormatColor(data.Color, "RGB", 2)) then
					syde:FlashCopy(colorpicker.HueValues.RGB.Copy)
				end
			end)

			local function AddRecentColor(newColor)
				local recentFrame = colorpicker.colorPlaceHolder:Clone()
				recentFrame.Visible = true
				recentFrame.Parent = colorpicker.color.Values.Recent
				recentFrame.BackgroundColor3 = newColor

				recentFrame.interact.MouseButton1Click:Connect(function()
					local h, s, v = newColor:ToHSV()
					if s > 0.02 then
						HSV[1] = h
					end
					HSV[2] = s
					HSV[3] = v
					updatestuff()
				end)

				recentFrame.interact.MouseEnter:Connect(function()
					tweenservice
						:Create(
							recentFrame,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0, 20, 0, 20) }
						)
						:Play()
				end)

				recentFrame.interact.MouseLeave:Connect(function()
					tweenservice
						:Create(
							recentFrame,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint),
							{ Size = UDim2.new(0, 12, 0, 12) }
						)
						:Play()
				end)

				local maxRecentColors = 10
				local recentContainer = colorpicker.color.Values.Recent

				local children = recentContainer:GetChildren()
				if #children > maxRecentColors then
					for _, child in ipairs(children) do
						if child:IsA("Frame") then
							child:Destroy()
							break
						end
					end
				end
			end

			local SV, HUE = nil, nil
			local function stopColorDrag(recordRecent)
				local wasDragging = SV ~= nil or HUE ~= nil
				if SV then
					SV:Disconnect()
					SV = nil
				end
				if HUE then
					HUE:Disconnect()
					HUE = nil
				end
				if recordRecent and wasDragging then
					AddRecentColor(data.Color)
				end
			end
			local _, disconnectColorDragInput = syde:AddConnection(userinput.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					stopColorDrag(true)
				end
			end)
			local _, disconnectColorFocus = syde:AddConnection(userinput.WindowFocusReleased, function()
				stopColorDrag(true)
			end)
			colorpicker.Destroying:Connect(function()
				stopColorDrag(false)
				disconnectColorDragInput()
				disconnectColorFocus()
			end)

			syde:AddConnection(SVPicker.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					stopColorDrag(false)
					SV = runservice.RenderStepped:Connect(function()
						local pickerSize = SVPicker.AbsoluteSize
						if pickerSize.X <= 0 or pickerSize.Y <= 0 then
							return
						end
						local mouse = game.Players.LocalPlayer:GetMouse()
						local ColorX = math.clamp(mouse.X - SVPicker.AbsolutePosition.X, 0, pickerSize.X) / pickerSize.X
						local ColorY = math.clamp(mouse.Y - SVPicker.AbsolutePosition.Y, 0, pickerSize.Y) / pickerSize.Y

						HSV[2] = ColorX
						HSV[3] = 1 - ColorY

						updatestuff()
					end)
				end
			end)

			syde:AddConnection(SVPicker.InputEnded, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 and SV then
					stopColorDrag(true)
				end
			end)

			syde:AddConnection(HUESlider.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					stopColorDrag(false)
					HUE = runservice.RenderStepped:Connect(function()
						local sliderWidth = HUESlider.AbsoluteSize.X
						if sliderWidth <= 0 then
							return
						end
						local mouse = game.Players.LocalPlayer:GetMouse()
						local ColorX = math.clamp(mouse.X - HUESlider.AbsolutePosition.X, 0, sliderWidth) / sliderWidth

						HSV[1] = 1 - ColorX

						updatestuff()
					end)
				end
			end)

			syde:AddConnection(HUESlider.InputEnded, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 and HUE then
					stopColorDrag(true)
				end
			end)

			colorpicker.HueValues.HEX.V.HEXBox.FocusLost:Connect(function(Enter)
				if not Enter then
					return
				end

				local hexInput = colorpicker.HueValues.HEX.V.HEXBox.Text

				local success, result = pcall(function()
					return Color3.fromHex(hexInput)
				end)

				if success then
					local Hue, Saturation, Value = result:ToHSV()
					colorpicker.HueValues.HEX.V.HEXBox.Text = ""
					if Saturation > 0.02 then
						HSV[1] = Hue
					end
					HSV[2] = Saturation
					HSV[3] = Value
					updatestuff()
				else
					warn("Failed to convert hex to color:", result)
				end
			end)

			colorpicker.HueValues.RGB.V.RGBBox.FocusLost:Connect(function(Enter)
				if not Enter then
					return
				end

				local rgbInput = colorpicker.HueValues.RGB.V.RGBBox.Text

				local r, g, b = rgbInput:match("^(%d+),%s*(%d+),%s*(%d+)$")

				if r and g and b then
					r, g, b = tonumber(r), tonumber(g), tonumber(b)

					if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
						local color = Color3.fromRGB(r, g, b)

						local Hue, Saturation, Value = color:ToHSV()
						if Saturation > 0.02 then
							HSV[1] = Hue
						end
						HSV[2] = Saturation
						HSV[3] = Value

						colorpicker.HueValues.RGB.V.RGBBox.Text = ""
						updatestuff()
					else
						warn("RGB values must be between 0 and 255.")
					end
				else
					warn("Invalid RGB format. Please use the format 'R,G,B' (e.g., 16,16,16).")
				end
			end)

			local UserInputService = game:GetService("UserInputService")
			local TweenService = game:GetService("TweenService")
			local RunService = game:GetService("RunService")

			local linkDragging = false
			local originalPosition = UDim2.new(0.5, 0, 0, 0)
			local draggedColorPicker = nil
			local followMouseConnection
			local linkableColorPickers = {}
			local lastHoveredPicker = nil

			local function isMouseOver(guiObject)
				local mouse = game.Players.LocalPlayer:GetMouse()
				local pos = guiObject.AbsolutePosition
				local size = guiObject.AbsoluteSize
				return mouse.X >= pos.X and mouse.X <= pos.X + size.X and mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y
			end

			colorpicker.HueValues.Link.Frame.interact.MouseButton1Down:Connect(function()
				linkDragging = true
				draggedColorPicker = colorpicker

				TweenService:Create(
					colorpicker.HueValues.Link.Frame,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
					{ Size = UDim2.new(0, 40, 1, 0) }
				):Play()

				if followMouseConnection then
					followMouseConnection:Disconnect()
				end
				table.clear(linkableColorPickers)
				lastHoveredPicker = nil
				for _, otherPicker in pairs(Page:GetChildren()) do
					local linkable = otherPicker:IsA("Frame") and otherPicker:FindFirstChild("isLinkable")
					if linkable and linkable.Value and otherPicker ~= draggedColorPicker then
						table.insert(linkableColorPickers, otherPicker)
					end
				end
				followMouseConnection = RunService.RenderStepped:Connect(function()
					if not linkDragging then
						if followMouseConnection then
							followMouseConnection:Disconnect()
							followMouseConnection = nil
						end
						return
					end
					local mouse = game.Players.LocalPlayer:GetMouse()
					colorpicker.HueValues.Link.Frame.Position = UDim2.new(
						0,
						mouse.X - colorpicker.AbsolutePosition.X - 50,
						0,
						mouse.Y - colorpicker.AbsolutePosition.Y - 260
					)

					local hoveredPicker
					for _, otherPicker in ipairs(linkableColorPickers) do
						if otherPicker.Parent and isMouseOver(otherPicker) then
							hoveredPicker = otherPicker
							break
						end
					end
					if hoveredPicker ~= lastHoveredPicker then
						local previousStroke = lastHoveredPicker and lastHoveredPicker:FindFirstChild("UIStroke")
						local hoveredStroke = hoveredPicker and hoveredPicker:FindFirstChild("UIStroke")
						if previousStroke then
							previousStroke.Transparency = 1
						end
						if hoveredStroke then
							hoveredStroke.Transparency = 0
						end
						lastHoveredPicker = hoveredPicker
					end
				end)
			end)

			local _, disconnectLinkInput = syde:AddConnection(UserInputService.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and linkDragging then
					linkDragging = false
					if followMouseConnection then
						followMouseConnection:Disconnect()
						followMouseConnection = nil
					end
					if lastHoveredPicker then
						local stroke = lastHoveredPicker:FindFirstChild("UIStroke")
						if stroke then
							stroke.Transparency = 1
						end
						lastHoveredPicker = nil
					end
					table.clear(linkableColorPickers)
					local foundTarget = false

					for _, otherPicker in pairs(Page:GetChildren()) do
						if
							otherPicker:IsA("Frame")
							and otherPicker:FindFirstChild("isLinkable")
							and otherPicker.isLinkable.Value
						then
							if isMouseOver(otherPicker) and otherPicker ~= draggedColorPicker then
								otherPicker.HueSat.Value = draggedColorPicker.HueSat.Value
								updatestuff()
								foundTarget = true
								syde:Toast({
									Content = "Color Linked",
									Duration = 2,
								})
								TweenService:Create(
									colorpicker.HueValues.Link.Frame,
									TweenInfo.new(0.3, Enum.EasingStyle.Quint),
									{ Position = originalPosition }
								):Play()

								TweenService:Create(
									otherPicker.UIStroke,
									TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
									{ Transparency = 1 }
								):Play()

								TweenService:Create(
									colorpicker.HueValues.Link.Frame,
									TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
									{ Size = UDim2.new(1, 0, 1, 0) }
								):Play()
								break
							end
						end
					end

					if not foundTarget then
						TweenService:Create(
							colorpicker.HueValues.Link.Frame,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ Size = UDim2.new(1, 0, 1, 0) }
						):Play()
						TweenService:Create(
							colorpicker.HueValues.Link.Frame,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint),
							{ Position = originalPosition }
						):Play()
					end
				end
			end)
			colorpicker.Destroying:Connect(function()
				stopColorDrag(false)
				if disconnectColorFocus then
					disconnectColorFocus()
				end
				if colorDragInputConnection and colorDragInputConnection.Connected then
					colorDragInputConnection:Disconnect()
				end
				linkDragging = false
				if followMouseConnection then
					followMouseConnection:Disconnect()
					followMouseConnection = nil
				end
				if lastHoveredPicker then
					local stroke = lastHoveredPicker:FindFirstChild("UIStroke")
					if stroke then
						stroke.Transparency = 1
					end
					lastHoveredPicker = nil
				end
				table.clear(linkableColorPickers)
				if disconnectLinkInput then
					disconnectLinkInput()
				end
			end)

			local function updateColorPicker()
				local Hue, Saturation, Value = HueSat.Value:ToHSV()

				if Saturation > 0.02 then
					HSV[1] = Hue
				end
				HSV[2] = Saturation
				HSV[3] = Value

				updatestuff()
			end

			HueSat.Changed:Connect(updateColorPicker)

			local isRainbowEnabled = false
			local huerender
			local rainbowUpdateDepth = 0
			local function updateRainbowColor()
				rainbowUpdateDepth += 1
				data.RainbowUpdating = true
				data.RainbowUpdateState.Updating = true
				local ok, failure = pcall(updatestuff)
				rainbowUpdateDepth -= 1
				data.RainbowUpdating = rainbowUpdateDepth > 0
				data.RainbowUpdateState.Updating = data.RainbowUpdating
				return ok, failure
			end

			local function SetRainbowEffect(enabled, skipSave)
				enabled = enabled == true
				if isRainbowEnabled == enabled then
					return
				end
				isRainbowEnabled = enabled
				data.Rainbow = enabled
				if isRainbowEnabled then
					if not huerender then
						local lastUpdate = os.clock()
						huerender = runservice.Heartbeat:Connect(function()
							if not colorpicker.Parent then
								huerender:Disconnect()
								huerender = nil
								return
							end
							local now = os.clock()
							if now - lastUpdate < 0.08 then
								return
							end
							HueValue = (HueValue + math.min(now - lastUpdate, 0.2) * 0.12) % 1
							lastUpdate = now
							HSV[1] = HueValue
							local ok, failure = updateRainbowColor()
							if not ok then
								warn("[Syde RGB] " .. tostring(failure))
							end
						end)
						tweenservice
							:Create(
								colorpicker.color.Values.Rainbow,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
								{ ImageColor3 = Color3.fromRGB(255, 255, 255) }
							)
							:Play()
					end
				else
					if huerender then
						huerender:Disconnect()
						huerender = nil
					end
					tweenservice
						:Create(
							colorpicker.color.Values.Rainbow,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
							{ ImageColor3 = Color3.fromRGB(62, 62, 62) }
						)
						:Play()
				end
				if not skipSave then
					syde.LoadedConfig = syde.LoadedConfig or {}
					if data.Flag then
						syde.LoadedConfig[data.Flag .. "_Rainbow"] = enabled
					end
					SaveCfg(game and game.GameId)
				end
			end

			function data:SetRainbow(enabled, skipSave)
				SetRainbowEffect(enabled, skipSave)
			end
			colorpicker.color.Values.Rainbow.MouseButton1Click:Connect(function()
				data:SetRainbow(not data.Rainbow)
			end)
			colorpicker.Destroying:Connect(function()
				isRainbowEnabled = false
				if huerender then
					huerender:Disconnect()
					huerender = nil
				end
			end)

			function data:Set(RGBColor, skipSave)
				if typeof(RGBColor) ~= "Color3" then
					return
				end

				data.Color = RGBColor
				local h, s, v = RGBColor:ToHSV()
				HSV[1], HSV[2], HSV[3] = h, s, v

				updatestuff()
			end

			if syde.ConfigEnabled and data.Flag then
				syde.Flags[data.Flag] = data
				if syde.LoadedConfig and syde.LoadedConfig[data.Flag] ~= nil then
					local saved = syde.LoadedConfig[data.Flag]
					local unpacked = syde:ColorUnpack(saved)
					if typeof(unpacked) == "Color3" then
						data:Set(unpacked, true)
					end
				end
				if syde.LoadedConfig and syde.LoadedConfig[data.Flag .. "_Rainbow"] == true then
					data:SetRainbow(true, true)
				end
			end

			data._frame = colorpicker
			data.toggle = function(self)
				colorpicker.Visible = not colorpicker.Visible
			end
			data.remove = function(self)
				colorpicker:Destroy()
			end

			return data
		end

		function initelement:Modal(ModalConfig)
			return syde:Modal(ModalConfig)
		end

		function initelement:Dialog(ModalConfig)
			return syde:Modal(ModalConfig)
		end

		function initelement:AddToggle(ToggleConfig)
			ToggleConfig = ToggleConfig or {}
			local flagName = ToggleConfig.Flag or ToggleConfig.Name or ToggleConfig.Title or "Toggle"
			local defVal = ToggleConfig.Default
			if defVal == nil then
				defVal = ToggleConfig.Value
			end
			if type(defVal) ~= "boolean" then
				defVal = false
			end

			local savedValue = syde.LoadedConfig and syde.LoadedConfig[flagName]
			if type(savedValue) == "boolean" then
				defVal = savedValue
			end

			local userCb = ToggleConfig.Callback or ToggleConfig.CallBack
			local data = self:Toggle({
				Title = ToggleConfig.Name or ToggleConfig.Title or "Toggle",
				Description = ToggleConfig.Description or ToggleConfig.Desc or "",
				Value = defVal,
				Flag = flagName,
				Config = ToggleConfig.Config == true,
				Save = ToggleConfig.Save ~= false,
				CallBack = function(v)
					if userCb then
						userCb(v)
					end
				end,
			})
			local savedKeybind = syde.LoadedConfig and syde.LoadedConfig[flagName .. "_Keybind"]
			if type(savedKeybind) == "string" and data.SetKeybind then
				local key = decodeToggleKeybind(savedKeybind)
				if key then
					data:SetKeybind(key, true)
				end
			end

			data.Type = "Toggle"
			data.Save = ToggleConfig.Save ~= false
			data.Flag = flagName
			data.Value = defVal
			syde.Flags[flagName] = data
			return data
		end

		function initelement:AddSlider(SliderConfig)
			SliderConfig = SliderConfig or {}
			local flagName = SliderConfig.Flag
				or SliderConfig.Name
				or SliderConfig.Title
				or SliderConfig.ValueName
				or "Slider"

			if syde.LoadedConfig and syde.LoadedConfig[flagName] ~= nil then
				SliderConfig.Default = syde.LoadedConfig[flagName]
			end

			SliderConfig.Flag = flagName
			SliderConfig.Save = SliderConfig.Save ~= false
			local origCb = SliderConfig.Callback or SliderConfig.CallBack
			SliderConfig.Callback = function(val)
				if origCb then
					local ok, failure = pcall(origCb, val)
					if not ok then
						syde:Report("Slider '" .. tostring(flagName) .. "' callback", failure)
					end
				end
			end

			local sliderObj = self:Slider(SliderConfig)
			local setValue = sliderObj.Set
			if type(setValue) == "function" then
				sliderObj.Set = function(_, value, skipSave)
					setValue(sliderObj, value, skipSave)
					if not skipSave and SliderConfig.Save and flagName then
						SaveConfig(game and game.GameId)
					end
				end
			end
			sliderObj.Type = "Slider"
			sliderObj.Save = SliderConfig.Save ~= false
			sliderObj.Flag = flagName
			sliderObj.Value = SliderConfig.Default or SliderConfig.Min or 0
			syde.Flags[flagName] = sliderObj
			return sliderObj
		end

		function initelement:AddDropdown(DropdownConfig)
			DropdownConfig = DropdownConfig or {}
			local flagName = DropdownConfig.Flag or DropdownConfig.Name or DropdownConfig.Title or "Dropdown"
			local userCb = DropdownConfig.Callback or DropdownConfig.CallBack

			if syde.LoadedConfig and syde.LoadedConfig[flagName] ~= nil then
				DropdownConfig.Default = syde.LoadedConfig[flagName]
			end

			DropdownConfig.Flag = flagName
			DropdownConfig.Save = DropdownConfig.Save ~= false
			DropdownConfig.Callback = function(val)
				if userCb then
					local ok, failure = pcall(userCb, val)
					if not ok then
						syde:Report("Dropdown '" .. tostring(flagName) .. "' callback", failure)
					end
				end
				if DropdownConfig.Save then
					SaveConfig(game and game.GameId)
				end
			end

			local dropObj = self:Dropdown(DropdownConfig)
			dropObj.Type = "Dropdown"
			dropObj.Save = DropdownConfig.Save ~= false
			dropObj.Flag = flagName
			dropObj.Value = dropObj.Value ~= nil and dropObj.Value or DropdownConfig.Default
			syde.Flags[flagName] = dropObj
			return dropObj
		end

		function initelement:AddPlayerDropdown(PlayerDropdownConfig)
			local config = table.clone(PlayerDropdownConfig or {})
			local playerService = player
			local selectedNames = {}
			local departedPlayers = {}
			local callback = config.Callback or config.CallBack
			local control
			local controlRemoved = false
			local refreshPlayers
			local refreshScheduled = false

			local function schedulePlayerRefresh()
				if controlRemoved or refreshScheduled then
					return
				end
				refreshScheduled = true
				task.defer(function()
					refreshScheduled = false
					if not controlRemoved and refreshPlayers then
						refreshPlayers()
					end
				end)
			end

			local function playerOption(target, offline)
				local userId = tonumber(target.UserId) or 0
				return {
					Name = tostring(target.Name),
					Value = tostring(target.Name),
					Label = tostring(target.DisplayName or target.Name),
					DisplayName = tostring(target.DisplayName or target.Name),
					Username = tostring(target.Name),
					Player = true,
					Image = userId > 0 and string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48", userId)
						or "",
					UserId = userId,
					Offline = offline == true,
				}
			end

			local function getOptions()
				local options, onlineNames = {}, {}
				for _, target in ipairs(playerService:GetPlayers()) do
					if not departedPlayers[target.Name] then
						onlineNames[target.Name] = true
						table.insert(options, playerOption(target, false))
					end
				end
				for name, target in pairs(departedPlayers) do
					if selectedNames[name] and not onlineNames[name] then
						table.insert(options, playerOption(target, true))
					end
				end
				return options
			end

			local flagName = config.Flag or config.Name or config.Title or "PlayerDropdown"
			local saved = syde.LoadedConfig and syde.LoadedConfig[flagName]
			if type(saved) == "table" then
				for _, name in ipairs(saved) do
					selectedNames[tostring(name)] = true
				end
			elseif type(saved) == "string" then
				selectedNames[saved] = true
			end
			local onlineNames = {}
			for _, target in ipairs(playerService:GetPlayers()) do
				onlineNames[target.Name] = true
			end
			for name in pairs(selectedNames) do
				if not onlineNames[name] then
					departedPlayers[name] = { Name = name, DisplayName = name, UserId = 0 }
				end
			end

			config.Flag = flagName
			config.Options = getOptions()
			config.Multi = config.Multi == true or config.MultipleSelection == true
			config.PlayerSelection = true
			config.Placeholder = config.Placeholder or config.PlaceHolder or "Select players..."
			config.Callback = function(value)
				table.clear(selectedNames)
				if type(value) == "table" then
					for _, name in ipairs(value) do
						selectedNames[tostring(name)] = true
					end
				elseif value ~= nil and value ~= "" then
					selectedNames[tostring(value)] = true
				end
				local activeNames = {}
				for _, target in ipairs(playerService:GetPlayers()) do
					activeNames[target.Name] = true
				end
				local departedChanged = false
				for name in pairs(selectedNames) do
					if not activeNames[name] and not departedPlayers[name] then
						departedPlayers[name] = { Name = name, DisplayName = name, UserId = 0 }
						departedChanged = true
					end
				end
				for name in pairs(departedPlayers) do
					if not selectedNames[name] then
						departedPlayers[name] = nil
						departedChanged = true
					end
				end
				if departedChanged and refreshPlayers then
					schedulePlayerRefresh()
				end
				if callback then
					callback(value)
				end
			end

			control = self:AddDropdown(config)
			refreshPlayers = function()
				if not controlRemoved and control and control.Refresh then
					control:Refresh(getOptions(), false)
				end
			end

			local addedConnection, disconnectAdded = syde:AddConnection(playerService.PlayerAdded, function(joining)
				departedPlayers[joining.Name] = nil
				schedulePlayerRefresh()
			end)
			local removingConnection, disconnectRemoving = syde:AddConnection(
				playerService.PlayerRemoving,
				function(leaving)
					if selectedNames[leaving.Name] then
						departedPlayers[leaving.Name] = {
							Name = leaving.Name,
							DisplayName = leaving.DisplayName,
							UserId = leaving.UserId,
						}
					else
						departedPlayers[leaving.Name] = nil
					end
					schedulePlayerRefresh()
				end
			)
			local removeControl = control.remove
			local disconnectFrameDestroying
			local function cleanupPlayerConnections()
				if controlRemoved then
					return false
				end
				controlRemoved = true
				if disconnectAdded then
					disconnectAdded()
				elseif addedConnection.Connected then
					addedConnection:Disconnect()
				end
				if disconnectRemoving then
					disconnectRemoving()
				elseif removingConnection.Connected then
					removingConnection:Disconnect()
				end
				if disconnectFrameDestroying then
					local disconnect = disconnectFrameDestroying
					disconnectFrameDestroying = nil
					disconnect()
				end
				return true
			end
			if control._frame then
				local _, disconnectDestroying = syde:AddConnection(control._frame.Destroying, cleanupPlayerConnections)
				disconnectFrameDestroying = disconnectDestroying
			end
			control.remove = function(self)
				if not cleanupPlayerConnections() then
					return false
				end
				if removeControl then
					return removeControl(self)
				end
				return true
			end
			return control
		end

		function initelement:AddPlayerMultiDropdown(PlayerDropdownConfig)
			PlayerDropdownConfig = PlayerDropdownConfig or {}
			PlayerDropdownConfig.Multi = true
			return self:AddPlayerDropdown(PlayerDropdownConfig)
		end

		function initelement:PlayerDropdown(PlayerDropdownConfig)
			return self:AddPlayerDropdown(PlayerDropdownConfig)
		end

		function initelement:PlayerMultiDropdown(PlayerDropdownConfig)
			PlayerDropdownConfig = table.clone(PlayerDropdownConfig or {})
			PlayerDropdownConfig.Multi = true
			return self:AddPlayerDropdown(PlayerDropdownConfig)
		end

		function initelement:AddPerformanceOverlay(Options)
			Options = Options or {}
			local performanceToggle = self:AddToggle({
				Name = Options.Name or "Performance Overlay",
				Description = Options.Description or "Show FPS and ping in the top bar",
				Flag = Options.Flag or "syde_performance_overlay",
				Default = Options.Default ~= false,
				Save = Options.Save ~= false,
				Callback = function(enabled)
					syde:SetPerformanceOverlay(enabled)
					if Options.Callback then
						Options.Callback(enabled)
					end
				end,
			})
			syde:SetPerformanceOverlay(performanceToggle.Value)
			return performanceToggle
		end

		function initelement:AddButton(ButtonConfig)
			ButtonConfig = ButtonConfig or {}
			return self:Button({
				Title = ButtonConfig.Name or ButtonConfig.Title or "Button",
				Description = ButtonConfig.Description or ButtonConfig.Desc or "",
				Type = ButtonConfig.Type or "Default",
				HoldTime = ButtonConfig.HoldTime or 3,
				CallBack = ButtonConfig.Callback or ButtonConfig.CallBack,
			})
		end

		function initelement:AddParagraph(a, b, c)
			local title, content
			if type(a) == "table" then
				title = a.Title or a.Name or "Paragraph"
				content = a.Content or a.Text or ""
			else
				title = tostring(a or "")
				content = tostring(b or "")
			end
			return self:Paragraph({
				Title = title,
				Content = content,
			})
		end

		function initelement:AddPbind(PBindConfig)
			PBindConfig = PBindConfig or {}
			local name = PBindConfig.Name or "Position"
			local flagName = PBindConfig.Flag or name
			local defX = tostring(PBindConfig.DefaultX or "")
			local defY = tostring(PBindConfig.DefaultY or "")
			local defZ = tostring(PBindConfig.DefaultZ or "")

			if syde.LoadedConfig and syde.LoadedConfig[flagName] ~= nil then
				local saved = syde.LoadedConfig[flagName]
				if type(saved) == "table" then
					defX = tostring(saved.X or defX)
					defY = tostring(saved.Y or defY)
					defZ = tostring(saved.Z or defZ)
				end
			end

			local cb = PBindConfig.Callback or PBindConfig.CallBack or function() end

			local pbindFrame = pages.page.Input:Clone()
			pbindFrame.Visible = true
			pbindFrame.Parent = Page
			pbindFrame.Name = name
			pbindFrame.title.Text = name
			pbindFrame:SetAttribute("Searchable", true)

			if pbindFrame:FindFirstChild("TextFrame") then
				pbindFrame.TextFrame.Visible = false
			end

			local coordsHolder = Instance.new("Frame")
			coordsHolder.Name = "CoordsHolder"
			coordsHolder.BackgroundTransparency = 1
			coordsHolder.Size = UDim2.new(0, 240, 0, 32)
			coordsHolder.Position = UDim2.new(1, -250, 0.5, -16)
			coordsHolder.Parent = pbindFrame

			local layout = Instance.new("UIListLayout")
			layout.FillDirection = Enum.FillDirection.Horizontal
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			layout.VerticalAlignment = Enum.VerticalAlignment.Center
			layout.Padding = UDim.new(0, 6)
			layout.Parent = coordsHolder

			local boxes = {}
			local pbindObj = {
				ValueX = defX,
				ValueY = defY,
				ValueZ = defZ,
				Type = "Pbind",
				Save = PBindConfig.Save ~= false,
				Flag = flagName,
				_frame = pbindFrame,
			}

			local function createCoordBox(lblText, defVal, keyName)
				local boxContainer = Instance.new("Frame")
				boxContainer.Name = lblText .. "Box"
				boxContainer.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
				boxContainer.Size = UDim2.new(0, 72, 0, 28)
				boxContainer.Parent = coordsHolder

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 6)
				corner.Parent = boxContainer

				local stroke = Instance.new("UIStroke")
				stroke.Color = Color3.fromRGB(50, 50, 50)
				stroke.Transparency = 0.5
				stroke.Parent = boxContainer

				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Size = UDim2.new(0, 16, 1, 0)
				lbl.Position = UDim2.new(0, 5, 0, 0)
				lbl.Font = Enum.Font.GothamBold
				lbl.Text = lblText .. ":"
				lbl.TextColor3 = syde.theme.Accent or Color3.fromRGB(255, 151, 227)
				lbl.TextSize = 12
				lbl.Parent = boxContainer

				local tb = Instance.new("TextBox")
				tb.BackgroundTransparency = 1
				tb.Size = UDim2.new(1, -24, 1, 0)
				tb.Position = UDim2.new(0, 22, 0, 0)
				tb.Font = Enum.Font.Gotham
				tb.Text = defVal
				tb.PlaceholderText = "0"
				tb.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
				tb.TextColor3 = Color3.fromRGB(255, 255, 255)
				tb.TextSize = 12
				tb.ClearTextOnFocus = false
				tb.Parent = boxContainer

				local function fireCallback()
					pbindObj.ValueX = boxes.X and boxes.X.Text or ""
					pbindObj.ValueY = boxes.Y and boxes.Y.Text or ""
					pbindObj.ValueZ = boxes.Z and boxes.Z.Text or ""
					cb(pbindObj.ValueX, pbindObj.ValueY, pbindObj.ValueZ)
					SaveCfg(game and game.GameId)
				end

				tb.FocusLost:Connect(fireCallback)
				tb:GetPropertyChangedSignal("Text"):Connect(function()
					local cleaned = tb.Text:gsub("[^0-9%.%-]", "")
					if tb.Text ~= cleaned then
						tb.Text = cleaned
					end
				end)

				boxes[lblText] = tb
			end

			createCoordBox("X", defX, "ValueX")
			createCoordBox("Y", defY, "ValueY")
			createCoordBox("Z", defZ, "ValueZ")

			function pbindObj:Set(x, y, z)
				if x ~= nil and boxes.X then
					boxes.X.Text = tostring(x)
					pbindObj.ValueX = tostring(x)
				end
				if y ~= nil and boxes.Y then
					boxes.Y.Text = tostring(y)
					pbindObj.ValueY = tostring(y)
				end
				if z ~= nil and boxes.Z then
					boxes.Z.Text = tostring(z)
					pbindObj.ValueZ = tostring(z)
				end
				cb(pbindObj.ValueX, pbindObj.ValueY, pbindObj.ValueZ)
				SaveCfg(game and game.GameId)
			end

			function pbindObj:toggle()
				pbindFrame.Visible = not pbindFrame.Visible
			end

			function pbindObj:remove()
				pbindFrame:Destroy()
			end

			syde.Flags[flagName] = pbindObj
			return pbindObj
		end

		function initelement:AddBind(BindConfig)
			BindConfig = BindConfig or {}
			local flagName = BindConfig.Flag or BindConfig.Name or BindConfig.Title or "Bind"
			local key = BindConfig.Default or BindConfig.Key or Enum.KeyCode.Unknown

			if syde.LoadedConfig and syde.LoadedConfig[flagName] ~= nil then
				local saved = syde.LoadedConfig[flagName]
				local success, keyEnum = pcall(function()
					return Enum.KeyCode[saved] or Enum.UserInputType[saved]
				end)
				if success and keyEnum then
					key = keyEnum
				elseif typeof(saved) == "string" and Enum.KeyCode[saved] then
					key = Enum.KeyCode[saved]
				end
			end

			local cb = BindConfig.Callback or BindConfig.CallBack or function() end
			local name = BindConfig.Name or BindConfig.Title or "Bind"
			local bindObj

			local bindData = self:Keybind({
				Title = name,
				Key = key,
				Flag = flagName,
				Description = BindConfig.Description or "",
				Save = BindConfig.Save ~= false,
				OnKeyChanged = function(newKey)
					if bindObj then
						bindObj.Value = typeof(newKey) == "EnumItem" and newKey.Name or "NONE"
						bindObj.Key = newKey
					end
					if BindConfig.Save ~= false then
						SaveCfg(game and game.GameId)
					end
				end,
				CallBack = cb,
			})

			bindObj = {
				Type = "Bind",
				Save = BindConfig.Save ~= false,
				Flag = flagName,
				Value = typeof(key) == "EnumItem" and key.Name or tostring(key or "NONE"),
				Key = key,
				_frame = bindData and bindData._frame or nil,
				Set = function(self, newKey)
					if typeof(newKey) == "string" then
						local success, keyEnum = pcall(function()
							return Enum.KeyCode[newKey] or Enum.UserInputType[newKey]
						end)
						if success and keyEnum then
							newKey = keyEnum
						end
					end
					if bindData and bindData.Set then
						bindData:Set(newKey)
					end
					self.Value = typeof(newKey) == "EnumItem" and newKey.Name or "NONE"
					self.Key = newKey
				end,
				toggle = function(self)
					if bindData and bindData._frame then
						bindData._frame.Visible = not bindData._frame.Visible
					end
				end,
				remove = function(self)
					if bindData and bindData._frame then
						bindData._frame:Destroy()
					end
				end,
			}

			syde.Flags[flagName] = bindObj
			return bindObj
		end

		function initelement:AddTextbox(TextboxConfig)
			TextboxConfig = TextboxConfig or {}
			local name = TextboxConfig.Name or TextboxConfig.Title or "Textbox"
			local flagName = TextboxConfig.Flag or name
			local def = TextboxConfig.Default ~= nil and tostring(TextboxConfig.Default) or ""

			if syde.LoadedConfig and syde.LoadedConfig[flagName] ~= nil then
				def = tostring(syde.LoadedConfig[flagName])
			end

			local placeholder = TextboxConfig.BackGrountText
				or TextboxConfig.PlaceHolder
				or TextboxConfig.Placeholder
				or "Enter..."
			local clearOnLost = TextboxConfig.TextDisappear ~= false
			local cb = TextboxConfig.Callback or TextboxConfig.CallBack or function() end

			local inputData = self:TextInput({
				Title = name,
				PlaceHolder = placeholder,
				ClearOnLost = clearOnLost,
				Default = def,
				Flag = flagName,
				Save = TextboxConfig.Save ~= false,
				CallBack = function(txt)
					cb(txt)
					SaveCfg(game and game.GameId)
				end,
			})

			local tbObj = {
				Type = "Textbox",
				Save = TextboxConfig.Save ~= false,
				Flag = flagName,
				Value = def,
				_frame = inputData and inputData._frame or nil,
				Set = function(self, val)
					self.Value = tostring(val)
					if inputData and inputData.Set then
						inputData:Set(val)
					else
						cb(tostring(val))
					end
					SaveCfg(game and game.GameId)
				end,
				toggle = function(self)
					if inputData and inputData._frame then
						inputData._frame.Visible = not inputData._frame.Visible
					end
				end,
				remove = function(self)
					if inputData and inputData._frame then
						inputData._frame:Destroy()
					end
				end,
			}

			syde.Flags[flagName] = tbObj
			return tbObj
		end

		function initelement:AddColorpicker(ColorpickerConfig)
			ColorpickerConfig = ColorpickerConfig or {}
			local name = ColorpickerConfig.Name or ColorpickerConfig.Title or "Color Picker"
			local flagName = ColorpickerConfig.Flag or name
			local defColor = ColorpickerConfig.Default or ColorpickerConfig.Color or Color3.fromRGB(255, 255, 255)

			if syde.LoadedConfig and syde.LoadedConfig[flagName] ~= nil then
				local saved = syde.LoadedConfig[flagName]
				defColor = UnpackColor(saved)
			end

			local cb = ColorpickerConfig.Callback or ColorpickerConfig.CallBack or function() end
			local suppressSave = false
			local rainbowState = { Updating = false }
			local pickerData = self:ColorPicker({
				Title = name,
				Color = defColor,
				Flag = flagName,
				Save = ColorpickerConfig.Save ~= false,
				_RainbowUpdateState = rainbowState,
				CallBack = function(col)
					if cb then
						local ok, failure = pcall(cb, col)
						if not ok then
							syde:Report("Colorpicker '" .. tostring(flagName) .. "' callback", failure)
						end
					end
					if not suppressSave and not rainbowState.Updating and ColorpickerConfig.Save ~= false then
						SaveConfig(game and game.GameId)
					end
				end,
			})
			pickerData.Type = "Colorpicker"
			pickerData.Save = ColorpickerConfig.Save ~= false
			pickerData.Flag = flagName
			pickerData.Value = pickerData.Color or defColor
			local setColor = pickerData.Set
			pickerData.Set = function(_, color, skipSave)
				if typeof(color) ~= "Color3" then
					return false
				end
				suppressSave = true
				local ok, failure = pcall(setColor, pickerData, color, skipSave)
				suppressSave = false
				if not ok then
					syde:Report("Colorpicker '" .. tostring(flagName) .. "' setter", failure)
					return false
				end
				if not skipSave and pickerData.Save then
					SaveConfig(game and game.GameId)
				end
				return true
			end
			local setRainbow = pickerData.SetRainbow
			pickerData.SetRainbow = function(_, enabled, skipSave)
				if type(setRainbow) ~= "function" then
					return false
				end
				setRainbow(pickerData, enabled, true)
				if not skipSave and pickerData.Save then
					SaveConfig(game and game.GameId)
				end
				return true
			end
			syde.Flags[flagName] = pickerData
			return pickerData
		end

		initelement.AddColorPicker = initelement.AddColorpicker

		function initelement:AddMultiColorpicker(config)
			config = config or {}
			local name = config.Name or config.Title or "Multi Color Picker"
			local flagName = config.Flag or name
			local entries = config.Pickers or config.Colors or {}
			if type(entries) ~= "table" then
				entries = {}
			end
			local callback = config.Callback or config.CallBack or function() end
			local savedColors = syde.LoadedConfig and syde.LoadedConfig[flagName]
			local savedRainbow = syde.LoadedConfig and syde.LoadedConfig[flagName .. "_Rainbow"]
			local values = {}
			local pickerData = {
				Type = "MultiColorpicker",
				Name = name,
				Flag = flagName,
				Pickers = {},
				Value = values,
				Save = config.Save ~= false,
			}
			local suppressCallback = true

			local function snapshot()
				local result = {}
				for index, picker in ipairs(pickerData.Pickers) do
					result[index] = picker.Value
				end
				return result
			end

			for index, entry in ipairs(entries) do
				local entryConfig = type(entry) == "table" and entry or { Name = tostring(entry) }
				local entryName = entryConfig.Name or entryConfig.Title or ("Color " .. tostring(index))
				local default = entryConfig.Default or entryConfig.Color
				if type(config.Default) == "table" then
					default = config.Default[index] or default
				end
				if type(savedColors) == "table" and savedColors.R == nil and savedColors[index] ~= nil then
					default = UnpackColor(savedColors[index])
				end
				default = default or Color3.fromRGB(255, 255, 255)

				local slot = { Value = default }
				table.insert(pickerData.Pickers, slot)
				local childFlag = flagName .. "__Color_" .. tostring(index)
				local rainbowState = { Updating = false }
				local picker
				picker = self:ColorPicker({
					Title = tostring(name) .. " · " .. tostring(entryName),
					Color = default,
					Flag = childFlag,
					Save = false,
					_RainbowUpdateState = rainbowState,
					CallBack = function(color)
						slot.Value = color
						values[index] = color
						if not suppressCallback then
							local ok, failure = pcall(callback, index, color, snapshot())
							if not ok then
								syde:Report("Multi colorpicker '" .. tostring(flagName) .. "' callback", failure)
							end
							if pickerData.Save and not rainbowState.Updating then
								SaveConfig(game and game.GameId)
							end
						end
					end,
				})
				local setPickerRainbow = picker.SetRainbow
				picker.SetRainbow = function(_, enabled, skipSave)
					if type(setPickerRainbow) ~= "function" then
						return false
					end
					setPickerRainbow(picker, enabled, true)
					if not skipSave and pickerData.Save then
						SaveConfig(game and game.GameId)
					end
					return true
				end
				slot.Control = picker
				slot.Value = picker.Value or default
				values[index] = slot.Value
				if syde.Flags[childFlag] == picker then
					syde.Flags[childFlag] = nil
				end
				if type(savedRainbow) == "table" and savedRainbow[index] == true and picker.SetRainbow then
					picker:SetRainbow(true, true)
				end
			end

			suppressCallback = false
			pickerData.Set = function(_, index, color, skipSave)
				local slot = pickerData.Pickers[index]
				if not slot or not slot.Control then
					return false
				end
				if type(color) == "table" then
					color = UnpackColor(color)
				end
				if typeof(color) ~= "Color3" then
					return false
				end
				local wasSuppressingCallback = suppressCallback
				suppressCallback = true
				local ok, failure = pcall(slot.Control.Set, slot.Control, color, true)
				suppressCallback = wasSuppressingCallback
				if not ok then
					syde:Report("Multi colorpicker '" .. tostring(flagName) .. "' setter", failure)
					return false
				end
				slot.Value = color
				values[index] = color
				if pickerData.Save and not skipSave then
					SaveConfig(game and game.GameId)
				end
				return true
			end
			pickerData.SetRainbow = function(_, index, enabled, skipSave)
				local slot = pickerData.Pickers[index]
				if not slot or not slot.Control or not slot.Control.SetRainbow then
					return false
				end
				slot.Control:SetRainbow(enabled == true, true)
				if not skipSave and pickerData.Save then
					SaveConfig(game and game.GameId)
				end
				return true
			end
			pickerData.GetValues = snapshot
			pickerData.remove = function()
				for _, slot in ipairs(pickerData.Pickers) do
					if slot.Control and slot.Control.remove then
						slot.Control:remove()
					end
				end
				if syde.Flags[flagName] == pickerData then
					syde.Flags[flagName] = nil
				end
			end
			pickerData.toggle = function()
				local visible = pickerData.Pickers[1]
					and pickerData.Pickers[1].Control
					and pickerData.Pickers[1].Control._frame
					and pickerData.Pickers[1].Control._frame.Visible
				for _, slot in ipairs(pickerData.Pickers) do
					local frame = slot.Control and slot.Control._frame
					if frame then
						frame.Visible = not visible
					end
				end
			end
			if pickerData.Save then
				syde.Flags[flagName] = pickerData
			end
			return pickerData
		end

		initelement.AddMultiColorPicker = initelement.AddMultiColorpicker

		function initelement:ColorLabel(Text, ToChangeColor, Position)
			local Label = pages.page.Label:Clone()
			Label.Visible = true
			Label.Parent = Page
			Label.text.Text = tostring(Text or "")
			Label:SetAttribute("Searchable", true)

			if ToChangeColor then
				Label.text.TextColor3 = ToChangeColor
			else
				Label.text.TextColor3 = syde.theme.Accent or Color3.fromRGB(255, 151, 227)
			end

			if Position == "Center" then
				Label.text.TextXAlignment = Enum.TextXAlignment.Center
			elseif Position == "Right" then
				Label.text.TextXAlignment = Enum.TextXAlignment.Right
			else
				Label.text.TextXAlignment = Enum.TextXAlignment.Left
			end

			local labelObj = {
				_frame = Label,
				Set = function(self, newText, newColor)
					if newText then
						Label.text.Text = tostring(newText)
					end
					if newColor then
						Label.text.TextColor3 = newColor
					end
				end,
				toggle = function(self)
					Label.Visible = not Label.Visible
				end,
				remove = function(self)
					Label:Destroy()
				end,
			}
			return labelObj
		end

		function initelement:AddLabel(Text, Alignment)
			return self:Label(Text, Alignment)
		end

		function initelement:AddLog(Text)
			local Label = pages.page.Label:Clone()
			Label.Visible = true
			Label.Parent = Page
			Label.text.Text = tostring(Text or "")
			Label.text.TextXAlignment = Enum.TextXAlignment.Center
			Label.text.TextColor3 = Color3.fromRGB(200, 200, 200)
			Label:SetAttribute("Searchable", true)

			local logObj = {
				_frame = Label,
				Set = function(self, newText)
					Label.text.Text = tostring(newText or "")
				end,
				toggle = function(self)
					Label.Visible = not Label.Visible
				end,
				remove = function(self)
					Label:Destroy()
				end,
			}
			return logObj
		end

		function initelement:AddSection(Title, Alignment, Height)
			Title = Title or ""
			local Section = pages.page.Section:Clone()
			Section.Visible = true
			Section.Title.Text = Title
			Section.Parent = Page
			Section.Title.Position = UDim2.new(0, 0, 0, 0)
			Section.icon.Visible = false

			if Alignment == "Right" then
				Section.Title.TextXAlignment = Enum.TextXAlignment.Right
			elseif Alignment == "Center" then
				Section.Title.TextXAlignment = Enum.TextXAlignment.Center
			else
				Section.Title.TextXAlignment = Enum.TextXAlignment.Left
			end

			local secObj = {
				_frame = Section,
				Set = function(self, newTitle)
					Section.Title.Text = tostring(newTitle or "")
				end,
				toggle = function(self)
					Section.Visible = not Section.Visible
				end,
				remove = function(self)
					Section:Destroy()
				end,
			}
			return secObj
		end

		function initelement:AddPlayerParagraph(userId)
			userId = userId
				or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.UserId)
				or 0
			local displayName = "Player"
			local username = "Player"

			pcall(function()
				local info = game:GetService("UserService"):GetUserInfosByUserIdsAsync({ userId })
				if info and info[1] then
					displayName = info[1].DisplayName or displayName
					username = info[1].Username or username
				end
			end)

			local para = pages.page.Paragraph:Clone()
			para.Visible = true
			para.Parent = Page
			para.Frame.title.Text = displayName .. " (@" .. username .. ")"
			para.Content.Text = "UserId: " .. tostring(userId)
			para:SetAttribute("Searchable", true)

			local playerObj = {
				_frame = para,
				toggle = function(self)
					para.Visible = not para.Visible
				end,
				remove = function(self)
					para:Destroy()
				end,
			}
			return playerObj
		end

		function initelement:FreeMouseDrp()
			return self:AddDropdown({
				Name = "Unlock Mouse Mode",
				Options = { "ThirdPerson", "FreeMouse" },
				Default = syde.UMouseMode or "ThirdPerson",
				Callback = function(Value)
					syde.UMouseMode = Value
					if syde.FreeMouse then
						syde:UnlockMouse(false)
						task.wait(0.1)
						syde:UnlockMouse(true)
					end
				end,
			})
		end

		function initelement:AddUiBind()
			return self:AddBind({
				Name = "UI Keybind",
				Default = uitoggle or Enum.KeyCode.RightShift,
				Callback = function()
					if ToggleUI then
						ToggleUI()
					end
				end,
			})
		end

		function initelement:AddSmartTheme()
			self:AddColorpicker({
				Name = "Base Accent Color",
				Default = syde.theme.Accent or Color3.fromRGB(255, 151, 227),
				Callback = function(Value)
					syde:UpdateTheme({
						Accent = Value,
						HitBox = Value,
					})
				end,
			})

			self:AddButton({
				Name = "Reset Theme",
				Callback = function()
					syde:UpdateTheme({
						Accent = Color3.fromRGB(255, 151, 227),
						HitBox = Color3.fromRGB(255, 151, 227),
					})
				end,
			})
		end

		for _bn, _bf in pairs(initelement) do
			if type(_bf) == "function" then
				initelement[_bn] = syde:Guard("Building a '" .. tostring(_bn) .. "' element", _bf)
			end
		end

		return initelement
	end
	syde._currentWindow = tbdata
	return tbdata
end

pcall(function()
	if getgenv then
		getgenv().syde = syde
		getgenv().OrionLib = syde
	end
	_G.syde = syde
	_G.OrionLib = syde
end)

return syde
