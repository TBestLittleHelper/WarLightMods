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
		
		--Capitals results in bigger city (fixed value for now)
		--Useful for Custom scenario, where players starts with a lot of territories
		if (territory.NumArmies.NumArmies == Mod.Settings.CustomSenarioCapitals) then
			structure[Cities] = 5;
			territory.Structures = structure;
			--Reset to 1, as we loop back to avg territories.
			structure[Cities] = 1;
		end
	end
end
