
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	UI.CreateLabel(vert).SetText('Zombie Starting Armies on each territory: ' .. Mod.Settings.ZombieStrength );
	UI.CreateLabel(vert).SetText('Zombie Starting Bonus is worth: ' .. Mod.Settings.ZombieStarts);
	UI.CreateLabel(vert).SetText('Zombie(s) starts with this number of bonuses : ' .. Mod.Settings.StartingBonuses );
	UI.CreateLabel(vert).SetText('Zombie Team members: ' .. Mod.Settings.ZombieTeam);
end
