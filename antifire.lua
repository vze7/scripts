
local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
local a = game.Players.LocalPlayer.Character.Humanoid.FireDebounce
local b = workspace.Map.Hole.PoisonSmallHole.ExtinguishPart

game.RunService.Heartbeat:Connect(function()
    if a.Value == true then
        firetouchinterest(hrp.FirePlayerPart, b, 0)
        firetouchinterest(hrp.FirePlayerPart, b, 1)
    end
end)