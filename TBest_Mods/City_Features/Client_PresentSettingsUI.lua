function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	if (Mod.Settings.StartingCitiesActive) then
		UI.CreateLabel(vert).SetText('Number of cities in distributed territories ' .. Mod.Settings.NumberOfStartingCities);
	end
	if(Mod.Settings.CityWallsActive) then
		UI.CreateLabel(vert).SetText('Percantage bonus for each city on a territory is ' .. Mod.Settings.DefPower*100 .. '%');
	end
	if (Mod.Settings.CustomSenarioCapitals > 0) then
		UI.CreateLabel(vert).SetText('Capitals had this many armies in the custom senario distribution ' .. Mod.Settings.CustomSenarioCapitals);
		UI.CreateLabel(vert).SetText('Capitals started with ' .. Mod.Settings.CapitalExtraStartingCities .. 'cities');
	end
	if (Mod.Settings.BombcardActive) then
		UI.CreateLabel(vert).SetText('Bomb card reduces each city by ' .. Mod.Settings.BombcardPower);
	end
	if (Mod.Settings.BlockadeBuildCityActive) then
		UI.CreateLabel(vert).SetText('Blocade and Emergency Blocade card increase a city by  ' .. Mod.Settings.BlockadePower);
	end
	if (Mod.Settings.EMBActive) then
		UI.CreateLabel(vert).SetText('Emergency Blocade card can found a new city of size  ' .. Mod.Settings.EMBPower);
	end
	if (Mod.Settings.WastlandCities) then
		UI.CreateLabel(vert).SetText('Wastlands starts with a city');
	end
	if (Mod.Settings.CommerceFreeCityDeploy) then
		UI.CreateLabel(vert).SetText('Deploying armies on a city will give you twice as many armies. BUT will reduce your city by 1.');
	end
	if (Mod.Settings.CityDeployOnly) then
		UI.CreateLabel(vert).SetText('You can only deploy in cities');
	end
end