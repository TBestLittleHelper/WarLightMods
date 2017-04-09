
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert).SetText('BonusValue = numTerritories +/- ' .. Mod.Settings.Amount);
	UI.CreateLabel(vert).SetText('Change negative bonuses ' .. Mod.Settings.changeNegative);
	UI.CreateLabel(vert).SetText('Change multiply ' .. Mod.Settings.changeMultiply);
end

