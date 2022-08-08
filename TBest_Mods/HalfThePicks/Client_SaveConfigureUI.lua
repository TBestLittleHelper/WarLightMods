function Client_SaveConfigureUI(alert)
	Mod.Settings.PickablePercent = numberInputField.GetValue()
	if (Mod.Settings.PickablePercent < 1) then
		Mod.Settings.PickablePercent = 1
	end

	if (Mod.Settings.PickablePercent > 99) then
		Mod.Settings.PickablePercent = 100
	end
end
