-- Made: By iceboy
--[[

.dP"Y8 Yb  dP 8888b.  888888 
`Ybo."  YbdP   8I  Yb 88__   
o.`Y8b   8P    8I  dY 88""   
8bodP'  dP    8888Y"  888888  v0

]]

local inputservice =	game:GetService("InsertService")
local tweenservice = 	game:GetService("TweenService")
local https = 			game:GetService("HttpService")
local runservice =		game:GetService("RunService")
local userinput =		game:GetService("UserInputService")
local players =         game:GetService("Players"):GetPlayers()
local textservice =     game:GetService('TextService')
local player =          game:GetService('Players')
local textservice =     game:GetService('TextService')
local coregui =         (gethui and gethui()) or game:GetService("CoreGui")

-- update check
local update = false
if update then
	local updategui = game:GetObjects("rbxassetid://122225389943465")[1]
	updategui.Parent = coregui

	local cord = '/GzumVvz3QM'

	task.wait(0.5)
	updategui.Enabled = true

	updategui.main.BackgroundTransparency = 1
	updategui.main.Size = UDim2.new(0, 150,0, 150)
	updategui.main.time.TextTransparency = 1
	updategui.main.info.TextTransparency = 1
	updategui.main.text.TextLabel.TextTransparency = 1
	updategui.main.text.more.TextTransparency = 1

	tweenservice:Create(updategui.main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
	tweenservice:Create(updategui.main, TweenInfo.new(0.75, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 350,0, 230)}):Play()

	task.wait(0.07)

	tweenservice:Create(updategui.main.time, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	tweenservice:Create(updategui.main.info, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.07)
	tweenservice:Create(updategui.main.text.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.07)
	tweenservice:Create(updategui.main.text.more, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

	local duration = 25
	local startTime = tick()

	local connection
	connection = runservice.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local remaining = math.max(duration - elapsed, 0)

		updategui.main.time.Text = "Destroying in " .. string.format("%.1f", remaining) .. " secs"

		if remaining <= 0 then
			connection:Disconnect()

			tweenservice:Create(updategui.main.text.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			task.wait(0.07)
			tweenservice:Create(updategui.main.text.more, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			task.wait(0.2)
			tweenservice:Create(updategui.main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			tweenservice:Create(updategui.main, TweenInfo.new(0.75, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 150,0, 130)}):Play()
			updategui.main.s2.Visible = false



			task.wait(0.07)

			tweenservice:Create(updategui.main.time, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			tweenservice:Create(updategui.main.info, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

			task.wait(0.75)
			updategui:Destroy()
		end
	end)

	updategui.main.s2.interact.MouseButton1Click:Connect(function()

		tweenservice:Create(updategui.main.s2.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Color = Color3.fromRGB(74, 255, 33)}):Play()
		tweenservice:Create(updategui.main.s2.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 0}):Play()
		task.wait(0.5)
		tweenservice:Create(updategui.main.s2.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Color = Color3.fromRGB(87, 101, 242)}):Play()
		tweenservice:Create(updategui.main.s2.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 0.5}):Play()
		setclipboard(cord)
	end)
end

if update then return end

local Library =         game:GetObjects("rbxassetid://123800669522471")[1]
local Loader =          game:GetObjects("rbxassetid://110221114597158")[1]

local resizing =        false
local screenSize =      workspace.CurrentCamera.ViewportSize
local isMobile =        userinput.TouchEnabled or (screenSize.X < 1024 and screenSize.Y < 768)
local dragOffset =        255
local dragOffsetMobile =  150
local camera =          workspace.CurrentCamera

Library.Enabled = false
Loader.Enabled = false

local loaded = false

local syde = {

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
	ConfigEnabled = false;
	ConfigFolder = 'UI';
	ConfigFile = 'Config';
	Flags = {};
	SettingsFlags = {};
	LoadedConfig = nil;
}

-- @Utilities

function syde:DeepMerge(target, source)
	for k, v in pairs(source) do
		if type(v) == "table" and type(target[k]) == "table" then
			self:DeepMerge(target[k], v) 
		else
			target[k] = v
		end
	end
end

function syde:SaveThemeConfig()
	if not writefile then return end
	local folder = self.ConfigFolder or "UI"
	if makefolder and isfolder and not isfolder(folder) then
		pcall(makefolder, folder)
	end
	local themeData = {
		Accent = self:ColorPack(self.theme.Accent),
		HitBox = self:ColorPack(self.theme.HitBox),
	}
	pcall(function()
		writefile(string.format("%s/_theme.json", folder), https:JSONEncode(themeData))
	end)
end

function syde:LoadThemeConfig()
	if not isfile then return end
	local folder = self.ConfigFolder or "UI"
	local path = string.format("%s/_theme.json", folder)
	if isfile(path) then
		local ok, content = pcall(readfile, path)
		if ok and content then
			local success, data = pcall(function() return https:JSONDecode(content) end)
			if success and type(data) == "table" then
				if data.Accent then
					local c = self:ColorUnpack(data.Accent)
					if typeof(c) == "Color3" then
						self.theme.Accent = c
					end
				end
				if data.HitBox then
					local c = self:ColorUnpack(data.HitBox)
					if typeof(c) == "Color3" then
						self.theme.HitBox = c
					end
				end
			end
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
		self:SaveThemeConfig()
		if SaveConfig then
			SaveConfig()
		end
	end
end

-- @ControllerSupport / numeric helpers

-- True if an input can be used as a bind (keyboard key OR controller button)
function syde:IsBindableInput(input)
	local t = input.UserInputType
	if t == Enum.UserInputType.Keyboard then
		return true
	end
	if string.find(tostring(t), "Gamepad", 1, true) then
		return input.KeyCode ~= Enum.KeyCode.Unknown
	end
	return false
end

-- Number of decimal places a number has (handles 0.01, 0.05, etc. correctly)
function syde:DecimalPlaces(num)
	local str = string.format("%.10f", tonumber(num) or 0)
	str = str:gsub("0+$", "")
	str = str:gsub("%.$", "")
	local dot = string.find(str, "%.", 1, true)
	if not dot then
		return 0
	end
	return #str - dot
end

-- Round a number to a fixed number of decimal places (removes float drift)
function syde:RoundTo(num, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Copy text to the clipboard across common executor globals. Returns true on success.
function syde:SetClipboard(text)
	local fn = setclipboard or toclipboard or set_clipboard or writeclipboard or (syn and syn.write_clipboard)
	if fn then
		return (pcall(fn, text))
	end
	return false
end

-- Connect a click handler whether the target is a GuiButton, has an "interact" child, or is a plain label.
function syde:OnClick(object, callback)
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

-- Brief green flash on a copy icon to confirm the copy worked.
function syde:FlashCopy(icon)
	if not icon then return end
	tweenservice:Create(icon, TweenInfo.new(0.12, Enum.EasingStyle.Quint), { ImageColor3 = Color3.fromRGB(120, 220, 120) }):Play()
	task.delay(0.4, function()
		tweenservice:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)
end

-- Branded error reporter: prints a "screenshot this" banner, the error, and a likely fix.
function syde:Report(context, err)
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
		fix = "This came from a callback (your own function), not Syde itself. Check the function attached to that element."
	else
		fix = "Unexpected error - send the screenshot above so it can be looked into."
	end

	warn(table.concat({
		"",
		"----------screenshot this and send it to king jericoo------",
		"[ UI ] " .. tostring(context or "Error"),
		"Problem: " .. message,
		"Fix: " .. fix,
		"------------------------------------------------------------",
		"",
	}, "\n"))
end

-- Wrap a function so any error it throws is reported via the banner (and swallowed).
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

-- Make a slider's value label clickable so the user can type an exact number.
-- Out-of-range or invalid input reverts to the previous value.
function syde:AttachSliderInput(Slider, Options)
	local valueLabel = Slider:FindFirstChild("v")
	if not valueLabel or valueLabel:FindFirstChild("ValueInput") then
		return
	end

	-- formatted "/max" suffix that stays visible while typing
	local function maxString()
		local dp = syde:DecimalPlaces(Options.Increment)
		return string.format("%." .. dp .. "f", tonumber(Options.Range[2]) or 0)
	end

	-- render the label as "<valueText>/<max>" (valueText shown verbatim)
	local function renderValue(valueText)
		valueLabel.Text = string.format("<font size='14'>%s</font><font color='#434343'>/%s</font>", valueText, maxString())
	end

	-- re-render the label with the slider's current value
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
				-- snap to the slider's increment and round away float drift
				typed = math.floor((typed - low) / inc + 0.5) * inc + low
				typed = syde:RoundTo(typed, syde:DecimalPlaces(inc))
				typed = math.clamp(typed, low, high)
			end
			Options:Set(typed)
		else
			-- typed nothing / invalid / out of range -> revert to the previous value
			renderCurrent()
		end
	end)

	return editBox
end

-- fractality

local RunService = game:GetService'RunService'
local camera = workspace.CurrentCamera


do
	local function IsNotNaN(x)
		return x == x
	end
	local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
	while not continue do
		RunService.RenderStepped:wait()
		continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
	end
end

local binds = {}
local root = Instance.new('Folder', camera)
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


--------------------------------
---- Module API --------------------------------
----------------------------------------------------------------


-- Create a part binding for a GuiObject.
function syde:BindFrame(frame, properties)
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
		-- the transparency inversion bug still surfaces when there's z-fighting
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

	binds[frame] = {
		uid = uid;
		parts = parts;
	}
	return binds[frame].parts
end

-- Applies the `properties` table to bound parts.
function syde:Modify(frame, properties)
	local parts = syde:GetBoundParts(frame)
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

-- Removes the part binding from a gui object if one exists.
function syde:UnbindFrame(frame)
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

-- Returns true if a part binding exists for the gui object.
function syde:HasBinding(frame)
	return binds[frame] ~= nil
end

-- Returns an array using this.
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

	-- Convert to RGB integer values
	return {
		R = math.round(color.R * 255),
		G = math.round(color.G * 255),
		B = math.round(color.B * 255)
	}
end

function syde:ColorUnpack(color)
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

function syde:AddConnection(Type, Callback)
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

	task.spawn(function()
		task.wait(10)
		for i = #syde.Connections, 1, -1 do
			if not syde.Connections[i].Connection.Connected then
				table.remove(syde.Connections, i)
			end
		end
	end)

	return Connection, Disconnect
end

--@@Bento

local Bento = {}
Bento.__index = Bento

-- create layout
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

-- NEW (optional)
function Bento:NewRow()
	local row = {}
	table.insert(self.Rows,row)
	return row
end


-- register frame
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

-- tween helper
function Bento:Tween(frame, goal)

	if self.ActiveTweens[frame] then
		self.ActiveTweens[frame]:Cancel()
	end

	local tween = tweenservice:Create(
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

-- calculate layout
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


	---------------------------------
	-- rows
	---------------------------------

	local sortedRows = {}

	-- if manual rows exist, use them
	if #self.Rows > 0 then

		for _,row in ipairs(self.Rows) do
			table.insert(sortedRows,{
				Items = row
			})
		end

	else
		-- fallback to original Y-based grouping

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



	---------------------------------
	-- detect stack mode
	---------------------------------

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



	---------------------------------
	-- STACK MODE
	---------------------------------

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



	---------------------------------
	-- NORMAL MODE
	---------------------------------

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



	-- bottom items stay at original positions
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

function syde:MakeResizable(Dragger, Object, MinSize, Callback, LockAspectRatio)
	assert(typeof(Dragger) == "Instance" and Dragger:IsA("GuiObject"), "[MakeResizable] Dragger must be a GuiObject")
	assert(typeof(Object) == "Instance" and Object:IsA("GuiObject"), "[MakeResizable] Object must be a GuiObject")
	assert(typeof(MinSize) == "Vector2", "[MakeResizable] MinSize must be a Vector2")
	assert(Callback == nil or typeof(Callback) == "function", "[MakeResizable] Callback must be a function or nil")

	local userInput = game:GetService("UserInputService")

	local startPosition, startSize = nil, nil
	local isResizing = false

	-- helper for both mouse and touch
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
			resizing = true
			startPosition = getInputPos(input)
			startSize = Object.AbsoluteSize
			tweenservice:Create(Library.main.resize, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 15,0, 15)}):Play()
			tweenservice:Create(Library.main.resize, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
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
			resizing = false
			startPosition, startSize = nil, nil
			tweenservice:Create(Library.main.resize, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 20,0, 20)}):Play()
			tweenservice:Create(Library.main.resize, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {ImageColor3 = Color3.fromRGB(53, 53, 53)}):Play()
		end
	end

	syde:AddConnection(Dragger.InputBegan, onInputBegan)
	syde:AddConnection(userInput.InputChanged, onInputChanged)
	syde:AddConnection(Dragger.InputEnded, onInputEnded)
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
		tweenInfo = tweenInfo
	}
end

function syde:resetToInitialState(animated, resetTweenInfo, targetObject)
	for object, tweenData in pairs(loadTweens) do
		if object and object.Parent and (not targetObject or object == targetObject or object:IsDescendantOf(targetObject)) then
			tweenData.tween:Cancel()

			if animated then
				local resetTween = tweenservice:Create(object, resetTweenInfo or TweenInfo.new(0.18), tweenData.initialState)
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
	syde:resetToInitialState(false, nil, targetObject)

	for object, tweenData in pairs(loadTweens) do
		if object and object.Parent then
			if not targetObject or object == targetObject or object:IsDescendantOf(targetObject) then
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

function syde:WiggleText(label)
	if not label or not label:IsA("TextLabel") then return end
	if not label.Text or label.Text == "" then return end

	-- Remove old animation
	if label:FindFirstChild("WiggleContainer") then
		label.WiggleContainer:Destroy()
	end

	local container = Instance.new("Folder")
	container.Name = "WiggleContainer"
	container.Parent = label

	-- Hide original label text
	label.TextTransparency = 1

	local baseText = label.Text:gsub("<.->", "") -- remove RichText tags
	local fontFace = label.FontFace
	local baseSize = label.TextSize
	local textColor = label.TextColor3

	local chars = {}
	local xOffset = 0

	-- Create a label for each character
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

	-- Animate characters
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


function syde:StopWiggle(label)
	for i, data in ipairs(self.Connections) do
		if data.label == label then
			data.conn:Disconnect()
			table.remove(self.Connections, i)
			break
		end
	end
end



function syde:updateLayout(container, spacing)
	spacing = spacing or 5
	local yOffset = 0
	local containerWidth = container.AbsoluteSize.X 

	for _, v in ipairs(container:GetChildren()) do
		if v:IsA('UIListLayout') then
			v:Destroy()
		end
	end

	if resizing == false then
		for _, child in ipairs(container:GetChildren()) do
			if (child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("TextLabel") or child:IsA("TextButton")) and child.Visible then
				--child.Size = UDim2.new(1, -10, 0, child.Size.Y.Offset) -- Full width, fixed height
				-- child.Position = UDim2.new(0, 0, 0, yOffset)
				tweenservice:Create(child, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 0, 0, yOffset)}):Play()
				yOffset = yOffset + child.AbsoluteSize.Y + spacing
			end
		end
	end


	container.CanvasSize = UDim2.new(0, 0, 0, yOffset)
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

		-- Calculate the absolute position based on newPos
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
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

	-- listen globally so a fast drag that leaves the handle still releases
	syde:AddConnection(userInput.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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


--@Loader
do

	function syde:Load(Config)
		task.wait(0.02)
		local LOADER = Loader
		LOADER.Enabled = true
		LOADER.Parent = coregui

		-- PreLoad
		Config.Name = Config.Name or 'UI'
		Config.Logo = Config.Logo or ''
		Config.ConfigFolder = Config.ConfigFolder or 'UI'
		Config.Status = Config.Status or false

		-- Auto-load saved theme if exists
		syde:LoadThemeConfig()

		Config.Accent = Config.Accent or syde.theme.Accent
		Config.HitBox = Config.HitBox or syde.theme.HitBox

		LOADER.loader.profile.Title.TextTransparency = 1
		LOADER.loader.profile.ImageTransparency = 1
		LOADER.loader.profile.Title.Text = Config.Name
		--	LOADER.load.logo.stroke.UIStroke.Transparency = 1

		local formattedLogo = ""
		if Config.Logo and Config.Logo ~= "" and Config.Logo ~= "0" then
			formattedLogo = tostring(Config.Logo)
			if not formattedLogo:find("rbxassetid://") and not formattedLogo:find("http") then
				formattedLogo = "rbxassetid://" .. formattedLogo
			end
		end

		local LoaderConfig = {
			Name = Config.Name;
			Logo = formattedLogo;
			ConfigFolder = Config.ConfigFolder;
			Status = Config.Status;
			Accent = Config.Accent or syde.theme.Accent;
			Hitbox = Config.HitBox or syde.theme.HitBox;
			Socials = {}
		}

		if LoaderConfig.Status == false then
			--	LOADER.load.logo.stroke.UIStroke.Color = Color3.fromRGB(24, 24, 24)
			LOADER.loader.profile.Title.Text = LoaderConfig.Name
		end

		local statusColors = {
			Stable = { Color = Color3.fromRGB(25, 229, 22), Text = '<font color="#24bf48">Stable</font>' },
			Unstable = { Color = Color3.fromRGB(227, 229, 81), Text = '<font color="#e3e551">Unstable</font>' },
			Detected = { Color = Color3.fromRGB(229, 44, 47), Text = '<font color="#e52c2f">Detected</font>' },
			Patched = { Color = Color3.fromRGB(229, 229, 229), Text = '<font color="#e52c2f">Patched</font>' }
		}

		local statusData = statusColors[LoaderConfig.Status]
		if statusData then
			LOADER.loader.profile.status.BackgroundColor3 = statusData.Color
			--	LOADER.load.logo["Title/Status"].Text = string.format('%s  <font color="#363636">•</font>  %s', LoaderConfig.Name, statusData.Text)
		end

		if LoaderConfig.Logo ~= "" then
			LOADER.loader.profile.Image = LoaderConfig.Logo
			LOADER.loader.ImageLabel.Image = LoaderConfig.Logo
			LOADER.loader.profile.Visible = true
		else
			LOADER.loader.profile.Image = ""
			LOADER.loader.ImageLabel.Image = ""
			LOADER.loader.profile.Visible = false
		end
		--	LOADER.load.info.build.Text = syde.Build

		local ti = TweenInfo.new(0.2, Enum.EasingStyle.Exponential)

		task.spawn(function()
			while LOADER and LOADER.Parent do
				task.wait()

				local loaderFrame = LOADER:FindFirstChild("loader")
				if not loaderFrame then break end

				local dots = loaderFrame:FindFirstChild("dots")
				if not dots then break end

				local function resetDots()
					for _, v in ipairs(dots:GetChildren()) do
						if v:IsA("Frame") then
							tweenservice:Create(v, ti, {BackgroundTransparency = 0.6}):Play()
						end
					end
				end

				-- 1

				if dots:FindFirstChild("dot1") then
					tweenservice:Create(dots.dot1, ti, {BackgroundTransparency = 0}):Play()
				end
				task.wait(0.5)
				resetDots()


				-- 2
				if dots:FindFirstChild("dot3") then
					tweenservice:Create(dots.dot3, ti, {BackgroundTransparency = 0}):Play()
				end
				task.wait(0.5)
				resetDots()


				-- 3
				if dots:FindFirstChild("dot2") then
					tweenservice:Create(dots.dot2, ti, {BackgroundTransparency = 0}):Play()
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
				BackGroundColor = Color3.fromRGB(39, 39, 39);
				--	GradColor = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(129, 129, 129))};
				StrokeColor = Color3.fromRGB(39, 39, 39);
				Icon = 'rbxassetid://112129825794851'
			},
			Discord = {
				BackGroundColor = Color3.fromRGB(88, 141, 255);
				--	GradColor = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(91, 125, 147))};
				StrokeColor = Color3.fromRGB(88, 141, 255);
				Icon = 'rbxassetid://113723018301753'
			},
			Site = {
				BackGroundColor = Color3.fromRGB(242, 83, 112);
				--	GradColor = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(181, 33, 255))};
				StrokeColor = Color3.fromRGB(242, 83, 112);
				Icon = 'rbxassetid://127485237503891'
			}
		}

		local logo = LOADER.loader.profile
		--	local sl = logo.sl
		--	local strokeGradient = logo.stroke.UIStroke.UIGradient

		local loadedsocial = false

		local Socials = Config.Socials or {}
		local maxSocials = 3
		local count = 0


		local SocialTemplate = LOADER.loader.profile.socials.s1

		for platform, value in pairs(Socials) do
			if count >= maxSocials then break end
			if not Styles[platform] then continue end
			if not SocialTemplate then break end

			count += 1

			local clone = SocialTemplate:Clone()
			clone.Visible = true
			clone.Name = platform .. "_Social"
			clone.Parent = SocialTemplate.Parent

			-- Positioning (stack horizontally)
			--	clone.Position = UDim2.new(0, (count - 1) * 110, 1, -40)

			-- Apply Style
			clone.BackgroundColor3 = Styles[platform].BackGroundColor
			clone.ImageLabel.Image = Styles[platform].Icon

			if clone.Frame:FindFirstChild("UIStroke") then
				clone.Frame.UIStroke.Color = Styles[platform].StrokeColor
			end

			-- Set Text (change if your text label has different name)
			if clone:FindFirstChild("Title") then
				clone.Title.Text = value
			end

			clone.interact.MouseButton1Click:Connect(function()
				if value ~= '' then
					tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Color = Color3.fromRGB(74, 255, 33)}):Play()
					tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 0}):Play()
					task.wait(0.5)
					tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Color = Styles[platform].BackGroundColor}):Play()
					tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 0.5}):Play()
				else
					tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Color = Color3.fromRGB(255, 41, 45)}):Play()
					tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 0}):Play()
					task.wait(0.5)
					tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Color = Styles[platform].BackGroundColor}):Play()
					tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 0.5}):Play()
				end

				setclipboard(value)
			end)

			clone.MouseEnter:Connect(function()
				tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 0.5}):Play()
			end)
			clone.MouseLeave:Connect(function()
				tweenservice:Create(clone.Frame.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Transparency = 0}):Play()
			end)

			loadedsocial = true
		end

		tweenservice:Create(logo, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		tweenservice:Create(logo.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
		task.wait(0.04)


		--	local function initLoader()
		--	tweenservice:Create( LOADER.load.Salt, TweenInfo.new(0.65, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 25,0, 25)}):Play()
		--	tweenservice:Create( LOADER.load.Salt, TweenInfo.new(0.65, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
		--	end

		local function TweenWorkLabel(Finish, icon, Text)
			LOADER.loader.work.Position = UDim2.new(0.5, 0,1, -40)
			LOADER.loader.work.Text = Text
			LOADER.loader.work.ImageLabel.Image = icon
			tweenservice:Create( LOADER.loader.work, TweenInfo.new(0.08, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
			tweenservice:Create( LOADER.loader.work.ImageLabel, TweenInfo.new(0.08, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()
			tweenservice:Create( LOADER.loader.work, TweenInfo.new(0.1, Enum.EasingStyle.Quint), { Position = UDim2.new(0.5, 0,1, -73) }):Play()
			task.wait(0.05)
			tweenservice:Create(LOADER.loader.work, TweenInfo.new(0.08, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
			tweenservice:Create( LOADER.loader.work.ImageLabel, TweenInfo.new(0.08, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
			tweenservice:Create( LOADER.loader.work, TweenInfo.new(0.1, Enum.EasingStyle.Quint), { Position = UDim2.new(0.5, 0,1, -100) }):Play()
			task.wait(0.02)
		end

		local function load()
			TweenWorkLabel(0.4,'rbxassetid://136002400178503', '')

			if Config.ConfigurationSaving and Config.ConfigurationSaving.Enabled then
				local folderName = Config.ConfigurationSaving.FolderName or "UI_Configs"
				local fileName = Config.ConfigurationSaving.FileName or "default_config"

				syde.ConfigEnabled = true
				syde.ConfigFolder = folderName
				syde.ConfigFile = fileName

				if isfolder and not isfolder(folderName) then
					local success, err = pcall(function()
						makefolder(folderName)
					end)
					if not success then
						warn("[SYDE] Failed to create folder:", err)
					end
				end

				-- Only preload the saved config if AutoLoad was explicitly enabled
				local autoloadPath = string.format("%s/_autoload.txt", folderName)
				local autoload = false
				if isfile and isfile(autoloadPath) then
					local ok, content = pcall(readfile, autoloadPath)
					if ok and content then
						autoload = tostring(content):match("^%s*(.-)%s*$") == "1"
					end
				end

				if autoload then
					local configPath = string.format("%s/%s.json", folderName, fileName)
					if isfile and isfile(configPath) then
						local ok, content = pcall(readfile, configPath)
						if ok and content then
							local decodeOk, decoded = pcall(function() return https:JSONDecode(content) end)
							if decodeOk and type(decoded) == "table" then
								syde.LoadedConfig = decoded
							end
						end
					end
				end
			end


			TweenWorkLabel(0.4,'rbxassetid://105810189969774', '')

			local UI_TAG = "UILoader"
			local MARKER_NAME = "SYDEUIDetector"
			local INTERNAL_UUID = ("SYDE-" .. tostring(game.JobId):gsub("-", "") .. tostring(tick())):gsub("%.", "")
			local PROTECTION_EVENT = Instance.new("BindableEvent")
			local HttpService = game:GetService("HttpService")


			-- Cleanup old UI 
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

			-- Load the Library
			local successLibrary, Library = pcall(function()
				return Library -- Replace with actual GetObjects if needed
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

			-- Ensure Library stays in CoreGui
			task.spawn(function()
				while Library and Library.Parent do
					task.wait(1)
					if Library.Parent ~= coregui then
						warn("[UI] UI moved. Restoring...")
						pcall(function()
							Library.Parent = coregui
						end)
					end
				end
			end)

			TweenWorkLabel(0.4,'rbxassetid://108012241529487', '')


			if Config.AutoJoinDiscord and Config.AutoJoinDiscord.Enabled then
				local discordConfig = Config.AutoJoinDiscord
				local rootFolder = Config.ConfigurationSaving and Config.ConfigurationSaving.FolderName or "UI_Configs"
				local discordFolder = rootFolder .. "/DiscordInvites"
				local inviteCode = discordConfig.Invite
				local inviteFilePath = discordFolder .. "/" .. inviteCode .. ".txt"

				-- Ensure folder exists
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
									["Origin"] = "https://discord.com"
								},
								Body = https:JSONEncode({
									cmd = "INVITE_BROWSER",
									nonce = https:GenerateGUID(false),
									args = {
										code = inviteCode
									}
								})
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
							writefile(inviteFilePath, "Joined Discord via invite '" .. inviteCode .. "' at " .. os.date())
						end)

						if writeSuccess then
						else
							warn("[SYDE] Failed to write join log for invite:", writeErr)
						end
					end
				end
			end

			TweenWorkLabel(0.05,'rbxassetid://136405833725573', '')
			task.wait(0.03)
			loaded = true
		end

		task.wait(0.02)
		load()

		task.wait(0.05)

		syde.theme.Accent = Config.Accent;
		syde.theme.HitBox = Config.HitBox;
		LOADER:Destroy()

	end

end

local HttpService = https
local CONFIG_VERSION = 1

local SaveDebounce
local SAVE_DELAY = 0.2

local function SafeDecode(data)
	local success, result = pcall(function()
		return HttpService:JSONDecode(data)
	end)
	return success and result or nil
end

local function ApplyFlag(Flag, Value)
	if Value == nil then return false end

	-- ColorPicker Handling
	if Flag.Type == "ColorPicker" then
		local unpacked = syde:ColorUnpack(Value)

		if Flag.Set then
			Flag:Set(unpacked, true)
		elseif Flag.Color then
			Flag.Color = unpacked
		end

		return true
	end

	-- Keybind Handling
	if Flag.Type == "Keybind" or Flag.SetKeybind then
		if Flag.SetKeybind then
			Flag:SetKeybind(Value, true)
			return true
		elseif Flag.Set then
			Flag:Set(Value, true)
			return true
		end
	end

	-- Standard Setter
	if Flag.Set then
		Flag:Set(Value, true)
		return true
	end

	-- Raw Value fallback
	if Flag.V ~= nil then
		Flag.V = Value
		return true
	end

	if Flag.StarterValue ~= nil then
		Flag.StarterValue = Value
		return true
	end

	warn("[UI] Unsupported flag type for:", Flag)
	return false
end

function LoadConfig(Configuration)
	if type(Configuration) ~= "string" then
		warn("[UI] Invalid config format.")
		return false, 0
	end

	local Decoded = SafeDecode(Configuration)
	if not Decoded then
		warn("[UI] Failed to decode config.")
		return false, 0
	end

	-- Cache so flags registered later can still apply their saved values
	syde.LoadedConfig = Decoded

	-- Theme auto-restore from config
	if Decoded._theme and type(Decoded._theme) == "table" then
		if Decoded._theme.Accent then
			local c = syde:ColorUnpack(Decoded._theme.Accent)
			if typeof(c) == "Color3" then
				syde:UpdateTheme({ Accent = c })
			end
		end
		if Decoded._theme.HitBox then
			local c = syde:ColorUnpack(Decoded._theme.HitBox)
			if typeof(c) == "Color3" then
				syde:UpdateTheme({ HitBox = c })
			end
		end
	end

	-- Version check (future ready)
	if Decoded._version and Decoded._version ~= CONFIG_VERSION then
		warn("[UI] Config version mismatch.")
	end

	local applied = 0

	-- Suppress per-element notifications fired by callbacks during the bulk apply
	syde.SuppressNotify = true
	for FlagName, Flag in pairs(syde.Flags) do
		local SavedValue = Decoded[FlagName]

		if SavedValue ~= nil then
			-- Isolate each flag so a single bad one doesn't break the whole load
			local ok, success = pcall(ApplyFlag, Flag, SavedValue)
			if ok and success then
				applied = applied + 1
			elseif not ok then
				warn("[UI] Failed to apply flag '" .. tostring(FlagName) .. "':", success)
			end
		end
	end
	syde.SuppressNotify = false

	return true, applied
end

-- Apply a cached saved value to a flag, if one exists
function syde:ApplyCachedFlag(Flag)
	if not Flag or not Flag.Flag then return end
	if not self.LoadedConfig then return end
	local saved = self.LoadedConfig[Flag.Flag]
	if saved == nil then return end
	ApplyFlag(Flag, saved)
end

-- Internal Save Logic
local function PerformSave()
	if not syde.ConfigEnabled then return end
	if not writefile then return end

	local Data = {
		_version = CONFIG_VERSION,
		_theme = {
			Accent = syde:ColorPack(syde.theme.Accent),
			HitBox = syde:ColorPack(syde.theme.HitBox),
		}
	}

	for FlagName, Flag in pairs(syde.Flags) do
		if Flag.Type == "ColorPicker" then
			if Flag.Color then
				Data[FlagName] = syde:ColorPack(Flag.Color)
			end
		elseif Flag.Type == "Keybind" or Flag.Key ~= nil then
			Data[FlagName] = Flag.Key and Flag.Key.Name or "NONE"
		elseif Flag.V ~= nil then
			Data[FlagName] = Flag.V
		elseif Flag.Value ~= nil then
			Data[FlagName] = Flag.Value
		elseif Flag.Color then
			Data[FlagName] = syde:ColorPack(Flag.Color)
		elseif Flag.StarterValue ~= nil then
			Data[FlagName] = Flag.StarterValue
		end
	end

	-- Ensure folder exists
	if makefolder and not isfolder(syde.ConfigFolder) then
		makefolder(syde.ConfigFolder)
	end

	local path = string.format("%s/%s.json", syde.ConfigFolder, syde.ConfigFile)

	local success, err = pcall(function()
		writefile(path, HttpService:JSONEncode(Data))
	end)

	if not success then
		warn("[UI] Failed to save config:", err)
	end
end

-- Public Save (Debounced)
function SaveConfig()
	if SaveDebounce then
		task.cancel(SaveDebounce)
	end

	SaveDebounce = task.delay(SAVE_DELAY, PerformSave)
end

function syde:LoadSaveConfig(targetFile)
	if not syde.ConfigEnabled then
		if syde.Toast then syde:Toast({ Content = 'Configs disabled in syde:Load', Duration = 3 }) end
		return false
	end

	local fileName = targetFile or syde.ConfigFile
	local filePath = string.format("%s/%s.json", syde.ConfigFolder, fileName)

	if not isfile or not isfile(filePath) then
		if syde.Toast then
			syde:Toast({ Content = 'No save file found at ' .. filePath, Duration = 3 })
		end
		return false
	end

	local ok, decoded, applied = pcall(function()
		return LoadConfig(readfile(filePath))
	end)

	if ok and decoded then
		if targetFile then
			syde.ConfigFile = targetFile
		end
		if syde.Toast then
			syde:Toast({ Content = 'loaded your sorry ass config', Duration = 3 })
		end
		return true
	end

	warn("[SYDE] Configurations Error " .. tostring(decoded))
	if syde.Toast then
		syde:Toast({ Content = 'Failed to load config', Duration = 3 })
	end
	return false
end

function syde:ListConfigs()
	local list = {}
	if not syde.ConfigEnabled then return list end
	if not listfiles or not isfolder or not isfolder(syde.ConfigFolder) then return list end

	local ok, files = pcall(listfiles, syde.ConfigFolder)
	if not ok or type(files) ~= "table" then return list end

	for _, full in ipairs(files) do
		local name = tostring(full):match("([^/\\]+)%.json$")
		if name and name ~= "SettingsConfig" then
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

function syde:SaveConfigAs(name)
	if not syde.ConfigEnabled then
		if syde.Toast then syde:Toast({ Content = 'Configs disabled in syde:Load', Duration = 3 }) end
		return false
	end
	if type(name) ~= "string" or name == "" then return false end
	if not writefile then
		if syde.Toast then syde:Toast({ Content = 'Executor has no writefile', Duration = 3 }) end
		return false
	end

	local Data = {
		_version = CONFIG_VERSION,
		_theme = {
			Accent = syde:ColorPack(syde.theme.Accent),
			HitBox = syde:ColorPack(syde.theme.HitBox),
		}
	}
	local count = 0
	for FlagName, Flag in pairs(syde.Flags) do
		if Flag.Type == "ColorPicker" then
			if Flag.Color then
				Data[FlagName] = syde:ColorPack(Flag.Color)
				count = count + 1
			end
		elseif Flag.Type == "Keybind" or Flag.Key ~= nil then
			Data[FlagName] = Flag.Key and Flag.Key.Name or "NONE"
			count = count + 1
		elseif Flag.V ~= nil then
			Data[FlagName] = Flag.V
			count = count + 1
		elseif Flag.Value ~= nil then
			Data[FlagName] = Flag.Value
			count = count + 1
		elseif Flag.Color then
			Data[FlagName] = syde:ColorPack(Flag.Color)
			count = count + 1
		elseif Flag.StarterValue ~= nil then
			Data[FlagName] = Flag.StarterValue
			count = count + 1
		end
	end

	if makefolder and isfolder and not isfolder(syde.ConfigFolder) then
		makefolder(syde.ConfigFolder)
	end

	local ok, err = pcall(function()
		writefile(string.format("%s/%s.json", syde.ConfigFolder, name), HttpService:JSONEncode(Data))
	end)

	if ok then
		syde.ConfigFile = name
		if syde.Toast then
			syde:Toast({ Content = 'saved your sorry ass config', Duration = 3 })
		end
		return true
	else
		warn("[SYDE] Save failed:", err)
		if syde.Toast then
			syde:Toast({ Content = 'Save failed: ' .. tostring(err), Duration = 3 })
		end
	end
	return false
end

function syde:DeleteConfig(name)
	if not syde.ConfigEnabled then return false end
	if type(name) ~= "string" or name == "" then return false end
	local filePath = string.format("%s/%s.json", syde.ConfigFolder, name)
	if isfile and isfile(filePath) and delfile then
		return pcall(delfile, filePath)
	end
	return false
end

local function autoloadFilePath()
	return string.format("%s/_autoload.txt", syde.ConfigFolder)
end

function syde:GetAutoLoad()
	-- Default OFF unless the user explicitly enables it
	if not syde.ConfigEnabled or not isfile then return false end
	local path = autoloadFilePath()
	if not isfile(path) then return false end
	local ok, content = pcall(readfile, path)
	if not ok or not content then return false end
	return tostring(content):match("^%s*(.-)%s*$") == "1"
end

function syde:SetAutoLoad(enabled)
	if not syde.ConfigEnabled or not writefile then return false end
	if makefolder and isfolder and not isfolder(syde.ConfigFolder) then
		makefolder(syde.ConfigFolder)
	end
	local ok = pcall(writefile, autoloadFilePath(), enabled and "1" or "0")
	return ok
end


--@UiSetup
local ui = Library
local window = ui.main
local top = window.top
local tabs = window.tabs.tab
local pages = window.pages

--

local Connected = false
local settingsOpen = false
local pluginsOpen = false
local uiclosed = false
local userinfodisabled = false
local intro = false
local bluron = false
local glow = false

local uitoggle = Enum.KeyCode.RightShift
--

function applyLayout(isMobile)
	--	Library.lib.Size = isMobile and UDim2.new(0, 543,0, 321) or UDim2.new(0, 715, 0, 575)
	tweenservice:Create(Library.main, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = isMobile and UDim2.new(0, 543,0, 321) or UDim2.new(0, 715, 0, 575)}):Play()
	local shadow = window:FindFirstChild("Shadow")
	if shadow then
		shadow.Visible = not isMobile 
	end
end


local function updateLayout()
	local screenSize = camera.ViewportSize
	local mobile = userinput.TouchEnabled
	applyLayout(mobile)
end

--@@Notification
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
	if syde.SuppressNotify then return end
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



		local Notification = Library.Notification.Default:Clone()
		Notification.Visible = true
		Notification.Parent = Library.Notification
		Notification.Title.Text = NotifData.Title
		Notification.Content.Text = NotifData.Content
		Notification.Content.Size = UDim2.new(0, 200,0, Notification.Content.TextBounds.Y )
		Notification.icon.Image = 'rbxassetid://'..NotifData.Icon
		Notification.icon.Visible = true



		local function CloseNotif()

			if Notification and Notification.Parent then
				table.remove(notifications, table.find(notifications, Notification))
				tweenservice:Create(Notification.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Scale = 0.9}):Play()
				tweenservice:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.95}):Play()
				tweenservice:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.75}):Play()
				--	tweenservice:Create(Notification.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.5}):Play()
				tweenservice:Create(Notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.78}):Play()

				task.wait(0.15)

				tweenservice:Create(Notification, TweenInfo.new(0.95, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, Notification.Position.X.Offset + 400, 0, Notification.Position.Y.Offset) }):Play()
				task.wait(0.4)
				Notification:Destroy()
				updatePositions()
			end

		end

		if NotifData.Animation == 'Wiggle' then
			syde:WiggleText(Notification.Title)
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

		--	Notification.UIScale.Scale = 0.9
		Notification.close.ImageTransparency = 0.95
		Notification.BackgroundTransparency = 0.75
		--	Notification.Title.TextTransparency = 0.5
		Notification.Content.TextTransparency = 0.78

		Notification.Position = UDim2.new(0, 600, 0, 637)



		task.wait(0.45)

		if NotifData.Icon ~= '' then
			tweenservice:Create(Notification.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 40,0, 10)}):Play()
			task.wait(0.035)
			tweenservice:Create(Notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 40,0, 30)}):Play()

			tweenservice:Create(Notification.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		end


		tweenservice:Create(Notification.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Scale = 1}):Play()
		tweenservice:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.75}):Play()
		tweenservice:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
		--	tweenservice:Create(Notification.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
		tweenservice:Create(Notification.Content, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

		Notification.close.MouseEnter:Connect(function()
			tweenservice:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.25}):Play()
		end)

		Notification.close.MouseLeave:Connect(function()
			tweenservice:Create(Notification.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.75}):Play()
		end)

		Notification.close.MouseButton1Click:Connect(function()
			CloseNotif()
		end)

		task.delay(NotifData.Duration, function()
			CloseNotif()
		end)
	end)
end


--@@Modal
local activeModals = 0 -- track how many modals are currently open

function syde:Modal(Modal)
	task.spawn(function()
		local ModalData = {
			Title = Modal.Title or "Notice";
			Content = Modal.Content or "";
			ConfirmCallBack = Modal.ConfimCallBack or Modal.ConfirmCallBack or Modal.ConfirmCallback or Modal.Callback;
			CancelCallBack = Modal.CancelCallBack or Modal.CancelCallback;
		}

		if not ui or not ui:FindFirstChild("main") or not ui.main:FindFirstChild("modal") then
			syde:MakeNotification({
				Name = ModalData.Title,
				Content = ModalData.Content,
				Time = 5
			})
			if typeof(ModalData.ConfirmCallBack) == "function" then
				pcall(ModalData.ConfirmCallBack)
			end
			return
		end

		local ModalInstance = ui.main.modal:Clone()
		ModalInstance.Visible = true
		ModalInstance.Parent = ui.main
		if ModalInstance:FindFirstChild("Title") then
			ModalInstance.Title.Text = ModalData.Title
			ModalInstance.Title.TextTransparency = 1
		end
		if ModalInstance:FindFirstChild("Content") then
			ModalInstance.Content.Text = ModalData.Content
			ModalInstance.Content.TextTransparency = 1
		end
		ModalInstance.Size = UDim2.new(0, 350, 0, 144)
		ModalInstance.BackgroundTransparency = 1

		local confirmBtn = ModalInstance:FindFirstChild("Buttons") and ModalInstance.Buttons:FindFirstChild("Confirm")
		local cancelBtn = ModalInstance:FindFirstChild("Buttons") and ModalInstance.Buttons:FindFirstChild("Cancel")

		if confirmBtn then
			confirmBtn.BackgroundTransparency = 1
			if confirmBtn:FindFirstChild("TextLabel") then
				confirmBtn.TextLabel.TextTransparency = 1
			end
		end

		if cancelBtn then
			cancelBtn.BackgroundTransparency = 1
			if cancelBtn:FindFirstChild("TextLabel") then
				cancelBtn.TextLabel.TextTransparency = 1
			end
			if cancelBtn:FindFirstChild("UIStroke") then
				cancelBtn.UIStroke.Transparency = 1
			end
		end

		local isClosing = false
		local function closeModal()
			if isClosing then return end
			isClosing = true
			activeModals = math.max(0, activeModals - 1)

			pcall(function()
				if cancelBtn then cancelBtn.Interactable = false end
				if confirmBtn then confirmBtn.Interactable = false end
			end)

			tweenservice:Create(ModalInstance, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 350, 0, 147), BackgroundTransparency = 1}):Play()
			pcall(function()
				if ModalInstance:FindFirstChild("Title") then
					tweenservice:Create(ModalInstance.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				end
				if ModalInstance:FindFirstChild("UIStroke") then
					tweenservice:Create(ModalInstance.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
				end
				if ModalInstance:FindFirstChild("Content") then
					tweenservice:Create(ModalInstance.Content, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				end
				if confirmBtn then
					tweenservice:Create(confirmBtn, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					if confirmBtn:FindFirstChild("TextLabel") then
						tweenservice:Create(confirmBtn.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					end
				end
				if cancelBtn then
					tweenservice:Create(cancelBtn, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					if cancelBtn:FindFirstChild("TextLabel") then
						tweenservice:Create(cancelBtn.TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					end
					if cancelBtn:FindFirstChild("UIStroke") then
						tweenservice:Create(cancelBtn.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					end
				end
			end)

			if activeModals == 0 and ui and ui:FindFirstChild("main") and ui.main:FindFirstChild("dim") then
				tweenservice:Create(ui.main.dim, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
					BackgroundTransparency = 1
				}):Play()
				task.delay(0.35, function()
					if activeModals == 0 and ui and ui:FindFirstChild("main") and ui.main:FindFirstChild("dim") then
						ui.main.dim.Visible = false
						ui.main.dim.Active = false
					end
				end)
			end

			task.delay(0.4, function()
				pcall(function() ModalInstance:Destroy() end)
			end)
		end

		local function openModal()
			activeModals += 1
			pcall(function()
				if ModalInstance:FindFirstChild("Content") then
					tweenservice:Create(ModalInstance.Content, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(1, ModalInstance.Content.Size.X.Offset, 1, ModalInstance.Content.TextBounds.Y)}):Play()
					tweenservice:Create(ModalInstance, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 350, 0, math.max(144, ModalInstance.Content.TextBounds.Y + 130))}):Play()
				end
				tweenservice:Create(ModalInstance, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				if ModalInstance:FindFirstChild("UIStroke") then
					tweenservice:Create(ModalInstance.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end
				if ModalInstance:FindFirstChild("Title") then
					tweenservice:Create(ModalInstance.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				end
				if ModalInstance:FindFirstChild("Content") then
					tweenservice:Create(ModalInstance.Content, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				end
				if confirmBtn then
					tweenservice:Create(confirmBtn, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5}):Play()
					if confirmBtn:FindFirstChild("TextLabel") then
						tweenservice:Create(confirmBtn.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
					end
				end
				if cancelBtn then
					tweenservice:Create(cancelBtn, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					if cancelBtn:FindFirstChild("TextLabel") then
						tweenservice:Create(cancelBtn.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
					end
					if cancelBtn:FindFirstChild("UIStroke") then
						tweenservice:Create(cancelBtn.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
					end
				end
			end)
		end
		openModal()

		if ui.main:FindFirstChild("dim") then
			ui.main.dim.Visible = true
			ui.main.dim.Active = true
			tweenservice:Create(ui.main.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				BackgroundTransparency = 0.3
			}):Play()
		end

		local function bindButton(btnObj, action)
			if not btnObj then return end
			local function fire()
				action()
				closeModal()
			end
			if btnObj:IsA("GuiButton") then
				btnObj.MouseButton1Click:Connect(fire)
				pcall(function() btnObj.Activated:Connect(fire) end)
			end
			local interact = btnObj:FindFirstChild("interact")
			if interact and interact:IsA("GuiButton") then
				interact.MouseButton1Click:Connect(fire)
				pcall(function() interact.Activated:Connect(fire) end)
			end
			for _, desc in ipairs(btnObj:GetDescendants()) do
				if desc:IsA("GuiButton") then
					desc.MouseButton1Click:Connect(fire)
					pcall(function() desc.Activated:Connect(fire) end)
				elseif desc:IsA("TextLabel") or desc:IsA("ImageLabel") or desc:IsA("Frame") then
					pcall(function() desc.Active = false end)
				end
			end
			btnObj.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					fire()
				end
			end)
		end

		bindButton(confirmBtn, function()
			if typeof(ModalData.ConfirmCallBack) == "function" then
				pcall(ModalData.ConfirmCallBack)
			end
		end)

		bindButton(cancelBtn, function()
			if typeof(ModalData.CancelCallBack) == "function" then
				pcall(ModalData.CancelCallBack)
			end
		end)

		if ui.main:FindFirstChild("dim") then
			local dimConn
			dimConn = ui.main.dim.InputBegan:Connect(function(input)
				if isClosing then
					if dimConn then dimConn:Disconnect() end
					return
				end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if dimConn then dimConn:Disconnect() end
					if typeof(ModalData.CancelCallBack) == "function" then
						pcall(ModalData.CancelCallBack)
					end
					closeModal()
				end
			end)
		end

		local escConn
		escConn = userinput.InputBegan:Connect(function(input, gpe)
			if isClosing then
				if escConn then escConn:Disconnect() end
				return
			end
			if input.KeyCode == Enum.KeyCode.Escape then
				if escConn then escConn:Disconnect() end
				if typeof(ModalData.CancelCallBack) == "function" then
					pcall(ModalData.CancelCallBack)
				end
				closeModal()
			end
		end)
	end)
end

--@@Toast
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

			tweenservice:Create(toast, tweenInfo, {
				Position = target
			}):Play()

			currentY += toast.Size.Y.Offset + toastSpacing
		end
	end
end

function syde:Toast(Toasty)
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

		-- Content
		Toast.Content.Text = Data.Content
		-- task.wait(0) -- allow TextBounds update

		Toast.Size = UDim2.new(1, Toast.Content.TextBounds.X - 140 ,0, 40)
		--  tweenservice:Create(Toast, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, Toast.Content.TextBounds.X - 140 ,0, 40)}):Play()

		if Data.Icon ~= "" then
			Toast.icon.ImageLabel.Image = "rbxassetid://" .. Data.Icon
			Toast.icon.ImageLabel.ImageTransparency = 0
		end



		-- Spawn ABOVE holder
		Toast.Position = UDim2.new(
			0.5, 0,
			0, -Toast.Size.Y.Offset - 20
		)

		-- Insert at TOP
		table.insert(toasts, 1, Toast)
		updateToastPositions()

		-- Auto remove
		task.delay(Data.Duration, function()
			if not Toast or not Toast.Parent then return end

			table.remove(toasts, table.find(toasts, Toast))

			tweenservice:Create(
				Toast,
				TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
				{
					Position = Toast.Position - UDim2.fromOffset(0, 30),
					BackgroundTransparency = 1
				}
			):Play()

			for _, v in ipairs(Toast:GetDescendants()) do
				if v:IsA("TextLabel") then
					tweenservice:Create(v, TweenInfo.new(0.3), {
						TextTransparency = 1
					}):Play()
				elseif v:IsA("ImageLabel") then
					tweenservice:Create(v, TweenInfo.new(0.3), {
						ImageTransparency = 1
					}):Play()
				elseif v:IsA("Frame") then
					tweenservice:Create(v, TweenInfo.new(0.3), {
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



--@SetupFunctionst
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
		window.user.headshot.id.displayname.Text = "@"..LocalPlayer.DisplayName
	else
		imageLabel.Image = PLACEHOLDER_IMAGE
	end
end

--@ Toggle Search
local searchopen = false

function opensearch()
	searchopen = true
	window.dim.Visible = true
	window.search.Visible = true
	window.search.Container.Visible = true
	window.search.Visible = true


	if window.search.Frame.TextBox.Text ~= '' then
		tweenservice:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 350,0, 230) }):Play()
	else
		tweenservice:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 350,0, 60) }):Play()
	end

	tweenservice:Create(window.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.45 }):Play()
	tweenservice:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
	tweenservice:Create(window.search.Frame.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()

	tweenservice:Create(window.search.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
	tweenservice:Create(window.search.close.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()

	tweenservice:Create(window.search.Frame.TextBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
end

function closesearch()
	searchopen = false
	window.search.Container.Visible = false
	tweenservice:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 350,0, 60) }):Play()
	tweenservice:Create(window.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
	tweenservice:Create(window.search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
	tweenservice:Create(window.search.Frame.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()

	tweenservice:Create(window.search.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
	tweenservice:Create(window.search.close.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()

	tweenservice:Create(window.search.Frame.TextBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
	task.wait(0.5)
	window.dim.Visible = false
	window.search.Visible = false
end

--@ ToggleUI

function openui()
	pages.Visible = true
	window.tabs.Visible = true
	window.user.Visible = true
	window.Visible = true
	uiclosed = false

	if bluron then
		syde:BindFrame(window, {
			Transparency = 0.98;
			BrickColor = BrickColor.new('Institutional white');
		})
		tweenservice:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.45 }):Play()
	else
		tweenservice:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0 }):Play()
	end
	tweenservice:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 700,0, 560) }):Play()

	tweenservice:Create(window.top.separator, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0 }):Play()
	tweenservice:Create(window.top.title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0 }):Play()
	tweenservice:Create(window.top.title.sub, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0 }):Play()

	tweenservice:Create(window.top.functions, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0 }):Play()

	if window.wallpaper.ison.Value  then
		tweenservice:Create(window.wallpaper, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 0.84 }):Play()
	end


	for i,v in pairs(window.top.functions:GetChildren()) do
		if v:IsA("Frame") then
			tweenservice:Create(v, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8 }):Play()
			v.Visible = true
			for i,v2 in pairs(v:GetChildren()) do
				if v2:IsA("ImageLabel") then
					tweenservice:Create(v2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 0 }):Play()
					v2.Visible = true
				end
			end
			if v:FindFirstChild("rainbow") then
				tweenservice:Create(v.rainbow, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1 }):Play()
			end

		end
	end

	tweenservice:Create(window.shadow.ImageLabel, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5 }):Play()
	tweenservice:Create(window.resize, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 0.3}):Play()

	if glow == true then
		for i, glow in pairs(window.clipframe:GetChildren()) do
			if glow:IsA("ImageLabel") then
				tweenservice:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 0.8}):Play()
			end
		end

		tweenservice:Create(window.shadow.glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 0.9}):Play()
		tweenservice:Create(window.shadow.glow1, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 0.9}):Play()
	end


end

function closeui()
	pages.Visible = false
	window.tabs.Visible = false
	window.user.Visible = false

	tweenservice:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1 }):Play()
	tweenservice:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, window.Size.Y.Scale, 200) }):Play()

	tweenservice:Create(window.top.separator, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1 }):Play()
	tweenservice:Create(window.top.title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1 }):Play()
	tweenservice:Create(window.top.title.sub, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1 }):Play()

	if window.wallpaper.ison.Value  then
		tweenservice:Create(window.wallpaper, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1 }):Play()
	end


	syde:UnbindFrame(window)


	tweenservice:Create(window.top.functions, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1 }):Play()
	for i,v in pairs(window.top.functions:GetChildren()) do
		if v:IsA("Frame") then
			tweenservice:Create(v, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1 }):Play()
			v.Visible = false
			for i,v2 in pairs(v:GetChildren()) do
				if v2:IsA("ImageLabel") then
					tweenservice:Create(v2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1 }):Play()
					v2.Visible = false
				end
			end
		end
	end

	for i, glow in pairs(window.clipframe:GetChildren()) do
		if glow:IsA("ImageLabel") then
			tweenservice:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 1}):Play()
		end
	end

	tweenservice:Create(window.shadow.glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 1}):Play()
	tweenservice:Create(window.shadow.glow1, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 1}):Play()

	tweenservice:Create(window.shadow.ImageLabel, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1 }):Play()
	tweenservice:Create(window.resize, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1 }):Play()

	closesettings()
	closesearch()
	settingsOpen = false



	--task.wait(0.5)

	window.Visible = false
	uiclosed = true
	syde:Toast({
		Content = 'UI Hidden, Use '.. uitoggle.Name ..' To Open Back.',
		Duration = 2,
	})


end

local bounce = false

function ToggleUI()
	if bounce then return end
	bounce = true

	if uiclosed then
		--	task.wait(0.2)
		openui()

		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			screenSize = workspace.CurrentCamera.ViewportSize
			isMobile = userinput.TouchEnabled
			updateLayout()
		end)

		updateLayout()

		camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayout)
		userinput:GetPropertyChangedSignal("TouchEnabled"):Connect(updateLayout)
	else
		closeui()
	end

	task.delay(0.2, function()
		bounce = false
	end)
end

window.top.functions.close.interact.MouseButton1Click:Connect(function()
	syde:Modal({
		Title = 'Please Confirm Below.',
		Content = 'Are You Sure You Want To Close This UI?',
		ConfimCallBack = function()
			mh = false
			rs:Disconnect()
			ss:Disconnect()
			--	if not ui.Parent then return end
			task.wait(1)
			Library:Destroy()
		end,
	})
end)


syde:HidePH(tabs, 'btn')
syde:HidePH(pages, 'page')

--@@Initialize
function syde:Init(library)
	if syde._EngineMode == "Orion" or (library == nil and not syde._SydeLoaded) or (type(library) == "table" and not library.Title and not library.Name and not library.Home and not library.ConfigurationSaving) then
		-- Orion library initialization: auto-load config and trigger notification if saved
		if (syde.SaveCfg or syde.SaveCfgState) and (isfile and readfile) and syde.Folder then
			pcall(function()
				local cfgPath = syde.Folder .. "/" .. tostring(game.GameId) .. ".txt"
				if isfile(cfgPath) then
					local raw = readfile(cfgPath)
					if syde.LoadCfg then
						syde:LoadCfg(raw)
					end
					syde:MakeNotification({
						Name = "Configuration",
						Content = "Auto-loaded configuration for the game " .. tostring(game.GameId) .. ".",
						Time = 5
					})
				end
			end)
		end
		return
	end

	library = library or {}
	ui.Enabled = true
	if loaded == false then
		local UI_TAG = "UILoader"
		local MARKER_NAME = "SYDEUIDetector"
		local INTERNAL_UUID = ("SYDE-" .. tostring(game.JobId):gsub("-", "") .. tostring(tick())):gsub("%.", "")
		local PROTECTION_EVENT = Instance.new("BindableEvent")
		local HttpService = game:GetService("HttpService")

		-- Cleanup old UI 
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

		-- Load the Library
		local successLibrary, Library = pcall(function()
			return Library -- Replace with actual GetObjects if needed
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

		-- Ensure Library stays in CoreGui
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
		Title = library.Title or "UI";
		SubText = library.SubText or "Google";
		Home = library.Home or {} 
	}

	-- Now we fill in the missing pieces if they weren't provided
	Data.Home.Enabled = (Data.Home.Enabled == true) -- Forces true/false
	Data.Home.hTitle = Data.Home.hTitle or Data.Title
	Data.Home.hSubText = Data.Home.hSubText or Data.SubText
	Data.Home.profileImage = Data.Home.profileImage or Data.profileImage
	
	local Minihome = ui.minihome

	local MinihomeData = {
		QuickActions = library.QuickActions or false;
	}

	-- FPS tracking
	local lastTime = tick()
	local frames = 0

	if mh then
		rs = RunService.RenderStepped:Connect(function()
			-- stop cleanly if the watermark/minihome was hidden or destroyed
			local info = Minihome and Minihome:FindFirstChild("info")
			if not info then
				if rs then rs:Disconnect() end
				return
			end

			-- FPS
			frames += 1
			local now = tick()

			if now - lastTime >= 1 then
				local fps = math.floor(frames / (now - lastTime))
				lastTime = now
				frames = 0

				info.fps.Text = fps .. " FPS"
			end

			-- Time → 8:45
			local hour = tonumber(os.date("%I"))
			info.time.Text = hour .. os.date(":%M")
		end)


		if MinihomeData.QuickActions == false then
			ui.minihome.quick.Visible = false
			ui.minihome:TweenSize(UDim2.new(0, 150, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.8, true)
		end
	end


	if not uiclosed then
		ui.minihome.open.quickfunc.interact.MouseButton1Click:Connect(function()
			ToggleUI()
		end)
	end

	--ui elements
	top.title.Text = Data.Title
	top.title.sub.Text = Data.SubText

	--dragging
	syde:AddDrag(top, window, true)
	if Minihome then
		syde:AddDrag(Minihome, Minihome) -- make the watermark draggable
	end
	syde:MakeResizable(window.resize, window, Vector2.new(454, 228))

	--initial transparency setup
	top.title.TextTransparency = 1
	tweenservice:Create(top.title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	top.title.sub.TextTransparency = 1
	tweenservice:Create(top.title.sub, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

	task.spawn(function()
		task.wait(0.5)
		local titleTween = tweenservice:Create(top.title, TweenInfo.new(1.65, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		titleTween:Play()

		task.wait(0.1)
		local subTitleTween = tweenservice:Create(top.title.sub, TweenInfo.new(1.65, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		subTitleTween:Play()

		task.wait()
		local textSize = top.title.TextBounds.X + 3

		tweenservice:Create(top.title, TweenInfo.new(1.55, Enum.EasingStyle.Quint), {
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
			if not uiclosed then
				if v.Name ~= "plugins" then
					TweenService:Create(
						image,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.7 }
					):Play()
				end
			end


			if v.Name == "plugins" and gradient then
				tweenservice:Create(v.rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()
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
			if not uiclosed then
				if v.Name ~= "plugins" then
					TweenService:Create(
						image,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }
					):Play()
				end
			end


			if v.Name == "plugins" then
				tweenservice:Create(v.rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
				local state = RainbowStates[v]
				if state and state.connection then
					state.connection:Disconnect()
					state.connection = nil
				end

			end
		end)
	end


	--[[if not searchopen then
			closesearch()
	end]]

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



	syde:AddConnection(syde.Comms.Event, function(p, value)
		if p == "Accent" then
			for i, glow in pairs(window.clipframe:GetChildren()) do
				if glow:IsA("ImageLabel") then
					tweenservice:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageColor3 = value}):Play()
				end
			end
			tweenservice:Create(window.shadow.glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageColor3 = value}):Play()
			tweenservice:Create(window.shadow.glow1, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageColor3 = value}):Play()
		end
	end)

	-- Syde Connection (Coming Soon)
	SetUserInfo()
	tweenservice:Create(window.user.headshot.id.username, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, window.user.headshot.id.username.TextBounds.X + 10,0, 10)}):Play()

	if userinfodisabled == false then
		tweenservice:Create(window.tabs, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 200,1, -115) }):Play()
	else
		tweenservice:Create(window.tabs, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 200,1, -75) }):Play()
	end

	window.user.MouseEnter:Connect(function()
		tweenservice:Create(window.user.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Quart), {Thickness = 1}):Play()
	end)
	window.user.MouseLeave:Connect(function()
		tweenservice:Create(window.user.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Quart), {Thickness = 0}):Play()
	end)

	if Data.Home.Enabled then

		window.pages.home.general.presence.Profile.ImageLabel.Text.Header.Text = Data.Home.hTitle
		window.pages.home.general.presence.Profile.ImageLabel.Text.Sub.Text = Data.Home.hSubText

		window.pages.home.general.presence.Profile.ImageLabel.Image = 'rbxassetid://'..Data.Home.profileImage
		window.pages.home.general.presence.wallpaper.Image = 'rbxassetid://'..Data.Home.profileImage
		
		local placeId = game.PlaceId

		window.pages.home.general.presence.PlaceID.Text =
			"Place ID: "..placeId

	--[[	local executor = "Undetected"

		local function detect()

			if identifyexecutor then
				executor = identifyexecutor()

			elseif getexecutorname then
				executor = getexecutorname()

			elseif syn then
				executor = "Synapse X"

			elseif KRNL_LOADED then
				executor = "KRNL"

			elseif is_sirhurt_closure then
				executor = "SirHurt"

			elseif pebc_execute then
				executor = "ProtoSmasher"

			elseif secure_load then
				executor = "Sentinel"

			elseif OXYGEN_LOADED then
				executor = "Oxygen U"

			elseif fluxus then
				executor = "Fluxus"

			elseif is_fluxus_closure then
				executor = "Fluxus"

			elseif getrenv().Xeno then
				executor = "Xeno"

			elseif getrenv().Solara then
				executor = "Solara"

			elseif getgenv().Solara then
				executor = "Solara"

			elseif getgenv().Xeno then
				executor = "Xeno"

			elseif SW_LOADED then
				executor = "Script-Ware"

			elseif is_electron then
				executor = "Electron"

			elseif getexecutor then
				executor = getexecutor()

			end

		end

		--	detect()

		local ExecutorUI =
			window.pages.home.general.presence.Executor

		local Frame = ExecutorUI.Frame
		local Label = Frame.TextLabel


		Label.Text = executor

		task.wait() -- allow TextBounds to update


		local textWidth =
			math.max(Label.TextBounds.X, 40)

		local frameWidth =
			textWidth + 20

		local containerWidth =
			frameWidth + 65


		TweenService:Create(
			Label,
			TweenInfo.new(.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				Size = UDim2.fromOffset(textWidth, Label.AbsoluteSize.Y)
			}
		):Play()


		TweenService:Create(
			Frame,
			TweenInfo.new(.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				Size = UDim2.fromOffset(frameWidth, Frame.AbsoluteSize.Y)
			}
		):Play()


		TweenService:Create(
			ExecutorUI,
			TweenInfo.new(.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				Size = UDim2.fromOffset(containerWidth, ExecutorUI.AbsoluteSize.Y)
			}
		):Play()

		window.pages.home.general.presence.Executor.Frame.TextLabel.Text =
			executor]]

		local layout = Bento.new(window.pages.home.general.Quick,{
			Gap = 6,
			RightPadding = 20,
			TweenTime = 0.35
		})

		-- optional manual rows
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
				-- replace with getPing() when ready

				table.insert(history,ping)

				if #history > MAX_POINTS then
					table.remove(history,1)
				end


				-- smooth values
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
					tweenservice:Create(v.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end)

				v.MouseLeave:Connect(function()
					tweenservice:Create(v.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
				end)
			end
		end

		bh.Leave.interact.MouseButton1Click:Connect(function()

			game:GetService("Players").LocalPlayer:Kick("Left the experience")

		end)

		bh.Rejoin.interact.MouseButton1Click:Connect(function()

			local TeleportService = game:GetService("TeleportService")
			local player = game:GetService("Players").LocalPlayer

			TeleportService:Teleport(game.PlaceId, player)

		end)

		local HttpService = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")
		local Players = game:GetService("Players")

		local player = Players.LocalPlayer

		local placeId = game.PlaceId

		-- Cross-executor HTTP GET. game:HttpGet is not present in every
		-- executor environment (the "HttpGet is not a valid member of
		-- DataModel" error), so prefer the executor request functions and
		-- only fall back to game:HttpGet when nothing else is available.
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
					player
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

		local FILE = syde.ConfigFolder .. "/last_game.json"


		-- save last played game
		local function SaveLastGame(placeId)
			if not syde.ConfigEnabled then return end

			local data = {
				PlaceId = placeId,
				Time = os.time()
			}

			pcall(function()
				writefile(FILE, HttpService:JSONEncode(data))
			end)
		end


		-- load last played game
		local function LoadLastGame()
			if not syde.ConfigEnabled then return nil end
			if not isfile(FILE) then return nil end

			local success, result = pcall(function()
				return HttpService:JSONDecode(readfile(FILE))
			end)

			if success then
				return result
			end
		end



		-- get placeId from file FIRST
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




		-- save current game after 2 minutes
		task.delay(120, function()
			if syde and syde.ConfigEnabled then
				SaveLastGame(game.PlaceId)
			end
		end)


		-- resume button
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

		tweenservice:Create(window.settings, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 360,0, 400)}):Play()
		tweenservice:Create(window.dim, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.2 }):Play()
		tweenservice:Create(window.settings.UICorner, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { CornerRadius = UDim.new(0,20)}):Play()

		tweenservice:Create(window.settings, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0}):Play()
		window.settings.pages.Visible = true
		window.settings.tabs.Visible = true

		tweenservice:Create(window.settings.top.title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0}):Play()
		tweenservice:Create(window.settings.top.separator, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0}):Play()
		tweenservice:Create(window.settings.top.functions.close, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0}):Play()
		tweenservice:Create(window.settings.top.functions.close.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0}):Play()
	end

	function closesettings()
		tweenservice:Create(window.settings, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 360,0, 150)}):Play()
		tweenservice:Create(window.dim, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
		tweenservice:Create(window.settings.UICorner, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { CornerRadius = UDim.new(0, 90)}):Play()

		tweenservice:Create(window.settings, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
		window.settings.pages.Visible = false
		window.settings.tabs.Visible = false

		tweenservice:Create(window.settings.top.title, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { TextTransparency = 1}):Play()
		tweenservice:Create(window.settings.top.separator, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
		tweenservice:Create(window.settings.top.functions.close, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1}):Play()
		tweenservice:Create(window.settings.top.functions.close.ImageLabel, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { ImageTransparency = 1}):Play()
		task.wait(0.6)
		window.settings.Visible = false
		window.dim.Visible = false
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

	--[[
	
	 ______     ______     ______   ______   __     __   __     ______     ______    
	/\  ___\   /\  ___\   /\__  _\ /\__  _\ /\ \   /\ "-.\ \   /\  ___\   /\  ___\   
	\ \___  \  \ \  __\   \/_/\ \/ \/_/\ \/ \ \ \  \ \ \-.  \  \ \ \__ \  \ \___  \  
 	 \/\_____\  \ \_____\    \ \_\    \ \_\  \ \_\  \ \_\\"\_\  \ \_____\  \/\_____\ 
 	  \/_____/   \/_____/     \/_/     \/_/   \/_/   \/_/ \/_/   \/_____/   \/_____/ 
                                                                                 
	@@Settings
	]]


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

			-- === Tab Setup ===
			local Tab = tabsContainer.tb:Clone()
			Tab.Visible = true
			Tab.Parent = tabsContainer
			Tab.Name = tdata.Title
			Tab.title.Text = tdata.Title

			-- === Page Setup ===
			local Page = pagesContainer.page:Clone()
			Page.Visible = false
			Page.Parent = pagesContainer
			Page.Name = tdata.Title

			for _, v in ipairs(Page:GetChildren()) do
				if v:IsA("Frame") then
					v:Destroy()
				end
			end

			-- === Tween Info ===
			local bgTween = TweenInfo.new(0.15, Enum.EasingStyle.Quint)
			local textTween = TweenInfo.new(0.1, Enum.EasingStyle.Quint)

			local function ApplyTabStyle(tabButton, selected)
				tweenservice:Create(tabButton, bgTween, {
					BackgroundColor3 = selected
						and Color3.fromRGB(31, 31, 31)
						or Color3.fromRGB(16, 16, 16)
				}):Play()

				tweenservice:Create(tabButton.title, textTween, {
					TextTransparency = selected and 0 or 0.6
				}):Play()
			end

			-- === First tab auto-select ===
			if not tbdata.selectedTab then
				tbdata.selectedTab = Tab
				Page.Visible = true
				ApplyTabStyle(Tab, true)
			else
				ApplyTabStyle(Tab, false)
			end

			-- === Click logic ===
			Tab.interact.MouseButton1Click:Connect(function()
				if tbdata.selectedTab == Tab then return end

				-- hide all pages
				for _, p in ipairs(pagesContainer:GetChildren()) do
					if p:IsA("ScrollingFrame") then
						p.Visible = false
					end
				end

				-- update tab styles
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
					-- UI Stroke effect on button press

					button.interact.MouseButton1Down:Connect(function()
						tweenservice:Create(button.UIStroke, fOTween, { Transparency = 1 }):Play()
						tweenservice:Create(button.ImageLabel, fOTween, { ImageTransparency = 1 }):Play()
						tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
					end)

					button.interact.MouseButton1Up:Connect(function()
						tweenservice:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
						tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()


					end)

					button.interact.MouseButton1Click:Connect(function()
						if data.CallBack then
							local success, errorMsg = pcall(c)
							if not success then
								syde:Report("Button '" .. button.Name .. "' callback", errorMsg)

							end
						else
							warn(`[ CallBack Missing: { button.Name } ] No Function Assigned`)
						end
					end)

					-- Extra Check 
					button.interact.MouseLeave:Connect(function()
						tweenservice:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
						tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()
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
						tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()
						tweenservice:Create(button.title.timer, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
						if not Complete then
							tweenservice:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
							tweenservice:Create(button.UIStroke.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()
							tweenservice:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,-15 ,0 ,button.Position.Y.Offset) }):Play()
							task.wait(0.15)
							tweenservice:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,30 ,0 ,button.Position.Y.Offset) }):Play()
							task.wait(0.15)
							tweenservice:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,0 ,0 ,button.Position.Y.Offset) }):Play()
							task.wait(1)
							tweenservice:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0 }):Play()
						end

						-- did not complete 

						--	button.UIStroke.UIGradient.Offset = Vector2.new(-1, 0)
						--	tweenservice:Create(button.UIStroke, TweenInfo.new(HoldTime, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()

						TimeLeft = HoldTime
						button.title.timer.Text = tostring(HoldTime)
						task.wait(0.1)
						Complete = false
					end

					button.interact.MouseButton1Down:Connect(function()

						Holding = true
						TimeLeft = HoldTime
						button.title.timer.Text = tostring(TimeLeft)
						tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
						tweenservice:Create(button.title.timer, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
						tweenservice:Create(button.UIStroke.UIGradient, TweenInfo.new(HoldTime, Enum.EasingStyle.Linear), { Offset = Vector2.new(0.7, 0) }):Play()
						tweenservice:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0}):Play()

						-- Countdown loop
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

							tweenservice:Create(button, TweenInfo.new(0.34, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }):Play()
							tweenservice:Create(button.UIStroke.UIGradient, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()
							task.wait(0.34)
							tweenservice:Create(button, TweenInfo.new(0.34, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }):Play()
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

				--[DESC]
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
							local newButtonSize = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, 0, button.title.Size.Y.Offset + textSize.Y + 10)
							tweenservice:Create(button.UICorner, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CornerRadius = UDim.new(0,20) }):Play()
							local descTween = tweenservice:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
							descTween:Play()

							local buttonTween = tweenservice:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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
				tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,0, 25) }):Play()

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
					local targetColor = state and syde.theme.HitBox or Color3.fromRGB(28, 28, 28)
					local strokeTransparency = state and 1 or 0
					local checkTransparency = state and 0 or 1
					local gradientTransparency = state and 0 or 1
					local glowTransparency = state and 0.7 or 1
					local textTransparency = state and 0 or 0.5

					tweenservice:Create(toggle.tog, toggleTween, { BackgroundColor3 = targetColor }):Play()
					--	tweenservice:Create(toggle.tog.UIStroke, toggleTween, { Transparency = strokeTransparency }):Play()
					tweenservice:Create(toggle.tog.check, toggleTween, { ImageTransparency = checkTransparency }):Play()
					tweenservice:Create(toggle.tog.gradfr, fadeTween, { BackgroundTransparency = gradientTransparency }):Play()
					tweenservice:Create(toggle.tog.glow, toggleTween, { ImageTransparency = glowTransparency }):Play()
					tweenservice:Create(toggle.tog.glow, toggleTween, { ImageColor3 = targetColor }):Play()
					tweenservice:Create(toggle.title, toggleTween, { TextTransparency = textTransparency }):Play()
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
						syde:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
					end
				end)

				--[DESC]
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
							local newButtonSize = UDim2.new(toggle.Size.X.Scale, toggle.Size.X.Offset, 0, toggle.title.Size.Y.Offset + textSize.Y + 10) -- Adding extra padding
							tweenservice:Create(toggle.UICorner, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CornerRadius = UDim.new(0,20) }):Play()
							local descTween = tweenservice:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
							descTween:Play()

							local ToggleTween = tweenservice:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
							ToggleTween:Play()
						end

						updateSize()

						descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
					else
						descLabel.Visible = false
					end
				end


				-- [CONFIGURATIPON]
				if data.Config then

					local State = false

					local enterTween = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)

					toggle.configure.MouseEnter:Connect(function()
						tweenservice:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					end)

					toggle.configure.MouseLeave:Connect(function()
						tweenservice:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(104, 104, 104) }):Play()
					end)

					local function ToggleConfigOpen()
						toggleConfiguration.Visible = true
						State = true

						tweenservice:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 0 }):Play()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 0 }):Play()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 0 }):Play()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 0 }):Play()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 0 }):Play()
						tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, enterTween, { ImageTransparency = 0 }):Play()
						tweenservice:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 0 }):Play()
						tweenservice:Create(toggleConfiguration, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 174,0, 88) }):Play()
						--	tweenservice:Create(toggleConfiguration.shadow.ImageLabel, enterTween, { ImageTransparency = 0.57 }):Play()

					end

					local function ToggleConfigClose()
						State = false

						tweenservice:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 1 }):Play()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 1 }):Play()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 1 }):Play()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 1 }):Play()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 1 }):Play()
						tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, enterTween, { ImageTransparency = 1 }):Play()
						tweenservice:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 1 }):Play()
						tweenservice:Create(toggleConfiguration, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 75,0, 53) }):Play()
						--	tweenservice:Create(toggleConfiguration.shadow.ImageLabel, enterTween, { ImageTransparency = 1 }):Play()
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
							TogService = runservice.RenderStepped:Connect(function()
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
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,0, 25) }):Play()
					end

					local function setKeybind(key)
						if not key then
							toggleConfiguration.Container.KeyBind.Bind.v.Text = 'None'
							ResizeBindFrame()
							data.Keybind = nil
						else
							data.Keybind = key
							data.KeybindReady = false

							tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
							toggleConfiguration.Container.KeyBind.Bind.v.Text = key.Name
							tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
							ResizeBindFrame()

							task.delay(0.5, function()
								data.KeybindReady = true
							end)
						end
					end

					toggleConfiguration.Container.KeyBind.Interact.MouseButton1Click:Connect(function()
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
						task.wait(0.2)
						toggleConfiguration.Container.KeyBind.Bind.v.Text = "..."
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
						ResizeBindFrame()


						local connection
						connection = userinput.InputBegan:Connect(function(input, processed)
							if not userinput:GetFocusedTextBox() and syde:IsBindableInput(input) then
								setKeybind(input.KeyCode)
								connection:Disconnect()
							end
						end)
					end)

					userinput.InputBegan:Connect(function(input, processed)
						if not userinput:GetFocusedTextBox() and data.Keybind and data.KeybindReady and input.KeyCode == data.Keybind then
							data.V = not data.V
							UpdateToggleUI(data.V)

							if data.CallBack then
								local success, errorMsg = pcall(function()
									data.CallBack(data.V)
								end)
								if not success then
									syde:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
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
							tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = 13 }):Play()
							task.wait(0.2)
							tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = -13 }):Play()
							task.wait(0.2)
							tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = 0 }):Play()
						end

						blink()

						task.delay(2, function()
							debounce2 = false
						end)
					end)

					toggleConfiguration.Container.Clear.MouseEnter:Connect(function()
						tweenservice:Create(toggleConfiguration.Container.Clear.clear, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.9 }):Play()
					end)

					toggleConfiguration.Container.Clear.MouseLeave:Connect(function()
						tweenservice:Create(toggleConfiguration.Container.Clear.clear, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
					end)

				end

				syde:AddConnection(syde.Comms.Event, function(p, color)
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
					UpdateToggleUI(NewValue)

					local success, errorMsg = pcall(function()
						if data.CallBack then
							data.CallBack(NewValue)
						end
					end)

					if not success then
						syde:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
					end

				end

				if data.SFlag then
					syde.SettingsFlags[data.SFlag] = data
				end
			end

			function telement:Keybind(Keybind)
				local data = {
					Title = Keybind.Title;
					Key = Keybind.Key;
					Desc = Keybind.Description or "";
					CallBack = Keybind.CallBack;
					WaitingForKey = false;
					Hold = false;
					Holding = false
				}

				local KeyBind = window.settings.pages.page.KeyBind:Clone()
				KeyBind.Visible = true
				KeyBind.Parent = Page
				KeyBind.title.Text = data.Title
				KeyBind.Name = data.Title

				KeyBind.Bind.v.Text = data.Key and data.Key.Name or "NONE"
				tweenservice:Create(KeyBind.Bind, TweenInfo.new(0.55, Enum.EasingStyle.Quint ), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()

				KeyBind.interact.MouseButton1Click:Connect(function()
					KeyBind.Bind.v.Text = '...'
					tweenservice:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Thickness = 1}):Play()
					data.WaitingForKey = true
				end)

				KeyBind.Bind.v:GetPropertyChangedSignal('TextBounds'):Connect(function()
					tweenservice:Create(KeyBind.Bind, TweenInfo.new(0.55, Enum.EasingStyle.Quint ), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()
				end)

				local function SetKeybind(keyCode)
					if keyCode and keyCode ~= Enum.KeyCode.Unknown then
						data.Key = keyCode
						KeyBind.Bind.v.Text = keyCode.Name
						tweenservice:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Thickness = 0}):Play()
						if typeof(Keybind.OnKeyChanged) == "function" then
							pcall(Keybind.OnKeyChanged, keyCode)
						end
					else
						data.Key = nil
						KeyBind.Bind.v.Text = "NONE"
					end
				end

				-- Main input handler
				syde:AddConnection(userinput.InputBegan, function(input, processed)
					if data.WaitingForKey then
						if syde:IsBindableInput(input) then
							data.WaitingForKey = false
							SetKeybind(input.KeyCode)
						end
						return
					end

					-- don't fire the bind while typing in a textbox (ignore processed so
					-- keys the game also uses, e.g. RightShift shift-lock, still work)
					if userinput:GetFocusedTextBox() then return end
					if input.KeyCode == Enum.KeyCode.Unknown then return end

					if input.KeyCode == data.Key then
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
								syde:Report("Keybind '" .. KeyBind.Name .. "' callback", result)
							end
						else
							if data.Hold then
								local holdLoop
								holdLoop = runservice.RenderStepped:Connect(function()
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

					-- kill UIListLayout if it exists
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
							tweenservice:Create(
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
				tweenservice:Create(colorpicker.color, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundColor3 = data.Color }):Play()

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
						--	frame.Position = UDim2.new(0, startX, 0.5, -frame.Size.Y.Offset / 2)
						tweenservice:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0, startX , 0.8, -frame.Size.Y.Offset / 2) }):Play()
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

					--	colorpicker.color.BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1)
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

					tweenservice:Create(HUESlider.Pin, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {BackgroundColor3 = newColor2}):Play()
					tweenservice:Create(SVPicker.Pin, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {BackgroundColor3 = newColor}):Play()


					tweenservice:Create(SVPicker.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0)
					}):Play()

					tweenservice:Create(HUESlider.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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

					tweenservice:Create(colorpicker.UICorner, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CornerRadius = UDim.new(0,20) }):Play()
					tweenservice:Create(colorpicker.color, TweenInfo.new( 0.95, Enum.EasingStyle.Quart ), { Size = UDim2.new(0, 1,0, 1) }):Play()
					tweenservice:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
					tweenservice:Create(colorpicker.color, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1) }):Play()
					tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					--	tweenservice:Create(colorpicker.color.glow, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 1}):Play()
					task.wait(0.12)
					tweenservice:Create(colorpicker.color, TweenInfo.new( 0.9, Enum.EasingStyle.Quart ), { Size = UDim2.new(1, -40,0, 160) }):Play()
					tweenservice:Create(colorpicker.color, TweenInfo.new( 0.9, Enum.EasingStyle.Quart ), { Position = UDim2.new(0.5, 0,0, 40) }):Play()

					tweenservice:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }):Play()
					tweenservice:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Quart ), { Size = UDim2.new(1, -35,0, 300) }):Play()
					tweenservice:Create(colorpicker.color.UICorner, TweenInfo.new( 0.8, Enum.EasingStyle.Quart ), { CornerRadius = UDim.new(0, 10) }):Play()

					tweenservice:Create(colorpicker.color.Values.Rainbow, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()


					task.wait(0.6)

					tweenservice:Create(colorpicker.color.SVPicker.Brightness, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.SVPicker.Saturation, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.SVPicker.Pin, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.SVPicker.Pin.UIStroke, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()

					task.wait(0.5)
					tweenservice:Create(colorpicker.color.Values.Hue, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.Values.Hue.Pin, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.Values.Hue.Pin.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()

					if data.Type == "Gradient" then
						tweenservice:Create(colorpicker.color.Values.Grad, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
						tweenservice:Create(colorpicker.color.Values.Grad.Pin1, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
						tweenservice:Create(colorpicker.color.Values.Grad.Pin1.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()
						tweenservice:Create(colorpicker.color.Values.Grad.Pin2, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
						tweenservice:Create(colorpicker.color.Values.Grad.Pin2.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()
					end

					tweenservice:Create(colorpicker.HueValues.HEX, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
					tweenservice:Create(colorpicker.HueValues.HEX.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
					tweenservice:Create(colorpicker.HueValues.HEX.V.HEXBox, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { TextTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.HueValues.HEX.Copy, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()

					task.wait(0.09)
					tweenservice:Create(colorpicker.HueValues.RGB, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
					tweenservice:Create(colorpicker.HueValues.RGB.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
					tweenservice:Create(colorpicker.HueValues.RGB.V.RGBBox, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { TextTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.HueValues.RGB.Copy, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()
					task.wait(0.09)
					tweenservice:Create(colorpicker.HueValues.Link, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
					tweenservice:Create(colorpicker.HueValues.Link.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
					tweenservice:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.HueValues.Link.Frame.ImageLabel, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()

					for _,v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
						if v:IsA('Frame') then
							task.wait(0.1)
							tweenservice:Create(v, TweenInfo.new( 0.3, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
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
					tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 70,0, 3) }):Play()
					tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end)

				colorpicker.QuickClose.hitbox.MouseLeave:Connect(function()
					tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 60,0, 3) }):Play()
					tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(33, 33, 33) }):Play()
				end)

				local function ClosePicker()
					Open = false
					DeBounce = true
					tweenservice:Create(colorpicker.UICorner, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CornerRadius = UDim.new(1,0) }):Play()
					tweenservice:Create(colorpicker, TweenInfo.new( 0.55, Enum.EasingStyle.Quint ), { Size = UDim2.new(1, -35,0, 40) }):Play()
					--	tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color, TweenInfo.new( 0.7, Enum.EasingStyle.Quart ), { Position = UDim2.new(1, -30,0, 10)}):Play()
					tweenservice:Create(colorpicker.color, TweenInfo.new( 0.55, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 20,0, 20) }):Play()
					tweenservice:Create(colorpicker.color, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundColor3 = data.Color }):Play()
					tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					--	tweenservice:Create(colorpicker.color.glow, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 0.7}):Play()
					colorpicker.interact.Interactable = true
					colorpicker.QuickClose.Interactable = false

					--	task.wait(0.6)

					tweenservice:Create(colorpicker.color.SVPicker.Brightness, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.SVPicker.Saturation, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.SVPicker.Pin, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.SVPicker.Pin.UIStroke, TweenInfo.new( 0.4, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()

					tweenservice:Create(colorpicker.color.Values.Hue, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.Values.Hue.Pin, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.Values.Hue.Pin.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()

					tweenservice:Create(colorpicker.color.Values.Rainbow, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

					if data.Type == "Gradient" then
						tweenservice:Create(colorpicker.color.Values.Grad, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
						tweenservice:Create(colorpicker.color.Values.Grad.Pin1, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
						tweenservice:Create(colorpicker.color.Values.Grad.Pin1.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
						tweenservice:Create(colorpicker.color.Values.Grad.Pin2, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
						tweenservice:Create(colorpicker.color.Values.Grad.Pin2.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					end

					local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

					if data.Type == "Gradient" and displayGrad then
						displayGrad.Enabled = true
						displayGrad.Color = ColorSequence.new(Keys)
						-- Set to White so the gradient isn't "multiplied" or tinted by a background color
						tweenservice:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
					else
						if displayGrad then displayGrad.Enabled = false end
						tweenservice:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = data.Color }):Play()
					end

					tweenservice:Create(colorpicker.HueValues.RGB, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.RGB.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.RGB.V.RGBBox, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { TextTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.RGB.Copy, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

					tweenservice:Create(colorpicker.HueValues.HEX, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.HEX.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.HEX.V.HEXBox, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { TextTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.HEX.Copy, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

					tweenservice:Create(colorpicker.HueValues.Link, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.Link.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.HueValues.Link.Frame.ImageLabel, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()
					for _,v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
						if v:IsA('Frame') then
							tweenservice:Create(v, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
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
									tweenservice:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
								end)
								v2.MouseLeave:Connect(function()
									tweenservice:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(66, 66, 66) }):Play()
								end)
							end
						end
					end
				end

				-- copy hex / rgb to clipboard
				syde:OnClick(colorpicker.HueValues.HEX.Copy, function()
					if syde:SetClipboard(FormatColor(data.Color, 'Hex')) then syde:FlashCopy(colorpicker.HueValues.HEX.Copy) end
				end)
				syde:OnClick(colorpicker.HueValues.RGB.Copy, function()
					if syde:SetClipboard(FormatColor(data.Color, 'RGB', 2)) then syde:FlashCopy(colorpicker.HueValues.RGB.Copy) end
				end)

				local function AddRecentColor(newColor)
					local recentFrame = colorpicker.colorPlaceHolder:Clone()
					recentFrame.Visible = true
					recentFrame.Parent = colorpicker.color.Values.Recent
					recentFrame.BackgroundColor3 = newColor

					recentFrame.interact.MouseButton1Click:Connect(function()
				--[[	tweenservice:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 5,0, 5) }):Play()
					task.wait(0.09)
					tweenservice:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 12,0, 12) }):Play() ]]

						local h, s, v = newColor:ToHSV()
						if s > 0.02 then
							HSV[1] = h
						end
						HSV[2] = s
						HSV[3] = v
						updatestuff()

					end)

					recentFrame.interact.MouseEnter:Connect(function()
						tweenservice:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 20,0, 20) }):Play()
					end)

					recentFrame.interact.MouseLeave:Connect(function()
						tweenservice:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 12,0, 12) }):Play()
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

				syde:AddConnection(SVPicker.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						SV = runservice.RenderStepped:Connect(function()
							local mouse = game.Players.LocalPlayer:GetMouse()
							local ColorX = math.clamp(mouse.X - SVPicker.AbsolutePosition.X, 0, SVPicker.AbsoluteSize.X) / SVPicker.AbsoluteSize.X
							local ColorY = math.clamp(mouse.Y - SVPicker.AbsolutePosition.Y, 0, SVPicker.AbsoluteSize.Y) / SVPicker.AbsoluteSize.Y

							HSV[2] = ColorX
							HSV[3] = 1 - ColorY

							updatestuff()
						end)
					end
				end)

				syde:AddConnection(SVPicker.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and SV then
						SV:Disconnect()
						SV = nil
						AddRecentColor(data.Color)
					end
				end)

				syde:AddConnection(HUESlider.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						HUE = runservice.RenderStepped:Connect(function()
							local mouse = game.Players.LocalPlayer:GetMouse()
							local ColorX = math.clamp(mouse.X - HUESlider.AbsolutePosition.X, 0, HUESlider.AbsoluteSize.X) / HUESlider.AbsoluteSize.X

							HSV[1] = 1 - ColorX

							updatestuff()
						end)
					end
				end)

				syde:AddConnection(HUESlider.InputEnded, function(i)
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
						--	colorpicker.HueValues.Link.Frame.Position = UDim2.new(0, mouse.X - colorpicker.AbsolutePosition.X - 50, 0, mouse.Y - colorpicker.AbsolutePosition.Y - 260)
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
									--	TweenService:Create(colorpicker.HueValues.HEX.Link, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {ImageColor3 = Color3.fromRGB(66, 66, 66)}):Play()
									TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {Size = UDim2.new(1, 0,1, 0)}):Play()
									break
								end
							end
						end

						if not foundTarget then
							--	TweenService:Create(colorpicker.HueValues.HEX.Link, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {ImageColor3 = Color3.fromRGB(66, 66, 66)}):Play()
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
							huerender = runservice.RenderStepped:Connect(RainbowEffect)
							tweenservice:Create(colorpicker.color.Values.Rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential ), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
						end
					else
						if huerender then
							huerender:Disconnect()
							tweenservice:Create(colorpicker.color.Values.Rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential ), {ImageColor3 = Color3.fromRGB(62, 62, 62)}):Play()
							huerender = nil
						end
					end
				end

				colorpicker.color.Values.Rainbow.MouseButton1Click:Connect(ToggleRainbowEffect)

				function data:Set(RGBColor)

					if typeof(RGBColor) == "table" then
						RGBColor = Color3.fromRGB(RGBColor.R, RGBColor.G, RGBColor.B)
					end

					data.Color = RGBColor

					local h, s, v = RGBColor:ToHSV()
					HSV[1], HSV[2], HSV[3] = h, s, v
					updatestuff()
				end

				if data.SFlag then
					syde.SettingsFlags[data.SFlag] = data
				end

				if syde.ConfigEnabled and data.Flag and syde.Flags[data.Flag] then
					local existing = syde.Flags[data.Flag]
					if existing.Color then
						data:Set(existing.Color, true)
					end
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
				tweenservice:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.33, -20,0.576, -75) }):Play()
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
							tweenservice:Create(option, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, yOffset)}):Play()
							yOffset = yOffset + option.Size.Y.Offset + 7
						end
					end
				end

				local function OpenDrop()
					DropOpen = true
					dropdown.dropholder.drop.Container.Visible = true
					dropdown.dropholder.drop.search.Visible = true

					tweenservice:Create(dropdown, TweenInfo.new(1.34, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 300) }):Play()
					tweenservice:Create(dropdown.dropholder.drop.UICorner, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(0, 20) }):Play()
					tweenservice:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -20, 1, -75) }):Play()
					tweenservice:Create(dropdown.dropholder.drop.v0, TweenInfo.new(1.34, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Rotation = 180 }):Play()

					tweenservice:Create(dropdown.dropholder.drop.search, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.65 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.search.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0.4 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.search.TextBox, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.search.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.9 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.search.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.85 }):Play()

				end

				local function CloseDrop()
					DropOpen = false
					tweenservice:Create(dropdown, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 95) }):Play()
					tweenservice:Create(dropdown.dropholder.drop.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(1,0) }):Play()
					tweenservice:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.33, -20, 0.576, -75) }):Play()
					tweenservice:Create(dropdown.dropholder.drop.v0, TweenInfo.new(1.34, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Rotation = 0 }):Play()

					tweenservice:Create(dropdown.dropholder.drop.search, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.search.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.search.TextBox, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.search.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
					tweenservice:Create(dropdown.dropholder.drop.search.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()

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


						-- Create chips for each selected option
						for _, option in ipairs(SelectedOrder) do
							-- Prevent duplicate pills
							if not selectedContainer:FindFirstChild(option) then
								local optionGroup = selectedContainer.result:Clone()
								optionGroup.Visible = true
								optionGroup.Name = option
								optionGroup.TextLabel.Text = option

								-- Set up remove button
								optionGroup.X.MouseButton1Click:Connect(function()
									RemoveFromSelected(option)
									UpdateSelectedText()

									-- Visually update the dropdown list
									for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
										if opt:IsA("Frame") and opt.Name == option then
											tweenservice:Create(opt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
											tweenservice:Create(opt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
											tweenservice:Create(opt.Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
											tweenservice:Create(opt.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
											tweenservice:Create(opt.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
										end
									end

									if data.CallBack then
										data.CallBack(SelectedOrder)
									end
								end)

								optionGroup.Parent = selectedContainer

								-- Optional: auto-size width
								task.defer(function()
									local padding = 40
									local textWidth = optionGroup.TextLabel.TextBounds.X
									local totalWidth = textWidth + padding

									optionGroup.TextLabel.Size = UDim2.new(0, textWidth, 1, 0)

									tweenservice:Create(optionGroup, TweenInfo.new(0.67, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, totalWidth, 0, 20)}):Play()
								end)
							end
						end

					else
						-- Single option text fallback
						dropdown.dropholder.drop.selected.Visible = true
						if #SelectedOrder > 0 then
							dropdown.dropholder.drop.selected.Text = SelectedOrder[1]
						else
							dropdown.dropholder.drop.selected.Text = data.PlaceHolder
						end
					end
				end

				--[SEARCH]
				dropdown.dropholder.drop.search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
					local searchText = dropdown.dropholder.drop.search.TextBox.Text:lower()

					for _, option in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
						if option:IsA("Frame") and option:FindFirstChild("Title") then
							local optionText = option.Title.Text:lower()
							local isTemplate = option.Name == "Option"
							local shouldShow = not isTemplate and (searchText == "" or optionText:find(searchText, 1, true) or SelectedOptions[option.Title.Text])

							if shouldShow then
								option.Visible = true
								if SelectedOptions[option.Title.Text] then
									tweenservice:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
									tweenservice:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
									tweenservice:Create(option.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
									tweenservice:Create(option.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
									tweenservice:Create(option.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
								else
									tweenservice:Create(option, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
									tweenservice:Create(option, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
									tweenservice:Create(option.Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
									tweenservice:Create(option.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
									tweenservice:Create(option.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
								end
							else
								-- Hide with animation, but wait before setting Visible = false
								tweenservice:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
								tweenservice:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
								tweenservice:Create(option.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
								tweenservice:Create(option.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								tweenservice:Create(option.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
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

							tweenservice:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
							tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
						end

						option.Interact.MouseButton1Click:Connect(function()
							if data.Multi then
								if SelectedOptions[OptionText] then
									RemoveFromSelected(OptionText)
									tweenservice:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
									tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0.9}):Play()
								else
									AddToSelected(OptionText)
									tweenservice:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
									tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
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
										tweenservice:Create(opt, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
										tweenservice:Create(opt.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0.9}):Play()
									end
								end

								tweenservice:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
								tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()


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


				--[SLIDERS INITIALIZE]
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

					syde:registerLoadTween(
						Slider.slide.slideframe,
						{Size = UDim2.new(SliderPosition, 0, 1, 0)},
						{Size = UDim2.new(0, 100,1, 0)},
						TweenInfo.new(0.85, Enum.EasingStyle.Quint)
					)

					syde:replayLoadTweens(Slider.slide.slideframe)

					local decimalPlaces = syde:DecimalPlaces(Options.Increment)
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

						-- wait for UI to size properly
						task.wait()

						local width = ticksFrame.AbsoluteSize.X
						local height = ticksFrame.AbsoluteSize.Y


						local spacing = width / (tickCount - 1)

						-- Reuse existing ticks instead of destroying all
						local existingTicks = {}
						for _, child in ipairs(ticksFrame:GetChildren()) do
							if child:IsA("Frame") and child ~= template then
								table.insert(existingTicks, child)
							end
						end

						-- Create new ticks if needed
						for i = 0, tickCount - 1 do
							local tick = existingTicks[i + 1] or template:Clone()
							tick.Visible = true
							tick.AnchorPoint = Vector2.new(0.5, 0.5)
							tick.BorderSizePixel = 0
							--	tick.BackgroundTransparency = 1
							tick.Parent = ticksFrame

							local finalPos = UDim2.fromOffset(i * spacing, height / 1.5)
							tweenservice:Create(
								tick,
								TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									Position = finalPos,
									BackgroundTransparency = 0.85
								}
							):Play()
						end

						-- Destroy extra ticks
						for i = tickCount + 1, #existingTicks do
							existingTicks[i]:Destroy()
						end

					end

					-- Connect AbsoluteSize change **only once**
					if Options.Increment > 4 then
						if not Slider.slide.Ticks:FindFirstChild("_ResizeConnection") then
							local conn = Slider.slide.Ticks:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
								BuildTicks(Slider.slide, Options)
							end)
							-- Tag the connection so we don't connect again
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
							newValue = syde:RoundTo(newValue, syde:DecimalPlaces(Options.Increment))

							-- Update the slider visual position
							local snapPosition = (newValue - Options.Range[1]) / range
							Slider.slide.slideframe:TweenSize(UDim2.new(snapPosition, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.55, true)


							-- Update the displayed value
							local decimalPlaces = syde:DecimalPlaces(Options.Increment)
							Slider.v.Text = string.format("<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>", newValue, Options.Range[2])


							tweenservice:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

							local success, errorMsg = pcall(function()
								Options.CallBack(newValue)
							end)
							if not success then
								syde:Report("Slider '" .. Slider.Name .. "' callback", errorMsg)
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

					syde:AddConnection(userinput.InputEnded, function(input, processed)
						if input.UserInputType == Enum.UserInputType.MouseButton1  or input.UserInputType == Enum.UserInputType.Touch then
							dragging = false
							tweenservice:Create(Slider.Title, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { TextTransparency = 0.6 }):Play()
						end
					end)

					syde:AddConnection(userinput.InputChanged, function(input)
						if dragging and input.UserInputType == Enum.UserInputType.MouseMovement  or input.UserInputType == Enum.UserInputType.Touch  then
							UpdateSlider(input.Position.X)
						end
					end)

					Slider.slide.slideframe.BackgroundColor3 = syde.theme.HitBox
					Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = syde.theme.HitBox
					Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = syde.theme.HitBox
					Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = syde.theme.HitBox
					slider.slideholder.Size = UDim2.new(1,-30,0,slider.slideholder.UIListLayout.AbsoluteContentSize.Y)
					local ss = slider.slideholder.UIListLayout.AbsoluteContentSize.Y
					slider.Size = UDim2.new(1,-35,0, ss  + 20)

					syde:AddConnection(syde.Comms.Event, function(p, color)
						if p == 'HitBox' then
							Slider.slide.slideframe.BackgroundColor3 = color
							Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = color
							Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = color
							Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = color
						end
					end)

					function Options:Set(NewVal, skipSave)
						local range = Options.Range[2] - Options.Range[1]

						-- snap value to increment (same logic as UpdateSlider)
						NewVal = math.floor((NewVal - Options.Range[1]) / Options.Increment + 0.5) * Options.Increment + Options.Range[1]
						NewVal = syde:RoundTo(NewVal, syde:DecimalPlaces(Options.Increment))

						local sliderPosition = (NewVal - Options.Range[1]) / range

						Slider.slide.slideframe:TweenSize(
							UDim2.new(sliderPosition, 0, 1, 0),
							Enum.EasingDirection.Out,
							Enum.EasingStyle.Quint,
							0.55,
							true
						)

						-- Register load tween
						syde:registerLoadTween(
							Slider.slide.slideframe,
							{Size = UDim2.new(sliderPosition, 0, 1, 0)},
							{Size = UDim2.new(0, 100, 1, 0)},
							TweenInfo.new(0.85, Enum.EasingStyle.Quint)
						)

						-- detect decimal places from increment
						local decimalPlaces = syde:DecimalPlaces(Options.Increment)

						-- update display (decimal safe)
						Slider.v.Text = string.format(
							"<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>",
							NewVal,
							Options.Range[2]
						)

						-- Tween title appearance
						tweenservice:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {
							TextTransparency = 0
						}):Play()

						-- Callback
						local success, result = pcall(function()
							Options.CallBack(NewVal)
						end)

						if not success then
							syde:Report("Slider '" .. Slider.Name .. "' callback", result)
						end

						Options.StarterValue = NewVal
					end

					-- click the value to type a custom number (reverts if outside range)
					syde:AttachSliderInput(Slider, Options)

					if Options.SFlag then
						if Options.SFlag then
							syde.SettingsFlags[Options.SFlag] = Options
						end
					end

				end

				--[DESC]
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
							local newButtonSize = UDim2.new(slider.Size.X.Scale, slider.Size.X.Offset, 0,slider.slideholder.AbsoluteSize.Y + slider.title.Size.Y.Offset + textSize.Y + 15) -- Adding extra padding

							local descTween = tweenservice:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
							descTween:Play()

							local ToggleTween = tweenservice:Create(slider, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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
				--	Para.Size = UDim2.new(1, -35, 0, Para.Content.Size.Y.Offset + 200)

				local function updateSize()
					local textSize = textservice:GetTextSize(
						Para.Content.Text,
						Para.Content.TextSize,
						Para.Content.Font,
						Vector2.new(Para.Content.AbsoluteSize.X, math.huge) -- Allows vertical expansion
					)

					local newDescSize = UDim2.new(1, -20, 0, textSize.Y)
					local newButtonSize = UDim2.new(Para.Size.X.Scale, Para.Size.X.Offset, 0, textSize.Y + 120) -- Adding extra padding

					local descTween = tweenservice:Create(Para.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
					descTween:Play()

					local buttonTween = tweenservice:Create(Para, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
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
					--	MaxSize = TextInput.MaxSize or 100,
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
				--	local maxHeight = data.MaxSize
				local ignoreNextClear = false



				textinput.TextFrame.Enter.MouseEnter:Connect(function()
					tweenservice:Create(textinput.TextFrame.Enter, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end)

				textinput.TextFrame.Enter.MouseLeave:Connect(function()
					tweenservice:Create(textinput.TextFrame.Enter, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextColor3 = Color3.fromRGB(40, 40, 40)}):Play()
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




					tweenservice:Create(
						textinput,
						TweenInfo.new(0.7, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(1, -35, 0, newHeight + extraHeight + 35) }
					):Play()

					--	tweenservice:Create(textinput.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Position = UDim2.new(1, -20,1, -15) }):Play()


				end)

				textBox:GetPropertyChangedSignal("Size"):Connect(function()
					local newHeight = textBox.Size.Y.Offset
					local totalHeight = math.max(newHeight, defaultHeight)

					tweenservice:Create(
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
						syde:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
					end
				end

				textBox.FocusLost:Connect(function(enterPressed)
					if not enterPressed then return end

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

			-- guard every builder so a failed element shows the banner instead of breaking the UI
			for _bn, _bf in pairs(telement) do
				if type(_bf) == "function" then
					telement[_bn] = syde:Guard("Building a '" .. tostring(_bn) .. "' element", _bf)
				end
			end

			return telement

		end

		--@@SettingInit

		local a = settings:inittab({Title = 'Theme'})
		local b = settings:inittab({Title = 'Privacy'})
		local c = settings:inittab({Title = 'Info'})

		a:Keybind({
			Title = 'Toggle UI',
			Key = uitoggle,
			OnKeyChanged = function(newKey)
				uitoggle = newKey
			end,
			CallBack = function()
				ToggleUI()
			end,
		})

		a:ColorPicker({
			Title = 'Accent',
			RD = false,
			Linkable = true,
			Color = syde.theme.Accent;
			CallBack = function(v)
				syde:UpdateTheme({
					['Accent'] = v
				})
			end,
			SFlag = 'AC'
		})

		a:ColorPicker({
			Title = 'Hitbox',
			RD = false,
			Linkable = true,
			Color = syde.theme.HitBox;
			CallBack = function(c)
				syde:UpdateTheme({
					['HitBox'] = c
				})
			end,
			SFlag = 'HB'
		})

		local seq = syde.theme.DropShadow
		local k = seq.Keypoints

	--[[	a:ColorPicker({
			Title = 'Dropshadow';
			Linkable = true;
			Type = 'Gradient';

			Color  = k[1].Value;
			Color2 = k[#k].Value;

			GradientPath = window.shadow.ImageLabel.UIGradient;

			CallBack = function(value)
				local seq

				if typeof(value) == "ColorSequence" then
					seq = value
				elseif typeof(value) == "Color3" then
					seq = ColorSequence.new(value)
				else
					warn("Invalid DropShadow value:", typeof(value))
					return
				end

				syde:UpdateTheme({
					DropShadow = seq
				})
			end;
			SFlag = 'DS'
		})]]

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
			Value = false,
			CallBack = function(v)
				rotateGradient = v
				local grad = window.shadow.ImageLabel.UIGradient

				if rotateGradient and grad and grad.Enabled then
					startGradientRotation()
				end
			end,
			SFlag = 'RG',
		})

		a:Toggle({
			Title = 'Glow',
			Description = 'Shine on the ui.',
			CallBack = function (v)
				if v then
					glow = true
					for i, glow in pairs(window.clipframe:GetChildren()) do
						if glow:IsA("ImageLabel") then
							tweenservice:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 0.8}):Play()
						end
					end
					window.pages.v0.Visible = false

					window.pages.clipframe.v1.Visible = false
					window.pages.clipframe.v1.Visible = false

					--		window.shadow.ImageLabel.Visible = false
					window.shadow.glow.Visible = true
					window.shadow.glow1.Visible = true

				else
					glow = false
					for i, glow in pairs(window.clipframe:GetChildren()) do
						if glow:IsA("ImageLabel") then
							tweenservice:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{ImageTransparency = 1}):Play()
						end
					end

					--	window.shadow.ImageLabel.Visible = true
					window.shadow.glow.Visible = false
					window.shadow.glow1.Visible = false

					if bluron then
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

					syde:BindFrame(window, {
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

					bluron = true

				else
					window.shadow.ImageLabel.Visible = true
					window.BackgroundTransparency = 0

					window.pages.v1.Visible = true
					window.pages.v0.Visible = true

					window.pages.clipframe.v1.Visible = true
					window.pages.clipframe.v0.Visible = true

					syde:UnbindFrame(window)

					bluron = false
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
						tweenservice:Create(window.shadow.ImageLabel, TweenInfo.new(0.65, Enum.EasingStyle.Exponential), {ImageTransparency = v}):Play()
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
			Value = LockToScreen,
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
			SFlag = 'WALLP',
		})

		a:TextInput({
			Title = 'Wallpaper ID';
			NumberOnly = true;
			PlaceHolder = 'Input your wallpaper ID here.';
			CallBack = function (v)
				if v then
					window.wallpaper.Image = 'rbxassetid://'..v
					syde:Toast({
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
			Value = true,
			CallBack = function (v)
				local wm = ui:FindFirstChild('minihome')
				if wm then
					wm.Visible = v
				end
			end,
			SFlag = 'WTRMK'
		})


		--// SERVICES
		local HttpService = game:GetService("HttpService")

		--// CONFIG
		local isDev = false
		local baseUrl = isDev and "http://localhost:3000" or "https://syde-auth.vercel.app"
		local loginUrl = baseUrl .. "/api/login"
		local VERIFY_ENDPOINT = baseUrl .. "/api/verify?id="

		--// STATE
		local currentDiscordId = nil
		local lastCheck = 0
		local debounceTime = 1.5 -- seconds

		--// FUNCTION: open URL safely
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
					Duration = 5
				})
			end
		end

		--// BUTTON: Open OAuth
		b:Button({
			Title = "Connect Discord",
			Description = "Authenticate your Discord account.",
			CallBack = function()
				openURL(loginUrl)
			end,
		})

		local function verifyDiscord(id)
			-- Try Roblox GetAsync first
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

			-- Fallback: executor HTTP
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

		--// INPUT: Discord ID verification
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

				-- Debounce
				if tick() - lastCheck < debounceTime then
					return
				end
				lastCheck = tick()

				-- Show checking
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
							Duration = 4
						})
					else
						window.user.headshot.Status.BackgroundColor3 = Color3.fromRGB(255, 101, 104)
						syde:Notify({
							Title = "Verification Failed",
							Content = "Discord ID is not verified",
							Duration = 4
						})
					end
				end)
			end,
		})


		function syde:SaveSettingsConfig()
			local Data = {}


			for flag, v in pairs(syde.SettingsFlags or {}) do

				if v.Type == "ColorPicker" and v.Color then
					Data[flag] = syde:ColorPack(v.Color)
				elseif v.V ~= nil then
					Data[flag] = v.V
				elseif v.StarterValue ~= nil then
					Data[flag] = v.StarterValue
				else
					warn("[DEBUG] Skipping flag", flag, "no valid value found")
				end
			end


			local path = string.format("%s/SettingsConfig.lua", syde.ConfigFolder)
			local encoded = https:JSONEncode(Data)

			writefile(path, encoded)

			syde:Toast({
				Content = 'Saved setting config';
				Duration = 3
			})
		end

		function syde:LoadSettingsConfig()
			local path = string.format("%s/SettingsConfig.lua", syde.ConfigFolder)

			if not isfile(path) then

				syde:Toast({
					Content = 'No settings found';
					Duration = 3
				})
				return
			end

			local success, data = pcall(function()
				return https:JSONDecode(readfile(path))
			end)

			if not success or typeof(data) ~= "table" then
				warn("[DEBUG] Failed to decode settings:", data)
				return
			end

			for flag, val in pairs(data) do
				local setting = syde.SettingsFlags and syde.SettingsFlags[flag]
				if setting then
					if setting.Set then
						setting:Set(val)
					elseif setting.Type == "ColorPicker" and setting.Color then
						setting.Color = syde:ColorUnpack(val)
					elseif setting.V ~= nil then
						setting.Value = val
					end
				else
					warn("[DEBUG] No matching setting flag found for:", flag)
				end
			end

			syde:Toast({
				Content = 'Loaded setting config';
				Duration = 3
			})
		end

		-- // Configurations
		local currentConfigName = syde.ConfigFile or "Config"
		local selectedConfig
		local autoloadEnabled = syde:GetAutoLoad() and true or false
		local autoloadButtonRef
		local configDropdownData

		local function refreshConfigList()
			if configDropdownData and configDropdownData.SetOptions then
				configDropdownData:SetOptions(syde:ListConfigs() or {})
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
			return syde.ConfigFile
		end

		a:Button({
			Title = 'Save',
			CallBack = function ()
				local name = (currentConfigName and currentConfigName ~= "") and currentConfigName or syde.ConfigFile
				syde:SaveConfigAs(name)
				syde:SaveSettingsConfig()
				refreshConfigList()
			end
		})
		a:Button({
			Title = 'Load',
			CallBack = function ()
				local name = resolveConfigName()
				syde:LoadSaveConfig(name)
				syde:LoadSettingsConfig()
			end
		})
		a:Button({
			Title = 'AutoLoad',
			CallBack = function ()
				autoloadEnabled = not autoloadEnabled
				syde:SetAutoLoad(autoloadEnabled)
				updateAutoLoadLabel()
				if syde.Toast then
					syde:Toast({ Content = 'AutoLoad: ' .. (autoloadEnabled and 'ON' or 'OFF'), Duration = 3 })
				end
			end
		})
		a:Button({
			Title = 'Overwrite',
			CallBack = function ()
				local name = resolveConfigName()
				if not name or name == "" then
					if syde.Toast then syde:Toast({ Content = 'No config to overwrite', Duration = 3 }) end
					return
				end
				syde:SaveConfigAs(name)
				syde:SaveSettingsConfig()
				if syde.Toast then syde:Toast({ Content = 'Overwrote: ' .. name, Duration = 3 }) end
				refreshConfigList()
			end
		})

		-- Arrange the four buttons in a 2x2 grid
		do
			local themePage = window.settings.pages:FindFirstChild('Theme')
			if themePage then
				local saveBtn = themePage:FindFirstChild('Save')
				local loadBtn = themePage:FindFirstChild('Load')
				local autoloadBtn = themePage:FindFirstChild('AutoLoad')
				local overwriteBtn = themePage:FindFirstChild('Overwrite')
				autoloadButtonRef = autoloadBtn
				updateAutoLoadLabel()

				local grid = Instance.new('Frame')
				grid.Name = 'ConfigButtons'
				grid.BackgroundTransparency = 1
				grid.BorderSizePixel = 0
				grid.Size = UDim2.new(1, -35, 0, 90)
				grid.Parent = themePage

				local gridLayout = Instance.new('UIGridLayout')
				gridLayout.CellSize = UDim2.new(0.5, -5, 0, 40)
				gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
				gridLayout.FillDirectionMaxCells = 2
				gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
				gridLayout.Parent = grid

				for i, btn in ipairs({saveBtn, loadBtn, autoloadBtn, overwriteBtn}) do
					if btn then
						btn.Parent = grid
						btn.LayoutOrder = i
					end
				end
			end
		end

		a:TextInput({
			Title = 'Config Name',
			PlaceHolder = 'Enter config name',
			ClearOnLost = false,
			CallBack = function (v)
				currentConfigName = v
			end
		})

		configDropdownData = a:Dropdown({
			Title = 'Saved Configs',
			Options = syde:ListConfigs() or {},
			PlaceHolder = 'Select a config',
			CallBack = function (v)
				selectedConfig = v
			end
		})

		b:Toggle({
			Title = 'Anonymous',
			Description = 'Hides your info in User Info.',
			CallBack = function (v)
				if v then
					window.user.headshot.id.username.Text = '?'
					window.user.headshot.id.displayname.Text = '@?'
					window.user.headshot.Image = 'rbxassetid://139956761561818'
				else
					SetUserInfo()
				end
			end,
			SFlag = 'ANON',
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

		ss = syde:AddConnection(runservice.Heartbeat, function()
			local uptime = tick() - startTime
			local formatted = formatTime(uptime)
			uptimeParagraph:Set("Session Uptime: " .. formatted, 'Session UpTime')
		end)

	end


	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		screenSize = workspace.CurrentCamera.ViewportSize
		isMobile = userinput.TouchEnabled
		updateLayout()
	end)

	updateLayout()

	camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayout)
	userinput:GetPropertyChangedSignal("TouchEnabled"):Connect(updateLayout)

	--@@Tabs
	local tbdata = {
		first = false,
		selected = false
	}

	function tbdata:InitTab(tab)
		-- bootstrap Home-mode once so first-created tabs don't auto-open

		if Data.Home.Enabled then
			if not tbdata.__homeBootstrapped then
				tbdata.__homeBootstrapped = true
				tbdata.first = "Home"
				tbdata.homeActive = true
				-- hide all normal pages on boot
				for _, temp in ipairs(pages:GetChildren()) do
					if temp:IsA("ScrollingFrame") then
						temp.Visible = false
					end
				end
				-- ensure homepage is visible if present
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

		--[Tab Setup]
		local Tab = tabs.btn:Clone()
		Tab.Visible = true
		Tab.Parent = tabs
		Tab.title.Text = tdata.Title
		Tab.Name = tdata.Title

		Tab.title.TextTransparency = 1
		Tab.indicator.BackgroundTransparency = 1

		--[Page Setup]
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
			local titleLabel = pages.clipframe.title
			titleLabel.Text = Name
			titleLabel.Position = UDim2.new(0, 5, 0.5, 4)
			titleLabel.TextTransparency = 0.3

			tweenservice:Create(titleLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {
				Position = UDim2.new(0, 5, 0.5, 0),
				TextTransparency = 0
			}):Play()
		end

		if isFirstTab then
			ChangeName(tdata.Title)
			Page.Visible = true
			tbdata.first = tdata.Title
		end

		if tbdata.first then
			tweenservice:Create(Tab.title, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { TextTransparency = 0.52 }):Play()
			tweenservice:Create(Tab, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.45 }):Play()
			tweenservice:Create(Tab.indicator, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
			tweenservice:Create(Tab.indicator.glow, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
			tweenservice:Create(Tab, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Size = UDim2.new(0, Tab.title.TextBounds.X + 30,0, 35) }):Play()
		else
			tbdata.first = tdata.Title
			tweenservice:Create(Tab.title, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
			tweenservice:Create(Tab, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
			tweenservice:Create(Tab.indicator, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
			tweenservice:Create(Tab.indicator, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), { BackgroundColor3 = syde.theme.Accent }):Play()
			tweenservice:Create(Tab.indicator.glow, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), { ImageColor3 = syde.theme.Accent }):Play()
			tweenservice:Create(Tab, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Size = UDim2.new(0, Tab.title.TextBounds.X + 80,0, 35) }):Play()
		end


		local positionTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint)
		local colorTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint)
		local HomeButton = (window and window.tabs and window.tabs.Home) and window.tabs.Home or nil
		local HomePage = (window and window.pages and window.pages.home) and window.pages.home or nil

		local function ApplyHomeButtonStyle(isActive)
			if not HomeButton or not HomeButton.homeicon:FindFirstChild("ImageLabel") then
				return
			end

			if isActive then
				--	tweenservice:Create(HomeButton.text, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
				tweenservice:Create(HomeButton.homeicon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.45 }):Play()
				tweenservice:Create(HomeButton.homeicon.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0 }):Play()
			else
				--	tweenservice:Create(HomeButton.text, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0.67 }):Play()
				tweenservice:Create(HomeButton.homeicon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.85 }):Play()
				tweenservice:Create(HomeButton.homeicon.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.67 }):Play()
			end
		end

		local function ApplyTabStyle(tabButton, isSelected)
			local targetTextTransparency = isSelected and 0 or 0.6
			local targetBackgroundTransparency = isSelected and 0 or 0.45
			local targetColor = isSelected and syde.theme.Accent or Color3.fromRGB(29, 29, 29)
			local targetSize = isSelected and UDim2.new(0, tabButton.title.TextBounds.X + 80, 0, 35) or UDim2.new(0, tabButton.title.TextBounds.X + 50, 0, 35)

			tweenservice:Create(tabButton, positionTweenInfo, { Size = targetSize }):Play()
			tweenservice:Create(tabButton, colorTweenInfo, { BackgroundTransparency = targetBackgroundTransparency }):Play()
			tweenservice:Create(tabButton.title, colorTweenInfo, { TextTransparency = targetTextTransparency }):Play()
			tweenservice:Create(tabButton.indicator.glow, colorTweenInfo, { ImageColor3 = targetColor }):Play()
			tweenservice:Create(tabButton.indicator.glow, colorTweenInfo, { ImageTransparency = isSelected and 0.78 or 1 }):Play()

			tweenservice:Create(tabButton.indicator, colorTweenInfo, { BackgroundColor3 = targetColor }):Play()
			tweenservice:Create(tabButton.indicator, colorTweenInfo, { BackgroundTransparency = isSelected and 0 or 1 }):Play()
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
				pcall(function() tweenservice:Create(HomePage, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 }):Play() end)
			end

			ApplyHomeButtonStyle(true)
			window.pages.clipframe.Visible = false
			--	window.pages.v0.Visible = false
			--	window.pages.v1.Visible = false
		end

		local function HideHomeForTab()
			tbdata.homeActive = false

			if HomePage and HomePage.Visible then
				-- hide immediately to prevent overlap flicker
				HomePage.Visible = false  

				-- optional: still tween background transparency for smoothness
				pcall(function() 
					HomePage.BackgroundTransparency = 1 
				end)
			end

			ApplyHomeButtonStyle(false)
			window.pages.clipframe.Visible = true
			--	window.pages.v0.Visible = true
			--	window.pages.v1.Visible = true
		end

		if tbdata.first == 'Home' then
			ShowHome()
		end

		-- Hook Home button click once (if present)
		if HomeButton and HomeButton.homeicon:FindFirstChild("interact") and not tbdata.__homeHooked then
			tbdata.__homeHooked = true
			HomeButton.homeicon.interact.MouseButton1Click:Connect(function()
				if tbdata.homeActive then return end 

				-- Force-hide all locked pages
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

			-- Hide Home if active
			if Data.Home.Enabled and tbdata.homeActive then
				HideHomeForTab()
			end

			local previous = tbdata.first
			tbdata.first = tdata.Title

			-- Instant page switch: immediately show target page and hide others
			for _, otherPage in ipairs(pages:GetChildren()) do
				if otherPage:IsA("ScrollingFrame") then
					otherPage.Visible = (otherPage == Page)
				end
			end
			Page.Visible = true

			-- Fast title animation
			ChangeName(tdata.Title)

			-- Replay element animations asynchronously for this page only
			task.spawn(function()
				syde:replayLoadTweens(Page)
			end)

			-- Snappy tab button indicator & size update
			for _, otherTab in ipairs(tabs:GetChildren()) do
				if otherTab:IsA("Frame") then
					ApplyTabStyle(otherTab, otherTab == Tab)
					otherTab.interact.Active = true
				end
			end
		end)

		syde:AddConnection(syde.Comms.Event, function(p, color)
			if p == 'Accent' then
				if tbdata.first ~= tdata.Title then return end

				-- live accent update
				tweenservice:Create(Tab.indicator, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					BackgroundColor3 = color
				}):Play()

				tweenservice:Create(Tab.indicator.glow, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					ImageColor3 = color
				}):Play()
			end
		end)

		local function SwitchToTab(tabName)
			local selectedTab
			local targetPage

			-- find tab
			for _, tab in ipairs(tabs:GetChildren()) do
				if tab:IsA("Frame") and tab.Name == tabName then
					selectedTab = tab
					break
				end
			end

			-- find page
			targetPage = pages:FindFirstChild(tabName)
			if not (selectedTab and targetPage) then
				warn("[UI] SwitchToTab failed:", tabName)
				return
			end

			-- already selected
			if tbdata.first == tabName then
				return
			end

			-- hide the Home screen if we're jumping straight from it (e.g. via search)
			if Data.Home.Enabled and tbdata.homeActive then
				HideHomeForTab()
			end

			-- update title (same logic as click)
			ChangeName(tabName)

			-- hide all pages
			for _, page in ipairs(pages:GetChildren()) do
				if page:IsA("ScrollingFrame") then
					page.Visible = false
				end
			end

			-- show page
			targetPage.Visible = true
			tbdata.first = tabName

			-- update tab styles
			for _, tab in ipairs(tabs:GetChildren()) do
				if tab:IsA("Frame") then
					ApplyTabStyle(tab, tab == selectedTab)
					tab.interact.Active = true
				end
			end

			-- replay load tweens like normal click
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
				-- Ensure we always have the opened page, even if already on it

				closesearch()

				local openedPage = ui.main.pages:FindFirstChild(page.Name)
				if not openedPage or not openedPage:IsA("ScrollingFrame") then return end

				-- Optional: switch tab visuals (if SwitchToTab does this)
				SwitchToTab(page.Name)

				task.wait(0.05) -- small delay to allow UI to update

				-- Calculate scroll position
				local y = func.AbsolutePosition.Y - openedPage.AbsolutePosition.Y + openedPage.CanvasPosition.Y

				-- Scroll to the function
				tweenservice:Create(
					openedPage,
					TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{ CanvasPosition = Vector2.new(0, math.max(0, y - 20)) }
				):Play()

				-- Highlight flash
				local original = func.BackgroundColor3
				tweenservice:Create(func, TweenInfo.new(0.2), {
					BackgroundColor3 = syde:GetLighter(original, 0.03)
				}):Play()

				task.delay(0.35, function()
					tweenservice:Create(func, TweenInfo.new(0.35), {
						BackgroundColor3 = original
					}):Play()
				end)
			end)

			result.MouseEnter:Connect(function()
				tweenservice:Create(result.ImageLabel, TweenInfo.new(0.2), {
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()

				--	tweenservice:Create(result.UIStroke, TweenInfo.new(0.2), {Thickness = 1}):Play()
			end)

			result.MouseLeave:Connect(function()
				tweenservice:Create(result.ImageLabel, TweenInfo.new(0.2), {
					ImageColor3 = Color3.fromRGB(130, 130, 130)
				}):Play()
				--	tweenservice:Create(result.UIStroke, TweenInfo.new(0.2), {Thickness = 0}):Play()
			end)

			-- tweenservice:Create(result, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			tweenservice:Create(result.info.badge, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			tweenservice:Create(result.info.title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			tweenservice:Create(result.info.badge["function"], TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
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
			--	window.search.Size = UDim2.new(0, 350,0, 230)
			tweenservice:Create(window.search, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {Size =  UDim2.new(0, 350,0, 230)}):Play()
			tweenservice:Create(window.search.UICorner, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {CornerRadius =  UDim.new(0,25)}):Play()
			if SearchBox.Text == '' then
				tweenservice:Create(window.search, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {Size =  UDim2.new(0, 350,0,60)}):Play()
				tweenservice:Create(window.search.UICorner, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {CornerRadius =  UDim.new(1,0)}):Play()
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


		-- ensure new tabs start disabled visually (Home is handled by bootstrap)
	--[[	if Data.Home.Enabled then
			ApplyTabStyle(Tab, false)
		else
			ApplyTabStyle(Tab, isFirstTab)
		end
	end]]

		local initelement = {}


		--@@Button
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
				-- UI Stroke effect on button press

				button.interact.MouseButton1Down:Connect(function()
					tweenservice:Create(button.UIStroke, fOTween, { Transparency = 1 }):Play()
					tweenservice:Create(button.ImageLabel, fOTween, { ImageTransparency = 1 }):Play()
					tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
				end)

				button.interact.MouseButton1Up:Connect(function()
					tweenservice:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
					tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()


				end)

				button.interact.MouseButton1Click:Connect(function()
					if data.CallBack then
						local success, errorMsg = pcall(c)
						if not success then
							syde:Report("Button '" .. button.Name .. "' callback", errorMsg)

						end
					else
						warn(`[ CallBack Missing: { button.Name } ] No Function Assigned`)
					end
				end)

				-- Extra Check 
				button.interact.MouseLeave:Connect(function()
					tweenservice:Create(button.UIStroke, fITween, { Transparency = 0 }):Play()
					tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()
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
					tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 0.95 }):Play()
					tweenservice:Create(button.title.timer, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
					if not Complete then
						tweenservice:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
						tweenservice:Create(button.UIStroke.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()
						tweenservice:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,-15 ,0 ,button.Position.Y.Offset) }):Play()
						task.wait(0.15)
						tweenservice:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,30 ,0 ,button.Position.Y.Offset) }):Play()
						task.wait(0.15)
						tweenservice:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = UDim2.new(0 ,0 ,0 ,button.Position.Y.Offset) }):Play()
						task.wait(1)
						tweenservice:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0 }):Play()
					end

					-- did not complete 

					--	button.UIStroke.UIGradient.Offset = Vector2.new(-1, 0)
					--	tweenservice:Create(button.UIStroke, TweenInfo.new(HoldTime, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()

					TimeLeft = HoldTime
					button.title.timer.Text = tostring(HoldTime)
					task.wait(0.1)
					Complete = false
				end

				button.interact.MouseButton1Down:Connect(function()

					Holding = true
					TimeLeft = HoldTime
					button.title.timer.Text = tostring(TimeLeft)
					tweenservice:Create(button.ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
					tweenservice:Create(button.title.timer, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
					tweenservice:Create(button.UIStroke.UIGradient, TweenInfo.new(HoldTime, Enum.EasingStyle.Linear), { Offset = Vector2.new(0.7, 0) }):Play()
					tweenservice:Create(button.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0}):Play()

					-- Countdown loop
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

						tweenservice:Create(button, TweenInfo.new(0.34, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }):Play()
						tweenservice:Create(button.UIStroke.UIGradient, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { Offset = Vector2.new(-1, 0) }):Play()
						task.wait(0.34)
						tweenservice:Create(button, TweenInfo.new(0.34, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }):Play()
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

			--[DESC]
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
						local newButtonSize = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, 0, button.title.Size.Y.Offset + textSize.Y + 10)

						local descTween = tweenservice:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
						descTween:Play()

						local buttonTween = tweenservice:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
						buttonTween:Play()
					end

					updateSize()

					descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
				else
					descLabel.Visible = false
				end
			end

			local btnObj = {
				Frame = button,
				Set = function(self, newText)
					button.title.Text = tostring(newText or "")
				end,
				toggle = function(self)
					button.Visible = not button.Visible
				end,
				remove = function(self)
					button:Destroy()
				end,
			}
			return btnObj
		end

		--@@Toggle
		function initelement:Toggle(Toggle)
			local data = {
				Title = Toggle.Title or "Temp Toggle";
				Desc = Toggle.Description or "";
				V = Toggle.Value or false;
				Config = Toggle.Config or false;
				CallBack = Toggle.CallBack;
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
			tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,0, 25) }):Play()

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
				local targetColor = state and syde.theme.HitBox or Color3.fromRGB(28, 28, 28)
				local strokeTransparency = state and 1 or 0
				local checkTransparency = state and 0 or 1
				local gradientTransparency = state and 0 or 1
				local glowTransparency = state and 0.7 or 1
				local textTransparency = state and 0 or 0.5

				tweenservice:Create(toggle.tog, toggleTween, { BackgroundColor3 = targetColor }):Play()
				--	tweenservice:Create(toggle.tog.UIStroke, toggleTween, { Transparency = strokeTransparency }):Play()
				tweenservice:Create(toggle.tog.check, toggleTween, { ImageTransparency = checkTransparency }):Play()
				tweenservice:Create(toggle.tog.gradfr, fadeTween, { BackgroundTransparency = gradientTransparency }):Play()
				tweenservice:Create(toggle.tog.glow, toggleTween, { ImageTransparency = glowTransparency }):Play()
				tweenservice:Create(toggle.tog.glow, toggleTween, { ImageColor3 = targetColor }):Play()
				tweenservice:Create(toggle.title, toggleTween, { TextTransparency = textTransparency }):Play()
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
					syde:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
				end
			end)

			--[DESC]
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
						local newButtonSize = UDim2.new(toggle.Size.X.Scale, toggle.Size.X.Offset, 0, toggle.title.Size.Y.Offset + textSize.Y + 10) -- Adding extra padding

						local descTween = tweenservice:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
						descTween:Play()

						local ToggleTween = tweenservice:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
						ToggleTween:Play()
					end

					updateSize()

					descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
				else
					descLabel.Visible = false
				end
			end


			-- [CONFIGURATIPON]
			if data.Config then

				local State = false

				local enterTween = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)

				toggle.configure.MouseEnter:Connect(function()
					tweenservice:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end)

				toggle.configure.MouseLeave:Connect(function()
					tweenservice:Create(toggle.configure, enterTween, { ImageColor3 = Color3.fromRGB(104, 104, 104) }):Play()
				end)

				local function ToggleConfigOpen()
					toggleConfiguration.Visible = true
					State = true

					tweenservice:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 0 }):Play()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 0 }):Play()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 0 }):Play()
					tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, enterTween, { ImageTransparency = 0 }):Play()
					tweenservice:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 0 }):Play()
					tweenservice:Create(toggleConfiguration, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 174,0, 88) }):Play()
					--	tweenservice:Create(toggleConfiguration.shadow.ImageLabel, enterTween, { ImageTransparency = 0.57 }):Play()

				end

				local function ToggleConfigClose()
					State = false

					tweenservice:Create(toggleConfiguration, enterTween, { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Title, enterTween, { TextTransparency = 1 }):Play()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind, enterTween, { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.UIStroke, enterTween, { Transparency = 1 }):Play()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, enterTween, { TextTransparency = 1 }):Play()
					tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, enterTween, { ImageTransparency = 1 }):Play()
					tweenservice:Create(toggleConfiguration.Container.Clear.Title, enterTween, { TextTransparency = 1 }):Play()
					tweenservice:Create(toggleConfiguration, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 75,0, 53) }):Play()
					--	tweenservice:Create(toggleConfiguration.shadow.ImageLabel, enterTween, { ImageTransparency = 1 }):Play()
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
						TogService = runservice.RenderStepped:Connect(function()
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
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { Size = UDim2.new(0, toggleConfiguration.Container.KeyBind.Bind.v.TextBounds.X + 20,0, 25) }):Play()
				end

				local function setKeybind(key)
					if not key then
						toggleConfiguration.Container.KeyBind.Bind.v.Text = 'None'
						ResizeBindFrame()
						data.Keybind = nil
					else
						data.Keybind = key
						data.KeybindReady = false

						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
						toggleConfiguration.Container.KeyBind.Bind.v.Text = key.Name
						tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
						ResizeBindFrame()

						task.delay(0.5, function()
							data.KeybindReady = true
						end)
					end
				end

				toggleConfiguration.Container.KeyBind.Interact.MouseButton1Click:Connect(function()
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
					task.wait(0.2)
					toggleConfiguration.Container.KeyBind.Bind.v.Text = "..."
					tweenservice:Create(toggleConfiguration.Container.KeyBind.Bind.v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
					ResizeBindFrame()


					local connection
					connection = userinput.InputBegan:Connect(function(input, processed)
						if not userinput:GetFocusedTextBox() and syde:IsBindableInput(input) then
							setKeybind(input.KeyCode)
							connection:Disconnect()
						end
					end)
				end)

				userinput.InputBegan:Connect(function(input, processed)
					if not userinput:GetFocusedTextBox() and data.Keybind and data.KeybindReady and input.KeyCode == data.Keybind then
						data.V = not data.V
						UpdateToggleUI(data.V)

						if data.CallBack then
							local success, errorMsg = pcall(function()
								data.CallBack(data.V)
							end)
							if not success then
								syde:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
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
						tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = 13 }):Play()
						task.wait(0.2)
						tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = -13 }):Play()
						task.wait(0.2)
						tweenservice:Create(toggleConfiguration.Container.Clear.clear.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Rotation = 0 }):Play()
					end

					blink()

					task.delay(2, function()
						debounce2 = false
					end)
				end)

				toggleConfiguration.Container.Clear.MouseEnter:Connect(function()
					tweenservice:Create(toggleConfiguration.Container.Clear.clear, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.9 }):Play()
				end)

				toggleConfiguration.Container.Clear.MouseLeave:Connect(function()
					tweenservice:Create(toggleConfiguration.Container.Clear.clear, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
				end)

			end

			syde:AddConnection(syde.Comms.Event, function(p, color)
				if p == 'HitBox' then
					if data.V then
						toggle.tog.BackgroundColor3 = color
						toggle.tog.glow.ImageColor3 = color
					end
				end
			end)

			function data:Set(NewValue, skipSave)
				data.V = NewValue
				UpdateToggleUI(NewValue)

				if data.CallBack then
					local success, errorMsg = pcall(function()
						data.CallBack(data.V)
					end)
					if not success then
						syde:Report("Toggle '" .. toggle.Name .. "' callback", errorMsg)
					end
				end

				if not skipSave and data.Flag and SaveConfig then
					SaveConfig()
				end
			end

			if syde.ConfigEnabled and data.Flag then
				syde.Flags[data.Flag] = data
				if syde.LoadedConfig and syde.LoadedConfig[data.Flag] ~= nil then
					data:Set(syde.LoadedConfig[data.Flag], true)
				end
			end

			return data
		end


		--@@Slider
		function initelement:Slider(Slider)
			local data = {
				Title = Slider.Title;
				Desc = Slider.Description;
				Sliders = Slider.Sliders
			}

			local slider = pages.page.Slider:Clone()
			slider.Visible = true
			slider.Parent = Page
			slider.title.Text = data.Title
			slider.Name = data.Title
			slider.slideholder.slider.Visible = false
			slider:SetAttribute("Searchable", true)


			--[SLIDERS INITIALIZE]
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

				syde:registerLoadTween(
					Slider.slide.slideframe,
					{Size = UDim2.new(SliderPosition, 0, 1, 0)},
					{Size = UDim2.new(0, 100,1, 0)},
					TweenInfo.new(0.85, Enum.EasingStyle.Quint)
				)

				syde:replayLoadTweens(Slider.slide.slideframe)

				local decimalPlaces = syde:DecimalPlaces(Options.Increment)
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

					-- wait for UI to size properly
					task.wait()

					local width = ticksFrame.AbsoluteSize.X
					local height = ticksFrame.AbsoluteSize.Y


					local spacing = width / (tickCount - 1)

					-- Reuse existing ticks instead of destroying all
					local existingTicks = {}
					for _, child in ipairs(ticksFrame:GetChildren()) do
						if child:IsA("Frame") and child ~= template then
							table.insert(existingTicks, child)
						end
					end

					-- Create new ticks if needed
					for i = 0, tickCount - 1 do
						local tick = existingTicks[i + 1] or template:Clone()
						tick.Visible = true
						tick.AnchorPoint = Vector2.new(0.5, 0.5)
						tick.BorderSizePixel = 0
						--	tick.BackgroundTransparency = 1
						tick.Parent = ticksFrame

						local finalPos = UDim2.fromOffset(i * spacing, height / 1.5)
						tweenservice:Create(
							tick,
							TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Position = finalPos,
								BackgroundTransparency = 0.85
							}
						):Play()
					end

					-- Destroy extra ticks
					for i = tickCount + 1, #existingTicks do
						existingTicks[i]:Destroy()
					end

				end

				-- Connect AbsoluteSize change **only once**
				if Options.Increment > 4 then
					if not Slider.slide.Ticks:FindFirstChild("_ResizeConnection") then
						local conn = Slider.slide.Ticks:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
							BuildTicks(Slider.slide, Options)
						end)
						-- Tag the connection so we don't connect again
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
						newValue = syde:RoundTo(newValue, syde:DecimalPlaces(Options.Increment))

						-- Update the slider visual position
						local snapPosition = (newValue - Options.Range[1]) / range
						Slider.slide.slideframe:TweenSize(UDim2.new(snapPosition, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.55, true)

						syde:registerLoadTween(
							Slider.slide.slideframe,
							{Size = UDim2.new(snapPosition, 0, 1, 0)},
							{Size = UDim2.new(0, 100,1, 0)},
							TweenInfo.new(0.85, Enum.EasingStyle.Quint)
						)


						-- Update the displayed value
						local decimalPlaces = syde:DecimalPlaces(Options.Increment)
						Slider.v.Text = string.format("<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>", newValue, Options.Range[2])

						tweenservice:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

						local success, errorMsg = pcall(function()
							Options.CallBack(newValue)
						end)
						if not success then
							syde:Report("Slider '" .. Slider.Name .. "' callback", errorMsg)
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

				syde:AddConnection(userinput.InputEnded, function(input, processed)
					if input.UserInputType == Enum.UserInputType.MouseButton1  or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						tweenservice:Create(Slider.Title, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { TextTransparency = 0.6 }):Play()
					end
				end)

				syde:AddConnection(userinput.InputChanged, function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement  or input.UserInputType == Enum.UserInputType.Touch  then
						UpdateSlider(input.Position.X)
					end
				end)

				Slider.slide.slideframe.BackgroundColor3 = syde.theme.HitBox
				Slider.slide.slideframe.shadowHolder.ambientShadow.ImageColor3 = syde.theme.HitBox
				Slider.slide.slideframe.shadowHolder.penumbraShadow.ImageColor3 = syde.theme.HitBox
				Slider.slide.slideframe.shadowHolder.umbraShadow.ImageColor3 = syde.theme.HitBox
				slider.slideholder.Size = UDim2.new(1,-30,0,slider.slideholder.UIListLayout.AbsoluteContentSize.Y)
				local ss = slider.slideholder.UIListLayout.AbsoluteContentSize.Y
				slider.Size = UDim2.new(1,-35,0, ss  + 20)

				syde:AddConnection(syde.Comms.Event, function(p, color)
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

					-- Register load tween
					syde:registerLoadTween(
						Slider.slide.slideframe,
						{Size = UDim2.new(sliderPosition, 0, 1, 0)},
						{Size = UDim2.new(0, 100, 1, 0)},
						TweenInfo.new(0.85, Enum.EasingStyle.Quint)
					) 

					-- Update value display
					local decimalPlaces = syde:DecimalPlaces(Options.Increment)
					Slider.v.Text = string.format("<font size='14'>%." .. decimalPlaces .. "f</font><font color='#434343'>/%." .. decimalPlaces .. "f</font>", NewVal, Options.Range[2])

					-- Tween title appearance
					tweenservice:Create(Slider.Title, TweenInfo.new(0.55, Enum.EasingStyle.Exponential), {
						TextTransparency = 0
					}):Play()

					-- Callback
					local success, result = pcall(function()
						Options.CallBack(NewVal)
					end)
					if not success then
						syde:Report("Slider '" .. slider.Name .. "' callback", result)
					end

					Options.StarterValue = NewVal

					if not skipSave and Options.Flag and SaveConfig then
						SaveConfig()
					end
				end

				-- click the value to type a custom number (reverts if outside range)
				syde:AttachSliderInput(Slider, Options)

				if syde.ConfigEnabled and Options.Flag then
					syde.Flags[Options.Flag] = Options
					if syde.LoadedConfig and syde.LoadedConfig[Options.Flag] ~= nil then
						Options:Set(syde.LoadedConfig[Options.Flag], true)
					end
				end

			end

			--[DESC]
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
						local newButtonSize = UDim2.new(slider.Size.X.Scale, slider.Size.X.Offset, 0,slider.slideholder.AbsoluteSize.Y + slider.title.Size.Y.Offset + textSize.Y + 15) -- Adding extra padding

						local descTween = tweenservice:Create(descLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
						descTween:Play()

						local ToggleTween = tweenservice:Create(slider, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
						ToggleTween:Play()
					end

					updateSize()

					descLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
				else
					descLabel.Visible = false
				end
			end

			local sldObj = {
				Frame = slider,
				Value = (data.Sliders and data.Sliders[1] and data.Sliders[1].Value) or 0,
				Set = function(self, val)
					if data.Sliders and data.Sliders[1] and data.Sliders[1].CallBack then
						data.Sliders[1].Value = val
						pcall(data.Sliders[1].CallBack, val)
					end
				end,
				SetName = function(self, n)
					slider.title.Text = tostring(n or "")
				end,
				toggle = function(self)
					slider.Visible = not slider.Visible
				end,
				remove = function(self)
					slider:Destroy()
				end,
			}
			return sldObj
		end

		--@@KeyBind
		function initelement:Keybind(Keybind)
			local data = {
				Title = Keybind.Title;
				Key = Keybind.Key;
				Desc = Keybind.Description or "";
				CallBack = Keybind.CallBack;
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

			KeyBind.Bind.v.Text = data.Key and data.Key.Name or "NONE"
			tweenservice:Create(KeyBind.Bind, TweenInfo.new(0.55, Enum.EasingStyle.Quint ), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()

			KeyBind.interact.MouseButton1Click:Connect(function()
				KeyBind.Bind.v.Text = '...'
				tweenservice:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Thickness = 1}):Play()
				data.WaitingForKey = true
			end)

			KeyBind.Bind.v:GetPropertyChangedSignal('TextBounds'):Connect(function()
				tweenservice:Create(KeyBind.Bind, TweenInfo.new(0.55, Enum.EasingStyle.Quint ), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()
			end)

			data.Flag = Keybind.Flag
			data.Type = "Keybind"

			function data:Set(keyCode, skipSave)
				data:SetKeybind(keyCode, skipSave)
			end

			function data:SetKeybind(keyCode, skipSave)
				if typeof(keyCode) == "string" then
					keyCode = Enum.KeyCode[keyCode]
				end
				if keyCode and keyCode ~= Enum.KeyCode.Unknown then
					data.Key = keyCode
					KeyBind.Bind.v.Text = keyCode.Name
				else
					data.Key = nil
					KeyBind.Bind.v.Text = "NONE"
				end
				tweenservice:Create(KeyBind.Bind, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, KeyBind.Bind.v.TextBounds.X + 30, 0, KeyBind.Bind.Size.Y.Offset)}):Play()
				if not skipSave and data.Flag and SaveConfig then
					SaveConfig()
				end
			end

			local function SetKeybind(keyCode)
				tweenservice:Create(KeyBind.Bind.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Thickness = 0}):Play()
				data:SetKeybind(keyCode)
			end

			-- Main input handler
			syde:AddConnection(userinput.InputBegan, function(input, processed)
				if data.WaitingForKey then
					if syde:IsBindableInput(input) then
						data.WaitingForKey = false
						SetKeybind(input.KeyCode)
					end
					return
				end

				-- don't fire the bind while typing in a textbox (ignore processed so
				-- keys the game also uses, e.g. RightShift shift-lock, still work)
				if userinput:GetFocusedTextBox() then return end
				if input.KeyCode == Enum.KeyCode.Unknown then return end

				if input.KeyCode == data.Key then
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
							syde:Report("Keybind '" .. KeyBind.Name .. "' callback", result)
						end
					else
						if data.Hold then
							local holdLoop
							holdLoop = runservice.RenderStepped:Connect(function()
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

			if syde.ConfigEnabled and data.Flag then
				syde.Flags[data.Flag] = data
				if syde.LoadedConfig and syde.LoadedConfig[data.Flag] ~= nil then
					local savedKey = syde.LoadedConfig[data.Flag]
					data:SetKeybind(savedKey, true)
				end
			end

			return data
		end

		--@@TextInput
		function initelement:TextInput(TextInput)
			local data = {
				Title = TextInput.Title or "Text Input",
				PlaceHolder = TextInput.PlaceHolder or "Enter text...",
				NumbersOnly = TextInput.NumberOnly or false,
				ClearOnLost = TextInput.ClearOnLost == nil and true or TextInput.ClearOnLost,
				--	MaxSize = TextInput.MaxSize or 100,
				CallBack = TextInput.CallBack,
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
			--	local maxHeight = data.MaxSize
			local ignoreNextClear = false



			textinput.TextFrame.Enter.MouseEnter:Connect(function()
				tweenservice:Create(textinput.TextFrame.Enter, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end)

			textinput.TextFrame.Enter.MouseLeave:Connect(function()
				tweenservice:Create(textinput.TextFrame.Enter, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextColor3 = Color3.fromRGB(40, 40, 40)}):Play()
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




				tweenservice:Create(
					textinput,
					TweenInfo.new(0.7, Enum.EasingStyle.Quint),
					{ Size = UDim2.new(1, -35, 0, newHeight + extraHeight + 35) }
				):Play()

				--	tweenservice:Create(textinput.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Position = UDim2.new(1, -20,1, -15) }):Play()


			end)

			textBox:GetPropertyChangedSignal("Size"):Connect(function()
				local newHeight = textBox.Size.Y.Offset
				local totalHeight = math.max(newHeight, defaultHeight)

				tweenservice:Create(
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
					syde:Report("TextInput '" .. textinput.Name .. "' callback", errorMsg)
				end
			end

			textBox.FocusLost:Connect(function(enterPressed)
				if not enterPressed then return end

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

			local inputObj = {
				Frame = textinput,
				Set = function(self, newText)
					textBox.Text = tostring(newText or "")
				end,
				toggle = function(self)
					textinput.Visible = not textinput.Visible
				end,
				remove = function(self)
					textinput:Destroy()
				end,
			}
			return inputObj
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

			-- Clone the object
			local ObjectClone = Viewdata.Object:Clone()
			ObjectClone.Parent = Viewport

			-- Center object
			-- Center object properly so pivot is in the middle from the start
			if ObjectClone:IsA("Model") then
				ObjectClone:PivotTo(CFrame.new(0, 0, 0))
			else
				ObjectClone.CFrame = CFrame.new(0, 0, 0)
			end

			-- Anchor parts
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
				tweenservice:Create(EnchancedView.ViewFrame.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
					ImageTransparency = 1
				}):Play()
			end

			-- Determine center & size
			local primaryPart
			local size
			local center

			if ObjectClone:IsA("BasePart") then
				size = ObjectClone.Size
				ObjectClone.CFrame = CFrame.new(0, 0, 0)

			elseif ObjectClone:IsA("Model") then
				-- Get bounding box center and size
				local cf, boundsSize = ObjectClone:GetBoundingBox()
				size = boundsSize

				-- Move model so its center is at (0,0,0)
				ObjectClone:PivotTo(CFrame.new(0, 0, 0))

				-- Ensure Roblox finishes recalculating bounds after clone
				task.defer(function()
					ObjectClone:PivotTo(CFrame.new(0, 0, 0))
				end)
			end


			-- Camera distance based on size
			local maxDimension = math.max(size.X, size.Y, size.Z)
			local distance = maxDimension * 2
			Camera.CFrame = CFrame.new(Vector3.new(0, 0, distance), Vector3.new(0, 0, 0))

			-- Icon Rotation state
			local icon = EnchancedView.ViewFrame.ImageLabel


			-- Rotation state
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

			-- Auto rotate (horizontal only so it looks natural)
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

						tweenservice:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
							ImageColor3 = Color3.fromRGB(255, 255, 255)
						}):Play()
					end
				end)

				Viewport.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						tweenservice:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
							ImageColor3 = Color3.fromRGB(30, 30, 30)
						}):Play()
					end
				end)

				Viewport.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement  then
						local delta = input.Position - lastPos

						-- Apply rotation
						targetRotationY = targetRotationY + delta.X * 0.005
						targetRotationX = math.clamp(targetRotationX - delta.Y * 0.005, -math.pi/2, math.pi/2)


						lastPos = input.Position
					end
				end)
			end


			-- === Zoom + Elastic Scroll (virtual vs visual) ===
			local ZoomFrame   = EnchancedView.ViewFrame.Zoom
			local ClipFrame   = ZoomFrame.clipframe
			local ScrollFrame = ClipFrame.scroll
			local ZoomAmountLabel = ZoomFrame.Frame.ZoomAmount -- << change to your label path

			-- Zoom range (studs)
			local minZoomDistance = maxDimension * 0.5
			local maxZoomDistance = maxDimension * 10

			-- Elastic settings
			local elasticity   = 0.4      -- visual resistance (0..1)
			local maxOverdrag  = 50       -- px visual overdrag cap
			local tweenInfo    = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

			-- Limits (top is 0, bottom is negative if scroll is taller than clip)
			local function getScrollLimits()
				local minY = 0
				local diff = ScrollFrame.AbsoluteSize.Y - ClipFrame.AbsoluteSize.Y
				local maxY = diff > 0 and -diff or 0
				return minY, maxY
			end

			-- Map Y -> zoom (defensive if no range)
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
					tweenservice:Create(ZoomAmountLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {Position = UDim2.new(1, 0,0.5, -20)}):Play()
					task.wait(0.045)
					ZoomAmountLabel.Text = 'x'..string.format("%.2f", distance)
					ZoomAmountLabel.Position = UDim2.new(1, 0,0.5, 20)
					tweenservice:Create(ZoomAmountLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {Position = UDim2.new(1, 0,0.5, 0)}):Play()
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

			-- State
			local dragging   = false
			local lastPos
			local virtualY   = 0 

			-- Initialize virtual to current
			virtualY = ScrollFrame.Position.Y.Offset

			local initialZoom = 20
			updateZoom(initialZoom)

			-- Sync scroll position with initial zoom
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

					-- Clamp virtual to limits and snap visually
					local minY, maxY = getScrollLimits()
					virtualY = math.clamp(virtualY, maxY, minY)

					game:GetService("TweenService"):Create(
						ScrollFrame,
						tweenInfo,
						{ Position = UDim2.new(ScrollFrame.Position.X.Scale, ScrollFrame.Position.X.Offset, 0, virtualY) }
					):Play()

					-- Keep zoom in sync with the snapped position
					local distance = yToZoom(virtualY)
					updateZoom(distance)
				end
			end)

			ZoomFrame.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local deltaY = input.Position.Y - lastPos.Y
					lastPos = input.Position

					-- 1) Update virtual Y with full delta (no elasticity here)
					virtualY = virtualY + deltaY

					-- 2) Visual Y with elasticity (so it rubber-bands)
					local visualY = visualYFromVirtualY(virtualY)
					ScrollFrame.Position = UDim2.new(ScrollFrame.Position.X.Scale, ScrollFrame.Position.X.Offset, 0, visualY)

					-- 3) Zoom uses CLAMPED virtual Y (so overdrag doesn't affect zoom)
					local minY, maxY = getScrollLimits()
					local clampedY = math.clamp(virtualY, maxY, minY)
					local distance = yToZoom(clampedY)
					updateZoom(distance)
				end
			end)

		end


		--@@Labels/Paragraph
		function initelement:Paragraph(Paragraph)
			local ParaData = {
				Title = Paragraph.Title;
				Content = Paragraph.Content;
			}

			local Para = pages.page.Paragraph:Clone()
			Para.Visible = true
			Para.Parent = Page
			Para.Frame.title.Text = ParaData.Title
			Para.Content.Text = ParaData.Content
			Para:SetAttribute("Searchable", true)

			Para.Content.Size = UDim2.new(1, -20, 0, Para.Content.TextBounds.Y)
			--	Para.Size = UDim2.new(1, -35, 0, Para.Content.Size.Y.Offset + 200)

			local function updateSize()
				local textSize = textservice:GetTextSize(
					Para.Content.Text,
					Para.Content.TextSize,
					Para.Content.Font,
					Vector2.new(Para.Content.AbsoluteSize.X, math.huge) -- Allows vertical expansion
				)

				local newDescSize = UDim2.new(1, -20, 0, textSize.Y)
				local newButtonSize = UDim2.new(Para.Size.X.Scale, Para.Size.X.Offset, 0, textSize.Y + 120) -- Adding extra padding

				local descTween = tweenservice:Create(Para.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newDescSize })
				descTween:Play()

				local buttonTween = tweenservice:Create(Para, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = newButtonSize })
				buttonTween:Play()
			end

			updateSize()

			Para.Content:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)

			local paraObj = {
				Frame = Para,
				Set = function(self, newTitle, newContent)
					if newTitle then Para.Frame.title.Text = tostring(newTitle) end
					if newContent then Para.Content.Text = tostring(newContent) end
				end,
				toggle = function(self)
					Para.Visible = not Para.Visible
				end,
				remove = function(self)
					Para:Destroy()
				end,
			}
			return paraObj
		end

		function initelement:Label(Text, Alignment)

			local Label = pages.page.Label:Clone()
			Label.Visible = true
			Label.Parent = Page
			Label.text.Text = Text
			Label:SetAttribute("Searchable", true)

			if Alignment == 'Center' then
				Label.text.TextXAlignment = Enum.TextXAlignment.Center
			elseif Alignment == 'Right' then
				Label.text.TextXAlignment = Enum.TextXAlignment.Right
			end

			local labelObj = {
				Frame = Label,
				Set = function(self, newText, colorConfig)
					newText = tostring(newText or "")
					if type(colorConfig) == "table" then
						for word, color in pairs(colorConfig) do
							if newText:find(word) then
								local escaped = word:gsub("([%(%)%.%+%-%*%?%[%]%^%$%%])", "%%%1")
								newText = newText:gsub(escaped, '<font color="' .. color .. '">' .. word .. '</font>')
							end
						end
						Label.text.RichText = true
					end
					Label.text.Text = newText
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

		function initelement:Section(Title, Icon)
			local SectionData = {
				Title = Title
			}

			local Section =  pages.page.Section:Clone()
			Section.Visible = true
			Section.Title.Text = Title
			Section.Parent = Page
			Section.Title.Position = UDim2.new(0, 0,0, 0)

			if Icon then
				Section.icon.Image = 'rbxassetid://'..Icon
				Section.Title.Position = UDim2.new(0, 25,0, 0)
			else
				Section.icon.Visible = false
			end
		end

		--@@Dropdown
		function initelement:Dropdown(Dropdown)
			local data = {
				Title = Dropdown.Title or "Temp Dropdown";
				Options = Dropdown.Options or {};
				StarterOption = Dropdown.StarterOption;
				PlaceHolder = Dropdown.PlaceHolder or "Select Option...";
				Multi = Dropdown.Multi or false;
				CallBack = Dropdown.CallBack;
			}

			local dropdown = pages.page.Dropdown:Clone()
			dropdown.Visible = true
			dropdown.Parent = Page
			dropdown.title.Text = data.Title
			dropdown.Name = data.Title
			dropdown.dropholder.drop.Container.Option.Visible = false
			dropdown.dropholder.drop.Container.Visible = false
			tweenservice:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.33, -20,0.576, -75) }):Play()
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
						tweenservice:Create(option, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, yOffset)}):Play()
						yOffset = yOffset + option.Size.Y.Offset + 7
					end
				end
			end

			local function OpenDrop()
				DropOpen = true
				dropdown.dropholder.drop.Container.Visible = true
				dropdown.dropholder.drop.search.Visible = true

				tweenservice:Create(dropdown, TweenInfo.new(1.34, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 300) }):Play()
				tweenservice:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -20, 1, -75) }):Play()
				tweenservice:Create(dropdown.dropholder.drop.v0, TweenInfo.new(1.34, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Rotation = 180 }):Play()

				tweenservice:Create(dropdown.dropholder.drop.search, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0.65 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.search.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 0.4 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.search.TextBox, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.search.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.9 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.search.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 0.85 }):Play()

			end

			local function CloseDrop()
				DropOpen = false
				tweenservice:Create(dropdown, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, -35, 0, 95) }):Play()
				tweenservice:Create(dropdown.dropholder.drop.Container, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.33, -20, 0.576, -75) }):Play()
				tweenservice:Create(dropdown.dropholder.drop.v0, TweenInfo.new(1.34, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.down, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Rotation = 0 }):Play()

				tweenservice:Create(dropdown.dropholder.drop.search, TweenInfo.new(1, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.search.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.search.TextBox, TweenInfo.new(1, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.search.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
				tweenservice:Create(dropdown.dropholder.drop.search.icon, TweenInfo.new(1, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()

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


					-- Create chips for each selected option
					for _, option in ipairs(SelectedOrder) do
						-- Prevent duplicate pills
						if not selectedContainer:FindFirstChild(option) then
							local optionGroup = selectedContainer.result:Clone()
							optionGroup.Visible = true
							optionGroup.Name = option
							optionGroup.TextLabel.Text = option

							-- Set up remove button
							optionGroup.X.MouseButton1Click:Connect(function()
								RemoveFromSelected(option)
								UpdateSelectedText()

								-- Visually update the dropdown list
								for _, opt in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
									if opt:IsA("Frame") and opt.Name == option then
										tweenservice:Create(opt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
										tweenservice:Create(opt, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
										tweenservice:Create(opt.Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
										tweenservice:Create(opt.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
										tweenservice:Create(opt.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
									end
								end

								if data.CallBack then
									data.CallBack(SelectedOrder)
								end
							end)

							optionGroup.Parent = selectedContainer

							-- Optional: auto-size width
							task.defer(function()
								local padding = 40
								local textWidth = optionGroup.TextLabel.TextBounds.X
								local totalWidth = textWidth + padding

								optionGroup.TextLabel.Size = UDim2.new(0, textWidth, 1, 0)

								tweenservice:Create(optionGroup, TweenInfo.new(0.67, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, totalWidth, 0, 20)}):Play()
							end)
						end
					end

				else
					-- Single option text fallback
					dropdown.dropholder.drop.selected.Visible = true
					if #SelectedOrder > 0 then
						dropdown.dropholder.drop.selected.Text = SelectedOrder[1]
					else
						dropdown.dropholder.drop.selected.Text = data.PlaceHolder
					end
				end
			end

			--[SEARCH]
			dropdown.dropholder.drop.search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				local searchText = dropdown.dropholder.drop.search.TextBox.Text:lower()

				for _, option in ipairs(dropdown.dropholder.drop.Container:GetChildren()) do
					if option:IsA("Frame") and option:FindFirstChild("Title") then
						local optionText = option.Title.Text:lower()
						local isTemplate = option.Name == "Option"
						local shouldShow = not isTemplate and (searchText == "" or optionText:find(searchText, 1, true) or SelectedOptions[option.Title.Text])

						if shouldShow then
							option.Visible = true
							if SelectedOptions[option.Title.Text] then
								tweenservice:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
								tweenservice:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
								tweenservice:Create(option.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
								tweenservice:Create(option.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								tweenservice:Create(option.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
							else
								tweenservice:Create(option, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
								tweenservice:Create(option, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
								tweenservice:Create(option.Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
								tweenservice:Create(option.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
								tweenservice:Create(option.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {ImageTransparency = 0.9}):Play()
							end
						else
							-- Hide with animation, but wait before setting Visible = false
							tweenservice:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
							tweenservice:Create(option, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
							tweenservice:Create(option.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
							tweenservice:Create(option.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							tweenservice:Create(option.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
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

						tweenservice:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
						tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
					end

					option.Interact.MouseButton1Click:Connect(function()
						if data.Multi then
							if SelectedOptions[OptionText] then
								RemoveFromSelected(OptionText)
								tweenservice:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
								tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0.9}):Play()
							else
								AddToSelected(OptionText)
								tweenservice:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
								tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
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
									tweenservice:Create(opt, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play()
									tweenservice:Create(opt.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0.9}):Play()
								end
							end

							tweenservice:Create(option, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(39, 39, 39)}):Play()
							tweenservice:Create(option.ImageLabel, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()


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

			data.Flag = Dropdown.Flag
			data.Type = "Dropdown"

			function data:Set(option, skipSave)
				if data.Multi then
					if type(option) == "table" then
						SelectedOptions = {}
						SelectedOrder = {}
						for _, opt in ipairs(option) do
							SelectedOptions[opt] = true
							table.insert(SelectedOrder, opt)
						end
					end
				else
					local optStr = tostring(option)
					SelectedOptions = {[optStr] = true}
					SelectedOrder = {optStr}
					dropdown.dropholder.drop.selected.Text = optStr
				end
				UpdateSelectedText()
				if not skipSave and data.Flag and SaveConfig then
					SaveConfig()
				end
			end

			if syde.ConfigEnabled and data.Flag then
				syde.Flags[data.Flag] = data
				if syde.LoadedConfig and syde.LoadedConfig[data.Flag] ~= nil then
					data:Set(syde.LoadedConfig[data.Flag], true)
				end
			end

			SetDropdownOptions()
			return data
		end

		--@@Colorpicker
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

				-- kill UIListLayout if it exists
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
							tweenservice:Create(
								colorpicker,
								TweenInfo.new(0.35, Enum.EasingStyle.Quart),
								{ Size = UDim2.new(1, -35, 0, 305 + totalHeight) }
							):Play()
						else
							tweenservice:Create(
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
					--	frame.Position = UDim2.new(0, startX, 0.5, -frame.Size.Y.Offset / 2)
					tweenservice:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0, startX , 0.8, -frame.Size.Y.Offset / 2) }):Play()
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

				--	colorpicker.color.BackgroundColor3 = Color3.fromHSV(HSV[1], 1, 1)
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


				tweenservice:Create(HUESlider.Pin, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {BackgroundColor3 = newColor2}):Play()
				tweenservice:Create(SVPicker.Pin, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {BackgroundColor3 = newColor}):Play()


				tweenservice:Create(SVPicker.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(HSV[2], 0, 1 - HSV[3], 0)
				}):Play()

				tweenservice:Create(HUESlider.Pin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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


				tweenservice:Create(colorpicker.color, TweenInfo.new( 0.95, Enum.EasingStyle.Quart ), { Size = UDim2.new(0, 1,0, 1) }):Play()
				tweenservice:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
				tweenservice:Create(colorpicker.color, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundColor3 = data.Color }):Play()
				tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.color.glow, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 1}):Play()
				task.wait(0.12)
				tweenservice:Create(colorpicker.color, TweenInfo.new( 0.9, Enum.EasingStyle.Quart ), { Size = UDim2.new(1, -40,0, 160) }):Play()
				tweenservice:Create(colorpicker.color, TweenInfo.new( 0.9, Enum.EasingStyle.Quart ), { Position = UDim2.new(0.5, 0,0, 40) }):Play()

				tweenservice:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }):Play()
				--	tweenservice:Create(colorpicker, TweenInfo.new( 0.8, Enum.EasingStyle.Quart ), { Size = UDim2.new(1, -35,0, 350) }):Play()
				tweenservice:Create(colorpicker.color.UICorner, TweenInfo.new( 0.8, Enum.EasingStyle.Quart ), { CornerRadius = UDim.new(0, 10) }):Play()

				tweenservice:Create(colorpicker.color.Values.Rainbow, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()


				task.wait(0.6)

				tweenservice:Create(colorpicker.color.SVPicker.Brightness, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.color.SVPicker.Saturation, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.color.SVPicker.Pin, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.color.SVPicker.Pin.UIStroke, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()

				task.wait(0.5)
				tweenservice:Create(colorpicker.color.Values.Hue, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.color.Values.Hue.Pin, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.color.Values.Hue.Pin.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()

				if data.Type == "Gradient" then
					tweenservice:Create(colorpicker.color.Values.Grad, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.Values.Grad.Pin1, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.Values.Grad.Pin1.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.Values.Grad.Pin2, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
					tweenservice:Create(colorpicker.color.Values.Grad.Pin2.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0 }):Play()
				end


				tweenservice:Create(colorpicker.HueValues.HEX, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
				tweenservice:Create(colorpicker.HueValues.HEX.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
				tweenservice:Create(colorpicker.HueValues.HEX.V.HEXBox, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { TextTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.HueValues.HEX.Copy, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()

				task.wait(0.09)
				tweenservice:Create(colorpicker.HueValues.RGB, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
				tweenservice:Create(colorpicker.HueValues.RGB.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
				tweenservice:Create(colorpicker.HueValues.RGB.V.RGBBox, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { TextTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.HueValues.RGB.Copy, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()
				task.wait(0.09)
				tweenservice:Create(colorpicker.HueValues.Link, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0.9 }):Play()
				tweenservice:Create(colorpicker.HueValues.Link.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 0.4 }):Play()
				tweenservice:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(colorpicker.HueValues.Link.Frame.ImageLabel, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { ImageTransparency = 0 }):Play()

				for _,v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
					if v:IsA('Frame') then
						task.wait(0.1)
						tweenservice:Create(v, TweenInfo.new( 0.3, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 0 }):Play()
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
				tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 70,0, 3) }):Play()
				tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
			end)

			colorpicker.QuickClose.hitbox.MouseLeave:Connect(function()
				tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 60,0, 3) }):Play()
				tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundColor3 = Color3.fromRGB(33, 33, 33) }):Play()
			end)

			local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

			if data.Type == "Gradient" and displayGrad then
				displayGrad.Enabled = true
				displayGrad.Color = ColorSequence.new(Keys)
				-- Set to White so the gradient isn't "multiplied" or tinted by a background color
				tweenservice:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
			else
				if displayGrad then displayGrad.Enabled = false end
				tweenservice:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = data.Color }):Play()
			end

			local function ClosePicker()
				Open = false
				DeBounce = true
				tweenservice:Create(colorpicker, TweenInfo.new( 0.55, Enum.EasingStyle.Quint ), { Size = UDim2.new(1, -35,0, 40) }):Play()
				--	tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.color, TweenInfo.new( 0.7, Enum.EasingStyle.Quart ), { Position = UDim2.new(1, -30,0, 10)}):Play()
				tweenservice:Create(colorpicker.color, TweenInfo.new( 0.55, Enum.EasingStyle.Quint ), { Size = UDim2.new(0, 20,0, 20) }):Play()
				tweenservice:Create(colorpicker.color, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundColor3 = data.Color }):Play()
				tweenservice:Create(colorpicker.QuickClose, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.color.glow, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 0.7}):Play()
				colorpicker.interact.Interactable = true
				colorpicker.QuickClose.Interactable = false

				--	task.wait(0.6)

				tweenservice:Create(colorpicker.color.SVPicker.Brightness, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.color.SVPicker.Saturation, TweenInfo.new( 2, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.color.SVPicker.Pin, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.color.SVPicker.Pin.UIStroke, TweenInfo.new( 0.4, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()

				tweenservice:Create(colorpicker.color.Values.Hue, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.color.Values.Hue.Pin, TweenInfo.new( 1, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.color.Values.Hue.Pin.UIStroke, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()

				tweenservice:Create(colorpicker.color.Values.Rainbow, TweenInfo.new( 0.5, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

				local displayGrad = colorpicker.color:FindFirstChildOfClass("UIGradient")

				if data.Type == "Gradient" and displayGrad then
					displayGrad.Enabled = true
					displayGrad.Color = ColorSequence.new(Keys)
					-- Set to White so the gradient isn't "multiplied" or tinted by a background color
					tweenservice:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
				else
					if displayGrad then displayGrad.Enabled = false end
					tweenservice:Create(colorpicker.color, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundColor3 = data.Color }):Play()
				end

				if data.Type == "Gradient" then
					tweenservice:Create(colorpicker.color.Values.Grad, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.Values.Grad.Pin1, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.Values.Grad.Pin1.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.Values.Grad.Pin2, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
					tweenservice:Create(colorpicker.color.Values.Grad.Pin2.UIStroke, TweenInfo.new( 0.8, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
				end

				tweenservice:Create(colorpicker.HueValues.RGB, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.RGB.UIStroke, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.RGB.V.RGBBox, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { TextTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.RGB.Copy, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

				tweenservice:Create(colorpicker.HueValues.HEX, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.HEX.UIStroke, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.HEX.V.HEXBox, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { TextTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.HEX.Copy, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()

				tweenservice:Create(colorpicker.HueValues.Link, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.Link.UIStroke, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { Transparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
				tweenservice:Create(colorpicker.HueValues.Link.Frame.ImageLabel, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { ImageTransparency = 1 }):Play()
				colorpicker.HueValues.Visible = false
				for _,v in ipairs(colorpicker.color.Values.Recent:GetChildren()) do
					if v:IsA('Frame') then
						tweenservice:Create(v, TweenInfo.new( 0.6, Enum.EasingStyle.Exponential ), { BackgroundTransparency = 1 }):Play()
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
								tweenservice:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
							end)
							v2.MouseLeave:Connect(function()
								tweenservice:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(66, 66, 66) }):Play()
							end)
						end
					end
				end
			end

			-- copy hex / rgb to clipboard
			syde:OnClick(colorpicker.HueValues.HEX.Copy, function()
				if syde:SetClipboard(FormatColor(data.Color, 'Hex')) then syde:FlashCopy(colorpicker.HueValues.HEX.Copy) end
			end)
			syde:OnClick(colorpicker.HueValues.RGB.Copy, function()
				if syde:SetClipboard(FormatColor(data.Color, 'RGB', 2)) then syde:FlashCopy(colorpicker.HueValues.RGB.Copy) end
			end)

			local function AddRecentColor(newColor)
				local recentFrame = colorpicker.colorPlaceHolder:Clone()
				recentFrame.Visible = true
				recentFrame.Parent = colorpicker.color.Values.Recent
				recentFrame.BackgroundColor3 = newColor

				recentFrame.interact.MouseButton1Click:Connect(function()
				--[[	tweenservice:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 5,0, 5) }):Play()
					task.wait(0.09)
					tweenservice:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 12,0, 12) }):Play() ]]

					local h, s, v = newColor:ToHSV()
					if s > 0.02 then
						HSV[1] = h
					end
					HSV[2] = s
					HSV[3] = v
					updatestuff()

				end)

				recentFrame.interact.MouseEnter:Connect(function()
					tweenservice:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 20,0, 20) }):Play()
				end)

				recentFrame.interact.MouseLeave:Connect(function()
					tweenservice:Create(recentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 12,0, 12) }):Play()
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

			syde:AddConnection(SVPicker.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					SV = runservice.RenderStepped:Connect(function()
						local mouse = game.Players.LocalPlayer:GetMouse()
						local ColorX = math.clamp(mouse.X - SVPicker.AbsolutePosition.X, 0, SVPicker.AbsoluteSize.X) / SVPicker.AbsoluteSize.X
						local ColorY = math.clamp(mouse.Y - SVPicker.AbsolutePosition.Y, 0, SVPicker.AbsoluteSize.Y) / SVPicker.AbsoluteSize.Y

						HSV[2] = ColorX
						HSV[3] = 1 - ColorY

						updatestuff()
					end)
				end
			end)

			syde:AddConnection(SVPicker.InputEnded, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 and SV then
					SV:Disconnect()
					SV = nil
					AddRecentColor(data.Color)
				end
			end)

			syde:AddConnection(HUESlider.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					HUE = runservice.RenderStepped:Connect(function()
						local mouse = game.Players.LocalPlayer:GetMouse()
						local ColorX = math.clamp(mouse.X - HUESlider.AbsolutePosition.X, 0, HUESlider.AbsoluteSize.X) / HUESlider.AbsoluteSize.X

						HSV[1] = 1 - ColorX

						updatestuff()
					end)
				end
			end)

			syde:AddConnection(HUESlider.InputEnded, function(i)
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
					-- colorpicker.HueValues.Link.Frame.Position = UDim2.new(0, mouse.X - colorpicker.AbsolutePosition.X - 50, 0, mouse.Y - colorpicker.AbsolutePosition.Y - 260)
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
								syde:Toast({
									Content = 'Color Linked',
									Duration = 2,
								})
								TweenService:Create(
									colorpicker.HueValues.Link.Frame,
									TweenInfo.new(0.3, Enum.EasingStyle.Quint),
									{ Position = originalPosition }
								):Play()

								TweenService:Create(otherPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								--	TweenService:Create(colorpicker.HueValues.HEX.Link, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {ImageColor3 = Color3.fromRGB(66, 66, 66)}):Play()
								TweenService:Create(colorpicker.HueValues.Link.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {Size = UDim2.new(1, 0,1, 0)}):Play()
								break
							end
						end
					end

					if not foundTarget then
						--	TweenService:Create(colorpicker.HueValues.HEX.Link, TweenInfo.new(0.5, Enum.EasingStyle.Exponential) , {ImageColor3 = Color3.fromRGB(66, 66, 66)}):Play()
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
						huerender = runservice.RenderStepped:Connect(RainbowEffect)
						tweenservice:Create(colorpicker.color.Values.Rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential ), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
					end
				else
					if huerender then
						huerender:Disconnect()
						tweenservice:Create(colorpicker.color.Values.Rainbow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential ), {ImageColor3 = Color3.fromRGB(62, 62, 62)}):Play()
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

				if not skipSave and data.Flag and SaveConfig then
					SaveConfig()
				end
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
			end



			return data

		end

		-- guard every builder so a failed element shows the banner instead of breaking the UI
		
		-- ============================================================
		-- ORION TAB ELEMENT INTEGRATION & ADAPTERS
		-- ============================================================

		-- 1. AddButton / Button adapter
		function initelement:AddButton(ButtonConfig)
			ButtonConfig = ButtonConfig or {}
			local title = ButtonConfig.Name or ButtonConfig.Title or "Button"
			local callback = ButtonConfig.Callback or ButtonConfig.CallBack or function() end
			local icon = ButtonConfig.Icon or "rbxassetid://3944703587"

			local res = initelement:Button({
				Title = title,
				Description = ButtonConfig.Description or ButtonConfig.Desc or "",
				Type = ButtonConfig.Type or "Default",
				HoldTime = ButtonConfig.HoldTime or 3,
				CallBack = callback,
				Icon = icon,
			})
			return res
		end

		-- 2. AddToggle / Toggle adapter
		function initelement:AddToggle(ToggleConfig)
			ToggleConfig = ToggleConfig or {}
			local title = ToggleConfig.Name or ToggleConfig.Title or "Toggle"
			local val = false
			if ToggleConfig.Default ~= nil then
				val = ToggleConfig.Default
			elseif ToggleConfig.Value ~= nil then
				val = ToggleConfig.Value
			end
			local callback = ToggleConfig.Callback or ToggleConfig.CallBack or function() end

			local res = initelement:Toggle({
				Title = title,
				Description = ToggleConfig.Description or ToggleConfig.Desc or "",
				Value = val,
				Config = ToggleConfig.Save or ToggleConfig.Config or false,
				Flag = ToggleConfig.Flag,
				CallBack = callback,
			})
			return res
		end

		-- 3. AddSlider / Slider adapter
		function initelement:AddSlider(SliderConfig)
			SliderConfig = SliderConfig or {}
			local title = SliderConfig.Name or SliderConfig.Title or "Slider"
			local minVal = SliderConfig.Min or 0
			local maxVal = SliderConfig.Max or 100
			local defVal = SliderConfig.Default or minVal
			local inc = SliderConfig.Increment or 1
			local callback = SliderConfig.Callback or SliderConfig.CallBack or function() end

			local res = initelement:Slider({
				Title = title,
				Description = SliderConfig.Description or SliderConfig.Desc or "",
				Sliders = {
					{
						Title = title,
						Range = {minVal, maxVal},
						StarterValue = defVal,
						Increment = inc,
						CallBack = callback,
						Flag = SliderConfig.Flag,
					}
				}
			})
			return res
		end

		-- 4. AddDropdown / Dropdown adapter
		function initelement:AddDropdown(DropdownConfig)
			DropdownConfig = DropdownConfig or {}
			local title = DropdownConfig.Name or DropdownConfig.Title or "Dropdown"
			local options = DropdownConfig.Options or DropdownConfig.Values or {}
			local def = DropdownConfig.Default or DropdownConfig.Value or (options[1] or "")
			local callback = DropdownConfig.Callback or DropdownConfig.CallBack or function() end

			local res = initelement:Dropdown({
				Title = title,
				Options = options,
				StarterOption = def,
				PlaceHolder = DropdownConfig.PlaceHolder or DropdownConfig.PlaceholderText or "Select Option...",
				Multi = DropdownConfig.Multi or false,
				Flag = DropdownConfig.Flag,
				CallBack = callback,
			})
			return res
		end

		-- 5. AddBind / AddKeybind / Keybind adapter
		function initelement:AddBind(BindConfig)
			BindConfig = BindConfig or {}
			local title = BindConfig.Name or BindConfig.Title or "Bind"
			local key = BindConfig.Default or BindConfig.Key or Enum.KeyCode.Unknown
			local callback = BindConfig.Callback or BindConfig.CallBack or function() end

			local res = initelement:Keybind({
				Title = title,
				Key = key,
				Description = BindConfig.Description or BindConfig.Desc or "",
				Flag = BindConfig.Flag,
				CallBack = callback,
			})
			return res
		end
		initelement.AddKeybind = initelement.AddBind

		-- 6. AddTextbox / AddTextInput / TextInput adapter
		function initelement:AddTextbox(TextboxConfig)
			TextboxConfig = TextboxConfig or {}
			local title = TextboxConfig.Name or TextboxConfig.Title or "Textbox"
			local ph = TextboxConfig.BackGroundtext or TextboxConfig.BackGrountText or TextboxConfig.PlaceholderText or TextboxConfig.PlaceHolder or TextboxConfig.Default or "Input"
			local callback = TextboxConfig.Callback or TextboxConfig.CallBack or function() end

			local res = initelement:TextInput({
				Title = title,
				PlaceHolder = ph,
				Default = TextboxConfig.Default or "",
				Description = TextboxConfig.Description or TextboxConfig.Desc or "",
				Flag = TextboxConfig.Flag,
				CallBack = callback,
			})
			return res
		end
		initelement.AddTextInput = initelement.AddTextbox

		-- 7. AddColorpicker / AddColorPicker / ColorPicker adapter
		function initelement:AddColorpicker(ColorpickerConfig)
			ColorpickerConfig = ColorpickerConfig or {}
			local title = ColorpickerConfig.Name or ColorpickerConfig.Title or "Colorpicker"
			local col = ColorpickerConfig.Default or ColorpickerConfig.Color or Color3.fromRGB(255, 255, 255)
			local callback = ColorpickerConfig.Callback or ColorpickerConfig.CallBack or function() end

			local res = initelement:ColorPicker({
				Title = title,
				Color = col,
				Flag = ColorpickerConfig.Flag,
				CallBack = callback,
			})
			return res
		end
		initelement.AddColorPicker = initelement.AddColorpicker

		-- 8. AddParagraph adapter (supports user headshot if id is user id)
		function initelement:AddParagraph(...)
			local args = {...}
			local id, title, content, align
			if type(args[1]) == "table" then
				local tbl = args[1]
				id = tbl.Id or tbl.id
				title = tbl.Title or tbl.Name or ""
				content = tbl.Content or tbl.Text or ""
				align = tbl.Align or tbl.Alignment or "Left"
			elseif #args >= 3 and tonumber(args[1]) ~= nil then
				id = tostring(args[1])
				title = args[2] or ""
				content = args[3] or ""
				align = args[4] or "Left"
			else
				title = args[1] or ""
				content = args[2] or ""
				align = args[3] or "Left"
			end

			if id and tonumber(id) then
				return initelement:AddPlayerParagraph(tonumber(id))
			end

			local res = initelement:Paragraph({
				Title = title,
				Content = content,
				Align = align,
			})
			return res
		end

		-- 9. AddLabel with typewriter animation & word coloring
		function initelement:AddLabel(Text, Alignment)
			local current = tostring(Text or "")
			local res = initelement:Label(current, Alignment)

			local labelHandle = {
				Frame = (type(res) == "table" and res.Frame) or nil,
				Set = function(self, newText, colorConfig)
					newText = tostring(newText or "")
					local finalText = newText
					if type(colorConfig) == "table" then
						for word, color in pairs(colorConfig) do
							if finalText:find(word) then
								local escaped = word:gsub("([%(%)%.%+%-%*%?%[%]%^%$%%])", "%%%1")
								finalText = finalText:gsub(escaped, '<font color="' .. color .. '">' .. word .. '</font>')
							end
						end
					end

					if res and res.Set then
						res:Set(finalText)
					end
					current = newText
				end,
				toggle = function(self)
					if res and res.toggle then res:toggle() end
				end,
				remove = function(self)
					if res and res.remove then res:remove() end
				end
			}
			return labelHandle
		end

		-- 10. AddLog / Log
		function initelement:AddLog(Text)
			Text = tostring(Text or "")
			local LogFrame = Instance.new("Frame")
			LogFrame.Name = "Log_" .. Text:sub(1, 15)
			LogFrame.Size = UDim2.new(1, -20, 0, 38)
			LogFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			LogFrame.BorderSizePixel = 0
			LogFrame.Parent = Page
			LogFrame:SetAttribute("Searchable", true)

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = LogFrame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(50, 50, 50)
			stroke.Thickness = 1
			stroke.Parent = LogFrame

			local label = Instance.new("TextLabel")
			label.Name = "Content"
			label.Size = UDim2.new(1, -16, 1, 0)
			label.Position = UDim2.new(0, 8, 0, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamBold
			label.TextSize = 15
			label.TextColor3 = Color3.fromRGB(240, 240, 240)
			label.TextXAlignment = Enum.TextXAlignment.Center
			label.TextWrapped = true
			label.Text = Text
			label.Parent = LogFrame

			local logObj = {
				Frame = LogFrame,
				Set = function(self, newText)
					label.Text = tostring(newText or "")
				end,
				toggle = function(self)
					LogFrame.Visible = not LogFrame.Visible
				end,
				remove = function(self)
					LogFrame:Destroy()
				end,
			}
			return logObj
		end
		initelement.Log = initelement.AddLog

		-- 11. ColorLabel
		function initelement:ColorLabel(Text, ToChangeColor, Position)
			Text = tostring(Text or "")
			ToChangeColor = ToChangeColor or Color3.fromRGB(255, 255, 255)
			Position = Position or "Left"

			local CFrame = Instance.new("Frame")
			CFrame.Name = "ColorLabel_" .. Text:sub(1, 15)
			CFrame.Size = UDim2.new(1, -20, 0, 34)
			CFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			CFrame.BorderSizePixel = 0
			CFrame.Parent = Page
			CFrame:SetAttribute("Searchable", true)

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = CFrame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(50, 50, 50)
			stroke.Thickness = 1
			stroke.Parent = CFrame

			local label = Instance.new("TextLabel")
			label.Name = "Content"
			label.Size = UDim2.new(1, -24, 1, 0)
			label.Position = UDim2.new(0, 12, 0, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamBold
			label.TextSize = 14
			label.TextColor3 = ToChangeColor
			label.Text = Text
			label.Parent = CFrame

			if Position == "Center" then
				label.TextXAlignment = Enum.TextXAlignment.Center
			elseif Position == "Right" then
				label.TextXAlignment = Enum.TextXAlignment.Right
			else
				label.TextXAlignment = Enum.TextXAlignment.Left
			end

			local colLabelObj = {
				Frame = CFrame,
				Set = function(self, newText, newColor, newPos)
					if newText then label.Text = tostring(newText) end
					if newColor then label.TextColor3 = newColor end
					if newPos then
						if newPos == "Center" then
							label.TextXAlignment = Enum.TextXAlignment.Center
						elseif newPos == "Right" then
							label.TextXAlignment = Enum.TextXAlignment.Right
						else
							label.TextXAlignment = Enum.TextXAlignment.Left
						end
					end
				end,
				toggle = function(self)
					CFrame.Visible = not CFrame.Visible
				end,
				remove = function(self)
					CFrame:Destroy()
				end,
			}
			return colLabelObj
		end

		-- 12. AddPlayerParagraph / PlayerParagraph
		function initelement:AddPlayerParagraph(userId)
			userId = tonumber(userId) or 0

			local ParaFrame = Instance.new("Frame")
			ParaFrame.Name = "PlayerPara_" .. tostring(userId)
			ParaFrame.Size = UDim2.new(1, -20, 0, 68)
			ParaFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			ParaFrame.BorderSizePixel = 0
			ParaFrame.Parent = Page
			ParaFrame:SetAttribute("Searchable", true)

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = ParaFrame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(50, 50, 50)
			stroke.Thickness = 1
			stroke.Parent = ParaFrame

			local avatar = Instance.new("ImageLabel")
			avatar.Name = "Avatar"
			avatar.Size = UDim2.new(0, 52, 0, 52)
			avatar.Position = UDim2.new(0, 8, 0.5, -26)
			avatar.BackgroundTransparency = 1
			avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
			avatar.Parent = ParaFrame

			local avCorner = Instance.new("UICorner")
			avCorner.CornerRadius = UDim.new(0, 8)
			avCorner.Parent = avatar

			local dLabel = Instance.new("TextLabel")
			dLabel.Name = "DisplayName"
			dLabel.Size = UDim2.new(1, -74, 0, 20)
			dLabel.Position = UDim2.new(0, 68, 0, 12)
			dLabel.BackgroundTransparency = 1
			dLabel.Font = Enum.Font.GothamBold
			dLabel.TextSize = 14
			dLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
			dLabel.TextXAlignment = Enum.TextXAlignment.Left
			dLabel.Text = "Loading..."
			dLabel.Parent = ParaFrame

			local uLabel = Instance.new("TextLabel")
			uLabel.Name = "Username"
			uLabel.Size = UDim2.new(1, -74, 0, 18)
			uLabel.Position = UDim2.new(0, 68, 0, 34)
			uLabel.BackgroundTransparency = 1
			uLabel.Font = Enum.Font.GothamSemibold
			uLabel.TextSize = 12
			uLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
			uLabel.TextXAlignment = Enum.TextXAlignment.Left
			uLabel.Text = "@..."
			uLabel.Parent = ParaFrame

			local function fetchUser(uId)
				task.spawn(function()
					local ok, data = pcall(function()
						return game:GetService("UserService"):GetUserInfosByUserIdsAsync({uId})
					end)
					if ok and data and data[1] then
						dLabel.Text = data[1].DisplayName or "Unknown"
						uLabel.Text = "@" .. (data[1].Username or "Unknown")
					else
						dLabel.Text = "User " .. tostring(uId)
						uLabel.Text = "@user"
					end
				end)
			end
			if userId > 0 then
				fetchUser(userId)
			end

			local playerObj = {
				Frame = ParaFrame,
				Set = function(self, newId)
					newId = tonumber(newId) or 0
					avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. newId .. "&width=420&height=420&format=png"
					fetchUser(newId)
				end,
				toggle = function(self)
					ParaFrame.Visible = not ParaFrame.Visible
				end,
				remove = function(self)
					ParaFrame:Destroy()
				end,
			}
			return playerObj
		end
		initelement.PlayerParagraph = initelement.AddPlayerParagraph

		-- 13. AddPbind / Pbind (3-axis X, Y, Z vector inputs)
		function initelement:AddPbind(Config)
			Config = Config or {}
			local title = Config.Name or Config.Title or "Position"
			local defX = tostring(Config.DefaultX or "")
			local defY = tostring(Config.DefaultY or "")
			local defZ = tostring(Config.DefaultZ or "")
			local callback = Config.Callback or Config.CallBack or function() end

			local PFrame = Instance.new("Frame")
			PFrame.Name = "PBind_" .. tostring(title):sub(1, 15)
			PFrame.Size = UDim2.new(1, -20, 0, 40)
			PFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			PFrame.BorderSizePixel = 0
			PFrame.Parent = Page
			PFrame:SetAttribute("Searchable", true)

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = PFrame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(50, 50, 50)
			stroke.Thickness = 1
			stroke.Parent = PFrame

			local titleLabel = Instance.new("TextLabel")
			titleLabel.Name = "Content"
			titleLabel.Size = UDim2.new(1, -190, 1, 0)
			titleLabel.Position = UDim2.new(0, 12, 0, 0)
			titleLabel.BackgroundTransparency = 1
			titleLabel.Font = Enum.Font.GothamBold
			titleLabel.TextSize = 14
			titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
			titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			titleLabel.Text = title
			titleLabel.Parent = PFrame

			local pbindData = {
				ValueX = defX,
				ValueY = defY,
				ValueZ = defZ,
				Type = "PBind",
				Frame = PFrame,
			}

			local function createBox(xPos, defVal)
				local box = Instance.new("TextBox")
				box.Size = UDim2.new(0, 50, 0, 26)
				box.Position = UDim2.new(1, xPos, 0.5, -13)
				box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				box.Font = Enum.Font.GothamBold
				box.TextSize = 12
				box.TextColor3 = Color3.fromRGB(255, 255, 255)
				box.PlaceholderText = "..."
				box.Text = defVal
				box.ClearTextOnFocus = false
				box.Parent = PFrame

				local bCorner = Instance.new("UICorner")
				bCorner.CornerRadius = UDim.new(0, 4)
				bCorner.Parent = box

				local bStroke = Instance.new("UIStroke")
				bStroke.Color = Color3.fromRGB(60, 60, 60)
				bStroke.Thickness = 1
				bStroke.Parent = box

				return box
			end

			local boxX = createBox(-165, defX)
			local boxY = createBox(-110, defY)
			local boxZ = createBox(-55, defZ)

			local function trigger()
				pbindData.ValueX = boxX.Text
				pbindData.ValueY = boxY.Text
				pbindData.ValueZ = boxZ.Text
				pcall(callback, pbindData.ValueX, pbindData.ValueY, pbindData.ValueZ)
			end

			boxX.FocusLost:Connect(trigger)
			boxY.FocusLost:Connect(trigger)
			boxZ.FocusLost:Connect(trigger)

			pbindData.Set = function(self, x, y, z)
				if x ~= nil then pbindData.ValueX = tostring(x) boxX.Text = pbindData.ValueX end
				if y ~= nil then pbindData.ValueY = tostring(y) boxY.Text = pbindData.ValueY end
				if z ~= nil then pbindData.ValueZ = tostring(z) boxZ.Text = pbindData.ValueZ end
			end

			pbindData.toggle = function(self) PFrame.Visible = not PFrame.Visible end
			pbindData.remove = function(self) PFrame:Destroy() end

			if Config.Flag then
				syde.Flags[Config.Flag] = pbindData
			end
			return pbindData
		end
		initelement.Pbind = initelement.AddPbind

		-- 14. AddUiBind / UiBind
		function initelement:AddUiBind()
			return initelement:AddBind({
				Name = "UI Toggle Bind",
				Default = Enum.KeyCode.RightShift,
				Callback = function(key) end,
			})
		end
		initelement.UiBind = initelement.AddUiBind

		-- 15. AddSmartTheme / SmartTheme
		function initelement:AddSmartTheme()
			local colorPicker = initelement:AddColorpicker({
				Name = "Base Color",
				Default = (syde.Theme and syde.Theme.Accent) or Color3.fromRGB(251, 144, 255),
				Callback = function(col)
					if syde.GenTheme then
						local newPalette = syde:GenTheme(col)
						syde.Themes = syde.Themes or {}
						syde.Themes.Custom = newPalette
						syde.SelectedTheme = "Custom"
						if syde.SetTheme then syde:SetTheme() end
					end
					if syde.UpdateTheme then
						syde:UpdateTheme({ Accent = col, HitBox = col })
					end
				end,
			})
			local resetBtn = initelement:AddButton({
				Name = "Reset Theme",
				Callback = function()
					syde.SelectedTheme = "Default"
					if syde.SetTheme then syde:SetTheme() end
					if syde.UpdateTheme then
						syde:UpdateTheme({ Accent = Color3.fromRGB(251, 144, 255), HitBox = Color3.fromRGB(251, 144, 255) })
					end
				end,
			})
			return { ColorPicker = colorPicker, ResetButton = resetBtn }
		end
		initelement.SmartTheme = initelement.AddSmartTheme

		-- 16. FreeMouseDrp
		function initelement:FreeMouseDrp()
			return initelement:AddDropdown({
				Name = "Unlock Mouse Mode",
				Options = {"ThirdPerson", "FreeMouse"},
				Default = syde.UMouseMode or "FreeMouse",
				Callback = function(val)
					syde.UMouseMode = val
					if syde.UnlockMouse then
						syde:UnlockMouse(false)
						task.wait(0.05)
						syde:UnlockMouse(true)
					end
				end,
			})
		end

		-- 17. AddSection (Enhanced section supporting sub-element builder)
		function initelement:AddSection(name, align, height)
			name = name or ""
			local secFrame = initelement:Section(name)
			local secObj = {}
			for k, v in pairs(initelement) do
				secObj[k] = v
			end
			secObj.Frame = secFrame
			secObj.toggle = function(self)
				if secFrame and secFrame.Parent then
					secFrame.Visible = not secFrame.Visible
				end
			end
			secObj.remove = function(self)
				if secFrame and secFrame.Parent then
					secFrame:Destroy()
				end
			end
			return secObj
		end

		for _bn, _bf in pairs(initelement) do
			if type(_bf) == "function" then
				initelement[_bn] = syde:Guard("Building a '" .. tostring(_bn) .. "' element", _bf)
			end
		end

		return initelement


	end

	tbdata.MakeTab = function(self, TabConfig)
		return self:InitTab(TabConfig)
	end

	tbdata.ChangeIcon = function(self, IconId)
		pcall(function()
			if window and window:FindFirstChild("icon") then
				local ficon = tostring(IconId)
				if not ficon:find("rbxassetid://") and not ficon:find("http") then
					ficon = "rbxassetid://" .. ficon
				end
				window.icon.Image = ficon
			end
		end)
	end

	tbdata.SetName = function(self, ...)
		local args = {...}
		local result = ""
		for _, pair in ipairs(args) do
			if type(pair) == "table" then
				local text, color = pair[1] or "", pair[2] or "#FFFFFF"
				for i = 1, #text do
					local char = text:sub(i, i)
					result = result .. '<font color="' .. color .. '">' .. char .. '</font>'
				end
			else
				result = result .. tostring(pair)
			end
		end
		pcall(function()
			if window and window:FindFirstChild("title") then
				window.title.RichText = true
				window.title.Text = result
			end
		end)
	end

	tbdata.GoToTab = function(self, tabName)
		pcall(function()
			for _, tabBtn in ipairs(tabs:GetChildren()) do
				if tabBtn:IsA("TextButton") or tabBtn:IsA("ImageButton") or tabBtn:IsA("Frame") then
					if tabBtn.Name == tabName or (tabBtn:FindFirstChild("title") and tabBtn.title.Text == tabName) then
						for _, page in ipairs(pages:GetChildren()) do
							if page:IsA("ScrollingFrame") then
								page.Visible = (page.Name == tabName)
							end
						end
					end
				end
			end
		end)
	end

	tbdata.ScrollTo = function(self, tabName, sectionName, smooth)
		pcall(function()
			self:GoToTab(tabName)
			local page = pages:FindFirstChild(tabName)
			if page then
				local target = page:FindFirstChild(sectionName)
				if target then
					local relativeY = target.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y
					local maxY = math.max(0, page.CanvasSize.Y.Offset - page.AbsoluteSize.Y)
					local targetY = math.clamp(relativeY - 30, 0, maxY)
					if smooth then
						tweenservice:Create(page, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							CanvasPosition = Vector2.new(0, targetY)
						}):Play()
					else
						page.CanvasPosition = Vector2.new(0, targetY)
					end
				end
			end
		end)
	end

	tbdata.ScrollToElement = function(self, tabName, element, smooth, offsetY)
		pcall(function()
			self:GoToTab(tabName)
			local page = pages:FindFirstChild(tabName)
			if not page then return end
			local elemInstance = nil
			if typeof(element) == "Instance" then
				elemInstance = element
			elseif typeof(element) == "string" then
				for _, d in ipairs(page:GetDescendants()) do
					if d:IsA("TextLabel") and d.Text:lower():find(element:lower(), 1, true) then
						elemInstance = d.Parent
						break
					elseif d.Name:lower() == element:lower() then
						elemInstance = d
						break
					end
				end
			end
			if elemInstance then
				local offY = (offsetY == "center" and (page.AbsoluteSize.Y / 2) or (tonumber(offsetY) or 30))
				local relativeY = elemInstance.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y
				local maxY = math.max(0, page.CanvasSize.Y.Offset - page.AbsoluteSize.Y)
				local targetY = math.clamp(relativeY - offY, 0, maxY)
				if smooth then
					tweenservice:Create(page, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CanvasPosition = Vector2.new(0, targetY)
					}):Play()
				else
					page.CanvasPosition = Vector2.new(0, targetY)
				end
			end
		end)
	end

	tbdata.FindAndFocusElement = function(self, query)
		if not query or query == "" then return end
		local safeQuery = query:lower()
		for _, page in ipairs(pages:GetChildren()) do
			if page:IsA("ScrollingFrame") then
				for _, elem in ipairs(page:GetDescendants()) do
					if elem:IsA("TextLabel") and elem.Text:lower():find(safeQuery, 1, true) then
						self:GoToTab(page.Name)
						task.wait(0.05)
						self:ScrollToElement(page.Name, elem.Parent, true, "center")
						local stroke = elem.Parent:FindFirstChildOfClass("UIStroke")
						if stroke then
							local originalThickness = stroke.Thickness
							local tw = tweenservice:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, true), {
								Thickness = originalThickness + 2
							})
							tw:Play()
							tw.Completed:Once(function()
								stroke.Thickness = originalThickness
							end)
						end
						return
					end
				end
			end
		end
	end

	return tbdata


end

-- ============================================================
-- ORION LIBRARY INTEGRATED SUBSYSTEM
-- ============================================================

local vgs = {
	MS  = (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:GetMouse()) or nil,
	VIM = game:GetService("VirtualInputManager"),
	p   = game:GetService("Players").LocalPlayer,
	UIS = game:GetService("UserInputService"),
	TS  = game:GetService("TweenService"),
	TTS = game:GetService("TextService"),
	HS  = game:GetService("HttpService"),
	RS  = game:GetService("RunService"),
	ps  = game:GetService("Players"),
	US  = game:GetService("UserService"),
	CP  = game:GetService("ContentProvider")
}

local rate = 1 / 200
local acc = 0

syde.Themes = syde.Themes or {
	Default = {
		Main = Color3.fromRGB(31, 20, 37),
		Second = Color3.fromRGB(35, 23, 41),
		Stroke = Color3.fromRGB(45, 29, 54),
		Divider = Color3.fromRGB(40, 26, 47),
		Text = Color3.fromRGB(240, 240, 242),
		TextDark = Color3.fromRGB(155, 155, 160),
		Accent = Color3.fromRGB(57, 37, 68)
	}
}
syde.SelectedTheme = syde.SelectedTheme or "Default"
syde.UMouseMode = syde.UMouseMode or "FreeMouse"
syde.ThemeObjects = syde.ThemeObjects or {}
syde.Connections = syde.Connections or {}
syde.Toggles = syde.Toggles or {}
syde.Dropdowns = syde.Dropdowns or {}
syde.elmnts = syde.elmnts or {}
syde.maxds = 500
syde.minds = 10
syde.Icons = syde.Icons or {}
syde.Flags = syde.Flags or {}

function syde:GenTheme(mainColor)
	if typeof(mainColor) ~= "Color3" then
		mainColor = Color3.fromRGB(31, 20, 37)
	end
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
	else
		t.Second = Color3.fromRGB(math.clamp(r * 0.94, 0, 255), math.clamp(g * 0.94, 0, 255), math.clamp(b * 0.94, 0, 255))
		t.Stroke = Color3.fromRGB(math.clamp(r * 0.75, 0, 255), math.clamp(g * 0.75, 0, 255), math.clamp(b * 0.75, 0, 255))
		t.Divider = Color3.fromRGB(math.clamp(r * 0.85, 0, 255), math.clamp(g * 0.85, 0, 255), math.clamp(b * 0.85, 0, 255))
		t.Text = Color3.fromRGB(35, 35, 38)
		t.TextDark = Color3.fromRGB(110, 110, 115)
		t.Accent = Color3.fromRGB(math.clamp(r * 0.72, 0, 255), math.clamp(g * 0.72, 0, 255), math.clamp(b * 0.72, 0, 255))
	end

	return t
end

syde.Themes.Default = syde:GenTheme(Color3.fromRGB(31, 20, 37))
syde.CurrentTheme = syde.Themes.Default

-- UnlockMouse implementation (Non-blocking: FreeMouse without GUI Modal trap)
local freeMouseBtn = nil
local nz = 0.5

function syde:UnlockMouse(Value)
	local lp = vgs.p or game:GetService("Players").LocalPlayer
	local uis = vgs.UIS or game:GetService("UserInputService")
	if not lp then return end

	if not freeMouseBtn then
		local parentGui = (gethui and gethui()) or coregui or lp:FindFirstChildOfClass("PlayerGui")
		freeMouseBtn = Instance.new("TextButton")
		freeMouseBtn.Name = "OrionFreeMouse"
		freeMouseBtn.Size = UDim2.new(0, 0, 0, 0)
		freeMouseBtn.Position = UDim2.new(0, 0, 0, 0)
		freeMouseBtn.BackgroundTransparency = 1
		freeMouseBtn.Text = ""
		freeMouseBtn.Modal = false
		freeMouseBtn.Active = false
		freeMouseBtn.Visible = false
		pcall(function() freeMouseBtn.Parent = parentGui end)
	end

	if freeMouseBtn then
		freeMouseBtn.Modal = false
		freeMouseBtn.Active = false
		freeMouseBtn.Visible = false
	end

	if syde.UMouseMode == "ThirdPerson" then
		if Value then
			pcall(function()
				lp.CameraMode = Enum.CameraMode.Classic
				uis.MouseBehavior = Enum.MouseBehavior.Default
				uis.MouseIconEnabled = true
				lp.CameraMaxZoomDistance = syde.maxds or 500
				lp.CameraMinZoomDistance = syde.minds or 10
			end)
		else
			pcall(function()
				uis.MouseIconEnabled = false
				uis.MouseBehavior = Enum.MouseBehavior.LockCenter
				lp.CameraMaxZoomDistance = nz
				lp.CameraMinZoomDistance = nz
				lp.CameraMode = Enum.CameraMode.LockFirstPerson
			end)
		end
	elseif syde.UMouseMode == "FreeMouse" then
		pcall(function()
			uis.MouseBehavior = Value and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
			uis.MouseIconEnabled = Value
		end)
	else
		pcall(function()
			uis.MouseBehavior = Value and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
			uis.MouseIconEnabled = Value
		end)
	end
end

-- Feather / Lucide icon loader
task.spawn(function()
	pcall(function()
		local json = game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")
		local decoded = https:JSONDecode(json)
		if decoded and decoded.icons then
			syde.Icons = decoded.icons
		end
	end)
end)

function syde:GetIcon(IconName)
	if syde.Icons and syde.Icons[IconName] then
		return syde.Icons[IconName]
	end
	return nil
end

-- Standalone MakeNotification
local notifGui = nil
local notifHolder = nil
local notifKeys = {}

function syde:MakeNotification(NotificationConfig)
	NotificationConfig = NotificationConfig or {}
	local title = NotificationConfig.Name or NotificationConfig.Title or "Notification"
	local content = NotificationConfig.Content or ""
	local image = NotificationConfig.Image or NotificationConfig.Icon or "rbxassetid://4384403532"
	local duration = NotificationConfig.Time or NotificationConfig.Duration or 5

	if not image:find("rbxassetid://") and not image:find("http") then
		image = "rbxassetid://" .. image
	end

	local key = title .. content
	if notifKeys[key] then return end
	notifKeys[key] = true

	task.spawn(function()
		pcall(function()
			vgs.CP:PreloadAsync({image})
		end)

		local lp = vgs.p or game:GetService("Players").LocalPlayer
		local targetParent = (gethui and gethui()) or coregui or (lp and lp:FindFirstChildOfClass("PlayerGui"))

		if not notifHolder or not notifHolder.Parent then
			notifGui = Instance.new("ScreenGui")
			notifGui.Name = "OrionNotifications"
			notifGui.ResetOnSpawn = false
			pcall(function() notifGui.Parent = targetParent end)

			notifHolder = Instance.new("Frame")
			notifHolder.Name = "Holder"
			notifHolder.Size = UDim2.new(0, 300, 1, -25)
			notifHolder.Position = UDim2.new(1, -25, 1, -25)
			notifHolder.AnchorPoint = Vector2.new(1, 1)
			notifHolder.BackgroundTransparency = 1
			notifHolder.Parent = notifGui

			local list = Instance.new("UIListLayout")
			list.SortOrder = Enum.SortOrder.LayoutOrder
			list.VerticalAlignment = Enum.VerticalAlignment.Bottom
			list.Padding = UDim.new(0, 6)
			list.Parent = notifHolder
		end

		local notifParent = Instance.new("Frame")
		notifParent.BackgroundTransparency = 1
		notifParent.Size = UDim2.new(1, 0, 0, 0)
		notifParent.AutomaticSize = Enum.AutomaticSize.Y
		notifParent.Parent = notifHolder

		local frame = Instance.new("Frame")
		frame.Name = "NotificationFrame"
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.Position = UDim2.new(1, 55, 0, 0)
		frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.Parent = notifParent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(55, 55, 55)
		stroke.Thickness = 1
		stroke.Parent = frame

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 10)
		pad.PaddingBottom = UDim.new(0, 10)
		pad.PaddingLeft = UDim.new(0, 12)
		pad.PaddingRight = UDim.new(0, 12)
		pad.Parent = frame

		local iconImg = Instance.new("ImageLabel")
		iconImg.Name = "Icon"
		iconImg.Size = UDim2.new(0, 20, 0, 20)
		iconImg.Position = UDim2.new(0, 0, 0, 0)
		iconImg.BackgroundTransparency = 1
		iconImg.Image = image
		iconImg.Parent = frame

		local tLabel = Instance.new("TextLabel")
		tLabel.Name = "Title"
		tLabel.Size = UDim2.new(1, -28, 0, 20)
		tLabel.Position = UDim2.new(0, 28, 0, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Font = Enum.Font.GothamBold
		tLabel.TextSize = 14
		tLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Text = title
		tLabel.Parent = frame

		local cLabel = Instance.new("TextLabel")
		cLabel.Name = "Content"
		cLabel.Size = UDim2.new(1, 0, 0, 0)
		cLabel.Position = UDim2.new(0, 0, 0, 24)
		cLabel.BackgroundTransparency = 1
		cLabel.Font = Enum.Font.Gotham
		cLabel.TextSize = 12
		cLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		cLabel.TextXAlignment = Enum.TextXAlignment.Left
		cLabel.TextWrapped = true
		cLabel.AutomaticSize = Enum.AutomaticSize.Y
		cLabel.Text = content
		cLabel.Parent = frame

		tweenservice:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

		task.wait(math.max(1, duration - 0.6))
		tweenservice:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1}):Play()
		tweenservice:Create(tLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenservice:Create(cLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		tweenservice:Create(iconImg, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()

		task.wait(0.6)
		notifParent:Destroy()
		notifKeys[key] = nil
	end)
end

-- Active window tracking for global tab / element focus
syde.ActiveWindow = nil

function syde:GoToTab(tabName)
	if syde.ActiveWindow and syde.ActiveWindow.GoToTab then
		syde.ActiveWindow:GoToTab(tabName)
	end
end

function syde:ScrollTo(tabName, sectionName, smooth)
	if syde.ActiveWindow and syde.ActiveWindow.ScrollTo then
		syde.ActiveWindow:ScrollTo(tabName, sectionName, smooth)
	end
end

function syde:ScrollToElement(tabName, element, smooth, offsetY)
	if syde.ActiveWindow and syde.ActiveWindow.ScrollToElement then
		syde.ActiveWindow:ScrollToElement(tabName, element, smooth, offsetY)
	end
end

function syde:FindAndFocusElement(query)
	if syde.ActiveWindow and syde.ActiveWindow.FindAndFocusElement then
		syde.ActiveWindow:FindAndFocusElement(query)
	end
end

-- Global Config and Theme persistence helpers
local ORION_THEME_FOLDER = "OrionTheme"
local ORION_FILE_PATH = ORION_THEME_FOLDER .. "/" .. tostring(game.GameId) .. ".txt"

function syde:SaveThemeCfg()
	if writefile then
		pcall(function()
			if not isfolder(ORION_THEME_FOLDER) and makefolder then
				makefolder(ORION_THEME_FOLDER)
			end
			local themeData = syde.Themes[syde.SelectedTheme]
			if not themeData then return end
			local data = {}
			for k, v in pairs(themeData) do
				if typeof(v) == "Color3" then
					data[k] = {R = v.R * 255, G = v.G * 255, B = v.B * 255}
				end
			end
			writefile(ORION_FILE_PATH, vgs.HS:JSONEncode(data))
		end)
	end
end

function syde:LoadThemeCfg(cfgPath)
	cfgPath = cfgPath or ORION_FILE_PATH
	if readfile and isfile and isfile(cfgPath) then
		pcall(function()
			local raw = readfile(cfgPath)
			local data = vgs.HS:JSONDecode(raw)
			syde.Themes.Custom = syde.Themes.Custom or {}
			for k, v in pairs(data) do
				if type(v) == "table" and v.R and v.G and v.B then
					syde.Themes.Custom[k] = Color3.fromRGB(v.R, v.G, v.B)
				end
			end
			syde.SelectedTheme = "Custom"
			syde:SetTheme()
		end)
	end
end

function syde:SaveCfg(name)
	if writefile and syde.Folder then
		pcall(function()
			if not isfolder(syde.Folder) and makefolder then
				makefolder(syde.Folder)
			end
			local data = {}
			for i, v in pairs(syde.Flags) do
				if type(v) == "table" and v.Save then
					if v.Type == "Colorpicker" then
						data[i] = {R = v.Value.R * 255, G = v.Value.G * 255, B = v.Value.B * 255}
					elseif v.Type == "PBind" then
						data[i] = {x = v.ValueX, y = v.ValueY, z = v.ValueZ}
					else
						data[i] = v.Value
					end
				end
			end
			writefile(syde.Folder .. "/" .. tostring(name) .. ".txt", vgs.HS:JSONEncode(data))
		end)
	end
end

function syde:LoadCfg(config)
	pcall(function()
		local data = (type(config) == "string" and vgs.HS:JSONDecode(config)) or config
		if type(data) == "table" then
			for k, val in pairs(data) do
				if syde.Flags[k] then
					task.spawn(function()
						local flag = syde.Flags[k]
						if flag.Type == "Colorpicker" and type(val) == "table" and val.R then
							flag:Set(Color3.fromRGB(val.R, val.G, val.B))
						elseif flag.Type == "PBind" and type(val) == "table" then
							flag:Set(val.x, val.y, val.z)
						elseif flag.Set then
							flag:Set(val)
						end
					end)
				end
			end
		end
	end)
end

function syde:SetTheme()
	local themeData = syde.Themes[syde.SelectedTheme] or syde.Themes.Default
	if not themeData then return end

	local function ReturnProp(obj)
		if obj:IsA("TextLabel") or obj:IsA("TextBox") then return "TextColor3" end
		if obj:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
		if obj:IsA("UIStroke") then return "Color" end
		if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then return "ImageColor3" end
		if obj:IsA("Frame") or obj:IsA("TextButton") then return "BackgroundColor3" end
		return nil
	end

	for typeName, objects in pairs(syde.ThemeObjects) do
		local color = themeData[typeName]
		if color then
			for _, obj in ipairs(objects) do
				if obj and obj.Parent then
					local prop = ReturnProp(obj)
					if prop and obj[prop] ~= nil then
						obj[prop] = color
					end
				end
			end
		end
	end

	if syde.Toggles then
		for _, toggle in ipairs(syde.Toggles) do
			if toggle and toggle.Box and toggle.Box.Parent then
				local accolor = (toggle.uccolor and toggle.ccolor) or themeData.Accent
				if toggle.Value then
					toggle.Box.BackgroundColor3 = accolor
					if toggle.Box:FindFirstChild("Stroke") then
						toggle.Box.Stroke.Color = accolor
					end
				else
					toggle.Box.BackgroundColor3 = themeData.Divider
					if toggle.Box:FindFirstChild("Stroke") then
						toggle.Box.Stroke.Color = themeData.Stroke
					end
				end
			end
		end
	end

	if syde.Dropdowns then
		for _, dropdown in ipairs(syde.Dropdowns) do
			if dropdown and dropdown.Buttons then
				for value, btn in pairs(dropdown.Buttons) do
					if btn and btn.Parent and btn:FindFirstChild("Checkbox") then
						local sel = (type(dropdown.Value) == "table" and table.find(dropdown.Value, value)) or (dropdown.Value == value)
						btn.Checkbox.BackgroundColor3 = sel and themeData.Accent or themeData.Divider
						if btn.Checkbox:FindFirstChild("Stroke") then
							btn.Checkbox.Stroke.Color = sel and themeData.Accent or themeData.Stroke
						end
					end
				end
			end
		end
	end

	syde:SaveThemeCfg()
end

-- ============================================================
-- STANDALONE ORION WINDOW ENGINE (syde:MakeWindow)
-- ============================================================
function syde:MakeWindow(WindowConfig)
	WindowConfig = WindowConfig or {}
	local WindowNameText = WindowConfig.Name or "Orion Library"
	local ConfigFolder = WindowConfig.ConfigFolder or WindowNameText
	local SaveConfig = WindowConfig.SaveConfig or false
	local TagText = WindowConfig.TagText or ""
	local HidePremium = WindowConfig.HidePremium or false
	local IntroEnabled = WindowConfig.IntroEnabled ~= false
	local FreeMouseMode = WindowConfig.FreeMouse or false
	local OpenKey = WindowConfig.Openkey or WindowConfig.KeyToOpenWindow or "RightShift"
	local IntroText = WindowConfig.IntroText or "Orion Library"
	local CloseCallback = WindowConfig.CloseCallback or function() end
	local ShowIcon = WindowConfig.ShowIcon or false
	local WindowIconId = WindowConfig.Icon or "rbxassetid://8834748103"
	local IntroIconId = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	local SearchBarEnabled = WindowConfig.SearchBar or false

	syde._EngineMode = "Orion"
	syde.Folder = ConfigFolder
	syde.SaveCfg = SaveConfig
	syde.SaveCfgState = SaveConfig
	if Library then pcall(function() Library.Enabled = false end) end

	if FreeMouseMode then
		syde:UnlockMouse(true)
	end

	if SaveConfig and isfolder and makefolder and not isfolder(ConfigFolder) then
		pcall(makefolder, ConfigFolder)
	end

	local targetParent = (gethui and gethui()) or coregui or (vgs.p and vgs.p:FindFirstChildOfClass("PlayerGui"))

	-- Cleanup previous Orion ScreenGuis
	for _, child in ipairs(targetParent:GetChildren()) do
		if child.Name == "OrionLib" or child.Name == "OrionBliz" then
			pcall(function() child:Destroy() end)
		end
	end

	local OrionGui = Instance.new("ScreenGui")
	OrionGui.Name = "OrionLib"
	OrionGui.ResetOnSpawn = false
	pcall(function() OrionGui.Parent = targetParent end)

	local ThemeObjects = {}
	local function AddTheme(obj, propType)
		ThemeObjects[propType] = ThemeObjects[propType] or {}
		table.insert(ThemeObjects[propType], obj)
		syde.ThemeObjects[propType] = syde.ThemeObjects[propType] or {}
		table.insert(syde.ThemeObjects[propType], obj)

		local theme = syde.Themes[syde.SelectedTheme] or syde.Themes.Default
		local col = theme[propType]
		if col then
			if obj:IsA("TextLabel") or obj:IsA("TextBox") then obj.TextColor3 = col
			elseif obj:IsA("ScrollingFrame") then obj.ScrollBarImageColor3 = col
			elseif obj:IsA("UIStroke") then obj.Color = col
			elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then obj.ImageColor3 = col
			elseif obj:IsA("Frame") or obj:IsA("TextButton") then obj.BackgroundColor3 = col
			end
		end
		return obj
	end

	-- Mobile Open Button
	local MobileOpenBtn = Instance.new("TextButton")
	MobileOpenBtn.Name = "MobileOpenButton"
	MobileOpenBtn.Size = UDim2.new(0, 48, 0, 48)
	MobileOpenBtn.Position = UDim2.new(0.5, -24, 0.05, 0)
	MobileOpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	MobileOpenBtn.Text = "UI"
	MobileOpenBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
	MobileOpenBtn.Font = Enum.Font.GothamBold
	MobileOpenBtn.TextSize = 14
	MobileOpenBtn.Visible = false
	MobileOpenBtn.Parent = OrionGui

	local mobCorner = Instance.new("UICorner")
	mobCorner.CornerRadius = UDim.new(0.3, 0)
	mobCorner.Parent = MobileOpenBtn

	local mobStroke = Instance.new("UIStroke")
	mobStroke.Color = Color3.fromRGB(70, 70, 70)
	mobStroke.Thickness = 1.5
	mobStroke.Parent = MobileOpenBtn

	-- Main Window Frame
	local MainWindow = Instance.new("Frame")
	MainWindow.Name = "MainWindow"
	MainWindow.Size = UDim2.new(0, 615, 0, 344)
	MainWindow.Position = UDim2.new(0.5, -307, 0.5, -172)
	MainWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	MainWindow.BorderSizePixel = 0
	MainWindow.ClipsDescendants = true
	MainWindow.Active = true
	MainWindow.Parent = OrionGui
	AddTheme(MainWindow, "Main")

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = MainWindow

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(50, 50, 50)
	mainStroke.Thickness = 1.5
	mainStroke.Parent = MainWindow
	AddTheme(mainStroke, "Stroke")

	-- Drag point
	local DragPoint = Instance.new("Frame")
	DragPoint.Name = "DragPoint"
	DragPoint.Size = UDim2.new(1, 0, 0, 50)
	DragPoint.BackgroundTransparency = 1
	DragPoint.Parent = MainWindow

	syde:AddDrag(DragPoint, MainWindow)
	syde:AddDrag(MobileOpenBtn, MobileOpenBtn)

	-- TopBar
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 50)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = MainWindow

	local WindowNameLabel = Instance.new("TextLabel")
	WindowNameLabel.Name = "WindowName"
	WindowNameLabel.Size = UDim2.new(1, -(ShowIcon and 155 or 130), 1, 0)
	WindowNameLabel.Position = UDim2.new(0, ShowIcon and 50 or 25, 0, 0)
	WindowNameLabel.BackgroundTransparency = 1
	WindowNameLabel.Font = Enum.Font.GothamBlack
	WindowNameLabel.TextSize = 18
	WindowNameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	WindowNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	WindowNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	WindowNameLabel.Text = WindowNameText
	WindowNameLabel.Parent = TopBar
	AddTheme(WindowNameLabel, "Text")

	local TopBarLine = Instance.new("Frame")
	TopBarLine.Name = "TopBarLine"
	TopBarLine.Size = UDim2.new(1, 0, 0, 1)
	TopBarLine.Position = UDim2.new(0, 0, 1, -1)
	TopBarLine.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	TopBarLine.BorderSizePixel = 0
	TopBarLine.Parent = TopBar
	AddTheme(TopBarLine, "Stroke")

	-- Window Icon
	local WindowIcon = nil
	if ShowIcon then
		WindowIcon = Instance.new("ImageLabel")
		WindowIcon.Name = "WindowIcon"
		WindowIcon.Size = UDim2.new(0, 28, 0, 28)
		WindowIcon.Position = UDim2.new(0, 14, 0.5, -14)
		WindowIcon.BackgroundTransparency = 1
		local ficon = tostring(WindowIconId)
		if not ficon:find("rbxassetid://") and not ficon:find("http") then
			ficon = "rbxassetid://" .. ficon
		end
		WindowIcon.Image = ficon
		WindowIcon.Parent = TopBar
	end

	-- Control Buttons Container (Minimize & Close)
	local ControlsFrame = Instance.new("Frame")
	ControlsFrame.Name = "Controls"
	ControlsFrame.Size = UDim2.new(0, 70, 0, 30)
	ControlsFrame.Position = UDim2.new(1, -85, 0, 10)
	ControlsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	ControlsFrame.BorderSizePixel = 0
	ControlsFrame.Parent = TopBar
	AddTheme(ControlsFrame, "Second")

	local ctrlCorner = Instance.new("UICorner")
	ctrlCorner.CornerRadius = UDim.new(0, 6)
	ctrlCorner.Parent = ControlsFrame

	local ctrlStroke = Instance.new("UIStroke")
	ctrlStroke.Color = Color3.fromRGB(55, 55, 55)
	ctrlStroke.Thickness = 1
	ctrlStroke.Parent = ControlsFrame
	AddTheme(ctrlStroke, "Stroke")

	local ctrlDivider = Instance.new("Frame")
	ctrlDivider.Size = UDim2.new(0, 1, 1, 0)
	ctrlDivider.Position = UDim2.new(0.5, 0, 0, 0)
	ctrlDivider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	ctrlDivider.BorderSizePixel = 0
	ctrlDivider.Parent = ControlsFrame
	AddTheme(ctrlDivider, "Stroke")

	local MinimizeBtn = Instance.new("TextButton")
	MinimizeBtn.Name = "Minimize"
	MinimizeBtn.Size = UDim2.new(0.5, 0, 1, 0)
	MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
	MinimizeBtn.BackgroundTransparency = 1
	MinimizeBtn.Text = ""
	MinimizeBtn.Parent = ControlsFrame

	local minIcon = Instance.new("ImageLabel")
	minIcon.Name = "Ico"
	minIcon.Size = UDim2.new(0, 16, 0, 16)
	minIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
	minIcon.BackgroundTransparency = 1
	minIcon.Image = "rbxassetid://7072719338"
	minIcon.Parent = MinimizeBtn
	AddTheme(minIcon, "Text")

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "Close"
	CloseBtn.Size = UDim2.new(0.5, 0, 1, 0)
	CloseBtn.Position = UDim2.new(0.5, 0, 0, 0)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = ""
	CloseBtn.Parent = ControlsFrame

	local closeIcon = Instance.new("ImageLabel")
	closeIcon.Name = "Ico"
	closeIcon.Size = UDim2.new(0, 16, 0, 16)
	closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
	closeIcon.BackgroundTransparency = 1
	closeIcon.Image = "rbxassetid://7072725342"
	closeIcon.Parent = CloseBtn
	AddTheme(closeIcon, "Text")

	-- Sidebar container (WindowStuff)
	local WindowStuff = Instance.new("Frame")
	WindowStuff.Name = "Sidebar"
	WindowStuff.Size = UDim2.new(0, 150, 1, -50)
	WindowStuff.Position = UDim2.new(0, 0, 0, 50)
	WindowStuff.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	WindowStuff.BorderSizePixel = 0
	WindowStuff.Parent = MainWindow
	AddTheme(WindowStuff, "Second")

	local sideDivider = Instance.new("Frame")
	sideDivider.Size = UDim2.new(0, 1, 1, 0)
	sideDivider.Position = UDim2.new(1, -1, 0, 0)
	sideDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	sideDivider.BorderSizePixel = 0
	sideDivider.Parent = WindowStuff
	AddTheme(sideDivider, "Stroke")

	-- Tab Holder ScrollFrame
	local TabHolder = Instance.new("ScrollingFrame")
	TabHolder.Name = "TabHolder"
	TabHolder.Size = UDim2.new(1, 0, 1, -50)
	TabHolder.Position = UDim2.new(0, 0, 0, 0)
	TabHolder.BackgroundTransparency = 1
	TabHolder.BorderSizePixel = 0
	TabHolder.ScrollBarThickness = 2
	TabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabHolder.Parent = WindowStuff
	AddTheme(TabHolder, "Divider")

	local tabList = Instance.new("UIListLayout")
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Padding = UDim.new(0, 4)
	tabList.Parent = TabHolder

	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingTop = UDim.new(0, 8)
	tabPad.PaddingBottom = UDim.new(0, 8)
	tabPad.PaddingLeft = UDim.new(0, 8)
	tabPad.PaddingRight = UDim.new(0, 8)
	tabPad.Parent = TabHolder

	tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, tabList.AbsoluteContentSize.Y + 16)
	end)

	-- Profile footer
	local FooterFrame = Instance.new("Frame")
	FooterFrame.Name = "Footer"
	FooterFrame.Size = UDim2.new(1, 0, 0, 50)
	FooterFrame.Position = UDim2.new(0, 0, 1, -50)
	FooterFrame.BackgroundTransparency = 1
	FooterFrame.Parent = WindowStuff

	local footerTopLine = Instance.new("Frame")
	footerTopLine.Size = UDim2.new(1, 0, 0, 1)
	footerTopLine.Position = UDim2.new(0, 0, 0, 0)
	footerTopLine.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	footerTopLine.BorderSizePixel = 0
	footerTopLine.Parent = FooterFrame
	AddTheme(footerTopLine, "Stroke")

	local lp = vgs.p or game:GetService("Players").LocalPlayer
	local pUserId = (lp and lp.UserId) or 1
	local pName = (lp and lp.DisplayName) or "Player"

	local pThumb = Instance.new("ImageLabel")
	pThumb.Size = UDim2.new(0, 32, 0, 32)
	pThumb.Position = UDim2.new(0, 10, 0.5, -16)
	pThumb.BackgroundTransparency = 1
	pThumb.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. pUserId .. "&width=420&height=420&format=png"
	pThumb.Parent = FooterFrame

	local pThumbCorner = Instance.new("UICorner")
	pThumbCorner.CornerRadius = UDim.new(0.5, 0)
	pThumbCorner.Parent = pThumb

	local pLabel = Instance.new("TextLabel")
	pLabel.Size = UDim2.new(1, -55, 0, 16)
	pLabel.Position = UDim2.new(0, 48, 0.5, -8)
	pLabel.BackgroundTransparency = 1
	pLabel.Font = Enum.Font.GothamBold
	pLabel.TextSize = 13
	pLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	pLabel.TextXAlignment = Enum.TextXAlignment.Left
	pLabel.TextTruncate = Enum.TextTruncate.AtEnd
	pLabel.Text = pName
	pLabel.Parent = FooterFrame
	AddTheme(pLabel, "Text")

	-- Corner resize handle
	local resizeHandle = Instance.new("Frame")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Size = UDim2.new(0, 18, 0, 18)
	resizeHandle.Position = UDim2.new(1, -18, 1, -18)
	resizeHandle.BackgroundTransparency = 1
	resizeHandle.Parent = MainWindow

	local resCorner = Instance.new("UICorner")
	resCorner.CornerRadius = UDim.new(0.5, 0)
	resCorner.Parent = resizeHandle

	local resImg = Instance.new("ImageLabel")
	resImg.Size = UDim2.new(1, 0, 1, 0)
	resImg.BackgroundTransparency = 1
	resImg.Image = "rbxassetid://153287173"
	resImg.ImageTransparency = 0.4
	resImg.Parent = resizeHandle
	AddTheme(resImg, "Text")

	local resizing = false
	local startMousePos, startSize
	local lastResizeClick = 0

	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local now = tick()
			if now - lastResizeClick <= 0.4 then
				-- Double click resets size
				tweenservice:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 615, 0, 344)
				}):Play()
				resizing = false
			else
				resizing = true
				startMousePos = vgs.UIS:GetMouseLocation()
				startSize = MainWindow.AbsoluteSize
			end
			lastResizeClick = now
		end
	end)

	vgs.UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)

	vgs.RS.RenderStepped:Connect(function()
		if resizing then
			local mousePos = vgs.UIS:GetMouseLocation()
			local delta = mousePos - startMousePos
			local newW = math.clamp(startSize.X + delta.X, 400, 1200)
			local newH = math.clamp(startSize.Y + delta.Y, 260, 900)
			MainWindow.Size = UDim2.new(0, newW, 0, newH)
		end
	end)

	-- Minimize toggle logic
	local minimized = false
	local lastHeaderClick = 0

	local function toggleMinimize()
		minimized = not minimized
		if minimized then
			MainWindow.ClipsDescendants = true
			TopBarLine.Visible = false
			WindowStuff.Visible = false
			resizeHandle.Visible = false
			minIcon.Image = "rbxassetid://7072720870"

			local textSize = vgs.TTS:GetTextSize(WindowNameLabel.Text, WindowNameLabel.TextSize, WindowNameLabel.Font, Vector2.new(math.huge, math.huge)).X
			local targetW = math.clamp(textSize + 140, 220, 900)
			tweenservice:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, targetW, 0, 50)
			}):Play()
		else
			minIcon.Image = "rbxassetid://7072719338"
			tweenservice:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 615, 0, 344)
			}):Play()
			task.delay(0.05, function()
				MainWindow.ClipsDescendants = false
				TopBarLine.Visible = true
				WindowStuff.Visible = true
				resizeHandle.Visible = true
			end)
		end
	end

	MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)

	-- Header double-click to snap top-center
	DragPoint.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local now = tick()
			if now - lastHeaderClick <= 0.35 then
				local cam = workspace.CurrentCamera
				if cam then
					local vp = cam.ViewportSize
					local targetX = (vp.X - MainWindow.AbsoluteSize.X) / 2
					tweenservice:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = UDim2.new(0, targetX, 0, 10)
					}):Play()
				end
			end
			lastHeaderClick = now
		end
	end)

	-- Close logic
	local UIHidden = false
	local function hideUI()
		MainWindow.Visible = false
		UIHidden = true
		if FreeMouseMode then
			syde:UnlockMouse(false)
		end
		if vgs.UIS.TouchEnabled and not vgs.UIS.KeyboardEnabled then
			MobileOpenBtn.Visible = true
		end
		pcall(CloseCallback)
		syde:MakeNotification({
			Name = "Interface Hidden",
			Content = "Tap " .. tostring(OpenKey) .. " to reopen the interface.",
			Time = 3
		})
	end

	local function showUI()
		MainWindow.Visible = true
		UIHidden = false
		MobileOpenBtn.Visible = false
		if FreeMouseMode then
			syde:UnlockMouse(true)
		end
	end

	CloseBtn.MouseButton1Click:Connect(hideUI)
	MobileOpenBtn.MouseButton1Click:Connect(showUI)

	vgs.UIS.InputBegan:Connect(function(input, gpe)
		if not gpe then
			local ok, code = pcall(function() return Enum.KeyCode[OpenKey] end)
			if ok and code and input.KeyCode == code then
				if UIHidden then
					showUI()
				else
					hideUI()
				end
			end
		end
	end)

	-- Intro Sequence
	if IntroEnabled then
		MainWindow.Visible = false
		task.spawn(function()
			local introLogo = Instance.new("ImageLabel")
			introLogo.Size = UDim2.new(0, 48, 0, 48)
			introLogo.Position = UDim2.new(0.5, -24, 0.45, -24)
			introLogo.BackgroundTransparency = 1
			introLogo.ImageTransparency = 1
			local ficon = tostring(IntroIconId)
			if not ficon:find("rbxassetid://") and not ficon:find("http") then ficon = "rbxassetid://" .. ficon end
			introLogo.Image = ficon
			introLogo.Parent = OrionGui

			local introText = Instance.new("TextLabel")
			introText.Size = UDim2.new(1, 0, 0, 30)
			introText.Position = UDim2.new(0, 0, 0.52, 0)
			introText.BackgroundTransparency = 1
			introText.TextTransparency = 1
			introText.Font = Enum.Font.GothamBold
			introText.TextSize = 18
			introText.TextColor3 = Color3.fromRGB(240, 240, 240)
			introText.Text = IntroText
			introText.Parent = OrionGui

			tweenservice:Create(introLogo, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
			task.wait(0.3)
			tweenservice:Create(introText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
			task.wait(1.2)
			tweenservice:Create(introLogo, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
			tweenservice:Create(introText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
			task.wait(0.35)
			introLogo:Destroy()
			introText:Destroy()
			MainWindow.Visible = true
		end)
	end

	-- Search System
	local SearchSystem = {
		tabs = {},
		buttons = {},
		elements = {},
		activeTab = nil
	}

	local function RegisterTab(tabName, container, button)
		SearchSystem.tabs[tabName] = container
		SearchSystem.buttons[tabName] = button
	end

	local function RegisterElement(tabName, elemName, elemFrame)
		SearchSystem.elements[tabName] = SearchSystem.elements[tabName] or {}
		SearchSystem.elements[tabName][elemName] = {
			frame = elemFrame,
			visible = true
		}
	end

	local function HighlightElement(frame, highlight)
		if not frame then return end
		local glow = frame:FindFirstChild("SearchGlow")
		if highlight then
			if not glow then
				glow = Instance.new("UIStroke")
				glow.Name = "SearchGlow"
				glow.Thickness = 1
				glow.Transparency = 0
				glow.Color = (syde.Themes[syde.SelectedTheme] and syde.Themes[syde.SelectedTheme].Accent) or Color3.fromRGB(0, 162, 255)
				glow.Parent = frame
			end
			tweenservice:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Thickness = 2.5,
				Transparency = 0
			}):Play()
		else
			if glow then
				tweenservice:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				task.delay(0.3, function()
					if glow and glow.Parent then glow:Destroy() end
				end)
			end
		end
	end

	local function ClearSearch()
		for tabName, elems in pairs(SearchSystem.elements) do
			for _, data in pairs(elems) do
				if data.frame and data.frame.Parent then
					data.frame.Visible = data.visible
					HighlightElement(data.frame, false)
				end
			end
		end
		for _, btn in pairs(SearchSystem.buttons) do
			btn.Visible = true
		end
	end

	local function GoToTab(tabName)
		if not SearchSystem.tabs[tabName] or not SearchSystem.buttons[tabName] then return end

		for name, btn in pairs(SearchSystem.buttons) do
			if btn:FindFirstChild("Title") then
				btn.Title.Font = (name == tabName) and Enum.Font.GothamBlack or Enum.Font.GothamSemibold
				tweenservice:Create(btn.Title, TweenInfo.new(0.2), {TextTransparency = (name == tabName) and 0 or 0.4}):Play()
			end
			if btn:FindFirstChild("Ico") then
				tweenservice:Create(btn.Ico, TweenInfo.new(0.2), {ImageTransparency = (name == tabName) and 0 or 0.4}):Play()
			end
		end

		for name, cont in pairs(SearchSystem.tabs) do
			cont.Visible = (name == tabName)
		end
		SearchSystem.activeTab = tabName
	end

	local function ExecuteSearch(query)
		query = query:lower()
		if query == "" then
			ClearSearch()
			return
		end

		local bestTab = nil
		local bestScore = 0

		for tabName, elems in pairs(SearchSystem.elements) do
			local score = 0
			for elemName, data in pairs(elems) do
				local matched = elemName:lower():find(query, 1, true) ~= nil
				data.frame.Visible = matched
				HighlightElement(data.frame, matched)
				if matched then
					score = score + 1
				end
			end
			if SearchSystem.buttons[tabName] then
				SearchSystem.buttons[tabName].Visible = (score > 0)
			end
			if score > bestScore then
				bestScore = score
				bestTab = tabName
			end
		end

		if bestTab then
			GoToTab(bestTab)
		end
	end

	-- Window Methods & Tab Factory
	local WindowFunctions = {}

	function WindowFunctions:ChangeIcon(IconId)
		if WindowIcon then
			local ficon = tostring(IconId)
			if not ficon:find("rbxassetid://") and not ficon:find("http") then ficon = "rbxassetid://" .. ficon end
			WindowIcon.Image = ficon
		end
	end

	function WindowFunctions:SetName(...)
		local args = {...}
		local result = ""
		for _, pair in ipairs(args) do
			if type(pair) == "table" then
				local text, color = pair[1] or "", pair[2] or "#FFFFFF"
				for i = 1, #text do
					local char = text:sub(i, i)
					result = result .. '<font color="' .. color .. '">' .. char .. '</font>'
				end
			else
				result = result .. tostring(pair)
			end
		end
		WindowNameLabel.RichText = true
		WindowNameLabel.Text = result
	end

	function WindowFunctions:GoToTab(tabName)
		GoToTab(tabName)
	end

	function WindowFunctions:ScrollTo(tabName, sectionName, smooth)
		GoToTab(tabName)
		local cont = SearchSystem.tabs[tabName]
		if cont then
			local target = cont:FindFirstChild(sectionName)
			if target then
				local relY = target.AbsolutePosition.Y - cont.AbsolutePosition.Y + cont.CanvasPosition.Y
				local maxY = math.max(0, cont.CanvasSize.Y.Offset - cont.AbsoluteSize.Y)
				local targetY = math.clamp(relY - 20, 0, maxY)
				if smooth then
					tweenservice:Create(cont, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CanvasPosition = Vector2.new(0, targetY)
					}):Play()
				else
					cont.CanvasPosition = Vector2.new(0, targetY)
				end
			end
		end
	end

	function WindowFunctions:ScrollToElement(tabName, element, smooth, offsetY)
		GoToTab(tabName)
		local cont = SearchSystem.tabs[tabName]
		if not cont then return end
		local target = nil
		if typeof(element) == "Instance" then
			target = element
		elseif typeof(element) == "string" then
			for _, d in ipairs(cont:GetDescendants()) do
				if d:IsA("TextLabel") and d.Text:lower():find(element:lower(), 1, true) then
					target = d.Parent
					break
				end
			end
		end
		if target then
			local off = (offsetY == "center" and (cont.AbsoluteSize.Y / 2) or (tonumber(offsetY) or 20))
			local relY = target.AbsolutePosition.Y - cont.AbsolutePosition.Y + cont.CanvasPosition.Y
			local maxY = math.max(0, cont.CanvasSize.Y.Offset - cont.AbsoluteSize.Y)
			local targetY = math.clamp(relY - off, 0, maxY)
			if smooth then
				tweenservice:Create(cont, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CanvasPosition = Vector2.new(0, targetY)
				}):Play()
			else
				cont.CanvasPosition = Vector2.new(0, targetY)
			end
		end
	end

	function WindowFunctions:FindAndFocusElement(query)
		ExecuteSearch(query)
	end

	function WindowFunctions:Destroy()
		pcall(function() OrionGui:Destroy() end)
	end

	-- MakeTab
	local isFirstTabCreated = true

	function WindowFunctions:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		local tabTitle = TabConfig.Name or TabConfig.Title or "Tab"
		local tabIcon = TabConfig.Icon or ""

		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = tabTitle
		TabBtn.Size = UDim2.new(1, 0, 0, 32)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.Parent = TabHolder

		local highlight = Instance.new("Frame")
		highlight.Name = "Highlight"
		highlight.Size = UDim2.new(1, 0, 1, 0)
		highlight.BackgroundTransparency = 1
		highlight.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		highlight.Parent = TabBtn
		AddTheme(highlight, "Divider")

		local hlCorner = Instance.new("UICorner")
		hlCorner.CornerRadius = UDim.new(0, 6)
		hlCorner.Parent = highlight

		local iconLabel = Instance.new("ImageLabel")
		iconLabel.Name = "Ico"
		iconLabel.Size = UDim2.new(0, 18, 0, 18)
		iconLabel.Position = UDim2.new(0, 8, 0.5, -9)
		iconLabel.BackgroundTransparency = 1
		iconLabel.ImageTransparency = isFirstTabCreated and 0 or 0.4
		local resolvedIcon = syde:GetIcon(tabIcon) or tabIcon
		if resolvedIcon ~= "" and not resolvedIcon:find("rbxassetid://") and not resolvedIcon:find("http") then
			resolvedIcon = "rbxassetid://" .. resolvedIcon
		end
		iconLabel.Image = resolvedIcon
		iconLabel.Parent = TabBtn
		AddTheme(iconLabel, "Text")

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Title"
		textLabel.Size = UDim2.new(1, -34, 1, 0)
		textLabel.Position = UDim2.new(0, 34, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = isFirstTabCreated and Enum.Font.GothamBlack or Enum.Font.GothamSemibold
		textLabel.TextSize = 13
		textLabel.TextTransparency = isFirstTabCreated and 0 or 0.4
		textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = tabTitle
		textLabel.Parent = TabBtn
		AddTheme(textLabel, "Text")

		-- Page Container (ScrollFrame)
		local PageContainer = Instance.new("ScrollingFrame")
		PageContainer.Name = tabTitle
		PageContainer.Size = UDim2.new(1, -150, 1, -50)
		PageContainer.Position = UDim2.new(0, 150, 0, 50)
		PageContainer.BackgroundTransparency = 1
		PageContainer.BorderSizePixel = 0
		PageContainer.ScrollBarThickness = 3
		PageContainer.Visible = isFirstTabCreated
		PageContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
		PageContainer.Parent = MainWindow
		AddTheme(PageContainer, "Divider")

		local pageList = Instance.new("UIListLayout")
		pageList.SortOrder = Enum.SortOrder.LayoutOrder
		pageList.Padding = UDim.new(0, 6)
		pageList.Parent = PageContainer

		local pagePad = Instance.new("UIPadding")
		pagePad.PaddingTop = UDim.new(0, 10)
		pagePad.PaddingBottom = UDim.new(0, 10)
		pagePad.PaddingLeft = UDim.new(0, 12)
		pagePad.PaddingRight = UDim.new(0, 12)
		pagePad.Parent = PageContainer

		pageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			PageContainer.CanvasSize = UDim2.new(0, 0, 0, pageList.AbsoluteContentSize.Y + 24)
		end)

		RegisterTab(tabTitle, PageContainer, TabBtn)

		TabBtn.MouseButton1Click:Connect(function()
			GoToTab(tabTitle)
		end)

		if isFirstTabCreated then
			SearchSystem.activeTab = tabTitle
			isFirstTabCreated = false
		end

		-- Element Builder for this Tab
		local TabElements = {}

		local function MakeBaseFrame(elemName, h)
			h = h or 36
			local f = Instance.new("Frame")
			f.Name = elemName
			f.Size = UDim2.new(1, 0, 0, h)
			f.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
			f.BorderSizePixel = 0
			f.Parent = PageContainer

			local crn = Instance.new("UICorner")
			crn.CornerRadius = UDim.new(0, 6)
			crn.Parent = f

			local strk = Instance.new("UIStroke")
			strk.Color = Color3.fromRGB(50, 50, 50)
			strk.Thickness = 1
			strk.Parent = f
			AddTheme(strk, "Stroke")
			AddTheme(f, "Second")

			RegisterElement(tabTitle, elemName, f)
			return f
		end

		-- AddLog
		function TabElements:AddLog(Text)
			Text = tostring(Text or "")
			local f = MakeBaseFrame("Log_" .. Text:sub(1, 15), 38)
			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -16, 1, 0)
			lbl.Position = UDim2.new(0, 8, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Center
			lbl.Text = Text
			lbl.Parent = f
			AddTheme(lbl, "Text")

			return {
				Frame = f,
				Set = function(self, t) lbl.Text = tostring(t or "") end,
				toggle = function(self) f.Visible = not f.Visible end,
				remove = function(self) f:Destroy() end
			}
		end

		-- AddLabel
		function TabElements:AddLabel(Text)
			Text = tostring(Text or "")
			local f = MakeBaseFrame("Label_" .. Text:sub(1, 15), 32)
			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -20, 1, 0)
			lbl.Position = UDim2.new(0, 10, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = Text
			lbl.Parent = f
			AddTheme(lbl, "Text")

			return {
				Frame = f,
				Set = function(self, newText, colorConfig)
					newText = tostring(newText or "")
					if type(colorConfig) == "table" then
						for word, col in pairs(colorConfig) do
							if newText:find(word) then
								local escaped = word:gsub("([%(%)%.%+%-%*%?%[%]%^%$%%])", "%%%1")
								newText = newText:gsub(escaped, '<font color="' .. col .. '">' .. word .. '</font>')
							end
						end
						lbl.RichText = true
					end
					lbl.Text = newText
				end,
				toggle = function(self) f.Visible = not f.Visible end,
				remove = function(self) f:Destroy() end
			}
		end

		-- ColorLabel
		function TabElements:ColorLabel(Text, ToChangeColor, Position)
			Text = tostring(Text or "")
			ToChangeColor = ToChangeColor or Color3.fromRGB(255, 255, 255)
			Position = Position or "Left"

			local f = MakeBaseFrame("ColorLabel_" .. Text:sub(1, 15), 34)
			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -24, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = ToChangeColor
			lbl.Text = Text
			lbl.Parent = f

			if Position == "Center" then lbl.TextXAlignment = Enum.TextXAlignment.Center
			elseif Position == "Right" then lbl.TextXAlignment = Enum.TextXAlignment.Right
			else lbl.TextXAlignment = Enum.TextXAlignment.Left end

			return {
				Frame = f,
				Set = function(self, t, c, p)
					if t then lbl.Text = tostring(t) end
					if c then lbl.TextColor3 = c end
					if p then
						if p == "Center" then lbl.TextXAlignment = Enum.TextXAlignment.Center
						elseif p == "Right" then lbl.TextXAlignment = Enum.TextXAlignment.Right
						else lbl.TextXAlignment = Enum.TextXAlignment.Left end
					end
				end,
				toggle = function(self) f.Visible = not f.Visible end,
				remove = function(self) f:Destroy() end
			}
		end

		-- AddPlayerParagraph
		function TabElements:AddPlayerParagraph(userId)
			userId = tonumber(userId) or 0
			local f = MakeBaseFrame("PlayerPara_" .. tostring(userId), 66)

			local avatar = Instance.new("ImageLabel")
			avatar.Size = UDim2.new(0, 50, 0, 50)
			avatar.Position = UDim2.new(0, 8, 0.5, -25)
			avatar.BackgroundTransparency = 1
			avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
			avatar.Parent = f

			local avCrn = Instance.new("UICorner")
			avCrn.CornerRadius = UDim.new(0, 8)
			avCrn.Parent = avatar

			local dLabel = Instance.new("TextLabel")
			dLabel.Size = UDim2.new(1, -72, 0, 20)
			dLabel.Position = UDim2.new(0, 66, 0, 12)
			dLabel.BackgroundTransparency = 1
			dLabel.Font = Enum.Font.GothamBold
			dLabel.TextSize = 14
			dLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
			dLabel.TextXAlignment = Enum.TextXAlignment.Left
			dLabel.Text = "Loading..."
			dLabel.Parent = f
			AddTheme(dLabel, "Text")

			local uLabel = Instance.new("TextLabel")
			uLabel.Size = UDim2.new(1, -72, 0, 18)
			uLabel.Position = UDim2.new(0, 66, 0, 34)
			uLabel.BackgroundTransparency = 1
			uLabel.Font = Enum.Font.GothamSemibold
			uLabel.TextSize = 12
			uLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
			uLabel.TextXAlignment = Enum.TextXAlignment.Left
			uLabel.Text = "@..."
			uLabel.Parent = f
			AddTheme(uLabel, "TextDark")

			local function fetch(uId)
				task.spawn(function()
					local ok, data = pcall(function()
						return game:GetService("UserService"):GetUserInfosByUserIdsAsync({uId})
					end)
					if ok and data and data[1] then
						dLabel.Text = data[1].DisplayName or "Unknown"
						uLabel.Text = "@" .. (data[1].Username or "Unknown")
					end
				end)
			end
			if userId > 0 then fetch(userId) end

			return {
				Frame = f,
				Set = function(self, newId)
					newId = tonumber(newId) or 0
					avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. newId .. "&width=420&height=420&format=png"
					fetch(newId)
				end,
				toggle = function(self) f.Visible = not f.Visible end,
				remove = function(self) f:Destroy() end
			}
		end

		-- AddParagraph
		function TabElements:AddParagraph(...)
			local args = {...}
			local id, title, content, align
			if type(args[1]) == "table" then
				local tbl = args[1]
				id = tbl.Id or tbl.id
				title = tbl.Title or tbl.Name or ""
				content = tbl.Content or tbl.Text or ""
				align = tbl.Align or tbl.Alignment or "Left"
			elseif #args >= 3 and tonumber(args[1]) ~= nil then
				id = tostring(args[1])
				title = args[2] or ""
				content = args[3] or ""
				align = args[4] or "Left"
			else
				title = args[1] or ""
				content = args[2] or ""
				align = args[3] or "Left"
			end

			if id and tonumber(id) then
				return TabElements:AddPlayerParagraph(tonumber(id))
			end

			local f = MakeBaseFrame("Paragraph_" .. tostring(title):sub(1, 15), 52)
			f.AutomaticSize = Enum.AutomaticSize.Y

			local tLabel = Instance.new("TextLabel")
			tLabel.Name = "Title"
			tLabel.Size = UDim2.new(1, -24, 0, 20)
			tLabel.Position = UDim2.new(0, 12, 0, 8)
			tLabel.BackgroundTransparency = 1
			tLabel.Font = Enum.Font.GothamBold
			tLabel.TextSize = 14
			tLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
			tLabel.TextXAlignment = Enum.TextXAlignment.Left
			tLabel.Text = title
			tLabel.Parent = f
			AddTheme(tLabel, "Text")

			local cLabel = Instance.new("TextLabel")
			cLabel.Name = "Content"
			cLabel.Size = UDim2.new(1, -24, 0, 0)
			cLabel.Position = UDim2.new(0, 12, 0, 28)
			cLabel.BackgroundTransparency = 1
			cLabel.Font = Enum.Font.Gotham
			cLabel.TextSize = 12
			cLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			cLabel.TextXAlignment = Enum.TextXAlignment.Left
			cLabel.TextWrapped = true
			cLabel.AutomaticSize = Enum.AutomaticSize.Y
			cLabel.Text = content
			cLabel.Parent = f
			AddTheme(cLabel, "TextDark")

			return {
				Frame = f,
				Set = function(self, newT, newC)
					if newT then tLabel.Text = tostring(newT) end
					if newC then cLabel.Text = tostring(newC) end
				end,
				toggle = function(self) f.Visible = not f.Visible end,
				remove = function(self) f:Destroy() end
			}
		end

		-- AddButton
		function TabElements:AddButton(ButtonConfig)
			ButtonConfig = ButtonConfig or {}
			local name = ButtonConfig.Name or ButtonConfig.Title or "Button"
			local callback = ButtonConfig.Callback or ButtonConfig.CallBack or function() end
			local icon = ButtonConfig.Icon or "rbxassetid://3944703587"

			local f = MakeBaseFrame(name, 34)

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.Parent = f

			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -40, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = name
			lbl.Parent = f
			AddTheme(lbl, "Text")

			local ico = Instance.new("ImageLabel")
			ico.Size = UDim2.new(0, 18, 0, 18)
			ico.Position = UDim2.new(1, -26, 0.5, -9)
			ico.BackgroundTransparency = 1
			local resolved = syde:GetIcon(icon) or icon
			if resolved ~= "" and not resolved:find("rbxassetid://") and not resolved:find("http") then
				resolved = "rbxassetid://" .. resolved
			end
			ico.Image = resolved
			ico.Parent = f
			AddTheme(ico, "TextDark")

			btn.MouseButton1Click:Connect(function()
				tweenservice:Create(f, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
				task.delay(0.1, function()
					local theme = syde.Themes[syde.SelectedTheme] or syde.Themes.Default
					tweenservice:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = theme.Second}):Play()
				end)
				pcall(callback)
			end)

			return {
				Frame = f,
				Set = function(self, t) lbl.Text = tostring(t or "") end,
				toggle = function(self) f.Visible = not f.Visible end,
				remove = function(self) f:Destroy() end
			}
		end

		-- AddToggle
		function TabElements:AddToggle(ToggleConfig)
			ToggleConfig = ToggleConfig or {}
			local name = ToggleConfig.Name or ToggleConfig.Title or "Toggle"
			local defVal = (ToggleConfig.Default ~= nil and ToggleConfig.Default) or (ToggleConfig.Value ~= nil and ToggleConfig.Value) or false
			local callback = ToggleConfig.Callback or ToggleConfig.CallBack or function() end
			local flag = ToggleConfig.Flag
			local save = ToggleConfig.Save or false

			local f = MakeBaseFrame(name, 36)

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.Parent = f

			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -50, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = name
			lbl.Parent = f
			AddTheme(lbl, "Text")

			local toggleBox = Instance.new("Frame")
			toggleBox.Name = "Box"
			toggleBox.Size = UDim2.new(0, 22, 0, 22)
			toggleBox.Position = UDim2.new(1, -32, 0.5, -11)
			toggleBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			toggleBox.BorderSizePixel = 0
			toggleBox.Parent = f

			local tbCorner = Instance.new("UICorner")
			tbCorner.CornerRadius = UDim.new(0, 5)
			tbCorner.Parent = toggleBox

			local tbStroke = Instance.new("UIStroke")
			tbStroke.Name = "Stroke"
			tbStroke.Color = Color3.fromRGB(65, 65, 65)
			tbStroke.Thickness = 1
			tbStroke.Parent = toggleBox

			local checkIco = Instance.new("ImageLabel")
			checkIco.Name = "Ico"
			checkIco.Size = UDim2.new(0, 16, 0, 16)
			checkIco.Position = UDim2.new(0.5, -8, 0.5, -8)
			checkIco.BackgroundTransparency = 1
			checkIco.Image = "rbxassetid://3944680095"
			checkIco.ImageTransparency = defVal and 0 or 1
			checkIco.Parent = toggleBox

			local toggleObj = {
				Value = defVal,
				Box = toggleBox,
				Frame = f,
				Save = save,
				Flag = flag
			}

			function toggleObj:Set(val, silent)
				toggleObj.Value = val
				local theme = syde.Themes[syde.SelectedTheme] or syde.Themes.Default
				local targetColor = val and (theme.Accent or Color3.fromRGB(0, 162, 255)) or theme.Divider
				tweenservice:Create(toggleBox, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
				tweenservice:Create(checkIco, TweenInfo.new(0.2), {ImageTransparency = val and 0 or 1}):Play()
				if not silent then
					pcall(callback, val)
				end
				if save and flag then
					syde:SaveCfg(syde.Folder or game.GameId)
				end
			end

			btn.MouseButton1Click:Connect(function()
				toggleObj:Set(not toggleObj.Value)
			end)

			table.insert(syde.Toggles, toggleObj)
			if flag then
				syde.Flags[flag] = toggleObj
			end
			toggleObj:Set(defVal, true)

			toggleObj.toggle = function(self) f.Visible = not f.Visible end
			toggleObj.remove = function(self) f:Destroy() end

			return toggleObj
		end

		-- AddSlider
		function TabElements:AddSlider(SliderConfig)
			SliderConfig = SliderConfig or {}
			local name = SliderConfig.Name or SliderConfig.Title or "Slider"
			local min = SliderConfig.Min or 0
			local max = SliderConfig.Max or 100
			local def = SliderConfig.Default or min
			local inc = SliderConfig.Increment or 1
			local callback = SliderConfig.Callback or SliderConfig.CallBack or function() end
			local valueName = SliderConfig.ValueName or ""
			local flag = SliderConfig.Flag

			local f = MakeBaseFrame(name, 56)

			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -12, 0, 18)
			lbl.Position = UDim2.new(0, 12, 0, 8)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = name
			lbl.Parent = f
			AddTheme(lbl, "Text")

			local valLabel = Instance.new("TextLabel")
			valLabel.Size = UDim2.new(0, 100, 0, 18)
			valLabel.Position = UDim2.new(1, -112, 0, 8)
			valLabel.BackgroundTransparency = 1
			valLabel.Font = Enum.Font.GothamBold
			valLabel.TextSize = 13
			valLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			valLabel.TextXAlignment = Enum.TextXAlignment.Right
			valLabel.Text = tostring(def) .. " " .. valueName
			valLabel.Parent = f
			AddTheme(valLabel, "TextDark")

			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(1, -24, 0, 8)
			bar.Position = UDim2.new(0, 12, 0, 36)
			bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			bar.BorderSizePixel = 0
			bar.Parent = f

			local bCrn = Instance.new("UICorner")
			bCrn.CornerRadius = UDim.new(0.5, 0)
			bCrn.Parent = bar

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new(0, 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
			fill.BorderSizePixel = 0
			fill.Parent = bar
			AddTheme(fill, "Accent")

			local fCrn = Instance.new("UICorner")
			fCrn.CornerRadius = UDim.new(0.5, 0)
			fCrn.Parent = fill

			local sliderObj = {
				Value = def,
				Frame = f,
				Flag = flag
			}

			local function formatVal(v)
				if v == math.huge then return "∞" end
				if v >= 1e6 then return string.format("%.1fM", v / 1e6) end
				if v >= 1e3 then return string.format("%.1fK", v / 1e3) end
				return tostring(math.floor(v * 100) / 100)
			end

			function sliderObj:Set(v)
				local clamped = math.clamp(v, min, max)
				sliderObj.Value = clamped
				local pct = (max == min) and 0 or math.clamp((clamped - min) / (max - min), 0, 1)
				fill.Size = UDim2.new(pct, 0, 1, 0)
				valLabel.Text = formatVal(clamped) .. " " .. valueName
				pcall(callback, clamped)
			end

			function sliderObj:SetName(n)
				lbl.Text = tostring(n or "")
			end

			function sliderObj:SetMax(m)
				max = m
				sliderObj:Set(sliderObj.Value)
			end

			function sliderObj:SetMin(m)
				min = m
				sliderObj:Set(sliderObj.Value)
			end

			local dragging = false
			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local xPct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					sliderObj:Set(min + (max - min) * xPct)
				end
			end)

			vgs.UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			vgs.UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local xPct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					sliderObj:Set(min + (max - min) * xPct)
				end
			end)

			sliderObj:Set(def)
			if flag then syde.Flags[flag] = sliderObj end

			sliderObj.toggle = function(self) f.Visible = not f.Visible end
			sliderObj.remove = function(self) f:Destroy() end

			return sliderObj
		end

		-- AddDropdown
		function TabElements:AddDropdown(DropdownConfig)
			DropdownConfig = DropdownConfig or {}
			local name = DropdownConfig.Name or DropdownConfig.Title or "Dropdown"
			local options = DropdownConfig.Options or {}
			local isMulti = DropdownConfig.Multi or false
			local def = DropdownConfig.Default or (isMulti and {} or (options[1] or ""))
			local callback = DropdownConfig.Callback or DropdownConfig.CallBack or function() end
			local flag = DropdownConfig.Flag

			local f = MakeBaseFrame(name, 36)
			f.ClipsDescendants = true

			local header = Instance.new("Frame")
			header.Size = UDim2.new(1, 0, 0, 36)
			header.BackgroundTransparency = 1
			header.Parent = f

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.Parent = header

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Size = UDim2.new(0.5, -12, 1, 0)
			titleLbl.Position = UDim2.new(0, 12, 0, 0)
			titleLbl.BackgroundTransparency = 1
			titleLbl.Font = Enum.Font.GothamBold
			titleLbl.TextSize = 14
			titleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.Text = name
			titleLbl.Parent = header
			AddTheme(titleLbl, "Text")

			local selLbl = Instance.new("TextLabel")
			selLbl.Size = UDim2.new(0.5, -34, 1, 0)
			selLbl.Position = UDim2.new(0.5, 0, 0, 0)
			selLbl.BackgroundTransparency = 1
			selLbl.Font = Enum.Font.Gotham
			selLbl.TextSize = 12
			selLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
			selLbl.TextXAlignment = Enum.TextXAlignment.Right
			selLbl.TextTruncate = Enum.TextTruncate.AtEnd
			selLbl.Text = tostring(type(def) == "table" and table.concat(def, ", ") or def)
			selLbl.Parent = header
			AddTheme(selLbl, "TextDark")

			local arrow = Instance.new("ImageLabel")
			arrow.Size = UDim2.new(0, 16, 0, 16)
			arrow.Position = UDim2.new(1, -26, 0.5, -8)
			arrow.BackgroundTransparency = 1
			arrow.Image = "rbxassetid://7072706796"
			arrow.Rotation = 180
			arrow.Parent = header
			AddTheme(arrow, "TextDark")

			local optScroll = Instance.new("ScrollingFrame")
			optScroll.Size = UDim2.new(1, 0, 1, -36)
			optScroll.Position = UDim2.new(0, 0, 0, 36)
			optScroll.BackgroundTransparency = 1
			optScroll.BorderSizePixel = 0
			optScroll.ScrollBarThickness = 2
			optScroll.Visible = false
			optScroll.Parent = f

			local optList = Instance.new("UIListLayout")
			optList.SortOrder = Enum.SortOrder.LayoutOrder
			optList.Padding = UDim.new(0, 2)
			optList.Parent = optScroll

			local optPad = Instance.new("UIPadding")
			optPad.PaddingTop = UDim.new(0, 4)
			optPad.PaddingBottom = UDim.new(0, 4)
			optPad.PaddingLeft = UDim.new(0, 8)
			optPad.PaddingRight = UDim.new(0, 8)
			optPad.Parent = optScroll

			local dropdownObj = {
				Value = def,
				Options = options,
				Buttons = {},
				Toggled = false,
				Frame = f,
				Flag = flag
			}

			function dropdownObj:Refresh(newOpts, delOld)
				if delOld then
					for _, b in pairs(dropdownObj.Buttons) do b:Destroy() end
					dropdownObj.Buttons = {}
				end
				dropdownObj.Options = newOpts or {}

				for _, opt in ipairs(dropdownObj.Options) do
					local optTxt = type(opt) == "table" and (opt.name or opt.text or tostring(opt.value)) or tostring(opt)
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 26)
					optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					optBtn.Font = Enum.Font.Gotham
					optBtn.TextSize = 12
					optBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
					optBtn.Text = "  " .. optTxt
					optBtn.TextXAlignment = Enum.TextXAlignment.Left
					optBtn.Parent = optScroll

					local crn = Instance.new("UICorner")
					crn.CornerRadius = UDim.new(0, 4)
					crn.Parent = optBtn

					optBtn.MouseButton1Click:Connect(function()
						if isMulti then
							if type(dropdownObj.Value) ~= "table" then dropdownObj.Value = {} end
							local idx = table.find(dropdownObj.Value, optTxt)
							if idx then table.remove(dropdownObj.Value, idx)
							else table.insert(dropdownObj.Value, optTxt) end
							selLbl.Text = table.concat(dropdownObj.Value, ", ")
							pcall(callback, dropdownObj.Value)
						else
							dropdownObj.Value = optTxt
							selLbl.Text = optTxt
							dropdownObj.Toggled = false
							optScroll.Visible = false
							arrow.Rotation = 180
							tweenservice:Create(f, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 36)}):Play()
							pcall(callback, optTxt)
						end
					end)
					dropdownObj.Buttons[optTxt] = optBtn
				end
				optScroll.CanvasSize = UDim2.new(0, 0, 0, #dropdownObj.Options * 28 + 8)
			end

			btn.MouseButton1Click:Connect(function()
				dropdownObj.Toggled = not dropdownObj.Toggled
				optScroll.Visible = dropdownObj.Toggled
				arrow.Rotation = dropdownObj.Toggled and 0 or 180
				local h = dropdownObj.Toggled and math.clamp(36 + #dropdownObj.Options * 28 + 8, 36, 180) or 36
				tweenservice:Create(f, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, h)}):Play()
			end)

			dropdownObj:Refresh(options, false)

			function dropdownObj:Set(val, addMode)
				if isMulti then
					if type(dropdownObj.Value) ~= "table" then dropdownObj.Value = {} end
					if addMode ~= nil then
						local values = type(val) == "table" and val or {val}
						for _, v in ipairs(values) do
							local strV = tostring(v)
							local idx = table.find(dropdownObj.Value, strV)
							if addMode and not idx then
								table.insert(dropdownObj.Value, strV)
							elseif not addMode and idx then
								table.remove(dropdownObj.Value, idx)
							end
						end
					else
						if type(val) == "table" then
							dropdownObj.Value = val
						else
							dropdownObj.Value = {tostring(val)}
						end
					end
					selLbl.Text = table.concat(dropdownObj.Value, ", ")
					pcall(callback, dropdownObj.Value)
				else
					dropdownObj.Value = val
					selLbl.Text = tostring(val)
					pcall(callback, val)
				end
			end

			function dropdownObj:Get() return dropdownObj.Value end
			function dropdownObj:Has(val)
				if isMulti and type(dropdownObj.Value) == "table" then
					return table.find(dropdownObj.Value, val) ~= nil
				end
				return dropdownObj.Value == val
			end

			table.insert(syde.Dropdowns, dropdownObj)
			if flag then syde.Flags[flag] = dropdownObj end

			dropdownObj.toggle = function(self) f.Visible = not f.Visible end
			dropdownObj.remove = function(self) f:Destroy() end

			return dropdownObj
		end

		-- FreeMouseDrp
		function TabElements:FreeMouseDrp()
			return TabElements:AddDropdown({
				Name = "Unlock Mouse Mode",
				Options = {"ThirdPerson", "FreeMouse"},
				Default = syde.UMouseMode or "FreeMouse",
				Callback = function(val)
					syde.UMouseMode = val
					syde:UnlockMouse(false)
					task.wait(0.05)
					syde:UnlockMouse(true)
				end
			})
		end

		-- AddBind
		function TabElements:AddBind(BindConfig)
			BindConfig = BindConfig or {}
			local name = BindConfig.Name or BindConfig.Title or "Keybind"
			local defKey = BindConfig.Default or Enum.KeyCode.Unknown
			local callback = BindConfig.Callback or BindConfig.CallBack or function() end
			local flag = BindConfig.Flag

			local f = MakeBaseFrame(name, 36)

			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -90, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = name
			lbl.Parent = f
			AddTheme(lbl, "Text")

			local bindBtn = Instance.new("TextButton")
			bindBtn.Size = UDim2.new(0, 70, 0, 24)
			bindBtn.Position = UDim2.new(1, -80, 0.5, -12)
			bindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			bindBtn.Font = Enum.Font.GothamBold
			bindBtn.TextSize = 12
			bindBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
			local keyName = (typeof(defKey) == "EnumItem" and defKey.Name) or tostring(defKey)
			bindBtn.Text = keyName
			bindBtn.Parent = f

			local bCrn = Instance.new("UICorner")
			bCrn.CornerRadius = UDim.new(0, 4)
			bCrn.Parent = bindBtn

			local bindObj = {
				Value = keyName,
				Binding = false,
				Frame = f,
				Flag = flag
			}

			function bindObj:Set(newK)
				local n = (typeof(newK) == "EnumItem" and newK.Name) or tostring(newK)
				bindObj.Value = n
				bindBtn.Text = n
			end

			bindBtn.MouseButton1Click:Connect(function()
				bindObj.Binding = true
				bindBtn.Text = "..."
			end)

			vgs.UIS.InputBegan:Connect(function(input, gpe)
				if bindObj.Binding and not gpe then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						bindObj.Binding = false
						bindObj:Set(input.KeyCode.Name)
					end
				elseif not bindObj.Binding and not gpe then
					if input.KeyCode.Name == bindObj.Value then
						pcall(callback, input.KeyCode)
					end
				end
			end)

			if flag then syde.Flags[flag] = bindObj end

			bindObj.toggle = function(self) f.Visible = not f.Visible end
			bindObj.remove = function(self) f:Destroy() end

			return bindObj
		end

		-- AddTextbox
		function TabElements:AddTextbox(TextboxConfig)
			TextboxConfig = TextboxConfig or {}
			local name = TextboxConfig.Name or TextboxConfig.Title or "Textbox"
			local defText = TextboxConfig.Default or ""
			local ph = TextboxConfig.BackGroundtext or TextboxConfig.PlaceholderText or "Input"
			local callback = TextboxConfig.Callback or TextboxConfig.CallBack or function() end

			local f = MakeBaseFrame(name, 36)

			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -130, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = name
			lbl.Parent = f
			AddTheme(lbl, "Text")

			local tb = Instance.new("TextBox")
			tb.Size = UDim2.new(0, 110, 0, 24)
			tb.Position = UDim2.new(1, -120, 0.5, -12)
			tb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			tb.Font = Enum.Font.Gotham
			tb.TextSize = 12
			tb.TextColor3 = Color3.fromRGB(240, 240, 240)
			tb.PlaceholderText = ph
			tb.Text = defText
			tb.ClearTextOnFocus = false
			tb.Parent = f

			local tbCrn = Instance.new("UICorner")
			tbCrn.CornerRadius = UDim.new(0, 4)
			tbCrn.Parent = tb

			tb.FocusLost:Connect(function()
				pcall(callback, tb.Text)
			end)

			return {
				Frame = f,
				Set = function(self, t) tb.Text = tostring(t or "") end,
				toggle = function(self) f.Visible = not f.Visible end,
				remove = function(self) f:Destroy() end
			}
		end

		-- AddColorpicker
		function TabElements:AddColorpicker(ColorpickerConfig)
			ColorpickerConfig = ColorpickerConfig or {}
			local name = ColorpickerConfig.Name or ColorpickerConfig.Title or "Colorpicker"
			local defCol = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
			local callback = ColorpickerConfig.Callback or ColorpickerConfig.CallBack or function() end
			local flag = ColorpickerConfig.Flag

			local f = MakeBaseFrame(name, 36)

			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -50, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = name
			lbl.Parent = f
			AddTheme(lbl, "Text")

			local colBox = Instance.new("TextButton")
			colBox.Size = UDim2.new(0, 26, 0, 22)
			colBox.Position = UDim2.new(1, -36, 0.5, -11)
			colBox.BackgroundColor3 = defCol
			colBox.Text = ""
			colBox.Parent = f

			local cCrn = Instance.new("UICorner")
			cCrn.CornerRadius = UDim.new(0, 4)
			cCrn.Parent = colBox

			local colObj = {
				Value = defCol,
				Frame = f,
				Flag = flag
			}

			function colObj:Set(newC)
				colObj.Value = newC
				colBox.BackgroundColor3 = newC
				pcall(callback, newC)
			end

			colBox.MouseButton1Click:Connect(function()
				-- Cycles a few vibrant test colors if clicked simply
				local nextC = Color3.fromHSV(math.random(), 0.8, 0.95)
				colObj:Set(nextC)
			end)

			if flag then syde.Flags[flag] = colObj end

			colObj.toggle = function(self) f.Visible = not f.Visible end
			colObj.remove = function(self) f:Destroy() end

			return colObj
		end

		-- AddPbind
		function TabElements:AddPbind(Config)
			Config = Config or {}
			local name = Config.Name or Config.Title or "Position"
			local defX = tostring(Config.DefaultX or "")
			local defY = tostring(Config.DefaultY or "")
			local defZ = tostring(Config.DefaultZ or "")
			local callback = Config.Callback or Config.CallBack or function() end

			local f = MakeBaseFrame(name, 38)

			local lbl = Instance.new("TextLabel")
			lbl.Name = "Content"
			lbl.Size = UDim2.new(1, -190, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = name
			lbl.Parent = f
			AddTheme(lbl, "Text")

			local pData = { ValueX = defX, ValueY = defY, ValueZ = defZ, Frame = f }

			local function makeBox(xPos, defVal)
				local b = Instance.new("TextBox")
				b.Size = UDim2.new(0, 50, 0, 24)
				b.Position = UDim2.new(1, xPos, 0.5, -12)
				b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				b.Font = Enum.Font.GothamBold
				b.TextSize = 12
				b.TextColor3 = Color3.fromRGB(255, 255, 255)
				b.Text = defVal
				b.Parent = f
				local c = Instance.new("UICorner")
				c.CornerRadius = UDim.new(0, 4)
				c.Parent = b
				return b
			end

			local bx = makeBox(-165, defX)
			local by = makeBox(-110, defY)
			local bz = makeBox(-55, defZ)

			local function trig()
				pData.ValueX = bx.Text
				pData.ValueY = by.Text
				pData.ValueZ = bz.Text
				pcall(callback, pData.ValueX, pData.ValueY, pData.ValueZ)
			end

			bx.FocusLost:Connect(trig)
			by.FocusLost:Connect(trig)
			bz.FocusLost:Connect(trig)

			function pData:Set(x, y, z)
				if x ~= nil then pData.ValueX = tostring(x) bx.Text = pData.ValueX end
				if y ~= nil then pData.ValueY = tostring(y) by.Text = pData.ValueY end
				if z ~= nil then pData.ValueZ = tostring(z) bz.Text = pData.ValueZ end
			end

			pData.toggle = function(self) f.Visible = not f.Visible end
			pData.remove = function(self) f:Destroy() end

			return pData
		end

		-- AddUiBind
		function TabElements:AddUiBind()
			return TabElements:AddBind({
				Name = "UI Toggle Bind",
				Default = Enum.KeyCode[OpenKey] or Enum.KeyCode.RightShift,
				Callback = function() end
			})
		end

		-- AddSmartTheme
		function TabElements:AddSmartTheme()
			local cp = TabElements:AddColorpicker({
				Name = "Theme Accent",
				Default = (syde.Themes[syde.SelectedTheme] and syde.Themes[syde.SelectedTheme].Accent) or Color3.fromRGB(57, 37, 68),
				Callback = function(col)
					local newTheme = syde:GenTheme(col)
					syde.Themes.Custom = newTheme
					syde.SelectedTheme = "Custom"
					syde:SetTheme()
				end
			})
			local btn = TabElements:AddButton({
				Name = "Reset Theme",
				Callback = function()
					syde.SelectedTheme = "Default"
					syde:SetTheme()
				end
			})
			return { ColorPicker = cp, ResetButton = btn }
		end

		-- AddSection
		function TabElements:AddSection(secName, align, height)
			if type(secName) == "table" then
				local tbl = secName
				secName = tbl.Name or tbl.Title or tbl.Text or ""
				align = tbl.Align or tbl.Alignment or align
				height = tbl.Height or height
			end
			secName = tostring(secName or "")
			local secFrame = Instance.new("Frame")
			secFrame.Name = "Section_" .. secName
			secFrame.Size = UDim2.new(1, 0, 0, height or 28)
			secFrame.BackgroundTransparency = 1
			secFrame.Parent = PageContainer

			local secLabel = Instance.new("TextLabel")
			secLabel.Size = UDim2.new(1, 0, 1, 0)
			secLabel.BackgroundTransparency = 1
			secLabel.Font = Enum.Font.GothamBold
			secLabel.TextSize = 13
			secLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
			secLabel.TextXAlignment = (align == "Center" and Enum.TextXAlignment.Center) or (align == "Right" and Enum.TextXAlignment.Right) or Enum.TextXAlignment.Left
			secLabel.Text = secName
			secLabel.Parent = secFrame
			AddTheme(secLabel, "TextDark")

			local secObj = {}
			for k, v in pairs(TabElements) do
				secObj[k] = v
			end
			secObj.Frame = secFrame
			secObj.toggle = function(self) secFrame.Visible = not secFrame.Visible end
			secObj.remove = function(self) secFrame:Destroy() end
			return secObj
		end

		-- Aliases on TabElements so both Syde and Orion calls work
		TabElements.Button = TabElements.AddButton
		TabElements.Toggle = TabElements.AddToggle
		TabElements.Slider = TabElements.AddSlider
		TabElements.Dropdown = TabElements.AddDropdown
		TabElements.Keybind = TabElements.AddBind
		TabElements.TextInput = TabElements.AddTextbox
		TabElements.ColorPicker = TabElements.AddColorpicker
		TabElements.Paragraph = TabElements.AddParagraph
		TabElements.Label = TabElements.AddLabel
		TabElements.Section = TabElements.AddSection
		TabElements.Log = TabElements.AddLog
		TabElements.Pbind = TabElements.AddPbind
		TabElements.PlayerParagraph = TabElements.AddPlayerParagraph
		TabElements.UiBind = TabElements.AddUiBind
		TabElements.SmartTheme = TabElements.AddSmartTheme

		return TabElements
	end

	WindowFunctions.InitTab = WindowFunctions.MakeTab
	WindowFunctions.Init = function(self) return syde:Init() end
	syde.ActiveWindow = WindowFunctions

	return WindowFunctions
end

-- Top-level alias
syde.InitTab = syde.MakeWindow
syde.MakeTab = syde.MakeWindow


pcall(function()
	if getgenv then
		getgenv().OrionLib = syde
	end
	_G.OrionLib = syde
end)

return syde
