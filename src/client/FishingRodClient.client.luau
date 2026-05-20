-- FishingRodClient.client.luau (Deve ser colocado como LocalScript dentro da Tool)
local Tool = script.Parent
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Remotes = game.ReplicatedStorage:WaitForChild("FishingRemotes")

-- IDs de animação (Substitua pelos seus IDs de animação no Roblox)
local CAST_ANIM_ID = "rbxassetid://0" 
local REEL_ANIM_ID = "rbxassetid://0"

local animCast = Humanoid:LoadAnimation(Instance.new("Animation", script))
animCast.Animation.AnimationId = CAST_ANIM_ID

local animReel = Humanoid:LoadAnimation(Instance.new("Animation", script))
animReel.Animation.AnimationId = REEL_ANIM_ID

Tool.Activated:Connect(function()
    print("DEBUG: Tool ativada - Cast")
    animCast:Play()
    local mouse = Player:GetMouse()
    Remotes.CastEvent:FireServer(mouse.Hit.Position)
    Remotes.HookEvent:FireServer()
end)

-- Detectar Mouse2 (Recolher)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Tool.Parent == Character then
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
