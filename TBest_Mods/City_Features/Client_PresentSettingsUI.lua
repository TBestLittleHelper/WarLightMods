function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	if (Mod.Settings.BombcardActive) then
	UI.CreateLabel(vert).SetText('Percantage bonus for each city on a territory is: ' .. Mod.Settings.DefPower);
	end
	if (Mod.Settings.StartingCitiesActive) then
	UI.CreateLabel(vert).SetText('Bombcard reduces each city by: ' .. Mod.Settings.BombcardPower);
	end
	if (Mod.Settings.BlockadeBuildCityActive) then
	UI.CreateLabel(vert).SetText('Capitals had this many armies in the custom senario distribution: ' .. Mod.Settings.CustomSenarioCapitals);
	end
end
