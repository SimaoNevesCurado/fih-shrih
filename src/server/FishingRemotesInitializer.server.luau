-- FishingRemotesInitializer.server.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Garante que a pasta existe ou cria
local RemoteFolder = ReplicatedStorage:FindFirstChild("FishingRemotes") or Instance.new("Folder")
RemoteFolder.Name = "FishingRemotes"
RemoteFolder.Parent = ReplicatedStorage

local function createRemote(name)
    local remote = RemoteFolder:FindFirstChild(name) or Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = RemoteFolder
end

createRemote("CastEvent")
createRemote("HookEvent")
createRemote("DragUpdateEvent")
createRemote("TensionUpdate")

print("DEBUG: FishingRemotes inicializados!")
