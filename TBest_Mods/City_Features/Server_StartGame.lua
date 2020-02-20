function Server_StartGame(game, standing)	
	--Make a city on all starting territories/pc=icks
	local structure = {}
	Cities = WL.StructureType.City
	structure[Cities] = 1;

	for _, territory in pairs(standing.Territories) do
		if (not territory.IsNeutral) then
		--Players starts with a city
			territory.Structures  = structure
		elseif (territory.NumArmies.NumArmies == game.Settings.WastelandSize) then
		--Wastelands starts with a city.
			territory.Structures  = structure		
		end
	end
end

