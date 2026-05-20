-- FishingRodInitializer.server.luau
local ServerStorage = game:GetService("ServerStorage")
local Tool = Instance.new("Tool")
Tool.Name = "FishingRod"
Tool.RequiresHandle = true

local Handle = Instance.new("Part", Tool)
Handle.Name = "Handle"
Handle.Size = Vector3.new(0.5, 4, 0.5)
Handle.Color = Color3.fromRGB(139, 69, 19)

-- Cria o LocalScript dentro da Tool
local clientScript = Instance.new("LocalScript", Tool)
clientScript.Name = "FishingRodClient"
clientScript.Source = [[
local Tool = script.Parent
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Remotes = game.ReplicatedStorage:WaitForChild("FishingRemotes")

-- IDs de animação (Substitua pelos seus IDs)
local CAST_ANIM_ID = "rbxassetid://0" 
local REEL_ANIM_ID = "rbxassetid://0"

local animCast = Humanoid:LoadAnimation(Instance.new("Animation", script))
animCast.Animation.AnimationId = CAST_ANIM_ID
local animReel = Humanoid:LoadAnimation(Instance.new("Animation", script))
animReel.Animation.AnimationId = REEL_ANIM_ID

Tool.Activated:Connect(function()
    animCast:Play()
    local mouse = Player:GetMouse()
    Remotes.CastEvent:FireServer(mouse.Hit.Position)
    Remotes.HookEvent:FireServer()
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or Tool.Parent ~= Character then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        animReel:Play()
        Remotes.DragUpdateEvent:FireServer("Retrieve", true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        animReel:Stop()
        Remotes.DragUpdateEvent:FireServer("Retrieve", false)
    end
end)
]]

Tool.Parent = ServerStorage
print("FishingRod criada na ServerStorage com script client inserido.")
