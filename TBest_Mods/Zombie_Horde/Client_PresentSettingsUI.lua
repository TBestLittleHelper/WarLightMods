
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	UI.CreateLabel(vert).SetText('Zombie Strength: ' .. Mod.Settings.ZombieStrength );
	UI.CreateLabel(vert).SetText('Zombie Starts: ' .. Mod.Settings.ZombieStarts);
	UI.CreateLabel(vert).SetText('Zombie Team members: ' .. Mod.Settings.ZombieTeam);
end