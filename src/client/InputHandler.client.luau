-- InputHandler.client.luau
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("FishingRemotes")

local function createVisualBobber(position)
    local bobber = Instance.new("Part")
    bobber.Shape = Enum.PartType.Ball
    bobber.Size = Vector3.new(0.5, 0.5, 0.5)
    bobber.Position = position
    bobber.Anchored = true
    bobber.CanCollide = false
    bobber.Color = Color3.fromRGB(255, 255, 0)
    bobber.Parent = workspace
    task.delay(5, function() bobber:Destroy() end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = game.Players.LocalPlayer:GetMouse()
        Remotes.CastEvent:FireServer(mouse.Hit.Position)
        Remotes.HookEvent:FireServer()
    
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        Remotes.DragUpdateEvent:FireServer("Retrieve", true)
        
    elseif input.KeyCode == Enum.KeyCode.Q then
        Remotes.DragUpdateEvent:FireServer("Drag", -0.1)
    elseif input.KeyCode == Enum.KeyCode.E then
        Remotes.DragUpdateEvent:FireServer("Drag", 0.1)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Remotes.DragUpdateEvent:FireServer("Retrieve", false)
    end
end)
