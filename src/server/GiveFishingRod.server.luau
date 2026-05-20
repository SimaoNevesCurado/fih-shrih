-- GiveFishingRod.server.luau
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        local rod = ServerStorage:FindFirstChild("FishingRod"):Clone()
        rod.Parent = player:FindFirstChild("Backpack")
    end)
end)
