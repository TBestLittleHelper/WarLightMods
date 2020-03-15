function Server_StartGame(game, standing)	
	--Make a city on all starting territories
	local structure = {}
	Cities = WL.StructureType.City
	structure[Cities] = 1;
	
	for _, territory in pairs(standing.Territories) do
		if (territory.IsNeutral == false and Mod.Settings.StartingCitiesActive == true) then
			--Players starts with a city
			territory.Structures  = structure
			
			elseif (territory.NumArmies.NumArmies == game.Settings.WastelandSize and Mod.Settings.WastlandCities == true) then
			--Wastelands starts with a city.
			territory.Structures  = structure	
		end
		
		--Capitals results in bigger city (fixed value for now)
		--Useful for Custom scenario, where players can start with a lot of territories
		if (territory.NumArmies.NumArmies == Mod.Settings.CustomSenarioCapitals) then
			structure[Cities] = 5;
			territory.Structures = structure;
			--Reset to 1, as we loop back to avg territories.
			structure[Cities] = 1;
		end
	end
end