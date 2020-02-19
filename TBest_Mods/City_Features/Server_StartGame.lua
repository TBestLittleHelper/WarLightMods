function Server_StartGame(game, standing)	

	local structure = {}
	Cities = WL.StructureType.City
	structure[Cities] = 1;

	for _, territory in pairs(standing.Territories) do
		if (not territory.IsNeutral) then
			territory.Structures  = structure
		end
	end
end

