function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert).SetText('Can attack other players AFTER ' .. Mod.Settings.NumTurns .. ' turns without declering war');
end
