function Client_SaveConfigureUI(alert)
	Mod.Settings.FreeOrders = numberInputField.GetValue()
	if (Mod.Settings.FreeOrders < 0) then
		Mod.Settings.FreeOrders = 0
	end

	if (Mod.Settings.FreeOrders > 10) then
		Mod.Settings.FreeOrders = 10
	end
end
