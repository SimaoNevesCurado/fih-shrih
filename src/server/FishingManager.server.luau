-- FishingManager.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishingData = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FishingData"))
local FishingMath = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FishingMath"))

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
        Distance = 0,
        IsRetrieving = false,
        CurrentFish = nil
    }
end

for _, player in ipairs(Players:GetPlayers()) do initPlayer(player) end
Players.PlayerAdded:Connect(initPlayer)
Players.PlayerRemoving:Connect(function(player) PlayerStates[player.UserId] = nil end)

-- Loop de Briga (Heartbeat Server Simulation)
task.spawn(function()
    while true do
        for userId, state in pairs(PlayerStates) do
            if state and state.State == "Fighting" then
                local result = FishingMath.UpdateFight(state, 0.1)
                
                local player = Players:GetPlayerByUserId(userId)
                if player then
                    Remotes.TensionUpdate:FireClient(player, {
                        Tension = state.Tension,
                        Progress = state.Progress,
                        IsRetrieving = state.IsRetrieving,
                        Distance = state.Distance,
                        Drag = state.Drag * 100
                    })
                end
                
                if result ~= "Fighting" then
                    print("DEBUG SERVER: Resultado da briga: " .. result)
                    state.State = "Idle"
                    state.Tension = 0
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Eventos de Input
Remotes.DragUpdateEvent.OnServerEvent:Connect(function(player, action, value)
    local state = PlayerStates[player.UserId]
    if not state then return end
    
    if action == "Drag" and type(value) == "number" then
        state.Drag = math.clamp(state.Drag + value, 0, 1)
    elseif action == "Retrieve" then
        state.IsRetrieving = (value == true)
    end
end)

Remotes.CastEvent.OnServerEvent:Connect(function(player, targetPosition)
    local state = PlayerStates[player.UserId]
    if not state or state.State ~= "Idle" then return end
    state.State = "Waiting"
    state.CastPosition = targetPosition
end)

Remotes.HookEvent.OnServerEvent:Connect(function(player)
    local state = PlayerStates[player.UserId]
    if state and state.State == "Waiting" then -- Simplificado para o protótipo
        state.State = "Fighting"
        state.CurrentFish = FishingData.GetRandomFish()
        FishingMath.InitializeFight(state, state.CurrentFish, 50)
    end
end)
