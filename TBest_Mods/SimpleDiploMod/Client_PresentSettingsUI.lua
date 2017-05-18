function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert).SetText('This mod will only affect the game until turn ' .. Mod.Settings.NumTurns);
	UI.CreateLabel(vert).SetText('Turs from declering war until you can attack is ' .. Mod.Settings.NumTurns);
end
