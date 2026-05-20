-- FishingMath.lua
-- Módulo matemático de física para a briga com o peixe
local FishingMath = {}

function FishingMath.InitializeFight(playerState, fish, castDistance)
    playerState.Distance = castDistance
    playerState.MaxDistance = 150 -- Distância limite para fuga
    playerState.Tension = 10
    playerState.Progress = 0
    playerState.FishState = "Tired" 
    playerState.LastStateChange = os.clock()
end

function FishingMath.UpdateFight(state, dt)
    local fish = state.CurrentFish
    if not fish then return "Idle" end
    
    -- 1. Alternância de estados do peixe (Fúria vs Cansaço)
    if os.clock() - state.LastStateChange > math.random(3, 6) then
        state.FishState = (state.FishState == "Tired") and "Fury" or "Tired"
        state.LastStateChange = os.clock()
    end

    local isFury = (state.FishState == "Fury")
    local dragFactor = state.Drag -- 0 a 1
    local fishBaseForce = isFury and fish.FightForce or (fish.FightForce * 0.2)
    local retrieveForce = 15

    -- 2. Cálculo da Tensão (Tension)
    -- O Drag faz a força do peixe ser transferida para a Tensão da linha
    local tensionFromFish = (fishBaseForce * dragFactor)
    local tensionFromRetrieve = state.IsRetrieving and 10 or 0
    -- O Drag alto ajuda a segurar, mas se ele estiver muito alto durante a fúria, a tensão dispara
    local tensionChange = (tensionFromFish + tensionFromRetrieve - (state.Drag * 5)) * dt
    state.Tension = math.clamp(state.Tension + tensionChange, 0, 100)

    -- 3. Cálculo da Distância (Distance)
    -- Peixe ganha distância quando o Drag está baixo e ele está em fúria
    local distanceGain = (fishBaseForce * (1 - dragFactor)) * (isFury and 1.5 or 0.5) * dt
    -- Jogador perde distância do peixe apenas quando não está em fúria
    local distanceLoss = (state.IsRetrieving and not isFury) and retrieveForce * dt or 0
    
    state.Distance = math.clamp(state.Distance + distanceGain - distanceLoss, 0, state.MaxDistance)
    
    -- Atualiza progresso baseado na distância percorrida (0 a 100)
    state.Progress = math.clamp(((state.MaxDistance - state.Distance) / state.MaxDistance) * 100, 0, 100)

    -- 4. Verificação de status
    if state.Tension >= 100 then return "Snapped" end
    if state.Distance >= state.MaxDistance then return "Escaped" end
    if state.Distance <= 0 then return "Caught" end

    return "Fighting"
end

return FishingMath
