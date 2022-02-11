function Client_SaveConfigureUI(alert)
	Mod.Settings.NumPortals = numberInputField.GetValue()
	if (Mod.Settings.NumPortals < 1) then
		Mod.Settings.NumPortals = 1
	end

	if (Mod.Settings.NumPortals > 3) then
		Mod.Settings.NumPortals = 3
	end
end
