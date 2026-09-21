-- Made: By iceboy

local runService = game:GetService("RunService")
local playersService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = playersService.LocalPlayer
local struggleRemote = replicatedStorage.CharacterEvents.Struggle

local FIRE_COOLDOWN = 0.15
local lastFired = 0

runService.Heartbeat:Connect(function()
	local character = localPlayer.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not (head and hrp) then return end

	if head:FindFirstChild("PartOwner") or hrp.ReceiveAge ~= 0 then
		local now = os.clock()
		if now - lastFired >= FIRE_COOLDOWN then
			lastFired = now
			struggleRemote:FireServer()
		end
	end
end)