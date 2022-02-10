function Server_StartGame(game, standing)
	local publicGameData = Mod.PublicGameData
	publicGameData.portals = {}
	territoryArray = {}

	local count = 1
	-- TODO check that map has enough territories
	for _, territory in pairs(game.Map.Territories) do
		territoryArray[count] = territory
		count = count + 1
	end

	structure = {}
	Portals = WL.StructureType.Power
	structure[Portals] = 0

	--todo the 6 here should be a mod variable
	for i = 1, 6 do
		publicGameData.portals[i] = getRandomTerritory(territoryArray)
		if (i % 2 == 1) then
			structure[Portals] = structure[Portals] + 1
		end

		standing.Territories[publicGameData.portals[i]].Structures = structure
	end

	Mod.PublicGameData = publicGameData
end

function getRandomTerritory(territoryArray)
	local index = math.random(#territoryArray)
	local territoryID = territoryArray[index].ID
	table.remove(territoryArray, index)

	return territoryID
end
