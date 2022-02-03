function Server_StartGame(game, standing)
	publicGameData = Mod.PublicGameData

	territories = game.Map.Territories

	portalA = math.randomchoice(territories)
	territories[portalA.ID] = nil
	portalB = math.randomchoice(territories)

	print(portalA.Name)
	print(portalB.Name)
	publicGameData.portalA = portalA.ID
	publicGameData.portalB = portalB.ID

	Mod.PublicGameData = publicGameData

	local structure = {}
	Portals = WL.StructureType.Power
	structure[Portals] = 1
	standing.Territories[portalA.ID].Structures = structure
	standing.Territories[portalB.ID].Structures = structure
end

--https://gist.github.com/jdev6/1e7ff30671edf88d03d4
function math.randomchoice(t) --Selects a random item from a table
	local keys = {}
	for key, value in pairs(t) do
		keys[#keys + 1] = key --Store keys in another table
	end
	index = keys[math.random(1, #keys)]
	return t[index]
end
