function Server_StartGame(game, standing)
	local publicGameData = Mod.PublicGameData
	local territories = game.Map.Territories

	local keys = {}
	for key, value in pairs(territories) do
		keys[#keys + 1] = key --Store keys in another table
	end
	local index = math.random(1, #keys - 1)
	portalA = territories[keys[index]].ID
	portalB = territories[keys[index + 1]].ID

	publicGameData.portalA = portalA
	publicGameData.portalB = portalB

	Mod.PublicGameData = publicGameData

	local structure = {}
	Portals = WL.StructureType.Power
	structure[Portals] = 1
	standing.Territories[portalA].Structures = structure
	standing.Territories[portalB].Structures = structure
end
