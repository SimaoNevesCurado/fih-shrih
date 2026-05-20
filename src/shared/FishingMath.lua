-- FishingMath.lua
local FishingMath = {}

function FishingMath.InitializeFight(playerState, fish, castDistance)
    playerState.Distance = castDistance
    playerState.MaxDistance = 150
    playerState.Tension = 10
    playerState.Progress = 0
    playerState.FishState = "Tired" 
    playerState.LastStateChange = os.clock()
end

function FishingMath.UpdateFight(state, dt)
    local fish = state.CurrentFish
    if not fish then return "Idle" end
    
    -- 1. Gerenciamento de Estado
    if os.clock() - state.LastStateChange > math.random(3, 6) then
        state.FishState = (state.FishState == "Tired") and "Fury" or "Tired"
        state.LastStateChange = os.clock()
    end

    local isFury = (state.FishState == "Fury")
    local drag = state.Drag -- 0.0 a 1.0
    local baseForce = isFury and fish.FightForce or (fish.FightForce * 0.2)
    
    -- 2. TENSÃO (Tension)
    -- O Drag alto trava a linha, logo qualquer força do peixe vira Tensão.
    -- O Drag baixo libera a linha, reduzindo drasticamente a Tensão gerada.
    -- Adicionamos um multiplicador base para controlar a agressividade geral.
    local tensionGeneration = baseForce * drag
    
    -- Se o jogador estiver a recolher (Retrieve):
    -- Recolher gera tensão adicional, mas é a única forma de ganhar progresso.
    local retrieveTension = state.IsRetrieving and (baseForce * 0.5) or 0
    
    -- Tensão final: (Tensão do Peixe + Tensão do Recolhimento) - Alívio do Drag
    -- O Drag atua como alívio: se o drag for 0, a tensão cai para 0 rapidamente.
    local delta = (tensionGeneration + retrieveTension - (1.0 - drag) * 20) * dt
    
    state.Tension = math.clamp(state.Tension + delta, 0, 100)

    -- 3. DISTÂNCIA e PROGRESSO (Distance)
    -- Se o Drag estiver baixo, o peixe ganha distância.
    -- Se o Drag estiver alto, o peixe não consegue correr (resistência).
    -- Recolher (Retrieve) só funciona se a Tensão não estiver crítica.
    local runSpeed = baseForce * (1.1 - drag) * (isFury and 1.5 or 0.5)
    local pullSpeed = (state.IsRetrieving and state.Tension < 80) and (fish.FightForce * 0.8) or 0
    
    state.Distance = math.clamp(state.Distance + (runSpeed - pullSpeed) * dt, 0, state.MaxDistance)
    
    -- Progresso: 100% quando Distance é 0.
    state.Progress = math.clamp(((state.MaxDistance - state.Distance) / state.MaxDistance) * 100, 0, 100)

    -- 4. Verificação
    if state.Tension >= 100 then return "Snapped" end
    if state.Distance >= state.MaxDistance then return "Escaped" end
    if state.Distance <= 0 then return "Caught" end

    return "Fighting"
end

return FishingMath
