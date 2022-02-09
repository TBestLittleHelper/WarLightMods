function Server_StartGame(game, standing)
	local publicGameData = Mod.PublicGameData
	publicGameData.portals = {}
	territoryArray = {}

	local count = 1
	for _, territory in pairs(game.Map.Territories) do
		territoryArray[count] = territory
		count = count + 1
	end

	local structure = {}
	Portals = WL.StructureType.Power
	structure[Portals] = 1

	for i = 1, 4 do
		publicGameData.portals[i] = getRandomTerritory(territoryArray)
		standing.Territories[publicGameData.portals[i]].Structures = structure
	end

	Mod.PublicGameData = publicGameData
end

function getRandomTerritory(territoryArray)
	local index = math.random(#territoryArray)
	local territory = territoryArray[index]
	table.remove(territoryArray, index)

	return territory.ID
end
