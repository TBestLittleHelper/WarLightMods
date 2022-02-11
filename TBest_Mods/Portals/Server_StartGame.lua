function Server_StartGame(game, standing)
	local privateGameData = Mod.PrivateGameData
	privateGameData.portals = {}
	territoryArray = {}

	local count = 1
	for _, territory in pairs(game.Map.Territories) do
		territoryArray[count] = territory
		count = count + 1
	end

	-- Check that the map has enough territories, else make the minimum number of portals
	local NumPortals = Mod.Settings.NumPortals
	if (#territoryArray < Mod.Settings.NumPortals * 2) then
		NumPortals = 1
	end

	structure = {}
	Portals = WL.StructureType.Power
	structure[Portals] = 0

	for i = 1, NumPortals * 2 do
		privateGameData.portals[i] = getRandomTerritory(territoryArray)
		if (i % 2 == 1) then
			structure[Portals] = structure[Portals] + 1
		end

		standing.Territories[privateGameData.portals[i]].Structures = structure
	end

	Mod.PrivateGameData = privateGameData
end

function getRandomTerritory(territoryArray)
	local index = math.random(#territoryArray)
	local territoryID = territoryArray[index].ID
	table.remove(territoryArray, index)

	return territoryID
end
