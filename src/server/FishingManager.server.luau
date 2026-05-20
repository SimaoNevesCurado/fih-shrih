-- FishingManager.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishingData = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FishingData"))

-- Aguarda a pasta de Remotes ser criada pelo Initializer
local RemoteFolder = ReplicatedStorage:WaitForChild("FishingRemotes")

local Remotes = {
    CastEvent = RemoteFolder:WaitForChild("CastEvent"),
    HookEvent = RemoteFolder:WaitForChild("HookEvent"),
    DragUpdateEvent = RemoteFolder:WaitForChild("DragUpdateEvent"),
    TensionUpdate = RemoteFolder:WaitForChild("TensionUpdate")
}

local PlayerStates = {}

-- Inicializa estados
local function initPlayer(player)
    PlayerStates[player.UserId] = {
        State = "Idle",
        Drag = 0.5,
        Tension = 0,
        CurrentFish = nil
    }
end

for _, player in ipairs(Players:GetPlayers()) do
    initPlayer(player)
end
Players.PlayerAdded:Connect(initPlayer)
Players.PlayerRemoving:Connect(function(player)
    PlayerStates[player.UserId] = nil
end)

-- Loop de Tensão e Progresso
task.spawn(function()
    while true do
        for userId, state in pairs(PlayerStates) do
            if state and state.State == "Fighting" then
                -- O Drag reduz a tensão base do peixe
                local dragReduction = state.Drag * 10
                local fishPull = state.CurrentFish.FightForce * 0.05
                
                -- Se estiver a enrolar (retrieve), aumenta a tensão mas avança o progresso
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
                    print("DEBUG SERVER: Peixe capturado!")
                    state.State = "Idle"
                    state.Tension = 0
                    state.Progress = 0
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
    
    if action == "Drag" then
        state.Drag = math.clamp(state.Drag + value, 0, 1)
    elseif action == "Retrieve" then
        state.IsRetrieving = value
    end
end)


-- Conexão de Retrieve (Mouse 2)
UserInputService = game:GetService("UserInputService") -- Nota: Isso deve ser capturado via Remote no cliente
Remotes.DragUpdateEvent.OnServerEvent:Connect(function(player, change)
    local state = PlayerStates[player.UserId]
    if state then
        -- Se change for um número, é ajuste de Drag. Se for string "Retrieve", é ação.
        if type(change) == "number" then
            state.Drag = math.clamp(state.Drag + change, 0, 1)
            print("DEBUG SERVER: Drag atualizado para", state.Drag)
        end
    end
end)


-- Conexões de Eventos
Remotes.CastEvent.OnServerEvent:Connect(function(player, targetPosition)
    print("DEBUG SERVER: Cast recebido de", player.Name, " - Posição:", targetPosition)
    local state = PlayerStates[player.UserId]
    if not state then 
        print("DEBUG SERVER: Erro - Jogador não registrado no PlayerStates")
        return 
    end
    
    if state.State ~= "Idle" then 
        print("DEBUG SERVER: Erro - Jogador não está Idle. Estado atual:", state.State)
        return 
    end
    
    state.State = "Waiting"
    print("DEBUG SERVER: Sucesso - Jogador", player.Name, "entrou em modo Waiting")
    
    task.delay(math.random(3, 7), function()
        if state and state.State == "Waiting" then
            state.State = "Alert"
            print("DEBUG SERVER: Evento de Alert disparado para", player.Name)
            Remotes.TensionUpdate:FireClient(player, {Type = "Alert"})
        end
    end)
end)

Remotes.HookEvent.OnServerEvent:Connect(function(player)
    print("DEBUG SERVER: Hook recebido de", player.Name)
    local state = PlayerStates[player.UserId]
    if state and state.State == "Alert" then
        state.State = "Fighting"
        state.CurrentFish = FishingData.GetRandomFish()
        state.Tension = 10
        print("DEBUG SERVER: Peixe fisgado! Iniciando briga.")
    else
        print("DEBUG SERVER: Hook inválido. Estado atual:", state and state.State or "nil")
    end
end)

Remotes.DragUpdateEvent.OnServerEvent:Connect(function(player, change)
    local state = PlayerStates[player.UserId]
    if state then
        state.Drag = math.clamp(state.Drag + change, 0, 1)
    end
end)
