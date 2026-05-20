-- UIHandler.client.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "FishingUI"

-- Tensão
local tensionBar = Instance.new("Frame", screenGui)
tensionBar.Size = UDim2.new(0.2, 0, 0.03, 0)
tensionBar.Position = UDim2.new(0.4, 0, 0.9, 0)
tensionBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
local barFill = Instance.new("Frame", tensionBar)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

-- Info
local infoLabel = Instance.new("TextLabel", screenGui)
infoLabel.Size = UDim2.new(0.2, 0, 0.1, 0)
infoLabel.Position = UDim2.new(0.4, 0, 0.8, 0)
infoLabel.Text = "Drag: 50% | Tempo: 0s"
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.BackgroundTransparency = 1

local Remotes = ReplicatedStorage:WaitForChild("FishingRemotes")

local currentDrag = 50
local currentTension = 0

-- Progresso
local progressBar = Instance.new("Frame", screenGui)
progressBar.Size = UDim2.new(0.2, 0, 0.03, 0)
progressBar.Position = UDim2.new(0.4, 0, 0.75, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
local progressFill = Instance.new("Frame", progressBar)
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

Remotes.TensionUpdate.OnClientEvent:Connect(function(data)
    if typeof(data) == "table" then
        currentTension = data.Tension
        currentDrag = data.Drag or currentDrag -- Atualiza drag vindo do servidor
        barFill.Size = UDim2.new(data.Tension / 100, 0, 1, 0)
        progressFill.Size = UDim2.new(data.Progress / 100, 0, 1, 0)
        
        if data.IsRetrieving then
            infoLabel.Text = "RETRIEVING... | Drag: " .. math.floor(currentDrag) .. "%"
        else
            infoLabel.Text = "Drag: " .. math.floor(currentDrag) .. "% | Tension: " .. math.floor(currentTension) .. "%"
        end
    elseif typeof(data) == "table" and data.Type == "Alert" then
        infoLabel.Text = "!! FISGUE AGORA (Mouse1) !!"
    end
end)
