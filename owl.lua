local Services = {
	Http = game:GetService("HttpService"),
	Insert = game:GetService("InsertService"),
	Players = game:GetService("Players"),
	Run = game:GetService("RunService"),
	Stats = game:GetService("Stats"),
	Text = game:GetService("TextService"),
	Tween = game:GetService("TweenService"),
	UserInput = game:GetService("UserInputService"),
}

local GuiRoot = (gethui and gethui()) or game:GetService("CoreGui")
local uiAsset = game:GetObjects("rbxassetid://123800669522471")[1]
local viewportSize = workspace.CurrentCamera.ViewportSize
local isMobile = Services.UserInput.TouchEnabled or (viewportSize.X < 1024 and viewportSize.Y < 768)
local activeCamera = workspace.CurrentCamera
local isResizing = false
local isLoaded = false

uiAsset.Enabled = false
for _, descendant in ipairs(uiAsset:GetDescendants()) do
	if descendant:IsA("LocalScript") or descendant:IsA("Script") then
		descendant.Disabled = true
	end
end

local Owl = {

	theme = {
		['Accent'] = Color3.fromRGB(255, 151, 227);
		['HitBox'] = Color3.fromRGB(255, 151, 227);
		['DropShadow']   = ColorSequence.new(Color3.fromRGB(0, 0, 0));

	};
	Connections = {};
	Comms = Instance.new('BindableEvent');
	ParentOverride = nil;
	Build = 'Sv0';
	plugins = {};
	ConfigEnabled = true;
	ConfigFolder = 'OwlHub';
	ConfigFile = 'Config';
	Folder = 'OwlHub';
	SaveCfg = true;
	Flags = {};
	SettingsFlags = {};
	LoadedConfig = nil;
	UMouseMode = "ThirdPerson";
	PreserveCameraMode = true;
	maxds = 500;
	minds = 10;
	FreeMouse = true;
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
	};
	SelectedTheme = "Default";
	_currentWindow = nil;
}

function Owl:DeepMerge(target, source)
	for k, v in pairs(source) do
		if type(v) == "table" and type(target[k]) == "table" then
			self:DeepMerge(target[k], v) 
		else
			target[k] = v
		end
	end
end

function Owl:UpdateTheme(Config)
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
				warn(("[UpdateTheme] Type mismatch for key '%s' (expected %s, got %s)"):format(
					key, typeof(self.theme[key]), typeof(value)
					))
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
function Owl:IsBindableInput(input)
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
function Owl:DecimalPlaces(num)
	local str = string.format("%.10f", tonumber(num) or 0)
	str = str:gsub("0+$", "")
	str = str:gsub("%.$", "")
	local dot = string.find(str, "%.", 1, true)
	if not dot then
		return 0
	end
	return #str - dot
end
function Owl:RoundTo(num, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(num * mult + 0.5) / mult
end
function Owl:SetClipboard(text)
	local fn = setclipboard or toclipboard or set_clipboard or writeclipboard or (syn and syn.write_clipboard)
	if fn then
		return (pcall(fn, text))
	end
	return false
end
function Owl:OnClick(object, callback)
	if not object then return end
	local target = object:FindFirstChild("interact") or object:FindFirstChild("Interact") or object
	if target:IsA("GuiButton") then
		target.MouseButton1Click:Connect(callback)
	else
		target.Active = true
		target.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				callback()
			end
		end)
	end
end
function Owl:FlashCopy(icon)
	if not icon then return end
	Services.Tween:Create(icon, TweenInfo.new(0.12, Enum.EasingStyle.Quint), { ImageColor3 = Color3.fromRGB(120, 220, 120) }):Play()
	task.delay(0.4, function()
		Services.Tween:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)
end
function Owl:Report(context, err)
	local message = tostring(err or "unknown error")
	local low = string.lower(message)

	local fix
	if string.find(low, "httpget", 1, true) or string.find(low, "getobjects", 1, true)
		or string.find(low, "failed to load library", 1, true) or string.find(low, "rbxassetid", 1, true) then
		fix = "The UI asset/source failed to download. Re-run it; if it keeps happening your executor is blocking HttpGet/asset loading, or GitHub is serving an old/partial copy (wait ~30s)."
	elseif string.find(low, "not a valid member", 1, true) or string.find(low, "attempt to index nil", 1, true)
		or string.find(low, "index a nil", 1, true) then
		fix = "A UI element is missing - your Source and the UI asset id are out of sync. Re-copy the newest Source and re-grab the UI asset."
	elseif string.find(low, "attempt to call a nil value", 1, true) then
		fix = "A required function is missing - usually an executor that lacks a global like gethui/getgenv/setclipboard. Try an updated/different executor."
	elseif string.find(low, "callback", 1, true) then
		fix = "This came from a callback (your own function), not Owl itself. Check the function attached to that element."
	else
		fix = "Unexpected error - send the screenshot above so it can be looked into."
	end

	warn(table.concat({
		"",
		"----------screenshot this and send it to Owl support------",
		"[ Owl ] " .. tostring(context or "Error"),
		"Problem: " .. message,
		"Fix: " .. fix,
		"------------------------------------------------------------",
		"",
	}, "\n"))
end
function Owl:Guard(context, fn)
	return function(...)
		local res = table.pack(pcall(fn, ...))
		if not res[1] then
			Owl:Report(context, res[2])
			return nil
		end
		return table.unpack(res, 2, res.n)
	end
end
function Owl:AttachSliderInput(Slider, Options)
	local valueLabel = Slider:FindFirstChild("v")
	if not valueLabel or valueLabel:FindFirstChild("ValueInput") then
		return
	end
	local function maxString()
		local dp = Owl:DecimalPlaces(Options.Increment)
		return string.format("%." .. dp .. "f", tonumber(Options.Range[2]) or 0)
	end
	local function renderValue(valueText)
		valueLabel.Text = string.format("<font size='14'>%s</font><font color='#434343'>/%s</font>", valueText, maxString())
	end
	local function renderCurrent()
		local dp = Owl:DecimalPlaces(Options.Increment)
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
	editBox.TextTransparency = 1   -- invisible; live feedback is shown on the label itself
	editBox.TextSize = 14
	editBox.Size = UDim2.fromScale(1, 1)
	editBox.Position = UDim2.fromScale(0, 0)
	editBox.ZIndex = valueLabel.ZIndex + 5
	editBox.Parent = valueLabel

	editBox.Focused:Connect(function()
		editing = true
		editBox.Text = ""      -- box starts empty on click
		renderValue("")        -- value cleared, the "/max" suffix stays visible
	end)

	editBox:GetPropertyChangedSignal("Text"):Connect(function()
		if not editing then return end
		renderValue(editBox.Text)   -- live-update the label as the user types
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
				typed = Owl:RoundTo(typed, Owl:DecimalPlaces(inc))
				typed = math.clamp(typed, low, high)
			end
			Options:Set(typed)
		else
			renderCurrent()
		end
	end)

	return editBox
end

local RunService = game:GetService'RunService'
local activeCamera = workspace.CurrentCamera


do
	local function IsNotNaN(x)
		return x == x
	end
	local continue = IsNotNaN(activeCamera:ScreenPointToRay(0,0).Origin.x)
	while not continue do
		RunService.RenderStepped:wait()
		continue = IsNotNaN(activeCamera:ScreenPointToRay(0,0).Origin.x)
	end
end

local binds = {}
local root = Instance.new('Folder', activeCamera)
root.Name = 'neon'


local GenUid; do -- Generate unique names for RenderStepped bindings
	local id = 0
	function GenUid()
		id = id + 1
		return 'neon::'..tostring(id)
	end
end

local DrawQuad; do
	local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
	local sz = 0.2

	function DrawTriangle(v1, v2, v3, p0, p1) -- I think Stravant wrote this function
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

		local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
		local perp = sqrt((C-A).magnitude^2 - para*para)
		local dif_para = (A - B).magnitude - para

		local st = CFrame.new(B, A)
		local za = CFrame.Angles(pi/2,0,0)

		local cf0 = st

		local Top_Look = (cf0 * za).lookVector
		local Mid_Point = A + CFrame.new(A, B).lookVector * para
		local Needed_Look = CFrame.new(Mid_Point, C).lookVector
		local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

		local ac = CFrame.Angles(0, 0, acos(dot))

		cf0 = cf0 * ac
		if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
			cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
		end
		cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

		local cf1 = st * ac * CFrame.Angles(0, pi, 0)
		if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
			cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
		end
		cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

		if not p0 then
			p0 = Instance.new('Part')
			p0.FormFactor = 'Custom'
			p0.TopSurface = 0
			p0.BottomSurface = 0
			p0.Anchored = true
			p0.CanCollide = false
			p0.Material = 'Glass'
			p0.Size = Vector3.new(sz, sz, sz)
			local mesh = Instance.new('SpecialMesh', p0)
			mesh.MeshType = 2
			mesh.Name = 'WedgeMesh'
		end
		p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
		p0.CFrame = cf0

		if not p1 then
			p1 = p0:clone()
		end
		p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
		p1.CFrame = cf1

		return p0, p1
	end

	function DrawQuad(v1, v2, v3, v4, parts)
		parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
		parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
	end
end
function Owl:BindFrame(frame, properties)
	if binds[frame] then
		return binds[frame].parts
	end

	local uid = GenUid()
	local parts = {}
	local f = Instance.new('Folder', root)
	f.Name = frame.Name

	local parents = {} -- construct hierarchy tree for rotation
	do
		local function add(child)
			if child:IsA'GuiObject' then
				parents[#parents + 1] = child
				add(child.Parent)
			end
		end
		add(frame)
	end

	local function UpdateOrientation(fetchProps)
		local zIndex = 1 - 0.05*frame.ZIndex
		local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		do
			local rot = 0;
			for _, v in ipairs(parents) do
				rot = rot + v.Rotation
			end
			if rot ~= 0 and rot%180 ~= 0 then
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				local vec = tl
				tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
				tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
				bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
				br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
			end
		end
		DrawQuad(
			activeCamera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
			activeCamera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
			activeCamera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
			activeCamera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
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

	binds[frame] = {
		uid = uid;
		parts = parts;
	}
	return binds[frame].parts
end
function Owl:Modify(frame, properties)
	local parts = Owl:GetBoundParts(frame)
	if parts then
		for propName, propValue in pairs(properties) do
			for _, pt in pairs(parts) do
				pt[propName] = propValue
			end
		end
	else
		warn(('No part bindings exist for %s'):format(frame:GetFullName()))
	end
end
function Owl:UnbindFrame(frame)
	local cb = binds[frame]
	if cb then
		RunService:UnbindFromRenderStep(cb.uid)
		for _, v in pairs(cb.parts) do
			v:Destroy()
		end
		binds[frame] = nil
	else
		warn(('No part bindings exist for %s'):format(frame:GetFullName()))
	end
end
function Owl:HasBinding(frame)
	return binds[frame] ~= nil
end
function Owl:GetBoundParts(frame)
	return binds[frame] and binds[frame].parts
end



function Owl:GetDark(Color, val, mode)
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

function Owl:GetLighter(color: Color3, strength: number)
	strength = math.clamp(strength or 0.2, 0, 1)

	return Color3.new(
		color.R + (1 - color.R) * strength,
		color.G + (1 - color.G) * strength,
		color.B + (1 - color.B) * strength
	)
end

function Owl:ColorPack(color)
	assert(typeof(color) == "Color3", "PackColor expects a Color3 value.")
	return {
		R = math.round(color.R * 255),
		G = math.round(color.G * 255),
		B = math.round(color.B * 255)
	}
end

function Owl:ColorUnpack(color)
	assert(type(color) == "table" or type(color) == "string", "Invalid color format. Expected table (RGB) or string (HEX).")

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

function Owl:HidePH(instance, placeholder, recursive)
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

function Owl:AddConnection(Type, Callback)
	if typeof(Type) ~= "RBXScriptSignal" then
		error("[AddConnection] Invalid Type: Expected RBXScriptSignal, got " .. typeof(Type))
	end
	if typeof(Callback) ~= "function" then
		error("[AddConnection] Invalid Callback: Expected function, got " .. typeof(Callback))
	end

	local Connection = Type:Connect(Callback)
	local ConnectionData = { Connection = Connection }

	Owl.Connections = Owl.Connections or {}
	table.insert(Owl.Connections, ConnectionData)

	local function Disconnect()
		if Connection.Connected then
			Connection:Disconnect()
		end

		for i = #Owl.Connections, 1, -1 do
			if Owl.Connections[i] == ConnectionData then
				table.remove(Owl.Connections, i)
				break
			end
		end
	end

	task.spawn(function()
		task.wait(10)
		for i = #Owl.Connections, 1, -1 do
			if not Owl.Connections[i].Connection.Connected then
				table.remove(Owl.Connections, i)
			end
		end
	end)

	return Connection, Disconnect
end

local Bento = {}
Bento.__index = Bento
function Bento.new(container, config)
	local self = setmetatable({}, Bento)

	self.Container = container
	self.Items = {}

	self.Rows = {} -- NEW (optional manual rows)

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
	table.insert(self.Rows,row)
	return row
end
function Bento:AddItem(frame, options, row)

	frame.AnchorPoint = Vector2.new(0,0)

	local item = {
		Frame = frame,
		Bottom = options and options.Bottom,
		Row = row -- NEW
	}

	self.Original[frame] = {
		Position = frame.Position,
		Size = frame.Size
	}

	table.insert(self.Items,item)

	if row then
		table.insert(row,item)
	end

end
function Bento:Tween(frame, goal)

	if self.ActiveTweens[frame] then
		self.ActiveTweens[frame]:Cancel()
	end

	local tween = Services.Tween:Create(
		frame,
		TweenInfo.new(
			self.TweenTime,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		goal
	)

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

	for _,item in ipairs(self.Items) do
		if item.Bottom then
			table.insert(bottomItems,item)
		else
			table.insert(normalItems,item)
		end
	end

	local sortedRows = {}
	if #self.Rows > 0 then

		for _,row in ipairs(self.Rows) do
			table.insert(sortedRows,{
				Items = row
			})
		end

	else

		local rows = {}

		for _,item in ipairs(normalItems) do

			local original = self.Original[item.Frame]
			local y = original.Position.Y.Offset

			rows[y] = rows[y] or {}
			table.insert(rows[y],item)

		end

		for y,row in pairs(rows) do

			table.insert(sortedRows,{
				Y = y,
				Items = row
			})

		end

		table.sort(sortedRows,function(a,b)
			return a.Y < b.Y
		end)

	end

	local widestRow = 0

	for _,row in ipairs(sortedRows) do

		local width = 0

		for _,item in ipairs(row.Items) do
			width += self.Original[item.Frame].Size.X.Offset
		end

		width += (#row.Items-1) * self.Gap

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

			self:Tween(frame,{
				Position = UDim2.fromOffset(0,y),
				Size = UDim2.fromOffset(
					containerWidth - self.RightPadding,
					original.Size.Y.Offset
				)
			})

			y += original.Size.Y.Offset + self.Gap

		end


		for _,row in ipairs(sortedRows) do
			for _,item in ipairs(row.Items) do
				if not item.Bottom then -- FIX
					stackItem(item)
				end
			end
		end

		for _,item in ipairs(bottomItems) do
			stackItem(item)
		end


		self.Container.Size = UDim2.new(
			self.OriginalContainerSize.X.Scale,
			self.OriginalContainerSize.X.Offset,
			0,
			y - self.Gap
		)

		return
	end

	for _,row in ipairs(sortedRows) do

		table.sort(row.Items,function(a,b)

			local ax = self.Original[a.Frame].Position.X.Offset
			local bx = self.Original[b.Frame].Position.X.Offset

			return ax < bx

		end)



		for i,item in ipairs(row.Items) do

			local frame = item.Frame
			local original = self.Original[frame]

			local currentX = original.Position.X.Offset
			local height = original.Size.Y.Offset

			local nextItem = row.Items[i+1]

			local width

			if nextItem then

				local nextX =
					self.Original[nextItem.Frame].Position.X.Offset

				width =
					nextX
				- currentX
				- self.Gap

			else

				width =
					containerWidth
				- currentX
				- self.RightPadding

			end


			self:Tween(frame,{
				Position = original.Position,
				Size = UDim2.fromOffset(width,height)
			})

		end

	end
	for _,item in ipairs(bottomItems) do

		local frame = item.Frame
		local original = self.Original[frame]

		local width =
			containerWidth
		- original.Position.X.Offset
		- self.RightPadding

		self:Tween(frame,{
			Position = original.Position,
			Size = UDim2.fromOffset(width,original.Size.Y.Offset)
		})

	end



	self.Container.Size = self.OriginalContainerSize

end

function Bento:Bind()

	local busy = false

	self.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()

		if busy then return end
		busy = true

		task.defer(function()

			self:Update()

			busy = false

		end)

	end)

end

function Owl:MakeResizable(Dragger, Object, MinSize, Callback, LockAspectRatio)
	assert(typeof(Dragger) == "Instance" and Dragger:IsA("GuiObject"), "[MakeResizable] Dragger must be a GuiObject")
	assert(typeof(Object) == "Instance" and Object:IsA("GuiObject"), "[MakeResizable] Object must be a GuiObject")
	assert(typeof(MinSize) == "Vector2", "[MakeResizable] MinSize must be a Vector2")
	assert(Callback == nil or typeof(Callback) == "function", "[MakeResizable] Callback must be a function or nil")

	local userInput = game:GetService("UserInputService")

	local startPosition, startSize = nil, nil
	local isResizing = false
	local function getInputPos(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			return Vector2.new(input.Position.X, input.Position.Y)
		else
			return userInput:GetMouseLocation()
		end
	end

	local function onInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isResizing = true
			isResizing = true
			startPosition = getInputPos(input)
			startSize = Object.AbsoluteSize
			Services.Tween:Create(uiAsset.main.resize, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 15,0, 15)}):Play()
			Services.Tween:Create(uiAsset.main.resize, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		end
	end

	local function onInputChanged(input)
		if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mouse = getInputPos(input)
			if startPosition and mouse then
				local delta = mouse - startPosition

				local newWidth = math.max(MinSize.X, startSize.X + delta.X)
				local newHeight = math.max(MinSize.Y, startSize.Y + delta.Y)

				if LockAspectRatio then
					local aspectRatio = startSize.X / startSize.Y
					newHeight = newWidth / aspectRatio
				end

				Object:TweenSize(
					UDim2.fromOffset(newWidth, newHeight),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quint,
					0.4,
					true
				)

				if Callback then
					Callback(Vector2.new(newWidth, newHeight))
				end
			end
		end
	end

	local function onInputEnded(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isResizing = false
			isResizing = false
			startPosition, startSize = nil, nil
			Services.Tween:Create(uiAsset.main.resize, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 20,0, 20)}):Play()
			Services.Tween:Create(uiAsset.main.resize, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {ImageColor3 = Color3.fromRGB(53, 53, 53)}):Play()
		end
	end

	Owl:AddConnection(Dragger.InputBegan, onInputBegan)
	Owl:AddConnection(userInput.InputChanged, onInputChanged)
	Owl:AddConnection(Dragger.InputEnded, onInputEnded)
end


local loadTweens = {}

function Owl:registerLoadTween(object, properties, initialState, tweenInfo)
	assert(typeof(object) == "Instance", "[registerLoadTween] Object must be an Instance")
	assert(typeof(properties) == "table", "[registerLoadTween] Properties must be a table")
	assert(typeof(initialState) == "table", "[registerLoadTween] Initial state must be a table")
	assert(typeof(tweenInfo) == "TweenInfo", "[registerLoadTween] TweenInfo must be of type TweenInfo")

	loadTweens[object] = {
		tween = Services.Tween:Create(object, tweenInfo, properties),
		properties = properties,
		initialState = initialState,
		tweenInfo = tweenInfo
	}
end

function Owl:resetToInitialState(animated, resetTweenInfo)
	for object, tweenData in pairs(loadTweens) do
		if object and object.Parent then
			tweenData.tween:Cancel()

			if animated then
				local resetTween = Services.Tween:Create(object, resetTweenInfo or TweenInfo.new(0.3), tweenData.initialState)
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

function Owl:replayLoadTweens(targetObject)
	Owl:resetToInitialState(false)

	for object, tweenData in pairs(loadTweens) do
		if object and object.Parent then
			if not targetObject or object == targetObject then
				tweenData.tween:Cancel()
				tweenData.tween:Play()
			end
		end
	end
end

function Owl:removeLoadTween(object)
	if loadTweens[object] then
		loadTweens[object].tween:Cancel()
		loadTweens[object] = nil
	end
end

local RunService = game:GetService("RunService")

function Owl:WiggleText(label)
	if not label or not label:IsA("TextLabel") then return end
	if not label.Text or label.Text == "" then return end
	if label:FindFirstChild("WiggleContainer") then
		label.WiggleContainer:Destroy()
	end

	local container = Instance.new("Folder")
	container.Name = "WiggleContainer"
	container.Parent = label
	label.TextTransparency = 1

	local baseText = label.Text:gsub("<.->", "") -- remove RichText tags
	local fontFace = label.FontFace
	local baseSize = label.TextSize
	local textColor = label.TextColor3

	local chars = {}
	local xOffset = 0
	for i = 1, #baseText do
		local char = baseText:sub(i, i)
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
	local id = "Wiggle_" .. tostring(math.random(1, 999999))
	RunService:BindToRenderStep(id, Enum.RenderPriority.First.Value, function(dt)
		t += dt * 6
		for i, charLabel in ipairs(chars) do
			local offset = math.sin(t + i * 0.3) * 3 -- wiggle amplitude
			charLabel.Position = UDim2.new(0, charLabel.Position.X.Offset, 0.5, offset)
		end
	end)

	label.Destroying:Connect(function()
		RunService:UnbindFromRenderStep(id)
	end)
end


function Owl:StopWiggle(label)
	for i, data in ipairs(self.Connections) do
		if data.label == label then
			data.conn:Disconnect()
			table.remove(self.Connections, i)
			break
		end
	end
end



function Owl:updateLayout(container, spacing)
	spacing = spacing or 8
	local yOffset = 8

	for _, v in ipairs(container:GetChildren()) do
		if v:IsA('UIListLayout') then
			v:Destroy()
		end
	end

	if isResizing == false then
		for _, child in ipairs(container:GetChildren()) do
			if (child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("TextLabel") or child:IsA("TextButton")) and child.Visible then
				if child.Size.X.Offset ~= -16 or child.Size.X.Scale ~= 1 then
					child.Size = UDim2.new(1, -16, 0, child.Size.Y.Offset)
				end
				Services.Tween:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 8, 0, yOffset)}):Play()
				yOffset = yOffset + child.AbsoluteSize.Y + spacing
			end
		end
	end

	container.CanvasSize = UDim2.new(0, 0, 0, yOffset + 14)
end

local dragSpeed = 0.6
local LockToScreen = false

function Owl:AddDrag(Object, Main, ConstrainToParent)
	assert(typeof(Object) == "Instance" and Object:IsA("GuiObject"), "[AddDrag] Object must be a GuiObject")
	assert(typeof(Main) == "Instance" and Main:IsA("GuiObject"), "[AddDrag] Main must be a GuiObject")

	local userInput = game:GetService("UserInputService")
	local tweenService = game:GetService("TweenService")

	local dragging, dragInput, startMousePos, startFramePos = false, nil, nil, nil

	local function getConstrainedPosition(newPos)
		if not LockToScreen then
			return newPos
		end

		local viewportSize = workspace.CurrentCamera.ViewportSize
		local frameSize = Main.AbsoluteSize
		local anchorPoint = Main.AnchorPoint
		local absX = newPos.X.Offset
		local absY = newPos.Y.Offset

		local minX = 0 + (frameSize.X * anchorPoint.X)
		local maxX = viewportSize.X - (frameSize.X * (1 - anchorPoint.X))

		local minY = 0 + (frameSize.Y * anchorPoint.Y)
		local maxY = viewportSize.Y - (frameSize.Y * (1 - anchorPoint.Y))

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




	Owl:AddConnection(Object.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startMousePos = getInputPos(input)

			local viewportSize = workspace.CurrentCamera.ViewportSize
			local absX = viewportSize.X * Main.Position.X.Scale + Main.Position.X.Offset
			local absY = viewportSize.Y * Main.Position.Y.Scale + Main.Position.Y.Offset

			Main.Position = UDim2.new(0, absX, 0, absY)
			startFramePos = Main.Position
		end
	end)


	Owl:AddConnection(userInput.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local currentMousePos = getInputPos(input)
			if currentMousePos and startMousePos then
				local delta = currentMousePos - startMousePos

				local newPos = UDim2.new(
					startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
					startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
				)

				Main:TweenPosition(getConstrainedPosition(newPos), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, dragSpeed, true)
			end
		end
	end)
	Owl:AddConnection(userInput.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function Owl:HidePlaceHolder(instance, placeholder, recursive)
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
local isMinihomeRuntimeActive = true
function Owl:Load(config)
	config = config or {}
	local accent = config.Accent or Owl.theme.Accent
	local title = config.Name or "Owl"
	local loaderGui = Instance.new("ScreenGui")
	loaderGui.Name = "OwlLoader"
	loaderGui.IgnoreGuiInset = true
	loaderGui.ResetOnSpawn = false
	loaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	loaderGui.Parent = GuiRoot

	local backdrop = Instance.new("Frame")
	backdrop.BackgroundColor3 = Color3.fromRGB(7, 7, 9)
	backdrop.BackgroundTransparency = 1
	backdrop.BorderSizePixel = 0
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.Parent = loaderGui

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(400, 186)
	card.Parent = backdrop

	local cardScale = Instance.new("UIScale")
	cardScale.Scale = 0.94
	cardScale.Parent = card

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 18)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = accent
	cardStroke.Transparency = 1
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local glow = Instance.new("Frame")
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundColor3 = accent
	glow.BackgroundTransparency = 0.88
	glow.BorderSizePixel = 0
	glow.Position = UDim2.fromScale(0.78, 0.2)
	glow.Size = UDim2.fromOffset(150, 150)
	glow.Parent = card

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(1, 0)
	glowCorner.Parent = glow

	local owlMark = Instance.new("Frame")
	owlMark.AnchorPoint = Vector2.new(0.5, 0.5)
	owlMark.BackgroundColor3 = Color3.new(0, 0, 0)
	owlMark.BorderSizePixel = 0
	owlMark.Position = UDim2.fromOffset(49, 57)
	owlMark.Size = UDim2.fromOffset(48, 42)
	owlMark.Parent = card

	local owlCorner = Instance.new("UICorner")
	owlCorner.CornerRadius = UDim.new(0, 13)
	owlCorner.Parent = owlMark

	local owlScale = Instance.new("UIScale")
	owlScale.Scale = 0.82
	owlScale.Parent = owlMark

	local leftEar = Instance.new("Frame")
	leftEar.AnchorPoint = Vector2.new(0.5, 0.5)
	leftEar.BackgroundColor3 = Color3.new(0, 0, 0)
	leftEar.BorderSizePixel = 0
	leftEar.Position = UDim2.fromOffset(9, 3)
	leftEar.Rotation = 45
	leftEar.Size = UDim2.fromOffset(17, 17)
	leftEar.Parent = owlMark

	local rightEar = leftEar:Clone()
	rightEar.Position = UDim2.fromOffset(39, 3)
	rightEar.Parent = owlMark

	local eyes = {}
	local pupils = {}
	for index, x in ipairs({14, 34}) do
		local eye = Instance.new("Frame")
		eye.AnchorPoint = Vector2.new(0.5, 0.5)
		eye.BackgroundColor3 = accent
		eye.BorderSizePixel = 0
		eye.Position = UDim2.fromOffset(x, 19)
		eye.Size = UDim2.fromOffset(11, 8)
		eye.ZIndex = 3
		eye.Parent = owlMark

		local eyeCorner = Instance.new("UICorner")
		eyeCorner.CornerRadius = UDim.new(1, 0)
		eyeCorner.Parent = eye

		local eyeGlow = Instance.new("UIStroke")
		eyeGlow.Color = accent
		eyeGlow.Thickness = 3
		eyeGlow.Transparency = 0.45
		eyeGlow.Parent = eye

		local pupil = Instance.new("Frame")
		pupil.AnchorPoint = Vector2.new(0.5, 0.5)
		pupil.BackgroundColor3 = Color3.new(0, 0, 0)
		pupil.BorderSizePixel = 0
		pupil.Position = UDim2.fromScale(0.5, 0.5)
		pupil.Size = UDim2.fromOffset(3, 4)
		pupil.ZIndex = 4
		pupil.Parent = eye

		local pupilCorner = Instance.new("UICorner")
		pupilCorner.CornerRadius = UDim.new(1, 0)
		pupilCorner.Parent = pupil
		eyes[index] = eye
		pupils[index] = pupil
	end

	local beak = Instance.new("Frame")
	beak.AnchorPoint = Vector2.new(0.5, 0.5)
	beak.BackgroundColor3 = Color3.fromRGB(21, 21, 26)
	beak.BorderSizePixel = 0
	beak.Position = UDim2.fromOffset(24, 29)
	beak.Rotation = 45
	beak.Size = UDim2.fromOffset(6, 6)
	beak.ZIndex = 3
	beak.Parent = owlMark

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.Position = UDim2.fromOffset(84, 34)
	titleLabel.Size = UDim2.new(1, -108, 0, 24)
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(247, 247, 250)
	titleLabel.TextSize = 18
	titleLabel.TextTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = card

	local statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.Position = UDim2.fromOffset(84, 62)
	statusLabel.Size = UDim2.new(1, -108, 0, 18)
	statusLabel.Text = "Loading interface"
	statusLabel.TextColor3 = Color3.fromRGB(151, 151, 162)
	statusLabel.TextSize = 12
	statusLabel.TextTransparency = 1
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = card

	local track = Instance.new("Frame")
	track.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
	track.BackgroundTransparency = 1
	track.BorderSizePixel = 0
	track.Position = UDim2.fromOffset(28, 132)
	track.Size = UDim2.new(1, -56, 0, 4)
	track.Parent = card

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = accent
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local fillGradient = Instance.new("UIGradient")
	fillGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, accent),
		ColorSequenceKeypoint.new(0.5, accent:Lerp(Color3.new(1, 1, 1), 0.35)),
		ColorSequenceKeypoint.new(1, accent),
	})
	fillGradient.Offset = Vector2.new(-1, 0)
	fillGradient.Parent = fill

	Services.Tween:Create(backdrop, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.12}):Play()
	Services.Tween:Create(card, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.03}):Play()
	Services.Tween:Create(cardScale, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
	Services.Tween:Create(cardStroke, TweenInfo.new(0.34, Enum.EasingStyle.Quint), {Transparency = 0.62}):Play()
	Services.Tween:Create(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	Services.Tween:Create(statusLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
	Services.Tween:Create(track, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
	Services.Tween:Create(fill, TweenInfo.new(0.92, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromScale(1, 1)}):Play()
	Services.Tween:Create(fillGradient, TweenInfo.new(0.78, Enum.EasingStyle.Sine), {Offset = Vector2.new(1, 0)}):Play()
	Services.Tween:Create(owlScale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

	local breatheTween = Services.Tween:Create(owlScale, TweenInfo.new(0.78, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Scale = 1.035})
	local floatTween = Services.Tween:Create(owlMark, TweenInfo.new(0.78, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.fromOffset(49, 54)})
	local glowTweens = {}
	for _, eye in ipairs(eyes) do
		local glowTween = Services.Tween:Create(eye, TweenInfo.new(0.72, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundColor3 = accent:Lerp(Color3.new(1, 1, 1), 0.18)})
		glowTween:Play()
		table.insert(glowTweens, glowTween)
	end
	local loadingActive = true
	task.delay(0.3, function()
		if loadingActive and loaderGui.Parent then
			breatheTween:Play()
			floatTween:Play()
		end
	end)
	for _, pupil in ipairs(pupils) do
		Services.Tween:Create(pupil, TweenInfo.new(0.38, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 1, true), {Position = UDim2.fromScale(0.68, 0.5)}):Play()
	end
	task.spawn(function()
		task.wait(0.34)
		while loadingActive and loaderGui.Parent do
			for _, eye in ipairs(eyes) do
				Services.Tween:Create(eye, TweenInfo.new(0.065, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromOffset(11, 1)}):Play()
			end
			task.wait(0.07)
			for _, eye in ipairs(eyes) do
				Services.Tween:Create(eye, TweenInfo.new(0.13, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(11, 8)}):Play()
			end
			task.wait(0.72)
		end
	end)

	task.wait(0.42)
	Services.Tween:Create(statusLabel, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
	task.wait(0.1)
	statusLabel.Text = "Finishing details"
	Services.Tween:Create(statusLabel, TweenInfo.new(0.16), {TextTransparency = 0}):Play()
	task.wait(0.42)
	loadingActive = false
	breatheTween:Cancel()
	floatTween:Cancel()
	for _, glowTween in ipairs(glowTweens) do
		glowTween:Cancel()
	end
	Services.Tween:Create(cardScale, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0.98}):Play()
	Services.Tween:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
	Services.Tween:Create(backdrop, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
	task.wait(0.25)
	loaderGui:Destroy()
end

local HttpService = Services.Http
local THEME_FOLDER = "OwlTheme"
local FILE_PATH = THEME_FOLDER .. "/" .. tostring(game and game.GameId or "0") .. ".txt"

if makefolder and isfolder and not isfolder(THEME_FOLDER) then
	pcall(makefolder, THEME_FOLDER)
end

local LoadedThemeFile = false
local ThemeColorsToSave = {}

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function PackColor(Color)
	if typeof(Color) ~= "Color3" then return nil end
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end  

local function UnpackColor(Color)
	if type(Color) ~= "table" then return Color3.fromRGB(255, 255, 255) end
	local red = tonumber(Color.R)
	local green = tonumber(Color.G)
	local blue = tonumber(Color.B)
	if not red or not green or not blue then return Color3.fromRGB(255, 255, 255) end
	return Color3.fromRGB(math.clamp(red, 0, 255), math.clamp(green, 0, 255), math.clamp(blue, 0, 255))
end

function Owl:SaveThemeCfg()
	if not LoadedThemeFile then return end

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
		if self.theme.Accent then ThemeColorsToSave["Accent"] = PackColor(self.theme.Accent) end
		if self.theme.HitBox then ThemeColorsToSave["HitBox"] = PackColor(self.theme.HitBox) end
	end

	if makefolder and isfolder and not isfolder(THEME_FOLDER) then
		pcall(makefolder, THEME_FOLDER)
	end
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
			Owl.Themes = Owl.Themes or {}
			Owl.Themes.Custom = Owl.Themes.Custom or {}

			for TypeName, Value in pairs(Data) do
				local c = UnpackColor(Value)
				Owl.Themes.Custom[TypeName] = c
				if TypeName == "Accent" or TypeName == "HitBox" then
					if Owl.theme then
						Owl.theme[TypeName] = c
					end
				end
			end

			Owl.SelectedTheme = "Custom"
			LoadedThemeFile = true

			task.wait(0.02)
			Owl:SetTheme()
		else
			LoadedThemeFile = true
		end
	else
		LoadedThemeFile = true
	end
end

function Owl:SetTheme()
	local themeData = (self.Themes and self.SelectedTheme and self.Themes[self.SelectedTheme]) or self.theme
	if not themeData then return end

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

function Owl:GenTheme(mainColor)
	local r, g, b = mainColor.R * 255, mainColor.G * 255, mainColor.B * 255
	local lum = 0.299 * r + 0.587 * g + 0.114 * b
	local dark = lum < 128
	local t = {Main = mainColor}

	if dark then
		t.Second = Color3.fromRGB(math.clamp(r * 1.12, 0, 255), math.clamp(g * 1.12, 0, 255), math.clamp(b * 1.12, 0, 255))
		t.Stroke = Color3.fromRGB(math.clamp(r * 1.45, 0, 255), math.clamp(g * 1.45, 0, 255), math.clamp(b * 1.45, 0, 255))
		t.Divider = Color3.fromRGB(math.clamp(r * 1.28, 0, 255), math.clamp(g * 1.28, 0, 255), math.clamp(b * 1.28, 0, 255))
		t.Text = Color3.fromRGB(240, 240, 242)
		t.TextDark = Color3.fromRGB(155, 155, 160)
		t.Accent = Color3.fromRGB(math.clamp(r * 1.85, 0, 255), math.clamp(g * 1.85, 0, 255), math.clamp(b * 1.85, 0, 255))
		t.HitBox = t.Accent
	else
		t.Second = Color3.fromRGB(math.clamp(r * 0.94, 0, 255), math.clamp(g * 0.94, 0, 255), math.clamp(b * 0.94, 0, 255))
		t.Stroke = Color3.fromRGB(math.clamp(r * 0.75, 0, 255), math.clamp(g * 0.75, 0, 255), math.clamp(b * 0.75, 0, 255))
		t.Divider = Color3.fromRGB(math.clamp(r * 0.85, 0, 255), math.clamp(g * 0.85, 0, 255), math.clamp(b * 0.85, 0, 255))
		t.Text = Color3.fromRGB(35, 35, 38)
		t.TextDark = Color3.fromRGB(110, 110, 115)
		t.Accent = Color3.fromRGB(math.clamp(r * 0.72, 0, 255), math.clamp(g * 0.72, 0, 255), math.clamp(b * 0.72, 0, 255))
		t.HitBox = t.Accent
	end

	return t
end

local function SaveCfg(Name)
	Name = Name or (game and game.GameId) or "default"
	local folder = Owl.Folder or Owl.ConfigFolder or "OwlHub"
	if makefolder and isfolder and not isfolder(folder) then
		pcall(makefolder, folder)
	end

	local Data = {}
	for i, v in pairs(Owl.Flags) do
		if v and v.Save ~= false then
			if v.Type == "MultiColorpicker" then
				if v.Pickers and #v.Pickers > 0 then
					local colorList = {}
					for index, picker in ipairs(v.Pickers) do
						colorList[index] = PackColor(picker.Value)
					end
					Data[i] = colorList
				end
			elseif v.Type == "Colorpicker" or v.Type == "ColorPicker" then
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
			end
		end	
	end

	if writefile then
		pcall(function()
			writefile(folder .. "/" .. tostring(Name) .. ".txt", tostring(HttpService:JSONEncode(Data)))
		end)
	end
end

local function LoadCfg(Config)
	local ok, Data = pcall(function()
		return HttpService:JSONDecode(Config)
	end)
	if not ok or type(Data) ~= "table" then return end

	Owl.LoadedConfig = Data

	local flagsProcessed = 0
	local totalFlags = 0
	for _, _ in pairs(Data) do totalFlags += 1 end

	for a, b in pairs(Data) do
		if Owl.Flags[a] then
			task.spawn(function()
				local flag = Owl.Flags[a]
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

				flagsProcessed += 1
				if flagsProcessed >= totalFlags then
					task.wait(0.05)
					Owl:SetTheme()
				end
			end)
		else
			flagsProcessed += 1
			if flagsProcessed >= totalFlags then
				task.wait(0.05)
				Owl:SetTheme()
			end
		end
	end
end

local saveDebounce = nil
function SaveConfig(Name)
	if saveDebounce then
		task.cancel(saveDebounce)
	end
	saveDebounce = task.delay(0.05, function()
		saveDebounce = nil
		SaveCfg(Name or (game and game.GameId))
	end)
end

function LoadConfig(Configuration)
	LoadCfg(Configuration)
	return true
end

function Owl:AutoSave()
	SaveCfg(game and game.GameId)
end

function Owl:LoadSaveConfig(targetFile)
	local folder = Owl.Folder or Owl.ConfigFolder or "OwlHub"
	local fileName = targetFile or (game and game.GameId) or "default"
	local filePath = string.format("%s/%s.txt", folder, fileName)

	if not isfile or not isfile(filePath) then
		if Owl.Toast then
			Owl:Toast({ Content = 'No save file found at ' .. filePath, Duration = 3 })
		end
		return false
	end

	local ok, content = pcall(readfile, filePath)
	if ok and content then
		LoadCfg(content)
		if Owl.Toast then
			Owl:Toast({ Content = 'Loaded config ' .. fileName, Duration = 3 })
		end
		return true
	end
	return false
end

function Owl:ListConfigs()
	local list = {}
	local folder = Owl.Folder or Owl.ConfigFolder or "OwlHub"
	if not listfiles or not isfolder or not isfolder(folder) then return list end

	local ok, files = pcall(listfiles, folder)
	if not ok or type(files) ~= "table" then return list end

	for _, full in ipairs(files) do
		local name = tostring(full):match("([^/\\]+)%.txt$")
		if name and name ~= "SettingsConfig" then
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

function Owl:SaveConfigAs(name)
	if type(name) ~= "string" or name == "" then return false end
	SaveCfg(name)
	if Owl.Toast then
		Owl:Toast({ Content = 'Saved config as ' .. name, Duration = 3 })
	end
	return true
end

function Owl:DeleteConfig(name)
	if type(name) ~= "string" or name == "" then return false end
	local folder = Owl.Folder or Owl.ConfigFolder or "OwlHub"
	local filePath = string.format("%s/%s.txt", folder, name)
	if isfile and isfile(filePath) and delfile then
		return pcall(delfile, filePath)
	end
	return false
end

function Owl:GetAutoLoad()
	local folder = Owl.Folder or Owl.ConfigFolder or "OwlHub"
	local autoloadPath = string.format("%s/_autoload.txt", folder)
	if isfile and isfile(autoloadPath) then
		local ok, content = pcall(readfile, autoloadPath)
		if ok and content then
			return tostring(content):match("^%s*(.-)%s*$") == "1"
		end
	end
	return false
end

function Owl:SetAutoLoad(enabled)
	local folder = Owl.Folder or Owl.ConfigFolder or "OwlHub"
	local autoloadPath = string.format("%s/_autoload.txt", folder)
	if makefolder and isfolder and not isfolder(folder) then
		pcall(makefolder, folder)
	end
	if writefile then
		pcall(writefile, autoloadPath, enabled and "1" or "0")
	end
end

Owl.PackColor = PackColor
Owl.UnpackColor = UnpackColor
Owl.SaveCfg = SaveCfg
Owl.LoadCfg = LoadCfg
Owl.SaveThemeCfg = Owl.SaveThemeCfg
Owl.LoadThemeCfg = LoadThemeCfg
local ui = uiAsset
local window = ui.main
local top = window.top
local tabs = window.tabs.tab
local pages = window.pages

local settingsOpen = false
local uiRuntime = {
	isClosed = false,
	transitionId = 0,
	isTransitionLocked = false,
	layoutBound = false,
	cameraViewportConnection = nil,
}
local isUserInfoHidden = false
local isBlurEnabled = false
local glow = false

local uitoggle = Enum.KeyCode.RightShift
local performanceOverlay = {
	enabled = false,
	connection = nil,
	frame = nil,
	label = nil,
	frameCount = 0,
	elapsed = 0,
}

local function createPerformanceOverlay()
	if performanceOverlay.frame and performanceOverlay.frame.Parent then
		return
	end

	local frame = Instance.new("Frame")
	frame.Name = "PerformanceOverlay"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Position = UDim2.new(0.56, 0, 0, 9)
	frame.Size = UDim2.new(0, 120, 0, 20)
	frame.Visible = false
	frame.ZIndex = 25
	frame.Parent = window.top

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamSemibold
	label.Size = UDim2.fromScale(1, 1)
	label.Text = "-- FPS  ·  -- ms"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 11
	label.ZIndex = 26
	label.Parent = frame

	performanceOverlay.frame = frame
	performanceOverlay.label = label

end

function Owl:SetPerformanceOverlay(enabled)
	performanceOverlay.enabled = enabled == true
	createPerformanceOverlay()
	performanceOverlay.frame.Visible = performanceOverlay.enabled

	if performanceOverlay.connection then
		performanceOverlay.connection:Disconnect()
		performanceOverlay.connection = nil
	end

	if not performanceOverlay.enabled then
		return
	end

	performanceOverlay.frameCount = 0
	performanceOverlay.elapsed = 0
	performanceOverlay.connection = Services.Run.Heartbeat:Connect(function(deltaTime)
		performanceOverlay.frameCount += 1
		performanceOverlay.elapsed += deltaTime
		if performanceOverlay.elapsed < 0.25 then
			return
		end

		local fps = math.floor(performanceOverlay.frameCount / performanceOverlay.elapsed + 0.5)
		local pingMilliseconds = nil
		local dataPingOk, dataPingValue = pcall(function()
			return Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if dataPingOk and type(dataPingValue) == "number" then
			pingMilliseconds = math.floor(dataPingValue + 0.5)
		else
			local localPlayer = Services.Players.LocalPlayer
			if localPlayer then
				local networkPingOk, pingSeconds = pcall(localPlayer.GetNetworkPing, localPlayer)
				if networkPingOk and type(pingSeconds) == "number" then
					pingMilliseconds = math.floor(pingSeconds * 1000 + 0.5)
				end
			end
		end
		pingMilliseconds = pingMilliseconds or 0

		if performanceOverlay.label and performanceOverlay.label.Parent then
			performanceOverlay.label.Text = string.format("%d FPS  ·  %d ms", fps, pingMilliseconds)
			performanceOverlay.label.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		performanceOverlay.frameCount = 0
		performanceOverlay.elapsed = 0
	end)
end

function applyLayout(isMobile)
	Services.Tween:Create(uiAsset.main, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = isMobile and UDim2.new(0, 543,0, 321) or UDim2.new(0, 715, 0, 575)}):Play()
	local shadow = window:FindFirstChild("Shadow")
	if shadow then
		shadow.Visible = not isMobile 
	end
end


local function updateLayout()
	local activeCamera = workspace.CurrentCamera
	if not activeCamera then
		return
	end
	local viewportSize = activeCamera.ViewportSize
	local mobile = Services.UserInput.TouchEnabled
	applyLayout(mobile)
end

local function bindLayoutListeners()
	if uiRuntime.layoutBound then
		return
	end

	uiRuntime.layoutBound = true

	local function rebindCameraViewport()
		if uiRuntime.cameraViewportConnection then
			uiRuntime.cameraViewportConnection:Disconnect()
			uiRuntime.cameraViewportConnection = nil
		end

		local activeCamera = workspace.CurrentCamera
		if activeCamera then
			uiRuntime.cameraViewportConnection = activeCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayout)
		end

		updateLayout()
	end

	rebindCameraViewport()
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(rebindCameraViewport)
	Services.UserInput:GetPropertyChangedSignal("TouchEnabled"):Connect(updateLayout)
end
local notifications = {}
local notificationSpacing = 10

local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

function updatePositions()
	local currentY = 18

	for i = #notifications, 1, -1 do
		local notif = notifications[i]
		local targetPosition = UDim2.new(1, -268, 0, currentY)
		Services.Tween:Create(notif, tweenInfo, { Position = targetPosition }):Play()
		currentY += notif.Size.Y.Offset + notificationSpacing
	end
end

for _, temp in ipairs(uiAsset.Notification:GetChildren()) do
	if temp:IsA("Frame") then
		temp.Visible = false
	end
end 

function Owl:Notify(Notification)
	if Owl.SuppressNotify then return end
	Notification = Notification or {}
	if Notification.Varient ~= "Options" then
		local title = tostring(Notification.Title or "Owl")
		local content = tostring(Notification.Content or "")
		Owl:Toast({
			Content = content ~= "" and (title .. "  •  " .. content) or title,
			Duration = Notification.Duration or 5,
			Icon = Notification.Icon or "",
		})
		return
	end
	task.spawn(function()

		local NotifData = {
			Title = Notification.Title;
			Content = Notification.Content;
			Duration = Notification.Duration or 5;
			Icon = Notification.Icon or '';
			Varient = Notification.Varient or 'Default';
			Animation = Notification.Animation ;
			ConfirmCallback = Notification.ConfirmCallback
		}



		local Notification = uiAsset.Notification.Default:Clone()
		Notification.Visible = true
		Notification.Parent = uiAsset.Notification
		Notification.Title.Text = NotifData.Title
		Notification.Content.Text = NotifData.Content
		Notification.Content.Size = UDim2.new(0, 200,0, Notification.Content.TextBounds.Y )
		Notification.icon.Image = 'rbxassetid://'..NotifData.Icon
		Notification.icon.Visible = true



		local function CloseNotif()

			if Notification and Notification.Parent then
				table.remove(notifications, table.find(notifications, Notification))
				Services.Tween:Create(Notification.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Scale = 0.9}):Play()
				Services.Tween:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.95}):Play()
				Services.Tween:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.75}):Play()
				Services.Tween:Create(Notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.78}):Play()

				task.wait(0.15)

				Services.Tween:Create(Notification, TweenInfo.new(0.95, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, Notification.Position.X.Offset + 400, 0, Notification.Position.Y.Offset) }):Play()
				task.wait(0.4)
				Notification:Destroy()
				updatePositions()
			end

		end

		if NotifData.Animation == 'Wiggle' then
			Owl:WiggleText(Notification.Title)
		end

		if NotifData.Varient == 'Options' then
			Notification.Block.Visible = true
			Notification.Size = UDim2.new(1, 0,0, Notification.Content.TextBounds.Y + 80)
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
			Notification.Size = UDim2.new(1, 0,0, Notification.Content.TextBounds.Y + 45)
		end


		table.insert(notifications, Notification)
		updatePositions()
		Notification.close.ImageTransparency = 0.95
		Notification.BackgroundTransparency = 0.75
		Notification.Content.TextTransparency = 0.78

		Notification.Position = UDim2.new(1, 280, 0, 18)



		task.wait(0.45)

		if NotifData.Icon ~= '' then
			Services.Tween:Create(Notification.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 40,0, 10)}):Play()
			task.wait(0.035)
			Services.Tween:Create(Notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 40,0, 30)}):Play()

			Services.Tween:Create(Notification.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		end


		Services.Tween:Create(Notification.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Scale = 1}):Play()
		Services.Tween:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.75}):Play()
		Services.Tween:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
		Services.Tween:Create(Notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

		Notification.close.MouseEnter:Connect(function()
			Services.Tween:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.25}):Play()
		end)

		Notification.close.MouseLeave:Connect(function()
			Services.Tween:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.75}):Play()
		end)

		Notification.close.MouseButton1Click:Connect(function()
			CloseNotif()
		end)

		task.delay(NotifData.Duration, function()
			CloseNotif()
		end)
	end)
end
local activeModals = 0 -- track how many modals are currently open

function Owl:Modal(Modal)
	Modal = Modal or {}
	task.spawn(function()
		local ModalData = {
			Title = Modal.Title or Modal.Name or "Confirm",
			Content = Modal.Content or Modal.Text or "Are you sure?",
			ConfirmCallBack = Modal.ConfirmCallBack or Modal.ConfimCallBack or Modal.Callback or Modal.CallBack
		}

		local modalTemplate = (ui and ui.main and (ui.main:FindFirstChild("modal") or ui.main:FindFirstChild("Modal")))

		local ModalInstance
		if modalTemplate then
			ModalInstance = modalTemplate:Clone()
		else
			ModalInstance = Instance.new("Frame")
			ModalInstance.Name = "Modal"
			ModalInstance.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
			local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 8) corner.Parent = ModalInstance
			local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(60, 60, 60) stroke.Parent = ModalInstance

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
			confirm.BackgroundColor3 = Owl.theme.Accent or Color3.fromRGB(255, 151, 227)
			confirm.Size = UDim2.new(0.48, 0, 1, 0)
			confirm.Position = UDim2.new(0.52, 0, 0, 0)
			confirm.Text = "Confirm"
			confirm.TextColor3 = Color3.fromRGB(20, 20, 20)
			confirm.Font = Enum.Font.GothamBold
			confirm.TextSize = 13
			local c_corner = Instance.new("UICorner") c_corner.CornerRadius = UDim.new(0, 6) c_corner.Parent = confirm
			local c_lbl = Instance.new("TextLabel") c_lbl.Name = "TextLabel" c_lbl.Text = "Confirm" c_lbl.Size = UDim2.new(1,0,1,0) c_lbl.BackgroundTransparency = 1 c_lbl.TextColor3 = Color3.fromRGB(20,20,20) c_lbl.Font = Enum.Font.GothamBold c_lbl.TextSize = 13 c_lbl.Parent = confirm
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
			local can_corner = Instance.new("UICorner") can_corner.CornerRadius = UDim.new(0, 6) can_corner.Parent = cancel
			local can_lbl = Instance.new("TextLabel") can_lbl.Name = "TextLabel" can_lbl.Text = "Cancel" can_lbl.Size = UDim2.new(1,0,1,0) can_lbl.BackgroundTransparency = 1 can_lbl.TextColor3 = Color3.fromRGB(220,220,220) can_lbl.Font = Enum.Font.Gotham can_lbl.TextSize = 13 can_lbl.Parent = cancel
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
			Services.Tween:Create(dim, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { BackgroundTransparency = 0.3 }):Play()
		end

		local function closeModal()
			activeModals = math.max(0, activeModals - 1)
			pcall(function()
				Services.Tween:Create(ModalInstance, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
					Size = UDim2.new(0, 320, 0, 120),
					BackgroundTransparency = 1
				}):Play()
			end)
			task.wait(0.2)
			ModalInstance:Destroy()
			if activeModals == 0 and dim then
				Services.Tween:Create(dim, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 }):Play()
				task.delay(0.2, function()
					if activeModals == 0 then dim.Visible = false end
				end)
			end
		end

		activeModals += 1
		Services.Tween:Create(ModalInstance, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 360, 0, 150),
			BackgroundTransparency = 0
		}):Play()

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

local tweenInfo = TweenInfo.new(
	0.55,
	Enum.EasingStyle.Exponential,
	Enum.EasingDirection.Out
)

local function updateToastPositions()
	local startY = 10 -- padding from top of toastholder
	local currentY = startY

	for i = 1, #toasts do
		local toast = toasts[i]
		if toast and toast.Parent then
			local target = UDim2.new(
				0.5, 0,
				0, currentY
			)

			Services.Tween:Create(toast, tweenInfo, {
				Position = target
			}):Play()

			currentY += toast.Size.Y.Offset + toastSpacing
		end
	end
end

function Owl:Toast(Toasty)
	task.spawn(function()
		local Data = {
			Content = Toasty.Content or "",
			Duration = Toasty.Duration or 5,
			Icon = Toasty.Icon or ""
		}

		local Toast = ui.toastholder.toast:Clone()
		Toast.Visible = true
		Toast.Parent = ui.toastholder
		Toast.AnchorPoint = Vector2.new(0.5, 0)
		Toast.Content.Text = Data.Content

		Toast.Size = UDim2.new(1, Toast.Content.TextBounds.X - 140 ,0, 40)

		if Data.Icon ~= "" then
			Toast.icon.ImageLabel.Image = "rbxassetid://" .. Data.Icon
			Toast.icon.ImageLabel.ImageTransparency = 0
		end
		Toast.Position = UDim2.new(
			0.5, 0,
			0, -Toast.Size.Y.Offset - 20
		)
		table.insert(toasts, 1, Toast)
		updateToastPositions()
		task.delay(Data.Duration, function()
			if not Toast or not Toast.Parent then return end

			table.remove(toasts, table.find(toasts, Toast))

			Services.Tween:Create(
				Toast,
				TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
				{
					Position = Toast.Position - UDim2.fromOffset(0, 30),
					BackgroundTransparency = 1
				}
			):Play()

			for _, v in ipairs(Toast:GetDescendants()) do
				if v:IsA("TextLabel") then
					Services.Tween:Create(v, TweenInfo.new(0.3), {
						TextTransparency = 1
					}):Play()
				elseif v:IsA("ImageLabel") then
					Services.Tween:Create(v, TweenInfo.new(0.3), {
						ImageTransparency = 1
					}):Play()
				elseif v:IsA("Frame") then
					Services.Tween:Create(v, TweenInfo.new(0.3), {
						BackgroundTransparency = 1
					}):Play()
				end
			end

			task.wait(0.35)
			Toast:Destroy()
			updateToastPositions()
		end)
	end)
end

function Owl:MakeNotification(NotificationConfig)
	NotificationConfig = NotificationConfig or {}
	local icon = NotificationConfig.Image or NotificationConfig.Icon or ""
	if type(icon) == "string" then
		icon = icon:gsub("rbxassetid://", "")
	end
	return Owl:Notify({
		Title = NotificationConfig.Name or NotificationConfig.Title or "Note!",
		Content = NotificationConfig.Content or "Message",
		Duration = NotificationConfig.Time or NotificationConfig.Duration or 5,
		Icon = icon
	})
end

local freeMouseBtn = nil
local function getFreeMouseBtn()
	if freeMouseBtn and freeMouseBtn.Parent then return freeMouseBtn end
	pcall(function()
		local targetParent = (ui and ui:IsA("ScreenGui") and ui) or (uiAsset and uiAsset:IsA("ScreenGui") and uiAsset) or GuiRoot
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

function Owl:UnlockMouse(Value)
	local btn = getFreeMouseBtn()
	if btn then
		btn.Modal = Value and true or false
		btn.Visible = Value and true or false
	end

	local uis = game:GetService("UserInputService")
	local lp = Services.Players.LocalPlayer

	if Owl.UMouseMode == "ThirdPerson" then
		if Value then
			if lp and not Owl.PreserveCameraMode then
				lp.CameraMode = Enum.CameraMode.LockFirstPerson
				task.wait()
				lp.CameraMode = Enum.CameraMode.Classic
				lp.CameraMaxZoomDistance = Owl.maxds or 500
				lp.CameraMinZoomDistance = Owl.minds or 10
			end
			uis.MouseBehavior = Enum.MouseBehavior.Default
			uis.MouseIconEnabled = true
		else
			uis.MouseIconEnabled = false
			uis.MouseBehavior = Enum.MouseBehavior.LockCenter
			if lp and not Owl.PreserveCameraMode then
				lp.CameraMaxZoomDistance = 0.5
				lp.CameraMinZoomDistance = 0.5
				lp.CameraMode = Enum.CameraMode.LockFirstPerson
			end
		end
	else
		uis.MouseBehavior = Value and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
		uis.MouseIconEnabled = Value and true or false
	end
end

function Owl:MakeWindow(WindowConfig)
	WindowConfig = WindowConfig or {}
	local previousLibrary = getgenv and getgenv().Owl
	if previousLibrary and previousLibrary ~= Owl and type(previousLibrary.Destroy) == "function" then
		pcall(previousLibrary.Destroy, previousLibrary)
	end
	WindowConfig.Name = WindowConfig.Name or "Fire Hub"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name or "OwlHub"
	WindowConfig.SaveConfig = true
	if WindowConfig.PreserveCameraMode ~= nil then
		Owl.PreserveCameraMode = WindowConfig.PreserveCameraMode
	end

	local cfgFolder = WindowConfig.ConfigFolder
	Owl.ConfigFolder = cfgFolder
	Owl.Folder = cfgFolder
	Owl.SaveCfg = true
	Owl.ConfigEnabled = true
	Owl.ConfigFile = tostring(game and game.GameId or "default")

	if makefolder and isfolder then
		if not isfolder(cfgFolder) then pcall(makefolder, cfgFolder) end
		if not isfolder(THEME_FOLDER) then pcall(makefolder, THEME_FOLDER) end
	end
	LoadThemeCfg(FILE_PATH)
	local configFilePath = string.format("%s/%s.txt", cfgFolder, tostring(game and game.GameId or "default"))
	if isfile and isfile(configFilePath) then
		local ok, rawData = pcall(readfile, configFilePath)
		if ok and rawData and rawData ~= "" then
			local decodeOk, decoded = pcall(function() return HttpService:JSONDecode(rawData) end)
			if decodeOk and type(decoded) == "table" then
				Owl.LoadedConfig = decoded
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
		Title = WindowConfig.Name or WindowConfig.Title or "Owl",
		SubText = WindowConfig.TagText or WindowConfig.SubText or "Hub",
		Watermark = WindowConfig.Watermark == true,
		Home = {
			Enabled = false
		}
	}

	if WindowConfig.FreeMouse ~= false then
		Owl.FreeMouse = true
		task.spawn(function()
			task.wait(0.05)
			Owl:UnlockMouse(true)
		end)
	end

	local windowObj = Owl:Init(libConfig)
	if WindowConfig.PerformanceOverlay == true then
		Owl:SetPerformanceOverlay(true)
	end

	if WindowConfig.KeyToOpenWindow or WindowConfig.Openkey then
		local key = WindowConfig.KeyToOpenWindow or WindowConfig.Openkey
		if type(key) == "string" and Enum.KeyCode[key] then
			uitoggle = Enum.KeyCode[key]
		elseif typeof(key) == "EnumItem" then
			uitoggle = key
		end
	end

	return windowObj
end

function Owl:CreateWindow(WindowConfig)
	return self:MakeWindow(WindowConfig)
end

function Owl:Destroy()
	if Owl._destroyed then
		return
	end
	Owl._destroyed = true

	if performanceOverlay.connection then
		performanceOverlay.connection:Disconnect()
		performanceOverlay.connection = nil
	end

	for index = #Owl.Connections, 1, -1 do
		local connectionData = Owl.Connections[index]
		if connectionData.Connection and connectionData.Connection.Connected then
			connectionData.Connection:Disconnect()
		end
		Owl.Connections[index] = nil
	end

	Owl:UnlockMouse(false)
	pcall(function()
		if uiAsset and uiAsset.Parent then
			uiAsset:Destroy()
		end
	end)
end

function Owl:DestroyLib()
	Owl:Destroy()
end
function SetUserInfo()
	local LocalPlayer = Services.Players.LocalPlayer

	local PLACEHOLDER_IMAGE = "rbxassetid://0" 
	local THUMBNAIL_TYPE = Enum.ThumbnailType.HeadShot
	local THUMBNAIL_SIZE = Enum.ThumbnailSize.Size420x420

	local imageLabel = window:WaitForChild("user"):WaitForChild("headshot")
	imageLabel.Image = PLACEHOLDER_IMAGE

	local success, thumbnail = pcall(function()
		return Services.Players:GetUserThumbnailAsync(LocalPlayer.UserId, THUMBNAIL_TYPE, THUMBNAIL_SIZE)
	end)

	if success and thumbnail then
		imageLabel.Image = thumbnail
		window.user.headshot.id.username.Text = LocalPlayer.Name
		window.user.headshot.id.displayname.Text = "@"..LocalPlayer.DisplayName
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


	if window.search.Frame.TextBox.Text ~= '' then
		Services.Tween:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 350,0, 230) }):Play()
	else
		Services.Tween:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 350,0, 60) }):Play()
	end

	Services.Tween:Create(window.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.45 }):Play()
	Services.Tween:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
	Services.Tween:Create(window.search.Frame.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()

	Services.Tween:Create(window.search.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
	Services.Tween:Create(window.search.close.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()

	Services.Tween:Create(window.search.Frame.TextBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
end

function closesearch()
	if not window.search.Visible then
		if not settingsOpen then
			window.dim.Visible = false
			window.dim.BackgroundTransparency = 1
		end
		return
	end
	searchopen = false
	window.search.Container.Visible = false
	Services.Tween:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 350,0, 60) }):Play()
	Services.Tween:Create(window.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
	Services.Tween:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
	Services.Tween:Create(window.search.Frame.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()

	Services.Tween:Create(window.search.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
	Services.Tween:Create(window.search.close.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()

	Services.Tween:Create(window.search.Frame.TextBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
	task.delay(0.5, function()
		if not searchopen then
			window.dim.Visible = false
			window.search.Visible = false
		end
	end)
end

function openui()
	uiRuntime.transitionId += 1
	uiRuntime.isClosed = false
	pages.Visible = true
	window.tabs.Visible = true
	window.user.Visible = true
	window.Visible = true

	if Owl.FreeMouse ~= false then
		Owl:UnlockMouse(true)
	end

	local fastTween = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	if isBlurEnabled then
		Owl:BindFrame(window, {
			Transparency = 0.98;
			BrickColor = BrickColor.new('Institutional white');
		})
		Services.Tween:Create(window, fastTween, {BackgroundTransparency = 0.45 }):Play()
	else
		Services.Tween:Create(window, fastTween, {BackgroundTransparency = 0 }):Play()
	end
	Services.Tween:Create(window, fastTween, {Size = UDim2.new(0, 700, 0, 560) }):Play()

	Services.Tween:Create(window.top.separator, fastTween, {BackgroundTransparency = 0 }):Play()
	Services.Tween:Create(window.top.title, fastTween, {TextTransparency = 0 }):Play()
	Services.Tween:Create(window.top.title.sub, fastTween, {TextTransparency = 0 }):Play()
	Services.Tween:Create(window.top.functions, fastTween, {BackgroundTransparency = 0 }):Play()

	if window.wallpaper.ison.Value then
		Services.Tween:Create(window.wallpaper, fastTween, {ImageTransparency = 0.84 }):Play()
	end

	for i,v in pairs(window.top.functions:GetChildren()) do
		if v:IsA("Frame") then
			Services.Tween:Create(v, fastTween, {BackgroundTransparency = 0.8 }):Play()
			v.Visible = true
			for i,v2 in pairs(v:GetChildren()) do
				if v2:IsA("ImageLabel") then
					Services.Tween:Create(v2, fastTween, {ImageTransparency = 0 }):Play()
					v2.Visible = true
				end
			end
			if v:FindFirstChild("rainbow") then
				Services.Tween:Create(v.rainbow, fastTween, {ImageTransparency = 1 }):Play()
			end
		end
	end

	Services.Tween:Create(window.shadow.ImageLabel, fastTween, {ImageTransparency = 0.5 }):Play()
	Services.Tween:Create(window.resize, fastTween, {ImageTransparency = 0.3}):Play()

	if glow == true then
		for i, g in pairs(window.clipframe:GetChildren()) do
			if g:IsA("ImageLabel") then
				Services.Tween:Create(g, fastTween, {ImageTransparency = 0.8}):Play()
			end
		end
		Services.Tween:Create(window.shadow.glow, fastTween, {ImageTransparency = 0.9}):Play()
		Services.Tween:Create(window.shadow.glow1, fastTween, {ImageTransparency = 0.9}):Play()
	end
end

function closeui()
	uiRuntime.transitionId += 1
	local closeTransitionId = uiRuntime.transitionId
	uiRuntime.isClosed = true
	local fastTween = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	pages.Visible = false
	window.tabs.Visible = false
	window.user.Visible = false

	Services.Tween:Create(window, fastTween, {BackgroundTransparency = 1 }):Play()
	Services.Tween:Create(window, fastTween, {Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, window.Size.Y.Scale, 120) }):Play()
	Services.Tween:Create(window.top.separator, fastTween, {BackgroundTransparency = 1 }):Play()
	Services.Tween:Create(window.top.title, fastTween, {TextTransparency = 1 }):Play()
	Services.Tween:Create(window.top.title.sub, fastTween, {TextTransparency = 1 }):Play()

	if window.wallpaper.ison.Value then
		Services.Tween:Create(window.wallpaper, fastTween, {ImageTransparency = 1 }):Play()
	end

	Owl:UnbindFrame(window)
	Services.Tween:Create(window.top.functions, fastTween, {BackgroundTransparency = 1 }):Play()

	for i,v in pairs(window.top.functions:GetChildren()) do
		if v:IsA("Frame") then
			Services.Tween:Create(v, fastTween, {BackgroundTransparency = 1 }):Play()
			v.Visible = false
			for i,v2 in pairs(v:GetChildren()) do
				if v2:IsA("ImageLabel") then
					Services.Tween:Create(v2, fastTween, {ImageTransparency = 1 }):Play()
					v2.Visible = false
				end
			end
		end
	end

	Services.Tween:Create(window.shadow.ImageLabel, fastTween, {ImageTransparency = 1 }):Play()
	Services.Tween:Create(window.resize, fastTween, {ImageTransparency = 1 }):Play()

	settingsOpen = false

	if Owl.FreeMouse ~= false then
		Owl:UnlockMouse(false)
	end

	task.delay(0.2, function()
		if uiRuntime.isClosed and uiRuntime.transitionId == closeTransitionId then
			window.Visible = false
		end
	end)

	task.spawn(function()
		closesettings()
		closesearch()
	end)

	Owl:Toast({
		Content = 'UI Hidden, Use '.. uitoggle.Name ..' To Open Back.',
		Duration = 2,
	})
end

function ToggleUI()
	if uiRuntime.isTransitionLocked then return end
	uiRuntime.isTransitionLocked = true

	if uiRuntime.isClosed then
		openui()
		updateLayout()
	else
		closeui()
	end

	task.delay(0.2, function()
		uiRuntime.isTransitionLocked = false
	end)
end

bindLayoutListeners()

window.top.functions.close.interact.MouseButton1Click:Connect(function()
	Owl:Modal({
		Title = 'Please Confirm Below.',
		Content = 'Are You Sure You Want To Close This UI?',
		ConfimCallBack = function()
			isMinihomeRuntimeActive = false
			rs:Disconnect()
			ss:Disconnect()
			task.wait(1)
			uiAsset:Destroy()
		end,
	})
end)


Owl:HidePH(tabs, 'btn')
Owl:HidePH(pages, 'page')
function Owl:Init(library)
	if Owl._currentWindow and (not library or library == true or type(library) ~= "table" or not library.Title) then
		pcall(function()
			local folder = Owl.Folder or Owl.ConfigFolder or "OwlHub"
			local filePath = folder .. "/" .. tostring(game and game.GameId or "0") .. ".txt"
			if isfile and isfile(filePath) then
				local content = readfile(filePath)
				if content and content ~= "" then
					LoadCfg(content)
					if Owl.MakeNotification then
						Owl:MakeNotification({
							Name = "Configuration",
							Content = "Auto-isLoaded configuration for the game " .. tostring(game.GameId) .. ".",
							Time = 5
						})
					elseif Owl.Notify then
						Owl:Notify({
							Title = "Configuration",
							Content = "Auto-isLoaded configuration for the game " .. tostring(game.GameId) .. ".",
							Duration = 5
						})
					end
				end
			end
		end)
		return Owl._currentWindow
	end

	library = library or {}
	ui.Enabled = true
	if isLoaded == false then
		local UI_TAG = "OwlUILoader"
		local MARKER_NAME = "OWLUIDetector"
		local INTERNAL_UUID = ("OWL-" .. tostring(game.JobId):gsub("-", "") .. tostring(tick())):gsub("%.", "")
		local PROTECTION_EVENT = Instance.new("BindableEvent")
		local HttpService = game:GetService("HttpService")
		local function deepCleanup()
			for _, v in ipairs(GuiRoot:GetChildren()) do
				if v:IsA("ScreenGui") then
					local name = string.lower(v.Name)
					local isLegacyUi = v:FindFirstChild(MARKER_NAME)
						or string.find(name, "syde", 1, true)
						or string.find(name, "owlui", 1, true)
					for _, child in ipairs(v:GetDescendants()) do
						if child:IsA("TextLabel") and string.find(string.lower(child.Text or ""), "luffyhub", 1, true) then
							isLegacyUi = true
							break
						end
					end
					if isLegacyUi then
						pcall(function()
							v:Destroy()
						end)
					end
				end
			end
		end
		deepCleanup()
		local successLibrary, uiAsset = pcall(function()
			return uiAsset -- Replace with actual GetObjects if needed
		end)

		if not successLibrary or not uiAsset then
			Owl:Report("Loading UI library", "uiAsset/GetObjects returned nil - the UI asset failed to load")
			return
		end

		uiAsset.Name = UI_TAG
		uiAsset.ResetOnSpawn = false

		local marker = Instance.new("StringValue")
		marker.Name = MARKER_NAME
		marker.Value = INTERNAL_UUID
		marker.Parent = uiAsset

		pcall(function()
			uiAsset.Parent = GuiRoot
		end)
		task.spawn(function()
			while uiAsset and uiAsset.Parent do
				task.wait(1)
				if uiAsset.Parent ~= GuiRoot then
					warn("[OWL] UI moved. Restoring...")
					pcall(function()
						uiAsset.Parent = GuiRoot
					end)
				end
			end
		end)

	end
	task.wait(0.1)

	local Data = {
		Title = library.Title or "Owl";
		SubText = library.SubText or "Google";
		Home = {Enabled = false}
	}
	local homePage = window.pages:FindFirstChild("home")
	if homePage then
		homePage.Visible = false
	end
	local homeTab = window.tabs:FindFirstChild("Home")
	if homeTab then
		local homeInteract = homeTab:FindFirstChild("homeicon") and homeTab.homeicon:FindFirstChild("interact")
		if homeInteract then
			homeInteract.Interactable = false
		end
	end
	local wallpaper = window:FindFirstChild("wallpaper")
	if wallpaper then
		wallpaper.Visible = false
		local wallpaperState = window.wallpaper:FindFirstChild("ison")
		if wallpaperState then
			wallpaperState.Value = false
		end
	end
	for _, object in ipairs(homePage and homePage:GetDescendants() or {}) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			local text = string.lower(object.Text or "")
			if string.find(text, "luffy", 1, true) or string.find(text, "nicko", 1, true) then
				object.Text = ""
				object.Visible = false
			end
		end
	end
	
	local Minihome = ui.minihome
	Owl.WatermarkEnabled = library.Watermark == true

	function Owl:SetWatermarkEnabled(enabled)
		self.WatermarkEnabled = enabled == true
		if Minihome then
			Minihome.Visible = self.WatermarkEnabled or Services.UserInput.TouchEnabled
		end
	end

	Owl:SetWatermarkEnabled(Owl.WatermarkEnabled)
	Owl:AddConnection(Services.UserInput:GetPropertyChangedSignal("TouchEnabled"), function()
		Owl:SetWatermarkEnabled(Owl.WatermarkEnabled)
	end)

	local MinihomeData = {
		QuickActions = library.QuickActions or false;
	}
	local lastTime = tick()
	local frames = 0

	if isMinihomeRuntimeActive then
		rs = RunService.RenderStepped:Connect(function()
			local info = Minihome and Minihome:FindFirstChild("info")
			if not info then
				if rs then rs:Disconnect() end
				return
			end
			frames += 1
			local now = tick()

			if now - lastTime >= 1 then
				local fps = math.floor(frames / (now - lastTime))
				lastTime = now
				frames = 0

				info.fps.Text = fps .. " FPS"
			end
			local hour = tonumber(os.date("%I"))
			info.time.Text = hour .. os.date(":%M")
		end)


		if MinihomeData.QuickActions == false then
			ui.minihome.quick.Visible = false
			ui.minihome:TweenSize(UDim2.new(0, 150, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.8, true)
		end
	end


	ui.minihome.open.quickfunc.interact.MouseButton1Click:Connect(function()
		if uiRuntime.isClosed then
			ToggleUI()
		end
	end)
	top.title.Text = Data.Title
	top.title.sub.Text = Data.SubText
	Owl:AddDrag(top, window, true)
	if Minihome then
		Owl:AddDrag(Minihome, Minihome) -- make the watermark draggable
	end
	Owl:MakeResizable(window.resize, window, Vector2.new(454, 228))
	top.title.TextTransparency = 1
	Services.Tween:Create(top.title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	top.title.sub.TextTransparency = 1
	Services.Tween:Create(top.title.sub, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

	task.spawn(function()
		task.wait(0.5)
		local titleTween = Services.Tween:Create(top.title, TweenInfo.new(1.65, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		titleTween:Play()

		task.wait(0.1)
		local subTitleTween = Services.Tween:Create(top.title.sub, TweenInfo.new(1.65, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		subTitleTween:Play()

		task.wait()
		local textSize = top.title.TextBounds.X + 3

		Services.Tween:Create(top.title, TweenInfo.new(1.55, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0, textSize, 0, 20)
		}):Play()
	end)

	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")

	local RainbowStates = {}


	for _, v in ipairs(top.functions:GetChildren()) do
		if not v:IsA("Frame") then continue end
		if not v:FindFirstChild("ImageLabel") then continue end

		local image = v.ImageLabel
		local rain
		local gradient
		if v.Name == "plugins" then
			rain = v.rainbow
			gradient = rain:FindFirstChildOfClass("UIGradient")
		end

		if v.Name == "plugins" then
			RainbowStates[v] = {
				hue = math.random(),
				connection = nil,
			}
		end

		v.MouseEnter:Connect(function()
			if not uiRuntime.isClosed then
				if v.Name ~= "plugins" then
					TweenService:Create(
						image,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.7 }
					):Play()
				end
			end


			if v.Name == "plugins" and gradient then
				Services.Tween:Create(v.rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()
				local state = RainbowStates[v]
				if state.connection then return end

				state.connection = RunService.RenderStepped:Connect(function(dt)
					state.hue = (state.hue + dt * 0.6) % 1

					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(state.hue, 1, 1)),
						ColorSequenceKeypoint.new(0.2, Color3.fromHSV((state.hue + 0.2) % 1, 1, 1)),
						ColorSequenceKeypoint.new(0.4, Color3.fromHSV((state.hue + 0.4) % 1, 1, 1)),
						ColorSequenceKeypoint.new(0.6, Color3.fromHSV((state.hue + 0.6) % 1, 1, 1)),
						ColorSequenceKeypoint.new(0.8, Color3.fromHSV((state.hue + 0.8) % 1, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV((state.hue + 1) % 1, 1, 1)),
					})
				end)

			end
		end)


		v.MouseLeave:Connect(function()
			if not uiRuntime.isClosed then
				if v.Name ~= "plugins" then
					TweenService:Create(
						image,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }
					):Play()
				end
			end


			if v.Name == "plugins" then
				Services.Tween:Create(v.rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
				local state = RainbowStates[v]
				if state and state.connection then
					state.connection:Disconnect()
					state.connection = nil
				end

			end
		end)
	end


	

	window.search.close.interact.MouseButton1Click:Connect(function()
		closesearch()
	end)


	local debounce = false
	local DEBOUNCE_TIME = 0.1

	top.functions.search.interact.MouseButton1Click:Connect(function()
		if debounce then return end
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



	Owl:AddConnection(Owl.Comms.Event, function(p, value)
		if p == "Accent" then
			for i, glow in pairs(window.clipframe:GetChildren()) do
				if glow:IsA("ImageLabel") then
					Services.Tween:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageColor3 = value}):Play()
				end
			end
			Services.Tween:Create(window.shadow.glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageColor3 = value}):Play()
			Services.Tween:Create(window.shadow.glow1, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageColor3 = value}):Play()
		end
	end)
	SetUserInfo()
	Services.Tween:Create(window.user.headshot.id.username, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, window.user.headshot.id.username.TextBounds.X + 10,0, 10)}):Play()

	if not isUserInfoHidden then
		Services.Tween:Create(window.tabs, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 200,1, -115) }):Play()
	else
		Services.Tween:Create(window.tabs, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 200,1, -75) }):Play()
	end

	window.user.MouseEnter:Connect(function()
		Services.Tween:Create(window.user.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Quart), {Thickness = 1}):Play()
	end)
	window.user.MouseLeave:Connect(function()
		Services.Tween:Create(window.user.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Quart), {Thickness = 0}):Play()
	end)

	if Data.Home.Enabled then

		window.pages.home.general.presence.Profile.ImageLabel.Text.Header.Text = Data.Home.hTitle
		window.pages.home.general.presence.Profile.ImageLabel.Text.Sub.Text = Data.Home.hSubText

		window.pages.home.general.presence.Profile.ImageLabel.Image = 'rbxassetid://'..Data.Home.profileImage
		window.pages.home.general.presence.wallpaper.Image = 'rbxassetid://'..Data.Home.profileImage
		
		local placeId = game.PlaceId

		window.pages.home.general.presence.PlaceID.Text =
			"Place ID: "..placeId

	

		local layout = Bento.new(window.pages.home.general.Quick,{
			Gap = 6,
			RightPadding = 20,
			TweenTime = 0.35
		})
		local row1 = layout:NewRow()
		local row2 = layout:NewRow()
		local row3 = layout:NewRow()

		layout:AddItem(window.pages.home.general.Quick.QuickPlay,nil,row1)
		layout:AddItem(window.pages.home.general.Quick.Player,nil,row1)
		layout:AddItem(window.pages.home.general.Quick.Latency,nil,row3)

		layout:AddItem(
			window.pages.home.general.Quick.QuickSettings,
			{Bottom = true},
			row2
		)


		layout:Bind()
		layout:Update()


		local Stats = game:GetService("Stats")
		local TweenService = game:GetService("TweenService")

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
		local gridBuilt = false

		repeat task.wait() until graph.AbsoluteSize.X > 0


		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")

		local function getPing()

			local ping =
				Players.LocalPlayer:GetNetworkPing() * 1000

			if ping == 0 and RunService:IsStudio() then

				return 50 + math.noise(os.clock()*0.5)*40

			end

			return math.floor(ping)

		end



		local function clear()

			for _,obj in ipairs(graph:GetChildren()) do

				if obj ~= pointTemplate
					and obj ~= lineTemplate then

					obj:Destroy()

				end

			end

		end


		local function createGrid()

			local w = graph.AbsoluteSize.X
			local h = graph.AbsoluteSize.Y

			local steps = 4

			for i=0,steps do

				local percent = i/steps
				local y = h - (percent*h)

				local gridLine = Instance.new("Frame")
				gridLine.Size = UDim2.fromOffset(w,1)
				gridLine.Position = UDim2.fromOffset(34,y)
				gridLine.BackgroundTransparency = 0.85
				gridLine.BorderSizePixel = 0
				gridLine.Parent = graph


				local label = Instance.new("TextLabel")
				label.Size = UDim2.fromOffset(40,14)
				label.Position = UDim2.fromOffset(2,y-7)

				label.BackgroundTransparency = 1
				label.TextSize = 6
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextColor3 = Color3.fromRGB(255, 255, 255)

				label.Text =
					math.floor(percent*MAX_PING)
					.." ms"

				label.TextTransparency = 0

				label.Parent = graph

			end

		end



		local function draw()

			clear()
			createGrid()

			local w = graph.AbsoluteSize.X
			local h = graph.AbsoluteSize.Y

			local step = w/(MAX_POINTS-1)

			local lastX,lastY

			for i,value in ipairs(smoothHistory) do

				local percent =
					math.clamp(value/MAX_PING,0,1)

				local x = (i-1)*step
				local y = h - (percent*h)


				local point = pointTemplate:Clone()
				point.Visible = false
				point.Position = UDim2.fromOffset(x,y)
				point.AnchorPoint = Vector2.new(0.5,0.5)

				point.Parent = graph


				if lastX then

					local dx = x-lastX
					local dy = y-lastY

					local length =
						math.sqrt(dx*dx + dy*dy)

					local angle =
						math.deg(math.atan2(dy,dx))

					local midX = (lastX + x)/2
					local midY = (lastY + y)/2

					local line = lineTemplate:Clone()

					line.Visible = true
					line.AnchorPoint = Vector2.new(0.5,0.5)

					line.Position =
						UDim2.fromOffset(midX,midY)

					line.Size =
						UDim2.fromOffset(length,1)

					line.Rotation = angle

					line.Parent = graph

				end


				lastX = x
				lastY = y

			end

		end



		task.spawn(function()
			while true do

				local ping = getPing()

				table.insert(history,ping)

				if #history > MAX_POINTS then
					table.remove(history,1)
				end
				for i,v in ipairs(history) do

					local current =
						smoothHistory[i] or v

					smoothHistory[i] =
						current + (v-current)*SMOOTH_SPEED

				end


				draw()

				task.wait(UPDATE_INTERVAL)

			end
		end)

		local bh = window.pages.home.general.Quick.QuickSettings.QuickButtons.holder

		for i,v in ipairs(window.pages.home.general.Quick.QuickSettings.QuickButtons.holder:GetChildren()) do
			if v:IsA('Frame') then
				v.MouseEnter:Connect(function()
					Services.Tween:Create(v.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end)

				v.MouseLeave:Connect(function()
					Services.Tween:Create(v.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
				end)
			end
		end

		bh.Leave.interact.MouseButton1Click:Connect(function()

			game:GetService("Players").LocalPlayer:Kick("Left the experience")

		end)

		bh.Rejoin.interact.MouseButton1Click:Connect(function()

			local TeleportService = game:GetService("TeleportService")
			local rejoinPlayer = Services.Players.LocalPlayer

			TeleportService:Teleport(game.PlaceId, rejoinPlayer)

		end)

		local HttpService = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")
		local Players = game:GetService("Players")

		local localPlayer = Players.LocalPlayer

		local placeId = game.PlaceId
		local httpRequest = (syn and syn.request)
			or (http and http.request)
			or http_request
			or request

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

				local url =
					"https://games.roblox.com/v1/games/"
					..placeId..
					"/servers/Public?sortOrder=Asc&limit=100&cursor="
					..cursor

				local ok, response = pcall(function()
					return HttpService:JSONDecode(httpGet(url))
				end)

				if not ok or type(response) ~= "table" or not response.data then
					break
				end

				for _,server in pairs(response.data) do

					if server.playing < server.maxPlayers
						and server.id ~= game.JobId then

						table.insert(servers,server.id)

					end

				end

				cursor = response.nextPageCursor

			until cursor == nil or #servers > 0


			if #servers > 0 then

				TeleportService:TeleportToPlaceInstance(
					placeId,
					servers[math.random(1,#servers)],
					Services.Players
				)

			end

		end

		bh.Fast.interact.MouseButton1Click:Connect(function()

			ServerHop()

		end)
		
		local Players = game:GetService("Players")

		local label = window.pages.home.general.Quick.Player.Frame.TextLabel -- put script inside TextLabel

		local function update()

			local current =
				#Players:GetPlayers()

			local max =
				Players.MaxPlayers

			label.Text =
				current.." / "..max

		end


		update()

		Players.PlayerAdded:Connect(update)
		Players.PlayerRemoving:Connect(update)
		
		local QuickPlay = window.pages.home.general.Quick.QuickPlay

		local HttpService = game:GetService("HttpService")
		local MarketplaceService = game:GetService("MarketplaceService")
		local TeleportService = game:GetService("TeleportService")

		local FILE = Owl.ConfigFolder .. "/last_game.json"
		local function SaveLastGame(placeId)
			if not Owl.ConfigEnabled then return end

			local data = {
				PlaceId = placeId,
				Time = os.time()
			}

			pcall(function()
				writefile(FILE, HttpService:JSONEncode(data))
			end)
		end
		local function LoadLastGame()
			if not Owl.ConfigEnabled then return nil end
			if not isfile(FILE) then return nil end

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

			local id=placeId -- your game id
			local thumbnailUrl="https://www.roblox.com/asset-thumbnail/image?assetId="..id.."&width=768&height=432&format=png"
			QuickPlay.thumb.Image=thumbnailUrl

		else

			warn("Failed to get game info for", placeId)

		end
		task.delay(120, function()
			if Owl and Owl.ConfigEnabled then
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
		local legacyHome = window.pages:FindFirstChild("home")
		if legacyHome then
			legacyHome.Visible = false
		end
		local legacyHomeTab = window.tabs:FindFirstChild("Home")
		local legacyHomeButton = legacyHomeTab and legacyHomeTab:FindFirstChild("homeicon")
		local legacyHomeInteract = legacyHomeButton and legacyHomeButton:FindFirstChild("interact")
		if legacyHomeInteract then
			legacyHomeInteract.Interactable = false
		end
	end



	function opensettings()
		if settingsOpen and window.settings.Visible then return end
		window.dim.ZIndex = 90
		window.dim.Active = false
		window.settings.ZIndex = 100
		window.settings.Active = true
		for _, descendant in ipairs(window.settings:GetDescendants()) do
			if descendant:IsA("GuiObject") then
				descendant.ZIndex = math.max(descendant.ZIndex, 101)
			end
		end
		window.settings.Visible = true
		window.dim.Visible = true

		Services.Tween:Create(window.settings, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 360,0, 400)}):Play()
		Services.Tween:Create(window.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.2 }):Play()
		Services.Tween:Create(window.settings.UICorner, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { CornerRadius = UDim.new(0,20)}):Play()

		Services.Tween:Create(window.settings, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0}):Play()
		window.settings.pages.Visible = true
		window.settings.tabs.Visible = true

		Services.Tween:Create(window.settings.top.title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0}):Play()
		Services.Tween:Create(window.settings.top.separator, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0}):Play()
		Services.Tween:Create(window.settings.top.functions.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0}):Play()
		Services.Tween:Create(window.settings.top.functions.close.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0}):Play()
	end

	function closesettings()
		if not window.settings.Visible then
			if not searchopen then
				window.dim.Visible = false
				window.dim.BackgroundTransparency = 1
				window.dim.Active = false
			end
			return
		end
		Services.Tween:Create(window.settings, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 360,0, 150)}):Play()
		Services.Tween:Create(window.dim, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
		Services.Tween:Create(window.settings.UICorner, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { CornerRadius = UDim.new(0, 90)}):Play()

		Services.Tween:Create(window.settings, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
		window.settings.pages.Visible = false
		window.settings.tabs.Visible = false

		Services.Tween:Create(window.settings.top.title, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { TextTransparency = 1}):Play()
		Services.Tween:Create(window.settings.top.separator, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
		Services.Tween:Create(window.settings.top.functions.close, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
		Services.Tween:Create(window.settings.top.functions.close.ImageLabel, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { ImageTransparency = 1}):Play()
		task.delay(0.35, function()
			if not settingsOpen then
				window.settings.Visible = false
				window.settings.Active = false
				window.dim.Visible = false
				window.dim.Active = false
			end
		end)
	end

	if not settingsOpen then
		closesettings()
	end
	window.settings.Visible = false
	window.settings.Active = false
	window.settings.pages.Visible = false
	window.settings.tabs.Visible = false
	window.search.Visible = false
	window.search.Active = false
	window.search.Container.Visible = false
	window.dim.Visible = false
	window.dim.BackgroundTransparency = 1
	window.dim.Active = false

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
		if not uiRuntime.isClosed then
			ToggleUI()
		end
	end)

	


	do
		local settings = {}

		local tbdata = {
			first = false,
			selected = false
		}

		function settings:inittab(tab)
			local telement = {}
			local tdata = {
				Title = tab.Title
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
				Services.Tween:Create(tabButton, bgTween, {
					BackgroundColor3 = selected
						and Color3.fromRGB(31, 31, 31)
						or Color3.fromRGB(16, 16, 16)
				}):Play()

				Services.Tween:Create(tabButton.title, textTween, {
					TextTransparency = selected and 0 or 0.6
				}):Play()
			end
			if not tbdata.selectedTab then
				tbdata.selectedTab = Tab
				Page.Visible = true
				ApplyTabStyle(Tab, true)
			else
				ApplyTabStyle(Tab, false)
			end
			Tab.interact.MouseButton1Click:Connect(function()
				if tbdata.selectedTab == Tab then return end
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
					Title = Button.Title or "Temp Button";
					CallBack = Button.CallBack;
					Desc = Button.Description or "";
					Type = Button.Type or 'Default';
					HoldTime = Button.HoldTime or 3;
				}

				local button = window.settings.pages.page.Button:Clone()
				button.Visible = true
				button.Parent = Page
				button.title.Text = data.Title
				button.Name = data.Title
				button.title.Size = UDim2.new(0, button.title.TextBounds.X + 15,0, 35)

				local c

				c = data.CallBack


				local fOTween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)
				local fITween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)

				if data.Type == 'Default' then

					button.interact.MouseButton1Down:Connect(function()
						Services.Tween:Create(button.UIStroke, fOTween, { Transparency = 1 }):Play()
						Services.Tween:Create(button.ImageLabel, fOTween, { ImageTransparency = 1 }):Play()
						Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
					end)

					button.interact.MouseButton1Up:Connect(function()
						Services.Tween:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
						Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()


					end)

					button.interact.MouseButton1Click:Connect(function()
						if data.CallBack then
							local success, errorMsg = pcall(c)
							if not success then
								Owl:Report("Button '" .. button.Name .. "' callback", errorMsg)

							end
						else
							warn(`[ CallBack Missing: { button.Name } ] No Function Assigned`)
						end
					end)
					button.interact.MouseLeave:Connect(function()
						Services.Tween:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
						Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()
					end)
				elseif data.Type == 'Hold' then
					local HoldTime = data.HoldTime
					local Holding = false
					local TimeLeft = HoldTime
					local Complete = false

					button.ImageLabel.Image = 'rbxassetid://127075195365098'
					button.ImageLabel.Rotation = 0
					button.ImageLabel.Size = UDim2.new(0, 16,0, 16)
					button.ImageLabel.Position = UDim2.new(1, -41,0.5, 0)

					local function CancelOperation()
						Holding = false
						Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()
						Services.Tween:Create(button.title.timer, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
						if not Complete then
							Services.Tween:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
							Services.Tween:Create(button.UIStroke.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()
							Services.Tween:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,-15 ,0 ,button.Position.Y.Offset) }):Play()
							task.wait(0.15)
							Services.Tween:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,30 ,0 ,button.Position.Y.Offset) }):Play()
							task.wait(0.15)
							Services.Tween:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,0 ,0 ,button.Position.Y.Offset) }):Play()
							task.wait(1)
							Services.Tween:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0 }):Play()
						end

						TimeLeft = HoldTime
						button.title.timer.Text = tostring(HoldTime)
						task.wait(0.1)
						Complete = false
					end

					button.interact.MouseButton1Down:Connect(function()

						Holding = true
						TimeLeft = HoldTime
						button.title.timer.Text = tostring(TimeLeft)
						Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
						Services.Tween:Create(button.title.timer, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
						Services.Tween:Create(button.UIStroke.UIGradient, TweenInfo.new(HoldTime, Enum.EasingStyle.Linear), { Offset = Vector2.new(0.7, 0) }):Play()
						Services.Tween:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0}):Play()
						while Holding and TimeLeft > 0 do
							TimeLeft = math.max(0, TimeLeft - Services.Run.Heartbeat:Wait())
							button.title.timer.Text = string.format("%.1f", TimeLeft) 

						end

						if TimeLeft <= 0 then
							Complete = true

							if data.CallBack then
								local success, errorMsg = pcall(data.CallBack)
								if not success then
									Owl:Report("Element callback", errorMsg)
								end
							else
								warn("[CALLBACK MISSING]: No Function Assigned To", data.Title)
							end

							Services.Tween:Create(button, TweenInfo.new(0.34, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }):Play()
							Services.Tween:Create(button.UIStroke.UIGradient, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()
							task.wait(0.34)
							Services.Tween:Create(button, TweenInfo.new(0.34, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }):Play()
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
							local textSize = Services.Text:GetTextSize(
								descLabel.Text,
								descLabel.TextSize,
								descLabel.Font,
								Vector2.new(descLabel.AbsoluteSize.X, math.huge)
							)

							local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
							local newButtonSize = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, 0, button.title.Size.Y.Offset + textSize.Y + 10)
							Services.Tween:Create(button.UICorner, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CornerRadius = UDim.new(0,20) }):Play()
							local descTween = Services.Tween:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
							descTween:Play()

							local buttonTween = Services.Tween:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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
					Title = Toggle.Title or "Temp Toggle";
					Desc = Toggle.Description or "";
					V = Toggle.Value or false;
					Config = Toggle.Config or false;
					CallBack = Toggle.CallBack;
					SFlag = Toggle.SFlag;
					SettingsConfig = true;
				}

				local toggle = window.settings.pages.page.Toggle:Clone()
				toggle.Visible = true
				toggle.Parent = Page
				toggle.title.Text = data.Title
				toggle.Name = data.Title


				local toggleConfiguration = ui.Render.ToggleConfiguration:Clone()
				toggleConfiguration.Parent = ui.Render
				toggleConfiguration.Visible = false

				toggleConfiguration.Container.KeyBind.Bind.v.Text = 'None'
				Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,0, 25) }):Play()

				toggleConfiguration.BackgroundTransparency = 1
				toggleConfiguration.Container.KeyBind.Title.TextTransparency = 1
				toggleConfiguration.Container.KeyBind.Bind.BackgroundTransparency = 1
				toggleConfiguration.Container.KeyBind.Bind.v.TextTransparency = 1
				toggleConfiguration.Container.Clear.Title.TextTransparency = 1
				toggleConfiguration.Container.Clear.clear.ImageLabel.ImageTransparency = 1
				toggleConfiguration.Size = UDim2.new(0, 75,0, 53)

				if not data.Config then
					toggle.configure:Destroy()
				end

				local toggleTween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)
				local fadeTween = TweenInfo.new(0.57, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

				local function UpdateToggleUI(state)
					local targetColor = state and Owl.theme.HitBox or Color3.fromRGB(28, 28, 28)
					local strokeTransparency = state and 1 or 0
					local checkTransparency = state and 0 or 1
					local gradientTransparency = state and 0 or 1
					local glowTransparency = state and 0.7 or 1
					local textTransparency = state and 0 or 0.5

					Services.Tween:Create(toggle.tog, toggleTween, { BackgroundColor3 = targetColor }):Play()
					Services.Tween:Create(toggle.tog.check, toggleTween, { ImageTransparency = checkTransparency }):Play()
					Services.Tween:Create(toggle.tog.gradfr, fadeTween, { BackgroundTransparency = gradientTransparency }):Play()
					Services.Tween:Create(toggle.tog.glow, toggleTween, { ImageTransparency = glowTransparency }):Play()
					Services.Tween:Create(toggle.tog.glow, toggleTween, { ImageColor3 = targetColor }):Play()
					Services.Tween:Create(toggle.title, toggleTween, { TextTransparency = textTransparency }):Play()
				end

				UpdateToggleUI(data.V)

				toggle.interact.MouseButton1Click:Connect(function()
					data.V = not data.V
					UpdateToggleUI(data.V)

					local success, errorMsg = pcall(function()
						if data.CallBack then
							data.CallBack(data.V)
						end
					end)

					if not success then
						Owl:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
					end
				end)
				local descLabel = toggle:FindFirstChild("desc")

				if descLabel then
					if data.Desc and data.Desc ~= "" then
						descLabel.Text = data.Desc
						descLabel.Visible = true
						descLabel.TextWrapped = true

						local function updateSize()
							local textSize = Services.Text:GetTextSize(
								descLabel.Text,
								descLabel.TextSize,
								descLabel.Font,
								Vector2.new(descLabel.AbsoluteSize.X, math.huge)
							)

							local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
							local newButtonSize = UDim2.new(toggle.Size.X.Scale, toggle.Size.X.Offset, 0, toggle.title.Size.Y.Offset + textSize.Y + 10) -- Adding extra padding
							Services.Tween:Create(toggle.UICorner, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CornerRadius = UDim.new(0,20) }):Play()
							local descTween = Services.Tween:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
							descTween:Play()

							local ToggleTween = Services.Tween:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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
						Services.Tween:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					end)

					toggle.configure.MouseLeave:Connect(function()
						Services.Tween:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(104, 104, 104) }):Play()
					end)

					local function ToggleConfigOpen()
						toggleConfiguration.Visible = true
						State = true

						Services.Tween:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 0 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 0 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 0 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 0 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 0 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, enterTween, { ImageTransparency = 0 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 0 }):Play()
						Services.Tween:Create(toggleConfiguration, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 174,0, 88) }):Play()

					end

					local function ToggleConfigClose()
						State = false

						Services.Tween:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 1 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 1 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 1 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 1 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 1 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, enterTween, { ImageTransparency = 1 }):Play()
						Services.Tween:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 1 }):Play()
						Services.Tween:Create(toggleConfiguration, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 75,0, 53) }):Play()
						task.wait(0.5)

						toggleConfiguration.Visible = false

					end

					local TogService
					local heldKeys = {} 
					local debounce1 = false

					local function ToggleConfig()
						if debounce1 then return end
						debounce1 = true

						if not toggleConfiguration.Visible then
							TogService = Services.Run.RenderStepped:Connect(function()
								toggleConfiguration:TweenPosition(UDim2.new(0,toggle.configure.AbsolutePosition.X - 190,0,toggle.configure.AbsolutePosition.Y + toggle.configure.AbsoluteSize.Y + 65), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
								if not toggleConfiguration.Visible then
									TogService:Disconnect()
								end
							end)
							ToggleConfigOpen()
						else
							if TogService then TogService:Disconnect() end
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
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,0, 25) }):Play()
					end

					local function setKeybind(key)
						if not key then
							toggleConfiguration.Container.KeyBind.Bind.v.Text = 'None'
							ResizeBindFrame()
							data.Keybind = nil
						else
							data.Keybind = key
							data.KeybindReady = false

							Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
							toggleConfiguration.Container.KeyBind.Bind.v.Text = key.Name
							Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
							ResizeBindFrame()

							task.delay(0.5, function()
								data.KeybindReady = true
							end)
						end
					end

					toggleConfiguration.Container.KeyBind.Interact.MouseButton1Click:Connect(function()
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
						task.wait(0.2)
						toggleConfiguration.Container.KeyBind.Bind.v.Text = "..."
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
						ResizeBindFrame()


						local connection
						connection = Services.UserInput.InputBegan:Connect(function(input, processed)
							if not Services.UserInput:GetFocusedTextBox() and Owl:IsBindableInput(input) then
								setKeybind(input.KeyCode)
								connection:Disconnect()
							end
						end)
					end)

					Services.UserInput.InputBegan:Connect(function(input, processed)
						if not Services.UserInput:GetFocusedTextBox() and data.Keybind and data.KeybindReady and input.KeyCode == data.Keybind then
							data.V = not data.V
							UpdateToggleUI(data.V)

							if data.CallBack then
								local success, errorMsg = pcall(function()
									data.CallBack(data.V)
								end)
								if not success then
									Owl:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
								end
							end
						end
					end)

					local debounce2 = false

					toggleConfiguration.Container.Clear.Interact.MouseButton1Click:Connect(function()
						if debounce2 then return end
						debounce2 = true

						setKeybind(nil)

						local function blink()
							Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = 13 }):Play()
							task.wait(0.2)
							Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = -13 }):Play()
							task.wait(0.2)
							Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = 0 }):Play()
						end

						blink()

						task.delay(2, function()
							debounce2 = false
						end)
					end)

					toggleConfiguration.Container.Clear.MouseEnter:Connect(function()
						Services.Tween:Create(toggleConfiguration.Container.Clear.clear, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.9 }):Play()
					end)

					toggleConfiguration.Container.Clear.MouseLeave:Connect(function()
						Services.Tween:Create(toggleConfiguration.Container.Clear.clear, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
					end)

				end

				Owl:AddConnection(Owl.Comms.Event, function(p, color)
					if p == 'HitBox' then
						if data.V then
							task.wait(0.5)
							toggle.tog.BackgroundColor3 = color
							toggle.tog.glow.ImageColor3 = color
						end
					end
				end)

				function data:Set(NewValue)
					data.V = NewValue
					data.Value = NewValue
					UpdateToggleUI(NewValue)

					local success, errorMsg = pcall(function()
						if data.CallBack then
							data.CallBack(NewValue)
						end
					end)

					if not success then
						Owl:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
					end
				end

				data.Type = "Toggle"
				data.Save = Toggle.Save ~= false
				data.Value = data.V
				local flagKey = Toggle.Flag or Toggle.SFlag or Toggle.Title
				data.Flag = flagKey
				if flagKey then
					Owl.Flags[flagKey] = data
				end
				if data.SFlag then
					Owl.SettingsFlags[data.SFlag] = data
				end

				return data
			end

			function telement:Keybind(Keybind)
				local flagKey = Keybind.Flag or Keybind.SFlag or Keybind.Title or "Keybind"
				local initialKey = Keybind.Key or Keybind.Default
				if Owl.LoadedConfig and Owl.LoadedConfig[flagKey] ~= nil then
					local saved = Owl.LoadedConfig[flagKey]
					local success, keyEnum = pcall(function()
						return Enum.KeyCode[saved] or Enum.UserInputType[saved]
					end)
					if success and keyEnum then
						initialKey = keyEnum
					end
				end

				local data = {
					Title = Keybind.Title or "Keybind";
					Key = initialKey;
					Value = initialKey and (typeof(initialKey) == "EnumItem" and initialKey.Name or tostring(initialKey)) or "NONE";
					Desc = Keybind.Description or "";
					CallBack = Keybind.CallBack;
					WaitingForKey = false;
					Hold = false;
					Holding = false;
					Type = "Bind";
					Save = Keybind.Save ~= false;
					Flag = flagKey;
					SFlag = Keybind.SFlag;
				}

				local KeyBind = window.settings.pages.page.KeyBind:Clone()
				KeyBind.Visible = true
				KeyBind.Parent = Page
				KeyBind.title.Text = data.Title
				KeyBind.Name = data.Title

				KeyBind.Bind.v.Text = data.Key and (typeof(data.Key) == "EnumItem" and data.Key.Name or tostring(data.Key)) or "NONE"
				Services.Tween:Create(KeyBind.Bind, TweenInfo.new(0.55, Enum.EasingStyle.Quint ), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()

				KeyBind.interact.MouseButton1Click:Connect(function()
					KeyBind.Bind.v.Text = '...'
					Services.Tween:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Thickness = 1}):Play()
					data.WaitingForKey = true
				end)

				KeyBind.Bind.v:GetPropertyChangedSignal('TextBounds'):Connect(function()
					Services.Tween:Create(KeyBind.Bind, TweenInfo.new(0.55, Enum.EasingStyle.Quint ), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()
				end)

				local function SetKeybind(keyCode)
					if keyCode and keyCode ~= Enum.KeyCode.Unknown then
						if typeof(keyCode) == "string" then
							keyCode = Enum.KeyCode[keyCode] or Enum.UserInputType[keyCode] or keyCode
						end
						data.Key = keyCode
						data.Value = typeof(keyCode) == "EnumItem" and keyCode.Name or tostring(keyCode)
						KeyBind.Bind.v.Text = data.Value
						Services.Tween:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Thickness = 0}):Play()
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
				Owl:AddConnection(Services.UserInput.InputBegan, function(input, processed)
					if data.WaitingForKey then
						if Owl:IsBindableInput(input) then
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

					if Services.UserInput:GetFocusedTextBox() then return end
					if input.KeyCode == Enum.KeyCode.Unknown then return end

					local isMatch = false
					if typeof(data.Key) == "EnumItem" then
						if data.Key.EnumType == Enum.KeyCode and input.KeyCode == data.Key then
							isMatch = true
						elseif data.Key.EnumType == Enum.UserInputType and input.UserInputType == data.Key then
							isMatch = true
						end
					end

					if isMatch then
						data.Hold = true

						local holdConnection
						holdConnection = input.Changed:Connect(function(prop)
							if prop == "UserInputState" then
								local state = input.UserInputState
								data.Hold = (state == Enum.UserInputState.Begin)
								if state == Enum.UserInputState.End and holdConnection then
									holdConnection:Disconnect()
								end
							end
						end)

						local success, result = pcall(data.CallBack)
						if not data.Holding then
							if not success then
								Owl:Report("Keybind '" .. KeyBind.Name .. "' callback", result)
							end
						else
							if data.Hold then
								local holdLoop
								holdLoop = Services.Run.RenderStepped:Connect(function()
									if not data.Hold then
										data.CallBack(false)
										holdLoop:Disconnect()
									else
										data.CallBack(false)
									end
								end)
							end
						end
					end
				end)

				data._frame = KeyBind
				data.toggle = function(self) KeyBind.Visible = not KeyBind.Visible end
				data.remove = function(self) KeyBind:Destroy() end

				if flagKey then
					Owl.Flags[flagKey] = data
				end
				if Keybind.SFlag then
					Owl.SettingsFlags[Keybind.SFlag] = data
				end

				return data
			end

			function telement:ColorPicker(ColorPicker)
				local data = {
					Title = ColorPicker.Title;
					Color = ColorPicker.Color;
					Color2 = ColorPicker.Color2;
					Linkable = ColorPicker.Linkable;
					Type = ColorPicker.Type or 'ColorPicker';
					GradientPath = ColorPicker.GradientPath;
					CallBack = ColorPicker.CallBack;
					SFlag = ColorPicker.SFlag;
				}

				ColorPicker.Linkable = ColorPicker.Linkable or true

				local colorpicker = window.settings.pages.page.ColorPicker:Clone()
				colorpicker.Visible = true
				colorpicker.Parent = Page
				colorpicker.title.Text = data.Title
				colorpicker.Name = data.Title

				local isLinkable = Instance.new("BoolValue")
				isLinkable.Name = 'isLinkable'
				isLinkable.Value = data.Linkable
				isLinkable.Parent = colorpicker

				local HueSat = Instance.new("Color3Value")
				HueSat.Name = 'HueSat'
				HueSat.Value = data.Color
				HueSat.Parent = colorpicker


				local Open = false
				local DeBounce = false
				local State = false

				do
					local HueValues = colorpicker.HueValues
					local list = HueValues:FindFirstChildOfClass("UIListLayout")
					if list then list:Destroy() end

					local ITEMS = {
						HueValues.HEX,
						HueValues.RGB,
						HueValues.Link
					}

					local GAP = 8
					local ITEM_HEIGHT = 30
					local ITEM_WIDTH = 120
					local HORIZONTAL_THRESHOLD = 260

					local function updateHueValuesLayout()
						if not HueValues.Visible then return end

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
						HueValues.Position = UDim2.new(0.5, 0,1, -50)

						if Open then
							Services.Tween:Create(
								colorpicker,
								TweenInfo.new(0.35, Enum.EasingStyle.Quart),
								{ Size = UDim2.new(1, -35, 0, 295 + totalHeight) }
							):Play()
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
				Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundColor3 = data.Color }):Play()

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
						Services.Tween:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0, startX , 0.8, -frame.Size.Y.Offset / 2) }):Play()
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
					if type(Table) ~= "table" then return Table end
					return Color3.fromHSV(Table[1],Table[2],Table[3])
				end

				local function FormatColor(Color, format, precision)

					format = format or "RGB"
					precision = precision or 2

					local formattedColor = ""

					if format == "RGB" then
						return	math.round(Color.R * 255) .. "," .. math.round(Color.G * 255) .. "," .. math.round(Color.B * 255)
					elseif format == "Hex" then
						formattedColor = string.format("#%02X%02X%02X",
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

						data.Color  = Keys[2].Value
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

					Services.Tween:Create(HUESlider.Pin, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {BackgroundColor3 = newColor2}):Play()
					Services.Tween:Create(SVPicker.Pin, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {BackgroundColor3 = newColor}):Play()


					Services.Tween:Create(SVPicker.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0)
					}):Play()

					Services.Tween:Create(HUESlider.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(1 - HSV[1], 0, 0.5, 0)
					}):Play()

					local formattedHex = FormatColor(data.Color, 'Hex')
					colorpicker.HueValues.HEX.V.HEXBox.PlaceholderText = formattedHex

					local formattedRGB = FormatColor(data.Color,'RGB', 2)
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
						if oldCallback then oldCallback(col) end
						return
					end

					table.sort(Keys, function(a,b) return a.Time < b.Time end)

					Keys[1] = ColorSequenceKeypoint.new(0, Keys[2].Value)
					Keys[4] = ColorSequenceKeypoint.new(1, Keys[3].Value)

					data.Color  = Keys[2].Value
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
						ColorSequenceKeypoint.new(1, endCol)         
					}

					ActivePin = 2 

					GradientFrame.Pin1.BackgroundColor3 = startCol
					GradientFrame.Pin2.BackgroundColor3 = endCol
				end

				local oldCallback = data.CallBack
				data.CallBack = function(col)
					if data.Type ~= "Gradient" then
						if oldCallback then oldCallback(col) end
						return
					end

					table.sort(Keys, function(a,b) return a.Time < b.Time end)
					Keys[1] = ColorSequenceKeypoint.new(0, Keys[1].Value)
					Keys[#Keys] = ColorSequenceKeypoint.new(1, Keys[#Keys].Value)

					local seq = ColorSequence.new(Keys)
					ExternalGradient.Color = seq
					GradientFrame.Gradient.Color = seq

					if oldCallback then oldCallback(seq) end
				end

				if data.Type == "Gradient" then
					local g = GradientFrame
					local UIS = game:GetService("UserInputService")
					local RS = game:GetService("RunService")
					local mouse = game.Players.LocalPlayer:GetMouse()

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
							ActivePin = 2
							local h, s, v = Keys[2].Value:ToHSV()
							HSV[1], HSV[2], HSV[3] = h, s, v
							updatestuff()
						end
					end)

					g.Pin2.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							DraggingPin = 3
							ActivePin = 3
							local h, s, v = Keys[3].Value:ToHSV()
							HSV[1], HSV[2], HSV[3] = h, s, v
							updatestuff()
						end
					end)

					UIS.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							DraggingPin = nil
						end
					end)

					RS.Heartbeat:Connect(function()
						if not DraggingPin then return end

						local relX = (mouse.X - g.AbsolutePosition.X) / g.AbsoluteSize.X
						relX = math.clamp(relX, 0, 1)

						if DraggingPin == 2 then
							relX = math.clamp(relX, 0, Keys[3].Time - 0.01) 
						elseif DraggingPin == 3 then
							relX = math.clamp(relX, Keys[2].Time + 0.01, 1) 
						end

						Keys[DraggingPin] = ColorSequenceKeypoint.new(relX, Keys[DraggingPin].Value)

						updateUI()
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

					Services.Tween:Create(colorpicker.UICorner, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CornerRadius = UDim.new(0,20) }):Play()
					Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.95, Enum.EasingStyle.Quart ), { Size = UDim2.new(0, 1,0, 1) }):Play()
					Services.Tween:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
					Services.Tween:Create(colorpicker.color, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1) }):Play()
					Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					task.wait(0.12)
					Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.9, Enum.EasingStyle.Quart ), { Size = UDim2.new(1, -40,0, 160) }):Play()
					Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.9, Enum.EasingStyle.Quart ), { Position = UDim2.new(0.5, 0,0, 40) }):Play()

					Services.Tween:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }):Play()
					Services.Tween:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Quart ), { Size = UDim2.new(1, -35,0, 300) }):Play()
					Services.Tween:Create(colorpicker.color.UICorner, TweenInfo.new( 0.8, Enum.EasingStyle.Quart ), { CornerRadius = UDim.new(0, 10) }):Play()

					Services.Tween:Create(colorpicker.color.Values.Rainbow, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()


					task.wait(0.6)

					Services.Tween:Create(colorpicker.color.SVPicker.Brightness, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.SVPicker.Saturation, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.SVPicker.Pin, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.SVPicker.Pin.UIStroke, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()

					task.wait(0.5)
					Services.Tween:Create(colorpicker.color.Values.Hue, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Hue.Pin, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Hue.Pin.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()

					if data.Type == "Gradient" then
						Services.Tween:Create(colorpicker.color.Values.Grad, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
						Services.Tween:Create(colorpicker.color.Values.Grad.Pin1, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
						Services.Tween:Create(colorpicker.color.Values.Grad.Pin1.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()
						Services.Tween:Create(colorpicker.color.Values.Grad.Pin2, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
						Services.Tween:Create(colorpicker.color.Values.Grad.Pin2.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()
					end

					Services.Tween:Create(colorpicker.HueValues.HEX, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
					Services.Tween:Create(colorpicker.HueValues.HEX.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
					Services.Tween:Create(colorpicker.HueValues.HEX.V.HEXBox, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { TextTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.HueValues.HEX.Copy, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()

					task.wait(0.09)
					Services.Tween:Create(colorpicker.HueValues.RGB, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
					Services.Tween:Create(colorpicker.HueValues.RGB.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
					Services.Tween:Create(colorpicker.HueValues.RGB.V.RGBBox, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { TextTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.HueValues.RGB.Copy, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()
					task.wait(0.09)
					Services.Tween:Create(colorpicker.HueValues.Link, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
					Services.Tween:Create(colorpicker.HueValues.Link.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
					Services.Tween:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.HueValues.Link.Frame.ImageLabel, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()

					for _,v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
						if v:IsA('Frame') then
							task.wait(0.1)
							Services.Tween:Create(v, TweenInfo.new( 0.3, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
						end
					end

					task.wait(0.7)
					DeBounce = false
				end


				colorpicker.interact.MouseButton1Click:Connect(function()
					if DeBounce then return end
					if not Open then
						Open = true
						OpenPicker()
					end
				end)

				colorpicker.QuickClose.hitbox.MouseEnter:Connect(function()
					Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 70,0, 3) }):Play()
					Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end)

				colorpicker.QuickClose.hitbox.MouseLeave:Connect(function()
					Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 60,0, 3) }):Play()
					Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(33, 33, 33) }):Play()
				end)

				local function ClosePicker()
					Open = false
					DeBounce = true
					Services.Tween:Create(colorpicker.UICorner, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CornerRadius = UDim.new(1,0) }):Play()
					Services.Tween:Create(colorpicker, TweenInfo.new( 0.55, Enum.EasingStyle.Quint ), { Size = UDim2.new(1, -35,0, 40) }):Play()
					Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.7, Enum.EasingStyle.Quart ), { Position = UDim2.new(1, -30,0, 10)}):Play()
					Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.55, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 20,0, 20) }):Play()
					Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundColor3 = data.Color }):Play()
					Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					colorpicker.interact.Interactable = true
					colorpicker.QuickClose.Interactable = false

					Services.Tween:Create(colorpicker.color.SVPicker.Brightness, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.SVPicker.Saturation, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.SVPicker.Pin, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.SVPicker.Pin.UIStroke, TweenInfo.new( 0.4, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()

					Services.Tween:Create(colorpicker.color.Values.Hue, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Hue.Pin, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Hue.Pin.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()

					Services.Tween:Create(colorpicker.color.Values.Rainbow, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

					if data.Type == "Gradient" then
						Services.Tween:Create(colorpicker.color.Values.Grad, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
						Services.Tween:Create(colorpicker.color.Values.Grad.Pin1, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
						Services.Tween:Create(colorpicker.color.Values.Grad.Pin1.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
						Services.Tween:Create(colorpicker.color.Values.Grad.Pin2, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
						Services.Tween:Create(colorpicker.color.Values.Grad.Pin2.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					end

					local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

					if data.Type == "Gradient" and displayGrad then
						displayGrad.Enabled = true
						displayGrad.Color = ColorSequence.new(Keys)
						Services.Tween:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
					else
						if displayGrad then displayGrad.Enabled = false end
						Services.Tween:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = data.Color }):Play()
					end

					Services.Tween:Create(colorpicker.HueValues.RGB, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.RGB.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.RGB.V.RGBBox, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { TextTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.RGB.Copy, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

					Services.Tween:Create(colorpicker.HueValues.HEX, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.HEX.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.HEX.V.HEXBox, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { TextTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.HEX.Copy, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

					Services.Tween:Create(colorpicker.HueValues.Link, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.Link.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.HueValues.Link.Frame.ImageLabel, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()
					for _,v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
						if v:IsA('Frame') then
							Services.Tween:Create(v, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
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
					if DeBounce then return end
					if Open then
						Open = false
						ClosePicker()
					end
				end)


				for _,v in ipairs(colorpicker.HueValues:GetChildren()) do
					if v:IsA("Frame") then
						for _,v2 in ipairs(v:GetChildren()) do
							if v2:IsA("ImageLabel") then
								v2.MouseEnter:Connect(function()
									Services.Tween:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
								end)
								v2.MouseLeave:Connect(function()
									Services.Tween:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(66, 66, 66) }):Play()
								end)
							end
						end
					end
				end
				Owl:OnClick(colorpicker.HueValues.HEX.Copy, function()
					if Owl:SetClipboard(FormatColor(data.Color, 'Hex')) then Owl:FlashCopy(colorpicker.HueValues.HEX.Copy) end
				end)
				Owl:OnClick(colorpicker.HueValues.RGB.Copy, function()
					if Owl:SetClipboard(FormatColor(data.Color, 'RGB', 2)) then Owl:FlashCopy(colorpicker.HueValues.RGB.Copy) end
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
						Services.Tween:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 20,0, 20) }):Play()
					end)

					recentFrame.interact.MouseLeave:Connect(function()
						Services.Tween:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 12,0, 12) }):Play()
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

				Owl:AddConnection(SVPicker.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						SV = Services.Run.RenderStepped:Connect(function()
							local mouse = game.Players.LocalPlayer:GetMouse()
							local ColorX = math.clamp(mouse.X - SVPicker.AbsolutePosition.X, 0, SVPicker.AbsoluteSize.X) / SVPicker.AbsoluteSize.X
							local ColorY = math.clamp(mouse.Y - SVPicker.AbsolutePosition.Y, 0, SVPicker.AbsoluteSize.Y) / SVPicker.AbsoluteSize.Y

							HSV[2] = ColorX
							HSV[3] = 1 - ColorY

							updatestuff()
						end)
					end
				end)

				Owl:AddConnection(SVPicker.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and SV then
						SV:Disconnect()
						SV = nil
						AddRecentColor(data.Color)
					end
				end)

				Owl:AddConnection(HUESlider.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						HUE = Services.Run.RenderStepped:Connect(function()
							local mouse = game.Players.LocalPlayer:GetMouse()
							local ColorX = math.clamp(mouse.X - HUESlider.AbsolutePosition.X, 0, HUESlider.AbsoluteSize.X) / HUESlider.AbsoluteSize.X

							HSV[1] = 1 - ColorX

							updatestuff()
						end)
					end
				end)

				Owl:AddConnection(HUESlider.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and HUE then
						HUE:Disconnect()
						HUE = nil
						AddRecentColor(data.Color)
					end
				end)

				colorpicker.HueValues.HEX.V.HEXBox.FocusLost:Connect(function(Enter)
					if not Enter then return end

					local hexInput = colorpicker.HueValues.HEX.V.HEXBox.Text

					local success, result = pcall(function()
						return Color3.fromHex(hexInput)
					end)

					if success then
						local Hue, Saturation, Value = result:ToHSV()
						colorpicker.HueValues.HEX.V.HEXBox.Text = ''
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
					if not Enter then return end

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

							colorpicker.HueValues.RGB.V.RGBBox.Text = ''
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
				local originalPosition = UDim2.new(0.5, 0,0, 0)
				local draggedColorPicker = nil

				local function isMouseOver(guiObject)
					local mouse = game.Players.LocalPlayer:GetMouse()
					local pos = guiObject.AbsolutePosition
					local size = guiObject.AbsoluteSize
					return mouse.X >= pos.X and mouse.X <= pos.X + size.X and mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y
				end

				colorpicker.HueValues.Link.Frame.interact.MouseButton1Down:Connect(function()
					linkDragging = true
					draggedColorPicker = colorpicker

					TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {Size = UDim2.new(0, 40,1, 0)}):Play()

					local followMouse
					followMouse = RunService.RenderStepped:Connect(function()
						if not linkDragging then
							followMouse:Disconnect()
							return
						end
						local mouse = game.Players.LocalPlayer:GetMouse()
						TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, mouse.X - colorpicker.AbsolutePosition.X - 50, 0, mouse.Y - colorpicker.AbsolutePosition.Y - 260) }):Play()

						for _, otherPicker in pairs(Page:GetChildren()) do
							if otherPicker:IsA("Frame") and otherPicker:FindFirstChild("isLinkable") and otherPicker.isLinkable.Value then
								if isMouseOver(otherPicker) and otherPicker ~= draggedColorPicker then
									TweenService:Create(otherPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
								else
									TweenService:Create(otherPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								end
							end
						end
					end)
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and linkDragging then
						linkDragging = false
						local foundTarget = false

						for _, otherPicker in pairs(Page:GetChildren()) do
							if otherPicker:IsA("Frame") and otherPicker:FindFirstChild("isLinkable") and otherPicker.isLinkable.Value then
								if isMouseOver(otherPicker) and otherPicker ~= draggedColorPicker then
									otherPicker.HueSat.Value = draggedColorPicker.HueSat.Value
									updatestuff() 
									foundTarget = true
									TweenService:Create(
										colorpicker.HueValues.Link.Frame,
										TweenInfo.new(0.3, Enum.EasingStyle.Quint),
										{ Position = originalPosition }
									):Play()

									TweenService:Create(otherPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
									TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {Size = UDim2.new(1, 0,1, 0)}):Play()
									break
								end
							end
						end

						if not foundTarget then
							TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {Size = UDim2.new(1, 0,1, 0)}):Play()
							TweenService:Create(
								colorpicker.HueValues.Link.Frame,
								TweenInfo.new(0.3, Enum.EasingStyle.Quint),
								{ Position = originalPosition }
							):Play()
						end
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

				local hueIncrement = 0.005 

				local function RainbowEffect()
					HueValue = (HueValue + hueIncrement) % 1
					HSV[1] = HueValue

					updatestuff()
				end

				local isRainbowEnabled = false
				local huerender = nil

				local function ToggleRainbowEffect()
					isRainbowEnabled = not isRainbowEnabled
					if isRainbowEnabled then
						if not huerender then
							huerender = Services.Run.RenderStepped:Connect(RainbowEffect)
							Services.Tween:Create(colorpicker.color.Values.Rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential ), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
						end
					else
						if huerender then
							huerender:Disconnect()
							Services.Tween:Create(colorpicker.color.Values.Rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential ), {ImageColor3 = Color3.fromRGB(62, 62, 62)}):Play()
							huerender = nil
						end
					end
				end

				colorpicker.color.Values.Rainbow.MouseButton1Click:Connect(ToggleRainbowEffect)

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
					Owl.Flags[flagKey] = data
				end
				if data.SFlag then
					Owl.SettingsFlags[data.SFlag] = data
				end

				colorpicker.color.Values.Rainbow.MouseButton1Click:Connect(ToggleRainbowEffect)

				return data

			end


			function telement:Dropdown(Dropdown)
				local data = {
					Title = Dropdown.Title or "Temp Dropdown";
					Options = Dropdown.Options or {};
					StarterOption = Dropdown.StarterOption;
					PlaceHolder = Dropdown.PlaceHolder or "Select Option...";
					Multi = Dropdown.Multi or false;
					CallBack = Dropdown.CallBack;
				}

				local dropdown = window.settings.pages.page.Dropdown:Clone()
				dropdown.Visible = true
				dropdown.Parent = Page
				dropdown.title.Text = data.Title
				dropdown.Name = data.Title
				dropdown.dropholder.drop.Container.Option.Visible = false
				dropdown.dropholder.drop.Container.Visible = false
				Services.Tween:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.33, -20,0.576, -75) }):Play()
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
							Services.Tween:Create(option, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, yOffset)}):Play()
							yOffset = yOffset + option.Size.Y.Offset + 7
						end
					end
				end

				local function OpenDrop()
					DropOpen = true
					dropdown.dropholder.drop.Container.Visible = true
					dropdown.dropholder.drop.search.Visible = true

					Services.Tween:Create(dropdown, TweenInfo.new(1.34, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 300) }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.UICorner, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(0, 20) }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -20, 1, -75) }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.v0, TweenInfo.new(1.34, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Rotation = 180 }):Play()

					Services.Tween:Create(dropdown.dropholder.drop.search, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.65 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.search.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0.4 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.search.TextBox, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.search.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.9 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.search.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.85 }):Play()

				end

				local function CloseDrop()
					DropOpen = false
					Services.Tween:Create(dropdown, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 95) }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(1,0) }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.33, -20, 0.576, -75) }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.v0, TweenInfo.new(1.34, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Rotation = 0 }):Play()

					Services.Tween:Create(dropdown.dropholder.drop.search, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.search.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.search.TextBox, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.search.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
					Services.Tween:Create(dropdown.dropholder.drop.search.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()

					task.wait(0.6)
					dropdown.dropholder.drop.Container.Visible = false
					dropdown.dropholder.drop.search.Visible = false

				end

				dropdown.dropholder.drop.down.MouseButton1Click:Connect(function()
					if DeBounce then return end
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
								optionGroup.X.MouseButton1Click:Connect(function()
									RemoveFromSelected(option)
									UpdateSelectedText()
									for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
										if opt:IsA("Frame") and opt.Name == option then
											Services.Tween:Create(opt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
											Services.Tween:Create(opt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
											Services.Tween:Create(opt.Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
											Services.Tween:Create(opt.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
											Services.Tween:Create(opt.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
										end
									end

									if data.CallBack then
										data.CallBack(SelectedOrder)
									end
								end)

								optionGroup.Parent = selectedContainer
								task.defer(function()
									local padding = 40
									local textWidth = optionGroup.TextLabel.TextBounds.X
									local totalWidth = textWidth + padding

									optionGroup.TextLabel.Size = UDim2.new(0, textWidth, 1, 0)

									Services.Tween:Create(optionGroup, TweenInfo.new(0.67, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, totalWidth, 0, 20)}):Play()
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
							local showldShow = not isTemplate and (searchText == "" or optionText:find(searchText, 1, true) or SelectedOptions[option.Title.Text])

							if showldShow then
								option.Visible = true
								if SelectedOptions[option.Title.Text] then
									Services.Tween:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
									Services.Tween:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
									Services.Tween:Create(option.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
									Services.Tween:Create(option.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
									Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
								else
									Services.Tween:Create(option, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
									Services.Tween:Create(option, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
									Services.Tween:Create(option.Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
									Services.Tween:Create(option.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
									Services.Tween:Create(option.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
								end
							else
								Services.Tween:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
								Services.Tween:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
								Services.Tween:Create(option.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
								Services.Tween:Create(option.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
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

						if OptionText == data.StarterOption and not starterSet then
							starterSet = true
							dropdown.dropholder.drop.Selected.Text = OptionText
							SelectedOptions = {[OptionText] = true}
							SelectedOrder = {OptionText}

							Services.Tween:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
							Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
						end

						option.Interact.MouseButton1Click:Connect(function()
							if data.Multi then
								if SelectedOptions[OptionText] then
									RemoveFromSelected(OptionText)
									Services.Tween:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
									Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0.9}):Play()
								else
									AddToSelected(OptionText)
									Services.Tween:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
									Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
								end

								if data.CallBack then
									data.CallBack(SelectedOrder)
								end
							else
								dropdown.dropholder.drop.selected.Text = OptionText

								SelectedOptions = {[OptionText] = true}
								SelectedOrder = {OptionText}

								for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
									if opt:IsA("Frame") then
										Services.Tween:Create(opt, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
										Services.Tween:Create(opt.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0.9}):Play()
									end
								end

								Services.Tween:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
								Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()


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

					UpdateCustomLayout()
				end

				SetDropdownOptions()

				function data:GetSelected()
					return SelectedOrder[1]
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
					Title = Slider.Title;
					Desc = Slider.Description;
					Sliders = Slider.Sliders
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
						Title = Options.Title or "Slider";
						Increment = Options.Increment or 1;
						Range = Options.Range or {0, 100};
						StarterValue = Options.StarterValue or 16;
						CallBack = Options.CallBack;
						SFlag = Options.SFlag;
						SettingsConfig = true;
					}

					Slider.Name = Options.Title
					Slider.Title.Text = Options.Title
					Options.Value = Options.StarterValue

					local dragging = false
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


					Slider.slide.slideframe:TweenSize(UDim2.new(SliderPosition, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

					Owl:registerLoadTween(
						Slider.slide.slideframe,
						{Size = UDim2.new(SliderPosition, 0, 1, 0)},
						{Size = UDim2.new(0, 100,1, 0)},
						TweenInfo.new(0.85, Enum.EasingStyle.Quint)
					)

					Owl:replayLoadTweens(Slider.slide.slideframe)

					local decimalPlaces = Owl:DecimalPlaces(Options.Increment)
					Slider.v.Text = string.format("<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>", Options.StarterValue, Options.Range[2])

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
						if tickCount < 2 then return end
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
							Services.Tween:Create(
								tick,
								TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									Position = finalPos,
									BackgroundTransparency = 0.85
								}
							):Play()
						end
						for i = tickCount + 1, #existingTicks do
							existingTicks[i]:Destroy()
						end

					end
					if Options.Increment > 4 then
						if not Slider.slide.Ticks:FindFirstChild("_ResizeConnection") then
							local conn = Slider.slide.Ticks:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
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
							local sliderPosition = (x - sliderStart) / sliderWidth
							sliderPosition = math.clamp(sliderPosition, 0, 1)

							local range = Options.Range[2] - Options.Range[1]
							local newValue = Options.Range[1] + sliderPosition * range
							newValue = math.floor((newValue - Options.Range[1]) / Options.Increment + 0.5) * Options.Increment + Options.Range[1]
							newValue = Owl:RoundTo(newValue, Owl:DecimalPlaces(Options.Increment))
							local snapPosition = (newValue - Options.Range[1]) / range
							Slider.slide.slideframe:TweenSize(UDim2.new(snapPosition, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.55, true)
							local decimalPlaces = Owl:DecimalPlaces(Options.Increment)
							Slider.v.Text = string.format("<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>", newValue, Options.Range[2])


							Services.Tween:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

							local success, errorMsg = pcall(function()
								Options.CallBack(newValue)
							end)
							if not success then
								Owl:Report("Slider '" .. Slider.Name .. "' callback", errorMsg)
							end

							Options.StarterValue = newValue
						end
					end

					Slider.slide.Interact.MouseButton1Down:Connect(function()
						dragging = true
					end)

					Slider.slide.Interact.MouseButton1Up:Connect(function()
						dragging = false
					end)

					Owl:AddConnection(Services.UserInput.InputEnded, function(input, processed)
						if input.UserInputType == Enum.UserInputType.MouseButton1  or input.UserInputType == Enum.UserInputType.Touch then
							dragging = false
							Services.Tween:Create(Slider.Title, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { TextTransparency = 0.6 }):Play()
						end
					end)

					Owl:AddConnection(Services.UserInput.InputChanged, function(input)
						if dragging and input.UserInputType == Enum.UserInputType.MouseMovement  or input.UserInputType == Enum.UserInputType.Touch  then
							UpdateSlider(input.Position.X)
						end
					end)

					Slider.slide.slideframe.BackgroundColor3 = Owl.theme.HitBox
					Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = Owl.theme.HitBox
					Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = Owl.theme.HitBox
					Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = Owl.theme.HitBox
					slider.slideholder.Size = UDim2.new(1,-30,0,slider.slideholder.UIListLayout.AbsoluteContentSize.Y)
					local ss = slider.slideholder.UIListLayout.AbsoluteContentSize.Y
					slider.Size = UDim2.new(1,-35,0, ss  + 20)

					Owl:AddConnection(Owl.Comms.Event, function(p, color)
						if p == 'HitBox' then
							Slider.slide.slideframe.BackgroundColor3 = color
							Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = color
							Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = color
							Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = color
						end
					end)

					function Options:Set(NewVal, skipSave)
						local range = Options.Range[2] - Options.Range[1]
						NewVal = math.floor((NewVal - Options.Range[1]) / Options.Increment + 0.5) * Options.Increment + Options.Range[1]
						NewVal = Owl:RoundTo(NewVal, Owl:DecimalPlaces(Options.Increment))

						local sliderPosition = (NewVal - Options.Range[1]) / range

						Slider.slide.slideframe:TweenSize(
							UDim2.new(sliderPosition, 0, 1, 0),
							Enum.EasingDirection.Out,
							Enum.EasingStyle.Quint,
							0.55,
							true
						)
						Owl:registerLoadTween(
							Slider.slide.slideframe,
							{Size = UDim2.new(sliderPosition, 0, 1, 0)},
							{Size = UDim2.new(0, 100, 1, 0)},
							TweenInfo.new(0.85, Enum.EasingStyle.Quint)
						)
						local decimalPlaces = Owl:DecimalPlaces(Options.Increment)
						Slider.v.Text = string.format(
							"<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>",
							NewVal,
							Options.Range[2]
						)
						Services.Tween:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {
							TextTransparency = 0
						}):Play()
						local success, result = pcall(function()
							Options.CallBack(NewVal)
						end)

						if not success then
							Owl:Report("Slider '" .. Slider.Name .. "' callback", result)
						end

						Options.StarterValue = NewVal
					end
					Owl:AttachSliderInput(Slider, Options)

					if Options.SFlag then
						if Options.SFlag then
							Owl.SettingsFlags[Options.SFlag] = Options
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
							local textSize = Services.Text:GetTextSize(
								descLabel.Text,
								descLabel.TextSize,
								descLabel.Font,
								Vector2.new(descLabel.AbsoluteSize.X, math.huge)
							)

							local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
							local newButtonSize = UDim2.new(slider.Size.X.Scale, slider.Size.X.Offset, 0,slider.slideholder.AbsoluteSize.Y + slider.title.Size.Y.Offset + textSize.Y + 15) -- Adding extra padding

							local descTween = Services.Tween:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
							descTween:Play()

							local ToggleTween = Services.Tween:Create(slider, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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
					Title = Paragraph.Title;
					Content = Paragraph.Content;
				}

				local Para = window.settings.pages.page.Paragraph:Clone()
				Para.Visible = true
				Para.Parent = Page
				Para.Frame.title.Text = ParaData.Title
				Para.Content.Text = ParaData.Content

				Para.Content.Size = UDim2.new(1, -20, 0, Para.Content.TextBounds.Y)

				local function updateSize()
					local textSize = Services.Text:GetTextSize(
						Para.Content.Text,
						Para.Content.TextSize,
						Para.Content.Font,
						Vector2.new(Para.Content.AbsoluteSize.X, math.huge) -- Allows vertical expansion
					)

					local newDescSize = UDim2.new(1, -20, 0, textSize.Y)
					local newButtonSize = UDim2.new(Para.Size.X.Scale, Para.Size.X.Offset, 0, textSize.Y + 120) -- Adding extra padding

					local descTween = Services.Tween:Create(Para.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
					descTween:Play()

					local buttonTween = Services.Tween:Create(Para, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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

				local textinput =  window.settings.pages.page.Input:Clone()
				textinput.Visible = true
				textinput.Parent = Page
				textinput.Name = data.Title
				textinput.title.Text = data.Title
				textinput.TextFrame.TextBox.PlaceholderText = data.PlaceHolder

				local textBox = textinput.TextFrame.TextBox
				local defaultHeight = 32
				local ignoreNextClear = false



				textinput.TextFrame.Enter.MouseEnter:Connect(function()
					Services.Tween:Create(textinput.TextFrame.Enter, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end)

				textinput.TextFrame.Enter.MouseLeave:Connect(function()
					Services.Tween:Create(textinput.TextFrame.Enter, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextColor3 = Color3.fromRGB(40, 40, 40)}):Play()
				end)

				textBox:GetPropertyChangedSignal("Text"):Connect(function()
					if data.NumbersOnly then
						textBox.Text = textBox.Text:gsub("%D", "")
					end

					textBox.Size = UDim2.new(1, -60, 0, defaultHeight + 40)

					local textSize = game:GetService("TextService"):GetTextSize(
						textBox.Text, textBox.TextSize, textBox.Font, Vector2.new(textBox.AbsoluteSize.X, math.huge)
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




					Services.Tween:Create(
						textinput,
						TweenInfo.new(0.7, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(1, -35, 0, newHeight + extraHeight + 35) }
					):Play()


				end)

				textBox:GetPropertyChangedSignal("Size"):Connect(function()
					local newHeight = textBox.Size.Y.Offset
					local totalHeight = math.max(newHeight, defaultHeight)

					Services.Tween:Create(
						textinput.TextFrame,
						TweenInfo.new(0.7, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(1, -60, 0, totalHeight + 0) }
					):Play()


				end)

				local function ProcessInput(text)
					local success, errorMsg = pcall(function()
						data.CallBack(text)
					end)
					if not success then
						Owl:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
					end
				end

				textBox.FocusLost:Connect(function(enterPressed)
					if not enterPressed then return end

					local success, errorMsg = pcall(function()
						data.CallBack(textBox.Text)
					end)
					if not success then
						Owl:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
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
						Owl:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
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
					telement[_bn] = Owl:Guard("Building a '" .. tostring(_bn) .. "' element", _bf)
				end
			end

			return telement

		end

		local a = settings:inittab({Title = 'Theme'})
		local b = settings:inittab({Title = 'Privacy'})
		local c = settings:inittab({Title = 'Info'})
		tbdata._settingsTab = a

		a:Keybind({
			Title = 'Toggle UI',
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

		a:ColorPicker({
			Title = 'Accent',
			RD = false,
			Linkable = true,
			Color = Owl.theme.Accent;
			Flag = "Accent",
			SFlag = 'AC',
			Save = true,
			CallBack = function(v)
				Owl:UpdateTheme({
					['Accent'] = v
				})
				Owl:SaveThemeCfg()
				SaveCfg(game and game.GameId)
			end,
		})

		a:ColorPicker({
			Title = 'Hitbox',
			RD = false,
			Linkable = true,
			Color = Owl.theme.HitBox;
			Flag = "HitBox",
			SFlag = 'HB',
			Save = true,
			CallBack = function(c)
				Owl:UpdateTheme({
					['HitBox'] = c
				})
				Owl:SaveThemeCfg()
				SaveCfg(game and game.GameId)
			end,
		})

		local seq = Owl.theme.DropShadow
		local k = seq.Keypoints

	

		local rotateGradient = false
		local rotating = false

		local function startGradientRotation()
			if rotating then return end
			rotating = true

			task.spawn(function()
				local grad = window.shadow.ImageLabel.UIGradient
				local rotation = 0
				while rotateGradient and grad and grad.Enabled do
					rotation = (rotation + 1) % 360
					grad.Rotation = rotation
					task.wait() -- adjust speed if you want
				end
				rotating = false
			end)
		end

		a:Toggle({
			Title = 'Rotate Gradient',
			Description = 'Slowly rotates the gradient if enabled.',
			Value = Owl.LoadedConfig and Owl.LoadedConfig["RotateGradient"] or false,
			Flag = "RotateGradient",
			SFlag = 'RG',
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

		a:Toggle({
			Title = 'Glow',
			Description = 'Shine on the ui.',
			Value = Owl.LoadedConfig and Owl.LoadedConfig["Glow"] or false,
			Flag = "Glow",
			SFlag = 'GLOW',
			Save = true,
			CallBack = function (v)
				if v then
					glow = true
					for i, glow in pairs(window.clipframe:GetChildren()) do
						if glow:IsA("ImageLabel") then
							Services.Tween:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 0.8}):Play()
						end
					end
					window.pages.v0.Visible = false

					window.pages.clipframe.v1.Visible = false
					window.pages.clipframe.v1.Visible = false
					window.shadow.glow.Visible = true
					window.shadow.glow1.Visible = true

				else
					glow = false
					for i, glow in pairs(window.clipframe:GetChildren()) do
						if glow:IsA("ImageLabel") then
							Services.Tween:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 1}):Play()
						end
					end
					window.shadow.glow.Visible = false
					window.shadow.glow1.Visible = false

					if isBlurEnabled then
						window.pages.v0.Visible = false
					else
						window.pages.v0.Visible = true
						window.pages.clipframe.v1.Visible = true
						window.pages.clipframe.v1.Visible = true
					end
				end
			end,
			SFlag = 'GLW',
		})

		a:Toggle({
			Title = 'Blur',
			Description = 'Make sure your graphics are above 8.',
			CallBack = function (v)
				if v then
					window.shadow.ImageLabel.Visible = false
					window.BackgroundTransparency = 0.45

					window.pages.v1.Visible = false
					window.pages.v0.Visible = false

					window.pages.clipframe.v1.Visible = false
					window.pages.clipframe.v0.Visible = false

					Owl:BindFrame(window, {
						Transparency = 0.98;
						BrickColor = BrickColor.new('Institutional white');
					})

					local dof = Instance.new('DepthOfFieldEffect')
					dof.Parent = game.Lighting
					dof.Enabled = true
					dof.FocusDistance = 51.6
					dof.InFocusRadius = 50
					dof.NearIntensity = 1
					dof.FarIntensity = 0

					isBlurEnabled = true

				else
					window.shadow.ImageLabel.Visible = true
					window.BackgroundTransparency = 0

					window.pages.v1.Visible = true
					window.pages.v0.Visible = true

					window.pages.clipframe.v1.Visible = true
					window.pages.clipframe.v0.Visible = true

					Owl:UnbindFrame(window)

					isBlurEnabled = false
				end
			end,
			SFlag = 'BLUR',
		})


		a:Slider({
			Title = 'Modifiers',
			Sliders = {
				{
					Title = 'DS Density',
					Range = {0, 1},
					Increment = 0.1,
					StarterValue = window.shadow.ImageLabel.ImageTransparency,
					CallBack = function(v)
						Services.Tween:Create(window.shadow.ImageLabel, TweenInfo.new(0.65, Enum.EasingStyle.Exponential), {ImageTransparency = v}):Play()
					end,
					SFlag = 'GDensity',
					SettingConfig = true
				},
				{
					Title = 'Drag Smoothness',
					Range = {0, 1},
					Increment = 0.1,
					StarterValue = dragSpeed,
					CallBack = function(v)
						dragSpeed = v
					end,
					SFlag = 'DSmoothness',
					SettingConfig = true
				},
			}
		})

		a:Toggle({
			Title = 'Wallpaper';
			Description = 'Displays personalized wallpaper';
			Value = window.wallpaper.ison.Value,
			CallBack = function (v)
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

					if isBlurEnabled then
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
			SFlag = 'WALLP',
		})

		a:TextInput({
			Title = 'Wallpaper ID';
			NumberOnly = true;
			PlaceHolder = 'Input your wallpaper ID here.';
			CallBack = function (v)
				if v then
					window.wallpaper.Image = 'rbxassetid://'..v
					Owl:Toast({
						Content = 'Wallpaper applied.'
					})
				end
			end
		})


		a:Toggle({
			Title = 'LockToScreen',
			Description = 'Prevents UI from moving off screen.',
			Value = LockToScreen,
			CallBack = function (v)
				LockToScreen = v
			end,
			SFlag = 'LS'
		})

		a:Toggle({
			Title = 'Watermark',
			Description = 'Toggles the draggable watermark display.',
			Value = Owl.WatermarkEnabled,
			CallBack = function (v)
				Owl:SetWatermarkEnabled(v)
			end,
			SFlag = 'WTRMK'
		})

		a:Toggle({
			Title = 'Performance Overlay',
			Description = 'Shows FPS and Data Ping in the top bar.',
			Value = Owl.LoadedConfig and Owl.LoadedConfig["owl_performance_overlay"] or false,
			Flag = "owl_performance_overlay",
			Save = true,
			CallBack = function(enabled)
				Owl:SetPerformanceOverlay(enabled)
				SaveCfg(game and game.GameId)
			end,
			SFlag = 'PERF'
		})
		local HttpService = game:GetService("HttpService")
		local isDev = false
		local baseUrl = isDev and "http://localhost:3000" or "https://Owl-auth.vercel.app"
		local loginUrl = baseUrl .. "/api/login"
		local VERIFY_ENDPOINT = baseUrl .. "/api/verify?id="
		local currentDiscordId = nil
		local lastCheck = 0
		local debounceTime = 1.5 -- seconds
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
				Owl:Notify({
					Title = "Link Copied",
					Content = "OAuth link copied to clipboard. Paste in your browser.",
					Duration = 5
				})
			end
		end
		b:Button({
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
		b:TextInput({
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
						Owl:Notify({
							Title = "Success",
							Content = "Discord verified successfully",
							Duration = 4
						})
					else
						window.user.headshot.Status.BackgroundColor3 = Color3.fromRGB(255, 101, 104)
						Owl:Notify({
							Title = "Verification Failed",
							Content = "Discord ID is not verified",
							Duration = 4
						})
					end
				end)
			end,
		})


		function Owl:SaveSettingsConfig()
			SaveCfg(game and game.GameId)
			Owl:SaveThemeCfg()
			Owl:Toast({
				Content = 'Saved settings config';
				Duration = 3
			})
		end

		function Owl:LoadSettingsConfig()
			LoadThemeCfg(FILE_PATH)
			local folder = Owl.Folder or Owl.ConfigFolder or "OwlHub"
			local filePath = folder .. "/" .. tostring(game and game.GameId or "0") .. ".txt"
			if isfile and isfile(filePath) then
				LoadCfg(readfile(filePath))
			end
			Owl:Toast({
				Content = 'Loaded settings config';
				Duration = 3
			})
		end
		local currentConfigName = Owl.ConfigFile or "Config"
		local selectedConfig
		local autoloadEnabled = Owl:GetAutoLoad() and true or false
		local autoloadButtonRef
		local configDropdownData

		local function refreshConfigList()
			if configDropdownData and configDropdownData.SetOptions then
				configDropdownData:SetOptions(Owl:ListConfigs() or {})
			end
		end

		local function updateAutoLoadLabel()
			if autoloadButtonRef and autoloadButtonRef:FindFirstChild('title') then
				autoloadButtonRef.title.Text = autoloadEnabled and 'AutoLoad: ON' or 'AutoLoad: OFF'
				autoloadButtonRef.title.Size = UDim2.new(0, 120, 0, 35)
			end
		end

		local function resolveConfigName()
			if selectedConfig and selectedConfig ~= "" then return selectedConfig end
			if currentConfigName and currentConfigName ~= "" then return currentConfigName end
			return Owl.ConfigFile
		end

		a:Paragraph({
			Title = 'Auto-Save System',
			Content = 'All toggles, sliders, dropdowns, binds and positions are saved automatically.'
		})

		b:Toggle({
			Title = 'Anonymous',
			Description = 'Hides your info in User Info.',
			Value = Owl.LoadedConfig and Owl.LoadedConfig["ANON"] or false,
			Flag = 'ANON',
			SFlag = 'ANON',
			Save = true,
			CallBack = function (v)
				if v then
					window.user.headshot.id.username.Text = '?'
					window.user.headshot.id.displayname.Text = '@?'
					window.user.headshot.Image = 'rbxassetid://139956761561818'
				else
					SetUserInfo()
				end
				SaveCfg(game and game.GameId)
			end,
		})

		c:Paragraph({
			Title = 'Status',
			Content = 'Your Up To Date!'
		})


		local startTime = tick()

		local uptimeParagraph = c:Paragraph({
			Title = 'Session UpTime',
			Content = 'Calculating...'
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

		ss = Owl:AddConnection(Services.Run.Heartbeat, function()
			local uptime = tick() - startTime
			local formatted = formatTime(uptime)
			uptimeParagraph:Set("Session Uptime: " .. formatted, 'Session UpTime')
		end)

	end
	local tbdata = {
		first = false,
		selected = false
	}

	function tbdata:Modal(ModalConfig)
		return Owl:Modal(ModalConfig)
	end

	function tbdata:Dialog(ModalConfig)
		return Owl:Modal(ModalConfig)
	end

	function tbdata:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		local tabTitle = TabConfig.Name or TabConfig.Title or "Tab"
		local tabObj = self:InitTab({
			Title = tabTitle,
			Locked = TabConfig.Locked,
			Key = TabConfig.Key
		})
		return tabObj
	end

	function tbdata:CreateSettingsTab(Options)
		return self._settingsTab
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
			local titleText = "Owl"
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
				top.title.Text = titleText
				if titleColor then
					top.title.TextColor3 = titleColor
				end
				local textSize = top.title.TextBounds.X + 3
				Services.Tween:Create(top.title, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
					Size = UDim2.new(0, textSize, 0, 20)
				}):Play()
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
			Title = tab.Title;
			Locked = tab.Locked or false;
			Key = tab.Key;
		}

		local LockedFrames = {}
		local Tab = tabs.btn:Clone()
		Tab.Visible = true
		Tab.Parent = tabs
		Tab.title.Text = tdata.Title
		Tab.Name = tdata.Title

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
				Owl:updateLayout(Page, 7) 
			end)
			child:GetPropertyChangedSignal("Visible"):Connect(function()
				Owl:updateLayout(Page, 7)
			end)
			Owl:updateLayout(Page, 7)
		end)

		Page.ChildRemoved:Connect(function()
			Owl:updateLayout(Page, 7)
		end)

		Page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Owl:updateLayout(Page, 7)
		end)

		Owl:updateLayout(Page, 7)



		local function ChangeName(Name)
			local fadeOut = Services.Tween:Create(pages.clipframe.title, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1, Position = UDim2.new(0, 5, 0.5, -12) })
			fadeOut:Play()
			task.delay(0.1, function()
				pages.clipframe.title.Text = Name
				pages.clipframe.title.Position = UDim2.new(0, 5, 0.5, 12)
				Services.Tween:Create(pages.clipframe.title, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0, Position = UDim2.new(0, 5, 0.5, 0) }):Play()
			end)
		end

		if isFirstTab then
			ChangeName(tdata.Title)
			Page.Visible = true
			tbdata.first = tdata.Title
		end

		local tabInitTween = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		if tbdata.first then
			Services.Tween:Create(Tab.title, tabInitTween, { TextTransparency = 0.52 }):Play()
			Services.Tween:Create(Tab, tabInitTween, { BackgroundTransparency = 0.45 }):Play()
			Services.Tween:Create(Tab.indicator, tabInitTween, { BackgroundTransparency = 1 }):Play()
			Services.Tween:Create(Tab.indicator.glow, tabInitTween, { ImageTransparency = 1 }):Play()
			Services.Tween:Create(Tab, tabInitTween, { Size = UDim2.new(0, Tab.title.TextBounds.X + 30, 0, 35) }):Play()
		else
			tbdata.first = tdata.Title
			Services.Tween:Create(Tab.title, tabInitTween, { TextTransparency = 0 }):Play()
			Services.Tween:Create(Tab, tabInitTween, { BackgroundTransparency = 0 }):Play()
			Services.Tween:Create(Tab.indicator, tabInitTween, { BackgroundTransparency = 0 }):Play()
			Services.Tween:Create(Tab.indicator, tabInitTween, { BackgroundColor3 = Owl.theme.Accent }):Play()
			Services.Tween:Create(Tab.indicator.glow, tabInitTween, { ImageColor3 = Owl.theme.Accent }):Play()
			Services.Tween:Create(Tab, tabInitTween, { Size = UDim2.new(0, Tab.title.TextBounds.X + 80, 0, 35) }):Play()
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
				Services.Tween:Create(HomeButton.homeicon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.45 }):Play()
				Services.Tween:Create(HomeButton.homeicon.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()
			else
				Services.Tween:Create(HomeButton.homeicon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.85 }):Play()
				Services.Tween:Create(HomeButton.homeicon.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.67 }):Play()
			end
		end

		local isInit = true

		local function ApplyTabStyle(tabButton, isSelected)
			local targetTextTransparency = isSelected and 0 or 0.6
			local targetBackgroundTransparency = isSelected and 0 or 0.45
			local targetTransparency = isSelected and 0 or 1
			local targetColor = isSelected and Owl.theme.Accent or Color3.fromRGB(29, 29, 29)
			local targetSize = isSelected and UDim2.new(0, tabButton.title.TextBounds.X + 80,0, 35) or UDim2.new(0, tabButton.title.TextBounds.X + 50,0, 35)


			if isInit then
				task.spawn(function()
					for _, v in ipairs(tabs:GetChildren()) do
						if v:IsA("Frame") then
							Services.Tween:Create(v, TweenInfo.new(0.75, Enum.EasingStyle.Quart), { Size = UDim2.new(0, v.title.TextBounds.X + 100,0, 30) }):Play()
							task.wait(0.15)
							Services.Tween:Create(tabButton, TweenInfo.new(0.75, Enum.EasingStyle.Quart), { Size = targetSize }):Play()
							isInit = false
						end
					end
				end)

			end


			Services.Tween:Create(tabButton, positionTweenInfo, { Size = targetSize }):Play()
			Services.Tween:Create(tabButton, colorTweenInfo, { BackgroundTransparency = targetBackgroundTransparency, }):Play()
			Services.Tween:Create(tabButton.title, colorTweenInfo, { TextTransparency = targetTextTransparency }):Play()
			Services.Tween:Create(tabButton.indicator.glow, colorTweenInfo, { ImageColor3 = targetColor }):Play()
			Services.Tween:Create(tabButton.indicator.glow, colorTweenInfo, { ImageTransparency = isSelected and 0.78 or 1 }):Play()

			Services.Tween:Create(tabButton.indicator, colorTweenInfo, { BackgroundColor3 = targetColor }):Play()
			Services.Tween:Create(tabButton.indicator, colorTweenInfo, { BackgroundTransparency = isSelected and 0 or 1 }):Play()


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
				pcall(function() Services.Tween:Create(HomePage, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 }):Play() end)
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

		if tbdata.first == 'Home' then
			ShowHome()
		end
		if HomeButton and HomeButton.homeicon:FindFirstChild("interact") and not tbdata.__homeHooked then
			tbdata.__homeHooked = true
			HomeButton.homeicon.interact.MouseButton1Click:Connect(function()
				if tbdata.homeActive then return end 
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
			if tbdata.first == tdata.Title then return end 
			if Data.Home.Enabled then
				if tbdata.homeActive then
					HideHomeForTab()
				end
			end


			local previous = tbdata.first
			tbdata.first = tdata.Title
			local prevPage = pages:FindFirstChild(previous)
			local newPage  = pages:FindFirstChild(tdata.Title)

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

		

			Owl:replayLoadTweens()

			for _, otherTab in ipairs(tabs:GetChildren()) do
				if otherTab:IsA("Frame") then
					ApplyTabStyle(otherTab, otherTab == Tab)
					otherTab.interact.Active = true
				end
			end

		end)

		Owl:AddConnection(Owl.Comms.Event, function(p, color)
			if p == 'Accent' then
				if tbdata.first ~= tdata.Title then return end
				Services.Tween:Create(Tab.indicator, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					BackgroundColor3 = color
				}):Play()

				Services.Tween:Create(Tab.indicator.glow, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					ImageColor3 = color
				}):Play()
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
				warn("[Owl] SwitchToTab failed:", tabName)
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
			Owl:replayLoadTweens()

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
			local key = func:GetFullName() -- unique string key
			if activeResults[key] then return end
			activeResults[key] = true

			local result = Template:Clone()
			result.Visible = true
			result.Parent = Results

			result.info.title.Text = func.Name
			result.info.badge["function"].Text = getFunctionType(func)
			result.info.badge.Size = UDim2.new(0, result.info.badge["function"].TextBounds.X + 20,0, 20)
			result.interact.MouseButton1Click:Connect(function()

				closesearch()

				local openedPage = ui.main.pages:FindFirstChild(page.Name)
				if not openedPage or not openedPage:IsA("ScrollingFrame") then return end
				SwitchToTab(page.Name)

				task.wait(0.05) -- small delay to allow UI to update
				local y = func.AbsolutePosition.Y - openedPage.AbsolutePosition.Y + openedPage.CanvasPosition.Y
				Services.Tween:Create(
					openedPage,
					TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{ CanvasPosition = Vector2.new(0, math.max(0, y - 20)) }
				):Play()
				local original = func.BackgroundColor3
				Services.Tween:Create(func, TweenInfo.new(0.2), {
					BackgroundColor3 = Owl:GetLighter(original, 0.03)
				}):Play()

				task.delay(0.35, function()
					Services.Tween:Create(func, TweenInfo.new(0.35), {
						BackgroundColor3 = original
					}):Play()
				end)
			end)

			result.MouseEnter:Connect(function()
				Services.Tween:Create(result.ImageLabel, TweenInfo.new(0.2), {
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
			end)

			result.MouseLeave:Connect(function()
				Services.Tween:Create(result.ImageLabel, TweenInfo.new(0.2), {
					ImageColor3 = Color3.fromRGB(130, 130, 130)
				}):Play()
			end)
			Services.Tween:Create(result.info.badge, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			Services.Tween:Create(result.info.title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			Services.Tween:Create(result.info.badge["function"], TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
		end

		local function searchFunctions(query)
			searchDebounce += 1
			local thisSearch = searchDebounce

			task.delay(0.05, function()
				if thisSearch ~= searchDebounce then return end

				clearResults()
				query = query:lower()
				if query == "" then return end


				for _, page in ipairs(Pages:GetChildren()) do
					if page:IsA("ScrollingFrame") then
						for _, child in ipairs(page:GetChildren()) do
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
			Services.Tween:Create(window.search, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {Size =  UDim2.new(0, 350,0, 230)}):Play()
			Services.Tween:Create(window.search.UICorner, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {CornerRadius =  UDim.new(0,25)}):Play()
			if SearchBox.Text == '' then
				Services.Tween:Create(window.search, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {Size =  UDim2.new(0, 350,0,60)}):Play()
				Services.Tween:Create(window.search.UICorner, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {CornerRadius =  UDim.new(1,0)}):Play()
			end
		end)




		Owl:AddConnection(Owl.Comms.Event, function(p, value)
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
				Title = Button.Title or "Temp Button";
				CallBack = Button.CallBack;
				Desc = Button.Description or "";
				Type = Button.Type or 'Default';
				HoldTime = Button.HoldTime or 3;
			}

			local button = pages.page.Button:Clone()
			button.Visible = true
			button.Parent = Page
			button.title.Text = data.Title
			button.Name = data.Title
			button.title.Size = UDim2.new(0, button.title.TextBounds.X + 15,0, 35)
			button:SetAttribute("Searchable", true)

			local c

			c = data.CallBack


			local fOTween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)
			local fITween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)

			if data.Type == 'Default' then

				button.interact.MouseButton1Down:Connect(function()
					Services.Tween:Create(button.UIStroke, fOTween, { Transparency = 1 }):Play()
					Services.Tween:Create(button.ImageLabel, fOTween, { ImageTransparency = 1 }):Play()
					Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
				end)

				button.interact.MouseButton1Up:Connect(function()
					Services.Tween:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
					Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()


				end)

				button.interact.MouseButton1Click:Connect(function()
					if data.CallBack then
						local success, errorMsg = pcall(c)
						if not success then
							Owl:Report("Button '" .. button.Name .. "' callback", errorMsg)

						end
					else
						warn(`[ CallBack Missing: { button.Name } ] No Function Assigned`)
					end
				end)
				button.interact.MouseLeave:Connect(function()
					Services.Tween:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
					Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()
				end)
			elseif data.Type == 'Hold' then
				local HoldTime = data.HoldTime
				local Holding = false
				local TimeLeft = HoldTime
				local Complete = false

				button.ImageLabel.Image = 'rbxassetid://127075195365098'
				button.ImageLabel.Rotation = 0
				button.ImageLabel.Size = UDim2.new(0, 16,0, 16)
				button.ImageLabel.Position = UDim2.new(1, -41,0.5, 0)

				local function CancelOperation()
					Holding = false
					Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()
					Services.Tween:Create(button.title.timer, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
					if not Complete then
						Services.Tween:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
						Services.Tween:Create(button.UIStroke.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()
						Services.Tween:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,-15 ,0 ,button.Position.Y.Offset) }):Play()
						task.wait(0.15)
						Services.Tween:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,30 ,0 ,button.Position.Y.Offset) }):Play()
						task.wait(0.15)
						Services.Tween:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,0 ,0 ,button.Position.Y.Offset) }):Play()
						task.wait(1)
						Services.Tween:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0 }):Play()
					end

					TimeLeft = HoldTime
					button.title.timer.Text = tostring(HoldTime)
					task.wait(0.1)
					Complete = false
				end

				button.interact.MouseButton1Down:Connect(function()

					Holding = true
					TimeLeft = HoldTime
					button.title.timer.Text = tostring(TimeLeft)
					Services.Tween:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
					Services.Tween:Create(button.title.timer, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
					Services.Tween:Create(button.UIStroke.UIGradient, TweenInfo.new(HoldTime, Enum.EasingStyle.Linear), { Offset = Vector2.new(0.7, 0) }):Play()
					Services.Tween:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0}):Play()
					while Holding and TimeLeft > 0 do
						TimeLeft = math.max(0, TimeLeft - Services.Run.Heartbeat:Wait())
						button.title.timer.Text = string.format("%.1f", TimeLeft) 

					end

					if TimeLeft <= 0 then
						Complete = true

						if data.CallBack then
							local success, errorMsg = pcall(data.CallBack)
							if not success then
								Owl:Report("Element callback", errorMsg)
							end
						else
							warn("[CALLBACK MISSING]: No Function Assigned To", data.Title)
						end

						Services.Tween:Create(button, TweenInfo.new(0.34, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }):Play()
						Services.Tween:Create(button.UIStroke.UIGradient, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()
						task.wait(0.34)
						Services.Tween:Create(button, TweenInfo.new(0.34, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }):Play()
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
						local textSize = Services.Text:GetTextSize(
							descLabel.Text,
							descLabel.TextSize,
							descLabel.Font,
							Vector2.new(descLabel.AbsoluteSize.X, math.huge)
						)

						local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
						local newButtonSize = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, 0, button.title.Size.Y.Offset + textSize.Y + 10)

						local descTween = Services.Tween:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
						descTween:Play()

						local buttonTween = Services.Tween:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
						buttonTween:Play()
					end

					updateSize()

					descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
				else
					descLabel.Visible = false
				end
			end

			data._frame = button
			data.toggle = function(self) if self._frame and self._frame.Parent then self._frame.Visible = not self._frame.Visible end end
			data.remove = function(self) if self._frame and self._frame.Parent then self._frame:Destroy() end end
			return data

		end
		function initelement:Toggle(Toggle)
			local data = {
				Title = Toggle.Title or Toggle.Name or "Temp Toggle";
				Desc = Toggle.Description or Toggle.Desc or "";
				V = Toggle.Value ~= nil and Toggle.Value or (Toggle.Default ~= nil and Toggle.Default or false);
				Config = Toggle.Config or false;
				CallBack = Toggle.Callback or Toggle.CallBack;
				Flag = Toggle.Flag;
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

			toggleConfiguration.Container.KeyBind.Bind.v.Text = 'None'
			Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,0, 25) }):Play()

			toggleConfiguration.BackgroundTransparency = 1
			toggleConfiguration.Container.KeyBind.Title.TextTransparency = 1
			toggleConfiguration.Container.KeyBind.Bind.BackgroundTransparency = 1
			toggleConfiguration.Container.KeyBind.Bind.v.TextTransparency = 1
			toggleConfiguration.Container.Clear.Title.TextTransparency = 1
			toggleConfiguration.Container.Clear.clear.ImageLabel.ImageTransparency = 1
			toggleConfiguration.Size = UDim2.new(0, 75,0, 53)

			if not data.Config then
				toggle.configure:Destroy()
			end

			local toggleTween = TweenInfo.new(0.7, Enum.EasingStyle.Exponential)
			local fadeTween = TweenInfo.new(0.57, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

			local function UpdateToggleUI(state)
				local targetColor = state and Owl.theme.HitBox or Color3.fromRGB(28, 28, 28)
				local strokeTransparency = state and 1 or 0
				local checkTransparency = state and 0 or 1
				local gradientTransparency = state and 0 or 1
				local glowTransparency = state and 0.7 or 1
				local textTransparency = state and 0 or 0.5

				Services.Tween:Create(toggle.tog, toggleTween, { BackgroundColor3 = targetColor }):Play()
				Services.Tween:Create(toggle.tog.check, toggleTween, { ImageTransparency = checkTransparency }):Play()
				Services.Tween:Create(toggle.tog.gradfr, fadeTween, { BackgroundTransparency = gradientTransparency }):Play()
				Services.Tween:Create(toggle.tog.glow, toggleTween, { ImageTransparency = glowTransparency }):Play()
				Services.Tween:Create(toggle.tog.glow, toggleTween, { ImageColor3 = targetColor }):Play()
				Services.Tween:Create(toggle.title, toggleTween, { TextTransparency = textTransparency }):Play()
			end

			UpdateToggleUI(data.V)

			toggle.interact.MouseButton1Click:Connect(function()
				data.V = not data.V
				UpdateToggleUI(data.V)

				local success, errorMsg = pcall(function()
					if data.CallBack then
						data.CallBack(data.V)
					end
				end)

				if not success then
					Owl:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
				end
			end)
			local descLabel = toggle:FindFirstChild("desc")

			if descLabel then
				if data.Desc and data.Desc ~= "" then
					descLabel.Text = data.Desc
					descLabel.Visible = true
					descLabel.TextWrapped = true

					local function updateSize()
						local textSize = Services.Text:GetTextSize(
							descLabel.Text,
							descLabel.TextSize,
							descLabel.Font,
							Vector2.new(descLabel.AbsoluteSize.X, math.huge)
						)

						local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
						local newButtonSize = UDim2.new(toggle.Size.X.Scale, toggle.Size.X.Offset, 0, toggle.title.Size.Y.Offset + textSize.Y + 10) -- Adding extra padding

						local descTween = Services.Tween:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
						descTween:Play()

						local ToggleTween = Services.Tween:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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
					Services.Tween:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end)

				toggle.configure.MouseLeave:Connect(function()
					Services.Tween:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(104, 104, 104) }):Play()
				end)

				local function ToggleConfigOpen()
					toggleConfiguration.Visible = true
					State = true

					Services.Tween:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 0 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 0 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 0 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, enterTween, { ImageTransparency = 0 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 0 }):Play()
					Services.Tween:Create(toggleConfiguration, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 174,0, 88) }):Play()

				end

				local function ToggleConfigClose()
					State = false

					Services.Tween:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 1 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 1 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 1 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, enterTween, { ImageTransparency = 1 }):Play()
					Services.Tween:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 1 }):Play()
					Services.Tween:Create(toggleConfiguration, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 75,0, 53) }):Play()
					task.wait(0.5)

					toggleConfiguration.Visible = false

				end

				local TogService
				local heldKeys = {} 
				local debounce1 = false

				local function ToggleConfig()
					if debounce1 then return end
					debounce1 = true

					if not toggleConfiguration.Visible then
						TogService = Services.Run.RenderStepped:Connect(function()
							toggleConfiguration:TweenPosition(UDim2.new(0,toggle.configure.AbsolutePosition.X - 190,0,toggle.configure.AbsolutePosition.Y + toggle.configure.AbsoluteSize.Y + 65), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
							if not toggleConfiguration.Visible then
								TogService:Disconnect()
							end
						end)
						ToggleConfigOpen()
					else
						if TogService then TogService:Disconnect() end
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
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,0, 25) }):Play()
				end

				local function setKeybind(key)
					if not key then
						toggleConfiguration.Container.KeyBind.Bind.v.Text = 'None'
						ResizeBindFrame()
						data.Keybind = nil
					else
						data.Keybind = key
						data.KeybindReady = false

						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
						toggleConfiguration.Container.KeyBind.Bind.v.Text = key.Name
						Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
						ResizeBindFrame()

						task.delay(0.5, function()
							data.KeybindReady = true
						end)
					end
				end

				toggleConfiguration.Container.KeyBind.Interact.MouseButton1Click:Connect(function()
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
					task.wait(0.2)
					toggleConfiguration.Container.KeyBind.Bind.v.Text = "..."
					Services.Tween:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
					ResizeBindFrame()


					local connection
					connection = Services.UserInput.InputBegan:Connect(function(input, processed)
						if not Services.UserInput:GetFocusedTextBox() and Owl:IsBindableInput(input) then
							setKeybind(input.KeyCode)
							connection:Disconnect()
						end
					end)
				end)

				Services.UserInput.InputBegan:Connect(function(input, processed)
					if not Services.UserInput:GetFocusedTextBox() and data.Keybind and data.KeybindReady and input.KeyCode == data.Keybind then
						data.V = not data.V
						UpdateToggleUI(data.V)

						if data.CallBack then
							local success, errorMsg = pcall(function()
								data.CallBack(data.V)
							end)
							if not success then
								Owl:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
							end
						end


					end
				end)

				local debounce2 = false

				toggleConfiguration.Container.Clear.Interact.MouseButton1Click:Connect(function()
					if debounce2 then return end
					debounce2 = true

					setKeybind(nil)

					local function blink()
						Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = 13 }):Play()
						task.wait(0.2)
						Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = -13 }):Play()
						task.wait(0.2)
						Services.Tween:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = 0 }):Play()
					end

					blink()

					task.delay(2, function()
						debounce2 = false
					end)
				end)

				toggleConfiguration.Container.Clear.MouseEnter:Connect(function()
					Services.Tween:Create(toggleConfiguration.Container.Clear.clear, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.9 }):Play()
				end)

				toggleConfiguration.Container.Clear.MouseLeave:Connect(function()
					Services.Tween:Create(toggleConfiguration.Container.Clear.clear, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
				end)

			end

			Owl:AddConnection(Owl.Comms.Event, function(p, color)
				if p == 'HitBox' then
					if data.V then
						toggle.tog.BackgroundColor3 = color
						toggle.tog.glow.ImageColor3 = color
					end
				end
			end)

			function data:Set(NewValue, skipSave)
				data.V = NewValue
				data.Value = NewValue
				UpdateToggleUI(NewValue)

				if data.CallBack then
					local success, errorMsg = pcall(function()
						data.CallBack(data.V)
					end)
					if not success then
						Owl:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
					end
			end
			end

			data.Value = data.V
			data._frame = toggle
			data.toggle = function(self) if self._frame and self._frame.Parent then self._frame.Visible = not self._frame.Visible end end
			data.remove = function(self) if self._frame and self._frame.Parent then self._frame:Destroy() end end

			if Owl.ConfigEnabled and data.Flag then
				Owl.Flags[data.Flag] = data
				if Owl.LoadedConfig and Owl.LoadedConfig[data.Flag] ~= nil then
					data:Set(Owl.LoadedConfig[data.Flag], true)
				end
			end

			return data
		end
		function initelement:Slider(Slider)
			local data = {
				Title = Slider.Title or Slider.Name or "Slider";
				Desc = Slider.Description or Slider.Desc or "";
				Sliders = Slider.Sliders
			}

			if not data.Sliders then
				data.Sliders = {
					{
						Title = Slider.ValueName or Slider.Name or Slider.Title or "Value",
						Range = Slider.Range or {Slider.Min or 0, Slider.Max or 100},
						Increment = Slider.Increment or 1,
						StarterValue = Slider.Default ~= nil and Slider.Default or (Slider.StarterValue or 0),
						CallBack = Slider.Callback or Slider.CallBack,
						Flag = Slider.Flag
					}
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
					Title = Options.Title or "Slider";
					Increment = Options.Increment or 1;
					Range = Options.Range or {0, 100};
					StarterValue = Options.StarterValue or 16;
					CallBack = Options.CallBack;
					Flag = Options.Flag;
				}

				Slider.Name = Options.Title
				Slider.Title.Text = Options.Title
				Options.Value = Options.StarterValue

				local dragging = false
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


				Slider.slide.slideframe:TweenSize(UDim2.new(SliderPosition, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

				Owl:registerLoadTween(
					Slider.slide.slideframe,
					{Size = UDim2.new(SliderPosition, 0, 1, 0)},
					{Size = UDim2.new(0, 100,1, 0)},
					TweenInfo.new(0.85, Enum.EasingStyle.Quint)
				)

				Owl:replayLoadTweens(Slider.slide.slideframe)

				local decimalPlaces = Owl:DecimalPlaces(Options.Increment)
				Slider.v.Text = string.format("<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>", Options.StarterValue, Options.Range[2])

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
					if tickCount < 2 then return end
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
						Services.Tween:Create(
							tick,
							TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Position = finalPos,
								BackgroundTransparency = 0.85
							}
						):Play()
					end
					for i = tickCount + 1, #existingTicks do
						existingTicks[i]:Destroy()
					end

				end
				if Options.Increment > 4 then
					if not Slider.slide.Ticks:FindFirstChild("_ResizeConnection") then
						local conn = Slider.slide.Ticks:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
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
						local sliderPosition = (x - sliderStart) / sliderWidth
						sliderPosition = math.clamp(sliderPosition, 0, 1)

						local range = Options.Range[2] - Options.Range[1]
						local newValue = Options.Range[1] + sliderPosition * range
						newValue = math.floor((newValue - Options.Range[1]) / Options.Increment + 0.5) * Options.Increment + Options.Range[1]
						newValue = Owl:RoundTo(newValue, Owl:DecimalPlaces(Options.Increment))
						local snapPosition = (newValue - Options.Range[1]) / range
						Slider.slide.slideframe:TweenSize(UDim2.new(snapPosition, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.55, true)

						Owl:registerLoadTween(
							Slider.slide.slideframe,
							{Size = UDim2.new(snapPosition, 0, 1, 0)},
							{Size = UDim2.new(0, 100,1, 0)},
							TweenInfo.new(0.85, Enum.EasingStyle.Quint)
						)
						local decimalPlaces = Owl:DecimalPlaces(Options.Increment)
						Slider.v.Text = string.format("<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>", newValue, Options.Range[2])

						Services.Tween:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

						local success, errorMsg = pcall(function()
							Options.CallBack(newValue)
						end)
						if not success then
							Owl:Report("Slider '" .. Slider.Name .. "' callback", errorMsg)
						end


						Options:Set(newValue)

					end
				end
				UpdateSlider()

				Slider.slide.Interact.MouseButton1Down:Connect(function()
					dragging = true
				end)

				Slider.slide.Interact.MouseButton1Up:Connect(function()
					dragging = false
				end)

				Owl:AddConnection(Services.UserInput.InputEnded, function(input, processed)
					if input.UserInputType == Enum.UserInputType.MouseButton1  or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						Services.Tween:Create(Slider.Title, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { TextTransparency = 0.6 }):Play()
					end
				end)

				Owl:AddConnection(Services.UserInput.InputChanged, function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement  or input.UserInputType == Enum.UserInputType.Touch  then
						UpdateSlider(input.Position.X)
					end
				end)

				Slider.slide.slideframe.BackgroundColor3 = Owl.theme.HitBox
				Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = Owl.theme.HitBox
				Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = Owl.theme.HitBox
				Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = Owl.theme.HitBox
				slider.slideholder.Size = UDim2.new(1,-30,0,slider.slideholder.UIListLayout.AbsoluteContentSize.Y)
				local ss = slider.slideholder.UIListLayout.AbsoluteContentSize.Y
				slider.Size = UDim2.new(1,-35,0, ss  + 20)

				Owl:AddConnection(Owl.Comms.Event, function(p, color)
					if p == 'HitBox' then
						Slider.slide.slideframe.BackgroundColor3 = color
						Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = color
						Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = color
						Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = color
					end
				end)

				function Options:Set(NewVal, skipSave)
					local range = Options.Range[2] - Options.Range[1]
					local sliderPosition = (NewVal - Options.Range[1]) / range

					Slider.slide.slideframe:TweenSize(
						UDim2.new(sliderPosition, 0, 1, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quint,
						0.55,
						true
					)
					Owl:registerLoadTween(
						Slider.slide.slideframe,
						{Size = UDim2.new(sliderPosition, 0, 1, 0)},
						{Size = UDim2.new(0, 100, 1, 0)},
						TweenInfo.new(0.85, Enum.EasingStyle.Quint)
					) 
					local decimalPlaces = Owl:DecimalPlaces(Options.Increment)
					Slider.v.Text = string.format("<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>", NewVal, Options.Range[2])
					Services.Tween:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {
						TextTransparency = 0
					}):Play()
					local success, result = pcall(function()
						Options.CallBack(NewVal)
					end)
					if not success then
						Owl:Report("Slider '" .. slider.Name .. "' callback", result)
					end

					Options.StarterValue = NewVal
				end
				Owl:AttachSliderInput(Slider, Options)

				Options._frame = slider
				Options.toggle = function(self) slider.Visible = not slider.Visible end
				Options.remove = function(self) slider:Destroy() end
				if not primaryOptions then
					primaryOptions = Options
				end

				if Owl.ConfigEnabled and Options.Flag then
					Owl.Flags[Options.Flag] = Options
					if Owl.LoadedConfig and Owl.LoadedConfig[Options.Flag] ~= nil then
						Options:Set(Owl.LoadedConfig[Options.Flag], true)
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
						local textSize = Services.Text:GetTextSize(
							descLabel.Text,
							descLabel.TextSize,
							descLabel.Font,
							Vector2.new(descLabel.AbsoluteSize.X, math.huge)
						)

						local newDescSize = UDim2.new(1, -150, 0, textSize.Y)
						local newButtonSize = UDim2.new(slider.Size.X.Scale, slider.Size.X.Offset, 0,slider.slideholder.AbsoluteSize.Y + slider.title.Size.Y.Offset + textSize.Y + 15) -- Adding extra padding

						local descTween = Services.Tween:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
						descTween:Play()

						local ToggleTween = Services.Tween:Create(slider, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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
							if type(t) ~= "table" then return true end
							return not t[Slider.Block[2]]
						end)
						if ok and blocked ~= lastBlocked then
							lastBlocked = blocked
							slider.slideholder.Interactable = not blocked
							Services.Tween:Create(slider, TweenInfo.new(0.3), {
								BackgroundTransparency = blocked and 0.8 or 0
							}):Play()
						end
						task.wait(0.2)
					end
				end)
			end

			data._frame = slider
			data.toggle = function(self) slider.Visible = not slider.Visible end
			data.remove = function(self) slider:Destroy() end

			if primaryOptions then
				primaryOptions._frame = slider
				primaryOptions.toggle = data.toggle
				primaryOptions.remove = data.remove
				return primaryOptions
			end

			return data

		end
		function initelement:Keybind(Keybind)
			Keybind = Keybind or {}
			local data = {
				Title = Keybind.Title or Keybind.Name or "Keybind";
				Key = Keybind.Key or Keybind.Default;
				Desc = Keybind.Description or Keybind.Desc or "";
				CallBack = Keybind.Callback or Keybind.CallBack or function() end;
				Flag = Keybind.Flag or Keybind.Name or Keybind.Title;
				Save = Keybind.Save ~= false;
				Type = "Keybind";
				WaitingForKey = false;
				Hold = false;
				Holding = false
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
			Services.Tween:Create(KeyBind.Bind, TweenInfo.new(0.55, Enum.EasingStyle.Quint ), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()

			KeyBind.interact.MouseButton1Click:Connect(function()
				KeyBind.Bind.v.Text = '...'
				Services.Tween:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Thickness = 1}):Play()
				data.WaitingForKey = true
			end)

			KeyBind.Bind.v:GetPropertyChangedSignal('TextBounds'):Connect(function()
				Services.Tween:Create(KeyBind.Bind, TweenInfo.new(0.55, Enum.EasingStyle.Quint ), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()
			end)

			local function SetKeybind(keyCode)
				if typeof(keyCode) == "EnumItem" and keyCode ~= Enum.KeyCode.Unknown then
					data.Key = keyCode
					data.Value = keyCode.Name
					Services.Tween:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Thickness = 0}):Play()
					KeyBind.Bind.v.Text = keyCode.Name
				else
					data.Key = nil
					data.Value = "NONE"
					KeyBind.Bind.v.Text = "NONE"
				end

				if data.Flag and data.Save then
					Owl.Flags[data.Flag] = data
					SaveConfig(game and game.GameId)
				end
			end

			if Owl.LoadedConfig and data.Flag and Owl.LoadedConfig[data.Flag] ~= nil then
				local savedKey = Owl.LoadedConfig[data.Flag]
				SetKeybind(Enum.KeyCode[savedKey] or Enum.UserInputType[savedKey])
			else
				SetKeybind(data.Key)
			end
			Owl:AddConnection(Services.UserInput.InputBegan, function(input, processed)
				if data.WaitingForKey then
					if Owl:IsBindableInput(input) then
						data.WaitingForKey = false
						if input.UserInputType == Enum.UserInputType.Keyboard then
							SetKeybind(input.KeyCode)
						else
							SetKeybind(input.UserInputType)
						end
					end
					return
				end

				if Services.UserInput:GetFocusedTextBox() then return end

				local isMatchingKey = false
				if typeof(data.Key) == "EnumItem" then
					if data.Key.EnumType == Enum.KeyCode and input.KeyCode == data.Key then
						isMatchingKey = true
					elseif data.Key.EnumType == Enum.UserInputType and input.UserInputType == data.Key then
						isMatchingKey = true
					end
				end

				if isMatchingKey then
					data.Hold = true

					local holdConnection
					holdConnection = input.Changed:Connect(function(prop)
						if prop == "UserInputState" then
							local state = input.UserInputState
							data.Hold = (state == Enum.UserInputState.Begin)
							if state == Enum.UserInputState.End and holdConnection then
								holdConnection:Disconnect()
							end
						end
					end)

					local success, result = pcall(data.CallBack)
					if not data.Holding then
						if not success then
							Owl:Report("Keybind '" .. KeyBind.Name .. "' callback", result)
						end
					else
						if data.Hold then
							local holdLoop
							holdLoop = Services.Run.RenderStepped:Connect(function()
								if not data.Hold then
									data.CallBack(false)
									holdLoop:Disconnect()
								else
									data.CallBack(false)
								end
							end)
						end
					end
				end
			end)

			data._frame = KeyBind
			data.toggle = function(self) KeyBind.Visible = not KeyBind.Visible end
			data.remove = function(self) KeyBind:Destroy() end
			data.Set = function(self, newKey) SetKeybind(newKey) end
			if data.Flag then
				Owl.Flags[data.Flag] = data
			end

			return data

		end
		function initelement:TextInput(TextInput)
			local data = {
				Title = TextInput.Title or TextInput.Name or "Text Input",
				PlaceHolder = TextInput.PlaceHolder or TextInput.BackGrountText or TextInput.Placeholder or "Enter text...",
				NumbersOnly = TextInput.NumberOnly or false,
				ClearOnLost = TextInput.ClearOnLost == nil and (TextInput.TextDisappear ~= false) or TextInput.ClearOnLost,
				CallBack = TextInput.Callback or TextInput.CallBack,
				Default = TextInput.Default
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
				Services.Tween:Create(textinput.TextFrame.Enter, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end)

			textinput.TextFrame.Enter.MouseLeave:Connect(function()
				Services.Tween:Create(textinput.TextFrame.Enter, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end)

			textBox:GetPropertyChangedSignal("Text"):Connect(function()
				if data.NumbersOnly then
					textBox.Text = textBox.Text:gsub("%D", "")
				end

				textBox.Size = UDim2.new(1, -60, 0, defaultHeight + 40)

				local textSize = game:GetService("TextService"):GetTextSize(
					textBox.Text, textBox.TextSize, textBox.Font, Vector2.new(textBox.AbsoluteSize.X, math.huge)
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




				Services.Tween:Create(
					textinput,
					TweenInfo.new(0.7, Enum.EasingStyle.Quint),
					{ Size = UDim2.new(1, -35, 0, newHeight + extraHeight + 35) }
				):Play()


			end)

			textBox:GetPropertyChangedSignal("Size"):Connect(function()
				local newHeight = textBox.Size.Y.Offset
				local totalHeight = math.max(newHeight, defaultHeight)

				Services.Tween:Create(
					textinput.TextFrame,
					TweenInfo.new(0.7, Enum.EasingStyle.Quint),
					{ Size = UDim2.new(1, -60, 0, totalHeight + 0) }
				):Play()


			end)

			local function ProcessInput(text)
				local success, errorMsg = pcall(function()
					data.CallBack(text)
				end)
				if not success then
					Owl:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
				end
			end

			textBox.FocusLost:Connect(function(enterPressed)
				if not enterPressed then return end

				local success, errorMsg = pcall(function()
					data.CallBack(textBox.Text)
				end)
				if not success then
					Owl:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
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
					Owl:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
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
			data.toggle = function(self) textinput.Visible = not textinput.Visible end
			data.remove = function(self) textinput:Destroy() end
			data.Set = function(self, val)
				textBox.Text = tostring(val or "")
				if data.CallBack then data.CallBack(textBox.Text) end
			end

			return data

		end

		function initelement:EnchancedView(View)
			local Viewdata = {
				Title = View.Title or "3D View",
				Object = View.Object,
				UserRotate = View.UserRotate or false,
				AutoRotate = View.AutoRotate ~= false -- default true
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
				Services.Tween:Create(EnchancedView.ViewFrame.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
					ImageTransparency = 1
				}):Play()
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
						dragStartPos = input.Position -- store where drag started

						Services.Tween:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
							ImageColor3 = Color3.fromRGB(255, 255, 255)
						}):Play()
					end
				end)

				Viewport.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						Services.Tween:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
							ImageColor3 = Color3.fromRGB(30, 30, 30)
						}):Play()
					end
				end)

				Viewport.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement  then
						local delta = input.Position - lastPos
						targetRotationY = targetRotationY + delta.X * 0.005
						targetRotationX = math.clamp(targetRotationX - delta.Y * 0.005, -math.pi/2, math.pi/2)


						lastPos = input.Position
					end
				end)
			end
			local ZoomFrame   = EnchancedView.ViewFrame.Zoom
			local ClipFrame   = ZoomFrame.clipframe
			local ScrollFrame = ClipFrame.scroll
			local ZoomAmountLabel = ZoomFrame.Frame.ZoomAmount -- << change to your label path
			local minZoomDistance = maxDimension * 0.5
			local maxZoomDistance = maxDimension * 10
			local elasticity   = 0.4      -- visual resistance (0..1)
			local maxOverdrag  = 50       -- px visual overdrag cap
			local tweenInfo    = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
				local t = (y - minY) / (maxY - minY) -- 0..1
				return minZoomDistance + (maxZoomDistance - minZoomDistance) * t
			end

			local function updateZoom(distance)
				distance = math.clamp(distance, minZoomDistance, maxZoomDistance)
				Camera.CFrame = CFrame.new(Vector3.new(0, 0, distance), Vector3.new(0, 0, 0))
				if ZoomAmountLabel then
					Services.Tween:Create(ZoomAmountLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {Position = UDim2.new(1, 0,0.5, -20)}):Play()
					task.wait(0.045)
					ZoomAmountLabel.Text = 'x'..string.format("%.2f", distance)
					ZoomAmountLabel.Position = UDim2.new(1, 0,0.5, 20)
					Services.Tween:Create(ZoomAmountLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {Position = UDim2.new(1, 0,0.5, 0)}):Play()
				end
			end



			local function visualYFromVirtualY(vy)
				local minY, maxY = getScrollLimits()
				if vy > minY then
					local over = vy - minY
					return math.min(minY + over * elasticity, minY + maxOverdrag)
				elseif vy < maxY then
					local over = vy - maxY -- negative
					return math.max(maxY + over * elasticity, maxY - maxOverdrag)
				else
					return vy
				end
			end
			local dragging   = false
			local lastPos
			local virtualY   = 0 
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

					game:GetService("TweenService"):Create(
						ScrollFrame,
						tweenInfo,
						{ Position = UDim2.new(ScrollFrame.Position.X.Scale, ScrollFrame.Position.X.Offset, 0, virtualY) }
					):Play()
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
					ScrollFrame.Position = UDim2.new(ScrollFrame.Position.X.Scale, ScrollFrame.Position.X.Offset, 0, visualY)
					local minY, maxY = getScrollLimits()
					local clampedY = math.clamp(virtualY, maxY, minY)
					local distance = yToZoom(clampedY)
					updateZoom(distance)
				end
			end)

		end
		function initelement:Paragraph(Paragraph)
			local ParaData = {
				Title = Paragraph.Title or Paragraph.Name or "Paragraph";
				Content = Paragraph.Content or Paragraph.Text or "";
			}

			local Para = pages.page.Paragraph:Clone()
			Para.Visible = true
			Para.Parent = Page
			Para.Frame.title.Text = ParaData.Title
			Para.Content.Text = ParaData.Content
			Para:SetAttribute("Searchable", true)

			Para.Content.Size = UDim2.new(1, -20, 0, Para.Content.TextBounds.Y)

			local function updateSize()
				local textSize = Services.Text:GetTextSize(
					Para.Content.Text,
					Para.Content.TextSize,
					Para.Content.Font,
					Vector2.new(Para.Content.AbsoluteSize.X, math.huge)
				)

				local newDescSize = UDim2.new(1, -20, 0, textSize.Y)
				local newButtonSize = UDim2.new(Para.Size.X.Scale, Para.Size.X.Offset, 0, textSize.Y + 120)

				local descTween = Services.Tween:Create(Para.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
				descTween:Play()

				local buttonTween = Services.Tween:Create(Para, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
				buttonTween:Play()
			end

			updateSize()

			Para.Content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)

			ParaData._frame = Para
			ParaData.toggle = function(self) Para.Visible = not Para.Visible end
			ParaData.remove = function(self) Para:Destroy() end
			ParaData.Set = function(self, newTitle, newContent)
				if newTitle then Para.Frame.title.Text = tostring(newTitle) end
				if newContent then Para.Content.Text = tostring(newContent) updateSize() end
			end
			return ParaData
		end

		function initelement:Label(Text, Alignment)

			local Label = pages.page.Label:Clone()
			Label.Visible = true
			Label.Parent = Page
			Label.text.Text = tostring(Text or "")
			Label:SetAttribute("Searchable", true)

			if Alignment == 'Center' then
				Label.text.TextXAlignment = Enum.TextXAlignment.Center
			elseif Alignment == 'Right' then
				Label.text.TextXAlignment = Enum.TextXAlignment.Right
			end

			local labelData = {
				_frame = Label,
				Set = function(self, newText) Label.text.Text = tostring(newText or "") end,
				toggle = function(self) Label.Visible = not Label.Visible end,
				remove = function(self) Label:Destroy() end
			}
			return labelData

		end

		function initelement:Section(Title, Icon)
			local SectionData = {
				Title = Title or ""
			}

			local Section = pages.page.Section:Clone()
			Section.Visible = true
			Section.Title.Text = SectionData.Title
			Section.Parent = Page
			Section.Title.Position = UDim2.new(0, 0,0, 0)

			if Icon then
				Section.icon.Image = 'rbxassetid://'..Icon
				Section.Title.Position = UDim2.new(0, 25,0, 0)
			else
				Section.icon.Visible = false
			end

			SectionData._frame = Section
			SectionData.toggle = function(self) Section.Visible = not Section.Visible end
			SectionData.remove = function(self) Section:Destroy() end
			SectionData.Set = function(self, newTitle) Section.Title.Text = tostring(newTitle or "") end
			return SectionData
		end
		function initelement:Dropdown(Dropdown)
			local data = {
				Title = Dropdown.Title or Dropdown.Name or "Temp Dropdown";
				Options = Dropdown.Options or {};
				StarterOption = Dropdown.Default ~= nil and Dropdown.Default or Dropdown.StarterOption;
				PlaceHolder = Dropdown.PlaceHolder or Dropdown.Placeholder or "Select Option...";
				Multi = Dropdown.Multi or false;
				CallBack = Dropdown.Callback or Dropdown.CallBack;
				Flag = Dropdown.Flag;
			}

			local dropdown = pages.page.Dropdown:Clone()
			dropdown.Visible = true
			dropdown.Parent = Page
			dropdown.title.Text = data.Title
			dropdown.Name = data.Title
			dropdown.dropholder.drop.Container.Option.Visible = false
			dropdown.dropholder.drop.Container.Visible = false
			Services.Tween:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.33, -20,0.576, -75) }):Play()
			dropdown.dropholder.drop.selected.Text = data.PlaceHolder 
			dropdown:SetAttribute("Searchable", true)

			local DropOpen = false
			local DeBounce = false
			local OptionButton = dropdown.dropholder.drop.Container.Option
			local SelectedOptions = {}
			local SelectedOrder = {}

			local function UpdateCustomLayout()
				local yOffset = 0
				for _, option in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
					if option:IsA("Frame") and option.Visible then
						Services.Tween:Create(option, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, yOffset)}):Play()
						yOffset = yOffset + option.Size.Y.Offset + 7
					end
				end
			end

			local function OpenDrop()
				DropOpen = true
				dropdown.dropholder.drop.Container.Visible = true
				dropdown.dropholder.drop.search.Visible = true

				Services.Tween:Create(dropdown, TweenInfo.new(1.34, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 300) }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -20, 1, -75) }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.v0, TweenInfo.new(1.34, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Rotation = 180 }):Play()

				Services.Tween:Create(dropdown.dropholder.drop.search, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.65 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.search.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0.4 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.search.TextBox, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.search.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.9 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.search.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.85 }):Play()

			end

			local function CloseDrop()
				DropOpen = false
				Services.Tween:Create(dropdown, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 95) }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.33, -20, 0.576, -75) }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.v0, TweenInfo.new(1.34, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Rotation = 0 }):Play()

				Services.Tween:Create(dropdown.dropholder.drop.search, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.search.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.search.TextBox, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.search.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
				Services.Tween:Create(dropdown.dropholder.drop.search.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()

				task.wait(0.6)
				dropdown.dropholder.drop.Container.Visible = false
				dropdown.dropholder.drop.search.Visible = false

			end

			dropdown.dropholder.drop.down.MouseButton1Click:Connect(function()
				if DeBounce then return end
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
							optionGroup.X.MouseButton1Click:Connect(function()
								RemoveFromSelected(option)
								UpdateSelectedText()
								for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
									if opt:IsA("Frame") and opt.Name == option then
										Services.Tween:Create(opt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
										Services.Tween:Create(opt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
										Services.Tween:Create(opt.Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
										Services.Tween:Create(opt.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
										Services.Tween:Create(opt.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
									end
								end

								if data.CallBack then
									data.CallBack(SelectedOrder)
								end
							end)

							optionGroup.Parent = selectedContainer
							task.defer(function()
								local padding = 40
								local textWidth = optionGroup.TextLabel.TextBounds.X
								local totalWidth = textWidth + padding

								optionGroup.TextLabel.Size = UDim2.new(0, textWidth, 1, 0)

								Services.Tween:Create(optionGroup, TweenInfo.new(0.67, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, totalWidth, 0, 20)}):Play()
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
						local showldShow = not isTemplate and (searchText == "" or optionText:find(searchText, 1, true) or SelectedOptions[option.Title.Text])

						if showldShow then
							option.Visible = true
							if SelectedOptions[option.Title.Text] then
								Services.Tween:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
								Services.Tween:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
								Services.Tween:Create(option.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
								Services.Tween:Create(option.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
							else
								Services.Tween:Create(option, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
								Services.Tween:Create(option, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
								Services.Tween:Create(option.Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
								Services.Tween:Create(option.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
								Services.Tween:Create(option.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
							end
						else
							Services.Tween:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
							Services.Tween:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
							Services.Tween:Create(option.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
							Services.Tween:Create(option.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
							option.Visible = false
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
				local starterSet = false
				for _, OptionText in ipairs(data.Options) do
					local option = OptionButton:Clone()
					option.Title.Text = OptionText
					option.Parent = dropdown.dropholder.drop.Container
					option.Visible = true
					option.Name = OptionText

					if OptionText == data.StarterOption and not starterSet then
						starterSet = true
						dropdown.dropholder.drop.Selected.Text = OptionText
						SelectedOptions = {[OptionText] = true}
						SelectedOrder = {OptionText}

						Services.Tween:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
						Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
					end

					option.Interact.MouseButton1Click:Connect(function()
						if data.Multi then
							if SelectedOptions[OptionText] then
								RemoveFromSelected(OptionText)
								Services.Tween:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
								Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0.9}):Play()
							else
								AddToSelected(OptionText)
								Services.Tween:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
								Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
							end

							if data.CallBack then
								data.CallBack(SelectedOrder)
							end
						else
							dropdown.dropholder.drop.selected.Text = OptionText

							SelectedOptions = {[OptionText] = true}
							SelectedOrder = {OptionText}

							for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
								if opt:IsA("Frame") then
									Services.Tween:Create(opt, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
									Services.Tween:Create(opt.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0.9}):Play()
								end
							end

							Services.Tween:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
							Services.Tween:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()


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

				UpdateCustomLayout()
			end

			SetDropdownOptions()

			function data:Refresh(newOptions, clearCurrent)
				data.Options = newOptions or {}
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
			end

			function data:Set(value, state)
				if data.Multi then
					if state == nil or state == true then
						AddToSelected(value)
					else
						RemoveFromSelected(value)
					end
					UpdateSelectedText()
					if data.CallBack then
						data.CallBack(SelectedOrder)
					end
				else
					SelectedOptions = {[value] = true}
					SelectedOrder = {value}
					dropdown.dropholder.drop.selected.Text = tostring(value)
					for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
						if opt:IsA("Frame") and opt:FindFirstChild("Title") then
							local isMatch = (opt.Title.Text == value)
							opt.BackgroundColor3 = isMatch and Color3.fromRGB(39, 39, 39) or Color3.fromRGB(33, 33, 33)
							if opt:FindFirstChild("ImageLabel") then
								opt.ImageLabel.ImageTransparency = isMatch and 0 or 0.9
							end
						end
					end
					if data.CallBack then
						data.CallBack(value)
					end
				end
			end

			data._frame = dropdown
			data.toggle = function(self) dropdown.Visible = not dropdown.Visible end
			data.remove = function(self) dropdown:Destroy() end
			data.tg = nil
			data.Value = data.Multi and SelectedOrder or data.StarterOption

			return data

		end
		function initelement:ColorPicker(ColorPicker)
			local data = {
				Title = ColorPicker.Title;
				Color = ColorPicker.Color;
				Color2 = ColorPicker.Color2;
				Linkable = ColorPicker.Linkable;
				Type = ColorPicker.Type or 'ColorPicker';
				GradientPath = ColorPicker.GradientPath;
				CallBack = ColorPicker.CallBack;
				Flag = ColorPicker.Flag;
			}

			ColorPicker.Linkable = ColorPicker.Linkable or true


			local colorpicker = pages.page.ColorPicker:Clone()
			colorpicker.Visible = true
			colorpicker.Parent = Page
			colorpicker.title.Text = data.Title
			colorpicker.Name = data.Title
			colorpicker:SetAttribute("Searchable", true)



			local isLinkable = Instance.new("BoolValue")
			isLinkable.Name = 'isLinkable'
			isLinkable.Value = data.Linkable
			isLinkable.Parent = colorpicker

			local HueSat = Instance.new("Color3Value")
			HueSat.Name = 'HueSat'
			HueSat.Value = data.Color
			HueSat.Parent = colorpicker


			local Open = false
			local DeBounce = false
			local State = false

			do
				local HueValues = colorpicker.HueValues
				local list = HueValues:FindFirstChildOfClass("UIListLayout")
				if list then list:Destroy() end

				local ITEMS = {
					HueValues.HEX,
					HueValues.RGB,
					HueValues.Link
				}

				local GAP = 8
				local ITEM_HEIGHT = 30
				local ITEM_WIDTH = 120
				local HORIZONTAL_THRESHOLD = 260

				local function updateHueValuesLayout()
					if not HueValues.Visible then return end

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
					HueValues.Position = UDim2.new(0.5, 0,1, -50)

					if Open then
						if data.Type == "Gradient" then
							Services.Tween:Create(
								colorpicker,
								TweenInfo.new(0.35, Enum.EasingStyle.Quart),
								{ Size = UDim2.new(1, -35, 0, 305 + totalHeight) }
							):Play()
						else
							Services.Tween:Create(
								colorpicker,
								TweenInfo.new(0.35, Enum.EasingStyle.Quart),
								{ Size = UDim2.new(1, -35, 0, 290 + totalHeight) }
							):Play()
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
					Services.Tween:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0, startX , 0.8, -frame.Size.Y.Offset / 2) }):Play()
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
				if type(Table) ~= "table" then return Table end
				return Color3.fromHSV(Table[1],Table[2],Table[3])
			end

			local function FormatColor(Color, format, precision)

				format = format or "RGB"
				precision = precision or 2

				local formattedColor = ""

				if format == "RGB" then
					return	math.round(Color.R * 255) .. "," .. math.round(Color.G * 255) .. "," .. math.round(Color.B * 255)
				elseif format == "Hex" then
					formattedColor = string.format("#%02X%02X%02X",
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

					data.Color  = Keys[2].Value
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


				Services.Tween:Create(HUESlider.Pin, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {BackgroundColor3 = newColor2}):Play()
				Services.Tween:Create(SVPicker.Pin, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {BackgroundColor3 = newColor}):Play()


				Services.Tween:Create(SVPicker.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0)
				}):Play()

				Services.Tween:Create(HUESlider.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(1 - HSV[1], 0, 0.5, 0)
				}):Play()

				local formattedHex = FormatColor(data.Color, 'Hex')
				colorpicker.HueValues.HEX.V.HEXBox.PlaceholderText = formattedHex

				local formattedRGB = FormatColor(data.Color,'RGB', 2)
				colorpicker.HueValues.RGB.V.RGBBox.PlaceholderText = formattedRGB

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
					if oldCallback then oldCallback(col) end
					return
				end

				table.sort(Keys, function(a,b) return a.Time < b.Time end)

				Keys[1] = ColorSequenceKeypoint.new(0, Keys[2].Value)
				Keys[4] = ColorSequenceKeypoint.new(1, Keys[3].Value)

				data.Color  = Keys[2].Value
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
					ColorSequenceKeypoint.new(1, endCol)         
				}

				ActivePin = 2 

				GradientFrame.Pin1.BackgroundColor3 = startCol
				GradientFrame.Pin2.BackgroundColor3 = endCol
			end

			local oldCallback = data.CallBack
			data.CallBack = function(col)
				if data.Type ~= "Gradient" then
					if oldCallback then oldCallback(col) end
					return
				end

				table.sort(Keys, function(a,b) return a.Time < b.Time end)
				Keys[1] = ColorSequenceKeypoint.new(0, Keys[1].Value)
				Keys[#Keys] = ColorSequenceKeypoint.new(1, Keys[#Keys].Value)

				local seq = ColorSequence.new(Keys)
				ExternalGradient.Color = seq
				GradientFrame.Gradient.Color = seq

				if oldCallback then oldCallback(seq) end
			end

			if data.Type == "Gradient" then
				local g = GradientFrame
				local UIS = game:GetService("UserInputService")
				local RS = game:GetService("RunService")
				local mouse = game.Players.LocalPlayer:GetMouse()

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
						ActivePin = 2
						local h, s, v = Keys[2].Value:ToHSV()
						HSV[1], HSV[2], HSV[3] = h, s, v
						updatestuff()
					end
				end)

				g.Pin2.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						DraggingPin = 3
						ActivePin = 3
						local h, s, v = Keys[3].Value:ToHSV()
						HSV[1], HSV[2], HSV[3] = h, s, v
						updatestuff()
					end
				end)

				UIS.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						DraggingPin = nil
					end
				end)

				RS.Heartbeat:Connect(function()
					if not DraggingPin then return end

					local relX = (mouse.X - g.AbsolutePosition.X) / g.AbsoluteSize.X
					relX = math.clamp(relX, 0, 1)

					if DraggingPin == 2 then
						relX = math.clamp(relX, 0, Keys[3].Time - 0.01) 
					elseif DraggingPin == 3 then
						relX = math.clamp(relX, Keys[2].Time + 0.01, 1) 
					end

					Keys[DraggingPin] = ColorSequenceKeypoint.new(relX, Keys[DraggingPin].Value)

					updateUI()
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


				Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.95, Enum.EasingStyle.Quart ), { Size = UDim2.new(0, 1,0, 1) }):Play()
				Services.Tween:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
				Services.Tween:Create(colorpicker.color, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundColor3 = data.Color }):Play()
				Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.color.glow, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 1}):Play()
				task.wait(0.12)
				Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.9, Enum.EasingStyle.Quart ), { Size = UDim2.new(1, -40,0, 160) }):Play()
				Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.9, Enum.EasingStyle.Quart ), { Position = UDim2.new(0.5, 0,0, 40) }):Play()

				Services.Tween:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }):Play()
				Services.Tween:Create(colorpicker.color.UICorner, TweenInfo.new( 0.8, Enum.EasingStyle.Quart ), { CornerRadius = UDim.new(0, 10) }):Play()

				Services.Tween:Create(colorpicker.color.Values.Rainbow, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()


				task.wait(0.6)

				Services.Tween:Create(colorpicker.color.SVPicker.Brightness, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.color.SVPicker.Saturation, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.color.SVPicker.Pin, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.color.SVPicker.Pin.UIStroke, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()

				task.wait(0.5)
				Services.Tween:Create(colorpicker.color.Values.Hue, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.color.Values.Hue.Pin, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.color.Values.Hue.Pin.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()

				if data.Type == "Gradient" then
					Services.Tween:Create(colorpicker.color.Values.Grad, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Grad.Pin1, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Grad.Pin1.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Grad.Pin2, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Grad.Pin2.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()
				end


				Services.Tween:Create(colorpicker.HueValues.HEX, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
				Services.Tween:Create(colorpicker.HueValues.HEX.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
				Services.Tween:Create(colorpicker.HueValues.HEX.V.HEXBox, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { TextTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.HueValues.HEX.Copy, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()

				task.wait(0.09)
				Services.Tween:Create(colorpicker.HueValues.RGB, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
				Services.Tween:Create(colorpicker.HueValues.RGB.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
				Services.Tween:Create(colorpicker.HueValues.RGB.V.RGBBox, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { TextTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.HueValues.RGB.Copy, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()
				task.wait(0.09)
				Services.Tween:Create(colorpicker.HueValues.Link, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
				Services.Tween:Create(colorpicker.HueValues.Link.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
				Services.Tween:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				Services.Tween:Create(colorpicker.HueValues.Link.Frame.ImageLabel, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()

				for _,v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
					if v:IsA('Frame') then
						task.wait(0.1)
						Services.Tween:Create(v, TweenInfo.new( 0.3, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					end
				end

				task.wait(0.7)
				DeBounce = false
			end


			colorpicker.interact.MouseButton1Click:Connect(function()
				if DeBounce then return end
				if not Open then
					Open = true
					OpenPicker()
				end
			end)

			colorpicker.QuickClose.hitbox.MouseEnter:Connect(function()
				Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 70,0, 3) }):Play()
				Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
			end)

			colorpicker.QuickClose.hitbox.MouseLeave:Connect(function()
				Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 60,0, 3) }):Play()
				Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(33, 33, 33) }):Play()
			end)

			local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

			if data.Type == "Gradient" and displayGrad then
				displayGrad.Enabled = true
				displayGrad.Color = ColorSequence.new(Keys)
				Services.Tween:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
			else
				if displayGrad then displayGrad.Enabled = false end
				Services.Tween:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = data.Color }):Play()
			end

			local function ClosePicker()
				Open = false
				DeBounce = true
				Services.Tween:Create(colorpicker, TweenInfo.new( 0.55, Enum.EasingStyle.Quint ), { Size = UDim2.new(1, -35,0, 40) }):Play()
				Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.7, Enum.EasingStyle.Quart ), { Position = UDim2.new(1, -30,0, 10)}):Play()
				Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.55, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 20,0, 20) }):Play()
				Services.Tween:Create(colorpicker.color, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundColor3 = data.Color }):Play()
				Services.Tween:Create(colorpicker.QuickClose, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.color.glow, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 0.7}):Play()
				colorpicker.interact.Interactable = true
				colorpicker.QuickClose.Interactable = false

				Services.Tween:Create(colorpicker.color.SVPicker.Brightness, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.color.SVPicker.Saturation, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.color.SVPicker.Pin, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.color.SVPicker.Pin.UIStroke, TweenInfo.new( 0.4, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()

				Services.Tween:Create(colorpicker.color.Values.Hue, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.color.Values.Hue.Pin, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.color.Values.Hue.Pin.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()

				Services.Tween:Create(colorpicker.color.Values.Rainbow, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

				local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

				if data.Type == "Gradient" and displayGrad then
					displayGrad.Enabled = true
					displayGrad.Color = ColorSequence.new(Keys)
					Services.Tween:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
				else
					if displayGrad then displayGrad.Enabled = false end
					Services.Tween:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = data.Color }):Play()
				end

				if data.Type == "Gradient" then
					Services.Tween:Create(colorpicker.color.Values.Grad, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Grad.Pin1, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Grad.Pin1.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Grad.Pin2, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					Services.Tween:Create(colorpicker.color.Values.Grad.Pin2.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
				end

				Services.Tween:Create(colorpicker.HueValues.RGB, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.RGB.UIStroke, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.RGB.V.RGBBox, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { TextTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.RGB.Copy, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

				Services.Tween:Create(colorpicker.HueValues.HEX, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.HEX.UIStroke, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.HEX.V.HEXBox, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { TextTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.HEX.Copy, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

				Services.Tween:Create(colorpicker.HueValues.Link, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.Link.UIStroke, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				Services.Tween:Create(colorpicker.HueValues.Link.Frame.ImageLabel, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()
				colorpicker.HueValues.Visible = false
				for _,v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
					if v:IsA('Frame') then
						Services.Tween:Create(v, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					end
				end
				task.wait(1)
				colorpicker.color.SVPicker.Visible = false
				colorpicker.color.Values.Recent.Visible = false
				task.wait(0.7)
				DeBounce = false
			end

			colorpicker.QuickClose.hitbox.MouseButton1Click:Connect(function()
				if DeBounce then return end
				if Open then
					Open = false
					ClosePicker()
				end
			end)


			for _,v in ipairs(colorpicker.HueValues:GetChildren()) do
				if v:IsA("Frame") then
					for _,v2 in ipairs(v:GetChildren()) do
						if v2:IsA("ImageLabel") then
							v2.MouseEnter:Connect(function()
								Services.Tween:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
							end)
							v2.MouseLeave:Connect(function()
								Services.Tween:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(66, 66, 66) }):Play()
							end)
						end
					end
				end
			end
			Owl:OnClick(colorpicker.HueValues.HEX.Copy, function()
				if Owl:SetClipboard(FormatColor(data.Color, 'Hex')) then Owl:FlashCopy(colorpicker.HueValues.HEX.Copy) end
			end)
			Owl:OnClick(colorpicker.HueValues.RGB.Copy, function()
				if Owl:SetClipboard(FormatColor(data.Color, 'RGB', 2)) then Owl:FlashCopy(colorpicker.HueValues.RGB.Copy) end
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
					Services.Tween:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 20,0, 20) }):Play()
				end)

				recentFrame.interact.MouseLeave:Connect(function()
					Services.Tween:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 12,0, 12) }):Play()
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

			Owl:AddConnection(SVPicker.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					SV = Services.Run.RenderStepped:Connect(function()
						local mouse = game.Players.LocalPlayer:GetMouse()
						local ColorX = math.clamp(mouse.X - SVPicker.AbsolutePosition.X, 0, SVPicker.AbsoluteSize.X) / SVPicker.AbsoluteSize.X
						local ColorY = math.clamp(mouse.Y - SVPicker.AbsolutePosition.Y, 0, SVPicker.AbsoluteSize.Y) / SVPicker.AbsoluteSize.Y

						HSV[2] = ColorX
						HSV[3] = 1 - ColorY

						updatestuff()
					end)
				end
			end)

			Owl:AddConnection(SVPicker.InputEnded, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 and SV then
					SV:Disconnect()
					SV = nil
					AddRecentColor(data.Color)
				end
			end)

			Owl:AddConnection(HUESlider.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					HUE = Services.Run.RenderStepped:Connect(function()
						local mouse = game.Players.LocalPlayer:GetMouse()
						local ColorX = math.clamp(mouse.X - HUESlider.AbsolutePosition.X, 0, HUESlider.AbsoluteSize.X) / HUESlider.AbsoluteSize.X

						HSV[1] = 1 - ColorX

						updatestuff()
					end)
				end
			end)

			Owl:AddConnection(HUESlider.InputEnded, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 and HUE then
					HUE:Disconnect()
					HUE = nil
					AddRecentColor(data.Color)
				end
			end)

			colorpicker.HueValues.HEX.V.HEXBox.FocusLost:Connect(function(Enter)
				if not Enter then return end

				local hexInput = colorpicker.HueValues.HEX.V.HEXBox.Text

				local success, result = pcall(function()
					return Color3.fromHex(hexInput)
				end)

				if success then
					local Hue, Saturation, Value = result:ToHSV()
					colorpicker.HueValues.HEX.V.HEXBox.Text = ''
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
				if not Enter then return end

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

						colorpicker.HueValues.RGB.V.RGBBox.Text = ''
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
			local originalPosition = UDim2.new(0.5, 0,0, 0)
			local draggedColorPicker = nil

			local function isMouseOver(guiObject)
				local mouse = game.Players.LocalPlayer:GetMouse()
				local pos = guiObject.AbsolutePosition
				local size = guiObject.AbsoluteSize
				return mouse.X >= pos.X and mouse.X <= pos.X + size.X and mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y
			end

			colorpicker.HueValues.Link.Frame.interact.MouseButton1Down:Connect(function()
				linkDragging = true
				draggedColorPicker = colorpicker

				TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {Size = UDim2.new(0, 40,1, 0)}):Play()

				local followMouse
				followMouse = RunService.RenderStepped:Connect(function()
					if not linkDragging then
						followMouse:Disconnect()
						return
					end
					local mouse = game.Players.LocalPlayer:GetMouse()
					TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, mouse.X - colorpicker.AbsolutePosition.X - 50, 0, mouse.Y - colorpicker.AbsolutePosition.Y - 260) }):Play()

					for _, otherPicker in pairs(Page:GetChildren()) do
						if otherPicker:IsA("Frame") and otherPicker:FindFirstChild("isLinkable") and otherPicker.isLinkable.Value then
							if isMouseOver(otherPicker) and otherPicker ~= draggedColorPicker then
								TweenService:Create(otherPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
							else
								TweenService:Create(otherPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							end
						end
					end
				end)
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and linkDragging then
					linkDragging = false
					local foundTarget = false

					for _, otherPicker in pairs(Page:GetChildren()) do
						if otherPicker:IsA("Frame") and otherPicker:FindFirstChild("isLinkable") and otherPicker.isLinkable.Value then
							if isMouseOver(otherPicker) and otherPicker ~= draggedColorPicker then
								otherPicker.HueSat.Value = draggedColorPicker.HueSat.Value
								updatestuff() 
								foundTarget = true
								Owl:Toast({
									Content = 'Color Linked',
									Duration = 2,
								})
								TweenService:Create(
									colorpicker.HueValues.Link.Frame,
									TweenInfo.new(0.3, Enum.EasingStyle.Quint),
									{ Position = originalPosition }
								):Play()

								TweenService:Create(otherPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {Size = UDim2.new(1, 0,1, 0)}):Play()
								break
							end
						end
					end

					if not foundTarget then
						TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {Size = UDim2.new(1, 0,1, 0)}):Play()
						TweenService:Create(
							colorpicker.HueValues.Link.Frame,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint),
							{ Position = originalPosition }
						):Play()
					end
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

			local hueIncrement = 0.005 

			local function RainbowEffect()
				HueValue = (HueValue + hueIncrement) % 1
				HSV[1] = HueValue

				updatestuff()
			end

			local isRainbowEnabled = false
			local huerender = nil

			local function ToggleRainbowEffect()
				isRainbowEnabled = not isRainbowEnabled
				if isRainbowEnabled then
					if not huerender then
						huerender = Services.Run.RenderStepped:Connect(RainbowEffect)
						Services.Tween:Create(colorpicker.color.Values.Rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential ), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
					end
				else
					if huerender then
						huerender:Disconnect()
						Services.Tween:Create(colorpicker.color.Values.Rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential ), {ImageColor3 = Color3.fromRGB(62, 62, 62)}):Play()
						huerender = nil
					end
				end
			end

			colorpicker.color.Values.Rainbow.MouseButton1Click:Connect(ToggleRainbowEffect)

			function data:Set(RGBColor, skipSave)
				if typeof(RGBColor) ~= "Color3" then return end

				data.Color = RGBColor
				local h, s, v = RGBColor:ToHSV()
				HSV[1], HSV[2], HSV[3] = h, s, v

				updatestuff()
			end

			if Owl.ConfigEnabled and data.Flag then
				Owl.Flags[data.Flag] = data
				if Owl.LoadedConfig and Owl.LoadedConfig[data.Flag] ~= nil then
					local saved = Owl.LoadedConfig[data.Flag]
					local unpacked = Owl:ColorUnpack(saved)
					if typeof(unpacked) == "Color3" then
						data:Set(unpacked, true)
					end
				end
			end



			data._frame = colorpicker
			data.toggle = function(self) colorpicker.Visible = not colorpicker.Visible end
			data.remove = function(self) colorpicker:Destroy() end

			return data

		end
		function initelement:Modal(ModalConfig)
			return Owl:Modal(ModalConfig)
		end

		function initelement:Dialog(ModalConfig)
			return Owl:Modal(ModalConfig)
		end

		function initelement:AddToggle(ToggleConfig)
			ToggleConfig = ToggleConfig or {}
			local flagName = ToggleConfig.Flag or ToggleConfig.Name or ToggleConfig.Title or "Toggle"
			local defVal = ToggleConfig.Default ~= nil and ToggleConfig.Default or (ToggleConfig.Value ~= nil and ToggleConfig.Value or false)

			if Owl.LoadedConfig and Owl.LoadedConfig[flagName] ~= nil then
				defVal = Owl.LoadedConfig[flagName]
			end

			local userCb = ToggleConfig.Callback or ToggleConfig.CallBack
			local data = self:Toggle({
				Title = ToggleConfig.Name or ToggleConfig.Title or "Toggle",
				Description = ToggleConfig.Description or ToggleConfig.Desc or "",
				Value = defVal,
				Flag = flagName,
				Save = ToggleConfig.Save ~= false,
				CallBack = function(v)
					if userCb then userCb(v) end
					SaveCfg(game and game.GameId)
				end
			})

			data.Type = "Toggle"
			data.Save = ToggleConfig.Save ~= false
			data.Flag = flagName
			data.Value = defVal
			Owl.Flags[flagName] = data
			return data
		end

		function initelement:AddSlider(SliderConfig)
			SliderConfig = SliderConfig or {}
			local flagName = SliderConfig.Flag or SliderConfig.Name or SliderConfig.Title or SliderConfig.ValueName or "Slider"
			local userCb = SliderConfig.Callback or SliderConfig.CallBack

			if Owl.LoadedConfig and Owl.LoadedConfig[flagName] ~= nil then
				SliderConfig.Default = Owl.LoadedConfig[flagName]
			end

			SliderConfig.Flag = flagName
			SliderConfig.Save = SliderConfig.Save ~= false
			local origCb = SliderConfig.Callback or SliderConfig.CallBack
			SliderConfig.Callback = function(val)
				if origCb then origCb(val) end
				SaveCfg(game and game.GameId)
			end

			local sliderObj = self:Slider(SliderConfig)
			sliderObj.Type = "Slider"
			sliderObj.Save = SliderConfig.Save ~= false
			sliderObj.Flag = flagName
			sliderObj.Value = SliderConfig.Default or SliderConfig.Min or 0
			Owl.Flags[flagName] = sliderObj
			return sliderObj
		end

		function initelement:AddDropdown(DropdownConfig)
			DropdownConfig = DropdownConfig or {}
			local flagName = DropdownConfig.Flag or DropdownConfig.Name or DropdownConfig.Title or "Dropdown"
			local userCb = DropdownConfig.Callback or DropdownConfig.CallBack

			if Owl.LoadedConfig and Owl.LoadedConfig[flagName] ~= nil then
				DropdownConfig.Default = Owl.LoadedConfig[flagName]
			end

			DropdownConfig.Flag = flagName
			DropdownConfig.Save = DropdownConfig.Save ~= false
			DropdownConfig.Callback = function(val)
				if userCb then userCb(val) end
				SaveCfg(game and game.GameId)
			end

			local dropObj = self:Dropdown(DropdownConfig)
			dropObj.Type = "Dropdown"
			dropObj.Save = DropdownConfig.Save ~= false
			dropObj.Flag = flagName
			dropObj.Value = DropdownConfig.Default
			Owl.Flags[flagName] = dropObj
			return dropObj
		end

		function initelement:AddButton(ButtonConfig)
			ButtonConfig = ButtonConfig or {}
			return self:Button({
				Title = ButtonConfig.Name or ButtonConfig.Title or "Button",
				Description = ButtonConfig.Description or ButtonConfig.Desc or "",
				Type = ButtonConfig.Type or "Default",
				HoldTime = ButtonConfig.HoldTime or 3,
				CallBack = ButtonConfig.Callback or ButtonConfig.CallBack
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
				Content = content
			})
		end

		function initelement:AddPbind(PBindConfig)
			PBindConfig = PBindConfig or {}
			local name = PBindConfig.Name or "Position"
			local flagName = PBindConfig.Flag or name
			local defX = tostring(PBindConfig.DefaultX or "")
			local defY = tostring(PBindConfig.DefaultY or "")
			local defZ = tostring(PBindConfig.DefaultZ or "")

			if Owl.LoadedConfig and Owl.LoadedConfig[flagName] ~= nil then
				local saved = Owl.LoadedConfig[flagName]
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
				_frame = pbindFrame
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
				lbl.TextColor3 = Owl.theme.Accent or Color3.fromRGB(255, 151, 227)
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
					if tb.Text ~= cleaned then tb.Text = cleaned end
				end)

				boxes[lblText] = tb
			end

			createCoordBox("X", defX, "ValueX")
			createCoordBox("Y", defY, "ValueY")
			createCoordBox("Z", defZ, "ValueZ")

			function pbindObj:Set(x, y, z)
				if x ~= nil and boxes.X then boxes.X.Text = tostring(x) pbindObj.ValueX = tostring(x) end
				if y ~= nil and boxes.Y then boxes.Y.Text = tostring(y) pbindObj.ValueY = tostring(y) end
				if z ~= nil and boxes.Z then boxes.Z.Text = tostring(z) pbindObj.ValueZ = tostring(z) end
				cb(pbindObj.ValueX, pbindObj.ValueY, pbindObj.ValueZ)
				SaveCfg(game and game.GameId)
			end

			function pbindObj:toggle()
				pbindFrame.Visible = not pbindFrame.Visible
			end

			function pbindObj:remove()
				pbindFrame:Destroy()
			end

			Owl.Flags[flagName] = pbindObj
			return pbindObj
		end

		function initelement:AddBind(BindConfig)
			BindConfig = BindConfig or {}
			local flagName = BindConfig.Flag or BindConfig.Name or BindConfig.Title or "Bind"
			local key = BindConfig.Default or BindConfig.Key or Enum.KeyCode.Unknown

			if Owl.LoadedConfig and Owl.LoadedConfig[flagName] ~= nil then
				local saved = Owl.LoadedConfig[flagName]
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

			local bindData = self:Keybind({
				Title = name,
				Key = key,
				Flag = flagName,
				Description = BindConfig.Description or "",
				Save = BindConfig.Save ~= false,
				OnKeyChanged = function(newKey)
					if bindObj then
						bindObj.Value = typeof(newKey) == "EnumItem" and newKey.Name or tostring(newKey)
						bindObj.Key = newKey
					end
					SaveCfg(game and game.GameId)
				end,
				CallBack = cb
			})

			local bindObj = {
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
					self.Value = typeof(newKey) == "EnumItem" and newKey.Name or tostring(newKey)
					self.Key = newKey
					SaveCfg(game and game.GameId)
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
				end
			}

			Owl.Flags[flagName] = bindObj
			return bindObj
		end

		function initelement:AddTextbox(TextboxConfig)
			TextboxConfig = TextboxConfig or {}
			local name = TextboxConfig.Name or TextboxConfig.Title or "Textbox"
			local flagName = TextboxConfig.Flag or name
			local def = TextboxConfig.Default ~= nil and tostring(TextboxConfig.Default) or ""

			if Owl.LoadedConfig and Owl.LoadedConfig[flagName] ~= nil then
				def = tostring(Owl.LoadedConfig[flagName])
			end

			local placeholder = TextboxConfig.BackGrountText or TextboxConfig.PlaceHolder or TextboxConfig.Placeholder or "Enter..."
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
				end
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
				end
			}

			Owl.Flags[flagName] = tbObj
			return tbObj
		end

		function initelement:AddColorpicker(ColorpickerConfig)
			ColorpickerConfig = ColorpickerConfig or {}
			local name = ColorpickerConfig.Name or ColorpickerConfig.Title or "Color Picker"
			local flagName = ColorpickerConfig.Flag or name
			local defColor = ColorpickerConfig.Default or ColorpickerConfig.Color or Color3.fromRGB(255, 255, 255)

			if Owl.LoadedConfig and Owl.LoadedConfig[flagName] ~= nil then
				local saved = Owl.LoadedConfig[flagName]
				defColor = UnpackColor(saved)
			end

			local cb = ColorpickerConfig.Callback or ColorpickerConfig.CallBack or function() end

			local pickerData = self:ColorPicker({
				Title = name,
				Color = defColor,
				Flag = flagName,
				Save = ColorpickerConfig.Save ~= false,
				CallBack = function(col)
					if cb then cb(col) end
					SaveCfg(game and game.GameId)
				end
			})
			pickerData.Type = "Colorpicker"
			pickerData.Save = ColorpickerConfig.Save ~= false
			pickerData.Flag = flagName
			pickerData.Value = defColor
			Owl.Flags[flagName] = pickerData
			return pickerData
		end

		function initelement:ColorLabel(Text, ToChangeColor, Position)
			local Label = pages.page.Label:Clone()
			Label.Visible = true
			Label.Parent = Page
			Label.text.Text = tostring(Text or "")
			Label:SetAttribute("Searchable", true)

			if ToChangeColor then
				Label.text.TextColor3 = ToChangeColor
			else
				Label.text.TextColor3 = Owl.theme.Accent or Color3.fromRGB(255, 151, 227)
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
					if newText then Label.text.Text = tostring(newText) end
					if newColor then Label.text.TextColor3 = newColor end
				end,
				toggle = function(self)
					Label.Visible = not Label.Visible
				end,
				remove = function(self)
					Label:Destroy()
			end
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
			end
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
			end
			}
			return secObj
		end

		function initelement:AddPlayerParagraph(userId)
			userId = userId or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.UserId) or 0
			local displayName = "Player"
			local username = "Player"

			pcall(function()
				local info = game:GetService("UserService"):GetUserInfosByUserIdsAsync({userId})
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
				toggle = function(self) para.Visible = not para.Visible end,
				remove = function(self) para:Destroy() end
			}
			return playerObj
		end

		function initelement:FreeMouseDrp()
			return self:AddDropdown({
				Name = "Unlock Mouse Mode",
				Options = {"ThirdPerson", "FreeMouse"},
				Default = Owl.UMouseMode or "ThirdPerson",
				Callback = function(Value)
					Owl.UMouseMode = Value
					if Owl.FreeMouse then
						Owl:UnlockMouse(false)
						task.wait(0.1)
						Owl:UnlockMouse(true)
					end
				end
			})
		end

		function initelement:AddUiBind()
			return self:AddBind({
				Name = "UI Keybind",
				Default = uitoggle or Enum.KeyCode.RightShift,
				Callback = function()
					if ToggleUI then ToggleUI() end
				end
			})
		end

		function initelement:AddPerformanceOverlay(Options)
			Options = Options or {}
			return self:AddToggle({
				Name = Options.Name or "Performance Overlay",
				Description = Options.Description or "Show FPS and ping in the top bar",
				Flag = Options.Flag or "owl_performance_overlay",
				Default = Options.Default == true,
				Save = Options.Save ~= false,
				Callback = function(enabled)
					Owl:SetPerformanceOverlay(enabled)
					if Options.Callback then
						Options.Callback(enabled)
					end
				end,
			})
		end

		function initelement:AddSmartTheme()
			self:AddColorpicker({
				Name = "Base Accent Color",
				Default = Owl.theme.Accent or Color3.fromRGB(255, 151, 227),
				Callback = function(Value)
					Owl:UpdateTheme({
						Accent = Value,
						HitBox = Value
					})
				end
			})

			self:AddButton({
				Name = "Reset Theme",
				Callback = function()
					Owl:UpdateTheme({
						Accent = Color3.fromRGB(255, 151, 227),
						HitBox = Color3.fromRGB(255, 151, 227)
					})
				end
			})

			self:AddPerformanceOverlay()
		end
		for _bn, _bf in pairs(initelement) do
			if type(_bf) == "function" then
				initelement[_bn] = Owl:Guard("Building a '" .. tostring(_bn) .. "' element", _bf)
			end
		end

		return initelement


	end
	Owl._currentWindow = tbdata
	return tbdata


end

pcall(function()
	if getgenv then
		getgenv().Owl = Owl
	end
	_G.Owl = Owl
end)

return Owl
