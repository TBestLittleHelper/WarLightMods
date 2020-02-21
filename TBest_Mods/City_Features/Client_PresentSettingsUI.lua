function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText('Percantage bonus for each city on a territory is: ' .. Mod.Settings.DefPower);
	UI.CreateLabel(vert).SetText('Bombcard reduces each city by: ' .. Mod.Settings.BombcardPower);
	UI.CreateLabel(vert).SetText('Capitals had this many armies in the custom senario distribution: ' .. Mod.Settings.CustomSenarioCapitals);
end

