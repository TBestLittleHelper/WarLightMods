
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText('Armies added on EACH Zombie territory each turn:' .. Mod.Settings.ExtraArmies);
	if (Mod.Settings.RandomZombie == true) then
		UI.CreateLabel(vert).SetText('RandomZombie is set to ' .. tostring(Mod.Settings.RandomZombie));	
		UI.CreateLabel(vert).SetText('RandomZombie seed is ' .. tostring(Mod.Settings.RandomSeed));	
	else
		UI.CreateLabel(vert).SetText('The ZombieID is ' .. Mod.Settings.ZombieID);
	end
end

