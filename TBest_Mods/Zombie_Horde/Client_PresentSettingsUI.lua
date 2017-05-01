
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText('Armies added on EACH Zombie territory each turn:' .. Mod.Settings.ExtraArmies);
	UI.CreateLabel(vert).SetText('The ZombieID is ' .. Mod.Settings.ZombieID);
end

