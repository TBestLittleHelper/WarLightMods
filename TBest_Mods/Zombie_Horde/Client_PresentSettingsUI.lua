
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText('Armies added on EACH Zombie territory each turn:' .. Mod.Settings.ExtraArmies);
end

