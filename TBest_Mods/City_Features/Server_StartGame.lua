function Server_StartGame(game, standing)		
	--If we are not doing anything, return
	if (Mod.Settings.StartingCitiesActive == false and Mod.Settings.WastlandCities == false and Mod.Settings.CustomSenarioCapitals == false)then
		return;
	end
	
	--Make a city on all starting territories
	local structure = {}
	Cities = WL.StructureType.City
	structure[Cities] = Mod.Settings.NumberOfStartingCities;
	
	for _, territory in pairs(standing.Territories) do
		if (territory.IsNeutral == false and Mod.Settings.StartingCitiesActive == true) then
			--Players starts with a city
			territory.Structures  = structure
			
			elseif (territory.NumArmies.NumArmies == game.Settings.WastelandSize and Mod.Settings.WastlandCities == true) then
			--Wastelands starts with a city.
			structure[Cities] = 1;
			territory.Structures  = structure
			structure[Cities] = Mod.Settings.NumberOfStartingCities;	
		end
		
		--Capitals results in bigger city
		--Useful for Custom scenario, where players can start with a lot of territories
		if (territory.NumArmies.NumArmies == Mod.Settings.CustomSenarioCapitals) then
			structure[Cities] = Mod.Settings.CapitalExtraStartingCities;
			territory.Structures = structure;
			--Reset to 1, as we loop back to the next territory.
			structure[Cities] = Mod.Settings.NumberOfStartingCities;
		end
	end
end
