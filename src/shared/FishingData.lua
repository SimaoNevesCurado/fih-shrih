-- FishingData.lua
-- Módulo de configuração para o sistema de pesca
local FishingData = {}

FishingData.Lures = {
	Bobber = {
		AttractionRate = 1.0, -- Multiplicador de tempo de espera (menor = mais rápido)
		RarityMod = 1.0,
		PreferredDepth = "Surface"
	},
	Crankbait = {
		AttractionRate = 0.8,
		RarityMod = 1.2,
		PreferredDepth = "Mid"
	},
	Spinnerbait = {
		AttractionRate = 1.2,
		RarityMod = 1.5,
		PreferredDepth = "Bottom"
	}
}

FishingData.Fishes = {
	{Name = "Bluegill", Rarity = 0.6, MinSize = 4, MaxSize = 10, BaseWeight = 0.5, FightForce = 10},
	{Name = "Largemouth Bass", Rarity = 0.3, MinSize = 10, MaxSize = 24, BaseWeight = 2.0, FightForce = 25},
	{Name = "Alligator Gar", Rarity = 0.1, MinSize = 30, MaxSize = 80, BaseWeight = 20.0, FightForce = 80}
}

-- Pré-processamento para Weighted Random Select (Prefix Sums)
local totalRarity = 0
for _, fish in ipairs(FishingData.Fishes) do
	totalRarity += fish.Rarity
	fish._threshold = totalRarity
end
FishingData.TotalRarity = totalRarity

function FishingData.GetRandomFish()
	local roll = math.random() * FishingData.TotalRarity
	for _, fish in ipairs(FishingData.Fishes) do
		if roll <= fish._threshold then
			return fish
		end
	end
	return FishingData.Fishes[1]
end

return FishingData
