-- FishingManager.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishingData = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FishingData"))

local RemoteFolder = ReplicatedStorage:WaitForChild("FishingRemotes")
local Remotes = {
    CastEvent = RemoteFolder:WaitForChild("CastEvent"),
    HookEvent = RemoteFolder:WaitForChild("HookEvent"),
    DragUpdateEvent = RemoteFolder:WaitForChild("DragUpdateEvent"),
    TensionUpdate = RemoteFolder:WaitForChild("TensionUpdate")
}

local PlayerStates = {}

local function initPlayer(player)
    PlayerStates[player.UserId] = {
        State = "Idle",
        Drag = 0.5,
        Tension = 0,
        Progress = 0,
        IsRetrieving = false,
        CurrentFish = nil
    }
end

for _, player in ipairs(Players:GetPlayers()) do initPlayer(player) end
Players.PlayerAdded:Connect(initPlayer)
Players.PlayerRemoving:Connect(function(player) PlayerStates[player.UserId] = nil end)

-- Loop de Tensão e Progresso
task.spawn(function()
    while true do
        for userId, state in pairs(PlayerStates) do
            if state and state.State == "Fighting" then
                local dragReduction = state.Drag * 10
                local fishPull = state.CurrentFish.FightForce * 0.05
                local retrieveTension = state.IsRetrieving and 1.5 or 0
                local progressGain = state.IsRetrieving and 0.5 or 0
                
                local delta = (fishPull + retrieveTension) - (dragReduction * 0.1)
                state.Tension = math.clamp(state.Tension + delta, 0, 100)
                state.Progress = math.clamp((state.Progress or 0) + progressGain, 0, 100)
                
                local player = Players:GetPlayerByUserId(userId)
                if player then
                    Remotes.TensionUpdate:FireClient(player, {
                        Tension = state.Tension,
                        Progress = state.Progress,
                        IsRetrieving = state.IsRetrieving
                    })
                end
                
                if state.Tension >= 100 then
                    state.State = "Idle"
                    state.Tension = 0
                    state.Progress = 0
                elseif state.Progress >= 100 then
                    state.State = "Idle"
                    state.Tension = 0
                    state.Progress = 0
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Eventos de Input Centralizados
Remotes.DragUpdateEvent.OnServerEvent:Connect(function(player, action, value)
    local state = PlayerStates[player.UserId]
    if not state then return end
    
    if action == "Drag" then
        state.Drag = math.clamp(state.Drag + value, 0, 1)
    elseif action == "Retrieve" then
        state.IsRetrieving = value
    end
end)

Remotes.CastEvent.OnServerEvent:Connect(function(player, targetPosition)
    local state = PlayerStates[player.UserId]
    if not state or state.State ~= "Idle" then return end
    state.State = "Waiting"
    task.delay(math.random(3, 7), function()
        if state and state.State == "Waiting" then
            state.State = "Alert"
            Remotes.TensionUpdate:FireClient(player, {Type = "Alert"})
        end
    end)
end)

Remotes.HookEvent.OnServerEvent:Connect(function(player)
    local state = PlayerStates[player.UserId]
    if state and state.State == "Alert" then
        state.State = "Fighting"
        state.CurrentFish = FishingData.GetRandomFish()
        state.Tension = 10
        state.Progress = 0
    end
end)
