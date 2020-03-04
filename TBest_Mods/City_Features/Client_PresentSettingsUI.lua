function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	if (Mod.Settings.BombcardActive) then
		UI.CreateLabel(vert).SetText('Bombcard reduces each city by ' .. Mod.Settings.BombcardPower);
	end
	--TODO add more settings
	-- if (Mod.Settings.StartingCitiesActive) then
	-- UI.CreateLabel(vert).SetText('Number of cities in distributed territories ' .. Mod.Settings.NumberOfStartingCities);
	-- end
	if(Mod.Settings.CityWallsActive) then
		UI.CreateLabel(vert).SetText('Percantage bonus for each city on a territory is ' .. Mod.Settings.DefPower*100 .. '%');
	end
	if (Mod.Settings.CustomSenarioCapitals) then
		UI.CreateLabel(vert).SetText('Capitals had this many armies in the custom senario distribution ' .. Mod.Settings.CustomSenarioCapitals);
		--UI.CreateLabel(vert).SetText('Capitals started with ' .. Mod.Settings.CapitalExtraStartingCities .. 'cities');
	end
	if (Mod.Settings.BlockadeBuildCityActive) then
		UI.CreateLabel(vert).SetText('Blocade and Emergency Blocade card increase a city by  ' .. Mod.Settings.BlockadePower);
	end
	if (Mod.Settings.WastlandCities) then
		UI.CreateLabel(vert).SetText('Wastlands starts with a city');
	end
	if (Mod.Settings.CommerceFreeCityDeploy) then
		UI.CreateLabel(vert).SetText('Deploying armies on a city will give you the gold back for the next turn');
	end
end